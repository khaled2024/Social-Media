//
//  PostsView.swift
//  Social-Media
//
//  Created by KhaleD HuSsien on 15/01/2023.
//

import SwiftUI

struct PostsView: View {
    @State var createNewPost: Bool = false
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .HAlign(.center).VAlign(.center)
            .overlay {
                Button {
                    createNewPost.toggle()
                } label: {
                    Image(systemName: "plus")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(13)
                        .background(.black,in:(Circle()))
                }
                .padding(15)
                .VAlign(.bottomTrailing).HAlign(.trailing)
            }
            .fullScreenCover(isPresented: $createNewPost) {
                CreateNewPost(onPost: { post in
                    
                })
            }
    }
}

struct PostsView_Previews: PreviewProvider {
    static var previews: some View {
        PostsView()
    }
}
