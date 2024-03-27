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
    
    @State private var pinIDs = [Int]()

    @State var toggle = false
    
    @State var mapRefresh = true
    
    var radius = ["All", "25mi", "50mi", "100mi"]
    
    @State private var disLat = 0.0
    @State private var disLong = 0.0
    
    @State private var nLat = 0.0
    @State private var nLong = 0.0
    
    @State private var a = 0.0
    
    @State private var rad = 0.0
    
    @State private var c = 0.0
    
    @State private var selectedRadius = "All"
    var body: some View {
        
            MapReader { proxy in
                ZStack {
                    
                    //Initializes map and current posi
                    Map(initialPosition: position) {
                            //iterate through the list of coords
                            //ForEach(bottom, id: \.id) { pin in
                                if selectedRadius == "All" {
                                    ForEach(bottom, id: \.id) { pin in
                                        if let latitude = Double(pin.pinLat), let longitude = Double(pin.pinLong) {
                                            Marker(pin.pinName, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                                        }
                                    }
                                }else if selectedRadius == "25mi"{
                                    ForEach(bottom, id: \.id) { pin in
                                        
                                        //ERRORING
                                        //let OUTPUT = distFromUser(userLat: locationManager.location?.coordinate.latitude ?? 0.0, userLong: locationManager.location?.coordinate.longitude ?? 0.0, pinLat: pin.pinLat, pinLong: pin.pinLong)
                                            
                                        //if(OUTPUT <= 25.0){
                                            if let latitude = Double(pin.pinLat), let longitude = Double(pin.pinLong) {
                                                Marker(pin.pinName, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                                            }
                                        //}
                                    }
                                }else if selectedRadius == "50mi"{
                                    ForEach(bottom, id: \.id) { pin in
                                        if let latitude = Double(pin.pinLat), let longitude = Double(pin.pinLong) {
                                            Marker(pin.pinName, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                                        }
                                    }
                                }else if selectedRadius == "100mi"{
                                        ForEach(bottom, id: \.id) { pin in
                                            if let latitude = Double(pin.pinLat), let longitude = Double(pin.pinLong) {
                                                Marker(pin.pinName, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                                            }
                                        }
                                }
                            }
                    //add mapcontrols, TODO:// Fix toggle
                    .mapStyle(toggle ? .hybrid : .standard)
                    .mapControls(){
                        //MULC not working, not sure why, might be bug from apple themselves
                        MapUserLocationButton().padding(10)
                        MapCompass().padding(10)
                    }
                    //when map is tapped, calculates screen coord with real coords
                    .onTapGesture { position in
                        //takes screen position
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
                                                let jsonData = try JSONSerialization.data(withJSONObject: postData, options: [])
                                                
                                                //create URL request
                                                guard let url = URL(string: "http://3.80.118.34:8000/pins.json") else {
                                                    print("Invalid URL")
                                                    return
                                                }
                                                var request = URLRequest(url: url)
                                                request.httpMethod = "POST"
                                                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                                                request.httpBody = jsonData
                                                
                                                //send POST request
                                                URLSession.shared.dataTask(with: request) { data, response, error in
                                                    if let error = error {
                                                        print("Error: \(error.localizedDescription)")
                                                    }
                                                    guard let data = data else {
                                                        print("No data received")
                                                        return
                                                    }
                                                    if let response = String(data: data, encoding: .utf8) {
                                                        print("Response: \(response)")
                                                        // Handle response as needed, you may update UI or perform other actions here
                                                    }
                                                    Task{
                                                        await fetchData()
                                                    }
                                                }.resume()
                                            } catch {
                                                print("Error: \(error.localizedDescription)")
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
                    VStack{
                        //Picker to select radius of pin
                        Text("Pin Radius: \(selectedRadius)").font(.title).padding(.vertical)
                        Picker("Please choose a Radius", selection: $selectedRadius) {
                            ForEach(radius, id: \.self) {
                                Text($0)
                            }
                        }.pickerStyle(.segmented).padding(.horizontal)
                        
                        Spacer()
                    }
                    
                }
            }.task {
                await fetchData()
        //when map starts, request location permissions
        }.onAppear(){CLLocationManager().requestWhenInUseAuthorization()
            }
        
    }
    
    func distFromUser(userLat: Double, userLong: Double, pinLat: Double, pinLong: Double) -> Double{
        
        disLat = (pinLat - userLat) * Double.pi / 180.0
        disLong = (pinLong - userLong) * Double.pi / 180.0
        
        //convert to radians
        nLat = (userLat) * Double.pi / 180.0
        nLong = (pinLat) * Double.pi / 180.0
        
        //how do i get cos and sin in swift AND square root and power
        a = pow(sin(disLat/2), 2) + pow(sin(disLong/2), 2)*cos(pinLat)
        
        rad = 3959
        
        c = 2 * asin(sqrt(a))
        
        
        
        return Double(rad) * c
        

    }

    func fetchData() async {
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
