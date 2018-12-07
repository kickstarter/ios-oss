import Prelude
import Result
import XCTest
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers

/* swiftlint:disable force_unwrapping */
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
  internal let projectCategoryName = TestObserver<String, NoError>()
  internal let projectCategoryViewHidden = TestObserver<Bool, NoError>()
  internal let projectCategoryStackViewHidden = TestObserver<Bool, NoError>()
  internal let projectIsStaffPickViewHidden = TestObserver<Bool, NoError>()

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

    self.vm.outputs.projectCategoryName.observe(self.projectCategoryName.observer)
    self.vm.outputs.projectCategoryViewHidden.observe(self.projectCategoryViewHidden.observer)
    self.vm.outputs.projectCategoryStackViewHidden.observe(self.projectCategoryStackViewHidden.observer)
    self.vm.outputs.projectIsStaffPickLabelHidden.observe(self.projectIsStaffPickViewHidden.observer)
  }

  func testCellAccessibility() {
    let project = .template
      |> Project.lens.name .~ "Hammocks for All"
      |> Project.lens.blurb .~ "Let's make hammocks universal for all creatures!"

    self.vm.inputs.configureWith(project: project, category: nil)
    self.cellAccessibilityLabel.assertValues([project.name])
    self.cellAccessibilityValue.assertValues([project.blurb + ". "])
  }

  func testCellAccessibilityProjectCancelledState() {
    let project = .template
      |> Project.lens.name .~ "Hammocks for All"
      |> Project.lens.blurb .~ "Let's make hammocks universal for all creatures!"
      |> Project.lens.state .~ .canceled

    self.vm.inputs.configureWith(project: project, category: nil)
    self.cellAccessibilityLabel.assertValues([project.name])
    self.cellAccessibilityValue.assertValues([project.blurb + ". " + "Project cancelled"])
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
    let featuredColor: UIColor = .ksr_soft_black

    let backedImage = image(named: "metadata-backing")
    let featuredImage = image(named: "metadata-featured")

    withEnvironment(currentUser: nil) {
      self.vm.inputs.configureWith(project: Project.template, category: nil)

      self.metadataLabelText.assertValueCount(0, "No metadata shown for logged out user.")
      self.metadataViewHidden.assertValues([true])

      AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeeef", user: User.template))
      self.vm.inputs.configureWith(project: backedProject, category: nil)

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

      self.vm.inputs.configureWith(project: featuredProject, category: nil)
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

    self.vm.inputs.configureWith(project: project, category: nil)

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

    self.vm.inputs.configureWith(project: project, category: nil)

    self.projectNameAndBlurbLabelText.assertValues(
      ["\(project.name) \(project.blurb)"]
    )
  }

  func testSocialData() {
    let oneFriend = [User.template |> \.name .~ "Milky"]

    let twoFriends = [
      User.template |> \.name .~ "Chad",
      User.template |> \.name .~ "Brad"
    ]

    let manyFriends = [
      User.template |> \.name .~ "Gayle",
      User.template |> \.name .~ "Eugene",
      User.template |> \.name .~ "Nancy",
      User.template |> \.name .~ "Phillis"
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

    self.vm.inputs.configureWith(project: projectNoSocial, category: nil)
    self.socialImageURL.assertValues([nil])
    self.socialLabelText.assertValues([""])
    self.socialStackViewHidden.assertValues([true])

    self.vm.inputs.configureWith(project: projectNoFriends, category: nil)
    self.socialImageURL.assertValues([nil, nil])
    self.socialLabelText.assertValues(["", ""])
    self.socialStackViewHidden.assertValues([true])

    self.vm.inputs.configureWith(project: projectOneFriend, category: nil)
    self.socialImageURL.assertValues([nil, nil, oneFriend[0].avatar.medium])
    self.socialLabelText.assertValues(
      [ "", "", Strings.project_social_friend_is_backer(friend_name: oneFriend[0].name) ]
    )
    self.socialStackViewHidden.assertValues([true, false])

    self.vm.inputs.configureWith(project: projectTwoFriends, category: nil)
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

    self.vm.inputs.configureWith(project: projectManyFriends, category: nil)
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

    self.vm.inputs.configureWith(project: live, category: nil)
    self.projectStateStackViewHidden.assertValues([true])
    self.projectStateSubtitleLabelText.assertValueCount(1, "Empty subtitle string emits.")
    self.projectStatsStackViewHidden.assertValues([false])
    self.fundingProgressContainerViewHidden.assertValues([false])
    self.fundingProgressBarViewHidden.assertValues([false])

    self.vm.inputs.configureWith(project: canceled, category: nil)
    self.projectStateIconHidden.assertValues([true, true])
    self.projectStateSubtitleLabelText.assertValueCount(2)
    self.projectStateTitleLabelText.assertValues(["",
      Strings.Project_cancelled()])
    self.projectStateTitleLabelColor.assertValues([navyColor])
    self.projectStateStackViewHidden.assertValues([true, false])
    self.projectStatsStackViewHidden.assertValues([false, true])
    self.fundingProgressBarViewHidden.assertValues([false, false])
    self.fundingProgressContainerViewHidden.assertValues([false, true])

    self.vm.inputs.configureWith(project: failed, category: nil)
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

    self.vm.inputs.configureWith(project: successful, category: nil)
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

    self.vm.inputs.configureWith(project: suspended, category: nil)
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

  // MARK: Project Category View
  func testShowsCategoryLabels_ParentCategorySelected() {
    let staffPickProject = Project.template
      |> Project.lens.staffPick .~ true
      |> Project.lens.category .~ .illustration

    self.vm.inputs.configureWith(project: staffPickProject, category: .art)

    self.projectIsStaffPickViewHidden.assertValue(false)
    self.projectCategoryStackViewHidden.assertValue(false)
    self.projectCategoryName.assertValue(KsApi.Category.illustration.name)
    self.projectCategoryViewHidden.assertValue(false)
  }

  func testShowsCategoryLabels_AlwaysIfFilterCategoryIsNil() {
    self.vm.inputs.configureWith(project: Project.template, category: nil)

    self.projectCategoryStackViewHidden.assertValue(false)
  }

  func testHidesCategoryLabel_IfFilterCategoryIsEqualToProjectCategory() {
    // Workaround for discrepancy between category ids from graphQL and category ids from the legacy API
    let categoryId = KsApi.Category.illustration.intID
    let illustrationCategory = KsApi.Category.illustration
      |> KsApi.Category.lens.id .~ String(categoryId!)

    let illustrationProject = Project.template
      |> Project.lens.category .~ illustrationCategory

    self.vm.inputs.configureWith(project: illustrationProject, category: .illustration)

    self.projectIsStaffPickViewHidden.assertValue(true)
    self.projectCategoryStackViewHidden.assertValue(true)
    self.projectCategoryName.assertValue(KsApi.Category.illustration.name)
    self.projectCategoryViewHidden.assertValue(true)
  }
}
