class_name VisualGovernance
extends RefCounted

const SHELL_TITLE := "The Delve Protocol"
const MOTION_HIERARCHY: Array[String] = [
	"player",
	"artifact",
	"hazard",
	"inhabitant",
	"environment",
	"cosmetic"
]
const MOTION_Z_INDEX := {
	"player": 60,
	"artifact": 50,
	"hazard": 40,
	"inhabitant": 30,
	"environment": 10,
	"cosmetic": 0
}
const VISUAL_BUDGET_LIMITS := {
	"particle_density": 18,
	"emissive_lighting": 6,
	"landmark_scale": 1.65,
	"cosmetic_brightness": 0.78
}
const ROOM_PACKET_SCHEMA_VERSION := 2
const SIGNAL_COMPRESSION_SCHEMA_VERSION := 1
const EXPEDITION_MUTATION_STACK_SLOTS: Array[String] = [
	"silhouette_layer",
	"carrier_frame_layer",
	"trace_overlay_layer",
	"aura_layer",
	"burden_signature_layer",
	"gesture_glyph_layer",
	"route_residue_layer",
	"transformation_state_layer"
]
const SYMBOL_FAMILIES := {
	"threshold": {
		"shell": "||",
		"segments": [
			[Vector2(-10, -12), Vector2(-10, 12)],
			[Vector2(10, -12), Vector2(10, 12)],
			[Vector2(-6, 0), Vector2(6, 0)]
		],
		"color": Color(0.89, 0.78, 0.40, 0.7)
	},
	"burden": {
		"shell": "[]",
		"segments": [
			[Vector2(-10, -8), Vector2(-10, 8)],
			[Vector2(10, -8), Vector2(10, 8)],
			[Vector2(-10, -8), Vector2(10, -8)],
			[Vector2(-10, 8), Vector2(10, 8)]
		],
		"color": Color(0.96, 0.60, 0.28, 0.7)
	},
	"witness": {
		"shell": "o",
		"segments": [
			[Vector2(-8, 0), Vector2(-4, -8)],
			[Vector2(-4, -8), Vector2(4, -8)],
			[Vector2(4, -8), Vector2(8, 0)],
			[Vector2(8, 0), Vector2(4, 8)],
			[Vector2(4, 8), Vector2(-4, 8)],
			[Vector2(-4, 8), Vector2(-8, 0)],
			[Vector2(-2, 0), Vector2(2, 0)]
		],
		"color": Color(0.70, 0.88, 0.92, 0.68)
	},
	"recursion": {
		"shell": "~",
		"segments": [
			[Vector2(-12, -8), Vector2(0, -2)],
			[Vector2(0, -2), Vector2(12, -8)],
			[Vector2(-12, 8), Vector2(0, 2)],
			[Vector2(0, 2), Vector2(12, 8)]
		],
		"color": Color(0.64, 0.74, 0.96, 0.68)
	}
}
const BRANCH_VISUALS := {
	"watcher_steps": {
		"far_shape": "arches",
		"mid_rhythm": "watch_ribs",
		"close_symbols": ["threshold", "witness"],
		"palette": {
			"background": Color(0.10, 0.10, 0.16, 0.92),
			"midground": Color(0.22, 0.26, 0.36, 0.50),
			"foreground": Color(0.72, 0.62, 0.42, 0.55),
			"accent": Color(0.80, 0.72, 0.42, 0.70)
		},
		"particle_density": 10,
		"emissive_lighting": 4,
		"landmark_scale": 1.15,
		"cosmetic_brightness": 0.72
	},
	"sundered_span": {
		"far_shape": "broken_spans",
		"mid_rhythm": "fracture_struts",
		"close_symbols": ["threshold", "burden"],
		"palette": {
			"background": Color(0.12, 0.08, 0.10, 0.94),
			"midground": Color(0.30, 0.22, 0.18, 0.52),
			"foreground": Color(0.66, 0.38, 0.28, 0.55),
			"accent": Color(0.84, 0.44, 0.32, 0.72)
		},
		"particle_density": 8,
		"emissive_lighting": 3,
		"landmark_scale": 1.25,
		"cosmetic_brightness": 0.70
	},
	"relay_hollows": {
		"far_shape": "vaults",
		"mid_rhythm": "relay_lanterns",
		"close_symbols": ["witness", "recursion"],
		"palette": {
			"background": Color(0.08, 0.11, 0.14, 0.92),
			"midground": Color(0.18, 0.30, 0.30, 0.48),
			"foreground": Color(0.44, 0.70, 0.74, 0.50),
			"accent": Color(0.68, 0.86, 0.92, 0.72)
		},
		"particle_density": 12,
		"emissive_lighting": 5,
		"landmark_scale": 1.05,
		"cosmetic_brightness": 0.74
	},
	"grave_lattice": {
		"far_shape": "vault_graves",
		"mid_rhythm": "lattice",
		"close_symbols": ["burden", "recursion"],
		"palette": {
			"background": Color(0.08, 0.07, 0.10, 0.94),
			"midground": Color(0.24, 0.20, 0.26, 0.52),
			"foreground": Color(0.58, 0.46, 0.64, 0.55),
			"accent": Color(0.82, 0.58, 0.76, 0.68)
		},
		"particle_density": 9,
		"emissive_lighting": 4,
		"landmark_scale": 1.10,
		"cosmetic_brightness": 0.68
	},
	"forge_veins": {
		"far_shape": "veins",
		"mid_rhythm": "forge_channels",
		"close_symbols": ["burden", "threshold"],
		"palette": {
			"background": Color(0.12, 0.09, 0.08, 0.94),
			"midground": Color(0.34, 0.22, 0.14, 0.50),
			"foreground": Color(0.76, 0.52, 0.30, 0.54),
			"accent": Color(0.96, 0.72, 0.36, 0.76)
		},
		"particle_density": 11,
		"emissive_lighting": 5,
		"landmark_scale": 1.18,
		"cosmetic_brightness": 0.72
	},
	"oath_terraces": {
		"far_shape": "terraces",
		"mid_rhythm": "oath_pillars",
		"close_symbols": ["threshold", "burden", "witness"],
		"palette": {
			"background": Color(0.10, 0.08, 0.12, 0.94),
			"midground": Color(0.34, 0.28, 0.20, 0.52),
			"foreground": Color(0.76, 0.66, 0.46, 0.56),
			"accent": Color(0.94, 0.82, 0.56, 0.76)
		},
		"particle_density": 9,
		"emissive_lighting": 4,
		"landmark_scale": 1.22,
		"cosmetic_brightness": 0.73
	},
	"murmur_warrens": {
		"far_shape": "warrens",
		"mid_rhythm": "murmur_threads",
		"close_symbols": ["recursion", "witness", "threshold"],
		"palette": {
			"background": Color(0.08, 0.08, 0.12, 0.95),
			"midground": Color(0.22, 0.24, 0.30, 0.52),
			"foreground": Color(0.54, 0.56, 0.72, 0.56),
			"accent": Color(0.76, 0.80, 0.94, 0.74)
		},
		"particle_density": 10,
		"emissive_lighting": 5,
		"landmark_scale": 1.08,
		"cosmetic_brightness": 0.72
	}
}
const PROTOCOL_VISUALS := {
	"expedition": {
		"light_mult": 1.15,
		"particle_mult": 1.05,
		"openness": 1.10,
		"staging": "broad",
		"midground_density": 1.0,
		"background_scale": 1.1,
		"shell_tone": "public"
	},
	"fracture": {
		"light_mult": 0.95,
		"particle_mult": 0.90,
		"openness": 0.92,
		"staging": "split",
		"midground_density": 1.1,
		"background_scale": 0.95,
		"shell_tone": "fractured"
	},
	"intimate": {
		"light_mult": 0.88,
		"particle_mult": 0.82,
		"openness": 0.78,
		"staging": "tight",
		"midground_density": 1.18,
		"background_scale": 0.88,
		"shell_tone": "close"
	},
	"exposure": {
		"light_mult": 0.70,
		"particle_mult": 0.76,
		"openness": 0.64,
		"staging": "oppressive",
		"midground_density": 1.25,
		"background_scale": 0.80,
		"shell_tone": "oppressive"
	}
}

