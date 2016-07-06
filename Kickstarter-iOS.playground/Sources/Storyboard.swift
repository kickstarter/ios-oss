import UIKit

public func storyboard(named name: String) -> UIStoryboard {
  // This needs to be called manually in playgrounds.
  UIViewController.initialize()

  return UIStoryboard(name: name, bundle: NSBundle(identifier: "com.Kickstarter-iOS-Framework"))
}
