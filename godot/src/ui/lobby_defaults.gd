class_name LobbyDefaults
extends RefCounted

const NETWORK_CONFIG_SCRIPT = preload("res://src/net/network_config.gd")

static func load_defaults() -> Dictionary:
	return NETWORK_CONFIG_SCRIPT.load_defaults()
