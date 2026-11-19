# CHISTIYA HIDAYAT MISSION — User and Setup Guide (v0.8)

## Current features
- Supabase email/password login with database access controlled by existing RLS policies
- Dashboard, student admission through the existing `create_student_admission` RPC, student list, search, class filter and CSV export
- Basic teacher, exam, notice, stock-item and expense entry screens
- Daily attendance entry
- Fee invoice creation by student, category and billing month
- Partial payment against a selected invoice, invoice allocation and outstanding balance register
- Payment register with printable receipt
- Responsive layout for Android, tablets and desktop browsers

## Important status
This is an early working foundation, not a completed school ERP. Important fee limitations: payments currently allocate to one selected invoice at a time. Automatic monthly invoice generation, multiple-invoice allocation in one payment, concessions/discount approval, accounting auto-posting and a transactional payment RPC are not included yet. If an allocation error appears after a payment is saved, do not retry the payment blindly; ask the administrator to reconcile the payment and invoice first. Marks entry, results and marksheets, salary workflows, stock transactions, calendar, backup/restore and complete edit/delete workflows are also pending. Do not use it as the sole system for live school records until each workflow has been tested.

## Supabase configuration
Create `.env.local` in the project root with only these values:

```env
VITE_SUPABASE_URL=https://YOUR_PROJECT.supabase.co
VITE_SUPABASE_ANON_KEY=YOUR_PUBLISHABLE_OR_ANON_KEY
```

Never put a `service_role` or secret key in the browser app. Do not upload `.env.local` to GitHub. The ZIP does not contain your actual key.

## Run on Windows
1. Extract the ZIP.
2. Install Node.js LTS.
3. Create `.env.local` in `chistiya_starter`.
4. Open Terminal or CMD in that folder and run `npm install`.
5. Run `npm run dev -- --host 0.0.0.0` and open the displayed local URL in Chrome.
6. For a production build, run `npm run build`. On Netlify use build command `npm run build` and publish directory `dist`.

## Android and desktop use
The same responsive web app can be opened in Chrome on Android and on a computer. The ZIP itself does not run by tapping it; it must first be built and hosted through GitHub/Netlify or run on a computer with Node.js.

## Data safety
This package does not reset or drop the database. Keep the existing Supabase project and records. Review and back up data before running any future database migration.

## Accounts Module (v1.0)
- Fee payments are posted to the Accounts ledger as income after invoice allocation succeeds.
- Expense vouchers are posted to the ledger as expenses.
- The Accounts screen shows income, expenses, net balance and a cashbook register.
- Before using this module, run `CHISTIYA_HIDAYAT_MISSION_Accounts_Migration_v1.0.sql` once in Supabase SQL Editor. This is an additive migration; it does not delete or reset existing data.
- Older fee and expense records are not backfilled automatically. The ledger starts receiving entries for new transactions after the migration.
- If a source record saves but its ledger posting fails, the app displays a warning. Reconcile the ledger before repeating the transaction.

## Version 1.1 — Teacher Salary
The Salary menu records one monthly salary payment per active teacher. It calculates net salary from basic salary minus deduction plus bonus, prints a salary voucher, and posts the payment as a Teacher Salary expense in `account_entries`.

The v1.1 salary module uses the existing `teacher_salary_payments` table from the foundation schema and the `account_entries` table created by the v1.0 Accounts migration. Apply the v1.0 Accounts migration before using salary-to-accounts posting. No additional SQL migration is required for v1.1.

Only one full monthly payment per teacher/month is supported in this version. Installments and advance recovery are not yet supported. If the salary record saves but its Accounts entry fails, reconcile the ledger before retrying; do not submit the same salary again.

## Version 1.2 - Attendance
The attendance module supports class-wise daily marking in Regular, Morning, and Evening slots. It loads any existing marks for the selected date and slot before editing, supports Mark All Present / Mark All Absent, and saves to the existing `student_attendance` table. The monthly class report currently summarizes the Regular slot and provides CSV download and browser printing. Attendance percentage is Present divided by Present plus Absent; holidays are excluded. No database migration is needed for v1.2.

