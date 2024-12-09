import BrazeKitCompat
import Foundation
import SegmentBraze

// MARK: - BrazeInAppMessageType

public protocol BrazeInAppMessageType {}

extension ABKInAppMessage: BrazeInAppMessageType {}

// MARK: - AppboyType

public protocol AppboyType {}

// extension SEGAppboyHelper: AppboyType {}
