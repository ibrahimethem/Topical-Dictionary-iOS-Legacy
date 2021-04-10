//
//  ResultTableViewCell.swift
//  Topical Dictionary
//
//  Created by İbrahim Ethem Karalı on 22.04.2019.
//  Copyright © 2019 İbrahim Ethem Karalı. All rights reserved.
//

import UIKit

class ResultTableViewCell: UITableViewCell {

    @IBOutlet var wordTextView: UITextView!
    
    var wordResult: WordResult! {
        didSet {
            var resultText = wordResult.definition ?? ""
            if wordResult.partOfSpeech != nil {
                resultText = "\(resultText) (\(wordResult.partOfSpeech!))"
            }
            if wordResult.examples != nil {
                resultText = "\(resultText)\n  eg. \(wordResult.examples![0])"
            }
            
            wordTextView.text = resultText
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
