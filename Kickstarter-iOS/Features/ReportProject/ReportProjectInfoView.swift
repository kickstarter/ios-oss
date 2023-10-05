import KsApi
import Library
import SwiftUI

enum ReportProjectHyperLinkType: String, CaseIterable {
  case prohibitedItems
  case communityGuidelines
  case ourRules

  func stringLiteral() -> String {
    switch self {
    case .prohibitedItems:
      return Strings.Prohibited_items()
    case .communityGuidelines:
      return "community guidelines"
    case .ourRules:
      return "our rules"
    }
  }
}

@available(iOS 15, *)
struct ReportProjectInfoView: View {
  let projectID: String
  let projectUrl: String
  let onSuccessfulSubmit: () -> Void

  @SwiftUI.Environment(\.dismiss) private var dismiss
  @State private var selection: Set<ReportProjectInfoListItem> = []
  @State private var popToRoot = false

  var body: some View {
    List(listItems, children: \.subItems) { item in
      RowView(
        item: item,
        projectID: self.projectID,
        projectUrl: self.projectUrl,
        popToRoot: self.$popToRoot
      )
    }
    .navigationTitle(Strings.Report_this_project())
    .navigationBarTitleDisplayMode(.inline)
    .onChange(of: popToRoot) { newValue in
      if newValue == true {
        dismiss()
        onSuccessfulSubmit()
      }
    }
    .listStyle(.plain)
    .listItemTint(Color(.ksr_create_700))
  }

  private func selectDeselect(_ item: ReportProjectInfoListItem) {
    if self.selection.contains(item) {
      self.selection.remove(item)
    } else {
      self.selection.insert(item)
    }
  }
}

// MARK: - Views

@available(iOS 15, *)
private struct BaseRowView: View {
  var item: ReportProjectInfoListItem

  var body: some View {
    VStack(spacing: 5) {
      Text(item.title)
        .font(item.type == .parent ? Font(UIFont.ksr_body()) : Font(UIFont.ksr_callout()))
        .bold()
        .frame(maxWidth: .infinity, alignment: .leading)

      if let hyperLink = hyperLink(in: item.subtitle) {
        Text(html: item.subtitle, with: [hyperLink.stringLiteral()])
          .font(item.type == .parent ? Font(UIFont.ksr_subhead()) : Font(UIFont.ksr_footnote()))
          .frame(maxWidth: .infinity, alignment: .leading)
          .multilineTextAlignment(.leading)
      } else {
        Text(item.subtitle)
          .font(item.type == .parent ? Font(UIFont.ksr_subhead()) : Font(UIFont.ksr_footnote()))
          .frame(maxWidth: .infinity, alignment: .leading)
          .multilineTextAlignment(.leading)
      }
    }
    .accessibilityElement(children: .combine)
  }
}

@available(iOS 15, *)
struct RowView: View {
  var item: ReportProjectInfoListItem
  let projectID: String
  let projectUrl: String

  @Binding var popToRoot: Bool

  var body: some View {
    VStack(alignment: .leading) {
      if let subItems = item.subItems, subItems.count > 0 {
        BaseRowView(item: item)
      } else {
        NavigationLink(destination: { ReportProjectFormView(
          projectID: self.projectID,
          projectURL: self.projectUrl,
          projectFlaggingKind: item.flaggingKind ?? GraphAPI.FlaggingKind.guidelinesViolation,
          popToRoot: $popToRoot
        ) }, label: { BaseRowView(item: item) })
          .buttonStyle(PlainButtonStyle())
      }
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
