//
//  UserCell.swift
//  v-labs
//
//  Created by Charles Etieve on 02/03/2019.
//  Copyright © 2019 Charles Etieve. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class UserCell : UITableViewCell {
    
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var userName: UILabel!
    
    var phoneButtonDisposable: Disposable?
    var emailButtonDisposable: Disposable?
    
    var user: User? {
        didSet {
            userName.text = user!.username
            phoneButtonDisposable = phoneButton.rx.tap.bind {
                //do not work on simulator
                if let phone = self.user?.phone {
                    if let url = URL(string: "tel://\(phone)") {
                        self.openUrl(url)
                    }
                }
            }
            emailButtonDisposable = emailButton.rx.tap.bind {
                //do not work on simulator
                if let email = self.user?.email {
                    if let url = URL(string: "mailto:\(email)") {
                        self.openUrl(url)
                    }
                }
            }
        }
    }
    
    func openUrl(_ url: URL) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    override func prepareForReuse() {
        phoneButtonDisposable?.dispose()
        emailButtonDisposable?.dispose()
    }
}
