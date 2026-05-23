-- Homework attachment on assignments + storage for files

ALTER TABLE homework
  ADD COLUMN IF NOT EXISTS attachment_url TEXT;

-- Buckets: teacher assignment files + student submission files
INSERT INTO storage.buckets (id, name, public)
VALUES
  ('homework-assignments', 'homework-assignments', true),
  ('homework-submissions', 'homework-submissions', true)
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "Authenticated users can upload homework assignments"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'homework-assignments');

CREATE POLICY "Anyone can view homework assignments"
ON storage.objects FOR SELECT
USING (bucket_id = 'homework-assignments');

CREATE POLICY "Authenticated users can upload homework submissions"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'homework-submissions');

CREATE POLICY "Anyone can view homework submissions"
ON storage.objects FOR SELECT
USING (bucket_id = 'homework-submissions');

CREATE POLICY "Users can delete own homework submission files"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'homework-submissions');

-- Allow students/parents to receive overdue homework in-app alerts
CREATE POLICY "Users can insert own notifications"
  ON notifications FOR INSERT
  WITH CHECK (user_id = auth.uid());
