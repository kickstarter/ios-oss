import KsApi
import Library
import SwiftUI

struct FilterRootView: View {
  @State var navigationState: [SearchFilterModalType]
  @ObservedObject var searchFilters: SearchFilters

  var onFilter: ((SearchFilterEvent) -> Void)? = nil
  var onSearchedForLocations: ((String) -> Void)? = nil
  var onReset: ((SearchFilterModalType) -> Void)? = nil
  var onResults: (() -> Void)? = nil
  var onClose: (() -> Void)? = nil

  var modalType: SearchFilterModalType {
    self.navigationState.first ?? .allFilters
  }

  init(
    filterType: SearchFilterModalType,
    searchFilters: SearchFilters
  ) {
    if filterType == .allFilters {
      // Show the root view
      self.navigationState = []
    } else {
      self.navigationState = [filterType]
    }

    self.searchFilters = searchFilters
  }

  // MARK: - Subviews

  @ViewBuilder
  var projectStateSection: some View {
    VStack(alignment: .leading, spacing: Constants.sectionSpacing) {
      Text(Strings.Project_status())
        .font(InterFont.headingLG.swiftUIFont())
        .foregroundStyle(Colors.Text.primary.swiftUIColor())
      FlowLayout(spacing: Constants.flowLayoutSpacing) {
        ForEach(self.searchFilters.projectState.stateOptions) { state in
          Button(action: {
            if let action = self.onFilter {
              action(.projectState(state))
            }
          }, label: {
            Text(state.title)
          })
          .buttonStyle(
            SearchFiltersPillStyle(
              isHighlighted: state == self.searchFilters.projectState.selectedProjectState
            )
          )
        }
      }
    }
    .padding(Constants.sectionPadding)
  }

  @ViewBuilder
  var percentRaisedSection: some View {
    NavigationLink(value: SearchFilterModalType.percentRaised) {
      FilterSectionButton(
        title: Strings.Percentage_raised(),
        subtitle:
        self.searchFilters.percentRaised.selectedBucket?.title
      )
    }
    .padding(Constants.sectionPadding)
  }

  @ViewBuilder
  var categorySection: some View {
    NavigationLink(value: SearchFilterModalType.category) {
      FilterSectionButton(
        title: Strings.Category(),
        subtitle: self.searchFilters.category.selectedCategory.name
      )
    }
    .padding(Constants.sectionPadding)
  }

  @ViewBuilder
  var locationSection: some View {
    NavigationLink(value: SearchFilterModalType.location) {
      FilterSectionButton(
        title: Strings.Location(),
        subtitle: self.searchFilters.location.selectedLocation?.displayableName
      )
    }
    .padding(Constants.sectionPadding)
  }

  @ViewBuilder
  var amountRaisedSection: some View {
    NavigationLink(value: SearchFilterModalType.amountRaised) {
      FilterSectionButton(
        title: Strings.Amount_raised(),
        subtitle: self.searchFilters.amountRaised.selectedBucket?.title
      )
    }
    .padding(Constants.sectionPadding)
  }

  @ViewBuilder
  var goalSection: some View {
    NavigationLink(value: SearchFilterModalType.goal) {
      FilterSectionButton(
        title: Strings.Goal(),
        subtitle: self.searchFilters.goal.selectedBucket?.title
      )
    }
    .padding(Constants.sectionPadding)
  }

  @ViewBuilder
  var showOnlySection: some View {
    // This is a modal and will be re-loaded when it's presented again.
    // So this doesn't need to be reactive.
    let loggedIn = AppEnvironment.current.currentUser.isSome
    VStack(alignment: .leading, spacing: Constants.sectionSpacing) {
      Text(Strings.Show_only())
        .font(InterFont.headingLG.swiftUIFont())
      Group {
        if loggedIn {
          Toggle(Strings.Show_only_recommended_for_you(), isOn: self.showRecommended)
        }
        Toggle(Strings.Show_only_projects_we_love(), isOn: self.showProjectsWeLove)
        if loggedIn {
          Toggle(Strings.Show_only_saved_projects(), isOn: self.showSavedProjects)
          Toggle(Strings.Show_only_following(), isOn: self.showFollowing)
        }
      }
      .toggleStyle(.switch)
      .tint(Colors.Text.primary.swiftUIColor())
      .font(InterFont.bodyMD.swiftUIFont())
    }
    .foregroundStyle(Colors.Text.primary.swiftUIColor())
    .padding(Constants.sectionPadding)
  }

  @ViewBuilder
  var percentRaisedModal: some View {
    PercentRaisedView(
      buckets: self.searchFilters.percentRaised.buckets,
      selectedBucket: self.selectedPercentRaisedBucket
    )
  }

  @ViewBuilder
  var categoryModal: some View {
    FilterCategoryView(
      categories: self.searchFilters.category.categories,
      selectedCategory: self.selectedCategory
    )
  }

  @ViewBuilder
  var locationModal: some View {
    LocationView(
      defaultLocations: self.searchFilters.location.defaultLocations,
      suggestedLocations: self.searchFilters.location.suggestedLocations,
      selectedLocation: self.selectedLocation,
      onSearchedForLocations: self.onSearchedForLocations ?? { _ in }
    )
  }

  @ViewBuilder
  var amountRaisedModal: some View {
    AmountRaisedView(
      buckets: self.searchFilters.amountRaised.buckets,
      selectedBucket: self.selectedAmountRaisedBucket
    )
  }

  @ViewBuilder
  var goalModal: some View {
    GoalView(
      buckets: self.searchFilters.goal.buckets,
      selectedBucket: self.selectedGoalBucket
    )
  }

