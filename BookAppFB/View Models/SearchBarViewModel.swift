//
//  um.swift
//  BookAppFB
//
//  Created by Kyle Burns on 5/16/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import Foundation

enum Scope {
    case library
    case store
}

class SearchBarViewModel: ObservableObject {
    @Published var bypass: Bool = false
    @Published var text: String = ""
    @Published var force: Bool = true
    @Published var results: [FullBook] = [FullBook]()
    @Published var scope : Scope = Scope.library
    @Published var push: Bool = false
    
    @Published var recents: [Recent] = [Recent]() {
        didSet {
            let encoder = JSONEncoder()
            do {
                let encoded = try encoder.encode(recents)
                UserDefaults.standard.set(encoded, forKey: "recents")
            } catch {
                print("Error: could not encoded recents: \(error.localizedDescription)")
            }
        }
    }
    
    init() {
        //UserDefaults.standard.removeObject(forKey: "recents")
        if let encoded = UserDefaults.standard.data(forKey: "recents") {
            let decoder = JSONDecoder()
            do {
                recents = try decoder.decode([Recent].self, from: encoded)
            } catch {
                print("Error: could not decoded recents: \(error.localizedDescription)")
            }
        } else {
            print("Error: key 'recents' does not exist")
        }
    }
}
