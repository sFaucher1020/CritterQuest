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
    
    var body: some View {
        VStack {
            Label("My Pins", systemImage: "pin").padding().foregroundStyle(.blue).labelStyle(.automatic).font(.system(size: 25))
            
            NavigationStack{
                List(pins, id: \.name){ pin in
                    HStack{
                        Text(pin.name).swipeActions(){
                            Button(role: .destructive) {
                                withAnimation {
                                    //delReq()
                                    ctx.delete(pin)
                                }
                            } label: {
                                Image(systemName: "trash")
                                Text("Delete")
                            }
                        }
                        Text(pin.desc)
                    }
                }
                Spacer()
            }.searchable(text:$searchText)
        }

    }
//    func delReq(){
//        guard let url = URL(string: "http://3.80.118.34:8000/pins.json") else {
//            print("Invalid URL")
//            return
//        }
//        var request = URLRequest(url: url)
//        request.httpMethod = "DELETE"
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("Error deleting pin:", error)
//                return
//            }
//            if let response = response as? HTTPURLResponse {
//                print("Response status code:", response.statusCode)
//            }
//        }.resume()
//    }
}

#Preview {
    pinListView()
}
