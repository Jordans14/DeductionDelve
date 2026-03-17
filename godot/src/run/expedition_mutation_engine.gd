class_name ExpeditionMutationEngine
extends RefCounted

static func build_mutation_plan(constitution: Dictionary, run_state: Node, trigger_type: String, trigger_context: Dictionary = {}) -> Dictionary:
	var envelope: Dictionary = Dictionary(constitution.get("mutation_envelope", {}))
	if envelope.is_empty():
		return {}
	var legal_triggers: Array = Array(envelope.get("triggers", []))
	if not legal_triggers.has(trigger_type):
		return {}
	var domain := _domain_for_trigger(trigger_type, trigger_context)
	var caps: Dictionary = Dictionary(envelope.get("caps", {}))
	var per_domain_cap := maxi(int(caps.get("per_domain", 3)), 1)
	var per_expedition_cap := maxi(int(caps.get("per_expedition", 8)), 1)
	var history: Array = Array(run_state.mutation_history).duplicate(true) if run_state != null else []
	var domain_budget: Dictionary = Dictionary(run_state.mutation_budget_by_domain).duplicate(true) if run_state != null else {}
	if history.size() >= per_expedition_cap:
		return {}
	if int(domain_budget.get(domain, 0)) >= per_domain_cap:
		return {}
	var mutation_index := history.size() + 1
	var visibility := _visibility_for_trigger(trigger_type, trigger_context)
	var public_meta := _build_public_meta(trigger_type, trigger_context)
	var truth_state_delta := _truth_state_delta_for_trigger(trigger_type, trigger_context)
	var event := {
		"mutation_id": "%s:%d" % [trigger_type, mutation_index],
		"trigger_type": trigger_type,
		"domain": domain,
		"visibility": visibility,
		"public_meta": public_meta,
		"actor_peer_id": int(trigger_context.get("actor_peer_id", -1)),
		"private_context": trigger_context.duplicate(true),
		"ordering_index": mutation_index,
		"constitution_hash": str(constitution.get("constitution_hash", "")),
		"cap_reason": "domain=%s %d/%d expedition=%d/%d" % [
			domain,
			int(domain_budget.get(domain, 0)) + 1,
			per_domain_cap,
			history.size() + 1,
			per_expedition_cap
		]
	}
	return {
		"event": event,
		"budget_delta": {domain: int(domain_budget.get(domain, 0)) + 1},
		"flags": {trigger_type: true},
		"truth_state_delta": truth_state_delta
	}

static func apply_mutation_plan(run_state: Node, event_log: Node, plan: Dictionary, tick: int = -1) -> Dictionary:
	if run_state == null or plan.is_empty():
		return {}
	var event: Dictionary = Dictionary(plan.get("event", {})).duplicate(true)
	if event.is_empty():
		return {}
	event["tick"] = tick
	if run_state.has_method("log_mutation"):
		run_state.log_mutation(event)
	else:
		run_state.mutation_history.append(event.duplicate(true))
	var budget_delta: Dictionary = Dictionary(plan.get("budget_delta", {}))
	for key in budget_delta.keys():
		run_state.mutation_budget_by_domain[str(key)] = int(budget_delta.get(key, 0))
	var flags: Dictionary = Dictionary(plan.get("flags", {}))
	for key in flags.keys():
		run_state.active_mutation_flags[str(key)] = bool(flags.get(key, false))
	var truth_state_delta: Dictionary = Dictionary(plan.get("truth_state_delta", {}))
	var truth_state: Dictionary = Dictionary(run_state.truth_state).duplicate(true)
	var public_trace_classes := Array(truth_state.get("public_trace_classes", [])).duplicate(true)
	var private_trace_classes := Array(truth_state.get("private_trace_classes", [])).duplicate(true)
	for trace_class_raw in Array(truth_state_delta.get("public_trace_classes", [])):
		var trace_class := str(trace_class_raw).strip_edges()
		if not trace_class.is_empty() and not public_trace_classes.has(trace_class):
			public_trace_classes.append(trace_class)
	for trace_class_raw in Array(truth_state_delta.get("private_trace_classes", [])):
		var trace_class := str(trace_class_raw).strip_edges()
		if not trace_class.is_empty() and not private_trace_classes.has(trace_class):
			private_trace_classes.append(trace_class)
	truth_state["public_trace_classes"] = public_trace_classes
	truth_state["private_trace_classes"] = private_trace_classes
	run_state.truth_state = truth_state
	run_state.mutation_caps_state["last_cap_reason"] = str(event.get("cap_reason", ""))
	run_state.mutation_visibility_state[str(event.get("mutation_id", ""))] = str(event.get("visibility", "private"))
	if event_log != null and event_log.has_method("add_mutation_event"):
		event_log.add_mutation_event(event)
	return event

