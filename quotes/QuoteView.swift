//
//  QuoteView.swift
//  quotes
//
//  Created by Liliia Ivanova on 04.06.2021.
//

import SwiftUI

class QuoteText: ObservableObject {
    @Published var data: QuoteResponse?

    public func setStates(result: QuoteResponse) {
        if data == nil {
            withAnimation(.easeOut(duration: 0.7)) {
                self.data = result
            }
        } else {
            self.data = result
        }
    }
}
struct QuoteView: View {
    @ObservedObject var currentText: QuoteText = QuoteText()

    public func setStates(result: QuoteResponse) {
        if result.status == "ok" {
            self.currentText.setStates(result: result)
        } else {
            print(result.quote)
        }
    }

    var body: some View {
        if currentText.data != nil {
            VStack {
                Text(currentText.data!.quote)
                Button(action: {
                    currentText.data!.like = !currentText.data!.like
                    // TODO send to server smth like this (quote.id, isLiked)
                }) {
                    Image(systemName: currentText.data!.like ? "heart.fill" : "heart").resizable()
                        .frame(width: 36.0, height: 36.0).foregroundColor(Color.black)
                }
            }
            .foregroundColor(Color.black)
            .multilineTextAlignment(.center)
            .font(.custom("Rockwell", size: 25))
            .padding(40)
            .background(Color.white.opacity(0.3)).cornerRadius(40.0).padding(20)
        }
    }
}

class QuoteList {
    @State var userID: String
    @State var data: [QuoteView] = [QuoteView(), QuoteView()]
    var serverClient: ServerClient?
    
    init(userID: String) {
        self.userID = userID
        self.serverClient = ServerClient(userID: userID, completionHandler: { index, result in
            self.data[index].setStates(result: result)
        })
    }

    public func setStates(index: Int) {
        self.serverClient!.loadQuote(index: index)
    }
}
