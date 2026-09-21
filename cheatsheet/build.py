"""
Printable Lisp keybinding cheat sheet — Doom Emacs (terminal).

Layout: US Letter landscape, two pages, dense 4-column grid.
Page 1: SLY, Geiser, CIDER, Racket-mode.
Page 2: Hy, structural editing, REPL comma-commands, Doom leader.

All bindings verified against upstream docs on 2026-09-17.
"""

from pathlib import Path

from reportlab.lib.colors import HexColor
from reportlab.lib.pagesizes import landscape, letter
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.units import inch
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import (
    BaseDocTemplate,
    Frame,
    KeepTogether,
    PageTemplate,
    Paragraph,
    Spacer,
    Table,
    TableStyle,
)


# ─── Fonts ─────────────────────────────────────────────────────────────────
FONT_DIR = Path("/tmp/fonts")
pdfmetrics.registerFont(TTFont("DM", str(FONT_DIR / "DMSans-Regular.ttf")))
pdfmetrics.registerFont(TTFont("DM-Med", str(FONT_DIR / "DMSans-Medium.ttf")))
pdfmetrics.registerFont(TTFont("DM-Bold", str(FONT_DIR / "DMSans-Bold.ttf")))
pdfmetrics.registerFont(TTFont("Mono", str(FONT_DIR / "JetBrainsMono-Regular.ttf")))
pdfmetrics.registerFont(TTFont("Mono-Bold", str(FONT_DIR / "JetBrainsMono-Bold.ttf")))

# ─── Palette (Nexus, print-friendly) ───────────────────────────────────────
BG        = HexColor("#F7F6F2")
INK       = HexColor("#28251D")
MUTED     = HexColor("#7A7974")
RULE      = HexColor("#D4D1CA")
ACCENT    = HexColor("#01696F")   # section headers
ACCENT_2  = HexColor("#8A3324")   # subtle emphasis (unused; reserved)
KEY_BG    = HexColor("#EDEAE2")   # tint behind key column


# ─── Styles ────────────────────────────────────────────────────────────────
TITLE = ParagraphStyle(
    "Title", fontName="DM-Bold", fontSize=14, leading=15,
    textColor=INK, spaceAfter=1,
)
SUBTITLE = ParagraphStyle(
    "Subtitle", fontName="DM", fontSize=7.5, leading=9,
    textColor=MUTED, spaceAfter=6,
)
SECTION = ParagraphStyle(
    "Section", fontName="DM-Bold", fontSize=8.5, leading=10,
    textColor=ACCENT, spaceBefore=3, spaceAfter=2,
)
SUBHEAD = ParagraphStyle(
    "Sub", fontName="DM-Med", fontSize=6.8, leading=8,
    textColor=MUTED, spaceBefore=2, spaceAfter=1,
)
FOOT = ParagraphStyle(
    "Foot", fontName="DM", fontSize=6, leading=7,
    textColor=MUTED, alignment=0,
)