## Version 1.3 - Examination & Result Management
- Configure class subjects with full marks and pass marks.
- Create First Unit Test, Half Yearly Examination and Annual Examination for each class.
- Enter marks class-wise and load existing marks before editing.
- Generate, print and export class results for a selected examination.
- Combined Annual Result aggregates marks from all three examinations and calculates percentage and merit rank.
- Equal percentages receive joint ranks. Students with missing marks are marked Incomplete and are not ranked.
- First Unit Test and Half Yearly provide class-wise results only; individual marksheets are not included in this version.
- Uses existing `subjects`, `exams`, `student_enrollments` and `exam_marks` tables. No new SQL migration is required.
- Examination start and end dates can be saved. To generate the Annual Examination result, select Combined Annual Result; this combines all three examinations.


## Version 1.4 — Academic Session & Student Promotion
- Create new academic sessions without changing the existing current session.
- View session dates and current / inactive / archived status.
- Load active students from a source session, select individual students, and choose a destination class for each student.
- Suggested class is the next active class according to `sort_order`; review it before promotion.
- A guarded database function creates new session enrollments and assigns roll numbers automatically within each destination class.
- Permanent student IDs and admission numbers remain unchanged. Old enrollments and previous-session records are retained. Students not selected are not moved.
- A second guarded function activates the selected session and archives the previous current session without deleting it.
- Run `CHISTIYA_HIDAYAT_MISSION_Session_Promotion_Migration_v1.4.sql` once in the correct CHISTIYA HIDAYAT MISSION Supabase project before using this module. This additive migration creates/replaces two RPC functions; it does not drop tables or records.
- The migration depends on the existing foundation schema and `is_active_admin()` function. Back up first, then test with a small group. Live Supabase testing and a complete production build are still pending.


## Version 1.5 - Student Profile & ID Card
This release adds a student profile view and an individual printable ID card. It uses the existing `students.photo_path` field and the `student-photos` Storage bucket; no SQL migration is included. The ID card prints one student per action. School logo/address/signature and A4 multi-card printing are not included yet. Allow browser pop-ups when printing. Live Supabase and production build testing remain to be completed.


## Version 1.6 — School Settings
The admin School Settings screen edits the existing `school_settings` row: school name, address, phone, headmaster/principal, default language, and logo/signature/stamp URL or path fields. No migration is required. Image upload and universal print-template integration are not included yet.


## Version 1.7 — Backup Management
The Backup screen downloads application data as a JSON file and records the export status and row count for each table. It reads records in pages of 500 and does not modify or delete database data. No SQL migration is required. Restore/import is intentionally not enabled. Login users/passwords, database schema, Storage files and private keys are not included. Keep downloaded backups private because they may contain student contact and financial data. Tables unavailable to the current account are marked as not exported. Build and live Supabase testing remain pending.

## v1.8 Activity Log
The Activity Log menu reads the latest 300 records from the existing `audit_logs` table. The app attempts to record successful login, new records in generic modules, fee invoice creation, fee payment, attendance updates, and examination mark updates. No new SQL migration is required. Activity logging is best-effort: a logging failure does not interrupt the primary operation. Access remains controlled by the existing Supabase RLS policy. This log is not a complete database audit trail and does not record every read, print, edit, or delete action.

## User & Role Management (v1.9)
- Admin can add a profile for an existing Supabase Auth user and assign Admin or Teacher.
- Existing profiles can be activated/deactivated. At least one active administrator is protected.
- Auth users and passwords are not created by this screen; create accounts in Supabase Authentication first.
- Teacher navigation is limited in the app, but this is not database security. Review Supabase RLS policies before enabling teacher access.
- v1.9 has not completed a production build or live Supabase test.


## Version 2.0
See RELEASE_NOTES_2.0.txt and RELEASE_NOTES_2.0_BN.txt for dashboard integration details.
