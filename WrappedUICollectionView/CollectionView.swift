//
//  CollectionView.swift
//  WrappedUICollectionView
//
//  Created by 春山泰成 on 2023/10/12.
//

import UIKit
import SwiftUI

extension CollectionView {
    typealias UIKitCollectionView = CollectionViewWithDataSource<SectionIdentifierType, ItemIdentifierType>
    typealias DataSource =  UICollectionViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>
    typealias Snapshot = NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>
    typealias UpdateCompletion = () -> Void
}

struct CollectionView<SectionIdentifierType, ItemIdentifierType> where
SectionIdentifierType: Hashable & Sendable,
ItemIdentifierType: Hashable & Sendable {
    private let snapshot: Snapshot
    private let configuration: ((UICollectionView) -> Void)
    private let cellProvider: DataSource.CellProvider
    private let supplementaryViewProvider: DataSource.SupplementaryViewProvider?

    private let collectionViewLayout: () -> UICollectionViewLayout

    private(set) var collectionViewDelegate: (() -> UICollectionViewDelegate)?
    private(set) var animatingDifferences: Bool = true
    private(set) var updateCallBack: UpdateCompletion?
    
    private(set) var _collectionView: UICollectionView?

    init(snapshot: Snapshot,
         collectionViewLayout: @escaping () -> UICollectionViewLayout,
         configuration: @escaping ((UICollectionView) -> Void) = { _ in },
         cellProvider: @escaping  DataSource.CellProvider,
         supplementaryViewProvider: DataSource.SupplementaryViewProvider? = nil) {

        self.snapshot = snapshot
        self.configuration = configuration
        self.cellProvider = cellProvider
        self.supplementaryViewProvider = supplementaryViewProvider
        self.collectionViewLayout = collectionViewLayout
    }
}

extension CollectionView: UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> some UIKitCollectionView {
        let collectionView = UIKitCollectionView(frame: .zero, collectionViewLayout: collectionViewLayout(), collectionViewConfiguration: configuration, cellProvider: cellProvider, supplementaryViewProvider: supplementaryViewProvider)
        
//        let delegate = collectionViewDelegate?()
//        collectionView.delegate = collectionViewDelegate?()//delegate
        collectionView.delegate = context.coordinator
        
        //_collectionView = collectionView
        
        return collectionView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
        uiView.apply(snapshot, animatingDifferences: animatingDifferences, completion: nil)
        
        uiView.scrollToLastItem()
//        let delegate = collectionViewDelegate?()
//        uiView.delegate = delegate
    }
}

extension CollectionView {
    func animateDifferences(_ animate: Bool) -> Self {
        var selfCopy = self
        selfCopy.animatingDifferences = animate
        return self
    }
    
    func onUpdate(_ perform: (() -> Void)?) -> Self {
        var selfCopy = self
        selfCopy.updateCallBack = perform
        return self
    }
    
    func collectionViewDelegate(_ makeDelegate: @escaping (() -> UICollectionViewDelegate)) -> Self {
        var selfCopy = self
        selfCopy.collectionViewDelegate = makeDelegate
        return self
    }
}

extension CollectionView {
    class Coordinator: NSObject, UICollectionViewDelegate {
        var parent: CollectionView<SectionIdentifierType, ItemIdentifierType>
        
        init(_ parent: CollectionView<SectionIdentifierType, ItemIdentifierType>) {
            self.parent = parent
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            print("did scroll")
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            print("セルが選択されました: \(indexPath)")
        }
    }
}
