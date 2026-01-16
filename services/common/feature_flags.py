"""
Feature Flags System
Controlled degradation and safe feature rollout.
"""

import os
import json
import logging
from typing import Optional

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class FeatureFlags:
    """
    Feature flag system for safe rollouts and kill switches.
    """
    
    # Default flag values
    DEFAULTS = {
        # Kill switches
        "llm_enabled": True,
        "personalization_enabled": True,
        "detailed_explanations": True,
        
        # Feature rollouts
        "new_model_v2": False,
        "batch_inference": False,
        
        # Operational
        "degraded_mode": False,
        "read_only_mode": False,
        "rate_limiting_strict": False,
    }
    
    def __init__(self, config_path: Optional[str] = None):
        self._flags = self.DEFAULTS.copy()
        self._overrides: dict[str, bool] = {}
        
        # Load from environment
        self._load_from_env()
        
        # Load from config file if exists
        if config_path:
            self._load_from_file(config_path)
        
        logger.info(f"Feature flags initialized: {len(self._flags)} flags")
    
    def _load_from_env(self):
        """Load flag overrides from environment variables."""
        for flag in self.DEFAULTS:
            env_key = f"FF_{flag.upper()}"
            env_value = os.getenv(env_key)
            if env_value is not None:
                self._overrides[flag] = env_value.lower() in ("true", "1", "yes")
                logger.info(f"Flag {flag} overridden by env: {self._overrides[flag]}")
    
    def _load_from_file(self, path: str):
        """Load flags from JSON config file."""
        try:
            with open(path) as f:
                config = json.load(f)
                for flag, value in config.get("flags", {}).items():
                    if flag in self.DEFAULTS:
                        self._overrides[flag] = bool(value)
        except FileNotFoundError:
            logger.warning(f"Feature flags config not found: {path}")
        except json.JSONDecodeError:
            logger.error(f"Invalid feature flags config: {path}")
    
    def is_enabled(self, flag: str) -> bool:
        """
        Check if a feature flag is enabled.
        
        Priority: overrides > defaults
        """
        if flag in self._overrides:
            return self._overrides[flag]
        return self._flags.get(flag, False)
    
    def set_flag(self, flag: str, enabled: bool):
        """Set a flag value (runtime override)."""
        self._overrides[flag] = enabled
        logger.info(f"Flag {flag} set to {enabled}")
    
    def get_all(self) -> dict[str, bool]:
        """Get all flag values."""
        result = self._flags.copy()
        result.update(self._overrides)
        return result
    
    def __getattr__(self, name: str) -> bool:
        """Allow attribute access for flags."""
        if name.startswith("_"):
            raise AttributeError(name)
        return self.is_enabled(name)


# Global feature flags instance
flags = FeatureFlags()


# Convenience functions
def is_enabled(flag: str) -> bool:
    """Check if feature is enabled."""
    return flags.is_enabled(flag)


def disable(flag: str):
    """Disable a feature (kill switch)."""
    flags.set_flag(flag, False)
    logger.warning(f"Feature disabled: {flag}")


def enable(flag: str):
    """Enable a feature."""
    flags.set_flag(flag, True)
    logger.info(f"Feature enabled: {flag}")


# Kill switch shortcuts
def disable_llm():
    """Emergency LLM disable."""
    disable("llm_enabled")


def enable_degraded_mode():
    """Enable degraded mode (reduced functionality)."""
    flags.set_flag("degraded_mode", True)
    flags.set_flag("llm_enabled", False)
    flags.set_flag("detailed_explanations", False)
    logger.warning("DEGRADED MODE ENABLED")
