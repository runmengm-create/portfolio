const crypto = require("crypto");

const MAX_MESSAGE_CHARS = 1200;
const MAX_HISTORY_MESSAGES = 12;
const MAX_REPLIES_PER_VISITOR = 8;
const MAX_REQUESTS_PER_MINUTE = 5;
const visitorUsage = new Map();

const SYSTEM_PROMPT = `你是马润萌（Renee Ma）作品集里的对话助手。请以马润萌本人第一人称自然回答，不要自称数字分身或 AI。语气聪明、亲切、有一点俏皮，但回答要清楚、有产品判断力。

公开事实：马润萌是 2027 届硕士，机械工程（工业设计工程方向），本科是工业设计；目标岗位是智能硬件产品经理或智能座舱产品经理。她擅长从真实用户场景中定义产品定位、系统规则和软硬件边界，并推动方案落地与验证。她做过智能喂食器称重与余粮体系、智能宠物项圈预立项、A 柱补盲/360° 全景影像、车载旅行规划 Agent 等项目。她相信 AI 不应只停留在软件聊天和写代码，而要真正进入物理世界，与硬件产品结合。公开邮箱是 runmengM@outlook.com。

边界：不编造公司、项目结果、上线状态、数据指标或个人经历；不确定就说“这部分我没有公开展开”。不回答感情经历、私人冲突、私人聊天记录等问题，应礼貌说明这是私领域，并引导访客通过公开邮箱联系。不代表马润萌接受 offer、报价或承诺合作，也不回答她本人的薪资预期。若访客明确表达招聘或合作意向，可以自然询问公司、业务方向、城市和对方期待；薪资/预算只可邀请对方自愿提供。每次最多问一个必要的追问，控制在 400 个汉字以内。访客使用英文时用英文回答，否则用中文。`;

function getVisitorKey(req) {
  const forwarded = req.headers["x-forwarded-for"];
  const ip = String(forwarded || req.socket?.remoteAddress || "unknown").split(",")[0].trim();
  const userAgent = String(req.headers["user-agent"] || "unknown").slice(0, 80);
  return crypto.createHmac("sha256", process.env.VISITOR_HASH_SECRET || process.env.DEEPSEEK_API_KEY).update(`${ip}:${userAgent}`).digest("hex");
}

module.exports = async function handler(req, res) {
  if (req.method !== "POST") return res.status(405).json({ error: "Method not allowed" });
  if (!process.env.DEEPSEEK_API_KEY) return res.status(503).json({ error: "网站还没有配置 DeepSeek API Key" });

  const now = Date.now();
  const key = getVisitorKey(req);
  const usage = visitorUsage.get(key) || { count: 0, startedAt: now, minuteStartedAt: now, minuteRequests: 0 };
  if (now - usage.startedAt > 24 * 60 * 60 * 1000) { usage.count = 0; usage.startedAt = now; }
  if (now - usage.minuteStartedAt > 60 * 1000) { usage.minuteRequests = 0; usage.minuteStartedAt = now; }
  if (usage.count >= MAX_REPLIES_PER_VISITOR) return res.status(429).json({ error: "本次对话次数已用完，可以通过邮箱继续联系我。" });
  if (usage.minuteRequests >= MAX_REQUESTS_PER_MINUTE) return res.status(429).json({ error: "消息太快啦，请稍等一分钟再继续。" });

  let body;
  try { body = typeof req.body === "string" ? JSON.parse(req.body) : (req.body || {}); }
  catch { return res.status(400).json({ error: "请求格式不正确" }); }

  const incoming = Array.isArray(body.messages)
    ? body.messages
    : (typeof body.message === "string" ? [{ role: "user", content: body.message }] : []);
  const messages = incoming
    .filter((item) => item && (item.role === "user" || item.role === "assistant") && typeof item.content === "string")
    .slice(-MAX_HISTORY_MESSAGES)
    .map((item) => ({ role: item.role, content: item.content.slice(0, MAX_MESSAGE_CHARS) }));
  if (!messages.length || messages[messages.length - 1].role !== "user") return res.status(400).json({ error: "请输入一条消息" });

  usage.minuteRequests += 1;
  visitorUsage.set(key, usage);

  try {
    const upstream = await fetch("https://api.deepseek.com/chat/completions", {
      method: "POST",
      headers: { "Content-Type": "application/json", Authorization: `Bearer ${process.env.DEEPSEEK_API_KEY}` },
      body: JSON.stringify({
        model: process.env.DEEPSEEK_MODEL || "deepseek-chat",
        messages: [{ role: "system", content: SYSTEM_PROMPT }, ...messages],
        max_tokens: 400,
        temperature: 0.7,
        stream: false
      })
    });
    const data = await upstream.json();
    if (!upstream.ok) { console.error("DeepSeek API error", upstream.status, data); return res.status(502).json({ error: "AI 服务暂时不可用" }); }
    const reply = data?.choices?.[0]?.message?.content;
    if (!reply) return res.status(502).json({ error: "AI 没有返回有效内容" });
    usage.count += 1;
    visitorUsage.set(key, usage);
    return res.status(200).json({ reply });
  } catch (error) {
    console.error("Chat handler error", error);
    return res.status(500).json({ error: "服务器暂时不可用" });
  }
};
