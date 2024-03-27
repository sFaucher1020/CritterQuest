//
//  aliasChange.swift
//  senProjTest
//
//  Created by Samuel Faucher on 3/20/24.
//

import SwiftUI
import SwiftData

struct aliasChange: View {
    
    @State private var aliasTextBox = ""
    @State var alias = "Anon"
    @State private var opacitythanks = 0.0
    @State private var opacitycharlen = 0.0
    

    var body: some View {
        
        ZStack {
            Image("potentialbg").resizable().opacity(0.9).ignoresSafeArea(.all, edges: .top)
                            VStack {
                                Spacer()
                                HStack{
                                    Spacer()
                                    Text("Have a safe time exploring, \(alias)!").opacity(opacitythanks).font(.largeTitle).foregroundStyle(.white).padding(.horizontal).padding(.top)
                                    Spacer()
                                }
                                Spacer()
                                Text("Add Alias").foregroundStyle(.white).font(.largeTitle)
                                TextField("Add Alias", text: $aliasTextBox).border(Color.black)       .textFieldStyle(.roundedBorder)
                                    .padding(.horizontal)
                                    .keyboardType(.default)
                                
                                Text("Please keep nickname under 10 characters").foregroundStyle(.red).opacity(opacitycharlen)
                                
                                Button(action: {
                                    if aliasTextBox != "" && aliasTextBox.count < 10{
                                        alias = aliasTextBox
                                        //mapHomeView(alias: $alias)
                                        opacitythanks = 1.0
                                        opacitycharlen = 0.0
                                        print("User has chosen", alias, "as their alias")
                                        aliasTextBox = ""
                                        
                                    }else{
                                        opacitycharlen = 1.0
                                    }
                                    
                                    
                                }, label: {
                                    Label("Submit", systemImage: "person.fill")
                                    }).buttonStyle(.borderedProminent)
                                    Spacer()
                            }
                            Spacer()
        }
    }
}

#Preview {
    aliasChange()
    
}
