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
