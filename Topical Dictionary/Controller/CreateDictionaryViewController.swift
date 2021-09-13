//
//  CreateDictionaryViewController.swift
//  Topical Dictionary
//
//  Created by İbrahim Ethem Karalı on 13.04.2019.
//  Copyright © 2019 İbrahim Ethem Karalı. All rights reserved.
//


// TODO: When dictionary is added it is placed to the right order. You need to sort the dictionaries.

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import GoogleMobileAds


class CreateDictionaryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var interstitial: GADInterstitial!
    
    @IBOutlet var addDictionaryTable: UITableView!
    
    var thisDictionary = DictionaryModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fireBaseSettings()
        
        // Do any additional setup after loading the view.
        addDictionaryTable.delegate = self
        addDictionaryTable.dataSource = self
        
        // Register xib files
        addDictionaryTable.register(UINib(nibName: "HeadTableViewCell", bundle: nil), forCellReuseIdentifier: "HeadCell")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Display ad if it is ready
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        } else {
            print("Ad wasn't ready")
        }
    }
    
    func fireBaseSettings() {
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        db = Firestore.firestore()
        db.settings = settings
    }
    
    //MARK: TapGesture
    
    @objc func somewhereTapped() {
        inputAccessoryView?.isHidden = true
        view.endEditing(true)
    }
    
    //MARK: - Saving the dictionary to FireBase
    
    
    func doneAction() {
        self.view.endEditing(true)
        thisDictionary.creator = Auth.auth().currentUser?.uid
        thisDictionary.date = Timestamp()
        
        do {
            let ref = try db.collection(Keys.dictionaryCollectionID.rawValue).addDocument(from: thisDictionary)
            print("Dictionary added with id: \(ref.documentID)")
            self.dismiss(animated: true, completion: nil)
        } catch {
            print("Error occured while adding the dictionary \(error as NSError)")
        }
    }
    
    
    //MARK: Adding the word with selected definition
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1, indexPath.row == 0 {
            doneAction()
        } else if indexPath.section == 1, indexPath.row == 1 {
            self.view.endEditing(true)
            self.dismiss(animated: true, completion: .none)
        }
    }
    
    //MARK: TableView Functions
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "HeadCell", for: indexPath) as! HeadTableViewCell
            
            // automaticaly fill the textField and textView with didSet method
            cell.topic = thisDictionary.topic ?? ""
            cell.explanation = thisDictionary.info ?? ""
            cell.updateText()
            
            cell.explanationTextView.isScrollEnabled = false
            //cell.tableView = tableView // WHY?
            cell.delegate = self
            
            return cell
            
        } else {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "doneCell", for: indexPath)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cancelCell", for: indexPath)
                return cell
            }
        }
    }

}

extension CreateDictionaryViewController: HeadCellDelegate {
    func titleDidChage(_ withText: String) {
        thisDictionary.topic = withText
    }
    
    func explanationDidChange(_ withText: String) {
        thisDictionary.info = withText
        self.addDictionaryTable.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
    }
}
