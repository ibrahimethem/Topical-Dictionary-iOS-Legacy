//
//  AccountViewController.swift
//  Topical Dictionary
//
//  Created by İbrahim Ethem Karalı on 3.12.2019.
//  Copyright © 2019 İbrahim Ethem Karalı. All rights reserved.
//

import UIKit
import FirebaseAuth

class AccountViewController: UIViewController {
    
    
    @IBOutlet weak var accountTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        accountTableView.dataSource = self
        accountTableView.delegate = self
    }
    
    func logout() {
        let auth = Auth.auth()
        do {
            try auth.signOut()
        } catch let signoutError as NSError {
            print("Error while signing out: \(signoutError)")
        }
    }
}

extension AccountViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "emailCell", for: indexPath)
            
            if let currentUser = Auth.auth().currentUser {
                if let displayname = currentUser.displayName {
                    cell.textLabel?.text = displayname
                    cell.detailTextLabel?.text = currentUser.email
                } else {
                    cell.textLabel?.text = currentUser.email
                    cell.detailTextLabel?.font = UIFont.init(name: "Roboto-LightItalic", size: 14.0)!
                    cell.detailTextLabel?.text = "There is no user information"
                }
                
            } else {
                cell.textLabel?.text = "Topical Dictionary"
            }
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath)
            
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "helpCell", for: indexPath)
            
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "termsCell", for: indexPath)
            
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "aboutCell", for: indexPath)
            
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "logoutCell", for: indexPath)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 75
        } else if indexPath.row == 5 {
            return 60
        } else {
            return 55
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 28
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 5:
            logout()
        default:
            print("\(tableView.cellForRow(at: indexPath)?.textLabel?.text ?? "no cell") is selected.")
        }
    }
    
}
