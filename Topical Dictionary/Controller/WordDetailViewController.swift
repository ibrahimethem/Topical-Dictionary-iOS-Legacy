//
//  WordDetailViewController.swift
//  Topical Dictionary
//
//  Created by İbrahim Ethem Karalı on 4.08.2021.
//  Copyright © 2021 İbrahim Ethem Karalı. All rights reserved.
//

import UIKit

struct WordDetailViewModel {
    var index: Int
    var word: WordModel
}

class WordDetailViewController: UIViewController, WordManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    lazy var wordManager = WordManager()
    var delegate: WordDetailViewDelegate?
    
    @IBOutlet var wordTableView: UITableView!
    
    var viewModel: WordDetailViewModel?
    var word: WordModel?
    
    var index: Int? {
        return viewModel?.index
    }
    
    var wordDescriptions: WordData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        word = viewModel?.word
        
        wordTableView.delegate = self
        wordTableView.dataSource = self
        wordManager.delegate = self
        
        if let wordString = word?.word {
            wordManager.fetchData(word: wordString)
        }
        
        wordTableView.register(UINib(nibName: "WordTableCell", bundle: .none), forCellReuseIdentifier: "WordTableViewCell")
        wordTableView.register(UINib(nibName: "ResultTableViewCell", bundle: .none), forCellReuseIdentifier: "ResultCells")

    }
    
    func didSearchWord(_ wordManager: WordManager, word: WordData) {
        wordDescriptions = word
        DispatchQueue.main.async {
            self.wordTableView.reloadData()
            //self.wordTableView.reloadSections(IndexSet(integer: 1), with: .fade)
        }
    }
    
    // MARK: - Table View Delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 1:
            return wordDescriptions?.results?.count ?? 0
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "WordTableViewCell", for: indexPath) as! WordTableViewCell
            cell.wordModel = word
            
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCells") as! ResultTableViewCell
            
            if let result = wordDescriptions?.results?[indexPath.row] {
                cell.set(wordResult: result)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Other Descriptions"
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if let wordResult = wordDescriptions?.results?[indexPath.row] {
                word?.description = wordResult.definition
                word?.partOfSpeech = wordResult.partOfSpeech
                word?.example = wordResult.examples?.first
                if word != nil {
                    delegate?.didUpdateWord(word: word!, index: index!)
                }
                delegate?.didUpdateWord(word: word!, index: index!)
                tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            }
        }
    }
    
}

protocol WordDetailViewDelegate {
    func didUpdateWord(word: WordModel, index: Int)
}
