class_name ItemSynergyService
extends RefCounted

const LATENT_KEYS: Array[String] = [
	"traversal",
	"rescue",
	"deception",
	"burden",
	"witness_visibility",
	"ritual_significance",
	"instability",
	"scarcity",
	"anti_protocol_potential"
]

const BUILD_AXES: Array[String] = [
	"Traversal build",
	"Rescue build",
	"Deception build",
	"Burden build",
	"Control build",
	"Anomaly build",
	"Exposure build"
]

const COMBO_CONTRACT_VERSION := 1

func resolve(item_def_ids: Array[String], gameplay_profiles: Dictionary, context: Dictionary = {}) -> Dictionary:
	var ordered_ids: Array[String] = item_def_ids.duplicate()
	ordered_ids.sort()
	var latent_totals := {}
	for key in LATENT_KEYS:
		latent_totals[key] = 0
	var build_scores := {
		"Traversal build": 0,
		"Rescue build": 0,
		"Deception build": 0,
		"Burden build": 0,
		"Control build": 0,
		"Anomaly build": 0,
		"Exposure build": 0
	}
	var behavior_signals: Array[String] = []
	var synergy_labels: Array[String] = []
	var ritual_hooks: Array[String] = []
	var anomaly_hooks: Array[String] = []
	var protocol_hooks: Array[String] = []
	var resource_signals: Array[String] = []
	var runtime_affordances := {
		"light_scale": 1.0,
		"move_speed_mult": 1.0,
		"jump_velocity_mult": 1.0,
		"carry_speed_mult": 1.0,
		"noise_trace_interval": 90,
		"footprint_interval": 48,
		"footprint_scale": 0.8
	}

	for item_def_id in ordered_ids:
		var profile: Dictionary = Dictionary(gameplay_profiles.get(item_def_id, {}))
		var latent_dimensions: Dictionary = Dictionary(profile.get("latent_dimensions", {}))
		for key in LATENT_KEYS:
			latent_totals[key] = int(latent_totals.get(key, 0)) + int(latent_dimensions.get(key, 0))
		behavior_signals = _merge_unique(behavior_signals, _string_array(profile.get("behavior_signals", [])))
		ritual_hooks = _merge_unique(ritual_hooks, _string_array(profile.get("ritual_hooks", [])))
		anomaly_hooks = _merge_unique(anomaly_hooks, _string_array(profile.get("anomaly_hooks", [])))
		protocol_hooks = _merge_unique(protocol_hooks, _string_array(profile.get("protocol_hooks", [])))
		resource_signals = _merge_unique(resource_signals, _string_array(profile.get("resource_hooks", [])))
		var affordances: Dictionary = Dictionary(profile.get("runtime_affordances", {}))
		runtime_affordances["light_scale"] = float(runtime_affordances.get("light_scale", 1.0)) * float(affordances.get("light_scale", 1.0))
		runtime_affordances["move_speed_mult"] = float(runtime_affordances.get("move_speed_mult", 1.0)) * float(affordances.get("move_speed_mult", 1.0))
		runtime_affordances["jump_velocity_mult"] = float(runtime_affordances.get("jump_velocity_mult", 1.0)) * float(affordances.get("jump_velocity_mult", 1.0))
		runtime_affordances["carry_speed_mult"] = float(runtime_affordances.get("carry_speed_mult", 1.0)) * float(affordances.get("carry_speed_mult", 1.0))
		runtime_affordances["noise_trace_interval"] = mini(int(runtime_affordances.get("noise_trace_interval", 90)), int(affordances.get("noise_trace_interval", 90)))
		runtime_affordances["footprint_interval"] = mini(int(runtime_affordances.get("footprint_interval", 48)), int(affordances.get("footprint_interval", 48)))
		runtime_affordances["footprint_scale"] = maxf(float(runtime_affordances.get("footprint_scale", 0.8)), float(affordances.get("footprint_scale", 0.8)))
		_score_item(profile, build_scores)

	var context_state := _apply_context(build_scores, behavior_signals, protocol_hooks, resource_signals, anomaly_hooks, context)
	behavior_signals = Array(context_state.get("behavior_signals", behavior_signals))
	protocol_hooks = Array(context_state.get("protocol_hooks", protocol_hooks))
	resource_signals = Array(context_state.get("resource_signals", resource_signals))
	anomaly_hooks = Array(context_state.get("anomaly_hooks", anomaly_hooks))
	var synergy_state := _apply_synergies(ordered_ids, build_scores, behavior_signals, synergy_labels, ritual_hooks, anomaly_hooks, protocol_hooks, resource_signals, context)
	behavior_signals = Array(synergy_state.get("behavior_signals", behavior_signals))
	synergy_labels = Array(synergy_state.get("synergy_labels", synergy_labels))
	ritual_hooks = Array(synergy_state.get("ritual_hooks", ritual_hooks))
	anomaly_hooks = Array(synergy_state.get("anomaly_hooks", anomaly_hooks))
	protocol_hooks = Array(synergy_state.get("protocol_hooks", protocol_hooks))
	resource_signals = Array(synergy_state.get("resource_signals", resource_signals))
	var feature_model := _build_feature_model(
		latent_totals,
		build_scores,
		behavior_signals,
		synergy_labels,
		ritual_hooks,
		anomaly_hooks,
		protocol_hooks,
		resource_signals,
		context
	)
	var combo_contract := _build_combo_contract(
		ordered_ids,
		synergy_labels,
		behavior_signals,
		ritual_hooks,
		anomaly_hooks,
		protocol_hooks,
		resource_signals,
		Dictionary(feature_model.get("feature_scores", {})),
		Array(feature_model.get("model_pressure", [])),
		context
	)

	return {
		"latent_totals": latent_totals,
		"behavior_signals": behavior_signals,
		"synergy_labels": synergy_labels,
		"ritual_hooks": ritual_hooks,
		"anomaly_hooks": anomaly_hooks,
		"protocol_hooks": protocol_hooks,
		"resource_signals": resource_signals,
		"feature_scores": Dictionary(feature_model.get("feature_scores", {})).duplicate(true),
		"feature_signals": Array(feature_model.get("feature_signals", [])).duplicate(),
		"build_stability": int(feature_model.get("build_stability", 0)),
		"risk_profile": str(feature_model.get("risk_profile", "mixed")).strip_edges(),
		"model_pressure": Array(feature_model.get("model_pressure", [])).duplicate(),
		"combo_contract_version": int(combo_contract.get("combo_contract_version", COMBO_CONTRACT_VERSION)),
		"combo_contract_digest": str(combo_contract.get("combo_contract_digest", "")).strip_edges(),
		"combo_family_ids": Array(combo_contract.get("combo_family_ids", [])).duplicate(true),
		"combo_entries": Array(combo_contract.get("combo_entries", [])).duplicate(true),
		"combo_pressure_tags": Array(combo_contract.get("combo_pressure_tags", [])).duplicate(true),
		"public_surface_tags": Array(combo_contract.get("public_surface_tags", [])).duplicate(true),
		"build_scores": build_scores,
		"build_identity": _pick_build_identity(build_scores),
		"runtime_affordances": runtime_affordances
	}

