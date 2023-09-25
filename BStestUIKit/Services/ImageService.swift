//
//  ImageService.swift
//  BStestUIKit
//
//  Created by Evgeny on 25.09.23.
//

import Foundation
import UIKit

class ImageService {
    static let sharedCache = NSCache<AnyObject, AnyObject>()
}

func getImage(with URL: URL, completionHandler: @escaping (UIImage?) -> Void) {
    if let cachedImage = ImageService.sharedCache.object(forKey: URL.absoluteString as AnyObject) as? UIImage {
        completionHandler(cachedImage)
    } else {
        URLSession.shared.dataTask(with: URL) { (data, response, error) in
            guard let data = data, let image = UIImage(data: data) else {
                completionHandler(nil)
                return
            }
            
            ImageService.sharedCache.setObject(image, forKey: URL.absoluteString as AnyObject)
            
            completionHandler(image)
        }.resume()
    }
}
