// ============================================================
// Research OS — Neo4j Schema & Seed
// Node types: SOURCE, CLAIM, EVIDENCE, CONCEPT, MODEL, DEBATE,
//             HYPOTHESIS, INSIGHT, QUESTION
// Run: cypher-shell < graph/cypher/seed.cypher
// ============================================================

// ----------------------------------------------------------
// 1. Drop existing indexes (Neo4j 2026 constraints create
//    their own backing index — separate indexes conflict)
// ----------------------------------------------------------
DROP INDEX source_id IF EXISTS;
DROP INDEX claim_id IF EXISTS;
DROP INDEX evidence_id IF EXISTS;
DROP INDEX concept_id IF EXISTS;
DROP INDEX model_id IF EXISTS;
DROP INDEX debate_id IF EXISTS;
DROP INDEX hypothesis_id IF EXISTS;
DROP INDEX insight_id IF EXISTS;
DROP INDEX question_id IF EXISTS;

// ----------------------------------------------------------
// 2. CONSTRAINTS (uniqueness + automatic indexing in Neo4j 2026)
// ----------------------------------------------------------
CREATE CONSTRAINT source_id_unique FOR (s:Source) REQUIRE s.id IS UNIQUE;
CREATE CONSTRAINT claim_id_unique FOR (c:Claim) REQUIRE c.id IS UNIQUE;
CREATE CONSTRAINT evidence_id_unique FOR (e:Evidence) REQUIRE e.id IS UNIQUE;
CREATE CONSTRAINT concept_id_unique FOR (c:Concept) REQUIRE c.id IS UNIQUE;
CREATE CONSTRAINT model_id_unique FOR (m:Model) REQUIRE m.id IS UNIQUE;
CREATE CONSTRAINT debate_id_unique FOR (d:Debate) REQUIRE d.id IS UNIQUE;
CREATE CONSTRAINT hypothesis_id_unique FOR (h:Hypothesis) REQUIRE h.id IS UNIQUE;
CREATE CONSTRAINT insight_id_unique FOR (i:Insight) REQUIRE i.id IS UNIQUE;
CREATE CONSTRAINT question_id_unique FOR (q:Question) REQUIRE q.id IS UNIQUE;

// ============================================================
// 3. SEED DATA — Sample knowledge graph
// Covers: VEX-CORE, EDU (spaced repetition), LOGISTICS (route consolidation)
// ============================================================

// ----------------------------------------------------------
// SOURCES
// ----------------------------------------------------------
CREATE (s1:Source {
  id: 'SRC-0001',
  type: 'paper',
  title: 'Spacing Effects in Learning: A Temporal Ridgeline of Distributed Practice',
  authors: ['Cepeda', 'Pashler', 'Vul', 'Wixted', 'Rohrer'],
  year: 2008,
  doi: '10.1037/0096-3445.134.3.353',
  url: 'https://psycnet.apa.org/record/2008-13837-001',
  domain: 'edu-core',
  source_score: 0.87
});

CREATE (s2:Source {
  id: 'SRC-0002',
  type: 'paper',
  title: 'The Effect of Feedback on Performance in Logistics Operations',
  authors: ['Smith', 'Jones'],
  year: 2020,
  doi: '10.1234/logistics.2020.001',
  url: 'https://example.org/paper-logistics-feedback',
  domain: 'logistics',
  source_score: 0.72
});

CREATE (s3:Source {
  id: 'SRC-0003',
  type: 'dataset',
  title: 'Medical Courier Delivery Time Dataset — Q1 2025',
  authors: ['LT-005 Operations'],
  year: 2025,
  url: 's3://lt005-data/delivery-times-q1-2025',
  domain: 'logistics',
  source_score: 0.95
});

CREATE (s4:Source {
  id: 'SRC-0004',
  type: 'paper',
  title: 'Spaced Repetition for Vocational Skill Acquisition: A Systematic Review',
  authors: ['Karpicke', 'Roediger'],
  year: 2018,
  doi: '10.1037/edu0000211',
  url: 'https://psycnet.apa.org/record/2018-12345-001',
  domain: 'edu-core',
  source_score: 0.82
});

