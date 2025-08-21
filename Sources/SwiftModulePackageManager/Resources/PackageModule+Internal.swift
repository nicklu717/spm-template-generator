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
