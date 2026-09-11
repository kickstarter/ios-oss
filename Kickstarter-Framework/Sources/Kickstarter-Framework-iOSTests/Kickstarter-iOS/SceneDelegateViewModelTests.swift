import GraphAPI
@testable import Kickstarter_Framework
@testable import KsApi
@testable import KsApiTestHelpers
@testable import Library
@testable import LibraryTestHelpers
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import UserNotifications
import XCTest

final class SceneDelegateViewModelTests: TestCase {
  var vm: SceneDelegateViewModelType!

  private let emailVerificationCompletedMessage = TestObserver<String, Never>()
  private let emailVerificationCompletedSuccess = TestObserver<Bool, Never>()
  private let findRedirectUrl = TestObserver<URL, Never>()
  private let goToActivity = TestObserver<(), Never>()
  private let goToDiscovery = TestObserver<DiscoveryParams?, Never>()
  private let goToLoginWithIntent = TestObserver<LoginIntent, Never>()
  private let goToProfile = TestObserver<(), Never>()
  private let goToMobileSafari = TestObserver<URL, Never>()
  private let goToSearch = TestObserver<(), Never>()
  private let presentViewController = TestObserver<Int, Never>()
  private let updateCurrentUserInEnvironment = TestObserver<User, Never>()

  private var defaultRootCategoriesTemplate: RootCategoriesEnvelope {
    RootCategoriesEnvelope.template
      |> RootCategoriesEnvelope.lens.categories .~ [
        .art,
        .filmAndVideo,
        .illustration,
        .documentary
      ]
  }

  override func setUp() {
    super.setUp()

    self.vm = SceneDelegateViewModel()

    self.vm.outputs.emailVerificationCompleted.map(first)
      .observe(self.emailVerificationCompletedMessage.observer)
    self.vm.outputs.emailVerificationCompleted.map(second)
      .observe(self.emailVerificationCompletedSuccess.observer)
    self.vm.outputs.findRedirectUrl.observe(self.findRedirectUrl.observer)
    self.vm.outputs.goToActivity.observe(self.goToActivity.observer)
    self.vm.outputs.goToDiscovery.observe(self.goToDiscovery.observer)
    self.vm.outputs.goToLoginWithIntent.observe(self.goToLoginWithIntent.observer)
    self.vm.outputs.goToProfile.observe(self.goToProfile.observer)
    self.vm.outputs.goToMobileSafari.observe(self.goToMobileSafari.observer)
    self.vm.outputs.goToSearch.observe(self.goToSearch.observer)
    self.vm.outputs.presentViewController.map { ($0 as! UINavigationController).viewControllers.count }
      .observe(self.presentViewController.observer)
    self.vm.outputs.updateCurrentUserInEnvironment.observe(self.updateCurrentUserInEnvironment.observer)
  }

  func testPresentViewController() {
    let apiService = MockService(
      fetchProjectResult: .success(.template),
      fetchUpdateResponse: .template
    )
    withEnvironment(apiService: apiService) {
      let rootUrl = "https://www.kickstarter.com/"

      self.presentViewController.assertValues([])

      let projectUrl = rootUrl + "projects/tequila/help-me-transform-this-pile-of-wood"
      var result = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: URL(string: projectUrl)!,
        options: [:]
      )
      XCTAssertTrue(result)

      self.presentViewController.assertValues([1])

      let commentsUrl = projectUrl + "/comments"
      result = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: URL(string: commentsUrl)!,
        options: [:]
      )
      XCTAssertTrue(result)

      self.presentViewController.assertValues([1, 2])

