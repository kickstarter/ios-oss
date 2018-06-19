import UIKit
import Foundation

import Library

// This needs to be called manually in playgrounds.
public func initialize() {

    UIView.self.perform(Selector(("doBadSwizzleStuff")), with: nil)
    UIViewController.self.perform(Selector(("doBadSwizzleStuff")), with: nil)
}

public func initialize(viewController: UIViewController.Type) {

  //viewController.view.perform(Selector(("doBadSwizzleStuff")), with: nil)
  viewController.doBadSwizzleStuff()
}
