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
    
    func asDictionary() -> [String:Any] {
        let dictionary: [String:Any] = [
            "creater": creator ?? "",
            "date": date ?? Timestamp(),
            "info": info ?? "",
            "isFavorite": isFavorite ?? false,
            "topic": topic ?? "",
            "words": asWords()
        ]
        return dictionary
    }
    
    private func asWords() -> [[String:Any]] {
        var array: [[String:Any]] = [[String:Any]]()
        
        if words != nil {
            for word in words! {
                array.append(word.asDictionary())
            }
        }
        
        return array
    }
    
    func searchWord(word searchedWord: String) -> [WordModel] {
        if let result = words?.filter({ (savedWord) -> Bool in
            (savedWord.word?.elementsEqual(searchedWord))! || (savedWord.description?.elementsEqual(searchedWord))!
        }) {
            return result
        } else {
            return [WordModel]()
        }
    }
}

struct WordModel: Codable {
    var description: String?
    var example: String?
    var partOfSpeech: String?
    var word: String?
    
    func asDictionary() -> [String:Any] {
        var dictionary: [String:Any] = [String:Any]()
        if description != nil {
            dictionary["description"] = description!
        }
        if example != nil {
            dictionary["example"] = example!
        }
        if partOfSpeech != nil {
            dictionary["partOfSpeech"] = partOfSpeech!
        }
        if word != nil {
            dictionary["word"] = word!
        }
        
        return dictionary
    }
}
