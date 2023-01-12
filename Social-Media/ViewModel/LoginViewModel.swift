//
//  LoginViewModel.swift
//  Social-Media
//
//  Created by KhaleD HuSsien on 12/01/2023.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestore
class LoginViewModel: ObservableObject{
    //MARK: - User Details Properties
    @Published var emailID: String = ""
    @Published var password: String = ""
    //MARK: - View Properties
    @Published var createAccount: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var showLoadingView: Bool = false
    //MARK: - User defaults...
    @AppStorage("log_Status") var logStatus: Bool = false
    @AppStorage("user_profile_url") var profileURL:URL?
    @AppStorage("user_name") var userNameStored: String = ""
    @AppStorage("user_UID") var userIDStored: String = ""
    //MARK: Functions
    // log in the user...
    func loginUser() {
        showLoadingView = true
        closeKeyboard()
        Task {
            do {
                //With the help of swift COncurrency Auth can be done with Single Line
                try await Auth.auth().signIn(withEmail: emailID, password: password)
                print("User Found")
                try await fetchUser()
            } catch{
                await setError(error)
            }
        }
    }
    // when user log i succefully we need to fetch his user data from database...
    func fetchUser()async throws{
        guard let userID = Auth.auth().currentUser?.uid else{return}
        let user = try await Firestore.firestore().collection("Users").document(userID).getDocument(as: User.self)
        DispatchQueue.main.async {
            self.userIDStored = userID
            self.userNameStored = user.userName
            self.profileURL = user.userProfileURL
            self.logStatus = true
        }
    }
    // reset user password with his email...
    func resetPassword() {
        Task {
            do {
                //With the help of swift COncurrency Auth can be done with Single Line
                try await Auth.auth().sendPasswordReset(withEmail: emailID)
                print("Link Sent")
            } catch {
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