def kb_table(rows, key_w=1.1 * inch, desc_w=1.55 * inch):
    """Build a compact key-binding table.

    rows: list of (key, description) tuples. A row with key=None is a sub-header.
    """
    data = []
    styles = [
        ("FONT",        (0, 0), (-1, -1), "DM", 6.6),
        ("TEXTCOLOR",   (0, 0), (-1, -1), INK),
        ("VALIGN",      (0, 0), (-1, -1), "MIDDLE"),
        ("LEFTPADDING", (0, 0), (-1, -1), 3),
        ("RIGHTPADDING",(0, 0), (-1, -1), 3),
        ("TOPPADDING",  (0, 0), (-1, -1), 1.4),
        ("BOTTOMPADDING",(0, 0), (-1, -1), 1.4),
        # key column
        ("FONT",        (0, 0), (0, -1), "Mono", 6.2),
        ("BACKGROUND",  (0, 0), (0, -1), KEY_BG),
        ("TEXTCOLOR",   (0, 0), (0, -1), INK),
        # hairline row separators
        ("LINEBELOW",   (0, 0), (-1, -2), 0.25, RULE),
    ]
    for i, row in enumerate(rows):
        if row[0] is None:
            # sub-header row: spans both cols, styled differently
            data.append([row[1], ""])
            styles.append(("SPAN", (0, i), (1, i)))
            styles.append(("FONT", (0, i), (-1, i), "DM-Bold", 6.4))
            styles.append(("TEXTCOLOR", (0, i), (-1, i), ACCENT))
            styles.append(("BACKGROUND", (0, i), (-1, i), BG))
            styles.append(("TOPPADDING", (0, i), (-1, i), 4))
            styles.append(("BOTTOMPADDING", (0, i), (-1, i), 2))
            styles.append(("LEFTPADDING", (0, i), (-1, i), 0))
        else:
            data.append([row[0], row[1]])

    tbl = Table(data, colWidths=[key_w, desc_w], hAlign="LEFT")
    tbl.setStyle(TableStyle(styles))
    return tbl


# ─── Content ───────────────────────────────────────────────────────────────
SLY = [
    (None, "Source buffers"),
    ("C-c C-c",       "Compile defun"),
    ("C-c C-k",       "Compile & load file"),
    ("C-c M-k",       "Compile file (no load)"),
    ("C-c C-l",       "LOAD file"),
    ("C-x C-e",       "Eval last sexp"),
    ("C-M-x",         "Eval defun"),
    ("C-c C-r",       "Eval region"),
    ("C-c C-p",       "Eval + pretty-print"),
    ("C-c C-b",       "Interrupt Lisp"),
    ("C-c C-z",       "Switch to REPL"),
    ("C-c ~",         "Sync REPL pkg/dir"),
    ("M-. / M-,",     "Jump to def / back"),
    ("M-?",           "Find references"),
    ("M-n / M-p",     "Next / prev note"),
    (None, "Docs (C-c C-d …)"),
    ("C-c C-d C-d",   "Describe symbol"),
    ("C-c C-d C-f",   "Describe function"),
    ("C-c C-d C-h",   "HyperSpec lookup"),
    ("C-c C-d C-a",   "Apropos"),
    ("C-c C-d C-p",   "Apropos package"),
    (None, "Analyze"),
    ("C-c C-m",       "Macroexpand-1"),
    ("C-c M-m",       "Macroexpand all"),
    ("C-c M-d",       "Disassemble"),
    ("C-c I",         "Inspect (prompt)"),
    ("C-c C-t",       "Toggle trace"),
    ("C-c T",         "Trace Dialog"),
    ("C-c < / >",     "List callers / callees"),
    (None, "Stickers"),
    ("C-c C-s C-s",   "Sticker at point"),
    ("C-c C-s C-r",   "Replay stickers"),
    ("C-c C-s n/p",   "Next / prev sticker"),
    (None, "REPL (sly-mrepl)"),
    ("M-p / M-n",     "History prev / next"),
    ("C-r",           "Isearch history"),
    ("C-c C-o",       "Clear recent output"),
    ("C-c M-o",       "Clear entire REPL"),
    (", <cmd>",       ",in-package  ,cd  ,quit"),
]

