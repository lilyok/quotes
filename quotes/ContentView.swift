//
//  ContentView.swift
//  quotes
//
//  Created by Liliia Ivanova on 20.05.2021.
//

import SwiftUI
import CoreData

let ColorScheme = [
    // #FFEFB5 #FC9E83
    [Color(red: 1.00, green: 0.94, blue: 0.71), Color(red: 0.99, green: 0.62, blue: 0.51)],
    // #FFCBB5 #FC83D4
    [Color(red: 1.00, green: 0.80, blue: 0.71), Color(red: 0.99, green: 0.51, blue: 0.83)],
    // #B4FFFE #83BEFC
    [Color(red: 0.71, green: 1.00, blue: 0.92), Color(red: 0.51, green: 0.75, blue: 0.99)]
]


struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var openSettings = false

    @State private var currentColorScheme = 0
    @State private var isLiked = false
    
    @State private var tmp = 0
    
    @State private var offset: CGSize = .zero
    @State private var currentCard = 0
    @State private var didJustSwipe = false

    init() {
        UITableView.appearance().backgroundColor = UIColor.clear
        UITableViewCell.appearance().backgroundColor = .clear
    }
    
    var quoteView: some View {
        return VStack {
            Spacer()
            Text("Test quote wise motivation it is dummy text to understand how it will be look like \(tmp)")
                .foregroundColor(Color.black)
                .padding(40).multilineTextAlignment(.center)
                .font(.custom("Rockwell", size: 25))
                .background(Color.white.opacity(0.3)).cornerRadius(40.0).padding(20).offset(y: -40)

            Button(action: {
                isLiked.toggle()
                // TODO send to server smth like this (quote.id, isLiked)
            }) {
                Image(systemName: isLiked ? "heart.fill" : "heart").resizable()
                    .frame(width: 36.0, height: 36.0).foregroundColor(Color.black)
            }
            Spacer()
        }
    }

    var gesture: some Gesture {
        DragGesture()
            .onChanged {
                if self.didJustSwipe {
                    self.didJustSwipe = false
                    self.currentCard += 1
                    self.offset = .zero
                } else {
                    self.offset = $0.translation
                }
        }
            .onEnded {
                let w = $0.translation.width
                if abs(w) > 100 {
                    self.didJustSwipe = true
                    let x = w > 0 ? 1000 : -1000
                    self.offset = .init(width: x, height: 0)
                } else {
                    self.offset = .zero
                }
                tmp += 1
        }
    }

//    func offset(for i: Int) -> CGSize {
//        return i == currentCard ? offset : .zero
//    }

    var body: some View {
        NavigationView {
            RadialGradient(
                gradient: Gradient(colors: ColorScheme[currentColorScheme]), center: .center, startRadius: 100, endRadius: 470
            ).edgesIgnoringSafeArea(.all)
            .overlay(
                ZStack{
                    self.quoteView
                        .offset(self.offset)
                        .gesture(self.gesture)
                        .animation(.spring())
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Label {
                            Text("Settings")
                        } icon: {
                            Button(action: {
                                openSettings.toggle()
                                
                            }) {
                                Image(systemName: "gearshape").resizable()
                                    .frame(width: 32.0, height: 32.0).foregroundColor(Color.black)
                            }
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Label {
                            Text("Chnage color scheme")
                        } icon: {
                            Button(action: {
                                currentColorScheme = (currentColorScheme + 1) % ColorScheme.count
                                // TODO save chosen color in user defaults
                            }) {
                                Image(systemName: "paintpalette").resizable()
                                    .frame(width: 32.0, height: 32.0).foregroundColor(Color.black)
                            }
                        }
                        
                    }
                    
                }
            )
        }
//        .fullScreenCover(isPresented: $openSettings) {
//            SettingsView()
//        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
