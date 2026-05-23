-- Allow teachers to push in-app notifications when posting class announcements.
CREATE POLICY "Teachers can insert notifications"
  ON notifications FOR INSERT
  WITH CHECK (public.app_user_role() IN ('admin', 'teacher'));
