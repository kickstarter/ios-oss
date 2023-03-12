import Library
import SwiftUI

@available(iOS 15.0, *)
struct MessageBannerView: View {
  @ObservedObject var viewModel: MessageBannerViewViewModel

  var body: some View {
    RoundedRectangle(cornerRadius: 4)
      .foregroundColor(viewModel.bannerBackgroundColor)
      .overlay {
        Label(viewModel.bannerMessage, image: viewModel.iconImageName)
          .font(Font(UIFont.ksr_subhead()))
          .foregroundColor(viewModel.messageTextColor)
          .lineLimit(3)
          .multilineTextAlignment(viewModel.messageTextAlignment)
          .padding()
      }
      .padding()
  }
}

struct MessageBannerView_Previews: PreviewProvider {
  static var previews: some View {
    let viewModel = MessageBannerViewViewModel((.success, Strings.Got_it_your_changes_have_been_saved()))
    if #available(iOS 15, *) {
      MessageBannerView(viewModel: viewModel)
    }
  }
}
