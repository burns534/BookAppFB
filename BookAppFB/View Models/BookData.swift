//
//  BookData.swift
//  BookAppFB
//
//  Created by Kyle Burns on 5/8/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
import CoreData

var sortDescriptors : [NSSortDescriptor] = [NSSortDescriptor(keyPath: \CoreBook.added, ascending: false)]

class BookData: NSObject, ObservableObject {

    @Published var contextBook : FullBook = FullBook()
    
    @Published var didSort: Bool = false
    
    @Published var editMode: Bool = false
    
    @Published var books : [FullBook] = [FullBook]()
    
    @Published var swap: Bool = false
    
    @Published var sortDescriptors : [NSSortDescriptor] = [NSSortDescriptor(keyPath: \CoreBook.added, ascending: false)]
    
    private var fetchRequest = NSFetchRequest<CoreBook>(entityName: "CoreBook")

}

