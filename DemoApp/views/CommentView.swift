//
//  CommentCell.swift
//  v-labs
//
//  Created by Charles Etieve on 05/03/2019.
//  Copyright © 2019 Charles Etieve. All rights reserved.
//

import Foundation
import UIKit

class CommentView : UIView {
    @IBOutlet weak var body: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var background: UIView!
    
    class func instanceFromNib() -> CommentView {
        return UINib(nibName: "CommentView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CommentView
    }
    
    var comment : Comment? {
        didSet {
            background.layer.cornerRadius = 10
            background.clipsToBounds = true
            background.layer.borderColor = UIColor.lightGray.cgColor
            background.layer.borderWidth = 1
            email.text = comment!.email
            body.text = comment!.body
        }
    }
    
    static func calculateHeight(cellWidth: CGFloat, comment: Comment) -> CGFloat {
        return comment.body!.height(withConstrainedWidth: cellWidth - 40, font: UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.regular))
            + 68.5
    }
}
