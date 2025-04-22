//
//  Date+.swift
//  GaeSaeIlKi
//
//  Created by Sean Cho on 4/22/25.
//

import SwiftUI

extension Date {
    var formatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: self)
    }
}
