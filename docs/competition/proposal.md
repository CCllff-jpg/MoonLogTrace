# MoonLogTrace 项目申报书

## 基本信息

| 项目 | 内容 |
|------|------|
| **项目名称** | MoonLogTrace：纯 MoonBit 结构化日志与追踪库 |
| **GitHub 仓库** | https://github.com/Mitsuha11zz/MoonLogTrace |
| **GitLink 仓库** | https://gitlink.org.cn/clf060328/MoonLogTrace |
| **项目方向** | MoonBit 基础库 / 可观测性工具 |
| **是否为移植项目** | 否（原创项目） |
| **许可证** | Apache-2.0 |

## 项目简介

MoonLogTrace 是一个纯 MoonBit 实现的结构化日志与追踪库，覆盖日志记录、格式化、过滤、输出分发、上下文追踪、性能统计的全链路可观测性需求。19 个模块、54 个测试，零外部依赖。

MoonBit 生态目前缺乏可观测性工具，本项目填补了这一空白。提供 5 级日志过滤、11 种格式化器、Span 追踪、RequestContext 关联ID、Pipeline 中间件、批量日志、性能统计等能力。

## 核心功能范围

### 日志核心
- 5 级日志（TRACE/DEBUG/INFO/WARN/ERROR）+ 级别过滤
- 级别解析器（字符串→Level，支持 WARNING 别名）
- LogRecord 结构化记录 + 类型化字段（Int/Float/Bool/String）

### 格式化器（11 种）
- 文本格式 / JSON / 彩色 ANSI / Compact / CSV
- Pattern 自定义模板（{t} {l} {m} {f}）
- Logfmt / XML / NDJSON
- Syslog RFC 5424 / GELF（Graylog）

### 输出分发
- ConsoleAppender（文本/JSON 控制台输出）
- MemoryAppender（内存收集，测试用）
- RollingAppender（滚动窗口）
- BatchLogger（批量累积输出）
- LogRouter（按级别分流到不同输出端）

### 追踪与上下文
- Span（enter/exit 自动耗时记录，支持嵌套）
- LogContext（持久化键值对，自动附加）
- CorrelationId（请求链路追踪ID）
- RequestContext（上下文+关联ID+Span 完整组合）

### 过滤与管道
- LevelFilter / MessageFilter / FieldFilter
- AllowListFilter / DenyListFilter
- Pipeline（字段添加/脱敏/消息前缀，链式中间件）

### 性能统计
- Counter / Timer / Histogram（基础统计）
- EventMeter（滑动窗口事件计数）
- RateLimiter（速率限制）
- ThroughputCounter（吞吐量统计）

### 配置与预设
- LoggerConfig 构建器
- create_dev_logger / create_prod_logger / create_test_logger 预设

## 差异化价值

| 对比维度 | MoonLogTrace | MoonBit 生态现状 |
|---------|-------------|----------------|
| 日志记录 | 5 级 + 过滤 + 结构化字段 | 无可对标项目 |
| 格式化 | 11 种格式（文本/JSON/Syslog/GELF/...） | 无可对标项目 |
| 追踪 | Span + CorrelationId + RequestContext | 无可对标项目 |
| 统计 | Counter/Timer/Histogram/EventMeter | 无可对标项目 |
| 输出 | 控制台/内存/滚动/批量/分流 | 无可对标项目 |
| 依赖 | 零外部依赖，纯 MoonBit | — |

MoonLogTrace 是 MoonBit 生态中**首个可观测性工具库**，填补了日志、追踪、指标三大可观测性支柱的空白。

## 项目规模

| 类别 | 行数 | 文件数 |
|------|------|--------|
| 日志核心（level/record/logger） | 123 | 3 |
| 格式化器（formatter/format_syslog） | 248 | 2 |
| 输出分发（appender/batch/router） | 179 | 3 |
| 追踪上下文（span/context/correlation） | 124 | 3 |
| 过滤管道（filter/pipeline） | 158 | 2 |
| 性能统计（stats/meter） | 179 | 2 |
| 配置工具（config/level_parser/typed_field） | 184 | 3 |
| 入口 + Demo CLI | 64 | 2 |
| 测试（wbtest + blackbox） | 410 | 2 |
| 文档（README + CI） | 187 | 2 |
| **合计** | **~1,856** | **24** |

项目总计约 1,856 行（源码 1,676 行 + 文档 180 行），14 次有效提交，54 个测试全部通过。

## 适用场景

- **后端服务日志**：5 级过滤 + JSON 格式 + RequestContext 链路追踪
- **CLI 工具调试**：彩色 ANSI 输出 + DEBUG/TRACE 级别
- **性能监控**：Counter/Timer/Histogram + RateLimiter
- **安全审计**：Pipeline 脱敏 + LogRouter 分流 + Syslog 格式
- **Wasm 前端**：MemoryAppender 内存收集 + JSON/GELF 格式对接日志平台
- **MoonBit 生态基础设施**：为所有 MoonBit 项目提供可观测性能力
