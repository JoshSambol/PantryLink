from flask import Blueprint, jsonify, current_app, request
from app.models.volunteer import volunteer_model
from bson import ObjectId

volunteer_routes = Blueprint("volunteer_routes", __name__)

# Define a simple route inside this blueprint

@volunteer_routes.route("/create", methods=["POST"])
def create_volunteer():
    try:
        data = request.get_json()
        username = data["username"]
        first_name = data["first_name"]
        last_name = data["last_name"]
        date_of_birth = data["date_of_birth"]
        email = data["email"]
        phone_number = data["phone_number"]
        zipcode = data["zipcode"]
        roles = data["roles"]
        availability = data["availability"]
        emergency_name = data["emergency_name"]
        emergency_number = data["emergency_number"]
        verified = "False" 
        
        new_volunteer = volunteer_model(current_app.mongo)

        response = new_volunteer.create_volunteer(username, first_name, last_name, date_of_birth, email, phone_number, zipcode, roles, availability, emergency_name, emergency_number, verified)

    except Exception as e:
        return jsonify({"message": "Error creating volunteer", "error": str(e)}), 400
    
    return jsonify(
        {
            "_id": response,
        }
    ), 201

@volunteer_routes.route("/update/<string:volunteer_id>", methods=["PUT"])
def update_volunteer(volunteer_id):
    try: 
        data = request.get_json()

        update_data = {
            "username": data["username"],
            "first_name": data["first_name"],
            "last_name": data["last_name"],
            "date_of_birth": data["date_of_birth"],
            "email": data["email"],
            "phone_number": data["phone_number"],
            "zipcode": data["zipcode"],
            "roles": data["roles"],
            "availability": data["availability"],
            "emergency_name": data["emergency_name"],
            "emergency_number": data["emergency_number"],
            "verified": data["verified"]
        }

        new_volunteer = volunteer_model(current_app.mongo)
        response = new_volunteer.update_volunteer(ObjectId(volunteer_id), update_data)

    except Exception as e:
        return jsonify({"message": "Error updating volunteer", "error": str(e)}), 400
    
    return jsonify({"_id": volunteer_id}), 200

@volunteer_routes.route("/get", methods=["GET"])
def get_volunteers():
    try:
        volunteer_instance = volunteer_model(current_app.mongo)
        volunteers = volunteer_instance.get_volunteers()

    except Exception as e:
        return jsonify({"message": "Error getting volunteers", "error": str(e)}), 400
    
    return jsonify(volunteers)

@volunteer_routes.route("/delete/<string:volunteer_id>", methods=["DELETE"])
def delete_volunteer(volunteer_id):
    try:
        volunteer = volunteer_model(current_app.mongo)
        response = volunteer.delete_volunteer(ObjectId(volunteer_id))

    except Exception as e:
        return jsonify({"message": "Error deleting volunteer", "error": str(e)}), 400
    
    return jsonify({"_id": volunteer_id})

@volunteer_routes.route("/check/<string:username>", methods=["GET"])
def check_volunteer_exists(username):
    """Check if a volunteer account already exists for the given username"""
    try:
        volunteer_instance = volunteer_model(current_app.mongo)
        existing_volunteer = volunteer_instance.find_volunteer_by_username(username)
        
        if existing_volunteer:
            return jsonify({
                "exists": True,
                "message": "A volunteer account already exists for this username"
            }), 200
        else:
            return jsonify({
                "exists": False,
                "message": "No volunteer account found for this username"
            }), 200

    except Exception as e:
        return jsonify({"message": "Error checking volunteer", "error": str(e)}), 400