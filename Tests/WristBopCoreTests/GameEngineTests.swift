import Foundation
import Testing
@testable import WristBopCore

@Suite("GameEngine Tests")
struct GameEngineTests {

    @Test("Start game resets state and sets first command")
    func testStartGameResetsState() {
        let randomizer = SequenceCommandRandomizer(sequence: [.shake, .flickUp, .twist])
        let store = InMemoryHighScoreStore()
        let engine = GameEngine(commandRandomizer: randomizer, highScoreStore: store)

        engine.startGame()

        #expect(engine.state.isPlaying == true)
        #expect(engine.state.isGameOver == false)
        #expect(engine.state.score == 0)
        #expect(engine.state.currentCommand != nil)
        #expect(engine.state.timePerCommand == GameConstants.initialTimePerCommand)
        #expect(engine.state.successCount == 0)
    }

    @Test("Correct gesture increments score")
    func testCorrectGestureIncrementsScore() {
        let randomizer = SequenceCommandRandomizer(sequence: [.shake, .flickUp, .twist])
        let store = InMemoryHighScoreStore()
        let engine = GameEngine(commandRandomizer: randomizer, highScoreStore: store)

        engine.startGame()
        let command = engine.state.currentCommand!

        engine.handleGestureMatch(command)

        #expect(engine.state.score == 1)
        #expect(engine.state.isPlaying == true)
        #expect(engine.state.isGameOver == false)
    }

    @Test("Wrong gesture is ignored within time window")
    func testWrongGestureIgnored() {
        let randomizer = SequenceCommandRandomizer(sequence: [.shake, .flickUp, .twist])
        let store = InMemoryHighScoreStore()
        let engine = GameEngine(commandRandomizer: randomizer, highScoreStore: store)

        engine.startGame()
        let command = engine.state.currentCommand!
        let wrongCommand: GestureType = command == .shake ? .flickUp : .shake

        engine.handleGestureMatch(wrongCommand)

        #expect(engine.state.score == 0)
        #expect(engine.state.isPlaying == true)
        #expect(engine.state.isGameOver == false)
        #expect(engine.state.currentCommand == command)
    }

    @Test("Difficulty ramps after 3 successes")
    func testDifficultyRamp() {
        let randomizer = SequenceCommandRandomizer(
            sequence: [.shake, .flickUp, .twist, .spinCrown]
        )
        let store = InMemoryHighScoreStore()
        let engine = GameEngine(commandRandomizer: randomizer, highScoreStore: store)

        engine.startGame()
        let initialTime = engine.state.timePerCommand

        // Complete 3 successful gestures
        for _ in 0..<3 {
            let command = engine.state.currentCommand!
            engine.handleGestureMatch(command)
        }

        let newTime = engine.state.timePerCommand
        #expect(newTime < initialTime)
        #expect(newTime == initialTime - GameConstants.timeDecrementPerRamp)
    }

    @Test("Speed-up cue triggers when time decreases")
    func testSpeedUpCueTriggers() {
        let randomizer = SequenceCommandRandomizer(
            sequence: [.shake, .flickUp, .twist, .spinCrown]
        )
        let store = InMemoryHighScoreStore()
        let engine = GameEngine(commandRandomizer: randomizer, highScoreStore: store)

        engine.startGame()

        // First 2 gestures should not trigger speed-up cue
        for _ in 0..<2 {
            let command = engine.state.currentCommand!
            engine.handleGestureMatch(command)
            #expect(engine.state.didTriggerSpeedUpCue == false)
        }

        // Third gesture should trigger speed-up cue
        let command = engine.state.currentCommand!
        engine.handleGestureMatch(command)
        #expect(engine.state.didTriggerSpeedUpCue == true)
    }

