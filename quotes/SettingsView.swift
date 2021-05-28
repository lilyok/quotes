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
                    NavigationMenuItem(text: "Remove ads", labelName: "pip.remove", destination: AnyView(BuyPremiumView(currentColorScheme: currentColorScheme, text: "Pay to remove ads"))).padding(.vertical, 10)
                    NotificationSettingsView()
                        .overlay(RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white, lineWidth: 5))
                    Spacer()
                    NavigationMenuItem(text: "Select quote's categories", labelName: "wand.and.stars", destination: AnyView(QuotesCategoriesView(currentColorScheme: currentColorScheme)))
                    NavigationMenuItem(text: "Upgrade to Pro", labelName: "lock.open", destination: AnyView(BuyPremiumView(currentColorScheme: currentColorScheme, text: "Pay to upgrade app")))
                }.foregroundColor(.black).padding(30).font(.custom("San Francisco", size: 20)).id("_upgrade_to_pro")
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

struct NavigationMenuItem: View {
    let text: String
    let labelName: String
    let destination: AnyView

    var body: some View {
        NavigationLink(destination: destination) {
            Text(text).font(.custom("San Francisco", size: 22))
            Spacer()
            Image(systemName: labelName)
                .resizable().aspectRatio(contentMode: .fit)
                .frame(height: 22).foregroundColor(Color.black)
            Image(systemName: "arrow.right.square")
                .resizable().aspectRatio(contentMode: .fit)
                .frame(height: 22).foregroundColor(Color.black)
        }
        .padding(20)
        .overlay(RoundedRectangle(cornerRadius: 20)
        .stroke(Color.white, lineWidth: 5))
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(currentColorScheme: 0)
    }
}
