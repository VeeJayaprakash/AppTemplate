//
//  Product.swift
//  AppTemplate
//
//  Created by Vijendran  on 6/02/26.
//

import Foundation

// MARK: - Models

struct Product: Codable, Identifiable {
    let id: Int
    let title: String
    let description: String
    let category: String
    let price: Double
}

struct ProductsResponse: Codable {
    let products: [Product]
    let total: Int
    let skip: Int
    let limit: Int
}
