import Foundation

/// A deliberately volatile stand-in for a hardware-backed secret store.
/// Records never leave the actor and are discarded when `clear()` is called.
public actor VolatileDeviceAdapter {
    private var records: [UUID: Data] = [:]

    public init() {}

    func store(_ candidates: [SyntheticRecord]) {
        for candidate in candidates {
            records[candidate.id] = candidate.bytes
        }
    }

    func verify(_ candidates: [SyntheticRecord]) -> Bool {
        candidates.allSatisfy { records[$0.id] == $0.bytes }
    }

    public func clear() {
        records.removeAll(keepingCapacity: false)
    }

    public var recordCount: Int {
        records.count
    }
}
