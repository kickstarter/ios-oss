import Foundation
import Library
import SwiftUI

struct PPOProjectCreator: View {
  let creatorName: String
  @SwiftUI.Environment(\.sizeCategory) var sizeCategory

  var body: some View {
    HStack(alignment: .center) {
      Text("\(Strings.project_menu_created_by()) **\(self.creatorName)**")
        .font(Font(PPOStyles.subtitle.font))
        .background(Color(PPOStyles.background))
        .foregroundStyle(Color(PPOStyles.subtitle.color))
        .frame(
          maxWidth: Constants.labelMaxWidth,
          alignment: Constants.labelAlignment
        )
        .lineLimit(
          self.sizeCategory > .extraExtraExtraLarge ?
            Constants.largeTextLineLimit :
            Constants.textLineLimit
        )

      Image(PPOStyles.sendMessageImage)
        .resizable()
        .scaledToFit()
        .frame(width: Constants.messageIconSize, height: Constants.messageIconSize)
        .background(Color(PPOStyles.background))
        .foregroundStyle(Color(Constants.sendMessageColor))
    }
    .frame(maxWidth: .infinity)
  }

  private enum Constants {
    static let messageIconSize: CGFloat = 24
    static let spacerWidth = Styles.grid(1)
    static let textLineLimit = 1
    static let largeTextLineLimit = 3
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
