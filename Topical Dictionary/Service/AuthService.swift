//
//  AuthService.swift
//  Topical Dictionary
//
//  Created by İbrahim Ethem Karalı on 2025-02-14.
//

import Foundation
import FirebaseAuth

enum AuthServiceError: Error {
    case missingUser
}

final class AuthService {
    static let shared = AuthService()

    private let auth: Auth

    init(auth: Auth = .auth()) {
        self.auth = auth
    }

    var currentUser: User? {
        auth.currentUser
    }

    func loginMethod(for user: User?) -> AuthProvider? {
        let providerID = user?.providerData.first?.providerID
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

    func signOut() throws {
        try auth.signOut()
    }

    func signIn(email: String, password: String, completion: @escaping (AuthDataResult?, Error?) -> Void) {
        auth.signIn(withEmail: email, password: password, completion: completion)
    }

    func register(email: String, password: String, displayName: String, completion: @escaping (AuthDataResult?, Error?) -> Void) {
        auth.createUser(withEmail: email, password: password) { authDataResult, error in
            if let error = error {
                completion(authDataResult, error)
                return
            }
            guard let _ = authDataResult?.user else {
                completion(authDataResult, AuthServiceError.missingUser)
                return
            }
            self.updateDisplayName(displayName) { updateError in
                completion(authDataResult, updateError)
            }
        }
    }

    func updateDisplayName(_ name: String, completion: @escaping (Error?) -> Void) {
        guard let change = auth.currentUser?.createProfileChangeRequest() else {
            completion(AuthServiceError.missingUser)
            return
        }
        change.displayName = name
        change.commitChanges(completion: completion)
    }
}
