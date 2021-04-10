//
//  EmailLoginViewController.swift
//  Topical Dictionary
//
//  Created by İbrahim Ethem Karalı on 1.02.2021.
//  Copyright © 2021 İbrahim Ethem Karalı. All rights reserved.
//

import UIKit
import FirebaseAuth

class EmailLoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var loginOrRegisterSegment: UISegmentedControl!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginTextfields: UIStackView!
    @IBOutlet weak var fullnameTextField: UITextField!
    
    var terms = UILabel() // add real terms and conditions
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailTextField.delegate = self
        emailTextField.tag = 1
        passwordTextField.delegate = self
        passwordTextField.tag = 2
        confirmPasswordTextField.delegate = self
        confirmPasswordTextField.tag = 3
        fullnameTextField.delegate = self
        fullnameTextField.tag = 0
        
        loginButton.layer.cornerRadius = 6.0
        
    }
    
    @IBAction func loginOrRegister(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            loginButton.setTitle("Sign in with Email", for: .normal)
            UIView.animate(withDuration: 0.4) {
                self.fullnameTextField.isHidden = true
                self.confirmPasswordTextField.isHidden = true
                self.terms.isHidden = true
            }
        } else {
            loginButton.setTitle("Sign up with Email", for: .normal)
            UIView.animate(withDuration: 0.4) {
                self.fullnameTextField.isHidden = false
                self.confirmPasswordTextField.isHidden = false
                self.terms.isHidden = false
            }
        }
    }
    
    @IBAction func login(_ sender: UIButton) {
        if loginOrRegisterSegment.isHidden {
            UIView.animate(withDuration: 0.3) {
                self.loginTextfields.isHidden = false
                self.loginOrRegisterSegment.isHidden = false
                self.terms.isHidden = false
                return
            }
        }
        
        if loginOrRegisterSegment.selectedSegmentIndex == 0 {
            // Login
            view.isUserInteractionEnabled = false
            Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (authDataResult, error) in
                if error != nil {
                    print("Error while signin: \(error!)")
                    let alert = UIAlertController(title: "Have an issue", message: error?.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    
                    self.present(alert, animated: true, completion: nil)
                    self.view.isUserInteractionEnabled = true
                    
                    return
                }
                
                if let authDataRes = authDataResult {
                    print("user signed in: UID: \(authDataRes.user.uid)")
                    print("is email verified: \(authDataRes.user.isEmailVerified)")
                    DispatchQueue.main.async {
                        //self.setupTabbar()
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                self.view.isUserInteractionEnabled = true
            }
            
        } else {
            // TODO: Add register with email
            // Register
        }
    }
    @IBAction func cancel(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
