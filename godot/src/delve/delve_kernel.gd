class_name DelveKernel
extends RefCounted

const REGISTRY_SCRIPT = preload("res://src/delve/control_surface_registry.gd")
const WORLD_MODEL_SCRIPT = preload("res://src/delve/world_model.gd")
const HORIZON_PLANNER_SCRIPT = preload("res://src/delve/horizon_planner.gd")
const SIMULATOR_SCRIPT = preload("res://src/delve/delve_simulator.gd")
const DOCTRINE_ENGINE_SCRIPT = preload("res://src/delve/doctrine_engine.gd")
const INFLUENCE_LATTICE_SCRIPT = preload("res://src/delve/influence_lattice.gd")
const META_RESISTANCE_SCRIPT = preload("res://src/delve/meta_resistance_engine.gd")
const COUNTER_INTELLIGENCE_SCRIPT = preload("res://src/delve/counter_intelligence_engine.gd")
const CAUSAL_AUDIT_SCRIPT = preload("res://src/delve/causal_audit.gd")
const RUN_GENERATOR_SCRIPT = preload("res://src/gen/run_generator.gd")
const CONSTITUTION_COMPILER_SCRIPT = preload("res://src/gen/constitution_compiler.gd")
const FAIRNESS_CONSTITUTION_SCRIPT = preload("res://src/delve/constitution/fairness_constitution.gd")
const LOGIC_CONSTITUTION_SCRIPT = preload("res://src/delve/constitution/logic_constitution.gd")
const LEGIBILITY_CONSTITUTION_SCRIPT = preload("res://src/delve/constitution/legibility_constitution.gd")
const DEDUCTION_CONSTITUTION_SCRIPT = preload("res://src/delve/constitution/deduction_constitution.gd")
const COHERENCE_CONSTITUTION_SCRIPT = preload("res://src/delve/constitution/coherence_constitution.gd")
const EPISTEMIC_CONSTITUTION_SCRIPT = preload("res://src/delve/constitution/epistemic_constitution.gd")
const EXPEDITION_CONSTITUTION_SCHEMA_SCRIPT = preload("res://src/delve/constitution/expedition_constitution_schema.gd")
const MINDS := [
	preload("res://src/delve/minds/experimenter_mind.gd"),
	preload("res://src/delve/minds/warden_mind.gd"),
	preload("res://src/delve/minds/archivist_mind.gd"),
	preload("res://src/delve/minds/protocol_mind.gd"),
	preload("res://src/delve/minds/myth_mind.gd"),
	preload("res://src/delve/minds/fairness_mind.gd"),
	preload("res://src/delve/minds/logic_mind.gd")
]

