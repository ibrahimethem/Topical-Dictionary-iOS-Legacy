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

    enum sections: Int {
        case head = 0
        case search = 1
        case searchedWords = 2
        case words = 3
    }
    
    @IBOutlet var wordsTableView: UITableView!
    @IBOutlet weak var favoriteButton: UIBarButtonItem!
    
    lazy var selectedDictionary = DictionaryModel()
    var searchedWord: WordData?
    lazy var wordManager = WordManager()
    
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
    }
    
    private func setFavorite(isFavorite: Bool,_ sender: UIBarButtonItem) {
        db.collection(Keys.dictionaryCollectionID.rawValue).document(selectedDictionary.id!).updateData(["isFavorite": isFavorite]) { error in
            if error != nil {
                print("Error in favorite: \(error!)")
                sender.isEnabled = true
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
            //sender.tintColor = UIColor(red: 253/255, green: 242/255, blue: 130/255, alpha: 1.0)
            sender.image = UIImage(named: "favoriteButton")
        } else {
            //sender.tintColor = UIColor.white
            sender.image = UIImage(named: "notFavoriteButton")
        }
        sender.isEnabled = true
    }
    
    
    // MARK: - Searching Functions
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchedWord = nil
        wordsTableView.reloadSections(IndexSet(arrayLiteral: sections.searchedWords.rawValue), with: .fade)
        wordManager.fetchData(word: searchBar.text ?? "")
    }
    
    // word delegate method
    func didSearchWord(_ wordManager: WordManager, word: WordData) {
        searchedWord = word
        DispatchQueue.main.async {
            self.wordsTableView.reloadSections(IndexSet(arrayLiteral: sections.searchedWords.rawValue), with: .fade)
        }
    }
    
    // MARK: - HeadCell Text Protocol
    
    
    func titleDidChage(_ withText: String) {
        db.collection(Keys.dictionaryCollectionID.rawValue).document(selectedDictionary.id!).updateData(["topic": withText]) { error in
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
        db.collection(Keys.dictionaryCollectionID.rawValue).document(selectedDictionary.id!).updateData(["info": withText]) { error in
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
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case sections.words.rawValue:
            selectedDictionary.words = selectedDictionary.words?.filter({ (savedWord) -> Bool in
                savedWord.word != nil
            })
            selectedDictionary.words?.sort(by: { (first, second) -> Bool in
                first.word!.lowercased() < second.word!.lowercased()
            })
            
            return selectedDictionary.words?.count ?? 0
        
        case sections.searchedWords.rawValue:
            return searchedWord?.results?.count ?? 0
        
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case sections.head.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "HeadCell", for: indexPath) as! HeadTableViewCell
            
            cell.topic = selectedDictionary.topic ?? ""
            cell.explanation = selectedDictionary.info ?? ""
            
            cell.explanationTextView.isScrollEnabled = false
            cell.updateText()
            
            cell.delegate = self
            
            return cell
        
        case sections.search.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchWordCell") as! SearchWordCell
            cell.seachBar.delegate = self
            
            return cell
            
        case sections.searchedWords.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCells") as! ResultTableViewCell
            cell.set(wordResult: searchedWord!.results![indexPath.row])
            
            return cell
        
        case sections.words.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "WordTableViewCell", for: indexPath) as! WordTableViewCell
            
            cell.wordModel = self.selectedDictionary.words![indexPath.row]
            
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case sections.search.rawValue:
            return "Add new word"
        case sections.words.rawValue:
            return "Words"
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == sections.searchedWords.rawValue {
            return CGFloat.leastNormalMagnitude
        }
        return 20
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == sections.searchedWords.rawValue {
            if searchedWord?.results?.count ?? 0 == 0 {
                return CGFloat.leastNormalMagnitude
            }
            return 20
        }
        return 20
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == sections.searchedWords.rawValue {
            self.wordsTableView.reloadSections(IndexSet(arrayLiteral: 1), with: .fade)
            var newWord = WordModel()
            guard searchedWord != nil else { return }
            newWord.word = searchedWord!.word
            let result = searchedWord!.results?[indexPath.row]
            newWord.description = result?.definition
            newWord.partOfSpeech = result?.partOfSpeech
            newWord.example = result?.examples?[0]
            
            if selectedDictionary.words == nil {
                selectedDictionary.words = [newWord]
            } else {
                selectedDictionary.words?.append(newWord)
            }
            
            searchedWord = .init()
            wordsTableView.reloadData()
            
            if selectedDictionary.words != nil {
                
                do {
                    try db.collection(Keys.dictionaryCollectionID.rawValue).document(selectedDictionary.id ?? "").setData(from: selectedDictionary, merge: true)
                    print("Dictionary updated")
                    DispatchQueue.main.async {
                        self.searchedWord = .init()
                        self.wordsTableView.reloadData()
                    }
                } catch {
                    print("Error occured while updating the dictionary \(error as NSError)")
                }
            }
        }
    }
    
}
