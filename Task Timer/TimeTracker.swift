//
//  TimeTracker.swift
//  Task Timer
//
//  Created by Joseph Chan on 4/9/17.
//  Copyright © 2017 Joseph Chan. All rights reserved.
//

import Foundation

class TimeTracker {
    enum State {
        case paused, running, expired
    }
    // Total amount of time for this tracker
    let durationInSecs: TimeInterval
    let handler: (TimeTracker) -> ()
    
    private(set) var state: State = State.paused
    private var _timeRemains: TimeInterval = 0.0
    // timer and endTime are only set when the tracker goes from paused to running.
    private var _timer: Timer? = nil
    private var _endTime: Date = Date.distantFuture
    
    // Public computed property for how much time is left on this tracker.
    // Together with durationInSecs, one can find out how much time is spent.
    var timeLeftInSecs: TimeInterval {
        switch state {
        case .paused, .expired:
            return _timeRemains
        case .running:
            let delta = _endTime.timeIntervalSinceNow
            return delta > 0.0 ? delta : 0.0
        }
    }
    
    // Takes a duration in secs, and a handler to be called when the tracker
    // expires or stopped. The tracker is passed back to the handler as an
    // identifier.
    init(duration secs: TimeInterval, handler: @escaping (TimeTracker) -> ()) {
        // TODO: arg validation
        self.handler = handler
        durationInSecs = secs
        _timeRemains = secs
    }
    
    deinit {
        stopTimer()
    }
    
    // Move the Tracker from paused state to running state.
    func start() {
        if state == .paused {
            state = .running
            _endTime = Date() + _timeRemains
            _timer = Timer.scheduledTimer(
                withTimeInterval: _timeRemains,
                repeats: false) { [unowned self] _ in self.expire() }
        }
    }
    
    // Move the Tracker from running state to paused state.
    func pause() {
        if state == .running {
            stopTimer()
            _timeRemains = _endTime.timeIntervalSinceNow
            state = .paused
        }
    }
    
    // Move the Tracker from any state into expired state. The handler will
    // still be called.
    func stop() {
        stopTimer()
        expire()
    }
    
    private func stopTimer() {
        if _timer != nil {
            _timer?.invalidate()
            _timer = nil
        }
    }
    
    // Move the Tracker into the expired state.
    private func expire() {
        if state != .expired {
            _timeRemains = timeLeftInSecs
            state = .expired
            handler(self)
        }
    }
}
