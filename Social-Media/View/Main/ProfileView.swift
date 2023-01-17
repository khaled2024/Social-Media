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
    @ObservedObject var profileVM = ProfileViewModel()
    var body: some View {
        NavigationStack{
            VStack{
                if let myProfile = profileVM.myProfile{
                    ReusableProfileContent(user: myProfile)
                    // swip down to refresh user data and featch a new update of user profile...
                        .refreshable(action: {
                            profileVM.myProfile = nil
                            await profileVM.featchingUserData()
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
                        //1: logout...
                        //2: delete account...
                        Button("Log out", action: profileVM.logOut)
                        Button("Delete Account",role: .destructive,action: profileVM.deleteAccount)
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
            LoadingView(showLoadingView: $profileVM.isLoading)
        }
        // for showing Alert
        .alert(profileVM.errorMessage, isPresented: $profileVM.showError, actions: {})
        // task happen before the view appear...
        .task {
            // if myProfile have value featchData else {return}...
            if profileVM.myProfile != nil {return}
            await profileVM.featchingUserData()
        }
    }
   
}
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
