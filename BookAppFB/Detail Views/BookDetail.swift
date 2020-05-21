//
//  BookDetail.swift
//  SwiftUIBook
//
//  Created by Kyle Burns on 5/3/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import SwiftUI
import CoreData
import Combine

struct BookDetail: View {

    var book : FullBook
    
    @State var contains : Bool = true
    
    @State var image : UIImage = UIImage()
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
                VStack {
                    Image(uiImage: book.getImage())
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 300, height: 480)
                        .cornerRadius(10)
                        .clipped()
                        .padding(.vertical)
                        .shadow(color: .gray, radius: 15, x: 0, y: 15)
                    VStack {
                        Text(self.book.title)
                            .font(.title)
                            .fontWeight(.thin)
                            .shadow(radius: 5)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .offset(y: 8)
                        Divider()
                            .frame(width: 100)
                        Text(self.book.author)
                            .font(.system(size: 20))
                            .fontWeight(.ultraLight)
                        }
                    StoreRow(book: self.book)
                        .padding(.horizontal)
                        .frame(width: UIScreen.main.bounds.width)
                    HyperLink(link: self.book.link, cover: "View on Wikipedia")
                        .frame(width: 108, height: 30, alignment: .center)
                    Spacer()
                }
                .frame(width: UIScreen.main.bounds.width)
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .foregroundColor(.olive)
    }
}

struct BookDetail_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
