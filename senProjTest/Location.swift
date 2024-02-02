//
//  Location.swift
//  CritterQuest
//
//  Created by Samuel Faucher on 2/1/24.
//

import Foundation

struct Location: Codable, Equatable, Identifiable {
    
    let id:UUID
    var name: String
    var description: String
    var latitude: Double
    var longitude: Double
}
