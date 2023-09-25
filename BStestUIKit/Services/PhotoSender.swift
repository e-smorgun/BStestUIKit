//
//  PhotoService.swift
//  BStestUIKit
//
//  Created by Evgeny on 24.09.23.
//

import Foundation

// MARK: -- PhotoService
class PhotoSender {

    func sendPhoto(photo: Content, imageData: Data, developerName: String = "Evgeny Smorgun", completion: @escaping (Result<String, Error>) -> Void) {

        guard let url = URL(string: "https://junior.balinasoft.com/api/v2/photo") else {
            completion(.failure(PhotoError.invalidURL))
            return
        }
        
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("*/*", forHTTPHeaderField: "accept")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let body = createMultipartFormData(with: developerName, photo: photo, imageData: imageData, boundary: boundary)
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(PhotoError.invalidResponse))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(PhotoError.serverError(httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(PhotoError.noResponseData))
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let id = json?["id"] as? String {
                    print(id)
                    completion(.success(id))
                } else {
                    completion(.failure(PhotoError.invalidResponseFormat))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }

    private func createMultipartFormData(with developerName: String, photo: Content, imageData: Data, boundary: String) -> Data {
        var body = Data()
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"name\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(developerName)\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"photo\"; filename=\"photo.jpeg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"typeId\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(photo.id)\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        return body
    }
}
