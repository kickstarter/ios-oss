@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers
import Prelude
import ReactiveCocoa
import Result
import UIKit
import XCTest

internal final class SortPagerViewModelTests: TestCase {
  private let vm: SortPagerViewModelType = SortPagerViewModel()

  private let notifyDelegateOfSelectedSort = TestObserver<DiscoveryParams.Sort, NoError>()
  private let pinSelectedIndicatorToPage = TestObserver<Int, NoError>()
  private let scrollPercentage = TestObserver<CGFloat, NoError>()
  private let createSortButtons = TestObserver<[DiscoveryParams.Sort], NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.notifyDelegateOfSelectedSort.observe(self.notifyDelegateOfSelectedSort.observer)
    self.vm.outputs.pinSelectedIndicatorToPage.observe(self.pinSelectedIndicatorToPage.observer)
    self.vm.outputs.scrollPercentage.observe(self.scrollPercentage.observer)
    self.vm.outputs.createSortButtons.observe(self.createSortButtons.observer)
  }

  func testCreateSortButtons() {
    let sorts: [DiscoveryParams.Sort] = [.Magic, .Popular, .Newest, .EndingSoon, .MostFunded]
    self.vm.inputs.configureWith(sorts: sorts)

    self.createSortButtons.assertValues([sorts], "Emits titles for the sort buttons.")
  }

  func testPinSelectedIndicator() {
    self.vm.inputs.configureWith(sorts: [.Magic, .Popular, .Newest, .EndingSoon, .MostFunded])

    self.pinSelectedIndicatorToPage.assertValues([], "Nothing emits initially.")

    self.vm.inputs.select(sort: .Popular)

    self.pinSelectedIndicatorToPage.assertValues([1], "Index of popular emits.")

    self.vm.inputs.sortButtonTapped(index: 3)

    self.pinSelectedIndicatorToPage.assertValues([1],
                                                 "Tapping sort button does not cause indicator to change.")
  }

  func testScrollPercentage() {
    self.vm.inputs.configureWith(sorts: [.Magic, .Popular, .Newest, .EndingSoon, .MostFunded])

    self.scrollPercentage.assertValues([], "Nothing emits initially.")

    self.vm.inputs.select(sort: .Popular)

    self.scrollPercentage.assertValues([0.25], "Selecting sort causes percentage to be emitted.")

    self.vm.inputs.sortButtonTapped(index: 3)

    self.scrollPercentage.assertValues([0.25], "Tapping button does not cause percentage to be emitted.")

    self.vm.inputs.select(sort: .MostFunded)

    self.scrollPercentage.assertValues([0.25, 1.0], "Selecting sort causes percentage to be emitted.")
  }

  func testNotifyDelegate() {
    self.vm.inputs.configureWith(sorts: [.Magic, .Popular, .Newest, .EndingSoon, .MostFunded])

    self.notifyDelegateOfSelectedSort.assertValues([], "Nothing emits initially.")

    self.vm.inputs.sortButtonTapped(index: 0)

    self.notifyDelegateOfSelectedSort.assertValues([.Magic], "Tapping sort button notifies the delegate.")

    self.vm.inputs.sortButtonTapped(index: 1)

    self.notifyDelegateOfSelectedSort.assertValues([.Magic, .Popular],
                                                   "Tapping sort button notifies the delegate.")

    self.vm.inputs.sortButtonTapped(index: 4)

    self.notifyDelegateOfSelectedSort.assertValues([.Magic, .Popular, .MostFunded],
                                                   "Tapping sort button notifies the delegate.")
  }
}
