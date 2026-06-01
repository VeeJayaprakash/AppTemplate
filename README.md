# AppTemplate

A production-ready iOS application template built with SwiftUI, featuring clean architecture, dependency injection, and modern Swift patterns.

## Project Overview

AppTemplate is a scalable iOS app starter template that demonstrates best practices for building maintainable, testable applications. It includes a complete authentication flow, networking layer, and modular architecture designed to grow with your project.

### Key Features

- Complete authentication system (login/logout with token management)
- Type-safe networking layer with automatic token refresh
- Factory pattern for view creation and dependency management
- MVVM architecture using Swift's @Observable macro
- Feature-based project structure
- Production-ready error handling

### Technology Stack

- **SwiftUI** - Modern declarative UI framework
- **Swift Observation** - Observable macro for state management (replacing Combine)
- **Swift Concurrency** - async/await for asynchronous operations
- **URLSession** - Native networking
- **iOS 17+** - Minimum deployment target

## Architecture

### Dependency Injection Pattern

The app uses a two-tier dependency injection system:

#### DependencyContainer (Infrastructure Layer)

Located in `DependencyContainer.swift`, this class manages core infrastructure dependencies:

- **NetworkClient** - Base HTTP networking layer
- **APIClient** - Authenticated API wrapper
- **UserSession** - Authentication state and token management
- **API Services** - Feature-specific API service instances

```swift
@MainActor
@Observable
final class DependencyContainer {
    let networkClient: NetworkClientProtocol
    var userSession: UserSession
    let apiClient: APIClient
    let loginAPIService: LoginAPIServiceProtocol

    init() {
        self.networkClient = NetworkClient()
        self.userSession = UserSession(networkClient: networkClient)
        self.apiClient = APIClient(
            networkClient: networkClient,
            tokenProvider: userSession
        )
        self.loginAPIService = LoginAPIService(networkClient: networkClient)
    }
}
```

#### ViewFactory (Presentation Layer)

Located in `ViewFactory.swift`, this class handles view and view model creation:

- Creates ViewModels with required dependencies
- Constructs Views with their ViewModels
- Keeps view initialization logic centralized
- Scales easily as features are added

```swift
@MainActor
@Observable
final class ViewFactory {
    private let dependencies: DependencyContainer

    func makeLoginView() -> LoginView {
        let viewModel = LoginViewModel(
            loginAPIService: dependencies.loginAPIService,
            userSession: dependencies.userSession
        )
        return LoginView(viewModel: viewModel)
    }
}
```

**Why This Separation?**

- **Single Responsibility**: DependencyContainer = infrastructure, ViewFactory = presentation
- **Scalability**: Add new services or views without mixing concerns
- **Testability**: Mock either layer independently
- **Clarity**: Clear boundaries between app layers

### MVVM Pattern

The app uses Model-View-ViewModel architecture with modern Swift Observation:

- **Models**: Plain data structures (User, LoginRequest, LoginResponse)
- **ViewModels**: Business logic, marked with `@Observable` macro
- **Views**: SwiftUI views that own their ViewModels via `@State`

#### ViewModel Ownership

ViewModels are owned by their views, not singletons:

```swift
struct LoginView: View {
    @State private var viewModel: LoginViewModel

    init(viewModel: LoginViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
}
```

**Benefits:**
- Proper lifecycle management
- No memory leaks or retain cycles
- Each view instance gets its own ViewModel
- Clear ownership model

### Clean Architecture Principles

- **Separation of Concerns**: Each layer has a single responsibility
- **Dependency Rule**: Dependencies point inward (Views → ViewModels → Services → Network)
- **Feature Modules**: Code organized by feature, not by type
- **Protocol-Oriented**: Key components use protocols for flexibility and testing

## Project Structure

