//
//  UIKitContentView.swift
//  WrappedUICollectionView
//
//  Created by 春山泰成 on 2023/10/13.
//

import Foundation
import SwiftUI

struct UIKitContentView: View {
    typealias Item = Int
    typealias Section = Int
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>

    @State var snapshot: Snapshot = {
        var initialSnapshot = Snapshot()
        initialSnapshot.appendSections([0])
        return initialSnapshot
    }()

    var body: some View {

        ZStack(alignment: .bottom) {
            CollectionView(
                snapshot: snapshot,
                collectionViewLayout: collectionViewLayout,
                configuration: collectionViewConfiguration,
                cellProvider: cellProvider,
                supplementaryViewProvider: supplementaryProvider
            )
            .padding()

            Button(
                action: {
                    let itemsCount = snapshot.numberOfItems(inSection: 0)
                    snapshot.appendItems([itemsCount + 1], toSection: 0)
                }, label: {
                    Text("Add More Items")
                }
            )
        }
    }
}


extension UIKitContentView {
    func collectionViewLayout() -> UICollectionViewLayout {
        //UICollectionViewFlowLayout()
        let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical  // 縦方向にスクロール
            layout.itemSize = CGSize(width: 400, height: 100)
            layout.minimumLineSpacing = 10  // アイテム間の縦の間隔
            return layout
    }

    func collectionViewConfiguration(_ collectionView: UICollectionView) {
        collectionView.register(
            UICollectionViewCell.self,
            forCellWithReuseIdentifier: "CellReuseId"
        )

        collectionView.register(
            UICollectionReusableView.self,
            forSupplementaryViewOfKind: "KindOfHeader",
            withReuseIdentifier: "SupplementaryReuseId"
        )
    }

    func cellProvider(_ collectionView: UICollectionView,
                                    indexPath: IndexPath,
                                    item: Item) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "CellReuseId",
            for: indexPath
        )

        cell.backgroundColor = .red
        return cell
    }


    func supplementaryProvider(_ collectionView: UICollectionView,
                                             elementKind: String,
                                             indexPath: IndexPath) -> UICollectionReusableView {

        collectionView.dequeueReusableSupplementaryView(
            ofKind: elementKind,
            withReuseIdentifier: "SupplementaryReuseId",
            for: indexPath
        )
    }
}
