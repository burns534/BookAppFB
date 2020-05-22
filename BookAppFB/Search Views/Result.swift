//
//  Result.swift
//  BookAppFB
//
//  Created by Kyle Burns on 5/16/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import SwiftUI


struct Result: View {
    var book: FullBook
    
    var body: some View {

            Text(self.book.title)
                .fontWeight(.light)
                .font(.system(size: 25))
                .foregroundColor(.olive)

    }
}
