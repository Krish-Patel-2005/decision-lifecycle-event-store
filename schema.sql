CREATE TABLE decision_events(
	decision_id UUID DEFAULT gen_random_uuid() NOT NULL,
	causal_index INT NOT NULL,
	event_type TEXT NOT NULL,
	time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	CONSTRAINT causal_index_positive CHECK (causal_index >= 1),
	CONSTRAINT unique_decision_event UNIQUE (decision_id, causal_index),
	CONSTRAINT valid_event_type CHECK (event_type IN (
										'INPUTS',
										'FEATURES',
										'MODEL',
										'POLICY',
										'OVERRIDE',
										'FINALIZED'		
								))
);


CREATE FUNCTION enforce_causal_index_order()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE expected INT;
BEGIN
	expected := COALESCE((SELECT MAX(causal_index) FROM decision_events 
				WHERE decision_id = NEW.decision_id), 0) + 1;
	IF NEW.causal_index != expected THEN RAISE EXCEPTION 
		'Casual Index order violation: expected %, got %', expected, NEW.causal_index;
	END IF;
	RETURN NEW;
END;
$$;

CREATE TRIGGER enforce_causal_index_order_trigger
BEFORE INSERT ON decision_events
FOR EACH ROW
EXECUTE FUNCTION enforce_causal_index_order();


CREATE FUNCTION enforce_single_open_decision()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE open_decision_count INT;
BEGIN
	SELECT COUNT(DISTINCT decision_id) INTO open_decision_count
	FROM decision_events WHERE event_type = 'INPUTS'
	AND decision_id NOT IN (
		SELECT decision_id FROM decision_events
		WHERE event_type = 'FINALIZED'
	);
	IF open_decision_count > 1 THEN
		RAISE EXCEPTION 'Only one decision lifecycle can be active at a time';
	END IF;
	RETURN NULL;
END;
$$;

CREATE CONSTRAINT TRIGGER enforce_single_open_decision_trigger
AFTER INSERT OR UPDATE OR DELETE ON decision_events
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW
EXECUTE FUNCTION enforce_single_open_decision();


CREATE FUNCTION forbid_modification()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
	RAISE EXCEPTION 'decision_events is append only';
END;
$$;

CREATE TRIGGER forbid_modification_trigger
BEFORE UPDATE OR DELETE ON decision_events
FOR EACH ROW
EXECUTE FUNCTION forbid_modification();


CREATE FUNCTION enforce_event_transition()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE prev_event TEXT;
BEGIN
	-- First event must be INPUTS
	IF NEW.causal_index = 1 THEN
		IF NEW.event_type <> 'INPUTS' THEN
			RAISE EXCEPTION 'First event must be INPUTS, got %', NEW.event_type;
		END IF;
		RETURN NEW;
	END IF;
	
	-- Get previous event
	SELECT event_type INTO prev_event FROM decision_events
	WHERE decision_id = NEW.decision_id AND causal_index = NEW.causal_index - 1;

	IF prev_event IS NULL THEN
		RAISE EXCEPTION 'Missing previous event at causal_index %', NEW.causal_index - 1;
	END IF;

	IF NOT ((prev_event = 'INPUTS'   AND NEW.event_type = 'FEATURES') OR
        	(prev_event = 'FEATURES' AND NEW.event_type = 'MODEL') OR
        	(prev_event = 'MODEL'    AND NEW.event_type = 'POLICY') OR
        	(prev_event = 'POLICY'   AND NEW.event_type IN ('OVERRIDE', 'FINALIZED')) OR
        	(prev_event = 'OVERRIDE' AND NEW.event_type = 'FINALIZED')
    	) THEN 
		RAISE EXCEPTION 'Invalid transition: % -> %', prev_event, NEW.event_type;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER enforce_event_transition_trigger
BEFORE INSERT ON decision_events
FOR EACH ROW
EXECUTE FUNCTION enforce_event_transition();


DROP TRIGGER IF EXISTS enforce_event_transition_trigger ON decision_events;
DROP TRIGGER IF EXISTS forbid_modification_trigger ON decision_events;
DROP TRIGGER IF EXISTS enforce_single_open_decision_trigger ON decision_events;
DROP TRIGGER IF EXISTS enforce_causal_index_order_trigger ON decision_events;
DROP FUNCTION IF EXISTS enforce_event_transition();
DROP FUNCTION IF EXISTS forbid_modification();
DROP FUNCTION IF EXISTS enforce_single_open_decision();
DROP FUNCTION IF EXISTS enforce_causal_index_order();
DROP TABLE IF EXISTS decision_events;
