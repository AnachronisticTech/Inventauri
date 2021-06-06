//
//  ItemView.swift
//  Inventauri
//
//  Created by Daniel Marriner on 11/05/2021.
//

import SwiftUI

struct ItemView: View {
    @ObservedObject var item: Item
    private var showingPath: Bool

    init(item: Item, showingPath: Bool = false) {
        self.item = item
        self.showingPath = showingPath
    }

    var body: some View {
        HStack {
            if let imageData = item.image, let uiImage = UIImage(data: imageData) {
                ZStack(alignment: .bottomLeading) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 70, height: 70, alignment: .leading)
                        .clipped()
                    Image(systemName: "flag.fill")
                        .font(.system(size: 8, weight: .regular))
                        .padding(4)
                        .foregroundColor(.white)
                        .background(Circle().fill(Color.blue))
                        .offset(x: 4, y: -4)
                }
            } else {
                ZStack {
                    Image(systemName: "flag.fill")
                        .font(.system(size: 16, weight: .regular))
                        .padding(14)
                        .foregroundColor(.white)
                        .background(Circle().fill(Color.blue))
                    }
                .padding()
            }
            VStack(alignment: .leading) {
                Text(item.name)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(Color(.label))
                if showingPath {
                    Text(item.pathString)
                        .multilineTextAlignment(.leading)
                        .font(.subheadline)
                        .foregroundColor(Color(.secondaryLabel))
                }
            }
            Spacer()
        }
        .background(Color(.systemGray5))
    }
}