CREATE (s5:Source {
  id: 'SRC-0005',
  type: 'book',
  title: 'Make It Stick: The Science of Successful Learning',
  authors: ['Brown', 'Roediger', 'McDaniel'],
  year: 2014,
  url: 'https://www.harvardpress.edu/makeitstick',
  domain: 'edu-core',
  source_score: 0.79
});

// ----------------------------------------------------------
// CONCEPTS (building blocks)
// ----------------------------------------------------------
CREATE (c1:Concept {
  id: 'CON-0001',
  label: 'Spaced Repetition',
  definition: 'Learning technique where practice is distributed over time to improve retention.',
  domain: 'edu-core',
  created: '2026-08-15'
});

CREATE (c2:Concept {
  id: 'CON-0002',
  label: 'Massed Practice',
  definition: 'Learning technique where practice is concentrated in a single session.',
  domain: 'edu-core',
  created: '2026-08-15'
});

CREATE (c3:Concept {
  id: 'CON-0003',
  label: 'Route Consolidation',
  definition: 'Combining multiple delivery stops into fewer, longer routes to reduce overhead.',
  domain: 'logistics',
  created: '2026-08-15'
});

CREATE (c4:Concept {
  id: 'CON-0004',
  label: 'Delivery Time Variance',
  definition: 'Statistical variance of delivery completion times around the mean.',
  domain: 'logistics',
  created: '2026-08-15'
});

CREATE (c5:Concept {
  id: 'CON-0005',
  label: 'Feedback Loop',
  definition: 'A system where output data is returned to operators to inform future behavior.',
  domain: 'logistics',
  created: '2026-08-15'
});

CREATE (c6:Concept {
  id: 'CON-0006',
  label: 'Forgetting Curve',
  definition: 'Ebbinghaus model describing exponential decay of memory retention over time.',
  domain: 'edu-core',
  created: '2026-08-15'
});

// ----------------------------------------------------------
// MODELS
// ----------------------------------------------------------
CREATE (m1:Model {
  id: 'MOD-0001',
  label: 'Ebbinghaus Forgetting Curve',
  description: 'R = e^(-t/S) where R is retention, t is time, S is strength.',
  domain: 'edu-core',
  created: '2026-08-15'
});

CREATE (m2:Model {
  id: 'MOD-0002',
  label: 'Vehicle Routing Problem (VRP) with Time Windows',
  description: 'Optimization model for routing vehicles to serve customers within time windows.',
  domain: 'logistics',
  created: '2026-08-15'
});

// ----------------------------------------------------------
// QUESTIONS
// ----------------------------------------------------------
CREATE (q1:Question {
  id: 'RQ-EDU-0001',
  label: 'How do spaced repetition schedules affect long-term retention in vocational training?',
  domain: 'edu-core',
  priority: 'high',
  status: 'active',
  created: '2026-08-15'
});

CREATE (q2:Question {
  id: 'RQ-LT-0001',
  label: 'How does route consolidation affect delivery time variance in medical courier networks?',
  domain: 'logistics',
  priority: 'high',
  status: 'active',
  created: '2026-08-15'
});

CREATE (q3:Question {
  id: 'RQ-VEX-0001',
  label: 'What metrics best measure venture ecosystem growth across all Worldwidebro ventures?',
  domain: 'vex-core',
  priority: 'high',
  status: 'active',
  created: '2026-08-15'
});

// ----------------------------------------------------------
// CLAIMS (statements with confidence + provenance)
// ----------------------------------------------------------
CREATE (cl1:Claim {
  id: 'CL-0001',
  statement: 'Spaced repetition outperforms massed practice for long-term declarative memory retention.',
  confidence: 0.91,
  status: 'fact',
  domain: 'edu-core',
  created: '2026-08-15',
  last_reviewed: '2026-08-15',
  falsification_criteria: 'A well-controlled randomized study showing massed practice produces superior long-term retention (measured at 30+ days) for declarative knowledge.',
  alternative_explanations: [
    'Differential motivation between groups',
    'Testing effects confounded with spacing',
    'Task difficulty not controlled'
  ]
});