func shell_title() -> String:
	return SHELL_TITLE

func mutation_stack_slots() -> Array[String]:
	return EXPEDITION_MUTATION_STACK_SLOTS.duplicate()

func motion_hierarchy() -> Array[String]:
	return MOTION_HIERARCHY.duplicate()

func motion_priority_for(kind: String) -> int:
	return int(MOTION_Z_INDEX.get(kind, 0))

func validate_motion_hierarchy() -> Array[String]:
	var failures: Array[String] = []
	for index in range(MOTION_HIERARCHY.size() - 1):
		var current := MOTION_HIERARCHY[index]
		var next := MOTION_HIERARCHY[index + 1]
		if motion_priority_for(current) <= motion_priority_for(next):
			failures.append("motion hierarchy priority for %s must exceed %s" % [current, next])
	return failures

func validate_mutation_stack(stack: Dictionary) -> Array[String]:
	var failures: Array[String] = []
	var major_layers := 0
	for slot_id in stack.keys():
		var key := str(slot_id)
		if not EXPEDITION_MUTATION_STACK_SLOTS.has(key):
			failures.append("unknown mutation stack slot %s" % key)
			continue
		var entry: Dictionary = Dictionary(stack.get(slot_id, {}))
		if bool(entry.get("major_signal", false)):
			major_layers += 1
		if bool(entry.get("hides_artifact_carrier", false)):
			failures.append("mutation stack must not hide artifact carrier readability")
		if bool(entry.get("suppresses_public_trace", false)):
			failures.append("mutation stack must not suppress public trace readability")
	if major_layers > 3:
		failures.append("mutation stack exceeds the major signal readability budget")
	return failures

