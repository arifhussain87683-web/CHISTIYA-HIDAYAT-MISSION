# CHISTIYA HIDAYAT MISSION — ব্যবহার নির্দেশিকা (v1.3)

## বর্তমান সুবিধা
- Supabase ইমেইল ও পাসওয়ার্ড লগইন
- Dashboard, নতুন ভর্তি, শিক্ষার্থী তালিকা, নাম/ভর্তি নম্বর অনুসন্ধান, শ্রেণি অনুযায়ী ফিল্টার এবং CSV export
- শিক্ষক, পরীক্ষা, নোটিশ, মজুত পণ্য ও ব্যয়ের প্রাথমিক এন্ট্রি
- দৈনিক উপস্থিতি
- প্রাথমিক ফি জমার রেকর্ড
- Android, tablet এবং computer-এর জন্য responsive layout

## গুরুত্বপূর্ণ সীমাবদ্ধতা
এটি প্রাথমিক সংস্করণ, সম্পূর্ণ School ERP নয়। Fee invoice, payment allocation, বকেয়া হিসাব, accounting auto-posting, marks entry, result/marksheet, salary, stock transaction, calendar, backup/restore, সম্পূর্ণ print এবং edit/delete workflow এখনো সম্পূর্ণ হয়নি। প্রতিটি workflow পরীক্ষা না করে দৈনন্দিন মূল রেকর্ডের একমাত্র ব্যবস্থা হিসেবে ব্যবহার করবেন না।

## Supabase সেটআপ
প্রজেক্টের মূল ফোল্ডারে `.env.local` তৈরি করে লিখুন:

```env
VITE_SUPABASE_URL=https://YOUR_PROJECT.supabase.co
VITE_SUPABASE_ANON_KEY=YOUR_PUBLISHABLE_OR_ANON_KEY
```

কখনো `service_role` বা secret key browser app-এ রাখবেন না এবং `.env.local` GitHub-এ upload করবেন না। এই ZIP-এ প্রকৃত key নেই।

## Windows computer-এ চালানো
1. ZIP Extract করুন।
2. Node.js LTS install করুন।
3. `chistiya_starter` ফোল্ডারে `.env.local` তৈরি করুন।
4. ওই ফোল্ডারে Terminal/CMD খুলে `npm install` চালান।
5. `npm run dev -- --host 0.0.0.0` চালিয়ে দেখানো URL Chrome-এ খুলুন।
6. Production build-এর জন্য `npm run build`; Netlify Build command `npm run build` এবং Publish directory `dist`।

## Mobile ও computer
একই web app Android Chrome এবং computer Chrome-এ ব্যবহার করা যাবে। ZIP-এ ট্যাপ করলেই app চালু হয় না; GitHub/Netlify-তে build ও host করতে হবে, অথবা Node.js-সহ computer-এ চালাতে হবে।

## তথ্যের নিরাপত্তা
এই package database reset বা drop করে না। বর্তমান Supabase project ও records অক্ষত রাখুন। ভবিষ্যতের কোনো SQL migration চালানোর আগে backup ও review করুন।

## Accounts Module (v1.0)
- Fee payments are posted to the Accounts ledger as income after invoice allocation succeeds.
- Expense vouchers are posted to the ledger as expenses.
- The Accounts screen shows income, expenses, net balance and a cashbook register.
- Before using this module, run `CHISTIYA_HIDAYAT_MISSION_Accounts_Migration_v1.0.sql` once in Supabase SQL Editor. This is an additive migration; it does not delete or reset existing data.
- Older fee and expense records are not backfilled automatically. The ledger starts receiving entries for new transactions after the migration.
- If a source record saves but its ledger posting fails, the app displays a warning. Reconcile the ledger before repeating the transaction.

