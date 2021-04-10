//
//  WordsViewController.swift
//  Topical Dictionary
//
//  Created by İbrahim Ethem Karalı on 30.07.2019.
//  Copyright © 2019 İbrahim Ethem Karalı. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class WordsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var tableData = [[String:Any]]()
    private var isAlreadyLoaded = true
    @IBOutlet var wordsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        fireBaseSettings()
        
        // Register Xib File
        wordsTableView.register(UINib(nibName: "WordTableCell", bundle: .none), forCellReuseIdentifier: "WordTableViewCell")
        
        wordsTableView.delegate = self
        wordsTableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        reloadTableIfNeeded()
    }
    
    func clearData() {
        isAlreadyLoaded = true
        tableData = [[String:Any]]()
        if wordsTableView != nil {
            wordsTableView.reloadData()
        }
        
    }
    
    private func reloadTableIfNeeded() {
        //print("trying to reload table")
        if isAlreadyLoaded {
            isAlreadyLoaded = false
            reloadTable()
        }
    }
    
    func reloadTable() {
        tableData = [[String:Any]]()
        wordsTableView.reloadData()
        
        
        var userID = String()
        if let user = Auth.auth().currentUser {
            userID = user.uid
        } else {
            return
        }
        
        db.collection("example").whereField("creater", isEqualTo: userID).getDocuments { (querySnapshot, err) in
            if err != nil {
                print("Error getting documents for words: \(err!)")
            } else {
                for document in querySnapshot!.documents {
                    for word in document.data()["words"] as! [[String:Any]] {
                        self.tableData.append(word)
                    }
                }
                DispatchQueue.main.async {
                    self.wordsTableView.reloadData()
                }
            }
        }
    }
    
    private func fireBaseSettings() {
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        db = Firestore.firestore()
        db.settings = settings
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableData.sort(by: {
            ($0["word"] as! String) < ($1["word"] as! String)
        })
        
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WordTableViewCell", for: indexPath) as! WordTableViewCell
        let word = tableData[indexPath.row]
        cell.wordLabel.text = word["word"] as? String
        cell.explanationLabel.text = word["description"] as? String
        cell.partOfSpeachLabel.text = word["partOfSpeech"] as? String
        
        return cell
    }

}
