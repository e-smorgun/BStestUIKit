//
//  File.swift
//  BStestUIKit
//
//  Created by Evgeny on 24.09.23.
//

import Foundation

// MARK: - Info
struct Info: Codable {
    let page, pageSize, totalPages, totalElements: Int
    let content: [Content]
}

// MARK: - Content
struct Content: Codable {
    let id: Int
    let name: String
    let image: String?
}
