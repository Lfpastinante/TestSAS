#!/usr/bin/env python3
"""
Robust PDF text extractor with multiple backends.

Usage:
  python extract_pdf.py INPUT_PDF OUTPUT_TXT

Attempts these libraries in order:
  - pypdf (modern fork of PyPDF2)
  - PyPDF2
  - pdfminer.six

Writes UTF-8 text to the output file and prints which backend was used.
"""

from __future__ import annotations

import sys
from pathlib import Path
from typing import Optional


def extract_with_pypdf(input_path: Path) -> Optional[str]:
    try:
        import pypdf  # type: ignore
        reader = pypdf.PdfReader(str(input_path))
        pages_text = []
        for page in reader.pages:
            content = page.extract_text() or ""
            pages_text.append(content)
        return "\n".join(pages_text)
    except Exception:
        return None


def extract_with_pypdf2(input_path: Path) -> Optional[str]:
    try:
        import PyPDF2  # type: ignore
        reader = PyPDF2.PdfReader(str(input_path))
        pages_text = []
        for page in reader.pages:
            content = page.extract_text() or ""
            pages_text.append(content)
        return "\n".join(pages_text)
    except Exception:
        return None


def extract_with_pdfminer(input_path: Path) -> Optional[str]:
    try:
        from pdfminer.high_level import extract_text  # type: ignore
        return extract_text(str(input_path))
    except Exception:
        return None


def main() -> int:
    if len(sys.argv) < 3:
        print("Usage: python extract_pdf.py INPUT_PDF OUTPUT_TXT", file=sys.stderr)
        return 2

    input_pdf = Path(sys.argv[1]).expanduser().resolve()
    output_txt = Path(sys.argv[2]).expanduser().resolve()

    if not input_pdf.exists():
        print(f"Input PDF not found: {input_pdf}", file=sys.stderr)
        return 2

    text = extract_with_pypdf(input_pdf)
    if text is not None and text.strip():
        output_txt.write_text(text, encoding="utf-8")
        print("used:pypdf")
        return 0

    text = extract_with_pypdf2(input_pdf)
    if text is not None and text.strip():
        output_txt.write_text(text, encoding="utf-8")
        print("used:PyPDF2")
        return 0

    text = extract_with_pdfminer(input_pdf)
    if text is not None and text.strip():
        output_txt.write_text(text, encoding="utf-8")
        print("used:pdfminer")
        return 0

    print("Failed to extract text with available backends.", file=sys.stderr)
    return 1


if __name__ == "__main__":
    raise SystemExit(main())

