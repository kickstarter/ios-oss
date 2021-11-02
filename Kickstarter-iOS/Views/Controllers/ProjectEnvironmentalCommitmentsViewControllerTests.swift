@testable import Kickstarter_Framework
@testable import KsApi
import Library
import Prelude
import XCTest

final class ProjectEnvironmentalCommitmentsViewControllerTests: TestCase {
  private let environmentalCommitments = [
    ProjectEnvironmentalCommitment(
      description: "foo bar",
      category: .environmentallyFriendlyFactories,
      id: 0
    ),
    ProjectEnvironmentalCommitment(description: "hello world", category: .longLastingDesign, id: 1),
    ProjectEnvironmentalCommitment(
      description: "Lorem ipsum",
      category: .reusabilityAndRecyclability,
      id: 2
    ),
    ProjectEnvironmentalCommitment(description: "blah blah blah", category: .sustainableDistribution, id: 3)
  ]

  override func setUp() {
    super.setUp()

    AppEnvironment.pushEnvironment(mainBundle: Bundle.framework)
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }

  func testViewController_PortraitOrientation() {
    let devices = [Device.phone4_7inch, Device.pad]

    combos(Language.allLanguages, devices).forEach { language, device in
      withEnvironment(currentUser: .template, language: language) {
        let controller = ProjectEnvironmentalCommitmentsViewController
          .configuredWith(environmentalCommitments: self.environmentalCommitments)

        let (parent, _) = traitControllers(
          device: device,
          orientation: .portrait,
          child: controller
        )

        parent.view.frame.size.height = 1_100

        self.scheduler.run()

        FBSnapshotVerifyView(
          parent.view,
          identifier: "ProjectEnvironmentalCommitmentsViewController - lang_\(language)_device_\(device)"
        )
      }
    }
  }

  func testViewController_LandscapeOrientation() {
    let devices = [Device.phone4_7inch, Device.pad]

    combos(Language.allLanguages, devices).forEach { language, device in
      withEnvironment(currentUser: .template, language: language) {
        let controller = ProjectEnvironmentalCommitmentsViewController
          .configuredWith(environmentalCommitments: self.environmentalCommitments)

        let (parent, _) = traitControllers(
          device: device,
          orientation: .landscape,
          child: controller
        )

        parent.view.frame.size.height = 1_100

        self.scheduler.run()

        FBSnapshotVerifyView(
          parent.view,
          identifier: "ProjectEnvironmentalCommitmentsViewController - lang_\(language)_device_\(device)"
        )
      }
    }
  }

  func testViewController_NoEnvironmentalCommitments() {
    let devices = [Device.phone4_7inch, Device.pad]

    combos(Language.allLanguages, devices).forEach { language, device in
      withEnvironment(currentUser: .template, language: language) {
        let controller = ProjectEnvironmentalCommitmentsViewController
          .configuredWith(environmentalCommitments: [])

        let (parent, _) = traitControllers(
          device: device,
          orientation: .portrait,
          child: controller
        )

        parent.view.frame.size.height = 1_100

        self.scheduler.run()

        FBSnapshotVerifyView(
          parent.view,
          identifier: "ProjectEnvironmentalCommitmentsViewController - lang_\(language)_device_\(device)"
        )
      }
    }
  }
}