func normalize_protocol_state(protocol_state: String) -> String:
	var key := protocol_state.strip_edges().to_lower()
	if key.is_empty():
		return "expedition"
	match key:
		"expedition", "fracture", "intimate", "exposure":
			return key
		_:
			return "expedition"

func branch_visual_profile(branch_family_id: String, protocol_state: String) -> Dictionary:
	var branch := Dictionary(BRANCH_VISUALS.get(branch_family_id, BRANCH_VISUALS["watcher_steps"])).duplicate(true)
	var protocol := Dictionary(PROTOCOL_VISUALS.get(normalize_protocol_state(protocol_state), PROTOCOL_VISUALS["expedition"])).duplicate(true)
	var palette := Dictionary(branch.get("palette", {})).duplicate(true)
	var irregularity := 0.18
	var scar_density := 0.34
	var anchor_spread := 1.0
	match branch_family_id:
		"sundered_span":
			irregularity = 0.32
			scar_density = 0.48
			anchor_spread = 1.12
		"relay_hollows":
			irregularity = 0.22
			scar_density = 0.26
			anchor_spread = 0.88
		"grave_lattice":
			irregularity = 0.28
			scar_density = 0.42
			anchor_spread = 0.92
		"forge_veins":
			irregularity = 0.24
			scar_density = 0.46
			anchor_spread = 1.06
		"oath_terraces":
			irregularity = 0.16
			scar_density = 0.30
			anchor_spread = 0.96
		"murmur_warrens":
			irregularity = 0.34
			scar_density = 0.40
			anchor_spread = 0.84
	palette["background"] = Color(palette.get("background", Color(0.08, 0.09, 0.12, 0.92))).darkened(1.0 - float(protocol.get("light_mult", 1.0)) * 0.4)
	palette["accent"] = _clamp_color_energy(Color(palette.get("accent", Color.WHITE)), float(branch.get("cosmetic_brightness", 0.72)))
	return {
		"branch_family_id": branch_family_id,
		"protocol_state": normalize_protocol_state(protocol_state),
		"far_shape": str(branch.get("far_shape", "arches")),
		"mid_rhythm": str(branch.get("mid_rhythm", "watch_ribs")),
		"close_symbols": Array(branch.get("close_symbols", [])).duplicate(),
		"palette": palette,
		"particle_density": clampi(int(round(float(branch.get("particle_density", 10)) * float(protocol.get("particle_mult", 1.0)))), 4, int(VISUAL_BUDGET_LIMITS["particle_density"])),
		"emissive_lighting": clampi(int(round(float(branch.get("emissive_lighting", 4)) * lerpf(0.85, 1.15, float(protocol.get("light_mult", 1.0)) - 0.7))), 2, int(VISUAL_BUDGET_LIMITS["emissive_lighting"])),
		"landmark_scale": minf(float(branch.get("landmark_scale", 1.0)) * float(protocol.get("background_scale", 1.0)), float(VISUAL_BUDGET_LIMITS["landmark_scale"])),
		"cosmetic_brightness": minf(float(branch.get("cosmetic_brightness", 0.72)), float(VISUAL_BUDGET_LIMITS["cosmetic_brightness"])),
		"macro_irregularity": irregularity,
		"scar_density": scar_density,
		"anchor_spread": anchor_spread,
		"weathering": lerpf(0.72, 1.18, scar_density),
		"protocol_profile": protocol
	}

