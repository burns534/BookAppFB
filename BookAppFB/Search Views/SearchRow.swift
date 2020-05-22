//
//  SearchRow.swift
//  SwiftUIBook
//
//  Created by Kyle Burns on 5/4/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import SwiftUI

struct SearchRow: View {
    var book : FullBook
    
    var body: some View {
        HStack {
            Image(uiImage: book.getImage())
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 50, height: 80)
                .clipped()
                .cornerRadius(5)
                .shadow(color: Color.init(UIColor.darkGray), radius: 5, x: 0, y: 5)
            Text(book.title)
                .fontWeight(.ultraLight)
                .frame(width: 150, height: 80)
                .multilineTextAlignment(.center)
                .shadow(radius: 5)
            Text(book.author)
                .fontWeight(.ultraLight)
                .italic()
                .frame(width: 150, height: 80)
                .multilineTextAlignment(.center)
                .shadow(radius: 5)
        }
        .padding(.horizontal)
    }
}

//struct SearchRow_Previews: PreviewProvider {
//    static var previews: some View {
//        VStack {
//            SearchRow(book: FullBook(fromBook: bookData[8].toBook()))
//            SearchRow(book: FullBook(fromBook: bookData[9].toBook()))
//            SearchRow(book: FullBook(fromBook: bookData[33].toBook()))
//        }
//    }
//}
