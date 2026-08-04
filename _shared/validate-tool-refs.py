#!/usr/bin/env python3
"""
Validate every MCP tool the skills reference against what the two servers actually register.

Catches the drift class that bit us repeatedly: a skill naming a tool that does not exist,
a tool attributed to the wrong server, or a shipped tool no skill ever uses.

Usage:
  python3 _shared/validate-tool-refs.py [--spider <server.ts>] [--platform <McpToolRegistrar.java>]

Exit 1 on any unknown or misattributed reference, so it can gate a release.
"""
import argparse, pathlib, re, sys

REPO = pathlib.Path(__file__).resolve().parent.parent
DEFAULT_SPIDER = REPO.parent / "digispot-ai-spider/mcp/server.ts"
DEFAULT_PLATFORM = REPO.parent / "digispot-server/src/main/java/com/digispot/mcp/McpToolRegistrar.java"

# Names that look like tools in prose but are not MCP tools.
NOT_TOOLS = {
    "get_page_text", "run_workflow_image", "get_started",
    "digispot_",  # prose: "every tool starts with `digispot_`"
}


def spider_tools(path: pathlib.Path) -> set[str]:
    """server.tool('name', ...) registrations."""
    if not path.exists():
        return set()
    return set(re.findall(r"server\.tool\(\s*'([a-z0-9_]+)'", path.read_text()))


def platform_tools(path: pathlib.Path) -> set[str]:
    """registerTool("digispot_name", ...) registrations."""
    if not path.exists():
        return set()
    return set(re.findall(r'registerTool\(\s*"(digispot_[a-z0-9_]+)"', path.read_text()))


def skill_files() -> list[pathlib.Path]:
    files = sorted((REPO / "skills").glob("*/SKILL.md"))
    files += [REPO / "_shared/seo-mcp-foundations.md", REPO / "_shared/AGENTS-template.md"]
    files += [REPO / "README.md"]
    return [f for f in files if f.exists()]


def referenced(path: pathlib.Path) -> set[str]:
    """Tool-ish identifiers inside backticks — the convention these docs use for tool names."""
    text = path.read_text()
    names = set()
    for tok in re.findall(r"`([a-z0-9_]+)`", text):
        if tok in NOT_TOOLS:
            continue
        if tok.startswith("digispot_"):
            names.add(tok)
        elif re.match(r"^(get|list|start|stop|pause|resume|wait_for|run|compare|activate|propose|download)_[a-z0-9_]+$", tok):
            names.add(tok)
    return names


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--spider", type=pathlib.Path, default=DEFAULT_SPIDER)
    ap.add_argument("--platform", type=pathlib.Path, default=DEFAULT_PLATFORM)
    args = ap.parse_args()

    spider = spider_tools(args.spider)
    platform = platform_tools(args.platform)
    if not spider or not platform:
        print(f"! could not read registrars (spider={len(spider)} platform={len(platform)}) — "
              f"check --spider/--platform paths", file=sys.stderr)
        return 2
    known = spider | platform
    print(f"registrars: spider={len(spider)} platform={len(platform)}\n")

    unknown: dict[str, set[str]] = {}
    used: set[str] = set()
    for f in skill_files():
        refs = referenced(f)
        used |= refs & known
        bad = refs - known
        if bad:
            unknown[str(f.relative_to(REPO))] = bad

    failed = False
    if unknown:
        failed = True
        print("UNKNOWN TOOL REFERENCES (not registered by either server):")
        for f, names in sorted(unknown.items()):
            for n in sorted(names):
                print(f"  {f}: {n}")
        print()
    else:
        print("✓ every referenced tool is registered by one of the servers\n")

    # A platform tool written without its digispot_ prefix is the likeliest misattribution.
    stripped = {t[len("digispot_"):] for t in platform}
    for f in skill_files():
        for n in referenced(f) - known:
            if n in stripped:
                print(f"  ^ '{n}' looks like platform '{'digispot_' + n}' missing its prefix")

    unused_p = sorted(platform - used)
    unused_s = sorted(spider - used)
    print(f"coverage: platform {len(platform)-len(unused_p)}/{len(platform)} referenced, "
          f"spider {len(spider)-len(unused_s)}/{len(spider)} referenced")
    if unused_p:
        print("  platform tools no skill mentions:")
        for t in unused_p:
            print(f"    {t}")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
