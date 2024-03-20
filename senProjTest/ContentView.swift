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


struct ContentView: View {
    
    var body: some View {
        
        TabView {
            mapHomeView().tabItem {
                Image(systemName: "map.fill")
                Text("Home")
            }
            pinListView().tabItem {
                Image(systemName: "pin.fill")
                Text("Edit Pins")
            }
            aliasChange().tabItem {
                Image(systemName: "person.fill")
                Text("Change Name")
            }
        }
        
    }

}


#Preview {
    ContentView()
}