static func plan_constitution(profile: Dictionary, session_context: Dictionary, seed_value: int, room_count: int) -> Dictionary:
	var world_model := WORLD_MODEL_SCRIPT.build_model(profile, session_context)
	var planner := HORIZON_PLANNER_SCRIPT.plan(world_model, session_context)
	var meta := META_RESISTANCE_SCRIPT.evaluate(world_model, session_context)
	var counter := COUNTER_INTELLIGENCE_SCRIPT.evaluate(profile, world_model, session_context)
	var run_identity := INFLUENCE_LATTICE_SCRIPT.synthesize(world_model, session_context, planner, seed_value, room_count, meta, counter)
	var public_doctrine: Dictionary = Dictionary(run_identity.get("public_safe_doctrine_summary", {}))
	var doctrine := _doctrine_from_lattice(run_identity, public_doctrine, session_context)
	var policy: Dictionary = REGISTRY_SCRIPT.clamp_policy(Dictionary(run_identity.get("control_surfaces", {})))
	policy = _apply_meta(policy, meta)
	policy = _apply_counter(policy, counter)
	var resolved_bundle := _resolve_emission_bundle(world_model, session_context, doctrine, policy, meta, counter, run_identity)
	doctrine = Dictionary(resolved_bundle.get("doctrine", doctrine)).duplicate(true)
	policy = REGISTRY_SCRIPT.clamp_policy(Dictionary(resolved_bundle.get("policy", policy)))
	var simulation := Dictionary(resolved_bundle.get("simulation", {})).duplicate(true)
	var violations: Array[String] = Array(resolved_bundle.get("violations", [])).duplicate()
	var summary: Dictionary = REGISTRY_SCRIPT.public_summary(policy)
	run_identity["control_surfaces"] = policy.duplicate(true)
	var mind_balance := _mind_balance_from_lattice(run_identity)
	var audit := CAUSAL_AUDIT_SCRIPT.build(
		seed_value,
		doctrine,
		policy,
		planner,
		world_model,
		mind_balance,
		simulation,
		violations,
		meta,
		counter,
		run_identity
	)
	var world_goals := _world_goals(planner, public_doctrine)
	var pressure_line := str(public_doctrine.get("pressure_line", _first_string(Array(summary.get("lines", [])), "")))
	var world_goal := str(public_doctrine.get("world_goal", _first_string(world_goals, "")))
	var generation_contract := _generation_contract(seed_value, room_count, world_model, doctrine, summary, public_doctrine, run_identity, policy)
	var compile_outputs: Dictionary = CONSTITUTION_COMPILER_SCRIPT.compile(
		seed_value,
		room_count,
		world_model,
		doctrine,
		summary,
		public_doctrine,
		run_identity,
		generation_contract,
		policy,
		simulation,
		violations,
		counter
	)
	doctrine = Dictionary(compile_outputs.get("doctrine", doctrine)).duplicate(true)
	generation_contract = Dictionary(compile_outputs.get("generation_surface", generation_contract)).duplicate(true)
	var constitution := EXPEDITION_CONSTITUTION_SCHEMA_SCRIPT.build(
		seed_value,
		room_count,
		world_model,
		doctrine,
		policy,
		summary,
		public_doctrine,
		world_goals,
		mind_balance,
		audit,
		run_identity,
		generation_contract,
		compile_outputs
	)
	var constitution_summary: Dictionary = Dictionary(constitution.get("constitution_summary", {}))
	if not constitution_summary.is_empty():
		pressure_line = str(constitution_summary.get("pressure_line", pressure_line))
		world_goal = str(constitution_summary.get("world_goal", world_goal))
	# Preserve the directive-era compatibility surface until runtime owners finish migrating.
	constitution["doctrine_family"] = str(doctrine.get("id", ""))
	constitution["doctrine_label"] = str(doctrine.get("label", ""))
	constitution["pressure_line"] = pressure_line
	constitution["world_goal"] = world_goal
	return constitution

static func plan_directive(profile: Dictionary, session_context: Dictionary, seed_value: int, room_count: int) -> Dictionary:
	return plan_constitution(profile, session_context, seed_value, room_count)