GEISER = [
    (None, "Scheme buffers"),
    ("C-x C-e",       "Eval last sexp"),
    ("C-M-x / C-c C-c","Eval defun"),
    ("C-c C-r",       "Eval region"),
    ("C-c C-b",       "Eval buffer"),
    ("C-c C-l",       "Load file"),
    ("C-c M-e",       "Eval defun + switch"),
    ("C-c M-r / M-b", "Eval region/buf + switch"),
    ("C-c C-z",       "Switch to REPL"),
    ("C-c C-a",       "Switch REPL + enter mod"),
    ("C-c C-s",       "Set Scheme impl"),
    ("M-. / M-,",     "Jump to def / back"),
    (None, "Docs & xref"),
    ("C-c C-d C-d",   "Symbol docs"),
    ("C-c C-d C-m",   "Module exports"),
    ("C-c < / >",     "Callers / callees"),
    (None, "Macros (C-c C-m …)"),
    ("C-c C-m C-e",   "Expand last sexp"),
    ("C-c C-m C-x",   "Expand definition"),
    ("C-c C-m C-r",   "Expand region"),
    (None, "Edit (C-c C-e …)"),
    ("C-c C-e C-m",   "Edit module"),
    ("C-c C-e C-l",   "Add to load path"),
    ("C-c C-e C-[",   "Toggle ( ) <-> [ ]"),
    ("C-c C-\\",      "Insert lambda"),
    (None, "REPL (geiser-repl)"),
    ("C-c C-m",       "Set current module"),
    ("C-c C-i",       "Import module"),
    ("C-c M-o",       "Clear REPL"),
    ("M-x …-restart-repl", "Restart (geiser-)"),
    (", <cmd>",       "Native Scheme commands: ,help"),
]

CIDER = [
    (None, "Eval"),
    ("C-x C-e / C-c C-e", "Eval last sexp"),
    ("C-c C-c / C-M-x", "Eval defun"),
    ("C-c C-v r",     "Eval region (C-c C-v map)"),
    ("C-c C-k",       "Load / reload buffer"),
    ("C-c C-z",       "Switch to REPL"),
    ("C-c C-b",       "Interrupt eval"),
    ("C-c C-q",       "Quit connection"),
    ("M-. / M-,",     "Jump to def / back"),
    (None, "Docs (C-c C-d …)"),
    ("C-c C-d d",     "Symbol docs"),
    ("C-c C-d j",     "Javadoc"),
    ("C-c C-d a",     "Apropos"),
    (None, "Tests (C-c C-t …)"),
    ("C-c C-t t",     "Test at point"),
    ("C-c C-t n",     "Tests in ns"),
    ("C-c C-t p",     "All project tests"),
    ("C-c C-t b",     "Show test report"),
    (None, "Debug / macro"),
    ("C-u C-M-x",     "Debug next form"),
    ("C-c C-m",       "Macroexpand-1"),
    ("C-c M-m",       "Macroexpand menu"),
    ("C-c M-i",       "Inspect value"),
    (None, "Namespaces (C-c M-n …)"),
    ("C-c M-n n",     "Set namespace"),
    ("C-c M-n r",     "Refresh (tools.namespace)"),
    ("C-c M-n b",     "Browse namespace"),
    (None, "clojure-lsp"),
    ("C-c c a",       "Code actions"),
    ("C-c c r",       "Rename"),
]

RACKET = [
    (None, "racket-mode (.rkt)"),
    ("C-c C-c / C-k", "Run module at point"),
    ("C-x C-e",       "Send last sexp"),
    ("C-M-x",         "Send definition"),
    ("C-c C-r",       "Send region"),
    ("C-c C-z",       "Switch to REPL"),
    ("C-c C-t",       "Run test submodule"),
    ("C-c C-o",       "Profile"),
    ("C-c C-p",       "Cycle paren shapes"),
    ("C-M-y",         "Insert lambda"),
    (None, "Expand (C-c C-e …)"),
    ("C-c C-e r",     "Expand region"),
    ("C-c C-e e",     "Expand last sexp"),
    ("C-c C-e x",     "Expand definition"),
    ("C-c C-e f",     "Expand file (stepper)"),
    (None, "racket-xp-mode (analysis)"),
    ("M-.",           "Jump to definition"),
    ("C-c C-d",       "Documentation"),
    ("C-c C-.",       "Describe symbol"),
    ("C-c # r",       "Rename"),
    ("C-c # ?",       "Find references"),
    ("C-c # n / p",   "Next / prev use"),
    ("C-c # j / k",   "Next / prev definition"),
    ("C-c # N / P",   "Next / prev error"),
    ("C-c # g",       "Re-annotate buffer"),
    (None, "REPL"),
    ("C-c C-c",       "Break computation"),
    ("C-c C-\\",      "Exit REPL"),
    ("C-c C-z",       "Back to source"),
]

