import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers

private let shippingRules = [
  ShippingRule.template
    |> ShippingRule.lens.location .~ .australia,
  ShippingRule.template
    |> ShippingRule.lens.location .~ .brooklyn,
  ShippingRule.template
    |> ShippingRule.lens.location .~ .canada,
  ShippingRule.template
    |> ShippingRule.lens.location .~ .greatBritain,
  ShippingRule.template
    |> ShippingRule.lens.location .~ .london,
  ShippingRule.template
    |> ShippingRule.lens.location .~ .losAngeles,
  ShippingRule.template
    |> ShippingRule.lens.location .~ .portland,
  ShippingRule.template
    |> ShippingRule.lens.location .~ .usa
]

final class ShippingRulesViewModelTests: TestCase {
  private let vm: ShippingRulesViewModelType = ShippingRulesViewModel()

  private let deselectVisibleCells = TestObserver<Void, Never>()
  private let flashScrollIndicators = TestObserver<Void, Never>()
  private let notifyDelegateOfSelectedShippingRule = TestObserver<ShippingRule, Never>()
  private let reloadDataWithShippingRulesData = TestObserver<[ShippingRuleData], Never>()
  private let reloadDataWithShippingRulesReload = TestObserver<Bool, Never>()
  private let scrollToCellAtIndex = TestObserver<Int, Never>()
  private let selectCellAtIndex = TestObserver<Int, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.deselectVisibleCells.observe(self.deselectVisibleCells.observer)
    self.vm.outputs.flashScrollIndicators.observe(self.flashScrollIndicators.observer)
    self.vm.outputs.notifyDelegateOfSelectedShippingRule.observe(
      self.notifyDelegateOfSelectedShippingRule.observer
    )
    self.vm.outputs.reloadDataWithShippingRules.map(first).observe(
      self.reloadDataWithShippingRulesData.observer
    )
    self.vm.outputs.reloadDataWithShippingRules.map(second).observe(
      self.reloadDataWithShippingRulesReload.observer
    )
    self.vm.outputs.scrollToCellAtIndex.observe(self.scrollToCellAtIndex.observer)
    self.vm.outputs.selectCellAtIndex.observe(self.selectCellAtIndex.observer)
  }

  func testFlashScrollIndicators() {
    self.vm.inputs.configureWith(.template, shippingRules: shippingRules, selectedShippingRule: .template)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewDidLayoutSubviews()

    self.flashScrollIndicators.assertValueCount(1)
  }

  func testDataIsSortedBasedOnLocalizedName() {
    let shippingRulesUnsorted = [
      ShippingRule.template
        |> ShippingRule.lens.location .~ .usa,
      ShippingRule.template
        |> ShippingRule.lens.location .~ .portland,
      ShippingRule.template
        |> ShippingRule.lens.location .~ .losAngeles,
      ShippingRule.template
        |> ShippingRule.lens.location .~ .london,
      ShippingRule.template
        |> ShippingRule.lens.location .~ .greatBritain,
      ShippingRule.template
        |> ShippingRule.lens.location .~ .canada,
      ShippingRule.template
        |> ShippingRule.lens.location .~ .brooklyn,
      ShippingRule.template
        |> ShippingRule.lens.location .~ .australia
    ]

    let project = Project.template
    let selectedShippingRule = shippingRulesUnsorted[0]

    self.vm.inputs.configureWith(
      project, shippingRules: shippingRulesUnsorted, selectedShippingRule: selectedShippingRule
    )
    self.vm.inputs.viewDidLoad()

    self.reloadDataWithShippingRulesData.assertValues(
      [
        // Sorted list: [Australia, Brooklyn, Canada, Great Britain, London, Los Angeles, Portland, USA]
        [
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule,
            shippingRule: shippingRulesUnsorted[7]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule,
            shippingRule: shippingRulesUnsorted[6]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule,
            shippingRule: shippingRulesUnsorted[5]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule,
            shippingRule: shippingRulesUnsorted[4]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule,
            shippingRule: shippingRulesUnsorted[3]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule,
            shippingRule: shippingRulesUnsorted[2]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule,
            shippingRule: shippingRulesUnsorted[1]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule,
            shippingRule: shippingRulesUnsorted[0]
          )
        ]
      ]
    )
    self.reloadDataWithShippingRulesReload.assertValues([true])
  }

  /**

   This test checks whether the table scrolls to the selected shipping rule row

   1) We load the list
    - Selected rule: Brooklyn
    - Scrolls to Brooklyn
   2) We perform search for shipping rules locations starting with "Lo" prefix
    - Selected rule: Brooklyn
    - Does not scroll since Brooklyn is now not in the filtered list
   3) We perform search for shipping rules locations starting with "B" prefix
    - Selected rule: Brooklyn
    - Scrolls to Brooklyn

   */
  func testScrollToCellAtIndex() {
    let selectedShippingRule = shippingRules[1]

    self.vm.inputs.configureWith(
      .template, shippingRules: shippingRules, selectedShippingRule: selectedShippingRule
    )
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewDidLayoutSubviews()

    self.scrollToCellAtIndex.assertValues([1])

    self.vm.inputs.searchTextDidChange("Lo")

    self.scheduler.advance(by: .milliseconds(100))

    self.scrollToCellAtIndex.assertValues([1])

    self.vm.inputs.searchTextDidChange("B")

    self.scheduler.advance(by: .milliseconds(100))

    self.scrollToCellAtIndex.assertValues([1, 0])
  }

  /**

   This test performs a search on shipping rules list

   1) We load the list
    - Shows: Australia, Brooklyn, Canada, Great Britain, London, Los Angeles, Portland, USA
   2) We perform search for shipping rules locations starting with "Lo" prefix
    - Shows: London, Los Angeles
   3) We perform another search for shipping rules locations starting with "a" prefix
    - Shows: Australia
   4) We perform another search for shipping rules locations starting with "x" prefix
    - Shows: empty list
   5) We clear the search query in order to show the original list
    - Shows: Australia, Brooklyn, Canada, Great Britain, London, Los Angeles, Portland, USA
   6) We perform another search for shipping rules locations starting with "C" prefix
    - Shows: Canada

   */
  func testSearch() {
    let project = Project.template
    let selectedShippingRule = shippingRules[0]

    self.vm.inputs.configureWith(
      project, shippingRules: shippingRules, selectedShippingRule: selectedShippingRule
    )
    self.vm.inputs.viewDidLoad()

    self.reloadDataWithShippingRulesData.assertValues(
      [
        // Unfiltered list: [Australia, Brooklyn, Canada, Great Britain, London, Los Angeles, Portland, USA]
        [
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[0]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[1]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[2]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[3]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[4]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[5]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[6]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[7]
          )
        ]
      ]
    )
    self.reloadDataWithShippingRulesReload.assertValues([true])

    // Search for shipping rules locations starting with "Lo" (should filter down to London, Los Angeles)
    self.vm.inputs.searchTextDidChange("Lo")

    self.scheduler.advance(by: .milliseconds(100))

    self.reloadDataWithShippingRulesData.assertValues(
      [
        // Unfiltered list: [Australia, Brooklyn, Canada, Great Britain, London, Los Angeles, Portland, USA]
        [
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[0]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[1]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[2]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[3]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[4]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[5]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[6]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[7]
          )
        ],
        // Filtered list by "Lo"
        // [London, Los Angeles]
        [
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[4]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[5]
          )
        ]
      ]
    )
    self.reloadDataWithShippingRulesReload.assertValues([true, true])

    // Search for shipping rules locations starting with "a" (should filter down to Australia)
    self.vm.inputs.searchTextDidChange("a")

    self.scheduler.advance(by: .milliseconds(100))

    self.reloadDataWithShippingRulesData.assertValues(
      [
        // Unfiltered list: [Australia, Brooklyn, Canada, Great Britain, London, Los Angeles, Portland, USA]
        [
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[0]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[1]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[2]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[3]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[4]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[5]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[6]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[7]
          )
        ],
        // Filtered list by "Lo"
        // [London, Los Angeles]
        [
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[4]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[5]
          )
        ],
        // Filtered list by "a"
        // [Australia]
        [
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[0]
          )
        ]
      ]
    )
    self.reloadDataWithShippingRulesReload.assertValues([true, true, true])

    self.vm.inputs.searchTextDidChange("x")

    self.scheduler.advance(by: .milliseconds(100))

    self.reloadDataWithShippingRulesData.assertValues(
      [
        // Unfiltered list: [Australia, Brooklyn, Canada, Great Britain, London, Los Angeles, Portland, USA]
        [
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[0]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[1]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[2]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[3]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[4]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[5]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[6]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[7]
          )
        ],
        // Filtered list by "Lo"
        // [London, Los Angeles]
        [
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[4]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[5]
          )
        ],
        // Filtered list by "a"
        // [Australia]
        [
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[0]
          )
        ],
        // Filtered list by "x"
        // Empty (no matches found)
        [
        ]
      ]
    )
    self.reloadDataWithShippingRulesReload.assertValues([true, true, true, true])

    self.vm.inputs.searchTextDidChange("")

    self.scheduler.advance(by: .milliseconds(100))

    self.reloadDataWithShippingRulesData.assertValues(
      [
        // Unfiltered list: [Australia, Brooklyn, Canada, Great Britain, London, Los Angeles, Portland, USA]
        [
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[0]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[1]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[2]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[3]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[4]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[5]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[6]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[7]
          )
        ],
        // Filtered list by "Lo"
        // [London, Los Angeles]
        [
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[4]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[5]
          )
        ],
        // Filtered list by "a"
        // [Australia]
        [
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[0]
          )
        ],
        // Filtered list by "x"
        // Empty (no matches found)
        [
        ],
        // Unfiltered list: [Australia, Brooklyn, Canada, Great Britain, London, Los Angeles, Portland, USA]
        [
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[0]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[1]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[2]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[3]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[4]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[5]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[6]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[7]
          )
        ]
      ]
    )
    self.reloadDataWithShippingRulesReload.assertValues([true, true, true, true, true])

    self.vm.inputs.searchTextDidChange("C")

    self.scheduler.advance(by: .milliseconds(100))

    self.reloadDataWithShippingRulesData.assertValues(
      [
        // Unfiltered list: [Australia, Brooklyn, Canada, Great Britain, London, Los Angeles, Portland, USA]
        [
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[0]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[1]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[2]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[3]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[4]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[5]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[6]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[7]
          )
        ],
        // Filtered list by "Lo"
        // [London, Los Angeles]
        [
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[4]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[5]
          )
        ],
        // Filtered list by "a"
        // [Australia]
        [
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[0]
          )
        ],
        // Filtered list by "x"
        // Empty (no matches found)
        [
        ],
        // Unfiltered list: [Australia, Brooklyn, Canada, Great Britain, London, Los Angeles, Portland, USA]
        [
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[0]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[1]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[2]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[3]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[4]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[5]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[6]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[7]
          )
        ],
        // Filtered list by "c"
        // [Canada]
        [
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[2]
          )
        ]
      ]
    )
    self.reloadDataWithShippingRulesReload.assertValues([true, true, true, true, true, true])
  }

  /**

   This test performs a search on shipping rules list as well as selection of a shipping rule

   1) We load the list
    - Shows: Australia, Brooklyn, Canada, Great Britain, London, Los Angeles, Portland, USA
    - Selected rule: Australia
   2) We perform search for shipping rules locations starting with "Lo" prefix
    - Shows: London, Los Angeles
    - Selected rule: Australia
   3) We perform selection of Los Angeles
    - Shows: London, Los Angeles
    - Selected rule: Los Angeles
   4) We perform search for shipping rules locations starting with "c" prefix
    - Shows: Canada
    - Selected rule: Los Angeles
   5) We perform selection of Los Angeles
    - Shows: Canada
    - Selected rule: Canada

   */
  func testSearchAndSelection() {
    let project = Project.template
    let selectedShippingRule = shippingRules[0]

    self.vm.inputs.configureWith(
      project, shippingRules: shippingRules, selectedShippingRule: selectedShippingRule
    )
    self.vm.inputs.viewDidLoad()

    self.reloadDataWithShippingRulesData.assertValues(
      [
        // Unfiltered list: [Australia, Brooklyn, Canada, Great Britain, London, Los Angeles, Portland, USA]
        // Selected rule: Australia
        [
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[0]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[1]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[2]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[3]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[4]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[5]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[6]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[7]
          )
        ]
      ]
    )
    self.reloadDataWithShippingRulesReload.assertValues([true])

    // Search for shipping rules locations starting with "Lo" (should filter down to London, Los Angeles)
    self.vm.inputs.searchTextDidChange("Lo")

    self.scheduler.advance(by: .milliseconds(100))

    self.reloadDataWithShippingRulesData.assertValues(
      [
        // Unfiltered list: [Australia, Brooklyn, Canada, Great Britain, London, Los Angeles, Portland, USA]
        // Selected rule: Australia
        [
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[0]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[1]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[2]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[3]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[4]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[5]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[6]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[7]
          )
        ],
        // Filtered list by "Lo": [London, Los Angeles]
        // Selected rule: Australia
        [
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[4]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[5]
          )
        ]
      ]
    )
    self.reloadDataWithShippingRulesReload.assertValues([true, true])

    self.vm.inputs.didSelectShippingRule(at: 1)

    let firstManuallySelectedShippingRule = shippingRules[5]

    self.deselectVisibleCells.assertValueCount(1)
    self.notifyDelegateOfSelectedShippingRule.assertValues([firstManuallySelectedShippingRule])
    self.reloadDataWithShippingRulesData.assertValues(
      [
        // Unfiltered list: [Australia, Brooklyn, Canada, Great Britain, London, Los Angeles, Portland, USA]
        // Selected rule: Australia
        [
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[0]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[1]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[2]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[3]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[4]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[5]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[6]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[7]
          )
        ],
        // Filtered list by "Lo": [London, Los Angeles]
        // Selected rule: Australia
        [
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[4]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[5]
          )
        ],
        // Filtered list by "Lo": [London, Los Angeles]
        // Selected rule: Los Angeles
        [
          ShippingRuleData(
            project: project, selectedShippingRule: firstManuallySelectedShippingRule,
            shippingRule: shippingRules[4]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: firstManuallySelectedShippingRule,
            shippingRule: shippingRules[5]
          )
        ]
      ]
    )
    self.reloadDataWithShippingRulesReload.assertValues([true, true, false])
    self.selectCellAtIndex.assertValues([1])

    // Search for shipping rules locations starting with "c" (should filter down to Canada)
    self.vm.inputs.searchTextDidChange("c")

    self.scheduler.advance(by: .milliseconds(100))

    self.reloadDataWithShippingRulesData.assertValues(
      [
        // Unfiltered list: [Australia, Brooklyn, Canada, Great Britain, London, Los Angeles, Portland, USA]
        // Selected rule: Australia
        [
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[0]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[1]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[2]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[3]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[4]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[5]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[6]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[7]
          )
        ],
        // Filtered list by "Lo": [London, Los Angeles]
        // Selected rule: Australia
        [
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[4]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[5]
          )
        ],
        // Filtered list by "Lo": [London, Los Angeles]
        // Selected rule: Los Angeles
        [
          ShippingRuleData(
            project: project, selectedShippingRule: firstManuallySelectedShippingRule,
            shippingRule: shippingRules[4]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: firstManuallySelectedShippingRule,
            shippingRule: shippingRules[5]
          )
        ],
        // Filtered list by "c": [Canada]
        // Selected rule: Los Angeles
        [
          ShippingRuleData(
            project: project, selectedShippingRule: firstManuallySelectedShippingRule,
            shippingRule: shippingRules[2]
          )
        ]
      ]
    )
    self.reloadDataWithShippingRulesReload.assertValues([true, true, false, true])

    self.vm.inputs.didSelectShippingRule(at: 0)

    let secondManuallySelectedShippingRule = shippingRules[2]

    self.deselectVisibleCells.assertValueCount(2)
    self.notifyDelegateOfSelectedShippingRule.assertValues(
      [firstManuallySelectedShippingRule, secondManuallySelectedShippingRule]
    )
    self.reloadDataWithShippingRulesData.assertValues(
      [
        // Unfiltered list: [Australia, Brooklyn, Canada, Great Britain, London, Los Angeles, Portland, USA]
        // Selected rule: Australia
        [
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[0]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[1]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[2]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[3]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[4]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[5]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[6]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[7]
          )
        ],
        // Filtered list by "Lo": [London, Los Angeles]
        // Selected rule: Australia
        [
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[4]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[5]
          )
        ],
        // Filtered list by "Lo": [London, Los Angeles]
        // Selected rule: Los Angeles
        [
          ShippingRuleData(
            project: project, selectedShippingRule: firstManuallySelectedShippingRule,
            shippingRule: shippingRules[4]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: firstManuallySelectedShippingRule,
            shippingRule: shippingRules[5]
          )
        ],
        // Filtered list by "c": [Canada]
        // Selected rule: Los Angeles
        [
          ShippingRuleData(
            project: project, selectedShippingRule: firstManuallySelectedShippingRule,
            shippingRule: shippingRules[2]
          )
        ],
        // Filtered list by "c": [Canada]
        // Selected rule: Canada
        [
          ShippingRuleData(
            project: project, selectedShippingRule: secondManuallySelectedShippingRule,
            shippingRule: shippingRules[2]
          )
        ]
      ]
    )
    self.reloadDataWithShippingRulesReload.assertValues([true, true, false, true, false])
    self.selectCellAtIndex.assertValues([1, 0])
  }

  /**

   This test performs selection of a shipping rule

   1) We load the list
    - Shows: Australia, Brooklyn, Canada, Great Britain, London, Los Angeles, Portland, USA
    - Selected rule: Brooklyn
   2) We perform selection of Portland
    - Shows: Australia, Brooklyn, Canada, Great Britain, London, Los Angeles, Portland, USA
    - Selected rule: Portland
   3) We perform selection of Great Britain
    - Shows: Australia, Brooklyn, Canada, Great Britain, London, Los Angeles, Portland, USA
    - Selected rule: Great Britain

   */
  func testSelection() {
    let project = Project.template
    let selectedShippingRule = shippingRules[1]

    self.vm.inputs.configureWith(
      project, shippingRules: shippingRules, selectedShippingRule: selectedShippingRule
    )
    self.vm.inputs.viewDidLoad()

    self.reloadDataWithShippingRulesData.assertValues(
      [
        // Unfiltered list: [Australia, Brooklyn, Canada, Great Britain, London, Los Angeles, Portland, USA]
        // Selected rule: Brooklyn
        [
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[0]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[1]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[2]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[3]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[4]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[5]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[6]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[7]
          )
        ]
      ]
    )
    self.reloadDataWithShippingRulesReload.assertValues([true])

    self.vm.inputs.didSelectShippingRule(at: 6)

    let firstManuallySelectedShippingRule = shippingRules[6]

    self.deselectVisibleCells.assertValueCount(1)
    self.notifyDelegateOfSelectedShippingRule.assertValues([firstManuallySelectedShippingRule])
    self.reloadDataWithShippingRulesData.assertValues(
      [
        // Unfiltered list: [Australia, Brooklyn, Canada, Great Britain, London, Los Angeles, Portland, USA]
        // Selected rule: Australia
        [
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[0]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[1]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[2]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[3]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[4]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[5]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[6]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[7]
          )
        ],
        // Unfiltered list: [Australia, Brooklyn, Canada, Great Britain, London, Los Angeles, Portland, USA]
        // Selected rule: Portland
        [
          ShippingRuleData(
            project: project, selectedShippingRule: firstManuallySelectedShippingRule,
            shippingRule: shippingRules[0]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: firstManuallySelectedShippingRule,
            shippingRule: shippingRules[1]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: firstManuallySelectedShippingRule,
            shippingRule: shippingRules[2]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: firstManuallySelectedShippingRule,
            shippingRule: shippingRules[3]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: firstManuallySelectedShippingRule,
            shippingRule: shippingRules[4]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: firstManuallySelectedShippingRule,
            shippingRule: shippingRules[5]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: firstManuallySelectedShippingRule,
            shippingRule: shippingRules[6]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: firstManuallySelectedShippingRule,
            shippingRule: shippingRules[7]
          )
        ]
      ]
    )
    self.reloadDataWithShippingRulesReload.assertValues([true, false])
    self.selectCellAtIndex.assertValues([6])

    self.vm.inputs.didSelectShippingRule(at: 3)

    let secondManuallySelectedShippingRule = shippingRules[3]

    self.deselectVisibleCells.assertValueCount(2)
    self.notifyDelegateOfSelectedShippingRule.assertValues(
      [firstManuallySelectedShippingRule, secondManuallySelectedShippingRule]
    )
    self.reloadDataWithShippingRulesData.assertValues(
      [
        // Unfiltered list: [Australia, Brooklyn, Canada, Great Britain, London, Los Angeles, Portland, USA]
        // Selected rule: Great Britain
        [
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[0]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[1]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[2]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[3]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[4]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[5]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[6]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRules[7]
          )
        ],
        // Unfiltered list: [Australia, Brooklyn, Canada, Great Britain, London, Los Angeles, Portland, USA]
        // Selected rule: Portland
        [
          ShippingRuleData(
            project: project, selectedShippingRule: firstManuallySelectedShippingRule,
            shippingRule: shippingRules[0]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: firstManuallySelectedShippingRule,
            shippingRule: shippingRules[1]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: firstManuallySelectedShippingRule,
            shippingRule: shippingRules[2]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: firstManuallySelectedShippingRule,
            shippingRule: shippingRules[3]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: firstManuallySelectedShippingRule,
            shippingRule: shippingRules[4]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: firstManuallySelectedShippingRule,
            shippingRule: shippingRules[5]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: firstManuallySelectedShippingRule,
            shippingRule: shippingRules[6]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: firstManuallySelectedShippingRule,
            shippingRule: shippingRules[7]
          )
        ],
        // Unfiltered list: [Australia, Brooklyn, Canada, Great Britain, London, Los Angeles, Portland, USA]
        // Selected rule: Great Britain
        [
          ShippingRuleData(
            project: project, selectedShippingRule: secondManuallySelectedShippingRule,
            shippingRule: shippingRules[0]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: secondManuallySelectedShippingRule,
            shippingRule: shippingRules[1]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: secondManuallySelectedShippingRule,
            shippingRule: shippingRules[2]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: secondManuallySelectedShippingRule,
            shippingRule: shippingRules[3]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: secondManuallySelectedShippingRule,
            shippingRule: shippingRules[4]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: secondManuallySelectedShippingRule,
            shippingRule: shippingRules[5]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: secondManuallySelectedShippingRule,
            shippingRule: shippingRules[6]
          ),
          ShippingRuleData(
            project: project, selectedShippingRule: secondManuallySelectedShippingRule,
            shippingRule: shippingRules[7]
          )
        ]
      ]
    )
    self.reloadDataWithShippingRulesReload.assertValues([true, false, false])
    self.selectCellAtIndex.assertValues([6, 3])
  }
}
