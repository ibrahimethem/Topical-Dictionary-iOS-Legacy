//
//  BaseViewController.swift
//  Topical Dictionary
//
//  Created by İbrahim Ethem Karalı on 2025-02-14.
//

import UIKit

class BaseViewController: UIViewController, BaseViewModelDelegate {
    var baseViewModel: BaseViewModelProtocol? {
        didSet {
            baseViewModel?.delegate = self
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewModel()
        bindViewModel()
    }

    func configureViewModel() {
        // Override in subclasses to create view model.
    }

    func bindViewModel() {
        // Override in subclasses to bind view model outputs.
    }

    func didReceiveError(_ error: Error) {
        presentError(error)
    }

    func presentError(_ error: Error) {
        let alert = UIAlertController(title: "Something Went Wrong", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
