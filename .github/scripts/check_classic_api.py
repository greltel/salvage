#!/usr/bin/env python3
"""Checks that the ABAP sources use only SAP objects that SAP classifies as classic API.

SALVage promises to use only objects that SAP lists as classic API in the Cloudification
Repository (https://github.com/SAP/abap-atc-cr-cv-s4hc). abaplint cannot check this: it does not
know the SALV classes. This script reads the names of SAP classes, interfaces and function
modules from the sources and looks each one up:

  - objectClassifications_SAP.json   state "classicAPI" passes, "noAPI" fails
  - objectReleaseInfo_PCELatest.json state "released" passes (released APIs, e.g. CX_ROOT)
  - in neither file                  fails: SAP has not classified the object

Objects that SALVage never uses, whatever their classification, fail as well (FORBIDDEN below).
An object that is needed all the same goes into the exceptions file, with the file that may
use it and the reason.

What the script cannot see: objects that are reached without their name, for example the class
of the object a method chain returns, and types of the ABAP Dictionary, which the Cloudification
Repository does not list. Check those in ADT (API State) when you add a call.

Usage:
  check_classic_api.py --classifications objectClassifications_SAP.json \\
                       --released objectReleaseInfo_PCELatest.json src
"""

import argparse
import fnmatch
import json
import pathlib
import re
import sys

# Never used by SALVage: the grid behind SALV and the internals of SALV
FORBIDDEN = [
    re.compile(r"CL_GUI_ALV_GRID\w*"),
    re.compile(r"CL_SALV_\w*ADAPTER\w*"),
    re.compile(r"CL_SALV_CONTROLLER\w*"),
    re.compile(r"R_CONTROLLER"),
]

OBJECT_NAME = re.compile(r"(?<![\w/])((?:/\w+/)?(?:CL|IF|CX)_\w+)")
FORBIDDEN_TOKEN = re.compile(r"(?<![\w/])R_CONTROLLER\b")
FUNCTION_CALL = re.compile(r"CALL\s+FUNCTION\s+'([^']+)'", re.IGNORECASE)

DEFAULT_EXCEPTIONS = pathlib.Path(__file__).with_name("classic_api_exceptions.txt")


def code_of(line):
    """Returns the line without its comment and without the content of its literals.

    The expressions embedded in a string template, |...{ expression }...|, stay: they are code.
    """
    if line.startswith("*"):
        return ""
    code = []
    literal = ""      # the delimiter of the literal the scan is in: ' ` or |
    braces = 0        # depth of { } inside string templates
    position = 0
    while position < len(line):
        char = line[position]
        if literal == "|":
            if char == "\\":
                position += 2
                continue
            if char == "{":
                braces += 1
                literal = ""
            elif char == "|":
                literal = ""
        elif literal:
            if char == literal:
                if line[position + 1:position + 2] == literal:
                    position += 2
                    continue
                literal = ""
        elif char == '"':
            break
        elif char in "'`|":
            literal = char
        elif char == "}" and braces > 0:
            braces -= 1
            literal = "|"
        else:
            code.append(char)
        position += 1
    return "".join(code)


def objects_of(path):
    """Returns the names of SAP classes, interfaces and function modules a source file uses."""
    classes = set()
    functions = set()
    for line in path.read_text(encoding="utf-8-sig").splitlines():
        code = code_of(line).upper()
        classes.update(OBJECT_NAME.findall(code))
        classes.update(FORBIDDEN_TOKEN.findall(code))
        if not line.startswith("*"):
            functions.update(name.upper() for name in FUNCTION_CALL.findall(line.split('"')[0]))
    return classes, functions


def states_of(path, section):
    """Returns the state of every object of a Cloudification Repository file, by type and name."""
    states = {}
    for entry in json.loads(pathlib.Path(path).read_text(encoding="utf-8"))[section]:
        states[(entry["objectType"], entry["objectKey"].upper())] = entry["state"]
    return states


def exceptions_of(path):
    """Returns the exceptions as (object, file pattern) pairs."""
    exceptions = []
    for line in pathlib.Path(path).read_text(encoding="utf-8").splitlines():
        if line.strip() and not line.lstrip().startswith("#"):
            name, pattern = line.split()[:2]
            exceptions.append((name.upper(), pattern))
    return exceptions


def problem_of(name, types, classified, released):
    """Returns why an object must not be used, or None if it may."""
    if any(pattern.fullmatch(name) for pattern in FORBIDDEN):
        return "never used by SALVage (internal of SALV or the grid behind it)"
    states = [states[(object_type, name)]
              for states in (classified, released)
              for object_type in types
              if (object_type, name) in states]
    if "classicAPI" in states or "released" in states:
        return None
    if states:
        return "classified " + ", ".join(sorted(set(states)))
    return "not classified by SAP"


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("sources", help="folder with the *.abap files")
    parser.add_argument("--classifications", required=True, help="objectClassifications_SAP.json")
    parser.add_argument("--released", required=True, help="objectReleaseInfo_PCELatest.json")
    parser.add_argument("--exceptions", default=DEFAULT_EXCEPTIONS, help="exceptions file")
    arguments = parser.parse_args()

    classified = states_of(arguments.classifications, "objectClassifications")
    released = states_of(arguments.released, "objectReleaseInfo")
    exceptions = exceptions_of(arguments.exceptions)
    used_exceptions = set()
    findings = []
    checked = set()

    files = sorted(pathlib.Path(arguments.sources).rglob("*.abap"))
    for path in files:
        classes, functions = objects_of(path)
        for name, types in [(name, ("CLAS", "INTF")) for name in sorted(classes)] + \
                           [(name, ("FUNC",)) for name in sorted(functions)]:
            checked.add(name)
            problem = problem_of(name, types, classified, released)
            if problem is None:
                continue
            allowed = [exception for exception in exceptions
                       if exception[0] == name and fnmatch.fnmatch(path.as_posix(), exception[1])]
            if allowed:
                used_exceptions.update(allowed)
            else:
                findings.append(f"{path.as_posix()}: {name} - {problem}")

    for name, pattern in sorted(set(exceptions) - used_exceptions):
        print(f"note: exception {name} for {pattern} is not needed any more")
    if findings:
        print("\n".join(findings))
        print(f"\n{len(findings)} use(s) of SAP objects outside the classic API. Use a classic "
              f"object, or add an exception with its reason to {arguments.exceptions}.")
        return 1
    print(f"{len(checked)} SAP objects in {len(files)} files: all classic API or released, "
          f"{len(used_exceptions)} documented exception(s).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
