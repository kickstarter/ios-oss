import Library
import SwiftUI

enum ReportProjectHyperLinkType: String, CaseIterable {
  case prohibitedItems
  case communityGuidelines

  func stringLiteral() -> String {
    switch self {
    case .prohibitedItems:
      return Strings.Prohibited_items()
    case .communityGuidelines:
      return "community guidelines"
    }
  }
}

@available(iOS 15, *)
struct ReportProjectInfoView: View {
  var body: some View {
    NavigationView {
      VStack(alignment: .leading, spacing: 10) {
        Text(Strings.Report_this_project())
          .font(Font(UIFont.ksr_title1()))
          .bold()
          .padding()

        List(listItems, children: \.subItems) { item in
          RowView(item: item)
        }
        .id(UUID())
        .navigationBarHidden(true)
        .listStyle(.inset)
        .tint(Color(.ksr_create_700))
      }
    }
  }
}

// MARK: - Views

@available(iOS 15, *)
private struct BaseRowView: View {
  var item: ReportProjectInfoListItem

  var body: some View {
    VStack(spacing: 0) {
      Text(item.title)
        .font(item.type == .parent ? Font(UIFont.ksr_body()) : Font(UIFont.ksr_callout()))
        .bold()
        .frame(maxWidth: .infinity, alignment: .leading)

      if let hyperLink = hyperLink(in: item.subtitle) {
        Text(html: item.subtitle, with: hyperLink)
          .font(item.type == .parent ? Font(UIFont.ksr_subhead()) : Font(UIFont.ksr_subhead(size: 14)))
          .frame(maxWidth: .infinity, alignment: .leading)
      } else {
      Text(item.subtitle)
        .font(item.type == .parent ? Font(UIFont.ksr_subhead()) : Font(UIFont.ksr_subhead(size: 14)))
        .frame(maxWidth: .infinity, alignment: .leading)
      }
    }
  }
}

@available(iOS 15, *)
struct RowView: View {
  var item: ReportProjectInfoListItem

  var body: some View {
    if item.type == .child {
      // TODO: Push Submission Form View In MBL-971(https://kickstarter.atlassian.net/browse/MBL-971)
      NavigationLink(destination: { Text("submit report view") }, label: { BaseRowView(item: item) })
    } else {
      BaseRowView(item: item)
    }
  }
}

// MARK: - Private Methods

/// Returns a ReportProjectHyperLinkType if the given string contains a type's string literal
private func hyperLink(in string: String) -> ReportProjectHyperLinkType? {
  for linkType in ReportProjectHyperLinkType.allCases {
    if string.lowercased().contains(linkType.stringLiteral().lowercased()) {
      return linkType
    }
  }

  return nil
}

// MARK: - Preview

@available(iOS 15, *)
struct ReportProjectInfoView_Previews: PreviewProvider {
  static var previews: some View {
    ReportProjectInfoView()
  }
}