static func summarize_mutations(mutation_history: Array) -> Dictionary:
	var summary := {
		"total": 0,
		"public": 0,
		"private": 0,
		"domains": {},
		"triggers": {},
		"public_surfaces": {}
	}
	for entry_raw in mutation_history:
		var entry: Dictionary = entry_raw
		summary["total"] = int(summary.get("total", 0)) + 1
		var visibility := str(entry.get("visibility", "private"))
		summary[visibility] = int(summary.get(visibility, 0)) + 1
		var domain := str(entry.get("domain", "")).strip_edges()
		if not domain.is_empty():
			var domains: Dictionary = Dictionary(summary.get("domains", {}))
			domains[domain] = int(domains.get(domain, 0)) + 1
			summary["domains"] = domains
		var trigger_type := str(entry.get("trigger_type", "")).strip_edges()
		if not trigger_type.is_empty():
			var triggers: Dictionary = Dictionary(summary.get("triggers", {}))
			triggers[trigger_type] = int(triggers.get(trigger_type, 0)) + 1
			summary["triggers"] = triggers
			if visibility == "public":
				var public_surfaces: Dictionary = Dictionary(summary.get("public_surfaces", {}))
				var trigger_surfaces: Array[String] = _string_array(public_surfaces.get(trigger_type, []))
				var surface_label := _surface_label_for_entry(trigger_type, Dictionary(entry.get("public_meta", {})))
				if not surface_label.is_empty() and not trigger_surfaces.has(surface_label):
					trigger_surfaces.append(surface_label)
				public_surfaces[trigger_type] = trigger_surfaces
				summary["public_surfaces"] = public_surfaces
	return summary

static func replay_signature(mutation_history: Array) -> String:
	var normalized: Array = []
	for entry_raw in mutation_history:
		var entry: Dictionary = entry_raw
		normalized.append({
			"mutation_id": str(entry.get("mutation_id", "")),
			"trigger_type": str(entry.get("trigger_type", "")),
			"domain": str(entry.get("domain", "")),
			"ordering_index": int(entry.get("ordering_index", -1)),
			"visibility": str(entry.get("visibility", "")),
			"public_meta": Dictionary(entry.get("public_meta", {})).duplicate(true)
		})
	return JSON.stringify(normalized).md5_text()

static func _domain_for_trigger(trigger_type: String, trigger_context: Dictionary) -> String:
	if trigger_context.has("domain"):
		return str(trigger_context.get("domain", "artifact_custody")).strip_edges()
	match trigger_type:
		"chamber_entered":
			return "chamber_state"
		"artifact_picked", "artifact_dropped", "artifact_stolen":
			return "artifact_custody"
		"extraction_window_started":
			return "route_state"
		"stability_threshold_crossed":
			return "stability"
		"trust_threshold_crossed":
			return "social_trust"
		"species_escalation":
			return "pressure_ecology"
		"covenant_activated":
			return "route_state"
		"transformation_threshold_crossed":
			return "readability_flags"
		_:
			return "trace_visibility"

