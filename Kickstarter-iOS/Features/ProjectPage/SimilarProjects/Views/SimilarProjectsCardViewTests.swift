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
    "postCampaignPledgingEnabled": isPostCampaignPledgingEnabled,

    "image": [
      "__typename": "Photo",
      "id": "UGhvdG8tNDg2ODQ3NTg=",
      "url": "https://i.kickstarter.com/assets/048/684/758/6ddc33481300f1f68bc0f8079c4e14ab_original.jpg?anim=false&fit=cover&gravity=auto&height=576&origin=ugc&q=92&v=1743084521&width=1024&sig=fOX9WaONZF%2FmUUtOBUqn%2FL2Tp0glAu1QsYklxk%2FKeo0%3D"
    ],
    "deadlineAt": 1_745_506_853,
    "launchedAt": 1_742_914_853,
    "url": "https://www.kickstarter.com/projects/ollis/the-ollis-cast-iron-skillet-and-dutch-oven-foundry-pan",
    "goal": [
      "__typename": "Money",
      "amount": "35000.0",
      "currency": "GBP",
      "symbol": "£"
    ],
    "addOns": [
      "__typename": "ProjectRewardConnection",
      "totalCount": 0
    ],
    "backersCount": 276,
    "category": [
      "__typename": "Category",
      "analyticsName": "Product Design",
      "parentCategory": [
        "__typename": "Category",
        "analyticsName": "Design",
        "id": "Q2F0ZWdvcnktNw=="
      ],
      "name": "Product Design"
    ],
    "commentsCount": 17,
    "country": [
      "__typename": "Country",
      "code": "GB",
      "name": "the United Kingdom"
    ],
    "creator": [
      "__typename": "User",
      "id": "x",
      "createdProjects": [
        "__typename": "UserCreatedProjectsConnection",
        "totalCount": 1
      ],
      "name": "x",
      "isBlocked": false,
      "imageUrl": ""
    ],
    "currency": "GBP",
    "isWatched": false,
    "isPrelaunchActivated": true,
    "projectTags": [],
    "rewards": [
      "__typename": "ProjectRewardConnection",
      "totalCount": 4
    ],
    "fxRate": 1.28198554,
    "usdExchangeRate": 1.28198554,
    "posts": [
      "__typename": "PostConnection",
      "totalCount": 2
    ],
    "projectDescription": "x",
    "stateChangedAt": 1_742_914_857,
    "projectUsdExchangeRate": 1.28198554,
    "location": [
      "__typename": "Location",
      "displayableName": "London, UK"
    ]
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
