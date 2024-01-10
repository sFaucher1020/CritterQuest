//
//  ContentView.swift
//  senProjTest
//
//  Created by Samuel Faucher on 12/29/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack{
            Image("grnbkgrnd").resizable().scaledToFill().ignoresSafeArea()
            VStack {
                Spacer()
                Text("Which Map would you like to browse?")
                Spacer()
                HStack{
                    Spacer()
                    Button {
                        
                    } label: {
                        Text("Private View")
                    }
                    
                    Spacer()
                    
                    Button {
                        
                    } label: {
                        Text("Public View")
                    }
                    Spacer()
                }
                Spacer()
                Spacer()
                
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
