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

    // MARK: Properties
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var countDownLabel: UILabel!
    @IBOutlet weak var timeDisplay: TimeDisplayView!
    @IBOutlet weak var startToggle: UIButton!
    @IBOutlet weak var resetButton: UIButton!

    // MARK: State
    private var pickerMin = 1
    private var pickerMax = 60
    private var pickerDuration: Int = 1  // Same as pickerMin for now
    private var tracker: TimeTracker?
    private var displayLink: CADisplayLink?
    
    enum TimerState {
        case stop, paused, run
    }
    var state = TimerState.stop

    // MARK: Action
    @IBAction func toggleTimer(_ sender: UIButton) {
        if sender == startToggle {
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
        resetButton.isEnabled = false
        
        updateViews()
    }

    func updateViews() {
        switch state {
        case .stop:
            // Timer is being set up.
            countDownLabel.text = String(format: "%02d:00", pickerDuration)

        case .paused, .run:
            // Timer is already active.
            let timeLeftInSecs = tracker!.timeLeftInSecs
            // let timeLeftRatio = timeLeftInSecs / tracker!.durationInSecs
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
    
    // MARK: Timer state transitions
    private func startTimer() {
        // Get the time from picker
        let row = picker.selectedRow(inComponent: 0)
        let duration: TimeInterval = Double(row + pickerMin) * 60.0
        tracker = TimeTracker(duration: duration) {
            [unowned self] _ in self.timerDone(aborting: false)
        }
        
        // Disable the Picker & Set the start button title
        picker.isUserInteractionEnabled = false
        picker.alpha = 0.0
        resetButton.isEnabled = true
        
        startToggle.setTitle("Pause", for: .normal)
        tracker?.start()
        startDisplayLink()
        timeDisplay.start(duration: duration)
    }
    
    private func pauseTimer() {
        tracker?.pause()
        startToggle.setTitle("Resume", for: .normal)
        timeDisplay.pause()
    }
    
    private func continueTimer() {
        tracker?.start()
        startToggle.setTitle("Pause", for: .normal)
        timeDisplay.resume()
    }
    
    private func stopTimer() {
        tracker?.stop()
        timerDone(aborting: true)
    }
    
    private func timerDone(aborting: Bool) {
        stopDisplayLink()
        timeDisplay.reset()

        // Re-enable the picker & update the start button title.
        picker.isUserInteractionEnabled = true
        picker.alpha = 1.0
        resetButton.isEnabled = false
        startToggle.setTitle("Start", for: .normal)
        
        // let timeLeft = tracker?.timeLeftInSecs
        tracker = nil
        state = .stop
        if !aborting {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
        updateViews()
    }
    
    // MARK: UIPickerView delegate & datasource
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
        updateViews()
    }
}

