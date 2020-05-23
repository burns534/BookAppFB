//
//  ContentView.swift
//  SwiftUIBook
//
//  Created by Kyle Burns on 5/3/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import SwiftUI
import CoreData

// make use of callback in collectionview for didSelectItemAt

struct Library: View {
    
    @State var bookIndex : Int = 0
    @State var detailView : Bool = false
    @State var text : String = ""
    @State var showSort : Bool = false
    
    @EnvironmentObject var library : BookData
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: CoreBook.entity(),
                  sortDescriptors: sortDescriptors) var books : FetchedResults<CoreBook>
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Button(action: { self.showSort = true }) {
                            Text("Sort")
                                .kerning(2)
                                .fontWeight(.ultraLight)
                        }
                        .padding(.horizontal)
                        .scaleEffect(1.2)
                        .offset(x: 0, y: 5)
                    .actionSheet(isPresented: $showSort) {
                        ActionSheet(title: Text("Select Criterion"), buttons: [
                            .default(Text("Title")) { self.library.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
                                self.library.didSort = true
                            },
                            .default(Text("Author")) { self.library.sortDescriptors = [NSSortDescriptor(key: "author", ascending: true)]
                                self.library.didSort = true
                            },
                            .default(Text("Recently Added")) { self.library.sortDescriptors = [NSSortDescriptor(key: "added", ascending: false)]
                                self.library.didSort = true
                            },
                            .default(Text("Manual")) { self.library.sortDescriptors = [NSSortDescriptor(key: "layout", ascending: true)]
                                self.library.didSort = true
                            },
                            .cancel()])
                    }
                    Spacer()
                    Text("Library")
                        .font(.title)
                        .kerning(3)
                        .fontWeight(.ultraLight)
                        .frame(width: 120, height: 10, alignment: .center)
                    Spacer()
                    Button(action: {
                        self.library.editMode.toggle()
                        
                    }) {
                        Text(self.library.editMode == false ? "Edit" : "Done")
                            .kerning(2)
                            .fontWeight(.ultraLight)
                    }
                        .scaleEffect(1.2)
                        .padding(.horizontal)
                        .offset(x: 0, y: 5)
                }
                .frame(width: UIScreen.main.bounds.width, height: 20, alignment: .center)
                .offset(x: 0, y: 2)
                .foregroundColor(.olive)
                CollectionView {
                    self.detailView = true
                }
                if self.books.count > 0 {
                    // similar issue that happened before and made me createe the contextBook
                    NavigationLink(destination: BookDetail(
                        book: library.contextBook).environment(\.managedObjectContext, self.moc).environmentObject(self.library),
                        isActive: $detailView,
                        label: { Text("") })
                        .frame(width: 0, height: 0)
                        .clipped()
                }
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
            .onDisappear {
                // prevents issues
                self.library.editMode = false
            }
        }
    }
}

struct Library_Previews: PreviewProvider {
    static var previews: some View {
        //Library().environmentObject(BookData())
        EmptyView()
    }
}
