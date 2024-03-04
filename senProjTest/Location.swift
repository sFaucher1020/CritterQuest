//
//  Location.swift
//  CritterQuest
//
//  Created by Samuel Faucher on 2/1/24.
//

import Foundation
import MapKit
import SwiftData


//struct Location: Codable, Equatable, Identifiable {
//    let id:UUID
//    var name: String
//    var description: String
//    var latitude: Double
//    var longitude: Double
//}



@MainActor
class LocationManager: NSObject, ObservableObject{
    @Published var location: CLLocation?
    @Published var region = MKCoordinateRegion()
    
    private let locationManager = CLLocationManager()
    
    override init(){
        super.init()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
    }
}

extension LocationManager: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else{
            return
        }
        self.location = location
        self.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
    }
}


