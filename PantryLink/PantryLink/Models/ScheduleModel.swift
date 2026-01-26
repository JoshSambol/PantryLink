//
//  ScheduleModel.swift
//  PantryLink
//
//  Created for volunteer scheduling system
//

import Foundation

// New format response: { date: string, schedule: { shifts: [...], general_volunteers: [...] } }
struct ScheduleResponse: Codable {
    let date: String
    let schedule: ScheduleData
    
    // Custom decoder to handle both new format (object) and legacy format (array)
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        date = try container.decode(String.self, forKey: .date)
        
        // Try to decode as new format first
        if let scheduleData = try? container.decode(ScheduleData.self, forKey: .schedule) {
            schedule = scheduleData
        } else if let legacyShifts = try? container.decode([Shift].self, forKey: .schedule) {
            // Legacy format: array of shifts
            schedule = ScheduleData(shifts: legacyShifts, general_volunteers: [])
        } else {
            // Empty schedule
            schedule = ScheduleData(shifts: [], general_volunteers: [])
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case date, schedule
    }
}

struct ScheduleData: Codable {
    let shifts: [Shift]
    let general_volunteers: [ShiftVolunteer]
    
    init(shifts: [Shift] = [], general_volunteers: [ShiftVolunteer] = []) {
        self.shifts = shifts
        self.general_volunteers = general_volunteers
    }
}

struct Shift: Codable, Identifiable {
    let id: Int
    let time: String
    let shift: String
    let volunteers: [ShiftVolunteer]
}

struct ShiftVolunteer: Codable, Identifiable {
    let name: String
    let email: String?
    let username: String?
    
    var id: String { "\(name)-\(username ?? "")" }
    
    init(name: String, email: String? = nil, username: String? = nil) {
        self.name = name
        self.email = email
        self.username = username
    }
}

struct ScheduleSettings: Codable {
    let schedulingEnabled: Bool?
    let openDays: [Int]?
    let excludedDates: [String]?
    let useDefaultSchedule: Bool?
    let defaultSchedule: [Shift]?
    
    var isSchedulingEnabled: Bool { schedulingEnabled ?? true }
    var effectiveOpenDays: [Int] { openDays ?? [1, 2, 3, 4, 5] }  // Mon-Fri default
    var effectiveExcludedDates: [String] { excludedDates ?? [] }
}

struct UserWeekScheduleItem: Codable, Identifiable {
    let pantry_id: String
    let pantry_name: String
    let date: String
    let shift: String
    let time: String
    
    var id: String { "\(pantry_id)-\(date)-\(shift)" }
}

struct UserWeekScheduleResponse: Codable {
    let schedules: [UserWeekScheduleItem]
}

struct UserConflictResponse: Codable {
    let scheduled: Bool
    let pantry_name: String?
    let pantry_id: String?
}

struct TodaysScheduleItem: Identifiable {
    let id = UUID()
    let pantryId: String
    let pantryName: String
    let pantryAddress: String
    let shift: String
    let time: String
    let date: String
}
