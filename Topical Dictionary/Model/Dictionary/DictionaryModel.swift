//
//  Dictionaries.swift
//  Topical Dictionary
//
//  Created by İbrahim Ethem Karalı on 20.07.2020.
//  Copyright © 2020 İbrahim Ethem Karalı. All rights reserved.
//


import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct DictionaryModel: Codable, Identifiable {
    @DocumentID var id: String?
    var creator: String?
    var date: Timestamp?
    var info: String?
    var isFavorite: Bool?
    var topic: String?
    var words: [WordModel]?
}

struct WordModel: Codable {
    var description: String?
    var example: String?
    var partOfSpeech: String?
    var word: String?
}
