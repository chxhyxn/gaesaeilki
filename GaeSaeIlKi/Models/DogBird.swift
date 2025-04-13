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
    var name: String = "이름없는 개새"
    var type_id: Int = 0
    
    // CGPoint 대신 개별 속성으로 저장
    var x: Double
    var y: Double
    
    var failureNote: String
    var isFlying: Bool = false
    var rotation: Double = Double.random(in: 0...360)
    var speed: Double = Double.random(in: 1...3)
    var size: CGFloat = CGFloat.random(in: 60...120)
    
    // 방향 관련 속성 추가 (오른쪽 방향이면 true)
    var movingRight: Bool = false
    
    // 추가 속성
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
