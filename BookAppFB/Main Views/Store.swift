//
//  Store.swift
//  BookAppFB
//
//  Created by Kyle Burns on 5/9/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import SwiftUI

struct Store: View {
    var body: some View {
        Text("Welcome to the Store.")
            .fontWeight(.ultraLight)
            .font(.system(size: 40))
            .foregroundColor(.olive)
    }
}

struct Store_Previews: PreviewProvider {
    static var previews: some View {
        Store()
    }
}
