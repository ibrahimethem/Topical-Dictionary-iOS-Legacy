//
//  BaseViewModel.swift
//  Topical Dictionary
//
//  Created by İbrahim Ethem Karalı on 2025-02-14.
//

import Foundation

protocol BaseViewModelDelegate: AnyObject {
    func didReceiveError(_ error: Error)
}

protocol BaseViewModelProtocol: AnyObject {
    var delegate: BaseViewModelDelegate? { get set }
}

class BaseViewModel: NSObject, BaseViewModelProtocol {
    weak var delegate: BaseViewModelDelegate?
}
