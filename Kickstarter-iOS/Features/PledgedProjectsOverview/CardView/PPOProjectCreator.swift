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
        .font(Font(self.style.projectCreator.createdByFont))
        .foregroundStyle(Color(self.style.projectCreator.createdByColor))
        .frame(
          maxWidth: self.style.projectCreator.labelMaxWidth,
          alignment: self.style.projectCreator.labelAlignment
        )
        .lineLimit(self.style.projectCreator.textLineLimit)

      Button(action: {
        // TODO: Action
      }, label: {
        // TODO: Localize
        Text("Send a message")
      })
      .font(Font(self.style.projectCreator.sendMessageFont))
      .foregroundStyle(Color(self.style.projectCreator.sendMessageColor))
      .frame(alignment: self.style.projectCreator.buttonAlignment)
      .lineLimit(self.style.projectCreator.textLineLimit)

      Spacer()
        .frame(width: self.style.projectCreator.spacerWidth)

      Image("chevron-right")
        .resizable()
        .scaledToFit()
        .frame(width: self.style.projectCreator.chevronSize, height: self.style.projectCreator.chevronSize)
        .offset(self.style.projectCreator.chevronOffset)
        .foregroundStyle(Color(self.style.projectCreator.sendMessageColor))
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
