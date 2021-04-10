//
//  DictionaryViewController.swift
//  Topical Dictionary
//
//  Created by İbrahim Ethem Karalı on 22.06.2019.
//  Copyright © 2019 İbrahim Ethem Karalı. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseFirestore

class DictionaryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, WordManagerDelegate, HeadCellDelegate {

    @IBOutlet var wordsTableView: UITableView!
    @IBOutlet weak var favoriteButton: UIBarButtonItem!
    
    var selectedDictionary = DictionaryModel()
    var words = [WordModel]()
    var searchedWord = WordData()
    var wordManager = WordManager()
    var headCell = HeadTableViewCell()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fireBaseSettings()
        
        // Register nib
        wordsTableView.register(UINib(nibName: "WordTableCell", bundle: .none), forCellReuseIdentifier: "WordTableViewCell")
        wordsTableView.register(UINib(nibName: "SearchWordCell", bundle: .none), forCellReuseIdentifier: "SearchWordCell")
        wordsTableView.register(UINib(nibName: "HeadTableViewCell", bundle: .none), forCellReuseIdentifier: "HeadCell")
        wordsTableView.register(UINib(nibName: "ResultTableViewCell", bundle: .none), forCellReuseIdentifier: "ResultCells")
        
        wordsTableView.register(UINib(nibName: "SearchWordCell", bundle: .none), forHeaderFooterViewReuseIdentifier: "SearchWordCell")
        
        // Set class as delegate and datasource of wordsTableView
        wordsTableView.delegate = self
        wordsTableView.dataSource = self
        
        wordManager.delegate = self
        
        navigationItem.largeTitleDisplayMode = .never
        
        let isFavorite = selectedDictionary.isFavorite ?? false
        setFavoriteImage(isFavorite, favoriteButton)
        
    }
    
    private func fireBaseSettings() {
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        db = Firestore.firestore()
        db.settings = settings
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == wordsTableView {
            view.endEditing(true)
        }
    }
    
    // MARK: - tabBarButtons
    
    
    @IBAction func favorite(_ sender: UIBarButtonItem) {
        sender.isEnabled = false
        if let isFavorite = selectedDictionary.isFavorite {
            setFavorite(isFavorite: !isFavorite, sender)
        } else {
            setFavorite(isFavorite: true, sender)
        }
        sender.isEnabled = true
    }
    
    private func setFavorite(isFavorite: Bool,_ sender: UIBarButtonItem) {
        db.collection("example").document(selectedDictionary.id!).updateData(["isFavorite": isFavorite]) { error in
            if error != nil {
                print("Error in favorite: \(error!)")
            } else {
                DispatchQueue.main.async {
                    self.selectedDictionary.isFavorite = isFavorite
                    self.setFavoriteImage(isFavorite, sender)
                }
            }
        }
    }
    
    private func setFavoriteImage(_ isFavorite: Bool,_ sender: UIBarButtonItem) {
        if isFavorite {
            sender.tintColor = UIColor(red: 253/255, green: 242/255, blue: 130/255, alpha: 1.0)
            sender.image = UIImage(named: "favoriteButton")
        } else {
            sender.tintColor = UIColor.white
            sender.image = UIImage(named: "notFavoriteButton")
        }
    }
    
    
    // MARK: - Searching Functions
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchedWord = WordData()
        wordsTableView.reloadSections(IndexSet(arrayLiteral: 1), with: .fade)
        wordManager.fetchData(word: searchBar.text ?? "")
    }
    
    // word delegate method
    func didSearchWord(_ wordManager: WordManager, word: WordData) {
        searchedWord = word
        DispatchQueue.main.async {
            self.wordsTableView.reloadSections(IndexSet(arrayLiteral: 1), with: .fade)
        }
    }
    
    // MARK: - HeadCell Text Protocol
    
    
    func titleDidChage(_ withText: String) {
        db.collection("example").document(selectedDictionary.id!).updateData(["topic": withText]) { error in
            if error != nil {
                print("Error in text did change: \(error!)")
            } else {
                DispatchQueue.main.async {
                    self.selectedDictionary.topic = withText
                }
            }
        }
    }
    
    func explanationDidChange(_ withText: String) {
        db.collection("example").document(selectedDictionary.id!).updateData(["info": withText]) { error in
            if error != nil {
                print("Error in explanation did change: \(error!)")
            } else {
                DispatchQueue.main.async {
                    self.selectedDictionary.info = withText
                    self.wordsTableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                }
            }
        }
    }
    
    // MARK: - tableView functions
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            selectedDictionary.words = selectedDictionary.words?.filter({ (savedWord) -> Bool in
                savedWord.word != nil
            })
            selectedDictionary.words?.sort(by: { (first, second) -> Bool in
                first.word!.lowercased() < second.word!.lowercased()
            })
            
            return selectedDictionary.words?.count ?? 0
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
            cell.topic = selectedDictionary.topic ?? ""
            cell.explanation = selectedDictionary.info ?? ""
            
            cell.explanationTextView.isScrollEnabled = false
            cell.tableView = tableView
            
            headCell = cell
            headCell.delegate = self
            
            return cell
            
        } else if indexPath.section == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCells") as! ResultTableViewCell
            cell.wordResult = searchedWord.results![indexPath.row]
            
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "WordTableViewCell", for: indexPath) as! WordTableViewCell
            
            cell.wordModel = self.selectedDictionary.words![indexPath.row]
            
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
            //headerCell.backgroundColor = UIColor(named: "HeaderColor")
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            self.wordsTableView.reloadSections(IndexSet(arrayLiteral: 1), with: .fade)
            var newWord = WordModel()
            newWord.word = searchedWord.word
            let result = searchedWord.results?[indexPath.row]
            newWord.description = result?.definition
            newWord.partOfSpeech = result?.partOfSpeech
            newWord.example = result?.examples?[0]
            
            selectedDictionary.words?.append(newWord)
            
            searchedWord = .init()
            wordsTableView.reloadData()
            
            if selectedDictionary.words != nil {
                db.collection("example").document(selectedDictionary.id ?? "").updateData([
                    "words": selectedDictionary.asDictionary()["words"]!
                ]) { err in
                    print("asd")
                    if err == nil {
                        print("word added")
                        DispatchQueue.main.async {
                            self.searchedWord = .init()
                            self.wordsTableView.reloadData()
                        }
                    } else {
                        print("Error while adding word: \(err!)")
                    }
                }
            }
        }
    }
    
}
