import Combine
import GraphAPI
import KsApi
import Library
import Observation
import ReactiveSwift
import SwiftUI

@Observable
internal final class RichTextExampleProjectsViewModel {
  struct ProjectItem: Identifiable, Hashable {
    let id: String
    let name: String
    let richText: RichTextComponentFragment
  }

  private(set) var projects: [ProjectItem] = []
  private(set) var isLoading = true
  private(set) var errorMessage: String?

  func loadProjects() async {
    guard self.projects.isEmpty else { return }

    self.isLoading = true
    self.errorMessage = nil

    do {
      let results = try await AppEnvironment.current.apiService.fetch(query: RichTextExampleProjectsQuery())
      let nodes = results?.projects?.nodes?.compactMap { $0 } ?? []
      self.projects = nodes.map { node in
        ProjectItem(
          id: node.id,
          name: node.name,
          richText: node.storyRichText.fragments.richTextComponentFragment
        )
      }
      self.isLoading = false
    } catch {
      self.isLoading = false
      self.errorMessage = error.localizedDescription
    }
  }
}