func room_visual_packet(room: Dictionary) -> Dictionary:
	var branch_context: Dictionary = Dictionary(room.get("branch_context", {}))
	var branch_family_id := str(room.get("branch_family_id", branch_context.get("id", "watcher_steps")))
	var protocol_state := str(room.get("protocol_state", branch_context.get("protocol_state", "expedition")))
	var visual_profile := branch_visual_profile(branch_family_id, protocol_state)
	var run_identity_summary: Dictionary = Dictionary(branch_context.get("run_identity_summary", {}))
	var room_type := str(room.get("type", "traversal"))
	var hazard := str(room.get("hazard", "none"))
	var symbols := Array(visual_profile.get("close_symbols", [])).duplicate()
	match room_type:
		"evidence":
			_ensure_symbol(symbols, "witness")
			_ensure_symbol(symbols, "threshold")
		"hazard":
			_ensure_symbol(symbols, "burden")
		_:
			_ensure_symbol(symbols, "threshold")
	if hazard == "collapse" or hazard == "push":
		_ensure_symbol(symbols, "recursion")
	for symbol_family in _motif_symbol_families(_string_array(run_identity_summary.get("symbolic_motifs", []))):
		_ensure_symbol(symbols, symbol_family)
	var protocol_profile: Dictionary = Dictionary(visual_profile.get("protocol_profile", {}))
	var pressure_grammar := _string_array(run_identity_summary.get("pressure_grammar", []))
	var pacing_profile := str(run_identity_summary.get("pacing_profile", "")).strip_edges()
	var convergence_axis := str(run_identity_summary.get("convergence_axis", "")).strip_edges()
	var pressure_profile := _string_array(branch_context.get("pressure_profile", []))
	var particle_density := int(visual_profile.get("particle_density", 10))
	var emissive_lighting := int(visual_profile.get("emissive_lighting", 4))
	var landmark_scale := float(visual_profile.get("landmark_scale", 1.0))
	var openness := float(protocol_profile.get("openness", 1.0))
	var midground_density := float(protocol_profile.get("midground_density", 1.0))
	if pacing_profile == "volatile":
		particle_density += 2
		emissive_lighting += 1
		midground_density += 0.08
	elif pacing_profile == "calm":
		particle_density -= 1
		emissive_lighting -= 1
		openness += 0.06
	if pressure_grammar.has("Exposure"):
		emissive_lighting += 1
	if pressure_grammar.has("Scarcity"):
		particle_density -= 1
	if pressure_grammar.has("Fragmentation") or convergence_axis == "fragmentation":
		openness -= 0.08
		midground_density += 0.08
	elif convergence_axis == "convergence":
		landmark_scale += 0.05
	var stagecraft := {
		"escort_lane": room_type == "evidence" or hazard == "collapse" or pressure_profile.has("escort_duty") or pressure_profile.has("return_pressure") or pressure_profile.has("legitimacy_custody") or pressure_profile.has("sacred_order"),
		"carrier_isolation": room_type == "hazard" or normalize_protocol_state(protocol_state) == "exposure" or convergence_axis == "fragmentation" or pressure_profile.has("handoff_obligation") or pressure_profile.has("anti_protocol_pull") or pressure_profile.has("taboo_silence"),
		"rescue_convergence": room_type == "evidence" or hazard == "push" or convergence_axis == "convergence" or pressure_profile.has("rescue_debt") or pressure_profile.has("relay_overload"),
		"confrontation_triangle": hazard != "none" or normalize_protocol_state(protocol_state) == "fracture" or pressure_profile.has("regroup_strain") or pressure_profile.has("relay_bottleneck") or pressure_profile.has("cohort_split") or pressure_profile.has("canon_conflict") or pressure_profile.has("ontology_heat"),
		"suspicious_distance": normalize_protocol_state(protocol_state) in ["fracture", "exposure"] or pressure_profile.has("witness_doubt") or pressure_profile.has("distributed_witness") or pressure_profile.has("rumor_heat") or pressure_profile.has("counter_reading") or pressure_profile.has("fragmentary_reading") or pressure_profile.has("holder_network") or pressure_profile.has("mourning_climate") or pressure_profile.has("ontology_heat")
	}
	var telegraph_channels := _telegraph_channels_for_room(room_type, hazard, stagecraft)
	var residue_layers := _residue_layers_for_room(room_type, hazard, pressure_profile, symbols)
	var signal_compression_profile := _signal_compression_profile_for_room(room_type, hazard, telegraph_channels, residue_layers)
	var apex_visual_profile := _apex_visual_profile_for_room(Dictionary(branch_context.get("apex_preview", {})), room_type, hazard)
	var temporal_density_budget := {
		"simultaneous_signals": int(signal_compression_profile.get("max_visible_channels", 3)),
		"residue_layers": residue_layers.size(),
		"hazard_window": 1 if hazard != "none" else 0
	}
	return {
		"packet_schema_version": ROOM_PACKET_SCHEMA_VERSION,
		"branch_family_id": branch_family_id,
		"protocol_state": normalize_protocol_state(protocol_state),
		"room_slot": int(room.get("slot", -1)),
		"room_type": room_type,
		"hazard": hazard,
		"visual_profile": visual_profile,
		"symbol_families": symbols,
		"stagecraft": stagecraft,
		"particle_density": clampi(particle_density, 4, int(VISUAL_BUDGET_LIMITS["particle_density"])),
		"emissive_lighting": clampi(emissive_lighting, 2, int(VISUAL_BUDGET_LIMITS["emissive_lighting"])),
		"landmark_scale": minf(landmark_scale, float(VISUAL_BUDGET_LIMITS["landmark_scale"])),
		"cosmetic_brightness": float(visual_profile.get("cosmetic_brightness", 0.72)),
		"telegraph_channels": telegraph_channels,
		"residue_layers": residue_layers,
		"apex_visual_profile": apex_visual_profile,
		"normalization_visual_rules": {
			"supported_modes": ["default", "fairness_sensitive", "all_ages", "forensic_replay"],
			"fairness_sensitive_behavior": "collapse_modulation_to_canonical",
			"all_ages_behavior": "collapse_modulation_to_canonical",
			"forensic_replay_behavior": "collapse_modulation_to_canonical"
		},
		"signal_compression_profile": signal_compression_profile,
		"temporal_density_budget": temporal_density_budget,
		"openness": maxf(openness, 0.45),
		"midground_density": maxf(midground_density, 0.7),
		"background_honesty": {
			"allow_reachable_paths": false,
			"allow_reachable_artifacts": false,
			"allow_interactable_silhouettes": false
		}
	}

