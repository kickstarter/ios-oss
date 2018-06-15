@testable import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit
import PlaygroundSupport
@testable import Kickstarter_Framework

let backer = User.brando

let creator = .template
  |> User.lens.id .~ 808
  |> User.lens.name .~ "Native Squad"

let project = .template
  |> Project.lens.creator .~ creator
  |> Project.lens.personalization.isBacking .~ false

let backerComment = .template
  |> Comment.lens.author .~ backer
  |> Comment.lens.body .~ "I have never seen such a beautiful project."

let creatorComment = .template
  |> Comment.lens.author .~ creator
  |> Comment.lens.body .~ "Thank you kindly for your feedback!"

let deletedComment = .template
  |> Comment.lens.author .~ (.template |> User.lens.name .~ "Naughty Blob")
  |> Comment.lens.body .~ "This comment has been deleted by Kickstarter."
  |> Comment.lens.deletedAt .~ NSDate().timeIntervalSince1970

let comments = [Comment.template, backerComment, creatorComment, deletedComment]

// Set the current app environment.
AppEnvironment.replaceCurrentEnvironment(
  apiService: MockService(
    fetchCommentsResponse: []
  ),
  currentUser: backer,
  language: .en,
  locale: Locale(identifier: "en"),
  mainBundle: Bundle.framework
)

// Initialize the view controller.
//initialize()
let controller = CommentsViewController.configuredWith(project: project)

let (parent, _) = playgroundControllers(device: .phone4inch, orientation: .portrait, child: controller)

let frame = parent.view.frame
parent.view.frame = frame
PlaygroundPage.current.liveView = parent
