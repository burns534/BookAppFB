//
//  SearchBar.swift
//  SwiftUIBook
//
//  Created by Kyle Burns on 5/4/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

/* FIX auto cap by word and case sensitive searching */

struct SearchBar : UIViewRepresentable {
    
    let search = UISearchBar(frame: .zero)
    
    let ref = Firestore.firestore().collection("books")
    
    @ObservedObject var sbvm : SearchBarViewModel
    
    @EnvironmentObject var library : BookData
    
    class Coordinator: NSObject, UISearchBarDelegate {
    
        var parent : SearchBar
        
        init(_ parent: SearchBar) {
            self.parent = parent
        }
        
        func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            searchBar.setShowsCancelButton(true, animated: true)
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            parent.sbvm.recents.removeAll(where: {
                $0.title == searchBar.text!
            })
            if parent.sbvm.recents.count > 8 {
                parent.sbvm.recents.removeFirst()
            }
            // push to recents stack
            parent.sbvm.recents.append(Recent(title: searchBar.text!))
            // manually force didSet to trigger
            parent.sbvm.recents = parent.sbvm.recents
            
            searchBar.endEditing(true)
            searchBar.resignFirstResponder()
            searchBar.setShowsCancelButton(false, animated: true)
        }
        
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            parent.sbvm.text = searchText
            // if searching store
            if ( searchBar.selectedScopeButtonIndex == 1 || parent.sbvm.force ) && searchText.count >= 2 {
                parent.ref
                    .whereField("title", isLessThan: incrementString(searchText))
                    .whereField("title", isGreaterThanOrEqualTo: searchText)
                    .limit(to: 20)
                    .getDocuments { snapshot, error in
                        if let error = error {
                            print("Error: query unsuccessful: \(error.localizedDescription)")
                        } else {
                            if let snapshot = snapshot {
                                self.parent.sbvm.results = snapshot.documents.map { document in
                                    let book = try? document.data(as: Book.self)
                                    return book!
                                }.map { book in
                                    FullBook(fromBook: book)
                                }
                            }
                        }
                    }
            } else if searchBar.selectedScopeButtonIndex == 1 && searchText.count < 2 {
                parent.sbvm.results.removeAll()
            }
        }
        
        func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
            parent.sbvm.scope = selectedScope == 0 ?.library : .store
            parent.sbvm.force.toggle()
            
            // force update results on switch
            if parent.sbvm.scope == Scope.store && parent.sbvm.text.count == 0 {
                parent.sbvm.results.removeAll()
            }
        }
        
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            parent.sbvm.text = ""
            parent.sbvm.results.removeAll()
            searchBar.searchTextField.text = ""
            searchBar.endEditing(true)
            searchBar.resignFirstResponder()
            searchBar.setShowsCancelButton(false, animated: true)
        }
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UISearchBar {
        search.delegate = context.coordinator
        search.searchBarStyle = UISearchBar.Style.minimal
        search.autocapitalizationType = UITextAutocapitalizationType.words
        search.isTranslucent = true
        search.spellCheckingType = UITextSpellCheckingType.yes
        search.placeholder = "Books"
        search.showsScopeBar = true
        search.scopeButtonTitles = ["Library", "Store"]
        let attributes : [NSAttributedString.Key : Any] = [
            .kern: NSNumber(value: 3.0),
            .foregroundColor: UIColor.darkGray.cgColor]
        search.setScopeBarButtonTitleTextAttributes(attributes, for: .normal)
        sbvm.scope = search.selectedScopeButtonIndex == 0 ? .library : .store
        sbvm.force = search.selectedScopeButtonIndex == 0 ? true : false
        return search
    }
    
    func updateUIView(_ uiView: UISearchBar, context: Context) {
        if sbvm.bypass {
            // check if it's valid before updating
            let searchBar = uiView
            // perform search
            ref.whereField("title", isLessThan: incrementString(sbvm.text))
                .whereField("title", isGreaterThan: decrementString(sbvm.text))
            .limit(to: 20)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error: query unsuccessful: \(error.localizedDescription)")
                } else {
                    if let snapshot = snapshot {
                        self.sbvm.results = snapshot.documents.map { document in
                            let book = try? document.data(as: Book.self)
                            return book!
                        }.map { book in
                            FullBook(fromBook: book)
                        }
                        
                        // load page directly if there is a match - doesn't work currently
                        if self.sbvm.results.count == 1 {
                            print("match")
                            self.library.contextBook = self.sbvm.results[0]
                            self.sbvm.push = true
                        }
                    }
                }
            }
            searchBar.searchTextField.text = sbvm.text
            searchBar.endEditing(true)
            searchBar.resignFirstResponder()
            searchBar.setShowsCancelButton(false, animated: true)
            sbvm.bypass.toggle()
        }
        uiView.text = sbvm.text
    }
    
}

