//
//  ServerClient.swift
//  quotes
//
//  Created by Liliia Ivanova on 04.06.2021.
//

import SwiftUI

let ENVNAME: String = "PROD"  // "TEST"  // "PROD"
let LINK: [String: String] = ["TEST": "http://127.0.0.1:8000/api", "PROD":  "https://quotes-lilyok.vercel.app/api"]


struct QuoteResponse: Codable {
    var quote: String
    var like: Bool
    var status: String
}


class ServerClient {
    let userID: String
    let completionHandler: (_ index: Int, _ result: QuoteResponse) -> ()
    var response: QuoteResponse?
    var isPreloaded: Bool = false
    
    init(userID: String, completionHandler: @escaping (_ index: Int, _ result: QuoteResponse) -> ()) {
        self.userID = userID
        self.completionHandler = completionHandler
        self.loadQuote()
    }

    private func manageResponse(index: Int, resp: QuoteResponse) {
        self.completionHandler(index, resp)  // resp.quote, false)
    }

    private func makeRequest(isNowPreloaded: Bool, index: Int, request: URLRequest) {
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode(QuoteResponse.self, from: data) {
                    DispatchQueue.main.async {
                        self.response = decodedResponse
                        if !isNowPreloaded {
                            self.manageResponse(index: index, resp: decodedResponse)
                            self.isPreloaded = true
                        }
                    }
                    return
                }
            }
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
            
        }.resume()
    }

    func loadQuote(index: Int = 0) {
        if isPreloaded && response != nil {
            manageResponse(index: index, resp: response!)
        }
        guard let url = URL(string: LINK[ENVNAME]!) else {
            print("Invalid URL")
            return
        }
        let request = URLRequest(url: url)
        let isNowPreloaded = self.isPreloaded
        makeRequest(isNowPreloaded: isNowPreloaded, index: index, request: request)
        if !self.isPreloaded {
            makeRequest(isNowPreloaded: true, index: index, request: request)
        }
    }
}


func getRandomQuote(userID: String) -> String {
    return "test quote\ntest \(Int.random(in: 1..<15))"
}