  @ViewBuilder
  var footerView: some View {
    HStack(spacing: Styles.grid(2)) {
      Button(self.navigationState == [] ? Strings.Reset_all_filters() : Strings.Reset_filters()) {
        if let action = self.onReset {
          action(self.modalType)
        }
      }
      .buttonStyle(KSRButtonStyleModifier(style: .outlined))
      .frame(maxWidth: Constants.resetButtonMaxWidth)
      .disabled(!self.searchFilters.canReset(filter: self.modalType))

      Button(Strings.See_results()) {
        if let action = self.onResults {
          action()
        }
      }
      .buttonStyle(KSRButtonStyleModifier(style: .filled))
      .frame(maxWidth: .infinity)
    }
    .padding(Constants.sectionPadding)
  }

  // MARK: - Body

  public var body: some View {
    VStack(alignment: .leading) {
      NavigationStack(path: self.$navigationState) {
        ScrollView {
          VStack {
            Divider()
            self.categorySection
            Divider()
            self.projectStateSection
            Divider()
            self.percentRaisedSection
            if featureSearchFilterByLocation() {
              Divider()
              self.locationSection
            }
            if featureSearchFilterByAmountRaised() {
              Divider()
              self.amountRaisedSection
            }
            if featureSearchFilterByShowOnlyToggles() {
              Divider()
              self.showOnlySection
            }
            if featureSearchFilterByGoal() {
              Divider()
              self.goalSection
            }
            Divider()
            Spacer()
          }
        }
        .navigationDestination(for: SearchFilterModalType.self, destination: { modalType in
          switch modalType {
          case .category:
            self.categoryModal
              .modalHeader(withTitle: Strings.Category(), onClose: self.onClose)
          case .percentRaised:
            self.percentRaisedModal
              .modalHeader(withTitle: Strings.Percentage_raised(), onClose: self.onClose)
          case .location:
            self.locationModal
              .modalHeader(withTitle: Strings.Location(), onClose: self.onClose)
          case .amountRaised:
            self.amountRaisedModal
              .modalHeader(withTitle: Strings.Amount_raised(), onClose: self.onClose)
          case .goal:
            self.goalModal
              .modalHeader(withTitle: Strings.Goal(), onClose: self.onClose)
          default:
            EmptyView()
          }
        })
        .modalHeader(withTitle: Strings.Filter(), onClose: self.onClose)
      }
      Divider()
      self.footerView
    }
  }

  enum Constants {
    static let sectionPadding: EdgeInsets = EdgeInsets(top: 24.0, leading: 24.0, bottom: 24.0, trailing: 24.0)
    static let sectionSpacing: CGFloat = 12.0
    static let flowLayoutSpacing: CGFloat = 8.0
    static let resetButtonMaxWidth: CGFloat = 130.0
  }
}

extension View {
  func modalHeader(withTitle title: String, onClose: (() -> Void)?) -> some View {
    self
      .navigationTitle(title)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            if let action = onClose {
              action()
            }
          } label: {
            if let icon = Library.image(named: "icon--cross") {
              Image(uiImage: icon.withRenderingMode(.alwaysTemplate))
                .tint(Colors.Text.primary.swiftUIColor())
            }
          }
        }
      }
  }
}

// MARK: - Bindings

extension FilterRootView {
  private var selectedCategory: Binding<SearchFiltersCategory> {
    Binding {
      self.searchFilters.category.selectedCategory
    } set: { newValue in
      if let action = self.onFilter {
        action(.category(newValue))
      }
    }
  }

  private var selectedPercentRaisedBucket: Binding<DiscoveryParams.PercentRaisedBucket?> {
    Binding {
      self.searchFilters.percentRaised.selectedBucket
    } set: { newValue in
      if let action = self.onFilter,
         let bucket = newValue {
        action(.percentRaised(bucket))
      }
    }
  }

  private var selectedLocation: Binding<Location?> {
    Binding {
      self.searchFilters.location.selectedLocation
    } set: { newValue in
      if let action = self.onFilter {
        action(.location(newValue))
      }
    }
  }

  private var selectedAmountRaisedBucket: Binding<DiscoveryParams.AmountRaisedBucket?> {
    Binding {
      self.searchFilters.amountRaised.selectedBucket
    } set: { newValue in
      if let action = self.onFilter,
         let bucket = newValue {
        action(.amountRaised(bucket))
      }
    }
  }

  private var selectedGoalBucket: Binding<DiscoveryParams.GoalBucket?> {
    Binding {
      self.searchFilters.goal.selectedBucket
    } set: { newValue in
      if let action = self.onFilter,
         let bucket = newValue {
        action(.goal(bucket))
      }
    }
  }

  private var showRecommended: Binding<Bool> {
    Binding {
      self.searchFilters.showOnly.recommended
    } set: { newValue in
      if let action = self.onFilter {
        action(.recommended(newValue))
      }
    }
  }

  private var showSavedProjects: Binding<Bool> {
    Binding {
      self.searchFilters.showOnly.savedProjects
    } set: { newValue in
      if let action = self.onFilter {
        action(.savedProjects(newValue))
      }
    }
  }

  private var showProjectsWeLove: Binding<Bool> {
    Binding {
      self.searchFilters.showOnly.projectsWeLove
    } set: { newValue in
      if let action = self.onFilter {
        action(.projectsWeLove(newValue))
      }
    }
  }

  private var showFollowing: Binding<Bool> {
    Binding {
      self.searchFilters.showOnly.following
    } set: { newValue in
      if let action = self.onFilter {
        action(.following(newValue))
      }
    }
  }
}

// MARK: - Identifiable extension

extension DiscoveryParams.State: @retroactive Identifiable {
  public var id: String {
    return self.rawValue
  }
}
