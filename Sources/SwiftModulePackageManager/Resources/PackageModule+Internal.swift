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
