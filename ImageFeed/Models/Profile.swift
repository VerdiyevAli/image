import Foundation

struct Profile {
    let id: String
    let userName: String
    let firstName: String
    let lastName: String
    let name: String
    let loginName: String
    let bio: String?
    
    init(from profileResult: ProfileResult) {
        self.id = profileResult.id
        self.userName = profileResult.username
        self.firstName = profileResult.firstName ?? ""
        self.lastName = profileResult.lastName ?? ""
        
        // Формируем полное имя с учетом возможных пустых значений
        let fullName = [profileResult.firstName, profileResult.lastName]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        
        self.name = fullName.isEmpty ? profileResult.username : fullName
        self.loginName = "@\(profileResult.username)"
        self.bio = profileResult.bio
    }
}
