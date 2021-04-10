//
//  WordTableViewCell.swift
//  Topical Dictionary
//
//  Created by İbrahim Ethem Karalı on 14.04.2019.
//  Copyright © 2019 İbrahim Ethem Karalı. All rights reserved.
//

import UIKit

class WordTableViewCell: UITableViewCell {
    
    @IBOutlet var wordLabel: UILabel!
    @IBOutlet var partOfSpeachLabel: UILabel!
    @IBOutlet weak var explanationLabel: UILabel!
    
    var wordModel: WordModel! {
        didSet {
            wordLabel.text = wordModel.word?.lowercased()
            if let pos = wordModel.partOfSpeech {
                partOfSpeachLabel.text = pos
            } else { partOfSpeachLabel.text = "" }
            
            var explanationText = ""
            if let description = wordModel.description {
                explanationText = description
            }
            
            if let eg = wordModel.example {
                explanationText = "\(explanationText)\n e.g. \(eg). "
            }
            
            explanationLabel.text = explanationText
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
