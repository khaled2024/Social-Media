//
//  User.swift
//  Social-Media
//
//  Created by KhaleD HuSsien on 12/01/2023.
//
import SwiftUI
import FirebaseFirestoreSwift

struct User: Identifiable,Codable{
    @DocumentID var id: String?
    var userName: String
    var userBio: String
    var userBioLink: String
    var userUID: String
    var userEmail: String
    var userProfileURL: URL
    
    enum CodingKeys: CodingKey {
        case id
        case userName
        case userBio
        case userBioLink
        case userUID
        case userEmail
        case userProfileURL
    }
}
