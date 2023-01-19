//
//  CreateNewPost.swift
//  Social-Media
//
//  Created by KhaleD HuSsien on 15/01/2023.
//

import Foundation
import SwiftUI
import PhotosUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

struct CreateNewPost: View {
    //MARK: - Proparties...
    //call back
    var onPost: (Post)->()
    @State private var postText: String = ""
    @State private var postImageData: Data?
    // UserDefaults
    @AppStorage("user_profile_url") private var profileURL:URL?
    @AppStorage("user_name") private var userNameStored: String = ""
    @AppStorage("user_UID") private var userIDStored: String = ""
    
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading: Bool = false
    @State private var errorMessage: String = ""
    @State private var showError: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var photoItem: PhotosPickerItem?
    // to toggle the keyboard on and off
    @FocusState private var showKeyboard: Bool
    var body: some View {
        VStack{
            //MARK: - Header...
            HStack{
                // Cancle button...
                Menu {
                    Button("Cancle",role: .destructive){dismiss()}
                } label: {
                    Text("Cancle")
                        .font(.callout)
                        .foregroundColor(Color("ColorButton"))
                }
                .HAlign(.leading)
                // Post button...
                Button {
                    // post to firebase
                    createPost()
                } label: {
                    Text("Post")
                        .font(.callout)
                        .foregroundColor(Color("ForegroundButton"))
                        .padding(.horizontal, 20)
                        .padding(.vertical,6)
                        .background(Color("ColorButton"))
                        .clipShape(Capsule())
                }
                // disable btn...
                //
                .disableWithOpacity(postText == "" && self.postImageData == nil)
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background(
                Rectangle()
                    .fill(.gray.opacity(0.05))
                    .ignoresSafeArea()
            )
            //MARK: - Content (Text & Image)...
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 15){
                    TextField("What's happening", text: $postText,axis: .vertical)
                        .focused($showKeyboard)
                        .tint(Color(uiColor: .secondarySystemGroupedBackground))
                    if let postImageData = self.postImageData,
                       let image = UIImage(data: postImageData){
                        GeometryReader { geo in
                            let size = geo.size
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: size.width, height: size.height)
                                .clipShape(RoundedRectangle(cornerRadius: 10,style: .continuous))
                            // overlay button delete...
                                .overlay(alignment: .topTrailing) {
                                    Button(action: {
                                        withAnimation(.easeInOut(duration: 0.02)) {
                                            self.postImageData = nil
                                        }
                                    }) {
                                        Image(systemName: "trash")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .tint(.red)
                                    }
                                    .padding(10)
                                }
                        }
                        .clipped()
                        .frame(height: 220)
                    }
                }
                .padding(15)
            }
            Divider()
            //MARK: - Fotter...
            HStack{
                // Show ImagePicker button...
                Button {
                    showImagePicker.toggle()
                } label: {
                    Image(systemName: "photo.on.rectangle")
                        .font(.title2)
                        .foregroundColor(Color("ColorButton"))
                }
                .HAlign(.leading)
                // Done button...
                Button("Done") {
                    showKeyboard = false
                }
            }
            .padding(10)
        }
        .VAlign(.top)
        // Show PhotosPicker...
        // Here it first append the image to "photoItem" then to "new value" when user pick another photo the new value go to rawImageData load it and convert to Data then to the "image" to convert it to uiImage then "compressedImageData" to make it pegData. and we must make "photoItem" nil if user pick a diff picture :)
        .photosPicker(isPresented: $showImagePicker, selection: $photoItem)
        .onChange(of: photoItem) { newValue in
            Task{
                if let rawImageData = try? await newValue?.loadTransferable(type: Data.self),
                   let image = UIImage(data: rawImageData),
                   let compressedImageData = image.jpegData(compressionQuality: 0.5){
                    await MainActor.run(body: {
                        postImageData = compressedImageData
                        photoItem = nil
                    })
                }
            }
        }
        .alert(errorMessage, isPresented: $showError, actions: {})
        .overlay {
            LoadingView(showLoadingView: $isLoading)
        }
    }
    //MARK: - Functions
    // Create post...
    func createPost(){
        isLoading = true
        showKeyboard = false
        Task {
            do{
                guard let profileURL = self.profileURL else{return}
                let imageRefID = "\(userIDStored)\(Date())"
                let storageRef = Storage.storage().reference().child("Post_Images").child(imageRefID)
                if let postImageData = self.postImageData{
                    let _ = try await storageRef.putDataAsync(postImageData)
                    let downloadURL = try await storageRef.downloadURL()
                    // create post object with image ID and URL...
                    let post = Post(text: postText, imageURL: downloadURL, imageRefID: imageRefID, userName: userNameStored, userID: userIDStored, userProfileURL: profileURL)
                    try await createDocumentAtFirebase(post)
                }else{
                    // direct post text if there is not any photo to firebase
                    let post = Post(text: postText, userName: userNameStored, userID: userIDStored, userProfileURL: profileURL)
                    try await createDocumentAtFirebase(post)
                }
            }catch{
                await setError(error)
            }
        }
    }
    // Create post object with image ID and URL...
    func createDocumentAtFirebase(_ post: Post)async throws{
        let doc = Firestore.firestore().collection("Posts").document()
        let _ = try doc.setData(from: post, completion: { error in
            if error == nil{
                isLoading = false
                var updatedPost = post
                updatedPost.id = doc.documentID
                onPost(updatedPost)
                dismiss()
            }
        })
    }
    // Display error...
    func setError(_ error: Error)async{
        await MainActor.run(body: {
            errorMessage = error.localizedDescription
            showError.toggle()
        })
    }
}

struct CreateNewPost_Previews: PreviewProvider {
    static var previews: some View {
        CreateNewPost(onPost: { _ in
            
        })
    }
}
