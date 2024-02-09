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
    
    var body: some View {
        VStack {
            Label("My Pins", systemImage: "pin").padding(10).foregroundStyle(.blue).labelStyle(.automatic).font(.system(size: 25))
            List(pins, id: \.name){ pin in
                HStack{
                    Text(pin.name).swipeActions(){
                        Button(role: .destructive) {
                            withAnimation {
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
        }
        

    }
}

#Preview {
    pinListView()
}
