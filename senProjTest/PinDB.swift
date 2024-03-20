//
//  PinDB.swift
//  senProjTest
//
//  Created by Samuel Faucher on 2/4/24.
//

import Foundation
import SwiftData

@Model
class PinDB{
    //let pinid: Int
    let name: String
    let desc: String
    let lat: Double
    let long: Double
    let date: Date
    
    init(/*pinid: Int,*/ name: String, desc: String, lat: Double, long: Double, date: Date) {
        //self.pinid = pinid
        self.name = name
        self.desc = desc
        self.lat = lat
        self.long = long
        self.date = date
    }
    
}
