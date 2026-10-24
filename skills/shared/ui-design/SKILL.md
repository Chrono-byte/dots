---
name: ui-design
description: Use for every UI design task or change to visible layout or copy. Remove filler subtitles, redundant labels, and implementation details while keeping text users need.
---

# UI design

Apply this skill whenever designing, building, or reviewing an interface. Use it alongside relevant framework skills.

Default to the control or content alone. Add a heading only when it distinguishes a section the user needs to identify. Add supporting text only when omitting it would leave a concrete ambiguity or prevent correct use. Keep edits within the user's requested scope.

Judge text by what it adds, even when the wording differs. A subtitle, subheader, eyebrow label, or tagline that paraphrases a heading, names an obvious action, or explains a familiar icon is redundant. Remove existing filler in the area being changed.

For example, remove "DISCORD · MEMBER ACTIVITY" above "Gamers Hall". Keep the heading alone. Do not replace the removed label with another decorative phrase.

Avoid generic copy such as "Your insights at a glance" or "Explore your community". Do not add text to fill empty space or restate a heading.

Keep text needed to interpret data or use a control correctly. Date ranges, timezones, units, XP cooldown rules, errors, and instructions for unfamiliar controls can meet this threshold.

For compact control interfaces, prefer recognizable icons and visible state. Keep accessible names in markup without adding visible captions unless the control would otherwise be ambiguous.

Remove labels, badges, and explanations that describe how the app works internally. Examples include "Live tracking", "Connected", "Powered by React", and background scan or synchronization status. A label does not belong in the interface just because it reports a real internal state.

Show technical status only when it changes what users can do or how they should interpret the result. Explain the consequence in user terms, such as "Data last updated at 3:15 PM" or "Could not load activity. Try again." Keep implementation details in developer tools or an explicitly requested diagnostics view.

Put explanations beside the relevant control or metric. Preserve accessible labels and wording the user explicitly requires.

Before finishing, review every heading, subtitle, caption, badge, and status line in the changed area. For each, name the information lost if removed. Delete it when nothing useful is lost.
