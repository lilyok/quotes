//
//  QuotesCategoriesView.swift
//  quotes
//
//  Created by Liliia Ivanova on 27.05.2021.
//

import SwiftUI

let DefaultChoice = "Common Sense"

class Categories: ObservableObject, Equatable {
    @Published var data: [String:Bool] = [DefaultChoice: true]
    
    static func ==(lhs: Categories, rhs: Categories) -> Bool {
        return lhs.data == rhs.data
    }
}


struct QuotesCategoriesView: View {
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    let currentColorScheme: Int
    let categories = [[DefaultChoice, "quote.bubble"], ["Favourite", "heart"], ["Popular", "star"]]
    @ObservedObject var selectedCategories = Categories()
    
    var body: some View {
        RadialGradient(
            gradient: Gradient(colors: ColorScheme[currentColorScheme]), center: .center, startRadius: 100, endRadius: 470
        ).background(Color.white).opacity(0.6).edgesIgnoringSafeArea(.all)
        .navigationBarTitleDisplayMode(.inline)
        .overlay(
            VStack{
                Text("Select interesting categories").font(.custom("San Francisco", size: 22))
                ForEach(categories, id: \.self) { value in
                    CheckboxFieldView(text: value[0], iconName: value[1], checkState: selectedCategories.data[value[0]] ?? false, selectedCategories: selectedCategories)
                }
                .id(UUID())
                
            }.onAppear() {
                selectedCategories.data = loadSelectedCategories()
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
    @State var selectedCategories: Categories
    @State var isLast = false

    var body: some View {
        ZStack {
            Button(action: {
                if !self.checkState {
                    self.checkState = true
                    self.selectedCategories.data[text] = true
                } else {
                    if (selectedCategories.data.filter{ $0.value == true }.count > 1) {
                        self.checkState = false
                        selectedCategories.data[text] = false
                    } else {
                        self.isLast = true
                    }
                }
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
            .foregroundColor(Color.black).font(.custom("San Francisco", size: 20)).padding(2)
            if (self.isLast) {
                Text("You should leave\nat least one category").foregroundColor(.white).multilineTextAlignment(.center).padding(2)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.black).shadow(radius: 3))
                    .zIndex(1)
                    .offset(x: 60, y: 10)
                    .onAppear() {
                        withAnimation(.linear(duration: 3)) {
                            self.isLast = false
                        }
                    }
            }
        }
    }
}

private func saveSelectedCategory(text: String, status: Bool) {
    let userDefaults = UserDefaults.standard
    var categories = userDefaults.object(forKey: "SelectedCategories") as? [String:Bool] ?? [DefaultChoice: true]
    categories[text] = status
    userDefaults.set(categories, forKey: "SelectedCategories")
}

public func loadSelectedCategories() -> [String: Bool] {
    let categories = UserDefaults.standard.object(forKey: "SelectedCategories") as? [String:Bool] ?? [DefaultChoice: true]
    return categories
}