HY = [
    (None, "hy-mode (.hy)"),
    ("C-c C-z",       "Start / switch to REPL"),
    ("C-c C-e",       "Send last sexp"),
    ("C-M-x",         "Send current form"),
    ("C-c C-r",       "Send region"),
    ("C-c C-b",       "Send buffer"),
    ("C-c C-d d",     "Describe at point"),
    ("C-c C-t",       "Insert breakpoint()"),
    (None, "Not bound by default"),
    ("C-x C-e",       "→ add via config.el"),
    ("C-c C-c",       "→ not defined"),
    (None, "Venv (uv + direnv)"),
    ("M-x pyvenv-activate", "Switch venv in Emacs"),
    ("direnv allow",  "Auto-activate on cd"),
]

STRUCTURAL = [
    (None, "Smartparens / paredit"),
    ("C-)",           "Slurp right"),
    ("C-}",           "Barf right"),
    ("C-(",           "Slurp left"),
    ("C-{",           "Barf left"),
    ("M-(",           "Wrap in parens"),
    ("M-s",           "Splice sexp"),
    ("M-r",           "Raise sexp"),
    ("M-\"",          "Wrap in double quotes"),
    ("C-M-t",         "Transpose sexps"),
    ("C-M-f / C-M-b", "Forward / back sexp"),
    ("C-M-d / C-M-u", "Down / up list"),
    ("C-M-k",         "Kill sexp"),
    ("C-M-SPC",       "Mark sexp"),
    (None, "Lispy (:editor lispy)"),
    ("",              "active when point is on a paren"),
    ("j / k",         "Next / prev sexp"),
    ("f / b",         "Forward / back into sexp"),
    ("d",             "Other end of sexp"),
    ("> / <",         "Slurp / barf"),
    ("w / s",         "Move sexp up / down"),
    ("e",             "Eval sexp"),
    ("m",             "Mark sexp"),
    ("c",             "Clone sexp"),
    ("r",             "Raise sexp"),
    ("x",             "Transform menu (lispy-x)"),
    ("q",             "Ace-jump to paren"),
    ("i",             "Insert inside sexp"),
]

DOOM = [
    (None, "General (leader = C-c)"),
    ("M-x",           "Command palette"),
    ("C-c p f",       "Find file in project"),
    ("C-c b b",       "Switch buffer"),
    ("C-c o t",       "Terminal (vterm)"),
    ("C-c g g",       "Magit status"),
    ("C-c t l",       "Toggle line numbers"),
    ("C-c c d",       "Jump to definition"),
    ("C-c c k",       "Docs at point"),
    ("C-c c a / r",   "LSP action / rename"),
    ("C-h k",         "Describe key"),
    ("C-h m",         "Mode bindings"),
    ("C-c",           "which-key: wait"),
    (None, "REPL launcher (C-c r …)"),
    ("s",             "Start SBCL"),
    ("w",             "Connect LispWorks :4005"),
    ("C",             "sly-connect (prompt)"),
    ("c / j",         "CIDER Clojure / cljs"),
    ("k",             "Run Racket buffer"),
    ("R",             "Geiser Racket REPL"),
    ("z",             "Geiser Chez REPL"),
    ("h",             "Hy REPL"),
    (None, "Unified grammar (C-c l …)"),
    ("'",             "REPL: start / switch"),
    ("e",             "Eval last sexp"),
    ("d",             "Eval defun"),
    ("r",             "Eval region"),
    ("b",             "Eval / load buffer"),
    ("f",             "Load file"),
    ("k",             "Docs for symbol"),
    ("m / M",         "Macroexpand-1 / all"),
    ("i",             "Inspect value"),
    ("t / T",         "Test / trace-debug"),
    ("c",             "Compile defun"),
    ("R",             "Restart REPL"),
    ("!",             "Interrupt"),
]


