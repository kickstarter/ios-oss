import Foundation
import KsApi
import Library
import SwiftUI

struct PPOProjectCard: View {
  @ObservedObject var viewModel: PPOProjectCardViewModel

  @State private var isUnread: Bool = false
  @State private var alerts: [PPOProjectCardAlert] = []
  @State private var imageURL: URL? = nil
  @State private var title: String? = ""
  @State private var pledge: GraphAPI.MoneyFragment? = nil
  @State private var creatorName: String? = nil
  @State private var address: String? = nil
  @State private var primaryAction: PPOProjectCardAction? = nil
  @State private var secondaryAction: PPOProjectCardAction? = nil
  @State private var parentSize: CGSize = .zero

  var body: some View {
    VStack(spacing: Constants.spacing) {
      self.flagList
      self.projectDetails(leadingColumnWidth: self.parentSize.width * Constants.firstColumnWidth)
      self.divider
      self.projectCreator
      self.divider
      self.addressDetails(leadingColumnWidth: self.parentSize.width * Constants.firstColumnWidth)
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
      content: { self.badge.opacity(self.isUnread ? 1 : 0) }
    )

    // insets
    .padding(.horizontal, Constants.outerPadding)

    // observation
    .onReceive(self.viewModel.isUnread, perform: { isUnread in
      self.isUnread = isUnread
    })
    .onReceive(self.viewModel.alerts, perform: { alerts in
      self.alerts = alerts
    })
    .onReceive(self.viewModel.imageURL, perform: { imageURL in
      self.imageURL = imageURL
    })
    .onReceive(self.viewModel.title, perform: { title in
      self.title = title
    })
    .onReceive(self.viewModel.pledge, perform: { pledge in
      self.pledge = pledge
    })
    .onReceive(self.viewModel.creatorName, perform: { creatorName in
      self.creatorName = creatorName
    })
    .onReceive(self.viewModel.address, perform: { address in
      self.address = address
    })
    .onReceive(self.viewModel.actions, perform: { actions in
      let (primary, secondary) = actions
      self.primaryAction = primary
      self.secondaryAction = secondary
    })
    .onReceive(self.viewModel.parentSize, perform: { size in
      self.parentSize = size
    })
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
    if self.alerts.isEmpty == false {
      HStack {
        VStack(alignment: .leading) {
          ForEach(self.alerts) { alert in
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
    if let title = self.title, let pledge = self.pledge, let imageURL = self.imageURL {
      PPOProjectDetails(
        imageUrl: imageURL,
        title: title,
        pledge: pledge,
        leadingColumnWidth: leadingColumnWidth
      )
      .padding([.horizontal])
    }
  }

  @ViewBuilder
  private var projectCreator: some View {
    if let creatorName = self.creatorName {
      PPOProjectCreator(creatorName: creatorName)
        .padding([.horizontal])
    }
  }

  @ViewBuilder
  private func addressDetails(leadingColumnWidth: CGFloat) -> some View {
    if let address = self.address {
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
      if let secondaryAction = self.secondaryAction {
        self.button(for: secondaryAction)
      }

      if let primaryAction = self.primaryAction {
        self.button(for: primaryAction)
      }
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

#Preview("Card variants") {
  GeometryReader(content: { geometry in
    ScrollView(.vertical) {
      VStack(spacing: 16) {
        PPOProjectCard(viewModel: PPOProjectCardViewModel(
          isUnread: true,
          alerts: [
            PPOProjectCardViewModel.Alert(type: .time, icon: .warning, message: "Address locks in 8 hours")
          ],
          imageURL: URL(string: "http://localhost/")!,
          title: "Sugardew Island - Your cozy farm shop let’s pretend this is a way way way longer title",
          pledge: .init(amount: "50.00", currency: .usd, symbol: "$"),
          creatorName: "rokaplay truncate if longer than",
          address: """
            Firsty Lasty
            123 First Street, Apt #5678
            Los Angeles, CA 90025-1234
            United States
          """,
          actions: (.confirmAddress, .editAddress),
          parentSize: geometry.size
        ))

        PPOProjectCard(viewModel: PPOProjectCardViewModel(
          isUnread: true,
          alerts: [
            PPOProjectCardViewModel.Alert(type: .alert, icon: .warning, message: "Survey available"),
            PPOProjectCardViewModel.Alert(type: .time, icon: .warning, message: "Address locks in 48 hours")
          ],
          imageURL: URL(string: "http://localhost/")!,
          title: "Sugardew Island - Your cozy farm shop let’s pretend this is a way way way longer title",
          pledge: .init(amount: "50.00", currency: .usd, symbol: "$"),
          creatorName: "rokaplay truncate if longer than",
          address: nil,
          actions: (.completeSurvey, nil),
          parentSize: geometry.size
        ))

        PPOProjectCard(viewModel: PPOProjectCardViewModel(
          isUnread: true,
          alerts: [
            PPOProjectCardViewModel.Alert(type: .alert, icon: .alert, message: "Payment failed"),
            PPOProjectCardViewModel.Alert(
              type: .time,
              icon: .alert,
              message: "Pledge will be dropped in 6 days"
            )
          ],
          imageURL: URL(string: "http://localhost/")!,
          title: "Sugardew Island - Your cozy farm shop let’s pretend this is a way way way longer title",
          pledge: .init(amount: "50.00", currency: .usd, symbol: "$"),
          creatorName: "rokaplay truncate if longer than",
          address: nil,
          actions: (.fixPayment, nil),
          parentSize: geometry.size
        ))

        PPOProjectCard(viewModel: PPOProjectCardViewModel(
          isUnread: true,
          alerts: [
            PPOProjectCardViewModel.Alert(type: .alert, icon: .alert, message: "Card needs authentication"),
            PPOProjectCardViewModel.Alert(
              type: .time,
              icon: .alert,
              message: "Pledge will be dropped in 6 days"
            )
          ],
          imageURL: URL(string: "http://localhost/")!,
          title: "Sugardew Island - Your cozy farm shop let’s pretend this is a way way way longer title",
          pledge: .init(amount: "50.00", currency: .usd, symbol: "$"),
          creatorName: "rokaplay truncate if longer than",
          address: nil,
          actions: (.authenticateCard, nil),
          parentSize: geometry.size
        ))

        PPOProjectCard(viewModel: PPOProjectCardViewModel(
          isUnread: true,
          alerts: [
            PPOProjectCardViewModel.Alert(type: .alert, icon: .warning, message: "Survey available")
          ],
          imageURL: URL(string: "http://localhost/")!,
          title: "Sugardew Island - Your cozy farm shop let’s pretend this is a way way way longer title",
          pledge: .init(amount: "50.00", currency: .usd, symbol: "$"),
          creatorName: "rokaplay truncate if longer than",
          address: nil,
          actions: (.completeSurvey, nil),
          parentSize: geometry.size
        ))
      }
    }
  })
}
