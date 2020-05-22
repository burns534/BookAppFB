//
//  StorePage.swift
//  SwiftUIBook
//
//  Created by Kyle Burns on 5/5/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import SwiftUI
import CoreData

struct StorePage: View {
    @EnvironmentObject var library : BookData
    @Environment(\.presentationMode) var presentationMode : Binding<PresentationMode>
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: CoreBook.entity(), sortDescriptors: []) var books: FetchedResults<CoreBook>
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
                VStack {
                    Image(uiImage: library.contextBook.getImage())
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 300, height: 480)
                        .cornerRadius(10)
                        .clipped()
                        .padding(.vertical)
                        .shadow(color: .gray, radius: 15, x: 0, y: 15)
                    VStack {
                        Text(self.library.contextBook.title)
                            .font(.title)
                            .fontWeight(.thin)
                            .shadow(radius: 5)
                            .multilineTextAlignment(.center)
                            .offset(y: 8)
                        Divider()
                            .frame(width: 100)
                        Text(self.library.contextBook.author)
                            .font(.system(size: 20))
                            .fontWeight(.ultraLight)
                            .multilineTextAlignment(.center)
                        }
                    if !self.books.contains(where: { $0.title == self.library.contextBook.title }) {
                        Button(action: {
                            let newBook = makeCoreBook(FullBook(andSetAdded: self.library.contextBook, added: self.books.count), context: self.moc, layout: self.books.count)
                            
                            print("Added title \(newBook.title!) with added \(newBook.added) and layout \(newBook.layout)")
                            
                            do {
                                try self.moc.save()
                            } catch {
                                print("Error: Could not save book to persistant storage: \(error.localizedDescription)")
                            }
                        }) {
                                HStack {
                                    Image(systemName: "plus")
                                        .scaleEffect(1.2)
                                    Text("Add to Library")
                                    .bold()
                                    .offset(x: -2, y: -2)
                                }
                                .frame(width: 100, height: 50)
                                .foregroundColor(.olive)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                        .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color.olive, lineWidth: 2))
                            .padding()
                    } else {
                        Button(action : {
                            if let book = self.books.first(where: {
                                $0.title == self.library.contextBook.title }) {
                                //print("deleting title \(book.title!)")
                                let added = book.added
                                let layout = book.layout
                                self.moc.delete(book)
                                do {
                                    try self.moc.save()
                                } catch {
                                    print("Error: could not delete book \(book.title ?? "") from persistant storage: \(error.localizedDescription)")
                                }
                                for i in self.books {
                                    if i.added < added {
                                        i.setValue(i.added - 1, forKey: "added")
                                        //print("decreased added for title \(i.title!) from \(i.added + 1) to \(i.added)")
                                    }
                                    if i.layout > layout {
                                        i.setValue(i.layout - 1, forKey: "layout")
                                        //print("decreased layout for title \(i.title!) from \(i.layout + 1) to \(i.layout)")
                                    }
                                }
                                self.presentationMode.wrappedValue.dismiss() // context book was being removed somehow
                            }
                        }) {
                            HStack {
                                Image(systemName: "checkmark")
                                    .scaleEffect(1.2)
                                    .foregroundColor(Color(UIColor.white))
                                Text("Add to Library")
                                    .bold()
                                    .foregroundColor(.white)
                                .offset(x: -1, y: -1)
                            }
                            .frame(width: 100, height: 50)
                            .background(Color.olive)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                        .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color.olive, lineWidth: 2))
                        .padding()
                    }
                    StoreRow(book: library.contextBook)
                        .frame(width: UIScreen.main.bounds.width)
                    HyperLink(link: self.library.contextBook.link, cover: "View on Wikipedia")
                        .frame(width: 108, height: 30, alignment: .center)
                    Spacer()
                }
                .frame(width: UIScreen.main.bounds.width)
                .padding(.horizontal)
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .foregroundColor(.olive)
        .onAppear() {
            imageFromString(for: self.library.contextBook.title) { image, error in
                if let error = error {
                    print("Error: StorePage: Could not load image for title \(self.library.contextBook.title): \(error.localizedDescription)")
                } else {
                    if let im = image {
                        self.library.contextBook.image = im
                    }
                }
            }
        }
        .onDisappear {
            self.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct StorePage_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