## Version 1.1 — শিক্ষক বেতন
Salary মেনু থেকে সক্রিয় শিক্ষক নির্বাচন করে মাসিক বেতন, কাটা টাকা, বোনাস এবং পেমেন্টের তারিখ সংরক্ষণ করা যাবে। Net Salary স্বয়ংক্রিয়ভাবে হিসাব হবে, প্রিন্টযোগ্য Salary Voucher তৈরি হবে এবং Accounts-এর Teacher Salary expense হিসেবে এন্ট্রি হবে।

এই মডিউল Foundation-এর `teacher_salary_payments` টেবিল এবং v1.0 Accounts migration-এর `account_entries` টেবিল ব্যবহার করে। Salary থেকে Accounts-এ এন্ট্রির জন্য আগে v1.0 Accounts migration চালানো থাকতে হবে। v1.1-এর জন্য আলাদা SQL migration প্রয়োজন নেই।

এই সংস্করণে প্রতি শিক্ষক ও প্রতি মাসে একটি পূর্ণ বেতন পেমেন্ট করা যাবে। কিস্তি বা অগ্রিম বেতন সমন্বয় এখনো নেই। বেতনের রেকর্ড সংরক্ষিত হলেও Accounts এন্ট্রি ব্যর্থ হলে পুনরায় বেতন জমা দেওয়ার আগে হিসাব মিলিয়ে নিতে হবে।

## Version 1.2 - Attendance
এই সংস্করণে শ্রেণিভিত্তিক দৈনিক উপস্থিতি, Regular / Morning / Evening সেশন, আগের উপস্থিতি লোড করে সংশোধন, একসঙ্গে সবাইকে Present বা Absent করা, এবং সংরক্ষণ সুবিধা যোগ করা হয়েছে। মাসিক শ্রেণিভিত্তিক রিপোর্টে Present, Absent, Holiday, Working Days ও Attendance Percentage দেখা যাবে। রিপোর্ট CSV হিসেবে ডাউনলোড ও প্রিন্ট করা যাবে। মাসিক রিপোর্ট বর্তমানে Regular সেশন ব্যবহার করে। এই মডিউলের জন্য নতুন SQL migration প্রয়োজন নেই।

## Version 1.3 — Examination & Result Management
- প্রতিটি শ্রেণির জন্য Subject, Full Marks এবং Pass Marks যোগ করা যাবে।
- First Unit Test, Half Yearly Examination এবং Annual Examination তৈরি করা যাবে।
- শ্রেণিভিত্তিক শিক্ষার্থীদের নম্বর প্রবেশ ও আগের নম্বর লোড করে সংশোধন করা যাবে।
- নির্বাচিত পরীক্ষার Class Result প্রিন্ট ও CSV ডাউনলোড করা যাবে।
- Combined Annual Result তিনটি পরীক্ষার নম্বর যোগ করে মোট নম্বর, শতকরা হার এবং Merit Rank তৈরি করবে।
- সমান শতকরা নম্বরে Joint Rank হবে; অসম্পূর্ণ নম্বর থাকলে শিক্ষার্থীকে Incomplete দেখানো হবে এবং Rank দেওয়া হবে না।
- First Unit Test ও Half Yearly-এর জন্য শুধু Class Result রয়েছে; Individual Marksheet এই সংস্করণে নেই।
- এই মডিউল বিদ্যমান `subjects`, `exams`, `student_enrollments` ও `exam_marks` টেবিল ব্যবহার করে। নতুন SQL migration প্রয়োজন নেই।
- পরীক্ষার Start Date ও End Date-ও সংরক্ষণ করা যাবে।
- Annual Examination-এর ফলাফল তৈরি করতে Combined Annual Result নির্বাচন করতে হবে; এটি তিনটি পরীক্ষার ফল একত্র করে।


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
এই সংস্করণে শিক্ষার্থীর প্রোফাইল এবং পৃথক ID Card প্রিন্ট করার সুবিধা যোগ করা হয়েছে। বিদ্যমান `students.photo_path` এবং `student-photos` Storage bucket ব্যবহার করা হয়; নতুন SQL Migration প্রয়োজন নেই। একবারে একজন শিক্ষার্থীর ID Card প্রিন্ট হবে। স্কুলের লোগো/ঠিকানা/স্বাক্ষর এবং A4-এ একাধিক কার্ড প্রিন্টের সুবিধা এখনো নেই। প্রিন্টের জন্য Browser Pop-up অনুমতি দিন। Live Supabase ও Production Build পরীক্ষা এখনো বাকি।


