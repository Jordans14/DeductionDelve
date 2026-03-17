class_name DoctrineSchemaRegistry
extends RefCounted

const CONSTITUTION_SCHEMA_PATH := "res://config/constitution_schema.json"
const ONTOLOGY_SCHEMA_PATH := "res://config/ontology_schema.json"
const EXPERIMENT_SCHEMA_PATH := "res://config/experiment_schema.json"
const CULTURAL_ACTOR_SCHEMA_PATH := "res://config/cultural_actor_schema.json"
const NARRATIVE_PRESSURE_SCHEMA_PATH := "res://config/narrative_pressure_schema.json"
const DOCTRINE_FAMILY_CATALOG_PATH := "res://config/doctrine_family_catalog.json"
const EXPERIMENT_FAMILY_CATALOG_PATH := "res://config/experiment_family_catalog.json"

const FALLBACK_CONSTITUTION_SCHEMA := {
	"schema_name": "ExpeditionConstitution",
	"schema_version": 1,
	"artifact_type": "expedition_constitution",
	"required_sections": [
		"identity",
		"doctrine",
		"control_surfaces",
		"surface_summary",
		"constitution_summary",
		"generation_surface",
		"compile_metadata",
		"narrative_pressure_state",
		"experimental_ontology_state"
	],
	"required_generation_surface_keys": [
		"seed",
		"protocol_state",
		"doctrine_family",
		"branch_family",
		"dominant_forces",
		"dominant_minds",
		"pacing_profile",
		"pressure_verbs",
		"symbolic_motifs",
		"item_ecology_bias",
		"group_tension_bias",
		"archive_tone",
		"convergence_axis",
		"relationship_routing",
		"relay_routing",
		"cookbook_routing",
		"civilization_routing",
		"ontology_routing"
	],
	"required_public_summary_keys": [
		"protocol_state",
		"doctrine_family",
		"doctrine_label",
		"pressure_line",
		"world_goal"
	],
	"required_symbolic_fields": [
		"constitution_id",
		"doctrine_family_id",
		"doctrine_variant_id",
		"generation_seed",
		"topology_profile",
		"chamber_grammar_profile",
		"route_profile",
		"item_ecology_profile",
		"pressure_ecology_profile",
		"narrative_pressure_state",
		"experimental_ontology_state",
		"information_doctrine_profile",
		"pacing_profile",
		"custody_profile",
		"mutation_permissions",
		"continuity_hooks",
		"symbolic_motifs",
		"fairness_bounds",
		"compile_metadata"
	],
	"forbidden_runtime_authority_fields": [
		"runtime_ai_arbitration",
		"hidden_truth_resolution"
	]
}

const FALLBACK_ONTOLOGY_SCHEMA := {
	"schema_name": "OntologySnapshot",
	"schema_version": 1,
	"domains": [
		"artifact_families",
		"chamber_families",
		"pressure_families",
		"doctrine_families",
		"ritual_families",
		"transformation_families",
		"taxonomy_classes",
		"experiment_families",
		"verification_classes",
		"residue_classes"
	],
	"lifecycle_states": [
		"birth",
		"expansion",
		"stabilization",
		"contestation",
		"fragmentation",
		"decline",
		"dormancy",
		"rediscovery"
	],
	"absence_types": [
		"extinct_class",
		"taboo_class",
		"missing_verification_method",
		"dormant_ritual_mode",
		"residue_only_class"
	],
	"niches": [
		"verification_niche",
		"traversal_pressure_niche",
		"archive_classification_niche",
		"civic_trust_niche",
		"ritual_legitimacy_niche",
		"public_argument_niche",
		"preparation_culture_niche",
		"residue_memory_niche",
		"threshold_pressure_niche"
	],
	"required_node_fields": [
		"id",
		"label",
		"domain",
		"lineage_id",
		"lifecycle_state",
		"niches",
		"status",
		"heat",
		"gravity"
	]
}

const FALLBACK_EXPERIMENT_SCHEMA := {
	"schema_name": "DelveMindExperiment",
	"schema_version": 1,
	"hypothesis_required_fields": [
		"hypothesis_id",
		"domain",
		"thesis",
		"confidence",
		"target_layers",
		"supporting_evidence_ids",
		"contradicting_evidence_ids",
		"open_branches",
		"persistence_state",
		"recurrence_weight",
		"foundational_flag"
	],
	"experiment_required_fields": [
		"experiment_id",
		"family_id",
		"program_id",
		"hypothesis_id",
		"target",
		"axis",
		"stressor",
		"ontology_condition",
		"cultural_medium",
		"time_horizon",
		"observation_contract",
		"fairness_bounds",
		"state",
		"topology_type",
		"expression_mode",
		"compile_outputs",
		"lineage_parent_id",
		"branch_ids",
		"synthesis_sources",
		"recurrence_weight"
	],
	"grammar_slots": [
		"target",
		"axis",
		"stressor",
		"ontology_condition",
		"cultural_medium",
		"time_horizon",
		"observation_contract",
		"fairness_bounds"
	],
	"allowed_domains": [
		"artifact_custody",
		"stewardship",
		"public_argument",
		"ritual_memory",
		"taxonomy_memory",
		"wonder_allocation"
	],
	"allowed_target_layers": ["constitution", "ontology", "pressure", "archive", "framing", "continuity"],
	"allowed_targets": ["constitution", "ontology", "archive", "pressure_ecology", "framing", "continuity"],
	"allowed_axes": ["stability", "skepticism", "stewardship", "ritual", "ambiguity", "curiosity"],
	"allowed_stressors": ["contradiction", "classification_drift", "public_attention", "ritual_load", "archive_echo", "stewardship_debt"],
	"allowed_ontology_conditions": ["missing_verification_classes", "taboo_category_activation", "rediscovered_extinct_categories", "hybrid_lineage_emergence", "residue_density_spike", "ritual_fragment_return"],
	"allowed_cultural_media": ["archive_case", "legend_cluster", "rumor_field", "institutional_memo", "public_shorthand", "ritual_annotation"],
	"allowed_time_horizons": ["immediate", "short_cycle", "seasonal", "long_arc"],
	"allowed_observation_contracts": ["traceable_archive_only", "public_safe_summary", "constitution_trace", "pressure_trace"],
	"allowed_topology_types": ["linear", "branching", "recurring", "synthesis"],
	"allowed_expression_modes": ["whisper_mode", "public_surface", "archive_bias", "constitution_bias"],
	"allowed_persistence_states": ["active", "recurring", "rare", "dormant", "archival", "foundational"],
	"allowed_compile_targets": ["constitution_weighting", "ontology_weighting", "pressure_input_bias", "archive_framing_bias", "public_activation"],
	"allowed_status_values": ["active", "recurring", "rare", "dormant", "archival", "foundational"],
	"forbidden_runtime_fields": [
		"peer_ids",
		"runtime_state",
		"event_log",
		"physics_override",
		"legality_override",
		"artifact_truth_override",
		"runtime_ai_arbitration"
	]
}

