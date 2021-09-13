//
//  SettingsViewModel.swift
//  Topical Dictionary
//
//  Created by İbrahim Ethem Karalı on 8.09.2021.
//  Copyright © 2021 İbrahim Ethem Karalı. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewModel: NSObject {
    
    var theme: UIUserInterfaceStyle? {
        didSet {
            if let currentTheme = theme {
                UserDefaults.standard.setValue(currentTheme.rawValue, forKey: "theme")
                NotificationCenter.default.post(name: Notification.Name("ThemeDidChange"), object: nil)
            }
        }
    }
    
    override init() {
        theme = UIUserInterfaceStyle(rawValue: UserDefaults.standard.integer(forKey: "theme")) ?? .unspecified
        super.init()
    }
    
}
