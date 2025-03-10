@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import SnapshotTesting
import XCTest

final class SimilarProjectsCardViewTests: TestCase {
  override func setUp() {
    super.setUp()
    AppEnvironment.pushEnvironment(mainBundle: Bundle.framework)
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    AppEnvironment.popEnvironment()
    UIView.setAnimationsEnabled(true)

    super.tearDown()
  }

  func testView_ProjectState_Live() {
    orthogonalCombos([Language.en], [Device.phone4_7inch]).forEach { language, device in
      withEnvironment(language: language) {
        let view = SimilarProjectsCardView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false

        var project = Project.template
        project.state = .live

        view.configureWith(value: project)

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
    orthogonalCombos([Language.en], [Device.phone4_7inch]).forEach { language, device in
      withEnvironment(language: language) {
        let view = SimilarProjectsCardView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false

        var project = Project.template
        project.state = .successful

        view.configureWith(value: project)

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
    orthogonalCombos([Language.en], [Device.phone4_7inch]).forEach { language, device in
      withEnvironment(language: language) {
        let view = SimilarProjectsCardView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false

        var project = Project.template
        project.state = .failed

        view.configureWith(value: project)

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
    orthogonalCombos([Language.en], [Device.phone4_7inch]).forEach { language, device in
      withEnvironment(language: language) {
        let view = SimilarProjectsCardView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false

        var project = Project.template
        project.state = .live
        project.prelaunchActivated = true
        project.dates.launchedAt = -5

        view.configureWith(value: project)

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
    orthogonalCombos([Language.en], [Device.phone4_7inch]).forEach { language, device in
      withEnvironment(language: language) {
        let view = SimilarProjectsCardView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false

        var project = Project.template
        project.isInPostCampaignPledgingPhase = true
        project.postCampaignPledgingEnabled = true

        view.configureWith(value: project)

        let (parent, _) = traitControllers(
          device: device,
          orientation: .portrait,
          child: wrappedViewController(subview: view, device: device)
        )
        parent.view.frame.size.height = 300

        self.scheduler.advance(by: .seconds(1))

        assertSnapshot(matching: parent.view, as: .image, named: "lang_\(language)_device_\(device)", record: true)
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
