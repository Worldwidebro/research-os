// Create source node
CREATE (s:Source {id: $id, title: $title, year: $year})

// Link source to claim
MATCH (s:Source {id: $source_id}), (c:Claim {id: $claim_id})
CREATE (s)-[:SUPPORTS]->(c)

// Find contradictions
MATCH (c1:Claim {id: $claim_id}), (c2:Claim)
WHERE c2.id <> c1.id AND c2.domain = c1.domain
OPTIONAL MATCH (c2)<-[r:CONTRADICTS]-()
RETURN c2, count(r) AS contradiction_strength
ORDER BY contradiction_strength DESC
LIMIT 10
