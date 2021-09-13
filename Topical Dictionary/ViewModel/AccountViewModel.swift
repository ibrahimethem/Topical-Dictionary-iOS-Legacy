//
//  AccountViewModel.swift
//  Topical Dictionary
//
//  Created by İbrahim Ethem Karalı on 8.09.2021.
//  Copyright © 2021 İbrahim Ethem Karalı. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth

class AccountViewModel: NSObject {
    
    var userModel: UserModel
    
    override init() {
        let currentUser = Auth.auth().currentUser
        let loginMethod = { () -> AuthProvider? in
            let providerID = currentUser?.providerData.first?.providerID
            switch providerID {
            case AuthProvider.email.rawValue:
                return AuthProvider.email
            case AuthProvider.facebook.rawValue:
                return AuthProvider.facebook
            case AuthProvider.google.rawValue:
                return AuthProvider.google
            case AuthProvider.apple.rawValue:
                return AuthProvider.apple
            default:
                return nil
            }
        }
        userModel = UserModel(userID: currentUser?.uid ?? "",
                              fullName: currentUser?.displayName,
                              email: currentUser?.email,
                              loginMethod: loginMethod())
        
        super.init()
    }
    
    
    
}
