class_name DoctrineSchemaRegistry
extends RefCounted

const CONSTITUTION_SCHEMA_PATH := "res://config/constitution_schema.json"
const ONTOLOGY_SCHEMA_PATH := "res://config/ontology_schema.json"
const EXPERIMENT_SCHEMA_PATH := "res://config/experiment_schema.json"
const EVALUATION_SCHEMA_PATH := "res://config/evaluation_schema.json"
const CULTURAL_ACTOR_SCHEMA_PATH := "res://config/cultural_actor_schema.json"
const NARRATIVE_PRESSURE_SCHEMA_PATH := "res://config/narrative_pressure_schema.json"
const LINEAGE_SCHEMA_PATH := "res://config/lineage_schema.json"
const INQUIRY_SCHEMA_PATH := "res://config/inquiry_schema.json"
const COGNITIVE_FIELD_SCHEMA_PATH := "res://config/cognitive_field_schema.json"
const CIVILIZATION_SCHEMA_PATH := "res://config/civilization_schema.json"
const GOVERNANCE_SCHEMA_PATH := "res://config/governance_schema.json"
const ARCHIVE_SCHEMA_PATH := "res://config/archive_schema.json"
const COOKBOOK_SCHEMA_PATH := "res://config/cookbook_schema.json"
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
		"authority",
		"trust",
		"ritual",
		"counterfeit",
		"taxonomy",
		"memory",
		"wonder",
		"public_fracture",
		"negative_space",
		"artifact_custody",
		"stewardship",
		"public_argument",
		"ritual_memory",
		"taxonomy_memory",
		"wonder_allocation"
	],
	"allowed_target_layers": ["constitution", "ontology", "pressure", "archive", "framing", "continuity"],
	"allowed_targets": [
		"operators",
		"institutions",
		"publics",
		"archive_systems",
		"taxonomy_systems",
		"artifact_careers",
		"ontology_itself",
		"mixed_civilizational_layers",
		"constitution",
		"ontology",
		"archive",
		"pressure_ecology",
		"framing",
		"continuity"
	],
	"allowed_axes": [
		"trust",
		"authority_dependence",
		"ambiguity_tolerance",
		"stability",
		"skepticism",
		"stewardship",
		"ritual",
		"ambiguity",
		"curiosity",
		"fear",
		"ritual_reliance",
		"greed",
		"legitimacy_formation",
		"classification_hunger",
		"wonder_receptivity",
		"memory_fidelity"
	],
	"allowed_stressors": [
		"contradiction",
		"scarcity",
		"lesion_surfacing",
		"counterfeit_pressure",
		"taxonomy_split",
		"rediscovery",
		"hybridization",
		"prestige_shock",
		"rumor_acceleration",
		"fossil_activation",
		"anomaly_cluster",
		"public_schism",
		"classification_drift",
		"public_attention",
		"ritual_load",
		"archive_echo",
		"stewardship_debt"
	],
	"allowed_ontology_conditions": [
		"stable_categories",
		"contested_categories",
		"missing_verification_classes",
		"taboo_category_activation",
		"category_split",
		"niche_overcrowding",
		"rediscovered_extinct_categories",
		"hybrid_lineage_emergence",
		"fossil_density_increase",
		"residue_density_spike",
		"ritual_fragment_return"
	],
	"allowed_cultural_media": [
		"archive_framing",
		"rumor_ecology",
		"civic_response",
		"public_naming",
		"legend_pressure",
		"market_reaction",
		"codex_conflict",
		"chamber_reputation_drift",
		"archive_case",
		"legend_cluster",
		"rumor_field",
		"institutional_memo",
		"public_shorthand",
		"ritual_annotation"
	],
	"allowed_time_horizons": ["expedition", "run_cluster", "season", "era", "immediate", "short_cycle", "seasonal", "long_arc"],
	"allowed_observation_contracts": [
		"extraction_behavior",
		"verification_use",
		"legitimacy_movement",
		"archive_relabeling",
		"rumor_uptake",
		"public_divergence",
		"category_adoption",
		"canonized_failure_formation",
		"wonder_retention",
		"traceable_archive_only",
		"public_safe_summary",
		"constitution_trace",
		"pressure_trace"
	],
	"allowed_topology_types": ["linear", "branching", "nested", "recursive", "convergent", "oscillatory", "recurring", "synthesis"],
	"allowed_expression_modes": ["whisper_mode", "fracture_mode", "crisis_mode", "renaissance_mode", "fossil_mode", "mirror_mode", "public_surface", "archive_bias", "constitution_bias"],
	"allowed_persistence_states": ["active", "recurring", "rare", "dormant", "archival", "foundational"],
	"allowed_compile_targets": [
		"constitution_weighting",
		"ontology_weighting",
		"artifact_career_pressure",
		"pressure_ecosystem_bias",
		"pressure_input_bias",
		"archive_framing_bias",
		"public_activation",
		"legitimacy_stress",
		"rumor_volatility",
		"wonder_allocation"
	],
	"supported_compile_output_sections": [
		"constitution_weighting",
		"ontology_weighting",
		"pressure_input_bias",
		"archive_framing_bias",
		"public_activation"
	],
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

