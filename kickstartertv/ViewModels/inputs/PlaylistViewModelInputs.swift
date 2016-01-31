import CoreGraphics

internal protocol PlaylistViewModelInputs {
  /// Call when a pan gesture ends with the distance the gesture traveled
  func swipeEnded(translation translation: CGPoint)
}
