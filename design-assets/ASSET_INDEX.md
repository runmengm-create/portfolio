# 视觉资产索引

更新日期：2026-08-14

本文件用于区分“已确认”“候选”“暂缓”和“弃用”素材。除 `assets/` 下的网页运行资源外，`design-assets/` 中的图片都只用于设计确认、追溯或后续拆分，不应直接整张贴进网页。

## 已确认 / approved

### 人物画风与身份锚点

- 文件：`generated/approved/character-style-anchor.png`
- SHA-256：`b152fbd35182477d1086953680c38805d1be99357273f3b930b8036573fd1e6f`
- 状态：已确认
- 用途：人物面部、双低辫、比例、宽松浅色毛衣、黑色百褶裙、白袜、黑色厚底鞋与手绘墨线的唯一身份锚点。
- 注意：人物后续必须保持此身份与原始穿搭；不要再次画成写实人物。

### 项目概览新版母版

- 文件：`generated/approved/works-open-fields-master-v1.png`
- SHA-256：`5029867615154f252ecfd94916e54177fca0191a265df25b5aaf5af4b350bcf2`
- 状态：用户明确确认“非常好，不用改了”
- 用途：项目概览最终构图依据。四个开放手绘场域沿蓝线向下排列，替代旧扑克牌卡片布局。
- 实现规则：
  - 不可把整张带字 PNG 直接贴进网页。
  - 米白纸纹使用全站 CSS 背景。
  - 四个手绘主体拆成独立无字资产；能矢量化的颤线优先 SVG。
  - 蓝色线路与节点使用独立 SVG；进入区域后一次性绘制完成。
  - 项目标题、标签和“查看项目”全部使用 HTML 真文字。
  - 蓝线依次经过 01/02/03/04 时，对应图形短暂提亮一次；播放完成后保持终态，不跟随鼠标、不重复播放。

### 角色概览横版母版

- 文件：`generated/approved/role-overview-horizontal-master-v1.png`
- SHA-256：`21a2856cf03946fb70df432d500fd7d403165b510eb65d848ac8b2fc0a30d208`
- 来源候选：`generated/styleframes/candidates/role-overview-horizontal-v10b-yarn-line-question.png`
- 状态：用户明确选择 B 版，已确认并锁定
- 构图：16:9 横版连续长卷；Dickies / 李宁布料场 → 浪漫主义卧猫与钴蓝毛线团 → 单一人物向右行走 → 蔚来座舱系统 → 蓝线路径自然长成问号。
- 已确认变化：不出现食盆或余粮节点；终点不使用多层年轮，也不与座舱轮廓相连，保留充分留白与一笔黑色落影。
- 实现规则：
  - 此 PNG 中的文字只用于展示排版和构图位置，不是网页运行文字。
  - 正式网页不可整张贴入此带字 PNG；应拆出无字手绘形态，纸纹由全站 CSS 承担。
  - 蓝线路径、毛线团线迹、节点与终点问号优先使用独立 SVG。
  - `02 角色概览`、公司名、职责概括、`查看经历 ↗` 和终点文案全部使用独立 HTML 真文字，确保清晰、可访问和响应式适配。
  - `我们一起` 使用钴蓝 HTML 文字，蓝线路径延伸成其独立下划线；其余终点文案为黑色。
- 人物身份与穿搭继续以 `generated/approved/character-style-anchor.png` 为唯一锚点。

## 网页运行分层资产

这些文件由 approved 母版确定性裁切而来，去除了纸张底色与网页文字；网页只引用 `assets/` 下的分层资源。

- 字体使用系统宋体与无衬线字体栈；本机字体文件不进入仓库或部署产物。
- `assets/illustrations/role/role-overview-artwork.png`：角色概览无字透明图案带；终点与公司信息由 HTML 渲染。
- `assets/illustrations/role/role-overview-artwork-no-person-v4.png`：预览页使用的无人物透明图案带；人物与旧第四 CTA 已移除，毛线球与座舱保留。
- `assets/illustrations/works/project-01.png` 至 `project-04.png`：四个项目无字透明图案；蓝线路径由 HTML/SVG 渲染。
- 处理脚本：`design-assets/tools/extract_transparent_art.swift`（主流程）、`extract_transparent_art.py`（备用记录）与 `clean_generated_alpha.swift`（候选图透明背景清理）。

## 01 Hero 小图 / integrated candidate

- 文件：`generated/styleframes/candidates/hero-01-system-panel-v1.png`
- 状态：已接入当前网页 Hero 预览；图案与背景、文字分层渲染，后续仍可替换为用户最终确认稿。
- 方向：沿用已确认项目图的细黑轮廓、颗粒黑填充与单一钴蓝节点，避免开屏圆环、立体纸雕与水墨笔刷风格。
- 实现原则：透明 PNG 只负责图案，Hero 背景与文字继续由网页层独立渲染；网页容器按 16:9 展示。

## Works 蓝线 / visual studies