static func _generation_contract(seed_value: int, room_count: int, world_model: Dictionary, doctrine: Dictionary, summary: Dictionary, public_doctrine: Dictionary, run_identity: Dictionary, policy: Dictionary = {}) -> Dictionary:
	var social_model: Dictionary = Dictionary(world_model.get("social_model", {}))
	var route_model: Dictionary = Dictionary(world_model.get("route_model", {}))
	var economy_model: Dictionary = Dictionary(world_model.get("economy_model", {}))
	var cultural_model: Dictionary = Dictionary(world_model.get("cultural_model", {}))
	var economy_policy: Dictionary = Dictionary(policy.get("economy", {}))
	var relationship_routing := {
		"alliance_stability": int(social_model.get("alliance_stability", 0)),
		"trust_fragility": int(social_model.get("trust_fragility", 0)),
		"friendship_pressure": int(social_model.get("friendship_pressure", 0)),
		"loyalty_pressure": int(social_model.get("loyalty_pressure", 0)),
		"obligation_heat": int(social_model.get("obligation_heat", 0)),
		"escort_expectation": 1 if int(social_model.get("alliance_stability", 0)) >= 3 else 0,
		"rescue_convergence": 1 if int(social_model.get("friendship_pressure", 0)) >= 2 or int(social_model.get("alliance_stability", 0)) >= 4 else 0,
		"regroup_strain": 1 if int(social_model.get("trust_fragility", 0)) >= 2 else 0,
		"witness_suspicion": 1 if int(social_model.get("trust_fragility", 0)) >= 2 and int(social_model.get("loyalty_pressure", 0)) >= 2 else 0,
		"obligation_risk": 1 if int(social_model.get("obligation_heat", 0)) >= 3 or int(social_model.get("loyalty_pressure", 0)) >= 2 else 0
	}
	var relay_stress := int(route_model.get("relay_stress", 0)) + int(cultural_model.get("relay_memory_pressure", 0))
	var witness_pressure := Array(route_model.get("witness_network", [])).size() + int(cultural_model.get("witness_network_pressure", 0))
	var bottleneck_pressure := Array(route_model.get("relay_bottlenecks", [])).size() + int(cultural_model.get("relay_bottleneck_pressure", 0))
	var rumor_pressure := Array(route_model.get("rumor_shock", [])).size() + int(cultural_model.get("rumor_shock_pressure", 0))
	var cohort_pressure := Array(route_model.get("cohort_pressure", [])).size() + int(cultural_model.get("cohort_pressure", 0))
	var relay_routing := {
		"relay_stress": relay_stress,
		"witness_network_pressure": witness_pressure,
		"bottleneck_pressure": bottleneck_pressure,
		"rumor_shock_pressure": rumor_pressure,
		"cohort_pressure": cohort_pressure,
		"relay_overload": 1 if relay_stress >= 2 or bottleneck_pressure >= 1 else 0,
		"distributed_witness": 1 if witness_pressure >= 1 else 0,
		"regroup_friction": 1 if bottleneck_pressure >= 1 or cohort_pressure >= 1 else 0,
		"rumor_heat": 1 if rumor_pressure >= 1 else 0,
		"return_pressure": 1 if relay_stress >= 2 or bottleneck_pressure >= 1 or cohort_pressure >= 1 else 0
	}
	var cookbook_fragment_pressure := int(cultural_model.get("cookbook_fragment_count", 0)) + int(cultural_model.get("cookbook_fragment_heat", 0))
	var cookbook_network_pressure := int(cultural_model.get("cookbook_holder_depth", 0)) + int(cultural_model.get("cookbook_network_pressure", 0)) + int(cultural_model.get("cookbook_network_rumor", 0))
	var cookbook_redirection_pressure := int(cultural_model.get("cookbook_redirection_pressure", 0)) + int(cultural_model.get("cookbook_redirection_heat", 0))
	var cookbook_routing := {
		"fragment_pressure": cookbook_fragment_pressure,
		"holder_pressure": cookbook_network_pressure,
		"redirection_pressure": cookbook_redirection_pressure,
		"holder_state": str(cultural_model.get("cookbook_holder_state", "")),
		"fragmentary_reading": 1 if cookbook_fragment_pressure >= 2 else 0,
		"holder_network": 1 if cookbook_network_pressure >= 2 else 0,
		"counter_reading": 1 if cookbook_redirection_pressure >= 1 else 0,
		"anti_protocol_pull": 1 if cookbook_redirection_pressure >= 2 or str(cultural_model.get("cookbook_holder_state", "")) == "holder" else 0
	}
	var civilization_routing := {
		"legitimacy_custody": 1 if int(cultural_model.get("legitimacy_pressure", 0)) >= 2 or int(cultural_model.get("custody_pressure", 0)) >= 2 or int(cultural_model.get("burial_pressure", 0)) >= 2 else 0,
		"taboo_silence": 1 if int(cultural_model.get("taboo_heat", 0)) >= 2 or int(cultural_model.get("silence_pressure", 0)) >= 2 or int(cultural_model.get("unclassified_pressure", 0)) >= 2 else 0,
		"canon_conflict": 1 if int(cultural_model.get("false_canon_pressure", 0)) >= 2 or int(cultural_model.get("semantic_drift", 0)) >= 2 or int(cultural_model.get("forgery_pressure", 0)) >= 2 or int(cultural_model.get("revision_pressure", 0)) >= 2 else 0,
		"sacred_order": 1 if int(cultural_model.get("sacred_pressure", 0)) >= 2 or int(cultural_model.get("administrative_pressure", 0)) >= 2 else 0,
		"mourning_climate": 1 if int(cultural_model.get("martyr_pressure", 0)) >= 2 or int(cultural_model.get("melancholy_heat", 0)) >= 2 or int(cultural_model.get("ordinary_life_pressure", 0)) >= 2 else 0,
		"ontology_heat": 1 if int(cultural_model.get("counterfactual_heat", 0)) >= 2 or not str(cultural_model.get("uncertainty_philosophy", "")).strip_edges().is_empty() else 0
	}
	var market_routing := {
		"market_volatility": int(economy_policy.get("market_volatility", 0)),
		"prestige_pressure": int(economy_policy.get("prestige_pressure", 0)),
		"hoard_visibility": int(economy_policy.get("hoard_visibility", 0)),
		"scarcity_recovery": int(economy_policy.get("scarcity_recovery", 0)),
		"carrier_risk_bias": int(economy_policy.get("carrier_risk_bias", 0)),
		"extraction_debt": int(economy_model.get("extraction_debt", 0)),
		"hoard_heat": int(economy_model.get("hoard_heat", 0)),
		"neglect_heat": int(economy_model.get("neglect_heat", 0)),
		"distortion_heat": int(economy_model.get("distortion_heat", 0)),
		"recovery_credit": int(economy_model.get("recovery_credit", 0)),
		"prestige_climate": str(economy_model.get("prestige_climate", "")).strip_edges(),
		"carrier_risk_band": str(economy_model.get("carrier_risk_band", "")).strip_edges(),
		"active_regime_ids": _unique_strings(Array(economy_model.get("active_regime_ids", []))),
		"lifecycle_state_ids": _unique_strings(Array(economy_model.get("lifecycle_state_ids", []))),
		"market_lines": _unique_strings(Array(economy_model.get("market_lines", []))),
		"lifecycle_lines": _unique_strings(Array(economy_model.get("lifecycle_lines", [])))
	}
	var directive_view := {
		"seed": seed_value,
		"room_count": room_count,
		"protocol_state": str(Dictionary(world_model.get("session_model", {})).get("protocol_state", "")),
		"doctrine_family": str(doctrine.get("id", "")),
		"public_summary": {
			"protocol_state": str(Dictionary(world_model.get("session_model", {})).get("protocol_state", "")),
			"doctrine": str(doctrine.get("label", "")),
			"dominant_minds": Array(public_doctrine.get("dominant_minds", [])).duplicate(true),
			"dominant_forces": Array(public_doctrine.get("dominant_forces", [])).duplicate(true),
			"dominant_domains": Array(public_doctrine.get("dominant_domains", [])).duplicate(true),
			"pacing_profile": str(public_doctrine.get("pacing_profile", "")),
			"pacing_label": str(public_doctrine.get("pacing_label", "")),
			"pressure_grammar": Array(public_doctrine.get("pressure_grammar", [])).duplicate(true),
			"symbolic_motifs": Array(public_doctrine.get("symbolic_motifs", [])).duplicate(true),
			"item_ecology_bias": str(public_doctrine.get("item_ecology_bias", "")),
			"group_tension_bias": str(public_doctrine.get("group_tension_bias", "")),
			"archive_tone": str(public_doctrine.get("archive_tone", "")),
			"convergence_axis": str(public_doctrine.get("convergence_axis", ""))
		},
		"surface_summary": summary.duplicate(true),
		"run_identity": run_identity.duplicate(true),
		"generation_contract": {
			"relationship_routing": relationship_routing,
			"relay_routing": relay_routing,
			"cookbook_routing": cookbook_routing,
			"civilization_routing": civilization_routing,
			"market_routing": market_routing
		}
	}
	return RUN_GENERATOR_SCRIPT.new().build_generation_contract(seed_value, directive_view)

