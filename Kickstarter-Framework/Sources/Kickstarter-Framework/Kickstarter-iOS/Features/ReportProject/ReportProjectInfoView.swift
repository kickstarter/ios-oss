import GraphAPI
import KDS
import KsApi
import Library
import SwiftUI

// MARK: - Constants

private enum Constants {
  static let animationDuration: Double = 0.25
  static let hStackSpacing: CGFloat = 8
  static let vStackSpacing: CGFloat = 4
  static let verticalPadding: CGFloat = 4
  static let chevronSymbol = "chevron.right"
  static let chevronSize: CGFloat = 14
  static let chevronExpandedDegrees: Double = 90
  static let chevronCollapsedDegrees: Double = 0
}

// MARK: - Hyperlink helpers

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

private func hyperLink(in string: String) -> ReportProjectHyperLinkType? {
  ReportProjectHyperLinkType.allCases.first {
    string.lowercased().contains($0.stringLiteral().lowercased())
  }
}

// MARK: - Main View

struct ReportProjectInfoView: View {
  let projectID: String
  let projectUrl: String
  let onSuccessfulSubmit: () -> Void

  @SwiftUI.Environment(\.dismiss) private var dismiss
  @State private var popToRoot = false
  @State private var expandedIDs: Set<ReportProjectInfoListItem.ID> = []

  var body: some View {
    List {
      ForEach(listItems) { item in
        Button {
          withAnimation(.easeInOut(duration: Constants.animationDuration)) {
            if self.expandedIDs.contains(item.id) {
              self.expandedIDs.remove(item.id)
            } else {
              self.expandedIDs.insert(item.id)
            }
          }
        } label: {
          ParentRowLabel(item: item, isExpanded: self.expandedIDs.contains(item.id))
        }
        .buttonStyle(.plain)

        if self.expandedIDs.contains(item.id) {
          ForEach(item.subItems ?? []) { subItem in
            NavigationLink {
              ReportProjectFormView(
                popToRoot: self.$popToRoot,
                projectID: self.projectID,
                projectURL: self.projectUrl,
                projectFlaggingKind: subItem.flaggingKind
                  ?? GraphAPI.NonDeprecatedFlaggingKind.guidelinesViolation
              )
            } label: {
              ChildRowLabel(item: subItem)
            }
          }
        }
      }
    }
    .listStyle(.plain)
    .navigationTitle(Strings.Report_this_project())
    .navigationBarTitleDisplayMode(.inline)
    .onChange(of: self.popToRoot) { _, newValue in
      if newValue {
        self.dismiss()
        self.onSuccessfulSubmit()
      }
    }
  }
}

// MARK: - ParentRowLabel

private struct ParentRowLabel: View {
  let item: ReportProjectInfoListItem
  let isExpanded: Bool

  @ScaledMetric private var chevronSize: CGFloat = Constants.chevronSize
  private let green = LegacyColors.ksr_create_700.swiftUIColor()

  var body: some View {
    HStack(alignment: .center, spacing: Constants.hStackSpacing) {
      VStack(alignment: .leading, spacing: Constants.vStackSpacing) {
        Text(self.item.title)
          .font(Font(UIFont.ksr_body()))
          .bold()
          .foregroundColor(Color(UIColor.label))
          .frame(maxWidth: .infinity, alignment: .leading)

        self.subtitleText
          .font(Font(UIFont.ksr_subhead()))
          .frame(maxWidth: .infinity, alignment: .leading)
          .multilineTextAlignment(.leading)
      }

      Image(systemName: Constants.chevronSymbol)
        .font(.system(size: self.chevronSize, weight: .semibold))
        .foregroundColor(self.green)
        .rotationEffect(.degrees(
          self.isExpanded ? Constants.chevronExpandedDegrees : Constants
            .chevronCollapsedDegrees
        ))
    }
    .padding(.vertical, Constants.verticalPadding)
    .contentShape(Rectangle())
  }

  @ViewBuilder
  private var subtitleText: some View {
    if let link = hyperLink(in: item.subtitle) {
      Text(html: self.item.subtitle, with: [link.stringLiteral()])
    } else {
      Text(self.item.subtitle)
    }
  }
}

// MARK: - ChildRowLabel

private struct ChildRowLabel: View {
  let item: ReportProjectInfoListItem

  var body: some View {
    VStack(alignment: .leading, spacing: Constants.vStackSpacing) {
      Text(self.item.title)
        .font(Font(UIFont.ksr_callout()))
        .bold()
        .foregroundColor(Color(UIColor.label))
        .frame(maxWidth: .infinity, alignment: .leading)

      self.subtitleText
        .font(Font(UIFont.ksr_footnote()))
        .foregroundColor(Color(UIColor.secondaryLabel))
        .frame(maxWidth: .infinity, alignment: .leading)
        .multilineTextAlignment(.leading)
    }
    .padding(.vertical, Constants.verticalPadding)
  }

  @ViewBuilder
  private var subtitleText: some View {
    if let link = hyperLink(in: item.subtitle) {
      Text(html: self.item.subtitle, with: [link.stringLiteral()])
    } else {
      Text(self.item.subtitle)
    }
  }
}
