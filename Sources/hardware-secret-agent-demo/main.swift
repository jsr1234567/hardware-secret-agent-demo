import HardwareSecretAgentCore

@main
struct DemoCLI {
    static func main() async {
        let session = AgentSession()

        do {
            let sources = try await session.scan()
            print("1. Scanned \(sources.count) synthetic source categories")

            try await session.approve()
            print("2. User approval recorded")

            try await session.connectDevice()
            print("3. Volatile device adapter connected")

            try await session.acknowledgeDemoPIN()
            print("4. Demo PIN step acknowledged")

            try await session.confirmPhysicalPresence()
            print("5. Physical-presence step confirmed")

            try await session.storeAndVerify()
            let stored = await session.snapshot()
            print("6. Stored and verified \(stored.volatileRecordCount) synthetic records")

            try await session.releaseAndClear()
            let cleared = await session.snapshot()
            print("7. Released session; volatile record count = \(cleared.volatileRecordCount)")
        } catch {
            print("Demo stopped safely: \(error)")
        }
    }
}
