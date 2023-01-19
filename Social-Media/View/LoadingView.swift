//
//  LoadingView.swift
//  Social-Media
//
//  Created by KhaleD HuSsien on 12/01/2023.
//

import SwiftUI

struct LoadingView: View {
    @Binding var showLoadingView: Bool
    var body: some View {
        ZStack{
            if showLoadingView{
                Group{
                    Rectangle()
                        .fill(.black.opacity(0.25))
                        .ignoresSafeArea()
                    ProgressView()
                        .padding(15)
                        .background(Color("ForegroundButton"),in: RoundedRectangle(cornerRadius: 10,style: .continuous))
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: showLoadingView)
    }
}
