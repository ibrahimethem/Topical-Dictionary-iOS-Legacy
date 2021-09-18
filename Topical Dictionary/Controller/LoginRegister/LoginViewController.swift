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
import CryptoKit
import AuthenticationServices
import NVActivityIndicatorView

class LoginViewController: UIViewController, UIScrollViewDelegate, GIDSignInDelegate {
    
    fileprivate var currentNonce: String?
    fileprivate var myActivityIndicator: MyActivityIndicator?
    
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
        
        
        let buttonRadius: CGFloat = 8.0
        
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
        fbLoginManager.logIn(permissions: ["email", "public_profile"], from: self) { (loginResult, error) in
            if error != nil {
                self.displayAlert(detail: error!.localizedDescription, title: "Facebook Login")
            }
            if let currentToken = AccessToken.current {
                let credential = FacebookAuthProvider.credential(withAccessToken: currentToken.tokenString)
                self.startLoading()
                Auth.auth().signIn(with: credential) { (authResult, error) in
                    if let error = error as NSError? {
                        self.myActivityIndicator?.endActivity()
                        self.displayAlert(detail: error.localizedDescription, title: "Facebook Login")
                    } else {
                        DispatchQueue.main.async {
                            self.myActivityIndicator?.endActivity()
                        }
                    }
                }
            } else {
                self.myActivityIndicator?.endActivity()
            }
        }
    }
    
    // MARK: Apple Login
    
    
    @IBAction func appleLogin(_ sender: UIButton) {
        startSignInWithAppleFlow()
    }
    
    // MARK: Google Login
    
    @IBAction func googleLogin(_ sender: UIButton) {
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        displayAlert(detail: error.localizedDescription, title: "Something Went Wrong")
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil {
            displayAlert(detail: error.localizedDescription, title: "Something Went Wrong")
        } else {
            guard let authentication = user.authentication else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
            self.startLoading()
            Auth.auth().signIn(with: credential) { (authDataResult, error) in
                if error != nil {
                    self.displayAlert(detail: error!.localizedDescription, title: "Something Went Wrong")
                    return
                }
                if let authResult = authDataResult {
                    self.myActivityIndicator?.endActivity()
                    print("user logged in with: \(authResult.user.uid)")
                }
            }
            
        }
    }
    
    
    // MARK: - Text Field Functions
    
    
    @objc private func somewhereTapped() {
        view.endEditing(true)
    }
    
    fileprivate func displayAlert(detail: String, title: String?) {
        let alert = UIAlertController(title: title ?? "Warning", message: detail, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true) {
            self.myActivityIndicator?.endActivity()
        }
    }
    
    fileprivate func startLoading() {
        if myActivityIndicator != nil {
            myActivityIndicator?.endActivity()
        }
        myActivityIndicator = view.addMyActivityIndicator()
    }

}


extension LoginViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      let charset: Array<Character> =
          Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
      var result = ""
      var remainingLength = length

      while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
          var random: UInt8 = 0
          let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
          if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
          }
          return random
        }

        randoms.forEach { random in
          if remainingLength == 0 {
            return
          }

          if random < charset.count {
            result.append(charset[Int(random)])
            remainingLength -= 1
          }
        }
      }

      return result
    }
    
    
    func startSignInWithAppleFlow() {
      let nonce = randomNonceString()
      currentNonce = nonce
      let appleIDProvider = ASAuthorizationAppleIDProvider()
      let request = appleIDProvider.createRequest()
      request.requestedScopes = [.fullName, .email]
      request.nonce = sha256(nonce)

      let authorizationController = ASAuthorizationController(authorizationRequests: [request])
      authorizationController.delegate = self
      authorizationController.presentationContextProvider = self
      authorizationController.performRequests()
    }

    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
      }.joined()

      return hashString
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
              guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
              }
              guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
              }
              guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
              }
              // Initialize a Firebase credential.
              let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                        idToken: idTokenString,
                                                        rawNonce: nonce)
              // Sign in with Firebase.
            self.startLoading()
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if error != nil {
                    self.displayAlert(detail: error!.localizedDescription, title: "Something Went Wrong")
                    return
                }
                self.myActivityIndicator?.endActivity()
                print("User logged in via Apple login with id: \(authResult?.user.uid ?? "nil")")
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Error while apple login: \(error.localizedDescription)")
    }
}
