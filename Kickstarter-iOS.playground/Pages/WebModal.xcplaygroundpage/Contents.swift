@testable import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit
import PlaygroundSupport
@testable import Kickstarter_Framework

// Set the initial URL.
let url = URL(string: "https://www.kickstarter.com/privacy")!

initialize()
let request = URLRequest(url: url)
let controller = WebModalViewController.configuredWith(request: request)
controller.bindViewModel()

PlaygroundPage.current.liveView = controller
controller.view
  |> UIView.lens.frame.size.height .~ 1_600
