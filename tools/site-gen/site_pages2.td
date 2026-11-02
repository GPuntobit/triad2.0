# =====================================================================
#  site_pages2.td - the remaining pages of the Triad 2.0 site:
#  apprendimento.html, ai.html and license.html.
#
#  It is a separate program from site_pages.td on purpose: the seed
#  reads a source of at most 61439 bytes and its heap is a bump
#  allocator of about 64 KiB, so every generator starts with a clean
#  arena and a clean source buffer.
#
#  Output: a text bundle with one marker per file:
#
#      === FILE: docs/pages/apprendimento.html ===
#      <!DOCTYPE html>
#      ...
#
#  Rules that this program obeys so that the native PE seed and the
#  reference JS interpreter produce the SAME bytes:
#    - one println per output line: a string literal never contains a
#      raw newline, because the seed does not interpret escapes and
#      the linter requires a closed literal on one line;
#    - no double quote inside a string literal (the seed ends the
#      literal at the first quote): the quotes of the MIT text are
#      written as &quot; entities;
#    - no backslash inside a string literal;
#    - no block (function/if/while/let) anywhere, so the seed never
#      scans the text of a literal for keywords;
#    - the shared page shell is allocated once in variables and
#      printed three times.
#
#  Run:  node tools/site-gen/build.mjs --dry tools/site-gen/site_pages2.td
# =====================================================================

# --- the shell shared by the three pages ------------------------------
b_doctype = "<!DOCTYPE html>"
b_html = "<html lang='en'>"
b_head = "<head>"
b_charset = "<meta charset='utf-8' />"
b_viewport = "<meta name='viewport' content='width=device-width, initial-scale=1' />"
b_css = "<link rel='stylesheet' href='../assets/css/style.css' />"
b_css2 = "<link rel='stylesheet' href='../assets/css/triad-generated.css' />"
b_headend = "</head>"
b_body = "<body>"
b_hdrdiv = "<div id='site-header'></div>"
b_main = "<main class='container'>"
b_layout = "<div class='doc-layout'>"
b_aside = "<aside class='doc-sidebar'>"
b_asideh4 = "<h4>Documentation</h4>"
b_ul = "<ul>"
b_li1 = "<li><a href='getting-started.html'>Get started</a></li>"
b_li2 = "<li><a href='language-tour.html'>Tour</a></li>"
b_li3 = "<li><a href='spec.html'>Spec</a></li>"
b_li4 = "<li><a href='tutorial.html'>Tutorial</a></li>"
b_li5 = "<li><a href='apprendimento.html'>Learning</a></li>"
b_li6 = "<li><a href='examples.html'>Examples</a></li>"
b_li7 = "<li><a href='playground.html'>Playground</a></li>"
b_li8 = "<li><a href='conformance.html'>Conformance</a></li>"
b_li9 = "<li><a href='bootstrap.html'>Bootstrap</a></li>"
b_li10 = "<li><a href='editors.html'>Editor</a></li>"
b_li11 = "<li><a href='status.html'>Status</a></li>"
b_li12 = "<li><a href='ai.html'>AI</a></li>"
b_li13 = "<li><a href='license.html'>License</a></li>"
b_ulend = "</ul>"
b_asideend = "</aside>"
b_content = "<div class='doc-content'>"
b_contentend = "</div>"
b_layoutend = "</div>"
b_mainend = "</main>"
b_ftrdiv = "<div id='site-footer'></div>"
b_script = "<script src='../assets/js/app.js'></script>"
b_bodyend = "</body>"
b_htmlend = "</html>"

