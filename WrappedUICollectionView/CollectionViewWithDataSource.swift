//
//  CollectionViewWithDataSource.swift
//  WrappedUICollectionView
//
//  Created by 春山泰成 on 2023/10/12.
//

import SwiftUI

final class CollectionViewWithDataSource<SectionIdentifierType, ItemIdentifierType>: UICollectionView where
SectionIdentifierType: Hashable & Sendable,
ItemIdentifierType: Hashable & Sendable {
    
    typealias DataSource = UICollectionViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>
    typealias Snapshot = NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>
    
    private let cellProvider: DataSource.CellProvider
    
    private let updateQueue: DispatchQueue = DispatchQueue(
        label: "com.collectionview.update",
        qos: .userInteractive)
    
    private lazy var collectionDataSource: DataSource = {
        DataSource(
            collectionView: self,
            cellProvider: cellProvider
        )
    }()
    
    private var indexPathForLastItem: IndexPath? {
      guard numberOfSections > 0 else { return nil }

      for offset in 1 ... numberOfSections {
        let section = numberOfSections - offset
        let lastItem = numberOfItems(inSection: section) - 1
        if lastItem >= 0 {
          return IndexPath(item: lastItem, section: section)
        }
      }
      return nil
    }
    
    init(frame: CGRect,
         collectionViewLayout: UICollectionViewLayout,
         collectionViewConfiguration: ((UICollectionView) -> Void),
         cellProvider: @escaping DataSource.CellProvider,
         supplementaryViewProvider: DataSource.SupplementaryViewProvider?) {
        
        self.cellProvider = cellProvider
        super.init(frame: frame, collectionViewLayout: collectionViewLayout)
        collectionViewConfiguration(self)
        print(self.allowsSelection)
        self.allowsSelection = true
        
        collectionDataSource.supplementaryViewProvider = supplementaryViewProvider
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func apply(_ snapshot: Snapshot,
               animatingDifferences: Bool = true,
               completion: (() -> Void)? = nil) {
        
        updateQueue.async { [weak self] in
            self?.collectionDataSource.apply(
                snapshot,
                animatingDifferences: animatingDifferences,
                completion: completion
            )
        }
    }
    
    public func scrollToLastItem(at pos: UICollectionView.ScrollPosition = .bottom, animated: Bool = true) {
      guard let indexPath = indexPathForLastItem else { return }

      scrollToItem(at: indexPath, at: pos, animated: animated)
    }

}