```
AppTemplate/
├── AppTemplateApp.swift          # App entry point, DI setup
├── ContentView.swift              # Root view, auth state routing
├── DependencyContainer.swift      # Infrastructure dependencies
├── ViewFactory.swift              # View/ViewModel factory
│
├── Networking/
│   ├── Core/
│   │   ├── NetworkClient.swift   # Base HTTP client
│   │   ├── APIClient.swift       # Authenticated wrapper
│   │   ├── Endpoint.swift        # Endpoint protocol
│   │   └── NetworkError.swift    # Error types
│   └── Protocol/
│       └── TokenProvider.swift   # Token management protocol
│
├── User/
│   ├── User.swift                # User model
│   └── UserSession.swift         # Auth state & token management
│
└── Feature/
    ├── Login/
    │   ├── LoginView.swift       # Login UI
    │   ├── LoginViewModel.swift  # Login logic & models
    │   └── LoginAPIService.swift # Login API calls
    │
    ├── Settings/
    │   ├── SettingsView.swift    # Settings UI
    │   └── SettingsViewModel.swift
    │
    ├── Home/
    │   └── HomeView.swift        # Home screen
    │
    └── MainTabView.swift         # Tab navigation
```

**Organization Principles:**
- **Feature-based structure**: Each feature has its own folder with all related files
- **Networking layer separate**: Shared infrastructure in its own module
- **User management separate**: Authentication concerns isolated
- **Flat where possible**: Avoid over-nesting directories

## Core Components

### Networking Layer

#### NetworkClient

Base networking layer (`Networking/Core/NetworkClient.swift`):

- Generic HTTP request handling
- URLSession-based implementation
- Automatic JSON encoding/decoding
- Error handling and mapping

```swift
protocol NetworkClientProtocol {
    func request<T: Decodable, U: Encodable>(
        endpoint: Endpoint,
        body: U?
    ) async throws -> T
}
```

#### APIClient

Authenticated API wrapper (`Networking/Core/APIClient.swift`):

- Wraps NetworkClient with token injection
- Automatic token refresh on 401 errors
- Retry logic for failed authentication
- Uses TokenProvider protocol

```swift
let response: UserProfile = try await apiClient.authenticatedRequest(
    endpoint: ProfileEndpoint.getProfile
)
```

#### Endpoint Protocol

Type-safe endpoint definitions (`Networking/Core/Endpoint.swift`):

```swift
protocol Endpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var queryParameters: [String: String]? { get }
}
```

Each feature defines its own endpoints:

```swift
struct LoginEndpoint: Endpoint {
    var baseURL: String { "https://api.example.com" }
    var path: String { "/auth/login" }
    var method: HTTPMethod { .post }
}
```

### User Session Management

#### UserSession

Central authentication state manager (`User/UserSession.swift`):

- Implements `TokenProvider` protocol
- Manages access and refresh tokens
- Tracks current user
- Handles token refresh logic
- Observable for UI updates

**Key Properties:**
```swift
var currentUser: User?           // Currently logged in user
var isUserLogged: Bool           // Authentication status
var isAuthenticated: Bool        // Has valid tokens
```

**Key Methods:**
```swift
func setUserSession(user:accessToken:refreshToken:)  // Login
func clearTokens()                                    // Logout
func getAccessToken() async throws -> String          // Get current token
func refreshToken() async throws                      // Refresh expired token
```

### Authentication Flow

#### Login Flow

1. User enters credentials in `LoginView`
2. `LoginViewModel.login()` validates input
3. `LoginAPIService.login()` makes API call
4. On success, `UserSession.setUserSession()` stores tokens and user
5. `ContentView` observes `isUserLogged` and shows `MainTabView`

#### Logout Flow

1. User taps Logout in `SettingsView`
2. Confirmation alert appears
3. On confirm, `UserSession.clearTokens()` clears auth state
4. `ContentView` observes change and shows `LoginView`

#### Token Refresh

Automatic token refresh handled by `APIClient`:

1. API request receives 401 Unauthorized
2. `APIClient` calls `tokenProvider.refreshToken()`
3. `UserSession.refreshToken()` requests new tokens
4. Original request retried with new token
5. On refresh failure, user logged out

### ViewFactory Pattern

Centralized view creation system for scalable architecture.

#### Creating Views

All views are created through factory methods:

