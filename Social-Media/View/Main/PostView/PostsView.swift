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
            ReusablePostView(posts: $recentsPost)
                .HAlign(.center)
                .VAlign(.center)
            // floating btn...
                .overlay {
                    Button {
                        createNewPost.toggle()
                    } label: {
                        Image(systemName: "plus")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("ForegroundButton"))
//                            .foregroundColor(Color("ColorButton"))
                            .padding(13)
                            .background(Color("ColorButton"),in:(Circle()))
                    }
                    .padding(15)
                    .VAlign(.bottomTrailing)
                    .HAlign(.trailing)
                }
                .toolbar(content: {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink {
                            SearchUserView()
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .tint(Color("IconColor"))
                                .scaleEffect(0.9)
                        }

                    }
                })
                .navigationTitle("Posts")
        }
        // To Show full screen (Create-New-Post)...
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