# =====================================================================
#  1. apprendimento.html
# =====================================================================
println("=== FILE: docs/pages/apprendimento.html ===")
println(b_doctype)
println(b_html)
println(b_head)
println(b_charset)
println(b_viewport)
println("<title>Learning — Triad 2.0</title>")
println("<meta name='description' content='The learning curve of Triad 2.0: the stages of the path, their difficulty, the part that can be exercised today and the threshold of Triad-Full.' />")
println(b_css)
println(b_css2)
println(b_headend)
println(b_body)
println(b_hdrdiv)
println(b_main)
println(b_layout)
println(b_aside)
println(b_asideh4)
println(b_ul)
println(b_li1)
println(b_li2)
println(b_li3)
println(b_li4)
println(b_li5)
println(b_li6)
println(b_li7)
println(b_li8)
println(b_li9)
println(b_li10)
println(b_li11)
println(b_li12)
println(b_li13)
println(b_ulend)
println(b_asideend)
println(b_content)
println("<h1>Learning curve and threshold</h1>")
println("<p class='section-sub'>Triad-Core is learned by doing, Triad-Full today only by reading. This page measures the path: the stages, their difficulty, how much of each stage can be exercised right now, and the threshold where the real mastery stops.</p>")
println("<h2>1. Two phases, one path</h2>")
println("<p>The path is built from the chapters of the tutorial and of the manual and it is made of 17 stages in three groups: 9 Core stages, 6 Full stages and 2 stages about the project itself. The Core stages cover the subset that the seed executes, so every Core chapter can be read, run and checked against its golden output. The Full stages cover the rest of the standard: of the 12 Full conformance cases only the error one passes today, so those chapters can be read but not executed.</p>")
println("<p>The split is not a matter of taste, it is the runtime that decides: a chapter is exercisable only when there is a case that produces the expected bytes. The tutorial follows the same order in five parts.</p>")
println("<div class='code-card'>")
println("Part I    chapters 1-3    first steps: install, run, first program")
println("Part II   chapters 4-17   Triad-Core, step by step")
println("Part III  chapters 18-32  Triad-Full")
println("Part IV   chapters 33-43  the project code")
println("Part V    chapters 44-49  reference: grammar, quick tab, debugging, glossary, FAQ")
println("</div>")
println("<h2>2. The curve</h2>")
println("<p>Two curves are drawn on the same axis. The theoretical one measures the cumulative effort of the stages and reaches 100% at the end of the language stages: reading the whole standard is possible. The real one measures what can actually be exercised, and it tells a different story. At the threshold, the last Core stage, the idiomatic patterns and the Core exercises, it stands at 34.7% while the theoretical curve is already at 44.2%; from there the real curve creeps up to about 39% and stays there, while the theoretical one keeps climbing to the end.</p>")
println("<div class='chart-card' id='lc-home'></div>")
println("<p>The same figure is available as a static file: <a href='../assets/img/learning-curve.svg' target='_blank' rel='noopener'>learning-curve.svg</a>.</p>")
println("<h3>The stages at a glance</h3>")
println("<p>The second chart shows the difficulty of every stage and the share that is exercisable today: the full bar is the share that can be run, the light bar is theory only.</p>")
println("<div class='chart-card' id='lc-stages'></div>")
println("<p class='chart-link'><a href='../assets/img/learning-stages.svg' target='_blank' rel='noopener'>learning-stages.svg</a></p>")
println("<div id='lc-table'></div>")
println("<div class='code-card'>")
println("# the same figures, rendered in the browser by the learning-curve script")
println("TriadLearningCurve.render('lc-home', 'curve', { compact: true });")
println("TriadLearningCurve.render('lc-stages', 'stages');")
println("TriadLearningCurve.renderTable('lc-table');")
println("</div>")
println("<h2>3. Where the difficulty jumps</h2>")
println("<p>The difficulty of the Core stages goes from 29 to 56 out of 100: the lexicon and printing, the operators, the control flow, the functions, the closures, the lists and strings, the runtime errors, the idiomatic patterns. The Full stages jump to a range from 64 to 93, and the peak is the stage on the logic, with the facts, the rules and the solver, at 93: unification with occurs-check, backtracking and the solver as a value. At the same time the share exercisable today collapses: it is between 40% and 95% in the Core stages and only 8% in every Full stage.</p>")
println("<p>The reason is in the nature of the language rather than in the number of pages. The Full profile adds declared types and multiple dispatch, structs, an extended flow control, the logic, the errors as values, the contracts, the budgets, the traces, the declared effects and the macros: each of them is a new way of writing a program, not a new function to call.</p>")
println("<h2>4. The method</h2>")
println("<ul class='feature-list'>")
println("<li>Read the chapter, then run every Core example: the examples are the same programs as the conformance cases.</li>")
println("<li>Write the case yourself: a deterministic program with no input, then generate the goldens and read them before committing them.</li>")
println("<li>For a Full chapter, read the specification next to it: the standard is the contract, the case will arrive with the runtime.</li>")
println("<li>Measure the plateau and not the number of pages: the real curve says what you can actually run today.</li>")
println("</ul>")
println("<p class='section-sub'>Source: docs/assets/js/learning-curve.js, docs/tutorial/TUTORIAL.md, docs/MANUALE.md, README.md, docs/index.html.</p>")
println(b_contentend)
println(b_layoutend)
println(b_mainend)
println(b_ftrdiv)
println(b_script)
println("<script src='../assets/js/learning-curve.js'></script>")
println("<script>TriadSite.mount('Learning'); TriadLearningCurve.render('lc-home', 'curve', { compact: true }); TriadLearningCurve.render('lc-stages', 'stages'); TriadLearningCurve.renderTable('lc-table');</script>")
println(b_bodyend)
println(b_htmlend)