func _telegraph_channels_for_room(room_type: String, hazard: String, stagecraft: Dictionary) -> Array[String]:
	var channels: Array[String] = ["route"]
	if room_type == "evidence":
		channels.append("evidence")
	if room_type == "hazard" or hazard != "none":
		channels.append("hazard")
	if bool(stagecraft.get("escort_lane", false)):
		channels.append("escort")
	if bool(stagecraft.get("carrier_isolation", false)):
		channels.append("burden")
	if bool(stagecraft.get("suspicious_distance", false)):
		channels.append("witness")
	return _string_array(channels)

func _residue_layers_for_room(room_type: String, hazard: String, pressure_profile: Array[String], symbols: Array) -> Array[String]:
	var layers: Array[String] = ["route_residue"]
	if room_type == "evidence":
		layers.append("evidence_residue")
	if hazard != "none":
		layers.append("hazard_residue")
	if pressure_profile.has("return_pressure") or pressure_profile.has("relay_overload"):
		layers.append("escort_residue")
	if Array(symbols).size() >= 3:
		layers.append("symbolic_residue")
	return _string_array(layers)

func _signal_compression_profile_for_room(room_type: String, hazard: String, telegraph_channels: Array[String], residue_layers: Array[String]) -> Dictionary:
	var max_visible_channels := 3 if room_type == "hazard" or hazard != "none" else 4
	var warning_flags: Array[String] = []
	if telegraph_channels.size() > max_visible_channels:
		warning_flags.append("telegraph_truncated")
	if residue_layers.size() > 3:
		warning_flags.append("residue_truncated")
	return {
		"schema_name": "SignalCompressionProfile",
		"schema_version": SIGNAL_COMPRESSION_SCHEMA_VERSION,
		"max_visible_channels": max_visible_channels,
		"max_lines_per_layer": 2,
		"max_total_lines": 6,
		"drop_policy": "priority_then_truncate",
		"residue_budget": mini(residue_layers.size(), 3),
		"max_major_vfx_layers": 3 if room_type == "hazard" or hazard != "none" else 2,
		"telegraph_priority": telegraph_channels.duplicate(),
		"warning_flags": warning_flags,
		"cognitive_budget_envelope": {
			"schema_name": "CognitiveBudgetEnvelope",
			"schema_version": 1,
			"budget_id": "room_%s_%s" % [room_type, hazard],
			"constitution_hash": "",
			"explanation_budget": {
				"max_lines_per_layer": 2,
				"max_total_lines": 6,
				"telegraph_priority": telegraph_channels.duplicate(),
				"drop_policy": "priority_then_truncate",
				"drop_counts": {
					"immediate": 0,
					"run": 0,
					"meta": 0,
					"summary": 0,
					"operator": 0
				}
			},
			"visual_budget": {
				"max_visible_channels": max_visible_channels,
				"residue_budget": mini(residue_layers.size(), 3),
				"max_major_vfx_layers": 3 if room_type == "hazard" or hazard != "none" else 2
			},
			"onboarding_budget": {
				"home_overview_lines_max": 8,
				"progression_preview_lines_max": 8,
				"profile_card_lines_max": 4,
				"reentry_summary_lines_max": 8
			},
			"warning_flags": warning_flags,
			"failure_codes": []
		},
		"drop_counts": {
			"telegraph": maxi(telegraph_channels.size() - max_visible_channels, 0),
			"residue": maxi(residue_layers.size() - 3, 0)
		}
	}

func _apex_visual_profile_for_room(apex_preview: Dictionary, room_type: String, hazard: String) -> Dictionary:
	var apex_manifest_ids := _string_array(apex_preview.get("apex_manifest_ids", []))
	var apex_class_ids := _string_array(apex_preview.get("apex_class_ids", []))
	return {
		"apex_manifest_ids": apex_manifest_ids,
		"apex_class_ids": apex_class_ids,
		"encounter_apex_consequence_version": int(apex_preview.get("encounter_apex_consequence_version", 0)),
		"anchored_pressures": _string_array(apex_preview.get("anchored_pressures", [])),
		"world_aftermath_tags": _string_array(apex_preview.get("world_aftermath_tags", [])),
		"peak_spacing_score": int(apex_preview.get("peak_spacing_score", 0)),
		"telegraph_emphasis": "crisis_window" if int(apex_preview.get("peak_spacing_score", 0)) >= 3 or room_type == "hazard" or hazard != "none" else "announce_window",
		"summary_lines": _string_array(apex_preview.get("apex_lines", [])) + _string_array(apex_preview.get("peak_structure_lines", []))
	}