CREATE (cl2:Claim {
  id: 'CL-0002',
  statement: 'The optimal spacing interval for vocabulary retention is approximately 10-20% of the desired retention period.',
  confidence: 0.76,
  status: 'evidence',
  domain: 'edu-core',
  created: '2026-08-15',
  last_reviewed: '2026-08-15',
  falsification_criteria: 'Experimental evidence showing optimal spacing is constant (not proportional to retention period) across multiple retention durations.',
  alternative_explanations: [
    'Optimal interval varies by material type',
    'Optimal interval depends on prior knowledge'
  ]
});

CREATE (cl3:Claim {
  id: 'CL-0003',
  statement: 'Route consolidation reduces mean delivery time but may increase variance under demand spikes.',
  confidence: 0.68,
  status: 'claim',
  domain: 'logistics',
  created: '2026-08-15',
  last_reviewed: '2026-08-15',
  falsification_criteria: 'Empirical data showing route consolidation reduces both mean and variance across all demand levels.',
  alternative_explanations: [
    'Driver experience moderates the variance effect',
    'Dynamic re-routing during the day eliminates the variance penalty'
  ]
});

CREATE (cl4:Claim {
  id: 'CL-0004',
  statement: 'Driver feedback loops improve on-time performance in logistics operations.',
  confidence: 0.55,
  status: 'disputed',
  domain: 'logistics',
  created: '2026-08-15',
  last_reviewed: '2026-08-15',
  falsification_criteria: 'RCT showing no significant improvement in on-time rate with feedback vs control.',
  alternative_explanations: [
    'Feedback works only for new drivers',
    'Effect is Hawthorne / novelty driven',
    'Metric gaming: drivers improve reported times, not actual times'
  ]
});

CREATE (cl5:Claim {
  id: 'CL-0005',
  statement: 'Every Worldwidebro venture should maintain a research question linked to its domain ontology.',
  confidence: 0.88,
  status: 'claim',
  domain: 'vex-core',
  created: '2026-08-15',
  last_reviewed: '2026-08-15',
  falsification_criteria: 'A venture that achieves significant growth without any linked research question.',
  alternative_explanations: [
    'Research questions are valuable only for R&D-heavy ventures',
    'Metrics-only approach is sufficient for small ventures'
  ]
});

// ----------------------------------------------------------
// EVIDENCE (links sources to claims with strength assessment)
// ----------------------------------------------------------
CREATE (e1:Evidence {
  id: 'EV-0001',
  claim_supported: 'CL-0001',
  source: 'SRC-0001',
  location: 'Experiment 3, pp. 361-364',
  evidence: 'Participants who received spaced presentations showed 65% retention at 8-year follow-up vs 20% for massed presentation.',
  evidence_type: 'experimental',
  strength: 'strong',
  reliability: 'high',
  researcher_interpretation: 'Large effect size; replication across multiple materials.'
});

CREATE (e2:Evidence {
  id: 'EV-0002',
  claim_supported: 'CL-0001',
  source: 'SRC-0004',
  location: 'Section 4.2',
  evidence: 'Systematic review of 42 studies found spaced repetition effect size d=0.89 for vocational skills.',
  evidence_type: 'experimental',
  strength: 'moderate',
  reliability: 'medium',
  researcher_interpretation: 'Moderate heterogeneity across studies; vocational context under-represented.'
});

CREATE (e3:Evidence {
  id: 'EV-0003',
  claim_supported: 'CL-0002',
  source: 'SRC-0001',
  location: 'Figure 2',
  evidence: 'Optimal gap increased linearly with desired retention interval (R²=0.94).',
  evidence_type: 'experimental',
  strength: 'moderate',
  reliability: 'high',
  researcher_interpretation: 'Supports proportional spacing rule; limited to word-pair materials.'
});

CREATE (e4:Evidence {
  id: 'EV-0004',
  claim_supported: 'CL-0003',
  source: 'SRC-0003',
  location: 'Q1 2025 delivery records',
  evidence: 'Consolidated routes (n=18) showed mean delivery time 12% lower (p<0.01) but variance 23% higher (p=0.04) vs non-consolidated routes (n=42).',
  evidence_type: 'observational',
  strength: 'moderate',
  reliability: 'medium',
  researcher_interpretation: 'Confounded by route length and driver experience. RCT needed.'
});

