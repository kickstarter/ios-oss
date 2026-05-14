import KDS
import SwiftUI

struct VideoFeedProgressBarView: View {
  private enum Constants {
    static let height: CGFloat = 4
    static let scrubHeight: CGFloat = 6
    static let barOpacity: Double = 0.3
    static let expandAnimation: Animation = .easeInOut(duration: 0.15)
    static let collapseAnimation: Animation = .easeInOut(duration: 0.25)
  }

  let player: VideoFeedVideoPlayer

  @State private var isScrubbing = false
  @State private var scrubProgress: Double = 0
  @State private var progressBeforeScrub: Double = 0
  @State private var videoPlayingBeforeScrub = false

  var body: some View {
    let displayProgress = self.isScrubbing ? self.scrubProgress : self.player.progress
    let trackHeight: CGFloat = self.isScrubbing ? Constants.scrubHeight : Constants.height

    GeometryReader { geo in
      ZStack(alignment: .leading) {
        /// Background
        Capsule()
          .fill(Color(Colors.Icon.light.uiColor()).opacity(Constants.barOpacity))
          .frame(height: trackHeight)

        /// Fill
        Capsule()
          .fill(Color(Colors.Icon.light.uiColor()))
          .frame(width: max(0, geo.size.width * displayProgress), height: trackHeight)
      }
      .frame(maxHeight: .infinity, alignment: .center)
      .contentShape(Rectangle())
      .gesture(
        DragGesture(minimumDistance: 0)
          .onChanged { value in
            let progress = min(max(value.location.x / geo.size.width, 0), 1)

            if !self.isScrubbing {
              self.progressBeforeScrub = self.player.progress
              self.videoPlayingBeforeScrub = self.player.isPlaying

              self.player.pause()

              withAnimation(Constants.expandAnimation) {
                self.isScrubbing = true
              }
            }

            self.scrubProgress = progress
          }
          .onEnded { value in
            self.scrubProgress = min(max(value.location.x / geo.size.width, 0), 1)

            self.player.seek(to: self.scrubProgress) { success in
              /// If Seek failed. Revert video back to where it was.
              if !success {
                self.scrubProgress = self.progressBeforeScrub
                self.player.seek(to: self.progressBeforeScrub) { _ in }
              }

              /// Only resume if the video was playing before the scrub started.
              if self.videoPlayingBeforeScrub {
                self.player.play()
              }

              withAnimation(Constants.collapseAnimation) {
                self.isScrubbing = false
              }
            }
          }
      )
    }
    .frame(height: Constants.scrubHeight)
    .animation(Constants.expandAnimation, value: self.isScrubbing)
  }
}