static func _resolve_emission_bundle(world_model: Dictionary, session_context: Dictionary, doctrine: Dictionary, policy: Dictionary, meta: Dictionary, counter: Dictionary, run_identity: Dictionary) -> Dictionary:
	var resolved_doctrine: Dictionary = doctrine.duplicate(true)
	var resolved_policy: Dictionary = REGISTRY_SCRIPT.clamp_policy(policy)
	var simulation: Dictionary = {}
	var violations: Array[String] = []
	for _attempt in range(4):
		simulation = SIMULATOR_SCRIPT.evaluate(world_model, session_context, resolved_doctrine, resolved_policy, meta, counter)
		violations = _constitution_violations({
			"policy": resolved_policy,
			"doctrine": resolved_doctrine,
			"simulation": simulation,
			"world_model": world_model,
			"counter": counter,
			"run_identity": run_identity
		})
		if violations.is_empty():
			break
		var next_doctrine := _stabilize_doctrine(resolved_doctrine, violations)
		var next_policy := _stabilize_policy(resolved_policy, violations)
		if JSON.stringify(next_doctrine) == JSON.stringify(resolved_doctrine) and JSON.stringify(next_policy) == JSON.stringify(resolved_policy):
			break
		resolved_doctrine = next_doctrine
		resolved_policy = next_policy
	return {
		"doctrine": resolved_doctrine,
		"policy": resolved_policy,
		"simulation": simulation,
		"violations": violations
	}

