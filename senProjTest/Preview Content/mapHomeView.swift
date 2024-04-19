//-------------------------------------------
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


struct top: Codable{
    
    var id: Int
    var user: String
    var pinName: String
    var pinDesc: String
    var pinLat: String
    var pinLong: String
}
//struct catFact: Codable{
//    var fact: String
//    var length: Int
//}

struct mapHomeView: View {
    
    @State private var bottom = [top]()
    
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
    @State var pinid = ""
    
    @State var userLatitude = 0.0
    
    @State var userLongitute = 0.0
    
    @State private var pinIDs = [Int]()

    @State var toggle = false
    
    @State var mapRefresh = true
    
    var radius = ["All", "25mi", "50mi", "100mi"]
    
    @State private var selectedRadius = "All"
    
    @State private var radiusSlider = 5.0
    
    @State private var isEditing = false
    var body: some View {
        
            MapReader { proxy in
                ZStack {
                    //Initializes map and current posi
                    Map(initialPosition: position) {
                            //iterate through the list of coords
                            //ForEach(bottom, id: \.id) { pin in
                        if radiusSlider == 100.0 {
                                    ForEach(bottom, id: \.id) { pin in
                                        if let latitude = Double(pin.pinLat), let longitude = Double(pin.pinLong) {
                                            Marker(pin.pinName, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude)).tint(.green)
                                        }
                                    }
                                    
                                }else {
                                    //sets user current coords
                                    let userLatitude = locationManager.location?.coordinate.latitude ?? 0.0
                                    let userLongitude = locationManager.location?.coordinate.longitude ?? 0.0
                                    //gets radius selected
                                    let selectedRadiusInMiles = radiusSlider
                                    //loops each pin
                                    ForEach(bottom, id: \.id) { pin in
                                        let pinLatitude = Double(pin.pinLat) ?? 0.0
                                        let pinLongitude = Double(pin.pinLong) ?? 0.0
                                        let distance = distFromUser(userLat: userLatitude, userLong: userLongitude, pinLat: pinLatitude, pinLong: pinLongitude)

                                        //makes a pin if and only if it is in the allowed radius
                                        if distance <= selectedRadiusInMiles {
                                            if let latitude = Double(pin.pinLat), let longitude = Double(pin.pinLong) {
                                                Marker(pin.pinName, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude)).tint(.green)
                                            }
                                        }
                                    }
                                }
                    }
                    //add mapcontrols, TODO:// Fix toggle
                    .mapControls(){
                        //MULC not working, not sure why, might be bug from apple themselves
                        MapUserLocationButton().padding(10)
                        MapCompass().padding(10)
                    }
                    //when map is tapped, calculates screen coord with real coords
                    .onTapGesture { position in
                        //takes screen position
                        selectedRadius = "All"
                        if let coordinate = proxy.convert(position, from: .local){
                            
                            //saves important info
                            self.tappedCoord = coordinate
                            self.sheetVisible.toggle()
                            self.pinInProgress = true
                            
                        }
                        //slides sheet up to allow users to name and describe
                        //what they pinned
                    }.sheet(isPresented: $sheetVisible, content: {
                        VStack{
                            //doesnt place the pin until user is done
                            if pinInProgress {
                                VStack{
                                    HStack{
                                        Text("Create Pin").font(.title.bold()).padding(.top).padding(.horizontal)
                                    }
                                    
                                    HStack{
                                        Text("Pin Name").presentationDetents([.height(200)]).padding(.horizontal)
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
                                    HStack{
                                        Toggle("Private Pin", isOn: $toggle).tint(.blue).padding(.horizontal)
                                        Spacer()
                                    }
                                    //submits all textfield info
                                    Button(action: {
                                        //only if pin is named!
                                        //desc optional tho
                                        if !pinNameField.isEmpty && !pinDesc.isEmpty{
                                            //populates local table
                                            let newPin = PinDB(name: pinNameField, desc: pinDesc, lat: tappedCoord?.latitude ?? 0.0, long: tappedCoord?.longitude ?? 0.0, date: dateTime)
                                            ctx.insert(newPin)
                                            
                                            //populate postData dictionary with pin data
                                            
                                            //username will be replaced with users real name
                                            let postData = ["user": "username",
                                                            "pinName": pinNameField,
                                                            "pinDesc": pinDesc,
                                                            "pinLat": "\(tappedCoord?.latitude ?? 0.0)",
                                                            "pinLong": "\(tappedCoord?.longitude ?? 0.0)"]
                                            
                                            //convert postData to JSON data
                                            do {
                                                //print(postData)
                                                //let jsonData = try JSONSerialization.data(withJSONObject: postData, options: [])
                                                    let jsonData = try JSONSerialization.data(withJSONObject: postData) // Simplified
                                                print(jsonData.count,"jsondata")
                                                    
                                                    //create URL request
                                                    guard let url = URL(string: "http://3.80.118.34:8000/pins.json") else {
                                                        print("Invalid URL")
                                                        return
                                                    }
                                                    
                                                    
                                                    var request = URLRequest(url: url)
                                                    request.httpMethod = "POST"
                                                    
                                                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                                                    
                                                    request.httpBody = jsonData
                                                    
                                                    //print(request.httpBody ?? "")
                                                    
                                                    
                                                    //send POST request
                                                    URLSession.shared.dataTask(with: request) { data, response, error in
                                                        if let error = error {
                                                            print("Error: \(error.localizedDescription)")
                                                            print("if let")
                                                        }
                                                        
                                                        guard let data = data else {
                                                            print("No data received")
                                                            return
                                                        }
                                                        
                                                        if let response = String(data: data, encoding: .utf8) {
                                                            print("Response: \(response)")
                                                            
                                                        }
                                                        Task{
                                                            await fetchData()
                                                        }
                                                    }.resume()
                                                } catch {
                                                    print("Error: \(error.localizedDescription)")
                                                    print("im in the catch")
                                                }
                                        }
                                        
                                        //resets all textfields and names
                                        pinNameField = ""
                                        pinDesc = ""
                                        //sets bools back to false :)
                                        //cleanup before next pin
                                        sheetVisible = false
                                        pinInProgress = false
                                    }, label: {
                                        Label("Submit", systemImage: "pin.fill")
                                    }).buttonStyle(.borderedProminent)
                                    Spacer()
                                }
                            }
                        }
                    })
                    //Slider to choose radius
                    VStack{
                        //Dark Green 29, 71, 40 <-- i dont think ill be able to add this color, dont care enough for custom color :P
                    
                        //Creates headline n Mi Radius
                        Text(String(format: "%.0fmi Radius", radiusSlider))
            .frame(maxWidth: .infinity)
                            .frame(maxHeight: 30)
                            .background(Color.green)
                            .foregroundColor(isEditing ? .gray : .black).font(.headline).background(Color.green)
                        
                        //Choose a more unique slider radius from 5mi-All Pins
                        Slider(value: $radiusSlider, in: 5...100, step: 5){
                            Text("mi").padding()
                        } minimumValueLabel: {
                            Text("5mi").padding()
                        } maximumValueLabel: {
                            Text("All Pins").padding()
                        } onEditingChanged: { editing in
                            isEditing = editing
                        }.background(Color.green)
                            .frame(maxHeight: 20)

                        Spacer()
                    }
                    Spacer()

                    
                }
            }.task {
                await fetchData()
        //when map starts, request location permissions
        }.onAppear(){CLLocationManager().requestWhenInUseAuthorization()
            }
        
    }
    func distFromUser(userLat: Double, userLong: Double, pinLat: Double, pinLong: Double) -> Double {
        let earthRadius = 3959.0 // Earth's radius in miles
        
        let deltaLat = (pinLat - userLat) * .pi / 180.0
        let deltaLong = (pinLong - userLong) * .pi / 180.0
        
        let a = sin(deltaLat / 2) * sin(deltaLat / 2) +
                cos(userLat * .pi / 180) * cos(pinLat * .pi / 180) *
                sin(deltaLong / 2) * sin(deltaLong / 2)
        
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        
        let distance = earthRadius * c
        
        return distance
    }

    func fetchData() async {
        
        //await Task.sleep(500_000_000) // 0.5 seconds in nanoseconds

        //create url
        guard let url = URL(string: "http://3.80.118.34:8000/pins.json") else{
            print("URL NOT VALID")
            return
        }
        //fetch data from url
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            //decode data
            if let decodedResponse = try? JSONDecoder().decode([top].self, from: data) {
                bottom = decodedResponse
                
                
                //print(bottom)
                //print("This is bottom[0]  ", bottom[0])
            }

            
        }catch {
            print("data not valid")
        }
    }
    
    
}
#Preview {
    mapHomeView()
        .environmentObject(LocationManager())
    
}
