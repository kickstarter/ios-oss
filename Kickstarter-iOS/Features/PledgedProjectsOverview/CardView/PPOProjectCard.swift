import Foundation
import KsApi
import Library
import SwiftUI

struct PPOProjectCard: View {
  @StateObject var viewModel: PPOProjectCardViewModel
  var parentSize: CGSize

  var onViewBackingDetails: ((PPOProjectCardModel) -> Void)? = nil
  var onSendMessage: ((PPOProjectCardModel) -> Void)? = nil
  var onPerformAction: ((PPOProjectCardModel, PPOProjectCardModel.Action) -> Void)? = nil

  var body: some View {
    VStack(spacing: Constants.spacing) {
      self.flagList
      self.projectDetails(leadingColumnWidth: self.parentSize.width * Constants.firstColumnWidth)
      self.divider
      self.projectCreator
      self.divider
      self.addressDetails(leadingColumnWidth: self.parentSize.width * Constants.firstColumnWidth)
      self.actionButtons
      self.actionDetails
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

    // Handle actions
    .onReceive(self.viewModel.viewBackingDetailsTapped) {
      self.onViewBackingDetails?(self.viewModel.card)
    }
    .onReceive(self.viewModel.sendMessageTapped) {
      self.onSendMessage?(self.viewModel.card)
    }
    .onReceive(self.viewModel.actionPerformed) { action in
      self.onPerformAction?(self.viewModel.card, action)
    }
  }

  @ViewBuilder
  private var cardRectangle: RoundedRectangle {
    RoundedRectangle(cornerRadius: Constants.cornerRadius)
  }

  @ViewBuilder
  private var badge: some View {
    Circle()
      .fill(Color(uiColor: PPOStyles.badgeColor))
      .frame(width: Constants.badgeSize, height: Constants.badgeSize)
      .offset(x: Constants.badgeSize / 2, y: -(Constants.badgeSize / 2))
  }

  @ViewBuilder
  private var flagList: some View {
    if self.viewModel.card.alerts.isEmpty == false {
      HStack {
        FlowLayout(
          spacing: PPOStyles.flagSpacing,
          alignment: .leading
        ) {
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
    Button { [weak viewModel] () in
      viewModel?.viewBackingDetails()
    } label: {
      PPOProjectDetails(
        image: self.viewModel.card.image,
        title: self.viewModel.card.projectName,
        pledge: self.viewModel.card.pledge,
        leadingColumnWidth: leadingColumnWidth
      )
      .padding([.horizontal])
    }
    // MBL-2020: Keeps the button action from being triggered by other taps in the card.
    .buttonStyle(BorderlessButtonStyle())
  }

  @ViewBuilder
  private var projectCreator: some View {
    Button { [weak viewModel] () in
      viewModel?.sendCreatorMessage()
    } label: {
      PPOProjectCreator(
        creatorName: self.viewModel.card.creatorName
      )
      .padding([.horizontal])
    }
    // MBL-2020: Keeps the button action from being triggered by other taps in the card.
    .buttonStyle(BorderlessButtonStyle())
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
    ZStack {
      switch action.style {
      case .green:
        self.baseButton(for: action)
          .buttonStyle(KSRButtonStyleModifier(style: .green))
      case .red:
        self.baseButton(for: action)
          .buttonStyle(KSRButtonStyleModifier(style: .filledDestructive))
      case .black:
        self.baseButton(for: action)
          .buttonStyle(KSRButtonStyleModifier(style: .filled))
      }

      if self.viewModel.buttonState == .loading {
        ProgressView()
          .progressViewStyle(CircularProgressViewStyle(tint: .white))
      }
    }
    .disabled(self.viewModel.buttonState == .loading || self.viewModel.buttonState == .disabled)
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
  private var actionDetails: some View {
    if let actionDetails = self.viewModel.actionDetails {
      Text(actionDetails)
        .font(Font(PPOStyles.subtitle.font))
        .frame(
          maxWidth: .infinity,
          alignment: .leading
        )
        .foregroundStyle(Color(PPOStyles.subtitle.color))
        .padding([.horizontal])
    }
  }

  @ViewBuilder
  private var divider: some View {
    Divider()
  }

  private enum Constants {
    static let cornerRadius: CGFloat = Styles.cornerRadius * 2
    static let borderColor = LegacyColors.ksr_support_300.uiColor()
    static let borderWidth: CGFloat = 1
    static let badgeAlignment = Alignment(horizontal: .trailing, vertical: .top)
    static let badgeSize: CGFloat = Styles.grid(2)
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
          ForEach(PPOProjectCardModel.previewTemplates) { template in
            PPOProjectCard(
              viewModel: PPOProjectCardViewModel(card: template),
              parentSize: geometry.size
            )
          }
        }
      }
    })
  }
#endif
