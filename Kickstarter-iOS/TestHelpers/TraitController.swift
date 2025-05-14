import UIKit

internal enum Device: CaseIterable {
  case phone4inch // iPhone SE
  case phone4_7inch // iPhone 8, 7, 6S
  case phone5_5inch // iPhone 8 Plus, 7 Plus, 6S Plus
  case phone5_8inch // iPhone X
  case pad

  var deviceSize: CGSize {
    switch self {
    case .phone4inch:
      CGSize(width: 320, height: 568)
    case .phone4_7inch:
      CGSize(width: 375, height: 667)
    case .phone5_5inch:
      CGSize(width: 414, height: 736)
    case .phone5_8inch:
      CGSize(width: 375, height: 812)
    case .pad:
      CGSize(width: 768, height: 1_024)
    }
  }

  func deviceSize(in orientation: Orientation) -> CGSize {
    orientation == .landscape ? self.deviceSize.inverted : self.deviceSize
  }
}

internal enum Orientation: CaseIterable {
  case portrait
  case landscape
}

internal func traitControllers(
  device: Device = .phone4_7inch,
  orientation: Orientation = .portrait,
  child: UIViewController = UIViewController(),
  additionalTraits: UITraitCollection = .init(),
  handleAppearanceTransition: Bool = true
)
  -> (parent: UIViewController, child: UIViewController) {
  let parent = UIViewController()
  parent.view.addSubview(child.view)
  parent.addChild(child)
  parent.didMove(toParent: parent)

  child.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

  parent.view.frame = .init(origin: .zero, size: device.deviceSize(in: orientation))

  let traits: UITraitCollection
  switch (device, orientation) {
  case (.phone4inch, .portrait):
    traits = .init(traitsFrom: [
      .init(horizontalSizeClass: .compact),
      .init(verticalSizeClass: .regular),
      .init(userInterfaceIdiom: .phone)
    ])
  case (.phone4inch, .landscape):
    traits = .init(traitsFrom: [
      .init(horizontalSizeClass: .compact),
      .init(verticalSizeClass: .compact),
      .init(userInterfaceIdiom: .phone)
    ])
  case (.phone4_7inch, .portrait):
    traits = .init(traitsFrom: [
      .init(horizontalSizeClass: .compact),
      .init(verticalSizeClass: .regular),
      .init(userInterfaceIdiom: .phone)
    ])
  case (.phone4_7inch, .landscape):
    traits = .init(traitsFrom: [
      .init(horizontalSizeClass: .compact),
      .init(verticalSizeClass: .compact),
      .init(userInterfaceIdiom: .phone)
    ])
  case (.phone5_5inch, .portrait):
    traits = .init(traitsFrom: [
      .init(horizontalSizeClass: .compact),
      .init(verticalSizeClass: .regular),
      .init(userInterfaceIdiom: .phone)
    ])
  case (.phone5_5inch, .landscape):
    traits = .init(traitsFrom: [
      .init(horizontalSizeClass: .regular),
      .init(verticalSizeClass: .compact),
      .init(userInterfaceIdiom: .phone)
    ])
  case (.phone5_8inch, .portrait):
    traits = .init(traitsFrom: [
      .init(horizontalSizeClass: .compact),
      .init(verticalSizeClass: .regular),
      .init(userInterfaceIdiom: .phone)
    ])
  case (.phone5_8inch, .landscape):
    traits = .init(traitsFrom: [
      .init(horizontalSizeClass: .compact),
      .init(verticalSizeClass: .compact),
      .init(userInterfaceIdiom: .phone)
    ])
  case (.pad, .portrait):
    traits = .init(traitsFrom: [
      .init(horizontalSizeClass: .regular),
      .init(verticalSizeClass: .regular),
      .init(userInterfaceIdiom: .pad)
    ])
  case (.pad, .landscape):
    traits = .init(traitsFrom: [
      .init(horizontalSizeClass: .regular),
      .init(verticalSizeClass: .regular),
      .init(userInterfaceIdiom: .pad)
    ])
  }

  child.view.frame = parent.view.frame

  parent.view.backgroundColor = LegacyColors.ksr_white.uiColor()
  child.view.backgroundColor = LegacyColors.ksr_white.uiColor()

  let allTraits = UITraitCollection.init(traitsFrom: [traits, additionalTraits])
  parent.setOverrideTraitCollection(allTraits, forChild: child)

  if handleAppearanceTransition {
    parent.beginAppearanceTransition(true, animated: false)
    parent.endAppearanceTransition()
  }

  return (parent, child)
}

/// Returns a `UIViewController` wrapped with the specified trait environment and containing a given subview.
///
/// This utility is intended for use in snapshot or UI tests. It creates a parent-child controller pair configured
/// with the provided device traits (size, idiom, orientation, etc.), and injects the given subview into the child
/// controller's view, pinned to its layout margins.
///
/// - Parameters:
///   - subview: The `UIView` to embed in the child view controller.
///   - device: The `Device` used to determine trait environment and container size.
///   - orientation: The screen orientation to simulate (portrait or landscape).
/// - Returns: A parent `UIViewController` configured with the specified traits, embedding the subview.
func traitWrappedViewController(
  subview: UIView,
  device: Device,
  orientation: Orientation = .portrait
) -> UIViewController {
  let controller = UIViewController(nibName: nil, bundle: nil)
  let (parent, _) = traitControllers(device: device, orientation: orientation, child: controller)

  controller.view.addSubview(subview)

  NSLayoutConstraint.activate([
    subview.leadingAnchor.constraint(equalTo: controller.view.layoutMarginsGuide.leadingAnchor),
    subview.topAnchor.constraint(equalTo: controller.view.layoutMarginsGuide.topAnchor),
    subview.trailingAnchor.constraint(equalTo: controller.view.layoutMarginsGuide.trailingAnchor),
    subview.bottomAnchor.constraint(equalTo: controller.view.layoutMarginsGuide.bottomAnchor)
  ])

  return parent
}

extension CGSize {
  var inverted: CGSize {
    CGSize(width: self.height, height: self.width)
  }
}
