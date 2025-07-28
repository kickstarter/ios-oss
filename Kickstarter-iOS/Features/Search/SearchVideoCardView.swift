import AVKit
import Library
import SwiftUI

private enum Constants {
  static let localTestVideoUrl: URL = Bundle.main.url(forResource: "test", withExtension: "MP4")!
  static let cardCornerRadius: CGFloat = 15
  static let shadowCornerRadius: CGFloat = 15
  static let categoryCornerRadius: CGFloat = 15
  static let categoryPadding: CGFloat = 10
  static let categoryBackgroundColor: Color = Color.black.opacity(0.5)
  static let infoOverlaySpacing: CGFloat = 10
  static let infoOverlayVerticalPadding: CGFloat = 8
  static let infoOverlayCornerRadius: CGFloat = 10
  static let infoOverlayGradient: Gradient = Gradient(colors: [Color.black.opacity(0), Color.black])
}

struct SearchVideoCardView: View {
  var body: some View {
    VStack {
      LoopingVideoPlayerSearchCardView(url: Constants.localTestVideoUrl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(InfoOverlayView(), alignment: .bottom)
        .clipShape(RoundedRectangle(cornerRadius: Constants.cardCornerRadius))
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .shadow(radius: Constants.shadowCornerRadius)
  }
}

@ViewBuilder
func InfoOverlayView() -> some View  {
  VStack {
    // MARK: Bookmark Icon
    HStack {
      Spacer()
      
      if let image = image(named: "icon--bookmark") {
        Image(uiImage: image)
          .renderingMode(.template)
          .foregroundColor(.white)
          .accessibilityLabel("Bookmark")
          .accessibilityHint("Bookmarks this campaign.")
          .accessibilityAddTraits(.isButton)
          .accessibilityRemoveTraits(.isImage)
      }
    }
    .padding()
    
    Spacer()
    
    // MARK: - Info Campaign Info
    HStack {
      VStack(alignment: .leading, spacing: Constants.infoOverlaySpacing) {
        Text("Hardware")
          .foregroundColor(.white)
          .font(.caption)
          .padding(Constants.categoryPadding)
          .background(Constants.categoryBackgroundColor)
          .cornerRadius(Constants.categoryCornerRadius)
        
        Text("This is a - Test project name")
          .foregroundColor(.white)
          .font(.headline)
        
        Text("Some company • 2 days left • $1987 raised")
          .foregroundColor(.white)
          .font(.subheadline)
      }
      .padding(.vertical, Constants.infoOverlayVerticalPadding)
      .cornerRadius(Constants.infoOverlayCornerRadius)
      
      Spacer()
      
      // Progress Indicator
    }
    .padding()
    .background(
      LinearGradient(
        gradient: Constants.infoOverlayGradient,
        startPoint: .top,
        endPoint: .bottom
      )
    )
  }
}

struct SearchVideoCardView_Previews: PreviewProvider {
  static var previews: some View {
//      SearchVideoCardView(videoURL: Bundle.main.url(forResource: "sample", withExtension: "mov")!, overlayText: "Your Text Here")
    SearchVideoCardView()
  }
}

// MARK: - FullScreenLoopingVideoPlayerView
/// Custom video player implementation so that it can fill the card completelly without the black bars on the edges that the native player automatically adds. 
struct LoopingVideoPlayerSearchCardView: UIViewControllerRepresentable {
  let url: URL

  func makeUIViewController(context _: Context) -> UIViewController {
    let controller = UIViewController()
    let player = AVPlayer(url: url)
    let playerLayer = AVPlayerLayer(player: player)

    playerLayer.videoGravity = .resizeAspectFill
    player.actionAtItemEnd = .none
    player.volume = 0
    

    playerLayer.frame = UIScreen.main.bounds
    controller.view.layer.addSublayer(playerLayer)

    // Looping logic
    NotificationCenter.default.addObserver(
      forName: .AVPlayerItemDidPlayToEndTime,
      object: player.currentItem,
      queue: .main
    ) { _ in
      player.seek(to: .zero)
      player.play()
    }

    player.play()
    return controller
  }

  func updateUIViewController(_: UIViewController, context _: Context) {}
}
