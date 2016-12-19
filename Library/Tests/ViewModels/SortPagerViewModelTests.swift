@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers
import Prelude
import ReactiveSwift
import Result
import UIKit
import XCTest

internal final class SortPagerViewModelTests: TestCase {
  fileprivate let vm: SortPagerViewModelType = SortPagerViewModel()

  fileprivate let createSortButtons = TestObserver<[DiscoveryParams.Sort], NoError>()
  fileprivate let indicatorViewIsHidden = TestObserver<Bool, NoError>()
  fileprivate let notifyDelegateOfSelectedSort = TestObserver<DiscoveryParams.Sort, NoError>()
  fileprivate let pinSelectedIndicatorToPage = TestObserver<Int, NoError>()
  fileprivate let pinSelectedIndicatorAnimated = TestObserver<Bool, NoError>()
  fileprivate let setSelectedButton = TestObserver<Int, NoError>()
  fileprivate let updateSortStyleId = TestObserver<Int?, NoError>()
  fileprivate let updateSortStyleSorts = TestObserver<[DiscoveryParams.Sort], NoError>()
  fileprivate let updateSortStyleAnimated = TestObserver<Bool, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.createSortButtons.observe(self.createSortButtons.observer)
    self.vm.outputs.indicatorViewIsHidden.observe(self.indicatorViewIsHidden.observer)
    self.vm.outputs.notifyDelegateOfSelectedSort.observe(self.notifyDelegateOfSelectedSort.observer)
    self.vm.outputs.pinSelectedIndicatorToPage.map(first).observe(self.pinSelectedIndicatorToPage.observer)
    self.vm.outputs.pinSelectedIndicatorToPage.map(second).observe(self.pinSelectedIndicatorAnimated.observer)
    self.vm.outputs.setSelectedButton.observe(self.setSelectedButton.observer)
    self.vm.outputs.updateSortStyle.map(first).observe(self.updateSortStyleId.observer)
    self.vm.outputs.updateSortStyle.map(second).observe(self.updateSortStyleSorts.observer)
    self.vm.outputs.updateSortStyle.map { $0.2 }.observe(self.updateSortStyleAnimated.observer)
  }

  func testCreateSortButtons() {
    let sorts: [DiscoveryParams.Sort] = [.magic, .popular, .newest, .endingSoon, .mostFunded]
    self.vm.inputs.configureWith(sorts: sorts)
    self.vm.inputs.viewWillAppear()

    self.createSortButtons.assertValues([sorts], "Emits titles for the sort buttons.")
  }

  func testUpdateStyle() {
    let sorts: [DiscoveryParams.Sort] = [.magic, .popular, .newest, .endingSoon, .mostFunded]
    self.vm.inputs.configureWith(sorts: sorts)

    self.updateSortStyleId.assertValueCount(0)
    self.updateSortStyleSorts.assertValueCount(0)

    self.vm.inputs.viewWillAppear()

    self.updateSortStyleId.assertValues([nil])
    self.updateSortStyleSorts.assertValues([sorts])
    self.updateSortStyleAnimated.assertValues([false])

    self.vm.inputs.updateStyle(categoryId: 3)

    self.updateSortStyleId.assertValues([nil, 3])
    self.updateSortStyleSorts.assertValues([sorts, sorts])
    self.updateSortStyleAnimated.assertValues([false, true])

    self.vm.inputs.updateStyle(categoryId: 12)

    self.updateSortStyleId.assertValues([nil, 3, 12])
    self.updateSortStyleSorts.assertValues([sorts, sorts, sorts])
    self.updateSortStyleAnimated.assertValues([false, true, true])

    self.vm.inputs.updateStyle(categoryId: nil)

    self.updateSortStyleId.assertValues([nil, 3, 12, nil])
    self.updateSortStyleSorts.assertValues([sorts, sorts, sorts, sorts])
    self.updateSortStyleAnimated.assertValues([false, true, true, true])

    self.vm.inputs.viewWillAppear()

    self.updateSortStyleId.assertValues([nil, 3, 12, nil], "Update style does not emit")
  }

  func testSelectedButton() {
    let sorts: [DiscoveryParams.Sort] = [.magic, .popular, .newest, .endingSoon, .mostFunded]

    self.vm.inputs.configureWith(sorts: sorts)

    self.setSelectedButton.assertValueCount(0)

    self.vm.inputs.viewWillAppear()

    self.setSelectedButton.assertValues([0], "Set the first button to the selected state.")

    self.vm.inputs.sortButtonTapped(index: 2)

    self.setSelectedButton.assertValues([0, 2], "Set the third button to the selected state.")

    self.vm.inputs.select(sort: .popular)

    self.setSelectedButton.assertValues([0, 2, 1], "Set the second button to the selected state.")

    self.vm.inputs.select(sort: .mostFunded)

    self.setSelectedButton.assertValues([0, 2, 1, 4], "Set the last button to the selected state.")

    self.vm.inputs.viewWillAppear()

    self.setSelectedButton.assertValues([0, 2, 1, 4], "Select button does not emit")
  }

  func testPinSelectedIndicator() {
    self.vm.inputs.configureWith(sorts: [.magic, .popular, .newest, .endingSoon, .mostFunded])

    self.vm.inputs.viewWillAppear()

    self.pinSelectedIndicatorToPage.assertValueCount(0)

    self.vm.inputs.viewDidAppear()

    self.pinSelectedIndicatorToPage.assertValues([0], "First index emits initially.")
    self.pinSelectedIndicatorAnimated.assertValues([false])

    self.vm.inputs.select(sort: .popular)

    self.pinSelectedIndicatorToPage.assertValues([0, 1], "Index of popular emits.")
    self.pinSelectedIndicatorAnimated.assertValues([false, true])

    self.vm.inputs.sortButtonTapped(index: 3)

    self.pinSelectedIndicatorToPage.assertValues([0, 1],
                                                 "Tapping sort button does not cause indicator to change.")
    self.pinSelectedIndicatorAnimated.assertValues([false, true])

    self.vm.inputs.viewWillAppear()

    self.pinSelectedIndicatorToPage.assertValues([0, 1], "Indicator does not emit")
  }

  func testPinSelectedIndicator_On_Rotation() {
    self.vm.inputs.configureWith(sorts: [.magic, .popular, .newest, .endingSoon, .mostFunded])

    self.indicatorViewIsHidden.assertValueCount(0)

    self.vm.inputs.viewWillAppear()

    self.indicatorViewIsHidden.assertValues([true])

    self.vm.inputs.viewDidAppear()

    self.indicatorViewIsHidden.assertValues([true], "Indicator does not show immediately.")

    self.scheduler.advanceByInterval(0.1)

    self.indicatorViewIsHidden.assertValues([true, false])

    self.pinSelectedIndicatorToPage.assertValues([0], "First index emits initially.")
    self.pinSelectedIndicatorAnimated.assertValues([false])

    self.vm.inputs.willRotateToInterfaceOrientation()

    self.indicatorViewIsHidden.assertValues([true, false, true])

    self.vm.inputs.didRotateFromInterfaceOrientation()

    self.pinSelectedIndicatorToPage.assertValues([0, 0])
    self.pinSelectedIndicatorAnimated.assertValues([false, false])
    self.indicatorViewIsHidden.assertValues([true, false, true], "Indicator is still hidden")

    self.scheduler.advanceByInterval(0.1)

    self.indicatorViewIsHidden.assertValues([true, false, true, false], "Indicator shows after delay.")

    self.vm.inputs.willRotateToInterfaceOrientation()

    self.indicatorViewIsHidden.assertValues([true, false, true, false, true])

    self.vm.inputs.didRotateFromInterfaceOrientation()

    self.pinSelectedIndicatorToPage.assertValues([0, 0, 0])
    self.pinSelectedIndicatorAnimated.assertValues([false, false, false])
    self.indicatorViewIsHidden.assertValues([true, false, true, false, true], "Indicator is still hidden")

    self.scheduler.advanceByInterval(0.1)

    self.indicatorViewIsHidden.assertValues([true, false, true, false, true, false],
                                            "Indicator shows after delay.")

    self.vm.inputs.select(sort: .newest)

    self.pinSelectedIndicatorToPage.assertValues([0, 0, 0, 2])
    self.pinSelectedIndicatorAnimated.assertValues([false, false, false, true])

    self.vm.inputs.willRotateToInterfaceOrientation()

    self.indicatorViewIsHidden.assertValues([true, false, true, false, true, false, true])

    self.vm.inputs.didRotateFromInterfaceOrientation()

    self.pinSelectedIndicatorToPage.assertValues([0, 0, 0, 2, 2])
    self.pinSelectedIndicatorAnimated.assertValues([false, false, false, true, false])
    self.indicatorViewIsHidden.assertValues([true, false, true, false, true, false, true])

    self.scheduler.advanceByInterval(0.1)

    self.indicatorViewIsHidden.assertValues([true, false, true, false, true, false, true, false])
  }

  func testNotifyDelegate() {
    self.vm.inputs.configureWith(sorts: [.magic, .popular, .newest, .endingSoon, .mostFunded])
    self.vm.inputs.viewWillAppear()

    self.notifyDelegateOfSelectedSort.assertValues([], "Nothing emits initially.")

    self.vm.inputs.sortButtonTapped(index: 0)

    self.notifyDelegateOfSelectedSort.assertValues([.magic], "Tapping sort button notifies the delegate.")

    self.vm.inputs.sortButtonTapped(index: 1)

    self.notifyDelegateOfSelectedSort.assertValues([.magic, .popular],
                                                   "Tapping sort button notifies the delegate.")

    self.vm.inputs.sortButtonTapped(index: 4)

    self.notifyDelegateOfSelectedSort.assertValues([.magic, .popular, .mostFunded],
                                                   "Tapping sort button notifies the delegate.")

    self.vm.inputs.viewWillAppear()
    self.vm.inputs.viewDidAppear()

    self.notifyDelegateOfSelectedSort.assertValues(
      [.magic, .popular, .mostFunded],
      "Navigating away and coming back to sorts does not re-emit."
    )
  }
}
