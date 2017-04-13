//
//  ViewController.swift
//  Task Timer
//
//  Created by Joseph Chan on 4/8/17.
//  Copyright © 2017 Joseph Chan. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    // MARK: Properties
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var countDownLabel: UILabel!
    @IBOutlet weak var startToggle: UIButton!
    @IBOutlet weak var resetButton: UIButton!

    // MARK: State
    var pickerMin = 5
    var pickerMax = 60
    
    enum TimerState {
        case stop, paused, run
    }
    var state = TimerState.stop

    // MARK: Action
    @IBAction func toggleTimer(_ sender: UIButton) {
        var text = "Start"
        if sender == startToggle {
            switch state {
            case .stop:
                state = .run
                text = "Pause"
            case .paused:
                state = .run
                text = "Pause"
            case .run:
                state = .paused
                text = "Resume"
            }
        } else if sender == resetButton && state != .stop {
            state = .stop
        }
        startToggle.setTitle(text, for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.picker.dataSource = self
        self.picker.delegate = self
        
    }

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
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        countDownLabel.text = String(format: "%02d:00", row + pickerMin)
    }
}

