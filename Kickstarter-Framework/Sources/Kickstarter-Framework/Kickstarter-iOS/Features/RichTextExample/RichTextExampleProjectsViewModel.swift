import Combine
import GraphAPI
import KsApi
import Library
import ReactiveSwift
import SwiftUI

internal final class RichTextExampleProjectsViewModel: ObservableObject {
  struct ProjectItem: Identifiable, Hashable {
    let id: String
    let name: String
    let richText: RichTextComponentFragment
  }

  @Published private(set) var projects: [ProjectItem] = []
  @Published private(set) var isLoading = true
  @Published private(set) var errorMessage: String?

  private var fetchDisposable: Disposable?

  func loadProjects() {
    guard self.projects.isEmpty else { return }

    self.isLoading = true
    self.errorMessage = nil
    self.fetchDisposable?.dispose()

    self.fetchDisposable = AppEnvironment.current.apiService
      .fetch(query: RichTextExampleProjectsQuery())
      .observeForUI()
      .startWithResult { [weak self] result in
        guard let self else { return }
        self.isLoading = false
        switch result {
        case let .success(data):
          let nodes = data.projects?.nodes?.compactMap { $0 } ?? []
          self.projects = nodes.map { node in
            ProjectItem(
              id: node.id,
              name: node.name,
              richText: node.storyRichText.fragments.richTextComponentFragment
            )
          }
          self.errorMessage = nil
        case let .failure(error):
          self.errorMessage = error.errorMessages.first ?? "Failed to load projects"
        }
      }
  }
}
