//
//  ContentView.swift
//  CritterQuest
//
//  Created by Samuel Faucher on 1/31/24.
//  Date is wrong ^, had to move code to new file
//

import SwiftUI
import CoreLocation

import MapKit

struct ContentView: View {
    
    @EnvironmentObject var locationManager: LocationManager
    
    let dateTime = Date()
    
    //gets users current gps pos
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    
    //self explanatory
    @State private var sheetVisible = false
    
    //holds current tapped coord
    @State private var tappedCoord: CLLocationCoordinate2D?
    
    
    //checks to see if the screen has been tapped
    @State private var pinInProgress = false
    
    //variables for pin name, field, and desc
    @State var pinNameField = ""
    @State var pinName = ""
    @State var pinDesc = ""
    
    //creates a list of current locations that have been pinned
    @State private var locations = [Location]()
    
    @State var toggle = false
    
    var body: some View {
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
                    
                }.mapStyle(toggle ? .hybrid : .standard)
                
                //when map is tapped -- creates a pin on the tapped location
                
                    .onTapGesture { position in
                        //takes screen position
                        if let coordinate = proxy.convert(position, from: .local){
                            
                            //print(coordinate)
                            self.tappedCoord = coordinate
                            self.sheetVisible.toggle()
                            self.pinInProgress = true
                            //print(coordinate, ": 1")
                            
                        }
                    }.sheet(isPresented: $sheetVisible, content: {
                        VStack{
                            //doesnt place the pin until user is done
                            if pinInProgress {
                                VStack{
                                    HStack{
                                        Text("New Pin").presentationDetents([.height(200)]).padding(.top).padding(.horizontal)
                                        Spacer()
                                    }
                                    
                                    HStack{
                                        TextField(" Bear, Eagle, Fox, etc", text: $pinNameField)
                                            .border(Color.blue)
                                            .textFieldStyle(.roundedBorder)
                                            .padding(.horizontal)
                                            .keyboardType(.default)
                                    }
                                    HStack{
                                        Text("Pin Description").presentationDetents([.height(300)]).padding(.horizontal)
                                        Spacer()
                                    }
                                    HStack{
                                        TextField(" had babies, was grazing, etc", text: $pinDesc)
                                            .border(Color.blue)
                                            .textFieldStyle(.roundedBorder)
                                            .padding(.horizontal)
                                            .keyboardType(.default)
                                    }
                                    
                                    //submits all textfield info
                                    Button(action: {
                                        //only if pin is named!
                                        //desc optional
                                        if !pinNameField.isEmpty{
                                            let newLocation = Location(id: UUID(), name: pinNameField, description: pinDesc, latitude: tappedCoord?.latitude ?? 0.0, longitude: tappedCoord?.longitude ?? 0.0)
                                            locations.append(newLocation)
                                            print("New pin: \(newLocation.name) at \(newLocation.longitude), \(newLocation.latitude)")
                                        }
                                        pinNameField = ""
                                        pinDesc = ""
                                        sheetVisible = false
                                        pinInProgress = false
                                    }, label: {
                                        Label("Submit", systemImage: "pin")
                                    }).buttonStyle(.borderedProminent)
                                    Spacer()
                                }
                            }
                        }
                    })
                //when map starts, request location permissions
            }.onAppear(){CLLocationManager().requestWhenInUseAuthorization()
                
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(LocationManager())
}
