@testable import KsApi
import Library
import Prelude
import Prelude_UIKit
import ReactiveCocoa
import UIKit
import XCPlayground
@testable import Kickstarter_Framework

let reward = .template
|> Reward.lens.description .~ "- PRINT COPY-  A full color copy of the Far Away comic book, plus a sticker and a Far Away Button. Also includes the pdf and all other digital downloads. "

let backing = .template
  |> Backing.lens.amount .~ 1_000
  |> Backing.lens.status .~ .canceled
  |> Backing.lens.sequence .~ 1_000
  |> Backing.lens.reward .~ reward

AppEnvironment.login(AccessTokenEnvelope(accessToken: "cafebeef",
  user: .template
    |> User.lens.avatar.small .~ "https://s-media-cache-ak0.pinimg.com/564x/fd/9a/25/fd9a25f4f454d86cfef6fe75ea9c7129.jpg"
    |> User.lens.name .~ "Darby"
  )
)

AppEnvironment.replaceCurrentEnvironment(
  language: .en,
  locale: NSLocale(localeIdentifier: "en"),
  apiService: MockService(fetchBackingResponse: backing),
  mainBundle: NSBundle.framework
)

initialize()
let controller = BackingViewController.configuredWith(project: .template, backer: .template)

XCPlaygroundPage.currentPage.liveView = controller
