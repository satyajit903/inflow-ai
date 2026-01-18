from typing import Dict, Any, Optional
import httpx
import logging

logger = logging.getLogger(__name__)

class ProfileError(Exception):
    """Base exception for ProfileClient"""
    pass

class ProfileNotFoundError(ProfileError):
    """Raised when the profile is not found (404)"""
    pass

class ProfileServiceError(ProfileError):
    """Raised for 500s, timeouts, or other connection errors"""
    pass

class ProfileClient:
    def __init__(self, base_url: str):
        """
        Initialize the ProfileClient.
        
        Args:
            base_url: The base URL of the Profile Service (e.g., "http://profile-service:8000")
        """
        self.base_url = base_url.rstrip("/")

    async def get_creator_profile(self, user_id: str) -> Dict[str, Any]:
        """
        Fetch a creator's profile by user_id.

        Args:
            user_id: The ID of the user to fetch.

        Returns:
            Dict containing the profile data.

        Raises:
            ProfileNotFoundError: If the user is not found.
            ProfileServiceError: If the service is down, times out, or returns 500.
        """
        url = f"{self.base_url}/profiles/{user_id}"
        
        try:
            async with httpx.AsyncClient() as client:
                # Enforce timeouts: hard timeout of 2.0 seconds
                response = await client.get(url, timeout=2.0)
                
                if response.status_code == 200:
                    return response.json()
                elif response.status_code == 404:
                    raise ProfileNotFoundError(f"Profile not found for user_id: {user_id}")
                else:
                    # 500 or other unexpected status codes
                    logger.error(f"Profile Service error: {response.status_code} - {response.text}")
                    raise ProfileServiceError(f"Profile Service failed with status {response.status_code}")

        except httpx.TimeoutException:
            logger.error(f"Profile Service timeout for user_id: {user_id}")
            raise ProfileServiceError("Profile Service timed out")
        except httpx.RequestError as e:
            logger.error(f"Profile Service connection error: {e}")
            raise ProfileServiceError(f"Profile Service connection failed: {str(e)}")
