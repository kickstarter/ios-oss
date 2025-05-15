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
  let projectFlaggingKind: GraphAPI.NonDeprecatedFlaggingKind

  @SwiftUI.Environment(\.dismiss) private var dismiss
  @StateObject private var viewModel = ReportProjectFormViewModel()

  @FocusState private var focusField: ReportFormFocusField?

  var body: some View {
    GeometryReader { proxy in
      Form {
        SwiftUI.Section(Strings.Email()) {
          if let retrievedEmail = viewModel.retrievedEmail, !retrievedEmail.isEmpty {
            Text(retrievedEmail)
              .font(Font(UIFont.ksr_body()))
              .foregroundColor(LegacyColors.ksr_support_400.swiftUIColor())
              .disabled(true)
          } else {
            Text(Strings.Loading())
              .font(Font(UIFont.ksr_body()))
              .foregroundColor(LegacyColors.ksr_support_400.swiftUIColor())
              .italic()
              .disabled(true)
          }
        }

        SwiftUI.Section(Strings.Project_url()) {
          Text(self.projectURL)
            .font(Font(UIFont.ksr_body()))
            .foregroundColor(LegacyColors.ksr_support_400.swiftUIColor())
            .disabled(true)
        }

        SwiftUI.Section {
          TextEditor(text: self.$viewModel.detailsText)
            .frame(minHeight: 75)
            .font(Font(UIFont.ksr_body()))
            .focused(self.$focusField, equals: .details)
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
            saveEnabled: self.$viewModel.saveButtonEnabled,
            showLoading: self.$viewModel.saveButtonLoading,
            titleText: Strings.Send()
          ) {
            self.viewModel.didTapSave()
          }
        }
      }
      .onAppear {
        self.focusField = .details

        self.viewModel.projectID = self.projectID
        self.viewModel.projectFlaggingKind = self.projectFlaggingKind

        self.viewModel.inputs.viewDidLoad()
      }
      .onReceive(self.viewModel.$bannerMessage) { newValue in
        /// bannerMessage is set to nil when its done presenting. When it is done, and submit was successful,  dismiss this view.
        if newValue == nil, self.viewModel.submitSuccess {
          self.dismiss()
          self.popToRoot = true
        }
      }
      .overlay(alignment: .bottom) {
        MessageBannerView(viewModel: self.$viewModel.bannerMessage)
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
