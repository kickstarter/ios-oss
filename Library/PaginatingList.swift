import Foundation
import SwiftUI

/// A List wrapper that handles pagination and refreshing
public struct PaginatingList<Data, Cell, Header>: View where Data: Identifiable, Data: Hashable, Cell: View, Header: View {
  var data: [Data] = []
  var canLoadMore: Bool
  var selectedItem: Binding<Data?>?

  let header: () -> Header
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
    header: @escaping () -> Header,
    content: @escaping (Data) -> Cell,
    onRefresh: @escaping () async -> Void,
    onLoadMore: @escaping () async -> Void
  ) {
    self.data = data
    self.canLoadMore = canLoadMore
    self.selectedItem = selectedItem
    self.header = header
    self.content = content
    self.onRefresh = onRefresh
    self.onLoadMore = onLoadMore
  }

  public var body: some View {
    List(selection: self.selectedItem) {
      self.header()
      ForEach(self.data) { item in
        self.content(item)
          .tag(item)
      }

      if self.canLoadMore {
        HStack(alignment: .center) {
          Spacer()
          ProgressView()
            .controlSize(.large)
            .id(self.loaderID)
          Spacer()
        }
        .listRowSeparator(.hidden, edges: .bottom)
        .onAppear {
          if !self.data.isEmpty {
            Task { () async in
              await self.onLoadMore()
            }
          }
        }
      }
    }
    .listStyle(.plain)
    .refreshable {
      await self.onRefresh()
    }
    .onChange(of: self.data) { _ in
      self.reloadLoaderID()
    }
  }

  // For some reason, a ProgressView in a List won't re-render without
  // this hacky ID reloading to make it think it's a different instance.
  // https://stackoverflow.com/questions/75570322/swiftui-progressview-in-list-can-only-be-displayed-once/75570351
  private func reloadLoaderID() {
    DispatchQueue.main.async {
      self.loaderID = UUID()
    }
  }

  @State private var loaderID = UUID()
}

extension PaginatingList where Header == EmptyView {
  public init(
    data: [Data],
    canLoadMore: Bool,
    selectedItem: Binding<Data?>? = nil,
    content: @escaping (Data) -> Cell,
    onRefresh: @escaping () async -> Void,
    onLoadMore: @escaping () async -> Void
  ) {
    self.init(
      data: data,
      canLoadMore: canLoadMore,
      selectedItem: selectedItem,
      header: { () in EmptyView() },
      content: content,
      onRefresh: onRefresh,
      onLoadMore: onLoadMore
    )
  }
}
