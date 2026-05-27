//
//  NetworkClient.swift
//  AppTemplate
//
//  Created by Vijendran  on 5/22/26.
//

import Foundation

protocol NetworkClientProtocol: Sendable {
    func request<T: Decodable>(
        endpoint: Endpoint,
        body: Encodable?
    ) async throws -> T
}

final class NetworkClient: NetworkClientProtocol, @unchecked Sendable {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder(),
        encoder: JSONEncoder = JSONEncoder()
    ) {
        self.session = session
        self.decoder = decoder
        self.encoder = encoder
    }

    func request<T: Decodable>(
        endpoint: Endpoint,
        body: Encodable? = nil
    ) async throws -> T {
        var request = try endpoint.buildRequest()

        // Encode body if provided
        if let body = body {
            do {
                request.httpBody = try encoder.encode(body)
            } catch {
                throw NetworkError.encodingError(error)
            }
        }

        // Perform request
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw NetworkError.networkError(error)
        }

        // Validate response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.networkError(URLError(.badServerResponse))
        }

        // Check status code - THIS IS WHERE 401 IS DETECTED
        switch httpResponse.statusCode {
        case 200...299:
            break // Success, continue to decode
        case 401:
            throw NetworkError.unauthorized
        default:
            throw NetworkError.httpError(
                statusCode: httpResponse.statusCode,
                data: data
            )
        }

        // Decode response
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}
