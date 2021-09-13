//
//  PrivacyViewController.swift
//  Topical Dictionary
//
//  Created by İbrahim Ethem Karalı on 11.09.2021.
//  Copyright © 2021 İbrahim Ethem Karalı. All rights reserved.
//

import UIKit
import WebKit

class PrivacyViewController: UIViewController {

    deinit {
        print("deinit about view controller")
    }
    
    @IBOutlet weak var webView: WKWebView!
    
    private var urlString: String {
        if UITraitCollection.current.userInterfaceStyle == .light {
            return "https://topicaldictionary.ethemkarali.com/privacy.html"
        } else {
            return "https://topicaldictionary.ethemkarali.com/privacy-dark.html"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.load(URLRequest(url: URL(string: urlString)!))
        
    }
}