## Version 1.6 — School Settings
স্কুলের নাম, ঠিকানা, ফোন, প্রধান শিক্ষক/প্রিন্সিপালের নাম, ডিফল্ট ভাষা এবং Logo/Signature/Stamp URL বা Path সংরক্ষণের ব্যবস্থা যোগ হয়েছে। বিদ্যমান `school_settings` টেবিল ব্যবহৃত হয়েছে; নতুন SQL Migration প্রয়োজন নেই। সরাসরি ছবি আপলোড এবং সব প্রিন্ট টেমপ্লেটে স্বয়ংক্রিয় সংযোগ এখনো অন্তর্ভুক্ত নয়।


## Version 1.7 — Backup Management
Backup মেনু থেকে স্কুলের অ্যাপ্লিকেশন ডেটা JSON ফাইল হিসেবে ডাউনলোড করা যাবে। প্রতিটি টেবিলের Export Status এবং Row Count ফাইলে থাকবে। ডেটা 500টি রেকর্ডের পেজে পড়া হয়। এই প্রক্রিয়ায় Supabase-এর কোনো তথ্য পরিবর্তন বা মুছে ফেলা হয় না এবং নতুন SQL Migration প্রয়োজন নেই। ভুলবশত ডেটা নষ্ট হওয়া ঠেকাতে এই সংস্করণে Restore/Import চালু করা হয়নি। Login User/Password, Database Schema, Storage Files এবং Private Key ব্যাকআপে অন্তর্ভুক্ত নয়। ফাইলে শিক্ষার্থীর ব্যক্তিগত ও আর্থিক তথ্য থাকতে পারে, তাই নিরাপদে রাখুন। যে টেবিল Export করা যাবে না, তার Status ফাইলে উল্লেখ থাকবে। Build এবং Live Supabase পরীক্ষা এখনো বাকি।

## v1.8 কার্যক্রম লগ
Activity Log মেনু থেকে বিদ্যমান `audit_logs` টেবিলের সর্বশেষ ৩০০টি রেকর্ড দেখা যাবে। সফল লগইন, সাধারণ মডিউলে নতুন রেকর্ড, ফি ইনভয়েস, ফি পেমেন্ট, উপস্থিতি আপডেট এবং পরীক্ষার নম্বর সংরক্ষণের কার্যক্রম লগ করার চেষ্টা করা হয়। নতুন SQL Migration প্রয়োজন নেই। লগ সংরক্ষণে সমস্যা হলেও মূল কাজ বন্ধ হবে না। Supabase RLS নীতি অনুযায়ী লগ দেখা যাবে। এটি সম্পূর্ণ Database Audit Trail নয়; প্রতিটি View, Print, Edit বা Delete কার্যক্রম এখানে রেকর্ড হয় না।

## ব্যবহারকারী ও ভূমিকা ব্যবস্থাপনা (v1.9)
- বিদ্যমান Supabase Auth user-এর profile যোগ করে Admin বা Teacher role দেওয়া যাবে।
- Profile Active/Inactive করা যাবে; অন্তত একজন Active Admin রাখা বাধ্যতামূলক।
- এই screen login account বা password তৈরি করে না; Supabase Authentication-এ আগে account তৈরি করুন।
- Teacher-এর menu সীমিত, তবে এটি database security নয়। Teacher চালুর আগে Supabase RLS policy পরীক্ষা করুন।
- v1.9-এর production build এবং live Supabase test এখনো সম্পন্ন হয়নি।


## Version 2.0
See RELEASE_NOTES_2.0.txt and RELEASE_NOTES_2.0_BN.txt for dashboard integration details.