# =====================================================================
#  2. ai.html
# =====================================================================
println("=== FILE: docs/pages/ai.html ===")
println(b_doctype)
println(b_html)
println(b_head)
println(b_charset)
println(b_viewport)
println("<title>AI — Triad 2.0</title>")
println("<meta name='description' content='The AI benchmark of Triad 2.0: how a language model is asked to write Triad, how the generated solution is verified against the goldens, and how the kit is meant to be used.' />")
println(b_css)
println(b_css2)
println(b_headend)
println(b_body)
println(b_hdrdiv)
println(b_main)
println(b_layout)
println(b_aside)
println(b_asideh4)
println(b_ul)
println(b_li1)
println(b_li2)
println(b_li3)
println(b_li4)
println(b_li5)
println(b_li6)
println(b_li7)
println(b_li8)
println(b_li9)
println(b_li10)
println(b_li11)
println(b_li12)
println(b_li13)
println(b_ulend)
println(b_asideend)
println(b_content)
println("<h1>The AI benchmark</h1>")
println("<p class='section-sub'>The kit in the ai folder measures whether a language model is able to write Triad. It is a developer tool: it is not part of the S0 to S4 chain, the official conformance stays the one of the conformance folder, and what is measured here is the quality of the generation.</p>")
println("<h2>1. What it is</h2>")
println("<p>Inside a task there are the pieces of a small benchmark. The system prompt is given to the model, the task file is the request in natural language, the golden output is the expected standard output, the golden code is the expected exit code, zero by default, and the solution file is the program that the model produced. The model receives the prompt and a task, it answers with a Triad program, the program is saved and it is verified against the goldens.</p>")
println("<p>The five tasks cover the Core subset and nothing else: the sum with its precedence, the factorial with the recursion and the ternary, the double recursion of the Fibonacci, the strings with the concatenation and the length, and a function that returns a lambda with a capture.</p>")
println("<div class='code-card'>")
println("ai/tasks/01_somma/         println, precedence, integers")
println("ai/tasks/02_fattoriale/    functions, recursion, ternary")
println("ai/tasks/03_fibonacci/     double recursion")
println("ai/tasks/04_stringhe/      strings, concatenation, length")
println("ai/tasks/05_chiusure/      a function that returns a lambda")
println("</div>")
println("<h2>2. How to run it</h2>")
println("<p>The verifier takes every task that has a solution, runs it with the seed and compares the standard output and the exit code with the goldens. It prints a verdict for each case and a summary at the end; a missing solution is skipped and does not make the verification fail, while a single failing solution is enough to make the command exit with the code 1.</p>")
println("<div class='code-card'>")
println("# all the tasks")
println("node cli/triad-cli.mjs ai verify")
println("")
println("# a single case")
println("node cli/triad-cli.mjs ai verify --tasks ai/tasks/02_fattoriale")
println("")
println("# with the obtained and the expected output side by side")
println("node cli/triad-cli.mjs ai verify --verbose")
println("</div>")
println("<h2>3. The format of the solution</h2>")
println("<p>The system prompt is strict on purpose: a single block of code, no text outside the block, no markdown around it, only the supported constructs of Triad-Core, no invented libraries, types or functions, and the output produced only with the print statement. The answer is saved as the solution file and it is executed by the Core interpreter.</p>")
println("<div class='code-card'>")
println("# the answer to the task 02, as the model has to return it")
println("fattoriale(n) = n &lt; 2 ? 1 : n * fattoriale(n - 1)")
println("println(fattoriale(5))")
println("</div>")
println("<p>The metrics that can be extracted are the usual ones of the generation benchmarks: the pass at one, a single generation per task with everything green, the pass at k, with k attempts per task where the first success counts, and the classification of the failures, syntax, runtime or wrong output, to understand whether the gap is in the specification, in the examples or in the tooling.</p>")
println("<h2>4. How not to use it</h2>")
println("<p>This is a measuring instrument, not a source of implementation: the generated program is not part of the language, the repository does not take it as an implementation and the official conformance remains the one in the conformance folder. The README of the folder says it in one line: developer tool, not part of the S0 to S4 chain.</p>")
println("<p>There is one real risk, and it is the reason the safety section exists: the verifier executes the generated code. A model can produce an infinite loop or an unexpected program, so the verification has to run inside a virtual machine or a container, without network and with limited resources, and an unverified output must never be pasted into production.</p>")
println("<p>The rule that binds this repository is the seventh of the agent instructions: when the task is to generate a solution, return only one single block of Triad code, without explanations and without markdown, conforming to the system prompt of the folder, and verify it with the command above.</p>")
println("<p class='section-sub'>Source: ai/README.md, ai/SYSTEM_PROMPT.md, ai/tasks/*, cli/triad-cli.mjs, cli/lib/commands/ai.mjs, AGENTS.md §3.</p>")
println(b_contentend)
println(b_layoutend)
println(b_mainend)
println(b_ftrdiv)
println(b_script)
println("<script>TriadSite.mount('AI')</script>")
println(b_bodyend)
println(b_htmlend)

