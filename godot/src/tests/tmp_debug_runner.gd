extends SceneTree

const PROFILE_SERVICE_SCRIPT = preload("res://src/product/profile_service.gd")
const PRODUCT_CATALOG_SCRIPT = preload("res://src/product/product_catalog.gd")
const WORLD_MODEL_SCRIPT = preload("res://src/delve/world_model.gd")
const DELVE_KERNEL_SCRIPT = preload("res://src/delve/delve_kernel.gd")
const THEORY_ENGINE_SCRIPT = preload("res://src/delve/theory_engine.gd")
const GOVERNANCE_SERVICE_SCRIPT = preload("res://src/product/governance_service.gd")
const CONTRADICTION_ENGINE_SCRIPT = preload("res://src/product/contradiction_engine.gd")
const CIVILIZATION_STATE_SERVICE_SCRIPT = preload("res://src/product/civilization_state_service.gd")

func _init() -> void:
	print("TMP_DEBUG start")
	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var profile := PROFILE_SERVICE_SCRIPT.create_default_profile(catalog)
	var session_context := {
		"player_count": 4,
		"peer_ids": [2, 3, 4, 5],
		"protocol_state": "Fracture Protocol",
		"public_cards": {
			"2": {"public_id": "p2", "display_name": "Aster"},
			"3": {"public_id": "p3", "display_name": "Bram"},
			"4": {"public_id": "p4", "display_name": "Cleo"},
			"5": {"public_id": "p5", "display_name": "Dax"}
		},
		"gameplay_snapshot": {
			"protocol_state": "Fracture Protocol",
			"group_model": {
				"group_signals": ["route control"],
				"fault_lines": ["split answer"],
				"model_pressure": ["route doubt"]
			}
		}
	}
	var world_model := WORLD_MODEL_SCRIPT.build_model(profile, session_context)
	print("TMP_DEBUG world_model ok")
	var experiment_state := Dictionary(world_model.get("experiment_state", {}))
	var governance_state := GOVERNANCE_SERVICE_SCRIPT.normalize(Dictionary(world_model.get("governance_state", {})))
	var theory_surface := THEORY_ENGINE_SCRIPT.build_surface(experiment_state, world_model, governance_state)
	print("TMP_DEBUG theory_surface ok ", JSON.stringify(theory_surface.get("statuses", [])))
	var civilization_surface := CIVILIZATION_STATE_SERVICE_SCRIPT.build_civilization_surface(Dictionary(world_model.get("world_memory_snapshot", {})))
	var contradiction_packet := CONTRADICTION_ENGINE_SCRIPT.build_contradiction_records(theory_surface, Dictionary(world_model.get("cookbook_state_snapshot", {})), Dictionary(world_model.get("world_memory_snapshot", {})))
	var evaluated_governance := GOVERNANCE_SERVICE_SCRIPT.evaluate_planning_state(governance_state, world_model, theory_surface, civilization_surface, contradiction_packet, Dictionary(world_model.get("cookbook_state_snapshot", {})))
	print("TMP_DEBUG governance ok ", JSON.stringify(Dictionary(evaluated_governance.get("activation_state", {})).get("active_channels", [])))
	var directive := DELVE_KERNEL_SCRIPT.plan_directive(profile, session_context, 1337, 9)
	print("TMP_DEBUG directive ok ", str(directive.get("doctrine_family", "")))
	quit()