CREATE (e5:Evidence {
  id: 'EV-0005',
  claim_supported: 'CL-0004',
  source: 'SRC-0002',
  location: 'Study 2',
  evidence: 'Feedback group improved on-time rate by 8pp (p=0.03) over 4 weeks; effect decayed to 2pp by week 8.',
  evidence_type: 'experimental',
  strength: 'moderate',
  reliability: 'medium',
  researcher_interpretation: 'Effect decays without reinforcement. Long-term RCT needed.'
});

// ----------------------------------------------------------
// HYPOTHESES (testable predictions with falsification criteria)
// ----------------------------------------------------------
CREATE (h1:Hypothesis {
  id: 'HYP-EDU-0001',
  statement: 'A 3-day inter-session interval produces superior 30-day retention for procedural vocational skills compared to a 1-day interval.',
  mechanism: 'Longer spacing allows partial forgetting, which strengthens re-encoding during retrieval practice.',
  prediction: [
    'Group with 3-day spacing will score ≥15% higher on 30-day retention test',
    'Effect will persist at 90-day follow-up',
    'No difference in immediate post-test performance'
  ],
  falsification_criteria: 'No significant difference between 3-day and 1-day spacing groups on 30-day retention test.',
  experiment: 'EXP-EDU-0001',
  status: 'proposed',
  created: '2026-08-15'
});

CREATE (h2:Hypothesis {
  id: 'HYP-EDU-0002',
  statement: 'Portfolio-based assessment correlates with workplace performance at r≥0.60 for vocational training completers.',
  mechanism: 'Portfolios capture authentic performance that transfer to workplace contexts.',
  prediction: [
    'Portfolio score will correlate with supervisor rating at r≥0.60',
    'Multiple-choice test will correlate at r≤0.40 with same supervisor rating',
    'Portfolio assessment will add predictive validity beyond MCQ scores'
  ],
  falsification_criteria: 'Portfolio-supervisor correlation < 0.40, or no incremental validity over MCQ.',
  experiment: 'EXP-EDU-0002',
  status: 'proposed',
  created: '2026-08-15'
});

CREATE (h3:Hypothesis {
  id: 'HYP-LT-0001',
  statement: 'Dynamic re-routing during the day eliminates the variance penalty of route consolidation.',
  mechanism: 'Real-time redistribution of deliveries prevents route overload when demand spikes.',
  prediction: [
    'Consolidated routes with dynamic re-routing will show variance ≤ non-consolidated routes',
    'Mean delivery time will remain lower than non-consolidated',
    'Effect depends on re-routing frequency (threshold: every 2 hours)'
  ],
  falsification_criteria: 'Variance of consolidated+dynamic routes exceeds non-consolidated routes.',
  experiment: 'EXP-LT-0001',
  status: 'proposed',
  created: '2026-08-15'
});

// ----------------------------------------------------------
// INSIGHTS (synthesized interpretations)
// ----------------------------------------------------------
CREATE (i1:Insight {
  id: 'INS-0001',
  statement: 'The forgetting curve (MOD-0001) explains why vocational training using massed practice fails: skills are retained for the test but decay before workplace application.',
  confidence: 0.82,
  domain: 'edu-core',
  created: '2026-08-15',
  sources: ['SRC-0001', 'SRC-0005']
});

CREATE (i2:Insight {
  id: 'INS-0002',
  statement: 'Route consolidation and feedback loops interact: consolidation reduces mean time (good) but may increase variance; feedback can reduce variance if it targets timeliness specifically.',
  confidence: 0.61,
  domain: 'logistics',
  created: '2026-08-15',
  sources: ['SRC-0002', 'SRC-0003']
});

CREATE (i3:Insight {
  id: 'INS-0003',
  statement: 'VEX-CORE ventures span multiple sectors (EC, TECH, EDU, LT, FIN); a single growth metric cannot capture ecosystem health. A composite dashboard with sector-weighted indicators is required.',
  confidence: 0.77,
  domain: 'vex-core',
  created: '2026-08-15',
  sources: ['SRC-0003']
});

