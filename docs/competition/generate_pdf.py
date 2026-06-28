"""Generate MoonLogTrace proposal PDF — distinct layout style."""
from fpdf import FPDF
import os

script_dir = os.path.dirname(os.path.abspath(__file__))
local_font = os.path.join(script_dir, "font.ttc")

if not os.path.exists(local_font):
    for fp in [
        "C:/Windows/Fonts/msyh.ttc",
        "C:/Windows/Fonts/msyhbd.ttc",
        "C:/Windows/Fonts/simsun.ttc",
        "C:/Windows/Fonts/simhei.ttf",
    ]:
        if os.path.exists(fp):
            import shutil
            shutil.copy(fp, local_font)
            break

if not os.path.exists(local_font):
    print("ERROR: No Chinese font found!")
    exit(1)

PRIMARY = (20, 110, 100)
LIGHT_BG = (235, 250, 248)
BORDER = (180, 220, 215)
DARK_TEXT = (30, 50, 48)
MED_TEXT = (90, 105, 100)

class PDF(FPDF):
    def __init__(self):
        super().__init__()
        self.add_font("F", fname=local_font)
        self.add_font("F", "B", fname=local_font)
        self.col = 0
        self.base_y = 0

    def header(self): pass
    def footer(self): pass

    def banner(self, title, subtitle):
        # Full-width colored banner at top
        self.set_fill_color(*PRIMARY)
        y0 = self.get_y()
        self.rect(self.l_margin, y0, self.w - self.l_margin - self.r_margin, 18, style="F")
        self.set_font("F", "B", 15)
        self.set_text_color(255, 255, 255)
        self.set_y(y0 + 2)
        self.cell(0, 7, title, align="C", new_x="LMARGIN", new_y="NEXT")
        self.set_font("F", "", 7.5)
        self.set_y(self.get_y() - 1)
        self.cell(0, 5, subtitle, align="C", new_x="LMARGIN", new_y="NEXT")
        self.set_y(y0 + 20)

    def tag(self, text):
        # Inline colored tag
        w = self.get_string_width(" " + text + " ") + 4
        x = self.get_x()
        y = self.get_y()
        self.set_fill_color(*LIGHT_BG)
        self.set_text_color(*PRIMARY)
        self.rect(x, y - 1, w, 5, style="F")
        self.set_font("F", "B", 7)
        self.cell(w, 4.5, " " + text + " ")
        self.set_text_color(*DARK_TEXT)

    def sec_title(self, text):
        self.ln(2)
        self.set_font("F", "B", 10.5)
        self.set_text_color(*PRIMARY)
        # Left accent bar
        self.set_fill_color(*PRIMARY)
        self.rect(self.l_margin, self.get_y() + 1, 2.5, 5, style="F")
        self.set_x(self.l_margin + 5)
        self.cell(0, 6, text, new_x="LMARGIN", new_y="NEXT")
        self.ln(2)

    def info_row(self, label, value):
        self.set_font("F", "B", 7.5)
        self.set_text_color(*PRIMARY)
        self.cell(26, 4.5, "  " + label)
        self.set_font("F", "", 7.5)
        self.set_text_color(*DARK_TEXT)
        self.cell(0, 4.5, value, new_x="LMARGIN", new_y="NEXT")

    def body(self, text):
        self.set_font("F", "", 7)
        self.set_text_color(*MED_TEXT)
        self.set_x(self.l_margin + 5)
        self.multi_cell(self.w - self.l_margin - self.r_margin - 5, 3.6, text, align="L")

    def bullet(self, text):
        self.set_font("F", "", 6.8)
        self.set_text_color(*DARK_TEXT)
        self.set_x(self.l_margin + 5)
        self.cell(3, 3.5, "")
        self.set_fill_color(*PRIMARY)
        self.circle(self.get_x() + 1, self.get_y() + 1.8, 0.8)
        self.set_x(self.get_x() + 4)
        self.cell(0, 3.5, text, new_x="LMARGIN", new_y="NEXT")

    def circle(self, cx, cy, r):
        # Draw a small filled circle (approximation with tiny rect)
        self.set_fill_color(*PRIMARY)
        self.rect(cx - r, cy - r, r * 2, r * 2, style="F")

    def t_header(self, cells, widths):
        self.set_fill_color(*PRIMARY)
        self.set_text_color(255, 255, 255)
        self.set_font("F", "B", 7)
        h = 5
        self.set_x(self.l_margin + 5)
        for cell, w in zip(cells, widths):
            x = self.get_x()
            self.rect(x, self.get_y(), w, h, style="F")
            self.cell(w, h, " " + cell)
        self.ln(h)

    def t_row(self, cells, widths, bold=False):
        if bold:
            self.set_fill_color(235, 250, 248)
            self.set_font("F", "B", 7)
        else:
            self.set_fill_color(255, 255, 255)
            self.set_font("F", "", 7)
        self.set_text_color(*DARK_TEXT)
        h = 4.8
        self.set_x(self.l_margin + 5)
        for i, (cell, w) in enumerate(zip(cells, widths)):
            x = self.get_x()
            self.rect(x, self.get_y(), w, h, style="DF")
            # Left border for first column
            if i == 0:
                self.set_fill_color(*PRIMARY)
                self.rect(x, self.get_y(), 1.5, h, style="F")
                self.set_fill_color(255, 255, 255)
            self.cell(w, h, "  " + cell)
        self.ln(h)


pdf = PDF()
pdf.set_auto_page_break(auto=False)
pdf.add_page()

pdf.banner("MoonLogTrace 项目申报书", "2026 MoonBit 国产开源生态竞赛（个人赛）")

