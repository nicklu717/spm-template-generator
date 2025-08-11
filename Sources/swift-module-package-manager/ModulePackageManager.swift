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
    
    func run() throws {
        // if `Package.swift` exists
        let fileManager = FileManager.default
        let currentDirectory = fileManager.currentDirectoryPath
        let packageFilePath = "\(currentDirectory)/Package.swift"
        if fileManager.fileExists(atPath: packageFilePath) {
            throw RunError("Package.swift already exists.")
        } else {
            let packageContent = """
            // swift-tools-version: 5.7
            
            import PackageDescription
            
            let package = Package(
                name: "ModulePackage",
                products: [
                    .library(name: "Module", targets: ["Module"]),
                ],
                dependencies: [],
                targets: [
                    .target(name: "Module", dependencies: []),
                    .testTarget(name: "ModuleTests", dependencies: ["Module"]),
                ]
            )
            """
            try packageContent.write(toFile: packageFilePath, atomically: true, encoding: .utf8)
            
            try fileManager.createDirectory(atPath: "\(currentDirectory)/Sources", withIntermediateDirectories: true, attributes: nil)
            try fileManager.createDirectory(atPath: "\(currentDirectory)/Tests", withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    struct RunError: Error, CustomStringConvertible {
        let description: String
        
        init(_ message: String) {
            self.description = message
        }
    }
}
