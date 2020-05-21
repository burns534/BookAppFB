//
//  BookRepository.swift
//  BookAppFB
//
//  Created by Kyle Burns on 5/7/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

class BookRepository: ObservableObject {
    let db = Firestore.firestore()
    
    private var timeStamp : Double = 0
    private var imageTimeStamp : Double = 0
       
    @Published var books = [Book]() {
        didSet {
            print("didSet rep books. Old: \(oldValue.count), New: \(books.count)")
            print("Latency: \(Date().timeIntervalSinceReferenceDate - timeStamp)")
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadData()
    }
    func loadData() {
        
        db.collection("books").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.books = querySnapshot!.documents.map { document in
                    let x = try? document.data(as: Book.self)
                    return x!
                    }
//                for book in self.books {
//                    let newTitle = book.imageName
//                    let newImageName = book.title
//                    self.updateField(fields: ["title": newTitle, "imageName": newImageName], book: book)
//                }
            }
        }
        timeStamp = Date().timeIntervalSinceReferenceDate
    }
    
    func addBook(book: Book) {
        do {
            let _ = try db.collection("books").addDocument(from: book)
        }
        catch {
            fatalError("Failed to encode book: \(error.localizedDescription)")
        }

        print("Book \(book.title) successfully added")
    }
    
    func updateField(fields: [String : Any], book: Book) {
        if let document = book.id {
            db.collection("books").document(document).updateData(fields){ error in
                if let error = error {
                    print("Error updating fields \(fields) for book \(book.title): \(error.localizedDescription)")
                }
            }
        } else {
            print("document had nil id")
        }
    }
    
    func loadFromArray(_ books: [Book]) {
        for i in 0..<books.count {
            let x = books[i]
            addBook(book: Book(author: x.author, country: x.country, language: x.language, link: x.link, title: x.title, year: x.year, added: x.added, isLiked: x.isLiked, pages: x.pages, imageName: x.imageName))
        }
    }
    
    func testAddBook() {
        addBook(book: Book(author: "JR Tolkein", country: "United States", language: "English", link: "none", title: "The Hobbit", year: 1954, added: 0, isLiked: true, pages: 530, imageName: "King Lear"))
    }
    
    func testUpdateField() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            assert(self.books.count > 0)
            print(self.books[0].title)
            self.updateField(fields: ["added": 32], book: self.books[0])
        }
    }
}
