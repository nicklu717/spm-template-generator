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
    name: "<#your-package-name#>",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: internalModules.map(\.product),
    dependencies: externalModules.map(\.package),
    targets: internalModules.map(\.target) + internalModules.compactMap(\.testTarget)
)
