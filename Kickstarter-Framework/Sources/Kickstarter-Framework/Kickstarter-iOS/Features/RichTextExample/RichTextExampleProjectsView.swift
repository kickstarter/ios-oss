import SwiftUI

internal struct RichTextExampleProjectsView: View {
  private var viewModel = RichTextExampleProjectsViewModel()
  private var onSelectProject: (RichTextExampleProjectsViewModel.ProjectItem) -> Void

  init(onSelectProject: @escaping (RichTextExampleProjectsViewModel.ProjectItem) -> Void) {
    self.onSelectProject = onSelectProject
  }

  var body: some View {
    Group {
      if self.viewModel.isLoading {
        ProgressView()
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      } else if let error = viewModel.errorMessage {
        Text(error)
          .foregroundColor(.red)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      } else {
        List(self.viewModel.projects) { project in
          Button(project.name) {
            self.onSelectProject(project)
          }
        }
      }
    }
    .navigationTitle("Rich Text Example")
    .task {
      await self.viewModel.loadProjects()
    }
  }
}
