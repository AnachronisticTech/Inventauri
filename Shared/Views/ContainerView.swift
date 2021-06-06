//
//  ContainerView.swift
//  Inventauri
//
//  Created by Daniel Marriner on 11/05/2021.
//

import SwiftUI

struct ContainerView: View {
    @ObservedObject var item: Item

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Image(systemName: "archivebox.fill")
                    .font(.system(size: 16, weight: .regular))
                    .padding(14)
                    .foregroundColor(.white)
                    .background(Circle().fill(Color.blue))
                Spacer()
                Text("\(item.all.count)")
                    .font(.title)
                    .foregroundColor(Color(.label))
                    .bold()
            }
            Text(item.name)
                .bold()
                .multilineTextAlignment(.center)
                .foregroundColor(Color(.secondaryLabel))
        }
        .padding()
        .background(Color(.systemGray5))
        .cornerRadius(15)
    }
}
