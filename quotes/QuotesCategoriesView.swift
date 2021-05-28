//
//  QuotesCategoriesView.swift
//  quotes
//
//  Created by Liliia Ivanova on 27.05.2021.
//

import SwiftUI

let DefaultChoice = "Common Sense"


struct QuotesCategoriesView: View {
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    let currentColorScheme: Int
    
    // TODO think about it
    let categories = [[DefaultChoice, "quote.bubble"], ["Favourite", "heart"], ["Popular", "star"]]
    
    @State var selectedCategories: [String:Bool] = [DefaultChoice: true]

    
    var body: some View {
        RadialGradient(
            gradient: Gradient(colors: ColorScheme[currentColorScheme]), center: .center, startRadius: 100, endRadius: 470
        ).background(Color.white).opacity(0.6).edgesIgnoringSafeArea(.all)
        .navigationBarTitleDisplayMode(.inline)
        .overlay(
            VStack{
                Text("Select interesting categories").font(.custom("San Francisco", size: 22))
                ForEach(categories, id: \.self) { value in
                    CheckboxFieldView(text: value[0], iconName: value[1], checkState: selectedCategories[value[0]] ?? false)
                }
                .id(UUID())
            }.onAppear() {
                selectedCategories = loadSelectedCategories()
            }
            
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action : {
                self.mode.wrappedValue.dismiss()
            }){
                Image(systemName: "arrowshape.turn.up.left").resizable()
                    .frame(width: 32.0, height: 32.0).foregroundColor(Color.black).font(.title)
            })
        )
    }
}


struct CheckboxFieldView : View {
    let text: String
    let iconName: String
    @State var checkState: Bool = false;

    var body: some View {

         Button(action: {
            self.checkState = !self.checkState
            saveSelectedCategory(text: text, status: self.checkState)
        }) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: self.checkState ? "\(iconName).fill" : iconName).resizable()
                    .frame(width: 32.0, height: 32.0).foregroundColor(Color.black).font(.title)
                Text(text)
                    .frame(alignment: .center)
            }
            .padding(10)
            .overlay(RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white, lineWidth: 5)).opacity(self.checkState ? 1.0 : 0.5)
        }
        .foregroundColor(Color.black)
        .font(.custom("San Francisco", size: 20))
        .padding(2)

    }
}

private func saveSelectedCategory(text: String, status: Bool) {
    let userDefaults = UserDefaults.standard
    var categories = userDefaults.object(forKey: "SelectedCategories") as? [String:Bool] ?? [DefaultChoice: true]
    categories[text] = status
    userDefaults.set(categories, forKey: "SelectedCategories")
}

private func loadSelectedCategories() -> [String: Bool] {
    let categories = UserDefaults.standard.object(forKey: "SelectedCategories") as? [String:Bool] ?? [DefaultChoice: true]
    return categories
}
