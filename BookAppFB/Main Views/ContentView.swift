//
//  ContentView.swift
//  BookAppFB
//
//  Created by Kyle Burns on 5/7/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import SwiftUI
import CoreData
import FirebaseStorage

// add swiping from tab to tab
// fix search page not updating tableview when leaving and returning back

struct ContentView: View {

    init() {
        tabBar()
    }
    var body: some View {
        GeometryReader { geometry in
            TabView {
                Library()
                    .tabItem {
                        Image(systemName: "book")
                        Text("Library")
                }
                .buttonStyle(PlainButtonStyle())
                Store()
                    .tabItem {
                        Image(systemName: "bag")
                        Text("Store")
                }
                .buttonStyle(PlainButtonStyle())
                SearchPage() // parameter is not doing anything
                    .tabItem {
                        Image(systemName: "magnifyingglass")
                        Text("Search")
                }
                .buttonStyle(PlainButtonStyle())
            }
            .offset(x: 0, y: 0.2)
            .accentColor(.olive)
        }
    }
}

extension ContentView {
    func tabBar() {
        UITabBar.appearance().layer.masksToBounds = true
        UITabBar.appearance().backgroundColor = .olive
        UITabBar.appearance().tintColor = .olive
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(BookData())
    }
}
