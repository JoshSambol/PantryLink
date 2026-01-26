//
//  ScheduleModel.swift
//  PantryLink
//
//  Created for volunteer scheduling system
//

import Foundation

struct ScheduleResponse: Codable {
    let date: String
    let schedule: [Shift]
}

struct Shift: Codable, Identifiable {
    let id: Int
    let time: String
    let shift: String
    let volunteers: [ShiftVolunteer]
}

struct ShiftVolunteer: Codable, Identifiable {
    let name: String
    let role: String
    let email: String?
    let username: String?
    
    var id: String { "\(name)-\(role)" }
}

struct TodaysScheduleItem: Identifiable {
    let id = UUID()
    let pantryId: String
    let pantryName: String
    let pantryAddress: String
    let shift: String
    let time: String
    let role: String
    let date: String
}
