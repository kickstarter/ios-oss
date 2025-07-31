import BrazeKitCompat
import SegmentBraze
import Foundation

// MARK: - BrazeInAppMessageType

public protocol BrazeInAppMessageType {}

extension ABKInAppMessage: BrazeInAppMessageType {}

// MARK: - AppboyType

public protocol AppboyType {}

//extension SEGAppboyHelper: AppboyType {}
