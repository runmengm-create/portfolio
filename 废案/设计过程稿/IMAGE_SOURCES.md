# 图片源文件与母版规范

## 当前唯一清晰度／画风母版

- 文件：`generated/approved/works-open-fields-master-v1.png`
- 来源：已确认的四项目纵向排版母版

此文件是**不可覆盖的唯一清晰度／画风母版**。它只可被读取、复制和作为新素材变体的直接输入；不得由任何后续生成图、网页运行资产或压缩导出图替代。此前的 `source-masters/works-horizontal-master-v1.png` 与 `assets/works-background*` 旧方案已废弃，不得引用。

## 衍生规则

1. 任何新变体都必须直接引用 `generated/approved/works-open-fields-master-v1.png` 原图。
2. 禁止以 `generated/` 下的 `v2`、`v3` 或其他衍生图继续生图；衍生图不能作为下一代生成源。
3. 每个衍生文件必须使用明确版本号，并在同目录说明文件或本文件中记录其父源（本母版的相对路径和版本）。
4. 网页运行资产与生成源严格分离：网页仅使用 `assets/` 中经批准的运行文件；生成源、母版和中间衍生文件仅存放于 `design-assets/`，不得互相覆盖。

## Works 运行时分层

正式网页使用四个透明项目图，蓝线路径以当前确认母版的坐标为基准独立复刻，文字由 HTML 渲染。此前整张 `works-background*` 与其路线切分脚本已废弃，不再参与任何预览或生成。
