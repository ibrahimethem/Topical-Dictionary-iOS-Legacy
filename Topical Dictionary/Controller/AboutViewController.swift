//
//  AboutViewController.swift
//  Topical Dictionary
//
//  Created by İbrahim Ethem Karalı on 11.09.2021.
//  Copyright © 2021 İbrahim Ethem Karalı. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    
    deinit {
        print("deinit about view controller")
        textView.removeFromSuperview()
    }
    
    @IBOutlet var textView: UITextView!
    
    private var urlString: String {
        if UITraitCollection.current.userInterfaceStyle == .light {
            return "https://topicaldictionary.ethemkarali.com/about.html"
        } else {
            return "https://topicaldictionary.ethemkarali.com/about-dark.html"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = URL(string: urlString),
           let htmlString = try? String(contentsOf: url, encoding: .utf8),
           let aboutText = try? NSAttributedString(data: Data(htmlString.utf8), options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
            textView.attributedText = aboutText
        }
        
    }

}
