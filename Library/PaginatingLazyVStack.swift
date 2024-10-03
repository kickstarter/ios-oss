import Foundation
import SwiftUI

// MARK: Implementation

public struct PaginatingLazyVStack<Data: Identifiable, Cell: View>: View {
  @Binding var data: [Data]
  @Binding var canShowProgressView: Bool

  let onRefresh: () async -> Void
  let onDidShowProgressView: () -> Void
  let configureCell: (Data) -> Cell

  public init(
    data: Binding<[Data]>,
    canShowProgressView: Binding<Bool>,
    configureCell: @escaping (Data) -> Cell,
    onRefresh: @escaping () async -> Void,
    onDidShowProgressView: @escaping () -> Void
  ) {
    self._data = data
    self._canShowProgressView = canShowProgressView
    self.onRefresh = onRefresh
    self.onDidShowProgressView = onDidShowProgressView
    self.configureCell = configureCell
  }

  public var body: some View {
    ScrollView {
      LazyVStack {
        ForEach(data) {
          configureCell($0)
        }
        .frame(
          maxWidth: .infinity
        )
        if canShowProgressView {
          HStack {
            Spacer()
            ProgressView()
              .progressViewStyle(.circular)
              .controlSize(.large)
              .onAppear {
                onDidShowProgressView()
              }
            Spacer()
          }
        }
      }
    }
    .refreshable {
      await onRefresh()
    }
  }
}

// MARK: Example view

private struct PaginatingLazyVStackExampleCell: View {
  let title: String
  var body: some View {
    Text(title)
      .padding(.all, 10)
  }
}

struct PaginatingExampleModel: Identifiable {
  let title: String
  let id: String
}

struct PaginatingLazyVStackExampleView: View {
  @State var data: [PaginatingExampleModel] = []
  @State var hasMore: Bool = true

  var body: some View {
    PaginatingLazyVStack(
      data: $data,
      canShowProgressView: $hasMore
    ) { model in
      PaginatingLazyVStackExampleCell(title: model.title)
    }
    onRefresh: {
      await refresh()
    }
    onDidShowProgressView: {
      DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        addMore()
      }
    }
  }

  private func addMore() {
    for _ in 0...15 {
      let uuid = UUID().uuidString
      self.data.append(PaginatingExampleModel(
        title: "Hello, world \(uuid)",
        id: uuid
      ))
    }

    if self.data.count > 100 {
      self.hasMore = false
    }
  }

  private func refresh() async {
    if #available(iOS 16.0, *) {
      try? await Task.sleep(for: .seconds(1))
    } else {}

    self.data = []
    self.addMore()
  }
}

#Preview {
  PaginatingLazyVStackExampleView()
}
