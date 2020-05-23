//
//  SearchPage.swift
//  SwiftUIBook
//
//  Created by Kyle Burns on 5/4/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import SwiftUI

struct SearchPage: View {
    
    @EnvironmentObject var library : BookData
    
    @ObservedObject var sbvm = SearchBarViewModel()
    
    @FetchRequest(entity: CoreBook.entity(), sortDescriptors: sortDescriptors) var myBooks : FetchedResults<CoreBook>
    @Environment(\.managedObjectContext) var moc
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(sbvm: self.sbvm)
                if sbvm.scope == Scope.store {
                    SearchPageStore(sbvm: self.sbvm)
                } else {
                    ScrollView {
                        // This was funky. SwiftUI would not let me do a regular tertiary but would let me do it inside the filter? go have you
                        ForEach(myBooks.filter { book in
                            filterContain(book, self.sbvm.text) || (self.sbvm.text == "" ? true : false)
                        } , id: \.title) { book in
                                Button(action: {
                                        self.library.contextBook = FullBook(fromCoreBook: book)
                                        self.sbvm.push.toggle()
                                }) {
                                    SearchRow(book: FullBook(fromCoreBook: book))
                                }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                NavigationLink(destination: StorePage().environmentObject(self.library), isActive: self.$sbvm.push) {
                    Text("")
                }
                .frame(width: 0, height: 0)
                .clipped()
            }
            .buttonStyle(PlainButtonStyle())
            .navigationBarTitle("")
            .navigationBarHidden(true)
        }
    }
}

struct SearchPage_Previews: PreviewProvider {
    
    static var previews: some View {
        EmptyView()
    }
}


