//
//  LoginViewController.swift
//  Topical Dictionary
//
//  Created by İbrahim Ethem Karalı on 14.09.2020.
//  Copyright © 2020 İbrahim Ethem Karalı. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import FBSDKCoreKit
import GoogleSignIn

class LoginViewController: UIViewController, UIScrollViewDelegate, GIDSignInDelegate {
    
    // Definitiion of the components
    @IBOutlet weak var logoHeight: NSLayoutConstraint!
    
    @IBOutlet weak var bottomSpaceHeight: NSLayoutConstraint!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var appleButton: UIButton!
    @IBOutlet weak var googleButton: UIButton!
    
    let fbLoginManager = LoginManager()
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var tabbar: UITabBarController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let buttonRadius: CGFloat = 6.0
        
        appleButton.layer.cornerRadius = buttonRadius
        googleButton.layer.cornerRadius = buttonRadius
        loginButton.layer.cornerRadius = buttonRadius
        facebookButton.layer.cornerRadius = buttonRadius
        
        
        scrollView.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(somewhereTapped))
        self.view.addGestureRecognizer(tapGesture)
        
        GIDSignIn.sharedInstance()?.delegate = self
        
    }
    
    // MARK: Facebook login
    
    
    @IBAction func facebookLogin(_ sender: UIButton) {
        fbLoginManager.logIn(permissions: ["email, public_profile"], from: self) { (loginResult, error) in
            if error != nil {
                print(error!)
            }
            
            if let currentToken = AccessToken.current {
                let credential = FacebookAuthProvider.credential(withAccessToken: currentToken.tokenString)
                Auth.auth().signIn(with: credential) { (authResult, error) in
                    if let error = error {
                        let authError = error as NSError
                        print(authError)
                    } else {
                        DispatchQueue.main.async {
                            self.setupTabbar()
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: Apple Login
    
    
    @IBAction func appleLogin(_ sender: UIButton) {
        // TODO: Add apple login
    }
    
    // MARK: Google Login
    
    
    @IBAction func googleLogin(_ sender: UIButton) {
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print(error as Any)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        print("didSignFor")
        if error != nil {
            print(error!)
        } else {
            guard let authentication = user.authentication else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
            Auth.auth().signIn(with: credential) { (authDataResult, error) in
                if error != nil {
                    print(error!)
                    return
                }
                if let authResult = authDataResult {
                    print("user logged in with: \(authResult.user.uid)")
                }
            }
            
        }
    }
    
    // Login Helper
    // Setting tabbar to the first index and make the tab bar apear
    func setupTabbar() {
        if tabbar != nil {
            tabbar!.selectedIndex = 0
            tabbar!.tabBar.isHidden = false
        }
    }
    
    // MARK: - Text Field Functions
    
    
    @objc private func somewhereTapped() {
        view.endEditing(true)
    }
    
    
    // MARK: - Scroll View Functions
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //view.endEditing(true)
    }

}

extension UIScrollView {
    func scrollToView(view: UIView, animated: Bool) {
        if let origin = view.superview {
                    // Get the Y position of your child view
            let childStartPoint = origin.convert(view.frame.origin, to: self)
                    // Scroll to a rectangle starting at the Y of your subview, with a height of the scrollview
                    self.scrollRectToVisible(CGRect(x:0, y:childStartPoint.y,width: 1,height: self.frame.height), animated: animated)
                }
    }
}
