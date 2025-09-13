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
                    productType: .library(hasResources: true),
                    unitTestsOption: .disabled
                )
            case .modulePackageManagerCLI:
                Module(
                    name: "swift-module-package-manager-cli",
                    dependencies: [
                        .internal(.modulePackageManager),
                        .external(.swiftArgumentParser)
                    ],
                    productType: .executable,
                    unitTestsOption: .disabled
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
                        version: .tag(.from("1.6.1"))
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
            case library(hasResources: Bool)
            case executable
        }
        
        let name: String
        let dependencies: [PackageModule]
        let path: String
        let productType: ProductType
        let unitTestsOption: UnitTestsOption
        
        init(name: String, dependencies: [PackageModule], intermediateDirectoryPath: String = "", productType: ProductType, unitTestsOption: UnitTestsOption) {
            self.name = name
            self.dependencies = dependencies
            self.path = "\(intermediateDirectoryPath)\(name)/"
            self.productType = productType
            self.unitTestsOption = unitTestsOption
        }
        
        enum UnitTestsOption {
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
            let version: Version
            
            enum Version {
                case tag(Tag)
                case branch(String)
                
                enum Tag {
                    case from(String)
                    case exact(String)
                }
            }
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
        switch productType {
        case .library(let hasResources):
            let resources: [Resource]? = hasResources ? [.process("Resources")] : nil
            return .target(name: name, dependencies: dependencies, path: path, resources: resources)
        case .executable:
            return .executableTarget(name: name, dependencies: dependencies, path: path)
        }
    }
    
    var testTarget: Target? {
        switch unitTestsOption {
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
        switch packageInfo.version {
        case .tag(let tag):
            switch tag {
            case .from(let version):
                return .package(url: packageInfo.url, from: Version(stringLiteral: version))
            case .exact(let version):
                return .package(url: packageInfo.url, exact: Version(stringLiteral: version))
            }
        case .branch(let branch):
            return .package(url: packageInfo.url, branch: branch)
        }
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
