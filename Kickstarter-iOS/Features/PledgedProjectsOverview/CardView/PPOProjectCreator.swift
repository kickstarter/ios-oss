import Foundation
import SwiftUI

struct PPOProjectCreator: View {
  let creatorName: String

  var body: some View {
    HStack(alignment: .firstTextBaseline) {
      // TODO: Localize
      Text("Created by **\(self.creatorName)**")
        .font(Font(Constants.createdByFont))
        .foregroundStyle(Color(Constants.createdByColor))
        .frame(maxWidth: .infinity, alignment: .leading)
        .lineLimit(1)

      // TODO: Localize
      Text("Send a message")
        .font(Font(Constants.sendMessageFont))
        .foregroundStyle(Color(Constants.sendMessageColor))
        .frame(alignment: .trailing)
        .lineLimit(1)

      Spacer()
        .frame(width: 6)

      Image("chevron-right")
        .resizable()
        .scaledToFit()
        .frame(width: 10, height: 10)
        .offset(y: 2)
        .foregroundStyle(Color(Constants.sendMessageColor))
    }
    .frame(maxWidth: .infinity)
  }

  private enum Constants {
    static let createdByFont = UIFont.ksr_caption2()
    static let createdByColor = UIColor.ksr_support_400
    static let sendMessageFont = UIFont.ksr_caption2()
    static let sendMessageColor = UIColor.ksr_create_700
  }
}

#Preview {
  VStack(spacing: 28) {
    PPOProjectCreator(creatorName: "Disco Dave")
    PPOProjectCreator(creatorName: "A much longer name")
    PPOProjectCreator(creatorName: "rokaplay truncate if longer than")
  }
  .padding(28)
}