// ----------------------------------------------------------
// DEBATES (contested areas with positions)
// ----------------------------------------------------------
CREATE (d1:Debate {
  id: 'DEB-0001',
  label: 'Optimal spacing interval for procedural vs declarative skills',
  domain: 'edu-core',
  status: 'active',
  created: '2026-08-15'
});

CREATE (d2:Debate {
  id: 'DEB-0002',
  label: 'Does route consolidation help or hurt delivery reliability?',
  domain: 'logistics',
  status: 'active',
  created: '2026-08-15'
});

// ----------------------------------------------------------
// RELATIONSHIPS
// ----------------------------------------------------------

// --- Sources support claims ---
MATCH (s:Source {id: 'SRC-0001'}), (c:Claim {id: 'CL-0001'})
CREATE (s)-[:SUPPORTS {strength: 'strong', date: '2026-08-15'}]->(c);

MATCH (s:Source {id: 'SRC-0004'}), (c:Claim {id: 'CL-0001'})
CREATE (s)-[:SUPPORTS {strength: 'moderate', date: '2026-08-15'}]->(c);

MATCH (s:Source {id: 'SRC-0001'}), (c:Claim {id: 'CL-0002'})
CREATE (s)-[:SUPPORTS {strength: 'moderate', date: '2026-08-15'}]->(c);

MATCH (s:Source {id: 'SRC-0003'}), (c:Claim {id: 'CL-0003'})
CREATE (s)-[:SUPPORTS {strength: 'moderate', date: '2026-08-15'}]->(c);

MATCH (s:Source {id: 'SRC-0002'}), (c:Claim {id: 'CL-0004'})
CREATE (s)-[:SUPPORTS {strength: 'moderate', date: '2026-08-15'}]->(c);

MATCH (s:Source {id: 'SRC-0003'}), (c:Claim {id: 'CL-0005'})
CREATE (s)-[:SUPPORTS {strength: 'strong', date: '2026-08-15'}]->(c);

// --- Evidence links to claims ---
MATCH (e:Evidence {id: 'EV-0001'}), (c:Claim {id: 'CL-0001'})
CREATE (e)-[:SUPPORTS_CLAIM {strength: 'strong'}]->(c);

MATCH (e:Evidence {id: 'EV-0002'}), (c:Claim {id: 'CL-0001'})
CREATE (e)-[:SUPPORTS_CLAIM {strength: 'moderate'}]->(c);

MATCH (e:Evidence {id: 'EV-0003'}), (c:Claim {id: 'CL-0002'})
CREATE (e)-[:SUPPORTS_CLAIM {strength: 'moderate'}]->(c);

MATCH (e:Evidence {id: 'EV-0004'}), (c:Claim {id: 'CL-0003'})
CREATE (e)-[:SUPPORTS_CLAIM {strength: 'moderate'}]->(c);

MATCH (e:Evidence {id: 'EV-0005'}), (c:Claim {id: 'CL-0004'})
CREATE (e)-[:SUPPORTS_CLAIM {strength: 'moderate'}]->(c);

// --- Evidence linked to sources ---
MATCH (e:Evidence {id: 'EV-0001'}), (s:Source {id: 'SRC-0001'})
CREATE (e)-[:FROM_SOURCE]->(s);

MATCH (e:Evidence {id: 'EV-0002'}), (s:Source {id: 'SRC-0004'})
CREATE (e)-[:FROM_SOURCE]->(s);

MATCH (e:Evidence {id: 'EV-0003'}), (s:Source {id: 'SRC-0001'})
CREATE (e)-[:FROM_SOURCE]->(s);

MATCH (e:Evidence {id: 'EV-0004'}), (s:Source {id: 'SRC-0003'})
CREATE (e)-[:FROM_SOURCE]->(s);

MATCH (e:Evidence {id: 'EV-0005'}), (s:Source {id: 'SRC-0002'})
CREATE (e)-[:FROM_SOURCE]->(s);

// --- Claims contradict claims ---
MATCH (c1:Claim {id: 'CL-0001'}), (c2:Claim {id: 'CL-0003'})
// Different domains — no contradiction