func _score_item(profile: Dictionary, build_scores: Dictionary) -> void:
	var latent_dimensions: Dictionary = Dictionary(profile.get("latent_dimensions", {}))
	_add_score(build_scores, "Traversal build", int(latent_dimensions.get("traversal", 0)))
	_add_score(build_scores, "Rescue build", int(latent_dimensions.get("rescue", 0)))
	_add_score(build_scores, "Deception build", int(latent_dimensions.get("deception", 0)))
	_add_score(build_scores, "Burden build", int(latent_dimensions.get("burden", 0)))
	_add_score(build_scores, "Control build", int(latent_dimensions.get("witness_visibility", 0)) / 2 + int(profile.get("control_pull", 0)))
	_add_score(build_scores, "Anomaly build", int(latent_dimensions.get("anti_protocol_potential", 0)) + int(latent_dimensions.get("instability", 0)) / 2)
	_add_score(build_scores, "Exposure build", int(latent_dimensions.get("scarcity", 0)) + int(latent_dimensions.get("instability", 0)) / 2)

func _apply_context(
	build_scores: Dictionary,
	behavior_signals: Array[String],
	protocol_hooks: Array[String],
	resource_signals: Array[String],
	anomaly_hooks: Array[String],
	context: Dictionary
) -> Dictionary:
	var tool_counts: Dictionary = Dictionary(context.get("tool_counts", {}))
	var bombs := int(tool_counts.get("bomb", 0))
	var ropes := int(tool_counts.get("rope", 0))
	var carrying_artifact := bool(context.get("carrying_artifact", false))
	var ghost_active := bool(context.get("ghost_active", false))
	var protocol_state := str(context.get("protocol_state", "")).strip_edges()
	if ropes > 0:
		behavior_signals = _merge_unique(behavior_signals, ["recovery lines", "fallback route"])
		resource_signals = _merge_unique(resource_signals, ["rope reserves"])
		_add_score(build_scores, "Traversal build", 1)
		_add_score(build_scores, "Rescue build", 1)
	if bombs > 0:
		behavior_signals = _merge_unique(behavior_signals, ["hazard forcing", "panic leverage"])
		resource_signals = _merge_unique(resource_signals, ["bomb reserves"])
		_add_score(build_scores, "Control build", 2)
		_add_score(build_scores, "Exposure build", 1)
	if carrying_artifact:
		behavior_signals = _merge_unique(behavior_signals, ["burden commitment", "visible answer"])
		resource_signals = _merge_unique(resource_signals, ["burden line"])
		_add_score(build_scores, "Burden build", 2)
		_add_score(build_scores, "Rescue build", 1)
	if ghost_active:
		behavior_signals = _merge_unique(behavior_signals, ["fear pressure", "panic response"])
		anomaly_hooks = _merge_unique(anomaly_hooks, ["attention under pursuit"])
		_add_score(build_scores, "Exposure build", 2)
		_add_score(build_scores, "Anomaly build", 1)
	match protocol_state:
		"Expedition Protocol":
			protocol_hooks = _merge_unique(protocol_hooks, ["witness-loaded pressure", "public answer lines"])
			_add_score(build_scores, "Control build", 1)
		"Fracture Protocol":
			protocol_hooks = _merge_unique(protocol_hooks, ["split accountability", "fragmented pressure"])
			_add_score(build_scores, "Traversal build", 1)
			_add_score(build_scores, "Deception build", 1)
		"Intimate Protocol":
			protocol_hooks = _merge_unique(protocol_hooks, ["pair pressure", "mutual exposure"])
			_add_score(build_scores, "Rescue build", 1)
			_add_score(build_scores, "Burden build", 1)
		"Exposure Protocol":
			protocol_hooks = _merge_unique(protocol_hooks, ["direct pressure", "solitary extraction"])
			_add_score(build_scores, "Exposure build", 2)
			_add_score(build_scores, "Anomaly build", 1)
	return {
		"behavior_signals": behavior_signals,
		"protocol_hooks": protocol_hooks,
		"resource_signals": resource_signals,
		"anomaly_hooks": anomaly_hooks
	}

