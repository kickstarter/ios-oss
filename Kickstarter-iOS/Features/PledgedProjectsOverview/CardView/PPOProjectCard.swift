//
//  PPOProjectCard.swift
//  Kickstarter-iOS
//
//  Created by Steve Streza on 7/29/24.
//  Copyright © 2024 Kickstarter. All rights reserved.
//

import Foundation
import KsApi
import SwiftUI

struct PPOProjectCard: View {
  @ObservedObject var viewModel: PPOProjectCardViewModel

  var body: some View {
    VStack(spacing: Constants.spacing) {
      flagList
      projectDetails
      Divider()
      projectCreator
      Divider()
      addressDetails
      actionButtons
    }
    .padding(.vertical)
    .frame(maxWidth: .infinity)
    // round rectangle around the card
    .clipShape(cardRectangle)
    .overlay(cardRectangle.strokeBorder(Color(uiColor: Constants.borderColor), lineWidth: Constants.borderWidth))
    // upper right corner badge
    .overlay(alignment: Constants.badgeAlignment, content: { badge })
    // insets
    .padding(.horizontal, Constants.outerPadding)
  }

  private var cardRectangle: RoundedRectangle {
    RoundedRectangle(cornerSize: CGSize(width: Constants.cornerSize, height: Constants.cornerSize))
  }

  @ViewBuilder
  private var badge: some View {
    Circle()
      .fill(Color(uiColor: Constants.badgeColor))
      .frame(width: Constants.badgeSize, height: Constants.badgeSize)
      .offset(x: Constants.badgeSize / 2, y: -(Constants.badgeSize / 2))
  }

  @ViewBuilder
  private var flagList: some View {
    if viewModel.alerts.isEmpty == false {
      HStack {
        VStack(alignment: .leading) {
          ForEach(viewModel.alerts) { alert in
            PPOAlertFlag(alert: alert)
          }
        }
        Spacer()
      }
      .padding([.horizontal])
    }
  }

  @ViewBuilder
  private var projectDetails: some View {
    PPOProjectDetails(
      imageUrl: viewModel.imageURL,
      title: viewModel.title
    )
    .padding([.horizontal])
  }

  @ViewBuilder
  private var projectCreator: some View {
    PPOProjectCreator(creatorName: viewModel.creatorName)
      .padding([.horizontal])
  }

  @ViewBuilder
  private var addressDetails: some View {
    if let address = viewModel.address {
      PPOAddressSummary(address: address)
        .padding([.horizontal])
    }
  }

  private func baseButton(for action: PPOProjectCardViewModel.Action) -> some View {
    Button(action.label) {
      action.action()
    }
  }

  @ViewBuilder
  private func button(for action: PPOProjectCardViewModel.Action) -> some View {
    switch action.style {
    case .green:
      baseButton(for: action)
        .buttonStyle(GreenButtonStyle())
    case .red:
      baseButton(for: action)
        .buttonStyle(RedButtonStyle())
    case .black:
      baseButton(for: action)
        .buttonStyle(BlackButtonStyle())
    }
  }

  private var actionButtons: some View {
    HStack {
      if let action = viewModel.secondaryAction {
        button(for: action)
      }

      button(for: viewModel.primaryAction)
    }
    .padding([.horizontal])
  }

  private enum Constants {
    static let cornerSize: CGFloat = 8
    static let borderColor = UIColor.ksr_support_300
    static let borderWidth: CGFloat = 1
    static let badgeAlignment = Alignment(horizontal: .trailing, vertical: .top)
    static let badgeColor = UIColor.hex(0xff3B30)
    static let badgeSize: CGFloat = 16
    static let spacing: CGFloat = 12
    static let outerPadding: CGFloat = 16
  }
}

#Preview("Basic card") {
  ScrollView(.vertical) {
    VStack(spacing: 16) {
      PPOProjectCard(viewModel: PPOProjectCardViewModel(
        alerts: [
          PPOProjectCardViewModel.Alert(type: .time, icon: .warning, message: "Address locks in 8 hours"),
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
        actions: (.init(label: "Confirm", style: .green, action: { () in }), .init(label: "Edit", style: .black, action: { () in }))
      ))

      PPOProjectCard(viewModel: PPOProjectCardViewModel(
        alerts: [
          PPOProjectCardViewModel.Alert(type: .alert, icon: .warning, message: "Survey available"),
          PPOProjectCardViewModel.Alert(type: .time, icon: .warning, message: "Address locks in 48 hours"),
        ],
        imageURL: URL(string: "http://localhost/")!,
        title: "Sugardew Island - Your cozy farm shop let’s pretend this is a way way way longer title",
        pledge: .init(amount: "50.00", currency: .usd, symbol: "$"),
        creatorName: "rokaplay truncate if longer than",
        address: nil,
        actions: (.init(label: "Complete survey", style: .green, action: { () in }), nil)
      ))

      PPOProjectCard(viewModel: PPOProjectCardViewModel(
        alerts: [
          PPOProjectCardViewModel.Alert(type: .alert, icon: .alert, message: "Payment failed"),
          PPOProjectCardViewModel.Alert(type: .time, icon: .alert, message: "Pledge will be dropped in 6 days"),
        ],
        imageURL: URL(string: "http://localhost/")!,
        title: "Sugardew Island - Your cozy farm shop let’s pretend this is a way way way longer title",
        pledge: .init(amount: "50.00", currency: .usd, symbol: "$"),
        creatorName: "rokaplay truncate if longer than",
        address: nil,
        actions: (.init(label: "Fix payment", style: .red, action: { () in }), nil)
      ))

      PPOProjectCard(viewModel: PPOProjectCardViewModel(
        alerts: [
          PPOProjectCardViewModel.Alert(type: .alert, icon: .alert, message: "Card needs authentication"),
          PPOProjectCardViewModel.Alert(type: .time, icon: .alert, message: "Pledge will be dropped in 6 days"),
        ],
        imageURL: URL(string: "http://localhost/")!,
        title: "Sugardew Island - Your cozy farm shop let’s pretend this is a way way way longer title",
        pledge: .init(amount: "50.00", currency: .usd, symbol: "$"),
        creatorName: "rokaplay truncate if longer than",
        address: nil,
        actions: (.init(label: "Authenticate card", style: .red, action: { () in }), nil)
      ))

      PPOProjectCard(viewModel: PPOProjectCardViewModel(
        alerts: [
          PPOProjectCardViewModel.Alert(type: .alert, icon: .warning, message: "Survey available"),
        ],
        imageURL: URL(string: "http://localhost/")!,
        title: "Sugardew Island - Your cozy farm shop let’s pretend this is a way way way longer title",
        pledge: .init(amount: "50.00", currency: .usd, symbol: "$"),
        creatorName: "rokaplay truncate if longer than",
        address: nil,
        actions: (.init(label: "Complete survey", style: .green, action: { () in }), nil)
      ))
    }
  }
}
