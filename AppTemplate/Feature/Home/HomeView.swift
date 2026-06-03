//
//  HomeView.swift
//  AppTemplate
//
//  Created by Vijendran  on 5/19/26.
//

import SwiftUI

struct HomeView: View {
    @State private var viewModel: HomeViewModel

    init(viewModel: HomeViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.products.isEmpty {
                    ProgressView("Loading products...")
                } else if let errorMessage = viewModel.errorMessage, viewModel.products.isEmpty {
                    ContentUnavailableView(
                        "Error Loading Products",
                        systemImage: "exclamationmark.triangle",
                        description: Text(errorMessage)
                    )
                } else {
                    productList
                }
            }
            .navigationTitle("Products")
            .task {
                await viewModel.loadProducts()
            }
        }
    }

    private var productList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.products) { product in
                    ProductRowView(product: product)
                }

                // Loading indicator for pagination
                if viewModel.isLoadingMore {
                    ProgressView()
                        .padding()
                }
            }
            .padding()
            .onScrollGeometryChange(for: Bool.self) { geometry in
                // Detect when user is near the bottom
                let contentHeight = geometry.contentSize.height
                let visibleHeight = geometry.containerSize.height
                let scrollOffset = geometry.contentOffset.y

                // Trigger pagination when user scrolls to 80% of content
                let threshold = contentHeight * 0.8
                let currentPosition = scrollOffset + visibleHeight

                return currentPosition >= threshold
            } action: { oldValue, newValue in
                // When threshold is crossed, load more
                if newValue && !oldValue && viewModel.hasMorePages {
                    Task {
                        await viewModel.loadMoreProducts()
                    }
                }
            }
        }
    }
}

// MARK: - Product Row View

struct ProductRowView: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.title)
                        .font(.headline)
                        .lineLimit(2)

                    Text(product.category.capitalized)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(4)
                }

                Spacer()

                Text("$\(product.price, specifier: "%.2f")")
                    .font(.title3.bold())
                    .foregroundStyle(.blue)
            }

            Text(product.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(3)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    let dependencies = DependencyContainer.mockDependencyContainer
    let factory = ViewFactory(dependencies: dependencies)
    return factory.makeHomeView()
        .environment(dependencies)
        .environment(factory)
}
