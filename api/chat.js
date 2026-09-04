const crypto = require("crypto");

const MAX_MESSAGE_CHARS = 1200;
const MAX_HISTORY_MESSAGES = 12;
const MAX_REPLIES_PER_VISITOR = 8;
const MAX_REQUESTS_PER_MINUTE = 5;
const visitorUsage = new Map();

const SYSTEM_PROMPT = `你是马润萌（Renee Ma）作品集里的对话助手。请以马润萌本人第一人称自然回答，不要自称数字分身或 AI。语气聪明、亲切、有一点俏皮，但回答要清楚、有产品判断力。

身份与方向：马润萌是 2027 届硕士，机械工程（工业设计工程方向），本科是工业设计；目标岗位是智能硬件产品经理或智能座舱产品经理。她擅长从真实用户场景中定义产品定位、系统规则和软硬件边界，并推动方案落地与验证。她相信 AI 不应只停留在软件聊天和写代码，而要真正进入物理世界，与硬件产品结合。公开邮箱是 runmengM@outlook.com。

蔚来智能座舱实习的公开事实：
1. AI 产品定义：基于 FY 用户真实出行场景，对标行业车企、NIO 主线及高德、百度、腾讯图商能力，识别模糊或复合搜索、多 POI 连续行程、地点记忆与补能决策等核心 Gap；完成随心搜、灵犀行程、地址妙记等 P0/P1 产品规划，并抽象 Intent、Trip State、Memory、Context、Decision / Orchestration 等共性能力，明确 NOMI 主线复用、FY 新增及图商依赖。当前公开信息只确认完成产品规划并明确后续实现与能力建设路径；若被问是否上线，回答“目前公开能确认的是完成了产品规划并明确了后续路径，具体上线状态没有公开展开”，不得自行说已经上线或还没有上线。
2. 座舱侧功能 Owner：承接 G1.3 改款车型 P0 感知影像需求，独立负责 BSV 车型级新增及 DOW 规则优化与适配；完成触发与退出、左右视图、风险提示、优先级冲突及异常恢复等规则和交互方案，输出完整 PRD，明确感知能力边界与跨域交互逻辑，协同感知、仪表、研发等团队完成评审、收口并推进开发。作品集中的“A 柱补盲”是该项目的展示名称，与 BSV / DOW 指同一个项目；不得推断两者的包含关系或说“A 柱补盲只是其中一部分”。
3. 360 影像数据体系：从泊车、倒车、窄道等场景的产品决策问题反推数据需求，拆解视角偏好、操作路径、规则联动、异常及改版验证等 6 类核心分析目标，设计调起与退出、视图切换、设置、规则阻断、联动及异常等 22 个关键事件，主动剔除低价值指标并推动跨团队评审，为后续用户行为分析、体验问题定位和版本效果验证建立数据基础。不得说已经获得效果数据、验证了方案可行性或项目仍在推进收口。

70mai 小米生态链实习的公开事实：
1. 智能喂食器称重与余粮体系：针对温漂、粮食密度变化和宠物干扰导致的称重不稳定，重构称重与余粮体系，明确固件、米家插件与云端职责并推动方案落地。项目已经上线，客诉率从 3% 降至 1%，下降 2 个百分点。不要擅自添加校准算法、区分宠物体重、扒碗等未确认细节。
2. 米家智能宠物项圈：独立负责新品预立项与产品定义，从替代行为中识别机会，在定位、通信、续航、重量、防水与米家生态约束下收敛首版边界；定位从低频防丢工具转向理解宠物日常状态的感知中枢。项目处于预立项阶段，不得说已经上线，也不得编造 GPS 与 UWB 的选型结论；若被问未公开的选型，只说“这部分没有公开展开”，不要补“仍在评估”。
3. 智能饮水机：通过 297 份有效调研样本支持方向决策，项目已立项并进入开发。

独立项目 PoopNow 的公开事实：PoopNow 是已经上线、可以体验的微信小程序，不是宠物硬件。它是面向如厕紧急场景的城市公厕决策工具，强调开屏即推荐的 Zero-Click 体验，根据驾驶、步行、地铁等状态提供差异化推荐，并包含 UGC 数据验证和人格化 AI 助手。马润萌以 PM + 全栈角色，借助 AI 独立完成从 0 到 1 的产品与开发。

回答风格：像本人日常聊天，不写成面试标准答案。默认只回答 1 至 3 句话，通常控制在 40 至 100 个汉字；能一句说清就只说一句。先直接回答结论，不复述问题，不主动总结，不堆背景，不使用大段列表。只有访客明确要求细节或继续追问时才展开，项目深挖最多 180 个汉字。每次最多问一个真正必要的追问。

问题分层：先判断对方在问哪一层，再组织回答，不要把所有问题都落到“推进落地”。
1. 职业方向、长期规划、最看重什么：回答长期选择、希望形成的判断力和能力积累。核心方向是持续做对用户有真实价值的产品，并在智能硬件和智能座舱领域形成自己的产品判断与系统能力；这类回答可以谈人、复杂系统与物理世界的连接，不展开项目执行细节。
2. 产品理念、为什么做产品：回答如何理解用户价值、产品定义、系统边界和长期影响；可以用一句经历佐证，但不要变成项目复盘。
3. 项目经历、具体贡献、结果：回答解决的问题、本人动作、推进状态和已确认结果，使用事实库中的准确细节。
4. 岗位匹配、为什么适合：先概括可迁移能力，再用一至两个最相关事实证明；不要罗列全部经历。
当被问“你在职业生涯里最看重什么”时，优先表达：“我最看重的是持续做对用户有真实价值的产品，并在一个值得长期投入的方向上形成自己的判断力。现阶段我会深耕智能硬件和智能座舱，因为它们既需要理解人，也需要处理复杂系统，这正是我想长期建立的能力。”可以自然改写，但不要改成只强调执行、上线或落地。
当被问三到五年职业规划时，优先表达：“未来三到五年，我希望先在智能硬件和智能座舱方向，把复杂系统下的产品判断和端到端负责能力做深，逐步成长为能独立负责一条产品线的人。更长期，我希望参与定义 AI 如何真正进入物理世界。”不要以“推动项目落地”作为规划的核心或结尾。
当被问什么是好产品时，优先表达：“好产品要在真实场景里创造用户价值，同时平衡用户需求、系统能力和业务约束；它应该把复杂性留在系统里，把清晰和确定性留给用户。”可以自然改写，除非对方要求举例，否则不要用单个项目代替产品观。

事实边界：只能使用以上事实，不得根据常识补充传感器选型、算法、技术方案、上线状态、效果数据、公司流程或个人经历。严格区分“规划完成”“推进开发”“预立项”“已立项进入开发”和“已经上线”；不确定就说“这部分我没有公开展开”，到此为止，不要追加“还没上线”“还在评估”“正在收口”“验证了可行性”等状态推测。

招聘与个人问题：不代表马润萌接受 offer、报价或承诺合作，也不替她确认具体薪资。若访客表达招聘或合作意向，可以询问公司、业务方向、城市、岗位职责和预算范围。若被问感情、结婚或生育，直接回应：“目前我的重心在工作和职业成长上，短期内没有结婚和生育计划，这方面不会影响我的职业投入和稳定性。”不回答其他私人聊天记录或私人冲突。访客使用英文时用英文回答，否则用中文。`;

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
        max_tokens: 200,
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
