"""
Apple Push Notification Service (APNs) integration for PantryLink.
Sends push notifications to iOS devices when new stream announcements are made.
"""

import jwt
import time
import json
import http.client
import os
from datetime import datetime, timedelta


class APNsService:
    """Service for sending push notifications via Apple Push Notification Service."""
    
    # APNs endpoints
    APNS_DEVELOPMENT_SERVER = "api.sandbox.push.apple.com"
    APNS_PRODUCTION_SERVER = "api.push.apple.com"
    
    def __init__(self):
        """Initialize the APNs service with credentials from environment variables."""
        self.team_id = os.environ.get("APNS_TEAM_ID")
        self.key_id = os.environ.get("APNS_KEY_ID")
        self.private_key = os.environ.get("APNS_PRIVATE_KEY")
        self.bundle_id = os.environ.get("APNS_BUNDLE_ID", "com.tcsm.pantrylink")
        self.use_sandbox = os.environ.get("APNS_USE_SANDBOX", "true").lower() == "true"
        
        # Cache for the JWT token
        self._token = None
        self._token_expires_at = 0
    
    def is_configured(self):
        """Check if APNs credentials are configured."""
        return all([self.team_id, self.key_id, self.private_key])
    
    def _get_token(self):
        """Generate or return cached JWT token for APNs authentication."""
        current_time = time.time()
        
        # Refresh token if expired (tokens are valid for 1 hour, refresh at 50 mins)
        if self._token is None or current_time >= self._token_expires_at:
            self._token = self._generate_token()
            self._token_expires_at = current_time + (50 * 60)  # 50 minutes
        
        return self._token
    
    def _generate_token(self):
        """Generate a new JWT token for APNs authentication."""
        if not self.is_configured():
            raise ValueError("APNs credentials not configured")
        
        # Handle private key - it may come with escaped newlines from env var
        private_key = self.private_key
        if "\\n" in private_key:
            private_key = private_key.replace("\\n", "\n")
        
        headers = {
            "alg": "ES256",
            "kid": self.key_id,
        }
        
        payload = {
            "iss": self.team_id,
            "iat": int(time.time()),
        }
        
        token = jwt.encode(payload, private_key, algorithm="ES256", headers=headers)
        return token
    
    def send_notification(self, device_token, title, body, data=None):
        """
        Send a push notification to a single device.
        
        Args:
            device_token: The APNs device token
            title: Notification title
            body: Notification body text
            data: Optional custom data dictionary
            
        Returns:
            tuple: (success: bool, error_message: str or None)
        """
        if not self.is_configured():
            print("APNs not configured - skipping notification")
            return False, "APNs credentials not configured"
        
        try:
            # Build the notification payload
            payload = {
                "aps": {
                    "alert": {
                        "title": title,
                        "body": body,
                    },
                    "sound": "default",
                    "badge": 1,
                },
            }
            
            # Add custom data if provided
            if data:
                payload["data"] = data
            
            payload_json = json.dumps(payload)
            
            # Get the appropriate server
            server = self.APNS_DEVELOPMENT_SERVER if self.use_sandbox else self.APNS_PRODUCTION_SERVER
            
            # Create HTTPS connection
            conn = http.client.HTTPSConnection(server, 443)
            
            # Set up headers
            headers = {
                "authorization": f"bearer {self._get_token()}",
                "apns-topic": self.bundle_id,
                "apns-push-type": "alert",
                "apns-priority": "10",  # Immediate delivery
                "content-type": "application/json",
            }
            
            # Send the request
            path = f"/3/device/{device_token}"
            conn.request("POST", path, payload_json, headers)
            
            # Get response
            response = conn.getresponse()
            response_body = response.read().decode("utf-8")
            
            conn.close()
            
            if response.status == 200:
                print(f"Push notification sent successfully to {device_token[:20]}...")
                return True, None
            else:
                error_msg = f"APNs error {response.status}: {response_body}"
                print(error_msg)
                return False, error_msg
                
        except Exception as e:
            error_msg = f"Failed to send push notification: {str(e)}"
            print(error_msg)
            return False, error_msg
    
    def send_bulk_notifications(self, device_tokens, title, body, data=None):
        """
        Send push notifications to multiple devices.
        
        Args:
            device_tokens: List of APNs device tokens
            title: Notification title
            body: Notification body text
            data: Optional custom data dictionary
            
        Returns:
            dict: {"success_count": int, "failure_count": int, "failures": list}
        """
        results = {
            "success_count": 0,
            "failure_count": 0,
            "failures": [],
        }
        
        if not device_tokens:
            return results
        
        for token in device_tokens:
            success, error = self.send_notification(token, title, body, data)
            if success:
                results["success_count"] += 1
            else:
                results["failure_count"] += 1
                results["failures"].append({
                    "token": token[:20] + "..." if len(token) > 20 else token,
                    "error": error,
                })
        
        print(f"Bulk notification results: {results['success_count']} sent, {results['failure_count']} failed")
        return results


# Singleton instance
_apns_service = None


def get_apns_service():
    """Get the singleton APNs service instance."""
    global _apns_service
    if _apns_service is None:
        _apns_service = APNsService()
    return _apns_service


def send_stream_notification(pantry_name, message, device_tokens):
    """
    Convenience function to send a stream notification to all devices.
    
    Args:
        pantry_name: Name of the pantry making the announcement
        message: The stream message content
        device_tokens: List of device tokens to notify
        
    Returns:
        dict: Results of the bulk notification
    """
    service = get_apns_service()
    
    title = f"{pantry_name}"
    body = message
    
    # Truncate body if too long (APNs has payload size limits)
    if len(body) > 200:
        body = body[:197] + "..."
    
    data = {
        "type": "stream_update",
        "pantry_name": pantry_name,
    }
    
    return service.send_bulk_notifications(device_tokens, title, body, data)
