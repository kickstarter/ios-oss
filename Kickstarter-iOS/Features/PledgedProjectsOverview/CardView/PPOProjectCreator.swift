import Foundation
import Library
import SwiftUI

struct PPOProjectCreator: View {
  let creatorName: String

  var body: some View {
    HStack(alignment: .firstTextBaseline) {
      // TODO: Localize
      Text("Created by **\(self.creatorName)**")
        .font(Font(PPOCardStyles.subtitle.font))
        .foregroundStyle(Color(PPOCardStyles.subtitle.color))
        .frame(
          maxWidth: Constants.labelMaxWidth,
          alignment: Constants.labelAlignment
        )
        .lineLimit(Constants.textLineLimit)

      Button(action: {
        // TODO: Action
      }, label: {
        // TODO: Localize
        Text("Send a message")
      })
      .font(Font(PPOCardStyles.subtitle.font))
      .foregroundStyle(Color(Constants.sendMessageColor))
      .frame(alignment: Constants.buttonAlignment)
      .lineLimit(Constants.textLineLimit)

      Spacer()
        .frame(width: Constants.spacerWidth)

      Image("chevron-right")
        .resizable()
        .scaledToFit()
        .frame(width: Constants.chevronSize, height: Constants.chevronSize)
        .offset(Constants.chevronOffset)
        .foregroundStyle(Color(Constants.sendMessageColor))
    }
    .frame(maxWidth: .infinity)
  }

  private enum Constants {
    static let chevronSize: CGFloat = 10
    static let chevronOffset = CGSize(width: 0, height: 2)
    static let spacerWidth = Styles.grid(1)
    static let textLineLimit = 1
    static let labelMaxWidth = CGFloat.infinity
    static let labelAlignment = Alignment.leading
    static let buttonAlignment = Alignment.trailing
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