# =====================================================================
#  3. license.html
# =====================================================================
println("=== FILE: docs/pages/license.html ===")
println(b_doctype)
println(b_html)
println(b_head)
println(b_charset)
println(b_viewport)
println("<title>License — Triad 2.0</title>")
println("<meta name='description' content='The license of Triad 2.0: the MIT license, its terms and the files of the repository it covers.' />")
println(b_css)
println(b_css2)
println(b_headend)
println(b_body)
println(b_hdrdiv)
println(b_main)
println(b_layout)
println(b_aside)
println(b_asideh4)
println(b_ul)
println(b_li1)
println(b_li2)
println(b_li3)
println(b_li4)
println(b_li5)
println(b_li6)
println(b_li7)
println(b_li8)
println(b_li9)
println(b_li10)
println(b_li11)
println(b_li12)
println(b_li13)
println(b_ulend)
println(b_asideend)
println(b_content)
println("<h1>License</h1>")
println("<p class='section-sub'>Triad 2.0 is distributed under the MIT license. The authoritative text is the LICENSE file at the root of the repository.</p>")
println("<h2>1. The terms</h2>")
println("<p>The LICENSE file holds the MIT License, with the copyright of the year 2026 in the name of GPuntobit. The permission is granted, free of charge, to anybody who obtains a copy of the software and of the associated documentation files, to use, copy, modify, merge, publish, distribute, sublicense and sell copies, without restriction, provided that the copyright notice and the permission notice are kept in all the copies or in the substantial portions of the software.</p>")
println("<p>The software is provided as it is, without warranty of any kind, express or implied, and the liability is disclaimed. These are the standard terms of the MIT license: permissive, with a single obligation, that of keeping the notice.</p>")
println("<div class='code-card'>")
println("MIT License")
println("")
println("Copyright (c) 2026 GPuntobit")
println("")
println("Permission is hereby granted, free of charge, to any person obtaining a copy")
println("of this software and associated documentation files (the &quot;Software&quot;), to deal")
println("in the Software without restriction, including without limitation the rights")
println("to use, copy, modify, merge, publish, distribute, sublicense, and/or sell")
println("copies of the Software, and to permit persons to whom the Software is")
println("furnished to do so, subject to the following conditions:")
println("")
println("THE SOFTWARE IS PROVIDED &quot;AS IS&quot;, WITHOUT WARRANTY OF ANY KIND")
println("</div>")
println("<p>The complete text is the file <a href='https://github.com/GPuntobit/triad2.0/blob/main/LICENSE' target='_blank' rel='noopener'>LICENSE</a> at the root of the repository.</p>")
println("<h2>2. What it covers</h2>")
println("<p>The license applies to the whole repository: the specification and the core profile, the reference interpreter, the seed and its hexadecimal dump, the conformance suite with its goldens, the documentation and this site. Nothing of the project is published under another license.</p>")
println("<p>The footer of every page of the site repeats the same two facts, the license and the version of the standard: 2026 Triad 2.0, distributed under the MIT license, standard 0.2.0. The version lives in the VERSION file and the history of the standard in the CHANGELOG.</p>")
println("<h2>3. The standard and the site</h2>")
println("<p>The specification, the conformance suite and the version file are the requirements to present Triad as an autonomous language: they are the parts of the repository the language is measured by, and they travel with the same license. A copy of the license is expected in every substantial copy or distribution of the software, a derived work included.</p>")
println("<p class='section-sub'>Source: LICENSE, VERSION, CHANGELOG.md, docs/assets/js/app.js (footer), editors/README.md.</p>")
println(b_contentend)
println(b_layoutend)
println(b_mainend)
println(b_ftrdiv)
println(b_script)
println("<script>TriadSite.mount('License')</script>")
println(b_bodyend)
println(b_htmlend)