# ─── Page assembly ─────────────────────────────────────────────────────────
def make_col(title, subtitle, table):
    return [
        Paragraph(title, SECTION),
        Paragraph(subtitle, SUBHEAD),
        table,
    ]


def build_pdf(out_path):
    W, H = landscape(letter)  # 11 x 8.5 in
    margin = 0.30 * inch
    gutter = 0.14 * inch
    n_cols = 4
    col_w = (W - 2 * margin - (n_cols - 1) * gutter) / n_cols
    body_h = H - 2 * margin - 0.45 * inch  # leave room for title strip

    doc = BaseDocTemplate(
        out_path,
        pagesize=landscape(letter),
        leftMargin=margin, rightMargin=margin,
        topMargin=margin, bottomMargin=margin,
        title="Lisp keybindings — Doom Emacs (terminal)",
        author="Perplexity Computer",
    )

    def draw_header(canv, doc_):
        canv.saveState()
        # Title strip
        canv.setFillColor(INK)
        canv.setFont("DM-Bold", 12)
        canv.drawString(margin, H - margin - 8, "Lisp keybindings — Doom Emacs (terminal)")
        canv.setFillColor(MUTED)
        canv.setFont("DM", 7)
        canv.drawString(
            margin, H - margin - 20,
            "SLY · Geiser · CIDER · racket-mode · hy-mode   ·   "
            "vanilla Emacs keys, no evil      Verified 2026-09-17",
        )
        canv.setFont("DM", 7)
        page_label = f"Page {doc_.page} of 2"
        canv.drawRightString(W - margin, H - margin - 8, page_label)
        # Rule under title
        canv.setStrokeColor(RULE)
        canv.setLineWidth(0.5)
        canv.line(margin, H - margin - 26, W - margin, H - margin - 26)
        canv.restoreState()

    # Two frames per page = four column frames; but we want ONE big frame that
    # flows into all four columns. Use a MultiColumn approach via 4 frames.
    frames = []
    for i in range(n_cols):
        x = margin + i * (col_w + gutter)
        y = margin
        frames.append(
            Frame(
                x, y, col_w, body_h,
                leftPadding=0, rightPadding=0,
                topPadding=0, bottomPadding=0,
                showBoundary=0,
            )
        )
    doc.addPageTemplates([
        PageTemplate(id="grid", frames=frames, onPage=draw_header),
    ])

    # Column widths for tables: (key, desc) inside each column
    # col_w is ~2.6". Use 1.05 / 1.5.
    key_w = 1.08 * inch
    desc_w = col_w - key_w - 4  # tiny slack

    story = []

    # Page 1 columns
    story += make_col(
        "Common Lisp — SLY",
        "sbcl (inferior) + LispWorks (slynk:4005)",
        kb_table(SLY, key_w, desc_w),
    )
    story.append(Spacer(1, 0.02 * inch))
    story += make_col(
        "Scheme — Geiser",
        "Chez (default) + Racket",
        kb_table(GEISER, key_w, desc_w),
    )
    # FrameBreak isn't needed — frames auto-flow when column full.
    story += make_col(
        "Clojure — CIDER",
        "cider-mode + clojure-lsp",
        kb_table(CIDER, key_w, desc_w),
    )
    story += make_col(
        "Racket — racket-mode",
        "racket-xp-mode enabled",
        kb_table(RACKET, key_w, desc_w),
    )

    # Force page 2
    from reportlab.platypus import PageBreak
    story.append(PageBreak())

    # Page 2 columns
    story += make_col(
        "Hy — hy-mode",
        "Python-hosted; needs uv venv + direnv",
        kb_table(HY, key_w, desc_w),
    )
    story += make_col(
        "Structural editing",
        "Works in every Lisp buffer",
        kb_table(STRUCTURAL, key_w, desc_w),
    )
    story += make_col(
        "Doom keys (non-evil)",
        "leader C-c  ·  localleader C-c l",
        kb_table(DOOM, key_w, desc_w),
    )

    # Fourth column on page 2: legend / notes
    from reportlab.platypus import KeepInFrame
    legend = [
        Paragraph("Legend & tips", SECTION),
        Paragraph("How to read this card", SUBHEAD),
        Paragraph(
            "<b>C-</b> is Control, <b>M-</b> is Meta (Option in iTerm2 with Left "
            "Option = Esc+). This config runs <b>without evil</b>, so Doom's leader "
            "is <b>C-c</b> and its localleader is <b>C-c l</b>. Sequences like "
            "<b>C-c C-d C-d</b> are three keystrokes in a row.",
            ParagraphStyle("body", fontName="DM", fontSize=6.6, leading=8.2, textColor=INK),
        ),
        Spacer(1, 4),
        Paragraph("Prefix maps", SUBHEAD),
        Paragraph(
            "CIDER groups commands under prefixes: "
            "<b>C-c C-d</b> docs, <b>C-c C-v</b> eval, <b>C-c C-t</b> tests, "
            "<b>C-c M-n</b> namespaces, <b>C-c M-m</b> macroexpand, "
            "<b>C-c C-j</b> insert-in-REPL. Wait after the prefix; which-key "
            "will show the suffixes.",
            ParagraphStyle("body", fontName="DM", fontSize=6.6, leading=8.2, textColor=INK),
        ),
        Spacer(1, 4),
        Paragraph("REPL comma-commands", SUBHEAD),
        Paragraph(
            "SLY, Chez, Racket, and Guile all accept comma commands at the "
            "REPL prompt. Type <b>,help</b> in any of them for the full list "
            "supported by that implementation. Handy defaults: "
            "<b>,in-package</b> / <b>,cd</b> / <b>,quit</b> (SLY); "
            "<b>,enter</b> (Racket); <b>,inspect</b> / <b>,cd</b> (Chez).",
            ParagraphStyle("body", fontName="DM", fontSize=6.6, leading=8.2, textColor=INK),
        ),
        Spacer(1, 4),
        Paragraph("If a key doesn't work", SUBHEAD),
        Paragraph(
            "1. <b>C-h k</b> then press the key — Emacs reports what it runs.<br/>"
            "2. <b>C-h m</b> lists every binding for the current major mode.<br/>"
            "3. <b>C-h b</b> lists every active binding.<br/>"
            "4. Check the mode line for minor modes; <b>racket-xp-mode</b>, "
            "<b>lispy-mode</b>, and <b>lsp-mode</b> all add bindings.<br/>"
            "5. <b>map!</b> forms scoped to evil states (<b>:n :i :v</b>) are "
            "silently ignored without <b>:editor evil</b>.",
            ParagraphStyle("body", fontName="DM", fontSize=6.6, leading=8.2, textColor=INK),
        ),
        Spacer(1, 4),
        Paragraph("Sources verified", SUBHEAD),
        Paragraph(
            "SLY 1.0.42 manual · Geiser manual (nongnu ELPA) · "
            "CIDER keybindings reference · racket-mode multi-back-end-index · "
            "hylang/hy-mode source (master).",
            ParagraphStyle("body", fontName="DM", fontSize=6.2, leading=7.6, textColor=MUTED),
        ),
    ]
    for f in legend:
        story.append(f)

    doc.build(story)


if __name__ == "__main__":
    out = "/home/user/workspace/cheatsheet/lisp-keybindings.pdf"
    build_pdf(out)
    print("Wrote", out)
