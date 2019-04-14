//
//  PhotoViewController.swift
//  DemoApp
//
//  Created by Charles Etieve on 13/04/2019.
//  Copyright © 2019 Charles Etieve. All rights reserved.
//

import Foundation
import UIKit

class PhotoViewController : UIViewController {
    @IBOutlet weak var photoImage: UIImageView!
    
    var photo: Photo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let placeHolder = UIImage(named: "placeholderPhoto")
        photoImage.kf.setImage(with: URL(string: photo.thumbnailUrl!)!, placeholder: placeHolder, options: [.transition(.fade(0.1))])
    }
}
