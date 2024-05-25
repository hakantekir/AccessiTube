//
//  PlayerViewModel.swift
//  AccessiTube
//
//  Created by Hakan Tekir on 7.03.2024.
//

import Combine
import AVFoundation

class PlayerViewModel: ObservableObject {
    var player: AVPlayer
    @Published var currentTestAction: TestAction = .button(.pause)
    var actionStartDate: Date
    
    var timeObservation: Any?
    let publisher = PassthroughSubject<CMTime, Never>()
    
    init(player: AVPlayer) {
        self.player = player
        actionStartDate = .now
        
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
    
    func testAction(_ action: TestAction) {
        guard action == currentTestAction else {
            return
        }
    }
}

enum TestAction: Comparable {
    case seek(CMTime)
    case button(TestButton)
}

enum TestButton: Comparable {
    case backward
    case forward
    case pause
}
