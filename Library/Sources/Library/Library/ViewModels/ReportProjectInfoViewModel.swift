import KsApi
import SwiftUI

/// View model for `ReportProjectInfoView`.
/// Fetches flagging options on `viewDidLoad` and publishes the result for SwiftUI.
@MainActor
public final class ReportProjectInfoViewModel: ObservableObject {
  @Published public var listItems: [ReportProjectInfoListItem] = []
  @Published public var isLoading = false

  public init() {}

  public func viewDidLoad() {
    Task {
      self.isLoading = true

      defer { isLoading = false }

      do {
        self.listItems = try await AppEnvironment.current.apiService
          .fetchFlaggingOptions(contentType: .project)
      } catch {
        /// listItems stays empty on error
      }
    }
  }
}
