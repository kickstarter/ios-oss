import KsApi
import Library
import SwiftUI

enum ReportFormFocusField {
  case details
}

@available(iOS 15.0, *)
struct ReportProjectFormView: View {
  var email: String = "asdf@asdf.com"
  let projectURL: String
  let projectFlaggingKind: GraphAPI.FlaggingKind
  
  @State var details: String = ""
  @State var saveEnabled: Bool = false
  @State var saveTriggered: Bool = false
  @State var showLoading: Bool = false
  @FocusState private var focusField: ReportFormFocusField?
  
  var body: some View {
    Form {
      SwiftUI.Section(Strings.Email()) {
        Text(email)
          .font(Font(UIFont.ksr_body()))
          .foregroundColor(Color(.ksr_support_400))
          .disabled(true)
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
    }
    .onChange(of: details) { _ in
      saveEnabled = !details.isEmpty
    }
    .onChange(of: saveTriggered) { _ in
      focusField = nil
    }
  }
  
  struct LoadingBarButtonItem: View {
    @Binding var saveEnabled: Bool
    @Binding var saveTriggered: Bool
    @Binding var showLoading: Bool
    @State var titleText: String
    
    var body: some View {
      let buttonColor = $saveEnabled.wrappedValue ? Color(.ksr_create_700) : Color(.ksr_support_400)
      
      HStack {
        if !showLoading {
          Button(titleText) {
            showLoading = true
            saveTriggered = true
          }
          .font(Font(UIFont.systemFont(ofSize: 17)))
          .foregroundColor(buttonColor)
          .disabled(!$saveEnabled.wrappedValue)
        } else {
          ProgressView()
            .foregroundColor(Color(.ksr_create_300))
            .onDisappear {
              saveTriggered = false
            }
        }
      }
      .accessibilityElement(children: .combine)
      .accessibilityLabel(titleText)
    }
  }
}



@available(iOS 15.0, *)
struct ReportProjectFormView_Previews: PreviewProvider {
  static var previews: some View {
    ReportProjectFormView(projectURL: "", projectFlaggingKind: .prohibitedItems)
  }
}
