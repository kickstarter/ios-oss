import KsApi
import Library
import SwiftUI

enum ReportFormFocusField {
  case details
}

struct ReportProjectFormView: View {
  @Binding var popToRoot: Bool
  let projectID: String
  let projectURL: String
  let projectFlaggingKind: GraphAPI.FlaggingKind

  @SwiftUI.Environment(\.dismiss) private var dismiss
  @StateObject private var viewModel = ReportProjectFormViewModel()

  @State private var showLoading: Bool = false
  @FocusState private var focusField: ReportFormFocusField?

  var body: some View {
    GeometryReader { proxy in
      Form {
        SwiftUI.Section(Strings.Email()) {
          if let retrievedEmail = viewModel.retrievedEmail, !retrievedEmail.isEmpty {
            Text(retrievedEmail)
              .font(Font(UIFont.ksr_body()))
              .foregroundColor(Color(.ksr_support_400))
              .disabled(true)
          } else {
            Text(Strings.Loading())
              .font(Font(UIFont.ksr_body()))
              .foregroundColor(Color(.ksr_support_400))
              .italic()
              .disabled(true)
          }
        }

        SwiftUI.Section(Strings.Project_url()) {
          Text(projectURL)
            .font(Font(UIFont.ksr_body()))
            .foregroundColor(Color(.ksr_support_400))
            .disabled(true)
        }

        SwiftUI.Section {
          TextEditor(text: $viewModel.detailsText)
            .frame(minHeight: 75)
            .font(Font(UIFont.ksr_body()))
            .focused($focusField, equals: .details)
            .padding()
        } header: {
          Text(Strings.Tell_us_more_details())
            .padding(.leading, 20)
        }
        .listRowInsets(EdgeInsets())
      }
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          LoadingBarButtonItem(
            saveEnabled: $viewModel.saveButtonEnabled,
            saveTriggered: $viewModel.saveTriggered,
            showLoading: $showLoading,
            titleText: Strings.Send()
          )
        }
      }
      .onAppear {
        focusField = .details

        viewModel.projectID = projectID
        viewModel.projectFlaggingKind = projectFlaggingKind

        viewModel.inputs.viewDidLoad()
      }
      .onReceive(viewModel.$bannerMessage) { newValue in
        showLoading = false

        /// bannerMessage is set to nil when its done presenting. When it is done, and submit was successful,  dismiss this view.
        if newValue == nil, viewModel.submitSuccess {
          dismiss()
          popToRoot = true
        }
      }
      .onReceive(viewModel.$saveTriggered) { triggered in
        showLoading = triggered
      }
      .overlay(alignment: .bottom) {
        MessageBannerView(viewModel: $viewModel.bannerMessage)
          .frame(
            minWidth: proxy.size.width,
            idealWidth: proxy.size.width,
            maxHeight: proxy.size.height / 5,
            alignment: .bottom
          )
          .animation(.easeInOut)
      }
    }
  }
}
