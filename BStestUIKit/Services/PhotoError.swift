//
//  PhotoError.swift
//  BStestUIKit
//
//  Created by Evgeny on 24.09.23.
//

import Foundation

// MARK: -- Error's
enum PhotoError: Error {
    case invalidURL
    case invalidResponse
    case serverError(Int)
    case noResponseData
    case invalidResponseFormat
    case jsonParsingError(Error)
}
