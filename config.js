// ---------------------------------------------------------------
//  Website <-> Supabase connection
//  Leave both values empty to run the website as a plain static
//  page (no admin, no database). Fill them in after you follow
//  SETUP-GUIDE.md. These two values are SAFE to be public:
//  the database rules (setup.sql) decide who can change data.
// ---------------------------------------------------------------
window.CMS_CONFIG = {
  url: "https://bprruapnoczfbyjbmqok.supabase.co",      // e.g. "https://abcdxyz.supabase.co"
  anonKey: "sb_publishable_e9o7zDBTx1I8YOdnXmebKA__h3TEIKy"   // the "anon" / "publishable" key from Supabase > Project Settings > API
};
