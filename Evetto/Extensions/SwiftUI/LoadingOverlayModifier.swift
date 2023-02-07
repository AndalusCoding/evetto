import SwiftUI

extension View {
    
    @ViewBuilder
    func displayLoadingOverlay(
        _ flag: Bool,
        alpha: CGFloat = 0
    ) -> some View {
        if flag {
            self
                .opacity(alpha)
                .overlay(
                    ProgressView()
                        .progressViewStyle(.circular)
                )
        } else {
            self
        }
    }
    
}
