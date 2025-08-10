//
//  SPMTemplateGenerator.swift
//  spm-template-generator
//
//  Created by 陸瑋恩 on 2025/8/10.
//

import ArgumentParser

@main
struct SPMTemplateGenerator: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Generate a Swift Package Manager template.",
        subcommands: [GenerateTemplate.self]
    )
    
    struct GenerateTemplate: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Generate a Swift Package Manager template."
        )
        
        @Option(name: .shortAndLong, help: "The name of the package.")
        var packageName: String
        
        func run() throws {
            print("Generating SPM template for package: \(packageName)")
        }
    }
}
