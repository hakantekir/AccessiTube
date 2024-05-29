//
//  AccessiTubeApp.swift
//  AccessiTube
//
//  Created by Hakan Tekir on 6.03.2024.
//

import SwiftUI
import SwiftData

@main
struct AccessiTubeApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .modelContainer(for: PlayerTestModel.self)
    }
}
