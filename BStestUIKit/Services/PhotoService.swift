//
//  PhotoService.swift
//  BStestUIKit
//
//  Created by Evgeny on 25.09.23.
//

import Foundation

class PhotoService {
    private let dataFetch = DataFetch()

    func fetchData(page: Int, completion: @escaping (Result<Info, Error>) -> Void) {
        let urlString: String = "https://junior.balinasoft.com/api/v2/photo/type?page=\(page)"
        let url = URL(string: urlString)!
        dataFetch.fetchModel(from: url, completion: completion)
    }
}
