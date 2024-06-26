//
//  pinListView.swift
//  senProjTest
//
//  Created by Samuel Faucher on 2/8/24.
//

import SwiftUI
import SwiftData

struct pinListView: View {
    @Environment(\.modelContext) var ctx
    @Query private var pins : [PinDB]
    
    @State private var searchText = ""
    
    @State private var id_of_Pin = 0
    
    @State private var cellTapped = false
    
    struct pinInfo: Codable{
        var id: Int
        var user: String
        var pinName: String
        var pinDesc: String
        var pinLat: String
        var pinLong: String
    }
    
    enum delError: Error {
        case invalid_Pin_ID
    }
    
    //search bar filter
    var filteredPins: [PinDB] {
        //if the search bar is empty
        guard !searchText.isEmpty else {
            //just returns all pins
            return pins
        }
        //if there is text in search bar
        return pins.filter { pin in
            //filters by name or desc
            pin.name.lowercased().contains(searchText.lowercased()) ||
            pin.desc.lowercased().contains(searchText.lowercased())
        }
    }

    var body: some View {
        
        VStack {
            Label("My Pins", systemImage: "pin").padding().foregroundStyle(.blue).labelStyle(.automatic).font(.system(size: 25))
            NavigationStack{
                List(filteredPins, id: \.name){ pin in
                    HStack{
                        Text(pin.name).swipeActions(){
                            Button(role: .destructive) {
                                withAnimation {
                                    print("Pin Name: ", pin.name,"Pin Lat: ", pin.lat,"Pin Long: ", pin.long)
                                    
                                    Task{
                                        await getpinID(pinLat: String(pin.lat) , pinLong: String(pin.long))
                                    }
                                    ctx.delete(pin)
                                }
                            } label: {
                                Image(systemName: "trash")
                                Text("Delete")
                            }
                        }.swipeActions(){
                            Button {
                                withAnimation {
                                    
                                    if let url = URL(string: "http://maps.apple.com/?q=\(pin.lat),\(pin.long)") {
                                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                    }
                                    
                                    //print("Pin Name: ", pin.name,"Pin Lat: ", pin.lat,"Pin Long: ", pin.long)
                                    
//                                    Task{
//                                        await getpinID(pinLat: String(pin.lat) , pinLong: String(pin.long))
//                                    }
                                    //ctx.delete(pin)
                                }
                            } label: {
                                Image(systemName: "map.circle").background(Color.blue)
                                Text("Open in Maps")
                            }.tint(.blue)
                            
                        }
                        //Text(pin.desc)
                    }
                    
                }
                Spacer()
            }.searchable(text: $searchText, prompt: "Search Pins")
        }
        
    }
    func delReq(pinid: Int) {
        // Construct the URL with the pin ID
        guard let url = URL(string: "http://3.80.118.34:8000/pins/\(pinid)") else {
            print("Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error deleting pin:", error)
                return
            }
            if let response = response as? HTTPURLResponse {
                print("Response status code:", response.statusCode)
            }
        }.resume()
    }
    
    
    
    func getpinID(pinLat: String, pinLong: String) async {
        //create url
        guard let url = URL(string: "http://3.80.118.34:8000/pins.json") else{
            print("URL NOT VALID")
            return
        }
        //fetch data from url
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            //decode data
            if let decodedResponse = try? JSONDecoder().decode([pinInfo].self, from: data) {
                @State var bottom = decodedResponse
                print("\n")
                //print("THIS IS THE BOTTOM STRING: -->", bottom)
                //print("THIS IS THE BOTTOM STRING: -->", bottom[0])
                
                print(pinLat.prefix(10), pinLong.prefix(10))
                
                for pin in bottom {
                    if pin.pinLat.prefix(10) == pinLat.prefix(10) && pin.pinLong.prefix(10) == pinLong.prefix(10){
                        print(pin.id)
                        delReq(pinid: pin.id)
                        
                    }
                }
                
                

            }

            
        }catch {
            print("data not valid")
        }
        
    }
}

#Preview {
    pinListView()
}