- `generated/styleframes/candidates/works-route-v2-preview.png`
  - 状态：静态构图候选，尚未接入正式网页。
  - 方向：参考角色概览母版的连续蓝线，把四个项目图与 HTML 文案串成一条细、长、带回旋的路径。
  - 网页规则：PNG 仅供视觉确认；正式版仍由 SVG 路径、节点与 HTML 文字独立渲染。

- `generated/styleframes/candidates/works-open-fields-route-orbit-v1.png`
  - 状态：基于已确认的 `generated/approved/works-open-fields-master-v1.png` 生成的静态候选，尚未接入正式网页。
  - 方向：环绕式；蓝线在四个开放图案外缘形成连续、细长的回环，再向下串联。

- `generated/styleframes/candidates/works-open-fields-route-weave-v1.png`
  - 状态：基于已确认项目母版的静态候选，尚未接入正式网页。
  - 方向：左右走；蓝线以宽松的横向 S 形穿过左右图案之间的留白，强调项目之间的来回关系。

- `generated/styleframes/candidates/works-open-fields-route-drift-v1.png`
  - 状态：基于已确认项目母版的静态候选，尚未接入正式网页。
  - 方向：飘逸式；蓝线以长波、低频、留白更大的方式经过四个项目，像被空气带着向下漂移。

- `generated/styleframes/candidates/works-open-fields-route-drift-desktop-v1.png`
  - 状态：C 版飘逸式的电脑端宽屏比例预览，尚未接入正式网页。
  - 方向：保留 C 版长波蓝线，将四个项目改为横向错落排列，避免桌面端内容过窄；画面比例约 16:9。

- `generated/styleframes/candidates/works-open-fields-route-drift-mobile-balance-v1.png`
  - 状态：C 版手机竖版的轻微平衡稿，尚未接入正式网页。
  - 方向：基本保持手机竖版构图，只将图案与对应文字向两侧轻推少量，保留大面积米白留白；暂不改变项目顺序、尺度和飘逸线路。

## 当前进度 / 2026-08-14

- 已确认：项目区先采用 C 版“飘逸式”作为方向；本轮新增手机竖版轻微平衡静态稿，等待确认。
- 开屏已接入第一版交互原型：蓝色毛线团滚入，点击后解开为 C 版飘逸蓝线，随后自然淡出进入 Hero；其他区域暂不改动。
- 暂不修改网页：项目区 C 版线路、全站蓝线动效、B 版字体替换均保留在候选/待实现状态。
- 网页版项目区的文字应比静态平衡稿更靠近对应图案；静态稿留白仅用于确认线路和整体节奏。
- 预览状态：当前 `127.0.0.1:4174` 仅供本机访问；手机与电脑不在同一网络，本轮不部署远程预览。
- DS API：用户已提供 key，但未写入仓库、网页或明文交接文件；待确认服务商与 endpoint 后使用安全环境变量接入。

## 字体 / reference sheet

- `generated/styleframes/candidates/font-reference-sheet-v1.png`
  - 状态：字体比较参考，尚未替换正式网页。
  - 对比：A 当前字体文件、B Songti SC、C STSong、D 当前无衬线文件、E PingFang SC、F Hiragino Sans GB。

## 角色概览 / archived drafts

角色概览已由 `generated/approved/role-overview-horizontal-master-v1.png` 锁定。以下文件只用于追溯，不再作为正式实现母版。

### v10A：逗猫棒＋开放墨弧问号

- 文件：`generated/styleframes/candidates/role-overview-horizontal-v10a-teaser-open-question.png`
- SHA-256：`b8b08de2c5321bf271664f7e045fa95a00afadff24f52d43289d2ff36d24d97b`
- 状态：未选；保留作方案对照

### v9：卧猫抓尾巴

- 文件：`generated/styleframes/candidates/role-overview-horizontal-morph-v9-lying-tail-play.png`
- SHA-256：`68ecaee32eb4d7fe996eddd2d20a126fcbd3fef6039edf45a7a05b8828f18512`
- 状态：已被 v10B 取代

### v8：浪漫主义墨块猫

- 文件：`generated/styleframes/candidates/role-overview-horizontal-morph-v8-romantic-ink-cat.png`
- SHA-256：`d5e9a8d3c8f2dcef1c4304870a6fe6f95ddea4390d1371ff6ba67b4cc7b34e84`
- 状态：已被 v9 / v10B 取代

### v7：猫＋黑色重量平衡

- 文件：`generated/styleframes/candidates/role-overview-horizontal-morph-v7-cat-balanced.png`
- SHA-256：`f8013a8730b03a512c0f9b18394936476f8241a8edbc8806aaecd90d1c8a2b32`
- 状态：未确认；需要再改
- 已保留的优点：
  - 16:9 横版长卷构图。
  - 从左到右：Dickies / 李宁布料 → 70mai 猫与称重食碗 → 中央人物行走 → 蔚来座舱系统 → 未知年轮。
  - 蔚来与未知年轮加入黑色颗粒墨块后，左右黑色重量更均衡。
  - 终点文案为“下一段经历，我们一起创造？”，其中“我们一起”为蓝色并接蓝色下划线。
  - 三家公司各自保留“查看经历 ↗”；问号区域没有“查看经历”。