const FALLBACK_CULTURAL_ACTOR_SCHEMA := {
	"schema_name": "CulturalActor",
	"schema_version": 1,
	"required_fields": [
		"id",
		"actor_type",
		"legitimacy_sources",
		"rumor_vectors",
		"archive_position"
	],
	"allowed_actor_types": ["institution", "school", "crew", "public", "ritual_holder"]
}

const FALLBACK_NARRATIVE_PRESSURE_SCHEMA := {
	"schema_name": "NarrativePressureState",
	"schema_version": 1,
	"required_fields": [
		"id",
		"pressure_family",
		"stability",
		"disruption",
		"authority",
		"skepticism",
		"fear",
		"curiosity",
		"certainty",
		"ambiguity",
		"ritual",
		"innovation",
		"extraction",
		"stewardship",
		"momentum",
		"resonance",
		"cascade_risk",
		"dominant_tensions",
		"generation_weighting",
		"constitution_bias",
		"archive_bias",
		"allowed_outputs",
		"safety_bounds",
		"public_lines",
		"trace"
	],
	"required_axes": [
		"stability",
		"disruption",
		"authority",
		"skepticism",
		"fear",
		"curiosity",
		"certainty",
		"ambiguity",
		"ritual",
		"innovation",
		"extraction",
		"stewardship"
	],
	"allowed_outputs": ["generation_weighting", "archive_bias", "constitution_bias"],
	"min_axis_value": 0,
	"max_axis_value": 4,
	"forbidden_runtime_fields": [
		"peer_ids",
		"role_payload",
		"runtime_state",
		"event_log",
		"physics_override",
		"legality_override",
		"artifact_truth_override"
	]
}

const FALLBACK_DOCTRINE_FAMILIES: Array[Dictionary] = [
	{
		"id": "witness_pressure",
		"label": "Witness Pressure",
		"lineage_id": "public_threshold_lineage",
		"focus_tags": ["public_read", "threshold", "crowd"],
		"niches": ["verification_niche", "public_argument_niche"],
		"protocol_affinities": ["Expedition Protocol", "Fracture Protocol"],
		"preferred_surfaces": {"generation": {"witness_exposure": 2, "rescue_geometry": 1}, "social": {"blame_ambiguity": 1, "coalition_visibility": 1}, "culture": {"public_heat_bias": 1}},
		"inheritance": {"pressure_verbs": ["Exposure", "Convergence"], "symbolic_motifs": ["Threshold Marks"], "item_ecology_bias": "rescue witness", "group_tension_bias": "public answer appetite", "archive_tone": "forensic dispute", "convergence_axis": "balanced"}
	},
	{
		"id": "burden_chain",
		"label": "Burden Chain",
		"lineage_id": "custody_obligation_lineage",
		"focus_tags": ["burden", "obligation", "route"],
		"niches": ["civic_trust_niche", "traversal_pressure_niche"],
		"protocol_affinities": ["Intimate Protocol", "Fracture Protocol"],
		"preferred_surfaces": {"generation": {"rescue_geometry": 2, "bottleneck_severity": 1}, "social": {"obligation_pressure": 2}, "economy": {"commitment_cost": 1}},
		"inheritance": {"pressure_verbs": ["Convergence", "Scarcity"], "symbolic_motifs": ["Burden Halos"], "item_ecology_bias": "burden rescue", "group_tension_bias": "trust fragility", "archive_tone": "memory custody", "convergence_axis": "artifact custody"}
	},
	{
		"id": "split_truth",
		"label": "Split Truth",
		"lineage_id": "fractured_verification_lineage",
		"focus_tags": ["split_read", "private", "fault_line"],
		"niches": ["verification_niche", "archive_classification_niche"],
		"protocol_affinities": ["Fracture Protocol", "Exposure Protocol"],
		"preferred_surfaces": {"social": {"private_evidence_ratio": 2, "blame_ambiguity": 1, "hidden_role_density": 1}, "generation": {"loop_probability": 1}},
		"inheritance": {"pressure_verbs": ["Fragmentation", "Misdirection"], "symbolic_motifs": ["Split Echoes"], "item_ecology_bias": "deception scarcity", "group_tension_bias": "ambiguous fault pressure", "archive_tone": "forensic dispute", "convergence_axis": "fragmentation"}
	},
	{
		"id": "custody_ritual",
		"label": "Custody Ritual",
		"lineage_id": "ritual_custody_lineage",
		"focus_tags": ["ritual", "burden", "symbolic"],
		"niches": ["ritual_legitimacy_niche", "archive_classification_niche"],
		"protocol_affinities": ["Intimate Protocol", "Exposure Protocol"],
		"preferred_surfaces": {"generation": {"ritual_frequency": 2, "rescue_geometry": 1}, "social": {"obligation_pressure": 1}, "culture": {"archive_emphasis": 2}},
		"inheritance": {"pressure_verbs": ["Delay", "Convergence"], "symbolic_motifs": ["Burden Halos", "Threshold Marks"], "item_ecology_bias": "burden memory", "group_tension_bias": "measured caution", "archive_tone": "memory custody", "convergence_axis": "artifact custody"}
	},
	{
		"id": "relay_pressure",
		"label": "Relay Pressure",
		"lineage_id": "distributed_route_lineage",
		"focus_tags": ["route", "relay", "public_read"],
		"niches": ["traversal_pressure_niche", "public_argument_niche"],
		"protocol_affinities": ["Expedition Protocol", "Fracture Protocol"],
		"preferred_surfaces": {"generation": {"loop_probability": 1, "witness_exposure": 1}, "social": {"coalition_visibility": 1}, "economy": {"recovery_cushion": 1}},
		"inheritance": {"pressure_verbs": ["Convergence", "Delay"], "symbolic_motifs": ["Threshold Marks", "Archive Scars"], "item_ecology_bias": "rescue route", "group_tension_bias": "public answer appetite", "archive_tone": "measured memory", "convergence_axis": "balanced"}
	},
	{
		"id": "exposure_test",
		"label": "Exposure Test",
		"lineage_id": "solitude_anomaly_lineage",
		"focus_tags": ["solitude", "pressure", "private"],
		"niches": ["threshold_pressure_niche", "verification_niche"],
		"protocol_affinities": ["Exposure Protocol"],
		"preferred_surfaces": {"generation": {"traversal_harshness": 1, "bottleneck_severity": 1}, "ecology": {"inhabitant_pressure": 1}, "economy": {"resource_austerity": 1}},
		"inheritance": {"pressure_verbs": ["Exposure", "Scarcity"], "symbolic_motifs": ["Split Echoes"], "item_ecology_bias": "scarcity deception", "group_tension_bias": "trust fragility", "archive_tone": "forensic dispute", "convergence_axis": "fragmentation"}
	}
]

