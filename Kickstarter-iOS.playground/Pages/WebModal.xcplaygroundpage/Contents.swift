@testable import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit
import XCPlayground
@testable import Kickstarter_Framework

// Set the initial URL.
let url = NSURL(string: "https://www.kickstarter.com/privacy")!

initialize()
let request = NSURLRequest(URL: url)
let controller = WebModalViewController.configuredWith(request: request)
controller.bindViewModel()

XCPlaygroundPage.currentPage.liveView = controller
controller.view
  |> UIView.lens.frame.size.height .~ 1_600
