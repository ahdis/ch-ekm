#!/usr/bin/env python3
"""Generate the two CH EKM overview SVGs on the profiles page.

  input/images/ekm-resource-relationships.svg  how the resources reference each other
  input/images/ekm-document-bundle.svg         schematic overview of the document Bundle

The SVGs are committed; re-run this script and commit its output when a profile changes a
reference, a section or an entry shown there. Usage:

  python3 scripts/generate-overview-svgs.py [output-dir]   # default: input/images

Palette taken from input/images/ekm-form-phases.svg and ekm-implementation-paths.svg.
"""
import os
import sys
from xml.sax.saxutils import escape

OUT = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "input", "images")

DARK = "#2B5081"
BLUE = "#3B73AA"
LIGHT = "#E9EEF6"
PALE = "#F1F4F9"
GREYBG = "#F4F5F8"
LINE = "#B9C8E1"
TITLE = "#3D4960"
TEXT = "#555555"
SOFT = "#7392C3"

HEAD = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 900 {h}" font-family="Arial, Helvetica, sans-serif">
  <title>{title}</title>
  <defs>
    <marker id="arr" markerWidth="8" markerHeight="6" refX="8" refY="3" orient="auto">
      <path d="M0,0 L8,3 L0,6 Z" fill="#3B73AA"/>
    </marker>
    <marker id="arr-dark" markerWidth="8" markerHeight="6" refX="8" refY="3" orient="auto">
      <path d="M0,0 L8,3 L0,6 Z" fill="#2B5081"/>
    </marker>
    <filter id="sh" x="-2%" y="-2%" width="104%" height="104%">
      <feDropShadow dx="1" dy="1" stdDeviation="2" flood-opacity="0.1"/>
    </filter>
  </defs>
