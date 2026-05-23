-- Allow self-registration for parent and student accounts

CREATE POLICY "Users can insert own profile"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can insert own parent record"
  ON parents FOR INSERT
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can insert own student record"
  ON students FOR INSERT
  WITH CHECK (auth.uid() = id);
