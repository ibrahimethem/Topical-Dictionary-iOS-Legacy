//
//  ChangePasswordViewController.swift
//  Topical Dictionary
//
//  Created by İbrahim Ethem Karalı on 13.09.2021.
//  Copyright © 2021 İbrahim Ethem Karalı. All rights reserved.
//

import UIKit
import FirebaseAuth

class ChangePasswordViewController: UITableViewController {
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newPasswordTextField.passwordRules = UITextInputPasswordRules(descriptor: "required: digit; max-consecutive: 2; minlength: 6;")
        confirmPasswordTextField.passwordRules = UITextInputPasswordRules(descriptor: "required: digit; max-consecutive: 2; minlength: 6;")
    }
    
    private func updatePassword() {
        guard let password = passwordTextField.text,
              let newPassword = newPasswordTextField.text,
              let confirmPassword = confirmPasswordTextField.text else { return }
        
        if newPassword != confirmPassword {
            displayAlert(with: "New password and confirm password did not match", completion: nil)
            return
        } else if !checkPassword(newPassword) {
            displayAlert(with: "New password is not following the rules", completion: nil)
            return
        }
        
        if let currentUser = Auth.auth().currentUser, let email = currentUser.email {
            let cred = EmailAuthProvider.credential(withEmail: email, password: password)
            Auth.auth().currentUser?.reauthenticate(with: cred, completion: { authDataResult, error in
                if let err = error as NSError? {
                    self.displayAlert(with: err.localizedDescription, completion: nil)
                } else {
                    currentUser.updatePassword(to: newPassword, completion: { error in
                        if error != nil {
                            self.displayAlert(with: error!.localizedDescription, completion: nil)
                        } else {
                            self.displayAlert(with: "You successfuly changed the password") {
                                DispatchQueue.main.async {
                                    self.navigationController?.popViewController(animated: true)
                                }
                            }
                        }
                    })
                }
            })
        }
    }
    
    private func displayAlert(with message: String, completion: (() -> ())?) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: completion)
    }
    
    private func checkPassword(_ password: String) -> Bool {
        let checker = NSPredicate(format: "SELF MATCHES %@ ", "^(?=.*[A-Za-z])(?=.*[0-9]).{6,}$")
        return checker.evaluate(with: password)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 2 {
            view.endEditing(true)
            updatePassword()
        }
    }

}
