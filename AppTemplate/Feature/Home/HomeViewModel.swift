//
//  HomeViewModel.swift
//  AppTemplate
//
//  Created by Vijendran  on 5/19/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel {
    var products: [Product] = []
    var isLoading: Bool = false
    var isLoadingMore: Bool = false
    var errorMessage: String?
    var hasMorePages: Bool = true

    private let homeAPIService: HomeAPIServiceProtocol
    private let pageLimit: Int = 30
    private var currentSkip: Int = 0
    private var totalProducts: Int = 0

    init(homeAPIService: HomeAPIServiceProtocol) {
        self.homeAPIService = homeAPIService
    }

    // MARK: - Public Methods

    func loadProducts() async {
        // Prevent multiple simultaneous loads
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil
        currentSkip = 0
        products = []
        hasMorePages = true

        await fetchProducts()

        isLoading = false
    }

    func loadMoreProducts() async {
        // Prevent multiple simultaneous loads
        guard !isLoadingMore && !isLoading && hasMorePages else { return }

        isLoadingMore = true
        currentSkip += pageLimit

        await fetchProducts()

        isLoadingMore = false
    }

    // MARK: - Private Methods

    private func fetchProducts() async {
        do {
            let response = try await homeAPIService.fetchProducts(
                skip: currentSkip,
                limit: pageLimit
            )

            // Append new products to existing list
            products.append(contentsOf: response.products)
            totalProducts = response.total

            // Check if there are more pages
            hasMorePages = products.count < totalProducts

        } catch NetworkError.networkError {
            errorMessage = "Network error. Please check your connection."
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
