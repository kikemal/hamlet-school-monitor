-- Hamlet School Monitor: RLS Policies

-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE schools ENABLE ROW LEVEL SECURITY;
ALTER TABLE teachers ENABLE ROW LEVEL SECURITY;
ALTER TABLE parents ENABLE ROW LEVEL SECURITY;
ALTER TABLE classes ENABLE ROW LEVEL SECURITY;
ALTER TABLE students ENABLE ROW LEVEL SECURITY;
ALTER TABLE subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE timetables ENABLE ROW LEVEL SECURITY;
ALTER TABLE attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE results ENABLE ROW LEVEL SECURITY;
ALTER TABLE homework ENABLE ROW LEVEL SECURITY;
ALTER TABLE homework_submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE announcements ENABLE ROW LEVEL SECURITY;
ALTER TABLE behaviour_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE fees ENABLE ROW LEVEL SECURITY;
ALTER TABLE fee_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE school_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE student_health_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;

-- Helper: current user's role from profiles (must live in public — auth schema is locked on Supabase)
CREATE OR REPLACE FUNCTION public.app_user_role()
RETURNS text
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT role::text FROM public.profiles WHERE id = auth.uid() LIMIT 1;
$$;

GRANT EXECUTE ON FUNCTION public.app_user_role() TO authenticated;
GRANT EXECUTE ON FUNCTION public.app_user_role() TO anon;

-- 1. PROFILES
-- Users can read their own profile. Admins can read all.
CREATE POLICY "Users can view own profile" ON profiles FOR SELECT USING (auth.uid() = id OR public.app_user_role() = 'admin');
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Admins can manage profiles" ON profiles FOR ALL USING (public.app_user_role() = 'admin');

-- 2. SCHOOLS
-- Everyone can view schools. Only admins can manage.
CREATE POLICY "Anyone can view schools" ON schools FOR SELECT USING (true);
CREATE POLICY "Admins can manage schools" ON schools FOR ALL USING (public.app_user_role() = 'admin');

-- 3. TEACHERS & 4. PARENTS
CREATE POLICY "Anyone can view teachers" ON teachers FOR SELECT USING (true);
CREATE POLICY "Admins can manage teachers" ON teachers FOR ALL USING (public.app_user_role() = 'admin');

CREATE POLICY "Users can view own parent record" ON parents FOR SELECT USING (auth.uid() = id OR public.app_user_role() = 'admin' OR public.app_user_role() = 'teacher');
CREATE POLICY "Admins can manage parents" ON parents FOR ALL USING (public.app_user_role() = 'admin');

-- 5. CLASSES & 6. STUDENTS & 7. SUBJECTS
CREATE POLICY "Anyone can view classes" ON classes FOR SELECT USING (true);
CREATE POLICY "Admins can manage classes" ON classes FOR ALL USING (public.app_user_role() = 'admin');

CREATE POLICY "Teachers and Admins can view all students" ON students FOR SELECT USING (public.app_user_role() IN ('admin', 'teacher'));
CREATE POLICY "Parents can view their own children" ON students FOR SELECT USING (parent_id = auth.uid());
CREATE POLICY "Students can view themselves" ON students FOR SELECT USING (id = auth.uid());
CREATE POLICY "Admins can manage students" ON students FOR ALL USING (public.app_user_role() = 'admin');

CREATE POLICY "Anyone can view subjects" ON subjects FOR SELECT USING (true);
CREATE POLICY "Admins can manage subjects" ON subjects FOR ALL USING (public.app_user_role() = 'admin');

-- 8. TIMETABLES
CREATE POLICY "Anyone can view timetables" ON timetables FOR SELECT USING (true);
CREATE POLICY "Admins can manage timetables" ON timetables FOR ALL USING (public.app_user_role() = 'admin');

-- 9. ATTENDANCE & 10. RESULTS
CREATE POLICY "Teachers and Admins can view all attendance" ON attendance FOR SELECT USING (public.app_user_role() IN ('admin', 'teacher'));
CREATE POLICY "Parents can view child attendance" ON attendance FOR SELECT USING (EXISTS (SELECT 1 FROM students WHERE students.id = attendance.student_id AND students.parent_id = auth.uid()));
CREATE POLICY "Students can view own attendance" ON attendance FOR SELECT USING (student_id = auth.uid());
CREATE POLICY "Teachers and Admins can manage attendance" ON attendance FOR ALL USING (public.app_user_role() IN ('admin', 'teacher'));

CREATE POLICY "Teachers and Admins can view all results" ON results FOR SELECT USING (public.app_user_role() IN ('admin', 'teacher'));
CREATE POLICY "Parents can view child results" ON results FOR SELECT USING (EXISTS (SELECT 1 FROM students WHERE students.id = results.student_id AND students.parent_id = auth.uid()));
CREATE POLICY "Students can view own results" ON results FOR SELECT USING (student_id = auth.uid());
CREATE POLICY "Teachers and Admins can manage results" ON results FOR ALL USING (public.app_user_role() IN ('admin', 'teacher'));