func _apply_synergies(
	item_def_ids: Array[String],
	build_scores: Dictionary,
	behavior_signals: Array[String],
	synergy_labels: Array[String],
	ritual_hooks: Array[String],
	anomaly_hooks: Array[String],
	protocol_hooks: Array[String],
	resource_signals: Array[String],
	context: Dictionary
) -> Dictionary:
	var carrying_artifact := bool(context.get("carrying_artifact", false))
	if _has_items(item_def_ids, ["lantern_snuffer", "decoy_emitter"]):
		synergy_labels.append("shadow-decoy lattice")
		behavior_signals = _merge_unique(behavior_signals, ["false trail", "attention split"])
		anomaly_hooks = _merge_unique(anomaly_hooks, ["pattern skew"])
		_add_score(build_scores, "Deception build", 2)
		_add_score(build_scores, "Anomaly build", 1)
	if _has_items(item_def_ids, ["heavy_boots", "zipline_kit"]):
		synergy_labels.append("commitment bridge")
		behavior_signals = _merge_unique(behavior_signals, ["rescue geometry", "route control", "commitment signal"])
		protocol_hooks = _merge_unique(protocol_hooks, ["visible route answer"])
		_add_score(build_scores, "Traversal build", 2)
		_add_score(build_scores, "Rescue build", 2)
		_add_score(build_scores, "Control build", 1)
	if _has_items(item_def_ids, ["timeline_bookmark", "lantern_snuffer"]):
		synergy_labels.append("private archive ritual")
		ritual_hooks = _merge_unique(ritual_hooks, ["quiet revision", "forbidden note"])
		anomaly_hooks = _merge_unique(anomaly_hooks, ["unstable recall"])
		_add_score(build_scores, "Anomaly build", 2)
		_add_score(build_scores, "Burden build", 1)
	if _has_items(item_def_ids, ["timeline_bookmark", "zipline_kit"]):
		synergy_labels.append("route-memory lattice")
		behavior_signals = _merge_unique(behavior_signals, ["route memory", "rescue reconstruction"])
		resource_signals = _merge_unique(resource_signals, ["anchor map"])
		_add_score(build_scores, "Traversal build", 2)
		_add_score(build_scores, "Rescue build", 1)
	if _has_items(item_def_ids, ["heavy_boots", "decoy_emitter"]):
		synergy_labels.append("loud false route")
		behavior_signals = _merge_unique(behavior_signals, ["route noise", "public misdirection"])
		_add_score(build_scores, "Deception build", 1)
		_add_score(build_scores, "Exposure build", 1)
	if _has_items(item_def_ids, ["custody_seal", "burden_sling"]):
		synergy_labels.append("sealed burden line")
		behavior_signals = _merge_unique(behavior_signals, ["custody relief", "escort answer"])
		ritual_hooks = _merge_unique(ritual_hooks, ["witnessed burden", "shared vow"])
		_add_score(build_scores, "Burden build", 2)
		_add_score(build_scores, "Rescue build", 1)
		_add_score(build_scores, "Control build", 1)
	if _has_items(item_def_ids, ["witness_chime", "timeline_bookmark"]):
		synergy_labels.append("public ledger")
		behavior_signals = _merge_unique(behavior_signals, ["forensic answer", "witness pressure"])
		protocol_hooks = _merge_unique(protocol_hooks, ["public certainty line"])
		_add_score(build_scores, "Control build", 2)
		_add_score(build_scores, "Exposure build", 1)
	if _has_items(item_def_ids, ["echo_lure", "lantern_snuffer"]):
		synergy_labels.append("hushed echo maze")
		behavior_signals = _merge_unique(behavior_signals, ["redirected pursuit", "shadow bait"])
		anomaly_hooks = _merge_unique(anomaly_hooks, ["hushed echo", "pattern break"])
		_add_score(build_scores, "Deception build", 2)
		_add_score(build_scores, "Anomaly build", 2)
	if _has_items(item_def_ids, ["echo_lure", "decoy_emitter"]):
		synergy_labels.append("echo fork")
		behavior_signals = _merge_unique(behavior_signals, ["route fork", "double bait"])
		protocol_hooks = _merge_unique(protocol_hooks, ["watch overcommitment"])
		_add_score(build_scores, "Deception build", 2)
		_add_score(build_scores, "Exposure build", 1)
	if _has_items(item_def_ids, ["hush_bead", "lantern_snuffer"]):
		synergy_labels.append("hushed burden line")
		behavior_signals = _merge_unique(behavior_signals, ["quiet burden", "trace restraint"])
		ritual_hooks = _merge_unique(ritual_hooks, ["hidden answer"])
		_add_score(build_scores, "Deception build", 1)
		_add_score(build_scores, "Control build", 1)
	if _has_items(item_def_ids, ["flare_ampoule", "witness_chime"]):
		synergy_labels.append("public witness bloom")
		behavior_signals = _merge_unique(behavior_signals, ["forced witness line", "loud verification"])
		protocol_hooks = _merge_unique(protocol_hooks, ["public answer flare"])
		_add_score(build_scores, "Control build", 2)
		_add_score(build_scores, "Exposure build", 2)
	if _has_items(item_def_ids, ["oath_ribbon", "burden_sling"]):
		synergy_labels.append("vowed burden line")
		behavior_signals = _merge_unique(behavior_signals, ["declared handoff", "escort vow"])
		ritual_hooks = _merge_unique(ritual_hooks, ["shared oath"])
		_add_score(build_scores, "Burden build", 2)
		_add_score(build_scores, "Rescue build", 2)
		_add_score(build_scores, "Control build", 1)
	if _has_items(item_def_ids, ["doubt_ink", "decoy_emitter"]):
		synergy_labels.append("smear route")
		behavior_signals = _merge_unique(behavior_signals, ["public doubt", "trace misdirection"])
		anomaly_hooks = _merge_unique(anomaly_hooks, ["ink scatter"])
		_add_score(build_scores, "Deception build", 2)
		_add_score(build_scores, "Exposure build", 1)
	if _has_items(item_def_ids, ["echo_molt", "echo_lure"]):
		synergy_labels.append("threshold echo break")
		behavior_signals = _merge_unique(behavior_signals, ["threshold feint", "unstable escape"])
		anomaly_hooks = _merge_unique(anomaly_hooks, ["echo shell", "pattern break"])
		_add_score(build_scores, "Anomaly build", 2)
		_add_score(build_scores, "Traversal build", 1)
	if carrying_artifact and _has_items(item_def_ids, ["zipline_kit"]):
		synergy_labels.append("burden line")
		behavior_signals = _merge_unique(behavior_signals, ["burden rescue", "route answer"])
		resource_signals = _merge_unique(resource_signals, ["artifact line"])
		_add_score(build_scores, "Burden build", 1)
		_add_score(build_scores, "Rescue build", 1)
	return {
		"behavior_signals": behavior_signals,
		"synergy_labels": synergy_labels,
		"ritual_hooks": ritual_hooks,
		"anomaly_hooks": anomaly_hooks,
		"protocol_hooks": protocol_hooks,
		"resource_signals": resource_signals
	}

