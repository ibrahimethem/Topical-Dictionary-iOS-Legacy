//
//  EmptyButtonViewController.swift
//  Topical Dictionary
//
//  Created by İbrahim Ethem Karalı on 24.04.2019.
//  Copyright © 2019 İbrahim Ethem Karalı. All rights reserved.
//

import UIKit

class EmptyButtonViewController: UIViewController {

    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tabBarController?.tabBar.isHidden = true
    }

}
