//
//  RegisterViewModel.swift
//  Social-Media
//
//  Created by KhaleD HuSsien on 12/01/2023.
//

import Foundation
import SwiftUI
import PhotosUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

class RegisterViewModel: ObservableObject{
    //MARK: - User Properties
    @Published var emailID: String = ""
    @Published var password: String = ""
    @Published var username: String = ""
    @Published var userBio: String = ""
    @Published var userBioLink: String = ""
    @Published var userProfilePicData: Data?
    //MARK: View Properties
    @Published var showImagePicker: Bool = false
    @Published var photoItem: PhotosPickerItem?
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var showLoadingView: Bool = false
    //MARK: - User defaults
    @AppStorage("log_Status") var logStatus: Bool = false
    @AppStorage("user_profile_url") var profileURL:URL?
    @AppStorage("user_name") var userNameStored: String = ""
    @AppStorage("user_UID") var userIDStored: String = ""
    //MARK: Functions
    func registerUser(){
        showLoadingView = true
        closeKeyboard()
        Task {
            do  {
                //Step 1: Creating Firebase Account
                try await Auth.auth().createUser(withEmail: emailID, password: password)
                // Step 2: Uploading Profile Photo Into firbase storage
                guard let userUID = Auth.auth().currentUser?.uid else { return }
                guard let imageData = userProfilePicData else { return }
                let storageRef = Storage.storage().reference().child("Profile_Images").child(userUID)
                let _ = try await storageRef.putDataAsync(imageData)
                // Step 3: downloading Image...
                let downloadURL = try await storageRef.downloadURL()
                // step 4: creating user
                let user = User(userName: username, userBio: userBio, userBioLink: userBioLink, userUID: userUID, userEmail: emailID, userProfileURL: downloadURL)
                // step 5: saving user document to firestore...
                let _ = try Firestore.firestore().collection("Users").document(userUID).setData(from: user, completion: { error in
                    if error == nil{
                        //"SAVED SUCCEFULLY"
                        print("SAVED SUCCEFULLY")
                        self.userNameStored = self.username
                        self.userIDStored = userUID
                        self.profileURL = downloadURL
                        // here to make Main view appear
                        self.logStatus = true
                    }
                })
            }
            catch {
                try await Auth.auth().currentUser?.delete()
                await setError(error)
            }
        }
    }
    //MARK: Displaying Error via Alert
    func setError(_ error : Error) async {
        //MARK: UI Must be updated on Main thread
        await MainActor.run(body: {
            errorMessage = error.localizedDescription
            showError.toggle()
            showLoadingView = false
        })
    }
    //MARK: - Closing All Active Keyboards
    // when sign in sign up pressed the keyboard is closed...
    func closeKeyboard(){
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
