import SwiftUI

extension View {
  /// Applies a glass/liquid glass effect to a view within a shape.
  /// - Parameters:
  ///   - shape: The shape to apply the glass effect within
  ///   - interactive: Whether the effect should be interactive (iOS 26+)
  /// - Returns: A view with the glass effect applied
  @ViewBuilder
  func glassedEffect(in shape: some Shape, interactive: Bool = false) -> some View {
    if #available(iOS 26.0, *) {
      self.glassEffect(interactive ? .regular.interactive() : .regular, in: shape)
    } else {
      self.background {
        shape.glassed()
      }
    }
  }
}

extension Shape {
  /// Creates a glass-like effect fallback for iOS < 26
  fileprivate func glassed() -> some View {
    self
      .fill(.ultraThinMaterial)
      .fill(
        .linearGradient(
          colors: [
            .primary.opacity(0.08),
            .primary.opacity(0.05),
            .primary.opacity(0.01),
            .clear,
            .clear,
            .clear
          ],
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )
      )
      .stroke(.primary.opacity(0.2), lineWidth: 0.7)
  }
}
