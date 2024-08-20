import Foundation
import Library
import SwiftUI

struct PPOProjectCreator: View {
  let creatorName: String
  @EnvironmentObject var style: PPOCardStyles

  var body: some View {
    HStack(alignment: .firstTextBaseline) {
      // TODO: Localize
      Text("Created by **\(self.creatorName)**")
        .font(Font(style.projectCreator.createdByFont))
        .foregroundStyle(Color(style.projectCreator.createdByColor))
        .frame(maxWidth: style.projectCreator.labelMaxWidth, alignment: style.projectCreator.labelAlignment)
        .lineLimit(style.projectCreator.textLineLimit)

      Button(action: {
        // TODO: Action
      }, label: {
        // TODO: Localize
        Text("Send a message")
      })
      .font(Font(style.projectCreator.sendMessageFont))
      .foregroundStyle(Color(style.projectCreator.sendMessageColor))
      .frame(alignment: style.projectCreator.buttonAlignment)
      .lineLimit(style.projectCreator.textLineLimit)

      Spacer()
        .frame(width: style.projectCreator.spacerWidth)

      Image("chevron-right")
        .resizable()
        .scaledToFit()
        .frame(width: style.projectCreator.chevronSize, height: style.projectCreator.chevronSize)
        .offset(style.projectCreator.chevronOffset)
        .foregroundStyle(Color(style.projectCreator.sendMessageColor))
    }
    .frame(maxWidth: .infinity)
  }
}

#Preview {
  VStack(spacing: 28) {
    PPOProjectCreator(creatorName: "Disco Dave")
    PPOProjectCreator(creatorName: "A much longer name")
    PPOProjectCreator(creatorName: "rokaplay truncate if longer than")
  }
  .padding(28)
  .environmentObject(PPOCardStyles())
}
