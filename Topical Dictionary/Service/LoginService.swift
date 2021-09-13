//
//  LoginService.swift
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
import CryptoKit
import AuthenticationServices

class LoginService {
    static var shared = LoginService()
    
    func setSnapshot(window: UIWindow) {
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        FirebaseApp.configure()

        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID

        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                if let token = AccessToken.current?.tokenString {
                    let params = ["fields": "first_name, last_name, email"]
                    let graphRequest = GraphRequest(graphPath: "me", parameters: params, tokenString: token, version: nil, httpMethod: .get)
                    graphRequest.start { (conn, result, error) in
                        if let err = error {
                            print("Error while requesting facebook data \(err)")
                        } else {
                            guard let json = result as? NSDictionary else { return }
                            if let email = json["email"] as? String {
                                user?.updateEmail(to: email, completion: nil)
                            }
                            if let firstName = json["first_name"] as? String, let lastName = json["last_name"] as? String {
                                user?.createProfileChangeRequest().displayName = "\(firstName.prefix(1).uppercased() + firstName.dropFirst()) \(lastName.prefix(1).uppercased() + lastName.dropFirst())"
                            }
                        }
                    }
                }

                let mainStoryBoard = UIStoryboard.init(name: "Main", bundle: nil)

                window.rootViewController = mainStoryBoard.instantiateInitialViewController()
            } else {

                let loginManager = LoginManager()
                loginManager.logOut()

                let loginRegisterStoryBoard = UIStoryboard.init(name: "LoginRegister", bundle: nil)

                window.rootViewController = loginRegisterStoryBoard.instantiateInitialViewController()
            }
        }
    }
    
}
