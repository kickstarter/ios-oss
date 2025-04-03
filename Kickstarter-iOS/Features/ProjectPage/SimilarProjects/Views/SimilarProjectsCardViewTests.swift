@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import SnapshotTesting
import XCTest

final class SimilarProjectsCardViewTests: TestCase {
  var similarProject: SimilarProjectFragment?

  override func setUp() {
    super.setUp()
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    UIView.setAnimationsEnabled(true)

    super.tearDown()
  }

  func testView_ProjectState_Live() {
    let validProjectFragment = createMockProjectNode(id: 1, name: "Project 1", state: "live")
    self.similarProject = SimilarProjectFragment(validProjectFragment.fragments.projectCardFragment)

    XCTAssertNotNil(self.similarProject, "SimilarProjectFragment should not be nil")

    orthogonalCombos([Language.en, Language.es], [Device.phone4_7inch]).forEach { language, device in
      withEnvironment(language: language) {
        let view = SimilarProjectsCardView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false

        view.configureWith(value: self.similarProject!)

        let (parent, _) = traitControllers(
          device: device,
          orientation: .portrait,
          child: wrappedViewController(subview: view, device: device)
        )
        parent.view.frame.size.height = 300

        self.scheduler.advance(by: .seconds(1))

        assertSnapshot(matching: parent.view, as: .image, named: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testView_ProjectState_Successful() {
    let validProjectFragment = createMockProjectNode(id: 1, name: "Project 1", state: "successful")
    self.similarProject = SimilarProjectFragment(validProjectFragment.fragments.projectCardFragment)

    XCTAssertNotNil(self.similarProject, "SimilarProjectFragment should not be nil")

    orthogonalCombos([Language.en, Language.es], [Device.phone4_7inch]).forEach { language, device in
      withEnvironment(language: language) {
        let view = SimilarProjectsCardView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false

        view.configureWith(value: self.similarProject!)

        let (parent, _) = traitControllers(
          device: device,
          orientation: .portrait,
          child: wrappedViewController(subview: view, device: device)
        )
        parent.view.frame.size.height = 300

        self.scheduler.advance(by: .seconds(1))

        assertSnapshot(matching: parent.view, as: .image, named: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testView_ProjectState_Failed() {
    let validProjectFragment = createMockProjectNode(id: 1, name: "Project 1", state: "failed")
    self.similarProject = SimilarProjectFragment(validProjectFragment.fragments.projectCardFragment)

    XCTAssertNotNil(self.similarProject, "SimilarProjectFragment should not be nil")

    orthogonalCombos([Language.en, Language.es], [Device.phone4_7inch]).forEach { language, device in
      withEnvironment(language: language) {
        let view = SimilarProjectsCardView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false

        view.configureWith(value: self.similarProject!)

        let (parent, _) = traitControllers(
          device: device,
          orientation: .portrait,
          child: wrappedViewController(subview: view, device: device)
        )
        parent.view.frame.size.height = 300

        self.scheduler.advance(by: .seconds(1))

        assertSnapshot(matching: parent.view, as: .image, named: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testView_Project_IsPrelaunch() {
    let validProjectFragment = createMockProjectNode(
      id: 1,
      name: "Project 1",
      state: "live",
      prelaunchActivated: true,
      launchedAt: "-5"
    )
    self.similarProject = SimilarProjectFragment(validProjectFragment.fragments.projectCardFragment)

    XCTAssertNotNil(self.similarProject, "SimilarProjectFragment should not be nil")

    orthogonalCombos([Language.en, Language.es], [Device.phone4_7inch]).forEach { language, device in
      withEnvironment(language: language) {
        let view = SimilarProjectsCardView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false

        view.configureWith(value: self.similarProject!)

        let (parent, _) = traitControllers(
          device: device,
          orientation: .portrait,
          child: wrappedViewController(subview: view, device: device)
        )
        parent.view.frame.size.height = 300

        self.scheduler.advance(by: .seconds(1))

        assertSnapshot(matching: parent.view, as: .image, named: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testView_Project_LatePledge() {
    let validProjectFragment = createMockProjectNode(
      id: 1,
      name: "Project 1",
      state: "live",
      isInPostCampaignPledgingPhase: true,
      isPostCampaignPledgingEnabled: true
    )
    self.similarProject = SimilarProjectFragment(validProjectFragment.fragments.projectCardFragment)

    XCTAssertNotNil(self.similarProject, "SimilarProjectFragment should not be nil")

    orthogonalCombos([Language.en, Language.es], [Device.phone4_7inch]).forEach { language, device in
      withEnvironment(language: language) {
        let view = SimilarProjectsCardView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false

        view.configureWith(value: self.similarProject!)

        let (parent, _) = traitControllers(
          device: device,
          orientation: .portrait,
          child: wrappedViewController(subview: view, device: device)
        )
        parent.view.frame.size.height = 300

        self.scheduler.advance(by: .seconds(1))

        assertSnapshot(matching: parent.view, as: .image, named: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testView_ProjectState_NameWithDescenders() {
    let validProjectFragment = createMockProjectNode(id: 1, name: "Project for a Thingy", state: "live")
    self.similarProject = SimilarProjectFragment(validProjectFragment.fragments.projectCardFragment)

    XCTAssertNotNil(self.similarProject, "SimilarProjectFragment should not be nil")

    orthogonalCombos([Language.en, Language.es], [Device.phone4_7inch]).forEach { language, device in
      withEnvironment(language: language) {
        let view = SimilarProjectsCardView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false

        view.configureWith(value: self.similarProject!)

        let (parent, _) = traitControllers(
          device: device,
          orientation: .portrait,
          child: wrappedViewController(subview: view, device: device)
        )
        parent.view.frame.size.height = 300

        self.scheduler.advance(by: .seconds(1))

        assertSnapshot(matching: parent.view, as: .image, named: "lang_\(language)_device_\(device)")
      }
    }
  }

}

private func wrappedViewController(subview: UIView, device: Device) -> UIViewController {
  let controller = UIViewController(nibName: nil, bundle: nil)
  let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

  controller.view.addSubview(subview)

  NSLayoutConstraint.activate([
    subview.leadingAnchor.constraint(equalTo: controller.view.layoutMarginsGuide.leadingAnchor),
    subview.topAnchor.constraint(equalTo: controller.view.layoutMarginsGuide.topAnchor),
    subview.trailingAnchor.constraint(equalTo: controller.view.layoutMarginsGuide.trailingAnchor),
    subview.bottomAnchor.constraint(equalTo: controller.view.layoutMarginsGuide.bottomAnchor)
  ])

  return parent
}

// Helper method to create mock project nodes for testing
private func createMockProjectNode(
  id: Int = 123,
  name: String = "Test Project",
  imageURL: String? = "https://example.com/image.jpg",
  state: String = "live",
  isLaunched: Bool = true,
  prelaunchActivated: Bool = false,
  launchedAt: String? = "1741737648",
  deadlineAt: String? = "1742737648",
  percentFunded: Int = 75,
  goal: Double? = 10_000,
  pledged: Double = 7_500,
  isInPostCampaignPledgingPhase: Bool = false,
  isPostCampaignPledgingEnabled: Bool = false
) -> GraphAPI.FetchSimilarProjectsQuery.Data.Project.Node {
  var resultMap: [String: Any] = [
    "__typename": "Project",
    "pid": id,
    "name": name,
    "state": GraphAPI.ProjectState(rawValue: state) ?? GraphAPI.ProjectState.__unknown(state),
    "isLaunched": isLaunched,
    "prelaunchActivated": prelaunchActivated,
    "percentFunded": percentFunded,
    "pledged": [
      "__typename": "Money",
      "amount": String(pledged),
      "currency": GraphAPI.CurrencyCode.usd,
      "symbol": "$"
    ],
    "isInPostCampaignPledgingPhase": isInPostCampaignPledgingPhase,
    "postCampaignPledgingEnabled": isPostCampaignPledgingEnabled
  ]

  // Add optional fields
  if let imageURL {
    resultMap["image"] = [
      "__typename": "Photo",
      "url": imageURL
    ]
  }

  if let launchedAt {
    resultMap["launchedAt"] = launchedAt
  }

  if let deadlineAt {
    resultMap["deadlineAt"] = deadlineAt
  }

  if let goal {
    resultMap["goal"] = [
      "__typename": "Money",
      "amount": String(goal),
      "currency": GraphAPI.CurrencyCode.usd,
      "symbol": "$"
    ]
  }

  return GraphAPI.FetchSimilarProjectsQuery.Data.Project.Node(unsafeResultMap: resultMap)
}
