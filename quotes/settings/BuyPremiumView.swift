//
//  BuyPremiumView.swift
//  quotes
//
//  Created by Liliia Ivanova on 27.05.2021.
//

import SwiftUI

struct BuyPremiumView: View {
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    let currentColorScheme: Int
    let text: String

    var body: some View {
        RadialGradient(
            gradient: Gradient(colors: ColorScheme[currentColorScheme]), center: .center, startRadius: 100, endRadius: 470
        ).background(Color.white).opacity(0.6).edgesIgnoringSafeArea(.all)
        .navigationBarTitleDisplayMode(.inline)
        .overlay(
            VStack{
                Text(text).font(.custom("San Francisco", size: 22))
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action : {
                self.mode.wrappedValue.dismiss()
            }){
                Image(systemName: "arrowshape.turn.up.left").resizable()
                    .frame(width: 32.0, height: 32.0).foregroundColor(Color.black).font(.title)
            }).onTapGesture {
                // TODO i don't know what I'm doing
                print("tap buy")
            }
        )
    }
}


