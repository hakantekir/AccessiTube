//
//  PlayerViewModel.swift
//  AccessiTube
//
//  Created by Hakan Tekir on 7.03.2024.
//

import Combine
import AVFoundation

class PlayerViewModel: ObservableObject {
    @Published var currentTestAction: TestAction?
    @Published var results: PlayerTestModel? = nil
    
    private var player: AVPlayer
    private var testActions: [TestAction] = []
    private var testResults: PlayerTestModel
    private var actionStartDate = Date()
    
    private var timeObservation: Any?
    let publisher = PassthroughSubject<CMTime, Never>()
    
    init(player: AVPlayer, playerType: PlayerType = .innovative) {
        self.player = player
        testResults = PlayerTestModel(tests: [], playerType: playerType)
        
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
        if case .seek(let actionTime) = currentTestAction, case .seek(let time) = action {
            guard let duration = player.currentItem?.duration, abs((actionTime.seconds - time.seconds) / duration.seconds) < 0.1 else {
                return
            }
        } else if action != currentTestAction { return }
        
        guard let currentTestAction else {
            return
        }
        let time: Double = -actionStartDate.timeIntervalSinceNow
        testResults.tests.append(PlayerTest(time: time, action: currentTestAction))
        
        newTest()
    }
    
    func createTestActions() {
        guard let duration = player.currentItem?.duration else {
            return
        }
        
        print(duration.seconds)
        testActions = [
            TestAction.button(
                .pause
            ),
            TestAction.seek(
                CMTime(seconds: (duration.seconds * .random(in: 0.0...1.0)), preferredTimescale: 600)
            ),
            TestAction.button(
                .backward
            ),
            TestAction.seek(
                CMTime(seconds: (duration.seconds * 0.5), preferredTimescale: 600)
            ),
            TestAction.button(
                .forward
            ),
            TestAction.button(
                .pause
            )
        ]
        
        newTest()
    }
    
    private func newTest() {
        guard let action = testActions.popLast() else {
            saveTest()
            currentTestAction = nil
            return
        }
        actionStartDate = .now
        currentTestAction = action
    }
    
    private func saveTest() {
        results = testResults
    }
}