const FALLBACK_EVALUATION_SCHEMA := {
	"schema_name": "DelveMindEvaluation",
	"schema_version": 1,
	"evaluation_required_fields": [
		"evaluation_id",
		"run_seed",
		"hypothesis_id",
		"experiment_id",
		"family_id",
		"dimensions",
		"outcomes",
		"supporting_evidence",
		"contradicting_evidence",
		"continuity_effects",
		"observation_signature",
		"public_trace_lines",
		"operator_trace_lines"
	],
	"dimension_keys": [
		"hypothesis_yield",
		"cultural_richness",
		"ontological_productivity",
		"narrative_resonance",
		"fairness_stability",
		"dignity_stability",
		"cognitive_budget_stability",
		"readability",
		"replay_distinctiveness",
		"long_horizon_branch_value",
		"meta_health"
	],
	"allowed_outcomes": [
		"strengthen_hypothesis",
		"weaken_hypothesis",
		"split_hypothesis",
		"synthesize_broader_theory",
		"move_to_recurring",
		"move_to_rare",
		"move_to_dormant",
		"preserve_archival_lineage",
		"elevate_foundational_inquiry"
	],
	"allowed_persistence_states": ["active", "recurring", "rare", "dormant", "archival", "foundational"],
	"continuity_effects_required_fields": [
		"confidence_delta",
		"recurrence_delta",
		"state_transition",
		"persistence_transition",
		"branch_pressure_family",
		"branch_open_ids",
		"synthesis_experiment_id",
		"synthesis_source_ids",
		"revive_candidate",
		"fairness_vetoed"
	],
	"transition_required_fields": ["from", "to"],
	"observation_signature_required_fields": [
		"story_tone",
		"artifact_result",
		"local_role",
		"build_identity",
		"topology_type",
		"time_horizon",
		"cultural_medium",
		"expression_mode",
		"retellability_score",
		"legend_density_score",
		"revisit_score",
		"interrupted"
	],
	"meta_learning_required_fields": [
		"topology_effectiveness",
		"topology_counts",
		"horizon_effectiveness",
		"horizon_counts",
		"medium_effectiveness",
		"medium_counts",
		"expression_mode_effectiveness",
		"expression_mode_counts",
		"noise_signatures",
		"accepted_evaluation_ids",
		"branch_signal_counts",
		"synthesis_signal_counts",
		"revive_signal_counts"
	],
	"guidance_required_fields": [
		"preferred_topologies",
		"suppressed_topologies",
		"preferred_horizons",
		"suppressed_horizons",
		"preferred_media",
		"suppressed_media",
		"branch_pressure_families",
		"synthesis_candidates",
		"revive_candidates",
		"accepted_evaluation_ids",
		"evaluation_count",
		"branch_signal_counts",
		"synthesis_signal_counts",
		"revive_signal_counts",
		"bias_basis",
		"public_lines",
		"operator_lines"
	],
	"guidance_bias_basis_required_fields": [
		"topology_averages",
		"horizon_averages",
		"medium_averages",
		"expression_mode_averages",
		"noise_signatures"
	],
	"immutable_hypothesis_fields": [
		"hypothesis_id",
		"domain",
		"thesis",
		"target_layers",
		"target_populations",
		"open_branches",
		"foundational_flag"
	],
	"immutable_experiment_fields": [
		"experiment_id",
		"family_id",
		"family_label",
		"program_id",
		"hypothesis_id",
		"target",
		"axis",
		"stressor",
		"ontology_condition",
		"cultural_medium",
		"time_horizon",
		"observation_contract",
		"topology_type",
		"expression_mode",
		"fairness_bounds",
		"compile_outputs"
	],
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

const FALLBACK_LINEAGE_SCHEMA := {
	"schema_name": "Lineage",
	"schema_version": 1,
	"required_fields": ["lineage_id", "kind", "label", "source_ids", "state", "visibility", "play_routing_tags"],
	"allowed_kinds": ["constitution", "experiment", "theory", "faction", "mutation", "cookbook", "judgment"],
	"allowed_states": ["active", "dormant", "archival", "suppressed", "quarantined", "failed", "fossilized"],
	"allowed_visibility": ["public", "operator", "archive", "suppressed"]
}

const FALLBACK_INQUIRY_SCHEMA := {
	"schema_name": "DelveMindInquiry",
	"schema_version": 1,
	"observation_store_required_fields": ["schema_name", "schema_version", "records", "behavior_field_snapshots", "observable_ids"],
	"procedure_store_required_fields": ["schema_name", "schema_version", "procedures", "proposal_ids"],
	"theory_store_required_fields": ["schema_name", "schema_version", "theories", "schools", "lineage_registry"],
	"judgment_store_required_fields": ["schema_name", "schema_version", "judgments", "contradiction_ids"],
	"observable_required_fields": ["observable_id", "label", "category", "capture_mode", "play_routing_tags"],
	"procedure_required_fields": ["procedure_id", "label", "status", "risk_class", "play_routing_tags"],
	"theory_required_fields": ["theory_id", "label", "status", "school_id", "observable_ids", "play_routing_tags"],
	"theory_school_required_fields": ["school_id", "label", "stance", "visibility"],
	"judgment_required_fields": ["judgment_id", "theory_id", "outcome", "confidence", "play_routing_tags"],
	"forecast_required_fields": ["forecast_id", "chamber_id", "theory_id", "prediction", "confidence"],
	"allowed_theory_states": ["official", "rival", "failed_archival", "suppressed_dangerous", "folk", "cookbook", "anomaly_only", "proto"],
	"allowed_judgment_outcomes": ["support", "weaken", "split", "suspend", "quarantine", "abstain"],
	"allowed_chamber_ids": ["tactical", "crawl", "cultural", "epoch", "constitutional"]
}

const FALLBACK_COGNITIVE_FIELD_SCHEMA := {
	"schema_name": "CognitiveField",
	"schema_version": 1,
	"field_dimensions": ["judgment", "instability", "memory", "structure", "containment", "reconciliation", "mourning", "anticipation"],
	"required_field_state_keys": ["schema_name", "schema_version", "field_vectors", "interaction_rules", "derived_mind_ids", "summary_lines"],
	"required_projection_keys": ["mind_id", "label", "intensity", "derived_from_dimensions"],
	"required_snapshot_keys": ["snapshot_id", "field_state_id", "observed_at", "dominant_dimensions"]
}

const FALLBACK_CIVILIZATION_SCHEMA := {
	"schema_name": "CivilizationState",
	"schema_version": 1,
	"faction_required_fields": ["faction_id", "label", "actor_type", "legibility", "play_routing_tags"],
	"regime_required_fields": ["regime_id", "label", "mode", "faction_ids"],
	"region_required_fields": ["region_id", "label", "pressure_profile", "play_routing_tags"],
	"world_mutation_required_fields": ["mutation_id", "label", "status", "reversal_mode", "play_routing_tags"],
	"residue_required_fields": ["residue_id", "label", "source_kind", "play_routing_tags"],
	"literacy_track_required_fields": ["track_id", "label", "tier", "activation_tags"],
	"strategy_cluster_required_fields": ["cluster_id", "label", "pressure_tags", "play_routing_tags"],
	"allowed_mutation_statuses": ["dormant", "proposed", "approved", "quarantined", "reversed"]
}

const FALLBACK_GOVERNANCE_SCHEMA := {
	"schema_name": "GovernanceState",
	"schema_version": 1,
	"activation_state_required_fields": ["epoch", "active_channels", "dormant_channels", "safe_mode_active", "quarantine_ids"],
	"safe_mode_required_fields": ["enabled", "reason", "fallback_constitution_id", "cooling_tags"],
	"explanation_packet_required_fields": ["packet_id", "artifact_type", "summary_lines", "operator_lines", "play_routing_tags"],
	"stability_report_required_fields": ["report_id", "status", "summary_lines"],
	"anti_bottleneck_report_required_fields": ["report_id", "bottleneck_flags", "summary_lines"],
	"play_routing_report_required_fields": ["report_id", "baseline_routes", "status", "summary_lines"],
	"court_decision_required_fields": ["decision_id", "status", "summary_lines"],
	"meta_reflection_required_fields": ["reflection_id", "status", "summary_lines"],
	"saturation_report_required_fields": ["report_id", "status", "summary_lines"],
	"dominance_strain_required_fields": ["report_id", "status", "summary_lines"],
	"throttle_record_required_fields": ["report_id", "status", "summary_lines"],
	"veto_registry_required_fields": ["report_id", "status", "summary_lines"],
	"rollback_registry_required_fields": ["report_id", "status", "summary_lines"],
	"exploit_absorption_required_fields": ["report_id", "status", "summary_lines"],
	"meta_collapse_required_fields": ["report_id", "status", "summary_lines"],
	"resurrection_priority_required_fields": ["schema_name", "schema_version", "candidate_ids", "summary_lines"],
	"allowed_report_statuses": ["stable", "cooling", "warning", "quarantined"]
}

const FALLBACK_ARCHIVE_SCHEMA := {
	"schema_name": "ArchiveEntry",
	"schema_version": 1,
	"required_fields": ["entry_id", "label", "entry_type", "summary_lines", "world_relation_line", "play_routing_tags"],
	"allowed_entry_types": ["case", "legend", "theory", "faction", "mutation", "court", "reflection"]
}

const FALLBACK_COOKBOOK_SCHEMA := {
	"schema_name": "CookbookFragment",
	"schema_version": 1,
	"required_fields": ["fragment_id", "claim", "method", "status", "power_envelope", "play_routing_tags"],
	"allowed_statuses": ["glimpsed", "assembled", "networked", "quarantined"]
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

static func evaluation_schema() -> Dictionary:
	return _load_json(EVALUATION_SCHEMA_PATH, FALLBACK_EVALUATION_SCHEMA)

static func cultural_actor_schema() -> Dictionary:
	return _load_json(CULTURAL_ACTOR_SCHEMA_PATH, FALLBACK_CULTURAL_ACTOR_SCHEMA)

static func narrative_pressure_schema() -> Dictionary:
	return _load_json(NARRATIVE_PRESSURE_SCHEMA_PATH, FALLBACK_NARRATIVE_PRESSURE_SCHEMA)

static func lineage_schema() -> Dictionary:
	return _load_json(LINEAGE_SCHEMA_PATH, FALLBACK_LINEAGE_SCHEMA)

static func inquiry_schema() -> Dictionary:
	return _load_json(INQUIRY_SCHEMA_PATH, FALLBACK_INQUIRY_SCHEMA)

static func cognitive_field_schema() -> Dictionary:
	return _load_json(COGNITIVE_FIELD_SCHEMA_PATH, FALLBACK_COGNITIVE_FIELD_SCHEMA)

static func civilization_schema() -> Dictionary:
	return _load_json(CIVILIZATION_SCHEMA_PATH, FALLBACK_CIVILIZATION_SCHEMA)

static func governance_schema() -> Dictionary:
	return _load_json(GOVERNANCE_SCHEMA_PATH, FALLBACK_GOVERNANCE_SCHEMA)

static func archive_schema() -> Dictionary:
	return _load_json(ARCHIVE_SCHEMA_PATH, FALLBACK_ARCHIVE_SCHEMA)

static func cookbook_schema() -> Dictionary:
	return _load_json(COOKBOOK_SCHEMA_PATH, FALLBACK_COOKBOOK_SCHEMA)

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
	failures.append_array(_validate_evaluation_schema(evaluation_schema()))
	failures.append_array(_validate_basic_schema(cultural_actor_schema(), "CulturalActor", ["required_fields", "allowed_actor_types"]))
	failures.append_array(_validate_narrative_pressure_schema(narrative_pressure_schema()))
	failures.append_array(_validate_lineage_schema(lineage_schema()))
	failures.append_array(_validate_inquiry_schema(inquiry_schema()))
	failures.append_array(_validate_cognitive_field_schema(cognitive_field_schema()))
	failures.append_array(_validate_civilization_schema(civilization_schema()))
	failures.append_array(_validate_governance_schema(governance_schema()))
	failures.append_array(_validate_archive_schema(archive_schema()))
	failures.append_array(_validate_cookbook_schema(cookbook_schema()))
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
	for section in [
		"identity",
		"doctrine",
		"control_surfaces",
		"constitution_summary",
		"generation_surface",
		"compile_metadata",
		"narrative_pressure_state",
		"experimental_ontology_state",
		"lineage_registry",
		"civilization_surface",
		"cognitive_field_state",
		"mind_projections",
		"theory_surface",
		"activation_state",
		"explanation_packet",
		"review_surface"
	]:
		if not required_sections.has(section):
			failures.append("constitution_schema.json required_sections missing %s" % section)
	var required_symbolic_fields := _string_array(schema.get("required_symbolic_fields", []))
	for field in [
		"doctrine_family_id",
		"doctrine_variant_id",
		"generation_seed",
		"topology_profile",
		"route_profile",
		"item_ecology_profile",
		"pressure_ecology_profile",
		"narrative_pressure_state",
		"experimental_ontology_state",
		"fairness_bounds",
		"compile_metadata",
		"lineage_registry",
		"civilization_surface",
		"cognitive_field_state",
		"mind_projections",
		"theory_surface",
		"activation_state",
		"explanation_packet",
		"review_surface"
	]:
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
		"supported_compile_output_sections",
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
	_require_values(_string_array(schema.get("allowed_targets", [])), [
		"operators", "institutions", "publics", "archive_systems", "taxonomy_systems", "artifact_careers", "ontology_itself", "mixed_civilizational_layers"
	], "DelveMindExperiment allowed_targets", failures)
	_require_values(_string_array(schema.get("allowed_axes", [])), [
		"trust", "authority_dependence", "ambiguity_tolerance", "curiosity", "fear", "ritual_reliance", "stewardship", "greed", "legitimacy_formation", "classification_hunger", "wonder_receptivity", "memory_fidelity"
	], "DelveMindExperiment allowed_axes", failures)
	_require_values(_string_array(schema.get("allowed_stressors", [])), [
		"contradiction", "scarcity", "lesion_surfacing", "counterfeit_pressure", "taxonomy_split", "rediscovery", "hybridization", "prestige_shock", "rumor_acceleration", "fossil_activation", "anomaly_cluster", "public_schism"
	], "DelveMindExperiment allowed_stressors", failures)
	_require_values(_string_array(schema.get("allowed_ontology_conditions", [])), [
		"stable_categories", "contested_categories", "missing_verification_classes", "taboo_category_activation", "category_split", "niche_overcrowding", "hybrid_lineage_emergence", "fossil_density_increase", "rediscovered_extinct_categories"
	], "DelveMindExperiment allowed_ontology_conditions", failures)
	_require_values(_string_array(schema.get("allowed_cultural_media", [])), [
		"archive_framing", "rumor_ecology", "civic_response", "public_naming", "legend_pressure", "market_reaction", "codex_conflict", "chamber_reputation_drift"
	], "DelveMindExperiment allowed_cultural_media", failures)
	_require_values(_string_array(schema.get("allowed_time_horizons", [])), [
		"expedition", "run_cluster", "season", "era"
	], "DelveMindExperiment allowed_time_horizons", failures)
	_require_values(_string_array(schema.get("allowed_observation_contracts", [])), [
		"extraction_behavior", "verification_use", "legitimacy_movement", "archive_relabeling", "rumor_uptake", "public_divergence", "category_adoption", "canonized_failure_formation", "wonder_retention"
	], "DelveMindExperiment allowed_observation_contracts", failures)
	_require_values(_string_array(schema.get("allowed_topology_types", [])), [
		"linear", "branching", "nested", "recursive", "convergent", "oscillatory"
	], "DelveMindExperiment allowed_topology_types", failures)
	_require_values(_string_array(schema.get("allowed_expression_modes", [])), [
		"whisper_mode", "fracture_mode", "crisis_mode", "renaissance_mode", "fossil_mode", "mirror_mode"
	], "DelveMindExperiment allowed_expression_modes", failures)
	_require_values(_string_array(schema.get("allowed_compile_targets", [])), [
		"constitution_weighting", "ontology_weighting", "artifact_career_pressure", "public_activation", "archive_framing_bias", "legitimacy_stress", "rumor_volatility", "pressure_ecosystem_bias", "wonder_allocation"
	], "DelveMindExperiment allowed_compile_targets", failures)
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

static func _validate_evaluation_schema(schema: Dictionary) -> Array[String]:
	var failures: Array[String] = []
	if str(schema.get("schema_name", "")) != "DelveMindEvaluation":
		failures.append("DelveMindEvaluation schema_name mismatch")
	for key in [
		"evaluation_required_fields",
		"dimension_keys",
		"allowed_outcomes",
		"allowed_persistence_states",
		"continuity_effects_required_fields",
		"transition_required_fields",
		"observation_signature_required_fields",
		"meta_learning_required_fields",
		"guidance_required_fields",
		"guidance_bias_basis_required_fields",
		"immutable_hypothesis_fields",
		"immutable_experiment_fields",
		"forbidden_runtime_fields"
	]:
		if not schema.has(key):
			failures.append("DelveMindEvaluation missing %s" % key)
	_require_values(_string_array(schema.get("evaluation_required_fields", [])), [
		"evaluation_id",
		"run_seed",
		"hypothesis_id",
		"experiment_id",
		"family_id",
		"dimensions",
		"outcomes",
		"supporting_evidence",
		"contradicting_evidence",
		"continuity_effects",
		"observation_signature",
		"public_trace_lines",
		"operator_trace_lines"
	], "DelveMindEvaluation evaluation_required_fields", failures)
	_require_values(_string_array(schema.get("dimension_keys", [])), [
		"hypothesis_yield",
		"cultural_richness",
		"ontological_productivity",
		"narrative_resonance",
		"fairness_stability",
		"dignity_stability",
		"cognitive_budget_stability",
		"readability",
		"replay_distinctiveness",
		"long_horizon_branch_value",
		"meta_health"
	], "DelveMindEvaluation dimension_keys", failures)
	_require_values(_string_array(schema.get("allowed_outcomes", [])), [
		"strengthen_hypothesis",
		"weaken_hypothesis",
		"split_hypothesis",
		"synthesize_broader_theory",
		"move_to_recurring",
		"move_to_rare",
		"move_to_dormant",
		"preserve_archival_lineage",
		"elevate_foundational_inquiry"
	], "DelveMindEvaluation allowed_outcomes", failures)
	_require_values(_string_array(schema.get("allowed_persistence_states", [])), [
		"active", "recurring", "rare", "dormant", "archival", "foundational"
	], "DelveMindEvaluation allowed_persistence_states", failures)
	_require_values(_string_array(schema.get("continuity_effects_required_fields", [])), [
		"confidence_delta",
		"recurrence_delta",
		"state_transition",
		"persistence_transition",
		"branch_pressure_family",
		"branch_open_ids",
		"synthesis_experiment_id",
		"synthesis_source_ids",
		"revive_candidate",
		"fairness_vetoed"
	], "DelveMindEvaluation continuity_effects_required_fields", failures)
	_require_values(_string_array(schema.get("transition_required_fields", [])), [
		"from",
		"to"
	], "DelveMindEvaluation transition_required_fields", failures)
	_require_values(_string_array(schema.get("observation_signature_required_fields", [])), [
		"story_tone",
		"artifact_result",
		"local_role",
		"build_identity",
		"topology_type",
		"time_horizon",
		"cultural_medium",
		"expression_mode",
		"retellability_score",
		"legend_density_score",
		"revisit_score",
		"interrupted"
	], "DelveMindEvaluation observation_signature_required_fields", failures)
	_require_values(_string_array(schema.get("meta_learning_required_fields", [])), [
		"topology_effectiveness",
		"topology_counts",
		"horizon_effectiveness",
		"horizon_counts",
		"medium_effectiveness",
		"medium_counts",
		"expression_mode_effectiveness",
		"expression_mode_counts",
		"noise_signatures",
		"accepted_evaluation_ids",
		"branch_signal_counts",
		"synthesis_signal_counts",
		"revive_signal_counts"
	], "DelveMindEvaluation meta_learning_required_fields", failures)
	_require_values(_string_array(schema.get("guidance_required_fields", [])), [
		"preferred_topologies",
		"suppressed_topologies",
		"preferred_horizons",
		"suppressed_horizons",
		"preferred_media",
		"suppressed_media",
		"branch_pressure_families",
		"synthesis_candidates",
		"revive_candidates",
		"accepted_evaluation_ids",
		"evaluation_count",
		"branch_signal_counts",
		"synthesis_signal_counts",
		"revive_signal_counts",
		"bias_basis",
		"public_lines",
		"operator_lines"
	], "DelveMindEvaluation guidance_required_fields", failures)
	_require_values(_string_array(schema.get("guidance_bias_basis_required_fields", [])), [
		"topology_averages",
		"horizon_averages",
		"medium_averages",
		"expression_mode_averages",
		"noise_signatures"
	], "DelveMindEvaluation guidance_bias_basis_required_fields", failures)
	_require_values(_string_array(schema.get("immutable_hypothesis_fields", [])), [
		"hypothesis_id", "domain", "thesis", "target_layers", "open_branches", "foundational_flag"
	], "DelveMindEvaluation immutable_hypothesis_fields", failures)
	_require_values(_string_array(schema.get("immutable_experiment_fields", [])), [
		"experiment_id", "family_id", "program_id", "target", "axis", "stressor", "ontology_condition", "cultural_medium", "time_horizon", "observation_contract", "topology_type", "expression_mode", "fairness_bounds", "compile_outputs"
	], "DelveMindEvaluation immutable_experiment_fields", failures)
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

static func _validate_lineage_schema(schema: Dictionary) -> Array[String]:
	var failures := _validate_basic_schema(schema, "Lineage", ["required_fields", "allowed_kinds", "allowed_states", "allowed_visibility"])
	_require_values(_string_array(schema.get("required_fields", [])), ["lineage_id", "kind", "label", "source_ids", "state", "visibility", "play_routing_tags"], "Lineage required_fields", failures)
	return failures

static func _validate_inquiry_schema(schema: Dictionary) -> Array[String]:
	var failures := _validate_basic_schema(schema, "DelveMindInquiry", [
		"observation_store_required_fields",
		"procedure_store_required_fields",
		"theory_store_required_fields",
		"judgment_store_required_fields",
		"observable_required_fields",
		"procedure_required_fields",
		"theory_required_fields",
		"theory_school_required_fields",
		"judgment_required_fields",
		"forecast_required_fields",
		"allowed_theory_states",
		"allowed_judgment_outcomes",
		"allowed_chamber_ids"
	])
	_require_values(_string_array(schema.get("observation_store_required_fields", [])), ["records", "behavior_field_snapshots", "observable_ids"], "DelveMindInquiry observation_store_required_fields", failures)
	_require_values(_string_array(schema.get("theory_required_fields", [])), ["theory_id", "label", "status", "school_id", "observable_ids", "play_routing_tags"], "DelveMindInquiry theory_required_fields", failures)
	_require_values(_string_array(schema.get("allowed_theory_states", [])), ["official", "rival", "failed_archival", "suppressed_dangerous", "folk", "cookbook", "anomaly_only", "proto"], "DelveMindInquiry allowed_theory_states", failures)
	return failures

static func _validate_cognitive_field_schema(schema: Dictionary) -> Array[String]:
	var failures := _validate_basic_schema(schema, "CognitiveField", ["field_dimensions", "required_field_state_keys", "required_projection_keys", "required_snapshot_keys"])
	_require_values(_string_array(schema.get("field_dimensions", [])), ["judgment", "instability", "memory", "structure", "containment", "reconciliation", "mourning", "anticipation"], "CognitiveField field_dimensions", failures)
	return failures

static func _validate_civilization_schema(schema: Dictionary) -> Array[String]:
	var failures := _validate_basic_schema(schema, "CivilizationState", [
		"faction_required_fields",
		"regime_required_fields",
		"region_required_fields",
		"world_mutation_required_fields",
		"residue_required_fields",
		"literacy_track_required_fields",
		"strategy_cluster_required_fields",
		"allowed_mutation_statuses"
	])
	_require_values(_string_array(schema.get("faction_required_fields", [])), ["faction_id", "label", "actor_type", "legibility", "play_routing_tags"], "CivilizationState faction_required_fields", failures)
	_require_values(_string_array(schema.get("world_mutation_required_fields", [])), ["mutation_id", "label", "status", "reversal_mode", "play_routing_tags"], "CivilizationState world_mutation_required_fields", failures)
	return failures

static func _validate_governance_schema(schema: Dictionary) -> Array[String]:
	var failures := _validate_basic_schema(schema, "GovernanceState", [
		"activation_state_required_fields",
		"safe_mode_required_fields",
		"explanation_packet_required_fields",
		"stability_report_required_fields",
		"anti_bottleneck_report_required_fields",
		"play_routing_report_required_fields",
		"court_decision_required_fields",
		"meta_reflection_required_fields",
		"saturation_report_required_fields",
		"dominance_strain_required_fields",
		"throttle_record_required_fields",
		"veto_registry_required_fields",
		"rollback_registry_required_fields",
		"exploit_absorption_required_fields",
		"meta_collapse_required_fields",
		"resurrection_priority_required_fields",
		"allowed_report_statuses"
	])
	_require_values(_string_array(schema.get("activation_state_required_fields", [])), ["epoch", "active_channels", "dormant_channels", "safe_mode_active", "quarantine_ids"], "GovernanceState activation_state_required_fields", failures)
	_require_values(_string_array(schema.get("explanation_packet_required_fields", [])), ["packet_id", "artifact_type", "summary_lines", "operator_lines", "play_routing_tags"], "GovernanceState explanation_packet_required_fields", failures)
	_require_values(_string_array(schema.get("resurrection_priority_required_fields", [])), ["schema_name", "schema_version", "candidate_ids", "summary_lines"], "GovernanceState resurrection_priority_required_fields", failures)
	return failures

static func _validate_archive_schema(schema: Dictionary) -> Array[String]:
	var failures := _validate_basic_schema(schema, "ArchiveEntry", ["required_fields", "allowed_entry_types"])
	_require_values(_string_array(schema.get("required_fields", [])), ["entry_id", "label", "entry_type", "summary_lines", "world_relation_line", "play_routing_tags"], "ArchiveEntry required_fields", failures)
	return failures

static func _validate_cookbook_schema(schema: Dictionary) -> Array[String]:
	var failures := _validate_basic_schema(schema, "CookbookFragment", ["required_fields", "allowed_statuses"])
	_require_values(_string_array(schema.get("required_fields", [])), ["fragment_id", "claim", "method", "status", "power_envelope", "play_routing_tags"], "CookbookFragment required_fields", failures)
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
		for pair in [
			["target", "allowed_targets"],
			["axis", "allowed_axes"],
			["stressor", "allowed_stressors"],
			["ontology_condition", "allowed_ontology_conditions"],
			["cultural_medium", "allowed_cultural_media"],
			["time_horizon", "allowed_time_horizons"],
			["observation_contract", "allowed_observation_contracts"],
			["topology_type", "allowed_topology_types"],
			["expression_mode", "allowed_expression_modes"]
		]:
			var field := str(pair[0])
			var allowed_key := str(pair[1])
			if not _string_array(experiment_schema_dict.get(allowed_key, [])).has(str(experiment.get(field, "")).strip_edges()):
				failures.append("%s experiment %s is not allowed by %s" % [family_id, field, allowed_key])
		var compile_outputs: Dictionary = Dictionary(experiment.get("compile_outputs", {}))
		for key in compile_outputs.keys():
			var section := str(key).strip_edges()
			if section == "compile_targets":
				continue
			if not _string_array(experiment_schema_dict.get("supported_compile_output_sections", [])).has(section):
				failures.append("%s compile_outputs section %s is not supported" % [family_id, section])
		for compile_target in _string_array(compile_outputs.get("compile_targets", [])):
			if not _string_array(experiment_schema_dict.get("allowed_compile_targets", [])).has(compile_target):
				failures.append("%s compile target %s is not allowed" % [family_id, compile_target])
	return failures

static func _require_values(actual: Array[String], required: Array[String], label: String, failures: Array[String]) -> void:
	for value in required:
		if not actual.has(value):
			failures.append("%s missing %s" % [label, value])

static func _string_array(values: Variant) -> Array[String]:
	var result: Array[String] = []
	if values is Array:
		for value in values:
			var text := str(value).strip_edges()
			if not text.is_empty() and not result.has(text):
				result.append(text)
	return result
