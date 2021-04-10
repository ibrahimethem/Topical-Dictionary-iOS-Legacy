//
//  AddOrSeachTableViewCell.swift
//  Topical Dictionary
//
//  Created by İbrahim Ethem Karalı on 15.08.2020.
//  Copyright © 2020 İbrahim Ethem Karalı. All rights reserved.
//

import UIKit

class SearchWordCell: UITableViewCell {

    @IBOutlet var seachBar: UISearchBar!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        self.selectionStyle = .none
    }
    
}
