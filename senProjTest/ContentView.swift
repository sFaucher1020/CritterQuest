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
    
    let dateTime = Date()
    
    //gets users current gps pos
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    
    //creates a list of current locations that have been pinned
    @State private var locations = [Location]()
    
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
            }.mapStyle(.hybrid)
            
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
            }.onAppear(){CLLocationManager().requestWhenInUseAuthorization()}
            
            
            HStack{
                Spacer()
                
                Button("", systemImage: "map"){
                    print("Clicked on map button")
                }.padding(5).bold().onLongPressGesture(minimumDuration: 0.5){
                    print("fuck")
                }
                
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
                    Spacer()
                    Button("", systemImage: "location"){
                        print("test")
                        //proxy.setCamera(.userLocation(fallback: .automatic))
                    }.buttonStyle(.borderedProminent).padding(10)
                    


                    
                    

                }
                Spacer()
            }
        }
    }
}

#Preview {
    ContentView()
}
