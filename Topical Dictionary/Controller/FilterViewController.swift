//
//  FilterViewController.swift
//  Topical Dictionary
//
//  Created by İbrahim Ethem Karalı on 2.08.2019.
//  Copyright © 2019 İbrahim Ethem Karalı. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var masterView: HomeViewController?
    @IBOutlet var container: UIView!
    @IBOutlet var pickerView: UIPickerView!
    let sortingTitles = ["New to Old", "Old to New", "A to Z", "Z to A"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        container.layer.cornerRadius = 8
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.layer.cornerRadius = 8
        
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func done(_ sender: UIButton) {
        dismiss(animated: true) {
            if self.masterView != nil {
                let selectedRow = self.pickerView.selectedRow(inComponent: 0)
                var sortingType = SortingType.newToOld
                if self.sortingTitles[selectedRow] == "New to Old" {
                    sortingType = SortingType.newToOld
                } else if self.sortingTitles[selectedRow] == "Old to New" {
                    sortingType = SortingType.oldToNew
                } else if self.sortingTitles[selectedRow] == "A to Z" {
                    sortingType = SortingType.aToZ
                } else if self.sortingTitles[selectedRow] == "Z to A" {
                    sortingType = SortingType.zToA
                }
                self.masterView?.dictionaryManager.sortDictionaries(by: sortingType)
            }
        }
    }
    
    //MARK: - Picker View Functions
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sortingTitles.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return sortingTitles[row]
    }

}
