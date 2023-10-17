//
//  SendMessageButton.swift
//  WrappedUICollectionView
//
//  Created by 春山泰成 on 2023/10/16.
//

import SwiftUI

public struct SendMessageButton: View {
    
    var enabled: Bool
    var onTap: () -> Void
    
    public init(enabled: Bool, onTap: @escaping () -> Void) {
        self.enabled = enabled
        self.onTap = onTap
    }
    
    public var body: some View {
        Button {
            onTap()
        } label: {
            Image(systemName: "arrow.forward.square.fill")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
        }
        .disabled(!enabled)
    }
}

struct SendMessageButton_Previews: PreviewProvider {
    static var previews: some View {
        SendMessageButton(enabled: true, onTap: { print("tapped!") })
    }
}
