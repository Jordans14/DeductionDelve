class_name ArchivistMind
extends RefCounted

static func propose(_world_model: Dictionary, _session_context: Dictionary, _planner: Dictionary, _meta: Dictionary, _counter: Dictionary) -> Dictionary:
	return {"name": "archivist", "weight": 2, "doctrine_biases": {"witness_pressure": 1, "custody_ritual": 1}, "surface_pushes": {"culture": {"archive_emphasis": 2, "public_heat_bias": 1}}, "notes": ["retellability"]}
