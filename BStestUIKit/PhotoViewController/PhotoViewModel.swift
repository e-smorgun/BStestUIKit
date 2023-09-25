//
//  PhotoView.swift
//  BStestUIKit
//
//  Created by Evgeny on 24.09.23.
//

import Foundation
import UIKit

class PhotoViewModel {
    var currentPage = 0
    var maxPage = 1
    var isLoading = false
    let photoService = PhotoService()
    let photoSender = PhotoSender()
    var photoes = [Content]()
    var selectedItem: Content?
    
    func uploadPhoto(photo: Content, imageData: Data, developerName: String = "Evgeny Smorgun", completion: @escaping (String?, Error?) -> Void) {
        photoSender.sendPhoto(photo: photo, imageData: imageData, developerName: developerName) { result in
            switch result {
            case .success(let id):
                completion(id, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    func fetchPhotoes(completion: @escaping () -> Void) {
        if isLoading { return }
        isLoading = true
        
        if currentPage == maxPage { return }
        
        photoService.fetchData(page: currentPage) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let info):
                    self.photoes += info.content
                    self.maxPage = info.totalPages
                    completion()
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func loadImage(at url: String, into imageView: UIImageView) {
        if url != " " {
            let imageURL = URL(string: url)!
                                
            getImage(with: imageURL) { image in
                DispatchQueue.main.async {
                    imageView.image = image
                }
            }
        } else {
            DispatchQueue.main.async {
                imageView.image = UIImage(named: "Error")
            }
        }
    }
}
