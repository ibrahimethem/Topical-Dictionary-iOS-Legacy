//
//  AccountViewController.swift
//  Topical Dictionary
//
//  Created by İbrahim Ethem Karalı on 3.12.2019.
//  Copyright © 2019 İbrahim Ethem Karalı. All rights reserved.
//

import UIKit
import FirebaseAuth

class AccountViewController: UIViewController, AccountViewModelDelegate {
    
    @IBOutlet weak var accountTableView: UITableView!
    
    var viewModel: AccountViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = AccountViewModel(delegate: self)
        
        accountTableView.dataSource = self
        accountTableView.delegate = self
        
    }
    
    func logout() {
        let alert = UIAlertController(title: "Loging out", message: "You are currently logging out. Do you want to continue?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Logout", style: .cancel, handler: { _ in
            let auth = Auth.auth()
            do {
                try auth.signOut()
            } catch let signoutError as NSError {
                print("Error while signing out: \(signoutError)")
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        present(alert, animated: true) {
            self.accountTableView.deselectRow(at: IndexPath(row: 0, section: 2), animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SettingsSegue", let dest = segue.destination as? SettingsViewController {
            dest.viewModel = .init()
        }
    }
    
    
    // MARK: - View Model Delegate
    
    func didErrorOccured(_ viewModel: AccountViewModel, error: Error) {
        let alert = UIAlertController(title: "Something Went Wrong", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func didUpdateName(_ viewModel: AccountViewModel, name: String) {
        DispatchQueue.main.async {
            self.accountTableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
        }
    }
    
}

extension AccountViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return 4
        } else if section == 0 {
            if viewModel?.userModel.loginMethod == .email {
                return 2
            } else {
                return 1
            }
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ChangePasswordCell", for: indexPath)
                cell.textLabel?.text = "Change Password"
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "emailCell", for: indexPath)
            
            if let provider = viewModel?.userModel.loginMethod {
                switch provider {
                case .email:
                    print("email")
                case .apple:
                    print("apple")
                case .facebook:
                    print("facebook")
                case .google:
                    print("google")
                }
            }
            
            if let user = viewModel?.userModel {
                if user.loginMethod == .email {
                    let editButton = UIButton(frame: CGRect(x: 0, y: 0, width: 23, height: 23))
                    editButton.setImage(UIImage(named: "edit-profile"), for: .normal)
                    editButton.addTarget(self, action: #selector(editProfile), for: .touchUpInside)
                    
                    cell.accessoryView = editButton
                }
                
                if let name = user.fullName, let email = user.email {
                    cell.textLabel?.text = name
                    cell.detailTextLabel?.text = email
                } else if let email = user.email {
                    cell.textLabel?.text = email
                    cell.detailTextLabel?.font = UIFont.init(name: "Roboto-LightItalic", size: 14.0)!
                    if let provider = user.loginMethod?.rawValue {
                        cell.detailTextLabel?.text = "Signed in via \(provider)"
                    } else {
                        cell.detailTextLabel?.text = "There is no user information"
                    }
                    
                } else if let provider = user.loginMethod?.rawValue {
                    cell.detailTextLabel?.font = UIFont.init(name: "Roboto-LightItalic", size: 14.0)!
                    cell.textLabel?.text = "Signed in via \(provider)"
                    cell.detailTextLabel?.text = "There is no user information"
                } else {
                    cell.textLabel?.text = "There is no user information"
                    cell.detailTextLabel?.text = ""
                }
            }
            
            return cell
        case 1:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath)
                
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "helpCell", for: indexPath)
                
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "termsCell", for: indexPath)
                
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "aboutCell", for: indexPath)
                
                return cell
            }
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "logoutCell", for: indexPath)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                return 75
            } else {
                return 40
            }
        } else if indexPath.section == 1 {
            return 55
        } else {
            return 55
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
        if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                performSegue(withIdentifier: "SettingsSegue", sender: nil)
            case 2:
                performSegue(withIdentifier: "PrivacySegue", sender: nil)
            case 3:
                performSegue(withIdentifier: "AboutSegue", sender: nil)
            default:
                print(indexPath.row)
            }
        }
        
        else if indexPath.section == 2 {
            logout()
        } else if indexPath.section == 0, indexPath.row == 1 {
            performSegue(withIdentifier: "ChangePasswordSegue", sender: nil)
        }
    }
    
    @objc private func editProfile() {
        let alert = UIAlertController(title: "Update Your Name", message: "Enter the name you want to set", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "New Name"
            textField.textContentType = .name
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { _ in
            if let name = alert.textFields?.first?.text {
                self.viewModel?.updateDisplayName(with: name)
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
}