MATCH (c1:Claim {id: 'CL-0001'}), (c2:Claim {id: 'CL-0004'})
// No direct contradiction

// --- Concepts related to claims ---
MATCH (c:Concept {id: 'CON-0001'}), (cl:Claim {id: 'CL-0001'})
CREATE (c)-[:RELATES_TO {role: 'core_concept'}]->(cl);

MATCH (c:Concept {id: 'CON-0002'}), (cl:Claim {id: 'CL-0001'})
CREATE (c)-[:RELATES_TO {role: 'contrast'}]->(cl);

MATCH (c:Concept {id: 'CON-0003'}), (cl:Claim {id: 'CL-0003'})
CREATE (c)-[:RELATES_TO {role: 'core_concept'}]->(cl);

MATCH (c:Concept {id: 'CON-0004'}), (cl:Claim {id: 'CL-0003'})
CREATE (c)-[:RELATES_TO {role: 'measured_outcome'}]->(cl);

MATCH (c:Concept {id: 'CON-0005'}), (cl:Claim {id: 'CL-0004'})
CREATE (c)-[:RELATES_TO {role: 'intervention'}]->(cl);

MATCH (c:Concept {id: 'CON-0006'}), (cl:Claim {id: 'CL-0002'})
CREATE (c)-[:RELATES_TO {role: 'theoretical_basis'}]->(cl);

// --- Models relate to concepts ---
MATCH (m:Model {id: 'MOD-0001'}), (c:Concept {id: 'CON-0006'})
CREATE (m)-[:DESCRIBES]->(c);

MATCH (m:Model {id: 'MOD-0002'}), (c:Concept {id: 'CON-0003'})
CREATE (m)-[:DESCRIBES]->(c);

// --- Questions link to concepts and claims ---
MATCH (q:Question {id: 'RQ-EDU-0001'}), (c:Concept {id: 'CON-0001'})
CREATE (q)-[:INVESTIGATES]->(c);

MATCH (q:Question {id: 'RQ-EDU-0001'}), (c:Concept {id: 'CON-0002'})
CREATE (q)-[:INVESTIGATES]->(c);

MATCH (q:Question {id: 'RQ-EDU-0001'}), (cl:Claim {id: 'CL-0001'})
CREATE (q)-[:EVALUATES_CLAIM]->(cl);

MATCH (q:Question {id: 'RQ-EDU-0001'}), (h:Hypothesis {id: 'HYP-EDU-0001'})
CREATE (q)-[:HAS_HYPOTHESIS]->(h);

MATCH (q:Question {id: 'RQ-LT-0001'}), (c:Concept {id: 'CON-0003'})
CREATE (q)-[:INVESTIGATES]->(c);

MATCH (q:Question {id: 'RQ-LT-0001'}), (c:Concept {id: 'CON-0004'})
CREATE (q)-[:INVESTIGATES]->(c);

MATCH (q:Question {id: 'RQ-LT-0001'}), (cl:Claim {id: 'CL-0003'})
CREATE (q)-[:EVALUATES_CLAIM]->(cl);

MATCH (q:Question {id: 'RQ-LT-0001'}), (h:Hypothesis {id: 'HYP-LT-0001'})
CREATE (q)-[:HAS_HYPOTHESIS]->(h);

MATCH (q:Question {id: 'RQ-VEX-0001'}), (cl:Claim {id: 'CL-0005'})
CREATE (q)-[:EVALUATES_CLAIM]->(cl);

// --- Hypotheses link to claims ---
MATCH (h:Hypothesis {id: 'HYP-EDU-0001'}), (cl:Claim {id: 'CL-0001'})
CREATE (h)-[:BASED_ON_CLAIM]->(cl);

MATCH (h:Hypothesis {id: 'HYP-LT-0001'}), (cl:Claim {id: 'CL-0003'})
CREATE (h)-[:BASED_ON_CLAIM]->(cl);

// --- Insights synthesize claims and evidence ---
MATCH (i:Insight {id: 'INS-0001'}), (cl:Claim {id: 'CL-0001'})
CREATE (i)-[:SYNTHESIZES_CLAIM]->(cl);

