extends Node

## Emit to trigger rebind overlay
signal keyboard_binding(action: String) 

## Emit to trigger rebind overlay
signal joypad_binding(action: String) 

## Emitted when StageRoot is ready
signal stage_ready 

signal player_state_changed(state: String, machine: String)

## Emitted whenever a stat changes in the player data
signal player_stat_updated(key: Key, value: Variant)

## Emitted whenever a stat changes in the game data
signal game_stat_updated(key: Key, value: Variant)
