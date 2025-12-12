//
//  WristBopTests.swift
//  WristBopTests
//
//  Created by Stewart Chan on 2025-12-05.
//

import Foundation
import Testing
@testable import WristBop
import WristBopCore

struct WristBopTests {

    @Test func testWristBopCoreImport() async throws {
        // Verify WristBopCore is properly linked by accessing its types
        let gestures = GestureType.allCases
        #expect(gestures.count == 4)
        #expect(gestures.contains(.shake))
        #expect(gestures.contains(.flickUp))
        #expect(gestures.contains(.twist))
        #expect(gestures.contains(.spinCrown))
    }

    @Test func testGameConstants() async throws {
        // Verify GameConstants are accessible
        #expect(GameConstants.initialTimePerCommand > 0)
        #expect(GameConstants.minimumTimePerCommand > 0)
        #expect(GameConstants.timeDecrementPerRamp > 0)
        #expect(GameConstants.successesPerDifficultyRamp > 0)
        #expect(GameConstants.highScoreKey == "WristBopHighScore")
    }

    @Test func testHighScoreStore() async throws {
        // Verify HighScoreStore functionality
        let store = UserDefaultsHighScoreStore()
        let originalScore = store.loadHighScore()

        defer {
            if originalScore > 0 {
                store.saveHighScore(originalScore)
            } else {
                UserDefaults.standard.removeObject(forKey: GameConstants.highScoreKey)
            }
        }

        // Save a test score
        store.saveHighScore(42)

        // Verify it was saved
        let loadedScore = store.loadHighScore()
        #expect(loadedScore == 42)
    }

    @Test func testGestureTypeDisplayNames() async throws {
        // Verify gesture display names are correct
        #expect(GestureType.shake.displayName == "Shake it!")
        #expect(GestureType.flickUp.displayName == "Flick it!")
        #expect(GestureType.twist.displayName == "Twist it!")
        #expect(GestureType.spinCrown.displayName == "Spin it!")
    }

    @Test func testThemeColors() async throws {
        // Verify Theme is accessible and has valid colors
        let primaryColor = Theme.primaryColor
        let accentColor = Theme.accentColor

        // Colors should be non-nil (basic smoke test)
        #expect(Theme.cornerRadius > 0)
        #expect(Theme.standardPadding > 0)
        #expect(Theme.largePadding > 0)
    }

}