"""


def t(x, y, s, size=8, fill=TEXT, anchor="start", weight=None, italic=False):
    a = f' text-anchor="{anchor}"' if anchor != "start" else ""
    w = f' font-weight="{weight}"' if weight else ""
    i = ' font-style="italic"' if italic else ""
    return f'  <text x="{x}" y="{y}"{a} font-size="{size}"{w} fill="{fill}"{i}>{escape(s)}</text>'


def box(x, y, w, h, rtype, role, profiles, color=BLUE, dashed=False):
    """Resource box: coloured header with the resource type, role and profile name(s) below."""
    out = []
    if dashed:
        out.append(f'  <rect x="{x}" y="{y}" width="{w}" height="{h}" rx="5" fill="#ffffff" stroke="{color}" stroke-width="1.5" stroke-dasharray="4,3" filter="url(#sh)"/>')
        out.append(t(x + w / 2, y + 13, rtype, 9.5, color, "middle", "bold"))
        out.append(f'  <line x1="{x + 8}" y1="{y + 19}" x2="{x + w - 8}" y2="{y + 19}" stroke="{color}" stroke-opacity="0.4" stroke-width="1"/>')
    else:
        out.append(f'  <rect x="{x}" y="{y}" width="{w}" height="{h}" rx="5" fill="#ffffff" stroke="{color}" stroke-width="1.5" filter="url(#sh)"/>')
        out.append(f'  <path d="M{x},{y + 19} V{y + 5} Q{x},{y} {x + 5},{y} H{x + w - 5} Q{x + w},{y} {x + w},{y + 5} V{y + 19} Z" fill="{color}"/>')
        out.append(t(x + w / 2, y + 13, rtype, 9.5, "#ffffff", "middle", "bold"))
    out.append(t(x + w / 2, y + 33, role, 9, TITLE, "middle", "bold"))
    yy = y + 46
    for p in profiles:
        size = 7.5 if len(p) < 30 else 7
        out.append(t(x + w / 2, yy, p, size, TEXT, "middle", italic=True))
        yy += 10
    return "\n".join(out)


def path(d, color=BLUE, marker="arr", dashed=False):
    da = ' stroke-dasharray="4,3"' if dashed else ""
    m = f' marker-end="url(#{marker})"' if marker else ""
    return f'  <path d="{d}" fill="none" stroke="{color}" stroke-width="1.5"{da}{m}/>'


def comment(s):
    return f"\n  <!-- {s} -->"


# ============================================================================
# 1. Resource relationships
# ============================================================================
def relationships():
    W = 150
    H = 62
    c = {1: 20, 2: 210, 3: 380, 4: 550, 5: 720}  # column x
    rowA, rowB, rowC, rowD, rowE = 50, 140, 262, 358, 454
    bus = 228
    o = [HEAD.format(h=560, title="CH EKM FHIR Document: how the resources reference each other")]
    o.append(t(450, 28, "How the resources of a CH EKM document reference each other", 18, TITLE, "middle", "bold"))

    o.append(comment("Row A: Patient, Composition, author"))
    o.append(box(c[1], rowA, W, 56, "Patient", "Reported person", ["ChEkmPatient (+ variants)"]))
    o.append(box(355, rowA, 190, 56, "Composition", "Clinical report", ["ChEkmComposition"], DARK))
    o.append(box(c[5], rowA, W, 56, "PractitionerRole", "Author", ["ChEkmPractitionerRole"]))
    o.append(path("M355,72 H171", DARK, "arr-dark"))
    o.append(t(262, 67, "subject 1..1", anchor="middle"))
    o.append(path("M545,72 H719", DARK, "arr-dark"))
    o.append(t(632, 67, "author 1..1", anchor="middle"))

    o.append(comment("Row B: hospitalisation, the author's Practitioner and Organization"))
    o.append(box(c[1], rowB, W, H, "Encounter", "Hospitalisation", ["ChEkmEncounter"]))
    o.append(box(555, rowB, W, H, "Practitioner", "Treating physician or broker",
                 ["ChEkmPractitionerTreatingPhysician", "ChEkmPractitionerBroker"]))
    o.append(box(c[5], rowB, W, H, "Organization", "Treating physician or broker",
                 ["ChEkmOrganizationTreatingPhysician", "ChEkmOrganizationBroker"]))
    o.append(path("M375,106 V168 H171", DARK, "arr-dark"))
    o.append(t(272, 163, "encounter 0..1", anchor="middle"))
    o.append(path("M95,140 V107"))
    o.append(t(100, 127, "subject 1..1"))
    o.append(path("M795,106 V139"))
    o.append(path("M795,118 H630 V139", marker="arr"))
    o.append(t(800, 132, "organization 0..1"))
    o.append(t(625, 132, "practitioner 0..1", anchor="end"))

    o.append(comment("Sections: trunk from the Composition, one drop per section"))
    o.append(path(f"M450,106 V{bus}", DARK, None))
    o.append(path(f"M160,{bus} H795", DARK, None))
    o.append(t(456, 190, "section", 8.5, DARK, weight="bold", italic=True))
    drops = [(160, "diagnosis 1..1"), (285, "cause-death 0..1"), (455, "social-history 0..1"),
             (625, "immunization 0..1"), (795, "laboratory 0..1")]
    for x, label in drops:
        o.append(path(f"M{x},{bus} V{rowC - 1}", DARK, "arr-dark"))
        o.append(t(x + 4, bus - 6, label, 8, DARK, weight="bold"))
    # second entry of a section: branches off the section's drop, runs along the column edge
    o.append(path(f"M160,{bus + 14} H200 V{rowD + 31} H171", DARK, "arr-dark"))
    for drop, x in ((455, 372), (625, 542)):
        o.append(path(f"M{drop},{bus + 14} H{x} V{rowD + 31} H{x + 7}", DARK, "arr-dark"))

    o.append(comment("Row C: first entry of each section"))
    o.append(box(c[1], rowC, W, H, "Condition", "Diagnosis, manifestation", ["ChEkmCondition"]))
    o.append(box(c[2], rowC, W, H, "Observation", "Cause of death", ["ChEkmObservationCauseOfDeath"]))
    o.append(box(c[3], rowC, W, H, "Observation", "Exposure", ["ChEkmExposure"]))
    o.append(box(c[4], rowC, W, H, "Immunization", "Vaccinated: yes", ["ChEkmImmunization"]))
    o.append(box(c[5], rowC, W, H, "ServiceRequest", "Laboratory order", ["ChEkmServiceRequest"]))

    o.append(comment("Row D: second entry of a section; the lab order's sample"))
    o.append(box(c[1], rowD, W, H, "QuestionnaireResponse", "Disease-specific answers",
                 ["only if the form asks any"], dashed=True))
    o.append(box(c[3], rowD, W, H, "Observation", "Trans person: no", ["ChEkmObservationTransgenderStatus"]))
    o.append(box(c[4], rowD, W, H, "Observation", "Vaccinated: no / unknown",
                 ["ChEkmObservationVaccinationStatus"]))
    o.append(box(c[5], rowD, W, H, "Specimen", "Sample", ["ChEkmSpecimen"]))
    o.append(box(c[5], rowE, W, H, "Organization", "Laboratory", ["ChEkmOrganizationLab"]))

    o.append(comment("Encounter <-> Condition, cause of death -> Condition, lab order -> specimen / lab"))
    o.append(path(f"M40,{rowC} V{rowB + H + 1}"))
    o.append(t(44, 226, "encounter"))
    o.append(t(44, 236, "0..1"))
    o.append(path(f"M90,{rowB + H} V{rowC - 1}"))
    o.append(t(94, 226, "reasonReference"))
    o.append(t(94, 236, "0..1"))
    # bridge over the diagnosis section's second entry line
    o.append(f'  <line x1="196" y1="293" x2="204" y2="293" stroke="#ffffff" stroke-width="5"/>')
    o.append(path(f"M{c[2]},293 H171"))
    o.append(t(185, 287, "focus", anchor="middle"))
    o.append(t(185, 306, "0..1", anchor="middle"))
    o.append(path(f"M795,{rowC + H} V{rowD - 1}"))
    o.append(t(800, 344, "specimen 0..1"))
    o.append(path(f"M{c[5]},305 H710 V485 H719"))
    o.append(t(705, 480, "performer 0..1", anchor="end"))

    o.append(comment("Notes"))
    o.append(f'  <rect x="20" y="{rowE}" width="510" height="{H}" rx="8" fill="{GREYBG}" stroke="{LINE}" stroke-width="1.5"/>')
    o.append(t(32, rowE + 17, "Every clinical resource also references the Patient (subject 1..1, Immunization.patient 1..1);", 8.5))
    o.append(t(32, rowE + 29, "those arrows are left out for readability.", 8.5))
    o.append(t(32, rowE + 44, "Broker scenario: author is the broker, Condition.recorder the treating physician's PractitionerRole.", 8.5))
    o.append(t(32, rowE + 56, "Not shown: the medication and risk-factors sections and the seroconversion Observation.", 8.5))

    o.append(t(450, 545, "Base profiles shown · each disease derives its own Document, Composition, Condition, Exposure, …"
               " (e.g. ChEkmConditionGonorrhoea)", 9, anchor="middle"))
    o.append("</svg>\n")
    return "\n".join(o)


# ============================================================================
# 2. Document Bundle
# ============================================================================
def chip(x, y, w, label, value, h=20):
    """A reference held by the Composition: 'label: Resource (Reference)'."""
    return "\n".join([
        f'  <rect x="{x}" y="{y}" width="{w}" height="{h}" rx="3" fill="#ffffff" stroke="{LINE}" stroke-width="1"/>',
        f'  <text x="{x + 8}" y="{y + 13.5}" font-size="9" fill="{TITLE}"><tspan font-weight="bold" fill="{DARK}">{escape(label)}:</tspan> {escape(value)}</text>',
    ])


def entry_bar(x, y, w, rtype, profile, dashed=False, h=22):
    if dashed:
        r = f'  <rect x="{x}" y="{y}" width="{w}" height="{h}" rx="3" fill="#ffffff" stroke="{DARK}" stroke-width="1" stroke-dasharray="3,2"/>'
        fill, pfill = DARK, DARK
    else:
        r = f'  <rect x="{x}" y="{y}" width="{w}" height="{h}" rx="3" fill="{DARK}"/>'
        fill, pfill = "#ffffff", LIGHT
    return "\n".join([
        r,
        f'  <text x="{x + 10}" y="{y + 15}" font-size="9.5" fill="{fill}"><tspan font-weight="bold">entry:</tspan> {escape(rtype)}</text>',
        t(x + w - 10, y + 15, profile, 8, pfill, "end", italic=True),
    ])


def bundle():
    o = [HEAD.format(h=570, title="CH EKM FHIR Document: schematic overview of the Bundle")]
    o.append(t(450, 28, "Schematic overview of a CH EKM FHIR Document", 18, TITLE, "middle", "bold"))

    o.append(comment("Bundle, with a folded corner"))
    x0, y0, x1, y1 = 20, 44, 880, 540
    o.append(f'  <path d="M{x0 + 8},{y0} H{x1 - 24} L{x1},{y0 + 24} V{y1 - 8} Q{x1},{y1} {x1 - 8},{y1} H{x0 + 8} Q{x0},{y1} {x0},{y1 - 8} V{y0 + 8} Q{x0},{y0} {x0 + 8},{y0} Z" fill="{PALE}" stroke="{DARK}" stroke-width="1.5" filter="url(#sh)"/>')
    o.append(f'  <path d="M{x1 - 24},{y0} V{y0 + 24} H{x1} Z" fill="{LINE}" stroke="{DARK}" stroke-width="1.5" stroke-linejoin="round"/>')
    o.append(f'  <text x="36" y="68" font-size="15" fill="{DARK}"><tspan font-weight="bold">Bundle:</tspan> CH EKM Document</text>')
    o.append(t(236, 68, "ChEkmDocument<Disease>", 9, TEXT, italic=True))
    o.append(t(36, 86, "type = document · identifier, timestamp · the Composition comes first, followed by every resource it references", 9, TEXT))

    o.append(comment("entry: Composition"))
    cx, cy, cw, ch = 36, 100, 470, 426
    o.append(f'  <rect x="{cx}" y="{cy}" width="{cw}" height="{ch}" rx="6" fill="{BLUE}" filter="url(#sh)"/>')
    o.append(f'  <text x="{cx + 14}" y="{cy + 22}" font-size="13" fill="#ffffff"><tspan font-weight="bold">entry:</tspan> <tspan font-weight="bold">Composition</tspan></text>')
    o.append(t(cx + cw - 14, cy + 22, "ChEkmComposition<Disease>", 8.5, LIGHT, "end", italic=True))
    o.append(t(cx + 14, cy + 40, "status = final, date, title · type = 722143004 Infectious disease diagnostic study note", 8.5, LIGHT))

    ix, iw = cx + 14, cw - 28
    y = cy + 50
    for label, value in [("subject", "Patient (Reference) 1..1"),
                         ("author", "PractitionerRole (Reference) 1..1"),
                         ("encounter", "Encounter (Reference) 0..1, only if hospitalised")]:
        o.append(chip(ix, y, iw, label, value))
        y += 24

    sections = [
        ("diagnosis", "1..1", ["Condition (Reference)", "QuestionnaireResponse (Reference), if any"]),
        ("laboratory", "0..1", ["ServiceRequest (Reference) → specimen, performer"]),
        ("immunization", "0..1", ["Immunization (yes) | Observation (no / unknown), one per answered row"]),
        ("social-history", "0..1", ["Observation (Reference), exposure", "Observation (Reference), trans person: no"]),
        ("cause-death", "0..1", ["Observation (Reference), cause of death"]),
    ]
    y += 4
    for name, card, entries in sections:
        h = 22 + 20 * len(entries) + 4
        o.append(f'  <rect x="{ix}" y="{y}" width="{iw}" height="{h}" rx="4" fill="{LIGHT}" stroke="{LINE}" stroke-width="1"/>')
        o.append(f'  <text x="{ix + 8}" y="{y + 15}" font-size="9.5" fill="{DARK}"><tspan font-weight="bold">section:</tspan> {escape(name)} {card}</text>')
        ey = y + 21
        for e in entries:
            o.append(chip(ix + 16, ey, iw - 24, "entry", e, h=17))
            ey += 20
        y += h + 5

    o.append(comment("The other entries of the Bundle"))
    ex, ew = 524, 340
    entries = [
        ("Patient", "ChEkmPatient (+ variants)", False),
        ("PractitionerRole", "ChEkmPractitionerRole", False),
        ("Practitioner", "ChEkmPractitioner…", False),
        ("Organization", "ChEkmOrganization…", False),
        ("Condition", "ChEkmCondition<Disease>", False),
        ("QuestionnaireResponse", "disease-specific answers", True),
        ("Encounter", "ChEkmEncounter", True),
        ("ServiceRequest", "ChEkmServiceRequest", True),
        ("Specimen", "ChEkmSpecimen", True),
        ("Organization", "ChEkmOrganizationLab", True),
        ("Immunization", "ChEkmImmunization…", True),
        ("Observation", "ChEkmObservationVaccinationStatus…", True),
        ("Observation", "ChEkmExposure<Disease>", True),
        ("Observation", "ChEkmObservationTransgenderStatus", True),
        ("Observation", "ChEkmObservationCauseOfDeath", True),
        ("…", "", True),
    ]
    y = 100
    for rtype, prof, dashed in entries:
        o.append(entry_bar(ex, y, ew, rtype, prof, dashed))
        y += 26

    o.append(t(450, 558, "Solid: in every document · dashed: only when the form's answers produce it · "
               "<Disease>: the disease profile, e.g. ChEkmConditionGonorrhoea", 9, anchor="middle"))
    o.append("</svg>\n")
    return "\n".join(o)


with open(f"{OUT}/ekm-resource-relationships.svg", "w") as f:
    f.write(relationships())
with open(f"{OUT}/ekm-document-bundle.svg", "w") as f:
    f.write(bundle())
