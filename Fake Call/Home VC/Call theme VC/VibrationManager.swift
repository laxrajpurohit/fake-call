//
//  VibrationManager.swift
//  Fake Call
//
//  Created by mac on 07/05/24.
//

import Foundation


import Foundation
import CoreHaptics

class VibrationManager {
    var engine: CHHapticEngine?
    var isRunning = false
    var timer: Timer?

    func startVibration() {
        guard !isRunning else { return }

        do {
            if engine == nil {
                engine = try CHHapticEngine()
                try engine?.start()
            }

            let continuousEvent = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [],
                relativeTime: 0,
                duration: 0.5
            )

            let pattern = try CHHapticPattern(events: [continuousEvent], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: CHHapticTimeImmediate)

            isRunning = true

        } catch {
            print("Error starting haptics: \(error)")
            isRunning = false
        }
    }

    func stopVibration() {
        engine?.stop(completionHandler: { error in
            if let error = error {
                print("Error stopping haptics: \(error)")
            }
        })

        isRunning = false
    }

    func startPeriodicVibration() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.startVibration()
        }
        timer?.fire() // Fire the timer immediately to start the first vibration
    }

    func stopPeriodicVibration() {
        timer?.invalidate()
        timer = nil
    }
}