const FALLBACK_EXPERIMENT_FAMILIES: Array[Dictionary] = [
	{
		"id": "archive_wonder_residue",
		"label": "Archive Wonder Residue",
		"domain": "wonder_allocation",
		"state": "archival",
		"target_layers": ["archive", "framing", "continuity"],
		"recurrence_weight": 1,
		"public_lines": [
			"Old wonder is still clinging to the cases people thought were settled."
		],
		"hypothesis": {
			"hypothesis_id": "hyp_archive_wonder_residue",
			"domain": "wonder_allocation",
			"thesis": "Residual wonder returns when hybrid lineages stay legible across archive retellings.",
			"confidence": 1,
			"target_layers": ["archive", "framing", "continuity"],
			"target_populations": ["archive readers", "legend keepers"],
			"supporting_evidence_ids": ["legend_echo", "hybrid_lineage"],
			"contradicting_evidence_ids": ["closed_case"],
			"open_branches": ["exp_ritual_recall"],
			"persistence_state": "archival",
			"dormancy_state": "archival",
			"recurrence_weight": 1,
			"foundational_flag": false
		},
		"experiment": {
			"experiment_id": "exp_archive_wonder_residue",
			"program_id": "archive_wonder_program",
			"topology_type": "synthesis",
			"target": "archive",
			"axis": "curiosity",
			"stressor": "archive_echo",
			"ontology_condition": "hybrid_lineage_emergence",
			"cultural_medium": "legend_cluster",
			"time_horizon": "long_arc",
			"observation_contract": "traceable_archive_only",
			"fairness_bounds": {
				"artifact_trust_floor": "objective_central",
				"mechanic_legibility_floor": "readable",
				"strategic_readability_floor": "arguable",
				"role_fairness_required": true,
				"runtime_non_mutation_required": true,
				"no_hidden_targeting_required": true
			},
			"state": "archival",
			"expression_mode": "archive_bias",
			"compile_outputs": {
				"archive_framing_bias": {
					"lines": [
						"Archive retellings are quietly reopening wonder around hybrid traces."
					],
					"emphasis_tags": ["wonder", "hybrid memory"]
				},
				"public_activation": {
					"surface_lines": [
						"Old wonder is still clinging to the cases people thought were settled."
					]
				},
				"wonder_allocation": 2,
				"compile_targets": ["archive_framing_bias", "public_activation"]
			},
			"lineage_parent_id": "exp_taxonomy_dormant",
			"branch_ids": [],
			"synthesis_sources": ["exp_taxonomy_dormant", "exp_ritual_recall"],
			"recurrence_weight": 1,
			"public_lines": [
				"Old wonder is still clinging to the cases people thought were settled."
			]
		}
	},
	{
		"id": "custody_foundation",
		"label": "Custody Foundation",
		"domain": "artifact_custody",
		"state": "foundational",
		"target_layers": ["constitution", "ontology", "archive"],
		"recurrence_weight": 2,
		"public_lines": [
			"Older custody habits are quietly shaping what the route calls important."
		],
		"hypothesis": {
			"hypothesis_id": "hyp_custody_foundation",
			"domain": "artifact_custody",
			"thesis": "Artifact custody stays most legible when stewardship readings remain active in the constitutional layer.",
			"confidence": 3,
			"target_layers": ["constitution", "ontology", "archive"],
			"target_populations": ["custody schools", "archive readers"],
			"supporting_evidence_ids": ["custody_rite", "burden_mark"],
			"contradicting_evidence_ids": ["pure extraction"],
			"open_branches": ["exp_stewardship_campaign", "exp_ritual_recall"],
			"persistence_state": "foundational",
			"dormancy_state": "foundational",
			"recurrence_weight": 2,
			"foundational_flag": true
		},
		"experiment": {
			"experiment_id": "exp_custody_foundation",
			"program_id": "custody_foundation_program",
			"topology_type": "linear",
			"target": "constitution",
			"axis": "stability",
			"stressor": "classification_drift",
			"ontology_condition": "ritual_fragment_return",
			"cultural_medium": "institutional_memo",
			"time_horizon": "long_arc",
			"observation_contract": "constitution_trace",
			"fairness_bounds": {
				"artifact_trust_floor": "objective_central",
				"mechanic_legibility_floor": "readable",
				"strategic_readability_floor": "arguable",
				"role_fairness_required": true,
				"runtime_non_mutation_required": true,
				"no_hidden_targeting_required": true
			},
			"state": "foundational",
			"expression_mode": "constitution_bias",
			"compile_outputs": {
				"constitution_weighting": {
					"pressure_verbs": ["Convergence"],
					"symbolic_motifs": ["Burden Halos"],
					"public_lines": [
						"Older custody habits are quietly shaping what the route calls important."
					],
					"item_ecology_bias_hint": "burden stewardship",
					"group_tension_bias_hint": "measured caution",
					"archive_tone_hint": "memory custody",
					"convergence_axis_hint": "artifact custody"
				},
				"ontology_weighting": {
					"lineage_bias_tags": ["ritual_custody_lineage"],
					"niche_bias_tags": ["ritual_legitimacy_niche"],
					"rediscovery_bias": 1,
					"hybridization_bias": 0
				},
				"pressure_input_bias": {
					"stability": 1,
					"stewardship": 1,
					"ritual": 1
				},
				"archive_framing_bias": {
					"lines": [
						"Archive records keep favoring the carried answer over the loud answer."
					],
					"emphasis_tags": ["custody", "stewardship"]
				},
				"public_activation": {
					"surface_lines": [
						"Older custody habits are quietly shaping what the route calls important."
					]
				},
				"legitimacy_stress": 1,
				"rumor_volatility": 0,
				"wonder_allocation": 0,
				"compile_targets": [
					"constitution_weighting",
					"ontology_weighting",
					"pressure_input_bias",
					"archive_framing_bias",
					"public_activation"
				]
			},
			"lineage_parent_id": "",
			"branch_ids": ["exp_stewardship_campaign", "exp_ritual_recall"],
			"synthesis_sources": [],
			"recurrence_weight": 2,
			"public_lines": [
				"Older custody habits are quietly shaping what the route calls important."
			]
		}
	},
	{
		"id": "fracture_echo",
		"label": "Fracture Echo",
		"domain": "public_argument",
		"state": "recurring",
		"target_layers": ["pressure", "archive", "framing"],
		"recurrence_weight": 2,
		"public_lines": [
			"Split readings keep returning before the public answer can settle."
		],
		"hypothesis": {
			"hypothesis_id": "hyp_fracture_echo",
			"domain": "public_argument",
			"thesis": "Skeptical public readings recur when verification classes stay incomplete.",
			"confidence": 2,
			"target_layers": ["pressure", "archive", "framing"],
			"target_populations": ["public witnesses", "rumor keepers"],
			"supporting_evidence_ids": ["split_record", "witness_dispute"],
			"contradicting_evidence_ids": ["clean_verification"],
			"open_branches": ["exp_taxonomy_dormant"],
			"persistence_state": "recurring",
			"dormancy_state": "recurring",
			"recurrence_weight": 2,
			"foundational_flag": false
		},
		"experiment": {
			"experiment_id": "exp_fracture_echo",
			"program_id": "fracture_echo_program",
			"topology_type": "recurring",
			"target": "pressure_ecology",
			"axis": "skepticism",
			"stressor": "contradiction",
			"ontology_condition": "missing_verification_classes",
			"cultural_medium": "rumor_field",
			"time_horizon": "seasonal",
			"observation_contract": "pressure_trace",
			"fairness_bounds": {
				"artifact_trust_floor": "objective_central",
				"mechanic_legibility_floor": "readable",
				"strategic_readability_floor": "arguable",
				"role_fairness_required": true,
				"runtime_non_mutation_required": true,
				"no_hidden_targeting_required": true
			},
			"state": "recurring",
			"expression_mode": "archive_bias",
			"compile_outputs": {
				"constitution_weighting": {
					"pressure_verbs": ["Fragmentation"],
					"symbolic_motifs": ["Split Echoes"],
					"public_lines": [
						"Split readings keep returning before the public answer can settle."
					],
					"group_tension_bias_hint": "ambiguous fault pressure",
					"archive_tone_hint": "forensic dispute",
					"convergence_axis_hint": "fragmentation"
				},
				"pressure_input_bias": {
					"skepticism": 1,
					"ambiguity": 1,
					"certainty": -1
				},
				"archive_framing_bias": {
					"lines": [
						"Archive framing keeps reopening disputes around who got to name the answer."
					],
					"emphasis_tags": ["skepticism", "classification dispute"]
				},
				"public_activation": {
					"surface_lines": [
						"Split readings keep returning before the public answer can settle."
					]
				},
				"rumor_volatility": 2,
				"compile_targets": [
					"constitution_weighting",
					"pressure_input_bias",
					"archive_framing_bias",
					"public_activation"
				]
			},
			"lineage_parent_id": "exp_custody_foundation",
			"branch_ids": ["exp_taxonomy_dormant"],
			"synthesis_sources": [],
			"recurrence_weight": 2,
			"public_lines": [
				"Split readings keep returning before the public answer can settle."
			]
		}
	},
	{
		"id": "ritual_recall",
		"label": "Ritual Recall",
		"domain": "ritual_memory",
		"state": "rare",
		"target_layers": ["constitution", "archive", "continuity"],
		"recurrence_weight": 1,
		"public_lines": [
			"Older rites are starting to look useful again instead of merely old."
		],
		"hypothesis": {
			"hypothesis_id": "hyp_ritual_recall",
			"domain": "ritual_memory",
			"thesis": "Dormant ritual fragments regain force when archive echoes stay unresolved long enough.",
			"confidence": 2,
			"target_layers": ["constitution", "archive", "continuity"],
			"target_populations": ["ritual holders", "archive readers"],
			"supporting_evidence_ids": ["fragment_mark", "burial_record"],
			"contradicting_evidence_ids": ["ritual_exhaustion"],
			"open_branches": ["exp_archive_wonder_residue"],
			"persistence_state": "rare",
			"dormancy_state": "rare",
			"recurrence_weight": 1,
			"foundational_flag": false
		},
		"experiment": {
			"experiment_id": "exp_ritual_recall",
			"program_id": "ritual_recall_program",
			"topology_type": "synthesis",
			"target": "continuity",
			"axis": "ritual",
			"stressor": "ritual_load",
			"ontology_condition": "ritual_fragment_return",
			"cultural_medium": "ritual_annotation",
			"time_horizon": "long_arc",
			"observation_contract": "traceable_archive_only",
			"fairness_bounds": {
				"artifact_trust_floor": "objective_central",
				"mechanic_legibility_floor": "readable",
				"strategic_readability_floor": "arguable",
				"role_fairness_required": true,
				"runtime_non_mutation_required": true,
				"no_hidden_targeting_required": true
			},
			"state": "rare",
			"expression_mode": "constitution_bias",
			"compile_outputs": {
				"constitution_weighting": {
					"symbolic_motifs": ["Threshold Marks"],
					"public_lines": [
						"Older rites are starting to look useful again instead of merely old."
					],
					"item_ecology_bias_hint": "ritual stewardship"
				},
				"ontology_weighting": {
					"lineage_bias_tags": ["ritual_custody_lineage"],
					"niche_bias_tags": ["residue_memory_niche"],
					"rediscovery_bias": 1,
					"hybridization_bias": 0
				},
				"pressure_input_bias": {
					"ritual": 1,
					"curiosity": 1
				},
				"public_activation": {
					"surface_lines": [
						"Older rites are starting to look useful again instead of merely old."
					]
				},
				"wonder_allocation": 1,
				"compile_targets": [
					"constitution_weighting",
					"ontology_weighting",
					"pressure_input_bias",
					"public_activation"
				]
			},
			"lineage_parent_id": "exp_custody_foundation",
			"branch_ids": ["exp_archive_wonder_residue"],
			"synthesis_sources": ["exp_custody_foundation"],
			"recurrence_weight": 1,
			"public_lines": [
				"Older rites are starting to look useful again instead of merely old."
			]
		}
	},
	{
		"id": "stewardship_campaign",
		"label": "Stewardship Campaign",
		"domain": "stewardship",
		"state": "active",
		"target_layers": ["constitution", "pressure", "framing"],
		"recurrence_weight": 2,
		"public_lines": [
			"Stewardship claims are starting to travel faster than extraction talk."
		],
		"hypothesis": {
			"hypothesis_id": "hyp_stewardship_campaign",
			"domain": "stewardship",
			"thesis": "Stewardship spreads fastest when rescue remains publicly visible and archive language stays calm.",
			"confidence": 3,
			"target_layers": ["constitution", "pressure", "framing"],
			"target_populations": ["public witnesses", "stewardship schools"],
			"supporting_evidence_ids": ["public_rescue", "quiet_carry"],
			"contradicting_evidence_ids": ["panic_extraction"],
			"open_branches": ["exp_fracture_echo"],
			"persistence_state": "active",
			"dormancy_state": "active",
			"recurrence_weight": 2,
			"foundational_flag": false
		},
		"experiment": {
			"experiment_id": "exp_stewardship_campaign",
			"program_id": "stewardship_campaign_program",
			"topology_type": "branching",
			"target": "framing",
			"axis": "stewardship",
			"stressor": "public_attention",
			"ontology_condition": "residue_density_spike",
			"cultural_medium": "public_shorthand",
			"time_horizon": "short_cycle",
			"observation_contract": "public_safe_summary",
			"fairness_bounds": {
				"artifact_trust_floor": "objective_central",
				"mechanic_legibility_floor": "readable",
				"strategic_readability_floor": "arguable",
				"role_fairness_required": true,
				"runtime_non_mutation_required": true,
				"no_hidden_targeting_required": true
			},
			"state": "active",
			"expression_mode": "public_surface",
			"compile_outputs": {
				"constitution_weighting": {
					"pressure_verbs": ["Convergence"],
					"public_lines": [
						"Stewardship claims are starting to travel faster than extraction talk."
					],
					"item_ecology_bias_hint": "stewardship rescue",
					"group_tension_bias_hint": "shared burden caution"
				},
				"pressure_input_bias": {
					"stewardship": 1,
					"extraction": -1,
					"curiosity": 1
				},
				"archive_framing_bias": {
					"lines": [
						"Archive framing is quietly favoring caretaking claims over triumphant exit stories."
					],
					"emphasis_tags": ["stewardship", "care"]
				},
				"public_activation": {
					"surface_lines": [
						"Stewardship claims are starting to travel faster than extraction talk."
					]
				},
				"legitimacy_stress": 1,
				"compile_targets": [
					"constitution_weighting",
					"pressure_input_bias",
					"archive_framing_bias",
					"public_activation"
				]
			},
			"lineage_parent_id": "exp_custody_foundation",
			"branch_ids": ["exp_fracture_echo"],
			"synthesis_sources": ["exp_custody_foundation"],
			"recurrence_weight": 2,
			"public_lines": [
				"Stewardship claims are starting to travel faster than extraction talk."
			]
		}
	},
	{
		"id": "taxonomy_dormant",
		"label": "Dormant Taxonomy",
		"domain": "taxonomy_memory",
		"state": "dormant",
		"target_layers": ["ontology", "archive", "continuity"],
		"recurrence_weight": 1,
		"public_lines": [
			"Old classifications are starting to feel less settled than they sounded."
		],
		"hypothesis": {
			"hypothesis_id": "hyp_taxonomy_dormant",
			"domain": "taxonomy_memory",
			"thesis": "Dormant classifications return when extinct categories begin to feel nameable again.",
			"confidence": 1,
			"target_layers": ["ontology", "archive", "continuity"],
			"target_populations": ["taxonomy keepers", "archive readers"],
			"supporting_evidence_ids": ["residue_trace", "classification_note"],
			"contradicting_evidence_ids": ["closed_index"],
			"open_branches": ["exp_archive_wonder_residue"],
			"persistence_state": "dormant",
			"dormancy_state": "dormant",
			"recurrence_weight": 1,
			"foundational_flag": false
		},
		"experiment": {
			"experiment_id": "exp_taxonomy_dormant",
			"program_id": "taxonomy_dormant_program",
			"topology_type": "branching",
			"target": "ontology",
			"axis": "ambiguity",
			"stressor": "classification_drift",
			"ontology_condition": "rediscovered_extinct_categories",
			"cultural_medium": "archive_case",
			"time_horizon": "seasonal",
			"observation_contract": "constitution_trace",
			"fairness_bounds": {
				"artifact_trust_floor": "objective_central",
				"mechanic_legibility_floor": "readable",
				"strategic_readability_floor": "arguable",
				"role_fairness_required": true,
				"runtime_non_mutation_required": true,
				"no_hidden_targeting_required": true
			},
			"state": "dormant",
			"expression_mode": "archive_bias",
			"compile_outputs": {
				"ontology_weighting": {
					"lineage_bias_tags": ["fractured_verification_lineage"],
					"niche_bias_tags": ["archive_classification_niche"],
					"rediscovery_bias": 2,
					"hybridization_bias": 1
				},
				"pressure_input_bias": {
					"ambiguity": 1,
					"certainty": -1
				},
				"archive_framing_bias": {
					"lines": [
						"Archive indexing is starting to sound less certain about old category boundaries."
					],
					"emphasis_tags": ["taxonomy drift", "rediscovery"]
				},
				"public_activation": {
					"surface_lines": [
						"Old classifications are starting to feel less settled than they sounded."
					]
				},
				"compile_targets": [
					"ontology_weighting",
					"pressure_input_bias",
					"archive_framing_bias",
					"public_activation"
				]
			},
			"lineage_parent_id": "exp_fracture_echo",
			"branch_ids": ["exp_archive_wonder_residue"],
			"synthesis_sources": ["exp_fracture_echo"],
			"recurrence_weight": 1,
			"public_lines": [
				"Old classifications are starting to feel less settled than they sounded."
			]
		}
	}
]

