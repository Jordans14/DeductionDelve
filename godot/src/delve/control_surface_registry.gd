class_name ControlSurfaceRegistry
extends RefCounted

const SURFACES := {
	"generation": {
		"witness_exposure": {"min": -2, "max": 2, "owner": "run_generator", "label": "Witness exposure"},
		"rescue_geometry": {"min": -2, "max": 2, "owner": "run_generator", "label": "Rescue geometry"},
		"bottleneck_severity": {"min": -2, "max": 2, "owner": "run_generator", "label": "Bottleneck severity"},
		"loop_probability": {"min": -2, "max": 2, "owner": "run_generator", "label": "Loop probability"},
		"traversal_harshness": {"min": -2, "max": 2, "owner": "run_generator", "label": "Traversal harshness"},
		"ritual_frequency": {"min": -2, "max": 2, "owner": "run_generator", "label": "Ritual frequency"}
	},
	"social": {
		"blame_ambiguity": {"min": -2, "max": 2, "owner": "doctrine_engine", "label": "Blame ambiguity"},
		"private_evidence_ratio": {"min": -2, "max": 2, "owner": "doctrine_engine", "label": "Private evidence ratio"},
		"obligation_pressure": {"min": -2, "max": 2, "owner": "doctrine_engine", "label": "Obligation pressure"},
		"coalition_visibility": {"min": -2, "max": 2, "owner": "doctrine_engine", "label": "Coalition visibility"},
		"hidden_role_density": {"min": -2, "max": 2, "owner": "doctrine_engine", "label": "Hidden-role density"}
	},
	"ecology": {
		"inhabitant_pressure": {"min": -2, "max": 2, "owner": "run_generator", "label": "Inhabitant pressure"},
		"stalking_bias": {"min": -2, "max": 2, "owner": "run_generator", "label": "Stalking bias"},
		"anomaly_contamination": {"min": -2, "max": 2, "owner": "run_generator", "label": "Anomaly contamination"}
	},
	"economy": {
		"resource_austerity": {"min": -2, "max": 2, "owner": "item_service", "label": "Resource austerity"},
		"recovery_cushion": {"min": -2, "max": 2, "owner": "item_service", "label": "Recovery cushion"},
		"commitment_cost": {"min": -2, "max": 2, "owner": "item_service", "label": "Commitment cost"},
		"lure_abundance": {"min": -2, "max": 2, "owner": "item_service", "label": "Lure abundance"}
	},
	"culture": {
		"public_heat_bias": {"min": -2, "max": 2, "owner": "framing_service", "label": "Public heat bias"},
		"archive_emphasis": {"min": -2, "max": 2, "owner": "archive_service", "label": "Archive emphasis"}
	}
}

static func definitions() -> Dictionary:
	return SURFACES.duplicate(true)

static func empty_policy() -> Dictionary:
	var policy := {}
	for group_name in SURFACES.keys():
		var group_policy := {}
		for surface_name in Dictionary(SURFACES.get(group_name, {})).keys():
			group_policy[surface_name] = 0
		policy[group_name] = group_policy
	return policy

static func clamp_policy(policy: Dictionary) -> Dictionary:
	var clamped := empty_policy()
	for group_name in SURFACES.keys():
		var group_defs: Dictionary = Dictionary(SURFACES.get(group_name, {}))
		var group_policy: Dictionary = Dictionary(policy.get(group_name, {}))
		for surface_name in group_defs.keys():
			var def: Dictionary = Dictionary(group_defs.get(surface_name, {}))
			var min_value := int(def.get("min", -2))
			var max_value := int(def.get("max", 2))
			var value := clampi(int(group_policy.get(surface_name, 0)), min_value, max_value)
			Dictionary(clamped[group_name])[surface_name] = value
	return clamped

static func apply_push(policy: Dictionary, group_name: String, surface_name: String, delta: int) -> Dictionary:
	var next := clamp_policy(policy)
	if not SURFACES.has(group_name):
		return next
	var group_policy: Dictionary = Dictionary(next.get(group_name, {}))
	group_policy[surface_name] = int(group_policy.get(surface_name, 0)) + delta
	next[group_name] = group_policy
	return clamp_policy(next)

static func apply_push_bundle(policy: Dictionary, pushes: Dictionary) -> Dictionary:
	var next := clamp_policy(policy)
	for group_name in pushes.keys():
		if not SURFACES.has(group_name):
			continue
		var group_pushes: Dictionary = Dictionary(pushes.get(group_name, {}))
		for surface_name in group_pushes.keys():
			next = apply_push(next, str(group_name), str(surface_name), int(group_pushes.get(surface_name, 0)))
	return clamp_policy(next)

static func surface_value(policy: Dictionary, group_name: String, surface_name: String) -> int:
	return int(Dictionary(policy.get(group_name, {})).get(surface_name, 0))

static func public_summary(policy: Dictionary) -> Dictionary:
	var clamped := clamp_policy(policy)
	var strongest: Array[Dictionary] = []
	for group_name in SURFACES.keys():
		var group_defs: Dictionary = Dictionary(SURFACES.get(group_name, {}))
		for surface_name in group_defs.keys():
			var value: int = abs(int(Dictionary(clamped.get(group_name, {})).get(surface_name, 0)))
			if value <= 0:
				continue
			strongest.append({
				"group": str(group_name),
				"surface": str(surface_name),
				"value": int(Dictionary(clamped.get(group_name, {})).get(surface_name, 0)),
				"label": str(Dictionary(group_defs.get(surface_name, {})).get("label", surface_name))
			})
	strongest.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var a_abs: int = abs(int(a.get("value", 0)))
		var b_abs: int = abs(int(b.get("value", 0)))
		if a_abs == b_abs:
			return str(a.get("label", "")) < str(b.get("label", ""))
		return a_abs > b_abs
	)
	var lines: Array[String] = []
	for entry_raw in strongest:
		var entry: Dictionary = Dictionary(entry_raw)
		var label := str(entry.get("label", "")).strip_edges()
		if label.is_empty():
			continue
		var value := int(entry.get("value", 0))
		var intensity: String = "tilted toward" if value > 0 else "held back from"
		lines.append("%s %s" % [label, intensity])
		if lines.size() >= 3:
			break
	return {
		"lines": lines,
		"strongest": strongest.slice(0, 6),
		"clamped": clamped
	}
