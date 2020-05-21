/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The model for an individual landmark.
*/

import UIKit
import SwiftUI
import Combine
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Book: Codable, Identifiable {
    var author: String
    var country: String
    var language: String
    var link: String
    var title: String
    var year: Int
    @DocumentID var id: String?
    var added: Int
    var isLiked: Bool
    var pages: Int
    var imageName : String
}

struct FullBook {
    var title: String
    var author: String
    var country: String
    var language: String
    var link: String
    var pages: Int
    var year: Int
    var added: Int
    var image: UIImage?
    var search: String!
    
    init() {
        title = "None"
        author = "None"
        country = "None"
        language = "None"
        link = "None"
        pages = 0
        year = 0
        added = 0
        image = UIImage(named: "Unavailable.jpg")
        search = "Unavailable.jpg"
    }
    
    init(andSetAdded book: FullBook, added: Int) {
        title = book.title
        author = book.author
        country = book.country
        language = book.language
        link = book.link
        pages = book.pages
        year = book.year
        self.added = added
        if let im = book.image {
            self.image = im
        }
        search = book.search
    }
    
    init(fromBook: Book) {
        title = fromBook.title
        author = fromBook.author
        country = fromBook.country
        language = fromBook.language
        link = fromBook.link
        pages = fromBook.pages
        year = fromBook.year
        added = fromBook.added
        search = fromBook.imageName
    }
    
    init(fromCoreBook: CoreBook) {
        title = fromCoreBook.title ?? ""
        author = fromCoreBook.author ?? ""
        country = fromCoreBook.country ?? ""
        language = fromCoreBook.language ?? ""
        link = fromCoreBook.link ?? ""
        pages = Int(fromCoreBook.pages)
        year = Int(fromCoreBook.year)
        added = Int(fromCoreBook.added)
        if let im = fromCoreBook.image {
            image = UIImage(data: im)
        }
        search = "Loading.jpg" // will not be used
    }
    
    func toBook() -> Book {
        return Book(author: author, country: country, language: language, link: link, title: title, year: year, added: added, isLiked: false, pages: pages, imageName: title)
    }
    
    func getImage() -> UIImage {
        if let im = self.image {
            return im
        } else {
            return UIImage(named: "Unavailable.jpg")!
        }
    }
}

struct RawBook: Codable, Identifiable {
    var author: String
    var country: String
    var language: String
    var link: String
    var pages: Int
    var title: String
    var year: Int
    var id: String?
    var added: Int
    // not used
    var isLiked: Bool

    var imageName : String
    
    func toBook() -> Book {
        return Book(author: author, country: country, language: language, link: link, title: title, year: year, id: id, added: added, isLiked: isLiked, pages: pages, imageName: imageName)
    }
}

struct OnePass: Codable {
    var title: String
    var author: String
    var country: String
    var language: String
    var year: String
    var pages: Int
    var link: String
    
    func toBook() -> Book {
        return Book(author: author, country: country, language: language, link: link, title: title, year: Int(year)!, added: 0, isLiked: false, pages: pages, imageName: title)
    }
}


