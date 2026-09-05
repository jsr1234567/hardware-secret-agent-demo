# Hardware Secret Agent Demo

A small, generic Swift reference implementation of a fail-closed state machine for moving synthetic secret records through a volatile hardware-adapter boundary.

This repository is intentionally standalone. It uses no real accounts, credentials, exports, device APIs, product infrastructure, or network services.

## What it demonstrates

- Metadata-only discovery across four synthetic source categories
- Explicit user approval before any simulated transfer
- Ordered connect, PIN, and physical-presence checkpoints
- Volatile in-process storage behind an actor boundary
- Store-and-verify behavior before release
- Clearing the device adapter and local candidate buffers at session end
- Fail-closed rejection of out-of-order actions

```mermaid
flowchart LR
    A["Synthetic source metadata"] --> B["Agent session state machine"]
    B --> C["Explicit approval checkpoints"]
    C --> D["Volatile device adapter"]
    D --> E["Verify, release, and clear"]
```

## State sequence

```text
idle
  -> scanned
  -> approved
  -> deviceConnected
  -> pinAcknowledged
  -> presenceConfirmed
  -> storedAndVerified
  -> releasedAndCleared
```

Each operation validates the current phase before changing state. An invalid transition throws an error and leaves the session unchanged.

## Run it

Requirements: macOS 13 or newer and Swift 6.

```bash
swift run hardware-secret-agent-demo
swift test
```

The command prints only counts and state transitions. The public source schema has no field capable of carrying a secret value.

## Repository layout

```text
Sources/HardwareSecretAgentCore/
  AgentSession.swift          ordered workflow coordinator
  Models.swift                value-free public schemas
  SyntheticCatalog.swift      deterministic source metadata
  VolatileDeviceAdapter.swift in-memory hardware stand-in
Sources/hardware-secret-agent-demo/
  main.swift                  runnable transcript
Tests/
  HardwareSecretAgentCoreTests/
```

## Security boundary

This is an educational simulation, not a production secret manager or hardware integration. The adapter is process memory, the PIN and physical-presence steps are acknowledgements, and the payloads are generated synthetic bytes. Swift does not guarantee complete erasure of copied `Data` storage; the explicit buffer reset illustrates intent rather than a formal zeroization guarantee.

A production implementation would need an audited hardware protocol, authenticated transport, platform-specific secure memory handling, strict connector permissions, threat modeling, recovery design, and independent security review.

## Design principles

1. Keep discovery metadata separate from secret material.
2. Require an explicit checkpoint for every authority increase.
3. Make the legal transition path small and testable.
4. Verify storage before reporting success.
5. Clear volatile state at the end of every completed session.
6. Treat unexpected ordering as an error, never as an implicit shortcut.

No license is granted by default. Add the license that matches your intended use before redistributing the code.