static func _stabilize_doctrine(doctrine: Dictionary, violations: Array[String]) -> Dictionary:
	var next: Dictionary = doctrine.duplicate(true)
	var focus_tags := _unique_strings(Array(next.get("focus_tags", [])))
	if _has_violation(violations, "crowd-focused doctrine conflicts with exposure protocol"):
		focus_tags.erase("crowd")
	if _has_violation(violations, "solitude-focused doctrine conflicts with expedition protocol"):
		focus_tags.erase("solitude")
	next["focus_tags"] = focus_tags
	return next

static func _stabilize_policy(policy: Dictionary, violations: Array[String]) -> Dictionary:
	var next := REGISTRY_SCRIPT.clamp_policy(policy)
	if _has_violation(violations, "policy exceeds fairness tolerance") or _has_violation(violations, "pressure stack is too punitive"):
		next = REGISTRY_SCRIPT.apply_push(next, "generation", "traversal_harshness", -1)
		next = REGISTRY_SCRIPT.apply_push(next, "ecology", "inhabitant_pressure", -1)
		next = REGISTRY_SCRIPT.apply_push(next, "economy", "resource_austerity", -1)
		next = REGISTRY_SCRIPT.apply_push(next, "economy", "recovery_cushion", 1)
		next = REGISTRY_SCRIPT.apply_push(next, "generation", "rescue_geometry", 1)
	if _has_violation(violations, "recovery routes are too constrained"):
		next = REGISTRY_SCRIPT.apply_push(next, "generation", "rescue_geometry", 1)
		next = REGISTRY_SCRIPT.apply_push(next, "economy", "recovery_cushion", 1)
	if _has_violation(violations, "too much ambiguity for a readable public game") or _has_violation(violations, "deduction clarity fell below minimum"):
		next = REGISTRY_SCRIPT.apply_push(next, "generation", "witness_exposure", 1)
		next = REGISTRY_SCRIPT.apply_push(next, "social", "private_evidence_ratio", -1)
		next = REGISTRY_SCRIPT.apply_push(next, "social", "hidden_role_density", -1)
		next = REGISTRY_SCRIPT.apply_push(next, "social", "blame_ambiguity", -1)
	if _has_violation(violations, "evidence visibility is too suppressed"):
		next = REGISTRY_SCRIPT.apply_push(next, "generation", "witness_exposure", 1)
		next = REGISTRY_SCRIPT.apply_push(next, "social", "private_evidence_ratio", -1)
	if _has_violation(violations, "ambiguity collapsed into noise"):
		next = REGISTRY_SCRIPT.apply_push(next, "social", "blame_ambiguity", 1)
		next = REGISTRY_SCRIPT.apply_push(next, "social", "private_evidence_ratio", 1)
	if _has_violation(violations, "ritual doctrine without ritual pressure is incoherent"):
		next = REGISTRY_SCRIPT.apply_push(next, "generation", "ritual_frequency", 1)
		next = REGISTRY_SCRIPT.apply_push(next, "culture", "archive_emphasis", 1)
	if _has_violation(violations, "burden doctrine without obligation pressure is incoherent"):
		next = REGISTRY_SCRIPT.apply_push(next, "social", "obligation_pressure", 1)
	if _has_violation(violations, "candidate breaks logic tolerance") or _has_violation(violations, "loop and bottleneck pressure are both too extreme"):
		next = REGISTRY_SCRIPT.apply_push(next, "generation", "loop_probability", -1)
		next = REGISTRY_SCRIPT.apply_push(next, "generation", "bottleneck_severity", -1)
	if _has_violation(violations, "anomaly pressure is too explicit for public-layer play"):
		next = REGISTRY_SCRIPT.apply_push(next, "ecology", "anomaly_contamination", -1)
	return REGISTRY_SCRIPT.clamp_policy(next)