func _build_feature_model(
	latent_totals: Dictionary,
	build_scores: Dictionary,
	behavior_signals: Array[String],
	synergy_labels: Array[String],
	ritual_hooks: Array[String],
	anomaly_hooks: Array[String],
	protocol_hooks: Array[String],
	resource_signals: Array[String],
	context: Dictionary
) -> Dictionary:
	var feature_scores := {
		"burden_commitment": int(latent_totals.get("burden", 0)),
		"rescue_geometry": int(latent_totals.get("rescue", 0)),
		"route_commitment": int(latent_totals.get("traversal", 0)),
		"visibility_pressure": int(latent_totals.get("witness_visibility", 0)),
		"ritual_curiosity": int(latent_totals.get("ritual_significance", 0)),
		"anomaly_curiosity": int(latent_totals.get("anti_protocol_potential", 0)) + int(latent_totals.get("instability", 0)),
		"deception_pressure": int(latent_totals.get("deception", 0)),
		"scarcity_tolerance": int(latent_totals.get("scarcity", 0)),
		"fallback_capacity": 0,
		"control_posture": 0,
		"spectacle_appetite": 0,
		"resource_caution": 0
	}
	var tool_counts: Dictionary = Dictionary(context.get("tool_counts", {}))
	feature_scores["fallback_capacity"] += int(tool_counts.get("rope", 0)) + int(tool_counts.get("bomb", 0))
	feature_scores["control_posture"] += int(build_scores.get("Control build", 0))
	if bool(context.get("carrying_artifact", false)):
		feature_scores["burden_commitment"] += 2
		feature_scores["visibility_pressure"] += 1
		feature_scores["spectacle_appetite"] += 1
	if bool(context.get("ghost_active", false)):
		feature_scores["anomaly_curiosity"] += 1
		feature_scores["scarcity_tolerance"] += 1
		feature_scores["resource_caution"] += 1
	var protocol_state := str(context.get("protocol_state", "")).strip_edges()
	if protocol_state == "Exposure Protocol":
		feature_scores["scarcity_tolerance"] += 1
		feature_scores["resource_caution"] += 1
		feature_scores["control_posture"] += 1
	elif protocol_state == "Intimate Protocol":
		feature_scores["rescue_geometry"] += 1
		feature_scores["burden_commitment"] += 1
	elif protocol_state == "Expedition Protocol":
		feature_scores["visibility_pressure"] += 1
		feature_scores["spectacle_appetite"] += 1
	for signal_value in behavior_signals:
		var signal_text := str(signal_value).to_lower()
		if signal_text.find("rescue") != -1:
			feature_scores["rescue_geometry"] += 1
		if signal_text.find("burden") != -1:
			feature_scores["burden_commitment"] += 1
		if signal_text.find("route") != -1 or signal_text.find("commitment") != -1:
			feature_scores["route_commitment"] += 1
		if signal_text.find("attention") != -1 or signal_text.find("visible") != -1 or signal_text.find("public") != -1:
			feature_scores["visibility_pressure"] += 1
		if signal_text.find("false") != -1 or signal_text.find("misdirection") != -1 or signal_text.find("panic lure") != -1:
			feature_scores["deception_pressure"] += 1
		if signal_text.find("recovery") != -1 or signal_text.find("fallback") != -1:
			feature_scores["fallback_capacity"] += 1
		if signal_text.find("public") != -1 or signal_text.find("visible") != -1:
			feature_scores["spectacle_appetite"] += 1
		if signal_text.find("scarcity") != -1 or signal_text.find("weight") != -1:
			feature_scores["resource_caution"] += 1
	for signal_value in resource_signals:
		var signal_text := str(signal_value).to_lower()
		if signal_text.find("artifact") != -1 or signal_text.find("burden") != -1 or signal_text.find("weight") != -1:
			feature_scores["burden_commitment"] += 1
			feature_scores["resource_caution"] += 1
		if signal_text.find("rope") != -1 or signal_text.find("bomb") != -1 or signal_text.find("anchor") != -1:
			feature_scores["fallback_capacity"] += 1
		if signal_text.find("pulse") != -1 or signal_text.find("trace") != -1:
			feature_scores["visibility_pressure"] += 1
	for hook_value in ritual_hooks:
		if not str(hook_value).strip_edges().is_empty():
			feature_scores["ritual_curiosity"] += 1
	for hook_value in anomaly_hooks:
		if not str(hook_value).strip_edges().is_empty():
			feature_scores["anomaly_curiosity"] += 1
	for hook_value in protocol_hooks:
		var hook_text := str(hook_value).to_lower()
		if hook_text.find("public") != -1 or hook_text.find("witness") != -1:
			feature_scores["visibility_pressure"] += 1
			feature_scores["spectacle_appetite"] += 1
		if hook_text.find("split") != -1 or hook_text.find("fragment") != -1:
			feature_scores["deception_pressure"] += 1
		if hook_text.find("pair") != -1 or hook_text.find("mutual") != -1:
			feature_scores["rescue_geometry"] += 1
		if hook_text.find("discipline") != -1 or hook_text.find("exposure") != -1:
			feature_scores["resource_caution"] += 1
			feature_scores["control_posture"] += 1
	var feature_signals: Array[String] = []
	if int(feature_scores.get("burden_commitment", 0)) >= 5:
		feature_signals.append("burden answer")
	if int(feature_scores.get("rescue_geometry", 0)) >= 5:
		feature_signals.append("rescue answer geometry")
	if int(feature_scores.get("route_commitment", 0)) >= 5:
		feature_signals.append("route commitment answer")
	if int(feature_scores.get("visibility_pressure", 0)) >= 5:
		feature_signals.append("witness-heavy answer")
	if int(feature_scores.get("deception_pressure", 0)) >= 4:
		feature_signals.append("misdirection answer")
	if int(feature_scores.get("fallback_capacity", 0)) >= 4:
		feature_signals.append("fallback-heavy answer")
	if int(feature_scores.get("ritual_curiosity", 0)) >= 4:
		feature_signals.append("ritual curiosity")
	if int(feature_scores.get("anomaly_curiosity", 0)) >= 4:
		feature_signals.append("anomaly curiosity")
	if int(feature_scores.get("control_posture", 0)) >= 4:
		feature_signals.append("control appetite")
	if int(feature_scores.get("spectacle_appetite", 0)) >= 4:
		feature_signals.append("public answer appetite")
	if int(feature_scores.get("resource_caution", 0)) >= 4:
		feature_signals.append("resource caution")
	if synergy_labels.size() >= 2:
		feature_signals.append("stacked synergy pressure")
	var sorted_builds: Array[Dictionary] = []
	for build_label in BUILD_AXES:
		sorted_builds.append({"label": build_label, "score": int(build_scores.get(build_label, 0))})
	sorted_builds.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if int(a.get("score", 0)) == int(b.get("score", 0)):
			return str(a.get("label", "")) < str(b.get("label", ""))
		return int(a.get("score", 0)) > int(b.get("score", 0))
	)
	var top_score := int(Dictionary(sorted_builds[0]).get("score", 0))
	var second_score := int(Dictionary(sorted_builds[1]).get("score", 0)) if sorted_builds.size() > 1 else 0
	var build_stability := maxi(top_score - second_score, 0)
	var risk_profile := "mixed"
	if int(feature_scores.get("anomaly_curiosity", 0)) >= 6 or int(feature_scores.get("deception_pressure", 0)) >= 5:
		risk_profile = "volatile"
	elif int(feature_scores.get("spectacle_appetite", 0)) >= 5 and int(feature_scores.get("visibility_pressure", 0)) >= 5:
		risk_profile = "performative"
	elif int(feature_scores.get("burden_commitment", 0)) >= 6 and int(feature_scores.get("rescue_geometry", 0)) >= 5:
		risk_profile = "committed"
	elif int(feature_scores.get("fallback_capacity", 0)) >= 5 and int(feature_scores.get("route_commitment", 0)) >= 5:
		risk_profile = "prepared"
	elif int(feature_scores.get("resource_caution", 0)) >= 5 and int(feature_scores.get("control_posture", 0)) >= 4:
		risk_profile = "disciplined"
	elif int(feature_scores.get("visibility_pressure", 0)) >= 5:
		risk_profile = "exposed"
	elif int(feature_scores.get("scarcity_tolerance", 0)) >= 4:
		risk_profile = "austere"
	var model_pressure: Array[String] = []
	if int(feature_scores.get("rescue_geometry", 0)) >= 5 and int(feature_scores.get("burden_commitment", 0)) >= 5:
		model_pressure.append("burden-rescue answer")
	if int(feature_scores.get("route_commitment", 0)) >= 5 and int(feature_scores.get("control_posture", 0)) >= 4:
		model_pressure.append("route-control answer")
	if int(feature_scores.get("deception_pressure", 0)) >= 4 and int(feature_scores.get("visibility_pressure", 0)) >= 4:
		model_pressure.append("public misdirection answer")
	if int(feature_scores.get("anomaly_curiosity", 0)) >= 5 and int(feature_scores.get("ritual_curiosity", 0)) >= 4:
		model_pressure.append("ritual anomaly answer")
	if int(feature_scores.get("resource_caution", 0)) >= 4 and int(feature_scores.get("fallback_capacity", 0)) >= 4:
		model_pressure.append("scarcity fallback answer")
	return {
		"feature_scores": feature_scores,
		"feature_signals": _merge_unique([], feature_signals),
		"build_stability": build_stability,
		"risk_profile": risk_profile,
		"model_pressure": _merge_unique([], model_pressure)
	}

