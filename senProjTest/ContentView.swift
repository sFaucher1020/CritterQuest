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
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) var ctx
    
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

    @State var toggle = false
    
    //pulls from SwiftData
    @Query private var pins : [PinDB]
    
    var body: some View {
        NavigationView {
            MapReader { proxy in
                //initialized map view
                ZStack {
                    
                    Color.gray.ignoresSafeArea()
                    
                    Map(initialPosition: position){
                        //iterate through the list of coords
                        ForEach(pins) { pin in
                            Marker(pin.name, coordinate: CLLocationCoordinate2D(latitude: pin.lat, longitude: pin.long))
                        }
                        
                    }
                    .mapStyle(toggle ? .hybrid : .standard)
                    .mapControls(){
                        MapUserLocationButton().padding(10)
                        MapCompass().padding(10)
                    }
                    
                    //when map is tapped, calculates screen coord with real coords
                    .onTapGesture { position in
                        //takes screen position
                        if let coordinate = proxy.convert(position, from: .local){
                            
                            //print(coordinate)
                            
                            //saves important info
                            self.tappedCoord = coordinate
                            self.sheetVisible.toggle()
                            self.pinInProgress = true
                            //print(coordinate, ": 1")
                            
                        }
                        //slides sheet up to allow users to name and describe
                        //what they pinned
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
                                        //desc optional tho
                                        if !pinNameField.isEmpty{
                                            //populates SwiftData DB "PinDB"
                                            let newPin = PinDB(name: pinNameField, desc: pinDesc, lat: tappedCoord?.latitude ?? 0.0, long: tappedCoord?.longitude ?? 0.0, date: dateTime)
                                            ctx.insert(newPin)
                                            
                                        }
                                        
                                        
                                        //resets all textfields and names
                                        pinNameField = ""
                                        pinDesc = ""
                                        //sets bools back to false :)
                                        //cleanup before next pin
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
                    
                }
                    NavigationLink(destination: pinListView()) {
                            HStack {
                                Label("Edit Pins", systemImage: "pencil").padding(10).background(Color.blue).foregroundStyle(.white).clipShape(RoundedRectangle(cornerRadius: 20.0)).labelStyle(.automatic).font(.system(size: 25))
                            }.padding(.horizontal)
                }
                    
                }
                    
                    //when map starts, request location permissions
                }.onAppear(){CLLocationManager().requestWhenInUseAuthorization()
            }
    }
}

#Preview {
    ContentView()
        .environmentObject(LocationManager())
}
