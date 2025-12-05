import Foundation

/// The four gesture types supported by WristBop MVP
public enum GestureType: String, CaseIterable, Sendable {
    case shake
    case flickUp
    case twist
    case spinCrown

    /// Human-readable display name for UI
    public var displayName: String {
        switch self {
        case .shake:
            return "Shake it!"
        case .flickUp:
            return "Flick it!"
        case .twist:
            return "Twist it!"
        case .spinCrown:
            return "Spin it!"
        }
    }
}
