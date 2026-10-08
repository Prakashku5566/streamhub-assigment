-- ====================================================================================
-- A4 SQL Assessment: Round-Trip Transfer Detection
-- Scenario: A -> B, followed by B -> A
-- Conditions: Return amount is within 10% of original, and within 24 hours.
-- ====================================================================================

-- 1. Create the table structure
CREATE TABLE transactions (
    id INT PRIMARY KEY,
    sender_account VARCHAR(50),
    receiver_account VARCHAR(50),
    amount DECIMAL(15, 2),
    transaction_time TIMESTAMP
);

-- 2. Insert sample test data
INSERT INTO transactions (id, sender_account, receiver_account, amount, transaction_time) VALUES
-- Valid Round-Trip (Within 10% and 24 hours)
(1, 'ACC_A', 'ACC_B', 1000.00, '2023-10-01 10:00:00'),
(2, 'ACC_B', 'ACC_A', 950.00,  '2023-10-01 15:00:00'),

-- Invalid Round-Trip (Amount is outside 10% threshold. 400 is not within 450-550)
(3, 'ACC_C', 'ACC_D', 500.00,  '2023-10-01 08:00:00'),
(4, 'ACC_D', 'ACC_C', 400.00,  '2023-10-01 09:00:00'),

-- Invalid Round-Trip (Time is outside the 24 hour window)
(5, 'ACC_E', 'ACC_F', 2000.00, '2023-10-01 10:00:00'),
(6, 'ACC_F', 'ACC_E', 1900.00, '2023-10-03 10:00:00');

-- ====================================================================================
-- 3. SQL #1 - Self JOIN Query
-- ====================================================================================

SELECT 
    T1.id AS original_txn_id,
    T1.sender_account AS account_A,
    T1.receiver_account AS account_B,
    T1.amount AS amount_sent,
    T1.transaction_time AS time_sent,
    
    T2.id AS return_txn_id,
    T2.amount AS amount_returned,
    T2.transaction_time AS time_returned
FROM 
    transactions T1
JOIN 
    transactions T2 
    -- Match the reversed sender/receiver roles
    ON T1.sender_account = T2.receiver_account 
    AND T1.receiver_account = T2.sender_account
WHERE 
    -- Ensure chronological order (Return transaction happens AFTER original)
    T2.transaction_time > T1.transaction_time
    
    -- Condition 1: Within 24 hours
    -- Note: PostgreSQL syntax. For SQL Server use: DATEDIFF(hour, T1.transaction_time, T2.transaction_time) <= 24
    -- For MySQL use: TIMESTAMPDIFF(HOUR, T1.transaction_time, T2.transaction_time) <= 24
    AND T2.transaction_time <= T1.transaction_time + INTERVAL '24 hours'
    
    -- Condition 2: Amount is within 10%
    -- Meaning T2 amount is between 90% (0.90) and 110% (1.10) of T1 amount
    AND T2.amount BETWEEN (T1.amount * 0.90) AND (T1.amount * 1.10);
