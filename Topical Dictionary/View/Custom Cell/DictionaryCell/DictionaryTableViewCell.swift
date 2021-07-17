//
//  DictionaryTableViewCell.swift
//  Topical Dictionary
//
//  Created by İbrahim Ethem Karalı on 18.04.2019.
//  Copyright © 2019 İbrahim Ethem Karalı. All rights reserved.
//

import UIKit

class DictionaryTableViewCell: UITableViewCell {
    @IBOutlet var title: UILabel!
    @IBOutlet var explanation: UITextView!
    @IBOutlet var dictionaryIcon: UIImageView!
    @IBOutlet var container: UIView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet weak var selectionView: UIView!
    
    func setDictionary(to dictionaryModel: DictionaryModel) {
        if let fav = dictionaryModel.isFavorite {
            if fav {
                dictionaryIcon.image = UIImage(named: "cellFavImage")
            } else {
                dictionaryIcon.image = UIImage()
            }
        } else {
            dictionaryIcon.image = UIImage()
        }
        if let timestamp = dictionaryModel.date {
            let date = timestamp.dateValue()
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            formatter.doesRelativeDateFormatting = true
            
            dateLabel.text = formatter.string(from: date)
        } else {
            dateLabel.text = "no date"
        }
        title.text = dictionaryModel.topic ?? ""
        explanation.text = dictionaryModel.info ?? ""
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let cornerRadius: CGFloat = 5.0
        container.layer.cornerRadius = cornerRadius
        selectionView.layer.cornerRadius = cornerRadius
        
        // Shadow
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.16
        container.layer.shadowRadius = 3
        
        explanation.textContainer.lineFragmentPadding = 0
        explanation.textContainerInset = .zero
        
        self.selectionStyle = .none
        self.shouldIndentWhileEditing = false
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        if selected {
            UIView.animate(withDuration: 0.3) {
                self.selectionView.isHidden = false
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.selectionView.isHidden = true
            }
        }
    }
    
}
