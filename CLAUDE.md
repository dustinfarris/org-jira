# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

org-jira is an Emacs package that syncs Jira issues, comments, worklogs and boards into org-mode files (one `<PROJ-KEY>.org` per project under `org-jira-working-dir`). Three elisp files at the repo root, no build step.

## Commands

- `make test` runs the whole ERT suite in batch Emacs (CI via `.travis.yml` does the same).
- Run a subset by regexp, using the same load list as the Makefile:
  ```sh
  emacs -batch -l ert -l t/batch-runner/request.el -l t/batch-runner/dash.el \
    -l jiralib.el -l org-jira-sdk.el -l org-jira.el -l t/org-jira-t.el -l t/jiralib-t.el \
    --eval '(ert-run-tests-batch-and-exit "REGEXP")'
  ```
- Interactively: load a test file and `M-x ert RET t RET`.
- There is no linter or byte-compile target. Compilation warnings have been fixed upstream before (see recent commits), so keep `declare-function`/`require` hygiene when adding cross-file calls.

`t/batch-runner/{request,dash}.el` are stubs so tests run without those packages installed. New tests go in `t/org-jira-t.el` or `t/jiralib-t.el` and must be registered via the Makefile's `-l` list if you add a file.

## Architecture

Layering, bottom to top:

- `jiralib.el` is the transport layer. `jiralib-call` is the single entry point for Jira calls. It handles login state and chooses REST (`jiralib-use-restapi`, default) or legacy SOAP. Calls are async via `request.el` when a CALLBACK is given, and synchronous when it is `nil` (slow, avoid). Auth comes from `~/.authinfo(.gpg)`, a bearer/PAT token, or basic auth; the token is stored in the global `jiralib-token`. REST helpers are `jiralib--rest-call-it`, and `jiralib-issue-regexp` is lazily built from the project list on first call.
- `org-jira-sdk.el` is a thin EIEIO entity layer: `org-jira-sdk-record` with subclasses `-issue`, `-comment`, `-board` and so on. Construct them with `org-jira-sdk-create-from-id` (hydrates from the remote through the class's `hydrate-fn`) or `org-jira-sdk-create-from-data` (wraps a raw alist). `org-jira-sdk-from-data` is a generic that normalises the raw Jira alist into typed slots. Record type names are mapped to class names by symbol munging (`org-jira-sdk-record-type-to-symbol`).
- `org-jira.el` is the UI and org-buffer layer (~2.7k lines): interactive commands, the `org-jira-mode` keymap, and the rendering and parsing of issues to and from org headings and properties. The `ensure-on-*` macros (`ensure-on-issue`, `ensure-on-issue-id`, `ensure-on-comment`, `ensure-on-worklog`, ...) position point on the right heading or buffer before running body; most mutating commands use them. Updates are pushed back by reading org properties and heading text, for example `org-jira-update-issue` and `org-jira-get-issue-struct`.

Comments are written in a popup `org-mode` buffer (`org-jira-comment-edit-buffer`, `org-jira-comment-mode`), not the minibuffer. Conversion from org to Jira markup is deliberately not in this package: `org-jira-comment-to-jira-function` is a hook that defaults to `identity`, and `org-jira-comment-mention-insert-function` controls what an `@` completion inserts. Mention candidates come from `jiralib-search-viewable-users` and are cached per issue and query. Both hooks are expected to be set from user config, which also handles the pull direction by advising `org-jira-sdk-from-data`.

Data flow for a pull: command, then `jiralib-call` (async callback), then raw alist, then `org-jira-sdk` record, then org-jira.el writes the heading and properties into the project file. Push is the reverse, driven by what is in the buffer.

## Gotchas

- Everything runs async, so callbacks may fire after the user has switched buffers. `TODO.org` documents a known problem where custom-JQL result buffers don't receive mutations because chained pulls (comments, worklogs) assume the `PROJ-KEY.org` buffer.
- `rest-calls/jira.rest` holds sample REST requests for manual API exploration.
- The `Package-Requires` headers differ between files (`dash` vs `s`) and are easy to let drift; check all three headers when adding a dependency.