static func constitution_schema() -> Dictionary:
	return _load_json(CONSTITUTION_SCHEMA_PATH, FALLBACK_CONSTITUTION_SCHEMA)

static func ontology_schema() -> Dictionary:
	return _load_json(ONTOLOGY_SCHEMA_PATH, FALLBACK_ONTOLOGY_SCHEMA)

static func experiment_schema() -> Dictionary:
	return _load_json(EXPERIMENT_SCHEMA_PATH, FALLBACK_EXPERIMENT_SCHEMA)

static func cultural_actor_schema() -> Dictionary:
	return _load_json(CULTURAL_ACTOR_SCHEMA_PATH, FALLBACK_CULTURAL_ACTOR_SCHEMA)

static func narrative_pressure_schema() -> Dictionary:
	return _load_json(NARRATIVE_PRESSURE_SCHEMA_PATH, FALLBACK_NARRATIVE_PRESSURE_SCHEMA)

static func doctrine_family_catalog() -> Dictionary:
	return _load_json(DOCTRINE_FAMILY_CATALOG_PATH, {
		"schema_name": "DoctrineFamilyCatalog",
		"schema_version": 1,
		"families": FALLBACK_DOCTRINE_FAMILIES
	})

static func experiment_family_catalog() -> Dictionary:
	return _load_json(EXPERIMENT_FAMILY_CATALOG_PATH, {
		"schema_name": "ExperimentFamilyCatalog",
		"schema_version": 1,
		"families": FALLBACK_EXPERIMENT_FAMILIES
	})

