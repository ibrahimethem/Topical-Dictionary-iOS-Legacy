//
//  AppDelegate.swift
//  Topical Dictionary
//
//  Created by İbrahim Ethem Karalı on 2.03.2019.
//  Copyright © 2019 İbrahim Ethem Karalı. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn

var db: Firestore!

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    static var snapShotListeners: [ListenerRegistration] = []
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
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
                
                self.window?.rootViewController = mainStoryBoard.instantiateInitialViewController()
            } else {
                for listener in AppDelegate.snapShotListeners {
                    listener.remove()
                }
                AppDelegate.snapShotListeners = []
                
                let loginManager = LoginManager()
                loginManager.logOut()
                
                let loginRegisterStoryBoard = UIStoryboard.init(name: "LoginRegister", bundle: nil)
                
                self.window?.rootViewController = loginRegisterStoryBoard.instantiateInitialViewController()
            }
        }
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if url.scheme?.hasPrefix("fb") ?? false {
            return ApplicationDelegate.shared.application(app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
        } else {
            return GIDSignIn.sharedInstance().handle(url)
        }
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.all
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    

}

