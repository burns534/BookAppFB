//
//  ContentViewModel.swift
//  BookAppFB
//
//  Created by Kyle Burns on 5/7/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import Foundation
import Combine

class ContentViewModel: ObservableObject {
    @Published var libraryVM : LibraryViewModel?
    
    @Published var books = [Book]() {
        didSet {
            print("didSet books in cvm: Old: \(oldValue.count), New: \(books.count)")
        }

    }
    
    private var cancellables = Set<AnyCancellable>()
    
    init(_ books : [Book]) {
        self.books = books
        self.$books.map { books in
            LibraryViewModel(books)
        }
        .assign(to: \.libraryVM, on: self)
        .store(in: &cancellables)
        
    }
}
