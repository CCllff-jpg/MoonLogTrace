# MoonLogTrace

纯 MoonBit 实现的结构化日志与追踪库。

## 功能

- **5 级日志** — TRACE, DEBUG, INFO, WARN, ERROR
- **级别过滤** — 低于阈值的日志自动丢弃
- **9 种格式化器** — 文本、JSON、彩色ANSI、Compact、CSV、Pattern、Logfmt、XML、NDJSON
- **多种输出端** — 控制台输出、内存收集、滚动窗口
- **上下文传递** — LogContext 持久化键值对，自动附加到每条日志
- **Span 追踪** — enter/exit 模式，自动记录耗时
- **高级过滤** — 级别、消息、字段、白名单、黑名单过滤器
- **性能统计** — Counter、Timer、Histogram、EventMeter、RateLimiter、ThroughputCounter
- **批量日志** — 累积批量输出
- **配置构建器** — LoggerConfig 一键创建预置 Logger（dev/prod/test）
- **零依赖** — 纯 MoonBit 实现

## 安装

```
moon add clf060328/MoonLogTrace
```

## 快速开始

```moonbit
let logger = Logger::new()
  .level(Level::INFO)
  .console()
  .build()

let l2 = logger.info("Server started", [("port", "8080")])
let l3 = l2.warn("Disk space low", [("free_gb", "2.3")])

// Span tracing
let (l4, span) = Span::enter(l3, "process", [("id", "42")])
let l5 = span.exit(l4)

let all_logs = l5.logs()
```

## API

### Logger
| 方法 | 说明 |
|------|------|
| `Logger::new()` | 创建默认 Logger (TRACE级别) |
| `.level(l)` | 设置最低日志级别 |
| `.console()` | 启用控制台文本输出 |
| `.console_json()` | 启用控制台JSON输出 |
| `.add_context(k, v)` | 添加上下文键值对 |
| `.build()` | 构建 Logger |
| `.trace(msg, fields)` | TRACE 级别日志 |
| `.debug(msg, fields)` | DEBUG 级别日志 |
| `.info(msg, fields)` | INFO 级别日志 |
| `.warn(msg, fields)` | WARN 级别日志 |
| `.error(msg, fields)` | ERROR 级别日志 |
| `.logs()` | 获取所有已收集日志 |
| `.log_count()` | 获取日志条数 |

### Span
- `Span::enter(logger, name, fields) -> (Logger, Span)`
- `span.exit(logger) -> Logger`

### LoggerConfig
- `LoggerConfig::new().set_level(l).enable_console().build_logger()`
- `create_dev_logger()` / `create_prod_logger()` / `create_test_logger()`

### 格式化器
- `format_text(record)` / `format_json(record)` / `format_color(record)`
- `format_compact(record)` / `format_csv(record)`
- `format_pattern(record, "{t} [{l}] {m}")`
- `format_logfmt(record)` / `format_xml(record)` / `format_ndjson(record)`

### 统计
- `Counter::new(name).increment().add(n).read()`
- `Timer::start(name, seq).stop(current_seq)`
- `Histogram::new(name).record(v).avg().min_val().max_val()`

## 许可证

Apache-2.0
