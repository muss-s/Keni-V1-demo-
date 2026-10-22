// Keni · push (added 2026-10-21). Sends web push notifications to tropa members.
// GET ?action=key            → the public VAPID key (made here on first use; the private key never leaves the database)
// POST + x-push-token header → sends everything waiting in public.push_queue (the database calls this; see push_enqueue)
import webpush from "npm:web-push@3.6.7";
import { createClient } from "jsr:@supabase/supabase-js@2";

const sb = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);
const CORS = { "Access-Control-Allow-Origin": "*", "Access-Control-Allow-Headers": "content-type, apikey, authorization, x-client-info" };
const json = (b: unknown, status = 200) => new Response(JSON.stringify(b), { status, headers: { ...CORS, "content-type": "application/json" } });

type Cfg = { token: string; vapid_public: string | null; vapid_private: string | null };
async function cfg(): Promise<Cfg> {
  const { data, error } = await sb.rpc("push_cfg"); if (error) throw error;
  let c = (Array.isArray(data) ? data[0] : data) as Cfg;
  if (!c.vapid_public) { // first use: make the keys and keep them in the database
    const k = webpush.generateVAPIDKeys();
    await sb.rpc("push_cfg_set_vapid", { p_pub: k.publicKey, p_priv: k.privateKey });
    const again = await sb.rpc("push_cfg"); c = (Array.isArray(again.data) ? again.data[0] : again.data) as Cfg; // another call may have won the race
  }
  return c;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });
  try {
    const c = await cfg();
    if (new URL(req.url).searchParams.get("action") === "key") return json({ key: c.vapid_public });
    if (req.headers.get("x-push-token") !== c.token) return json({ error: "no" }, 401);
    webpush.setVapidDetails("https://keni-real.vercel.app", c.vapid_public!, c.vapid_private!);
    let sent = 0, dropped = 0, failed = 0;
    for (let round = 0; round < 5; round++) {
      const { data, error } = await sb.rpc("push_take", { p_limit: 100 }); if (error) throw error;
      const rows = (data || []) as { endpoint: string; p256dh: string; auth: string; title: string; body: string; url: string; tag: string | null }[];
      if (!rows.length) break;
      await Promise.all(rows.map(async (r) => {
        try {
          await webpush.sendNotification({ endpoint: r.endpoint, keys: { p256dh: r.p256dh, auth: r.auth } },
            JSON.stringify({ title: r.title, body: r.body, url: r.url || "/", tag: r.tag || undefined }), { TTL: 12 * 3600, urgency: "high" });
          sent++;
        } catch (e) {
          const code = (e as { statusCode?: number }).statusCode;
          if (code === 404 || code === 410) { await sb.rpc("push_drop", { p_endpoint: r.endpoint }); dropped++; } else failed++; // that phone turned notifications off
        }
      }));
    }
    return json({ sent, dropped, failed });
  } catch (e) {
    return json({ error: String((e as Error).message || e) }, 500);
  }
});
