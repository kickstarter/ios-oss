import Foundation
import KsApi
import Library
import SwiftUI

struct PPOProjectCard: View {
  @StateObject var viewModel: PPOProjectCardViewModel

  var body: some View {
    VStack(spacing: Constants.spacing) {
      self.flagList
      self.projectDetails(leadingColumnWidth: self.viewModel.parentSize.width * Constants.firstColumnWidth)
      self.divider
      self.projectCreator
      self.divider
      self.addressDetails(leadingColumnWidth: self.viewModel.parentSize.width * Constants.firstColumnWidth)
      self.actionButtons
    }
    .padding(.vertical)
    .frame(maxWidth: .infinity)

    // round rectangle around the card
    .clipShape(self.cardRectangle)
    .overlay(self.cardRectangle.strokeBorder(
      Color(uiColor: Constants.borderColor),
      lineWidth: Constants.borderWidth
    ))

    // upper right corner badge
    .overlay(
      alignment: Constants.badgeAlignment,
      content: { self.badge.opacity(self.viewModel.card.isUnread ? 1 : 0) }
    )

    // insets
    .padding(.horizontal, Constants.outerPadding)
  }

  @ViewBuilder
  private var cardRectangle: RoundedRectangle {
    RoundedRectangle(cornerRadius: Constants.cornerRadius)
  }

  @ViewBuilder
  private var badge: some View {
    Circle()
      .fill(Color(uiColor: PPOCardStyles.badgeColor))
      .frame(width: Constants.badgeSize, height: Constants.badgeSize)
      .offset(x: Constants.badgeSize / 2, y: -(Constants.badgeSize / 2))
  }

  @ViewBuilder
  private var flagList: some View {
    if self.viewModel.card.alerts.isEmpty == false {
      HStack {
        VStack(alignment: .leading) {
          ForEach(self.viewModel.card.alerts) { alert in
            PPOAlertFlag(alert: alert)
          }
        }
        Spacer()
      }
      .padding([.horizontal])
    }
  }

  @ViewBuilder
  private func projectDetails(leadingColumnWidth: CGFloat) -> some View {
    PPOProjectDetails(
      imageUrl: self.viewModel.card.imageURL,
      title: self.viewModel.card.title,
      pledge: self.viewModel.card.pledge,
      leadingColumnWidth: leadingColumnWidth
    )
    .padding([.horizontal])
  }

  @ViewBuilder
  private var projectCreator: some View {
    PPOProjectCreator(creatorName: self.viewModel.card.creatorName)
      .padding([.horizontal])
  }

  @ViewBuilder
  private func addressDetails(leadingColumnWidth: CGFloat) -> some View {
    if let address = self.viewModel.card.address {
      PPOAddressSummary(address: address, leadingColumnWidth: leadingColumnWidth)
        .padding([.horizontal])
    }
  }

  @ViewBuilder
  private func baseButton(for action: PPOProjectCardViewModel.Action) -> some View {
    Button(action.label) { [weak viewModel] () in
      viewModel?.performAction(action: action)
    }
  }

  @ViewBuilder
  private func button(for action: PPOProjectCardViewModel.Action) -> some View {
    switch action.style {
    case .green:
      self.baseButton(for: action)
        .buttonStyle(GreenButtonStyle())
    case .red:
      self.baseButton(for: action)
        .buttonStyle(RedButtonStyle())
    case .black:
      self.baseButton(for: action)
        .buttonStyle(BlackButtonStyle())
    }
  }

  @ViewBuilder
  private var actionButtons: some View {
    HStack {
      if let secondaryAction = self.viewModel.secondaryAction {
        self.button(for: secondaryAction)
      }

      self.button(for: self.viewModel.primaryAction)
    }
    .padding([.horizontal])
  }

  @ViewBuilder
  private var divider: some View {
    Divider()
  }

  private enum Constants {
    static let cornerRadius: CGFloat = Styles.cornerRadius * 2
    static let borderColor = UIColor.ksr_support_300
    static let borderWidth: CGFloat = 1
    static let badgeAlignment = Alignment(horizontal: .trailing, vertical: .top)
    static let badgeSize: CGFloat = Styles.grid(4)
    static let spacing: CGFloat = Styles.grid(3)
    static let outerPadding: CGFloat = Styles.grid(4)
    static let firstColumnWidth: CGFloat = 0.25
  }
}

#if targetEnvironment(simulator)
  #Preview("Card variants") {
    GeometryReader(content: { geometry in
      ScrollView(.vertical) {
        VStack(spacing: 16) {
          ForEach(PledgedProjectOverviewCard.previewTemplates) { template in
            PPOProjectCard(viewModel: PPOProjectCardViewModel(card: template, parentSize: geometry.size))
          }
        }
      }
    })
  }
#endif
