//
//  EmailLoginViewModel.swift
//  Topical Dictionary
//
//  Created by İbrahim Ethem Karalı on 2025-02-14.
//

import Foundation
import FirebaseAuth

final class EmailLoginViewModel: BaseViewModel {
    private let authService: AuthService

    init(authService: AuthService = .shared) {
        self.authService = authService
        super.init()
    }

    func login(email: String, password: String, completion: @escaping (AuthDataResult?) -> Void) {
        authService.signIn(email: email, password: password) { result, error in
            if let error = error {
                self.delegate?.didReceiveError(error)
                return
            }
            completion(result)
        }
    }

    func register(email: String, password: String, displayName: String, completion: @escaping (AuthDataResult?) -> Void) {
        authService.register(email: email, password: password, displayName: displayName) { result, error in
            if let error = error {
                self.delegate?.didReceiveError(error)
                return
            }
            completion(result)
        }
    }
}
