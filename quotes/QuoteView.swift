//
//  QuoteView.swift
//  quotes
//
//  Created by Liliia Ivanova on 04.06.2021.
//

import SwiftUI

class QuoteText: ObservableObject {
    @Published var data: QuoteResponse?
    private var isConnectionError: Bool = false

    public func setStates(result: QuoteResponse?, isConnectionError: Bool) {
        self.isConnectionError = isConnectionError
        if result == nil {
            DispatchQueue.main.async {
                self.data = nil
            }
            return
        }
        if data == nil {
            withAnimation(.easeOut(duration: 0.7)) {
                self.data = result
            }
        } else {
            self.data = result
        }
    }
    
    public func getText() -> String {
        if self.isConnectionError {
            return "Swipe me after fixing your internet connection"
        }
        if data == nil {
            return "loading..."
        }
        return data!.quote
    }
    
    public func isLikeAvailable() -> Bool {
        return data != nil && !self.isConnectionError
    }
}

struct QuoteView: View {
    @ObservedObject var currentText: QuoteText = QuoteText()

    public func setStates(result: QuoteResponse?, isConnectionError: Bool) {
        if result != nil && result!.status != "ok" {
            print(result!.quote)
        }
        self.currentText.setStates(result: result, isConnectionError: isConnectionError)
    }

    var body: some View {
        VStack() {
            Text(currentText.getText())
                .fixedSize(horizontal: false, vertical: true)
                .foregroundColor(Color.black)
                .multilineTextAlignment(.center)
                .frame(alignment: .center)
                .font(.custom("American Typewriter", size: 25))
            if currentText.isLikeAvailable() {
                Button(action: {
                    currentText.data!.like = !currentText.data!.like
                    // TODO send to server smth like this (quote.id, isLiked)
                }) {
                    Image(systemName: currentText.data!.like ? "heart.fill" : "heart").resizable()
                        .frame(width: 36.0, height: 36.0).foregroundColor(Color.black)
                }
            }
        }
        .padding(40)
        .background(Color.white.opacity(0.3)).cornerRadius(40.0).padding(20)
    }
}

class QuoteList {
    @State var userID: String
    @State var data: [QuoteView] = [QuoteView(), QuoteView()]
    let completionErrorHandler: (_ result: String) -> ()
    var serverClient: ServerClient?

    init(userID: String, completionErrorHandler: @escaping (_ result: String) -> ()) {
        self.userID = userID
        self.completionErrorHandler = completionErrorHandler
        self.serverClient = ServerClient(userID: userID, completionHandler: { index, result in
            self.data[index].setStates(result: result, isConnectionError: false)
        }, completionErrorHandler: { index, description in
            self.data[0].setStates(result: nil, isConnectionError: true)
            self.data[1].setStates(result: nil, isConnectionError: true)
            
            self.completionErrorHandler(description)
        })
    }

    public func setStates(index: Int) {
        self.serverClient!.loadQuote(index: index)
    }
}
