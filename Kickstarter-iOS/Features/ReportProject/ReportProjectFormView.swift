import KsApi
import SwiftUI

struct ReportProjectFormView: View {
  let projectURL: String
  let projectFlaggingKind: GraphAPI.FlaggingKind

  var body: some View {
    VStack {
      Text(projectURL)
      Text(projectFlaggingKind.rawValue)
    }
  }
}

struct ReportProjectFormView_Previews: PreviewProvider {
  static var previews: some View {
    ReportProjectFormView(projectURL: "", projectFlaggingKind: .prohibitedItems)
  }
}