      let updatesUrl = projectUrl + "/posts"
      result = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: URL(string: updatesUrl)!,
        options: [:]
      )
      XCTAssertTrue(result)

      self.presentViewController.assertValues([1, 2, 2])

      let updateUrl = projectUrl + "/posts/1399396"
      result = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: URL(string: updateUrl)!,
        options: [:]
      )
      XCTAssertTrue(result)

      self.presentViewController.assertValues([1, 2, 2, 2])

      let updateCommentsUrl = updateUrl + "/comments"
      result = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: URL(string: updateCommentsUrl)!,
        options: [:]
      )
      XCTAssertTrue(result)

      self.presentViewController.assertValues([1, 2, 2, 2, 3])

      let faqUrl = projectUrl + "/faqs"
      result = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: URL(string: faqUrl)!,
        options: [:]
      )
      XCTAssertTrue(result)

      self.presentViewController.assertValues([1, 2, 2, 2, 3, 1])
    }
  }

  func testPresentViewController_ProjectPreviewLink_DisplayPrelaunch_True() {
    let project = Project.template
      |> Project.lens.displayPrelaunch .~ true

    let apiService = MockService(fetchProjectResult: .success(project))
    withEnvironment(apiService: apiService) {
      let rootUrl = "https://www.kickstarter.com/"

      self.presentViewController.assertValues([])

      let projectUrl = rootUrl + "projects/tequila/help-me-transform-this-pile-of-wood"
      let result = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: URL(string: projectUrl)!,
        options: [:]
      )
      XCTAssertTrue(result)

      self.presentViewController.assertValues([1])
      self.goToMobileSafari.assertValues([])
    }
  }

  func testPresentViewController_ProjectPreviewLink_DisplayPrelaunch_False() {
    let project = Project.template
      |> Project.lens.displayPrelaunch .~ false

    let apiService = MockService(fetchProjectResult: .success(project))
    withEnvironment(apiService: apiService) {
      let rootUrl = "https://www.kickstarter.com/"

      self.presentViewController.assertValues([])

      let projectUrl = rootUrl + "projects/tequila/help-me-transform-this-pile-of-wood"
      let result = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: URL(string: projectUrl)!,
        options: [:]
      )
      XCTAssertTrue(result)

      self.presentViewController.assertValues([1])
      self.goToMobileSafari.assertValues([])
    }
  }

  func testPresentViewController_ProjectPreviewLink_DisplayPrelaunch_Nil() {
    let project = Project.template
      |> Project.lens.displayPrelaunch .~ nil

    let apiService = MockService(fetchProjectResult: .success(project))
    withEnvironment(apiService: apiService) {
      let rootUrl = "https://www.kickstarter.com/"

      self.presentViewController.assertValues([])

      let projectUrl = rootUrl + "projects/tequila/help-me-transform-this-pile-of-wood"
      let result = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: URL(string: projectUrl)!,
        options: [:]
      )
      XCTAssertTrue(result)

      self.presentViewController.assertValues([1])
      self.goToMobileSafari.assertValues([])
    }
  }

  func testPresentViewController_ProjectCommentThread_Success() {
    withEnvironment(apiService: MockService(fetchCommentRepliesEnvelopeResult: .success(
      CommentRepliesEnvelope
        .successfulRepliesTemplate
    ), fetchProjectResult: .success(.template))) {
      let url =
        "https://\(AppEnvironment.current.apiService.serverConfig.webBaseUrl.host ?? "")/projects/fjorden/fjorden-iphone-photography-reinvented/comments?comment=Q29tbWVudC0zMzY0OTg0MQ%3D%3D"

      let result = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: URL(string: url)!,
        options: [:]
      )
      XCTAssertTrue(result)

      self.presentViewController.assertValues([3])
    }
  }

  func testPresentViewController_ProjectCommentThread_Reply_Success() {
    withEnvironment(apiService: MockService(fetchCommentRepliesEnvelopeResult: .success(
      CommentRepliesEnvelope
        .successfulRepliesTemplate
    ), fetchProjectResult: .success(.template))) {
      let url =
        "https://\(AppEnvironment.current.apiService.serverConfig.webBaseUrl.host ?? "")/projects/fjorden/fjorden-iphone-photography-reinvented/comments?comment=Q29tbWVudC0zMzY0OTg0MQ%3D%3D&reply=deadbeef"

      let result = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: URL(string: url)!,
        options: [:]
      )
      XCTAssertTrue(result)

      self.presentViewController.assertValues([3])
    }
  }

  func testPresentViewController_UpdateCommentThread_Success() {
    withEnvironment(apiService: MockService(fetchCommentRepliesEnvelopeResult: .success(
      CommentRepliesEnvelope
        .successfulRepliesTemplate
    ), fetchProjectResult: .success(.template))) {
      let url =
        "https://\(AppEnvironment.current.apiService.serverConfig.webBaseUrl.host ?? "")/projects/fjorden/fjorden-iphone-photography-reinvented/posts/3254626/comments?comment=Q29tbWVudC0zMzY0OTg0MQ%3D%3D"

      let result = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: URL(string: url)!,
        options: [:]
      )
      XCTAssertTrue(result)

      self.presentViewController.assertValues([4])
    }
  }

  func testPresentViewController_UpdateCommentThread_Reply_Success() {
    withEnvironment(apiService: MockService(fetchCommentRepliesEnvelopeResult: .success(
      CommentRepliesEnvelope
        .successfulRepliesTemplate
    ), fetchProjectResult: .success(.template))) {
      let url =
        "https://\(AppEnvironment.current.apiService.serverConfig.webBaseUrl.host ?? "")/projects/fjorden/fjorden-iphone-photography-reinvented/posts/3254626/comments?comment=Q29tbWVudC0zMzY0OTg0MQ%3D%3D&reply=deadbeef"

      let result = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: URL(string: url)!,
        options: [:]
      )
      XCTAssertTrue(result)

      self.presentViewController.assertValues([4])
    }
  }

  func testGoToActivity() {
    self.goToActivity.assertValueCount(0)

    let result = self.vm.inputs.applicationOpenUrl(
      application: UIApplication.shared,
      url: URL(string: "https://www.kickstarter.com/activity")!,
      options: [:]
    )
    XCTAssertTrue(result)

    self.goToActivity.assertValueCount(1)
  }

  func testGoToDiscovery() {
    self.goToDiscovery.assertValues([])

    let result = self.vm.inputs.applicationOpenUrl(
      application: UIApplication.shared,
      url: URL(string: "https://www.kickstarter.com/discover?sort=newest")!,
      options: [:]
    )
    XCTAssertTrue(result)

    let params = .defaults
      |> DiscoveryParams.lens.sort .~ .newest
    self.goToDiscovery.assertValues([params])
  }

  func testGoToDiscovery_NoParams() {
    self.goToDiscovery.assertValues([])

    let result = self.vm.inputs.applicationOpenUrl(
      application: UIApplication.shared,
      url: URL(string: "https://www.kickstarter.com/discover")!,
      options: [:]
    )
    XCTAssertTrue(result)

    self.goToDiscovery.assertValues([nil])
  }

  func testGoToDiscoveryWithCategoryName_ValidCategoryName_RoutesToCategory() {
    let mockService = MockService(fetchGraphCategoriesResult: .success(defaultRootCategoriesTemplate))

    withEnvironment(apiService: mockService) {
      self.goToDiscovery.assertValues([])

      let url = URL(string: "https://www.kickstarter.com/discover/categories/art")!
      let result = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: url,
        options: [:]
      )
      XCTAssertTrue(result)

      self.scheduler.advance()

      let params = .defaults |> DiscoveryParams.lens.category .~ .art
      self.goToDiscovery.assertValues([params])
    }
  }

  func testGoToDiscoveryWithCategoryName_InvalidCategoryName_DoesNotRouteToAnyCategory() {
    let mockService = MockService(fetchGraphCategoriesResult: .success(defaultRootCategoriesTemplate))

    withEnvironment(apiService: mockService) {
      self.goToDiscovery.assertValues([])

      let url = URL(string: "https://www.kickstarter.com/discover/categories/random")!
      let result = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: url,
        options: [:]
      )
      XCTAssertTrue(result)

      self.scheduler.advance()

      let params = .defaults |> DiscoveryParams.lens.category .~ .none
      self.goToDiscovery.assertValues([params])
    }
  }

  func testGoToDiscoveryWithSubcategoryName_ValidSubcategoryName_RoutesToSubcategory() {
    let gamesTemplate = RootCategoriesEnvelope.template
      |> RootCategoriesEnvelope.lens.categories .~ [
        .art,
        .filmAndVideo,
        .illustration,
        .documentary,
        .games
      ]

    let mockService = MockService(fetchGraphCategoriesResult: .success(gamesTemplate))

    withEnvironment(apiService: mockService) {
      self.goToDiscovery.assertValues([])

      let url = URL(string: "https://www.kickstarter.com/discover/categories/games/tabletop%20games")!
      let result = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: url,
        options: [:]
      )
      XCTAssertTrue(result)

      self.scheduler.advance()

      let params = .defaults |> DiscoveryParams.lens.category .~ .tabletopGames
      self.goToDiscovery.assertValues([params])
    }
  }

  func testGoToDiscoveryWithSubcategoryName_InvalidSubcategoryName_RoutesToCategory() {
    let gamesTemplate = RootCategoriesEnvelope.template
      |> RootCategoriesEnvelope.lens.categories .~ [
        .art,
        .filmAndVideo,
        .illustration,
        .documentary,
        .games
      ]

    let mockService = MockService(fetchGraphCategoriesResult: .success(gamesTemplate))

    withEnvironment(apiService: mockService) {
      self.goToDiscovery.assertValues([])

      let url = URL(string: "https://www.kickstarter.com/discover/categories/games/tabletopgames")!
      let result = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: url,
        options: [:]
      )
      XCTAssertTrue(result)

      self.scheduler.advance()

      let params = .defaults |> DiscoveryParams.lens.category .~ .games
      self.goToDiscovery.assertValues([params])
    }
  }

  func testGoToDiscoveryWithCategoryId_ValidCategoryId_RoutesToCategory() {
    let mockService = MockService(fetchGraphCategoriesResult: .success(defaultRootCategoriesTemplate))

    withEnvironment(apiService: mockService) {
      self.goToDiscovery.assertValues([])

      let url =
        URL(
          string: "https://www.kickstarter.com/discover/advanced?category_id=1&sort=magic&seed=2714369&page=1"
        )!
      let result = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: url,
        options: [:]
      )
      XCTAssertTrue(result)

      self.scheduler.advance()

      let params = .defaults |> DiscoveryParams.lens.category .~ .art
        |> DiscoveryParams.lens.sort .~ .magic
        |> DiscoveryParams.lens.seed .~ 2_714_369
        |> DiscoveryParams.lens.page .~ 1
      self.goToDiscovery.assertValues([params])
    }
  }

  func testGoToDiscoveryWithCategoryId_InvalidCategoryOrSubcategoryId_DoesNotRouteToAnyCategory() {
    let mockService = MockService(fetchGraphCategoriesResult: .success(defaultRootCategoriesTemplate))

    withEnvironment(apiService: mockService) {
      self.goToDiscovery.assertValues([])

      let url =
        URL(
          string: "https://www.kickstarter.com/discover/advanced?category_id=9999&sort=magic&seed=2714369&page=1"
        )!
      let result = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: url,
        options: [:]
      )
      XCTAssertTrue(result)

      self.scheduler.advance()

      let params = .defaults |> DiscoveryParams.lens.category .~ .none
        |> DiscoveryParams.lens.sort .~ .magic
        |> DiscoveryParams.lens.seed .~ 2_714_369
        |> DiscoveryParams.lens.page .~ 1
      self.goToDiscovery.assertValues([params])
    }
  }

  func testGoToDiscoveryWithSubcategoryId_ValidSubcategoryId_RoutesToSubcategory() {
    let gamesTemplate = RootCategoriesEnvelope.template
      |> RootCategoriesEnvelope.lens.categories .~ [
        .art,
        .filmAndVideo,
        .illustration,
        .documentary,
        .games
      ]

    let mockService = MockService(fetchGraphCategoriesResult: .success(gamesTemplate))

    withEnvironment(apiService: mockService) {
      self.goToDiscovery.assertValues([])

      let url =
        URL(
          string: "https://www.kickstarter.com/discover/advanced?category_id=34&sort=magic&seed=2714369&page=1"
        )!
      let result = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: url,
        options: [:]
      )
      XCTAssertTrue(result)

      self.scheduler.advance()

      let params = .defaults |> DiscoveryParams.lens.category .~ .tabletopGames
        |> DiscoveryParams.lens.sort .~ .magic
        |> DiscoveryParams.lens.seed .~ 2_714_369
        |> DiscoveryParams.lens.page .~ 1
      self.goToDiscovery.assertValues([params])
    }
  }

  func testGoToLogin() {
    self.goToLoginWithIntent.assertValueCount(0)

    let result = self.vm.inputs.applicationOpenUrl(
      application: UIApplication.shared,
      url: URL(string: "https://www.kickstarter.com/authorize")!,
      options: [:]
    )
    XCTAssertTrue(result)

    self.goToLoginWithIntent.assertValueCount(1)
  }

  func testGoToProfile() {
    self.goToProfile.assertValueCount(0)

    let result = self.vm.inputs.applicationOpenUrl(
      application: UIApplication.shared,
      url: URL(string: "https://www.kickstarter.com/profile/me")!,
      options: [:]
    )
    XCTAssertTrue(result)

    self.goToProfile.assertValueCount(1)
  }

  func testGoToSearch() {
    self.goToSearch.assertValueCount(0)

    let result = self.vm.inputs.applicationOpenUrl(
      application: UIApplication.shared,
      url: URL(string: "https://www.kickstarter.com/search")!,
      options: [:]
    )
    XCTAssertTrue(result)

    self.goToSearch.assertValueCount(1)
  }

  func testDeeplink_IsActivated_Success() {
    withEnvironment(currentUser: nil) {
      let result = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: URL(string: "https://www.kickstarter.com/search")!,
        options: [:]
      )

      XCTAssertTrue(result)

      self.goToSearch.assertValueCount(1)
    }
  }

  func testContinueUserActivity_ValidActivity() {
    let userActivity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
    userActivity.webpageURL = URL(string: "https://www.kickstarter.com/activity")

    self.goToActivity.assertValueCount(0)
    XCTAssertFalse(self.vm.outputs.continueUserActivityReturnValue.value)

    let result = self.vm.inputs.applicationContinueUserActivity(userActivity)
    XCTAssertTrue(result)

    self.goToActivity.assertValueCount(1)
    XCTAssertTrue(self.vm.outputs.continueUserActivityReturnValue.value)
  }

  func testContinueUserActivity_InvalidActivity() {
    let userActivity = NSUserActivity(activityType: "Other")

    let result = self.vm.inputs.applicationContinueUserActivity(userActivity)
    XCTAssertFalse(result)

    XCTAssertFalse(self.vm.outputs.continueUserActivityReturnValue.value)
  }

  func testContinueUserActivity_Success() {
    let userActivity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
    userActivity.webpageURL = URL(string: "https://www.kickstarter.com/activity")

    withEnvironment(currentUser: nil) {
      self.goToActivity.assertValueCount(0)
      XCTAssertFalse(self.vm.outputs.continueUserActivityReturnValue.value)

      let result = self.vm.inputs.applicationContinueUserActivity(userActivity)
      XCTAssertTrue(result)

      XCTAssertTrue(self.vm.outputs.continueUserActivityReturnValue.value)
      self.goToActivity.assertValueCount(1)
    }
  }

  func testProjectSurveyDeepLink() {
    self.presentViewController.assertValues([])

    let projectUrl = "https://www.kickstarter.com"
      + "/projects/tequila/help-me-transform-this-pile-of-wood/surveys/123"
    let result = self.vm.inputs.applicationOpenUrl(
      application: UIApplication.shared,
      url: URL(string: projectUrl)!,
      options: [:]
    )
    XCTAssertTrue(result)

    self.presentViewController.assertValues([1])
  }

  func testErroredPledgeDeepLink_LoggedIn() {
    let project = Project.template
      |> \.personalization.backing .~ .template
    let service = MockService(fetchProjectResult: .success(project))

    withEnvironment(apiService: service, currentUser: .template) {
      self.goToLoginWithIntent.assertDidNotEmitValue()
      self.presentViewController.assertValues([])

      let projectUrl = "https://www.kickstarter.com"
        + "/projects/sshults/greensens-the-easy-way-to-take-care-of-your-houseplants-0"
        + "/pledge?at=4f7d35e7c9d2bb57&ref=ksr_email_backer_failed_transaction"

      let result = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: URL(string: projectUrl)!,
        options: [:]
      )
      XCTAssertTrue(result)

      self.goToLoginWithIntent.assertDidNotEmitValue()
      self.presentViewController.assertValues([2])
    }
  }

  func testErroredPledgeDeepLink_LoggedOut() {
    withEnvironment(apiService: MockService(fetchProjectResult: .success(.template)), currentUser: nil) {
      self.goToLoginWithIntent.assertDidNotEmitValue()
      self.presentViewController.assertValues([])

      let projectUrl = "https://www.kickstarter.com"
        + "/projects/sshults/greensens-the-easy-way-to-take-care-of-your-houseplants-0"
        + "/pledge?at=4f7d35e7c9d2bb57&ref=ksr_email_backer_failed_transaction"

      let result = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: URL(string: projectUrl)!,
        options: [:]
      )
      XCTAssertTrue(result)

      self.goToLoginWithIntent.assertValues([.erroredPledge])
      self.presentViewController.assertDidNotEmitValue()
    }
  }

  func testUserSurveyDeepLink() {
    self.presentViewController.assertValues([])

    let projectUrl = "https://www.kickstarter.com/users/tequila/surveys/123"
    let result = self.vm.inputs.applicationOpenUrl(
      application: UIApplication.shared,
      url: URL(string: projectUrl)!,
      options: [:]
    )
    XCTAssertTrue(result)

    self.presentViewController.assertValues([1])
  }

  func testVerifyEmail_Success() {
    self.emailVerificationCompletedMessage.assertDidNotEmitValue()
    self.emailVerificationCompletedSuccess.assertDidNotEmitValue()

    guard let url = URL(string: "https://www.kickstarter.com/profile/verify_email?at=12345") else {
      XCTFail("Should have a url")
      return
    }

    let env = EmailVerificationResponseEnvelope(
      message: "Thanks—you’ve successfully verified your email address."
    )

    let mockService = MockService(verifyEmailResult: .success(env))

    withEnvironment(apiService: mockService) {
      _ = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: url,
        options: [:]
      )

      self.scheduler.advance()

      self.emailVerificationCompletedSuccess.assertValues([true])
      self.emailVerificationCompletedMessage.assertValues(
        ["Thanks—you’ve successfully verified your email address."]
      )
    }
  }

  func testVerifyEmail_Failure() {
    self.emailVerificationCompletedMessage.assertDidNotEmitValue()
    self.emailVerificationCompletedSuccess.assertDidNotEmitValue()

    guard let url = URL(string: "https://www.kickstarter.com/profile/verify_email?at=12345") else {
      XCTFail("Should have a url")
      return
    }

    let errorEnvelope = ErrorEnvelope(
      errorMessages: ["Error Message"],
      ksrCode: .UnknownCode,
      httpCode: 403,
      exception: nil
    )

    let mockService = MockService(verifyEmailResult: .failure(errorEnvelope))

    withEnvironment(apiService: mockService) {
      _ = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: url,
        options: [:]
      )

      self.scheduler.advance()

      self.emailVerificationCompletedSuccess.assertValues([false])
      self.emailVerificationCompletedMessage.assertValues(
        ["Error Message"]
      )
    }
  }

  func testVerifyEmail_Failure_UnknownError() {
    self.emailVerificationCompletedMessage.assertDidNotEmitValue()
    self.emailVerificationCompletedSuccess.assertDidNotEmitValue()

    guard let url = URL(string: "https://www.kickstarter.com/profile/verify_email?at=12345") else {
      XCTFail("Should have a url")
      return
    }

    let errorEnvelope = ErrorEnvelope(
      errorMessages: [],
      ksrCode: .UnknownCode,
      httpCode: 500,
      exception: nil
    )

    let mockService = MockService(verifyEmailResult: .failure(errorEnvelope))

    withEnvironment(apiService: mockService) {
      _ = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: url,
        options: [:]
      )

      self.scheduler.advance()

      self.emailVerificationCompletedSuccess.assertValues([false])
      self.emailVerificationCompletedMessage.assertValues(
        ["Something went wrong, please try again."]
      )
    }
  }

  func testGoToMobileSafari_unrecognizedDeeplink() {
    let url = URL(string: "https://fake-url.com")!
    _ = self.vm.inputs.applicationOpenUrl(application: nil, url: url, options: [:])

    self.goToMobileSafari.assertLastValue(url)
  }

  func testGoToMobileSafari_deeplinkFound() {
    let url = URL(string: "https://kickstarter.com/activity")!
    _ = self.vm.inputs.applicationOpenUrl(application: nil, url: url, options: [:])

    self.goToMobileSafari.assertDidNotEmitValue()
  }

  func testGoToMobileSafari_ksrUnrecognizedDeeplink() throws {
    let url = URL(string: "ksr://fake-url.com")!
    _ = self.vm.inputs.applicationOpenUrl(application: nil, url: url, options: [:])

    self.goToMobileSafari.assertDidNotEmitValue()
  }

  func testGoToMobileSafari_ksrDeeplinkFound() {
    let url = URL(string: "https://kickstarter.com/activity")!
    _ = self.vm.inputs.applicationOpenUrl(application: nil, url: url, options: [:])

    self.goToMobileSafari.assertDidNotEmitValue()
  }

  func testEmailDeepLinking() {
    withEnvironment(apiService: MockService(fetchProjectResult: .success(.template))) {
      let emailUrl = URL(string: "https://clicks.kickstarter.com/?qs=deadbeef")!

      self.findRedirectUrl.assertValues([])
      self.presentViewController.assertValues([])
      self.goToMobileSafari.assertValues([])

      // We deep-link to an email url.
      let result = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: emailUrl,
        options: [:]
      )
      XCTAssertTrue(result)

      self.findRedirectUrl.assertValues([emailUrl], "Ask to find the redirect after open the email url.")
      self.presentViewController.assertValues([], "No view controller is presented yet.")
      self.goToMobileSafari.assertValues([])

      // We find the redirect to be a project url.
      self.vm.inputs.foundRedirectUrl(URL(string: "https://www.kickstarter.com/projects/creator/project")!)

      self.findRedirectUrl.assertValues([emailUrl], "Nothing new is emitted.")
      self.presentViewController.assertValueCount(1, "Present the project view controller.")
      self.goToMobileSafari.assertValues([])
    }
  }

  func testEmailDeepLinking_ContinuedUserActivity() {
    withEnvironment(apiService: MockService(fetchProjectResult: .success(.template))) {
      let emailUrl = URL(string: "https://emails.kickstarter.com/?qs=deadbeef")!
      let userActivity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
      userActivity.webpageURL = emailUrl

      self.findRedirectUrl.assertValues([])
      self.presentViewController.assertValues([])
      self.goToMobileSafari.assertValues([])

      // We deep-link to an email url.
      let result = self.vm.inputs.applicationContinueUserActivity(userActivity)
      XCTAssertTrue(result)

      self.findRedirectUrl.assertValues([emailUrl], "Ask to find the redirect after open the email url.")
      self.presentViewController.assertValues([], "No view controller is presented yet.")
      self.goToMobileSafari.assertValues([])

      // We find the redirect to be a project url.
      self.vm.inputs.foundRedirectUrl(URL(string: "https://www.kickstarter.com/projects/creator/project")!)

      self.findRedirectUrl.assertValues([emailUrl], "Nothing new is emitted.")
      self.presentViewController.assertValueCount(1, "Present the project view controller.")
      self.goToMobileSafari.assertValues([])
    }
  }

  func testEmailDeepLinking_UnrecognizedUrl() {
    let emailUrl = URL(string: "https://clicks.kickstarter.com/?qs=deadbeef")!

    self.findRedirectUrl.assertValues([])
    self.presentViewController.assertValueCount(0)
    self.goToMobileSafari.assertValues([])

    // We deep-link to an email url.
    let result = self.vm.inputs.applicationOpenUrl(
      application: UIApplication.shared,
      url: emailUrl,
      options: [:]
    )
    XCTAssertTrue(result)

    self.findRedirectUrl.assertValues([emailUrl], "Ask to find the redirect after open the email url.")
    self.presentViewController.assertValues([], "No view controller is presented.")
    self.goToMobileSafari.assertValues([], "Do not go to mobile safari")

    // We find the redirect to be an unrecognized url.
    let unrecognizedUrl = URL(string: "https://www.kickstarter.com/unreconizable")!
    self.vm.inputs.foundRedirectUrl(unrecognizedUrl)

    self.findRedirectUrl.assertValues([emailUrl], "Nothing new is emitted.")
    self.presentViewController.assertValues([], "Do not present controller since the url was unrecognizable.")
    self.goToMobileSafari.assertValues([unrecognizedUrl], "Go to mobile safari for the unrecognized url.")
  }

  func testEmailDeepLinking_UnrecognizedUrl_ProjectPreview() {
    let emailUrl = URL(string: "https://emails.kickstarter.com/?qs=deadbeef")!

    self.findRedirectUrl.assertValues([])
    self.presentViewController.assertValueCount(0)
    self.goToMobileSafari.assertValues([])

    // We deep-link to an email url.
    let result = self.vm.inputs.applicationOpenUrl(
      application: UIApplication.shared,
      url: emailUrl,
      options: [:]
    )
    XCTAssertTrue(result)

    self.findRedirectUrl.assertValues([emailUrl], "Ask to find the redirect after open the email url.")
    self.presentViewController.assertValues([], "No view controller is presented.")
    self.goToMobileSafari.assertValues([], "Do not go to mobile safari")

    // We find the redirect to be an unrecognized url (project preview).
    let unrecognizedUrl = URL(string: "https://www.kickstarter.com/projects/creator/project?token=4")!
    self.vm.inputs.foundRedirectUrl(unrecognizedUrl)

    self.findRedirectUrl.assertValues([emailUrl], "Nothing new is emitted.")
    self.presentViewController.assertValues([], "Do not present controller since the url was unrecognizable.")
    self.goToMobileSafari.assertValues([unrecognizedUrl], "Go to mobile safari for the unrecognized url.")
  }

  func testDeepLink_UserDidUpdateNotificationSettings() {
    self.updateCurrentUserInEnvironment.assertDidNotEmitValue()

    withEnvironment(apiService: MockService()) {
      let user = User.template
        |> User.lens.notifications.mobileMessages .~ false

      let env = AccessTokenEnvelope(accessToken: "deadbeef", user: user)
      AppEnvironment.login(env)

      let updatedUser = user
        |> User.lens.notifications.mobileMessages .~ true

      let url =
        "https://\(AppEnvironment.current.apiService.serverConfig.webBaseUrl.host ?? "")/settings/notify_mobile_of_messages/true"

      let result = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: URL(string: url)!,
        options: [:]
      )
      XCTAssertTrue(result)

      self.updateCurrentUserInEnvironment.assertDidNotEmitValue()

      self.scheduler.advance()

      self.updateCurrentUserInEnvironment.assertValues([updatedUser])
    }
  }

}
