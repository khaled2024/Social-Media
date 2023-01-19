//
//  SearchUserView.swift
//  Social-Media
//
//  Created by KhaleD HuSsien on 19/01/2023.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import SDWebImageSwiftUI
struct SearchUserView: View {
    @State private var fetchedUsers: [User] = []
    @State private var searchText: String = ""
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        List{
            ForEach(fetchedUsers) { user in
                NavigationLink {
                    ReusableProfileContent(user: user)
                } label: {
                    HStack{
                        WebImage(url: user.userProfileURL).placeholder{
                            Image("person")
                                .resizable()
                        }
                        .resizable()
                        .frame(width: 45, height: 45, alignment: .leading)
                        .scaledToFill()
                        .clipShape(Circle())
                        Text(user.userName)
                            .font(.title2)
                    }
                    .frame(height: 60,alignment: .leading)
                }
            }
        }
        .listStyle(.sidebar)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Search User")
        .searchable(text: $searchText)
        .onSubmit(of: .search, {
            // fetch user from firestore...
            Task{await searchUser()}
        })
        .onChange(of: searchText, perform: { newValue in
            if newValue.isEmpty{
                fetchedUsers = []
            }
        })
        
    }
    func searchUser()async{
        do{
            let documents = try await Firestore.firestore().collection("Users")
                .whereField("userName", isGreaterThanOrEqualTo: searchText)
                .whereField("userName", isLessThanOrEqualTo: "\(searchText)\u{f8ff}")
                .getDocuments()
            
            let users = try documents.documents.compactMap { doc -> User? in
                try doc.data(as: User.self)
            }
            await MainActor.run(body: {
                fetchedUsers = users
            })
        }catch{
            print(error.localizedDescription)
        }
    }
}

struct SearchUserView_Previews: PreviewProvider {
    static var previews: some View {
        SearchUserView()
    }
}
