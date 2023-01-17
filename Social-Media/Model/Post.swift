//
//  Post.swift
//  Social-Media
//
//  Created by KhaleD HuSsien on 15/01/2023.
//

import SwiftUI
import FirebaseFirestoreSwift

struct Post: Identifiable,Codable{
    @DocumentID var id: String?
    var text: String
    var imageURL: URL?
    var imageRefID: String = ""
    var puplishedDate: Date = Date()
    var likedIDs: [String] = []
    var dislikedIDs: [String] = []
    var userName: String
    var userID: String
    var userProfileURL: URL
    
    enum CodingKeys: CodingKey {
        case id
        case text
        case imageURL
        case imageRefID
        case puplishedDate
        case likedIDs
        case dislikedIDs
        case userName
        case userID
        case userProfileURL
    }
}

