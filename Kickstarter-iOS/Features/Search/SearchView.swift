import SwiftUI

@available(iOS 17.0, *)
struct SearchView: View {
  // MARK: - Properties

  @Environment(\.colorScheme) private var scheme
  @Namespace private var animation
  @State private var searchText: String = ""
  @State private var activeTab: Tab = .forYou
  @State private var showProjectView = false
  @FocusState private var isSearching: Bool

  var body: some View {
    ScrollView(.vertical) {
      LazyVStack(spacing: 15) {
        ForEach(1..<11) { _ in
          SearchVideoCardView()
            .frame(width: 350, height: 400)
            .onTapGesture {
              showProjectView = true
            }
        }
      }
      .safeAreaPadding(15)
      .safeAreaInset(edge: .top, spacing: 0) {
        self.ExpandableNavigationBar()
      }
      .animation(.snappy(duration: 0.3, extraBounce: 0), value: self.isSearching)
    }
    .scrollTargetBehavior(CustomScrollTargetBehaviour())
    .background(.gray.opacity(0.15))
    .contentMargins(.top, 190, for: .scrollIndicators)
    .fullScreenCover(isPresented: $showProjectView) {
      ProjectView(showProjectView: $showProjectView)
    }
  }

  // MARK: -  Expandable Navigation Bar

  @ViewBuilder
  func ExpandableNavigationBar(_ title: String = "Kickstarter") -> some View {
    GeometryReader { proxy in
      let minY = proxy.frame(in: .scrollView(axis: .vertical)).minY
      let scrollViewHeight = proxy.bounds(of: .scrollView(axis: .vertical))?.height ?? 0
      let scaleProgress = minY > 0 ? 1 + (max(min(minY / scrollViewHeight, 1), 0) * 0.5) : 1
      let progress = self.isSearching ? 1 : max(min(-minY / 70, 1), 0)

      VStack(spacing: 10) {
        // MARK: - Title

        Text(title)
          .font(.largeTitle.bold())
          .scaleEffect(scaleProgress, anchor: .topLeading)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.bottom, 10)

        // MARK: - Search Bar

        HStack(spacing: 12) {
          Image(systemName: "magnifyingglass")
            .font(.title3)

          TextField("Search", text: self.$searchText)
            .focused(self.$isSearching)

          if self.isSearching {
            Button(action: {
              self.isSearching = false
            }, label: {
              Image(systemName: "xmark")
                .font(.title3)
            })
            .transition(.asymmetric(insertion: .push(from: .bottom), removal: .push(from: .top)))
          }
        }
        .foregroundStyle(Color.primary)
        .padding(.vertical, 10)
        .padding(.horizontal, 15 - (progress * 15))
        .frame(height: 45)
        .clipShape(.capsule)
        .background {
          RoundedRectangle(cornerRadius: 25 - (progress * 25))
            .fill(.background)
            .shadow(color: .gray.opacity(0.25), radius: 5, x: 0, y: 5)
            .padding(.top, -progress * 190)
            .padding(.bottom, -progress * 65)
            .padding(.horizontal, -progress * 15)
        }

        // MARK: - CategoryTabsView

        ScrollView(.horizontal) {
          HStack(spacing: 12) {
            ForEach(Tab.allCases, id: \.rawValue) { tab in
              Button(action: {
                withAnimation(.snappy) {
                  self.activeTab = tab
                }
              }) {
                Text(tab.rawValue)
                  .font(.callout)
                  .foregroundStyle(
                    self.activeTab == tab ? (self.scheme == .dark ? .black : .white) : Color
                      .primary
                  )
                  .padding(.vertical, 8)
                  .padding(.horizontal, 15)
                  .background {
                    if self.activeTab == tab {
                      Capsule()
                        .fill(Color.primary)
                        .matchedGeometryEffect(id: "ACTIVETAB", in: self.animation)
                    } else {
                      Capsule()
                        .fill(.background)
                    }
                  }
              }
              .buttonStyle(.plain)
            }
          }
        }
        .frame(height: 50)
      }
      .padding(.top, 25)
      .safeAreaPadding(.horizontal, 15)
      .offset(y: minY < 0 || self.isSearching ? -minY : 0)
      .offset(y: -progress * 65)
    }
    .frame(height: 190)
    .padding(.bottom, 10)
    .padding(.bottom, self.isSearching ? -65 : 0)
  }
}

@available(iOS 17.0, *)
struct CustomScrollTargetBehaviour: ScrollTargetBehavior {
  func updateTarget(_ target: inout ScrollTarget, context _: TargetContext) {
    if target.rect.minY < 70 {
      if target.rect.minY < 35 {
        target.rect.origin = .zero
      } else {
        target.rect.origin = .init(x: 0, y: 70)
      }
    }
  }
}

#Preview {
  if #available(iOS 17.0, *) {
    SearchView()
  }
}
