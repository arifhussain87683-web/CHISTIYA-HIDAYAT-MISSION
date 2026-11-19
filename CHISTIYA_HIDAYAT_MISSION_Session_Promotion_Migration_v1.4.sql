-- CHISTIYA HIDAYAT MISSION
-- Academic Session & Student Promotion Migration v1.4
-- ADDITIVE ONLY: creates/replaces two guarded RPC functions.
-- Does not drop tables, columns, policies, records, or existing functions.

create or replace function public.promote_students_to_session(
  p_from_session_id uuid,
  p_to_session_id uuid,
  p_students jsonb
)
returns table(promoted_count integer)
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_count integer;
  v_requested integer;
begin
  if not public.is_active_admin() then
    raise exception 'Administrator access required.';
  end if;
  if p_from_session_id is null or p_to_session_id is null or p_from_session_id = p_to_session_id then
    raise exception 'Choose two different academic sessions.';
  end if;
  if jsonb_typeof(p_students) <> 'array' or jsonb_array_length(p_students) = 0 then
    raise exception 'Select at least one student.';
  end if;

  perform pg_advisory_xact_lock(hashtext(p_to_session_id::text));

  if not exists (select 1 from public.academic_sessions where id = p_from_session_id) then
    raise exception 'Source academic session was not found.';
  end if;
  if not exists (select 1 from public.academic_sessions where id = p_to_session_id) then
    raise exception 'Destination academic session was not found.';
  end if;

  select count(*) into v_requested from jsonb_to_recordset(p_students) as x(student_id uuid, class_id uuid);
  if v_requested <> jsonb_array_length(p_students) then
    raise exception 'Invalid promotion list.';
  end if;
  if exists (
    select 1 from (
      select student_id, count(*) n
      from jsonb_to_recordset(p_students) as x(student_id uuid, class_id uuid)
      group by student_id having count(*) > 1
    ) d
  ) then
    raise exception 'A student appears more than once in the promotion list.';
  end if;
  if exists (
    select 1
    from jsonb_to_recordset(p_students) as x(student_id uuid, class_id uuid)
    left join public.student_enrollments se
      on se.student_id = x.student_id
     and se.session_id = p_from_session_id
     and se.enrollment_status = 'active'
    left join public.school_classes sc on sc.id = x.class_id and sc.is_active = true
    where se.id is null or sc.id is null
       or exists (select 1 from public.student_enrollments oldn where oldn.student_id=x.student_id and oldn.session_id=p_to_session_id)
  ) then
    raise exception 'One or more students are not eligible, destination class is inactive, or destination enrollment already exists.';
  end if;

  with requested as (
    select x.student_id, x.class_id
    from jsonb_to_recordset(p_students) as x(student_id uuid, class_id uuid)
  ), bases as (
    select r.class_id, coalesce(max(e.roll_number),0) as max_roll
    from requested r
    left join public.student_enrollments e
      on e.session_id = p_to_session_id and e.class_id = r.class_id
    group by r.class_id
  ), numbered as (
    select r.student_id, r.class_id,
           b.max_roll + row_number() over(partition by r.class_id order by r.student_id)::integer as new_roll
    from requested r join bases b on b.class_id = r.class_id
  )
  insert into public.student_enrollments(student_id, session_id, class_id, roll_number, enrollment_status)
  select student_id, p_to_session_id, class_id, new_roll, 'active' from numbered;

  update public.student_enrollments se
     set enrollment_status = 'promoted'
   where se.session_id = p_from_session_id
     and se.enrollment_status = 'active'
     and se.student_id in (select x.student_id from jsonb_to_recordset(p_students) as x(student_id uuid, class_id uuid));

  get diagnostics v_count = row_count;
  return query select v_count;
end;
$$;

revoke all on function public.promote_students_to_session(uuid, uuid, jsonb) from public;
grant execute on function public.promote_students_to_session(uuid, uuid, jsonb) to authenticated;

create or replace function public.set_current_academic_session(p_session_id uuid)
returns void
language plpgsql
security invoker
set search_path = public
as $$
begin
  if not public.is_active_admin() then
    raise exception 'Administrator access required.';
  end if;
  if not exists (select 1 from public.academic_sessions where id = p_session_id) then
    raise exception 'Academic session was not found.';
  end if;

  update public.academic_sessions
     set is_current = false,
         is_archived = case when id <> p_session_id and is_current then true else is_archived end
   where is_current = true;

  update public.academic_sessions
     set is_current = true, is_archived = false
   where id = p_session_id;

  update public.school_settings
     set current_session_id = p_session_id, updated_at = now();
end;
$$;

revoke all on function public.set_current_academic_session(uuid) from public;
grant execute on function public.set_current_academic_session(uuid) to authenticated;
