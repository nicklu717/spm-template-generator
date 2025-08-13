//
//  ModulePackageManager.swift
//  swift-module-package-manager
//
//  Created by 陸瑋恩 on 2025/8/10.
//

import ArgumentParser
import Foundation

@main
struct ModulePackageManager: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "swift-module-package",
        abstract: "Generate a Swift Package Manager template.",
        subcommands: [Init.self]
    )
}

struct Init: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "init",
        abstract: "Initialize a new Swift package."
    )
    
    @Option(name: .long, help: "The name of the package.")
    var name: String = FileManager.default.currentDirectoryPath.components(separatedBy: "/").last ?? "ModulePackage"
    
    func run() throws {
        let fileManager = FileManager.default
        let currentDirectory = fileManager.currentDirectoryPath
        let packageFilePath = "\(currentDirectory)/Package.swift"
        
        guard !fileManager.fileExists(atPath: packageFilePath) else {
            throw RunError("Package.swift already exists.")
        }
        let packageContent = """
        // swift-tools-version: 5.7

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
                // TODO: Add module cases here (if any)
                
                var module: Module {
                    switch self {}
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
                let hasTests: Bool
                let hasResources: Bool
                
                init(name: String, dependencies: [PackageModule], intermediateDirectoryPath: String = "", productType: ProductType = .library, hasTests: Bool, hasResources: Bool) {
                    self.name = name
                    self.dependencies = dependencies
                    self.path = "\\(intermediateDirectoryPath)\\(name)/"
                    self.productType = productType
                    self.hasTests = hasTests
                    self.hasResources = hasResources
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
                let path = "Sources/\\(path)"
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
                    return .testTarget(name: "\\(name)Tests", dependencies: [.byName(name: name)], path: "Tests/\\(path)")
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

        let internalModules = PackageModule.Internal.allCases.map(\\.module)
        let externalModules = PackageModule.External.allCases.map(\\.module)

        let package = Package(
            name: \"\(name)\",
            platforms: [.iOS(.v16), .macOS(.v13)],
            products: internalModules.map(\\.product),
            dependencies: externalModules.map(\\.package),
            targets: internalModules.map(\\.target) + internalModules.compactMap(\\.testTarget)
        )
        """
        try packageContent.write(toFile: packageFilePath, atomically: true, encoding: .utf8)
        
        try fileManager.createDirectory(atPath: "\(currentDirectory)/Sources/", withIntermediateDirectories: true)
        try fileManager.createDirectory(atPath: "\(currentDirectory)/Tests/", withIntermediateDirectories: true)
    }
    
    struct RunError: Error, CustomStringConvertible {
        let description: String
        
        init(_ message: String) {
            self.description = message
        }
    }
}
