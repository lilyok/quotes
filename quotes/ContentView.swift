//
//  ContentView.swift
//  quotes
//
//  Created by Liliia Ivanova on 20.05.2021.
//

import SwiftUI
import CoreData

struct QuoteView: View {
    let tmp: Int
    var body: some View {
        Text("Test quote wise motivation it is dummy text to understand how it will be look like \(tmp)")
            .foregroundColor(Color.black)
            .padding(40).multilineTextAlignment(.center)
            .font(.custom("Rockwell", size: 25))
            .background(Color.white.opacity(0.3)).cornerRadius(40.0).padding(20)//.offset(y: -40)
    }
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var openSettings = false
    @State private var currentColorScheme = 0
    @State private var isLiked = false
    @State private var currentCard = 0
    @State private var didJustSwipe = false
    @State private var offsets: [CGSize] = [.zero, .init(width: 1000, height: 0)]
    
    private var quoteCards: [QuoteView] = []
    
    init() {
        UITableView.appearance().backgroundColor = UIColor.clear
        UITableViewCell.appearance().backgroundColor = .clear
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
        self.quoteCards = [QuoteView(tmp: 0), QuoteView(tmp: 1)]
    }
    
    var gesture: some Gesture {
        DragGesture()
            .onChanged {
                self.offsets[currentCard] = $0.translation
            }
            .onEnded {
                let w = $0.translation.width
                let h = $0.translation.height
                if abs(w) > 100 || abs(h) > 100 {
                    let x = w > 50 ? 1000 : w < -50 ? -1000 : 0
                    let y = h > 50 ? 1000 : h < -50 ? -1000 : 0
                    let newCurrentCard = (self.currentCard + 1) % 2
                    self.offsets[newCurrentCard] = .init(width: -x, height: -y)
                    withAnimation(.linear(duration: 1)) {
                        self.offsets[currentCard] = .init(width: x, height: y)
                        self.offsets[newCurrentCard] = .zero
                        self.currentCard = newCurrentCard
                    }
                } else {
                    withAnimation(.linear(duration: 0.5)) {
                        self.offsets[currentCard] = .zero
                    }
                }
            }
    }
    
    var body: some View {
        NavigationView {
            RadialGradient(
                gradient: Gradient(colors: ColorScheme[currentColorScheme]), center: .center, startRadius: 100, endRadius: 470
            ).edgesIgnoringSafeArea(.all)
            .overlay(
                VStack {
                    ZStack{
                        ForEach(0...quoteCards.count - 1, id: \.self) { i in
                            quoteCards[i].offset(self.offsets[i]).gesture(self.gesture)
                        }
                    }
                    Button(action: {
                        isLiked.toggle()
                        // TODO send to server smth like this (quote.id, isLiked)
                    }) {
                        Image(systemName: isLiked ? "heart.fill" : "heart").resizable()
                            .frame(width: 36.0, height: 36.0).foregroundColor(Color.black)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Label {Text("Settings")} icon: {
                            Button(action: {openSettings.toggle()}) {
                                Image(systemName: "gearshape").resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 32).foregroundColor(Color.black)
                            }
                        }.padding(10)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Label {Text("Change color scheme")} icon: {
                            Button(action: {
                                currentColorScheme = (currentColorScheme + 1) % ColorScheme.count
                                saveColorScheme(colorId: currentColorScheme)
                                // TODO save chosen color in user defaults
                            }) {
                                Image(systemName: "paintpalette").resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 32).foregroundColor(Color.black)
                            }
                        }.padding(10)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Label {Text("Share the quote")} icon: {
                            Button(action: actionSheet) {
                                Image(systemName: "square.and.arrow.up")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 32).foregroundColor(Color.black)
                            }
                        }.padding(10)
                    }
                }
            )
        }.onAppear() {
            currentColorScheme = loadColorScheme()
        }
        .fullScreenCover(isPresented: $openSettings) {
            SettingsView(currentColorScheme: currentColorScheme)
        }
    }
    
    func actionSheet() {
        let img = takeScreenshot()
        showShareActivity(msg:nil, image: img, url: nil, sourceRect: nil)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
