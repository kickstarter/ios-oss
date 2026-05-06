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

  private static func extractSlug(from input: String) -> String? {
    // Test for url slug: foo/bar
    if input.contains("/"), !input.hasPrefix("http"), !input.hasPrefix("https") {
      let parts = input.split(separator: "/").map(String.init)
      if parts.count == 2, !parts[0].isEmpty, !parts[1].isEmpty {
        return parts.joined(separator: "/")
      }
    }

    // Test for url: (whatever kickstarter domain)/projects/foo/bar
    if
      let url = URL(string: input),
      let components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
      let pathComponents = components.path.split(separator: "/").map(String.init)
      if pathComponents.count >= 3, pathComponents[0].lowercased() == "projects" {
        let owner = pathComponents[1]
        let name = pathComponents[2]
        if !owner.isEmpty, !name.isEmpty {
          return "\(owner)/\(name)"
        }
      }
    }

    // No correct result found
    return nil
  }

  func loadProject(slug slugOrURL: String) async -> ProjectItem? {
    // Normalize input: accept either a raw slug "foo/bar" or a Kickstarter project URL
    guard let slug = Self.extractSlug(from: slugOrURL) else {
      return nil
    }

    let result = try? await AppEnvironment.current.apiService.fetch(
      query: RichTextExampleProjectBySlugQuery(slug: slug)
    )
    guard let project = result?.project else { return nil }
    let item = ProjectItem(
      id: project.id,
      name: project.name,
      richText: project.storyRichText.fragments.richTextComponentFragment
    )
    return item
  }

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
