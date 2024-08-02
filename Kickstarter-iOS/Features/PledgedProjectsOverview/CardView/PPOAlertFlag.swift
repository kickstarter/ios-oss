//
//  PPOAlertFlag.swift
//  Kickstarter-iOS
//
//  Created by Steve Streza on 7/30/24.
//  Copyright © 2024 Kickstarter. All rights reserved.
//

import Library
import SwiftUI

struct PPOAlertFlag: View {
  let alertType: AlertType
  let alertLevel: AlertLevel
  let message: String

  var image: Image {
    switch alertType {
    case .limitedTime:
      Image(Constants.limitedTimeImage)
    case .notice:
      Image(Constants.noticeImage)
    }
  }

  var foregroundColor: Color {
    switch alertLevel {
    case .informational:
      Color(uiColor: Constants.informationalForegroundColor)
    case .serious:
      Color(uiColor: Constants.seriousForegroundColor)
    }
  }

  var backgroundColor: Color {
    switch alertLevel {
    case .informational:
      Color(uiColor: Constants.informationalBackgroundColor)
    case .serious:
      Color(uiColor: Constants.seriousBackgroundColor)
    }
  }

  var body: some View {
    HStack {
      image
        .renderingMode(.template)
        .aspectRatio(contentMode: .fit)
        .foregroundStyle(foregroundColor)
        .frame(width: Constants.imageSize, height: Constants.imageSize)
      Spacer()
        .frame(width: Constants.spacerWidth)
      Text(message)
        .font(Font(Constants.font))
        .foregroundStyle(foregroundColor)
    }
    .padding(Constants.padding)
    .background(backgroundColor)
    .clipShape(RoundedRectangle(cornerSize: CGSize(width: Constants.cornerRadius, height: Constants.cornerRadius)))
  }

  enum AlertType: Identifiable {
    case limitedTime
    case notice

    var id: String {
      switch self {
      case .limitedTime:
        "limitedTime"
      case .notice:
        "notice"
      }
    }
  }

  enum AlertLevel: Identifiable {
    case informational
    case serious

    var id: String {
      switch self {
      case .informational:
        "informational"
      case .serious:
        "serious"
      }
    }
  }

  fileprivate enum Constants {
    static let informationalForegroundColor = UIColor.ksr_support_400
    static let informationalBackgroundColor = UIColor.ksr_celebrate_100

    static let seriousForegroundColor = UIColor.hex(0x73140D)
    static let seriousBackgroundColor = UIColor.hex(0xFEF2F1)

    static let limitedTimeImage = ImageResource.iconTimer
    static let noticeImage = ImageResource.iconExclamation

    static let imageSize: CGFloat = 18
    static let spacerWidth: CGFloat = 4
    static let cornerRadius: CGFloat = 6
    static let font = UIFont.ksr_caption1().bolded
    static let padding = EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 8)
  }
}

#Preview("Stack of flags") {
  VStack(alignment: .leading, spacing: 8) {
    PPOAlertFlag(alertType: .limitedTime, alertLevel: .informational, message: "Address locks in 8 hours")
    PPOAlertFlag(alertType: .notice, alertLevel: .informational, message: "Survey available")
    PPOAlertFlag(alertType: .notice, alertLevel: .serious, message: "Payment failed")
    PPOAlertFlag(alertType: .limitedTime, alertLevel: .serious, message: "Pledge will be dropped in 6 days")
    PPOAlertFlag(alertType: .notice, alertLevel: .serious, message: "Card needs authentication")
  }
}