MATCH (i:Insight {id: 'INS-0001'}), (e:Evidence {id: 'EV-0001'})
CREATE (i)-[:BASED_ON_EVIDENCE]->(e);

MATCH (i:Insight {id: 'INS-0002'}), (cl:Claim {id: 'CL-0003'})
CREATE (i)-[:SYNTHESIZES_CLAIM]->(cl);

MATCH (i:Insight {id: 'INS-0002'}), (cl:Claim {id: 'CL-0004'})
CREATE (i)-[:SYNTHESIZES_CLAIM]->(cl);

MATCH (i:Insight {id: 'INS-0003'}), (cl:Claim {id: 'CL-0005'})
CREATE (i)-[:SYNTHESIZES_CLAIM]->(cl);

// --- Debates contain claims ---
MATCH (d:Debate {id: 'DEB-0001'}), (cl:Claim {id: 'CL-0001'})
CREATE (d)-[:CONTAINS_CLAIM {position: 'majority'}]->(cl);

MATCH (d:Debate {id: 'DEB-0002'}), (cl:Claim {id: 'CL-0003'})
CREATE (d)-[:CONTAINS_CLAIM {position: 'tentative'}]->(cl);

MATCH (d:Debate {id: 'DEB-0002'}), (cl:Claim {id: 'CL-0004'})
CREATE (d)-[:CONTAINS_CLAIM {position: 'contested'}]->(cl);

// --- Sources cited by debates ---
MATCH (d:Debate {id: 'DEB-0001'}), (s:Source {id: 'SRC-0001'})
CREATE (d)-[:CITED_BY]->(s);

MATCH (d:Debate {id: 'DEB-0002'}), (s:Source {id: 'SRC-0002'})
CREATE (d)-[:CITED_BY]->(s);

MATCH (d:Debate {id: 'DEB-0002'}), (s:Source {id: 'SRC-0003'})
CREATE (d)-[:CITED_BY]->(s);

// ============================================================
// 4. USEFUL QUERIES (for agent use)
// ============================================================

// Q1: Find all claims in a domain with their confidence and sources
// CALL research_claims_in_domain('edu-core');
CREATE OR REPLACE PROCEDURE research_claims_in_domain(domain_param STRING)
YIELD claim_id, statement, confidence, status, source_count
BEGIN
  CALL {
    WITH domain_param
    MATCH (c:Claim {domain: domain_param})
    RETURN c.id AS claim_id, c.statement AS statement,
           c.confidence AS confidence, c.status AS status
  }
  CALL {
    WITH claim_id
    MATCH (s:Source)-[:SUPPORTS]->(c:Claim {id: claim_id})
    RETURN count(s) AS source_count
  }
  RETURN claim_id, statement, confidence, status, source_count;
END;

// Q2: Find contradictions — claims in same domain with conflicting evidence
// CALL research_find_contradictions('edu-core');
CREATE OR REPLACE PROCEDURE research_find_contradictions(domain_param STRING)
YIELD claim1_id, claim1_statement, claim2_id, claim2_statement, conflict_strength
BEGIN
  CALL {
    WITH domain_param
    MATCH (c1:Claim {domain: domain_param})
    MATCH (c2:Claim {domain: domain_param})
    WHERE c1.id < c2.id
    OPTIONAL MATCH (c1)<-[:SUPPORTS_CLAIM]-(e1:Evidence)
    OPTIONAL MATCH (c2)<-[:SUPPORTS_CLAIM]-(e2:Evidence)
    WHERE e1.source = e2.source
    RETURN c1, c2, count(e1) + count(e2) AS shared_sources
    HAVING shared_sources > 0
  }
  RETURN c1.id AS claim1_id, c1.statement AS claim1_statement,
         c2.id AS claim2_id, c2.statement AS claim2_statement,
         shared_sources AS conflict_strength;
END;

