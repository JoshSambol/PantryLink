"""
Device Token model for storing APNs device tokens.
Tokens are stored separately from users to support:
- Multiple devices per user
- Anonymous users who still want notifications
- Easy cleanup of invalid tokens
"""

from flask_pymongo import PyMongo
from datetime import datetime


class DeviceTokenModel:
    """Model for managing APNs device tokens."""
    
    def __init__(self, mongo: PyMongo):
        self.collection = mongo.cx["test"]["device_tokens"]
        # Ensure index on device_token for fast lookups and uniqueness
        self.collection.create_index("device_token", unique=True)
    
    def register_token(self, device_token, username=None):
        """
        Register a device token, optionally associated with a user.
        Uses upsert to handle both new registrations and updates.
        
        Args:
            device_token: The APNs device token string
            username: Optional username to associate with the token
            
        Returns:
            bool: True if successful
        """
        try:
            now = datetime.utcnow()
            
            result = self.collection.update_one(
                {"device_token": device_token},
                {
                    "$set": {
                        "device_token": device_token,
                        "username": username,
                        "updated_at": now,
                        "active": True,
                    },
                    "$setOnInsert": {
                        "created_at": now,
                    }
                },
                upsert=True
            )
            
            return True
        except Exception as e:
            print(f"Error registering device token: {e}")
            return False
    
    def unregister_token(self, device_token):
        """
        Remove a device token from the database.
        
        Args:
            device_token: The APNs device token to remove
            
        Returns:
            bool: True if token was found and removed
        """
        result = self.collection.delete_one({"device_token": device_token})
        return result.deleted_count > 0
    
    def deactivate_token(self, device_token):
        """
        Mark a token as inactive (instead of deleting).
        Useful for tracking invalid tokens from APNs feedback.
        
        Args:
            device_token: The APNs device token to deactivate
            
        Returns:
            bool: True if token was found and updated
        """
        result = self.collection.update_one(
            {"device_token": device_token},
            {"$set": {"active": False, "deactivated_at": datetime.utcnow()}}
        )
        return result.modified_count > 0
    
    def get_all_active_tokens(self):
        """
        Get all active device tokens for sending notifications.
        
        Returns:
            list: List of device token strings
        """
        tokens = self.collection.find(
            {"active": True},
            {"device_token": 1, "_id": 0}
        )
        return [t["device_token"] for t in tokens]
    
    def get_tokens_for_user(self, username):
        """
        Get all device tokens for a specific user.
        
        Args:
            username: The username to look up
            
        Returns:
            list: List of device token strings
        """
        tokens = self.collection.find(
            {"username": username, "active": True},
            {"device_token": 1, "_id": 0}
        )
        return [t["device_token"] for t in tokens]
    
    def update_token_user(self, device_token, username):
        """
        Associate a device token with a user (e.g., after login).
        
        Args:
            device_token: The device token to update
            username: The username to associate
            
        Returns:
            bool: True if token was found and updated
        """
        result = self.collection.update_one(
            {"device_token": device_token},
            {"$set": {"username": username, "updated_at": datetime.utcnow()}}
        )
        return result.modified_count > 0
    
    def get_token_count(self):
        """Get the count of active device tokens."""
        return self.collection.count_documents({"active": True})
    
    def cleanup_old_inactive_tokens(self, days=30):
        """
        Remove tokens that have been inactive for more than specified days.
        
        Args:
            days: Number of days after which to remove inactive tokens
            
        Returns:
            int: Number of tokens removed
        """
        from datetime import timedelta
        cutoff = datetime.utcnow() - timedelta(days=days)
        
        result = self.collection.delete_many({
            "active": False,
            "deactivated_at": {"$lt": cutoff}
        })
        return result.deleted_count
