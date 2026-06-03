//
//  HomeAPIServices.swift
//  AppTemplate
//
//  Created by Vijendran  on 5/19/26.
//

import Foundation

// MARK: - Endpoint

struct ProductsEndpoint: Endpoint {
    let skip: Int
    let limit: Int

    var path: String {
        return "/products"
    }

    var method: HTTPMethod {
        return .get
    }

    var queryParameters: [String: String]? {
        return [
            "skip": "\(skip)",
            "limit": "\(limit)"
        ]
    }
}

// MARK: - API Service

protocol HomeAPIServiceProtocol {
    func fetchProducts(skip: Int, limit: Int) async throws -> ProductsResponse
}

final class HomeAPIService: HomeAPIServiceProtocol {
    private let networkClient: NetworkClientProtocol

    init(networkClient: NetworkClientProtocol) {
        self.networkClient = networkClient
    }

    func fetchProducts(skip: Int, limit: Int) async throws -> ProductsResponse {
        let endpoint = ProductsEndpoint(skip: skip, limit: limit)
        return try await networkClient.request(endpoint: endpoint, body: Optional<String>.none)
    }
}