static func _doctrine_from_lattice(run_identity: Dictionary, public_doctrine: Dictionary, session_context: Dictionary) -> Dictionary:
	return {
		"id": str(public_doctrine.get("doctrine_family", "delve_trial")),
		"label": str(public_doctrine.get("doctrine_label", "Delve Trial")),
		"focus_tags": _focus_tags_from_lattice(run_identity, session_context),
		"run_identity": run_identity.duplicate(true)
	}

static func _focus_tags_from_lattice(run_identity: Dictionary, session_context: Dictionary) -> Array[String]:
	var tags: Array[String] = []
	var pressure_ids := _entry_ids(Array(run_identity.get("pressure_grammar", [])))
	var force_order := Array(run_identity.get("force_order", []))
	var motif_ids := _entry_ids(Array(run_identity.get("symbolic_motifs", [])))
	var pacing_id := str(Dictionary(run_identity.get("pacing_profile", {})).get("id", "steady"))
	var protocol_state := str(session_context.get("protocol_state", ""))
	var dominant_force := str(Dictionary(force_order[0] if not force_order.is_empty() else {}).get("id", "trial"))
	if pressure_ids.has("exposure") or dominant_force == "trial":
		tags.append("public_read")
	if pressure_ids.has("fragmentation") or pressure_ids.has("misdirection") or dominant_force == "deception":
		tags.append("split_read")
	if dominant_force == "memory" or motif_ids.has("archive_scars"):
		tags.append("ritual")
	if dominant_force == "containment" or motif_ids.has("burden_halos"):
		tags.append("burden")
	if pressure_ids.has("convergence") and protocol_state != "Exposure Protocol":
		tags.append("crowd")
	if pacing_id == "calm" and str(Dictionary(run_identity.get("convergence_fragmentation", {})).get("axis", "")) == "fragmentation" and protocol_state != "Expedition Protocol":
		tags.append("solitude")
	return _unique_strings(tags)

static func _mind_balance_from_lattice(run_identity: Dictionary) -> Dictionary:
	var influence := {}
	var notes: Array[String] = []
	for mind_raw in Array(run_identity.get("active_minds", [])):
		var mind_state: Dictionary = Dictionary(mind_raw)
		var label := str(mind_state.get("label", mind_state.get("id", "")))
		influence[label] = int(mind_state.get("score", 0))
		if notes.size() < 5:
			var role_name := str(mind_state.get("role", "")).strip_edges()
			var mood := str(mind_state.get("mood", "")).strip_edges()
			var summary := "%s as %s" % [label, role_name] if not role_name.is_empty() else label
			if not mood.is_empty():
				summary = "%s (%s)" % [summary, mood]
			notes.append(summary)
	var pacing_label := str(Dictionary(run_identity.get("pacing_profile", {})).get("label", "")).strip_edges()
	if not pacing_label.is_empty():
		notes.append("Pacing: %s" % pacing_label)
	var pressure_labels := _entry_labels(Array(run_identity.get("pressure_grammar", [])), 2)
	if not pressure_labels.is_empty():
		notes.append("Pressure verbs: %s" % ", ".join(pressure_labels))
	return {
		"influence": influence,
		"notes": notes
	}

static func _world_goals(planner: Dictionary, public_doctrine: Dictionary) -> Array[String]:
	var world_goals: Array[String] = []
	for lane in ["immediate", "run", "session"]:
		for goal in Array(Dictionary(planner).get(lane, [])):
			var text := str(goal).strip_edges()
			if not text.is_empty() and not world_goals.has(text):
				world_goals.append(text)
			if world_goals.size() >= 4:
				break
		if world_goals.size() >= 4:
			break
	var summary_goal := str(public_doctrine.get("world_goal", "")).strip_edges()
	if not summary_goal.is_empty() and not world_goals.has(summary_goal):
		world_goals.insert(0, summary_goal)
	return world_goals.slice(0, 4)

