//
//  ReusablePostsView.swift
//  Social-Media
//
//  Created by KhaleD HuSsien on 17/01/2023.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct ReusablePostsView: View {
    @Binding var posts: [Post]
    @State var isFeatching: Bool = false
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack{
                if isFeatching{
                    ProgressView()
                        .padding(.top,30)
                }else{
                    if posts.isEmpty{
                        // no posts found in firebase...
                        Text("No Post's Found")
                            .font(.title3.bold())
                            .foregroundColor(.gray)
                            .padding(.top, 30)
                    }else{
                        Posts()
                    }
                }
            }
            .padding(15)
        }
        .refreshable {
            // scroll to refresh...
            isFeatching = true
            posts = []
            await fetchPosts()
        }
        .task {
            // fetching for one time...
            // if posts isEmpty go to fetch data else return
            guard posts.isEmpty else{return}
            await fetchPosts()
        }
    }
    //MARK: - Functions...
    @ViewBuilder
    func Posts()-> some View{
        ForEach(posts) { post in
            PostCardView(post: post) { updatedPost in
                // uploading post in the array...
                if let index = posts.firstIndex(where: { post in
                    post.id == updatedPost.id
                }){
                    posts[index].likedIDs = updatedPost.likedIDs
                    posts[index].dislikedIDs = updatedPost.dislikedIDs
                }
            } onDelete: {
                // removing post from the array
                withAnimation(.easeInOut(duration: 0.25)) {
                    posts.removeAll {
                        post.id == $0.id
                    }
                }
            }
            Divider()
                .padding(.horizontal, -15)
        }
    }
    func fetchPosts()async{
        do{
            var query: Query!
            query = Firestore.firestore().collection("Posts")
                .order(by: "puplishedDate", descending: true)
                .limit(to: 20)
            let docs = try await query.getDocuments()
            let fetchedPosts = docs.documents.compactMap { doc -> Post? in
                try? doc.data(as: Post.self)
            }
            await MainActor.run(body: {
                posts = fetchedPosts
                isFeatching = false
            })
        }catch{
            print(error.localizedDescription)
        }
    }
}
struct ReusablePostsView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