func _build_combo_contract(
	ordered_ids: Array[String],
	synergy_labels: Array[String],
	behavior_signals: Array[String],
	ritual_hooks: Array[String],
	anomaly_hooks: Array[String],
	protocol_hooks: Array[String],
	resource_signals: Array[String],
	feature_scores: Dictionary,
	model_pressure: Array[String],
	context: Dictionary
) -> Dictionary:
	var combo_entries: Array[Dictionary] = []
	for synergy_label_raw in synergy_labels:
		var synergy_label := str(synergy_label_raw).strip_edges()
		if synergy_label.is_empty():
			continue
		var source_item_ids := _combo_source_item_ids(synergy_label)
		source_item_ids.sort()
		var family_slug := _slug(synergy_label)
		var family_id := "combo_family_%s" % family_slug
		var effect_tags := _combo_effect_tags(synergy_label, behavior_signals, ritual_hooks, anomaly_hooks, protocol_hooks, resource_signals)
		var public_surface_tags := ["combo_%s" % family_slug]
		for effect_tag in effect_tags:
			if public_surface_tags.size() >= 3:
				break
			if effect_tag.find("public") != -1 or effect_tag.find("route") != -1 or effect_tag.find("burden") != -1 or effect_tag.find("rescue") != -1 or effect_tag.find("witness") != -1:
				public_surface_tags.append(effect_tag)
		combo_entries.append({
			"combo_id": "combo_%s" % family_slug,
			"family_id": family_id,
			"source_item_ids": source_item_ids,
			"source_hooks": _combo_source_hooks(synergy_label, effect_tags),
			"context_tags": _combo_context_tags(context),
			"effect_tags": effect_tags,
			"public_surface_tags": public_surface_tags,
			"lifecycle_candidate_id": family_id,
			"visibility": "private"
		})
	combo_entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return str(a.get("combo_id", "")) < str(b.get("combo_id", ""))
	)
	var combo_family_ids: Array[String] = []
	var combo_public_surface_tags: Array[String] = []
	for combo_entry in combo_entries:
		var family_id := str(Dictionary(combo_entry).get("family_id", "")).strip_edges()
		if not family_id.is_empty() and not combo_family_ids.has(family_id):
			combo_family_ids.append(family_id)
		for tag_variant in Array(Dictionary(combo_entry).get("public_surface_tags", [])):
			var tag := str(tag_variant).strip_edges()
			if not tag.is_empty() and not combo_public_surface_tags.has(tag):
				combo_public_surface_tags.append(tag)
	var combo_pressure_tags: Array[String] = []
	for tag_variant in model_pressure:
		var pressure_tag := _slug(str(tag_variant))
		if not pressure_tag.is_empty():
			var public_pressure_tag := "pressure_%s" % pressure_tag
			if not combo_pressure_tags.has(public_pressure_tag):
				combo_pressure_tags.append(public_pressure_tag)
	for family_id in combo_family_ids:
		var family_tag := family_id.trim_prefix("combo_family_")
		if not family_tag.is_empty():
			var combo_tag := "combo_%s" % family_tag
			if not combo_pressure_tags.has(combo_tag):
				combo_pressure_tags.append(combo_tag)
	var digest_source := {
		"combo_contract_version": COMBO_CONTRACT_VERSION,
		"ordered_ids": ordered_ids.duplicate(),
		"combo_entries": combo_entries.duplicate(true),
		"combo_pressure_tags": combo_pressure_tags.duplicate(),
		"feature_scores": feature_scores.duplicate(true)
	}
	var private_entry_digest := JSON.stringify(combo_entries).md5_text() if not combo_entries.is_empty() else ""
	return {
		"combo_contract_version": COMBO_CONTRACT_VERSION,
		"combo_contract_digest": JSON.stringify(digest_source).md5_text(),
		"combo_family_ids": combo_family_ids,
		"combo_entries": combo_entries,
		"combo_pressure_tags": combo_pressure_tags,
		"public_surface_tags": combo_public_surface_tags,
		"private_entry_digest": private_entry_digest,
		"combo_contract_ref": {
			"combo_contract_version": COMBO_CONTRACT_VERSION,
			"combo_contract_digest": JSON.stringify(digest_source).md5_text(),
			"combo_family_ids": combo_family_ids.duplicate(),
			"combo_pressure_tags": combo_pressure_tags.duplicate(),
			"public_surface_tags": combo_public_surface_tags.duplicate(),
			"private_entry_digest": private_entry_digest
		}
	}

