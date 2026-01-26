"""
Routes for managing device tokens for push notifications.
"""

from flask import Blueprint, jsonify, current_app, request
from app.models.device_token import DeviceTokenModel

device_routes = Blueprint("device_routes", __name__)


@device_routes.route("/register", methods=["POST"])
def register_device():
    """
    Register a device token for push notifications.
    
    Body:
        device_token: The APNs device token (required)
        username: Optional username to associate with the token
        
    Returns:
        201: Token registered successfully
        400: Missing device token
    """
    try:
        data = request.get_json() or {}
        device_token = data.get("device_token")
        username = data.get("username")
        
        if not device_token:
            return jsonify({"message": "device_token is required"}), 400
        
        # Validate token format (should be 64 hex characters for APNs)
        if not isinstance(device_token, str) or len(device_token) < 32:
            return jsonify({"message": "Invalid device token format"}), 400
        
        model = DeviceTokenModel(current_app.mongo)
        success = model.register_token(device_token, username)
        
        if success:
            return jsonify({"message": "Device registered successfully"}), 201
        else:
            return jsonify({"message": "Failed to register device"}), 500
            
    except Exception as e:
        return jsonify({"message": "Error registering device", "error": str(e)}), 400


@device_routes.route("/unregister", methods=["POST"])
def unregister_device():
    """
    Unregister a device token (stop receiving notifications).
    
    Body:
        device_token: The APNs device token to remove
        
    Returns:
        200: Token removed successfully
        400: Missing device token
        404: Token not found
    """
    try:
        data = request.get_json() or {}
        device_token = data.get("device_token")
        
        if not device_token:
            return jsonify({"message": "device_token is required"}), 400
        
        model = DeviceTokenModel(current_app.mongo)
        success = model.unregister_token(device_token)
        
        if success:
            return jsonify({"message": "Device unregistered successfully"}), 200
        else:
            return jsonify({"message": "Device token not found"}), 404
            
    except Exception as e:
        return jsonify({"message": "Error unregistering device", "error": str(e)}), 400


@device_routes.route("/update-user", methods=["POST"])
def update_device_user():
    """
    Associate a device token with a user (call after login).
    
    Body:
        device_token: The APNs device token
        username: The username to associate
        
    Returns:
        200: Token updated successfully
        400: Missing required fields
    """
    try:
        data = request.get_json() or {}
        device_token = data.get("device_token")
        username = data.get("username")
        
        if not device_token or not username:
            return jsonify({"message": "device_token and username are required"}), 400
        
        model = DeviceTokenModel(current_app.mongo)
        success = model.update_token_user(device_token, username)
        
        if success:
            return jsonify({"message": "Device user updated successfully"}), 200
        else:
            # Token might not exist yet, try registering it
            success = model.register_token(device_token, username)
            if success:
                return jsonify({"message": "Device registered with user"}), 201
            return jsonify({"message": "Failed to update device"}), 404
            
    except Exception as e:
        return jsonify({"message": "Error updating device user", "error": str(e)}), 400


@device_routes.route("/count", methods=["GET"])
def get_device_count():
    """
    Get the count of registered devices (for admin/debugging).
    
    Returns:
        200: Count of active device tokens
    """
    try:
        model = DeviceTokenModel(current_app.mongo)
        count = model.get_token_count()
        return jsonify({"count": count}), 200
    except Exception as e:
        return jsonify({"message": "Error getting device count", "error": str(e)}), 400
