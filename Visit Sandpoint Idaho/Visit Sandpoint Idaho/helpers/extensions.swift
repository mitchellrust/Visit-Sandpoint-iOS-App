//
//  extensions.swift
//  Visit Sandpoint Idaho
//
//  Created by Mitchell Rust on 11/20/20.
//

import Foundation
import UIKit

// For loading spinner
var vSpinner : UIView?
 
extension UIViewController {
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: UIActivityIndicatorView.Style.large)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            vSpinner?.removeFromSuperview()
            vSpinner = nil
        }
    }
}

extension UIImage {
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size

        let widthRatio  = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height

        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}

extension String {
    func prettyPhoneNumber(phoneNumber: String) -> String {
        if phoneNumber.count == 0 {
            return phoneNumber
        }
        
        var phone = phoneNumber
        if phone.count == 11 {
            phone.remove(at: phone.startIndex)
        }
        
        let areaCode = phone.prefix(3)
        
        let start = phone.index(phone.startIndex, offsetBy: 3)
        let end = phone.index(phone.endIndex, offsetBy: -4)
        let range = start..<end
        let mid = phone[range]
        
        let last = phone.suffix(4)
        
        let result = "(\(areaCode)) \(mid)-\(last)"
        
        return result
    }
}
