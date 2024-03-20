//
//  aliasChange.swift
//  senProjTest
//
//  Created by Samuel Faucher on 3/20/24.
//

import SwiftUI

struct aliasChange: View {
    
    @State var alias = ""
    
    var body: some View {
        
        ZStack {
            Color.green.opacity(0.4).ignoresSafeArea().overlay {
                            VStack {
                                Text("Add Alias")
                                TextField("Add Alias", text: $alias).border(Color.black)       .textFieldStyle(.roundedBorder)
                                    .padding(.horizontal)
                                    .keyboardType(.default)
                                
                                Button(action: {
                                    
                                }, label: {
                                    Label("Submit", systemImage: "person.fill")
                                    }).buttonStyle(.borderedProminent)
//
                                
                            }
            }
        }
    }
}

#Preview {
    aliasChange()
}
