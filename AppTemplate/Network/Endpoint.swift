//
//  Endpoint.swift
//  AppTemplate
//
//  Created by Vijendran  on 5/22/26.
//

import Foundation

protocol Endpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var queryParameters: [String: String]? { get }
}

extension Endpoint {
    // Default base URL from AppConfig
    var baseURL: String { AppConfig.baseURL }

    var headers: [String: String]? { nil }
    var queryParameters: [String: String]? { nil }

    func buildRequest() throws -> URLRequest {
        guard var components = URLComponents(string: baseURL + path) else {
            throw NetworkError.invalidURL
        }

        if let queryParameters = queryParameters {
            components.queryItems = queryParameters.map {
                URLQueryItem(name: $0.key, value: $0.value)
            }
        }

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        return request
    }
}
