from flask_pymongo import PyMongo
from datetime import datetime, timedelta

class pantry_model: 
    def __init__(self, mongo: PyMongo):
        self.collection = mongo.cx["test"]["pantries"]
    
    def get_user_week_schedule(self, username: str, from_date: str, to_date: str):
        """
        Get all schedule entries for a user across all pantries within a date range.
        Returns list of {pantry_id, pantry_name, date, shift (or 'General'), time}.
        """
        # Find all pantries and check their schedules for this user
        pantries = list(self.collection.find({}, {"_id": 1, "name": 1, "schedules": 1}))
        results = []
        
        for pantry in pantries:
            pantry_id = str(pantry["_id"])
            pantry_name = pantry.get("name", "Unknown Pantry")
            schedules = pantry.get("schedules", {})
            
            if not isinstance(schedules, dict):
                continue
                
            for date_key, day_schedule in schedules.items():
                # Check if date is within range
                if date_key < from_date or date_key > to_date:
                    continue
                
                if not isinstance(day_schedule, dict):
                    continue
                
                # Check shifts
                shifts = day_schedule.get("shifts", [])
                for shift in shifts:
                    volunteers = shift.get("volunteers", [])
                    for vol in volunteers:
                        vol_username = vol.get("username", "")
                        if vol_username and vol_username.lower() == username.lower():
                            results.append({
                                "pantry_id": pantry_id,
                                "pantry_name": pantry_name,
                                "date": date_key,
                                "shift": shift.get("shift", "Unknown Shift"),
                                "time": shift.get("time", "")
                            })
                
                # Check general volunteers
                general_volunteers = day_schedule.get("general_volunteers", [])
                for vol in general_volunteers:
                    vol_username = vol.get("username", "")
                    if vol_username and vol_username.lower() == username.lower():
                        results.append({
                            "pantry_id": pantry_id,
                            "pantry_name": pantry_name,
                            "date": date_key,
                            "shift": "General",
                            "time": "Flexible"
                        })
        
        return results
    
    def check_user_scheduled_on_date(self, username: str, date_key: str, exclude_pantry_id=None):
        """
        Check if a user is already scheduled at any pantry on a given date.
        Returns {scheduled: bool, pantry_name: str or None, pantry_id: str or None}
        """
        from bson import ObjectId
        
        pantries = list(self.collection.find({}, {"_id": 1, "name": 1, "schedules": 1}))
        
        for pantry in pantries:
            pantry_id = str(pantry["_id"])
            
            # Skip the pantry we're trying to add to (if specified)
            if exclude_pantry_id and pantry_id == str(exclude_pantry_id):
                continue
                
            pantry_name = pantry.get("name", "Unknown Pantry")
            schedules = pantry.get("schedules", {})
            
            if not isinstance(schedules, dict):
                continue
            
            day_schedule = schedules.get(date_key)
            if not day_schedule or not isinstance(day_schedule, dict):
                continue
            
            # Check shifts
            shifts = day_schedule.get("shifts", [])
            for shift in shifts:
                volunteers = shift.get("volunteers", [])
                for vol in volunteers:
                    vol_username = vol.get("username", "")
                    if vol_username and vol_username.lower() == username.lower():
                        return {
                            "scheduled": True,
                            "pantry_name": pantry_name,
                            "pantry_id": pantry_id
                        }
            
            # Check general volunteers
            general_volunteers = day_schedule.get("general_volunteers", [])
            for vol in general_volunteers:
                vol_username = vol.get("username", "")
                if vol_username and vol_username.lower() == username.lower():
                    return {
                        "scheduled": True,
                        "pantry_name": pantry_name,
                        "pantry_id": pantry_id
                    }
        
        return {"scheduled": False, "pantry_name": None, "pantry_id": None}

    def create_pantry(self, name, address, email, phone_number, password, username=None, website=None):
        pantry_data = {
            "name": name,
            "address": address, 
            "email": email,
            "phone_number": phone_number,
            "password": password,
            "username": username or email,  # Use email as username if not provided
            "website": website,
            "stream": []
        }
        result = self.collection.insert_one(pantry_data)
        return str(result.inserted_id)

    def update_pantry(self, pantry_id, update_data):
        result = self.collection.update_one({"_id": pantry_id}, {"$set": update_data})
        return result
    
    def get_stock(self, pantry_id):
        return (
            self.collection.aggregate(
                [
                    {
                        "$match": {"_id": pantry_id}
                    },
                    {
                        "$project": {
                            "_id": 0,
                            "name": 0,
                            "address": 0,
                            "email": 0, 
                            "phone_number": 0,
                            "password": 0,
                        }
                    }
                ]
            )
        )
    def find_user_by_username(self, username):
        # Use a simple projection; convert ObjectId to string at the route level
        return self.collection.find_one(
            {"username": username},
            {"username": 1, "password": 1, "_id": {"$toString": "$_id"}},
        )
    
    def add_inventory_item(self, pantry_id, item):
        """Add a new inventory item to the pantry"""
        # Use upsert to create the stock array if it doesn't exist
        result = self.collection.update_one(
            {"_id": pantry_id},
            {"$push": {"stock": item}},
            upsert=False
        )
        # If the document exists but stock field doesn't, create it
        if result.matched_count > 0 and result.modified_count == 0:
            # Check if stock field exists
            pantry = self.collection.find_one({"_id": pantry_id}, {"stock": 1})
            if pantry and "stock" not in pantry:
                # Create the stock array with the first item
                result = self.collection.update_one(
                    {"_id": pantry_id},
                    {"$set": {"stock": [item]}}
                )
        return result.modified_count > 0
    
    def update_inventory_item(self, pantry_id, item_name, new_quantities):
        """Update an inventory item's quantities"""
        result = self.collection.update_one(
            {"_id": pantry_id, "stock.name": item_name},
            {"$set": {"stock.$.current": new_quantities["current"], "stock.$.full": new_quantities["full"]}}
        )
        return result.modified_count > 0
    
    def delete_inventory_item(self, pantry_id, item_name):
        """Remove an inventory item from the pantry"""
        result = self.collection.update_one(
            {"_id": pantry_id},
            {"$pull": {"stock": {"name": item_name}}}
        )
        return result.modified_count > 0
    
    def get_all_inventory(self, pantry_id):
        """Get all inventory items for a pantry"""
        pantry = self.collection.find_one(
            {"_id": pantry_id},
            {"stock": 1, "_id": 0}
        )
        return pantry.get("stock", []) if pantry else []
    
    def get_pantry_info(self, pantry_id):
        """Get pantry information (name, address, email, phone, website)"""
        pantry = self.collection.find_one(
            {"_id": pantry_id},
            {"name": 1, "address": 1, "email": 1, "phone_number": 1, "website": 1, "username": 1, "stream": 1, "_id": 0}
        )
        return pantry

    def post_stream_message(self, pantry_id, message: str):
        """Post a message to the pantry's stream and return the updated stream."""
        now = datetime.now().strftime("%m/%d/%Y %I:%M %p")
        result = self.collection.update_one(
            {"_id": pantry_id},
            {"$push": {"stream": {"date": now, "message": message}}}
        )
        if result.matched_count == 0:
            return None
        pantry = self.collection.find_one({"_id": pantry_id}, {"stream": 1, "_id": 0})
        return pantry.get("stream", [])

    def delete_stream_item(self, pantry_id, index: int):
        """Delete a stream item by index and return the updated stream."""
        # First unset the array element at index, then pull nulls
        unset_result = self.collection.update_one(
            {"_id": pantry_id},
            {"$unset": {f"stream.{index}": 1}}
        )
        if unset_result.matched_count == 0:
            return None
        self.collection.update_one({"_id": pantry_id}, {"$pull": {"stream": None}})
        pantry = self.collection.find_one({"_id": pantry_id}, {"stream": 1, "_id": 0})
        return pantry.get("stream", [])

    # --- Volunteer Schedules ---
    def get_schedule_for_date(self, pantry_id, date_key: str, auto_generate: bool = True):
        """
        Return schedule for a specific date key (YYYY-MM-DD).
        New format: { shifts: [...], general_volunteers: [...] }
        If auto_generate is True and schedule doesn't exist, generate from default template.
        """
        pantry = self.collection.find_one(
            {"_id": pantry_id},
            {f"schedules.{date_key}": 1, "schedule_settings": 1, "_id": 0}
        )
        
        schedules = pantry.get("schedules", {}) if pantry else {}
        existing_schedule = schedules.get(date_key)
        
        # If schedule exists, return it (handle legacy format)
        if existing_schedule is not None:
            # Handle legacy format (array of shifts)
            if isinstance(existing_schedule, list):
                return {
                    "shifts": existing_schedule,
                    "general_volunteers": []
                }
            return existing_schedule
        
        # If no schedule exists and auto_generate is enabled, try to create from default
        if auto_generate:
            generated = self._auto_generate_schedule(pantry_id, date_key, pantry)
            if generated:
                return generated
        
        # Return empty schedule structure
        return {"shifts": [], "general_volunteers": []}
    
    def _auto_generate_schedule(self, pantry_id, date_key: str, pantry_doc=None):
        """
        Auto-generate a schedule from the default template if conditions are met.
        Uses upsert with $setOnInsert for idempotent, concurrency-safe generation.
        """
        if pantry_doc is None:
            pantry_doc = self.collection.find_one(
                {"_id": pantry_id},
                {"schedule_settings": 1}
            )
        
        if not pantry_doc:
            return None
        
        settings = pantry_doc.get("schedule_settings", {})
        
        # Check if scheduling is enabled and default schedule should be used
        if not settings.get("schedulingEnabled", True):
            return None
        if not settings.get("useDefaultSchedule", False):
            return None
        
        # Check if date is an open day
        try:
            date_obj = datetime.strptime(date_key, "%Y-%m-%d")
            day_of_week = date_obj.weekday()  # 0=Monday, 6=Sunday
            # Convert to JS format (0=Sunday, 6=Saturday)
            js_day_of_week = (day_of_week + 1) % 7
        except ValueError:
            return None
        
        open_days = settings.get("openDays", [1, 2, 3, 4, 5])  # Default Mon-Fri
        if js_day_of_week not in open_days:
            return None
        
        # Check if date is excluded
        excluded_dates = settings.get("excludedDates", [])
        if date_key in excluded_dates:
            return None
        
        # Get default schedule template
        default_schedule = settings.get("defaultSchedule", [])
        if not default_schedule:
            return None
        
        # Create schedule from template (deep copy, clear volunteers)
        new_shifts = []
        for i, shift in enumerate(default_schedule):
            new_shifts.append({
                "id": shift.get("id", i + 1),
                "time": shift.get("time", ""),
                "shift": shift.get("shift", ""),
                "volunteers": []  # Start with no volunteers
            })
        
        new_schedule = {
            "shifts": new_shifts,
            "general_volunteers": []
        }
        
        # Use $setOnInsert pattern for idempotent generation
        # This only sets the value if the field doesn't exist
        result = self.collection.update_one(
            {"_id": pantry_id, f"schedules.{date_key}": {"$exists": False}},
            {"$set": {f"schedules.{date_key}": new_schedule}}
        )
        
        if result.modified_count > 0:
            return new_schedule
        
        # If not modified, the schedule might already exist (race condition)
        # Fetch and return whatever is there now
        pantry = self.collection.find_one(
            {"_id": pantry_id},
            {f"schedules.{date_key}": 1}
        )
        if pantry:
            schedules = pantry.get("schedules", {})
            return schedules.get(date_key, new_schedule)
        
        return new_schedule
    
    def ensure_schedules_for_range(self, pantry_id, from_date: str, to_date: str):
        """
        Ensure schedules exist for all eligible days in a date range.
        Only generates missing schedules from the default template.
        """
        pantry = self.collection.find_one(
            {"_id": pantry_id},
            {"schedules": 1, "schedule_settings": 1}
        )
        
        if not pantry:
            return 0
        
        settings = pantry.get("schedule_settings", {})
        if not settings.get("schedulingEnabled", True):
            return 0
        if not settings.get("useDefaultSchedule", False):
            return 0
        
        existing_schedules = pantry.get("schedules", {})
        if not isinstance(existing_schedules, dict):
            existing_schedules = {}
        
        generated_count = 0
        current_date = datetime.strptime(from_date, "%Y-%m-%d")
        end_date = datetime.strptime(to_date, "%Y-%m-%d")
        
        while current_date <= end_date:
            date_key = current_date.strftime("%Y-%m-%d")
            
            # Skip if already exists
            if date_key not in existing_schedules:
                result = self._auto_generate_schedule(pantry_id, date_key, pantry)
                if result:
                    generated_count += 1
            
            current_date += timedelta(days=1)
        
        return generated_count

    def save_schedule_for_date(self, pantry_id, date_key: str, schedule_data):
        """
        Save schedule for a specific date key (YYYY-MM-DD).
        Accepts new format: { shifts: [...], general_volunteers: [...] }
        Or legacy format: [...] (array of shifts)
        """
        # Handle legacy format (array of shifts)
        if isinstance(schedule_data, list):
            schedule_data = {
                "shifts": schedule_data,
                "general_volunteers": []
            }
        
        result = self.collection.update_one(
            {"_id": pantry_id},
            {"$set": {f"schedules.{date_key}": schedule_data}}
        )
        return result.matched_count > 0

    def delete_schedule_for_date(self, pantry_id, date_key: str):
        """Delete schedule for a specific date key (YYYY-MM-DD)."""
        result = self.collection.update_one(
            {"_id": pantry_id},
            {"$unset": {f"schedules.{date_key}": ""}}
        )
        return result.matched_count > 0

    def cleanup_past_schedules(self, pantry_id, today_key: str) -> int:
        """Unset any schedules with a key older than today_key (YYYY-MM-DD). Returns number removed."""
        pantry = self.collection.find_one({"_id": pantry_id}, {"schedules": 1})
        if not pantry:
            return 0
        schedules = pantry.get("schedules")
        if not isinstance(schedules, dict):
            return 0
        to_remove = [k for k in schedules.keys() if isinstance(k, str) and k < today_key]
        if not to_remove:
            return 0
        unset_spec = {f"schedules.{k}": "" for k in to_remove}
        self.collection.update_one({"_id": pantry_id}, {"$unset": unset_spec})
        return len(to_remove)
    
    def get_schedule_settings(self, pantry_id):
        """Get volunteer schedule settings for a pantry"""
        pantry = self.collection.find_one(
            {"_id": pantry_id},
            {"schedule_settings": 1, "_id": 0}
        )
        if pantry and "schedule_settings" in pantry:
            return pantry["schedule_settings"]
        # Return default settings if none exist
        return {
            "schedulingEnabled": True,
            "schedulingMode": "shifts",
            "openDays": [1, 2, 3, 4, 5],  # Monday through Friday
            "excludedDates": [],
            "useDefaultSchedule": False,
            "defaultSchedule": []
        }
    
    def save_schedule_settings(self, pantry_id, settings):
        """Save volunteer schedule settings for a pantry"""
        result = self.collection.update_one(
            {"_id": pantry_id},
            {"$set": {"schedule_settings": settings}}
        )
        return result.matched_count > 0
    
    def get_pantries(self):
        """Swift stream view functionality - includes schedule_settings for volunteer scheduling"""
        return list(
            self.collection.aggregate([
                {
                    "$addFields":{ #Calculate ratios
                        "stock":{ #replace old stock array with new stock array
                            "$map":{ #lets you transform element in array
                                "input":"$stock", #current stock array
                                "as":"s", #s represents each item in stock array
                                "in":{ #defines what each new element will look like
                                    "name": "$$s.name",
                                    "current":"$$s.current",
                                    "full":"$$s.full",
                                    "type":"$$s.type",
                                    "ratio":{
                                        "$round":[
                                            {"$divide":["$$s.current", "$$s.full"]},
                                            1
                                        ]
                                    }
                                }
                            }
                        }
                    }
                },
                {
                    "$addFields":{ #sort by descending ratio
                        "stock":{
                            "$sortArray":{
                                "input":"$stock",
                                "sortBy":{
                                    "ratio": -1
                                }
                            }
                        }
                    }
                },
                {
                    "$project":{
                        "_id": {"$toString": "$_id"},
                        "name":1,
                        "address":1,
                        "email":1,
                        "phone_number":1,
                        "website":1,
                        "stock":1,
                        "stream":1,
                        "schedule_settings":1,  # Include schedule settings for volunteer scheduling
                    }
                }
            ])
        )
