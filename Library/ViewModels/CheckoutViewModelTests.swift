// swiftlint:disable force_unwrapping
// swiftlint:disable force_cast
import XCTest
@testable import Library
@testable import KsApi
@testable import ReactiveExtensions_TestHelpers
import Result
import KsApi
import PassKit
import Prelude

private let questionMark = CharacterSet(charactersIn: "?")

final class CheckoutViewModelTests: TestCase {
  fileprivate let vm: CheckoutViewModelType = CheckoutViewModel()

  fileprivate let closeLoginTout = TestObserver<(), NoError>()
  fileprivate let dismissViewController = TestObserver<(), NoError>()
  fileprivate let evaluateJavascript = TestObserver<String, NoError>()
  fileprivate let goToPaymentAuthorization = TestObserver<NSDictionary, NoError>()
  fileprivate let goToSafariBrowser = TestObserver<URL, NoError>()
  fileprivate let goToThanks = TestObserver<Project, NoError>()
  fileprivate let goToWebModal = TestObserver<URLRequest, NoError>()
  fileprivate let openLoginTout = TestObserver<(), NoError>()
  fileprivate let popViewController = TestObserver<(), NoError>()
  fileprivate let setStripeAppleMerchantIdentifier = TestObserver<String, NoError>()
  fileprivate let setStripePublishableKey = TestObserver<String, NoError>()
  fileprivate let showAlert = TestObserver<String, NoError>()
  fileprivate let webViewLoadRequestIsPrepared = TestObserver<Bool, NoError>()
  fileprivate let webViewLoadRequestURL = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.closeLoginTout.observe(self.closeLoginTout.observer)
    self.vm.outputs.dismissViewController.observe(self.dismissViewController.observer)
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
    self.vm.outputs.showAlert.observe(self.showAlert.observer)
    self.vm.outputs.webViewLoadRequest
      .map { AppEnvironment.current.apiService.isPrepared(request: $0) }
      .observe(self.webViewLoadRequestIsPrepared.observer)
    self.vm.outputs.webViewLoadRequest
      .map { request -> String? in
        // Trim query parameters
        guard let url = request.url else { return nil }
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
        components.queryItems = components.queryItems?.filter {
          $0.name != "client_id" && $0.name != "currency" && $0.name != "oauth_token"
        }
        return components.string?.trimmingCharacters(in: questionMark)
      }
      .skipNil()
      .observe(self.webViewLoadRequestURL.observer)
  }

  func testCancelButtonPopsViewController() {
    let project = Project.template

    self.vm.inputs.configureWith(initialRequest: newPaymentsRequest().prepared(),
                                 project: project,
                                 reward: .template,
                                 applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    XCTAssertTrue(self.vm.inputs.shouldStartLoad(withRequest: stripeRequest(), navigationType: .other))

    // 1: Cancel button tapped
    self.popViewController.assertDidNotEmitValue()
    XCTAssertEqual([], self.trackingClient.events)

    self.vm.inputs.cancelButtonTapped()
    self.popViewController.assertValueCount(1)
    XCTAssertEqual(["Checkout Cancel", "Canceled Checkout"],
                   self.trackingClient.events, "Cancel event and its deprecated version are tracked")
    XCTAssertEqual(["new_pledge", "new_pledge"],
                   self.trackingClient.properties(forKey: "pledge_context", as: String.self))
  }

  func testNewPledgeRequestDismissesViewController() {
    let project = Project.template

    self.webViewLoadRequestURL.assertDidNotEmitValue()

    // 1: Open new payments form
    self.vm.inputs.configureWith(initialRequest: newPaymentsRequest().prepared(),
                                 project: project,
                                 reward: .template,
                                 applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    self.webViewLoadRequestURL.assertValues([newPaymentsURL()])

    XCTAssertFalse(
      self.vm.inputs.shouldStartLoad(withRequest: newPaymentsRequest(), navigationType: .other),
      "Not prepared"
    )

    XCTAssertTrue(
      self.vm.inputs.shouldStartLoad(
        withRequest: newPaymentsRequest().prepared(),
        navigationType: .other)
    )

    self.webViewLoadRequestIsPrepared.assertValues([true, true])
    self.webViewLoadRequestURL.assertValues(
      [newPaymentsURL(), newPaymentsURL()]
    )

    XCTAssertTrue(self.vm.inputs.shouldStartLoad(withRequest: stripeRequest(), navigationType: .other))

    // 2: Web view should not attempt to load the new pledge request
    XCTAssertFalse(
      self.vm.inputs.shouldStartLoad(
        withRequest: newPledgeRequest(project: project).prepared(),
        navigationType: .other
      )
    )

    self.webViewLoadRequestURL.assertValues([newPaymentsURL(), newPaymentsURL()])

    // 3: If we requested new pledge, the view controller should be dismissed
    self.dismissViewController.assertValueCount(1)
  }

  func testCancelPledge() {
    let project = Project.template
    withEnvironment(currentUser: .template) {
      self.webViewLoadRequestURL.assertDidNotEmitValue()

      self.vm.inputs.configureWith(initialRequest: editPledgeRequest(project: project).prepared(),
                                   project: project,
                                   reward: .template,
                                   applePayCapable: false)
      self.vm.inputs.viewDidLoad()

      // 1: Show reward and shipping form
      self.webViewLoadRequestIsPrepared.assertValues([true])
      self.webViewLoadRequestURL.assertValues([editPledgeURL(project: project)])

      XCTAssertTrue(
        self.vm.inputs.shouldStartLoad(
          withRequest: editPledgeRequest(project: project).prepared(),
          navigationType: .other
        )
      )
      XCTAssertTrue(self.vm.inputs.shouldStartLoad(withRequest: stripeRequest(), navigationType: .other))

      // 2: Click cancel link
      XCTAssertFalse(
        self.vm.inputs.shouldStartLoad(
          withRequest: cancelPledgeRequest(project: project),
          navigationType: .linkClicked
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
          navigationType: .other
        )
      )
      XCTAssertTrue(self.vm.inputs.shouldStartLoad(withRequest: stripeRequest(), navigationType: .other))

      // 3: Confirm cancellation
      XCTAssertFalse(
        self.vm.inputs.shouldStartLoad(
          withRequest: pledgeRequest(project: project),
          navigationType: .formSubmitted
        ),
        "Not prepared"
      )
      self.webViewLoadRequestIsPrepared.assertValues([true, true, true])
      self.webViewLoadRequestURL.assertValues(
        [editPledgeURL(project: project), cancelPledgeURL(project: project), pledgeURL(project: project)]
      )

      // 4: Redirect to project, view controller dismissed
      self.dismissViewController.assertDidNotEmitValue()
      XCTAssertEqual([], self.trackingClient.events)
      XCTAssertEqual([], self.trackingClient.properties(forKey: "type", as: String.self))

      XCTAssertFalse(
        self.vm.inputs.shouldStartLoad(withRequest: projectRequest(project: project), navigationType: .other)
      )
      XCTAssertEqual(["Checkout Cancel", "Canceled Checkout"],
                     self.trackingClient.events)
      self.dismissViewController.assertValueCount(1)
    }

    self.evaluateJavascript.assertValueCount(0, "No javascript was evaluated.")
  }

  func testChangePaymentMethod() {
    let project = Project.template
    withEnvironment(currentUser: .template) {
      self.webViewLoadRequestURL.assertDidNotEmitValue()

      self.vm.inputs.configureWith(initialRequest: editPledgeRequest(project: project).prepared(),
                                   project: project,
                                   reward: .template,
                                   applePayCapable: false)
      self.vm.inputs.viewDidLoad()

      // 1: Show reward and shipping form
      self.webViewLoadRequestIsPrepared.assertValues([true])
      self.webViewLoadRequestURL.assertValues([editPledgeURL(project: project)])

      XCTAssertTrue(
        self.vm.inputs.shouldStartLoad(
          withRequest: editPledgeRequest(project: project).prepared(),
          navigationType: .other
        )
      )
      XCTAssertTrue(self.vm.inputs.shouldStartLoad(withRequest: stripeRequest(), navigationType: .other))

      // 2: Click change payment method button
      XCTAssertFalse(
        self.vm.inputs.shouldStartLoad(
          withRequest: changePaymentMethodRequest(project: project),
          navigationType: .formSubmitted
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
          navigationType: .other
        )
      )
      XCTAssertTrue(self.vm.inputs.shouldStartLoad(withRequest: stripeRequest(), navigationType: .other))

      // 3: Redirect to new payments form
      self.webViewLoadRequestURL.assertValueCount(2)

      XCTAssertFalse(
        self.vm.inputs.shouldStartLoad(withRequest: newPaymentsRequest(), navigationType: .other),
        "Not prepared"
      )

      self.webViewLoadRequestIsPrepared.assertValues([true, true, true])
      self.webViewLoadRequestURL.assertValues(
        [editPledgeURL(project: project), changePaymentMethodURL(project: project), newPaymentsURL()]
      )

      XCTAssertTrue(
        self.vm.inputs.shouldStartLoad(withRequest: newPaymentsRequest().prepared(), navigationType: .other)
      )
      XCTAssertTrue(self.vm.inputs.shouldStartLoad(withRequest: stripeRequest(), navigationType: .other))

      // 4: Pledge with new card
      self.webViewLoadRequestURL.assertValueCount(3)

      XCTAssertFalse(
        self.vm.inputs.shouldStartLoad(withRequest: paymentsRequest(), navigationType: .formSubmitted),
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
        self.vm.inputs.shouldStartLoad(withRequest: paymentsRequest().prepared(), navigationType: .other)
      )

      // 5: Redirect to thanks
      self.goToThanks.assertDidNotEmitValue()
      self.webViewLoadRequestURL.assertValueCount(4)

      XCTAssertFalse(
        self.vm.inputs.shouldStartLoad(
          withRequest: thanksRequest(
            project: project, racing: false),
          navigationType: .other
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

      // 1: Open new payments form
      self.vm.inputs.configureWith(initialRequest: newPaymentsRequest().prepared(),
                                   project: project,
                                   reward: .template,
                                   applePayCapable: false)
      self.vm.inputs.viewDidLoad()

      self.webViewLoadRequestURL.assertValues([newPaymentsURL()])

      XCTAssertFalse(
        self.vm.inputs.shouldStartLoad(withRequest: newPaymentsRequest(), navigationType: .other),
        "Not prepared"
      )

      XCTAssertTrue(
        self.vm.inputs.shouldStartLoad(
          withRequest: newPaymentsRequest().prepared(),
          navigationType: .other)
      )

      self.webViewLoadRequestIsPrepared.assertValues([true, true])
      self.webViewLoadRequestURL.assertValues(
        [newPaymentsURL(), newPaymentsURL()]
      )

      XCTAssertTrue(self.vm.inputs.shouldStartLoad(withRequest: stripeRequest(), navigationType: .other))

      // 2: Pledge with new card
      self.webViewLoadRequestURL.assertValueCount(2)

      XCTAssertFalse(
        self.vm.inputs.shouldStartLoad(withRequest: paymentsRequest(), navigationType: .formSubmitted),
        "Not prepared"
      )

      self.webViewLoadRequestIsPrepared.assertValues([true, true, true])
      self.webViewLoadRequestURL.assertValues(
        [
          newPaymentsURL(),
          newPaymentsURL(),
          paymentsURL()
        ]
      )

      XCTAssertTrue(
        self.vm.inputs.shouldStartLoad(withRequest: paymentsRequest().prepared(), navigationType: .other)
      )

      // 3: Redirect to thanks
      self.goToThanks.assertDidNotEmitValue()
      self.webViewLoadRequestURL.assertValueCount(3)

      XCTAssertFalse(
        self.vm.inputs.shouldStartLoad(
          withRequest: thanksRequest(project: project, racing: false),
          navigationType: .other
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

      // 1: Open new payments form
      self.vm.inputs.configureWith(initialRequest: newPaymentsRequest().prepared(),
                                   project: project,
                                   reward: .template,
                                   applePayCapable: false)
      self.vm.inputs.viewDidLoad()

      self.webViewLoadRequestURL.assertValues([newPaymentsURL()])

      XCTAssertFalse(
        self.vm.inputs.shouldStartLoad(withRequest: newPaymentsRequest(), navigationType: .other),
        "Not prepared"
      )

      XCTAssertTrue(
        self.vm.inputs.shouldStartLoad(
          withRequest: newPaymentsRequest().prepared(),
          navigationType: .other)
      )

      self.webViewLoadRequestIsPrepared.assertValues([true, true])
      self.webViewLoadRequestURL.assertValues(
        [newPaymentsURL(), newPaymentsURL()]
      )

      XCTAssertTrue(self.vm.inputs.shouldStartLoad(withRequest: stripeRequest(), navigationType: .other))

      // 2: Pledge with stored card
      self.webViewLoadRequestURL.assertValueCount(2)

      XCTAssertFalse(
        self.vm.inputs.shouldStartLoad(withRequest: useStoredCardRequest(), navigationType: .formSubmitted),
        "Not prepared"
      )

      self.webViewLoadRequestIsPrepared.assertValues([true, true, true])
      self.webViewLoadRequestURL.assertValues(
        [
          newPaymentsURL(),
          newPaymentsURL(),
          useStoredCardURL()
        ]
      )

      XCTAssertTrue(
        self.vm.inputs.shouldStartLoad(withRequest: useStoredCardRequest().prepared(), navigationType: .other)
      )

      // 3: Redirect to thanks
      self.goToThanks.assertDidNotEmitValue()
      self.webViewLoadRequestURL.assertValueCount(3)

      XCTAssertFalse(
        self.vm.inputs.shouldStartLoad(
          withRequest: thanksRequest(project: project, racing: false),
          navigationType: .other
        ),
        "Don't go to the URL since we handle it with a native thanks screen."
      )
      self.goToThanks.assertValueCount(1)
    }

    self.evaluateJavascript.assertValueCount(0, "No javascript was evaluated.")
  }

  func testLoginDuringCheckout() {
    let project = Project.template

    self.vm.inputs.configureWith(initialRequest: newPaymentsRequest().prepared(),
                                 project: project,
                                 reward: .template,
                                 applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    // 1: Show reward and shipping form
    self.webViewLoadRequestIsPrepared.assertValues([true])
    self.webViewLoadRequestURL.assertValues([newPaymentsURL()])

    XCTAssertTrue(
      self.vm.inputs.shouldStartLoad(
        withRequest: newPaymentsRequest().prepared(),
        navigationType: .other
      )
    )
    XCTAssertTrue(self.vm.inputs.shouldStartLoad(withRequest: stripeRequest(), navigationType: .other))

    // 2: Submit reward and shipping form
    self.webViewLoadRequestURL.assertValueCount(1)

    XCTAssertFalse(
      self.vm.inputs.shouldStartLoad(
        withRequest: pledgeRequest(project: project),
        navigationType: .formSubmitted
      ),
      "Not prepared"
    )

    self.webViewLoadRequestIsPrepared.assertValues([true, true])
    self.webViewLoadRequestURL.assertValues(
      [newPaymentsURL(), pledgeURL(project: project)]
    )

    XCTAssertTrue(
      self.vm.inputs.shouldStartLoad(
        withRequest: pledgeRequest(project: project).prepared(),
        navigationType: .other
      )
    )

    // 3: Interrupt checkout for login/signup
    self.openLoginTout.assertDidNotEmitValue()

    XCTAssertFalse(self.vm.inputs.shouldStartLoad(withRequest: signupRequest(), navigationType: .other))
    self.openLoginTout.assertValueCount(1)

    // 4: Login
    AppEnvironment.login(.init(accessToken: "deadbeef", user: User.template))
    self.closeLoginTout.assertDidNotEmitValue()

    self.vm.inputs.userSessionStarted()
    self.closeLoginTout.assertValueCount(1)

    // 5: Attempt pledge request again
    self.webViewLoadRequestURL.assertValues(
      [newPaymentsURL(), pledgeURL(project: project), pledgeURL(project: project)],
      "Attempt pledge request again, now that user is logged in"
    )

    XCTAssertTrue(
      self.vm.inputs.shouldStartLoad(
        withRequest: pledgeRequest(project: project).prepared(),
        navigationType: .other
      )
    )
    XCTAssertFalse(
      self.vm.inputs.shouldStartLoad(withRequest: newPaymentsRequest(), navigationType: .other),
      "Not prepared"
    )

    self.webViewLoadRequestURL.assertValues(
      [
        newPaymentsURL(),
        pledgeURL(project: project),
        pledgeURL(project: project),
        newPaymentsURL()
      ]
    )

    XCTAssertTrue(
      self.vm.inputs.shouldStartLoad(withRequest: newPaymentsRequest().prepared(), navigationType: .other)
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
                                   reward: .template,
                                   applePayCapable: false)
      self.vm.inputs.viewDidLoad()

      // 1: Show reward and shipping form
      self.webViewLoadRequestIsPrepared.assertValues([true])
      self.webViewLoadRequestURL.assertValues([editPledgeURL(project: project)])

      XCTAssertTrue(
        self.vm.inputs.shouldStartLoad(
          withRequest: editPledgeRequest(project: project).prepared(),
          navigationType: .other
        )
      )
      XCTAssertTrue(self.vm.inputs.shouldStartLoad(withRequest: stripeRequest(), navigationType: .other))

      // 2: Submit reward and shipping form
      self.webViewLoadRequestURL.assertValueCount(1)

      XCTAssertFalse(
        self.vm.inputs.shouldStartLoad(
          withRequest: pledgeRequest(project: project),
          navigationType: .formSubmitted
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
          navigationType: .other
        )
      )

      // 3: Redirect to thanks
      self.goToThanks.assertDidNotEmitValue()

      XCTAssertFalse(
        self.vm.inputs.shouldStartLoad(
          withRequest: thanksRequest(project: project, racing: false),
          navigationType: .other
        ),
        "Don't go to the URL since we handle it with a native thanks screen."
      )
      self.goToThanks.assertValueCount(1)
    }

    self.evaluateJavascript.assertValueCount(0, "No javascript was evaluated.")
  }

  func testModalRequests() {
    let project = Project.template
    self.vm.inputs.configureWith(initialRequest: newPaymentsRequest().prepared(),
                                 project: project,
                                 reward: .template,
                                 applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    XCTAssertTrue(
      self.vm.inputs.shouldStartLoad(withRequest: newPaymentsRequest().prepared(),
        navigationType: .other)
    )
    self.goToWebModal.assertValueCount(0)

    XCTAssertFalse(
      self.vm.inputs.shouldStartLoad(withRequest: creatorRequest(project: project),
        navigationType: .linkClicked)
    )
    self.goToSafariBrowser.assertValueCount(0)
    self.goToWebModal.assertValueCount(1)

    XCTAssertFalse(
      self.vm.inputs.shouldStartLoad(withRequest: privacyPolicyRequest(project: project),
        navigationType: .linkClicked)
    )
    self.goToSafariBrowser.assertValueCount(1)
    self.goToWebModal.assertValueCount(1)
  }

  func testRacingFailure() {
    let failedEnvelope = CheckoutEnvelope.failed
    let project = Project.template
    withEnvironment(apiService: MockService(fetchCheckoutResponse: failedEnvelope), currentUser: .template) {
      self.webViewLoadRequestURL.assertDidNotEmitValue()

      // 1: Open new payments form
      self.vm.inputs.configureWith(initialRequest: newPaymentsRequest().prepared(),
                                   project: project,
                                   reward: .template,
                                   applePayCapable: false)
      self.vm.inputs.viewDidLoad()

      self.webViewLoadRequestURL.assertValues([newPaymentsURL()])

      XCTAssertFalse(
        self.vm.inputs.shouldStartLoad(withRequest: newPaymentsRequest(), navigationType: .other),
        "Not prepared"
      )

      XCTAssertTrue(
        self.vm.inputs.shouldStartLoad(
          withRequest: newPaymentsRequest().prepared(),
          navigationType: .other)
      )

      self.webViewLoadRequestIsPrepared.assertValues([true, true])
      self.webViewLoadRequestURL.assertValues(
        [newPaymentsURL(), newPaymentsURL()]
      )

      XCTAssertTrue(self.vm.inputs.shouldStartLoad(withRequest: stripeRequest(), navigationType: .other))

      // 2: Pledge with stored card
      self.webViewLoadRequestURL.assertValueCount(2)

      XCTAssertFalse(
        self.vm.inputs.shouldStartLoad(withRequest: useStoredCardRequest(), navigationType: .formSubmitted),
        "Not prepared"
      )

      self.webViewLoadRequestIsPrepared.assertValues([true, true, true])
      self.webViewLoadRequestURL.assertValues(
        [
          newPaymentsURL(),
          newPaymentsURL(),
          useStoredCardURL()
        ]
      )

      XCTAssertTrue(
        self.vm.inputs.shouldStartLoad(withRequest: useStoredCardRequest().prepared(), navigationType: .other)
      )

      // 3: Checkout is racing, delay a second to check status (failed!), then display failure alert.
      self.goToThanks.assertDidNotEmitValue()
      self.webViewLoadRequestURL.assertValueCount(3)

      XCTAssertFalse(
        self.vm.inputs.shouldStartLoad(
          withRequest: thanksRequest(project: project, racing: true),
          navigationType: .other
        )
      )
      self.showAlert.assertValueCount(0)

      self.scheduler.advance(by: .seconds(1))
      self.goToThanks.assertValueCount(0)
      self.showAlert.assertValues([failedEnvelope.stateReason])

      // 4: Alert dismissed, pop view controller
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

      // 1: Open new payments form
      self.vm.inputs.configureWith(initialRequest: newPaymentsRequest().prepared(),
                                   project: project,
                                   reward: .template,
                                   applePayCapable: false)
      self.vm.inputs.viewDidLoad()

      self.webViewLoadRequestURL.assertValues([newPaymentsURL()])

      XCTAssertFalse(
        self.vm.inputs.shouldStartLoad(withRequest: newPaymentsRequest(), navigationType: .other),
        "Not prepared"
      )

      XCTAssertTrue(
        self.vm.inputs.shouldStartLoad(
          withRequest: newPaymentsRequest().prepared(),
          navigationType: .other)
      )

      self.webViewLoadRequestIsPrepared.assertValues([true, true])
      self.webViewLoadRequestURL.assertValues(
        [newPaymentsURL(), newPaymentsURL()]
      )

      XCTAssertTrue(self.vm.inputs.shouldStartLoad(withRequest: stripeRequest(), navigationType: .other))

      // 2: Pledge with stored card
      self.webViewLoadRequestURL.assertValueCount(2)

      XCTAssertFalse(
        self.vm.inputs.shouldStartLoad(withRequest: useStoredCardRequest(), navigationType: .formSubmitted),
        "Not prepared"
      )

      self.webViewLoadRequestIsPrepared.assertValues([true, true, true])
      self.webViewLoadRequestURL.assertValues(
        [
          newPaymentsURL(),
          newPaymentsURL(),
          useStoredCardURL()
        ]
      )

      XCTAssertTrue(
        self.vm.inputs.shouldStartLoad(withRequest: useStoredCardRequest().prepared(), navigationType: .other)
      )

      // 3: Checkout is racing, delay a second to check status (successful!), then go to thanks.
      self.goToThanks.assertDidNotEmitValue()
      self.webViewLoadRequestURL.assertValueCount(3)

      XCTAssertFalse(
        self.vm.inputs.shouldStartLoad(
          withRequest: thanksRequest(project: project, racing: true),
          navigationType: .other
        )
      )

      self.scheduler.advance(by: .seconds(1))
      self.showAlert.assertValueCount(0)
      self.goToThanks.assertValueCount(1)
    }

    self.evaluateJavascript.assertValueCount(0, "No javascript was evaluated.")
  }

  func testProjectRequestDismissesViewController() {
    let project = Project.template

    self.webViewLoadRequestURL.assertDidNotEmitValue()

    // 1: Open new payments form
    self.vm.inputs.configureWith(initialRequest: newPaymentsRequest().prepared(),
                                 project: project,
                                 reward: .template,
                                 applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    self.webViewLoadRequestURL.assertValues([newPaymentsURL()])

    XCTAssertFalse(
      self.vm.inputs.shouldStartLoad(withRequest: newPaymentsRequest(), navigationType: .other),
      "Not prepared"
    )

    XCTAssertTrue(
      self.vm.inputs.shouldStartLoad(
        withRequest: newPaymentsRequest().prepared(),
        navigationType: .other)
    )

    self.webViewLoadRequestIsPrepared.assertValues([true, true])
    self.webViewLoadRequestURL.assertValues(
      [newPaymentsURL(), newPaymentsURL()]
    )

    XCTAssertTrue(self.vm.inputs.shouldStartLoad(withRequest: stripeRequest(), navigationType: .other))

    // 2: Project link clicked
    self.dismissViewController.assertDidNotEmitValue()
    XCTAssertEqual([], self.trackingClient.events)

    XCTAssertFalse(
      self.vm.inputs.shouldStartLoad(
        withRequest: projectRequest(project: project),
        navigationType: .linkClicked
      )
    )

    self.dismissViewController.assertValueCount(1)
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

      // 1: Open new payments form
      self.vm.inputs.configureWith(initialRequest: newPaymentsRequest().prepared(),
                                   project: project,
                                   reward: .template,
                                   applePayCapable: true)
      self.vm.inputs.viewDidLoad()

      self.webViewLoadRequestURL.assertValues([newPaymentsURL()])

      XCTAssertFalse(
        self.vm.inputs.shouldStartLoad(withRequest: newPaymentsRequest(), navigationType: .other),
        "Not prepared"
      )

      XCTAssertTrue(
        self.vm.inputs.shouldStartLoad(
          withRequest: newPaymentsRequest().prepared(),
          navigationType: .other)
      )

      self.webViewLoadRequestIsPrepared.assertValues([true, true])
      self.webViewLoadRequestURL.assertValues(
        [newPaymentsURL(), newPaymentsURL()]
      )

      XCTAssertTrue(self.vm.inputs.shouldStartLoad(withRequest: stripeRequest(), navigationType: .other))

      // 2: Pledge with apple pay
      self.webViewLoadRequestURL.assertValueCount(2)

      XCTAssertFalse(
        self.vm.inputs.shouldStartLoad(
          withRequest: applePayUrlRequest(
            project: project,
            amount: amount,
            reward: reward,
            location: location
          ),
          navigationType: .linkClicked
        ),
        "Apple Pay url not allowed"
      )

      self.webViewLoadRequestIsPrepared.assertValues([true, true])
      self.webViewLoadRequestURL.assertValues(
        [
          newPaymentsURL(),
          newPaymentsURL()
        ]
      )

      // 3: Apple Pay sheet

      self.goToPaymentAuthorization.assertValueCount(1)

      self.vm.inputs.paymentAuthorizationWillAuthorizePayment()

      XCTAssertEqual(["Apple Pay Show Sheet", "Showed Apple Pay Sheet"], self.trackingClient.events)

      self.vm.inputs.paymentAuthorization(
        didAuthorizePayment: .init(
          tokenData: .init(
            paymentMethodData: .init(displayName: "AmEx 1111", network: .amex, type: .credit),
            transactionIdentifier: "apple_pay_deadbeef"
          )
        )
      )

      XCTAssertEqual(
        ["Apple Pay Show Sheet", "Showed Apple Pay Sheet", "Apple Pay Authorized", "Authorized Apple Pay"],
        self.trackingClient.events)

      let status = self.vm.inputs.stripeCreatedToken(stripeToken: "stripe_deadbeef", error: nil)
      XCTAssertEqual(.success, status)

      XCTAssertEqual(
        ["Apple Pay Show Sheet", "Showed Apple Pay Sheet", "Apple Pay Authorized", "Authorized Apple Pay",
          "Apple Pay Stripe Token Created", "Created Apple Pay Stripe Token"],
        self.trackingClient.events)

      self.vm.inputs.paymentAuthorizationDidFinish()

      XCTAssertEqual(
        ["Apple Pay Show Sheet", "Showed Apple Pay Sheet", "Apple Pay Authorized", "Authorized Apple Pay",
          "Apple Pay Stripe Token Created", "Created Apple Pay Stripe Token", "Apple Pay Finished"],
        self.trackingClient.events
      )

      XCTAssertEqual(
        ["new_pledge", "new_pledge", "new_pledge", "new_pledge", "new_pledge", "new_pledge", "new_pledge"],
        self.trackingClient.properties(forKey: "pledge_context", as: String.self)
      )

      let javascriptDictionary: [String: Any] =
        self.dictionaryFromJavascript(string: self.evaluateJavascript.lastValue!)

      let applePayToken: [String: String] = javascriptDictionary["apple_pay_token"] as! [String: String]
      XCTAssertEqual(applePayToken["payment_instrument_name"], "AmEx 1111")
      XCTAssertEqual(applePayToken["payment_network"], "AmEx")
      XCTAssertEqual(applePayToken["transaction_identifier"], "apple_pay_deadbeef")

      let stripeToken: [String: String] = javascriptDictionary["stripe_token"] as! [String: String]
      XCTAssertEqual(stripeToken["id"], "stripe_deadbeef")

      // 4: Submit payment form
      self.webViewLoadRequestURL.assertValueCount(2)

      XCTAssertFalse(
        self.vm.inputs.shouldStartLoad(withRequest: paymentsRequest(), navigationType: .formSubmitted),
        "Not prepared"
      )

      self.webViewLoadRequestIsPrepared.assertValues([true, true, true])
      self.webViewLoadRequestURL.assertValues(
        [
          newPaymentsURL(),
          newPaymentsURL(),
          paymentsURL()
        ]
      )

      XCTAssertTrue(
        self.vm.inputs.shouldStartLoad(withRequest: paymentsRequest().prepared(), navigationType: .other)
      )
      XCTAssertEqual(
        ["Apple Pay Show Sheet", "Showed Apple Pay Sheet", "Apple Pay Authorized", "Authorized Apple Pay",
          "Apple Pay Stripe Token Created", "Created Apple Pay Stripe Token", "Apple Pay Finished",
        ],
        self.trackingClient.events
      )

      // 5: Redirect to thanks
      self.goToThanks.assertDidNotEmitValue()
      self.webViewLoadRequestURL.assertValueCount(3)

      XCTAssertFalse(
        self.vm.inputs.shouldStartLoad(
          withRequest: thanksRequest(project: project, racing: false),
          navigationType: .other
        ),
        "Don't go to the URL since we handle it with a native thanks screen."
      )
      self.goToThanks.assertValueCount(1)
    }
  }

  func testSetStripeAppleMerchantIdentifier_NotApplePayCapable() {
    self.vm.inputs.configureWith(initialRequest: newPledgeRequest(project: .template).prepared(),
                                 project: .template,
                                 reward: .template,
                                 applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    self.setStripeAppleMerchantIdentifier.assertValueCount(0)
  }

  func testSetStripeAppleMerchantIdentifier_ApplePayCapable() {
    self.vm.inputs.configureWith(initialRequest: newPledgeRequest(project: .template).prepared(),
                                 project: .template,
                                 reward: .template,
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
                                   reward: .template,
                                   applePayCapable: false)
      self.vm.inputs.viewDidLoad()

      self.setStripePublishableKey.assertValueCount(0)
    }
  }

  func testSetStripePublishableKey_ApplePayCapable() {
    withEnvironment(config: .template |> Config.lens.stripePublishableKey .~ "deadbeef") {
      self.vm.inputs.configureWith(initialRequest: newPledgeRequest(project: .template).prepared(),
                                   project: .template,
                                   reward: .template,
                                   applePayCapable: true)
      self.vm.inputs.viewDidLoad()

      self.setStripePublishableKey.assertValues(["deadbeef"])
    }
  }

  private func dictionaryFromJavascript(string: String) -> [String: Any] {

    let formattedString = "{\"stripe_token\":{\"id\":\"stripe_deadbeef\"}," +
    "\"apple_pay_token\":{\"payment_instrument_name\":\"AmEx 1111\",\"payment_network\":\"AmEx\"," +
    "\"transaction_identifier\":\"apple_pay_deadbeef\"}}"

    do {
      return try JSONSerialization.jsonObject(with: formattedString.data(using: .utf8)!,
                                              options: []) as! [String: Any]
    } catch {
      return [:]
    }
  }
}

internal extension URLRequest {
  internal func prepared() -> URLRequest {
    return AppEnvironment.current.apiService.preparedRequest(forRequest: self)
  }
}

private func applePayUrlRequest(project: Project,
                                amount: Int,
                                reward: Reward,
                                location: Location) -> URLRequest {

  let payload: [String: Any] = [
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

  let url = (try? JSONSerialization.data(withJSONObject: payload, options: []))
    .map { $0.base64EncodedString() }
    .map { "https://www.kickstarter.com/checkouts/1/payments/apple-pay?payload=\($0)" }
    .flatMap(URL.init(string:))

  return URLRequest(url: url!)
}

private func cancelPledgeRequest(project: Project) -> URLRequest {
  return URLRequest(url: URL(string: cancelPledgeURL(project: project))!)
}

private func cancelPledgeURL(project: Project) -> String {
  return "\(project.urls.web.project)/pledge/destroy"
}

private func changePaymentMethodRequest(project: Project) -> URLRequest {
  return URLRequest(url: URL(string: changePaymentMethodURL(project: project))!)
}

private func changePaymentMethodURL(project: Project) -> String {
  return "\(project.urls.web.project)/pledge/change_method"
}

private func creatorRequest(project: Project) -> URLRequest {
  return URLRequest(url: URL(string: creatorURL(project: project))!)
}

private func creatorURL(project: Project) -> String {
  return "\(project.urls.web.project)/pledge/big_print?modal=true#creator"
}

private func editPledgeRequest(project: Project) -> URLRequest {
  return URLRequest(url: URL(string: editPledgeURL(project: project))!)
}

private func editPledgeURL(project: Project) -> String {
  return "\(project.urls.web.project)/pledge/edit"
}

private func newPaymentsRequest() -> URLRequest {
  return URLRequest(url: URL(string: newPaymentsURL())!)
}

private func newPaymentsURL() -> String {
  return "https://www.kickstarter.com/checkouts/1/payments/new"
}

private func newPledgeRequest(project: Project) -> URLRequest {
  return URLRequest(url: URL(string: newPledgeURL(project: project))!)
}

private func newPledgeURL(project: Project) -> String {
  return "\(project.urls.web.project)/pledge/new"
}

private func paymentsRequest() -> URLRequest {
  var request = URLRequest(url: URL(string: paymentsURL())!)
  request.httpMethod = "POST"
  return request
}

private func paymentsURL() -> String {
  return "https://www.kickstarter.com/checkouts/1/payments"
}

private func pledgeRequest(project: Project) -> URLRequest {
  var request = URLRequest(url: URL(string: pledgeURL(project: project))!)
  request.httpMethod = "POST"
  return request
}

private func pledgeURL(project: Project) -> String {
  return "\(project.urls.web.project)/pledge"
}

private func privacyPolicyRequest(project: Project) -> URLRequest {
  return URLRequest(url:
    URL(string: privacyPolicyURL(project: project))!
  )
}

private func privacyPolicyURL(project: Project) -> String {
  return "\(project.urls.web.project)/privacy?modal=true&ref=checkout_payment_sources_page"
}

private func projectRequest(project: Project) -> URLRequest {
  return URLRequest(url: URL(string: project.urls.web.project)!)
}

private func signupRequest() -> URLRequest {
  return URLRequest(url: URL(string: "https://www.kickstarter.com/signup?context=checkout&then=%2Ffoo")!)
}

private func stripeRequest() -> URLRequest {
  return URLRequest(url: URL(string: stripeURL())!)
}

private func stripeURL() -> String {
  return "https://js.stripe.com/v2/channel.html"
}

private func thanksRequest(project: Project, racing: Bool) -> URLRequest {
  return URLRequest(url: URL(string: thanksURL(project: project, racing: racing))!)
}

private func thanksURL(project: Project, racing: Bool) -> String {
  return "\(project.urls.web.project)/checkouts/1/thanks\(racing ? "?racing=1" : "")"
}

private func useStoredCardRequest() -> URLRequest {
  return URLRequest(url: URL(string: useStoredCardURL())!)
}

private func useStoredCardURL() -> String {
  return "https://www.kickstarter.com/checkouts/1/payments/use_stored_card"
}
