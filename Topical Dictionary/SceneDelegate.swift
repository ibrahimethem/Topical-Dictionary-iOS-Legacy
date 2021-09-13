//
//  SceneDelegate.swift
//  Topical Dictionary
//
//  Created by İbrahim Ethem Karalı on 22.06.2021.
//  Copyright © 2021 İbrahim Ethem Karalı. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import IQKeyboardManagerSwift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        
        guard window != nil  else { return }
        LoginService.shared.setSnapshot(window: window!)
        
        let theme = UserDefaults.standard.integer(forKey: "theme")
        self.window!.overrideUserInterfaceStyle = UIUserInterfaceStyle(rawValue: theme) ?? .unspecified
        
        NotificationCenter.default.addObserver(forName: Notification.Name("ThemeDidChange"), object: nil, queue: nil) { notification in
            let theme = UserDefaults.standard.integer(forKey: "theme")
            self.window!.overrideUserInterfaceStyle = UIUserInterfaceStyle(rawValue: theme) ?? .unspecified
        }
        
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        
        guard let url = URLContexts.first?.url else {
            return
        }
        ApplicationDelegate.shared.application(
            UIApplication.shared,
            open: url,
            sourceApplication: nil,
            annotation: [UIApplication.OpenURLOptionsKey.annotation]
        )
    }
    
}
