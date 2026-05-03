# 下一步执行清单（协同聚类自适应参数）

## 1) 先跑固定基线（必须）
- 参数固定：`lambda_cont=0.12`、`lambda_branch=0.02`
- 目标：在 DRIVE / STARE 全测试集拿到稳定基线（ACC/SN/SP/F1/MCC + 每图结果）
- 输出文件建议：
  - `result_file/Drive/Drive1/performance.mat`
  - `result_file/STARE/data/performance_stare.mat`

## 2) 开启自动参数（与基线对照）
- 在 `main_drive.m` / `main_stare.m` 中设置：`params.use_auto_lambda = true`
- 记录每张图的：`C, N, V, B, lambda_cont, lambda_branch`
- 对比固定基线与自动参数两组的平均值与标准差

## 3) 做论文可用统计检验
- 指标：F1、MCC 为主，ACC/SN/SP 为辅
- 检验：配对 t-test 或 Wilcoxon signed-rank test（按每图指标）
- 输出：p 值 + 效应量（例如 Cohen's d）

## 4) 画 3 类关键图（论文最重要）
1. 参数分布图：`lambda_cont`、`lambda_branch` 在测试集的分布
2. 相关性图：`C/N/V/B` 与两个 lambda 的散点图 + 拟合线
3. 性能增益图：自动参数相对固定基线的每图 ΔF1 / ΔMCC

## 5) 若自动参数收益不稳定，按顺序修正
1. 调整线性映射系数（先调 `B` 对 `lambda_branch` 的系数）
2. 调整 clip 区间（避免过大 `lambda_branch` 导致召回下降）
3. 保持映射可解释，不要一开始就换复杂模型

## 6) 最小可发表版本（建议）
- 实验组：Fixed-Global vs Auto-Linear
- 数据集：DRIVE + STARE
- 表格：主指标均值±标准差 + 显著性
- 图：参数分布 + 相关性 + 典型可视化案例

> 你现在最该做的是：先把第 1 步和第 2 步跑完整，拿到“固定 vs 自动”的全量结果表。
