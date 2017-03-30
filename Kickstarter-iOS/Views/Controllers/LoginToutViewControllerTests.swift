import Library
@testable import Kickstarter_Framework

internal final class LoginToutViewControllerTests: TestCase {

  override func setUp() {
    super.setUp()

    AppEnvironment.pushEnvironment(mainBundle: Bundle.framework)
  }

  func testView() {
    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach { language, device in
      withEnvironment(language: language) {
        let controller = Storyboard.Login.instantiate(LoginToutViewController.self)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        controller.viewModel.inputs.loginIntent(.generic)
        controller.viewModel.inputs.viewWillAppear()
        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testStarProjectContext() {
    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach { language, device in
      withEnvironment(language: language) {
        let controller = Storyboard.Login.instantiate(LoginToutViewController.self)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        controller.viewModel.inputs.loginIntent(.starProject)
        controller.viewModel.inputs.viewWillAppear()
        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testBackProjectContext() {
    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach { language, device in
      withEnvironment(language: language) {
        let controller = Storyboard.Login.instantiate(LoginToutViewController.self)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        controller.viewModel.inputs.loginIntent(.backProject)
        controller.viewModel.inputs.viewWillAppear()
        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testLiveStreamContext() {
    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach { language, device in
      withEnvironment(language: language) {
        let controller = Storyboard.Login.instantiate(LoginToutViewController.self)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        controller.viewModel.inputs.loginIntent(.liveStreamSubscribe)
        controller.viewModel.inputs.viewWillAppear()
        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  override func tearDown() {
    AppEnvironment.popEnvironment()
    super.tearDown()
  }
}


