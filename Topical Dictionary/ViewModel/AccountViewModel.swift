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

class AccountViewModel: BaseViewModel {
    
    var userModel: UserModel
    var accountDelegate: AccountViewModelDelegate
    private let authService: AuthService
    
    init(delegate: AccountViewModelDelegate, authService: AuthService = .shared) {
        self.accountDelegate = delegate
        self.authService = authService
        let currentUser = authService.currentUser
        userModel = UserModel(userID: currentUser?.uid ?? "",
                              fullName: currentUser?.displayName,
                              email: currentUser?.email,
                              loginMethod: authService.loginMethod(for: currentUser))
        
        super.init()
    }
    
    func updateDisplayName(with text: String) {
        authService.updateDisplayName(text) { error in
            if let err = error {
                self.delegate?.didReceiveError(err)
            }
            self.userModel.fullName = text
            self.accountDelegate.didUpdateName(self, name: text)
        }
    }
    
}

protocol AccountViewModelDelegate {
    func didUpdateName(_ viewModel: AccountViewModel, name: String)
}
