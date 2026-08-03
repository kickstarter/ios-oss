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

// MARK: - Main View

/// Shows a plain list of expandable report categories fetched from the API.
/// Tapping a top-level group expands it, sub-groups expand further, leaf options navigate to the submit form.
struct ReportProjectInfoView: View {
  let projectID: String
  let projectUrl: String
  let onSuccessfulSubmit: () -> Void

  @SwiftUI.Environment(\.dismiss) private var dismiss
  @State private var popToRoot = false
  /// Tracks which group rows are expanded. IDs are unique across the whole tree.
  @State private var expandedIDs: Set<ReportProjectInfoListItem.ID> = []
  @StateObject private var viewModel = ReportProjectInfoViewModel()

  var body: some View {
    List {
      ForEach(self.viewModel.listItems) { item in
        /// Top-level group row, tap to expand/collapse.
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
            if subItem.subItems != nil {
              Button {
                withAnimation(.easeInOut(duration: Constants.animationDuration)) {
                  if self.expandedIDs.contains(subItem.id) {
                    self.expandedIDs.remove(subItem.id)
                  } else {
                    self.expandedIDs.insert(subItem.id)
                  }
                }
              } label: {
                ParentRowLabel(item: subItem, isExpanded: self.expandedIDs.contains(subItem.id))
              }
              .buttonStyle(.plain)
              .padding(.leading)

              if self.expandedIDs.contains(subItem.id) {
                ForEach(subItem.subItems ?? []) { leafItem in
                  self.optionLink(for: leafItem)
                    .padding(.leading)
                }
              }
            } else {
              /// Direct leaf option with no sub-group, goes straight to the submit form.
              self.optionLink(for: subItem)
            }
          }
        }
      }
    }
    .listStyle(.plain)
    .navigationTitle(Strings.Report_this_project())
    .navigationBarTitleDisplayMode(.inline)
    .onAppear {
      self.viewModel.inputs.viewDidLoad()
    }
    .onChange(of: self.popToRoot) { _, newValue in
      if newValue {
        self.dismiss()
        self.onSuccessfulSubmit()
      }
    }
  }

  /// Navigates to the submit form, passing the flagging kind and placeholder text.
  @ViewBuilder
  private func optionLink(for item: ReportProjectInfoListItem) -> some View {
    NavigationLink {
      ReportProjectFormView(
        popToRoot: self.$popToRoot,
        projectID: self.projectID,
        projectURL: self.projectUrl,
        projectFlaggingKind: item.flaggingKind ?? GraphAPI.NonDeprecatedFlaggingKind.guidelinesViolation,
        placeholder: item.placeholder
      )
    } label: {
      ChildRowLabel(item: item)
    }
  }
}

// MARK: - ParentRowLabel

/// Expandable group row with a rotating chevron and optional html linked
private struct ParentRowLabel: View {
  let item: ReportProjectInfoListItem
  let isExpanded: Bool

  @ScaledMetric private var chevronSize: CGFloat = Constants.chevronSize
  private let green = Colors.Icon.green.swiftUIColor()

  var body: some View {
    HStack(alignment: .center, spacing: Constants.hStackSpacing) {
      VStack(alignment: .leading, spacing: Constants.vStackSpacing) {
        self.titleText
          .frame(maxWidth: .infinity, alignment: .leading)

        self.subtitleText
          .frame(maxWidth: .infinity, alignment: .leading)
          .multilineTextAlignment(.leading)
      }

      Image(systemName: Constants.chevronSymbol)
        .font(.system(size: self.chevronSize, weight: .semibold))
        .foregroundColor(self.green)
        .rotationEffect(.degrees(
          self.isExpanded ? Constants.chevronExpandedDegrees : Constants.chevronCollapsedDegrees
        ))
    }
    .padding(.vertical, Constants.verticalPadding)
    .contentShape(Rectangle())
  }

  /// Bold body text, renders as AttributedString if the title contains an <a> link.
  @ViewBuilder
  private var titleText: some View {
    let base = UIFont.ksr_body()
    let boldFont = UIFont(
      descriptor: base.fontDescriptor.withSymbolicTraits(.traitBold) ?? base.fontDescriptor,
      size: 0
    )
    if self.item.title.containsHTMLLink {
      Text(self.item.title.htmlAttributedString(
        font: boldFont,
        baseColor: Colors.Text.primary.swiftUIColor()
      ))
    } else {
      Text(self.item.title)
        .font(Font(boldFont))
        .foregroundColor(Colors.Text.primary.swiftUIColor())
    }
  }

  /// Subhead supporting text, secondary color unless it contains a link.
  @ViewBuilder
  private var subtitleText: some View {
    if self.item.subtitle.containsHTMLLink {
      Text(self.item.subtitle.htmlAttributedString(
        font: .ksr_subhead(),
        baseColor: Colors.Text.primary.swiftUIColor()
      ))
    } else {
      Text(self.item.subtitle)
        .font(Font(UIFont.ksr_subhead()))
        .foregroundColor(Colors.Text.secondary.swiftUIColor())
    }
  }
}

// MARK: - ChildRowLabel

/// Leaf option row, non-expandable, used inside a NavigationLink to the report form.
private struct ChildRowLabel: View {
  let item: ReportProjectInfoListItem

  var body: some View {
    VStack(alignment: .leading, spacing: Constants.vStackSpacing) {
      self.titleText
        .frame(maxWidth: .infinity, alignment: .leading)

      self.subtitleText
        .frame(maxWidth: .infinity, alignment: .leading)
        .multilineTextAlignment(.leading)
    }
    .padding(.vertical, Constants.verticalPadding)
  }

  @ViewBuilder
  private var titleText: some View {
    if self.item.title.containsHTMLLink {
      Text(self.item.title.htmlAttributedString(
        font: .ksr_subhead(),
        baseColor: Colors.Text.secondary.swiftUIColor()
      ))
    } else {
      Text(self.item.title)
        .font(Font(UIFont.ksr_callout()))
        .bold()
        .foregroundColor(Colors.Text.primary.swiftUIColor())
    }
  }

  @ViewBuilder
  private var subtitleText: some View {
    if self.item.subtitle.containsHTMLLink {
      Text(self.item.subtitle.htmlAttributedString(
        font: .ksr_footnote(),
        baseColor: Colors.Text.secondary.swiftUIColor()
      ))
    } else {
      Text(self.item.subtitle)
        .font(Font(UIFont.ksr_footnote()))
        .foregroundColor(Colors.Text.secondary.swiftUIColor())
    }
  }
}
