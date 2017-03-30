import UIKit

// This needs to be called manually in playgrounds.
public func initialize() {
  UIView.self.perform(Selector(("doBadSwizzleStuff")), with: nil)
  UIViewController.self.perform(Selector(("doBadSwizzleStuff")), with: nil)
}
