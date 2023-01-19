//
//  RegisterView.swift
//  Social-Media
//
//  Created by KhaleD HuSsien on 12/01/2023.
//

import SwiftUI

struct RegisterView: View {
    @ObservedObject var registerVM = RegisterViewModel()
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        VStack(spacing: 10) {
            Text("Let's Register")
                .font(.largeTitle.bold())
                .HAlign(.leading)
            Text("Hello user, you have a wonderful journey")
                .font(.title3)
                .HAlign(.leading)
            //MARK: For Smaller Size Optimization
            ViewThatFits {
                ScrollView(.vertical, showsIndicators: false){
                    HelperView()
                }
            }
            //MARK: - Register Button
            HStack {
                Text("Already have an account?")
                    .foregroundColor(.gray)
                Button("Login Now") {
                    presentationMode.wrappedValue.dismiss()
                }
                .fontWeight(.bold)
                .foregroundColor(Color("ColorButton"))
            }
            .font(.callout)
            //            .VAlign(.bottom)
        }
        .VAlign(.top)
        .padding(15)
        .overlay(content: {
            LoadingView(showLoadingView: $registerVM.showLoadingView)
        })
        .photosPicker(isPresented: $registerVM.showImagePicker, selection: $registerVM.photoItem)
        .onChange(of: registerVM.photoItem) { newValue in
            //MARK: Extracting UIImage from PhotoItem
            if let newValue {
                Task {
                    do {
                        guard let imageData = try await newValue.loadTransferable(type: Data.self) else{return}
                        //MARK: UI Must be updated on Main thread
                        await MainActor.run(body: {
                            registerVM.userProfilePicData = imageData
                        })
                    } catch {}
                }
            }
        }
        //MARK: Displaying Alert
        .alert(registerVM.errorMessage, isPresented: $registerVM.showError, actions: {})
    }
    // MARK: - ViewBuilder
    @ViewBuilder
    func HelperView() -> some View {
        VStack(spacing: 12) {
            // for image
            ZStack {
                if let picData = registerVM.userProfilePicData, let image = UIImage(data: picData) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .tint(Color("IconColor"))
                }
            }
            .frame(width: 90, height: 90)
            .clipShape(Circle())
            .contentShape(Circle())
            .onTapGesture {
                registerVM.showImagePicker.toggle()
            }
            .padding(.top, 25)
            // TextFields...
            TextField("User Name", text: $registerVM.username)
                .textContentType(.username)
                .border(1, .gray.opacity(0.5))
            TextField("Email", text: $registerVM.emailID)
                .textContentType(.emailAddress)
                .border(1, .gray.opacity(0.5))
            SecureField("Password", text: $registerVM.password)
                .textContentType(.password)
                .border(1, .gray.opacity(0.5))
            TextField("About You", text: $registerVM.userBio, axis: .vertical)
                .frame(minHeight: 100, alignment: .top)
                .textContentType(.none)
                .border(1, .gray.opacity(0.5))
            TextField("Bio Link (Optional)", text: $registerVM.userBioLink)
                .textContentType(.URL)
                .border(1, .gray.opacity(0.5))
            
            Button(action: registerVM.registerUser) {
                Text("Sign up")
                    .foregroundColor(Color("ForegroundButton"))
                    .HAlign(.center)
                    .fillView(Color("ColorButton"))
            }
            .disableWithOpacity(registerVM.username == "" ||
                                registerVM.emailID == ""  ||
                                registerVM.userBio == ""  ||
                                registerVM.password == "" ||
                                registerVM.userProfilePicData == nil)
            .padding(.top, 10)
        } //: VSTACK
    }
}
struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
