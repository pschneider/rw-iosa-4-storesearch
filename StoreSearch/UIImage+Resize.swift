//
//  UIImage+Resize.swift
//  StoreSearch
//
//  Created by Patrick Schneider on 17/01/16.
//  Copyright © 2016 Patrick Schneider. All rights reserved.
//

import UIKit

extension UIImage {
    func resizeImageWithBounds(bounds: CGSize) -> UIImage {
        // fetch ratio for width / height so we display every format correctly
        let horizontalRatio = bounds.width / size.width
        let verticalRatio = bounds.height / size.height
        let ratio = min(horizontalRatio, verticalRatio)
        // determine new size based on ratio
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        // draw the new image
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        drawInRect(CGRect(origin: CGPoint.zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}