import UIKit
//import Kickstarter_Framework

public func initialize() {
  // This needs to be called manually in playgrounds.
//  UIView.doBadSwizzleStuff()
//  UIViewController.doBadSwizzleStuff()

  UIView.self.perform(Selector(("doBadSwizzleStuff")), with: nil)
  UIViewController.self.perform(Selector(("doBadSwizzleStuff")), with: nil)
}
