import json
import logging
from datetime import datetime
from typing import Dict, Optional

from confluent_kafka import Consumer, KafkaError, Message
from pydantic import BaseModel, ValidationError
from sqlalchemy import Column, String, DateTime, Integer
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import Session

# Configure logging
logger = logging.getLogger(__name__)

Base = declarative_base()

# --- 1. Pydantic Model ---
class InstagramEvent(BaseModel):
    post_id: str
    caption: str
    timestamp: datetime
    media_url: str
    platform_user_id: str

# --- 2. SQLAlchemy Model ---
class RawSocialEvent(Base):
    __tablename__ = 'raw_social_events'

    id = Column(Integer, primary_key=True, autoincrement=True)
    post_id = Column(String, nullable=False)
    caption = Column(String, nullable=False)
    timestamp = Column(DateTime, nullable=False)
    media_url = Column(String, nullable=False)
    platform_user_id = Column(String, nullable=False)
    processed_at = Column(DateTime, nullable=True)

# --- 3. Consumer Class ---
class InstagramConsumer:
    def __init__(self, conf: Dict, db_session: Session):
        """
        Initialize the Instagram Consumer.
        
        Args:
            conf: Kafka configuration dictionary.
            db_session: SQLAlchemy Session for database operations.
        """
        self.consumer = Consumer(conf)
        self.db_session = db_session
        self.running = True
        
        # Subscribe to the topic
        self.consumer.subscribe(['platform.instagram.events'])

    def run(self):
        """
        Main consumer loop.
        Polls for messages, validates them, and inserts into the database.
        """
        logger.info("Starting InstagramConsumer...")
        try:
            while self.running:
                # 1. Poll for messages (timeout=1.0)
                msg: Optional[Message] = self.consumer.poll(1.0)

                if msg is None:
                    continue

                # 2. If message error, log it
                if msg.error():
                    if msg.error().code() == KafkaError._PARTITION_EOF:
                        # End of partition event
                        continue
                    else:
                        logger.error(f"Consumer error: {msg.error()}")
                        continue

                try:
                    # 3. json.loads the value
                    message_value = msg.value().decode('utf-8')
                    data = json.loads(message_value)

                    # 4. Validate with InstagramEvent Pydantic model
                    event = InstagramEvent(**data)

                    # 5. If valid, insert into Postgres using db_session
                    db_record = RawSocialEvent(
                        post_id=event.post_id,
                        caption=event.caption,
                        timestamp=event.timestamp,
                        media_url=event.media_url,
                        platform_user_id=event.platform_user_id
                    )
                    self.db_session.add(db_record)
                    
                    # 6. Commit transaction
                    self.db_session.commit()
                    
                    # 7. Manual commit offset to Kafka
                    self.consumer.commit(message=msg, asynchronous=False)

                except ValidationError as ve:
                    # Error Handling (The Guardrails)
                    # Log strict error
                    logger.error(f"Schema Violation: {ve}")
                    
                    # Ensure DB session is clean
                    self.db_session.rollback()
                    
                    # DO commit offset (skip the bad message)
                    self.consumer.commit(message=msg, asynchronous=False)
                
                except Exception as e:
                    # Handle other unexpected errors
                    logger.error(f"Unexpected error processing message: {e}")
                    self.db_session.rollback()
                    # Not commiting offset here to allow retry depending on policy, 
                    # but forcing loop to continue.

        except Exception as e:
            logger.critical(f"Critical consumer failure: {e}")
        finally:
            logger.info("Closing consumer...")
            self.consumer.close()
