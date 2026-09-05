import Foundation

/// Enforces a fail-closed, user-mediated sequence around a volatile device adapter.
public actor AgentSession {
    private let catalog: [SourceDescriptor]
    private let device: VolatileDeviceAdapter
    private var phase: SessionPhase = .idle
    private var candidates: [SyntheticRecord] = []

    public init(
        catalog: [SourceDescriptor] = SyntheticCatalog.standard,
        device: VolatileDeviceAdapter = VolatileDeviceAdapter()
    ) {
        self.catalog = catalog
        self.device = device
    }

    @discardableResult
    public func scan() throws -> [SourceDescriptor] {
        try require(.idle)
        guard !catalog.isEmpty else { throw AgentError.emptyCatalog }
        phase = .scanned
        return catalog
    }

    public func approve() throws {
        try require(.scanned)
        phase = .approved
    }

    public func connectDevice() throws {
        try require(.approved)
        phase = .deviceConnected
    }

    public func acknowledgeDemoPIN() throws {
        try require(.deviceConnected)
        phase = .pinAcknowledged
    }

    public func confirmPhysicalPresence() throws {
        try require(.pinAcknowledged)
        phase = .presenceConfirmed
    }

    public func storeAndVerify() async throws {
        try require(.presenceConfirmed)

        candidates = catalog.flatMap { source in
            (0..<source.itemCount).map { index in
                let seed = "synthetic-record:\(source.id.uuidString):\(index)"
                return SyntheticRecord(id: UUID(), bytes: Data(seed.utf8))
            }
        }

        await device.store(candidates)
        guard await device.verify(candidates) else {
            await device.clear()
            candidates.removeAll(keepingCapacity: false)
            throw AgentError.verificationFailed
        }

        phase = .storedAndVerified
    }

    public func releaseAndClear() async throws {
        try require(.storedAndVerified)
        await device.clear()

        for index in candidates.indices {
            candidates[index].bytes.resetBytes(in: 0..<candidates[index].bytes.count)
        }
        candidates.removeAll(keepingCapacity: false)
        phase = .releasedAndCleared
    }

    public func snapshot() async -> SessionSnapshot {
        SessionSnapshot(
            phase: phase,
            sourceCount: phase == .idle ? 0 : catalog.count,
            itemCount: phase == .idle ? 0 : catalog.reduce(0) { $0 + $1.itemCount },
            volatileRecordCount: await device.recordCount
        )
    }

    private func require(_ expected: SessionPhase) throws {
        guard phase == expected else {
            throw AgentError.invalidTransition(expected: expected, actual: phase)
        }
    }
}
