//
//  KeychainManager.swift
//  AppTemplate
//
//  Created by Vijendran  on 6/02/26.
//

import Foundation
import Security

// MARK: - Keychain Error

enum KeychainError: Error {
    case saveFailed(OSStatus)
    case retrievalFailed(OSStatus)
    case deletionFailed(OSStatus)
    case encodingFailed
    case decodingFailed
    case itemNotFound
}

// MARK: - Protocol

protocol KeychainManagerProtocol {
    func save<T: Codable>(_ item: T, forKey key: String) throws
    func retrieve<T: Codable>(forKey key: String, as type: T.Type) throws -> T?
    func delete(forKey key: String) throws
    func deleteAll() throws
}

// MARK: - Implementation

final class KeychainManager: KeychainManagerProtocol {

    private let service: String

    init(service: String = Bundle.main.bundleIdentifier ?? "com.app.default") {
        self.service = service
    }

    // MARK: - Save

    func save<T: Codable>(_ item: T, forKey key: String) throws {
        // Encode the item to Data
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(item) else {
            throw KeychainError.encodingFailed
        }

        // Delete existing item if present
        try? delete(forKey: key)

        // Prepare query
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        // Save to keychain
        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
    }

    // MARK: - Retrieve

    func retrieve<T: Codable>(forKey key: String, as type: T.Type) throws -> T? {
        // Prepare query
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        // Retrieve from keychain
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status != errSecItemNotFound else {
            return nil
        }

        guard status == errSecSuccess else {
            throw KeychainError.retrievalFailed(status)
        }

        guard let data = result as? Data else {
            throw KeychainError.decodingFailed
        }

        // Decode the data
        let decoder = JSONDecoder()
        guard let item = try? decoder.decode(T.self, from: data) else {
            throw KeychainError.decodingFailed
        }

        return item
    }

    // MARK: - Delete

    func delete(forKey key: String) throws {
        // Prepare query
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        // Delete from keychain
        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deletionFailed(status)
        }
    }

    // MARK: - Delete All

    func deleteAll() throws {
        // Prepare query to delete all items for this service
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]

        // Delete from keychain
        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deletionFailed(status)
        }
    }
}

// MARK: - Mock Implementation for Testing

#if DEBUG
final class MockKeychainManager: KeychainManagerProtocol {
    private var storage: [String: Data] = [:]

    func save<T: Codable>(_ item: T, forKey key: String) throws {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(item) else {
            throw KeychainError.encodingFailed
        }
        storage[key] = data
    }

    func retrieve<T: Codable>(forKey key: String, as type: T.Type) throws -> T? {
        guard let data = storage[key] else {
            return nil
        }

        let decoder = JSONDecoder()
        guard let item = try? decoder.decode(T.self, from: data) else {
            throw KeychainError.decodingFailed
        }

        return item
    }

    func delete(forKey key: String) throws {
        storage.removeValue(forKey: key)
    }

    func deleteAll() throws {
        storage.removeAll()
    }
}
#endif
