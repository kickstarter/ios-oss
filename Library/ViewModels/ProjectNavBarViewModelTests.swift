@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class ProjectNavBarViewModelTests: TestCase {
  fileprivate let vm: ProjectNavBarViewModelType = ProjectNavBarViewModel()

  fileprivate let backgroundAnimate = TestObserver<Bool, Never>()
  fileprivate let backgroundOpaque = TestObserver<Bool, Never>()
  fileprivate let categoryButtonText = TestObserver<String, Never>()
  fileprivate let categoryButtonTintColor = TestObserver<UIColor, Never>()
  fileprivate let categoryButtonTitleColor = TestObserver<UIColor, Never>()
  fileprivate let categoryHidden = TestObserver<Bool, Never>()
  fileprivate let categoryAnimate = TestObserver<Bool, Never>()
  fileprivate let dismissViewController = TestObserver<(), Never>()
  fileprivate let projectName = TestObserver<String, Never>()
  fileprivate let titleAnimate = TestObserver<Bool, Never>()
  fileprivate let titleHidden = TestObserver<Bool, Never>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.backgroundOpaqueAndAnimate.map(second).observe(self.backgroundAnimate.observer)
    self.vm.outputs.backgroundOpaqueAndAnimate.map(first).observe(self.backgroundOpaque.observer)
    self.vm.outputs.categoryButtonText.observe(self.categoryButtonText.observer)
    self.vm.outputs.categoryButtonTintColor.observe(self.categoryButtonTintColor.observer)
    self.vm.outputs.categoryButtonTitleColor.observe(self.categoryButtonTitleColor.observer)
    self.vm.outputs.categoryHiddenAndAnimate.map(first).observe(self.categoryHidden.observer)
    self.vm.outputs.categoryHiddenAndAnimate.map(second).observe(self.categoryAnimate.observer)
    self.vm.outputs.dismissViewController.observe(self.dismissViewController.observer)
    self.vm.outputs.projectName.observe(self.projectName.observer)
    self.vm.outputs.titleHiddenAndAnimate.map(second).observe(self.titleAnimate.observer)
    self.vm.outputs.titleHiddenAndAnimate.map(first).observe(self.titleHidden.observer)
  }

  func testBackgroundOpaqueAndAnimate() {
    self.vm.inputs.configureWith(project: .template, refTag: nil)
    self.vm.inputs.viewDidLoad()

    self.backgroundOpaque.assertValues([false])
    self.backgroundAnimate.assertValues([false])

    // scroll image off screen
    self.vm.inputs.projectImageIsVisible(false)

    self.backgroundOpaque.assertValues([false, true])
    self.backgroundAnimate.assertValues([false, true])

    // scroll image back on screen
    self.vm.inputs.projectImageIsVisible(true)

    self.backgroundOpaque.assertValues([false, true, false])
    self.backgroundAnimate.assertValues([false, true, true])

    // start video
    self.vm.inputs.projectVideoDidStart()

    self.backgroundOpaque.assertValues([false, true, false])
    self.backgroundAnimate.assertValues([false, true, true])

    // scroll image off screen
    self.vm.inputs.projectImageIsVisible(false)

    self.backgroundOpaque.assertValues([false, true, false, true])
    self.backgroundAnimate.assertValues([false, true, true, true])

    // scroll image back on screen
    self.vm.inputs.projectImageIsVisible(true)

    self.backgroundOpaque.assertValues([false, true, false, true, false])
    self.backgroundAnimate.assertValues([false, true, true, true, true])

    // finish video
    self.vm.inputs.projectVideoDidFinish()

    self.backgroundOpaque.assertValues([false, true, false, true, false])
    self.backgroundAnimate.assertValues([false, true, true, true, true])
  }

  func testCategoryButtonText() {
    self.vm.inputs.configureWith(
      project: .template |> \.category.name .~ "Some Category",
      refTag: nil
    )
    self.vm.inputs.viewDidLoad()

    self.categoryButtonText.assertValues(["Some Category"])
  }

  func testCategoryHiddenAndAnimate() {
    self.vm.inputs.configureWith(project: .template, refTag: nil)
    self.vm.inputs.viewDidLoad()

    self.categoryHidden.assertValues([false])
    self.categoryAnimate.assertValues([false])

    // scroll image off screen
    self.vm.inputs.projectImageIsVisible(false)

    self.categoryHidden.assertValues([false, true])
    self.categoryAnimate.assertValues([false, true])

    // scroll image back on screen
    self.vm.inputs.projectImageIsVisible(true)

    self.categoryHidden.assertValues([false, true, false])
    self.categoryAnimate.assertValues([false, true, true])

    // start video
    self.vm.inputs.projectVideoDidStart()

    self.categoryHidden.assertValues([false, true, false, true])
    self.categoryAnimate.assertValues([false, true, true, true])

    // scroll image off screen
    self.vm.inputs.projectImageIsVisible(false)

    self.categoryHidden.assertValues([false, true, false, true])
    self.categoryAnimate.assertValues([false, true, true, true])

    // scroll image back on screen
    self.vm.inputs.projectImageIsVisible(true)

    self.categoryHidden.assertValues([false, true, false, true])
    self.categoryAnimate.assertValues([false, true, true, true])

    // finish video
    self.vm.inputs.projectVideoDidFinish()

    self.categoryHidden.assertValues([false, true, false, true, false])
    self.categoryAnimate.assertValues([false, true, true, true, true])
  }

  func testCategoryHiddenAndAnimate_PlayVideoWithoutScrolling() {
    self.vm.inputs.configureWith(project: .template, refTag: nil)
    self.vm.inputs.viewDidLoad()

    self.categoryHidden.assertValues([false])
    self.categoryAnimate.assertValues([false])

    self.vm.inputs.projectVideoDidStart()

    self.categoryHidden.assertValues([false, true])
    self.categoryAnimate.assertValues([false, true])

    self.vm.inputs.projectVideoDidFinish()

    self.categoryHidden.assertValues([false, true, false])
    self.categoryAnimate.assertValues([false, true, true])
  }

  func testDismissViewController() {
    self.vm.inputs.configureWith(project: .template, refTag: nil)
    self.vm.inputs.viewDidLoad()

    self.dismissViewController.assertValueCount(0)

    self.vm.inputs.closeButtonTapped()

    self.dismissViewController.assertValueCount(1)
  }

  func testTitleHiddenAndAnimate() {
    self.vm.inputs.configureWith(project: .template, refTag: nil)
    self.vm.inputs.viewDidLoad()

    self.titleHidden.assertValues([true])
    self.titleAnimate.assertValues([false])

    // scroll image off screen
    self.vm.inputs.projectImageIsVisible(false)

    self.titleHidden.assertValues([true, false])
    self.titleAnimate.assertValues([false, true])

    // scroll image back on screen
    self.vm.inputs.projectImageIsVisible(true)

    self.titleHidden.assertValues([true, false, true])
    self.titleAnimate.assertValues([false, true, true])

    // start video
    self.vm.inputs.projectVideoDidStart()

    self.titleHidden.assertValues([true, false, true])
    self.titleAnimate.assertValues([false, true, true])

    // scroll image off screen
    self.vm.inputs.projectImageIsVisible(false)

    self.titleHidden.assertValues([true, false, true, false])
    self.titleAnimate.assertValues([false, true, true, true])

    // scroll image back on screen
    self.vm.inputs.projectImageIsVisible(true)

    self.titleHidden.assertValues([true, false, true, false, true])
    self.titleAnimate.assertValues([false, true, true, true, true])

    // finish video
    self.vm.inputs.projectVideoDidFinish()

    self.titleHidden.assertValues([true, false, true, false, true])
    self.titleAnimate.assertValues([false, true, true, true, true])
  }
}