    @Test("Time floor is respected")
    func testTimeFloorRespected() {
        let randomizer = SequenceCommandRandomizer(
            sequence: Array(repeating: [.shake, .flickUp, .twist, .spinCrown], count: 20).flatMap { $0 }
        )
        let store = InMemoryHighScoreStore()
        let engine = GameEngine(commandRandomizer: randomizer, highScoreStore: store)

        engine.startGame()

        let rampsToFloor = Int(ceil(
            (GameConstants.initialTimePerCommand - GameConstants.minimumTimePerCommand)
            / GameConstants.timeDecrementPerRamp
        ))
        let gesturesToFloor = rampsToFloor * GameConstants.successesPerDifficultyRamp

        // Complete enough gestures to hit the floor (plus a buffer)
        for _ in 0..<(gesturesToFloor + GameConstants.successesPerDifficultyRamp) {
            let command = engine.state.currentCommand!
            engine.handleGestureMatch(command)
        }

        #expect(engine.state.timePerCommand >= GameConstants.minimumTimePerCommand)
    }

    @Test("Speed-up cue does not trigger when already at minimum")
    func testSpeedUpCueNotTriggeredAtMinimum() {
        let randomizer = SequenceCommandRandomizer(
            sequence: Array(repeating: [.shake, .flickUp, .twist, .spinCrown], count: 20).flatMap { $0 }
        )
        let store = InMemoryHighScoreStore()
        let engine = GameEngine(commandRandomizer: randomizer, highScoreStore: store)

        engine.startGame()

        let rampsToFloor = Int(ceil(
            (GameConstants.initialTimePerCommand - GameConstants.minimumTimePerCommand)
            / GameConstants.timeDecrementPerRamp
        ))
        let gesturesToFloor = rampsToFloor * GameConstants.successesPerDifficultyRamp

        // Complete enough gestures to hit the floor
        for _ in 0..<gesturesToFloor {
            let command = engine.state.currentCommand!
            engine.handleGestureMatch(command)
        }

        // Now at minimum time, complete 3 more gestures
        for i in 0..<3 {
            let command = engine.state.currentCommand!
            engine.handleGestureMatch(command)

            // On the third gesture, cue should NOT trigger since we're at minimum
            if i == 2 {
                #expect(engine.state.didTriggerSpeedUpCue == false)
            }
        }
    }

    @Test("Timeout ends game")
    func testTimeoutEndsGame() {
        let randomizer = SequenceCommandRandomizer(sequence: [.shake, .flickUp])
        let store = InMemoryHighScoreStore()
        let engine = GameEngine(commandRandomizer: randomizer, highScoreStore: store)

        engine.startGame()
        engine.handleTimeout()

        #expect(engine.state.isPlaying == false)
        #expect(engine.state.isGameOver == true)
    }

    @Test("High score is updated and persisted")
    func testHighScorePersistence() {
        let randomizer = SequenceCommandRandomizer(
            sequence: [.shake, .flickUp, .twist, .spinCrown]
        )
        let store = InMemoryHighScoreStore()
        let engine = GameEngine(commandRandomizer: randomizer, highScoreStore: store)

        engine.startGame()

        // Score some points
        for _ in 0..<5 {
            let command = engine.state.currentCommand!
            engine.handleGestureMatch(command)
        }

        engine.endGame()

        #expect(engine.state.highScore == 5)
        #expect(store.loadHighScore() == 5)
    }

    @Test("High score is not updated if score is lower")
    func testHighScoreNotUpdatedWhenLower() {
        let randomizer = SequenceCommandRandomizer(
            sequence: [.shake, .flickUp, .twist, .spinCrown]
        )
        let store = InMemoryHighScoreStore()
        store.saveHighScore(10)

        let engine = GameEngine(commandRandomizer: randomizer, highScoreStore: store)

        engine.startGame()

        // Score fewer points than high score
        for _ in 0..<3 {
            let command = engine.state.currentCommand!
            engine.handleGestureMatch(command)
        }

        engine.endGame()

        #expect(engine.state.highScore == 10)
        #expect(store.loadHighScore() == 10)
    }

    @Test("Next command excludes previous command")
    func testNextCommandExcludesPrevious() {
        let randomizer = SystemCommandRandomizer()
        let store = InMemoryHighScoreStore()
        let engine = GameEngine(commandRandomizer: randomizer, highScoreStore: store)

        engine.startGame()

        // Generate multiple commands and ensure they don't repeat
        var previousCommand = engine.state.currentCommand!

        for _ in 0..<10 {
            engine.handleGestureMatch(previousCommand)
            let newCommand = engine.state.currentCommand!
            #expect(newCommand != previousCommand)
            previousCommand = newCommand
        }
    }
}
