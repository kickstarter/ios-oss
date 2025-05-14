@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class BackerDashboardProjectCellViewModelTests: TestCase {
  private let vm: BackerDashboardProjectCellViewModelType = BackerDashboardProjectCellViewModel()

  private let metadataIconIsHidden = TestObserver<Bool, Never>()
  private let metadataText = TestObserver<String, Never>()
  private let prelaunchProject = TestObserver<Bool, Never>()
  private let percentFundedText = TestObserver<String, Never>()
  private let photoURL = TestObserver<String, Never>()
  private let progress = TestObserver<Float, Never>()
  private let progressBarColor = TestObserver<UIColor, Never>()
  private let projectTitleText = TestObserver<String, Never>()
  private let savedIconIsHidden = TestObserver<Bool, Never>()

  override func setUp() {
    super.setUp()
    self.vm.outputs.metadataIconIsHidden.observe(self.metadataIconIsHidden.observer)
    self.vm.outputs.metadataText.observe(self.metadataText.observer)
    self.vm.outputs.percentFundedText.map { $0.string }.observe(self.percentFundedText.observer)
    self.vm.outputs.photoURL.map { $0?.absoluteString ?? "" }.observe(self.photoURL.observer)
    self.vm.outputs.progress.observe(self.progress.observer)
    self.vm.outputs.prelaunchProject.observe(self.prelaunchProject.observer)
    self.vm.outputs.progressBarColor.observe(self.progressBarColor.observer)
    self.vm.outputs.projectTitleText.map { $0.string }.observe(self.projectTitleText.observer)
    self.vm.outputs.savedIconIsHidden.observe(self.savedIconIsHidden.observer)
  }

  func testProjectData_Live() {
    let endingInDays = self.endingIn(days: 14)

    let project = .template
      |> Project.lens.name .~ "Best of Lazy Bathtub Cat"
      |> Project.lens.photo.full .~ "http://www.lazybathtubcat.com/vespa.jpg"
      |> Project.lens.stats.fundingProgress .~ 0.5
      |> Project.lens.dates.deadline .~ endingInDays
      |> Project.lens.prelaunchActivated .~ false
      |> Project.lens.displayPrelaunch .~ false

    self.vm.inputs.configureWith(project: project)

    self.metadataIconIsHidden.assertValues([false])
    self.metadataText.assertValues(["14 days"])
    self.percentFundedText.assertValues(["50%"])
    self.photoURL.assertValues(["http://www.lazybathtubcat.com/vespa.jpg"])
    self.progress.assertValues([0.5])
    self.progressBarColor.assertValues([LegacyColors.ksr_create_700.uiColor()])
    self.projectTitleText.assertValues(["Best of Lazy Bathtub Cat"])
    self.savedIconIsHidden.assertValues([true])
  }

  func testProjectData_Successful() {
    let project = .template
      |> Project.lens.name .~ "Best of Lazy Bathtub Cat"
      |> Project.lens.photo.full .~ "http://www.lazybathtubcat.com/vespa.jpg"
      |> Project.lens.stats.fundingProgress .~ 1.1
      |> Project.lens.state .~ .successful
      |> Project.lens.prelaunchActivated .~ false
      |> Project.lens.displayPrelaunch .~ false

    self.vm.inputs.configureWith(project: project)

    self.metadataIconIsHidden.assertValues([true])
    self.metadataText.assertValues(["Successful"])
    self.percentFundedText.assertValues(["110%"])
    self.photoURL.assertValues(["http://www.lazybathtubcat.com/vespa.jpg"])
    self.progress.assertValues([1.1])
    self.progressBarColor.assertValues([LegacyColors.ksr_create_700.uiColor()])
    self.projectTitleText.assertValues(["Best of Lazy Bathtub Cat"])
    self.savedIconIsHidden.assertValues([true])
  }

  func testProjectData_Failed() {
    let project = .template
      |> Project.lens.name .~ "Best of Lazy Bathtub Cat"
      |> Project.lens.photo.full .~ "http://www.lazybathtubcat.com/vespa.jpg"
      |> Project.lens.stats.fundingProgress .~ 0.2
      |> Project.lens.state .~ .failed
      |> Project.lens.prelaunchActivated .~ false
      |> Project.lens.displayPrelaunch .~ false

    self.vm.inputs.configureWith(project: project)

    self.metadataIconIsHidden.assertValues([true])
    self.metadataText.assertValues(["Unsuccessful"])
    self.percentFundedText.assertValues(["20%"])
    self.photoURL.assertValues(["http://www.lazybathtubcat.com/vespa.jpg"])
    self.progress.assertValues([0.2])
    self.progressBarColor.assertValues([LegacyColors.ksr_support_300.uiColor()])
    self.projectTitleText.assertValues(["Best of Lazy Bathtub Cat"])
    self.savedIconIsHidden.assertValues([true])
  }

  func testProjectData_Saved() {
    let project = .template
      |> Project.lens.name .~ "Best of Lazy Bathtub Cat"
      |> Project.lens.photo.full .~ "http://www.lazybathtubcat.com/vespa.jpg"
      |> Project.lens.stats.fundingProgress .~ 1.1
      |> Project.lens.state .~ .successful
      |> Project.lens.personalization.isStarred .~ true
      |> Project.lens.prelaunchActivated .~ false
      |> Project.lens.displayPrelaunch .~ false

    self.vm.inputs.configureWith(project: project)

    self.metadataIconIsHidden.assertValues([true])
    self.metadataText.assertValues(["Successful"])
    self.percentFundedText.assertValues(["110%"])
    self.photoURL.assertValues(["http://www.lazybathtubcat.com/vespa.jpg"])
    self.progress.assertValues([1.1])
    self.progressBarColor.assertValues([LegacyColors.ksr_create_700.uiColor()])
    self.projectTitleText.assertValues(["Best of Lazy Bathtub Cat"])
    self.savedIconIsHidden.assertValues([false])
  }

  func testProjectData_Prelaunch_Displayed() {
    let project = .template
      |> Project.lens.name .~ "Best of Lazy Bathtub Cat"
      |> Project.lens.photo.full .~ "http://www.lazybathtubcat.com/vespa.jpg"
      |> Project.lens.prelaunchActivated .~ true
      |> Project.lens.displayPrelaunch .~ true
      |> Project.lens.personalization.isStarred .~ true

    self.prelaunchProject.assertDidNotEmitValue()

    self.vm.inputs.configureWith(project: project)

    self.prelaunchProject.assertValues([true])
    self.metadataText.assertValues(["Coming soon"])
  }

  func testProjectData_Prelaunch_ActivatedButNotDisplayed() {
    let project = .template
      |> Project.lens.name .~ "Best of Lazy Bathtub Cat"
      |> Project.lens.photo.full .~ "http://www.lazybathtubcat.com/vespa.jpg"
      |> Project.lens.prelaunchActivated .~ true
      |> Project.lens.displayPrelaunch .~ false
      |> Project.lens.personalization.isStarred .~ true
      |> Project.lens.state .~ .successful

    self.prelaunchProject.assertDidNotEmitValue()

    self.vm.inputs.configureWith(project: project)

    self.prelaunchProject.assertValues([false])
    self.metadataText.assertValues(["Successful"])
  }

  func testProjectData_Prelaunch_DateIsZero() {
    let project = .template
      |> Project.lens.name .~ "Best of Lazy Bathtub Cat"
      |> Project.lens.photo.full .~ "http://www.lazybathtubcat.com/vespa.jpg"
      |> Project.lens.prelaunchActivated .~ nil
      |> Project.lens.displayPrelaunch .~ nil
      |> Project.lens.dates.launchedAt .~ 0
      |> Project.lens.personalization.isStarred .~ true
      |> Project.lens.state .~ .successful

    self.prelaunchProject.assertDidNotEmitValue()

    self.vm.inputs.configureWith(project: project)

    self.prelaunchProject.assertValues([true])
    self.metadataText.assertValues(["Coming soon"])
  }

  func testProjectData_GraphQL_Live() {
    let endingInDays = self.endingIn(days: 10)

    let jsonString = """
      {
              "__typename": "Project",
              "projectId": "pid",
              "name": "Test Project Data Live",
              "projectState": "LIVE",
              "image": {
                "__typename": "Image",
                "id": "placeholder",
                "url": "https://www.kickerstart.com/image.png"
              },
              "goal": {
                "__typename": "Money",
                "amount": "500.0",
                "currency": "USD",
                "symbol": "$"
              },
              "pledged": {
                "__typename": "Money",
                "amount": "250.0",
                "currency": "USD",
                "symbol": "$"
              },
              "isLaunched": true,
              "projectPrelaunchActivated": false,
              "deadlineAt": \(endingInDays),
              "projectLaunchedAt": 1706727593,
              "isWatched": false
    }
    """

    let fragment = try! GraphAPI.BackerDashboardProjectCellFragment(jsonString: jsonString)

    self.vm.inputs.configureWith(project: fragment)

    self.metadataIconIsHidden.assertValues([false])
    self.metadataText.assertValues(["10 days"])
    self.percentFundedText.assertValues(["50%"])
    self.photoURL.assertValues(["https://www.kickerstart.com/image.png"])
    self.progress.assertValues([0.5])
    self.progressBarColor.assertValues([LegacyColors.ksr_create_700.uiColor()])
    self.projectTitleText.assertValues(["Test Project Data Live"])
    self.savedIconIsHidden.assertValues([true])
  }

  func testProjectData_GraphQL_Successful() {
    let jsonString = """
        {
          "__typename": "Project",
          "projectId": "pid",
          "name": "Test Project Data Successful",
          "projectState": "SUCCESSFUL",
          "image": {
            "__typename": "Image",
            "id": "id",
            "url": "https://www.kickerstart.com/image.png"
          },
          "goal": {
            "__typename": "Money",
            "amount": "500.0",
            "currency": "CAD",
            "symbol": "$"
          },
          "pledged": {
            "__typename": "Money",
            "amount": "2000.00",
            "currency": "CAD",
            "symbol": "$"
          },
          "isLaunched": true,
          "projectPrelaunchActivated": false,
          "deadlineAt": 1625071247,
          "projectLaunchedAt": 1622479247,
          "isWatched": false
        }
    """

    let fragment = try! GraphAPI.BackerDashboardProjectCellFragment(jsonString: jsonString)

    self.vm.inputs.configureWith(project: fragment)

    self.metadataIconIsHidden.assertValues([true])
    self.metadataText.assertValues(["Successful"])
    self.percentFundedText.assertValues(["400%"])
    self.photoURL.assertValues(["https://www.kickerstart.com/image.png"])
    self.progress.assertValues([4.0])
    self.progressBarColor.assertValues([LegacyColors.ksr_create_700.uiColor()])
    self.projectTitleText.assertValues(["Test Project Data Successful"])
    self.savedIconIsHidden.assertValues([true])
  }

  func testProjectData_GraphQL_Failed() {
    let jsonString = """
        {
          "__typename": "Project",
          "projectId": "pid",
          "name": "Test Project Data Failed",
          "projectState": "FAILED",
          "image": {
            "__typename": "Image",
            "id": "id",
            "url": "https://www.kickerstart.com/image.png"
          },
          "goal": {
            "__typename": "Money",
            "amount": "500.0",
            "currency": "CAD",
            "symbol": "$"
          },
          "pledged": {
            "__typename": "Money",
            "amount": "50.0",
            "currency": "CAD",
            "symbol": "$"
          },
          "isLaunched": true,
          "projectPrelaunchActivated": false,
          "deadlineAt": 1625071247,
          "projectLaunchedAt": 1622479247,
          "isWatched": false
        }
    """

    let fragment = try! GraphAPI.BackerDashboardProjectCellFragment(jsonString: jsonString)

    self.vm.inputs.configureWith(project: fragment)

    self.metadataIconIsHidden.assertValues([true])
    self.metadataText.assertValues(["Unsuccessful"])
    self.percentFundedText.assertValues(["10%"])
    self.photoURL.assertValues(["https://www.kickerstart.com/image.png"])
    self.progress.assertValues([0.1])
    self.progressBarColor.assertValues([LegacyColors.ksr_support_300.uiColor()])
    self.projectTitleText.assertValues(["Test Project Data Failed"])
    self.savedIconIsHidden.assertValues([true])
  }

  func testProjectData_GraphQL_Saved() {
    let endingInDays = self.endingIn(days: 94)

    let jsonString = """
      {
              "__typename": "Project",
              "projectId": "pid",
              "name": "Test Project Data Live",
              "projectState": "LIVE",
              "image": {
                "__typename": "Image",
                "id": "placeholder",
                "url": "https://www.kickerstart.com/image.png"
              },
              "goal": {
                "__typename": "Money",
                "amount": "500.0",
                "currency": "USD",
                "symbol": "$"
              },
              "pledged": {
                "__typename": "Money",
                "amount": "250.0",
                "currency": "USD",
                "symbol": "$"
              },
              "isLaunched": true,
              "projectPrelaunchActivated": false,
              "deadlineAt": \(endingInDays),
              "projectLaunchedAt": 1706727593,
              "isWatched": true
    }
    """

    let fragment = try! GraphAPI.BackerDashboardProjectCellFragment(jsonString: jsonString)

    self.vm.inputs.configureWith(project: fragment)

    self.metadataIconIsHidden.assertValues([false])
    self.metadataText.assertValues(["94 days"])
    self.percentFundedText.assertValues(["50%"])
    self.photoURL.assertValues(["https://www.kickerstart.com/image.png"])
    self.progress.assertValues([0.5])
    self.progressBarColor.assertValues([LegacyColors.ksr_create_700.uiColor()])
    self.projectTitleText.assertValues(["Test Project Data Live"])
    self.savedIconIsHidden.assertValues([false])
  }

  func testProjectData_GraphQL_Prelaunch_Displayed() {
    let jsonString = """
        {
          "__typename": "Project",
          "projectId": "pid",
          "name": "Test Project Data Prelaunch",
          "projectState": "SUBMITTED",
          "image": {
            "__typename": "Photo",
            "id": "imageid",
            "url": "https://www.kickstarter.com/image.png"
          },
          "goal": {
            "__typename": "Money",
            "amount": "100000.0",
            "currency": "CAD",
            "symbol": "$"
          },
          "pledged": {
            "__typename": "Money",
            "amount": "0.0",
            "currency": "CAD",
            "symbol": "$"
          },
          "isLaunched": false,
          "projectPrelaunchActivated": true,
          "deadlineAt": null,
          "projectLaunchedAt": null,
          "isWatched": false
        }
    """

    let fragment = try! GraphAPI.BackerDashboardProjectCellFragment(jsonString: jsonString)

    self.vm.inputs.configureWith(project: fragment)

    self.prelaunchProject.assertValues([true])
    self.metadataText.assertValues(["Coming soon"])
  }

  func testProjectData_GraphQL_Prelaunch_ActivatedButNotDisplayed() {
    let jsonString = """
        {
          "__typename": "Project",
          "projectId": "pid",
          "name": "Test Project Data Successful",
          "projectState": "SUCCESSFUL",
          "image": {
            "__typename": "Image",
            "id": "id",
            "url": "https://www.kickerstart.com/image.png"
          },
          "goal": {
            "__typename": "Money",
            "amount": "500.0",
            "currency": "CAD",
            "symbol": "$"
          },
          "pledged": {
            "__typename": "Money",
            "amount": "2000.00",
            "currency": "CAD",
            "symbol": "$"
          },
          "isLaunched": true,
          "projectPrelaunchActivated": true,
          "deadlineAt": 1625071247,
          "projectLaunchedAt": 1622479247,
          "isWatched": false
        }
    """

    let fragment = try! GraphAPI.BackerDashboardProjectCellFragment(jsonString: jsonString)

    self.vm.inputs.configureWith(project: fragment)

    self.prelaunchProject.assertValues([false])
    self.metadataText.assertValues(["Successful"])
  }

  private func endingIn(days: Int) -> TimeInterval {
    self.dateType.init().timeIntervalSince1970 + 60.0 * 60.0 * 24.0 * Double(days)
  }
}
