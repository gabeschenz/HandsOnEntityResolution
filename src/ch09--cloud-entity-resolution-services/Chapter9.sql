-- TODO: Get a better name for table `clusters_15719257497877843494`.
-- TODO: Get a better name for table `temp`.
-- TODO: Be consistent with use of schema name.
-- TODO: Convert this to use duckdb.
-- TODO: Rename the file to something more expressive.

-- Select all rows with clusters_ids where those cluster_ids
-- have at least one Mari match.
CREATE TEMP TABLE temp
AS
WITH mari AS (
    SELECT cluster_id
    FROM chapter9.clusters_15719257497877843494
    WHERE source_name = 'mari'
)

SELECT src.*
FROM chapter9.clusters_15719257497877843494 AS src
INNER JOIN mari
    ON (src.cluster_id = mari.cluster_id);

-- Select subset of clusters who have both an Mari match and at
-- least one Basic match. Remove clusters with only Mari match
CREATE TEMP TABLE match
AS
WITH matches AS (
    SELECT cluster_id
    FROM temp
    GROUP BY cluster_id
    HAVING COUNT(*) > 1
)

SELECT src.*
FROM temp AS src
INNER JOIN matches
    ON (src.cluster_id = matches.cluster_id);

-- Add extra columns from either basic or mari table, order by
-- cluster for easy comparision
CREATE TABLE chapter9.results
AS
WITH res1 AS (
    SELECT *
    FROM match
    WHERE match.source_name = match.basic
),

res2 AS (
    SELECT *
    FROM match
    WHERE match.source_name = match.mari
)

SELECT *
FROM chapter9.basic AS bas
INNER JOIN res1
    ON (res1.source_key = CAST(bas.unique_id AS STRING))
UNION ALL
SELECT *
FROM chapter9.mari AS mari
INNER JOIN res2
    ON (res2.source_key = CAST(mari.unique_id AS STRING))
ORDER BY
    confidence,
    cluster_id;
