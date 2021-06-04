//
//  ContentView.swift
//  quotes
//
//  Created by Liliia Ivanova on 20.05.2021.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var alertTitle = ""
    @State private var alertDescription = ""
    @State private var showingAlert = false
    
    @State private var openSettings = false
    @State private var currentColorScheme = 0
    @State private var currentCard = 0
    @State private var didJustSwipe = false
    @State private var offsets: [CGSize] = [.zero, .init(width: 1000, height: 0)]
    
    @State private var userID = ""
    
    @State private var quoteCards: QuoteList?
    
    init() {
        UITableView.appearance().backgroundColor = UIColor.clear
        UITableViewCell.appearance().backgroundColor = .clear
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
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
                    self.quoteCards!.setStates(index: newCurrentCard)
                    self.offsets[newCurrentCard] = .init(width: -x, height: -y)
                    withAnimation(.linear(duration: 1)) {
                        self.offsets[currentCard] = .init(width: x, height: y)
                        self.offsets[newCurrentCard] = .zero
                        self.currentCard = newCurrentCard
                    }
                } else {
                    withAnimation(.linear(duration: 1.0)) {
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
                        if quoteCards != nil {
                            ForEach(0...quoteCards!.data.count-1, id: \.self) { i in
                                quoteCards!.data[i].offset(self.offsets[i]).gesture(self.gesture)
                            }
                        }
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
            getUserRecordID(completionHandler: actWithUserRecordID)
        }
        .fullScreenCover(isPresented: $openSettings) {
            SettingsView(currentColorScheme: currentColorScheme)
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text(self.alertTitle),
                  message: Text(self.alertDescription),
                  dismissButton: .default(Text("Got it!")) {
                    
                    let settingsCloudKitURL = URL(string: "App-prefs:")
                    if let url = settingsCloudKitURL, UIApplication.shared.canOpenURL(url) {
                        if #available(iOS 10, *) {
                            if UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        } else {
                            UIApplication.shared.openURL(url)
                        }
                    }
                }
            )
        }
    }
    
    func actWithUserRecordID(result: String, isErrorOccurred: Bool) -> () {
        self.showingAlert = isErrorOccurred
        if isErrorOccurred {
            self.alertTitle = "User cannot be identified"
            self.alertDescription = result
            self.quoteCards = QuoteList(userID: "")
        } else {
            self.userID = result
            withAnimation(.linear(duration: 0.2)) {
                self.quoteCards = QuoteList(userID: self.userID)
            }
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