static func doctrine_families() -> Array[Dictionary]:
	var families := _families_from_catalog(doctrine_family_catalog(), FALLBACK_DOCTRINE_FAMILIES)
	return families if not families.is_empty() else FALLBACK_DOCTRINE_FAMILIES.duplicate(true)

static func doctrine_family(doctrine_id: String) -> Dictionary:
	for family in doctrine_families():
		if str(family.get("id", "")) == doctrine_id:
			return family.duplicate(true)
	return {}

static func experiment_families() -> Array[Dictionary]:
	var families := _families_from_catalog(experiment_family_catalog(), FALLBACK_EXPERIMENT_FAMILIES)
	return families if not families.is_empty() else FALLBACK_EXPERIMENT_FAMILIES.duplicate(true)

static func validate_registry() -> Array[String]:
	var failures: Array[String] = []
	failures.append_array(_validate_constitution_schema(constitution_schema()))
	failures.append_array(_validate_ontology_schema(ontology_schema()))
	failures.append_array(_validate_experiment_schema(experiment_schema()))
	failures.append_array(_validate_basic_schema(cultural_actor_schema(), "CulturalActor", ["required_fields", "allowed_actor_types"]))
	failures.append_array(_validate_narrative_pressure_schema(narrative_pressure_schema()))
	failures.append_array(_validate_doctrine_catalog(doctrine_family_catalog()))
	failures.append_array(_validate_experiment_catalog(experiment_family_catalog()))
	return failures

