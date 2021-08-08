//
//  DictionaryService.swift
//  Topical Dictionary
//
//  Created by İbrahim Ethem Karalı on 8.08.2021.
//  Copyright © 2021 İbrahim Ethem Karalı. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class DictionaryService {
    
    lazy var db: Firestore = {
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        let db = Firestore.firestore()
        db.settings = settings
        
        return db
    }()
    
    var delegate: DictionaryServiceDelegate?
    var dictionary: DictionaryModel
    
    init(dictionary: DictionaryModel) {
        self.dictionary = dictionary
    }
    
    private func update() {
        guard let docID = dictionary.id else { return }
        if let _ = try? db.collection(Keys.dictionaryCollectionID.rawValue).document(docID).setData(from: dictionary, merge: true) {
            delegate?.didUpdateDictionary(self, dictionary: dictionary)
        }
    }
    
    func updateWord(with word: WordModel, index: Int) {
        dictionary.words?[index] = word
        update()
    }
    
}

protocol DictionaryServiceDelegate {
    func didUpdateDictionary(_ DictionaryService: DictionaryService, dictionary: DictionaryModel)
}
