//
//  HeadTableViewCell.swift
//  Topical Dictionary
//
//  Created by İbrahim Ethem Karalı on 16.04.2019.
//  Copyright © 2019 İbrahim Ethem Karalı. All rights reserved.
//

import UIKit

class HeadTableViewCell: UITableViewCell, UITextViewDelegate, UITextFieldDelegate {

    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var explanationTextView: UITextView!
    let placeholder = "Write the explanation of your dictionary here"
    var tableView: UITableView!
    
    var initialTitleText = ""
    var initialExplanationText = ""
    
    let placeholderFont = UIFont.init(name: "Roboto-LightItalic", size: 14.0)!
    let explanationFont = UIFont.init(name: "Roboto-Light", size: 14.0)!
    
    var delegate: HeadCellDelegate?
    
    var topic: String? {
        didSet {
            titleTextField.text = topic
        }
    }
    
    var explanation: String? {
        didSet {
            if explanation == "" {
                explanationTextView.font = placeholderFont
                explanationTextView.text = placeholder
            } else {
                explanationTextView.font = explanationFont
                explanationTextView.text = explanation
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleTextField.delegate = self
        self.explanationTextView.delegate = self
        explanationTextView.text = placeholder
        explanationTextView.font = placeholderFont
        explanationTextView.textContainer.lineFragmentPadding = 0
        explanationTextView.textContainerInset = .zero
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        self.selectionStyle = .none
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.isScrollEnabled = true
        if textView.font == placeholderFont {
            textView.text = ""
        } else {
            initialExplanationText = textView.text
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.isScrollEnabled = false
        if textView.text == "" {
            textView.text = placeholder
            textView.font = placeholderFont
            delegate?.explanationDidChange("")
        } else {
            if textView.text != initialExplanationText {
                textView.font = explanationFont
                delegate?.explanationDidChange(textView.text)
            }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        initialTitleText = textField.text!
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if initialTitleText != textField.text {
            delegate?.titleDidChage(textField.text!)
        }
    }
    
}

protocol HeadCellDelegate {
    func titleDidChage(_ withText: String)
    func explanationDidChange(_ withText: String)
}
