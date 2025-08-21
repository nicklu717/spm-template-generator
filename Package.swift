// swift-tools-version: 5.7

enum PackageModule {
    case `internal`(Internal)
    case external(External)
    
    enum Internal: CaseIterable {
        case modulePackageManager
        case modulePackageManagerCLI
        
        var module: Module {
            switch self {
            case .modulePackageManager:
                Module(
                    name: "SwiftModulePackageManager",
                    dependencies: [],
                    hasResources: true,
                    testsOption: .disabled
                )
            case .modulePackageManagerCLI:
                Module(
                    name: "swift-module-package-manager-cli",
                    dependencies: [
                        .internal(.modulePackageManager),
                        .external(.swiftArgumentParser)
                    ],
                    productType: .executable,
                    hasResources: false,
                    testsOption: .disabled
                )
            }
        }
    }
    
    enum External: CaseIterable {
        case swiftArgumentParser
        
        var module: Module {
            switch self {
            case .swiftArgumentParser:
                Module(
                    name: "ArgumentParser",
                    packageInfo: .init(
                        name: "swift-argument-parser",
                        url: "https://github.com/apple/swift-argument-parser",
                        tag: "1.6.1"
                    )
                )
            }
        }
    }
}

// MARK: - Module Definitions
extension PackageModule.Internal {
    class Module {
        enum ProductType {
            case library, executable
        }
        
        let name: String
        let dependencies: [PackageModule]
        let path: String
        let productType: ProductType
        let hasResources: Bool
        let testsOption: TestsOption
        
        init(name: String, dependencies: [PackageModule], intermediateDirectoryPath: String = "", productType: ProductType = .library, hasResources: Bool, testsOption: TestsOption) {
            self.name = name
            self.dependencies = dependencies
            self.path = "\(intermediateDirectoryPath)\(name)/"
            self.productType = productType
            self.hasResources = hasResources
            self.testsOption = testsOption
        }
        
        enum TestsOption {
            case enabled(hasResourses: Bool)
            case disabled
        }
    }
}

extension PackageModule.External {
    class Module {
        struct PackageInfo {
            let name: String
            let url: String
            let tag: String
        }
        
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
        switch testsOption {
        case .enabled(let hasResourses):
            let path = "Tests/\(path)"
            return .testTarget(
                name: "\(name)Tests",
                dependencies: [.byName(name: name)],
                path: path,
                resources: hasResourses ? [.process("Resources")] : nil
            )
        case .disabled:
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
    name: "swift-module-package-manager",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: internalModules.map(\.product),
    dependencies: externalModules.map(\.package),
    targets: internalModules.map(\.target) + internalModules.compactMap(\.testTarget)
)
