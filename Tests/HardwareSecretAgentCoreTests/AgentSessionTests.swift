import Testing
@testable import HardwareSecretAgentCore

@Suite("Hardware secret agent state machine")
struct AgentSessionTests {
    @Test("The complete workflow stores, verifies, and clears every record")
    func completeWorkflow() async throws {
        let session = AgentSession()

        let sources = try await session.scan()
        #expect(sources.count == 4)
        try await session.approve()
        try await session.connectDevice()
        try await session.acknowledgeDemoPIN()
        try await session.confirmPhysicalPresence()
        try await session.storeAndVerify()

        let stored = await session.snapshot()
        #expect(stored.phase == .storedAndVerified)
        #expect(stored.itemCount == 10)
        #expect(stored.volatileRecordCount == 10)

        try await session.releaseAndClear()
        let cleared = await session.snapshot()
        #expect(cleared.phase == .releasedAndCleared)
        #expect(cleared.volatileRecordCount == 0)
    }

    @Test("Out-of-order actions fail closed without advancing state")
    func outOfOrderAction() async {
        let session = AgentSession()

        await #expect(throws: AgentError.invalidTransition(
            expected: .presenceConfirmed,
            actual: .idle
        )) {
            try await session.storeAndVerify()
        }

        let snapshot = await session.snapshot()
        #expect(snapshot.phase == .idle)
        #expect(snapshot.volatileRecordCount == 0)
    }

    @Test("An empty source catalog fails before approval")
    func emptyCatalog() async {
        let session = AgentSession(catalog: [])

        await #expect(throws: AgentError.emptyCatalog) {
            try await session.scan()
        }

        let snapshot = await session.snapshot()
        #expect(snapshot.phase == .idle)
    }

    @Test("A released session cannot be reused implicitly")
    func releasedSessionCannotRestart() async throws {
        let session = AgentSession()
        try await session.scan()
        try await session.approve()
        try await session.connectDevice()
        try await session.acknowledgeDemoPIN()
        try await session.confirmPhysicalPresence()
        try await session.storeAndVerify()
        try await session.releaseAndClear()

        await #expect(throws: AgentError.invalidTransition(
            expected: .idle,
            actual: .releasedAndCleared
        )) {
            try await session.scan()
        }
    }
}
