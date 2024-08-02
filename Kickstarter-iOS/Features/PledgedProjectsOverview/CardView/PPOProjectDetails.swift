//
//  PPOProjectDetails.swift
//  Kickstarter-iOS
//
//  Created by Steve Streza on 8/1/24.
//  Copyright © 2024 Kickstarter. All rights reserved.
//

import Foundation
import Kingfisher
import KsApi
import SwiftUI

struct PPOProjectDetails: View {
  let imageUrl: URL
  let title: String
  
  var body: some View {
      HStack {
        AsyncImage(url: imageUrl)
          .clipShape(RoundedRectangle(cornerRadius: 4))
          .aspectRatio(16/9, contentMode: .fit)
          .frame(height: 48)
        Spacer()
          .frame(width: 8)
        VStack {
          Text(title)
            .font(Font(UIFont.ksr_caption1().bolded))
            .frame(maxWidth: .infinity, alignment: .leading)
            .lineLimit(2)
          Text("$50.00 pledged")
            .font(Font(UIFont.ksr_footnote()))
            .foregroundStyle(Color(UIColor.ksr_support_400))
            .frame(maxWidth: .infinity, alignment: .leading)
            .lineLimit(1)
        }
      }
      .fixedSize(horizontal: false, vertical: true)
      .frame(maxWidth: .infinity)
  }
}

#Preview {
  return VStack {
    PPOProjectDetails(imageUrl: URL(string: "http:///")!, title: "Sugardew Island - Your cozy farm shop let’s pretend this is a way way way longer title")
    PPOProjectDetails(imageUrl: URL(string: "http:///")!, title: "One line")
  }
  .padding(28)
}
