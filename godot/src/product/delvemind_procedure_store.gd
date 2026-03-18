class_name DelveMindProcedureStore
extends RefCounted

const MAX_PROCEDURES := 48

static func default_store() -> Dictionary:
	return {
		"schema_name": "ProcedureStore",
		"schema_version": 1,
		"procedures": [],
		"proposal_ids": []
	}

static func normalize(store: Dictionary) -> Dictionary:
	var current := default_store()
	for key in store.keys():
		current[key] = store[key]
	var procedures: Array[Dictionary] = []
	for value in Array(current.get("procedures", [])):
		var procedure := Dictionary(value).duplicate(true)
		procedure["procedure_id"] = str(procedure.get("procedure_id", "")).strip_edges()
		procedure["label"] = str(procedure.get("label", "")).strip_edges()
		procedure["status"] = str(procedure.get("status", "dormant")).strip_edges()
		procedure["risk_class"] = str(procedure.get("risk_class", "bounded")).strip_edges()
		procedure["play_routing_tags"] = _string_array(procedure.get("play_routing_tags", []))
		if not procedure["procedure_id"].is_empty():
			procedures.append(procedure)
	current["procedures"] = procedures.slice(0, MAX_PROCEDURES)
	current["proposal_ids"] = _string_array(current.get("proposal_ids", []))
	return current

static func ensure_foundational_procedure(store: Dictionary) -> Dictionary:
	var current := normalize(store)
	if Array(current.get("procedures", [])).is_empty():
		current["procedures"] = [{
			"procedure_id": "proc_constitution_trace",
			"label": "Constitution trace comparison",
			"status": "foundational",
			"risk_class": "bounded",
			"play_routing_tags": ["witness", "route_choice", "return"]
		}]
		current["proposal_ids"] = ["proc_constitution_trace"]
	return normalize(current)

static func _string_array(values: Variant) -> Array[String]:
	var result: Array[String] = []
	if values is Array:
		for value in values:
			var text := str(value).strip_edges()
			if not text.is_empty() and not result.has(text):
				result.append(text)
	return result
