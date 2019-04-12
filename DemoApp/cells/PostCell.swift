//
//  PostCell.swift
//  v-labs
//
//  Created by Charles Etieve on 04/03/2019.
//  Copyright © 2019 Charles Etieve. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class PostCell: UICollectionViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var body: UILabel!
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var commentStackView: UIStackView!
    @IBOutlet weak var bottomButton: UIButton!
    
    var commentButtonDisposable: Disposable?
    var commentsDisposable: Disposable?
    var buttonTitleDisposable: Disposable?
 
    var viewModel: PostViewModel? {
        didSet {
            background.layer.cornerRadius = 10
            background.clipsToBounds = true
            background.layer.borderColor = UIColor.lightGray.cgColor
            background.layer.borderWidth = 1
            
            title.text = viewModel!.rawOutput.title
            body.text = viewModel!.rawOutput.body
            buttonTitleDisposable = viewModel!.output.buttonTitle.drive(self.bottomButton.rx.title())
            
            commentButtonDisposable = bottomButton.rx.tap.bind(to: self.viewModel!.input.buttonTapped)
            
            commentsDisposable = viewModel!.output.comments.drive(onNext: { comments in
                for view in self.commentStackView.arrangedSubviews {
                    view.removeFromSuperview()
                }
                for comment in comments {
                    let commentView = CommentView.instanceFromNib()
                    commentView.comment = comment
                    self.commentStackView.addArrangedSubview(commentView)
                }
            })
            
        }
    }
    
    override func prepareForReuse() {
        commentButtonDisposable?.dispose()
        commentsDisposable?.dispose()
        buttonTitleDisposable?.dispose()
    }
    
    static func calculateHeight(cellWidth: CGFloat, viewModel: PostViewModel) -> CGFloat {
        if viewModel.rawOutput.displayComments {
            var commentsHeight = CGFloat(0)
            for comment in viewModel.rawOutput.comments {
                let commentHeight = CommentView.calculateHeight(cellWidth: cellWidth - 40, comment: comment)
                commentsHeight += commentHeight
            }
            return viewModel.rawOutput.title.height(withConstrainedWidth: cellWidth - 40, font: UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.semibold))
                + viewModel.rawOutput.body.height(withConstrainedWidth: cellWidth - 40, font: UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.regular))
                + 90
                + commentsHeight
        } else {
            return viewModel.rawOutput.title.height(withConstrainedWidth: cellWidth - 20, font: UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.semibold))
                + viewModel.rawOutput.body.height(withConstrainedWidth: cellWidth - 20, font: UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.regular))
                + 80
        }
    }
}
