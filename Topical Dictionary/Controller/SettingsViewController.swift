//
//  SettingsViewController.swift
//  Topical Dictionary
//
//  Created by İbrahim Ethem Karalı on 8.09.2021.
//  Copyright © 2021 İbrahim Ethem Karalı. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    var viewModel: SettingsViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @objc func onSwitchValueChanged(_ defaultSwitch: UISwitch) {
        if defaultSwitch.isOn {
            viewModel?.theme = .unspecified
            tableView.performBatchUpdates {
                self.tableView.deleteRows(at: [IndexPath(row: 1, section: 0), IndexPath(row: 2, section: 0)], with: .automatic)
            } completion: { success in
                self.tableView.layoutIfNeeded()
            }
        } else {
            viewModel?.theme = nil
            tableView.performBatchUpdates {
                self.tableView.insertRows(at: [IndexPath(row: 1, section: 0), IndexPath(row: 2, section: 0)], with: .automatic)
            } completion: { success in
                self.tableView.layoutIfNeeded()
            }

            tableView.reloadRows(at: [IndexPath(row: 1, section: 0), IndexPath(row: 2, section: 0)], with: .automatic)
        }
    }

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard viewModel != nil else { return 0}
        switch section {
        case 0:
            if viewModel?.theme == .unspecified {
                return 1
            } else {
                return 3
            }
        default:
            return 0
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
                cell.defaultSwitch.isOn = viewModel?.theme == .unspecified
                cell.defaultSwitch.addTarget(self, action: #selector(onSwitchValueChanged), for: .valueChanged)
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ThemeCell", for: indexPath) as! DefaultCell
                cell.textLabel?.text = "Light"
                if viewModel?.theme == .light {
                    cell.accessoryType = .checkmark
                }
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ThemeCell", for: indexPath) as! DefaultCell
                cell.textLabel?.text = "Dark"
                if viewModel?.theme == .dark {
                    cell.accessoryType = .checkmark
                }
                return cell
            default:
                return UITableViewCell()
            }
        } else {
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 1 {
                viewModel?.theme = .light
                tableView.reloadRows(at: [IndexPath(row: 1, section: 0), IndexPath(row: 2, section: 0)], with: .automatic)
            } else if indexPath.row == 2 {
                viewModel?.theme = .dark
                tableView.reloadRows(at: [IndexPath(row: 1, section: 0), IndexPath(row: 2, section: 0)], with: .automatic)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Application Theme"
        default:
            return nil
        }
    }

}