```swift
// In ViewFactory
func makeLoginView() -> LoginView {
    let viewModel = LoginViewModel(
        loginAPIService: dependencies.loginAPIService,
        userSession: dependencies.userSession
    )
    return LoginView(viewModel: viewModel)
}

// Usage in parent view
@Environment(ViewFactory.self) var viewFactory
var body: some View {
    viewFactory.makeLoginView()
}
```

#### Benefits

- **Centralized Logic**: All view creation in one place
- **Dependency Injection**: ViewModels get dependencies they need
- **Scalability**: Easy to add new views as app grows
- **Testability**: Easy to inject mock factories
- **Type Safety**: Compile-time safety for view dependencies

## Getting Started

### Prerequisites

- Xcode 15.0 or later
- iOS 17.0 or later
- Swift 5.9 or later

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd AppTemplate
```

2. Open the project:
```bash
open AppTemplate.xcodeproj
```

3. Build and run:
- Select a simulator or device
- Press Cmd+R to build and run

### Configuration

#### API Endpoints

Update the base URL in your endpoint definitions:

```swift
// In LoginViewModel.swift (or create a Config.swift)
struct LoginEndpoint: Endpoint {
    var baseURL: String {
        return "https://your-api.example.com"  // Update this
    }
    // ...
}
```

#### Token Refresh

Implement token refresh in `UserSession.swift`:

```swift
func refreshToken() async throws {
    guard let refreshToken = self.refreshToken else {
        throw NetworkError.missingToken
    }

    let endpoint = AuthEndpoint.refresh
    let request = RefreshTokenRequest(refreshToken: refreshToken)
    let response: TokenResponse = try await networkClient.request(
        endpoint: endpoint,
        body: request
    )

    updateTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken
    )
}
```

## Adding New Features

### Step 1: Create API Service

Create a new service for your feature's API calls:

```swift
// Feature/Profile/ProfileAPIService.swift
protocol ProfileAPIServiceProtocol {
    func getProfile() async throws -> ProfileResponse
}

class ProfileAPIService: ProfileAPIServiceProtocol {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func getProfile() async throws -> ProfileResponse {
        return try await apiClient.authenticatedRequest(
            endpoint: ProfileEndpoint.get
        )
    }
}
```

### Step 2: Add to DependencyContainer

Register your service:

```swift
// In DependencyContainer.swift
@Observable
final class DependencyContainer {
    // ... existing properties
    let profileAPIService: ProfileAPIServiceProtocol

    init() {
        // ... existing initialization
        self.profileAPIService = ProfileAPIService(apiClient: apiClient)
    }
}
```

### Step 3: Create ViewModel

Build your feature's ViewModel:

```swift
// Feature/Profile/ProfileViewModel.swift
@MainActor
@Observable
final class ProfileViewModel {
    var profile: Profile?
    var isLoading: Bool = false
    var errorMessage: String?

    private let profileAPIService: ProfileAPIServiceProtocol

    init(profileAPIService: ProfileAPIServiceProtocol) {
        self.profileAPIService = profileAPIService
    }

    func loadProfile() async {
        isLoading = true
        do {
            profile = try await profileAPIService.getProfile()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
```

### Step 4: Create View

Build your SwiftUI view:

```swift
// Feature/Profile/ProfileView.swift
struct ProfileView: View {
    @State private var viewModel: ProfileViewModel

    init(viewModel: ProfileViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        // Your UI here
    }
}
```

### Step 5: Add to ViewFactory

Register the view creation method:

```swift
// In ViewFactory.swift
func makeProfileView() -> ProfileView {
    let viewModel = ProfileViewModel(
        profileAPIService: dependencies.profileAPIService
    )
    return ProfileView(viewModel: viewModel)
}
```

### Step 6: Use in Navigation

Use the factory to present your view:

```swift
// In parent view
@Environment(ViewFactory.self) var viewFactory

NavigationLink("Profile") {
    viewFactory.makeProfileView()
}

// Or for sheet presentation
.sheet(isPresented: $showProfile) {
    viewFactory.makeProfileView()
}
```

---

**Happy Coding!**
