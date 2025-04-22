//
//  DogBird.swift
//  GaeSaeIlKi
//
//  Created by Sean Cho on 4/9/25.
//

import SwiftUI
import SwiftData

@Model
class DogBird: Identifiable {
    var id = UUID()
    var type_id: Int = 0
    var x: Double
    var y: Double
    var failureNote: String
    var isFlyAway: Bool = false /// 이전 목표에서 썼던 실패 일기
    var isFlying: Bool = false
    var rotation: Double = Double.random(in: 0...360)
    var speed: Double = Double.random(in: 1...3)
    var size: CGFloat = CGFloat.random(in: 60...120)
    var movingRight: Bool = false
    var createdAt: Date = Date()
    var goalAtCreation: String = ""
    var position: CGPoint {
        get { CGPoint(x: x, y: y) }
        set {
            x = newValue.x
            y = newValue.y
        }
    }

    init(id: UUID = UUID(), type_id: Int, position: CGPoint, failureNote: String, goalAtCreation: String = "") {
        self.id = id
        self.type_id = type_id
        self.x = position.x
        self.y = position.y
        self.failureNote = failureNote
        self.goalAtCreation = goalAtCreation
        self.createdAt = Date()
    }
}
