//
//  DataFetchable.swift
//  BStestUIKit
//
//  Created by Evgeny on 24.09.23.
//

import Foundation

class DataFetch {
    func fetchModel<T: Decodable>(from url: URL, completion: @escaping (Result<T, Error>) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "Data is nil", code: 0, userInfo: nil)))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(T.self, from: data)
                //print(result)
                completion(.success(result))
            } catch let error {
                completion(.failure(error))
            }
        }.resume()
    }
}
