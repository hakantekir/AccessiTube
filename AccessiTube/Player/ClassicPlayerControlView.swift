//
//  ClassicPlayerControlView.swift
//  AccessiTube
//
//  Created by Hakan Tekir on 25.05.2024.
//

import SwiftUI
import AVKit

struct ClassicPlayerControlView: View {
    private let player: AVPlayer
    private let viewModel: PlayerViewModel
    @State private var durationValue = 0.0
    @State private var durationString = "00:00 - 00:00"
    @State private var isPaused = true
    @State private var isSeeking = false
    @State private var lastSeekedValue: CMTime = .zero
    
    init(player: AVPlayer) {
        self.player = player
        viewModel = PlayerViewModel(player: player)
    }
    var body: some View {
        VStack {
            Spacer()
            controlButtonsView
            Spacer()
            durationSliderView
        }
    }
    
    var controlButtonsView: some View {
        HStack {
            Spacer()
            backwardButton
            
            pauseButton
                .padding(.horizontal, 24.0)
            
            forwardButton
            Spacer()
        }
    }
    
    var durationSliderView: some View {
        HStack {
            Slider(value: $durationValue, onEditingChanged: { editing in
                isSeeking = editing
                if !editing {
                    player.seek(to: lastSeekedValue, toleranceBefore: .zero, toleranceAfter: .zero)
                    viewModel.testAction(.seek(lastSeekedValue))
                }
            })
            .onChange(of: durationValue, {
                onSliderValueChange()
            })
            .tint(.red)
            Text(durationString)
                .padding(.horizontal)
                .fixedSize()
        }
        .onReceive(viewModel.publisher, perform: { time in
            if let duration = player.currentItem?.duration.seconds, player.currentItem?.status == .readyToPlay && !isSeeking {
                updateDuration(time.seconds / duration)
                changeDurationString(with: time)
            }
        })
    }
    
    var pauseButton: some View {
        Button(action: {
            pausePlayer()
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
    
    private func pausePlayer() {
        if isPaused {
            player.play()
        } else {
            player.pause()
        }
        viewModel.testAction(.button(.pause))
        isPaused.toggle()
    }
    
    private func onSliderValueChange() {
        if let duration = player.currentItem?.duration.seconds {
            let newDuration = duration * durationValue
            let targetTime = CMTime(seconds: newDuration,                                    preferredTimescale: 600)
            changeDurationString(with: targetTime)
            lastSeekedValue = targetTime
        }
    }
    
    private func forwardPlayer(_ interval: Double) {
        if let duration = player.currentItem?.duration.seconds {
            let newDuration = player.currentTime().seconds + interval
            
            updateDuration(newDuration / duration)
            let targetTime = CMTime(seconds: newDuration,                                    preferredTimescale: 600)
            changeDurationString(with: targetTime)
            player.seek(to: targetTime)
        }
    }
    
    private func changeDurationString(with time: CMTime) {
        let current = time.toDurationString()
        let duration = player.currentItem?.duration.toDurationString()
        durationString = current + " - " + (duration ?? "")
    }
    
    private func updateDuration(_ value: Double) {
        durationValue = value
    }
}

#Preview {
    let url = URL(string: "https://devstreaming-cdn.apple.com/videos/tech-talks/111386/2/7E5193EB-C506-450C-9475-0A311E73EAC4/cmaf.m3u8")!
    let player = AVPlayer(url: url)
    return ClassicPlayerControlView(player: player)
}
