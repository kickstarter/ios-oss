import KsApi

extension KsApi.Category: @retroactive Identifiable {}
// Implements FilterCategory so KsApi.Category can be used in a FilterCategoryView.
extension KsApi.Category: FilterCategory {
  public var id: Int {
    guard let intId = self.intID else {
      assert(
        false,
        "Category is missing an int identifier. It may not display correctly in the filter sheet."
      )
      return -1
    }
    return intId
  }
}
