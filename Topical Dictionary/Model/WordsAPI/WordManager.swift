//
//  WordManager.swift
//  Topical Dictionary
//
//  Created by İbrahim Ethem Karalı on 23.08.2020.
//  Copyright © 2020 İbrahim Ethem Karalı. All rights reserved.
//

import Foundation
import UIKit

class WordManager {
    
    weak var delegate: WordManagerDelegate?
    
    func fetchData(word: String) {
        guard let encodedWord = word.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        let urlString = "https://wordsapiv1.p.rapidapi.com/words/\(encodedWord)"
        guard let url = URL(string: urlString) else {
            print("URL String is not valid for URL")
            return
        }
        performRequest(with: url)
    }
    
    
    func performRequest(with url: URL) {
        var request = URLRequest(url: url)
        
        request.addValue(APIKeys().wordsAPIKey, forHTTPHeaderField: "x-rapidapi-key")
        request.addValue("wordsapiv1.p.rapidapi.com", forHTTPHeaderField: "x-rapidapi-host")
        request.httpMethod = "GET"
        let session = URLSession.shared
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let dataTask = session.dataTask(with: request) { [unowned self] (data, response, error) in
            if error != nil {
                print(error!)
            }
            
            if let data = data {
                if let word = self.parseJSON(with: data) {
                    self.delegate?.didSearchWord(self, word: word)
                }
            }
        }
        dataTask.resume()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func parseJSON(with data: Data) -> WordData? {
        let decoder = JSONDecoder()
        do {
            var jsonData = try decoder.decode(WordData.self, from: data)
            
            jsonData.results = jsonData.results?.filter({ (wordResult) -> Bool in
                wordResult.definition != nil
            })
            
            jsonData.results?.reverse()
            
            return jsonData

        } catch let catchError {
            print(catchError)
            return nil
        }
        
    }
    
}

protocol WordManagerDelegate: AnyObject {
    func didSearchWord(_ wordManager: WordManager, word: WordData)
}
