@testable import Kickstarter_Framework
@testable import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit
import XCPlayground

let loggedOut: User? = nil
let loggedIn = User.brando
let member = User.brando |> User.lens.stats.memberProjectsCount .~ 1

//: Set the currentUser value to one of the states below.

let currentUser = loggedOut
//let currentUser = loggedIn
//let currentUser = member

AppEnvironment.replaceCurrentEnvironment(currentUser: currentUser, mainBundle: NSBundle.framework)

initialize()
let controller = Storyboard.Main.instantiate(RootTabBarViewController)

let (parent, _) = playgroundControllers(device: .phone4_7inch, orientation: .portrait, child: controller)
let frame = parent.view.frame
XCPlaygroundPage.currentPage.liveView = parent
parent.view.frame = frame
