//
//  DefaultCell.swift
//  Topical Dictionary
//
//  Created by İbrahim Ethem Karalı on 10.09.2021.
//  Copyright © 2021 İbrahim Ethem Karalı. All rights reserved.
//

import UIKit

class DefaultCell: UITableViewCell {

    override func prepareForReuse() {
        super.prepareForReuse()
        accessoryType = .none
    }
    
}
