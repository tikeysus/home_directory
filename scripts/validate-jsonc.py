#!/usr/bin/env python3
import json
import sys
from pathlib import Path


def strip_jsonc(text):
    output = []
    i = 0
    in_string = False
    escape = False
    length = len(text)

    while i < length:
        char = text[i]
        nxt = text[i + 1] if i + 1 < length else ""

        if in_string:
            output.append(char)
            if escape:
                escape = False
            elif char == "\\":
                escape = True
            elif char == '"':
                in_string = False
            i += 1
            continue

        if char == '"':
            in_string = True
            output.append(char)
            i += 1
            continue

        if char == "/" and nxt == "/":
            i += 2
            while i < length and text[i] not in "\r\n":
                i += 1
            continue

        if char == "/" and nxt == "*":
            i += 2
            while i + 1 < length and not (text[i] == "*" and text[i + 1] == "/"):
                i += 1
            i += 2
            continue

        output.append(char)
        i += 1

    return "".join(output)


def remove_trailing_commas(text):
    output = []
    i = 0
    in_string = False
    escape = False
    length = len(text)

    while i < length:
        char = text[i]

        if in_string:
            output.append(char)
            if escape:
                escape = False
            elif char == "\\":
                escape = True
            elif char == '"':
                in_string = False
            i += 1
            continue

        if char == '"':
            in_string = True
            output.append(char)
            i += 1
            continue

        if char == ",":
            j = i + 1
            while j < length and text[j].isspace():
                j += 1
            if j < length and text[j] in "]}":
                i += 1
                continue

        output.append(char)
        i += 1

    return "".join(output)


def main():
    if len(sys.argv) < 2:
        print("Usage: validate-jsonc.py FILE [...]", file=sys.stderr)
        return 1

    failed = False
    for filename in sys.argv[1:]:
        path = Path(filename)
        try:
            text = path.read_text()
            json.loads(remove_trailing_commas(strip_jsonc(text)))
        except Exception as exc:
            print(f"{path}: invalid JSONC: {exc}", file=sys.stderr)
            failed = True
        else:
            print(f"{path}: OK")

    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
