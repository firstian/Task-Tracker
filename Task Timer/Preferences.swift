//
//  Preferences.swift
//  Task Timer
//
//  Created by Joseph Chan on 5/22/17.
//  Copyright © 2017 Joseph Chan. All rights reserved.
//

import Foundation

class Preferences {
    private static let taskTimeKey = "default-task-time"
    private static let restTimeKey = "default-rest-time"
    
    var defaultTaskTime: Int {
        get {
            let value = getInt(key: Preferences.taskTimeKey)
            return value > 0 ? value : 25
        }
        set(value) {
            if value > 0 && value <= 60 {
                setInt(key: Preferences.taskTimeKey, value: value)
            }
        }
    }
    
    var defaultRestTime: Int {
        get {
            let value = getInt(key: Preferences.restTimeKey)
            return value > 0 ? value : 4
        }
        set(value) {
            if value > 0 && value <= 60 {
                setInt(key: Preferences.restTimeKey, value: value)
            }
        }
    }
    
    private func getInt(key: String) -> Int {
        let defaults = UserDefaults.standard
        return defaults.integer(forKey: key)
    }

    private func setInt(key: String, value: Int) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: key)
    }
}
