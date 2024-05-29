//
//  PlayerTestModel.swift
//  AccessiTube
//
//  Created by Hakan Tekir on 25.05.2024.
//

import AVFoundation
import SwiftData

struct PlayerTestStruct: Codable {
    let id: String
    let playerType: String
    var tests: [PlayerTest]
    
    init(testModel: PlayerTestModel) {
        id = testModel.id
        playerType = testModel.playerType
        tests = testModel.tests
    }
}

@Model
class PlayerTestModel {
    let id: String
    let playerType: String
    var tests: [PlayerTest]
    
    init(tests: [PlayerTest], playerType: PlayerType) {
        id = UUID().uuidString
        self.playerType = playerType.name
        self.tests = tests
    }
    
    func toStructModel() -> PlayerTestStruct {
        PlayerTestStruct(testModel: self)
    }
}

class PlayerTest: Codable {
    let time: Double
    let action: String
    
    init(time: Double, action: TestAction) {
        self.time = time
        self.action = action.testText
    }
}

enum PlayerType {
    case classic
    case innovative
    
    var name: String {
        switch self {
        case .classic:
            "classic"
        case .innovative:
            "innovative"
        }
    }
}

enum TestAction: Comparable {
    case seek(CMTime)
    case button(TestButton)
    
    var text: String {
        switch self {
        case .seek(let cmTime):
            "\(cmTime.toDurationString())'e sar"
        case .button(let testButton):
            "\(testButton.name) butonuna bas"
        }
    }
    
    var testText: String {
        switch self {
        case .seek(let cmTime):
            "seek"
        case .button(let testButton):
            "button"
        }
    }
}

enum TestButton: Comparable {
    case backward
    case forward
    case pause
    
    var name: String {
        switch self {
        case .backward:
            "Geri"
        case .forward:
            "İleri"
        case .pause:
            "Durdur/Başlat"
        }
    }
}

