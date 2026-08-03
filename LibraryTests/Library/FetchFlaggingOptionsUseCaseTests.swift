import GraphAPI
@testable import KsApi
@testable import KsApiTestHelpers
@testable import Library
@testable import LibraryTestHelpers
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class FetchFlaggingOptionsUseCaseTests: TestCase {
  private var useCase: FetchFlaggingOptionsUseCase!
  private let (trigger, triggerObserver) = Signal<Void, Never>.pipe()

  let flaggingOptions = TestObserver<[ReportProjectInfoListItem], Never>()
  let isLoading = TestObserver<Bool, Never>()

  override func setUp() {
    super.setUp()

    self.useCase = FetchFlaggingOptionsUseCase(
      contentType: .project,
      initialSignal: self.trigger
    )

    self.useCase.outputs.flaggingOptions.observe(self.flaggingOptions.observer)
    self.useCase.outputs.isLoading.observe(self.isLoading.observer)
  }

  func testFlaggingOptions_DoesNotEmit_BeforeTrigger() {
    self.flaggingOptions.assertDidNotEmitValue()
  }

  func testFlaggingOptions_EmitsEmptyArray_ImmediatelyOnTrigger() {
    self.triggerObserver.send(value: ())

    self.flaggingOptions.assertValues([[]])
  }

  func testFlaggingOptions_EmitsItems_AfterSuccessfulFetch() {
    withEnvironment(apiService: MockService(fetchFlaggingOptionsResult: .success(.mock))) {
      self.triggerObserver.send(value: ())

      /// First value is the immediate empty array, second is the loaded items
      self.flaggingOptions.assertValueCount(2)
      XCTAssertFalse(self.flaggingOptions.lastValue?.isEmpty ?? true)
    }
  }

  func testFlaggingOptions_MapsItemsCorrectly() {
    withEnvironment(apiService: MockService(fetchFlaggingOptionsResult: .success(.mock))) {
      self.triggerObserver.send(value: ())

      let items = self.flaggingOptions.lastValue ?? []
      XCTAssertEqual(items.first?.id, "project/post_funding_issues")
      XCTAssertNotNil(items.first?.subItems)
    }
  }

  func testFlaggingOptions_OnlyEmitsEmptyArray_OnFetchError() {
    withEnvironment(apiService: MockService(fetchFlaggingOptionsResult: .failure(.couldNotParseJSON))) {
      self.triggerObserver.send(value: ())

      self.flaggingOptions.assertValues([[]])
    }
  }

  func testFlaggingOptions_OnFetchError() {
    withEnvironment(apiService: MockService(fetchFlaggingOptionsResult: .failure(.couldNotParseJSON))) {
      self.triggerObserver.send(value: ())

      self.flaggingOptions.assertDidNotComplete()
    }
  }

  func testIsLoading_DoesNotEmit_BeforeTrigger() {
    self.isLoading.assertDidNotEmitValue()
  }

  func testIsLoading_EmitsTrueThenFalse_OnSuccess() {
    withEnvironment(apiService: MockService(fetchFlaggingOptionsResult: .success(.mock))) {
      self.triggerObserver.send(value: ())

      self.isLoading.assertValues([true, false])
    }
  }

  func testIsLoading_EmitsTrueThenFalse_OnError() {
    withEnvironment(apiService: MockService(fetchFlaggingOptionsResult: .failure(.couldNotParseJSON))) {
      self.triggerObserver.send(value: ())

      self.isLoading.assertValues([true, false])
    }
  }
}

// MARK: Mock data

extension GraphAPI.FlaggingOptionsQuery.Data {
  /// Minimal mock representing a two-level flagging options tree.
  static var mock: Self {
    // Replace with your project's Apollo mock data initializer pattern.
    // The structure mirrors the flat API response: a root GROUP with one OPTION child.
    .init(flaggingOptions: [
      .init(
        id: "project/post_funding_issues",
        parentId: "project",
        kind: nil,
        nodeType: .case(.group),
        title: "Concerns about rewards, project completion or creator communication.",
        subtitle: "Report an issue with the fulfillment of your reward.",
        placeholder: nil
      ),
      .init(
        id: "project/post_funding_issues/reward_received/post_funding_reward_not_as_described",
        parentId: "project/post_funding_issues",
        kind: .case(.postFundingRewardNotAsDescribed),
        nodeType: .case(.option),
        title: "I received my reward, but it was not as described.",
        subtitle: nil,
        placeholder: "Please share more information about the reward."
      )
    ])
  }
}
