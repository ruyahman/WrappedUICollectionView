//
//  InputTextView.swift
//  WrappedUICollectionView
//
//  Created by 春山泰成 on 2023/10/16.
//
import Foundation
import UIKit

public struct ComposerConfig {

    public var inputViewMinHeight: CGFloat
    public var inputViewMaxHeight: CGFloat
    public var inputViewCornerRadius: CGFloat
    public var inputFont: UIFont
    public var adjustMessageOnSend: (String) -> (String)
    public var adjustMessageOnRead: (String) -> (String)

    public init(
        inputViewMinHeight: CGFloat = 38,
        inputViewMaxHeight: CGFloat = 76,
        inputViewCornerRadius: CGFloat = 20,
        inputFont: UIFont = UIFont.preferredFont(forTextStyle: .body),
        adjustMessageOnSend: @escaping (String) -> (String) = { $0 },
        adjustMessageOnRead: @escaping (String) -> (String) = { $0 }
    ) {
        self.inputViewMinHeight = inputViewMinHeight
        self.inputViewMaxHeight = inputViewMaxHeight
        self.inputViewCornerRadius = inputViewCornerRadius
        self.inputFont = inputFont
        self.adjustMessageOnSend = adjustMessageOnSend
        self.adjustMessageOnRead = adjustMessageOnRead
    }
}

struct TextSizeConstants {
    static let composerConfig = ComposerConfig()
    static let defaultInputViewHeight: CGFloat = 38.0
    static var minimumHeight: CGFloat {
        composerConfig.inputViewMinHeight
    }

    static var maximumHeight: CGFloat {
        composerConfig.inputViewMaxHeight
    }

    static var minThreshold: CGFloat {
        composerConfig.inputViewMinHeight
    }

    static var cornerRadius: CGFloat {
        composerConfig.inputViewCornerRadius
    }
}

class InputTextView: UITextView {

    /// Label used as placeholder for textView when it's empty.
    open private(set) lazy var placeholderLabel: UILabel = UILabel().withoutAutoresizingMaskConstraints

    /// The minimum height of the text view.
    /// When there is no content in the text view OR the height of the content is less than this value,
    /// the text view will be of this height
    open var minimumHeight: CGFloat {
        TextSizeConstants.minimumHeight
    }

    /// The maximum height of the text view.
    /// When the content in the text view is greater than this height, scrolling will be enabled and the text view's height will be restricted to this value
    open var maximumHeight: CGFloat {
        TextSizeConstants.maximumHeight
    }

    override open var text: String! {
        didSet {
            if !oldValue.isEmpty && text.isEmpty {
                textDidChangeProgrammatically()
            }
        }
    }

    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard superview != nil else { return }

        setUp()
        setUpLayout()
        setUpAppearance()
    }

    open func setUp() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTextChange),
            name: UITextView.textDidChangeNotification,
            object: self
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(becomeFirstResponder),
            name: NSNotification.Name(getStreamFirstResponderNotification),
            object: nil
        )
    }

    open func setUpAppearance() {
        backgroundColor = .clear
        textContainer.lineFragmentPadding = 8
        //font = SiteCustomUIFont.bold(size: 14)
        textColor = .black
        textAlignment = .natural

        placeholderLabel.font = font
        placeholderLabel.textAlignment = .center
        //placeholderLabel.textColor = CommonColor.gray()
    }

    open func setUpLayout() {
        isScrollEnabled = true
    }

    /// Sets the given text in the current caret position.
    /// In case the caret is selecting a range of text, it replaces that text.
    ///
    /// - Parameter text: A string to replace the text in the caret position.
    open func replaceSelectedText(_ text: String) {
        guard let selectedRange = selectedTextRange else {
            self.text.append(text)
            return
        }

        replace(selectedRange, withText: text)
    }

    open func textDidChangeProgrammatically() {
        delegate?.textViewDidChange?(self)
        handleTextChange()
    }

    @objc open func handleTextChange() {
        placeholderLabel.isHidden = !text.isEmpty
    }

    open func shouldAnimate(_ newText: String) -> Bool {
        abs(newText.count - text.count) < 10
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if TextSizeConstants.defaultInputViewHeight != minimumHeight
            && minimumHeight == frame.size.height {
            let rect = layoutManager.usedRect(for: textContainer)
            let topInset = (frame.size.height - rect.height) / 2.0
            textContainerInset.top = max(0, topInset)
        }
    }

    override open func paste(_ sender: Any?) {
        super.paste(sender)
        handleTextChange()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            //self?.scrollToBottom()
        }
    }
}