static func _aggregate_minds(world_model: Dictionary, session_context: Dictionary, planner: Dictionary, meta: Dictionary, counter: Dictionary) -> Dictionary:
	var doctrine_biases := {}
	var surface_pushes := REGISTRY_SCRIPT.empty_policy()
	var notes: Array[String] = []
	var influence := {}
	for mind_script in MINDS:
		var proposal: Dictionary = mind_script.propose(world_model, session_context, planner, meta, counter)
		var name := str(proposal.get("name", "mind"))
		influence[name] = int(proposal.get("weight", 1))
		for doctrine_id in Dictionary(proposal.get("doctrine_biases", {})).keys():
			doctrine_biases[doctrine_id] = int(doctrine_biases.get(doctrine_id, 0)) + int(Dictionary(proposal.get("doctrine_biases", {})).get(doctrine_id, 0))
		surface_pushes = REGISTRY_SCRIPT.apply_push_bundle(surface_pushes, Dictionary(proposal.get("surface_pushes", {})))
		for note_raw in Array(proposal.get("notes", [])):
			var note := str(note_raw).strip_edges()
			if not note.is_empty() and not notes.has(note):
				notes.append(note)
	return {
		"doctrine_biases": doctrine_biases,
		"surface_pushes": surface_pushes,
		"notes": notes,
		"influence": influence
	}

static func _apply_meta(policy: Dictionary, meta: Dictionary) -> Dictionary:
	var next := REGISTRY_SCRIPT.clamp_policy(policy)
	if int(Dictionary(meta.get("dominance", {})).get("weight", 0)) >= 3:
		next = REGISTRY_SCRIPT.apply_push(next, "culture", "archive_emphasis", 1)
		next = REGISTRY_SCRIPT.apply_push(next, "social", "blame_ambiguity", -1)
	if int(meta.get("misclassification_pressure", 0)) >= 1:
		next = REGISTRY_SCRIPT.apply_push(next, "generation", "loop_probability", 1)
		next = REGISTRY_SCRIPT.apply_push(next, "social", "blame_ambiguity", 1)
	if int(meta.get("overcorrection_pressure", 0)) >= 1:
		next = REGISTRY_SCRIPT.apply_push(next, "generation", "witness_exposure", 1)
		next = REGISTRY_SCRIPT.apply_push(next, "generation", "rescue_geometry", 1)
	return next

static func _apply_counter(policy: Dictionary, counter: Dictionary) -> Dictionary:
	var next := REGISTRY_SCRIPT.clamp_policy(policy)
	var anomaly: Dictionary = Dictionary(counter.get("anomaly", {}))
	if not str(anomaly.get("pressure", "")).strip_edges().is_empty():
		next = REGISTRY_SCRIPT.apply_push(next, "ecology", "anomaly_contamination", 1)
	return next

static func _constitution_violations(bundle: Dictionary) -> Array[String]:
	var violations: Array[String] = []
	for constitution_script in [
		FAIRNESS_CONSTITUTION_SCRIPT,
		LOGIC_CONSTITUTION_SCRIPT,
		LEGIBILITY_CONSTITUTION_SCRIPT,
		DEDUCTION_CONSTITUTION_SCRIPT,
		COHERENCE_CONSTITUTION_SCRIPT,
		EPISTEMIC_CONSTITUTION_SCRIPT
	]:
		violations.append_array(constitution_script.validate(bundle))
	return violations

static func _first_string(values: Array, fallback: String = "") -> String:
	for value in values:
		var text := str(value).strip_edges()
		if not text.is_empty():
			return text
	return fallback

static func _entry_ids(entries: Array) -> Array[String]:
	var result: Array[String] = []
	for entry_raw in entries:
		var entry: Dictionary = Dictionary(entry_raw)
		var id := str(entry.get("id", "")).strip_edges()
		if not id.is_empty() and not result.has(id):
			result.append(id)
	return result

static func _entry_labels(entries: Array, limit: int) -> Array[String]:
	var result: Array[String] = []
	for entry_raw in entries:
		var entry: Dictionary = Dictionary(entry_raw)
		var label := str(entry.get("label", "")).strip_edges()
		if label.is_empty():
			continue
		result.append(label)
		if result.size() >= limit:
			break
	return result

static func _unique_strings(values: Array) -> Array[String]:
	var result: Array[String] = []
	for value in values:
		var text := str(value).strip_edges()
		if not text.is_empty() and not result.has(text):
			result.append(text)
	return result

static func _has_violation(violations: Array[String], text: String) -> bool:
	for violation_raw in violations:
		if str(violation_raw) == text:
			return true
	return false
