import KsApi
import Library
import SwiftUI

enum ReportFormFocusField {
  case details
}

@available(iOS 15.0, *)
struct ReportProjectFormView: View {
  let projectID: String
  let projectURL: String
  let projectFlaggingKind: GraphAPI.FlaggingKind
  @Binding var popToRoot: Bool

  @SwiftUI.Environment(\.dismiss) private var dismiss
  @ObservedObject private var viewModel = ReportProjectFormViewModel()

  @State private var retrievedEmail = ""
  @State private var details: String = ""
  @State private var saveEnabled: Bool = false
  @State private var saveTriggered: Bool = false
  @State private var showLoading: Bool = false
  @State private var showBannerMessage = false
  @State private var submitSuccess = false
  @State private var bannerMessage: MessageBannerViewViewModel?
  @FocusState private var focusField: ReportFormFocusField?

  var body: some View {
    GeometryReader { proxy in
      Form {
        if !retrievedEmail.isEmpty {
          SwiftUI.Section(Strings.Email()) {
            Text(retrievedEmail)
              .font(Font(UIFont.ksr_body()))
              .foregroundColor(Color(.ksr_support_400))
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
          TextEditor(text: $details)
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
            saveEnabled: $saveEnabled,
            saveTriggered: $saveTriggered,
            showLoading: $showLoading,
            titleText: Strings.Save()
          )
        }
      }
      .onAppear {
        focusField = .details
        viewModel.inputs.viewDidLoad()
        viewModel.projectID.send(self.projectID)
        viewModel.projectFlaggingKind.send(self.projectFlaggingKind)
      }
      .onChange(of: details) { detailsText in
        viewModel.detailsText.send(detailsText)
      }
      .onChange(of: saveTriggered) { triggered in
        focusField = nil
        showLoading = triggered
        viewModel.saveTriggered.send(triggered)
      }
      .onChange(of: bannerMessage) { newValue in
        /// bannerMessage is set to nil when its done presenting. When it is done, and submit was successful,  dismiss this view.
        if newValue == nil, self.submitSuccess {
          dismiss()
          popToRoot = true
        } else if newValue?.bannerBackgroundColor == Color(.ksr_alert) {
          saveEnabled = true
        }
      }
      .onReceive(viewModel.saveButtonEnabled) { newValue in
        saveEnabled = newValue
      }
      .onReceive(viewModel.submitSuccess) { _ in
        submitSuccess = true
      }
      .onReceive(viewModel.retrievedEmail) { email in
        retrievedEmail = email
      }
      .onReceive(viewModel.bannerMessage) { newValue in
        showLoading = false
        saveEnabled = false
        bannerMessage = newValue
      }
      .overlay(alignment: .bottom) {
        MessageBannerView(viewModel: $bannerMessage)
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
