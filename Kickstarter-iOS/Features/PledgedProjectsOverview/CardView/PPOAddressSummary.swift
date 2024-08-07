//
//  PPOAddressSummary.swift
//  Kickstarter-Framework-iOS
//
//  Created by Steve Streza on 8/7/24.
//  Copyright © 2024 Kickstarter. All rights reserved.
//

import Foundation
import SwiftUI

struct PPOAddressSummary: View {
  let address: String
  
  var body: some View {
    HStack(alignment: .firstTextBaseline) {
        Text("Shipping address")
          .font(Font(Constants.labelFont))
          .foregroundStyle(Color(Constants.labelColor))
          .frame(width: Constants.labelWidth, alignment: .leading)
          .multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/)

        Text(address)
          .multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/)
          .font(Font(Constants.addressFont))
          .foregroundStyle(Color(Constants.addressColor))
          .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
      }
      .frame(maxWidth: .infinity)
  }
  
  private enum Constants {
    static let labelWidth: CGFloat = 85
    static let labelFont = UIFont.ksr_caption1().bolded
    static let labelColor = UIColor.ksr_black
    static let addressFont = UIFont.ksr_caption1()
    static let addressColor = UIColor.ksr_black
  }
}

#Preview {
  return VStack(spacing: 28) {
    PPOAddressSummary(address: """
      Firsty Lasty
      123 First Street, Apt #5678
      Los Angeles, CA 90025-1234
      United States
    """)
    }
  .padding(28)
}
