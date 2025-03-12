# Phasor

**Spatial Audio With Translational and Rotational Movement**

## Development

Phasor uses [Tuist](https://tuist.io) for development. 

```zsh
# assuming tuist and gh cli are installed
gh repo clone gyoge0/Phasor
cd Phasor
tuist generate
```

The generated project will try and use my local development signing team. Use the signing and capabilities menu in Xcode to change it to yours, or update the Tuist project locally.

## Ignored Music

Phasor uses some licensed music which is not checked into git. See the table below for music that needs to be added.

|Name            |Path                                            |
|----------------|------------------------------------------------|
|Espresso Backing|`Phasor/Resources/Espresso/espresso_backing.m4a`|
|Espresso Bass   |`Phasor/Resources/Espresso/espresso_bass.m4a`   |
|Espresso Drums  |`Phasor/Resources/Espresso/espresso_drums.m4a`  |
|Espresso Guitar |`Phasor/Resources/Espresso/espresso_guitar.m4a` |
|Espresso Vocals |`Phasor/Resources/Espresso/espresso_vocals.m4a` |

## Architecture

See the mermaid diagram:
```mermaid
graph BT
    subgraph UI
        SwiftUI
        ARKit
    end

    ViewModels

    subgraph Services
        CoreMotion
        PHASE
    end

    subgraph Persistence
        SwiftData
    end

    SwiftUI -->|Interactions| ViewModels
    ViewModels -->|Models| SwiftUI
    ViewModels -->|Sound Source Locations| ARKit

    ARKit -->|Position Data| ViewModels
    CoreMotion -->|Rotation Data| PHASE
    ViewModels -->|Project Info| PHASE
    ViewModels -->|Position Data| PHASE
    ViewModels <-->|Models| SwiftData
```
