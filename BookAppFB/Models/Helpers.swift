//
//  Helpers.swift
//  BookAppFB
//
//  Created by Kyle Burns on 5/16/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import SwiftUI
import FirebaseStorage
import CoreData

extension Color {
    static let olive = Color(red: 0.231, green: 0.290, blue: 0.125)
}
extension UIColor {
    static let olive = UIColor(red: 0.231, green: 0.290, blue: 0.125, alpha: 1.0)
}
extension UIColor {
    static let lightOlive = UIColor(red: 165.0 / 255, green: 181.0 / 255, blue: 134.0 / 255, alpha: 1.0)
}
extension UIColor {
    static let darkWhite = UIColor(white: 0.95, alpha: 1.0)
}

func sort(_ a: Book, _ b: Book,_ by: String) -> (Bool) {
    switch by {
    case "author":
        return a.author < b.author
    case "recently added":
        return a.added > b.added
    default: // title
        return a.title < b.title
    }
}

func filterContain(_ book: CoreBook, _ text: String) -> (Bool) {
    return ( book.title!.lowercased().contains(text.lowercased()) || book.author!.lowercased().contains(text.lowercased()) )
}

func imageFromString(for title: String, completion: @escaping (UIImage?, Error?) -> ()){
    let imageRef = Storage.storage().reference(forURL: "gs://firestoretutorial-ecc5d.appspot.com/images/" + title + ".jpg")
    imageRef.getData(maxSize: 8 * 1024 * 1024) { data, error in
        if let error = error {
            print("Error: imageFromString: could not load image from firebase storage: \(error.localizedDescription)")
            return
        }
        completion(UIImage(data: data!), error)
    }
}

func makeCoreBook(_ book: FullBook, context: NSManagedObjectContext, layout: Int) -> (CoreBook) {
    let newBook = CoreBook(context: context)
    newBook.title = book.title
    newBook.author = book.author
    newBook.added = Int16(book.added)
    newBook.country = book.country
    newBook.language = book.language
    newBook.link = book.link
    newBook.pages = Int16(book.pages)
    newBook.year = Int16(book.year)
    if let im = book.image {
        newBook.image = im.jpegData(compressionQuality: 0.7)
    }
    newBook.layout = Int16(layout)
    return newBook
}


func CoreToBook(_ x: CoreBook) -> (Book) {
    return Book(author: x.author!, country: x.country!, language: x.language!, link: x.link!, title: x.title!, year: Int(x.year), id: x.id!, added: Int(x.added), isLiked: false, pages: Int(x.pages), imageName: x.title!)
}

func incrementString(_ string: String) -> String {
    let char = string.last!.asciiValue! + 1
    return String(string.dropLast(1) + String(UnicodeScalar(char)))
}

func decrementString(_ string: String) -> String {
    let char = string.last!.asciiValue! - 1
    return String(string.dropLast(1) + String(UnicodeScalar(char)))
}
//
//extension NSLayoutConstraint {
//    override public var description: String {
//        let id = identifier ?? ""
//        return "Name: \(id), value: \(constant)"
//    }
//}
