-- Behaviour severity column + realtime publication

CREATE TYPE behaviour_severity AS ENUM ('minor', 'moderate', 'serious');

ALTER TABLE behaviour_logs
  ADD COLUMN IF NOT EXISTS severity behaviour_severity NOT NULL DEFAULT 'moderate';

-- Backfill from legacy encoded descriptions [low|medium|high]
UPDATE behaviour_logs
SET severity = CASE
  WHEN description ~* '^\[low\]' THEN 'minor'::behaviour_severity
  WHEN description ~* '^\[high\]' THEN 'serious'::behaviour_severity
  WHEN description ~* '^\[medium\]' THEN 'moderate'::behaviour_severity
  WHEN description ~* '^\[minor\]' THEN 'minor'::behaviour_severity
  WHEN description ~* '^\[serious\]' THEN 'serious'::behaviour_severity
  ELSE 'moderate'::behaviour_severity
END
WHERE description ~* '^\[(low|high|medium|minor|serious|moderate)\]';

-- Enable realtime for parent behaviour alerts (skip if already added)
DO $$
BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE behaviour_logs;
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;
