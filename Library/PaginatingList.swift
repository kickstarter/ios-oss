import Foundation
import SwiftUI

/// A List wrapper that handles pagination and refreshing
public struct PaginatingList<Data, Cell>: View where Data: Identifiable, Data: Hashable, Cell: View {
  var data: [Data] = []
  var canLoadMore: Bool
  var selectedItem: Binding<Data?>?

  let content: (Data) -> Cell
  let onRefresh: () async -> Void
  let onLoadMore: () async -> Void

  /// Create a new PaginatingList
  /// - Parameters:
  ///   - data: The list of items to show in the list that we currently have
  ///   - canLoadMore: Whether the view can load additional items
  ///   - selectedItem: A Binding for which row is selected. Required if you want cell selection/highlighting.
  ///   - content: A closure to generate a Cell from a given item of Data
  ///   - onRefresh: Called when the user pulls to refresh. Must await until refreshing is complete.
  ///   - onLoadMore: Called when the user loads the next page. Must await until loading is complete.
  public init(
    data: [Data],
    canLoadMore: Bool,
    selectedItem: Binding<Data?>? = nil,
    content: @escaping (Data) -> Cell,
    onRefresh: @escaping () async -> Void,
    onLoadMore: @escaping () async -> Void
  ) {
    self.data = data
    self.canLoadMore = canLoadMore
    self.selectedItem = selectedItem
    self.content = content
    self.onRefresh = onRefresh
    self.onLoadMore = onLoadMore
  }

  public var body: some View {
    List(selection: self.selectedItem) {
      ForEach(self.data) { item in
        self.content(item)
          .tag(item)
      }
      if self.canLoadMore {
        HStack {
          Spacer()
          ProgressView()
            .progressViewStyle(.circular)
            .onAppear {
              Task { () async in
                await self.onLoadMore()
              }
            }
          Spacer()
        }
      }
    }
    .listStyle(.plain)
    .refreshable {
      await self.onRefresh()
    }
  }
}
