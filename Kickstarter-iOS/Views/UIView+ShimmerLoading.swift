import Foundation
import Library
import ObjectiveC
import UIKit

private let gradientLayerName = "ksr_shimmer_gradientLayer"

private enum ShimmerConstants {
  enum Locations {
    static let start: [NSNumber] = [-1.0, -0.5, 0.0]
    static let end: [NSNumber] = [1.0, 1.5, 2.0]
  }

  enum Animation {
    static let movingAnimationDuration: CFTimeInterval = 1.25
    static let delayBetweenAnimationLoops: CFTimeInterval = 0.3
  }
}

private struct AssociatedKeys {
  static var isLoading = "isLoading"
  static var shimmersWhenLoading = "shimmersWhenLoading"
  static var shimmerLayers = "shimmerLayers"
}

protocol ShimmerLoading: AnyObject {
  func startLoading()
  func stopLoading()
}

extension UIView {
  var shimmersWhenLoading: Bool {
    get {
      guard let value = objc_getAssociatedObject(self, &AssociatedKeys.shimmersWhenLoading) as? Bool else {
        return false
      }
      return value
    }
    set(newValue) {
      objc_setAssociatedObject(
        self,
        &AssociatedKeys.shimmersWhenLoading,
        newValue,
        objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
      )
    }
  }
}

extension ShimmerLoading where Self: UIView {
  private var isLoading: Bool {
    get {
      guard let value = objc_getAssociatedObject(self, &AssociatedKeys.isLoading) as? Bool else {
        return false
      }
      return value
    }
    set(newValue) {
      objc_setAssociatedObject(
        self, &AssociatedKeys.isLoading, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
      )

      self.updateAnimation()
    }
  }

  private var shimmerLayers: [CAGradientLayer] {
    get {
      guard
        let value = objc_getAssociatedObject(self, &AssociatedKeys.shimmerLayers) as? [CAGradientLayer]
      else { return [] }

      return value
    }
    set(newValue) {
      objc_setAssociatedObject(
        self,
        &AssociatedKeys.shimmerLayers,
        newValue,
        objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
      )
    }
  }

  // MARK: - Accessors

  func startLoading() {
    self.isLoading = true
  }

  func stopLoading() {
    self.isLoading = false
  }

  func layoutGradientLayers() {
    self.layoutIfNeeded()

    self.shimmerLayers.forEach { layer in
      layer.frame = layer.superlayer?.bounds ?? .zero
      layer.setNeedsLayout()
    }
  }

  // MARK: - Shimmer Animation

  private func updateAnimation() {
    guard self.isLoading else {
      self.shimmerLayers.forEach { $0.removeFromSuperlayer() }
      return
    }

    allSubViews(of: self)
      .filter { $0.shimmersWhenLoading }
      .forEach { view in
        let gradientLayer = newGradientLayer(with: view.bounds)
        let animation = newAnimation()
        let animationGroup = newAnimationGroup(with: animation)

        gradientLayer.add(animationGroup, forKey: animation.keyPath)

        view.layer.addSublayer(gradientLayer)
        self.shimmerLayers.append(gradientLayer)
      }
  }
}

private func allSubViews(of view: UIView) -> [UIView] {
  return view.subviews + view.subviews.flatMap(allSubViews(of:))
}

private func newGradientLayer(with frame: CGRect) -> CAGradientLayer {
  let gradientBackgroundColor: CGColor = UIColor(white: 0.85, alpha: 1.0).cgColor
  let gradientMovingColor: CGColor = UIColor(white: 0.75, alpha: 1.0).cgColor

  let gradientLayer = CAGradientLayer()
  gradientLayer.name = gradientLayerName
  gradientLayer.frame = frame
  gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
  gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)

  gradientLayer.colors = [
    gradientBackgroundColor,
    gradientMovingColor,
    gradientBackgroundColor
  ]

  gradientLayer.locations = ShimmerConstants.Locations.start

  return gradientLayer
}

private func newAnimation() -> CABasicAnimation {
  let locationsKeyPath = \CAGradientLayer.locations

  let animation = CABasicAnimation(keyPath: locationsKeyPath._kvcKeyPathString)
  animation.fromValue = ShimmerConstants.Locations.start
  animation.toValue = ShimmerConstants.Locations.end
  animation.duration = ShimmerConstants.Animation.movingAnimationDuration
  animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

  return animation
}

private func newAnimationGroup(with animation: CABasicAnimation) -> CAAnimationGroup {
  let animationGroup = CAAnimationGroup()

  animationGroup.duration = ShimmerConstants.Animation.movingAnimationDuration
    + ShimmerConstants.Animation.delayBetweenAnimationLoops
  animationGroup.animations = [animation]
  animationGroup.repeatCount = .infinity
  animationGroup.beginTime = CACurrentMediaTime()

  return animationGroup
}
