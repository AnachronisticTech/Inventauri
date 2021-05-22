//
//  GridHeaderFooter.swift
//  Inventauri
//
//  Created by Daniel Marriner on 23/05/2021.
//

import SwiftUI

struct GridHeader: View {
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedCorners(tl: 15, tr: 15, bl: 0, br: 0)
                .frame(height: 55)
                .foregroundColor(Color(.systemGray5))
            Text("Loose Items")
                .fontWeight(.semibold)
                .padding()
        }
    }
}

struct GridFooter: View {
    var body: some View {
        RoundedCorners(tl: 0, tr: 0, bl: 15, br: 15)
            .frame(height: 30)
            .foregroundColor(Color(.systemGray5))
            .offset(x: 0, y: -1)
    }
}