func validate_room_packet(packet: Dictionary) -> Array[String]:
	var failures: Array[String] = []
	if int(packet.get("packet_schema_version", 0)) < ROOM_PACKET_SCHEMA_VERSION:
		failures.append("room visual packet must expose packet_schema_version")
	if int(packet.get("particle_density", 0)) > int(VISUAL_BUDGET_LIMITS["particle_density"]):
		failures.append("particle density exceeds doctrine budget")
	if int(packet.get("emissive_lighting", 0)) > int(VISUAL_BUDGET_LIMITS["emissive_lighting"]):
		failures.append("emissive lighting exceeds doctrine budget")
	if float(packet.get("landmark_scale", 1.0)) > float(VISUAL_BUDGET_LIMITS["landmark_scale"]):
		failures.append("landmark scale exceeds doctrine budget")
	if float(packet.get("cosmetic_brightness", 0.0)) > float(VISUAL_BUDGET_LIMITS["cosmetic_brightness"]):
		failures.append("cosmetic brightness exceeds doctrine budget")
	var honesty := Dictionary(packet.get("background_honesty", {}))
	for key in ["allow_reachable_paths", "allow_reachable_artifacts", "allow_interactable_silhouettes"]:
		if bool(honesty.get(key, true)):
			failures.append("background honesty violated: %s" % key)
	var signal_compression_profile: Dictionary = Dictionary(packet.get("signal_compression_profile", {}))
	if signal_compression_profile.is_empty():
		failures.append("room visual packet must expose signal_compression_profile")
	else:
		if int(signal_compression_profile.get("max_visible_channels", 0)) > 4:
			failures.append("room visual packet exceeds the simultaneous signal budget")
		if int(signal_compression_profile.get("residue_budget", 0)) > 3:
			failures.append("room visual packet exceeds the residue budget")
		if int(signal_compression_profile.get("max_major_vfx_layers", 0)) > 3:
			failures.append("room visual packet exceeds the major VFX layer budget")
		if not signal_compression_profile.has("warning_flags"):
			failures.append("room visual packet must expose signal_compression_profile.warning_flags")
		if not signal_compression_profile.has("cognitive_budget_envelope"):
			failures.append("room visual packet must expose signal_compression_profile.cognitive_budget_envelope")
	if _string_array(packet.get("telegraph_channels", [])).is_empty():
		failures.append("room visual packet must expose telegraph_channels")
	if Array(packet.get("residue_layers", [])).is_empty():
		failures.append("room visual packet must expose residue_layers")
	var apex_visual_profile: Dictionary = Dictionary(packet.get("apex_visual_profile", {}))
	if not apex_visual_profile.is_empty():
		if int(apex_visual_profile.get("peak_spacing_score", 0)) < 0:
			failures.append("room visual packet apex_visual_profile must keep peak spacing non-negative")
		if _string_array(apex_visual_profile.get("summary_lines", [])).size() > 4:
			failures.append("room visual packet apex_visual_profile exceeds readability line budget")
	var normalization_visual_rules: Dictionary = Dictionary(packet.get("normalization_visual_rules", {}))
	if _string_array(normalization_visual_rules.get("supported_modes", [])).is_empty():
		failures.append("room visual packet must expose normalization_visual_rules.supported_modes")
	if str(normalization_visual_rules.get("fairness_sensitive_behavior", "")).strip_edges().is_empty():
		failures.append("room visual packet must expose fairness-sensitive normalization behavior")
	return failures

func validate_visual_only_layer(layer: Node, layer_label: String = "visual-only layer", allow_labels: bool = false) -> Array[String]:
	var failures: Array[String] = []
	if layer == null:
		failures.append("%s missing" % layer_label)
		return failures
	_validate_visual_only_node(layer, failures, layer_label, allow_labels)
	return failures

func validate_background_layer(layer: Node) -> Array[String]:
	return validate_visual_only_layer(layer, "background layer", false)

func validate_doctrine_layer(layer: Node) -> Array[String]:
	return validate_visual_only_layer(layer, "doctrine layer", false)

