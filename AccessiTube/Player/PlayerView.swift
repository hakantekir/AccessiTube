//
//  PlayerView.swift
//  AccessiTube
//
//  Created by Hakan Tekir on 6.03.2024.
//

import SwiftUI
import AVKit

struct PlayerView: View {
    private let player: AVPlayer
    
    init(_ url: URL) {
        player = AVPlayer(url: url)
    }
    
    var body: some View {
        ZStack {
            background
            playerView
        }
    }
    
    var background: some View {
        Color.black
            .ignoresSafeArea()
    }
    
    var playerView: some View {
        ZStack {
            VideoPlayer(player: player)
                .disabled(true)
                .ignoresSafeArea()
            PlayerControlView(player: player)
        }
    }
}

#Preview {
    let url = URL(string: "https://devstreaming-cdn.apple.com/videos/tech-talks/111386/2/7E5193EB-C506-450C-9475-0A311E73EAC4/cmaf.m3u8")!
    return PlayerView(url)
}
