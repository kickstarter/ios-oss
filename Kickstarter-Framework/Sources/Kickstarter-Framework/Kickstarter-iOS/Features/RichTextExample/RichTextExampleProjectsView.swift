import KDS
import SwiftUI

internal struct RichTextExampleProjectsView: View {
  private var viewModel = RichTextExampleProjectsViewModel()
  private var onSelectProject: (RichTextExampleProjectsViewModel.ProjectItem) -> Void
  @State private var slug: String = ""
  @State private var slugError: Bool = false

  init(onSelectProject: @escaping (RichTextExampleProjectsViewModel.ProjectItem) -> Void) {
    self.onSelectProject = onSelectProject
  }

  @ViewBuilder var directLinkField: some View {
    SwiftUI.Section {
      TextField("Project slug or URL (optional)", text: self.$slug)
        .autocorrectionDisabled()
        .autocapitalization(.none)
        .keyboardType(.URL)
        .onChange(of: self.slug) { _, _ in
          self.slugError = false
        }
        .onSubmit {
          Task {
            if let project = await self.viewModel.loadProject(slug: slug) {
              self.onSelectProject(project)
            } else {
              self.slugError = true
            }
          }
        }
      if self.slugError {
        Text("No project found")
          .foregroundStyle(Colors.Text.Accent.red.swiftUIColor())
      }
    }
  }

  var body: some View {
    List {
      self.directLinkField
      SwiftUI.Section {
        if self.viewModel.isLoading {
          ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let error = viewModel.errorMessage {
          Text(error)
            .foregroundColor(.red)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
          ForEach(self.viewModel.projects) { project in
            Button(project.name) {
              self.onSelectProject(project)
            }
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
