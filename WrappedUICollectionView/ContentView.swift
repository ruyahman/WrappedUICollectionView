//
//  ContentView.swift
//  WrappedUICollectionView
//
//  Created by 春山泰成 on 2023/10/12.
//

import SwiftUI

struct ContentView: View, KeyboardReadable {
    typealias Item = Int
    typealias Section = Int
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>

    @State var snapshot: Snapshot = {
        var initialSnapshot = Snapshot()
        initialSnapshot.appendSections([0])
        return initialSnapshot
    }()
    
    @State var messageText: NSMutableAttributedString = NSMutableAttributedString(string: "")
    @State var rangeLocation: Int = 0
    @State var demoText: String = ""
    
    @State private var keyboardShown = false

    var body: some View {

        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                CollectionView(
                    snapshot: snapshot,
                    collectionViewLayout: collectionViewLayout,
                    cellProvider: cellProviderWithRegistration
                )
                .modifier(HideKeyboardOnTapGesture(shouldAdd: keyboardShown))
                .padding()
                
                Button(
                    action: {
                        let itemsCount = snapshot.numberOfItems(inSection: 0)
                        snapshot.appendItems([itemsCount + 1], toSection: 0)
                    }, label: {
                        Text("Add More Items")
                    }
                )
                MessageInputView(rangeLocation: $rangeLocation, messageText: $messageText)
            }
        }
        .onReceive(keyboardWillChangePublisher, perform: { visible in
            keyboardShown = visible
        })
        .onAppear {
            keyboardShown = true
        }
    }
    
    let cellRegistration2 = UICollectionView.CellRegistration<MDemoViewCollectionViewCell, Item> { cell, _, item in
        cell.embed(content: .init(item: item), insets: .zero)
    }
}


extension ContentView {
    func collectionViewLayout() -> UICollectionViewLayout {
        //UICollectionViewFlowLayout()
        let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical  // 縦方向にスクロール
            layout.itemSize = CGSize(width: 400, height: 100)
            layout.minimumLineSpacing = 10  // アイテム間の縦の間隔
            return layout
    }

    func cellProviderWithRegistration(_ collectionView: UICollectionView,
                                                    indexPath: IndexPath,
                                                    item: Item) -> UICollectionViewCell {
        
        return collectionView.dequeueConfiguredReusableCell(
            using: cellRegistration2,
            for: indexPath,
            item: item
        )
    }
}
