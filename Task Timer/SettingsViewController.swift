//
//  SettingsViewController.swift
//  Task Timer
//
//  Created by Joseph Chan on 5/18/17.
//  Copyright © 2017 Joseph Chan. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet weak var taskTimeLabel: UILabel!
    @IBOutlet weak var restTimeLabel: UILabel!
    @IBOutlet weak var taskTimeStepper: UIStepper!
    @IBOutlet weak var restTimeStepper: UIStepper!

    override func viewDidLoad() {
        super.viewDidLoad()

        let prefs = Preferences()
        taskTimeStepper.value = Double(prefs.defaultTaskTime)
        restTimeStepper.value = Double(prefs.defaultRestTime)
        
        // Do any additional setup after loading the view.
        stepperChanged(taskTimeStepper)
        stepperChanged(restTimeStepper)
    }

    override func willMove(toParentViewController parent: UIViewController?) {
        if parent == nil {
            let prefs = Preferences()
            prefs.defaultTaskTime = Int(taskTimeStepper.value)
            prefs.defaultRestTime = Int(restTimeStepper.value)
        }
    }
    
    @IBAction func stepperChanged(_ sender: UIStepper) {
        if sender == taskTimeStepper {
            taskTimeLabel!.text = "\(Int(taskTimeStepper.value))"
        } else if sender == restTimeStepper {
            restTimeLabel!.text = "\(Int(restTimeStepper.value))"
        }
    }
}
