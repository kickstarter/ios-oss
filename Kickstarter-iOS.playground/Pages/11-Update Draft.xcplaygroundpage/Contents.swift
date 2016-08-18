@testable import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit
import XCPlayground
@testable import Kickstarter_Framework

let w = 80

let draft = .blank
  |> UpdateDraft.lens.update.title .~ "Lorem ipsum"
  |> UpdateDraft.lens.update.body .~ "Dolor sit amet!"
  |> UpdateDraft.lens.images .~ (0..<10).map { _ in
    .template |> UpdateDraft.Image.lens.thumb .~ "http://lorempixel.com/\(w)/\(w)/abstract"
}

AppEnvironment.replaceCurrentEnvironment(
  mainBundle: NSBundle.framework,
  apiService: MockService(
    oauthToken: OauthToken(token: "deadbeef"),
    fetchDraftResponse: draft
  ),
//  language: .es, locale: NSLocale(localeIdentifier: "es"),
  currentUser: Project.cosmicSurgery.creator
)

initialize()
let controller = UpdateDraftViewController.configuredWith(project: .template)

XCPlaygroundPage.currentPage.liveView =
//  controller
  UINavigationController(rootViewController: controller)
