//
//  Word.swift
//  Topical Dictionary
//
//  Created by İbrahim Ethem Karalı on 20.07.2020.
//  Copyright © 2020 İbrahim Ethem Karalı. All rights reserved.
//

import Foundation

struct WordData: Decodable {
    var word: String?
    var results: [WordResult]?
}
struct WordResult: Decodable {
    var definition: String?
    var partOfSpeech: String?
    var examples: [String]?
}