func _validate_visual_only_node(node: Node, failures: Array[String], layer_label: String, allow_labels: bool) -> void:
	for child in node.get_children():
		if child is Area2D or child is StaticBody2D or child is CollisionShape2D or child is CollisionPolygon2D:
			failures.append("%s must not contain interactable/reachable nodes" % layer_label)
		if not allow_labels and child is Label:
			failures.append("%s must not contain informative labels" % layer_label)
		if child.has_method("get_script") and child.get_script() != null:
			var script_path := str(child.get_script().resource_path)
			if script_path.find("item_pickup.gd") != -1 or script_path.find("evidence.gd") != -1 or script_path.find("door.gd") != -1 or script_path.find("crusher.gd") != -1:
				failures.append("%s must not contain pickup/evidence/door/hazard visuals" % layer_label)
		_validate_visual_only_node(child, failures, layer_label, allow_labels)

func artifact_carrier_profile(carrying: bool) -> Dictionary:
	return {
		"label_visible": carrying,
		"halo_energy": 0.85 if carrying else 0.0,
		"beacon_scale": 1.8 if carrying else 0.0,
		"burden_offset": Vector2(0, -20) if carrying else Vector2.ZERO,
		"silhouette_emphasis": 1.18 if carrying else 1.0,
		"crown_energy": 0.74 if carrying else 0.0,
		"yoke_alpha": 0.22 if carrying else 0.0,
		"shadow_scale": 1.14 if carrying else 1.0,
		"body_light": 0.10 if carrying else 0.0,
		"label_alpha": 0.96 if carrying else 0.0
	}

func item_visual_profile(item_def_id: String, category: String) -> Dictionary:
	var accent := Color(0.93, 0.81, 0.36, 1.0)
	var symbol := "threshold"
	var glyph_scale := 0.46
	var plate_alpha := 0.18
	var label_alpha := 0.92
	match item_def_id:
		"lantern_snuffer":
			accent = Color(0.62, 0.70, 0.90, 1.0)
			symbol = "witness"
		"heavy_boots":
			accent = Color(0.52, 0.38, 0.25, 1.0)
			symbol = "burden"
		"timeline_bookmark":
			accent = Color(0.88, 0.74, 0.36, 1.0)
			symbol = "recursion"
		"decoy_emitter":
			accent = Color(0.63, 0.87, 0.63, 1.0)
			symbol = "witness"
		"zipline_kit":
			accent = Color(0.74, 0.78, 0.92, 1.0)
			symbol = "threshold"
		"custody_seal":
			accent = Color(0.92, 0.80, 0.46, 1.0)
			symbol = "burden"
		"witness_chime":
			accent = Color(0.72, 0.88, 0.94, 1.0)
			symbol = "witness"
		"echo_lure":
			accent = Color(0.68, 0.72, 0.96, 1.0)
			symbol = "recursion"
		"burden_sling":
			accent = Color(0.72, 0.60, 0.38, 1.0)
			symbol = "burden"
		"hush_bead":
			accent = Color(0.66, 0.76, 0.72, 1.0)
			symbol = "witness"
			glyph_scale = 0.40
			plate_alpha = 0.12
			label_alpha = 0.82
		"flare_ampoule":
			accent = Color(0.94, 0.78, 0.42, 1.0)
			symbol = "threshold"
			glyph_scale = 0.50
			plate_alpha = 0.22
		"oath_ribbon":
			accent = Color(0.86, 0.72, 0.52, 1.0)
			symbol = "burden"
			glyph_scale = 0.48
			plate_alpha = 0.21
		"doubt_ink":
			accent = Color(0.44, 0.50, 0.60, 1.0)
			symbol = "recursion"
			glyph_scale = 0.44
			plate_alpha = 0.20
		"echo_molt":
			accent = Color(0.58, 0.82, 0.84, 1.0)
			symbol = "recursion"
			glyph_scale = 0.56
			plate_alpha = 0.24
			label_alpha = 0.96
		_:
			if category == "artifact":
				symbol = "burden"
	return {
		"accent": accent,
		"symbol_family": symbol,
		"outline": accent.lightened(0.18),
		"glow": accent.darkened(0.15),
		"plate_points": symbol_plate_points(symbol, 0.72),
		"glyph_scale": glyph_scale,
		"plate_alpha": plate_alpha,
		"label_alpha": label_alpha
	}

func evidence_visual_profile(is_forged: bool, carried: bool) -> Dictionary:
	var accent := Color(0.67, 0.90, 0.72, 1.0)
	var shell_symbol := "threshold"
	if is_forged:
		accent = Color(0.92, 0.57, 0.59, 1.0)
		shell_symbol = "recursion"
	elif carried:
		shell_symbol = "burden"
	return {
		"accent": accent,
		"symbol_family": shell_symbol,
		"ring_alpha": 0.72 if carried else (0.65 if is_forged else 0.0),
		"glyph_alpha": 0.92 if is_forged else (0.52 if carried else 0.0),
		"beacon_scale": 1.28 if carried else 1.0,
		"cradle_alpha": 0.26 if carried else 0.0,
		"frame_width": 2.4 if carried else 2.0
	}

