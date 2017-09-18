//
//  FullScreenPhotoViewController.swift
//  Tumblr
//
//  Created by Ali Mir on 9/17/17.
//  Copyright © 2017 com.AliMir. All rights reserved.
//

import UIKit

class FullScreenPhotoViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    var imageURL: URL!

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.setImageWith(imageURL)
    }
    
    @IBAction func dismissVC(sender: Any?) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
