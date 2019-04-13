//
//  UserCell.swift
//  DemoApp
//
//  Created by Charles Etieve on 02/03/2019.
//  Copyright © 2019 Charles Etieve. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import InitialsImageView

class UserCell : UITableViewCell {
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    
    var user: User? {
        didSet {
            userName.text = user!.username
            userImage.setImageForName(user!.username!, circular: true, textAttributes: nil)
        }
    }
}
