// swift-tools-version: 5.7

// MARK: - Modules Declared by Users
enum Module {
    case `internal`(Internal)
    case external(External)
    
    enum Internal: CaseIterable {}
    enum External: CaseIterable {}
}

extension Module.Internal {
    var name: String {
        switch self {}
    }
    
    var dependencies: [Module] {
        switch self {}
    }
    
    var path: String {
        switch self {}
    }
    
    enum ProductType {
        case library, executable
    }
    var productType: ProductType {
        switch self {}
    }
    
    var hasResources: Bool {
        switch self {}
    }
    
    var hasTests: Bool {
        switch self {}
    }
}

extension Module.External {
    var name: String {
        switch self {}
    }
    
    var packageInfo: (name: String, url: String, tag: String) {
        switch self {}
    }
}

// MARK: - Generate Package
import PackageDescription

extension Module.Internal {
    var product: Product {
        switch productType {
        case .library:
            return .library(name: name, targets: [name])
        case .executable:
            return .executable(name: name, targets: [name])
        }
    }
    
    var target: Target {
        let dependencies: [Target.Dependency] = dependencies.map { dependency in
            switch dependency {
            case .internal(let internalModule):
                return .byName(name: internalModule.name)
            case .external(let externalModule):
                return externalModule.product
            }
        }
        let path = "Sources/\(path)"
        let resources: [Resource]? = hasResources ? [.process("Resources")] : nil
        
        switch productType {
        case .library:
            return .target(name: name, dependencies: dependencies, path: path, resources: resources)
        case .executable:
            return .executableTarget(name: name, dependencies: dependencies, path: path, resources: resources)
        }
    }
    
    var testTarget: Target? {
        if hasTests {
            return .testTarget(name: "\(name)Tests", dependencies: [.byName(name: name)], path: "Tests/\(path)")
        } else {
            return nil
        }
    }
}

extension Module.External {
    var package: Package.Dependency {
        .package(url: packageInfo.url, exact: Version(stringLiteral: packageInfo.tag))
    }
    
    var product: Target.Dependency {
        .product(name: name, package: packageInfo.name)
    }
}

let internalModules = Module.Internal.allCases
let externalModules = Module.External.allCases
let package = Package(
    name: "Modules",
    platforms: [.macOS(.v13)],
    products: internalModules.map(\.product),
    dependencies: externalModules.map(\.package),
    targets: internalModules.map(\.target) + internalModules.compactMap(\.testTarget)
)
