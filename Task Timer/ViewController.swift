//
//  ViewController.swift
//  Task Timer
//
//  Created by Joseph Chan on 4/8/17.
//  Copyright © 2017 Joseph Chan. All rights reserved.
//

import UIKit
import AudioToolbox

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    // MARK: --- Properties ---
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var countDownLabel: UILabel!
    @IBOutlet weak var timeDisplay: TimeDisplayView!
    @IBOutlet weak var playToggle: PlayToggle!
    @IBOutlet weak var resetButton: UIButton!

    // MARK: --- State ---
    private var pickerMin = 1
    private var pickerMax = 60
    private var pickerDuration: Int = 1  // Same as pickerMin for now
    private var tracker: TimeTracker?
    private var displayLink: CADisplayLink?
    
    enum TimerState {
        case stop, paused, run
    }
    private var state = TimerState.stop
    private var observingAppState: Bool = false

    // MARK: --- Action ---
    @IBAction func toggleTimer(_ sender: UIButton) {
        if sender == playToggle {
            switch state {
            case .stop:
                state = .run
                startTimer()
            case .paused:
                state = .run
                continueTimer()
            case .run:
                state = .paused
                pauseTimer()
            }
        } else if sender == resetButton && state != .stop {
            state = .stop
            stopTimer()
        }
    }
    
    // Keep the app only in portrait mode.
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get { return .portrait }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        picker.dataSource = self
        picker.delegate = self
        
        updateViews()
    }

    private func setupAppSwitchNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appEntersForeground),
            name: NSNotification.Name.UIApplicationWillEnterForeground,
            object: nil)
        
        observingAppState = true
    }
    
    private func removeAppSwitchNotification() {
        if observingAppState {
            NotificationCenter.default.removeObserver(self)
            observingAppState = false
        }
    }

    func appEntersForeground() {
        // Reinstate the animation that was removed when the app goes into
        // background.
        if let t = tracker {
            let duration = t.durationInSecs
            let timePassed = duration - t.timeLeftInSecs
            if timePassed > 0.0 {
                self.timeDisplay.start(duration: duration, from: timePassed)
            }
        }
    }
    
    func updateViews() {
        switch state {
        case .stop:
            countDownLabel.text = String(format: "%02d:00", pickerDuration)

        case .paused, .run:
            // Timer is already active.
            // We want 1.0 > t > 0.0 be displayed as 00:01, thus ceil. This
            // label reflects the time marker that was just passed.
            let timeLeftInSecs = ceil(tracker!.timeLeftInSecs)
            let minLeft = Int(timeLeftInSecs) / 60
            let secLeft = Int(timeLeftInSecs) % 60
            countDownLabel.text = String(format: "%02d:%02d", minLeft, secLeft)
        }
    }

    private func startDisplayLink() {
        stopDisplayLink()
        
        displayLink = CADisplayLink(target: self, selector: #selector(updateViews))
        displayLink?.add(to: .main, forMode: .commonModes)
    }
    
    private func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    // MARK: --- Timer state transitions ---
    private func startTimer() {        
        // Get the time from picker
        let row = picker.selectedRow(inComponent: 0)
        let duration: TimeInterval = Double(row + pickerMin) * 60.0
        tracker = TimeTracker(duration: duration) {
            [unowned self] _ in self.timerDone(aborting: false)
        }
        playToggle.isSelected = true
        
        // Kick of view transition, wait for it to finish, then kick off timer.
        UIView.transition(
            from: picker,
            to: timeDisplay,
            duration: 1.0,
            options: [.transitionFlipFromRight, .showHideTransitionViews],
            completion: {
                [unowned self] finished in
                if finished {
                    // Animation is removed when the app goes to background.
                    // So we set up notification to resume the animation.
                    self.setupAppSwitchNotification()

                    self.startDisplayLink()
                    self.tracker?.start()
                    self.timeDisplay.start(duration: duration, from: 0.0)
               }
        })
    }
    
    private func pauseTimer() {
        tracker?.pause()
        playToggle.isSelected = false
        timeDisplay.pause()
    }
    
    private func continueTimer() {
        tracker?.start()
        playToggle.isSelected = true
        timeDisplay.resume()
    }
    
    private func stopTimer() {
        tracker?.stop()
        timerDone(aborting: true)
    }
    
    private func timerDone(aborting: Bool) {
        stopDisplayLink()
        timeDisplay.reset()
        removeAppSwitchNotification()

        // let timeLeft = tracker?.timeLeftInSecs
        tracker = nil
        state = .stop
        if !aborting {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            NSLog("Timer Done!")
        }
        
        // Transition view back to picker.
        UIView.transition(
            from: timeDisplay,
            to: picker,
            duration: 1.0,
            options: [.transitionFlipFromLeft, .showHideTransitionViews],
            completion: { [unowned self] finished in
                if finished {
                    // Update the play button state.
                    self.playToggle.isSelected = false
        
                    // Sync the selection of the picker to update timedisplay
                    // again so the next transition animation shows correct time
                    // when the picker is not changed. It is easier to do it
                    // here than in startTimer because we don't have to force an
                    // intervening runloop to ensure the drawing takes place.
                    self.updateViews()
                }
        })
    }
    
    // MARK: --- UIPickerView delegate & datasource ---
    // Number of column in the picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // Number of rows in the picker
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        // Inclusive of max.
        return pickerMax - pickerMin + 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(format: "%d min", row + pickerMin)
    }
    
//    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
//        return view!
//    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerDuration = row + pickerMin
        // Given the picker view and the time display is never shown at the same
        // time, there is no logical need to update the time display view when
        // the selection changes. The goal of this update is to ensure that the
        // time display view has a chance to draw itself in the runloop before
        // any transition animation kicks in. Without this update, the animation
        // captures the old content for animation, and then flash to update the
        // view, which looks very janky.
        updateViews()
    }
}

