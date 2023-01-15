//
//  ProfileViewModel.swift
//  Social-Media
//
//  Created by KhaleD HuSsien on 15/01/2023.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage
class ProfileViewModel: ObservableObject {
    
    //MARK: - profile data...
    @Published  var myProfile: User?
    @AppStorage("log_Status") var logStatus: Bool = false
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false
    @Published var isLoading: Bool = false
    
    //MARK: - functions...
    func featchingUserData()async{
        guard let userID = Auth.auth().currentUser?.uid else{return}
        guard let user = try? await Firestore.firestore().collection("Users").document(userID).getDocument(as: User.self) else{return}
        await MainActor.run(body: {
            myProfile = user
        })
    }
    func logOut(){
        print("log out")
        try? Auth.auth().signOut()
        logStatus = false
    }
    func deleteAccount(){
        isLoading = true
        Task {
            do{
                guard let userID = Auth.auth().currentUser?.uid else{return}
                // firest delete profile image...
                let ref = Storage.storage().reference().child("Profile_Images").child(userID)
                try await ref.delete()
                // delete user document...
                try await Firestore.firestore().collection("Users").document(userID).delete()
                // delete Auth account & setting logStatus to false...
                try await Auth.auth().currentUser?.delete()
                await MainActor.run(body: {
                    logStatus = false
                })
            }catch{
                await setError(error)
            }
        }
    }
    func setError(_ error: Error)async{
        await MainActor.run(body: {
            isLoading = false
            errorMessage = error.localizedDescription
            showError.toggle()
        })
    }
}
