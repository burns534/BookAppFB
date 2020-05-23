//
//  SearchPageStore.swift
//  BookAppFB
//
//  Created by Kyle Burns on 5/16/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import SwiftUI

struct SearchPageStore: View {
    @ObservedObject var sbvm : SearchBarViewModel
    
    @EnvironmentObject var library: BookData
    
    @Environment(\.managedObjectContext) var moc
    
    @State var pushStore : Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                if sbvm.recents.count > 0 {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Recent")
                                .fontWeight(.ultraLight)
                                .foregroundColor(.olive)
                            Spacer()
                            Button(action: {
                                self.sbvm.recents.removeAll()
                            }) {
                                Text("Clear")
                                    .fontWeight(.light)
                                    .kerning(3)
                                    .foregroundColor(.olive)
                                    .offset(y: 0.5)
                            }
                        }
                        Divider()
                        ForEach(sbvm.recents.reversed(), id: \.title) { recent in
                            HStack {
                                Button(action: {
                                    self.sbvm.bypass.toggle()
                                    self.sbvm.text = recent.title
                                    // refresh stack
                                    self.sbvm.recents.removeAll(where: {
                                        $0.title == recent.title
                                    })
                                    self.sbvm.recents.append(recent)
                                }) {
                                    RecentSearch(recent: recent)
                                }
                                Spacer()
                            }
                        }
                    }
                    .padding()
                }
                if sbvm.results.count != 0 {
                    VStack(alignment: .leading) {
                        Text("Suggestions")
                            .fontWeight(.ultraLight)
                            .foregroundColor(.olive)
                        Divider()
                        ForEach(sbvm.results, id: \.title) { book in
                            Button(action: {
                                self.library.contextBook = book
                                self.pushStore = true
                            }) {
                                HStack {
                                    Result(book: book)
                                        .frame(height: 35)
                                    Spacer()
                                }
                            }
                        }
                        NavigationLink(destination: StorePage().environment(\.managedObjectContext, self.moc).environmentObject(self.library), isActive: $pushStore) {
                            Text("")
                        }
                        .frame(width: 0, height: 0)
                        .clipped()
                    }
                    .padding()
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}


