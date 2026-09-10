import Foundation
import HardwareSecretAgentCore

@main
struct PreviewCLI {
    static func main() async {
        let arguments = Array(CommandLine.arguments.dropFirst())
        if arguments == ["--help"] || arguments == ["-h"] {
            print("""
            Usage: swift run hardware-secret-agent [--scenario walkthrough|blocked|all]

            walkthrough  Follow ten synthetic records through the public preview (default).
            blocked      Try skipping approval, skipping presence, and reusing a session.
            all          Run both scenarios.

            All data and checkpoints are synthetic. No files, accounts, or devices are read.
            """)
            return
        }
        let scenario: String
        if arguments.isEmpty {
            scenario = "walkthrough"
        } else if arguments.count == 2, arguments[0] == "--scenario",
                  ["walkthrough", "blocked", "all"].contains(arguments[1]) {
            scenario = arguments[1]
        } else {
            print("Unknown arguments. Use --help for available scenarios.")
            exit(2)
        }

        print("Hardware Secret Agent · public preview · synthetic only")
        print("No real source access, PIN verification, biometrics, or hardware.\n")
        do {
            if scenario != "blocked" { try await walkthrough() }
            if scenario != "walkthrough" { try await blockedActions() }
        } catch {
            print("Preview failed: \(error)")
            exit(1)
        }
    }

    private static func walkthrough() async throws {
        print("WALKTHROUGH")
        let session = AgentSession()
        let sources = try await session.scan()
        print("1. Discovered \(sources.count) synthetic source categories:")
        for source in sources {
            print("   \(source.kind.rawValue): \(source.itemCount) synthetic records")
        }
        print("   Discovery describes candidates; it does not read secret values.")
        try await session.approve()
        print("2. Simulated approval recorded for this session")
        try await session.connectDevice()
        print("3. Volatile in-process adapter connected")
        try await session.acknowledgeDemoPIN()
        print("4. Simulated PIN checkpoint acknowledged (no PIN is collected)")
        try await session.confirmPhysicalPresence()
        print("5. Simulated presence checkpoint acknowledged (no sensor is used)")
        try await session.storeAndVerify()
        let stored = await session.snapshot()
        print("6. Stored and verified \(stored.volatileRecordCount) generated synthetic records")
        try await session.releaseAndClear()
        let cleared = await session.snapshot()
        print("7. Closed session; volatile record count = \(cleared.volatileRecordCount)")
        print("   No value was delivered to an app. No source original was changed.\n")
    }

    private static func blockedActions() async throws {
        print("BLOCKED ACTIONS")
        let unapproved = AgentSession()
        try await unapproved.scan()
        try await expectBlocked("Connect before approval", session: unapproved,
                                expected: .approved, actual: .scanned) {
            try await unapproved.connectDevice()
        }

        let session = AgentSession()
        try await session.scan()
        try await session.approve()
        try await session.connectDevice()
        try await session.acknowledgeDemoPIN()
        try await expectBlocked("Store after PIN without presence", session: session,
                                expected: .presenceConfirmed, actual: .pinAcknowledged) {
            try await session.storeAndVerify()
        }

        try await session.confirmPhysicalPresence()
        try await session.storeAndVerify()
        try await session.releaseAndClear()
        try await expectBlocked("Reuse a completed session", session: session,
                                expected: .idle, actual: .releasedAndCleared) {
            _ = try await session.scan()
        }
        print("Each rejected action leaves the snapshot unchanged.\n")
    }

    private static func expectBlocked(
        _ label: String, session: AgentSession,
        expected: SessionPhase, actual: SessionPhase,
        action: () async throws -> Void
    ) async throws {
        let before = await session.snapshot()
        do {
            try await action()
            throw PreviewFailure.unexpectedSuccess
        } catch let error as AgentError {
            guard error == .invalidTransition(expected: expected, actual: actual),
                  await session.snapshot() == before else {
                throw PreviewFailure.unexpectedRejection
            }
            print("BLOCKED · \(label)")
            print("  \(error)")
            print("  Unchanged: \(before.phase.rawValue), \(before.volatileRecordCount) volatile records")
        }
    }

    private enum PreviewFailure: Error {
        case unexpectedSuccess
        case unexpectedRejection
    }
}