func _pick_build_identity(build_scores: Dictionary) -> String:
	var best := ""
	var best_score := -1
	for build_id in BUILD_AXES:
		var score := int(build_scores.get(build_id, 0))
		if score > best_score:
			best_score = score
			best = build_id
	return best if best_score > 0 else "Mixed build"

func _combo_source_item_ids(synergy_label: String) -> Array[String]:
	match synergy_label:
		"shadow-decoy lattice":
			return ["decoy_emitter", "lantern_snuffer"]
		"commitment bridge":
			return ["heavy_boots", "zipline_kit"]
		"private archive ritual":
			return ["lantern_snuffer", "timeline_bookmark"]
		"route-memory lattice":
			return ["timeline_bookmark", "zipline_kit"]
		"loud false route":
			return ["decoy_emitter", "heavy_boots"]
		"sealed burden line":
			return ["burden_sling", "custody_seal"]
		"public ledger":
			return ["timeline_bookmark", "witness_chime"]
		"hushed echo maze":
			return ["echo_lure", "lantern_snuffer"]
		"echo fork":
			return ["decoy_emitter", "echo_lure"]
		"hushed burden line":
			return ["hush_bead", "lantern_snuffer"]
		"public witness bloom":
			return ["flare_ampoule", "witness_chime"]
		"vowed burden line":
			return ["burden_sling", "oath_ribbon"]
		"smear route":
			return ["decoy_emitter", "doubt_ink"]
		"threshold echo break":
			return ["echo_lure", "echo_molt"]
		"burden line":
			return ["zipline_kit"]
	return []

