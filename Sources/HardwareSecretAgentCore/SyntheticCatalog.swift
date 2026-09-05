import Foundation

public enum SyntheticCatalog {
    /// Fixed metadata makes the demo deterministic and safe to run in CI.
    public static let standard: [SourceDescriptor] = [
        SourceDescriptor(
            id: UUID(uuidString: "10000000-0000-0000-0000-000000000001")!,
            kind: .browserExport,
            displayName: "Browser export (synthetic)",
            itemCount: 3
        ),
        SourceDescriptor(
            id: UUID(uuidString: "10000000-0000-0000-0000-000000000002")!,
            kind: .operatingSystemStore,
            displayName: "OS credential store (synthetic)",
            itemCount: 2
        ),
        SourceDescriptor(
            id: UUID(uuidString: "10000000-0000-0000-0000-000000000003")!,
            kind: .passwordManagerExport,
            displayName: "Password manager export (synthetic)",
            itemCount: 4
        ),
        SourceDescriptor(
            id: UUID(uuidString: "10000000-0000-0000-0000-000000000004")!,
            kind: .localProjectFolder,
            displayName: "Local project folder (synthetic)",
            itemCount: 1
        )
    ]
}
