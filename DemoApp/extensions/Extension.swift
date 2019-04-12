//
//  extension.swift
//  v-labs
//
//  Created by Charles Etieve on 06/03/2019.
//  Copyright © 2019 Charles Etieve. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift
import SVProgressHUD

extension String {
    
    func localized(bundle: Bundle = .main, tableName: String = "Localizable") -> String {
        return NSLocalizedString(self, tableName: tableName, value: "**\(self)**", comment: "")
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font : font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font : font], context: nil)
        
        return ceil(boundingBox.width)
    }
}

extension NSAttributedString {
    func height(withConstrainedWidth width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return ceil(boundingBox.width)
    }
}

extension UIViewController {
    func displayAlert(_ error: Error) {
        let alert = UIAlertController(title: "error".localized(), message: error.localizedDescription, preferredStyle: .alert)
        let alertOk = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(alertOk)
        present(alert, animated: true, completion: nil)
    }
}

extension Reactive where Base: SVProgressHUD {
    
    public static var isAnimating: Binder<Bool> {
        return Binder(UIApplication.shared) {progressHUD, isVisible in
            if isVisible {
                SVProgressHUD.show()
            } else {
                SVProgressHUD.dismiss()
            }
        }
    }
    
}
