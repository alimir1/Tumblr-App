//
//  DetailViewController.swift
//  Tumblr
//
//  Created by Ali Mir on 9/13/17.
//  Copyright © 2017 com.AliMir. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var captionLabel: UILabel!
    
    var imageURL: URL!
    var captionText: NSAttributedString!

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.setImageWith(imageURL)
        captionLabel?.attributedText = captionText
        captionLabel?.sizeToFit()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(presentFullScreenVC))
        imageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fullImage" {
            let vc = segue.destination as! FullScreenPhotoViewController
            vc.imageURL = imageURL
        }
    }
    
    func presentFullScreenVC() {
        performSegue(withIdentifier: "fullImage", sender: nil)
    }
    
}
