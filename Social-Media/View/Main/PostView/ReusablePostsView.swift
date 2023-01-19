//
//  ReusablePostsView.swift
//  Social-Media
//
//  Created by KhaleD HuSsien on 17/01/2023.
//

import SwiftUI
import Firebase

struct ReusablePostView: View {
    var basedOnUID: Bool = false
    var uid: String = ""
    @Binding var posts: [Post]
    ///VIew Properties
    @State private var isFetching: Bool = true
    /// - Pagicnation
    @State private var paginationDoc: QueryDocumentSnapshot?
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack {
                if isFetching {
                    ProgressView()
                        .padding(.top, 30)
                } else {
                    if posts.isEmpty {
                        /// No  Post found on firestore
                        Text("No Post's Found")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                            .padding(.top, 30)
                    } else {
                        //Display Post's
                        Posts()
                    }
                }
            }
            .padding(15)
        }
        .refreshable {
            /// - Scroll to Refresh
            /// - Disabling refresh for UID based Post's
            guard !basedOnUID else{return}
            isFetching = true
            posts = []
            /// - Reseting Pagination Doc
            paginationDoc = nil
            await fetchPosts()
        }
        .task {
            /// - Fetching For the One time
            guard posts.isEmpty else { return }
            await fetchPosts()
        }
    }
    //Displaying Fetched Post's
    @ViewBuilder
    func Posts() -> some View {
        ForEach(posts) { post in
            PostCardView(post: post) { updatedPost in
                ///Updating Post in the Array
                if let index = posts.firstIndex(where: { post in
                    post.id == updatedPost.id
                }){
                    posts[index].likedIDs = updatedPost.likedIDs
                    posts[index].dislikedIDs = updatedPost.dislikedIDs
                }
            } onDelete: {
                //Removing POst From the Array
                withAnimation(.easeInOut(duration: 0.25)) {
                    posts.removeAll { post.id == $0.id }
                }
            }
            .onAppear {
                /// - When Last Post Appears, Fetching New Post (If there)
                if post.id == posts.last?.id && paginationDoc != nil {
                    Task{await fetchPosts()}
                }
            }
            Divider()
                .padding(.horizontal, -15)
        }
    }
    func fetchPosts() async {
        do {
            var query: Query!
            ///- Implementation Pagination
            if let paginationDoc {
                query = Firestore.firestore().collection("Posts")
                    .order(by: "publishedDate", descending: true)
                    .start(afterDocument: paginationDoc)
                    .limit(to: 20)
            } else {
                query = Firestore.firestore().collection("Posts")
                    .order(by: "publishedDate", descending: true)
                    .limit(to: 20)
            }
            /// - New query for UID  based document fetch
            /// simply filter the posts which is not belongs to this UID
            if basedOnUID {
                query = query
                    .whereField("userID", isEqualTo: uid)
            }
            let docs = try await query.getDocuments()
            let fetchPosts = docs.documents.compactMap { doc -> Post? in
                try? doc.data(as: Post.self)
            }
            await MainActor.run(body: {
                posts.append(contentsOf: fetchPosts)
                paginationDoc = docs.documents.last
                isFetching = false
            })
        } catch {
            print(error.localizedDescription)
        }
    }
}
struct ReusablePostsView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
