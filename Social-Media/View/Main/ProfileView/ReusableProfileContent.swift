//
//  ReusableProfileContent.swift
//  Social-Media
//
//  Created by KhaleD HuSsien on 13/01/2023.
//

import SwiftUI
import SDWebImageSwiftUI
struct ReusableProfileContent: View {
    var user: User
    @State private var fetchedPosts: [Post] = []
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack{
                HStack(spacing: 12) {
                    WebImage(url:user.userProfileURL).placeholder{
                        Image("person")
                            .resizable()
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    VStackLayout(alignment: .leading){
                        Text(user.userName)
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text(user.userBio)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(4)
                        
                        if let bioLink = URL(string: user.userBioLink){
                            Link(user.userBioLink, destination: bioLink)
                                .font(.callout)
                                .tint(.blue)
                                .lineLimit(1)
                                .padding(.vertical, 2)
                        }
                    }
                    .HAlign(.leading)
                    .padding(.vertical, 4)
                }
                Divider()
                    .padding(.horizontal, 8)
                    .tint(Color(uiColor: .darkGray))
                Text("Posts")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("ColorButton"))
                    .HAlign(.leading)
                    .padding(.vertical,10)
                
                ReusablePostView(basedOnUID: true, uid: user.userUID, posts: $fetchedPosts)
            }
            .padding(15)
        }
    }
}
struct ReusableProfileContent_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
