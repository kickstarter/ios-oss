import Foundation

extension GraphAPI.BackingState {
  /**
   An adapter method which takes a `BackingState` and converts it to a `GraphAPI.BackingState?` object.

   - parameter backingState: `BackingState` object that needs to be converted to be `GraphAPI` compatible.
   */
  static func from(_ backingState: BackingState) -> GraphAPI.BackingState? {
    return GraphAPI.BackingState(rawValue: backingState.rawValue)
  }
}