static func _load_json(path: String, fallback: Dictionary) -> Dictionary:
	if not FileAccess.file_exists(path):
		return fallback.duplicate(true)
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return fallback.duplicate(true)
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		return fallback.duplicate(true)
	var merged := fallback.duplicate(true)
	for key in parsed.keys():
		merged[key] = parsed[key]
	return merged

static func _families_from_catalog(catalog: Dictionary, fallback: Array[Dictionary]) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for family_raw in Array(catalog.get("families", fallback)):
		result.append(Dictionary(family_raw).duplicate(true))
	result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return str(a.get("id", "")) < str(b.get("id", ""))
	)
	return result

static func _validate_constitution_schema(schema: Dictionary) -> Array[String]:
	var failures: Array[String] = []
	if str(schema.get("schema_name", "")) != "ExpeditionConstitution":
		failures.append("constitution_schema.json must declare ExpeditionConstitution")
	for key in ["schema_version", "artifact_type", "required_sections", "required_generation_surface_keys", "required_public_summary_keys", "required_symbolic_fields", "forbidden_runtime_authority_fields"]:
		if not schema.has(key):
			failures.append("constitution_schema.json missing %s" % key)
	var required_sections := _string_array(schema.get("required_sections", []))
	for section in ["identity", "doctrine", "control_surfaces", "constitution_summary", "generation_surface", "compile_metadata", "narrative_pressure_state", "experimental_ontology_state"]:
		if not required_sections.has(section):
			failures.append("constitution_schema.json required_sections missing %s" % section)
	var required_symbolic_fields := _string_array(schema.get("required_symbolic_fields", []))
	for field in ["doctrine_family_id", "doctrine_variant_id", "generation_seed", "topology_profile", "route_profile", "item_ecology_profile", "pressure_ecology_profile", "narrative_pressure_state", "experimental_ontology_state", "fairness_bounds", "compile_metadata"]:
		if not required_symbolic_fields.has(field):
			failures.append("constitution_schema.json required_symbolic_fields missing %s" % field)
	var required_generation_surface_keys := _string_array(schema.get("required_generation_surface_keys", []))
	if not required_generation_surface_keys.has("ontology_routing"):
		failures.append("constitution_schema.json required_generation_surface_keys missing ontology_routing")
	return failures

