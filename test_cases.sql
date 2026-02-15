DROP TRIGGER IF EXISTS enforce_event_transition_trigger ON decision_events;
DROP TRIGGER IF EXISTS forbid_modification_trigger ON decision_events;
DROP TRIGGER IF EXISTS enforce_single_open_decision_trigger ON decision_events;
DROP TRIGGER IF EXISTS enforce_causal_index_order_trigger ON decision_events;
DROP FUNCTION IF EXISTS enforce_event_transition();
DROP FUNCTION IF EXISTS forbid_modification();
DROP FUNCTION IF EXISTS enforce_single_open_decision();
DROP FUNCTION IF EXISTS enforce_causal_index_order();
DROP TABLE IF EXISTS decision_events;


SELECT * FROM decision_events;


INSERT INTO decision_events(decision_id, causal_index, event_type)
VALUES
('11111111-1111-1111-1111-111111111111', 1, 'INPUTS'),
('11111111-1111-1111-1111-111111111111', 2, 'FEATURES'),
('11111111-1111-1111-1111-111111111111', 3, 'MODEL'),
('11111111-1111-1111-1111-111111111111', 4, 'POLICY'),
('11111111-1111-1111-1111-111111111111', 5, 'FINALIZED');


INSERT INTO decision_events(decision_id, causal_index, event_type)
VALUES ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 1, 'INPUTS');
INSERT INTO decision_events(decision_id, causal_index, event_type)
VALUES ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 1, 'INPUTS');

-- First decision
INSERT INTO decision_events VALUES
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 1, 'INPUTS'),
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 2, 'FINALIZED');
-- Second decision (starts AFTER first finished)
INSERT INTO decision_events VALUES
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 1, 'INPUTS'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 2, 'FINALIZED');


INSERT INTO decision_events VALUES
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 1, 'INPUTS');
INSERT INTO decision_events VALUES
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 1, 'INPUTS');
INSERT INTO decision_events VALUES
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa0', 1, 'FINALIZED');


UPDATE decision_events SET event_type = 'MODEL' WHERE event_type = 'INPUTS'
DELETE FROM decision_events WHERE decision_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';


INSERT INTO decision_events VALUES
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 1, 'INPUTS'),
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 2, 'FEATURES'),
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 3, 'MODEL'),
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 4, 'POLICY'),
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 5, 'FINALIZED');

INSERT INTO decision_events VALUES
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 1, 'INPUTS'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 2, 'FEATURES'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 3, 'MODEL'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 4, 'POLICY'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 5, 'OVERRIDE'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 6, 'FINALIZED');

INSERT INTO decision_events VALUES
('ffffffff-ffff-ffff-ffff-ffffffffffff', 1, 'INPUTS'),
('ffffffff-ffff-ffff-ffff-ffffffffffff', 2, 'MODEL');

INSERT INTO decision_events VALUES
('11111111-2222-3333-4444-555555555555', 1, 'INPUTS'),
('11111111-2222-3333-4444-555555555555', 2, 'FEATURES'),
('11111111-2222-3333-4444-555555555555', 3, 'POLICY');

INSERT INTO decision_events VALUES
('66666666-7777-8888-9999-000000000000', 1, 'INPUTS'),
('66666666-7777-8888-9999-000000000000', 2, 'FEATURES'),
('66666666-7777-8888-9999-000000000000', 3, 'MODEL'),
('66666666-7777-8888-9999-000000000000', 4, 'OVERRIDE');

INSERT INTO decision_events VALUES
('99999999-aaaa-bbbb-cccc-dddddddddddd', 1, 'INPUTS'),
('99999999-aaaa-bbbb-cccc-dddddddddddd', 2, 'FINALIZED'),
('99999999-aaaa-bbbb-cccc-dddddddddddd', 3, 'FEATURES');


INSERT INTO decision_events VALUES
('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 1, 'MODEL');
ROLLBACK;
