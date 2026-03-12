import SwiftUI

internal struct RichTextExampleProjectsView: View {
  @StateObject private var viewModel = RichTextExampleProjectsViewModel()
  var onSelectProject: (RichTextExampleProjectsViewModel.ProjectItem) -> Void = { _ in }

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
    .onAppear {
      self.viewModel.loadProjects()
    }
  }
}