static func _validate_experiment_schema(schema: Dictionary) -> Array[String]:
	var failures: Array[String] = []
	if str(schema.get("schema_name", "")) != "DelveMindExperiment":
		failures.append("DelveMindExperiment schema_name mismatch")
	for key in [
		"hypothesis_required_fields",
		"experiment_required_fields",
		"grammar_slots",
		"allowed_domains",
		"allowed_target_layers",
		"allowed_targets",
		"allowed_axes",
		"allowed_stressors",
		"allowed_ontology_conditions",
		"allowed_cultural_media",
		"allowed_time_horizons",
		"allowed_observation_contracts",
		"allowed_topology_types",
		"allowed_expression_modes",
		"allowed_persistence_states",
		"allowed_compile_targets",
		"forbidden_runtime_fields"
	]:
		if not schema.has(key):
			failures.append("DelveMindExperiment missing %s" % key)
	for field in ["hypothesis_id", "domain", "thesis", "confidence", "target_layers", "persistence_state"]:
		if not _string_array(schema.get("hypothesis_required_fields", [])).has(field):
			failures.append("DelveMindExperiment hypothesis_required_fields missing %s" % field)
	for field in ["experiment_id", "hypothesis_id", "target", "axis", "stressor", "ontology_condition", "cultural_medium", "time_horizon", "observation_contract", "state", "topology_type", "expression_mode", "compile_outputs"]:
		if not _string_array(schema.get("experiment_required_fields", [])).has(field):
			failures.append("DelveMindExperiment experiment_required_fields missing %s" % field)
	for field in ["target", "axis", "stressor", "ontology_condition", "cultural_medium", "time_horizon", "observation_contract", "fairness_bounds"]:
		if not _string_array(schema.get("grammar_slots", [])).has(field):
			failures.append("DelveMindExperiment grammar_slots missing %s" % field)
	if not _string_array(schema.get("allowed_persistence_states", [])).has("foundational"):
		failures.append("DelveMindExperiment allowed_persistence_states must include foundational")
	if not _string_array(schema.get("allowed_compile_targets", [])).has("pressure_input_bias"):
		failures.append("DelveMindExperiment allowed_compile_targets must include pressure_input_bias")
	return failures

