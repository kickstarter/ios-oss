@testable import Kickstarter_Framework
@testable import KsApi
import Library
import PlaygroundSupport
import Prelude
import Prelude_UIKit
import UIKit

let w = 80

let draft = .blank
  |> UpdateDraft.lens.update.title .~ "Lorem ipsum"
  |> UpdateDraft.lens.update.body .~ "Dolor sit amet!"
  |> UpdateDraft.lens.images .~ (0..<10).map { _ in
    .template |> UpdateDraft.Image.lens.thumb .~ "http://lorempixel.com/\(w)/\(w)/abstract"
  }

AppEnvironment.replaceCurrentEnvironment(
  apiService: MockService(
    oauthToken: OauthToken(token: "deadbeef"),
    fetchDraftResponse: draft
  ),
  //  language: .es, locale: Locale(identifier: "es"),
  currentUser: Project.cosmicSurgery.creator,
  mainBundle: Bundle.framework
)

initialize()
let controller = UpdateDraftViewController.configuredWith(project: .template)

PlaygroundPage.current.liveView = controller
