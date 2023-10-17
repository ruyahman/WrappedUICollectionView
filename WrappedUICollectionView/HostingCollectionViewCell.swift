//
//  HostingCollectionViewCell.swift
//  WrappedUICollectionView
//
//  Created by 春山泰成 on 2023/10/16.
//

import Combine
import SwiftUI
import UIKit

open class HostingCollectionViewCell<Content: SwiftUI.View>: UICollectionViewCell {
    var hostingController: UIHostingController<Content>?
    private var leadingConstraint: NSLayoutConstraint?
    private var trailingConstraint: NSLayoutConstraint?
    private var topConstraint: NSLayoutConstraint?
    private var bottomConstraint: NSLayoutConstraint?

//    open func embed(content: Content, viewController: UIViewController, insets: NSDirectionalEdgeInsets) {
//        if let hostingController {
//            hostingController.rootView = content
//            update(insets: insets)
//        } else {
//            let hostingController = UIHostingController(rootView: content)
//            viewController.addChild(hostingController)
//            contentView.addSubview(hostingController.view)
//            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
//            leadingConstraint = contentView.leadingAnchor.constraint(equalTo: hostingController.view.leadingAnchor, constant: insets.leading)
//            trailingConstraint = contentView.trailingAnchor.constraint(equalTo: hostingController.view.trailingAnchor, constant: -insets.trailing)
//            topConstraint = contentView.topAnchor.constraint(equalTo: hostingController.view.topAnchor, constant: insets.top)
//            bottomConstraint = contentView.bottomAnchor.constraint(equalTo: hostingController.view.bottomAnchor, constant: -insets.bottom)
//            NSLayoutConstraint.activate([
//                leadingConstraint!,
//                trailingConstraint!,
//                topConstraint!,
//                bottomConstraint!
//            
//            ])
//            hostingController.didMove(toParent: viewController)
//            self.hostingController = hostingController
//        }
//        hostingController?.view.invalidateIntrinsicContentSize()
//    }
    
    open func embed(content: Content, insets: NSDirectionalEdgeInsets) {
        if let hostingController {
            hostingController.rootView = content
            update(insets: insets)
        } else {
            let hostingController = UIHostingController(rootView: content)
            //viewController.addChild(hostingController)
            contentView.addSubview(hostingController.view)
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            leadingConstraint = contentView.leadingAnchor.constraint(equalTo: hostingController.view.leadingAnchor, constant: insets.leading)
            trailingConstraint = contentView.trailingAnchor.constraint(equalTo: hostingController.view.trailingAnchor, constant: -insets.trailing)
            topConstraint = contentView.topAnchor.constraint(equalTo: hostingController.view.topAnchor, constant: insets.top)
            bottomConstraint = contentView.bottomAnchor.constraint(equalTo: hostingController.view.bottomAnchor, constant: -insets.bottom)
            NSLayoutConstraint.activate([
                leadingConstraint!,
                trailingConstraint!,
                topConstraint!,
                bottomConstraint!
            
            ])
            //hostingController.didMove(toParent: viewController)
            self.hostingController = hostingController
        }
        hostingController?.view.invalidateIntrinsicContentSize()
    }

    override open func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if newSuperview == nil {
            cleanup()
        }
    }

    public func update(insets: NSDirectionalEdgeInsets) {
        topConstraint?.constant = insets.top
        leadingConstraint?.constant = insets.leading
        trailingConstraint?.constant = -insets.trailing
        bottomConstraint?.constant = -insets.bottom
    }

    public func cleanup() {
        guard let hostingController else {
            return
        }
        hostingController.willMove(toParent: nil)
        hostingController.view.removeFromSuperview()
        hostingController.removeFromParent()
        self.hostingController = nil
        leadingConstraint = nil
        trailingConstraint = nil
        bottomConstraint = nil
        topConstraint = nil
    }
}