static func _visibility_for_trigger(trigger_type: String, trigger_context: Dictionary) -> String:
	if trigger_context.has("visibility"):
		return str(trigger_context.get("visibility", "private"))
	match trigger_type:
		"artifact_picked", "artifact_dropped", "artifact_stolen", "extraction_window_started":
			return "public"
		"species_escalation", "covenant_activated", "transformation_threshold_crossed":
			return "public"
		_:
			return "private"

static func _build_public_meta(trigger_type: String, trigger_context: Dictionary) -> Dictionary:
	match trigger_type:
		"chamber_entered":
			return {
				"room_slot": int(trigger_context.get("room_slot", -1)),
				"room_type": str(trigger_context.get("room_type", ""))
			}
		"artifact_picked", "artifact_dropped", "artifact_stolen":
			return {
				"artifact_id": int(trigger_context.get("artifact_id", 0)),
				"room_slot": int(trigger_context.get("room_slot", -1))
			}
		"extraction_window_started":
			return {
				"artifact_id": int(trigger_context.get("artifact_id", 0)),
				"room_slot": int(trigger_context.get("room_slot", -1))
			}
		"species_escalation":
			return {
				"species_id": str(trigger_context.get("species_id", "")),
				"room_slot": int(trigger_context.get("room_slot", -1)),
				"mode": str(trigger_context.get("mode", ""))
			}
		"covenant_activated":
			return {
				"item_def_id": str(trigger_context.get("item_def_id", "")),
				"room_slot": int(trigger_context.get("room_slot", -1)),
				"activation_condition": str(trigger_context.get("activation_condition", ""))
			}
		"transformation_threshold_crossed":
			return {
				"item_def_id": str(trigger_context.get("item_def_id", "")),
				"room_slot": int(trigger_context.get("room_slot", -1)),
				"discernibility_flag": str(trigger_context.get("discernibility_flag", ""))
			}
		_:
			return {}

static func _truth_state_delta_for_trigger(trigger_type: String, trigger_context: Dictionary) -> Dictionary:
	match trigger_type:
		"chamber_entered":
			return {
				"public_trace_classes": [],
				"private_trace_classes": ["chamber_entry"]
			}
		"artifact_picked":
			return {
				"public_trace_classes": ["artifact_custody"],
				"private_trace_classes": ["custody_shift"]
			}
		"artifact_dropped":
			return {
				"public_trace_classes": ["artifact_custody"],
				"private_trace_classes": ["custody_release"]
			}
		"artifact_stolen":
			return {
				"public_trace_classes": ["artifact_custody", "witness"],
				"private_trace_classes": ["custody_shift"]
			}
		"extraction_window_started":
			return {
				"public_trace_classes": ["artifact_custody", "witness"],
				"private_trace_classes": ["inspection"]
			}
		"species_escalation":
			return {
				"public_trace_classes": ["pressure_ecology", str(trigger_context.get("species_id", "")).strip_edges()],
				"private_trace_classes": ["escalation"]
			}
		"covenant_activated":
			return {
				"public_trace_classes": ["bargain"],
				"private_trace_classes": ["covenant"]
			}
		"transformation_threshold_crossed":
			return {
				"public_trace_classes": ["transformation"],
				"private_trace_classes": ["threshold_crossing"]
			}
		_:
			return {
				"public_trace_classes": [],
				"private_trace_classes": []
			}

static func _surface_label_for_entry(trigger_type: String, public_meta: Dictionary) -> String:
	match trigger_type:
		"species_escalation":
			var species_id := str(public_meta.get("species_id", "")).strip_edges()
			var mode := str(public_meta.get("mode", "")).strip_edges()
			if species_id.is_empty():
				return ""
			return "%s:%s" % [species_id, mode] if not mode.is_empty() else species_id
		"covenant_activated", "transformation_threshold_crossed":
			return str(public_meta.get("item_def_id", "")).strip_edges()
		_:
			return ""

static func _string_array(values: Variant) -> Array[String]:
	var result: Array[String] = []
	if values is Array:
		for value in values:
			var text := str(value).strip_edges()
			if not text.is_empty() and not result.has(text):
				result.append(text)
	return result
