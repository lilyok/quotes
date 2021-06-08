//
//  ColorScheme.swift
//  quotes
//
//  Created by Liliia Ivanova on 21.05.2021.
//

import SwiftUI

let ColorScheme = [
    // #FFEFB5 #FC9E83
    [Color(red: 1.00, green: 0.94, blue: 0.71), Color(red: 0.99, green: 0.62, blue: 0.51)],
    // #FFCBB5 #FC83D4
    [Color(red: 1.00, green: 0.80, blue: 0.71), Color(red: 0.99, green: 0.51, blue: 0.83)],
    // #B4FFFE #83BEFC
    [Color(red: 0.71, green: 1.00, blue: 0.92), Color(red: 0.51, green: 0.75, blue: 0.99)]
]

func saveColorScheme(colorID: Int) {
    UserDefaults.standard.set(colorID, forKey: "ColorSchemeColorID")
}

func loadColorScheme() -> Int {
    return UserDefaults.standard.object(forKey: "ColorSchemeColorID") as? Int ?? 0
}
