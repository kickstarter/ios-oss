//
//  PPOProjectCardView.swift
//  Kickstarter-iOS
//
//  Created by Steve Streza on 7/29/24.
//  Copyright © 2024 Kickstarter. All rights reserved.
//

import Foundation
import SwiftUI

fileprivate enum Constants {
  static let cornerSize: CGFloat = 8
  static let borderColor = UIColor.ksr_support_300
  static let borderWidth: CGFloat = 1
  static let badgeAlignment = Alignment(horizontal: .trailing, vertical: .top)
  static let badgeColor = UIColor.hex(0xff3B30)
  static let badgeSize: CGFloat = 16
}

protocol PPOAlertFlagData: Identifiable {
  var alertType: PPOAlertFlag.AlertType { get }
  var alertLevel: PPOAlertFlag.AlertLevel { get }
  var message: String { get }
}

protocol PPOProjectCardViewData {
  associatedtype Flag: PPOAlertFlagData
  var flags: [Flag] { get }
}

struct PPOProjectCardView<ViewData: PPOProjectCardViewData>: View {
  let viewData: ViewData
  
    var body: some View {
      let rect = RoundedRectangle(cornerSize: CGSize(width: Constants.cornerSize, height: Constants.cornerSize))
      return VStack {
        HStack {
          VStack(alignment: .leading) {
            ForEach(viewData.flags) { flag in
              PPOAlertFlag(alertType: flag.alertType, alertLevel: flag.alertLevel, message: flag.message)
            }
          }
          Spacer()
        }
//
//        Text("Two ghostly white figures in coveralls and helmets are softly dancing billions upon billions the only home we've ever known the carbon in our apple pies prime number Vangelis. From which we spring with pretty stories for which there's little good evidence astonishment star stuff harvesting star light a very small stage in a vast cosmic arena a mote of dust suspended in a sunbeam. Realm of the galaxies as a patch of light something incredible is waiting to be known encyclopaedia galactica network of wormholes courage of our questions and billions upon billions upon billions upon billions upon billions upon billions upon billions.")
      }
      .padding()
      .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
      .clipShape(rect)
      .overlay(rect.strokeBorder(Color(uiColor: Constants.borderColor), lineWidth: Constants.borderWidth))
      .overlay(alignment: Constants.badgeAlignment, content: {
        Circle()
          .fill(Color(uiColor: Constants.badgeColor))
          .frame(width: Constants.badgeSize, height: Constants.badgeSize)
          .offset(x: Constants.badgeSize / 2, y: -(Constants.badgeSize / 2))
      })
      .padding(16)
    }
}

#Preview("Basic card") {
  struct ViewData: PPOProjectCardViewData {
    struct Flag: PPOAlertFlagData {
      let alertType: PPOAlertFlag.AlertType
      let alertLevel: PPOAlertFlag.AlertLevel
      let message: String
      
      var id: String {
        "\(alertType.id) \(alertLevel.id) \(message)"
      }
    }
    
    var flags: [Flag]
  }
  
  return PPOProjectCardView(viewData: ViewData(
    flags: [
      ViewData.Flag(alertType: .limitedTime, alertLevel: .informational, message: "Hurry up"),
      ViewData.Flag(alertType: .notice, alertLevel: .serious, message: "We will delete your account")
    ]
  ))
}
