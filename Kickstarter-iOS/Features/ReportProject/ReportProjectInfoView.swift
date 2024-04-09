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

struct ReportProjectInfoView: View {
  let projectID: String
  let projectUrl: String
  let onSuccessfulSubmit: () -> Void

  @SwiftUI.Environment(\.dismiss) private var dismiss
  @State private var selection: Set<ReportProjectInfoListItem> = []
  @State private var popToRoot = false

  var body: some View {
    ScrollView {
      ForEach(listItems) { item in
        RowView(
          item: item,
          isExpanded: self.selection.contains(item),
          projectID: self.projectID,
          projectUrl: self.projectUrl,
          popToRoot: self.$popToRoot
        )
        .modifier(ListRowModifier())
        .onTapGesture {
          withAnimation {
            self.selectDeselect(item)
          }
        }
        .padding(5)
        .animation(.linear(duration: 0.3))
      }
    }
    .navigationTitle(Strings.Report_this_project())
    .navigationBarTitleDisplayMode(.inline)
    .onChange(of: self.popToRoot) { newValue in
      if newValue == true {
        self.dismiss()
        self.onSuccessfulSubmit()
      }
    }
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

private struct BaseRowView: View {
  var item: ReportProjectInfoListItem
  var isExpanded: Bool = false

  var body: some View {
    HStack {
      VStack(spacing: 5) {
        Text(self.item.title)
          .font(self.item.type == .parent ? Font(UIFont.ksr_body()) : Font(UIFont.ksr_callout()))
          .bold()
          .frame(maxWidth: .infinity, alignment: .leading)

        if let hyperLink = hyperLink(in: item.subtitle) {
          Text(html: self.item.subtitle, with: [hyperLink.stringLiteral()])
            .font(self.item.type == .parent ? Font(UIFont.ksr_subhead()) : Font(UIFont.ksr_footnote()))
            .frame(maxWidth: .infinity, alignment: .leading)
            .multilineTextAlignment(.leading)
        } else {
          Text(self.item.subtitle)
            .font(self.item.type == .parent ? Font(UIFont.ksr_subhead()) : Font(UIFont.ksr_footnote()))
            .frame(maxWidth: .infinity, alignment: .leading)
            .multilineTextAlignment(.leading)
        }
      }

      Spacer()

      Image(self.isExpanded ? "arrow-down" : "chevron-right")
        .resizable()
        .scaledToFit()
        .frame(width: 15, height: 15)
        .foregroundColor(self.item.type == .parent ? Color(.ksr_create_700) : Color(.ksr_support_400))
    }
  }
}

struct RowView: View {
  var item: ReportProjectInfoListItem
  let isExpanded: Bool
  let projectID: String
  let projectUrl: String

  @Binding var popToRoot: Bool

  private let contentSpacing = 10.0
  private let contentPadding = 12.0

  var body: some View {
    HStack {
      VStack(alignment: .leading) {
        BaseRowView(item: self.item, isExpanded: self.isExpanded)

        if self.isExpanded {
          ForEach(self.item.subItems ?? []) { item in
            VStack(alignment: .leading, spacing: self.contentSpacing) {
              NavigationLink(
                destination: {
                  ReportProjectFormView(
                    popToRoot: self.$popToRoot,
                    projectID: self.projectID,
                    projectURL: self.projectUrl,
                    projectFlaggingKind: item.flaggingKind ?? GraphAPI.NonDeprecatedFlaggingKind
                      .guidelinesViolation
                  )
                },
                label: { BaseRowView(item: item) }
              )
              .buttonStyle(PlainButtonStyle())
            }
            .padding(.vertical, 5)
            .padding(.leading, self.contentPadding)
          }
        }
      }
    }
    .padding(.trailing, 30)
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

// MARK: - Modifiers

struct ListRowModifier: ViewModifier {
  func body(content: Content) -> some View {
    Group {
      content
      Divider()
    }.offset(x: 20)
  }
}