func symbol_plate_points(symbol_family: String, scale: float = 1.0) -> PackedVector2Array:
	match symbol_family:
		"burden":
			return _scaled_points(PackedVector2Array([
				Vector2(-16, -10), Vector2(16, -10), Vector2(20, 0),
				Vector2(16, 10), Vector2(-16, 10), Vector2(-20, 0)
			]), scale)
		"witness":
			return _scaled_points(PackedVector2Array([
				Vector2(-12, -10), Vector2(12, -10), Vector2(18, -4),
				Vector2(18, 4), Vector2(12, 10), Vector2(-12, 10),
				Vector2(-18, 4), Vector2(-18, -4)
			]), scale)
		"recursion":
			return _scaled_points(PackedVector2Array([
				Vector2(-18, -8), Vector2(-4, -12), Vector2(16, -6),
				Vector2(20, 4), Vector2(6, 12), Vector2(-16, 8)
			]), scale)
		_:
			return _scaled_points(PackedVector2Array([
				Vector2(-14, -10), Vector2(14, -10), Vector2(20, 0),
				Vector2(14, 10), Vector2(-14, 10), Vector2(-20, 0)
			]), scale)

func symbol_anchor_offset(symbol_family: String, room_slot: int, anchor_index: int, spread: float = 1.0) -> Vector2:
	var seed := room_slot * 73 + anchor_index * 29 + symbol_family.hash()
	var x_phase := sin(float(seed)) * 14.0 * spread
	var y_phase := cos(float(seed + 11)) * 8.0 * spread
	return Vector2(x_phase, y_phase)

func shell_palette() -> Dictionary:
	return {
		"title": Color(0.92, 0.82, 0.58),
		"banner": Color(0.69, 0.77, 0.84),
		"primary": Color(0.84, 0.84, 0.84),
		"secondary": Color(0.76, 0.76, 0.74),
		"tertiary": Color(0.62, 0.66, 0.72),
		"focus": Color(0.86, 0.84, 0.70),
		"archive": Color(0.76, 0.70, 0.58),
		"broadcast": Color(0.80, 0.73, 0.62),
		"muted": Color(0.58, 0.62, 0.70)
	}

func _scaled_points(points: PackedVector2Array, scale: float) -> PackedVector2Array:
	var result := PackedVector2Array()
	for point in points:
		result.append(point * scale)
	return result

func shell_symbol_for_symbol_family(symbol_family: String) -> String:
	return str(Dictionary(SYMBOL_FAMILIES.get(symbol_family, {})).get("shell", ""))

func symbol_segments(symbol_family: String) -> Array:
	return Array(Dictionary(SYMBOL_FAMILIES.get(symbol_family, {})).get("segments", [])).duplicate(true)

func symbol_color(symbol_family: String) -> Color:
	return Color(Dictionary(SYMBOL_FAMILIES.get(symbol_family, {})).get("color", Color(0.9, 0.8, 0.4, 0.7)))

func clamp_palette_color(color: Color, max_energy: float = 0.78) -> Color:
	return _clamp_color_energy(color, max_energy)

func clamp_palette_strings(palette: Dictionary) -> Dictionary:
	var next := palette.duplicate(true)
	for key in palette.keys():
		var value: Variant = palette.get(key)
		if value is String:
			next[key] = _clamp_color_energy(Color(str(value)), float(VISUAL_BUDGET_LIMITS["cosmetic_brightness"])).to_html()
	return next

func _clamp_color_energy(color: Color, max_energy: float) -> Color:
	var energy := maxf(color.r, maxf(color.g, color.b))
	if energy <= max_energy or energy <= 0.0:
		return color
	var factor := max_energy / energy
	return Color(color.r * factor, color.g * factor, color.b * factor, color.a)

func _ensure_symbol(symbols: Array, symbol_family: String) -> void:
	if not symbols.has(symbol_family):
		symbols.append(symbol_family)

func _motif_symbol_families(motif_labels: Array[String]) -> Array[String]:
	var result: Array[String] = []
	for motif_label in motif_labels:
		match str(motif_label):
			"Threshold Marks":
				_ensure_symbol(result, "threshold")
				_ensure_symbol(result, "witness")
			"Sealed Ribs":
				_ensure_symbol(result, "burden")
				_ensure_symbol(result, "threshold")
			"Archive Scars":
				_ensure_symbol(result, "recursion")
				_ensure_symbol(result, "witness")
			"Split Echoes":
				_ensure_symbol(result, "witness")
				_ensure_symbol(result, "recursion")
			"Burden Halos":
				_ensure_symbol(result, "burden")
				_ensure_symbol(result, "witness")
	return result.slice(0, 3)

func _string_array(values: Variant) -> Array[String]:
	var result: Array[String] = []
	if values is Array:
		for value in values:
			var text := str(value).strip_edges()
			if not text.is_empty() and not result.has(text):
				result.append(text)
	return result
