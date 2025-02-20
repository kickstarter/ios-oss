import Foundation
import Library
import SwiftUI

struct PPOProjectCreator: View {
  let creatorName: String
  @SwiftUI.Environment(\.sizeCategory) var sizeCategory

  var body: some View {
    HStack(alignment: .firstTextBaseline) {
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

      Text(Strings.Send_a_message())
        .font(Font(PPOStyles.subtitle.font))
        .background(Color(PPOStyles.background))
        .foregroundStyle(Color(Constants.sendMessageColor))
        .frame(alignment: Constants.buttonAlignment)
        .lineLimit(nil)

      Spacer()
        .frame(width: Constants.spacerWidth)

      Image("chevron-right")
        .resizable()
        .scaledToFit()
        .frame(width: Constants.chevronSize, height: Constants.chevronSize)
        .offset(Constants.chevronOffset)
        .background(Color(PPOStyles.background))
        .foregroundStyle(Color(Constants.sendMessageColor))
    }
    .frame(maxWidth: .infinity)
  }

  private enum Constants {
    static let chevronSize: CGFloat = 10
    static let chevronOffset = CGSize(width: 0, height: 2)
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
