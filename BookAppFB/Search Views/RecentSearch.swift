//
//  RecentSearch.swift
//  BookAppFB
//
//  Created by Kyle Burns on 5/16/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import SwiftUI

struct RecentSearch: View {
    var recent: Recent
    
    var body: some View {
            Text(recent.title)
                .fontWeight(.light)
                .foregroundColor(.olive)
                .font(.system(size: 25))
                
    }
}


