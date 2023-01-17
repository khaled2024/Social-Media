//
//  PostCardView.swift
//  Social-Media
//
//  Created by KhaleD HuSsien on 17/01/2023.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase
import FirebaseStorage
struct PostCardView: View {
    var post: Post
    var onUpdate: (Post)->()
    var onDelete: ()->()
    @AppStorage("user_UID") private var userIDStored: String = ""
    // for live update (like & dislike)...
    @State private var docListner: ListenerRegistration?
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            WebImage(url: post.userProfileURL)
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 4) {
                Text(post.userName)
                    .font(.callout)
                    .fontWeight(.semibold)
                Text(post.puplishedDate.formatted(date: .numeric, time: .shortened))
                    .font(.caption2)
                    .foregroundColor(.gray)
                Text(post.text)
                    .textSelection(.enabled)
                    .padding(.vertical,8)
                // post image if found...
                if let postImageURL = post.imageURL{
                    GeometryReader { geo in
                        let size = geo.size
                        WebImage(url: postImageURL)
                            .resizable()
                            .scaledToFill()
                            .frame(width: size.width, height: size.height)
                            .clipShape(RoundedRectangle(cornerRadius: 10,style: .continuous))
                    }
                    .frame(height: 200)
                }
                // Like/Dislike Integration...
                postIntegration()
            }
        }
        .HAlign(.leading)
        .overlay(alignment: .topTrailing, content: {
            // display delete btn if it is Auther of the post...
            if post.userID == userIDStored{
                Menu {
                    Button("Delete Post",role: .destructive,action: deletePost)
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.caption)
                        .rotationEffect(Angle(degrees: 90))
                        .foregroundColor(.black)
                        .padding(8)
                        .contentShape(Rectangle())
                }
                .offset(x: 8)
            }
        })
        .onAppear {
            // adding only once...
            if docListner == nil {
                guard let postID = post.id else{return}
                docListner = Firestore.firestore().collection("Posts").document(postID).addSnapshotListener({ snapshot, error in
                    if let snapshot{
                        if snapshot.exists{
                            // document updated...
                            //fetching updated document...
                            if let updatedPost = try? snapshot.data(as: Post.self){
                                onUpdate(updatedPost)
                            }
                        }else{
                            // document delete...
                            onDelete()
                        }
                    }
                })
            }
        }
        .onDisappear {
            if let docListner{
                docListner.remove()
                self.docListner = nil
            }
        }
    }
    //MARK: - Like/Dislike Integration...
    @ViewBuilder
    func postIntegration()-> some View{
        HStack(spacing: 6) {
            Button(action: {likePost()}) {
                Image(systemName: post.likedIDs.contains(userIDStored) ? "hand.thumbsup.fill" : "hand.thumbsup")
            }
            Text("\(post.likedIDs.count)")
                .font(.caption)
                .foregroundColor(.gray)
            Button(action: {dislikePost()}) {
                Image(systemName: post.dislikedIDs.contains(userIDStored) ? "hand.thumbsdown.fill" : "hand.thumbsdown")
            }
            .padding(.leading, 25)
            Text("\(post.dislikedIDs.count)")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .foregroundColor(.black)
        .padding(.vertical, 8)
    }
    //MARK: - functions...
    func likePost(){
        Task{
            guard let postID = post.id else{return}
            if post.likedIDs.contains(userIDStored){
                // removing user id from the array...
                try await Firestore.firestore().collection("Posts").document(postID).updateData([
                    "likedIDs" : FieldValue.arrayRemove([userIDStored])
                ])
            }else{
                // adding user id to like array and remove our id from dislike array...
                try await Firestore.firestore().collection("Posts").document(postID).updateData([
                    "likedIDs" : FieldValue.arrayUnion([userIDStored]),
                    "dislikedIDs" : FieldValue.arrayRemove([userIDStored])
                ])
            }
        }
    }
    func dislikePost(){
        Task{
            guard let postID = post.id else{return}
            if post.dislikedIDs.contains(userIDStored){
                // removing user id from the array...
               try await Firestore.firestore().collection("Posts").document(postID).updateData([
                    "dislikedIDs" : FieldValue.arrayRemove([userIDStored])
                ])
            }else{
                // adding user id to like array and remove our id from dislike array...
                try await Firestore.firestore().collection("Posts").document(postID).updateData([
                    "likedIDs" : FieldValue.arrayRemove([userIDStored]),
                    "dislikedIDs" : FieldValue.arrayUnion([userIDStored])
                ])
            }
        }
    }
    func deletePost(){
        Task{
            // delete image from firebase...
            do{
                if post.imageRefID != ""{
                    try await Storage.storage().reference().child("Post_Images").child(post.imageRefID).delete()
                }
            // delete firestore document...
                guard let postID = post.id else{return}
                try await Firestore.firestore().collection("Posts").document(postID).delete()
            }catch{
                print(error.localizedDescription)
            }
        }
    }
}


