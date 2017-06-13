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
  internal let metadataLabelText = TestObserver<String, NoError>()
  internal let metadataViewHidden = TestObserver<Bool, NoError>()
  internal let notifyDelegateShareButtonTapped = TestObserver<ShareContext, NoError>()
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
  internal let socialImageURL = TestObserver<String?, NoError>()
  internal let socialLabelText = TestObserver<String, NoError>()
  internal let socialStackViewHidden = TestObserver<Bool, NoError>()
  internal let starButtonSelected = TestObserver<Bool, NoError>()

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
    self.vm.outputs.metadataData.map { $0.labelText }.observe(self.metadataLabelText.observer)
    self.vm.outputs.metadataViewHidden.observe(self.metadataViewHidden.observer)
    self.vm.outputs.notifyDelegateShareButtonTapped.observe(self.notifyDelegateShareButtonTapped.observer)
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
    self.vm.outputs.socialImageURL.map { $0?.absoluteString }.observe(self.socialImageURL.observer)
    self.vm.outputs.socialLabelText.observe(self.socialLabelText.observer)
    self.vm.outputs.socialStackViewHidden.observe(self.socialStackViewHidden.observer)
    self.vm.outputs.starButtonSelected.observe(self.starButtonSelected.observer)
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

  func testTappedShareButton() {
    let project = Project.template
    let discoveryContext = ShareContext.discovery(project)

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.shareButtonTapped()
    self.notifyDelegateShareButtonTapped.assertValues([discoveryContext])
  }

  func testTappedStarButton() {
    let project = Project.template
    let toggleStarResponse = .template
      |> StarEnvelope.lens.project .~ (project |> Project.lens.personalization.isStarred .~ true)

      withEnvironment(apiService: MockService(toggleStarResponse: toggleStarResponse)) {

        self.starButtonSelected.assertDidNotEmitValue("No values emitted at first.")

        self.vm.inputs.configureWith(project: project)

        self.vm.inputs.userSessionStarted()

        self.vm.inputs.starButtonTapped()

        self.notifyDelegateShowSaveAlert.assertValueCount(1)
    }
  }

  func testMetadata() {
    let featuredAt = AppEnvironment.current.calendar.startOfDay(for: MockDate().date).timeIntervalSince1970
    let potdAt = AppEnvironment.current.calendar.startOfDay(for: MockDate().date).timeIntervalSince1970

    let backedProject = .template
      |> Project.lens.personalization.isBacking .~ true

    let featuredProject = .template
      |> Project.lens.category.parent .~ Category.art
      |> Project.lens.dates.featuredAt .~ featuredAt

    let starredAndPotdProject = .template
      |> Project.lens.dates.potdAt .~ potdAt
      |> Project.lens.personalization.isStarred .~ true

    let backedStarredAndPotdProject = .template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.isStarred .~ true
      |> Project.lens.dates.potdAt .~ potdAt

    let potdAndFeaturedProject = .template
      |> Project.lens.dates.potdAt .~ potdAt
      |> Project.lens.dates.featuredAt .~ featuredAt

    withEnvironment(currentUser: nil) {
      self.vm.inputs.configureWith(project: Project.template)

      self.metadataLabelText.assertValues([], "No metadata shown for logged out user.")
      self.metadataViewHidden.assertValues([true])

      AppEnvironment.login(AccessTokenEnvelope(accessToken: "dadbeeef", user: User.template))
      self.vm.inputs.configureWith(project: backedProject)

      self.metadataLabelText.assertValues([Strings.discovery_baseball_card_metadata_backer()])
      self.metadataViewHidden.assertValues([true, false])

      self.vm.inputs.configureWith(project: starredAndPotdProject)

      self.metadataLabelText.assertValues(
        [
          Strings.discovery_baseball_card_metadata_backer(),
          Strings.discovery_baseball_card_metadata_project_of_the_Day()
        ], "Starred metadata takes precedence.")

      self.vm.inputs.configureWith(project: backedStarredAndPotdProject)
      self.metadataLabelText.assertValues(
        [
          Strings.discovery_baseball_card_metadata_backer(),
          Strings.discovery_baseball_card_metadata_project_of_the_Day(),
          Strings.discovery_baseball_card_metadata_backer()
        ], "Backed metadata takes precedence.")

      self.vm.inputs.configureWith(project: featuredProject)
      self.metadataLabelText.assertValues(
        [
          Strings.discovery_baseball_card_metadata_backer(),
          Strings.discovery_baseball_card_metadata_project_of_the_Day(),
          Strings.discovery_baseball_card_metadata_backer(),
          Strings.discovery_baseball_card_metadata_featured_project(
            category_name: featuredProject.category.name
          )
        ], "Featured metadata emits.")

      self.vm.inputs.configureWith(project: potdAndFeaturedProject)
      self.metadataLabelText.assertValues(
        [
          Strings.discovery_baseball_card_metadata_backer(),
          Strings.discovery_baseball_card_metadata_project_of_the_Day(),
          Strings.discovery_baseball_card_metadata_backer(),
          Strings.discovery_baseball_card_metadata_featured_project(
            category_name: featuredProject.category.name
          ),
          Strings.discovery_baseball_card_metadata_project_of_the_Day()
        ], "Potd metadata takes precedence.")

      AppEnvironment.logout()

      // Implement when updating DiscoveryPageVC logout behavior.
      // self.metadataViewHidden.assertValues([true, false, true])
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

    let greenColor = UIColor.ksr_text_green_700
    let navyColor = UIColor.ksr_text_navy_700

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