- 必须修改：70mai 猫咪仍偏具体、写实。下一版应更浪漫主义、更概括，像从布料墨块里长出来的猫形意象，而不是一只被准确描绘的宠物猫。
- 下一版生成规则：不要继续在 v7 像素上反复后修。应从不可覆盖横版母版、人物身份锚点与已确认项目母版重新生成清晰 v8；v7 仅作为布局参考。

### v6：无猫、构图收束版

- 文件：`generated/styleframes/candidates/role-overview-horizontal-morph-v6-consolidated.png`
- SHA-256：`5865a2d818db2a00f93f96c52a99939f86b50c4b0bf441ef2d293a6ddfaff0b8`
- 状态：未确认；保留作结构对照
- 价值：中段从许多零件碎片收束成完整称重装置，证明“每一段只保留一个大视觉主体”的方向正确。

### v5：平面统一但中段过碎

- 文件：`generated/styleframes/candidates/role-overview-horizontal-morph-v5-flat.png`
- SHA-256：`5ce72975da10c9bd4c3fb0c569ebb01d4d4180c8b94853d49973dca8ccb68a01`
- 状态：未确认
- 问题：硬件部分的小圆片、散点过多，视觉频率与项目母版不一致。

### v4B：横版连续变形原始方向

- 文件：`generated/styleframes/candidates/role-overview-horizontal-morph-v4b.png`
- SHA-256：`f47c9a102fce6438bd29ed05c1fe3201793ffc19dfc73edbed250899af19f7d3`
- 状态：方向选中，但空间语言不统一
- 价值：用户在 A/B 两案中认可 B。布料 → 硬件 → 座舱 → 未知波纹的连续变形长卷是后续角色概览的核心概念。
- 问题：左侧平面，人物附近之后出现立体零件与座舱，空间语言发生跳变。

### 其他角色稿

- `generated/styleframes/candidates/role-overview-horizontal-journey-v4a.png`：横向节点方案 A，清晰但更像履历导航，未选。
- `generated/styleframes/candidates/role-overview-walking-journey-v3.png`：竖版人物旅程，逻辑清楚但与横版开屏不搭。
- `generated/styleframes/candidates/role-overview-cross-section-v2.png`：中心能力剖面，信息混在一起，不清晰。
- `generated/styleframes/candidates/experience-master-derived-v1.png`：最初三段开放场域稿；视觉语言受到认可，后来被转用于项目概览方向。

## 教育经历 / text-led approved

- `generated/styleframes/candidates/education-typography-v3-songti.png`
  - 状态：文字排版方向已确认；正式网页使用 HTML 真文字，不贴整张 PNG。
  - 内容：东华大学机械硕士与 2025 市级一等奖；上海海事大学工业设计学士、本科阶段奖项与志愿经历。
- `generated/styleframes/candidates/education-master-derived-v2-mechanical-yacht.png`
  - 状态：旧图像方案暂缓，不作为网页素材。
- `generated/styleframes/candidates/education-master-derived-v1.png`
  - 状态：早期候选，不使用。
- 下一次教育设计应重新提案，不应继续对 v2 反复后修。

## 历史 Works 与交互原型

- `generated/styleframes/works-s-curve-styleframe-v2-no-characters.png`：旧扑克牌竖版 Works 母版，已被新版开放场域构图取代；仅供追溯当前 HTML。
- `generated/interaction-prototype/`：早期单卡片、人物与气泡交互实验。当前决定是人物暂不放进项目区，不能作为新版项目页的实现依据。

## 弃用 / rejected

- `generated/rejected/walk-sprite-v1-static-slide.png`：人物没有形成真实走路动作。
- `generated/rejected/wardrobe-white-v1-too-realistic.png`：过于写实。
- `generated/wardrobe-options/`：两套换装只作备选，当前人物继续使用身份锚点里的原始穿搭。

## 通用视觉规则

1. 一张连续米白纸面，纸纹不能只存在于图片卡片中。
2. 颤抖、不规则、略笨拙的黑色墨线；黑块带干刷与颗粒感。
3. 唯一强调色为电光钴蓝；用于路线、节点、小叉号、局部文字与下划线。
4. 不用摄影、不用写实插画、不用 3D、渐变、玻璃或精致矢量图标。
5. 不再使用撕纸、胶带、档案袋、正式时间轴或企业简历模板语言。
6. 大视觉主体优先：一段只保留一个完整意象，避免许多小图标与碎点。
7. 图片负责纸、墨与形；所有正式网页标题、标签、按钮和经历内容使用 HTML 真文字，避免放大模糊。
8. 不在多次后修生成稿上继续生图。下一轮必须回到清晰母版与 approved 锚点，从干净输入重新生成。
