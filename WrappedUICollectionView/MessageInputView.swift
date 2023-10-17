//
//  MessageInputView.swift
//  WrappedUICollectionView
//
//  Created by 春山泰成 on 2023/10/16.
//

import Foundation

import SwiftUI
import UIKit

struct MessageInputView: View {
    
    @State private var popupSize: CGFloat = 350
    @State private var composerHeight: CGFloat = 0
    @State private var keyboardShown = false
    @State private var editedMessageWillShow = false
    @State public var needReset = false
    
    @Binding var messageText: NSMutableAttributedString
    @Binding var rangeLocation: Int

    public init(popupSize: CGFloat = 350, composerHeight: CGFloat = 0, keyboardShown: Bool = false, editedMessageWillShow: Bool = false, rangeLocation: Binding<Int>,
                messageText: Binding<NSMutableAttributedString>) {
        self.popupSize = popupSize
        self.composerHeight = composerHeight
        self.keyboardShown = keyboardShown
        self.editedMessageWillShow = editedMessageWillShow
        _messageText = messageText
        _rangeLocation = rangeLocation
    }
    
    var body: some View {
        HStack {
            ComposerInputView(needReset: $needReset, text: $messageText, selectedRangeLocation: $rangeLocation, maxMessageLength: 5000, cooldownDuration: 0, uncommittedTextDidChange: { uncommittedText in
            })
            
            SendMessageButton(enabled: true) {
                print("send")
            }
            .padding(.trailing, 8)
        }
    }
}

public struct ComposerInputView: View {
    
    @Binding var needReset: Bool
    @Binding var text: NSMutableAttributedString
    @Binding var selectedRangeLocation: Int
    var maxMessageLength: Int?
    var cooldownDuration: Int
    var uncommittedTextDidChange: (String) -> Void
    
    @State var textHeight: CGFloat = TextSizeConstants.minimumHeight

    public init(
        needReset: Binding<Bool>,
        text: Binding<NSMutableAttributedString>,
        selectedRangeLocation: Binding<Int>,
        maxMessageLength: Int? = nil,
        cooldownDuration: Int,
        uncommittedTextDidChange: @escaping (String) -> Void
    ) {
        _needReset = needReset
        _text = text
        _selectedRangeLocation = selectedRangeLocation
        self.maxMessageLength = maxMessageLength
        self.cooldownDuration = cooldownDuration
        self.uncommittedTextDidChange = uncommittedTextDidChange
    }

    var textFieldHeight: CGFloat {
        let minHeight: CGFloat = TextSizeConstants.minimumHeight
        let maxHeight: CGFloat = TextSizeConstants.maximumHeight

        if textHeight < minHeight {
            return minHeight
        }

        if textHeight > maxHeight {
            return maxHeight
        }

        return textHeight
    }

    public var body: some View {
        VStack {
            HStack {
                ComposerTextInputView(
                    text: $text,
                    height: $textHeight,
                    selectedRangeLocation: $selectedRangeLocation,
                    uncommittedTextDidChange: uncommittedTextDidChange,
                    placeholder: "input..",
                    editable: !isInCooldown,
                    maxMessageLength: maxMessageLength,
                    currentHeight: textFieldHeight
                )
                .frame(height: textFieldHeight)
            }
            .frame(height: textFieldHeight)
        }
//        .onReceive(_needReset) { reset in
//            if reset {
//                //coordinator?.clearMarkedTextRange() // needResetがtrueの場合、Coordinatorのメソッドを呼び出す
//            }
//        }
        //.padding(.vertical, 8)
        .padding(.leading, 8)
        .background(composerInputBackground)
        .overlay(
            RoundedRectangle(cornerRadius: TextSizeConstants.cornerRadius)
                .stroke(Color.mint)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: TextSizeConstants.cornerRadius)
        )
        .accessibilityIdentifier("ComposerInputView")
    }

    private var composerInputBackground: Color {
        return Color(.white)
    }

    private var isInCooldown: Bool {
        cooldownDuration > 0
    }
}


struct ComposerTextInputView: UIViewRepresentable {
    
    //@Binding var coordinator: Coordinator?

    @Binding var text: NSMutableAttributedString
    @Binding var height: CGFloat
    @Binding var selectedRangeLocation: Int
    var uncommittedTextDidChange: (String) -> Void

    var placeholder: String
    var editable: Bool
    var maxMessageLength: Int?
    var currentHeight: CGFloat

