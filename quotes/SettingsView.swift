//
//  SettingsView.swift
//  quotes
//
//  Created by Liliia Ivanova on 21.05.2021.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    let currentColorScheme: Int

    var body: some View {
        NavigationView {
            RadialGradient(
                gradient: Gradient(colors: ColorScheme[currentColorScheme]), center: .center, startRadius: 100, endRadius: 470
            ).background(Color.white).opacity(0.8).edgesIgnoringSafeArea(.all)
            .navigationBarTitleDisplayMode(.inline)
            .overlay(
                VStack {
                    NotificationSettingsView()
                        .overlay(RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white, lineWidth: 5))
                    Spacer()        
                    Text("quotes categories")
                    Spacer()
                    Text("payment details")
                    Spacer()
                }.foregroundColor(.black).padding(30).font(.custom("San Francisco", size: 20))
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Label {Text("Back From Settings")} icon: {
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                                // TODO sendAllSettings - save on backend
                            }) {
                                Image(systemName: "arrowshape.turn.up.left").resizable()
                                    .frame(width: 32.0, height: 32.0).foregroundColor(Color.black).font(.title)
                            }
                        }
                    }
                }
            )
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(currentColorScheme: 0)
    }
}
