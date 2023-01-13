//
//  LoginView.swift
//  Social-Media
//
//  Created by KhaleD HuSsien on 12/01/2023.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var loginVM = LoginViewModel()
    var body: some View {
        VStack(spacing: 10) {
            Text("Lets Sign you in")
                .font(.largeTitle.bold())
                .HAlign(.leading)
            
            Text("Welcome Back, \nYou have been missed")
                .font(.title3)
                .HAlign(.leading)
            
            VStack(spacing: 12) {
                TextField("Email", text: $loginVM.emailID)
                    .textContentType(.emailAddress)
                    .border(1, .gray.opacity(0.5))
                    .padding(.top, 25)
                SecureField("Password", text: $loginVM.password)
                    .textContentType(.password)
                    .border(1, .gray.opacity(0.5))
                Button {
                    loginVM.resetPassword()
                } label: {
                    Text("Reset Password?")
                }
                .font(.callout)
                .fontWeight(.medium)
                .tint(.black)
                .HAlign(.trailing)
                Button {
                    loginVM.loginUser()
                } label: {
                    Text("Sign in")
                        .foregroundColor(.white)
                        .HAlign(.center)
                        .fillView(.black)
                }
                .padding(.top, 10)
            } //: VSTACK
            //MARK: - Register Button
            HStack {
                Text("Don't have an account?")
                    .foregroundColor(.gray)
                
                Button("Register Now") {
                    loginVM.createAccount.toggle()
                }
                .fontWeight(.bold)
                .foregroundColor(.black)
            }
            .font(.callout)
            .VAlign(.bottom)
            
        }
        .VAlign(.top)
        .padding(15)
        .overlay(content: {
            LoadingView(showLoadingView: $loginVM.showLoadingView)
        })
        // MARK: Register View Via Sheets
        .fullScreenCover(isPresented: $loginVM.createAccount) {
            RegisterView()
        }
        //MARK: Displaying Alert
        .alert(loginVM.errorMessage, isPresented: $loginVM.showError, actions: {})
    }
}


struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
