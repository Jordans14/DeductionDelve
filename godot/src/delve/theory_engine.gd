class_name TheoryEngine
extends RefCounted

const THEORY_STORE_SCRIPT = preload("res://src/product/delvemind_theory_store.gd")
const SIMULATION_CHAMBERS_SCRIPT = preload("res://src/delve/simulation_chambers.gd")

static func build_surface(experiment_state: Dictionary, world_model: Dictionary = {}, governance_state: Dictionary = {}) -> Dictionary:
	var theory_store := THEORY_STORE_SCRIPT.sync_from_experiments(
		Dictionary(experiment_state.get("theory_store", {})),
		experiment_state
	)
	var public_surface := THEORY_STORE_SCRIPT.build_public_surface(theory_store)
	var chamber_state := SIMULATION_CHAMBERS_SCRIPT.build_state(public_surface, world_model)
	var governance_activation := Dictionary(governance_state.get("activation_state", {}))
	return {
		"lines": Array(public_surface.get("lines", [])).duplicate(true),
		"theory_ids": Array(public_surface.get("theory_ids", [])).duplicate(true),
		"school_ids": Array(public_surface.get("school_ids", [])).duplicate(true),
		"statuses": Array(public_surface.get("statuses", [])).duplicate(true),
		"coexistence_modes": Array(public_surface.get("statuses", [])).duplicate(true),
		"activation_epoch": str(governance_activation.get("epoch", "structural_presence")).strip_edges(),
		"chamber_forecasts": Array(Dictionary(chamber_state).get("records", [])).duplicate(true),
		"chamber_lines": Array(Dictionary(SIMULATION_CHAMBERS_SCRIPT.build_surface(chamber_state)).get("lines", [])).duplicate(true),
		"theory_store": theory_store
	}
