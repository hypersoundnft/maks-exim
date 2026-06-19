-- Run this in Supabase SQL Editor (https://bqkjhwrdkizdloiowioe.supabase.co)
-- Go to SQL Editor → New Query → paste and run

-- 1. Create the deal_state table
CREATE TABLE IF NOT EXISTS deal_state (
  id TEXT PRIMARY KEY DEFAULT 'demo-deal-1',
  current_step_id INTEGER NOT NULL DEFAULT 1,
  completed_steps INTEGER[] NOT NULL DEFAULT '{}',
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Insert the initial row (safe to re-run)
INSERT INTO deal_state (id, current_step_id, completed_steps)
VALUES ('demo-deal-1', 1, '{}')
ON CONFLICT (id) DO NOTHING;

-- 3. Enable real-time (safe to re-run - will just warn if already added)
DO $$ BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE deal_state;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- 4. Required for UPDATE events to include full row data in real-time
ALTER TABLE deal_state REPLICA IDENTITY FULL;

-- 5. Enable RLS
ALTER TABLE deal_state ENABLE ROW LEVEL SECURITY;

-- 6. Permissive policy (anon key can read/write)
DROP POLICY IF EXISTS "Allow all access to deal_state" ON deal_state;
CREATE POLICY "Allow all access to deal_state"
  ON deal_state
  FOR ALL
  USING (true)
  WITH CHECK (true);