# ===== 一 =====
pdf.sec_title("基本信息")
pdf.info_row("项目名称", "MoonLogTrace：纯 MoonBit 结构化日志与追踪库")
pdf.info_row("GitHub", "https://github.com/CCllff-jpg/MoonLogTrace")
pdf.info_row("GitLink", "https://gitlink.org.cn/clf060328/MoonLogTrace")
pdf.info_row("项目方向", "MoonBit 基础库 / 可观测性工具")
pdf.info_row("类型 / 许可证", "原创项目  /  Apache-2.0")

# ===== 二 =====
pdf.sec_title("项目简介")
pdf.body(
    "MoonLogTrace 是一个纯 MoonBit 实现的结构化日志与追踪库，19 个模块、54 个测试，零外部依赖。"
    "覆盖日志记录、11 种格式化、5 种输出分发、Span 追踪、RequestContext 关联ID、Pipeline 中间件、"
    "批量日志、性能统计（Counter/Timer/Histogram/EventMeter/RateLimiter）的完整可观测性链路。"
    "MoonBit 生态目前缺乏可观测性工具，本项目填补了这一空白。"
)

# ===== 三 =====
pdf.sec_title("核心功能")

pdf.t_header(["模块", "内容"], [70, 100])
for row in [
    ("日志核心", "5级过滤(TRACE~ERROR) + 级别解析 + LogRecord + TypedField(Int/Float/Bool/String)"),
    ("格式化器 ×11", "文本 / JSON / 彩色ANSI / Compact / CSV / Pattern / Logfmt / XML / NDJSON / Syslog / GELF"),
    ("输出分发 ×5", "ConsoleAppender / MemoryAppender / RollingAppender / BatchLogger / LogRouter(按级别分流)"),
    ("追踪上下文", "Span(嵌套enter/exit) / LogContext(持久化) / CorrelationId / RequestContext"),
    ("过滤管道", "LevelFilter / MessageFilter / FieldFilter / AllowList / DenyList + Pipeline中间件"),
    ("性能统计 ×6", "Counter / Timer / Histogram / EventMeter(滑动窗口) / RateLimiter / ThroughputCounter"),
    ("配置预设", "LoggerConfig构建器 + create_dev_logger / create_prod_logger / create_test_logger"),
]:
    pdf.t_row(row, [70, 100])
pdf.ln(1)

pdf.body(
    "11 种格式化器覆盖从开发调试（彩色ANSI/Pattern）到生产运维（JSON/Syslog/GELF）的完整场景。"
    "Pipeline 支持字段添加、敏感信息脱敏、消息前缀等链式处理。"
    "LogRouter 按级别自动分流——ERROR/WARN 单独收集，INFO/DEBUG 全量存储。"
)

# ===== 四 =====
pdf.sec_title("差异化定位")
pdf.body(
    "MoonLogTrace 是 MoonBit 生态中首个可观测性工具库，填补了日志、追踪、指标三大支柱的空白。"
    "对比传统日志库仅提供 println 级别输出，MoonLogTrace 提供了完整的企业级可观测性能力："
    "结构化日志 + 多格式输出 + 请求链路追踪 + 性能指标采集 + 日志管道处理。"
)

pdf.t_header(["维度", "MoonLogTrace", "MoonBit 生态"], [36, 65, 65])
for row in [
    ("日志", "5级+结构化字段+11种格式", "无对标项目"),
    ("追踪", "Span+CorrelationId+RequestContext", "无对标项目"),
    ("指标", "Counter/Timer/Histogram/+3", "无对标项目"),
    ("输出", "5种Appender+路由分流", "无对标项目"),
    ("依赖", "零外部依赖，纯MoonBit", "—"),
]:
    pdf.t_row(row, [36, 65, 65])
pdf.ln(1)

# ===== 五 =====
pdf.sec_title("规模与状态")

pdf.t_header(["类别", "行数", "文件", "说明"], [36, 24, 18, 90])
for row in [
    ("格式化器", "248", "2", "formatter + format_syslog（11种格式）"),
    ("输出分发", "179", "3", "appender / batch / router"),
    ("性能统计", "179", "2", "stats / meter（6种工具）"),
    ("过滤管道", "158", "2", "filter（5种）+ pipeline中间件"),
    ("追踪上下文", "124", "3", "span / context / correlation"),
    ("日志核心", "123", "3", "level / record / logger"),
    ("配置工具", "184", "3", "config / level_parser / typed_field"),
    ("测试代码", "410", "2", "54个测试（白盒+黑盒），全通过"),
    ("文档+CI+CLI", "251", "4", "README / CI / Demo CLI / 入口"),
    ("合计", "1,856", "24", "14次有效提交"),
]:
    pdf.t_row(row, [36, 24, 18, 90], bold=(row[0] == "合计"))

# ===== 六 =====
pdf.sec_title("适用场景")
pdf.body(
    "后端服务日志（5级过滤 + JSON + RequestContext链路追踪） / "
    "CLI工具调试（彩色ANSI输出） / "
    "性能监控（Counter/Timer/Histogram + RateLimiter限流） / "
    "安全审计（Pipeline脱敏 + LogRouter分流 + Syslog标准格式） / "
    "Wasm前端（MemoryAppender + JSON/GELF对接日志平台） / "
    "MoonBit 生态基础设施（为所有项目提供可观测性能力）"
)

output_path = os.path.join(os.path.dirname(__file__), "MoonLogTrace项目申报书.pdf")
pdf.output(output_path)
print(f"Done: {output_path}")
