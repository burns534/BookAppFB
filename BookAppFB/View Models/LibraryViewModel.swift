//
//  LibraryViewModel.swift
//  BookAppFB
//
//  Created by Kyle Burns on 5/7/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import Foundation
import Combine

class LibraryViewModel: ObservableObject {
    @Published var collectionVM : CollectionViewModel?
    
    @Published var books = [Book]() {
        didSet {
            print("didSet books LVM. Old: \(oldValue.count), New: \(books.count)")
        }
    }
    @Published var sort : Bool = false
    @Published var text : String = ""
    @Published var search: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init(_ books: [Book]) {
        self.books = books
        
        
        $books.map { books in
            CollectionViewModel(books)
        }
        .assign(to: \.collectionVM, on: self)
        .store(in: &cancellables)
//        books.map { books in
//            CollectionViewModel(books)
//        }
//        .assign(to: \.collectionVM, on: self)
//        .store(in: &cancellables)
        
       // collectionVM = CollectionViewModel()
    }
}
