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
          .clipShape(Constants.imageShape)
          .aspectRatio(Constants.imageAspectRatio, contentMode: .fit)
          .frame(width: Constants.imageWidth)
        Spacer()
          .frame(width: Constants.spacing)
        VStack {
          Text(title)
            .font(Font(Constants.titleFont))
            .frame(maxWidth: .infinity, alignment: .leading)
            .lineLimit(2)
          Text("$50.00 pledged")
            .font(Font(Constants.subtitleFont))
            .foregroundStyle(Color(Constants.subtitleTextColor))
            .frame(maxWidth: .infinity, alignment: .leading)
            .lineLimit(1)
        }
      }
      .fixedSize(horizontal: false, vertical: true)
      .frame(maxWidth: .infinity)
  }
  
  private enum Constants {
    static let imageShape = RoundedRectangle(cornerRadius: 4)
    static let imageAspectRatio: CGFloat = 16/9
    static let imageWidth: CGFloat = 85
    static let spacing: CGFloat = 8
    static let titleFont = UIFont.ksr_caption1().bolded
    static let subtitleFont = UIFont.ksr_footnote()
    static let subtitleTextColor = UIColor.ksr_support_400
  }
}

#Preview {
  return VStack {
    PPOProjectDetails(imageUrl: URL(string: "http:///")!, title: "Sugardew Island - Your cozy farm shop let’s pretend this is a way way way longer title")
    PPOProjectDetails(imageUrl: URL(string: "http:///")!, title: "One line")
  }
  .padding(28)
}
