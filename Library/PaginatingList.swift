import Foundation
import SwiftUI

public struct PaginatingList<Data, Cell>: View where Data: Identifiable, Data: Hashable, Cell: View {
  var data: [Data] = []
  var canShowProgressView: Bool
  var selectedItem: Binding<Data?>?

  let content: (Data) -> Cell
  let onRefresh: () async -> Void
  let onLoadMore: () async -> Void
  let onSelect: (Data) -> Void

  public init(
    data: [Data],
    canShowProgressView: Bool,
    selectedItem: Binding<Data?>? = nil,
    content: @escaping (Data) -> Cell,
    onRefresh: @escaping () async -> Void,
    onLoadMore: @escaping () async -> Void,
    onSelect: @escaping (Data) -> Void
  ) {
    self.data = data
    self.canShowProgressView = canShowProgressView
    self.selectedItem = selectedItem
    self.content = content
    self.onRefresh = onRefresh
    self.onLoadMore = onLoadMore
    self.onSelect = onSelect
  }

  public var body: some View {
    List(selection: self.selectedItem) {
      ForEach(self.data) { item in
        self.content(item)
          .tag(item)
      }
      if self.canShowProgressView {
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
