---
name: plain-language-texts
description: Load before writing or restructuring a document or docs page (README, guide, report, spec), before writing a leadership update or a deck, and before editing or checking a text that someone else wrote. Holds the rules for these three kinds of text that the Plain language output style leaves out.
---

# Documents, leadership updates, and edits

These rules add to the Plain language output style. That style still applies in
full.

## Documents

A reader opens a document to find one thing, so make it findable. Start with the
title, one line on what it is for, who should read it, and the date. For a page
about one thing, the first sentence says what that thing is ("A custom action is
a named function defined in the configuration file"). The next sentence says
what the page covers. A page that only lists things says what it lists and
points to the page that explains how to use them. A reader who landed in the
wrong place can then move on. If someone might have the wrong document, say
where the right one is.

A heading says what the section says ("Install the dependencies"), not only its
topic ("Dependencies"). Write it in sentence case, and do not repeat it in the
first sentence below it. Use at most three heading levels, and add a table of
contents at six sections or more.

Let the content pick the format: a table for a comparison, a numbered list for
steps, a decision table for if-this-then-that. To explain a system, say what it
is for, then how its parts fit together, then show the code with file and line.
Give the same kind of thing the same place and form every time, so the reader
learns the layout once. A chart, diagram, or screenshot gets one sentence saying
what it shows. End a document on its last concrete point or the next action, not
on a summary of what it said.

## Leadership updates and decks

For leadership, use the order situation, complication, question, answer (SCQA):
where things stand, what makes it a problem, the question it raises, and your
answer. Then say what you need from them. Put data next to the claim it supports
(nobody reads the appendix) and bring a proposal with every problem. A deck
follows the same order, with one point per slide: the headline states it
("Hiring is over budget") and the slide shows the proof.

## Edits of someone else's text

When you are handed a draft, the author owns the voice and the facts. The reader
of the edited text must be able to trust that it still says what the author
meant.

- Change only a sentence that fails one of three tests: it carries a fact about
  this situation, it holds one idea, and the reader understands it on one
  reading. A second pass then changes nothing.
- Before you return the text, compare each sentence with the original. Restore
  every change that no test required, such as a swapped synonym, a changed
  tense, or a trimmed qualifier ("has room for 45 desks" became "has 45 desks").
- Keep every fact, number, name, quote, and citation. Keep how sure the text
  sounds: do not make a claim stronger or weaker.
- Add nothing the source did not supply.
- Leave code blocks, quoted text, link targets, identifiers, and tokens that
  another system depends on alone, unless I name them as the fix.
- Never say whether someone else's text was written by a model. You cannot know
  that from the text alone, and a guess is a claim without evidence. If I ask
  whether you wrote a text, answer truthfully.
- If asked only to check a text, name each tell that is part of a pattern, quote
  the line, and give a short fix, without rewriting. Do not flag a word that the
  field uses for one exact meaning, such as "robust" in statistics or "leverage"
  in finance.
