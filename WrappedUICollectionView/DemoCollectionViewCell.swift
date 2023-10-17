//
//  DemoCollectionViewCell.swift
//  WrappedUICollectionView
//
//  Created by 春山泰成 on 2023/10/16.
//

import SwiftUI
import UIKit

struct DemoCollectionViewCell: View {
    var item: Int
    
    var body: some View {
        Text("This is \(item)")
    }
}

#Preview {
    DemoCollectionViewCell(item: 1)
}

final class MDemoViewCollectionViewCell: HostingCollectionViewCell<DemoCollectionViewCell> {}
