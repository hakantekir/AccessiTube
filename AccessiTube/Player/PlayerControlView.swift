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
    private let viewModel: PlayerViewModel
    @State private var knobRadius: Double = 15.0
    @State private var durationValue: Double = 0.0
    @State private var angleValue: Double = 0.0
    @State private var durationString = "00:00 - 00:00"
    @State private var isPaused = true
    @State private var lastSeekedValue: CMTime = .zero
    
    init(player: AVPlayer) {
        self.player = player
        viewModel = PlayerViewModel(player: player)
    }
    
    var body: some View {
        VStack {
            Spacer()
            HStack(alignment: .bottom) {
                durationText
                Spacer()
                durationView
            }
        }
    }
    
    var durationText: some View {
        Text(durationString)
            .font(.title3.bold())
            .padding()
            .foregroundStyle(.white)
            .background(.gray.opacity(0.2), in: .capsule)
    }
    
    var durationView: some View {
        ZStack {
            durationButtonsView
            durationSlider
        }
        .frame(width: radius + 15, height: radius + 15)
    }
    
    var durationButtonsView: some View {
        VStack {
            HStack(alignment: .top) {
                pauseButton
                    .padding([.top, .leading], 40)
                Spacer()
                forwardButton
                    .padding(.trailing, 75)
            }
            Spacer()
            HStack {
                backwardButton
                    .padding(.bottom, 25)
                Spacer()
            }
            .padding(.trailing, radius + 75)
        }
        .padding(.bottom, 35.0)
        .frame(width: radius + 100, height: radius + 75)
    }
    
    var pauseButton: some View {
        Button(action: {
            pausePlayer()
            viewModel.testAction(.button(.pause))
        }, label: {
            Image(systemName: isPaused ? "play.fill" : "pause.fill")
                .foregroundStyle(.white)
                .font(.largeTitle)
        })
    }
    
    var backwardButton: some View {
        Button(action: {
            forwardPlayer(-10.0)
            viewModel.testAction(.button(.backward))
        }, label: {
            Image(systemName: "backward.fill")
                .foregroundStyle(.white)
                .font(.largeTitle)
        })
    }
    
    var forwardButton: some View {
        Button(action: {
            forwardPlayer(10.0)
            viewModel.testAction(.button(.forward))
        }, label: {
            Image(systemName: "forward.fill")
                .foregroundStyle(.white)
                .font(.largeTitle)
        })
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
        .frame(width: radius + 15, height: radius + 15)
        .onReceive(viewModel.publisher, perform: { time in
            if let duration = player.currentItem?.duration.seconds, player.currentItem?.status == .readyToPlay {
                updateDuration(time.seconds / duration)
                changeDurationString(with: time)
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
                        changeDuration(location: value.location)
                    })
                    .onEnded({ _ in
                        viewModel.testAction(.seek(lastSeekedValue))
                    })
            )
    }
    
    private func changeDuration(location: CGPoint) {
        let angle = atan2(location.y - (knobRadius + 50), location.x - (knobRadius + 50)) + .pi/2.0
        let fixedAngle = angle < 0.0 ? angle + 2.0 * .pi : angle
        let value = (fixedAngle / (2.0 * .pi) - 0.75) * 4
        
        if 0 <= value && value <= 1 {
            let targetTime = CMTime(seconds: value * (player.currentItem?.duration.seconds ?? 0),                                    preferredTimescale: 600)
            updateDuration(value)
            changeDurationString(with: targetTime)
            player.seek(to: targetTime, toleranceBefore: .zero, toleranceAfter: .zero)
            lastSeekedValue = targetTime
        }
    }
    
    private func changeDurationString(with time: CMTime) {
        let current = time.toDurationString()
        let duration = player.currentItem?.duration.toDurationString()
        durationString = current + " - " + (duration ?? "")
    }
    
    private func updateDuration(_ value: Double) {
        durationValue = value
        angleValue = value * 90
    }
    
    private func pausePlayer() {
        if isPaused {
            player.play()
        } else {
            player.pause()
        }
        isPaused.toggle()
    }
    
    private func forwardPlayer(_ interval: Double) {
        if let duration = player.currentItem?.duration.seconds {
            let seconds = player.currentTime().seconds + interval
            let newDuration = {
                if seconds < 0 {
                    return 0.0
                } else if duration < seconds {
                    return duration
                } else {
                    return seconds.rounded(.down)
                }
            }()
            
            updateDuration(newDuration / duration)
            let targetTime = CMTime(seconds: newDuration,                                    preferredTimescale: 600)
            changeDurationString(with: targetTime)
            player.seek(to: targetTime)
        }
    }
}

#Preview {
    let url = URL(string: "https://devstreaming-cdn.apple.com/videos/tech-talks/111386/2/7E5193EB-C506-450C-9475-0A311E73EAC4/cmaf.m3u8")!
    let player = AVPlayer(url: url)
    return PlayerControlView(player: player)
}
