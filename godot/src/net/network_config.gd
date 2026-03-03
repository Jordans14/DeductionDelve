class_name NetworkConfig
extends RefCounted

const CONFIG_PATH := "res://config/network_defaults.json"
const FALLBACK_DEFAULTS := {
	"default_port": 2456,
	"default_bind_address": "0.0.0.0",
	"default_join_address": "127.0.0.1",
	"max_peers": 8,
	"host_port_fallback_attempts": 10,
	"min_players_to_start": 2
}

static func load_defaults() -> Dictionary:
	if not FileAccess.file_exists(CONFIG_PATH):
		return FALLBACK_DEFAULTS.duplicate(true)
	var file := FileAccess.open(CONFIG_PATH, FileAccess.READ)
	if file == null:
		return FALLBACK_DEFAULTS.duplicate(true)
	var parsed = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		return FALLBACK_DEFAULTS.duplicate(true)
	var defaults := FALLBACK_DEFAULTS.duplicate(true)
	for key in parsed.keys():
		defaults[key] = parsed[key]
	return defaults
