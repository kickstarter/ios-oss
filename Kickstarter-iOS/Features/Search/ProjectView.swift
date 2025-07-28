import SwiftUI

struct ProjectView: View {
  @State var bottomOverlayHeight: CGFloat = 0
  @Binding var showProjectView: Bool
  
  var body: some View {
    GeometryReader { geometry in
      ScrollView(.vertical) {
        VStack(spacing: 0) {
          ProjectVideoView()
            .frame(height: geometry.size.height / 2)
          
          ProjectInfoView()
          
          Divider()
            .padding()
          
          ProjectRewards()
          
          Divider()
            .padding()
        }
        .padding(.bottom, bottomOverlayHeight)
      }
      .overlay {
        // MARK: Down Arrow Icon
        VStack {
          HStack {
              Image(systemName: "chevron.down.circle.fill")
                .renderingMode(.template)
                .foregroundColor(.white)
                .font(.largeTitle)
                .opacity(0.75)
                .accessibilityLabel("Bookmark")
                .accessibilityHint("Bookmarks this campaign.")
                .accessibilityAddTraits(.isButton)
                .accessibilityRemoveTraits(.isImage)
                .onTapGesture {
                  showProjectView.toggle()
                }
            
            Spacer()
          }
          .padding(20)
          .padding(.top)
          
          Spacer()
        }
      }
      .safeAreaInset(edge: .bottom) {
        VStack {
          Button {
            
          } label: {
            Text("Back this project")
              .frame(maxWidth: .infinity)
              .padding(.vertical)
              .foregroundColor(.white)
              .background(
                .black,
                in: RoundedRectangle(
                  cornerRadius: 10,
                  style: .continuous
                )
              )
          }
        }
        .padding()
        .padding(.bottom)
        .background(.white)
        .clipShape(UnevenRoundedRectangle(topLeadingRadius: Constants.cardCornerRadius, topTrailingRadius: Constants.cardCornerRadius))
      }
      .edgesIgnoringSafeArea(.bottom)
      .scrollIndicators(.hidden)
    }
    .ignoresSafeArea(edges: .all)
  }
}

private enum Constants {
  static let localTestVideoUrl: URL = Bundle.main.url(forResource: "test", withExtension: "MP4")!
  static let cardCornerRadius: CGFloat = 15
  static let infoOverlayPadding: CGFloat = 10
  static let infoOverlayBackgroundColor: Color = Color.black.opacity(0.5)
  static let infoOverlaySpacing: CGFloat = 10
  static let infoOverlayVerticalPadding: CGFloat = 8
  static let infoOverlayCornerRadius: CGFloat = 15
  static let infoOverlayGradient: Gradient = Gradient(colors: [Color.black.opacity(0), Color.black])
}

@ViewBuilder
func ProjectVideoView() -> some View {
  VStack {
    LoopingVideoPlayerSearchCardView(url: Constants.localTestVideoUrl)
      .overlay(ProjectVideoViewOverlay(), alignment: .bottom)
      .clipShape(UnevenRoundedRectangle(topLeadingRadius: Constants.cardCornerRadius, topTrailingRadius: Constants.cardCornerRadius))
  }
  .frame(maxWidth: .infinity, maxHeight: .infinity)
}

@ViewBuilder
func ProjectVideoViewOverlay() -> some View  {
  VStack {
    Spacer()
    
    // MARK: - Info Campaign Info
    HStack {
      HStack {
        Image(systemName: "play.fill")
          .renderingMode(.template)
          .foregroundColor(.white)
          .font(.title3)
          .accessibilityLabel("play button.")
          .accessibilityHint("play this project's video.")
          .accessibilityAddTraits(.isButton)
          .accessibilityRemoveTraits(.isImage)
        
          Text("3:24")
            .foregroundColor(.white)
            .font(.caption)
      }
      .padding(Constants.infoOverlayPadding)
      .background(Constants.infoOverlayBackgroundColor)
      .cornerRadius(Constants.infoOverlayCornerRadius)
      
      Spacer()
    }
    .padding()
  }
}

@ViewBuilder
func ProjectInfoView() -> some View {
  VStack(alignment: .leading, spacing: 10) {
    Text("HiDock P1 & P1 mini-AI Voice Recorder for Bluetooth Earphone")
      .font(.title3)
    
    HStack(spacing: 10) {
      Image(systemName: "circle.fill")
        .renderingMode(.template)
        .foregroundStyle(.teal)
        .font(.title3)
      
      Text("HiDock")
        .font(.subheadline)
      
      Text("Backer favorite")
        .font(.caption)
        .foregroundColor(.orange)
        .padding(2)
        .background(Color.orange.opacity(0.2))
        .cornerRadius(5)
      
      Text("Repeat creator")
        .font(.caption)
        .foregroundColor(.purple)
        .padding(2)
        .background(Color.purple.opacity(0.2))
        .cornerRadius(5)
      
    }
    
    Text("Record with Bluetooth Earphones | Studio-level ECM Mic | Lightening-Fast Audio Transfer | Lifetime Free Transcription")
      .font(.caption)
      .foregroundColor(.gray)
    
    HStack {
      VStack(alignment: .leading, spacing: 5) {
        Text("$812,928 pledged")
          .font(.headline)
        Text("$10,015 goal • 15 days to go • 7,001 backers")
          .font(.caption)
          .foregroundColor(.gray)
      }
      
      Spacer()
      
      Image(systemName: "circle")
        .renderingMode(.template)
        .foregroundStyle(.green)
        .font(.largeTitle)
      
    }
  }
  .padding()
  .frame(maxWidth: .infinity, maxHeight: .infinity)
  .background(.white)
  .clipShape(UnevenRoundedRectangle(topLeadingRadius:  Constants.cardCornerRadius, topTrailingRadius: Constants.cardCornerRadius))
}

@ViewBuilder
func ProjectRewards() -> some View {
  VStack(alignment: .leading) {
    HStack {
      Text("Rewards")
        .font(.headline)
      
      Spacer()
    }
    .padding(.horizontal)
    
    ScrollView(.horizontal) {
      HStack {
        ForEach(0..<5) { _ in
          ProjectRewardCard()
        }
      }
      .padding(.trailing)
    }
    .scrollIndicators(.hidden)
    .padding(.leading)
    
    HStack {
      Spacer()
      
      Button {
        
      } label: {
        Text("See all rewards")
          .frame(maxWidth: .infinity)
          .padding(.vertical)
          .foregroundColor(.black)
          .background(
            .gray.opacity(0.5),
            in: RoundedRectangle(
              cornerRadius: 10,
              style: .continuous
            )
          )
      }
      .padding(.top)
      
      Spacer()
    }
    .padding(.horizontal)
  }
}

@ViewBuilder
func ProjectRewardCard() -> some View {
  VStack(alignment: .leading, spacing: 10) {
    Color.mint
      .clipShape(RoundedRectangle(cornerRadius: 10))
      .frame(width: 175, height: 100)
    
    Text("[Early Bird] HiDock P1 * 2")
      .font(.caption)
      .foregroundColor(.gray)
      .padding(.leading, 10)
  }
}

#Preview {
  ProjectView(showProjectView: .constant(false))
}
