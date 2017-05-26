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
    @IBOutlet weak var resetButton: IconButton!
    @IBOutlet weak var settingsButton: IconButton!

    // MARK: --- State ---
    private var pickerMin = 1
    private var pickerMax = 60
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
        
        setupNextTimer()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
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
    
    func updateCountDownLabel() {
        switch state {
        case .stop:
            countDownLabel.text = String(format: "%02d:00", selectedTime())

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
        
        displayLink = CADisplayLink(target: self, selector: #selector(updateCountDownLabel))
        displayLink?.add(to: .main, forMode: .commonModes)
    }
    
    private func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    // MARK: --- Timer state transitions ---
    private func startTimer() {        
        // Get the time from picker
        let duration: TimeInterval = Double(selectedTime()) * 60.0
        tracker = TimeTracker(duration: duration) {
            [unowned self] _ in self.timerDone()
        }
        playToggle.isSelected = true
        settingsButton.isHidden = true
        updateCountDownLabel()
      
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
    }
    
    private func timerDone() {
        stopDisplayLink()
        timeDisplay.reset()
        removeAppSwitchNotification()

        let timeLeft = tracker!.timeLeftInSecs
        tracker = nil
        state = .stop
        // If the timeLeft is less than a 0.5s, then for all intend and purposes
        // it expired naturally.
        if timeLeft < 0.5 {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            NSLog("Timer Done!")
        }
        // Setting up the next timer will implicitly update the countDownLabel.
        // It doesn't cause any redraw problem because the transition hides the
        // label before the next runloop when the redraw occurs.
        setupNextTimer()
        
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
                    self.settingsButton.isHidden = false
               }
        })
    }
    
    private func setupNextTimer() {
        // Now set up the next round.
        // Reset the picker to the default value
        if state == .stop {
            let prefs = Preferences()
            setPickerSelection(duration: prefs.defaultTaskTime)
        }
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
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return countDownLabel.frame.height + 4
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.font = countDownLabel.font
        label.textAlignment = NSTextAlignment.center
        label.text = String(format: "%02d:00", row + pickerMin)
        return label
    }

    private func setPickerSelection(duration: Int) {
        picker.selectRow(duration - pickerMin, inComponent: 0, animated: true)
        // Sync the label view to the selected row.
        updateCountDownLabel()
    }
    
    private func selectedTime() -> Int {
        return picker.selectedRow(inComponent: 0) + pickerMin
    }
}

