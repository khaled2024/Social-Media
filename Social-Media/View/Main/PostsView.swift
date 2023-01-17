//
//  PostsView.swift
//  Social-Media
//
//  Created by KhaleD HuSsien on 15/01/2023.
//

import SwiftUI

struct PostsView: View {
    @State var createNewPost: Bool = false
    @State private var recentsPost: [Post] = []
    var body: some View {
        NavigationStack{
            ReusablePostsView(posts: $recentsPost)
                .HAlign(.center).VAlign(.center)
                .overlay {
                    Button {
                        createNewPost.toggle()
                    } label: {
                        Image(systemName: "plus")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(13)
                            .background(.black,in:(Circle()))
                    }
                    .padding(15)
                    .VAlign(.bottomTrailing)
                    .HAlign(.trailing)
                }
                .navigationTitle("Posts")
        }
        // to show full screen (Create-New-Post)...
        .fullScreenCover(isPresented: $createNewPost) {
            CreateNewPost(onPost: { post in
                self.recentsPost.insert(post, at: 0)
            })
        }
    }
}
struct PostsView_Previews: PreviewProvider {
    static var previews: some View {
        PostsView()
    }
}
