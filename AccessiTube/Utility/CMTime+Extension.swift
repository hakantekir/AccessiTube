//
//  CMTime+Extension.swift
//  AccessiTube
//
//  Created by Hakan Tekir on 6.03.2024.
//

import AVKit

extension CMTime {
    func toDurationString() -> String {
        let totalSeconds = seconds
        let hours = Int(totalSeconds / 3600)
        let minutes = Int((totalSeconds.truncatingRemainder(dividingBy: 3600)) / 60)
        let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}
