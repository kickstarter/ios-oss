//
//  PPOProjectCardViewModel.swift
//  Kickstarter-Framework-iOS
//
//  Created by Steve Streza on 8/8/24.
//  Copyright © 2024 Kickstarter. All rights reserved.
//

import Combine
import Foundation
import KsApi

protocol PPOProjectCardViewModelInputs {
  func sendCreatorMessage()
  func performAction(action: PPOProjectCardViewModel.Action)
}

protocol PPOProjectCardViewModelOutputs {
  var sendMessageTapped: AnyPublisher<Void, Never> { get }
  var actionPerformed: AnyPublisher<PPOProjectCardViewModel.Action, Never> { get }
}

typealias PPOProjectCardViewModelType = PPOProjectCardViewModelInputs & PPOProjectCardViewModelOutputs & ObservableObject & Identifiable

final class PPOProjectCardViewModel: PPOProjectCardViewModelType {
  internal private(set) var isUnread: Bool
  internal private(set) var alerts: [Alert]
  internal private(set) var imageURL: URL
  internal private(set) var title: String
  internal private(set) var pledge: GraphAPI.MoneyFragment
  internal private(set) var creatorName: String
  internal private(set) var address: String?
  internal private(set) var actions: (Action, Action?)

  private let sendCreatorMessageSubject = PassthroughSubject<Void, Never>()
  private let actionPerformedSubject = PassthroughSubject<PPOProjectCardViewModel.Action, Never>()

  init(
    isUnread: Bool,
    alerts: [PPOProjectCardViewModel.Alert],
    imageURL: URL,
    title: String,
    pledge: GraphAPI.MoneyFragment,
    creatorName: String,
    address: String?,
    actions: (PPOProjectCardViewModel.Action, PPOProjectCardViewModel.Action?)
  ) {
    self.isUnread = isUnread
    self.alerts = alerts
    self.imageURL = imageURL
    self.title = title
    self.pledge = pledge
    self.creatorName = creatorName
    self.address = address
    self.actions = actions
  }

  // Inputs

  func sendCreatorMessage() {
    sendCreatorMessageSubject.send(())
  }

  func performAction(action: Action) {
    actionPerformedSubject.send(action)
  }

  // Outputs

  var sendMessageTapped: AnyPublisher<(), Never> { sendCreatorMessageSubject.eraseToAnyPublisher() }
  var actionPerformed: AnyPublisher<Action, Never> { actionPerformedSubject.eraseToAnyPublisher() }

  // Helpers

  var primaryAction: PPOProjectCardViewModel.Action {
    let (primary, _) = actions
    return primary
  }

  var secondaryAction: PPOProjectCardViewModel.Action? {
    let (_, secondary) = actions
    return secondary
  }

  // Types

  enum Action: Identifiable {
    case confirmAddress
    case editAddress
    case completeSurvey
    case fixPayment
    case authenticateCard

    // TODO: Localize
    var label: String {
      switch self {
      case .confirmAddress:
        "Confirm"
      case .editAddress:
        "Edit"
      case .completeSurvey:
        "Complete survey"
      case .fixPayment:
        "Fix payment"
      case .authenticateCard:
        "Authenticate card"
      }
    }

    var style: Style {
      switch self {
      case .confirmAddress:
        .green
      case .editAddress:
        .black
      case .completeSurvey:
        .green
      case .fixPayment:
        .red
      case .authenticateCard:
        .red
      }
    }

    enum Style: Identifiable {
      case green
      case red
      case black

      var id: String {
        switch self {
        case .green: "green"
        case .red: "red"
        case .black: "black"
        }
      }
    }

    var id: String {
      "\(label) \(style.id)"
    }
  }

  struct Alert: Identifiable {
    let type: AlertType
    let icon: AlertIcon
    let message: String

    var id: String {
      "\(type)-\(icon)-\(message)"
    }

    enum AlertType: Identifiable {
      case time
      case alert

      var id: String {
        switch self {
        case .time:
          "time"
        case .alert:
          "alert"
        }
      }
    }

    enum AlertIcon: Identifiable {
      case warning
      case alert

      var id: String {
        switch self {
        case .warning:
          "warning"
        case .alert:
          "alert"
        }
      }
    }
  }
}
