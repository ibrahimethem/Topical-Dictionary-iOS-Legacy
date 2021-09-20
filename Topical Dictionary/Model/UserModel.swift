//
//  UserModel.swift
//  Topical Dictionary
//
//  Created by İbrahim Ethem Karalı on 8.09.2021.
//  Copyright © 2021 İbrahim Ethem Karalı. All rights reserved.
//

import Foundation

enum AuthProvider: String, Codable {
    case email = "password"
    case facebook = "facebook.com"
    case apple = "apple.com"
    case google = "google.com"
}

struct UserModel: Codable {
    var userID: String
    var fullName: String?
    var email: String?
    var loginMethod: AuthProvider?
}
