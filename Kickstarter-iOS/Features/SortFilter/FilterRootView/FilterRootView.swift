import KsApi
import Library
import SwiftUI

struct FilterRootView: View {
  @State var navigationState: [SearchFilterModalType]
  @ObservedObject var searchFilters: SearchFilters

  var onSelectedCategory: ((SearchFiltersCategory) -> Void)? = nil
  var onSelectedProjectState: ((DiscoveryParams.State) -> Void)? = nil
  var onSelectedPercentRaisedBucket: ((DiscoveryParams.PercentRaisedBucket) -> Void)? = nil
  var onSelectedLocation: ((Location?) -> Void)? = nil
  var onSelectedAmountRaisedBucket: ((DiscoveryParams.AmountRaisedBucket) -> Void)? = nil
  var onSearchedForLocations: ((String) -> Void)? = nil
  var onReset: ((SearchFilterModalType) -> Void)? = nil
  var onResults: (() -> Void)? = nil
  var onClose: (() -> Void)? = nil

  private var selectedCategory: Binding<SearchFiltersCategory> {
    Binding {
      self.searchFilters.category.selectedCategory
    } set: { newValue in
      if let action = self.onSelectedCategory {
        action(newValue)
      }
    }
  }

  private var selectedPercentRaisedBucket: Binding<DiscoveryParams.PercentRaisedBucket?> {
    Binding {
      self.searchFilters.percentRaised.selectedBucket
    } set: { newValue in
      if let action = self.onSelectedPercentRaisedBucket,
         let bucket = newValue {
        action(bucket)
      }
    }
  }

  private var selectedLocation: Binding<Location?> {
    Binding {
      self.searchFilters.location.selectedLocation
    } set: { newValue in
      if let action = self.onSelectedLocation {
        action(newValue)
      }
    }
  }

  private var selectedAmountRaisedBucket: Binding<DiscoveryParams.AmountRaisedBucket?> {
    Binding {
      self.searchFilters.amountRaised.selectedBucket
    } set: { newValue in
      if let action = self.onSelectedAmountRaisedBucket,
         let bucket = newValue {
        action(bucket)
      }
    }
  }

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

  @ViewBuilder
  var projectStateSection: some View {
    VStack(alignment: .leading, spacing: Constants.sectionSpacing) {
      Text(Strings.Project_status())
        .font(InterFont.headingLG.swiftUIFont())
        .foregroundStyle(Colors.Text.primary.swiftUIColor())
      FlowLayout(spacing: Constants.flowLayoutSpacing) {
        ForEach(self.searchFilters.projectState.stateOptions) { state in
          Button(action: {
            if let action = onSelectedProjectState {
              action(state)
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
    FilterSectionButton(
      title: Strings.Percentage_raised(),
      subtitle:
      self.searchFilters.percentRaised.selectedBucket?.title
    )
    .padding(Constants.sectionPadding)
  }

  @ViewBuilder
  var categorySection: some View {
    FilterSectionButton(
      title: Strings.Category(),
      subtitle: self.searchFilters.category.selectedCategory.name
    )
    .padding(Constants.sectionPadding)
  }

  @ViewBuilder
  var locationSection: some View {
    FilterSectionButton(
      title: Strings.Location(),
      subtitle: self.searchFilters.location.selectedLocation?.displayableName
    )
    .padding(Constants.sectionPadding)
  }

  @ViewBuilder
  var amountRaisedSection: some View {
    FilterSectionButton(
      title: Strings.Amount_raised(),
      subtitle: self.searchFilters.amountRaised.selectedBucket?.title
    )
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

  public var body: some View {
    VStack(alignment: .leading) {
      NavigationStack(path: self.$navigationState) {
        VStack {
          Divider()
          NavigationLink(value: SearchFilterModalType.category) {
            self.categorySection
          }
          Divider()
          self.projectStateSection
          Divider()
          NavigationLink(value: SearchFilterModalType.percentRaised) {
            self.percentRaisedSection
          }
          if featureSearchFilterByLocation() {
            Divider()
            NavigationLink(value: SearchFilterModalType.location) {
              self.locationSection
            }
          }
          if featureSearchFilterByAmountRaised() {
            Divider()
            NavigationLink(value: SearchFilterModalType.amountRaised) {
              self.amountRaisedSection
            }
          }
          Divider()
          Spacer()
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

extension DiscoveryParams.State: @retroactive Identifiable {
  public var id: String {
    return self.rawValue
  }
}