    func makeUIView(context: Context) -> InputTextView {
        let inputTextView: InputTextView
        if #available(iOS 16.0, *) {
            inputTextView = InputTextView(usingTextLayoutManager: false)
        } else {
            inputTextView = InputTextView()
        }
        context.coordinator.textView = inputTextView
        inputTextView.delegate = context.coordinator
        inputTextView.isEditable = editable
        inputTextView.layoutManager.delegate = context.coordinator
        inputTextView.placeholderLabel.text = placeholder
        inputTextView.contentInsetAdjustmentBehavior = .never
        inputTextView.setContentCompressionResistancePriority(.defaultLow + 10, for: .horizontal)
        
        //inputTextView.becomeFirstResponder()

        return inputTextView
    }

    func updateUIView(_ uiView: InputTextView, context: Context) {
        DispatchQueue.main.async {
            //if uiView.markedTextRange == nil {
            var shouldAnimate = false
            print(uiView.attributedText)
            print(text)
            if uiView.attributedText.string != text.string {
                let previousLocation = selectedRangeLocation
                //shouldAnimate = uiView.shouldAnimate(text)
                //uiView.text = text
                print(uiView.attributedText)
                uiView.attributedText = text
                print(text)
                print(uiView.attributedText)
                selectedRangeLocation = previousLocation
            }
            uiView.selectedRange.location = selectedRangeLocation
            uiView.isEditable = editable
            uiView.placeholderLabel.text = placeholder
            uiView.handleTextChange()
            context.coordinator.updateHeight(uiView, shouldAnimate: shouldAnimate)
            if uiView.frame.size.height != currentHeight {
                uiView.frame.size = CGSize(
                    width: uiView.frame.size.width,
                    height: currentHeight
                )
            }
            if uiView.contentSize.height != height {
                uiView.contentSize.height = height
            }
            //}
        }
    }

    func makeCoordinator() -> Coordinator {
//        let coordinator = Coordinator(textInput: self, maxMessageLength: maxMessageLength)
//        _coordinator.wrappedValue = coordinator // SwiftUIにCoordinatorを提供し、外部からアクセスできるようにする
//        return coordinator
        
        Coordinator(textInput: self, maxMessageLength: maxMessageLength)
        //_coordinator.wrappedValue = coordinator
    }

    class Coordinator: NSObject, UITextViewDelegate, NSLayoutManagerDelegate {
        weak var textView: InputTextView?

        var parent: ComposerTextInputView
        var maxMessageLength: Int?

        init(textInput: ComposerTextInputView,
             maxMessageLength: Int?) {
            self.parent = textInput
            self.maxMessageLength = maxMessageLength
        }

        func textViewDidChange(_ textView: UITextView) {

            guard let inputText = textView.attributedText else { return }
            
            let shouldAnimate = false //(textView as? InputTextView)?.shouldAnimate(textInput.text) ?? false
            
            parent.text = NSMutableAttributedString(attributedString: inputText) //textView.text
            parent.selectedRangeLocation = textView.selectedRange.location
            
            updateHeight(textView, shouldAnimate: shouldAnimate)
        }

        func updateHeight(_ textView: UITextView, shouldAnimate: Bool) {
            var height = textView.sizeThatFits(textView.bounds.size).height
            if height < TextSizeConstants.minThreshold {
                height = TextSizeConstants.minimumHeight
            }
            if parent.height != height {
                if shouldAnimate {
                    withAnimation {
                        parent.height = height
                    }
                } else {
                    parent.height = height
                }
            }
        }
        
        func clearMarkedTextRange() {
            textView?.setMarkedText(nil as String?, selectedRange: NSRange(location: 0, length: 0))
        }

        func textViewDidChangeSelection(_ textView: UITextView) {
            parent.selectedRangeLocation = textView.selectedRange.location
        }

        func textView(
            _ textView: UITextView,
            shouldChangeTextIn range: NSRange,
            replacementText text: String
        ) -> Bool {
            if let textPosition = textView.markedTextRange {
                let uncommittedText = textView.text(in: textPosition) ?? ""
                parent.uncommittedTextDidChange(uncommittedText)
            }
            
            guard let maxMessageLength = maxMessageLength else { return true }
            let newMessageLength = textView.text.count + (text.count - range.length)
            return newMessageLength <= maxMessageLength
        }
    }
}

extension UITextView {
    func scrollToBottom() {
        let textCount: Int = text.count
        guard textCount >= 1 else { return }
        scrollRangeToVisible(NSRange(location: textCount - 1, length: 1))
    }
}
