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
  static let spacing: CGFloat = 12
  static let outerPadding: CGFloat = 16
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
  
  private var cardRectangle: RoundedRectangle {
    RoundedRectangle(cornerSize: CGSize(width: Constants.cornerSize, height: Constants.cornerSize))
  }
  
    var body: some View {
      VStack(spacing: Constants.spacing) {
        HStack {
          VStack(alignment: .leading) {
            ForEach(viewData.flags) { flag in
              PPOAlertFlag(alertType: flag.alertType, alertLevel: flag.alertLevel, message: flag.message)
            }
          }
          Spacer()
        }
        .padding([.horizontal, .top])

        PPOProjectDetails(imageUrl: URL(string: "http://localhost/")!, title: "Sugardew Island - Your cozy farm shop let’s pretend this is a way, way longer title")
          .padding([.horizontal])

        Divider()
        
        PPOProjectCreator(creatorName: "rokaplay truncate if longer than")
          .padding([.horizontal])

        Divider()
        
        PPOAddressSummary(address: """
          Firsty Lasty
          123 First Street, Apt #5678
          Los Angeles, CA 90025-1234
          United States
        """)
        .padding([.horizontal])

        HStack   {
          Button("Edit") {
            // TODO
          }
          .buttonStyle(BlackButtonStyle())

          Button("Complete") {
            // TODO
          }
          .buttonStyle(GreenButtonStyle())
        }
        .padding([.horizontal, .bottom])
      }
      .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
      .clipShape(cardRectangle)
      .overlay(cardRectangle.strokeBorder(Color(uiColor: Constants.borderColor), lineWidth: Constants.borderWidth))
      .overlay(alignment: Constants.badgeAlignment, content: {
        Circle()
          .fill(Color(uiColor: Constants.badgeColor))
          .frame(width: Constants.badgeSize, height: Constants.badgeSize)
          .offset(x: Constants.badgeSize / 2, y: -(Constants.badgeSize / 2))
      })
      .padding(Constants.outerPadding)
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
  
  return  PPOProjectCardView(viewData: ViewData(
    flags: [
      ViewData.Flag(alertType: .limitedTime, alertLevel: .informational, message: "Survey available"),
      ViewData.Flag(alertType: .notice, alertLevel: .serious, message: "Pledge will be dropped in 6 days")
    ]
  ))
}
