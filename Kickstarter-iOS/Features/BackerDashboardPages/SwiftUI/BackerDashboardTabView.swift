import Library
import SwiftUI

@available(iOS 15.0, *)
struct BackerDashboardTabBarView: View {
  @State var currentTab: BackerDashboardTab = .backed
  @State var backedProjects: Int
  @State var savedProjects: Int

  @Namespace var animation

  var selectTab: (BackerDashboardTab) -> ()

  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 48) {
        TabView(tab: .backed, number: backedProjects)
        TabView(tab: .saved, number: savedProjects)
      }
      .padding(.leading, 21)
    }
  }

  // MARK: @ViewBuilders

  private func TabView(tab: BackerDashboardTab, number: Int) -> some View {
    Button {
      currentTab = tab
      selectTab(currentTab)
    } label: {
      VStack(alignment: .leading) {
        Text("\(number)\n\(tab.rawValue)")
          .font(.system(size: 13))
          .fontWeight(.semibold)
          .multilineTextAlignment(.leading)
          .foregroundColor(currentTab == tab ? .black : .gray)
          .padding(.bottom, 15)

        if currentTab == tab {
          Capsule()
            .fill(.black)
            .matchedGeometryEffect(id: animation.self, in: animation, properties: .frame)
            .frame(height: 2)
        } else {
          Capsule()
            .fill(.clear)
            .frame(height: 2)
        }
      }
      .animation(.spring(), value: currentTab)
    }
  }
}

@available(iOS 15.0, *)
struct BackerDashboardTabBar_Previews: PreviewProvider {
  static var previews: some View {
    BackerDashboardTabBarView(
      backedProjects: 0,
      savedProjects: 0,
      selectTab: { _ in }
    )
    .previewLayout(.sizeThatFits)
  }
}
