import XCTest
@testable import Library
@testable import KsApi
@testable import ReactiveExtensions_TestHelpers
import Result
import KsApi
import PassKit
import Prelude

private let questionMark = NSCharacterSet(charactersInString: "?")

final class CheckoutViewModelTests: TestCase {
  private let vm: CheckoutViewModelType = CheckoutViewModel()

  private let closeLoginTout = TestObserver<(), NoError>()
  private let evaluateJavascript = TestObserver<String, NoError>()
  private let goToPaymentAuthorization = TestObserver<NSDictionary, NoError>()
  private let goToSafariBrowser = TestObserver<NSURL, NoError>()
  private let goToThanks = TestObserver<Project, NoError>()
  private let goToWebModal = TestObserver<NSURLRequest, NoError>()
  private let openLoginTout = TestObserver<(), NoError>()
  private let popViewController = TestObserver<(), NoError>()
  private let setStripeAppleMerchantIdentifier = TestObserver<String, NoError>()
  private let setStripePublishableKey = TestObserver<String, NoError>()
  private let showFailureAlert = TestObserver<String, NoError>()
  private let webViewLoadRequestIsPrepared = TestObserver<Bool, NoError>()
  private let webViewLoadRequestURL = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.closeLoginTout.observe(self.closeLoginTout.observer)
    self.vm.outputs.evaluateJavascript.observe(self.evaluateJavascript.observer)
    self.vm.outputs.goToPaymentAuthorization.map { $0.encode() as NSDictionary }
      .observe(self.goToPaymentAuthorization.observer)
    self.vm.outputs.goToSafariBrowser.observe(self.goToSafariBrowser.observer)
    self.vm.outputs.goToThanks.observe(self.goToThanks.observer)
    self.vm.outputs.goToWebModal.observe(self.goToWebModal.observer)
    self.vm.outputs.openLoginTout.observe(self.openLoginTout.observer)
    self.vm.outputs.popViewController.observe(self.popViewController.observer)
    self.vm.outputs.setStripeAppleMerchantIdentifier.observe(self.setStripeAppleMerchantIdentifier.observer)
    self.vm.outputs.setStripePublishableKey.observe(self.setStripePublishableKey.observer)
    self.vm.outputs.showFailureAlert.observe(self.showFailureAlert.observer)
    self.vm.outputs.webViewLoadRequest
      .map { AppEnvironment.current.apiService.isPrepared(request: $0) }
      .observe(self.webViewLoadRequestIsPrepared.observer)
    self.vm.outputs.webViewLoadRequest
      .map { request -> String? in
        // Trim query parameters
        guard let url = request.URL else { return nil }
        guard let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: false) else { return nil }
        components.queryItems = components.queryItems?.filter {
          $0.name != "client_id" && $0.name != "oauth_token"
        }
        return components.string?.stringByTrimmingCharactersInSet(questionMark)
      }
      .ignoreNil()
      .observe(self.webViewLoadRequestURL.observer)
  }

  func testCancelButtonPopsViewController() {
    let project = Project.template

    self.vm.inputs.configureWith(initialRequest: newPledgeRequest(project: project).prepared(),
                                 project: project,
                                 applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    // 1: Show reward and shipping form
    self.webViewLoadRequestIsPrepared.assertValues([true])
    self.webViewLoadRequestURL.assertValues([newPledgeURL(project: project)])

    XCTAssertTrue(
      self.vm.inputs.shouldStartLoad(
        withRequest: newPledgeRequest(project: project).prepared(),
        navigationType: .Other
      )
    )
    XCTAssertTrue(self.vm.inputs.shouldStartLoad(withRequest: stripeRequest(), navigationType: .Other))

    // 2: Cancel button tapped
    self.popViewController.assertDidNotEmitValue()
    XCTAssertEqual([], self.trackingClient.events)

    self.vm.inputs.cancelButtonTapped()
    self.popViewController.assertValueCount(1)
    XCTAssertEqual(["Checkout Cancel", "Canceled Checkout"],
                   self.trackingClient.events, "Cancel event and its deprecated version are tracked")
  }

  func testCancelPledge() {
    let project = Project.template
    withEnvironment(currentUser: .template) {
      self.webViewLoadRequestURL.assertDidNotEmitValue()

      self.vm.inputs.configureWith(initialRequest: editPledgeRequest(project: project).prepared(),
                                   project: project,
                                   applePayCapable: false)
      self.vm.inputs.viewDidLoad()

      // 1: Show reward and shipping form
      self.webViewLoadRequestIsPrepared.assertValues([true])
      self.webViewLoadRequestURL.assertValues([editPledgeURL(project: project)])

      XCTAssertTrue(
        self.vm.inputs.shouldStartLoad(
          withRequest: editPledgeRequest(project: project).prepared(),
          navigationType: .Other
        )
      )
      XCTAssertTrue(self.vm.inputs.shouldStartLoad(withRequest: stripeRequest(), navigationType: .Other))

      // 2: Click cancel link
      XCTAssertFalse(
        self.vm.inputs.shouldStartLoad(
          withRequest: cancelPledgeRequest(project: project),
          navigationType: .LinkClicked
        ),
        "Not prepared"
      )

      self.webViewLoadRequestIsPrepared.assertValues([true, true])
      self.webViewLoadRequestURL.assertValues(
        [editPledgeURL(project: project), cancelPledgeURL(project: project)]
      )
      XCTAssertTrue(
        self.vm.inputs.shouldStartLoad(
          withRequest: cancelPledgeRequest(project: project).prepared(),
          navigationType: .Other
        )
      )
      XCTAssertTrue(self.vm.inputs.shouldStartLoad(withRequest: stripeRequest(), navigationType: .Other))

      // 3: Confirm cancellation
      XCTAssertFalse(
        self.vm.inputs.shouldStartLoad(
          withRequest: pledgeRequest(project: project),
          navigationType: .FormSubmitted
        ),
        "Not prepared"
      )
      self.webViewLoadRequestIsPrepared.assertValues([true, true, true])
      self.webViewLoadRequestURL.assertValues(
        [editPledgeURL(project: project), cancelPledgeURL(project: project), pledgeURL(project: project)]
      )

      // 4: Redirect to project, view controller popped
      self.popViewController.assertDidNotEmitValue()
      XCTAssertEqual([], self.trackingClient.events)

      XCTAssertFalse(
        self.vm.inputs.shouldStartLoad(withRequest: projectRequest(project: project), navigationType: .Other)
      )
      XCTAssertEqual(["Checkout Cancel", "Canceled Checkout"], self.trackingClient.events)
      self.popViewController.assertValueCount(1)
    }

    self.evaluateJavascript.assertValueCount(0, "No javascript was evaluated.")
  }

  func testChangePaymentMethod() {
    let project = Project.template
    withEnvironment(currentUser: .template) {
      self.webViewLoadRequestURL.assertDidNotEmitValue()

      self.vm.inputs.configureWith(initialRequest: editPledgeRequest(project: project).prepared(),
                                   project: project,
                                   applePayCapable: false)
      self.vm.inputs.viewDidLoad()

      // 1: Show reward and shipping form
      self.webViewLoadRequestIsPrepared.assertValues([true])
      self.webViewLoadRequestURL.assertValues([editPledgeURL(project: project)])

      XCTAssertTrue(
        self.vm.inputs.shouldStartLoad(
          withRequest: editPledgeRequest(project: project).prepared(),
          navigationType: .Other
        )
      )
      XCTAssertTrue(self.vm.inputs.shouldStartLoad(withRequest: stripeRequest(), navigationType: .Other))

      // 2: Click change payment method button
      XCTAssertFalse(
        self.vm.inputs.shouldStartLoad(
          withRequest: changePaymentMethodRequest(project: project),
          navigationType: .FormSubmitted
        ),
        "Not prepared"
      )

      self.webViewLoadRequestIsPrepared.assertValues([true, true])
      self.webViewLoadRequestURL.assertValues(
        [editPledgeURL(project: project), changePaymentMethodURL(project: project)]
      )
      XCTAssertTrue(
        self.vm.inputs.shouldStartLoad(
          withRequest: changePaymentMethodRequest(project: project).prepared(),
          navigationType: .Other
        )
      )
      XCTAssertTrue(self.vm.inputs.shouldStartLoad(withRequest: stripeRequest(), navigationType: .Other))

      // 3: Redirect to new payments form
      self.webViewLoadRequestURL.assertValueCount(2)

      XCTAssertFalse(
        self.vm.inputs.shouldStartLoad(withRequest: newPaymentsRequest(), navigationType: .Other),
        "Not prepared"
      )

      self.webViewLoadRequestIsPrepared.assertValues([true, true, true])
      self.webViewLoadRequestURL.assertValues(
        [editPledgeURL(project: project), changePaymentMethodURL(project: project), newPaymentsURL()]
      )

      XCTAssertTrue(
        self.vm.inputs.shouldStartLoad(withRequest: newPaymentsRequest().prepared(), navigationType: .Other)
      )
      XCTAssertTrue(self.vm.inputs.shouldStartLoad(withRequest: stripeRequest(), navigationType: .Other))

      // 4: Pledge with new card
      self.webViewLoadRequestURL.assertValueCount(3)

      XCTAssertFalse(
        self.vm.inputs.shouldStartLoad(withRequest: paymentsRequest(), navigationType: .FormSubmitted),
        "Not prepared"
      )

      self.webViewLoadRequestIsPrepared.assertValues([true, true, true, true])
      self.webViewLoadRequestURL.assertValues(
        [
          editPledgeURL(project: project),
          changePaymentMethodURL(project: project),
          newPaymentsURL(),
          paymentsURL()
        ]
      )

      XCTAssertTrue(
        self.vm.inputs.shouldStartLoad(withRequest: paymentsRequest().prepared(), navigationType: .Other)
      )

      // 5: Redirect to thanks
      self.goToThanks.assertDidNotEmitValue()
      self.webViewLoadRequestURL.assertValueCount(4)

      XCTAssertFalse(
        self.vm.inputs.shouldStartLoad(
          withRequest: thanksRequest(
            project: project, racing: false),
            navigationType: .Other
        ),
        "Not prepared"
      )
      self.goToThanks.assertValueCount(1)
    }

    self.evaluateJavascript.assertValueCount(0, "No javascript was evaluated.")
  }

  func testLoggedInUserPledgingWithNewCard() {
    let project = Project.template
    withEnvironment(currentUser: .template) {
      self.webViewLoadRequestURL.assertDidNotEmitValue()

      self.vm.inputs.configureWith(initialRequest: newPledgeRequest(project: project).prepared(),
                                   project: project,
                                   applePayCapable: false)
      self.vm.inputs.viewDidLoad()

      // 1: Show reward and shipping form
      self.webViewLoadRequestIsPrepared.assertValues([true])
      self.webViewLoadRequestURL.assertValues([newPledgeURL(project: project)])

      XCTAssertTrue(
        self.vm.inputs.shouldStartLoad(
          withRequest: newPledgeRequest(project: project).prepared(),
          navigationType: .Other
        )
      )
      XCTAssertTrue(self.vm.inputs.shouldStartLoad(withRequest: stripeRequest(), navigationType: .Other))

      // 2: Submit reward and shipping form
      self.webViewLoadRequestURL.assertValueCount(1)

      XCTAssertFalse(
        self.vm.inputs.shouldStartLoad(
          withRequest: pledgeRequest(project: project),
          navigationType: .FormSubmitted
        ),
        "Not prepared"
      )

      self.webViewLoadRequestIsPrepared.assertValues([true, true])
      self.webViewLoadRequestURL.assertValues(
        [newPledgeURL(project: project), pledgeURL(project: project)]
      )

      XCTAssertTrue(
        self.vm.inputs.shouldStartLoad(
          withRequest: pledgeRequest(project: project).prepared(),
          navigationType: .Other
        )
      )

      // 3: Redirect to new payments form
      self.webViewLoadRequestURL.assertValueCount(2)

      XCTAssertFalse(
        self.vm.inputs.shouldStartLoad(withRequest: newPaymentsRequest(), navigationType: .Other),
        "Not prepared"
      )

      self.webViewLoadRequestIsPrepared.assertValues([true, true, true])
      self.webViewLoadRequestURL.assertValues(
        [newPledgeURL(project: project), pledgeURL(project: project), newPaymentsURL()]
      )

      XCTAssertTrue(
        self.vm.inputs.shouldStartLoad(withRequest: newPaymentsRequest().prepared(), navigationType: .Other)
      )
      XCTAssertTrue(self.vm.inputs.shouldStartLoad(withRequest: stripeRequest(), navigationType: .Other))

      // 4: Pledge with new card
      self.webViewLoadRequestURL.assertValueCount(3)

      XCTAssertFalse(
        self.vm.inputs.shouldStartLoad(withRequest: paymentsRequest(), navigationType: .FormSubmitted),
        "Not prepared"
      )

      self.webViewLoadRequestIsPrepared.assertValues([true, true, true, true])
      self.webViewLoadRequestURL.assertValues(
        [
          newPledgeURL(project: project),
          pledgeURL(project: project),
          newPaymentsURL(),
          paymentsURL()
        ]
      )

      XCTAssertTrue(
        self.vm.inputs.shouldStartLoad(withRequest: paymentsRequest().prepared(), navigationType: .Other)
      )

      // 5: Redirect to thanks
      self.goToThanks.assertDidNotEmitValue()
      self.webViewLoadRequestURL.assertValueCount(4)

      XCTAssertFalse(
        self.vm.inputs.shouldStartLoad(
          withRequest: thanksRequest(project: project, racing: false),
          navigationType: .Other
        ),
        "Don't go to the URL since we handle it with a native thanks screen."
      )
      self.goToThanks.assertValueCount(1)
    }

    self.evaluateJavascript.assertValueCount(0, "No javascript was evaluated.")
  }

  func testLoggedInUserPledgingWithStoredCard() {
    let project = Project.template
    withEnvironment(currentUser: .template) {
      self.webViewLoadRequestURL.assertDidNotEmitValue()

      self.vm.inputs.configureWith(initialRequest: newPledgeRequest(project: project).prepared(),
                                   project: project,
                                   applePayCapable: false)
      self.vm.inputs.viewDidLoad()

      // 1: Show reward and shipping form
      self.webViewLoadRequestIsPrepared.assertValues([true])
      self.webViewLoadRequestURL.assertValues([newPledgeURL(project: project)])

      XCTAssertTrue(
        self.vm.inputs.shouldStartLoad(
          withRequest: newPledgeRequest(project: project).prepared(),
          navigationType: .Other
        )
      )
      XCTAssertTrue(self.vm.inputs.shouldStartLoad(withRequest: stripeRequest(), navigationType: .Other))

      // 2: Submit reward and shipping form
      self.webViewLoadRequestURL.assertValueCount(1)

      XCTAssertFalse(
        self.vm.inputs.shouldStartLoad(
          withRequest: pledgeRequest(project: project),
          navigationType: .FormSubmitted
        ),
        "Not prepared"
      )

      self.webViewLoadRequestIsPrepared.assertValues([true, true])
      self.webViewLoadRequestURL.assertValues(
        [newPledgeURL(project: project), pledgeURL(project: project)]
      )

      XCTAssertTrue(
        self.vm.inputs.shouldStartLoad(
          withRequest: pledgeRequest(project: project).prepared(),
          navigationType: .Other
        )
      )

      // 3: Redirect to new payments form
      self.webViewLoadRequestURL.assertValueCount(2)

      XCTAssertFalse(
        self.vm.inputs.shouldStartLoad(withRequest: newPaymentsRequest(), navigationType: .Other),
        "Not prepared"
      )

      self.webViewLoadRequestIsPrepared.assertValues([true, true, true])
      self.webViewLoadRequestURL.assertValues(
        [newPledgeURL(project: project), pledgeURL(project: project), newPaymentsURL()]
      )

      XCTAssertTrue(
        self.vm.inputs.shouldStartLoad(withRequest: newPaymentsRequest().prepared(), navigationType: .Other)
      )

      // 4: Pledge with stored card
      self.webViewLoadRequestURL.assertValueCount(3)

      XCTAssertFalse(
        self.vm.inputs.shouldStartLoad(withRequest: useStoredCardRequest(), navigationType: .FormSubmitted),
        "Not prepared"
      )

      self.webViewLoadRequestIsPrepared.assertValues([true, true, true, true])
      self.webViewLoadRequestURL.assertValues(
        [
          newPledgeURL(project: project),
          pledgeURL(project: project),
          newPaymentsURL(),
          useStoredCardURL()
        ]
      )

      XCTAssertTrue(
        self.vm.inputs.shouldStartLoad(withRequest: useStoredCardRequest().prepared(), navigationType: .Other)
      )

      // 5: Redirect to thanks
      self.goToThanks.assertDidNotEmitValue()
      self.webViewLoadRequestURL.assertValueCount(4)

      XCTAssertFalse(
        self.vm.inputs.shouldStartLoad(
          withRequest: thanksRequest(project: project, racing: false),
          navigationType: .Other
        ),
        "Don't go to the URL since we handle it with a native thanks screen."
      )
      self.goToThanks.assertValueCount(1)
    }

    self.evaluateJavascript.assertValueCount(0, "No javascript was evaluated.")
  }

  func testLoginDuringCheckout() {
    let project = Project.template

    self.vm.inputs.configureWith(initialRequest: newPledgeRequest(project: project).prepared(),
                                 project: project,
                                 applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    // 1: Show reward and shipping form
    self.webViewLoadRequestIsPrepared.assertValues([true])
    self.webViewLoadRequestURL.assertValues([newPledgeURL(project: project)])

    XCTAssertTrue(
      self.vm.inputs.shouldStartLoad(
        withRequest: newPledgeRequest(project: project).prepared(),
        navigationType: .Other
      )
    )
    XCTAssertTrue(self.vm.inputs.shouldStartLoad(withRequest: stripeRequest(), navigationType: .Other))

    // 2: Submit reward and shipping form
    self.webViewLoadRequestURL.assertValueCount(1)

    XCTAssertFalse(
      self.vm.inputs.shouldStartLoad(
        withRequest: pledgeRequest(project: project),
        navigationType: .FormSubmitted
      ),
      "Not prepared"
    )

    self.webViewLoadRequestIsPrepared.assertValues([true, true])
    self.webViewLoadRequestURL.assertValues(
      [newPledgeURL(project: project), pledgeURL(project: project)]
    )

    XCTAssertTrue(
      self.vm.inputs.shouldStartLoad(
        withRequest: pledgeRequest(project: project).prepared(),
        navigationType: .Other
      )
    )

    // 3: Interrupt checkout for login/signup
    self.openLoginTout.assertDidNotEmitValue()

    XCTAssertFalse(self.vm.inputs.shouldStartLoad(withRequest: signupRequest(), navigationType: .Other))
    self.openLoginTout.assertValueCount(1)

    // 4: Login
    AppEnvironment.login(.init(accessToken: "deadbeef", user: User.template))
    self.closeLoginTout.assertDidNotEmitValue()

    self.vm.inputs.userSessionStarted()
    self.closeLoginTout.assertValueCount(1)

    // 5: Attempt pledge request again
    self.webViewLoadRequestURL.assertValues(
      [newPledgeURL(project: project), pledgeURL(project: project), pledgeURL(project: project)],
      "Attempt pledge request again, now that user is logged in"
    )

    XCTAssertTrue(
      self.vm.inputs.shouldStartLoad(
        withRequest: pledgeRequest(project: project).prepared(),
        navigationType: .Other
      )
    )
    XCTAssertFalse(
      self.vm.inputs.shouldStartLoad(withRequest: newPaymentsRequest(), navigationType: .Other),
      "Not prepared"
    )

    self.webViewLoadRequestURL.assertValues(
      [
        newPledgeURL(project: project),
        pledgeURL(project: project),
        pledgeURL(project: project),
        newPaymentsURL()
      ]
    )

    XCTAssertTrue(
      self.vm.inputs.shouldStartLoad(withRequest: newPaymentsRequest().prepared(), navigationType: .Other)
    )

    self.evaluateJavascript.assertValueCount(0, "No javascript was evaluated.")

    // The rest of the checkout flow is the same as if the user had been logged in at the beginning,
    // so no need for further tests.
  }

  func testManagePledge() {
    let project = Project.template
    withEnvironment(currentUser: .template) {
      self.webViewLoadRequestURL.assertDidNotEmitValue()

      self.vm.inputs.configureWith(initialRequest: editPledgeRequest(project: project).prepared(),
                                   project: project,
                                   applePayCapable: false)
      self.vm.inputs.viewDidLoad()

      // 1: Show reward and shipping form
      self.webViewLoadRequestIsPrepared.assertValues([true])
      self.webViewLoadRequestURL.assertValues([editPledgeURL(project: project)])

      XCTAssertTrue(
        self.vm.inputs.shouldStartLoad(
          withRequest: editPledgeRequest(project: project).prepared(),
          navigationType: .Other
        )
      )
      XCTAssertTrue(self.vm.inputs.shouldStartLoad(withRequest: stripeRequest(), navigationType: .Other))

      // 2: Submit reward and shipping form
      self.webViewLoadRequestURL.assertValueCount(1)

      XCTAssertFalse(
        self.vm.inputs.shouldStartLoad(
          withRequest: pledgeRequest(project: project),
          navigationType: .FormSubmitted
        ),
        "Not prepared"
      )

      self.webViewLoadRequestIsPrepared.assertValues([true, true])
      self.webViewLoadRequestURL.assertValues(
        [editPledgeURL(project: project), pledgeURL(project: project)]
      )

      XCTAssertTrue(
        self.vm.inputs.shouldStartLoad(
          withRequest: pledgeRequest(project: project).prepared(),
          navigationType: .Other
        )
      )

      // 3: Redirect to thanks
      self.goToThanks.assertDidNotEmitValue()

      XCTAssertFalse(
        self.vm.inputs.shouldStartLoad(
          withRequest: thanksRequest(project: project, racing: false),
          navigationType: .Other
        ),
        "Don't go to the URL since we handle it with a native thanks screen."
      )
      self.goToThanks.assertValueCount(1)
    }

    self.evaluateJavascript.assertValueCount(0, "No javascript was evaluated.")
  }

  func testModalRequests() {
    let project = Project.template
    self.vm.inputs.configureWith(initialRequest: newPledgeRequest(project: project).prepared(),
                                 project: project,
                                 applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    XCTAssertTrue(
      self.vm.inputs.shouldStartLoad(withRequest: newPledgeRequest(project: project).prepared(),
        navigationType: .Other)
    )
    self.goToWebModal.assertValueCount(0)

    XCTAssertFalse(
      self.vm.inputs.shouldStartLoad(withRequest: creatorRequest(project: project),
        navigationType: .LinkClicked)
    )
    self.goToSafariBrowser.assertValueCount(0)
    self.goToWebModal.assertValueCount(1)

    XCTAssertFalse(
      self.vm.inputs.shouldStartLoad(withRequest: privacyPolicyRequest(project: project),
        navigationType: .LinkClicked)
    )
    self.goToSafariBrowser.assertValueCount(1)
    self.goToWebModal.assertValueCount(1)
  }

  func testRacingFailure() {
    let failedEnvelope = CheckoutEnvelope.failed
    let project = Project.template
    withEnvironment(apiService: MockService(fetchCheckoutResponse: failedEnvelope), currentUser: .template) {
      self.webViewLoadRequestURL.assertDidNotEmitValue()

      self.vm.inputs.configureWith(initialRequest: newPledgeRequest(project: project).prepared(),
                                   project: project,
                                   applePayCapable: false)
      self.vm.inputs.viewDidLoad()

      // 1: Show reward and shipping form
      self.webViewLoadRequestIsPrepared.assertValues([true])
      self.webViewLoadRequestURL.assertValues([newPledgeURL(project: project)])

      XCTAssertTrue(
        self.vm.inputs.shouldStartLoad(
          withRequest: newPledgeRequest(project: project).prepared(),
          navigationType: .Other
        )
      )
      XCTAssertTrue(self.vm.inputs.shouldStartLoad(withRequest: stripeRequest(), navigationType: .Other))

      // 2: Submit reward and shipping form
      self.webViewLoadRequestURL.assertValueCount(1)

      XCTAssertFalse(
        self.vm.inputs.shouldStartLoad(
          withRequest: pledgeRequest(project: project),
          navigationType: .FormSubmitted
        ),
        "Not prepared"
      )

      self.webViewLoadRequestIsPrepared.assertValues([true, true])
      self.webViewLoadRequestURL.assertValues(
        [newPledgeURL(project: project), pledgeURL(project: project)]
      )

      XCTAssertTrue(
        self.vm.inputs.shouldStartLoad(
          withRequest: pledgeRequest(project: project).prepared(),
          navigationType: .Other
        )
      )

      // 3: Redirect to new payments form
      self.webViewLoadRequestURL.assertValueCount(2)

      XCTAssertFalse(
        self.vm.inputs.shouldStartLoad(withRequest: newPaymentsRequest(), navigationType: .Other),
        "Not prepared"
      )

      self.webViewLoadRequestIsPrepared.assertValues([true, true, true])
      self.webViewLoadRequestURL.assertValues(
        [newPledgeURL(project: project), pledgeURL(project: project), newPaymentsURL()]
      )

      XCTAssertTrue(
        self.vm.inputs.shouldStartLoad(withRequest: newPaymentsRequest().prepared(), navigationType: .Other)
      )

      // 4: Pledge with stored card
      self.webViewLoadRequestURL.assertValueCount(3)

      XCTAssertFalse(
        self.vm.inputs.shouldStartLoad(withRequest: useStoredCardRequest(), navigationType: .FormSubmitted),
        "Not prepared"
      )

      self.webViewLoadRequestIsPrepared.assertValues([true, true, true, true])
      self.webViewLoadRequestURL.assertValues(
        [
          newPledgeURL(project: project),
          pledgeURL(project: project),
          newPaymentsURL(),
          useStoredCardURL()
        ]
      )

      XCTAssertTrue(
        self.vm.inputs.shouldStartLoad(withRequest: useStoredCardRequest().prepared(), navigationType: .Other)
      )

      // 5: Checkout is racing, delay a second to check status (failed!), then display failure alert.
      self.goToThanks.assertDidNotEmitValue()
      self.webViewLoadRequestURL.assertValueCount(4)

      XCTAssertFalse(
        self.vm.inputs.shouldStartLoad(
          withRequest: thanksRequest(project: project, racing: true),
          navigationType: .Other
        )
      )
      self.showFailureAlert.assertValueCount(0)

      self.scheduler.advanceByInterval(1)
      self.goToThanks.assertValueCount(0)
      self.showFailureAlert.assertValues([failedEnvelope.stateReason])

      // 6: Alert dismissed, pop view controller
      self.popViewController.assertValueCount(0)

      self.vm.inputs.failureAlertButtonTapped()
      self.popViewController.assertValueCount(1)
    }

    self.evaluateJavascript.assertValueCount(0, "No javascript was evaluated.")
  }

  func testRacingSuccess() {
    let envelope = CheckoutEnvelope.successful
    let project = Project.template
    withEnvironment(apiService: MockService(fetchCheckoutResponse: envelope), currentUser: .template) {
      self.webViewLoadRequestURL.assertDidNotEmitValue()

      self.vm.inputs.configureWith(initialRequest: newPledgeRequest(project: project).prepared(),
                                   project: project,
                                   applePayCapable: false)
      self.vm.inputs.viewDidLoad()

      // 1: Show reward and shipping form
      self.webViewLoadRequestIsPrepared.assertValues([true])
      self.webViewLoadRequestURL.assertValues([newPledgeURL(project: project)])

      XCTAssertTrue(
        self.vm.inputs.shouldStartLoad(
          withRequest: newPledgeRequest(project: project).prepared(),
          navigationType: .Other
        )
      )
      XCTAssertTrue(self.vm.inputs.shouldStartLoad(withRequest: stripeRequest(), navigationType: .Other))

      // 2: Submit reward and shipping form
      self.webViewLoadRequestURL.assertValueCount(1)

      XCTAssertFalse(
        self.vm.inputs.shouldStartLoad(
          withRequest: pledgeRequest(project: project),
          navigationType: .FormSubmitted
        ),
        "Not prepared"
      )

      self.webViewLoadRequestIsPrepared.assertValues([true, true])
      self.webViewLoadRequestURL.assertValues(
        [newPledgeURL(project: project), pledgeURL(project: project)]
      )

      XCTAssertTrue(
        self.vm.inputs.shouldStartLoad(
          withRequest: pledgeRequest(project: project).prepared(),
          navigationType: .Other
        )
      )

      // 3: Redirect to new payments form
      self.webViewLoadRequestURL.assertValueCount(2)

      XCTAssertFalse(
        self.vm.inputs.shouldStartLoad(withRequest: newPaymentsRequest(), navigationType: .Other),
        "Not prepared"
      )

      self.webViewLoadRequestIsPrepared.assertValues([true, true, true])
      self.webViewLoadRequestURL.assertValues(
        [newPledgeURL(project: project), pledgeURL(project: project), newPaymentsURL()]
      )

      XCTAssertTrue(
        self.vm.inputs.shouldStartLoad(withRequest: newPaymentsRequest().prepared(), navigationType: .Other)
      )

      // 4: Pledge with stored card
      self.webViewLoadRequestURL.assertValueCount(3)

      XCTAssertFalse(
        self.vm.inputs.shouldStartLoad(withRequest: useStoredCardRequest(), navigationType: .FormSubmitted),
        "Not prepared"
      )

      self.webViewLoadRequestIsPrepared.assertValues([true, true, true, true])
      self.webViewLoadRequestURL.assertValues(
        [
          newPledgeURL(project: project),
          pledgeURL(project: project),
          newPaymentsURL(),
          useStoredCardURL()
        ]
      )

      XCTAssertTrue(
        self.vm.inputs.shouldStartLoad(withRequest: useStoredCardRequest().prepared(), navigationType: .Other)
      )

      // 5: Checkout is racing, delay a second to check status (successful!), then go to thanks.
      self.goToThanks.assertDidNotEmitValue()
      self.webViewLoadRequestURL.assertValueCount(4)

      XCTAssertFalse(
        self.vm.inputs.shouldStartLoad(
          withRequest: thanksRequest(project: project, racing: true),
          navigationType: .Other
        )
      )

      self.scheduler.advanceByInterval(1)
      self.showFailureAlert.assertValueCount(0)
      self.goToThanks.assertValueCount(1)
    }

    self.evaluateJavascript.assertValueCount(0, "No javascript was evaluated.")
  }

  func testProjectRequestPopsViewController() {
    let project = Project.template

    self.vm.inputs.configureWith(initialRequest: newPledgeRequest(project: project).prepared(),
                                 project: project,
                                 applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    // 1: Show reward and shipping form
    self.webViewLoadRequestIsPrepared.assertValues([true])
    self.webViewLoadRequestURL.assertValues([newPledgeURL(project: project)])

    XCTAssertTrue(
      self.vm.inputs.shouldStartLoad(
        withRequest: newPledgeRequest(project: project).prepared(),
        navigationType: .Other
      )
    )
    XCTAssertTrue(self.vm.inputs.shouldStartLoad(withRequest: stripeRequest(), navigationType: .Other))

    // 2: Project link clicked
    self.popViewController.assertDidNotEmitValue()
    XCTAssertEqual([], self.trackingClient.events)

    XCTAssertFalse(
      self.vm.inputs.shouldStartLoad(
        withRequest: projectRequest(project: project),
        navigationType: .LinkClicked
      )
    )

    self.popViewController.assertValueCount(1)
    XCTAssertEqual(["Checkout Cancel", "Canceled Checkout"],
                   self.trackingClient.events, "Cancel event and its deprecated version are tracked")
  }

  func testEmbeddedApplePayFlow() {
    let amount = 25
    let location = Location.template
    let reward = .template
      |> Reward.lens.minimum .~ 20
    let project = .template
      |> Project.lens.rewards .~ [reward]

    withEnvironment(currentUser: .template) {
      self.webViewLoadRequestURL.assertDidNotEmitValue()

      self.vm.inputs.configureWith(initialRequest: newPledgeRequest(project: project).prepared(),
                                   project: project,
                                   applePayCapable: true)
      self.vm.inputs.viewDidLoad()

      // 1: Show reward and shipping form
      self.webViewLoadRequestIsPrepared.assertValues([true])
      self.webViewLoadRequestURL.assertValues([newPledgeURL(project: project)])

      XCTAssertTrue(
        self.vm.inputs.shouldStartLoad(
          withRequest: newPledgeRequest(project: project).prepared(),
          navigationType: .Other
        )
      )
      XCTAssertTrue(self.vm.inputs.shouldStartLoad(withRequest: stripeRequest(), navigationType: .Other))

      // 2: Submit reward and shipping form
      self.webViewLoadRequestURL.assertValueCount(1)

      XCTAssertFalse(
        self.vm.inputs.shouldStartLoad(
          withRequest: pledgeRequest(project: project),
          navigationType: .FormSubmitted
        ),
        "Not prepared"
      )

      self.webViewLoadRequestIsPrepared.assertValues([true, true])
      self.webViewLoadRequestURL.assertValues(
        [newPledgeURL(project: project), pledgeURL(project: project)]
      )

      XCTAssertTrue(
        self.vm.inputs.shouldStartLoad(
          withRequest: pledgeRequest(project: project).prepared(),
          navigationType: .Other
        )
      )

      // 3: Redirect to new payments form
      self.webViewLoadRequestURL.assertValueCount(2)

      XCTAssertFalse(
        self.vm.inputs.shouldStartLoad(withRequest: newPaymentsRequest(), navigationType: .Other),
        "Not prepared"
      )

      self.webViewLoadRequestIsPrepared.assertValues([true, true, true])
      self.webViewLoadRequestURL.assertValues(
        [newPledgeURL(project: project), pledgeURL(project: project), newPaymentsURL()]
      )

      XCTAssertTrue(
        self.vm.inputs.shouldStartLoad(withRequest: newPaymentsRequest().prepared(), navigationType: .Other)
      )
      XCTAssertTrue(self.vm.inputs.shouldStartLoad(withRequest: stripeRequest(), navigationType: .Other))

      // 4: Pledge with apple pay
      self.webViewLoadRequestURL.assertValueCount(3)

      XCTAssertFalse(
        self.vm.inputs.shouldStartLoad(
          withRequest: applePayUrlRequest(
            project: project,
            amount: amount,
            reward: reward,
            location: location
          ),
          navigationType: .LinkClicked
        ),
        "Apple Pay url not allowed"
      )

      self.webViewLoadRequestIsPrepared.assertValues([true, true, true])
      self.webViewLoadRequestURL.assertValues(
        [
          newPledgeURL(project: project),
          pledgeURL(project: project),
          newPaymentsURL()
        ]
      )

      // 5: Apple Pay sheet

      self.goToPaymentAuthorization.assertValueCount(1)

      self.vm.inputs.paymentAuthorizationWillAuthorizePayment()

      XCTAssertEqual(["Apple Pay Show Sheet"], self.trackingClient.events)

      self.vm.inputs.paymentAuthorizationDidFinish()

      XCTAssertEqual(["Apple Pay Show Sheet", "Apple Pay Canceled"], self.trackingClient.events)

      self.vm.inputs.paymentAuthorizationWillAuthorizePayment()
      self.vm.inputs.paymentAuthorization(
        didAuthorizePayment: .init(
          tokenData: .init(
            paymentMethodData: .init(displayName: "AmEx 1111", network: "AmEx", type: .Credit),
            transactionIdentifier: "apple_pay_deadbeef"
          )
        )
      )

      XCTAssertEqual(
        [
          "Apple Pay Show Sheet", "Apple Pay Canceled", "Apple Pay Show Sheet", "Apple Pay Authorized"
        ],
        self.trackingClient.events)

      self.vm.inputs.stripeCreatedToken(stripeToken: "stripe_deadbeef", error: nil)

      XCTAssertEqual(
        [
          "Apple Pay Show Sheet", "Apple Pay Canceled", "Apple Pay Show Sheet", "Apple Pay Authorized",
          "Apple Pay Stripe Token Created"
        ],
        self.trackingClient.events)

      self.vm.inputs.paymentAuthorizationDidFinish()

      XCTAssertEqual(
        [
          "Apple Pay Show Sheet", "Apple Pay Canceled", "Apple Pay Show Sheet", "Apple Pay Authorized",
          "Apple Pay Stripe Token Created", "Apple Pay Finished"
        ],
        self.trackingClient.events)

      self.evaluateJavascript.assertValues([
        "window.checkout_apple_pay_next({\"apple_pay_token\":{\"transaction_identifier\":" +
          "\"apple_pay_deadbeef\",\"payment_instrument_name\":\"AmEx 1111\",\"payment_network\":\"AmEx\"}," +
          "\"stripe_token\":{\"id\":\"stripe_deadbeef\"}});"
        ])

      // 6: Submit payment form
      self.webViewLoadRequestURL.assertValueCount(3)

      XCTAssertFalse(
        self.vm.inputs.shouldStartLoad(withRequest: paymentsRequest(), navigationType: .FormSubmitted),
        "Not prepared"
      )

      self.webViewLoadRequestIsPrepared.assertValues([true, true, true, true])
      self.webViewLoadRequestURL.assertValues(
        [
          newPledgeURL(project: project),
          pledgeURL(project: project),
          newPaymentsURL(),
          paymentsURL()
        ]
      )

      XCTAssertTrue(
        self.vm.inputs.shouldStartLoad(withRequest: paymentsRequest().prepared(), navigationType: .Other)
      )

      // 7: Redirect to thanks
      self.goToThanks.assertDidNotEmitValue()
      self.webViewLoadRequestURL.assertValueCount(4)

      XCTAssertFalse(
        self.vm.inputs.shouldStartLoad(
          withRequest: thanksRequest(project: project, racing: false),
          navigationType: .Other
        ),
        "Don't go to the URL since we handle it with a native thanks screen."
      )
      self.goToThanks.assertValueCount(1)
    }
  }

  func testSetStripeAppleMerchantIdentifier_NotApplePayCapable() {
    self.vm.inputs.configureWith(initialRequest: newPledgeRequest(project: .template).prepared(),
                                 project: .template,
                                 applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    self.setStripeAppleMerchantIdentifier.assertValues([])
  }

  func testSetStripeAppleMerchantIdentifier_ApplePayCapable() {
    self.vm.inputs.configureWith(initialRequest: newPledgeRequest(project: .template).prepared(),
                                 project: .template,
                                 applePayCapable: true)
    self.vm.inputs.viewDidLoad()

    self.setStripeAppleMerchantIdentifier.assertValues(
      [PKPaymentAuthorizationViewController.merchantIdentifier]
    )
  }

  func testSetStripePublishableKey_NotApplePayCapable() {
    withEnvironment(config: .template |> Config.lens.stripePublishableKey .~ "deadbeef") {
      self.vm.inputs.configureWith(initialRequest: newPledgeRequest(project: .template).prepared(),
                                   project: .template,
                                   applePayCapable: false)
      self.vm.inputs.viewDidLoad()

      self.setStripePublishableKey.assertValues([])
    }
  }

  func testSetStripePublishableKey_ApplePayCapable() {
    withEnvironment(config: .template |> Config.lens.stripePublishableKey .~ "deadbeef") {
      self.vm.inputs.configureWith(initialRequest: newPledgeRequest(project: .template).prepared(),
                                   project: .template,
                                   applePayCapable: true)
      self.vm.inputs.viewDidLoad()

      self.setStripePublishableKey.assertValues(["deadbeef"])
    }
  }

}

internal extension NSURLRequest {
  internal func prepared() -> NSURLRequest {
    return AppEnvironment.current.apiService.preparedRequest(forRequest: self)
  }
}

private func applePayUrlRequest(project project: Project,
                                 amount: Int,
                                 reward: Reward,
                                 location: Location) -> NSURLRequest {

  let payload = [
    "country_code": project.country.countryCode,
    "currency_code": project.country.currencyCode,
    "merchant_identifier": PKPaymentAuthorizationViewController.merchantIdentifier,
    "supported_networks": [ "AmEx", "Visa", "MasterCard", "Discover" ],
    "payment_summary_items": [
      [
        "label": project.name,
        "amount": "\(amount)"
      ],
      [
        "label": "Kickstarter (if funded)",
        "amount": "\(amount)"
      ]
    ]
  ]

  return (try? NSJSONSerialization.dataWithJSONObject(payload, options: []))
    .flatMap { String(data: $0.base64EncodedDataWithOptions([]), encoding: NSUTF8StringEncoding) }
    .map { "https://www.kickstarter.com/checkouts/1/payments/apple-pay?payload=\($0)" }
    .flatMap(NSURL.init(string:))
    .flatMap(NSURLRequest.init(URL:))
    .coalesceWith(NSURLRequest())
}

private func cancelPledgeRequest(project project: Project) -> NSURLRequest {
  return NSURLRequest(URL: NSURL(string: cancelPledgeURL(project: project))!)
}

private func cancelPledgeURL(project project: Project) -> String {
  return "\(project.urls.web.project)/pledge/destroy"
}

private func changePaymentMethodRequest(project project: Project) -> NSURLRequest {
  return NSURLRequest(URL: NSURL(string: changePaymentMethodURL(project: project))!)
}

private func changePaymentMethodURL(project project: Project) -> String {
  return "\(project.urls.web.project)/pledge/change_method"
}

private func creatorRequest(project project: Project) -> NSURLRequest {
  return NSURLRequest(URL: NSURL(string: creatorURL(project: project))!)
}

private func creatorURL(project project: Project) -> String {
  return "\(project.urls.web.project)/pledge/big_print?modal=true#creator"
}

private func editPledgeRequest(project project: Project) -> NSURLRequest {
  return NSURLRequest(URL: NSURL(string: editPledgeURL(project: project))!)
}

private func editPledgeURL(project project: Project) -> String {
  return "\(project.urls.web.project)/pledge/edit"
}

private func newPaymentsRequest() -> NSURLRequest {
  return NSURLRequest(URL: NSURL(string: newPaymentsURL())!)
}

private func newPaymentsURL() -> String {
  return "https://www.kickstarter.com/checkouts/1/payments/new"
}

private func newPledgeRequest(project project: Project) -> NSURLRequest {
  return NSURLRequest(URL: NSURL(string: newPledgeURL(project: project))!)
}

private func newPledgeURL(project project: Project) -> String {
  return "\(project.urls.web.project)/pledge/new"
}

private func paymentsRequest() -> NSURLRequest {
  let request = NSMutableURLRequest(URL: NSURL(string: paymentsURL())!)
  request.HTTPMethod = "POST"
  return request
}

private func paymentsURL() -> String {
  return "https://www.kickstarter.com/checkouts/1/payments"
}

private func pledgeRequest(project project: Project) -> NSURLRequest {
  let request = NSMutableURLRequest(URL: NSURL(string: pledgeURL(project: project))!)
  request.HTTPMethod = "POST"
  return request
}

private func pledgeURL(project project: Project) -> String {
  return "\(project.urls.web.project)/pledge"
}

private func privacyPolicyRequest(project project: Project) -> NSURLRequest {
  return NSURLRequest(URL:
    NSURL(string: privacyPolicyURL(project: project))!
  )
}

private func privacyPolicyURL(project project: Project) -> String {
  return "\(project.urls.web.project)/privacy?modal=true&ref=checkout_payment_sources_page"
}

private func projectRequest(project project: Project) -> NSURLRequest {
  return NSURLRequest(URL: NSURL(string: project.urls.web.project)!)
}

private func signupRequest() -> NSURLRequest {
  return NSURLRequest(URL: NSURL(string: "https://www.kickstarter.com/signup?context=checkout&then=%2Ffoo")!)
}

private func stripeRequest() -> NSURLRequest {
  return NSURLRequest(URL: NSURL(string: stripeURL())!)
}

private func stripeURL() -> String {
  return "https://js.stripe.com/v2/channel.html"
}

private func thanksRequest(project project: Project, racing: Bool) -> NSURLRequest {
  return NSURLRequest(URL: NSURL(string: thanksURL(project: project, racing: racing))!)
}

private func thanksURL(project project: Project, racing: Bool) -> String {
  return "\(project.urls.web.project)/checkouts/1/thanks\(racing ? "?racing=1" : "")"
}

private func useStoredCardRequest() -> NSURLRequest {
  return NSURLRequest(URL: NSURL(string: useStoredCardURL())!)
}

private func useStoredCardURL() -> String {
  return "https://www.kickstarter.com/checkouts/1/payments/use_stored_card"
}
