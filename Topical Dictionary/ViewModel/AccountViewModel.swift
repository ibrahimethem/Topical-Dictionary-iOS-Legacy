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
    var delegate: AccountViewModelDelegate
    
    init(delegate: AccountViewModelDelegate) {
        self.delegate = delegate
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
    
    func updateDisplayName(with text: String) {
        let change = Auth.auth().currentUser?.createProfileChangeRequest()
        change?.displayName = text
        change?.commitChanges(completion: { error in
            if let err = error {
                self.delegate.didErrorOccured(self, error: err)
            }
            self.userModel.fullName = text
            self.delegate.didUpdateName(self, name: text)
        })
    }
    
}

protocol AccountViewModelDelegate {
    func didErrorOccured(_ viewModel: AccountViewModel, error: Error)
    func didUpdateName(_ viewModel: AccountViewModel, name: String)
}
