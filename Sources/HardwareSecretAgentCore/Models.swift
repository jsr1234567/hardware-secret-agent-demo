import Foundation

public enum SourceKind: String, CaseIterable, Sendable {
    case browserExport = "browser-export"
    case operatingSystemStore = "os-credential-store"
    case passwordManagerExport = "password-manager-export"
    case localProjectFolder = "local-project-folder"
}

/// Metadata describing a source. It deliberately contains no secret value field.
public struct SourceDescriptor: Equatable, Sendable {
    public let id: UUID
    public let kind: SourceKind
    public let displayName: String
    public let itemCount: Int

    public init(id: UUID, kind: SourceKind, displayName: String, itemCount: Int) {
        self.id = id
        self.kind = kind
        self.displayName = displayName
        self.itemCount = itemCount
    }
}

public enum SessionPhase: String, Equatable, Sendable {
    case idle
    case scanned
    case approved
    case deviceConnected
    case pinAcknowledged
    case presenceConfirmed
    case storedAndVerified
    case releasedAndCleared
}

public struct SessionSnapshot: Equatable, Sendable {
    public let phase: SessionPhase
    public let sourceCount: Int
    public let itemCount: Int
    public let volatileRecordCount: Int
}

public enum AgentError: Error, Equatable, CustomStringConvertible {
    case invalidTransition(expected: SessionPhase, actual: SessionPhase)
    case emptyCatalog
    case verificationFailed

    public var description: String {
        switch self {
        case let .invalidTransition(expected, actual):
            "Expected phase \(expected.rawValue), but session is \(actual.rawValue)."
        case .emptyCatalog:
            "The source catalog is empty."
        case .verificationFailed:
            "The volatile device could not verify all stored records."
        }
    }
}

struct SyntheticRecord: Equatable, Sendable {
    let id: UUID
    var bytes: Data
}
