//
//  ServerClient.swift
//  quotes
//
//  Created by Liliia Ivanova on 04.06.2021.
//

import SwiftUI

let ENVNAME: String = "PROD"  // "TEST"  // "PROD"  //
let LINK: [String: String] = ["TEST": "http://127.0.0.1:8000/api", "PROD":  "https://quotes-lilyok.vercel.app/api"]

struct QuoteResponse: Codable {
    var id: UUID
    var quote: String
    var like: Bool
    var status: String
}

struct Like: Codable {
    var userID: String
    var quoteID: UUID
    var isLike: Bool
}

struct Settings: Codable {
    var userID: String
    var categories: [String]
    var isExpanded: Bool
    var currentStartTime: Date
    var currentStopTime: Date
    var numberOfQuotes: Int
}

struct CommonResponse: Codable {
    var status: String
}

class ServerClient {
    let userID: String
    let completionHandler: (_ index: Int, _ result: QuoteResponse) -> ()
    let completionErrorHandler: (_ description: String) -> ()
    var quoteResponse: QuoteResponse?
    var isPreloaded: Bool = false
    
    init(userID: String, completionHandler: @escaping (_ index: Int, _ result: QuoteResponse) -> (),
         completionErrorHandler: @escaping (_ description: String) -> ()) {
        self.userID = userID
        self.completionHandler = completionHandler
        self.completionErrorHandler = completionErrorHandler
        self.loadQuote()
    }

    private func manageResponse(index: Int, resp: QuoteResponse) {
        self.completionHandler(index, resp)
    }

    private func makeRequest(isNowPreloaded: Bool, index: Int, request: URLRequest) {
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode(QuoteResponse.self, from: data) {
                    DispatchQueue.main.async {
                        self.quoteResponse = decodedResponse
                        if !isNowPreloaded {
                            self.manageResponse(index: index, resp: decodedResponse)
                            self.isPreloaded = true
                        }
                    }
                    return
                }
            }
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
            let appName = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? "quotes"
            self.completionErrorHandler(error?.localizedDescription ?? "Please restart \(appName)")
        }.resume()
    }

    func loadQuote(index: Int = 0) {
        if isPreloaded && quoteResponse != nil {
            manageResponse(index: index, resp: quoteResponse!)
        }
        guard let url = URL(string: "\(LINK[ENVNAME]!)?id=\(self.userID)") else {
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
    
    func setPostRequest(fullLink: String, encodedObj: Data) {
        guard let url = URL(string: fullLink) else {
            print("Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = encodedObj

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode(CommonResponse.self, from: data) {
                    DispatchQueue.main.async {
                        let commonResponse = decodedResponse
                        if commonResponse.status != "ok" {
                            print("Fetch failed: \(commonResponse.status)")
                            self.completionErrorHandler(commonResponse.status)
                        }
                    }
                    return
                }
            }
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
            let appName = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? "quotes"
            self.completionErrorHandler(error?.localizedDescription ?? "Please restart \(appName)")
        }.resume()
    }

    func setLike(quoteID: UUID, isLike: Bool) {
        let likeObj = Like(userID: self.userID, quoteID: quoteID, isLike: isLike)
        guard let encoded = try? JSONEncoder().encode(likeObj) else {
            print("Failed to encode likeObj")
            return
        }
        self.setPostRequest(fullLink: "\(LINK[ENVNAME]!)/like", encodedObj: encoded)
    }
    
    
    func saveSettings() {        
        let categories = Array(loadSelectedCategories().filter { $0.value == true }.keys)
        let (isExpanded, currentStartTime, currentStopTime, numberOfQuotes) = loadAllNotificationSettings()
        
        let settingsObj = Settings(userID: self.userID, categories: categories, isExpanded: isExpanded,
                                   currentStartTime: currentStartTime, currentStopTime: currentStopTime, numberOfQuotes: numberOfQuotes)
        
        let encoder = JSONEncoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "HH:mm"  // "HH:mm Zzzz"
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        
        guard let encoded = try? encoder.encode(settingsObj) else {
            print("Failed to encode settingsObj")
            return
        }
        self.setPostRequest(fullLink: "\(LINK[ENVNAME]!)/settings", encodedObj: encoded)    
    }
}