// Q3: Evidence quality score per claim
// CALL research_evidence_quality('CL-0001');
CREATE OR REPLACE PROCEDURE research_evidence_quality(claim_id_param STRING)
YIELD claim_id, claim_statement, avg_strength, evidence_count, high_reliability_count
BEGIN
  CALL {
    WITH claim_id_param
    MATCH (e:Evidence)-[:SUPPORTS_CLAIM]->(c:Claim {id: claim_id_param})
    RETURN c.id AS claim_id, c.statement AS claim_statement,
           count(e) AS evidence_count,
           sum(
             CASE e.strength
               WHEN 'strong' THEN 3
               WHEN 'moderate' THEN 2
               WHEN 'weak' THEN 1
               ELSE 0
             END
           ) AS strength_points
  }
  RETURN claim_id, claim_statement, evidence_count,
         (strength_points / evidence_count) AS avg_strength,
         count(CASE WHEN e.reliability = 'high' THEN 1 END) AS high_reliability_count
  FROM (
    WITH claim_id_param
    MATCH (e:Evidence)-[:SUPPORTS_CLAIM]->(c:Claim {id: claim_id_param})
    RETURN c.id AS claim_id, c.statement AS claim_statement, e
  );
END;

// Q4: Concept graph — what concepts connect to what claims
// CALL research_concept_map('edu-core');
CREATE OR REPLACE PROCEDURE research_concept_map(domain_param STRING)
YIELD concept_id, concept_label, claim_id, claim_statement, relationship_role
BEGIN
  CALL {
    WITH domain_param
    MATCH (c:Concept {domain: domain_param})
    MATCH (c)-[r:RELATES_TO]->(cl:Claim)
    RETURN c.id AS concept_id, c.label AS concept_label,
           cl.id AS claim_id, cl.statement AS claim_statement,
           r.role AS relationship_role
  }
  RETURN concept_id, concept_label, claim_id, claim_statement, relationship_role;
END;

// Q5: Hypothesis status summary per question
// CALL research_hypothesis_status('RQ-EDU-0001');
CREATE OR REPLACE PROCEDURE research_hypothesis_status(question_id_param STRING)
YIELD question_id, hypothesis_id, hypothesis_statement, status, experiment_id
BEGIN
  CALL {
    WITH question_id_param
    MATCH (q:Question {id: question_id_param})
    MATCH (q)-[:HAS_HYPOTHESIS]->(h:Hypothesis)
    RETURN q.id AS question_id, h.id AS hypothesis_id,
           h.statement AS hypothesis_statement, h.status AS status,
           h.experiment AS experiment_id
  }
  RETURN question_id, hypothesis_id, hypothesis_statement, status, experiment_id;
END;

// Q6: Full provenance chain for a claim
// CALL research_provenance_chain('CL-0001');
CREATE OR REPLACE PROCEDURE research_provenance_chain(claim_id_param STRING)
YIELD node_id, node_type, node_label, relationship, source_id
BEGIN
  CALL {
    WITH claim_id_param
    MATCH (c:Claim {id: claim_id_param})
    OPTIONAL MATCH (s:Source)-[r1:SUPPORTS]->(c)
    RETURN c.id AS node_id, 'Claim' AS node_type, c.statement AS node_label,
           'claim' AS relationship, s.id AS source_id
    UNION
    WITH claim_id_param
    MATCH (c:Claim {id: claim_id_param})
    OPTIONAL MATCH (e:Evidence)-[r2:SUPPORTS_CLAIM]->(c)
    RETURN e.id AS node_id, 'Evidence' AS node_type, e.evidence AS node_label,
           'evidence' AS relationship, e.source AS source_id
  }
  RETURN node_id, node_type, node_label, relationship, source_id;
END;

// Q7: Find all insights that synthesize a given claim
// CALL research_insights_for_claim('CL-0001');
MATCH (i:Insight)-[:SYNTHESIZES_CLAIM]->(c:Claim {id: 'CL-0001'})
RETURN i.id AS insight_id, i.statement AS insight_statement, i.confidence AS confidence, i.domain AS domain;

// ============================================================
// 5. VERIFICATION
// ============================================================
// Run after seeding: verify all node types exist
MATCH (n)
RETURN labels(n) AS node_type, count(n) AS count
ORDER BY node_type;

// Expected output:
// Source      5
// Concept     6
// Model       2
// Question    3
// Claim       5
// Evidence    5
// Hypothesis  3
// Insight     3
// Debate      2
// ──────────────────────────────────────────────────────────
// Total       34 nodes
