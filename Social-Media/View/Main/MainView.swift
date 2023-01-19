//
//  MainView.swift
//  Social-Media
//
//  Created by KhaleD HuSsien on 13/01/2023.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        //MARK: - TableView with recent posts...
        TabView {
            PostsView()
                .tabItem {
                    Image(systemName: "rectangle.portrait.on.rectangle.portrait.angled")
                    Text("Posts")
                }
            ProfileView()
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
        }
        .tint(Color("IconColor"))
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
