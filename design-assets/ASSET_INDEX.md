# 视觉资产索引

更新日期：2026-08-13

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

## 角色概览 / current drafts

角色概览尚未最终确认。横版连续变形方案 B 是已选方向，继续迭代时不要回到竖版履历或中心能力图。

### 最新草稿 v7：猫＋黑色重量平衡

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

## 教育经历 / paused

- `generated/styleframes/candidates/education-master-derived-v2-mechanical-yacht.png`
  - SHA-256：`ebee0464ef3fac4afa1ed8c522c39fddad699bb8d8f60376462f2125bfd1e9fc`
  - 内容：东华机械学院用齿轮、轴承与连杆；上海海事大学徐悲鸿艺术学院用游艇。
  - 状态：用户暂时不喜欢，明确要求先暂停。不要直接实现到 HTML。
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
