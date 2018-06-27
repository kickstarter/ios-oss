@testable import Kickstarter_Framework
@testable import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit
import PlaygroundSupport

let loggedOut: User? = nil
let loggedIn = User.brando
let member = User.brando |> User.lens.stats.memberProjectsCount .~ 1

//: Set the currentUser value to one of the states below.

let currentUser = loggedOut
//let currentUser = loggedIn
//let currentUser = member

initialize()
AppEnvironment.replaceCurrentEnvironment(currentUser: currentUser, mainBundle: Bundle.framework)

let controller = Storyboard.Main.instantiate(RootTabBarViewController.self)

let (parent, _) = playgroundControllers(device: .phone4inch, orientation: .portrait, child: controller)
let frame = parent.view.frame
PlaygroundPage.current.liveView = parent

parent.view.frame = frame
