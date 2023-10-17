//
//  UIViewExtention.swift
//  WrappedUICollectionView
//
//  Created by 春山泰成 on 2023/10/16.
//

import UIKit

// layout
extension UIView {
    @discardableResult
    func pinToParent(padding: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        pinTo(to: self.superview, padding: padding)
    }

    @discardableResult
    func pinTo(to view: UIView?, padding: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        guard let pinToView = view else { return [] }
        let constraints = [
            topAnchor.constraint(equalTo: pinToView.topAnchor, constant: padding.top),
            leadingAnchor.constraint(equalTo: pinToView.leadingAnchor, constant: padding.left),
            trailingAnchor.constraint(equalTo: pinToView.trailingAnchor, constant: -padding.right),
            bottomAnchor.constraint(equalTo: pinToView.bottomAnchor, constant: -padding.bottom),
        ]
        NSLayoutConstraint.activate(constraints)
        return constraints
    }
    
    func embed(_ subview: UIView, insets: NSDirectionalEdgeInsets = .zero) {
        addSubview(subview)
        
        let constraints = [
            topAnchor.constraint(equalTo: self.topAnchor, constant: insets.top),
            leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: insets.leading),
            trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -insets.trailing),
            bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -insets.bottom),
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    func centerXInParent() {
        if let superViewCenterXAnchor = superview?.centerXAnchor {
            centerXAnchor.constraint(equalTo: superViewCenterXAnchor).isActive = true
        }
    }
    
    func centerYInParent() {
        if let centerY = superview?.centerYAnchor {
            centerYAnchor.constraint(equalTo: centerY).isActive = true
        }
    }

    func constrainWidth(constant: CGFloat) {
        widthAnchor.constraint(equalToConstant: constant).isActive = true
    }

    func constrainHeight(constant: CGFloat) {
        heightAnchor.constraint(equalToConstant: constant).isActive = true
    }
    
    var withoutAutoresizingMaskConstraints: Self {
        translatesAutoresizingMaskIntoConstraints = false
        return self
    }

    var isVisible: Bool {
        get { !isHidden }
        set { isHidden = !newValue }
    }
    
}

// safeArea
extension UIView {
    func hasBottomSafeArea() -> Bool {
        print(safeAreaInsets)
        return safeAreaInsets.bottom > 0
    }
}

