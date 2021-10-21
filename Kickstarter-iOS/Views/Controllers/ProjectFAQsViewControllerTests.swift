@testable import Kickstarter_Framework
@testable import KsApi
import Library
import Prelude
import XCTest

final class ProjectFAQsViewControllerTests: TestCase {
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
    let faqs = [
      ProjectFAQ(answer: "Answer 1", question: "Question 1", id: 0, createdAt: nil),
      ProjectFAQ(answer: "Answer 2", question: "Question 2", id: 1, createdAt: nil),
      ProjectFAQ(answer: "Answer 3", question: "Question 3", id: 2, createdAt: nil),
      ProjectFAQ(answer: "Answer 4", question: "Question 4", id: 3, createdAt: nil)
    ]

    let project = Project.template
      |> Project.lens.extendedProjectProperties .~ ExtendedProjectProperties(
        environmentalCommitments: [],
        faqs: faqs,
        risks: "",
        story: "",
        minimumPledgeAmount: 1
      )

    let devices = [Device.phone4_7inch, Device.pad]

    combos(Language.allLanguages, devices).forEach { language, device in
      withEnvironment(currentUser: .template, language: language) {
        let controller = ProjectFAQsViewController.configuredWith(project: project)

        let (parent, _) = traitControllers(
          device: device,
          orientation: .portrait,
          child: controller
        )

        parent.view.frame.size.height = 1_100

        self.scheduler.run()

        FBSnapshotVerifyView(
          parent.view,
          identifier: "ProjectFAQsViewController - lang_\(language)_device_\(device)"
        )
      }
    }
  }

  func testViewController_LandscapeOrientation() {
    let faqs = [
      ProjectFAQ(answer: "Answer 1", question: "Question 1", id: 0, createdAt: nil),
      ProjectFAQ(answer: "Answer 2", question: "Question 2", id: 1, createdAt: nil),
      ProjectFAQ(answer: "Answer 3", question: "Question 3", id: 2, createdAt: nil),
      ProjectFAQ(answer: "Answer 4", question: "Question 4", id: 3, createdAt: nil)
    ]

    let project = Project.template
      |> Project.lens.extendedProjectProperties .~ ExtendedProjectProperties(
        environmentalCommitments: [],
        faqs: faqs,
        risks: "",
        story: "",
        minimumPledgeAmount: 1
      )

    let devices = [Device.phone4_7inch, Device.pad]

    combos(Language.allLanguages, devices).forEach { language, device in
      withEnvironment(currentUser: .template, language: language) {
        let controller = ProjectFAQsViewController.configuredWith(project: project)

        let (parent, _) = traitControllers(
          device: device,
          orientation: .landscape,
          child: controller
        )

        parent.view.frame.size.height = 1_100

        self.scheduler.run()

        FBSnapshotVerifyView(
          parent.view,
          identifier: "ProjectFAQsViewController - lang_\(language)_device_\(device)"
        )
      }
    }
  }

  func testViewController_EmptyState() {
    let project = Project.template
      |> Project.lens.extendedProjectProperties .~ ExtendedProjectProperties(
        environmentalCommitments: [],
        faqs: [],
        risks: "",
        story: "",
        minimumPledgeAmount: 1
      )

    let devices = [Device.phone4_7inch, Device.pad]

    combos(Language.allLanguages, devices).forEach { language, device in
      withEnvironment(currentUser: .template, language: language) {
        let controller = ProjectFAQsViewController.configuredWith(project: project)

        let (parent, _) = traitControllers(
          device: device,
          orientation: .portrait,
          child: controller
        )

        parent.view.frame.size.height = 1_100

        self.scheduler.run()

        FBSnapshotVerifyView(
          parent.view,
          identifier: "ProjectFAQsViewController - lang_\(language)_device_\(device)"
        )
      }
    }
  }
}
