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


class CreateDictionaryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, WordManagerDelegate {
    
    
    var interstitial: GADInterstitial!
    
    @IBOutlet var addDictionaryTable: UITableView!
    @IBOutlet var toolBar: UIToolbar!
    
    //var headCell = HeadTableViewCell()
    
    var searchResultCells: [ResultTableViewCell] = [ResultTableViewCell]()
    var searchResults: [WordResult] = [WordResult]()
    var isWordSearching: Bool = false
    var isWordExist: Bool = true
    
    var addedWords: [String: WordResult] = [String: WordResult]()
    
    
    var searchedWord = WordData()
    var wordManager = WordManager()
    var thisDictionary = DictionaryModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fireBaseSettings()
        
        wordManager.delegate = self
        
        
        // Do any additional setup after loading the view.
        addDictionaryTable.delegate = self
        addDictionaryTable.dataSource = self
        
        // Register xib files
        addDictionaryTable.register(UINib(nibName: "HeadTableViewCell", bundle: nil), forCellReuseIdentifier: "HeadCell")
        addDictionaryTable.register(UINib(nibName: "WordTableCell", bundle: nil), forCellReuseIdentifier: "WordTableViewCell")
        addDictionaryTable.register(UINib(nibName: "ResultTableViewCell", bundle: nil), forCellReuseIdentifier: "ResultCells")
        addDictionaryTable.register(UINib(nibName: "ResultInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "ResultInfoCell")
        addDictionaryTable.register(UINib(nibName: "SearchWordCell", bundle: nil), forCellReuseIdentifier: "SearchWordCell")
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Display ad if it is ready
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        } else {
            print("Ad wasn't ready")
        }
    }
    
    //MARK: Toolbar Actions
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        doneAction()
    }
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: .none)
    }
    
    func fireBaseSettings() {
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        db = Firestore.firestore()
        db.settings = settings
    }
    
    //MARK: - Searching with wordsAPI
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchedWord = WordData()
        addDictionaryTable.reloadSections(IndexSet(arrayLiteral: 1), with: .fade)
        wordManager.fetchData(word: searchBar.text ?? "")
    }
    
    func didSearchWord(_ wordManager: WordManager, word: WordData) {
        searchedWord = word
        DispatchQueue.main.async {
            self.addDictionaryTable.reloadSections(IndexSet(arrayLiteral: 1), with: .fade)
        }
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
        let docData = thisDictionary.asDictionary()
        print(thisDictionary.asDictionary())
        
        var ref: DocumentReference? = nil
        ref = db.collection("example").addDocument(data: docData, completion: { (err) in
            if err != nil {
                print("Error while adding document: \(err!)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
                self.dismiss(animated: true, completion: .none)
            }
        })
    }
    
    
    //MARK: Adding the word with selected definition
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            self.addDictionaryTable.reloadSections(IndexSet(arrayLiteral: 1), with: .fade)
            var newWord = WordModel()
            newWord.word = searchedWord.word
            let result = searchedWord.results?[indexPath.row]
            newWord.description = result?.definition
            newWord.partOfSpeech = result?.partOfSpeech
            newWord.example = result?.examples?[0]
            
            // TODO: words yoksa exeption verebilir o yuzden init etmen gerekebilir
            if thisDictionary.words == nil {
                thisDictionary.words = [newWord]
            } else {
                thisDictionary.words?.append(newWord)
            }
            
            // TODO: tablo yenilemesini animasyon ile yapmayi dene
            searchedWord = .init()
            addDictionaryTable.reloadData()
            
            // Datayi updatelemene gerek yok cunku tek seferde yuklenicek
            
        }
    }
    
    //MARK: TableView Functions
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            thisDictionary.words = thisDictionary.words?.filter({ (savedWord) -> Bool in
                savedWord.word != nil
            })
            thisDictionary.words?.sort(by: { (first, second) -> Bool in
                first.word!.lowercased() < second.word!.lowercased()
            })
            
            return thisDictionary.words?.count ?? 0
        } else if section == 1 {
            return searchedWord.results?.count ?? 0
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
            
            //headCell = cell
            cell.delegate = self
            
            return cell
            
        } else if indexPath.section == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCells", for: indexPath) as! ResultTableViewCell
            // if results array is nill this part will not executed because row number is ZERO for section ONE
            cell.set(wordResult: searchedWord.results![indexPath.row])
            
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "WordTableViewCell", for: indexPath) as! WordTableViewCell
            // if results array is nill this part will not executed because row number is ZERO for section TWO
            cell.wordModel = self.thisDictionary.words![indexPath.row]
            
            return cell
            
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let headerCell = tableView.dequeueReusableCell(withIdentifier: "SearchWordCell") as! SearchWordCell
            headerCell.seachBar.delegate = self
            
            return headerCell.contentView
            
        } else if section == 2 {
            let headerCell = UITableViewHeaderFooterView()
            headerCell.tintColor = UIColor(named: "HeaderColor")
            headerCell.textLabel?.font = UIFont(name: "Roboto-Regular", size: 18)
            headerCell.textLabel?.text = "Words"
            
            return headerCell
        }
        
        else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 60
        } else if section == 2 {
            return 36
        } else {
            return 0
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
