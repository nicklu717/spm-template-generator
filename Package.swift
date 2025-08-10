// swift-tools-version: 5.7

// MARK: - Modules Declared by Users
enum PackageModule {
    case `internal`(Internal)
    case external(External)
    
    enum Internal: CaseIterable {
        // TODO: Add module cases here
        
        var module: Module {
            switch self {}
        }
    }
    
    enum External: CaseIterable {
        // Add external module cases here (if any)
        
        var module: Module {
            switch self {}
        }
    }
}

extension PackageModule.Internal {
    class Module {
        enum ProductType {
            case library, executable
        }
        
        let name: String
        let dependencies: [PackageModule]
        let path: String
        let productType: ProductType
        let hasTests: Bool
        let hasResources: Bool
        
        init(name: String, dependencies: [PackageModule] = [], path: String? = nil, productType: ProductType, hasTests: Bool, hasResources: Bool = false) {
            self.name = name
            self.dependencies = dependencies
            self.path = path ?? "\(name)/"
            self.productType = productType
            self.hasTests = hasTests
            self.hasResources = hasResources
        }
    }
}

extension PackageModule.External {
    class Module {
        typealias PackageInfo = (name: String, url: String, tag: String)
        
        let name: String
        let packageInfo: PackageInfo
        
        init(name: String, packageInfo: PackageInfo) {
            self.name = name
            self.packageInfo = packageInfo
        }
    }
}

// MARK: - Generate Package
import PackageDescription

extension PackageModule.Internal.Module {
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
            case .internal(let `internal`):
                return .byName(name: `internal`.module.name)
            case .external(let external):
                return external.module.product
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

extension PackageModule.External.Module {
    var package: Package.Dependency {
        .package(url: packageInfo.url, exact: Version(stringLiteral: packageInfo.tag))
    }
    
    var product: Target.Dependency {
        .product(name: name, package: packageInfo.name)
    }
}

let internalModules = PackageModule.Internal.allCases.map(\.module)
let externalModules = PackageModule.External.allCases.map(\.module)

let package = Package(
    name: "spm-template-generator",
    platforms: [.macOS(.v13)],
    products: internalModules.map(\.product),
    dependencies: externalModules.map(\.package),
    targets: internalModules.map(\.target) + internalModules.compactMap(\.testTarget)
)