-- 11. HOMEWORK & 12. HOMEWORK SUBMISSIONS
CREATE POLICY "Anyone can view homework" ON homework FOR SELECT USING (true);
CREATE POLICY "Teachers and Admins can manage homework" ON homework FOR ALL USING (public.app_user_role() IN ('admin', 'teacher'));

CREATE POLICY "Teachers and Admins can view all submissions" ON homework_submissions FOR SELECT USING (public.app_user_role() IN ('admin', 'teacher'));
CREATE POLICY "Students can view own submissions" ON homework_submissions FOR SELECT USING (student_id = auth.uid());
CREATE POLICY "Students can create own submissions" ON homework_submissions FOR INSERT WITH CHECK (student_id = auth.uid());
CREATE POLICY "Students can update own submissions" ON homework_submissions FOR UPDATE USING (student_id = auth.uid());
CREATE POLICY "Teachers and Admins can manage submissions" ON homework_submissions FOR ALL USING (public.app_user_role() IN ('admin', 'teacher'));

-- 13. CONVERSATIONS & 14. MESSAGES
CREATE POLICY "Participants can view conversations" ON conversations FOR SELECT USING (participant1_id = auth.uid() OR participant2_id = auth.uid());
CREATE POLICY "Participants can create conversations" ON conversations FOR INSERT WITH CHECK (participant1_id = auth.uid() OR participant2_id = auth.uid());

CREATE POLICY "Participants can view messages" ON messages FOR SELECT USING (EXISTS (SELECT 1 FROM conversations WHERE conversations.id = messages.conversation_id AND (participant1_id = auth.uid() OR participant2_id = auth.uid())));
CREATE POLICY "Sender can insert messages" ON messages FOR INSERT WITH CHECK (sender_id = auth.uid());

-- 15. NOTIFICATIONS
CREATE POLICY "Users can view own notifications" ON notifications FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Users can update own notifications" ON notifications FOR UPDATE USING (user_id = auth.uid());
CREATE POLICY "Admins can manage notifications" ON notifications FOR ALL USING (public.app_user_role() = 'admin');

-- 16. ANNOUNCEMENTS & 20. SCHOOL EVENTS
CREATE POLICY "Anyone can view announcements" ON announcements FOR SELECT USING (true);
CREATE POLICY "Admins and Teachers can manage announcements" ON announcements FOR ALL USING (public.app_user_role() IN ('admin', 'teacher'));

CREATE POLICY "Anyone can view school events" ON school_events FOR SELECT USING (true);
CREATE POLICY "Admins can manage school events" ON school_events FOR ALL USING (public.app_user_role() = 'admin');

-- 17. BEHAVIOUR LOGS
CREATE POLICY "Teachers and Admins can view behaviour logs" ON behaviour_logs FOR SELECT USING (public.app_user_role() IN ('admin', 'teacher'));
CREATE POLICY "Parents can view child behaviour logs" ON behaviour_logs FOR SELECT USING (EXISTS (SELECT 1 FROM students WHERE students.id = behaviour_logs.student_id AND students.parent_id = auth.uid()));
CREATE POLICY "Teachers and Admins can manage behaviour logs" ON behaviour_logs FOR ALL USING (public.app_user_role() IN ('admin', 'teacher'));

-- 18. FEES & 19. FEE PAYMENTS
CREATE POLICY "Admins can view fees" ON fees FOR SELECT USING (public.app_user_role() = 'admin');
CREATE POLICY "Parents can view relevant fees" ON fees FOR SELECT USING (public.app_user_role() = 'parent'); -- Simplified for RLS, ideally filter by student_id
CREATE POLICY "Admins can manage fees" ON fees FOR ALL USING (public.app_user_role() = 'admin');

CREATE POLICY "Admins can view all payments" ON fee_payments FOR SELECT USING (public.app_user_role() = 'admin');
CREATE POLICY "Parents can view own payments" ON fee_payments FOR SELECT USING (parent_id = auth.uid());
CREATE POLICY "Parents can insert own payments" ON fee_payments FOR INSERT WITH CHECK (parent_id = auth.uid());
CREATE POLICY "Admins can manage payments" ON fee_payments FOR ALL USING (public.app_user_role() = 'admin');

-- 21. STUDENT HEALTH RECORDS
CREATE POLICY "Admins and Teachers can view health records" ON student_health_records FOR SELECT USING (public.app_user_role() IN ('admin', 'teacher'));
CREATE POLICY "Parents can view child health records" ON student_health_records FOR SELECT USING (EXISTS (SELECT 1 FROM students WHERE students.id = student_health_records.student_id AND students.parent_id = auth.uid()));
CREATE POLICY "Admins can manage health records" ON student_health_records FOR ALL USING (public.app_user_role() = 'admin');

-- 22. DOCUMENTS
CREATE POLICY "Anyone can view documents" ON documents FOR SELECT USING (true);
CREATE POLICY "Admins and Teachers can manage documents" ON documents FOR ALL USING (public.app_user_role() IN ('admin', 'teacher'));
