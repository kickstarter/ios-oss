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

  parent.view.backgroundColor = .ksr_white
  child.view.backgroundColor = .ksr_white

  let allTraits = UITraitCollection.init(traitsFrom: [traits, additionalTraits])
  parent.setOverrideTraitCollection(allTraits, forChild: child)

  if handleAppearanceTransition {
    parent.beginAppearanceTransition(true, animated: false)
    parent.endAppearanceTransition()
  }

  return (parent, child)
}

extension CGSize {
  var inverted: CGSize {
    CGSize(width: self.height, height: self.width)
  }
}
