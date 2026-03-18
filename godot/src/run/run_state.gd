extends Node

var run_seed: int = 0
var run_counter: int = 0
var room_chain: Array = []
var player_ids: Array[int] = []
var local_role: String = "Unknown"
var local_role_payload: Dictionary = {}
var evidence_by_id: Dictionary = {}
var artifacts_by_id: Dictionary = {}
var items_by_id: Dictionary = {}
var expedition_constitution: Dictionary = {}
var constitution_hash: String = ""
var constitution_summary: Dictionary = {}
var generation_surface: Dictionary = {}
var survival_state := {
	"health_points": {},
	"stability_points": {},
	"social_trust_score": {}
}
var truth_state := {
	"public_trace_classes": [],
	"private_trace_classes": []
}
var mutation_history: Array = []
var mutation_budget_by_domain: Dictionary = {}
var active_mutation_flags: Dictionary = {}
var mutation_caps_state: Dictionary = {}
var mutation_visibility_state: Dictionary = {}
var replay_identity: Dictionary = {}
var governance_hook_set: Dictionary = {}
var telemetry_summary: Dictionary = {}
var forensic_bundle_header: Dictionary = {}

func set_run(seed_value: int, chain: Array, peers: Array[int], context: Dictionary = {}) -> void:
	run_counter += 1
	run_seed = seed_value
	room_chain = chain.duplicate(true)
	player_ids = peers.duplicate()
	local_role = "Unknown"
	local_role_payload.clear()
	evidence_by_id.clear()
	artifacts_by_id.clear()
	items_by_id.clear()
	expedition_constitution = Dictionary(context.get("constitution", {})).duplicate(true)
	constitution_hash = str(context.get("constitution_hash", expedition_constitution.get("constitution_hash", ""))).strip_edges()
	constitution_summary = Dictionary(context.get("constitution_summary", expedition_constitution.get("constitution_summary", expedition_constitution.get("public_summary", {})))).duplicate(true)
	generation_surface = Dictionary(context.get("generation_surface", expedition_constitution.get("generation_surface", expedition_constitution.get("generation_contract", {})))).duplicate(true)
	survival_state = {
		"health_points": Dictionary(Dictionary(context.get("survival_state", {})).get("health_points", {})).duplicate(true),
		"stability_points": Dictionary(Dictionary(context.get("survival_state", {})).get("stability_points", {})).duplicate(true),
		"social_trust_score": Dictionary(Dictionary(context.get("survival_state", {})).get("social_trust_score", {})).duplicate(true)
	}
	truth_state = {
		"public_trace_classes": Array(Dictionary(context.get("truth_state", {})).get("public_trace_classes", [])).duplicate(true),
		"private_trace_classes": Array(Dictionary(context.get("truth_state", {})).get("private_trace_classes", [])).duplicate(true)
	}
	mutation_history = Array(context.get("mutation_history", [])).duplicate(true)
	mutation_budget_by_domain = Dictionary(context.get("mutation_budget_by_domain", {})).duplicate(true)
	active_mutation_flags = Dictionary(context.get("active_mutation_flags", {})).duplicate(true)
	mutation_caps_state = Dictionary(context.get("mutation_caps_state", {})).duplicate(true)
	mutation_visibility_state = Dictionary(context.get("mutation_visibility_state", {})).duplicate(true)
	replay_identity = Dictionary(context.get("replay_identity", {})).duplicate(true)
	governance_hook_set = Dictionary(context.get("governance_hook_set", {})).duplicate(true)
	telemetry_summary = Dictionary(context.get("telemetry_summary", {})).duplicate(true)
	forensic_bundle_header = Dictionary(context.get("forensic_bundle_header", {})).duplicate(true)

func clear() -> void:
	run_seed = 0
	room_chain.clear()
	player_ids.clear()
	local_role = "Unknown"
	local_role_payload.clear()
	evidence_by_id.clear()
	artifacts_by_id.clear()
	items_by_id.clear()
	expedition_constitution.clear()
	constitution_hash = ""
	constitution_summary.clear()
	generation_surface.clear()
	survival_state = {
		"health_points": {},
		"stability_points": {},
		"social_trust_score": {}
	}
	truth_state = {
		"public_trace_classes": [],
		"private_trace_classes": []
	}
	mutation_history.clear()
	mutation_budget_by_domain.clear()
	active_mutation_flags.clear()
	mutation_caps_state.clear()
	mutation_visibility_state.clear()
	replay_identity.clear()
	governance_hook_set.clear()
	telemetry_summary.clear()
	forensic_bundle_header.clear()

func set_expedition_constitution(constitution: Dictionary) -> void:
	expedition_constitution = constitution.duplicate(true)
	constitution_hash = str(expedition_constitution.get("constitution_hash", constitution_hash)).strip_edges()
	constitution_summary = Dictionary(expedition_constitution.get("constitution_summary", expedition_constitution.get("public_summary", constitution_summary))).duplicate(true)
	generation_surface = Dictionary(expedition_constitution.get("generation_surface", expedition_constitution.get("generation_contract", generation_surface))).duplicate(true)

func get_expedition_constitution() -> Dictionary:
	return expedition_constitution.duplicate(true)

func log_mutation(event: Dictionary) -> void:
	mutation_history.append(event.duplicate(true))

func set_artifacts(next_artifacts: Dictionary) -> void:
	artifacts_by_id = next_artifacts.duplicate(true)
	evidence_by_id = next_artifacts.duplicate(true)

func set_items(next_items: Dictionary) -> void:
	items_by_id = next_items.duplicate(true)
