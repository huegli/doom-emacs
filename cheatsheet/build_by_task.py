"""
Task-oriented Lisp keybinding cheat sheet — Doom Emacs (terminal).

One row = one action. Six columns:
    Task | SLY (CL) | Geiser (Scheme) | CIDER (Clojure) | racket-mode | hy-mode

US Letter landscape, two pages. Verified 2026-09-17 against upstream docs.
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
    PageBreak,
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

# ─── Palette ───────────────────────────────────────────────────────────────
BG      = HexColor("#F7F6F2")
INK     = HexColor("#28251D")
MUTED   = HexColor("#7A7974")
FAINT   = HexColor("#BAB9B4")
RULE    = HexColor("#D4D1CA")
ACCENT  = HexColor("#01696F")
HEAD_BG = HexColor("#EDEAE2")
ROW_ALT = HexColor("#FBFBF9")


# Column headers — the five Lisps
LISPS = ["SLY", "Geiser", "CIDER", "racket-mode", "hy-mode"]
NA = "—"  # em-dash for "not applicable / not bound"

# ─── The matrix ────────────────────────────────────────────────────────────
# Each entry is (section_label_or_None, task, sly, geiser, cider, racket, hy)
# section rows use (label, None, None, None, None, None, None)

MATRIX = [
    # ─── Section: Start / connect ─────────────────────────────────────────
    ("Start / connect a REPL", None, None, None, None, None, None),
    ("Start (inferior process)",
        "M-x sly (SBCL)", "M-x geiser-chez", "C-c M-j (jack-in)",
        "C-c C-c (run)", "C-c C-z (run-hy)"),
    ("Connect to running REPL",
        "C-c r w (LispWorks :4005)", NA, "C-c M-c (cider-connect)",
        NA, NA),
    ("Switch to REPL buffer",
        "C-c C-z", "C-c C-z", "C-c C-z", "C-c C-z", "C-c C-z"),
    ("Switch REPL & enter module",
        NA, "C-c C-a", "C-c M-n M-s (set-ns)", NA, NA),
    ("Quit / disconnect",
        ", quit  (REPL)", NA, "C-c C-q", "C-c C-\\  (REPL)", NA),

    # ─── Section: Eval ────────────────────────────────────────────────────
    ("Eval", None, None, None, None, None, None),
    ("Eval last sexp",
        "C-x C-e", "C-x C-e", "C-x C-e  (C-c C-e)",
        "C-x C-e", "C-c C-e   *"),
    ("Eval defun / top-level form",
        "C-M-x", "C-M-x  (C-c C-c)", "C-c C-c  (C-M-x)",
        "C-M-x", "C-M-x"),
    ("Eval region",
        "C-c C-r", "C-c C-r", "C-c C-v r", "C-c C-r", "C-c C-r"),
    ("Eval / load buffer",
        "C-c C-k (compile+load)", "C-c C-b", "C-c C-k",
        "C-c C-c / C-c C-k", "C-c C-b"),
    ("Load file from disk",
        "C-c C-l", "C-c C-l", "C-c C-k (buffer)",
        NA, NA),
    ("Eval + pretty-print",
        "C-c C-p", NA, "C-c C-v p", NA, NA),
    ("Eval + switch to REPL",
        NA, "C-c M-e  /  M-r  /  M-b", NA, NA, NA),
    ("Interrupt evaluation",
        "C-c C-b", NA, "C-c C-b", "C-c C-c (REPL)", NA),

    # ─── Section: Navigate ────────────────────────────────────────────────
    ("Navigate", None, None, None, None, None, None),
    ("Jump to definition",
        "M-.", "M-.", "M-.", "M-.", "M-."),
    ("Pop definition stack",
        "M-,", "M-,", "M-,", "M-,", "M-,"),
    ("Find references",
        "M-?", NA, "M-?  (via lsp)", "C-c # ?", NA),
    ("Next / previous compile note",
        "M-n  /  M-p", NA, "C-c M-p n / p", NA, NA),
    ("Next / previous use (xp)",
        NA, NA, NA, "C-c # n  /  # p", NA),
    ("Next / previous error (xp)",
        NA, NA, NA, "C-c # N  /  # P", NA),
    ("List callers / callees",
        "C-c <  /  C-c >", "C-c <  /  C-c >", NA, NA, NA),

    # ─── Section: Docs ────────────────────────────────────────────────────
    ("Documentation", None, None, None, None, None, None),
    ("Symbol docs / describe",
        "C-c C-d C-d", "C-c C-d C-d", "C-c C-d d", "C-c C-.", "C-c C-d d"),
    ("Documentation search / lookup",
        "C-c C-d C-h  (HyperSpec)", "C-c C-d C-m  (module)", "C-c C-d j (Javadoc)",
        "C-c C-d", NA),
    ("Apropos",
        "C-c C-d C-a", NA, "C-c C-d a", NA, NA),
    ("Describe function",
        "C-c C-d C-f", NA, "C-c C-d f", NA, NA),

    # ─── Section: Macros ──────────────────────────────────────────────────
    ("Macro expansion", None, None, None, None, None, None),
    ("Macroexpand-1",
        "C-c C-m", "C-c C-m C-e", "C-c C-m", "C-c C-e e", NA),
    ("Macroexpand all",
        "C-c M-m", "C-c C-m C-x  (defn)", "C-c M-m a",
        "C-c C-e x  (defn)", NA),
    ("Macroexpand region",
        NA, "C-c C-m C-r", NA, "C-c C-e r", NA),
    ("Macro stepper / debugger",
        NA, NA, "C-u C-M-x  (debug)", "C-c C-e f (file)", NA),
]

MATRIX_P2 = [
    # ─── Section: Compile / test / analyze ────────────────────────────────
    ("Compile · test · analyze", None, None, None, None, None, None),
    ("Compile defun",
        "C-c C-c", NA, NA, NA, NA),
    ("Compile file (no load)",
        "C-c M-k", NA, NA, NA, NA),
    ("Run test at point",
        NA, NA, "C-c C-t t", "C-c C-t (submod)", NA),
    ("Run tests in ns / project",
        NA, NA, "C-c C-t n  /  p", NA, NA),
    ("Show test report",
        NA, NA, "C-c C-t b", NA, NA),
    ("Inspect value",
        "C-c I", NA, "C-c M-i", NA, NA),
    ("Trace at point",
        "C-c C-t", NA, "C-c M-t v (var)", NA, NA),
    ("Disassemble / profile",
        "C-c M-d (disas)", NA, "C-c C-= (profile menu)",
        "C-c C-o (profile)", NA),
    ("Debug next form",
        NA, NA, "C-u C-M-x  (C-u C-c C-c)", NA,
        "C-c C-t (breakpoint)"),
    ("Insert breakpoint / pdb",
        NA, NA, NA, NA, "C-c C-t"),

    # ─── Section: REPL ────────────────────────────────────────────────────
    ("REPL buffer", None, None, None, None, None, None),
    ("History previous / next",
        "M-p  /  M-n", NA, "M-p  /  M-n", NA, NA),
    ("Isearch history",
        "C-r", NA, "C-r", NA, NA),
    ("Clear recent output",
        "C-c C-o", "C-c M-o (all)", NA, NA, NA),
    ("Clear entire REPL",
        "C-c M-o", "C-c M-o", "C-c M-o", NA, NA),
    ("Sync REPL package / dir",
        "C-c ~", NA, NA, NA, NA),
    ("Set current module / ns",
        ", in-package (comma)", "C-c C-m", "C-c M-n n",
        NA, NA),
    ("Comma commands at prompt",
        ", in-package  ,cd  ,quit", ",help  (Chez/Racket)",
        NA, ", enter", NA),

    # ─── Section: Namespaces / modules ────────────────────────────────────
    ("Namespaces / modules", None, None, None, None, None, None),
    ("Refresh (tools.namespace)",
        NA, NA, "C-c M-n r", NA, NA),
    ("Browse namespace",
        NA, NA, "C-c M-n b", NA, NA),
    ("Edit / open module",
        NA, "C-c C-e C-m", NA, "C-c C-x C-f (require path)",
        NA),
    ("Import module (into REPL)",
        NA, "C-c C-i  (REPL)", NA, NA, NA),

    # ─── Section: Editing / structural ────────────────────────────────────
    ("Editing", None, None, None, None, None, None),
    ("Slurp / barf right",
        "C-)  /  C-}", "C-)  /  C-}", "C-)  /  C-}",
        "C-)  /  C-}", "C-)  /  C-}"),
    ("Slurp / barf left",
        "C-(  /  C-{", "C-(  /  C-{", "C-(  /  C-{",
        "C-(  /  C-{", "C-(  /  C-{"),
    ("Wrap in parens / string",
        "M-(  /  M-\"", "M-(  /  M-\"", "M-(  /  M-\"",
        "M-(  /  M-\"", "M-(  /  M-\""),
    ("Splice / raise sexp",
        "M-s  /  M-r", "M-s  /  M-r", "M-s  /  M-r",
        "M-s  /  M-r", "M-s  /  M-r"),
    ("Toggle ( ) <-> [ ]",
        NA, "C-c C-e C-[", NA, "C-c C-p (cycle)", NA),
    ("Insert lambda glyph",
        NA, "C-c C-\\", NA, "C-M-y", NA),
    ("Rename symbol",
        NA, NA, "C-c c r  (lsp)", "C-c # r  (xp)", "C-c c r"),
    ("Code actions",
        NA, NA, "C-c c a", NA, "C-c c a"),
]


# ─── Styles ────────────────────────────────────────────────────────────────
TITLE = ParagraphStyle(
    "Title", fontName="DM-Bold", fontSize=13, leading=14, textColor=INK,
)
FOOT = ParagraphStyle(
    "Foot", fontName="DM", fontSize=6.4, leading=8, textColor=MUTED,
)
NOTE_H = ParagraphStyle(
    "NH", fontName="DM-Bold", fontSize=7.5, leading=9, textColor=ACCENT,
    spaceBefore=4, spaceAfter=1,
)
NOTE_B = ParagraphStyle(
    "NB", fontName="DM", fontSize=6.8, leading=8.4, textColor=INK,
)


def key_para(text):
    """Wrap a key binding in a mono paragraph so long ones can wrap."""
    if text == NA:
        return Paragraph(
            f'<font color="#BAB9B4">{NA}</font>',
            ParagraphStyle("na", fontName="DM", fontSize=6.4, alignment=1, leading=8),
        )
    return Paragraph(
        text.replace(" ", "&nbsp;"),
        ParagraphStyle("k", fontName="Mono", fontSize=5.8, leading=7.4, textColor=INK),
    )


def task_para(text):
    return Paragraph(
        text,
        ParagraphStyle("t", fontName="DM-Med", fontSize=6.6, leading=8, textColor=INK),
    )


def section_para(text):
    return Paragraph(
        text,
        ParagraphStyle("s", fontName="DM-Bold", fontSize=7.4, leading=9, textColor=ACCENT),
    )


def build_matrix_table(rows, col_widths):
    """Build the six-column task matrix table.

    rows: list of tuples (task, sly, geiser, cider, racket, hy).
    Sub-header rows have task set and all key cells None.
    """
    data = [[
        Paragraph(
            "Task",
            ParagraphStyle("h", fontName="DM-Bold", fontSize=7, textColor=BG,
                           alignment=0, leading=8),
        ),
    ] + [
        Paragraph(
            f"<b>{name}</b>",
            ParagraphStyle("h", fontName="DM-Bold", fontSize=7, textColor=BG,
                           alignment=0, leading=8),
        )
        for name in LISPS
    ]]

    styles = [
        # Header
        ("BACKGROUND",   (0, 0), (-1, 0), ACCENT),
        ("TEXTCOLOR",    (0, 0), (-1, 0), BG),
        ("TOPPADDING",   (0, 0), (-1, 0), 4),
        ("BOTTOMPADDING",(0, 0), (-1, 0), 4),
        ("LEFTPADDING",  (0, 0), (-1, -1), 4),
        ("RIGHTPADDING", (0, 0), (-1, -1), 4),
        ("VALIGN",       (0, 0), (-1, -1), "MIDDLE"),
        # Body defaults
        ("TOPPADDING",   (0, 1), (-1, -1), 1.4),
        ("BOTTOMPADDING",(0, 1), (-1, -1), 1.4),
        ("LINEBELOW",    (0, 0), (-1, -2), 0.2, RULE),
    ]

    for i, row in enumerate(rows, start=1):
        task, *keys = row
        if all(k is None for k in keys):
            # Section header row
            data.append([section_para(task), "", "", "", "", ""])
            styles.append(("SPAN",       (0, i), (-1, i)))
            styles.append(("BACKGROUND", (0, i), (-1, i), HEAD_BG))
            styles.append(("TOPPADDING", (0, i), (-1, i), 5))
            styles.append(("BOTTOMPADDING",(0, i), (-1, i), 3))
            styles.append(("LEFTPADDING",(0, i), (-1, i), 6))
        else:
            row_cells = [task_para(task)] + [key_para(k) for k in keys]
            data.append(row_cells)
            # Alternate row shading for readability
            if i % 2 == 0:
                styles.append(("BACKGROUND", (0, i), (-1, i), ROW_ALT))

    tbl = Table(data, colWidths=col_widths, repeatRows=1)
    tbl.setStyle(TableStyle(styles))
    return tbl


def build_pdf(out_path):
    W, H = landscape(letter)  # 11 x 8.5 in
    margin = 0.30 * inch
    body_top = H - margin - 0.42 * inch  # room for title strip

    doc = BaseDocTemplate(
        out_path,
        pagesize=landscape(letter),
        leftMargin=margin, rightMargin=margin,
        topMargin=margin, bottomMargin=margin,
        title="Lisp keybindings by task — Doom Emacs",
        author="Perplexity Computer",
    )

    def draw_header(canv, doc_):
        canv.saveState()
        canv.setFillColor(INK)
        canv.setFont("DM-Bold", 12)
        canv.drawString(margin, H - margin - 8,
                        "Lisp keybindings by task — Doom Emacs (terminal)")
        canv.setFillColor(MUTED)
        canv.setFont("DM", 7)
        canv.drawString(
            margin, H - margin - 20,
            "One row per action across SLY · Geiser · CIDER · racket-mode · hy-mode   ·   "
            "vanilla Emacs keys, no evil      Verified 2026-09-17",
        )
        canv.setFont("DM", 7)
        canv.drawRightString(W - margin, H - margin - 8,
                             f"Page {doc_.page} of 2")
        canv.setStrokeColor(RULE)
        canv.setLineWidth(0.5)
        canv.line(margin, H - margin - 26, W - margin, H - margin - 26)
        canv.restoreState()

    # Single wide frame for the matrix
    frame_full = Frame(
        margin, margin, W - 2 * margin, body_top - margin,
        leftPadding=0, rightPadding=0, topPadding=0, bottomPadding=0,
        showBoundary=0,
    )
    doc.addPageTemplates([
        PageTemplate(id="wide", frames=[frame_full], onPage=draw_header),
    ])

    # Column widths (task column wider; five key columns equal)
    total_w = W - 2 * margin
    task_col = 1.65 * inch
    lisp_col = (total_w - task_col) / 5
    col_widths = [task_col] + [lisp_col] * 5

    story = []
    story.append(build_matrix_table(MATRIX, col_widths))
    story.append(PageBreak())
    story.append(build_matrix_table(MATRIX_P2, col_widths))

    # Footer notes on page 2
    story.append(Spacer(1, 0.10 * inch))
    story.append(Paragraph(
        "Unified layer \u2014 identical keys in every mode above", NOTE_H))
    story.append(Paragraph(
        "<font face='Mono'>unify-lisp-keys.el</font> puts one grammar on Doom's "
        "localleader, working the same in Common Lisp, Scheme, Clojure, Racket, Hy, "
        "and Emacs Lisp: "
        "<font face='Mono'><b>C-c l</b></font> then "
        "<font face='Mono'><b>'</b></font> REPL \u00b7 "
        "<font face='Mono'><b>e</b></font> eval sexp \u00b7 "
        "<font face='Mono'><b>d</b></font> defun \u00b7 "
        "<font face='Mono'><b>r</b></font> region \u00b7 "
        "<font face='Mono'><b>b</b></font> buffer \u00b7 "
        "<font face='Mono'><b>f</b></font> load file \u00b7 "
        "<font face='Mono'><b>k</b></font> docs \u00b7 "
        "<font face='Mono'><b>m</b></font>/<font face='Mono'><b>M</b></font> macroexpand \u00b7 "
        "<font face='Mono'><b>i</b></font> inspect \u00b7 "
        "<font face='Mono'><b>t</b></font>/<font face='Mono'><b>T</b></font> test/trace \u00b7 "
        "<font face='Mono'><b>c</b></font> compile \u00b7 "
        "<font face='Mono'><b>R</b></font> restart \u00b7 "
        "<font face='Mono'><b>!</b></font> interrupt. "
        "Unbound slots are omitted \u2014 press <font face='Mono'>C-c l</font> and wait.",
        NOTE_B))
    story.append(Spacer(1, 0.06 * inch))
    story.append(Paragraph("Notes", NOTE_H))
    story.append(Paragraph(
        "<b>No evil.</b> Doom's leader is <b>C-c</b>, localleader <b>C-c l</b>. The "
        "evil-only keys <b>gd</b>/<b>gD</b>/<b>K</b> do not exist here: docs-at-point is "
        "<b>C-c c k</b>, jump-to-definition <b>C-c c d</b> or <b>M-.</b>. Global REPL "
        "launcher is <b>C-c r</b>. The unified layer sits on the localleader precisely "
        "because it cannot collide with any mode's own <b>C-c C-x</b> style bindings.",
        NOTE_B))
    story.append(Paragraph(
        "<b>Em-dash (\u2014)</b> means that mode does not bind the action by default. Many "
        "gaps are still reachable via <b>M-x</b> \u2014 e.g. <b>sly-untrace-all</b>, "
        "<b>racket-profile</b>, <b>cider-macroexpand-all</b>.",
        NOTE_B))
    story.append(Paragraph(
        "<b>* hy-mode:</b> does not bind <b>C-x C-e</b>; its eval-last-sexp is "
        "<b>C-c C-e</b>. <font face='Mono'>unify-lisp-keys.el</font> adds "
        "<b>C-x C-e</b> to match the other four. <b>Prefix maps:</b> CIDER groups "
        "commands under <b>C-c C-d</b>, <b>C-c C-v</b>, <b>C-c C-t</b>, <b>C-c M-n</b>, "
        "and <b>C-c M-m</b> \u2014 press the prefix and wait for which-key.",
        NOTE_B))
    story.append(Paragraph(
        "<b>Sources.</b> SLY 1.0.42 manual \u00b7 Geiser manual (nongnu ELPA) \u00b7 "
        "CIDER keybindings reference \u00b7 racket-mode multi-back-end-index \u00b7 "
        "hylang/hy-mode source \u00b7 Doom Emacs docs (leader keys, :editor evil).",
        NOTE_B))

    doc.build(story)


if __name__ == "__main__":
    out = "/home/user/workspace/cheatsheet/lisp-keybindings-by-task.pdf"
    build_pdf(out)
    print("Wrote", out)
