# Minecraft SCRAM System

CC:Tweaked 1.101.4 / Minecraft 1.19.2 / SecurityCraft 1.9.6.1.

## Wiring
- left: SecurityCraft emergency lever/button
- right: SecurityCraft Keycard Reader
- back: SCRAM redstone output
- monitor: any attached monitor

## Behaviour
- lever OFF: reactor operating; validation reset; SCRAM output OFF
- lever ON without card: waiting for validation
- valid card pulse: card remains validated for 15 seconds
- lever ON + valid card: manual SCRAM; back redstone output ON
- card first or lever first: both orders are supported
- after 15 seconds without lever activation: card validation expires
