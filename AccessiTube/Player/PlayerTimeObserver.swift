//
//  PlayerTimeObserver.swift
//  AccessiTube
//
//  Created by Hakan Tekir on 7.03.2024.
//

import AVKit
import Combine

class PlayerTimeObserver {
    let player: AVPlayer
    var timeObservation: Any?
    let publisher = PassthroughSubject<CMTime, Never>()
    
    init(player: AVPlayer) {
        self.player = player
        
        timeObservation = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 600), queue: DispatchQueue.main) { [weak self] time in
            guard let self, self.player.currentItem != nil else { return }
            self.publisher.send(time)
        }

    }
    
    deinit {
        if let observer = timeObservation {
            player.removeTimeObserver(observer)
        }
    }
}