func _combo_effect_tags(
	synergy_label: String,
	behavior_signals: Array[String],
	ritual_hooks: Array[String],
	anomaly_hooks: Array[String],
	protocol_hooks: Array[String],
	resource_signals: Array[String]
) -> Array[String]:
	var source_values: Array[String] = []
	source_values.append_array(behavior_signals)
	source_values.append_array(ritual_hooks)
	source_values.append_array(anomaly_hooks)
	source_values.append_array(protocol_hooks)
	source_values.append_array(resource_signals)
	var effect_tags: Array[String] = []
	for value in source_values:
		var slug := _slug(str(value))
		if not slug.is_empty() and not effect_tags.has(slug):
			effect_tags.append(slug)
	if effect_tags.is_empty():
		effect_tags.append(_slug(synergy_label))
	effect_tags.sort()
	return effect_tags.slice(0, 6)

func _combo_source_hooks(synergy_label: String, effect_tags: Array[String]) -> Array[String]:
	var source_hooks: Array[String] = ["synergy_label:%s" % _slug(synergy_label)]
	for effect_tag in effect_tags:
		if effect_tag.find("ritual") != -1 or effect_tag.find("oath") != -1 or effect_tag.find("vow") != -1:
			if not source_hooks.has("ritual_hooks"):
				source_hooks.append("ritual_hooks")
		if effect_tag.find("echo") != -1 or effect_tag.find("anomaly") != -1 or effect_tag.find("pattern") != -1 or effect_tag.find("ink") != -1:
			if not source_hooks.has("anomaly_hooks"):
				source_hooks.append("anomaly_hooks")
		if effect_tag.find("public") != -1 or effect_tag.find("witness") != -1 or effect_tag.find("route") != -1 or effect_tag.find("control") != -1:
			if not source_hooks.has("protocol_hooks"):
				source_hooks.append("protocol_hooks")
		if effect_tag.find("artifact") != -1 or effect_tag.find("burden") != -1 or effect_tag.find("anchor") != -1:
			if not source_hooks.has("resource_signals"):
				source_hooks.append("resource_signals")
	if source_hooks.size() == 1:
		source_hooks.append("behavior_signals")
	return source_hooks

