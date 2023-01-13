//
//  ContentView.swift
//  Social-Media
//
//  Created by KhaleD HuSsien on 12/01/2023.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("log_Status") var logStatus: Bool = false
    var body: some View {
        if logStatus{
            MainView()
        }else{
            LoginView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        //            .previewDevice(PreviewDevice(rawValue: "iPhone 8"))
    }
}
