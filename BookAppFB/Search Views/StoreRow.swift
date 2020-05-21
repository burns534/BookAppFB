//
//  StoreRow.swift
//  SwiftUIBook
//
//  Created by Kyle Burns on 5/5/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import SwiftUI

struct StoreRow: View {
    var book : FullBook
    
    var body: some View {
            HStack(alignment: .top){
                VStack {
                    Text("Released")
                    Text(book.year >= 0 ? String(book.year) : String(book.year * -1) + " B.C.")
                        .fontWeight(.ultraLight)
                }
                Divider()
                    .frame(height: 60)
                VStack {
                    Text("Pages")
                    Text(String(book.pages))
                        .fontWeight(.ultraLight)
                }
                Divider()
                    .frame(height: 60)
                VStack {
                    Text("Language")
                    Text(book.language)
                        .fontWeight(.ultraLight)
                }
                Divider()
                    .frame(height: 60)
                VStack {
                    Text("Country")
                    Text(book.country)
                        .fontWeight(.ultraLight)
                }
            }
    }
}

struct StoreRow_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
