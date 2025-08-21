import Foundation
import Observation

public struct NextGenSearchResult: Identifiable, Equatable, Sendable {
  public let id: UUID
  public let name: String
}

@MainActor
public protocol NextGenSearchViewModelInputs {
  func onAppear()
  func searchTextChanged(_ text: String)
}

@MainActor
public protocol NextGenSearchViewModelOutputs {
  var results: [NextGenSearchResult] { get }
  var isLoading: Bool { get }
  var statusText: String { get }
}

@MainActor
public protocol NextGenSearchViewModelType {
  var inputs: NextGenSearchViewModelInputs { get }
  var outputs: NextGenSearchViewModelOutputs { get }
}

// ViewModel uses @Observable for SwiftUI binding, AsyncStream for typing, and an async/await apollo wrapper for network.
@MainActor
@Observable
public final class NextGenSearchViewModel: NextGenSearchViewModelType,
  NextGenSearchViewModelInputs, NextGenSearchViewModelOutputs, Identifiable {
  /// When the TextField changes `searchQuery`, push the new value into our AsyncStream
  /// so the debounced search pipeline can react to it.
  public var searchQuery: String = "" {
    didSet {
      self.textChangesContinuation.yield(self.searchQuery)
    }
  }

  public private(set) var results: [NextGenSearchResult] = []
  public private(set) var isLoading: Bool = false
  public private(set) var statusText: String = "Idle"

  private let service: any NextGenProjectSearchServicing
  private let textChangesStream: AsyncStream<String>
  private let textChangesContinuation: AsyncStream<String>.Continuation
  private var bindTask: Task<Void, Never>?
  private var currentRequest: Task<Void, Never>?

  public init(service: any NextGenProjectSearchServicing) {
    self.service = service

    (self.textChangesStream, self.textChangesContinuation) = AsyncStream<String>.makeStream()

    self.bindTyping(stream: self.textChangesStream)
  }

  public var inputs: NextGenSearchViewModelInputs { self }
  public var outputs: NextGenSearchViewModelOutputs { self }

  public func onAppear() {}

  public func searchTextChanged(_ text: String) { self.searchQuery = text }

  private func bindTyping(stream: AsyncStream<String>) {
    self.bindTask?.cancel()

    self.bindTask = Task {
      for await text in stream {
        try? await Task.sleep(nanoseconds: 250_000_000) // ~250ms

        if Task.isCancelled { return }

        await self.searchFor(query: text)
      }
    }
  }

  /// Perform one search (UI updates on MainActor).
  private func searchFor(query: String) async {
    let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

    guard !trimmedQuery.isEmpty else {
      self.currentRequest?.cancel()
      self.results = []
      self.statusText = "Idle"
      self.isLoading = false

      return
    }

    // Cancel previous and start a fresh task.
    self.currentRequest?.cancel()
    self.currentRequest = Task { @MainActor in
      self.isLoading = true
      self.statusText = "Searching projects for \"\(trimmedQuery)\"…"

      defer { self.isLoading = false }

      do {
        let items = try await self.service.searchProjects(matching: trimmedQuery)

        try Task.checkCancellation()

        self.results = items
        self.statusText = "Found \(items.count) project\(items.count == 1 ? "" : "s")"
      } catch is CancellationError {
        print("CancellationError when searching projects.")
      } catch {
        self.statusText = "Error: \(error.localizedDescription)"
      }
    }

    await self.currentRequest?.value
  }
}
