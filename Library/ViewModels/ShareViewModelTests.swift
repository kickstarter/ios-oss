@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class ShareViewModelTests: TestCase {
  internal let vm: ShareViewModelType = ShareViewModel()

  fileprivate let showShareSheet = TestObserver<(UIActivityViewController, UIView?), Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.showShareSheet.observe(self.showShareSheet.observer)
  }

  func testShowShareSheet_Discovery() {
    let project = .template |> Project.lens.id .~ 30
    let newProject = .template |> Project.lens.id .~ 55
    let view = UIView()

    self.vm.inputs.configureWith(shareContext: .discovery(project), shareContextView: view)
    self.vm.inputs.shareButtonTapped()
    self.vm.inputs.configureWith(shareContext: .discovery(newProject), shareContextView: view)

    self.showShareSheet.assertValueCount(1)
    XCTAssertEqual(["Showed Share Sheet", "Project Show Share Sheet"], self.trackingClient.events)
  }

  func testShowShareSheet_Project() {
    self.vm.inputs.configureWith(shareContext: .project(.template), shareContextView: nil)
    self.vm.inputs.shareButtonTapped()

    self.showShareSheet.assertValueCount(1)
  }

  func testShowShareSheet_Thanks() {
    self.vm.inputs.configureWith(shareContext: .thanks(.template), shareContextView: nil)
    self.vm.inputs.shareButtonTapped()

    self.showShareSheet.assertValueCount(1)
  }

  func testShowShareSheet_CreatorDashboard() {
    self.vm.inputs.configureWith(shareContext: .creatorDashboard(.template), shareContextView: nil)
    self.vm.inputs.shareButtonTapped()

    self.showShareSheet.assertValueCount(1)
  }

  func testShowShareSheet_Update() {
    self.vm.inputs.configureWith(shareContext: .update(.template, .template), shareContextView: nil)
    self.vm.inputs.shareButtonTapped()

    self.showShareSheet.assertValueCount(1)
  }

  func testShowShareSheet_BackerOnlyUpdate() {
    self.vm.inputs.configureWith(
      shareContext: .update(
        .template,
        .template |> Update.lens.isPublic .~ false
      ),
      shareContextView: nil
    )
    self.vm.inputs.shareButtonTapped()

    self.showShareSheet.assertValueCount(1)
  }

  func testTracking_CancelShareSheet() {
    self.vm.inputs.configureWith(shareContext: .project(.template), shareContextView: nil)
    self.vm.inputs.shareButtonTapped()

    XCTAssertEqual(["Showed Share Sheet", "Project Show Share Sheet"], self.trackingClient.events)

    self.vm.inputs.shareActivityCompletion(
      with: .init(activityType: nil, completed: false, returnedItems: nil, activityError: nil)
    )

    XCTAssertEqual(
      [
        "Showed Share Sheet", "Project Show Share Sheet", "Canceled Share Sheet",
        "Project Cancel Share Sheet"
      ],
      self.trackingClient.events
    )

    XCTAssertEqual(
      ["project", "project", "project", "project"],
      self.trackingClient.properties(forKey: "context", as: String.self)
    )
    XCTAssertEqual(
      [nil, true, nil, true],
      self.trackingClient.properties(forKey: Koala.DeprecatedKey, as: Bool.self)
    )
  }

  func testTracking_CancelThirdPartyShare() {
    self.vm.inputs.configureWith(shareContext: .project(.template), shareContextView: nil)
    self.vm.inputs.shareButtonTapped()

    XCTAssertEqual(["Showed Share Sheet", "Project Show Share Sheet"], self.trackingClient.events)

    self.vm.inputs.shareActivityCompletion(
      with: .init(
        activityType: UIActivity.ActivityType(rawValue: "com.third-party.share"),
        completed: false,
        returnedItems: nil,
        activityError: nil
      )
    )

    XCTAssertEqual(
      ["Showed Share Sheet", "Project Show Share Sheet", "Showed Share", "Project Show Share"],
      self.trackingClient.events
    )

    self.scheduler.run()

    XCTAssertEqual(
      ["Showed Share Sheet", "Project Show Share Sheet", "Showed Share", "Project Show Share"],
      self.trackingClient.events,
      "A canceled event is not tracked because we cannot determine that for 3rd party shares."
    )

    XCTAssertEqual(
      ["project", "project", "project", "project"],
      self.trackingClient.properties(forKey: "context", as: String.self)
    )
    XCTAssertEqual(
      [nil, nil, "com.third-party.share", "com.third-party.share"],
      self.trackingClient.properties(forKey: "share_activity_type", as: String.self)
    )
  }

  func testTracking_CancelFirstPartyShare() {
    self.vm.inputs.configureWith(shareContext: .project(.template), shareContextView: nil)
    self.vm.inputs.shareButtonTapped()

    XCTAssertEqual(["Showed Share Sheet", "Project Show Share Sheet"], self.trackingClient.events)

    self.vm.inputs.shareActivityCompletion(
      with: .init(activityType: .postToTwitter, completed: false, returnedItems: nil, activityError: nil)
    )

    XCTAssertEqual(
      ["Showed Share Sheet", "Project Show Share Sheet", "Showed Share", "Project Show Share"],
      self.trackingClient.events
    )

    self.scheduler.run()

    XCTAssertEqual(
      [
        "Showed Share Sheet", "Project Show Share Sheet", "Showed Share", "Project Show Share",
        "Canceled Share", "Project Cancel Share"
      ],
      self.trackingClient.events
    )

    XCTAssertEqual(
      ["project", "project", "project", "project", "project", "project"],
      self.trackingClient.properties(forKey: "context", as: String.self)
    )
    XCTAssertEqual(
      [
        nil,
        nil,
        UIActivity.ActivityType.postToTwitter.rawValue, UIActivity.ActivityType.postToTwitter.rawValue,
        UIActivity.ActivityType.postToTwitter.rawValue, UIActivity.ActivityType.postToTwitter.rawValue
      ],
      self.trackingClient.properties(forKey: "share_activity_type", as: String.self)
    )
  }

  func testTracking_ThirdPartyShare() {
    self.vm.inputs.configureWith(shareContext: .project(.template), shareContextView: nil)
    self.vm.inputs.shareButtonTapped()

    XCTAssertEqual(["Showed Share Sheet", "Project Show Share Sheet"], self.trackingClient.events)

    self.vm.inputs.shareActivityCompletion(
      with: .init(
        activityType: UIActivity.ActivityType(rawValue: "com.third-party.share"),
        completed: true,
        returnedItems: nil,
        activityError: nil
      )
    )

    XCTAssertEqual(
      ["Showed Share Sheet", "Project Show Share Sheet", "Showed Share", "Project Show Share"],
      self.trackingClient.events
    )

    self.scheduler.run()

    XCTAssertEqual(
      ["Showed Share Sheet", "Project Show Share Sheet", "Showed Share", "Project Show Share"],
      self.trackingClient.events
    )

    XCTAssertEqual(
      ["project", "project", "project", "project"],
      self.trackingClient.properties(forKey: "context", as: String.self)
    )
    XCTAssertEqual(
      [nil, nil, "com.third-party.share", "com.third-party.share"],
      self.trackingClient.properties(forKey: "share_activity_type", as: String.self)
    )
  }

  func testTracking_FirstPartyShare() {
    self.vm.inputs.configureWith(shareContext: .project(.template), shareContextView: nil)
    self.vm.inputs.shareButtonTapped()

    XCTAssertEqual(["Showed Share Sheet", "Project Show Share Sheet"], self.trackingClient.events)

    self.vm.inputs.shareActivityCompletion(
      with: .init(activityType: .postToTwitter, completed: true, returnedItems: nil, activityError: nil)
    )

    XCTAssertEqual(
      ["Showed Share Sheet", "Project Show Share Sheet", "Showed Share", "Project Show Share"],
      self.trackingClient.events
    )

    self.scheduler.run()

    XCTAssertEqual(
      [
        "Showed Share Sheet", "Project Show Share Sheet", "Showed Share", "Project Show Share", "Shared",
        "Project Share"
      ],
      self.trackingClient.events
    )

    XCTAssertEqual(
      ["project", "project", "project", "project", "project", "project"],
      self.trackingClient.properties(forKey: "context", as: String.self)
    )
    XCTAssertEqual(
      [
        nil,
        nil,
        UIActivity.ActivityType.postToTwitter.rawValue, UIActivity.ActivityType.postToTwitter.rawValue,
        UIActivity.ActivityType.postToTwitter.rawValue, UIActivity.ActivityType.postToTwitter.rawValue
      ],
      self.trackingClient.properties(forKey: "share_activity_type", as: String.self)
    )
  }

  func testTracking_Update_ThirdPartyShare() {
    self.vm.inputs.configureWith(shareContext: .update(.template, .template), shareContextView: nil)
    self.vm.inputs.shareButtonTapped()

    XCTAssertEqual(["Showed Share Sheet", "Update Show Share Sheet"], self.trackingClient.events)

    self.vm.inputs.shareActivityCompletion(
      with: .init(
        activityType: UIActivity.ActivityType(rawValue: "com.third-party.share"),
        completed: true,
        returnedItems: nil,
        activityError: nil
      )
    )

    XCTAssertEqual(
      ["Showed Share Sheet", "Update Show Share Sheet", "Showed Share", "Update Show Share"],
      self.trackingClient.events
    )

    self.scheduler.run()

    XCTAssertEqual(
      ["Showed Share Sheet", "Update Show Share Sheet", "Showed Share", "Update Show Share"],
      self.trackingClient.events
    )

    XCTAssertEqual(
      ["update", "update", "update", "update"],
      self.trackingClient.properties(forKey: "context", as: String.self)
    )
    XCTAssertEqual(
      [nil, nil, "com.third-party.share", "com.third-party.share"],
      self.trackingClient.properties(forKey: "share_activity_type", as: String.self)
    )
  }

  func testTracking_CreatorDashboard_ThirdPartyShare() {
    self.vm.inputs.configureWith(shareContext: .creatorDashboard(.template), shareContextView: nil)
    self.vm.inputs.shareButtonTapped()

    XCTAssertEqual(["Showed Share Sheet", "Project Show Share Sheet"], self.trackingClient.events)

    self.vm.inputs.shareActivityCompletion(
      with: .init(
        activityType: UIActivity.ActivityType(rawValue: "com.third-party.share"),
        completed: true,
        returnedItems: nil,
        activityError: nil
      )
    )

    XCTAssertEqual(
      ["Showed Share Sheet", "Project Show Share Sheet", "Showed Share", "Project Show Share"],
      self.trackingClient.events
    )

    self.scheduler.run()

    XCTAssertEqual(
      ["Showed Share Sheet", "Project Show Share Sheet", "Showed Share", "Project Show Share"],
      self.trackingClient.events
    )

    XCTAssertEqual(
      ["creator_dashboard", "creator_dashboard", "creator_dashboard", "creator_dashboard"],
      self.trackingClient.properties(forKey: "context", as: String.self)
    )
    XCTAssertEqual(
      [nil, nil, "com.third-party.share", "com.third-party.share"],
      self.trackingClient.properties(forKey: "share_activity_type", as: String.self)
    )
  }

  func testTracking_Thanks_ThirdPartyShare() {
    self.vm.inputs.configureWith(shareContext: .thanks(.template), shareContextView: nil)
    self.vm.inputs.shareButtonTapped()

    XCTAssertEqual(["Showed Share Sheet", "Checkout Show Share Sheet"], self.trackingClient.events)

    self.vm.inputs.shareActivityCompletion(
      with: .init(
        activityType: UIActivity.ActivityType(rawValue: "com.third-party.share"),
        completed: true,
        returnedItems: nil,
        activityError: nil
      )
    )

    XCTAssertEqual(
      ["Showed Share Sheet", "Checkout Show Share Sheet", "Showed Share", "Checkout Show Share"],
      self.trackingClient.events
    )

    self.scheduler.run()

    XCTAssertEqual(
      ["Showed Share Sheet", "Checkout Show Share Sheet", "Showed Share", "Checkout Show Share"],
      self.trackingClient.events
    )

    XCTAssertEqual(
      ["thanks", "thanks", "thanks", "thanks"],
      self.trackingClient.properties(forKey: "context", as: String.self)
    )
    XCTAssertEqual(
      [nil, nil, "com.third-party.share", "com.third-party.share"],
      self.trackingClient.properties(forKey: "share_activity_type", as: String.self)
    )
  }

  func testTracking_Thanks_FirstPartyShare() {
    self.vm.inputs.configureWith(shareContext: .thanks(.template), shareContextView: nil)
    self.vm.inputs.shareButtonTapped()

    XCTAssertEqual(["Showed Share Sheet", "Checkout Show Share Sheet"], self.trackingClient.events)

    self.vm.inputs.shareActivityCompletion(
      with: .init(activityType: .postToTwitter, completed: true, returnedItems: nil, activityError: nil)
    )

    XCTAssertEqual(
      ["Showed Share Sheet", "Checkout Show Share Sheet", "Showed Share", "Checkout Show Share"],
      self.trackingClient.events
    )

    self.scheduler.run()

    XCTAssertEqual(
      [
        "Showed Share Sheet", "Checkout Show Share Sheet", "Showed Share", "Checkout Show Share",
        "Shared", "Checkout Share"
      ],
      self.trackingClient.events
    )

    XCTAssertEqual(
      ["thanks", "thanks", "thanks", "thanks", "thanks", "thanks"],
      self.trackingClient.properties(forKey: "context", as: String.self)
    )
    XCTAssertEqual(
      [
        nil,
        nil,
        UIActivity.ActivityType.postToTwitter.rawValue, UIActivity.ActivityType.postToTwitter.rawValue,
        UIActivity.ActivityType.postToTwitter.rawValue, UIActivity.ActivityType.postToTwitter.rawValue
      ],
      self.trackingClient.properties(forKey: "share_activity_type", as: String.self)
    )
  }
}
