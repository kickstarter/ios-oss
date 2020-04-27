@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class DiscoveryNavigationHeaderViewModelTests: TestCase {
  fileprivate let vm: DiscoveryNavigationHeaderViewModelType = DiscoveryNavigationHeaderViewModel()

  private let animateArrowToDown = TestObserver<Bool, Never>()
  private let arrowOpacity = TestObserver<CGFloat, Never>()
  private let arrowOpacityAnimated = TestObserver<Bool, Never>()
  private let debugContainerViewIsHidden = TestObserver<Bool, Never>()
  private let debugImageViewIsDimmed = TestObserver<Bool, Never>()
  private let dividerIsHidden = TestObserver<Bool, Never>()
  private let exploreLabelIsHidden = TestObserver<Bool, Never>()
  private let logoutWithParams = TestObserver<DiscoveryParams, Never>()
  private let primaryLabelOpacity = TestObserver<CGFloat, Never>()
  private let primaryLabelOpacityAnimated = TestObserver<Bool, Never>()
  private let primaryLabelText = TestObserver<String, Never>()
  private let dismissDiscoveryFilters = TestObserver<(), Never>()
  private let notifyDelegateFilterSelectedParams = TestObserver<DiscoveryParams, Never>()
  private let secondaryLabelText = TestObserver<String, Never>()
  private let secondaryLabelIsHidden = TestObserver<Bool, Never>()
  private let titleAccessibilityHint = TestObserver<String, Never>()
  private let titleAccessibilityLabel = TestObserver<String, Never>()
  private let showDiscoveryFiltersRow = TestObserver<SelectableRow, Never>()
  private let favoriteButtonAccessibilityLabel = TestObserver<String, Never>()
  private let favoriteViewIsDimmed = TestObserver<Bool, Never>()
  private let favoriteViewIsHidden = TestObserver<Bool, Never>()
  private let showFavoriteOnboardingAlert = TestObserver<String, Never>()
  private let updateFavoriteButtonSelected = TestObserver<Bool, Never>()
  private let updateFavoriteButtonAnimated = TestObserver<Bool, Never>()

  let initialParams = .defaults
    |> DiscoveryParams.lens.includePOTD .~ true

  let categoryParams = .defaults |> DiscoveryParams.lens.category .~ .art
  let subcategoryParams = .defaults |> DiscoveryParams.lens.category .~ .documentary
  let starredParams = .defaults |> DiscoveryParams.lens.starred .~ true

  let selectableRow = SelectableRow(isSelected: false, params: .defaults)

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.animateArrowToDown.observe(self.animateArrowToDown.observer)
    self.vm.outputs.arrowOpacityAnimated.map(first).observe(self.arrowOpacity.observer)
    self.vm.outputs.arrowOpacityAnimated.map(second).observe(self.arrowOpacityAnimated.observer)
    self.vm.outputs.debugContainerViewIsHidden.observe(self.debugContainerViewIsHidden.observer)
    self.vm.outputs.debugImageViewIsDimmed.observe(self.debugImageViewIsDimmed.observer)
    self.vm.outputs.dismissDiscoveryFilters.observe(self.dismissDiscoveryFilters.observer)
    self.vm.outputs.dividerIsHidden.observe(self.dividerIsHidden.observer)
    self.vm.outputs.exploreLabelIsHidden.observe(self.exploreLabelIsHidden.observer)
    self.vm.outputs.primaryLabelOpacityAnimated.map(first).observe(self.primaryLabelOpacity.observer)
    self.vm.outputs.primaryLabelOpacityAnimated.map(second).observe(self.primaryLabelOpacityAnimated.observer)
    self.vm.outputs.primaryLabelText.observe(self.primaryLabelText.observer)
    self.vm.outputs.notifyDelegateFilterSelectedParams
      .observe(self.notifyDelegateFilterSelectedParams.observer)
    self.vm.outputs.secondaryLabelText.observe(self.secondaryLabelText.observer)
    self.vm.outputs.secondaryLabelIsHidden.observe(self.secondaryLabelIsHidden.observer)
    self.vm.outputs.titleButtonAccessibilityHint.observe(self.titleAccessibilityHint.observer)
    self.vm.outputs.titleButtonAccessibilityLabel.observe(self.titleAccessibilityLabel.observer)
    self.vm.outputs.showDiscoveryFilters.observe(self.showDiscoveryFiltersRow.observer)
    self.vm.outputs.favoriteButtonAccessibilityLabel.observe(self.favoriteButtonAccessibilityLabel.observer)
    self.vm.outputs.favoriteViewIsDimmed.observe(self.favoriteViewIsDimmed.observer)
    self.vm.outputs.favoriteViewIsHidden.observe(self.favoriteViewIsHidden.observer)
    self.vm.outputs.showFavoriteOnboardingAlert.observe(self.showFavoriteOnboardingAlert.observer)
    self.vm.outputs.updateFavoriteButton.map(first).observe(self.updateFavoriteButtonSelected.observer)
    self.vm.outputs.updateFavoriteButton.map(second).observe(self.updateFavoriteButtonAnimated.observer)
  }

  func testShowFilters() {
    let initialRow = SelectableRow(isSelected: true, params: initialParams)
    let starredRow = self.selectableRow |> SelectableRow.lens.params .~ self.starredParams
    let artRow = self.selectableRow |> SelectableRow.lens.params .~ self.categoryParams

    self.vm.inputs.viewDidLoad()
    self.vm.inputs.configureWith(params: self.initialParams)
    self.scheduler.advance(by: AppEnvironment.current.apiDelayInterval)

    self.showDiscoveryFiltersRow.assertValueCount(0)
    self.dismissDiscoveryFilters.assertValueCount(0)

    self.vm.inputs.titleButtonTapped()

    self.showDiscoveryFiltersRow.assertValues([initialRow])

    self.vm.inputs.filtersSelected(row: starredRow)

    self.showDiscoveryFiltersRow.assertValues([initialRow], "Show Filters does not emit on selection.")

    scheduler.advance(by: .milliseconds(400))
    self.dismissDiscoveryFilters.assertValueCount(1)

    self.vm.inputs.titleButtonTapped()

    self.showDiscoveryFiltersRow.assertValues([initialRow, starredRow])

    self.vm.inputs.titleButtonTapped()

    self.showDiscoveryFiltersRow.assertValues(
      [initialRow, starredRow],
      "Show filters does not emit on close."
    )

    self.vm.inputs.titleButtonTapped()

    self.showDiscoveryFiltersRow.assertValues([initialRow, starredRow, starredRow])

    self.vm.inputs.filtersSelected(row: artRow)
    self.vm.inputs.titleButtonTapped()

    self.showDiscoveryFiltersRow.assertValues([initialRow, starredRow, starredRow, artRow])
  }

  func testShowFilters_BeforeApiReturns() {
    let initialRow = SelectableRow(isSelected: true, params: initialParams)

    self.vm.inputs.viewDidLoad()
    self.vm.inputs.configureWith(params: self.initialParams)

    self.showDiscoveryFiltersRow.assertValueCount(0)
    self.dismissDiscoveryFilters.assertValueCount(0)

    // Tap title before the categories are fetched
    self.vm.inputs.titleButtonTapped()
    self.scheduler.advance(by: .milliseconds(400))

    self.showDiscoveryFiltersRow.assertValues(
      [initialRow],
      "Filters are shown even before categories are fetched."
    )
    self.dismissDiscoveryFilters.assertValueCount(0, "Dismissing is not emitted.")

    // Wait enough time for categories to come back
    self.scheduler.advance(by: AppEnvironment.current.apiDelayInterval)

    self.showDiscoveryFiltersRow.assertValues(
      [initialRow],
      "Nothing new is emitted once categories are fetched."
    )
    self.dismissDiscoveryFilters.assertValueCount(0, "Dismissing is not emitted.")

    // Tap title again to dismiss
    self.vm.inputs.titleButtonTapped()
    self.scheduler.advance(by: .milliseconds(400))

    self.showDiscoveryFiltersRow.assertValues([initialRow], "Nothing new is emitted when dismissing.")
    self.dismissDiscoveryFilters.assertValueCount(1, "Dismiss is emitted.")

    // Tap title again to present
    self.vm.inputs.titleButtonTapped()
    self.scheduler.advance(by: .milliseconds(400))

    self.showDiscoveryFiltersRow.assertValues(
      [initialRow, initialRow],
      "Filters are shown again."
    )
    self.dismissDiscoveryFilters.assertValueCount(1, "Dismissing is not emitted.")
  }

  func testTitleData() {
    self.arrowOpacity.assertValueCount(0)
    self.primaryLabelOpacity.assertValueCount(0)

    self.vm.inputs.viewDidLoad()

    self.arrowOpacity.assertValues([0.0])
    self.arrowOpacityAnimated.assertValues([false])
    self.primaryLabelOpacity.assertValues([0.0])
    self.primaryLabelOpacityAnimated.assertValues([false])
    self.animateArrowToDown.assertValueCount(0)
    self.dividerIsHidden.assertValueCount(0)
    self.primaryLabelText.assertValueCount(0)
    self.secondaryLabelText.assertValueCount(0)
    self.secondaryLabelIsHidden.assertValueCount(0)
    self.titleAccessibilityHint.assertValueCount(0)
    self.titleAccessibilityLabel.assertValueCount(0)

    self.vm.inputs.configureWith(params: self.initialParams)

    self.arrowOpacity.assertValues([0.0, 1.0])
    self.arrowOpacityAnimated.assertValues([false, true])
    self.primaryLabelOpacity.assertValues([0.0, 1.0])
    self.primaryLabelOpacityAnimated.assertValues([false, true])
    self.animateArrowToDown.assertValues([true])
    self.dividerIsHidden.assertValues([true])
    self.primaryLabelText.assertValues([Strings.All_Projects()])
    self.secondaryLabelText.assertValues([""])
    self.secondaryLabelIsHidden.assertValues([true])
    self.titleAccessibilityHint.assertValues([Strings.Opens_filters()])
    self.titleAccessibilityLabel.assertValues([Strings.Filter_by_all_projects()])

    self.vm.inputs.titleButtonTapped()

    self.arrowOpacity.assertValues([0.0, 1.0])
    self.arrowOpacityAnimated.assertValues([false, true])
    self.primaryLabelOpacity.assertValues([0.0, 1.0, 1.0])
    self.primaryLabelOpacityAnimated.assertValues([false, true, true])
    self.animateArrowToDown.assertValues([true, false])
    self.dividerIsHidden.assertValues([true])
    self.primaryLabelText.assertValues([Strings.All_Projects(), Strings.All_Projects()])
    self.secondaryLabelText.assertValues(["", ""])
    self.secondaryLabelIsHidden.assertValues([true])
    self.titleAccessibilityHint.assertValues([Strings.Opens_filters(), Strings.Closes_filters()])
    self.titleAccessibilityLabel.assertValues([
      Strings.Filter_by_all_projects(),
      Strings.Filter_by_all_projects()
    ])

    self.vm.inputs.filtersSelected(row: self.selectableRow |> SelectableRow.lens.params .~ self.starredParams)

    self.arrowOpacity.assertValues([0.0, 1.0])
    self.arrowOpacityAnimated.assertValues([false, true])
    self.primaryLabelOpacity.assertValues([0.0, 1.0, 1.0, 1.0])
    self.primaryLabelOpacityAnimated.assertValues([false, true, true, true])
    self.animateArrowToDown.assertValues([true, false, true])
    self.dividerIsHidden.assertValues([true])
    self.primaryLabelText.assertValues([
      Strings.All_Projects(), Strings.All_Projects(),
      Strings.Saved()
    ])
    self.secondaryLabelText.assertValues(["", "", ""])
    self.secondaryLabelIsHidden.assertValues([true])
    self.titleAccessibilityHint.assertValues([
      Strings.Opens_filters(), Strings.Closes_filters(),
      Strings.Opens_filters()
    ])
    self.titleAccessibilityLabel.assertValues([
      Strings.Filter_by_all_projects(),
      Strings.Filter_by_all_projects(), Strings.Filter_by_saved_projects()
    ])

    self.vm.inputs.titleButtonTapped()

    self.arrowOpacity.assertValues([0.0, 1.0])
    self.arrowOpacityAnimated.assertValues([false, true])
    self.primaryLabelOpacity.assertValues([0.0, 1.0, 1.0, 1.0, 1.0])
    self.primaryLabelOpacityAnimated.assertValues([false, true, true, true, true])
    self.animateArrowToDown.assertValues([true, false, true, false])
    self.dividerIsHidden.assertValues([true])
    self.primaryLabelText.assertValues([
      Strings.All_Projects(), Strings.All_Projects(),
      Strings.Saved(), Strings.Saved()
    ])
    self.secondaryLabelText.assertValues(["", "", "", ""])
    self.secondaryLabelIsHidden.assertValues([true])
    self.titleAccessibilityHint.assertValues([
      Strings.Opens_filters(), Strings.Closes_filters(),
      Strings.Opens_filters(), Strings.Closes_filters()
    ])
    self.titleAccessibilityLabel.assertValues([
      Strings.Filter_by_all_projects(),
      Strings.Filter_by_all_projects(), Strings.Filter_by_saved_projects(),
      Strings.Filter_by_saved_projects()
    ])

    self.vm.inputs.filtersSelected(
      row: self.selectableRow |> SelectableRow.lens.params .~ self.categoryParams
    )

    self.arrowOpacity.assertValues([0.0, 1.0])
    self.arrowOpacityAnimated.assertValues([false, true])
    self.primaryLabelOpacity.assertValues([0.0, 1.0, 1.0, 1.0, 1.0, 1.0])
    self.primaryLabelOpacityAnimated.assertValues([false, true, true, true, true, true])
    self.animateArrowToDown.assertValues([true, false, true, false, true])
    self.dividerIsHidden.assertValues([true])
    self.primaryLabelText.assertValues([
      Strings.All_Projects(), Strings.All_Projects(),
      Strings.Saved(), Strings.Saved(), Strings.All_Art_Projects()
    ])
    self.secondaryLabelText.assertValues(["", "", "", "", ""])
    self.secondaryLabelIsHidden.assertValues([true])
    self.titleAccessibilityHint.assertValues([
      Strings.Opens_filters(), Strings.Closes_filters(),
      Strings.Opens_filters(), Strings.Closes_filters(), Strings.Opens_filters()
    ])
    self.titleAccessibilityLabel.assertValues([
      Strings.Filter_by_all_projects(),
      Strings.Filter_by_all_projects(), Strings.Filter_by_saved_projects(),
      Strings.Filter_by_saved_projects(),
      Strings.Filter_by_category_name(category_name: self.categoryParams.category?.name ?? "")
    ])

    self.vm.inputs.titleButtonTapped()

    self.arrowOpacity.assertValues([0.0, 1.0])
    self.arrowOpacityAnimated.assertValues([false, true])
    self.primaryLabelOpacity.assertValues([0.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0])
    self.primaryLabelOpacityAnimated.assertValues([false, true, true, true, true, true, true])
    self.animateArrowToDown.assertValues([true, false, true, false, true, false])
    self.dividerIsHidden.assertValues([true])
    self.primaryLabelText.assertValues([
      Strings.All_Projects(), Strings.All_Projects(),
      Strings.Saved(), Strings.Saved(), Strings.All_Art_Projects(),
      Strings.All_Art_Projects()
    ])
    self.secondaryLabelText.assertValues(["", "", "", "", "", ""])
    self.secondaryLabelIsHidden.assertValues([true])
    self.titleAccessibilityHint.assertValues([
      Strings.Opens_filters(), Strings.Closes_filters(),
      Strings.Opens_filters(), Strings.Closes_filters(), Strings.Opens_filters(), Strings.Closes_filters()
    ])
    self.titleAccessibilityLabel.assertValues([
      Strings.Filter_by_all_projects(),
      Strings.Filter_by_all_projects(), Strings.Filter_by_saved_projects(),
      Strings.Filter_by_saved_projects(),
      Strings.Filter_by_category_name(category_name: self.categoryParams.category?.name ?? ""),
      Strings.Filter_by_category_name(category_name: self.categoryParams.category?.name ?? "")
    ])

    self.vm.inputs.filtersSelected(
      row: self.selectableRow |> SelectableRow.lens.params .~ self.subcategoryParams
    )

    self.arrowOpacity.assertValues([0.0, 1.0])
    self.arrowOpacityAnimated.assertValues([false, true])
    self.primaryLabelOpacity.assertValues([0.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.6])
    self.primaryLabelOpacityAnimated.assertValues([false, true, true, true, true, true, true, true])
    self.animateArrowToDown.assertValues([true, false, true, false, true, false, true])
    self.dividerIsHidden.assertValues([true, false])
    self.primaryLabelText.assertValues([
      Strings.All_Projects(), Strings.All_Projects(),
      Strings.Saved(), Strings.Saved(), Strings.All_Art_Projects(),
      Strings.All_Art_Projects(), "Film & Video"
    ])
    self.secondaryLabelText.assertValues(["", "", "", "", "", "", "Documentary"])
    self.secondaryLabelIsHidden.assertValues([true, false])
    self.titleAccessibilityHint.assertValues([
      Strings.Opens_filters(), Strings.Closes_filters(),
      Strings.Opens_filters(), Strings.Closes_filters(), Strings.Opens_filters(), Strings.Closes_filters(),
      Strings.Opens_filters()
    ])
    self.titleAccessibilityLabel.assertValues([
      Strings.Filter_by_all_projects(),
      Strings.Filter_by_all_projects(), Strings.Filter_by_saved_projects(),
      Strings.Filter_by_saved_projects(),
      Strings.Filter_by_category_name(category_name: self.categoryParams.category?.name ?? ""),
      Strings.Filter_by_category_name(category_name: self.categoryParams.category?.name ?? ""),
      Strings.Filter_by_subcategory_name_in_category_name(
        subcategory_name: self.subcategoryParams.category?.name ?? "",
        category_name: self.subcategoryParams.category?._parent?.name ?? ""
      )
    ])
  }

  func testExploreLabelIsHidden_ifSelectedFilterIsNotDefault() {
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.configureWith(params: self.initialParams)

    self.vm.inputs.filtersSelected(
      row: self.selectableRow |> SelectableRow.lens.params .~ self.categoryParams
    )

    self.exploreLabelIsHidden.assertValues([true])
  }

  func testExploreLabelIsNotHidden_ifSelectedFilterIsDefault() {
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.configureWith(params: self.initialParams)

    self.vm.inputs.filtersSelected(row: self.selectableRow)

    self.exploreLabelIsHidden.assertValues([false])
  }

  func testNotifyFilterSelectedParams() {
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.configureWith(params: self.initialParams)

    self.notifyDelegateFilterSelectedParams.assertValueCount(0)

    self.vm.inputs.filtersSelected(row: self.selectableRow)

    self.notifyDelegateFilterSelectedParams.assertValues([DiscoveryParams.defaults])

    self.vm.inputs.filtersSelected(
      row: self.selectableRow |> SelectableRow.lens.params .~ self.categoryParams
    )

    self.notifyDelegateFilterSelectedParams.assertValues([DiscoveryParams.defaults, self.categoryParams])
  }

  func testFavoriting() {
    let artSelectableRow = self.selectableRow |> SelectableRow.lens.params .~ self.categoryParams

    self.vm.inputs.viewDidLoad()
    self.vm.inputs.configureWith(params: self.initialParams)

    self.favoriteViewIsHidden.assertValues([true])

    self.vm.inputs.titleButtonTapped()

    self.favoriteViewIsHidden.assertValues([true])
    self.favoriteViewIsDimmed.assertValueCount(0)
    self.updateFavoriteButtonAnimated.assertValueCount(0)
    self.updateFavoriteButtonSelected.assertValueCount(0)
    self.favoriteButtonAccessibilityLabel.assertValueCount(0)

    self.vm.inputs.filtersSelected(row: artSelectableRow)

    self.favoriteViewIsHidden.assertValues([true, false])
    self.favoriteViewIsDimmed.assertValues([false])
    self.updateFavoriteButtonAnimated.assertValues([false])
    self.updateFavoriteButtonSelected.assertValues([false])
    self.showFavoriteOnboardingAlert.assertValueCount(0)
    self.favoriteButtonAccessibilityLabel.assertValues([
      Strings.discovery_favorite_categories_buttons_favorite_a11y_label()
    ])

    self.vm.inputs.favoriteButtonTapped()

    self.favoriteViewIsHidden.assertValues([true, false])
    self.favoriteViewIsDimmed.assertValues([false])
    self.updateFavoriteButtonAnimated.assertValues([false, true])
    self.updateFavoriteButtonSelected.assertValues([false, true])
    self.showFavoriteOnboardingAlert.assertValues(["All Art Projects saved."])
    self.favoriteButtonAccessibilityLabel.assertValues([
      Strings.discovery_favorite_categories_buttons_favorite_a11y_label(),
      Strings.discovery_favorite_categories_buttons_unfavorite_a11y_label()
    ])

    self.vm.inputs.titleButtonTapped()

    self.favoriteViewIsHidden.assertValues([true, false])
    self.favoriteViewIsDimmed.assertValues([false, true])
    self.updateFavoriteButtonAnimated.assertValues([false, true])
    self.updateFavoriteButtonSelected.assertValues([false, true])
    self.showFavoriteOnboardingAlert.assertValues(["All Art Projects saved."])
    self.favoriteButtonAccessibilityLabel.assertValues([
      Strings.discovery_favorite_categories_buttons_favorite_a11y_label(),
      Strings.discovery_favorite_categories_buttons_unfavorite_a11y_label()
    ])

    self.vm.inputs.titleButtonTapped()

    self.favoriteViewIsHidden.assertValues([true, false])
    self.favoriteViewIsDimmed.assertValues([false, true, false])
    self.updateFavoriteButtonAnimated.assertValues([false, true])
    self.updateFavoriteButtonSelected.assertValues([false, true])
    self.showFavoriteOnboardingAlert.assertValues(["All Art Projects saved."])
    self.favoriteButtonAccessibilityLabel.assertValues([
      Strings.discovery_favorite_categories_buttons_favorite_a11y_label(),
      Strings.discovery_favorite_categories_buttons_unfavorite_a11y_label()
    ])

    self.vm.inputs.favoriteButtonTapped()

    self.favoriteViewIsHidden.assertValues([true, false])
    self.favoriteViewIsDimmed.assertValues([false, true, false])
    self.updateFavoriteButtonAnimated.assertValues([false, true, true])
    self.updateFavoriteButtonSelected.assertValues([false, true, false])
    self.showFavoriteOnboardingAlert.assertValues(["All Art Projects saved."], "Alert does not emit again.")
    self.favoriteButtonAccessibilityLabel.assertValues([
      Strings.discovery_favorite_categories_buttons_favorite_a11y_label(),
      Strings.discovery_favorite_categories_buttons_unfavorite_a11y_label(),
      Strings.discovery_favorite_categories_buttons_favorite_a11y_label()
    ])

    self.vm.inputs.titleButtonTapped()

    self.favoriteViewIsHidden.assertValues([true, false])
    self.favoriteViewIsDimmed.assertValues([false, true, false, true])
    self.updateFavoriteButtonAnimated.assertValues([false, true, true])
    self.updateFavoriteButtonSelected.assertValues([false, true, false])
    self.showFavoriteOnboardingAlert.assertValues(["All Art Projects saved."], "Alert does not emit again.")
    self.favoriteButtonAccessibilityLabel.assertValues([
      Strings.discovery_favorite_categories_buttons_favorite_a11y_label(),
      Strings.discovery_favorite_categories_buttons_unfavorite_a11y_label(),
      Strings.discovery_favorite_categories_buttons_favorite_a11y_label()
    ])

    self.vm.inputs.filtersSelected(row: self.selectableRow)

    self.favoriteViewIsHidden.assertValues([true, false, true])
    self.favoriteViewIsDimmed.assertValues([false, true, false, true])
    self.updateFavoriteButtonAnimated.assertValues([false, true, true])
    self.updateFavoriteButtonSelected.assertValues([false, true, false])
    self.showFavoriteOnboardingAlert.assertValues(["All Art Projects saved."], "Alert does not emit again.")
    self.favoriteButtonAccessibilityLabel.assertValues([
      Strings.discovery_favorite_categories_buttons_favorite_a11y_label(),
      Strings.discovery_favorite_categories_buttons_unfavorite_a11y_label(),
      Strings.discovery_favorite_categories_buttons_favorite_a11y_label()
    ])
  }

  func testEnvironmentButtonIsNotHidden_Alpha() {
    withEnvironment(mainBundle: MockBundle(bundleIdentifier: KickstarterBundleIdentifier.alpha.rawValue)) {
      self.vm.inputs.viewDidLoad()

      self.debugContainerViewIsHidden.assertValue(false)
    }
  }

  func testEnvironmentButtonIsNotHidden_Beta() {
    withEnvironment(mainBundle: MockBundle(bundleIdentifier: KickstarterBundleIdentifier.beta.rawValue)) {
      self.vm.inputs.viewDidLoad()

      self.debugContainerViewIsHidden.assertValue(false)
    }
  }

  func testEnvironmentButtonIsHidden_Release() {
    withEnvironment(mainBundle: MockBundle(bundleIdentifier: KickstarterBundleIdentifier.release.rawValue)) {
      self.vm.inputs.viewDidLoad()

      self.debugContainerViewIsHidden.assertValue(true)
    }
  }

  func testDebugButtonIsHidden_Unknown() {
    withEnvironment(mainBundle: MockBundle(bundleIdentifier: "unknown")) {
      self.vm.inputs.viewDidLoad()

      self.debugContainerViewIsHidden.assertValue(true)
    }
  }

  func testDebugImageViewIsDimmed_whenDebugContainerViewIsNotHidden() {
    withEnvironment(mainBundle: MockBundle(bundleIdentifier: KickstarterBundleIdentifier.alpha.rawValue)) {
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.configureWith(params: self.initialParams)

      self.debugContainerViewIsHidden.assertValue(false)
      self.debugImageViewIsDimmed.assertValues([false])

      self.vm.inputs.titleButtonTapped()

      self.debugImageViewIsDimmed.assertValues([false, true])

      self.vm.inputs.titleButtonTapped()

      self.debugImageViewIsDimmed.assertValues([false, true, false])
    }
  }

  func testDebugImageViewIsDimmed_whenDebugcountainerViewIsHidden() {
    withEnvironment(mainBundle: MockBundle(bundleIdentifier: KickstarterBundleIdentifier.release.rawValue)) {
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.configureWith(params: self.initialParams)

      self.debugContainerViewIsHidden.assertValue(true)
      self.debugImageViewIsDimmed.assertDidNotEmitValue()

      self.vm.inputs.titleButtonTapped()

      self.debugImageViewIsDimmed.assertDidNotEmitValue()

      self.vm.inputs.titleButtonTapped()

      self.debugImageViewIsDimmed.assertDidNotEmitValue()
    }
  }
}
