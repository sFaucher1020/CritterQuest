//
//  ContentView.swift
//  CritterQuest
//
//  Created by Samuel Faucher on 1/31/24.
//

import SwiftUI
import CoreLocation
import MapKit

struct ContentView: View {
    
    @EnvironmentObject var locationManager: LocationManager
    
    let dateTime = Date()
    
    //gets users current gps pos
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    
    //creates a list of current locations that have been pinned
    @State private var locations = [Location]()
    
    @State var toggle = false
    
    var body: some View {
        ZStack{
            MapReader { proxy in
                //initialized map view
                Map(initialPosition: position){
                    //iterate through the list of coords
                    ForEach(locations) { location in
                        //creates a marker for each pin in locations
                        Marker(location.name,
                               coordinate: CLLocationCoordinate2D(
                                latitude: location.latitude,
                                longitude: location.longitude))
                    }
                //gives map functionality -- BROKEN BROKEN
                    
                }.mapStyle(toggle ? .hybrid : .standard)
                
                //when map is tapped -- creates a pin on the tapped location
                .onTapGesture { position in
                    //takes screen position
                    if let coordinate = proxy.convert(position, from: .local){
                        //converts screen position to coordinate
                        let newLocation = Location(id: UUID(), name: "New Pin", description: "", latitude: coordinate.latitude, longitude: coordinate.longitude)
                        print("Coordinate Placed at \(coordinate.latitude), \(coordinate.longitude), at \(dateTime)")
                        //adds new tapped location to list
                        locations.append(newLocation)
                    }
                //when map starts, request location permissions
                }.onAppear(){CLLocationManager().requestWhenInUseAuthorization()}
                
                //temporary NAV BAR
                //will implement "Picker" Later
                HStack{
                    Spacer()
                    
                    Button("", systemImage: "map"){
                        print("Clicked on map button")
                    }.padding(15).bold()
                    
                    Spacer()
                    
                    Button("",systemImage: "pin"){
                        print("Clicked on pins button")
                    }.bold()
                    
                    Spacer()
                    
                    Button("", systemImage: "person"){
                        print("Clicked on profile button")
                    }.bold()
                    
                    Spacer()
                }
            }
            VStack{
                HStack{
                    Toggle("", isOn: $toggle).toggleStyle(SwitchToggleStyle(tint: .blue)).toggleStyle(.automatic).padding(20).labelsHidden()
                    
                    Spacer()
                    
                    Text("Current Coordinates: \(locationManager.location?.coordinate.latitude ?? 0.0), \(locationManager.location?.coordinate.longitude ?? 0.0)")
                    
                    Spacer()
                    
                    Button("", systemImage: "location"){
                    //make the button return to users curr position
                
                        
                    }.buttonStyle(.borderedProminent).padding(20).labelsHidden()
                }
                Spacer()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(LocationManager())
}
