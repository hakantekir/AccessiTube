//
//  PlayerControlView.swift
//  AccessiTube
//
//  Created by Hakan Tekir on 6.03.2024.
//

import SwiftUI
import AVKit

struct PlayerControlView: View {
    private let player: AVPlayer
    private let radius: Double = 175.0
    private let timeObserver: PlayerTimeObserver
    @State private var knobRadius: Double = 15.0
    @State private var durationValue: Double = 0.0
    @State private var angleValue: Double = 0.0
    @State private var durationString = "00:00"
    
    init(player: AVPlayer) {
        self.player = player
        self.timeObserver = PlayerTimeObserver(player: player)
    }
    
    var body: some View {
        VStack {
            Spacer()
            HStack(alignment: .bottom) {
                durationText
                Spacer()
                durationSlider
            }
        }
    }
    
    var durationText: some View {
        Text(durationString)
            .font(.largeTitle)
            .padding()
            .foregroundStyle(.white)
    }
    
    var durationSlider: some View {
        ZStack {
            slider
            knob
        }
        .frame(width: radius + knobRadius, height: radius + knobRadius)
        .padding(20)
        .offset(CGSize(width: (radius + knobRadius) / 2, height: (radius + knobRadius) / 2))
        .clipped()
        .onReceive(timeObserver.publisher, perform: { time in
            if let duration = player.currentItem?.duration.seconds, player.currentItem?.status == .readyToPlay {
                updateDuration(time.seconds / duration)
                durationString = time.toDurationString()
            }
        })
    }
    
    var slider: some View {
        Group {
            Circle()
                .trim(from: 0.0, to: 0.25)
                .stroke(Color.gray)
            Circle()
                .trim(from: 0.0, to: durationValue/4)
                .stroke(Color.red, lineWidth: 2.5)
        }
        .rotationEffect(.degrees(180))
        .frame(width: radius * 2, height: radius * 2)
    }
    
    var knob: some View {
        Circle()
            .fill(Color.red)
            .frame(width: knobRadius * 2, height: knobRadius * 2)
            .padding(50)
            .offset(x: -radius)
            .rotationEffect(Angle.degrees(Double(angleValue)))
            .gesture(
                DragGesture(minimumDistance: 0.0)
                    .onChanged({ value in
                        knobRadius = 20
                        changeDuration(location: value.location)
                    })
                    .onEnded({ _ in
                        knobRadius = 15
                    })
            )
    }
    
    private func changeDuration(location: CGPoint) {
        let angle = atan2(location.y - (knobRadius + 50), location.x - (knobRadius + 50)) + .pi/2.0
        let fixedAngle = angle < 0.0 ? angle + 2.0 * .pi : angle
        let value = (fixedAngle / (2.0 * .pi) - 0.75) * 4
        
        if value >= 0 && value <= 1 {
            let targetTime = CMTime(seconds: value * (player.currentItem?.duration.seconds ?? 0),                                    preferredTimescale: 600)
            updateDuration(value)
            durationString = targetTime.toDurationString()
            player.seek(to: targetTime)
        }
    }
    
    private func updateDuration(_ value: Double) {
        durationValue = value
        angleValue = value * 90
    }
}

#Preview {
    let url = URL(string: "https://devstreaming-cdn.apple.com/videos/tech-talks/111386/2/7E5193EB-C506-450C-9475-0A311E73EAC4/cmaf.m3u8")!
    let player = AVPlayer(url: url)
    return PlayerControlView(player: player)
}
