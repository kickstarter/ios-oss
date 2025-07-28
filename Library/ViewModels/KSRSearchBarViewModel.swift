import Foundation
import ReactiveSwift

public protocol KSRSearchBarViewModelInputs {
  /// Call when the cancel button is pressed.
  func cancelButtonPressed()

  /// Call when the search clear button is tapped.
  func clearSearchText()

  /// Call when the search field begins editing.
  func searchFieldDidBeginEditing()

  /// Call when the user taps the return key.
  func searchTextEditingDidEnd()

  /// Call when the user enters a new search term.
  func searchTextChanged(_ searchText: String)
}

public protocol KSRSearchBarViewModelOutputs {
  /// Emits booleans that determines if the search field should be focused or not, and whether that focus
  /// should be animated.
  var changeSearchFieldFocus: Signal<Bool, Never> { get }

  /// Emits when the search field should resign focus.
  var resignFirstResponder: Signal<(), Never> { get }

  /// Emits a string that should be filled into the search field.
  var searchFieldText: Signal<String, Never> { get }
}

public protocol KSRSearchBarViewModelType {
  var inputs: KSRSearchBarViewModelInputs { get }
  var outputs: KSRSearchBarViewModelOutputs { get }
}

public final class KSRSearchBarViewModel: KSRSearchBarViewModelType, KSRSearchBarViewModelInputs,
  KSRSearchBarViewModelOutputs {
  public init() {
    self.changeSearchFieldFocus = Signal.merge(
      self.searchFieldDidBeginEditingProperty.signal.mapConst(true),
      self.searchTextEditingDidEndProperty.signal.mapConst(false)
    )

    self.searchFieldText = Signal.merge(
      self.searchTextChangedProperty.signal,
      self.cancelButtonPressedProperty.signal.mapConst(""),
      self.clearSearchTextProperty.signal.mapConst("")
    )

    self.resignFirstResponder = Signal
      .merge(
        self.cancelButtonPressedProperty.signal,
        self.searchTextEditingDidEndProperty.signal
      )
  }

  // MARK: - Inputs

  private let cancelButtonPressedProperty = MutableProperty(())
  public func cancelButtonPressed() {
    self.cancelButtonPressedProperty.value = ()
  }

  private let clearSearchTextProperty = MutableProperty(())
  public func clearSearchText() {
    self.clearSearchTextProperty.value = ()
  }

  private let searchFieldDidBeginEditingProperty = MutableProperty(())
  public func searchFieldDidBeginEditing() {
    self.searchFieldDidBeginEditingProperty.value = ()
  }

  private let searchTextEditingDidEndProperty = MutableProperty(())
  public func searchTextEditingDidEnd() {
    self.searchTextEditingDidEndProperty.value = ()
  }

  private let searchTextChangedProperty = MutableProperty("")
  public func searchTextChanged(_ searchText: String) {
    self.searchTextChangedProperty.value = searchText
  }

  // MARK: - Outputs

  public let changeSearchFieldFocus: Signal<Bool, Never>
  public let resignFirstResponder: Signal<(), Never>
  public let searchFieldText: Signal<String, Never>

  // MARK: - KSRSearchBarViewModelType

  public var inputs: KSRSearchBarViewModelInputs { return self }
  public var outputs: KSRSearchBarViewModelOutputs { return self }
}
