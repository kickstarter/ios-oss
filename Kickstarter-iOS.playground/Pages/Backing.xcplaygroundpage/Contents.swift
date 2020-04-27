@testable import Kickstarter_Framework
@testable import KsApi
import Library
import PlaygroundSupport
import Prelude
import Prelude_UIKit
import ReactiveSwift
import UIKit

initialize()
let controller = BackingViewController.configuredWith(project: .template, backer: .template)

// swiftformat:disable wrap
AppEnvironment.login(
  AccessTokenEnvelope(
    accessToken: "cafebeef",
    user: .template
      |> \.avatar.small .~ "https://s-media-cache-ak0.pinimg.com/564x/fd/9a/25/fd9a25f4f454d86cfef6fe75ea9c7129.jpg"
      |> \.name .~ "Darby"
  )
)

AppEnvironment.replaceCurrentEnvironment(
  apiService: MockService(fetchBackingResponse: backing),
  language: .es,
  locale: Locale(identifier: "en"),
  mainBundle: Bundle.framework
)

let reward = .template
  |> Reward.lens.description .~ "- PRINT COPY-  A full color copy of the Far Away comic book, plus a sticker and a Far Away Button. Also includes the pdf and all other digital downloads. "
// swiftformat:enable wrap

let backing = .template
  |> Backing.lens.amount .~ 1_000
  |> Backing.lens.status .~ .canceled
  |> Backing.lens.sequence .~ 1_000
  |> Backing.lens.reward .~ reward

let frame = controller.view.frame
PlaygroundPage.current.liveView = controller
controller.view.frame = frame
