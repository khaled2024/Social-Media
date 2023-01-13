//
//  ProfileView.swift
//  Social-Media
//
//  Created by KhaleD HuSsien on 13/01/2023.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

struct ProfileView: View {
    //MARK: - profile data...
    @State private var myProfile: User?
    @AppStorage("log_Status") var logStatus: Bool = false
    @State var errorMessage: String = ""
    @State var showError: Bool = false
    @State var isLoading: Bool = false
    var body: some View {
        NavigationStack{
            VStack{
                if let myProfile{
                    ReusableProfileContent(user: myProfile)
                        .refreshable(action: {
                            // swip down to refresh user data...
                            self.myProfile = nil
                            await featchingUserData()
                        })
                }else{
                    ProgressView()
                }
            }
            .navigationTitle("My Profile")
            // toolBar Buttons
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        // Two Actions...
                        // 1: logout...
                        //2: delete account...
                        Button("Log out", action: logOut)
                        Button("Delete Account",role: .destructive,action: deleteAccount)
                    } label: {
                        Image(systemName: "ellipsis")
                            .rotationEffect(Angle(degrees: 90))
                            .tint(.black)
                            .scaleEffect(0.8)
                    }
                }
            }
        }
        // for loading view
        .overlay{
            LoadingView(showLoadingView: $isLoading)
        }
        // for showing Alert
        .alert(errorMessage, isPresented: $showError, actions: {})
        // task happen before the view appear...
        .task {
            // if myProfile have value featchData else {return}...
            if myProfile != nil {return}
            await featchingUserData()
        }
    }
    //MARK: - functions...
    func featchingUserData()async{
        guard let userID = Auth.auth().currentUser?.uid else{return}
        guard let user = try? await Firestore.firestore().collection("Users").document(userID).getDocument(as: User.self) else{return}
        await MainActor.run(body: {
            myProfile = user
            print("\(myProfile)")
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
                logStatus = false
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
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
