//
//  CollectionViewModel.swift
//  BookAppFB
//
//  Created by Kyle Burns on 5/7/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import Foundation
import Combine

class CollectionViewModel: ObservableObject {
    
    @Published var bookIndex: Int = 0
    @Published var showDetailView: Bool = false
    @Published var books = [Book]() {
        didSet {
            print("didSet books CollectionVM. Old: \(oldValue.count), New: \(books.count)")
        }
    }
    
    init(_ books: [Book]) {
        self.books = books
    }
}