func _combo_context_tags(context: Dictionary) -> Array[String]:
	var context_tags: Array[String] = []
	var protocol_state := str(context.get("protocol_state", "")).strip_edges()
	if not protocol_state.is_empty():
		context_tags.append("protocol_%s" % _slug(protocol_state))
	if bool(context.get("carrying_artifact", false)):
		context_tags.append("carrying_artifact")
	if bool(context.get("ghost_active", false)):
		context_tags.append("ghost_active")
	var tool_counts: Dictionary = Dictionary(context.get("tool_counts", {}))
	for tool_key in tool_counts.keys():
		var count := int(tool_counts.get(tool_key, 0))
		if count > 0:
			context_tags.append("%s_%d" % [_slug(str(tool_key)), count])
	context_tags.sort()
	return context_tags

func _slug(value: String) -> String:
	var text := value.to_lower().strip_edges()
	if text.is_empty():
		return ""
	var result := ""
	var previous_underscore := false
	for ch in text:
		var code := ch.unicode_at(0)
		var is_lower := code >= 97 and code <= 122
		var is_digit := code >= 48 and code <= 57
		if is_lower or is_digit:
			result += ch
			previous_underscore = false
		elif not previous_underscore:
			result += "_"
			previous_underscore = true
	while result.begins_with("_"):
		result = result.substr(1)
	while result.ends_with("_"):
		result = result.substr(0, result.length() - 1)
	return result

func _has_items(item_def_ids: Array[String], required: Array[String]) -> bool:
	for item_def_id in required:
		if not item_def_ids.has(item_def_id):
			return false
	return true

func _add_score(scores: Dictionary, build_id: String, amount: int) -> void:
	if amount == 0:
		return
	scores[build_id] = int(scores.get(build_id, 0)) + amount

func _string_array(values: Variant) -> Array[String]:
	var result: Array[String] = []
	if values is Array:
		for value in values:
			var text := str(value).strip_edges()
			if not text.is_empty() and not result.has(text):
				result.append(text)
	return result

func _merge_unique(base: Array[String], extra: Array[String]) -> Array[String]:
	var result: Array[String] = base.duplicate()
	for value in extra:
		if not result.has(value):
			result.append(value)
	return result
