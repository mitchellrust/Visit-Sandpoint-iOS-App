//
//  FullscreenImageViewController.swift
//  Visit Sandpoint Idaho
//
//  Created by Mitchell Rust on 12/2/20.
//

import UIKit

class FullscreenImageViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cancelButton: UIButton!
    
    var image: UIImage!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imageView.image = image
        cancelButton.layer.cornerRadius = 0.5 * cancelButton.bounds.size.width
        cancelButton.clipsToBounds = true
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

}
