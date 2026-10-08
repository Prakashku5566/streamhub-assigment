-- ====================================================================================
-- A4 SQL Assessment: IPL 2024 Batting Streak
-- Requirement: Find players who scored 30+ runs in 3 consecutive matches in IPL 2024
-- Output: player_name, streak_start_date
-- Techniques demonstrated: Window Functions (ROW_NUMBER, LAG, PARTITION BY), Gap & Islands
-- ====================================================================================

-- 1. Create the table structure
CREATE TABLE ipl_batting (
    player VARCHAR(100),
    match_date DATE,
    runs INT
);

-- 2. Insert sample data (Simulating IPL 2024)
INSERT INTO ipl_batting (player, match_date, runs) VALUES
-- Virat Kohli (Valid Streak: April 5, 10, 15)
('Virat Kohli', '2024-04-01', 15),
('Virat Kohli', '2024-04-05', 35), -- Streak starts
('Virat Kohli', '2024-04-10', 42),
('Virat Kohli', '2024-04-15', 55), -- 3rd consecutive 30+
('Virat Kohli', '2024-04-20', 10), 

-- Rohit Sharma (Invalid: Only 2 consecutive 30+)
('Rohit Sharma', '2024-04-02', 40),
('Rohit Sharma', '2024-04-06', 45),
('Rohit Sharma', '2024-04-12', 12),
('Rohit Sharma', '2024-04-16', 60),

-- MS Dhoni (Valid Streak: May 1, 5, 10)
('MS Dhoni', '2024-05-01', 32), -- Streak starts
('MS Dhoni', '2024-05-05', 31),
('MS Dhoni', '2024-05-10', 30),
('MS Dhoni', '2024-05-15', 5);

-- ====================================================================================
-- 3. SQL #2 - Approach A: Gap and Islands using ROW_NUMBER()
-- (Highly professional, scalable for N consecutive matches)
-- ====================================================================================

WITH MatchSequence AS (
    -- Step A: Assign a sequence number to all matches for a player in 2024
    SELECT 
        player,
        match_date,
        runs,
        ROW_NUMBER() OVER(PARTITION BY player ORDER BY match_date) as rn_overall
    FROM ipl_batting
    WHERE EXTRACT(YEAR FROM match_date) = 2024
),
ThirtyPlusSequence AS (
    -- Step B: Assign a sequence number ONLY to matches where runs >= 30
    SELECT 
        player,
        match_date,
        runs,
        rn_overall,
        ROW_NUMBER() OVER(PARTITION BY player ORDER BY match_date) as rn_30_plus
    FROM MatchSequence
    WHERE runs >= 30
),
StreakGroups AS (
    -- Step C: The difference between the two row numbers creates a unique "Island ID"
    -- for consecutive streaks. If a match is missed, rn_overall increases but rn_30_plus doesn't.
    SELECT 
        player,
        match_date,
        (rn_overall - rn_30_plus) AS streak_island_id
    FROM ThirtyPlusSequence
)
SELECT 
    player AS player_name,
    MIN(match_date) AS streak_start_date
FROM StreakGroups
GROUP BY 
    player, streak_island_id
HAVING 
    COUNT(*) >= 3; -- Ensure the streak is at least 3 matches long


-- ====================================================================================
-- 4. SQL #2 - Approach B: Direct positional check using LAG()
-- (Simpler and very efficient if we only ever care about exactly 3 matches)
-- ====================================================================================

WITH PlayerHistory AS (
    SELECT 
        player,
        match_date,
        runs,
        LAG(runs, 1) OVER(PARTITION BY player ORDER BY match_date) as prev_1_runs,
        LAG(runs, 2) OVER(PARTITION BY player ORDER BY match_date) as prev_2_runs,
        LAG(match_date, 2) OVER(PARTITION BY player ORDER BY match_date) as streak_start_date
    FROM ipl_batting
    WHERE EXTRACT(YEAR FROM match_date) = 2024
)
SELECT DISTINCT
    player AS player_name,
    streak_start_date
FROM PlayerHistory
WHERE 
    runs >= 30 
    AND prev_1_runs >= 30 
    AND prev_2_runs >= 30;