static func _validate_narrative_pressure_schema(schema: Dictionary) -> Array[String]:
	var failures: Array[String] = []
	if str(schema.get("schema_name", "")) != "NarrativePressureState":
		failures.append("NarrativePressureState schema_name mismatch")
	for key in ["required_fields", "required_axes", "allowed_outputs", "min_axis_value", "max_axis_value", "forbidden_runtime_fields"]:
		if not schema.has(key):
			failures.append("NarrativePressureState missing %s" % key)
	var required_fields := _string_array(schema.get("required_fields", []))
	for field in ["pressure_family", "momentum", "resonance", "cascade_risk", "generation_weighting", "constitution_bias", "archive_bias", "safety_bounds", "public_lines", "trace"]:
		if not required_fields.has(field):
			failures.append("NarrativePressureState required_fields missing %s" % field)
	for axis in ["stability", "disruption", "authority", "skepticism", "fear", "curiosity", "certainty", "ambiguity", "ritual", "innovation", "extraction", "stewardship"]:
		if not _string_array(schema.get("required_axes", [])).has(axis):
			failures.append("NarrativePressureState required_axes missing %s" % axis)
	if int(schema.get("min_axis_value", 0)) != 0:
		failures.append("NarrativePressureState min_axis_value must stay at 0")
	if int(schema.get("max_axis_value", 0)) < 4:
		failures.append("NarrativePressureState max_axis_value must allow doctrine-scale pressure values")
	return failures

static func _validate_ontology_schema(schema: Dictionary) -> Array[String]:
	var failures: Array[String] = []
	if str(schema.get("schema_name", "")) != "OntologySnapshot":
		failures.append("ontology_schema.json must declare OntologySnapshot")
	for key in ["schema_version", "domains", "lifecycle_states", "absence_types", "niches", "required_node_fields"]:
		if not schema.has(key):
			failures.append("ontology_schema.json missing %s" % key)
	return failures

static func _validate_basic_schema(schema: Dictionary, schema_name: String, required_keys: Array[String]) -> Array[String]:
	var failures: Array[String] = []
	if str(schema.get("schema_name", "")) != schema_name:
		failures.append("%s schema_name mismatch" % schema_name)
	for key in required_keys:
		if not schema.has(key):
			failures.append("%s missing %s" % [schema_name, key])
	return failures

static func _validate_doctrine_catalog(catalog: Dictionary) -> Array[String]:
	var failures: Array[String] = []
	if str(catalog.get("schema_name", "")) != "DoctrineFamilyCatalog":
		failures.append("doctrine_family_catalog.json must declare DoctrineFamilyCatalog")
	var seen: Dictionary = {}
	for family_raw in Array(catalog.get("families", [])):
		var family: Dictionary = Dictionary(family_raw)
		var family_id := str(family.get("id", "")).strip_edges()
		if family_id.is_empty():
			failures.append("doctrine family missing id")
			continue
		if seen.has(family_id):
			failures.append("duplicate doctrine family %s" % family_id)
		seen[family_id] = true
		for key in ["label", "lineage_id", "focus_tags", "niches", "protocol_affinities", "preferred_surfaces", "inheritance"]:
			if not family.has(key):
				failures.append("%s missing %s" % [family_id, key])
	return failures

static func _validate_experiment_catalog(catalog: Dictionary) -> Array[String]:
	var failures: Array[String] = []
	if str(catalog.get("schema_name", "")) != "ExperimentFamilyCatalog":
		failures.append("experiment_family_catalog.json must declare ExperimentFamilyCatalog")
	var seen: Dictionary = {}
	var experiment_schema_dict := experiment_schema()
	for family_raw in Array(catalog.get("families", [])):
		var family: Dictionary = Dictionary(family_raw)
		var family_id := str(family.get("id", "")).strip_edges()
		if family_id.is_empty():
			failures.append("experiment family missing id")
			continue
		if seen.has(family_id):
			failures.append("duplicate experiment family %s" % family_id)
		seen[family_id] = true
		for key in ["label", "domain", "state", "target_layers", "hypothesis", "experiment", "public_lines"]:
			if not family.has(key):
				failures.append("%s missing %s" % [family_id, key])
		if not _string_array(experiment_schema_dict.get("allowed_domains", [])).has(str(family.get("domain", "")).strip_edges()):
			failures.append("%s declares invalid domain" % family_id)
		if not _string_array(experiment_schema_dict.get("allowed_persistence_states", [])).has(str(family.get("state", "")).strip_edges()):
			failures.append("%s declares invalid state" % family_id)
		for layer in _string_array(family.get("target_layers", [])):
			if not _string_array(experiment_schema_dict.get("allowed_target_layers", [])).has(layer):
				failures.append("%s target layer %s is not allowed" % [family_id, layer])
		var hypothesis: Dictionary = Dictionary(family.get("hypothesis", {}))
		var experiment: Dictionary = Dictionary(family.get("experiment", {}))
		for key in ["domain", "thesis", "confidence", "target_layers", "persistence_state"]:
			if not hypothesis.has(key):
				failures.append("%s hypothesis missing %s" % [family_id, key])
		for key in ["target", "axis", "stressor", "ontology_condition", "cultural_medium", "time_horizon", "observation_contract", "state", "topology_type", "expression_mode", "compile_outputs"]:
			if not experiment.has(key):
				failures.append("%s experiment missing %s" % [family_id, key])
	return failures

static func _string_array(values: Variant) -> Array[String]:
	var result: Array[String] = []
	if values is Array:
		for value in values:
			var text := str(value).strip_edges()
			if not text.is_empty() and not result.has(text):
				result.append(text)
	return result
