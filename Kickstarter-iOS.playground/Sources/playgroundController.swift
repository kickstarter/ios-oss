import UIKit

// swiftlint:disable function_body_length

public enum Device {
  case phone4inch
  case phone4_7inch
  case phone5_5inch
  case pad
}

public enum Orientation {
  case portrait
  case landscape
}

/**
 Creates a controller that represents a specific device, orientation with specific traits.

 - parameter device:           The device the controller should represent.
 - parameter orientation:      The orientation of the device.
 - parameter child:            An optional controller to put inside the parent controller. If omitted
 a blank controller will be used.
 - parameter additionalTraits: An optional set of traits that will also be applied. Traits in this collection
 will trump any traits derived from the device/orientation comboe specified.

 - returns: Two controllers: a root controller that can be set to the playground's live view, and a content
 controller which should have UI elements added to it
 */
public func playgroundControllers(device: Device = .phone4_7inch,
                                  orientation: Orientation = .portrait,
                                  child: UIViewController = UIViewController(),
                                  additionalTraits: UITraitCollection = .init())
  -> (parent: UIViewController, child: UIViewController) {

    let parent = UIViewController()
    parent.addChildViewController(child)
    parent.view.addSubview(child.view)

    child.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

    let traits: UITraitCollection
    switch (device, orientation) {
    case (.phone4inch, .portrait):
      parent.view.frame = .init(x: 0, y: 0, width: 320, height: 575)
      traits = .init(traitsFrom: [
        .init(horizontalSizeClass: .compact),
        .init(verticalSizeClass: .regular),
        .init(userInterfaceIdiom: .phone)
        ])
    case (.phone4inch, .landscape):
      parent.view.frame = .init(x: 0, y: 0, width: 575, height: 320)
      traits = .init(traitsFrom: [
        .init(horizontalSizeClass: .compact),
        .init(verticalSizeClass: .compact),
        .init(userInterfaceIdiom: .phone)
        ])
    case (.phone4_7inch, .portrait):
      parent.view.frame = .init(x: 0, y: 0, width: 375, height: 667)
      traits = .init(traitsFrom: [
        .init(horizontalSizeClass: .compact),
        .init(verticalSizeClass: .regular),
        .init(userInterfaceIdiom: .phone)
        ])
    case (.phone4_7inch, .landscape):
      parent.view.frame = .init(x: 0, y: 0, width: 667, height: 375)
      traits = .init(traitsFrom: [
        .init(horizontalSizeClass: .compact),
        .init(verticalSizeClass: .compact),
        .init(userInterfaceIdiom: .phone)
        ])
    case (.phone5_5inch, .portrait):
      parent.view.frame = .init(x: 0, y: 0, width: 414, height: 736)
      traits = .init(traitsFrom: [
        .init(horizontalSizeClass: .compact),
        .init(verticalSizeClass: .regular),
        .init(userInterfaceIdiom: .phone)
        ])
    case (.phone5_5inch, .landscape):
      parent.view.frame = .init(x: 0, y: 0, width: 736, height: 414)
      traits = .init(traitsFrom: [
        .init(horizontalSizeClass: .regular),
        .init(verticalSizeClass: .compact),
        .init(userInterfaceIdiom: .phone)
        ])
    case (.pad, .portrait):
      parent.view.frame = .init(x: 0, y: 0, width: 768, height: 1024)
      traits = .init(traitsFrom: [
        .init(horizontalSizeClass: .regular),
        .init(verticalSizeClass: .regular),
        .init(userInterfaceIdiom: .pad)
        ])
    case (.pad, .landscape):
      parent.view.frame = .init(x: 0, y: 0, width: 1024, height: 768)
      traits = .init(traitsFrom: [
        .init(horizontalSizeClass: .regular),
        .init(verticalSizeClass: .regular),
        .init(userInterfaceIdiom: .pad)
        ])
    }

    child.view.frame = parent.view.frame
    parent.preferredContentSize = parent.view.frame.size
    parent.view.backgroundColor = .white
    child.view.backgroundColor = .white

    let allTraits = UITraitCollection.init(traitsFrom: [traits, additionalTraits])
    parent.setOverrideTraitCollection(allTraits, forChildViewController: child)

    return (parent, child)
}
