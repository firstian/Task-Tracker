//
//  TimeTrackerTests.swift
//  Task Timer
//
//  Created by Joseph Chan on 4/11/17.
//  Copyright © 2017 Joseph Chan. All rights reserved.
//

import Foundation
import XCTest
@testable import Task_Timer

class TimeTrackerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testStartToExpire() {
        var fired = false
        let currTime = Date()
        let tracker = TimeTracker(duration: 3.0) { _ in fired = true }
        XCTAssertEqual(tracker.state, TimeTracker.State.paused)
        XCTAssertEqual(tracker.durationInSecs, 3.0)
        XCTAssertEqual(tracker.timeLeftInSecs, 3.0)
        
        tracker.start()
        RunLoop.current.run(until: (currTime + 1.0))
        XCTAssert(!fired)
        XCTAssertEqual(tracker.state, TimeTracker.State.running)
        XCTAssertEqual(tracker.durationInSecs, 3.0)
        XCTAssertEqualWithAccuracy(tracker.timeLeftInSecs, 2.0, accuracy: 0.1)

        RunLoop.current.run(until: (currTime + 3.1))
        XCTAssert(fired)
        XCTAssertEqual(tracker.state, TimeTracker.State.expired)
        XCTAssertEqual(tracker.timeLeftInSecs, 0.0)
    }

    func testStartToExpireWithPause() {
        var fired = false
        let currTime = Date()
        let tracker = TimeTracker(duration: 3.0) { _ in fired = true }

        tracker.start()
        RunLoop.current.run(until: (currTime + 1.0))
        XCTAssert(!fired)
        XCTAssertEqual(tracker.state, TimeTracker.State.running)
        
        // Pause
        tracker.pause()
        XCTAssertEqual(tracker.state, TimeTracker.State.paused)
        XCTAssertEqualWithAccuracy(tracker.timeLeftInSecs, 2.0, accuracy: 0.1)

        // Wait for the original duration and make sure it is not fired.
        RunLoop.current.run(until: (currTime + 3.1))
        XCTAssert(!fired)
        
        // Restart the tracker and watch it run to finish.
        tracker.start()
        RunLoop.current.run(until: (Date() + 2.1))
        XCTAssert(fired)
        XCTAssertEqual(tracker.state, TimeTracker.State.expired)
        XCTAssertEqual(tracker.timeLeftInSecs, 0.0)
    }

    func testMultiplePause() {
        var fired = false
        let currTime = Date()
        let tracker = TimeTracker(duration: 3.0) { _ in fired = true }
        
        // Run for 1 sec and pause
        tracker.start()
        RunLoop.current.run(until: (currTime + 1.0))
        XCTAssert(!fired)
        XCTAssertEqual(tracker.state, TimeTracker.State.running)
        
        // Pause #1
        tracker.pause()
        XCTAssert(!fired)
        XCTAssertEqual(tracker.state, TimeTracker.State.paused)
        XCTAssertEqualWithAccuracy(tracker.timeLeftInSecs, 2.0, accuracy: 0.1)
        
        // Wait for the original duration and make sure it is not fired.
        RunLoop.current.run(until: (currTime + 3.1))
        XCTAssert(!fired)
        
        // Restart the tracker, run for 1 sec and pause again
        tracker.start()
        RunLoop.current.run(until: (Date() + 1.0))
        XCTAssert(!fired)
        XCTAssertEqual(tracker.state, TimeTracker.State.running)

        // Pause #2
        tracker.pause()
        XCTAssert(!fired)
        XCTAssertEqual(tracker.state, TimeTracker.State.paused)
        XCTAssertEqualWithAccuracy(tracker.timeLeftInSecs, 1.0, accuracy: 0.1)

        // Wait for 1 sec, start again and run to finish
        RunLoop.current.run(until: (Date() + 1.0))
        tracker.start()
        RunLoop.current.run(until: (Date() + 1.1))
        
        XCTAssert(fired)
        XCTAssertEqual(tracker.state, TimeTracker.State.expired)
        XCTAssertEqual(tracker.timeLeftInSecs, 0.0)
    }

    func testStartToStop() {
        var fired = false
        let currTime = Date()
        let tracker = TimeTracker(duration: 3.0) { _ in fired = true }

        tracker.start()
        RunLoop.current.run(until: (currTime + 1.0))
        XCTAssert(!fired)
        XCTAssertEqual(tracker.state, TimeTracker.State.running)
        XCTAssert(!fired)

        // Stop
        tracker.stop()
        XCTAssert(fired)
        XCTAssertEqual(tracker.state, TimeTracker.State.expired)
        XCTAssertEqualWithAccuracy(tracker.timeLeftInSecs, 2.0, accuracy: 0.1)
    }

    func testPauseToExpire() {
        var fired = false
        let currTime = Date()
        let tracker = TimeTracker(duration: 3.0) { _ in fired = true }
        
        tracker.start()
        RunLoop.current.run(until: (currTime + 1.0))
        XCTAssert(!fired)
        XCTAssertEqual(tracker.state, TimeTracker.State.running)
        XCTAssert(!fired)
        
        // Pause
        tracker.pause()
        XCTAssertEqual(tracker.state, TimeTracker.State.paused)
        XCTAssertEqualWithAccuracy(tracker.timeLeftInSecs, 2.0, accuracy: 0.1)
 
        // Stop
        tracker.stop()
        XCTAssert(fired)
        XCTAssertEqual(tracker.state, TimeTracker.State.expired)
        XCTAssertEqualWithAccuracy(tracker.timeLeftInSecs, 2.0, accuracy: 0.1)
    }
    
}
