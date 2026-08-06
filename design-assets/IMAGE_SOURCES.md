# 图片源文件与母版规范

## 唯一清晰度／画风母版

- 文件：`source-masters/works-horizontal-master-v1.png`
- SHA-256：`4ae4aa37c0bc1ad588aaab74c5b3af9e359ca553c993bed4ec52bdb6cfbec36e`
- 来源：原始清晰横版 Works 母版

此文件是**不可覆盖的唯一清晰度／画风母版**。它只可被读取、复制和作为新素材变体的直接输入；不得由任何后续生成图、网页运行资产或压缩导出图替代。

## 衍生规则

1. 任何新变体都必须直接引用 `source-masters/works-horizontal-master-v1.png` 原图。
2. 禁止以 `generated/` 下的 `v2`、`v3` 或其他衍生图继续生图；衍生图不能作为下一代生成源。
3. 每个衍生文件必须使用明确版本号，并在同目录说明文件或本文件中记录其父源（本母版的相对路径和版本）。
4. 网页运行资产与生成源严格分离：网页仅使用 `assets/` 中经批准的运行文件；生成源、母版和中间衍生文件仅存放于 `design-assets/`，不得互相覆盖。

## Works 运行时无损分层

- 父源：`assets/works-background.png`（1004 × 1567，保持不变）
- 底图层：`assets/works-background-base.png`
- 蓝色路线层：`assets/works-route.png`
- 处理脚本：`design-assets/tools/split_works_route.py`

上述两个文件是为滚动揭示动效做的同尺寸确定性像素分层，不是新母版，也不得作为下一代生图输入。脚本只识别三段大连通域蓝色路线；卡片上的蓝点和蓝色叉号保留在底图层。处理不缩放、不全局滤镜、不经过生成模型。
