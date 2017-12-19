import Prelude
import Result
import XCTest
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers

internal final class DiscoveryPostcardViewModelTests: TestCase {
  internal let vm = DiscoveryPostcardViewModel()
  internal let backersTitleLabelText = TestObserver<String, NoError>()
  internal let cellAccessibilityLabel = TestObserver<String, NoError>()
  internal let cellAccessibilityValue = TestObserver<String, NoError>()
  internal let deadlineSubtitleLabelText = TestObserver<String, NoError>()
  internal let deadlineTitleLabelText = TestObserver<String, NoError>()
  internal let fundingProgressBarViewHidden = TestObserver<Bool, NoError>()
  internal let fundingProgressContainerViewHidden = TestObserver<Bool, NoError>()
  internal let metadataIcon = TestObserver<UIImage?, NoError>()
  internal let metadataIconTintColor = TestObserver<UIColor, NoError>()
  internal let metadataTextColor = TestObserver<UIColor, NoError>()
  internal let metadataLabelText = TestObserver<String, NoError>()
  internal let metadataViewHidden = TestObserver<Bool, NoError>()
  internal let notifyDelegateShowLoginTout = TestObserver<Void, NoError>()
  internal let notifyDelegateShowSaveAlert = TestObserver<Void, NoError>()
  internal let percentFundedTitleLabelText = TestObserver<String, NoError>()
  internal let progressPercentage = TestObserver<Float, NoError>()
  internal let projectImageURL = TestObserver<String?, NoError>()
  internal let projectNameAndBlurbLabelText = TestObserver<String, NoError>()
  internal let projectStateIconHidden = TestObserver<Bool, NoError>()
  internal let projectStateStackViewHidden = TestObserver<Bool, NoError>()
  internal let projectStateSubtitleLabelText = TestObserver<String, NoError>()
  internal let projectStateTitleLabelColor = TestObserver<UIColor, NoError>()
  internal let projectStateTitleLabelText = TestObserver<String, NoError>()
  internal let projectStatsStackViewHidden = TestObserver<Bool, NoError>()
  internal let saveButtonEnabled = TestObserver<Bool, NoError>()
  internal let saveButtonSelected = TestObserver<Bool, NoError>()
  internal let socialImageURL = TestObserver<String?, NoError>()
  internal let socialLabelText = TestObserver<String, NoError>()
  internal let socialStackViewHidden = TestObserver<Bool, NoError>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.backersTitleLabelText.observe(self.backersTitleLabelText.observer)
    self.vm.outputs.cellAccessibilityLabel.observe(self.cellAccessibilityLabel.observer)
    self.vm.outputs.cellAccessibilityValue.observe(self.cellAccessibilityValue.observer)
    self.vm.outputs.deadlineSubtitleLabelText.observe(self.deadlineSubtitleLabelText.observer)
    self.vm.outputs.deadlineTitleLabelText.observe(self.deadlineTitleLabelText.observer)
    self.vm.outputs.fundingProgressBarViewHidden.observe(self.fundingProgressBarViewHidden.observer)
    self.vm.outputs.fundingProgressContainerViewHidden
      .observe(self.fundingProgressContainerViewHidden.observer)
    self.vm.outputs.metadataIcon.observe(self.metadataIcon.observer)
    self.vm.outputs.metadataTextColor.observe(self.metadataTextColor.observer)
    self.vm.outputs.metadataIconImageViewTintColor.observe(self.metadataIconTintColor.observer)
    self.vm.outputs.metadataLabelText.observe(self.metadataLabelText.observer)
    self.vm.outputs.metadataViewHidden.observe(self.metadataViewHidden.observer)
    self.vm.outputs.notifyDelegateShowLoginTout.observe(self.notifyDelegateShowLoginTout.observer)
    self.vm.notifyDelegateShowSaveAlert.observe(self.notifyDelegateShowSaveAlert.observer)
    self.vm.outputs.percentFundedTitleLabelText.observe(self.percentFundedTitleLabelText.observer)
    self.vm.outputs.progressPercentage.observe(self.progressPercentage.observer)
    self.vm.outputs.projectImageURL.map { $0?.absoluteString }.observe(self.projectImageURL.observer)
    self.vm.outputs.projectNameAndBlurbLabelText
      .map { $0.string }.observe(self.projectNameAndBlurbLabelText.observer)
    self.vm.outputs.projectStateIconHidden.observe(self.projectStateIconHidden.observer)
    self.vm.outputs.projectStateStackViewHidden.observe(self.projectStateStackViewHidden.observer)
    self.vm.outputs.projectStateSubtitleLabelText.observe(self.projectStateSubtitleLabelText.observer)
    self.vm.outputs.projectStateTitleLabelColor.observe(self.projectStateTitleLabelColor.observer)
    self.vm.outputs.projectStateTitleLabelText.observe(self.projectStateTitleLabelText.observer)
    self.vm.outputs.projectStatsStackViewHidden.observe(self.projectStatsStackViewHidden.observer)
    self.vm.outputs.saveButtonEnabled.observe(self.saveButtonEnabled.observer)
    self.vm.outputs.saveButtonSelected.observe(self.saveButtonSelected.observer)
    self.vm.outputs.socialImageURL.map { $0?.absoluteString }.observe(self.socialImageURL.observer)
    self.vm.outputs.socialLabelText.observe(self.socialLabelText.observer)
    self.vm.outputs.socialStackViewHidden.observe(self.socialStackViewHidden.observer)
  }

  func testCellAccessibility() {
    let project = .template
      |> Project.lens.name .~ "Hammocks for All"
      |> Project.lens.blurb .~ "Let's make hammocks universal for all creatures!"

    self.vm.inputs.configureWith(project: project)
    self.cellAccessibilityLabel.assertValues([project.name])
    self.cellAccessibilityValue.assertValues([project.blurb + ". "])
  }

  func testCellAccessibilityProjectCancelledState() {
    let project = .template
      |> Project.lens.name .~ "Hammocks for All"
      |> Project.lens.blurb .~ "Let's make hammocks universal for all creatures!"
      |> Project.lens.state .~ .canceled

    self.vm.inputs.configureWith(project: project)
    self.cellAccessibilityLabel.assertValues([project.name])
    self.cellAccessibilityValue.assertValues([project.blurb + ". " + "Project cancelled"])
  }

  func testSaveAlertNotification() {
    let project = .template |> Project.lens.personalization.isStarred .~ false

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.saveButtonTapped()
    self.scheduler.advance()
    self.notifyDelegateShowSaveAlert.assertValueCount(1)
  }

  func testSaveProject_WithError() {
    let error = ErrorEnvelope(
      errorMessages: ["Something went wrong."],
      ksrCode: .UnknownCode,
      httpCode: 404,
      exception: nil
    )

    let project = Project.template

    withEnvironment(apiService: MockService(toggleStarError: error), currentUser: .template) {

      self.vm.inputs.configureWith(project: project)

      self.saveButtonSelected.assertValues([false], "Save button is not selected at first.")
      self.saveButtonEnabled.assertValueCount(0)

      self.vm.inputs.saveButtonTapped()

      self.saveButtonSelected.assertValues([false, false],
                                           "Emits false because the project personalization value is nil.")
      self.saveButtonEnabled.assertValues([false], "Save button is disabled while request is being made.")

      self.scheduler.advance()

      self.saveButtonSelected.assertValues([false, false, false], "Emits again with error.")
      self.saveButtonEnabled.assertValues([false, true], "Save button is enabled after request.")

    }
  }

  func testTappedSaveButton_LoggedIn_User() {
    let project = Project.template
      |> Project.lens.personalization.isStarred .~ true
    let toggleSaveResponse = .template
      |> StarEnvelope.lens.project .~ project

    withEnvironment(apiService: MockService(toggleStarResponse: toggleSaveResponse),
                    currentUser: .template) {

        self.vm.inputs.configureWith(project: project)

        self.saveButtonSelected.assertValues([true], "Save button is selected at first.")
        self.saveButtonEnabled.assertValueCount(0)

        self.vm.inputs.saveButtonTapped()

        self.saveButtonSelected.assertValues([true, false], "Emits false immediately.")
        self.saveButtonEnabled.assertValues([false], "Save button is disabled during request.")

        self.scheduler.advance()

        self.saveButtonSelected.assertValues([true, false], "Save button remains deselected after request.")
        self.saveButtonEnabled.assertValues([false, true], "Save is enabled after request.")
    }
  }

  func testTappedSaveButton_LoggedOut_User() {
    let project = Project.template
      |> Project.lens.personalization.isStarred .~ false
    let toggleSaveResponse = .template
      |> StarEnvelope.lens.project .~ project

      withEnvironment(apiService: MockService(toggleStarResponse: toggleSaveResponse)) {

        self.vm.inputs.configureWith(project: project)

        self.saveButtonSelected.assertValues([false], "Save button is not selected for logged out user.")
        self.saveButtonEnabled.assertValueCount(0)

        self.vm.inputs.saveButtonTapped()

        self.saveButtonSelected.assertValues([false],
                                              "Nothing is emitted when save button tapped while logged out.")
        self.saveButtonEnabled.assertValueCount(0)

        self.notifyDelegateShowLoginTout.assertValueCount(1,
                                                "Prompt to login when save button tapped while logged out.")

        AppEnvironment.login(.init(accessToken: "deadbeef", user: .template))
        self.vm.inputs.userSessionStarted()

        self.saveButtonSelected.assertValues([false, true],
                                              "Once logged in, the save button is selected immediately.")
        self.saveButtonEnabled.assertValues([false], "Save button is disabled during request.")

        self.scheduler.advance()

        self.saveButtonSelected.assertValues([false, true],
                                             "Save button stays selected after API request.")
        self.saveButtonEnabled.assertValues([false, true], "Save button is enabled after request.")

        let untoggleSaveResponse = .template
          |> StarEnvelope.lens.project .~ (project |> Project.lens.personalization.isStarred .~ false)

        withEnvironment(apiService: MockService(toggleStarResponse: untoggleSaveResponse)) {
          self.vm.inputs.saveButtonTapped()

          self.saveButtonSelected.assertValues([false, true, false],
                                               "Save button is deselected.")
          self.saveButtonEnabled.assertValues([false, true, false], "Save button is disabled during request.")

          self.scheduler.advance()

          self.saveButtonSelected.assertValues([false, true, false],
                                               "The save button remains unselected.")
          self.saveButtonEnabled.assertValues([false, true, false, true],
                                              "Save button is enabled after request.")

      }
    }
  }

  func testSaveProjectFromPamphlet() {
    let project = Project.template
      |> Project.lens.personalization.isStarred .~ false
    let toggleSaveResponse = .template
      |> StarEnvelope.lens.project .~ project
    let projectUpdated = project
      |> Project.lens.personalization.isStarred .~ true

    withEnvironment(apiService: MockService(toggleStarResponse: toggleSaveResponse)) {
      self.vm.inputs.configureWith(project: project)

      self.saveButtonSelected.assertValues([false])

      self.vm.inputs.projectFromNotification(project: projectUpdated)

      self.saveButtonSelected.assertValues([false, true])
    }
  }

  func testMetadata() {
    let featuredAt = AppEnvironment.current.calendar.startOfDay(for: MockDate().date).timeIntervalSince1970

    let backedProject = .template
      |> Project.lens.personalization.isBacking .~ true

    let featuredProject = .template
      |> Project.lens.category.parent .~ ParentCategory(id: Category.art.id,
                                                        name: Category.art.name)
      |> Project.lens.dates.featuredAt .~ featuredAt

    let backedColor: UIColor = .ksr_green_700
    let featuredColor: UIColor = .ksr_dark_grey_900

    let backedImage = image(named: "metadata-backing")
    let featuredImage = image(named: "metadata-featured")

    withEnvironment(currentUser: nil) {
      self.vm.inputs.configureWith(project: Project.template)

      self.metadataLabelText.assertValueCount(0, "No metadata shown for logged out user.")
      self.metadataViewHidden.assertValues([true])

      AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeeef", user: User.template))
      self.vm.inputs.configureWith(project: backedProject)

      self.metadataLabelText.assertValues([Strings.discovery_baseball_card_metadata_backer()])
      self.metadataViewHidden.assertValues([true, false])
      self.metadataIcon.assertValues([backedImage])
      self.metadataTextColor.assertValues([backedColor])
      self.metadataIconTintColor.assertValues([backedColor])

      self.metadataLabelText.assertValues(
        [
          Strings.discovery_baseball_card_metadata_backer(),
        ], "Starred metadata takes precedence.")

      self.metadataViewHidden.assertValues([true, false])
      self.metadataIcon.assertValues([backedImage])
      self.metadataTextColor.assertValues([backedColor])
      self.metadataIconTintColor.assertValues([backedColor])

      self.vm.inputs.configureWith(project: featuredProject)
      self.metadataLabelText.assertValues(
        [
          Strings.discovery_baseball_card_metadata_backer(),
          Strings.discovery_baseball_card_metadata_featured_project(
            category_name: featuredProject.category.name
          )
        ], "Featured metadata emits.")

      self.metadataViewHidden.assertValues([true, false, false])
      self.metadataIcon.assertValues([backedImage, featuredImage])
      self.metadataTextColor.assertValues([backedColor, featuredColor])
      self.metadataIconTintColor.assertValues([backedColor, featuredColor])

      AppEnvironment.logout()

      // Implement when updating DiscoveryPageVC logout behavior.
       self.metadataViewHidden.assertValues([true, false, false])
    }
  }

  func testProjectStatsEmit() {
    let project = Project.template

    self.vm.inputs.configureWith(project: project)

    self.backersTitleLabelText.assertValues([Format.wholeNumber(project.stats.backersCount)])

    let deadlineTitleAndSubtitle = Format.duration(secondsInUTC: project.dates.deadline, useToGo: true)
    self.deadlineSubtitleLabelText.assertValues([deadlineTitleAndSubtitle.unit])
    self.deadlineTitleLabelText.assertValues([deadlineTitleAndSubtitle.time])

    self.percentFundedTitleLabelText.assertValues(
      [Format.percentage(project.stats.percentFunded)]
    )

    self.progressPercentage.assertValues([project.stats.fundingProgress])
    self.projectImageURL.assertValues([project.photo.full])
    self.projectNameAndBlurbLabelText.assertValues(
      ["\(project.name): \(project.blurb)"]
    )
  }

  func testProjectNamePunctuationIsRetained() {
    let project = .template
      |> Project.lens.name .~ "The Turtle Hat. Helping people come out of their shells!"

    self.vm.inputs.configureWith(project: project)

    self.projectNameAndBlurbLabelText.assertValues(
      ["\(project.name) \(project.blurb)"]
    )
  }

  func testSocialData() {
    let oneFriend = [.template |> User.lens.name .~ "Milky"]

    let twoFriends = [
      .template |> User.lens.name .~ "Chad",
      .template |> User.lens.name .~ "Brad"
    ]

    let manyFriends = [
      .template |> User.lens.name .~ "Gayle",
      .template |> User.lens.name .~ "Eugene",
      .template |> User.lens.name .~ "Nancy",
      .template |> User.lens.name .~ "Phillis"
    ]

    let projectNoSocial = .template
      |> Project.lens.personalization.friends .~ nil

    let projectNoFriends = .template
      |> Project.lens.personalization.friends .~ []

    let projectOneFriend = .template
      |> Project.lens.personalization.friends .~ oneFriend

    let projectTwoFriends = .template
      |> Project.lens.personalization.friends .~ twoFriends

    let projectManyFriends = .template
      |> Project.lens.personalization.friends .~ manyFriends

    self.vm.inputs.configureWith(project: projectNoSocial)
    self.socialImageURL.assertValues([nil])
    self.socialLabelText.assertValues([""])
    self.socialStackViewHidden.assertValues([true])

    self.vm.inputs.configureWith(project: projectNoFriends)
    self.socialImageURL.assertValues([nil, nil])
    self.socialLabelText.assertValues(["", ""])
    self.socialStackViewHidden.assertValues([true])

    self.vm.inputs.configureWith(project: projectOneFriend)
    self.socialImageURL.assertValues([nil, nil, oneFriend[0].avatar.medium])
    self.socialLabelText.assertValues(
      [ "", "", Strings.project_social_friend_is_backer(friend_name: oneFriend[0].name) ]
    )
    self.socialStackViewHidden.assertValues([true, false])

    self.vm.inputs.configureWith(project: projectTwoFriends)
    self.socialImageURL.assertValues([nil, nil, oneFriend[0].avatar.medium, twoFriends[0].avatar.medium],
                                     "First friend's avatar emits.")
    self.socialLabelText.assertValues(
      [ "", "",
        Strings.project_social_friend_is_backer(friend_name: oneFriend.first?.name ?? ""),
        Strings.project_social_friend_and_friend_are_backers(friend_name: twoFriends[0].name,
          second_friend_name: twoFriends[1].name)
      ]
    )
    self.socialStackViewHidden.assertValues([true, false])

    self.vm.inputs.configureWith(project: projectManyFriends)
    self.socialImageURL.assertValues([nil, nil, oneFriend[0].avatar.medium, twoFriends[0].avatar.medium,
      manyFriends[0].avatar.medium], "First friend's avatar emits.")
    self.socialLabelText.assertValues(
      [ "", "",
        Strings.project_social_friend_is_backer(friend_name: oneFriend.first?.name ?? ""),
        Strings.project_social_friend_and_friend_are_backers(friend_name: twoFriends[0].name,
          second_friend_name: twoFriends[1].name),
        Strings.discovery_baseball_card_social_friends_are_backers(friend_name: manyFriends[0].name,
          second_friend_name: manyFriends[1].name, remaining_count: manyFriends.count - 2)
      ]
    )
    self.socialStackViewHidden.assertValues([true, false])
  }

  func testStatsAndStateViews() {
    let canceled = .template |> Project.lens.state .~ .canceled
    let failed = .template |> Project.lens.state .~ .failed
    let live = .template |> Project.lens.state .~ .live
    let successful = .template |> Project.lens.state .~ .successful
    let suspended = .template |> Project.lens.state .~ .suspended

    let greenColor = UIColor.ksr_green_700
    let navyColor = UIColor.ksr_text_dark_grey_900

    self.vm.inputs.configureWith(project: live)
    self.projectStateStackViewHidden.assertValues([true])
    self.projectStateSubtitleLabelText.assertValueCount(1, "Empty subtitle string emits.")
    self.projectStatsStackViewHidden.assertValues([false])
    self.fundingProgressContainerViewHidden.assertValues([false])
    self.fundingProgressBarViewHidden.assertValues([false])

    self.vm.inputs.configureWith(project: canceled)
    self.projectStateIconHidden.assertValues([true, true])
    self.projectStateSubtitleLabelText.assertValueCount(2)
    self.projectStateTitleLabelText.assertValues(["",
      Strings.Project_cancelled()])
    self.projectStateTitleLabelColor.assertValues([navyColor])
    self.projectStateStackViewHidden.assertValues([true, false])
    self.projectStatsStackViewHidden.assertValues([false, true])
    self.fundingProgressBarViewHidden.assertValues([false, false])
    self.fundingProgressContainerViewHidden.assertValues([false, true])

    self.vm.inputs.configureWith(project: failed)
    self.projectStateIconHidden.assertValues([true, true, true])
    self.projectStateSubtitleLabelText.assertValueCount(3)
    self.projectStateTitleLabelText.assertValues(
      [
        "",
        Strings.Project_cancelled(),
        Strings.dashboard_creator_project_funding_unsuccessful()
      ]
    )
    self.projectStateTitleLabelColor.assertValues([navyColor])
    self.projectStateStackViewHidden.assertValues([true, false])
    self.projectStatsStackViewHidden.assertValues([false, true])
    self.fundingProgressBarViewHidden.assertValues([false, false, true])
    self.fundingProgressContainerViewHidden.assertValues([false, true, false])

    self.vm.inputs.configureWith(project: successful)
    self.projectStateIconHidden.assertValues([true, true, true, false])
    self.projectStateSubtitleLabelText.assertValueCount(4)
    self.projectStateTitleLabelText.assertValues(
      [
        "",
        Strings.Project_cancelled(),
        Strings.dashboard_creator_project_funding_unsuccessful(),
        Strings.Funding_successful()
      ]
    )
    self.projectStateTitleLabelColor.assertValues([navyColor, greenColor])
    self.projectStateStackViewHidden.assertValues([true, false])
    self.projectStatsStackViewHidden.assertValues([false, true])
    self.fundingProgressBarViewHidden.assertValues([false, false, true, false])
    self.fundingProgressContainerViewHidden.assertValues([false, true, false, false])

    self.vm.inputs.configureWith(project: suspended)
    self.projectStateIconHidden.assertValues([true, true, true, false, true])
    self.projectStateSubtitleLabelText.assertValueCount(5)
    self.projectStateTitleLabelText.assertValues(
      [
        "",
        Strings.Project_cancelled(),
        Strings.dashboard_creator_project_funding_unsuccessful(),
        Strings.Funding_successful(),
        Strings.dashboard_creator_project_funding_suspended()
      ]
    )
    self.projectStateTitleLabelColor.assertValues([navyColor, greenColor, navyColor])
    self.projectStateStackViewHidden.assertValues([true, false])
    self.projectStatsStackViewHidden.assertValues([false, true])
    self.fundingProgressBarViewHidden.assertValues([false, false, true, false, false])
    self.fundingProgressContainerViewHidden.assertValues([false, true, false, false, true])
  }
}
