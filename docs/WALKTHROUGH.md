# Two-minute walkthrough

Run from the repository root with Swift 6 on macOS 13 or newer. Nothing to configure; every record is generated synthetic data.

## 1. Follow a complete session

```bash
swift run hardware-secret-agent
```

The catalog describes four categories: browser export (3 records), OS credential store (2), password manager export (4), and local project folder (1). These are fixed examples, not sources accessed on your computer.

Notice the separation between discovery and approval. Metadata appears first. Synthetic payloads are generated only after the approval, connection, PIN, and presence checkpoints have all advanced in order. The command acknowledges those checkpoints automatically; no real person, PIN, device, or biometric is verified.

The adapter reports ten stored records after verification and zero after session closure. Source originals remain unchanged because this preview never opens a source. Closing the session delivers nothing to an application.

## 2. Try taking shortcuts

```bash
swift run hardware-secret-agent --scenario blocked
```

You should see three `BLOCKED` results:

```text
BLOCKED · Connect before approval
  Expected phase approved, but session is scanned.
  Unchanged: scanned, 0 volatile records
BLOCKED · Store after PIN without presence
  Expected phase presenceConfirmed, but session is pinAcknowledged.
  Unchanged: pinAcknowledged, 0 volatile records
BLOCKED · Reuse a completed session
  Expected phase idle, but session is releasedAndCleared.
  Unchanged: releasedAndCleared, 0 volatile records
```

Each example checks both the expected transition error and the unchanged session snapshot. This makes the boundary visible: an attempted shortcut does not silently advance the workflow. These are sequential examples, not evidence of concurrency safety or resistance to an attacker.

## 3. Find the small pieces behind it

- [`AgentSession.swift`](../Sources/HardwareSecretAgentCore/AgentSession.swift): the existing legal transition sequence and checks.
- [`Models.swift`](../Sources/HardwareSecretAgentCore/Models.swift): metadata descriptors and session snapshots without a dedicated secret-value field. String fields are not a sanitizer; use synthetic inputs only.
- [`VolatileDeviceAdapter.swift`](../Sources/HardwareSecretAgentCore/VolatileDeviceAdapter.swift): an in-memory stand-in, not encrypted storage or a hardware boundary.
- [`main.swift`](../Sources/hardware-secret-agent/main.swift): the runnable examples and their assertions.

Run `swift test` for the reference suite. Both CLI scenarios also run in CI.

The sample illustrates ordering and separation of responsibilities. It does not establish secure erasure, real authentication, physical security, or production readiness. See the [security boundary](../README.md#security-boundary) before adapting it.
