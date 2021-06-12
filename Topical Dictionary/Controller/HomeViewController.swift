//
//  ViewController.swift
//  Topical Dictionary
//
//  Created by İbrahim Ethem Karalı on 11.04.2019.
//  Copyright © 2019 İbrahim Ethem Karalı. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift


enum SortingType {
    case newToOld
    case oldToNew
    case aToZ
    case zToA
}

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, DictionariesManagerDelegate {
    
    // MARK: Implementations
    var db: Firestore!
    
    @IBOutlet var mainTableView: UITableView!
    @IBOutlet var favButton: UIBarButtonItem!
    
    private var isFav = false
    private var stockRightBarItems: [UIBarButtonItem]?
    
    private let refreshControl = UIRefreshControl()
    
    var tableData: [DictionaryModel] = [DictionaryModel]()
    var selectedDictionary = DictionaryModel()
    var sectionZeroRowNumber = 0
    
    lazy var dictionaryManager = DictionariesManager()
    
    // MARK: View Did Load
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("initialized")
        
        fireBaseSettings() // function to setting up firebase
        
        stockRightBarItems = [UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(deleteItemAction))]
        
        // Reflesh Control
        mainTableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refleshData), for: .valueChanged)
        refreshControl.tintColor = UIColor.white
        
        // Delegates
        mainTableView.delegate = self
        mainTableView.dataSource = self
        dictionaryManager.delegate = self
        
        
        //Register xib file for WordTableView
        mainTableView.register(UINib(nibName: "DictionaryTableViewCell", bundle: nil), forCellReuseIdentifier: "DictionaryCell")
        mainTableView.register(UINib(nibName: "ResultInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "ResultInfoCell")
        mainTableView.register(UINib(nibName: "AddDictionaryTableViewCell", bundle: nil), forCellReuseIdentifier: "AddDictionaryCell")
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        dictionaryManager.setListener()
    }
    
    // MARK: - Bar Button Actions

    
    @IBAction func sortButton(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: "filterSegue", sender: self)
    }
    
    @IBAction func edit(_ sender: UIBarButtonItem) {
        editHelper()
        let indexPath = IndexPath(row: 0, section: 0)
        if sectionZeroRowNumber == 0 {
            sectionZeroRowNumber = 1
            mainTableView.insertRows(at: [indexPath], with: .fade)
        } else {
            sectionZeroRowNumber = 0
            mainTableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    private func editHelper() {
        let prevRightBarButtonItems = navigationItem.rightBarButtonItems
        navigationItem.rightBarButtonItems = stockRightBarItems
        stockRightBarItems = prevRightBarButtonItems
        mainTableView.allowsMultipleSelection = !mainTableView.allowsMultipleSelection
        setNavigationTitle()
    }

    
    @objc func deleteItemAction() {
        if let selectedIndexPaths = mainTableView.indexPathsForSelectedRows?.filter({ (indexPath) -> Bool in
            indexPath.section == 1
        }) {
            view.isUserInteractionEnabled = false
            for indexPath in selectedIndexPaths {
                guard let rowId = tableData[indexPath.row].id else {
                    print("Items couldn't deleted")
                    return
                }
                db.collection("example").document(rowId).delete { (err) in
                    if err == nil {
                        print("Doc ID: \(rowId) deleted")
                    } else {
                        print(err!)
                        self.view.isUserInteractionEnabled = true
                        return
                    }
                }
            }
            view.isUserInteractionEnabled = true
            
            editHelper()
            sectionZeroRowNumber = 0
        }
    }
    
    
    @IBAction func favorite(_ sender: UIBarButtonItem) {
        if isFav {
            isFav = false
            favButton.tintColor = UIColor.white
            favButton.image = UIImage(named: "notFavoriteButton")
            setNavigationTitle()
            mainTableView.reloadSections(.init(arrayLiteral: 1), with: .fade)
        } else {
            isFav = true
            favButton.tintColor = UIColor(red: 253/255, green: 242/255, blue: 130/255, alpha: 1.0)
            favButton.image = UIImage(named: "favoriteButton")
            setNavigationTitle()
            mainTableView.reloadSections(.init(arrayLiteral: 1), with: .fade)
        }
    }
    
    private func setNavigationTitle() {
        if mainTableView.allowsMultipleSelection {
            navigationItem.title = "Editing"
        } else {
            if isFav {
                navigationItem.title = "Favorites"
            } else {
                navigationItem.title = "Dictionaries"
            }
        }
    }
    
    
    // MARK: - DATABASE
    
    func didLoadDictionaries(_ dictionaryManager: DictionariesManager, dictionaries: [DictionaryModel]) {
        tableData = dictionaries
        mainTableView.reloadData()
    }
    
    func didFailLoadDictionaries(_ dictionaryManager: DictionariesManager, error: Error) {
        print(error)
    }
    
    func dictionariesDidChange(_ dictionaryManager: DictionariesManager) {
        mainTableView.reloadData()
    }
    
    private func fireBaseSettings() {
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        db = Firestore.firestore()
        db.settings = settings
    }
    
    // Scroll view refresh helper funciton
    @objc private func refleshData() {
        mainTableView.reloadData()
        
        DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
        }
    }
    
    // MARK: - TableView FUNCTIONS
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    // if the favorites are being listed filter as favorites number of fav dictionaries;
    // else, number of all dictionaries
    // both of them sorts table as selected sorting type
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return sectionZeroRowNumber
        } else {
            if dictionaryManager.allDictionaries == nil {
                return 0
            } else {
                if isFav {
                    tableData = dictionaryManager.favoriteDictionaries()
                    return tableData.count
                } else {
                    tableData = dictionaryManager.allDictionaries!
                    return tableData.count
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let numberOfSelectedRows = mainTableView.indexPathsForSelectedRows?.filter({ (indexPath) -> Bool in
                indexPath.section == 1
            })
            let cell = UITableViewCell()
            
            cell.backgroundColor = .clear
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = .white
            cell.textLabel?.text = "\(numberOfSelectedRows?.count ?? 0) dictionaries selected"
            
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DictionaryCell", for: indexPath) as! DictionaryTableViewCell
            cell.dictionary = tableData[indexPath.row]
            
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            tableView.cellForRow(at: indexPath)?.isSelected = false
        }
        else if tableView.allowsMultipleSelection {
            tableView.reloadSections(IndexSet.init(arrayLiteral: 0), with: .none)
        } else {
            selectedDictionary = tableData[indexPath.row]
            performSegue(withIdentifier: "HomeToDictionary", sender: selectedDictionary)
            mainTableView.selectRow(at: nil, animated: true, scrollPosition: .none)
        }
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView.allowsMultipleSelection && indexPath.section == 1 {
            tableView.reloadSections(IndexSet.init(arrayLiteral: 0), with: .none)
        }
    }
    
    // MARK: - tableView ACTIONS
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return false
        } else {
            return true
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        if indexPath.section == 0 {
            return nil
        }
        
        let fav = UITableViewRowAction(style: .default, title: "Favorite") { (action, indexPath) in
            let favOrNot = self.tableData[indexPath.row].isFavorite ?? false
            let setTo = !favOrNot
            let dictionaryID = self.tableData[indexPath.row].id!
            self.db.collection("example").document(dictionaryID).setData(["isFavorite" : setTo], merge: true,completion: { (err) in
                if err != nil {
                    print("Error while setting favorite: \(err!)")
                    return
                } else {
                    DispatchQueue.main.async {
                        print("setting favorite succesfully")
                    }
                }
            })
        }
        fav.backgroundColor = UIColor(red: 253/255, green: 242/255, blue: 130/255, alpha: 1.0)
        
        return [fav]
    }
    
    // MARK: - NAVIGATION
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "HomeToDictionary" {
            let destination = segue.destination as! DictionaryViewController
            destination.selectedDictionary = sender as! DictionaryModel
        } else if segue.identifier == "filterSegue" {
            let destination = segue.destination as! FilterViewController
            destination.masterView = self
        }
    }
}
