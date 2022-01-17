if exists('b:current_syntax')
  finish
endif

let s:save_cpoptions = &cpoptions
set cpoptions&vim

" For external user-defined commands.
syntax include @Sh syntax/sh.vim
unlet! b:current_syntax

let b:current_syntax = 'tigrc'

syntax iskeyword @,48-57,192-255,$,_,-,.
syntax case match

" Syntax {{{
" general {{{
let s:views = ['main', 'diff', 'log', 'reflog', 'help', 'pager', 'status', 'stage', 'tree', 'blob', 'blame', 'refs', 'stash', 'grep', 'generic']

let s:ui_areas = {
      \ 'general': ['default', 'cursor', 'status', 'title-focus', 'title-blur', 'search-result', 'delimiter', 'header', 'line-number', 'id', 'date', 'author', 'mode', 'overflow', 'directory', 'file', 'file-size', 'diff-header', 'diff-chunk', 'diff-stat', 'diff-add', 'diff-add2', 'diff-del', 'diff-del2', 'diff-add-highlight', 'diff-del-highlight', 'diff-oldmode', 'diff-newmode', 'diff-copy-from', 'diff-copy-to', 'diff-similarity', 'diff-index', 'pp-refs', 'pp-reflog', 'pp-reflogmsg', 'pp-merge', 'commit', 'parent', 'tree', 'author', 'committer', "tree-dir", 'tree-file'],
      \ 'main': ['graph-commit', 'main-commit', 'main-annotated', 'main-head', 'main-remote', 'main-tracked', 'main-tag', 'main-local-tag', 'main-ref', 'main-replace'],
      \ 'status': ['stat-none', 'stat-staged', 'stat-unstaged', 'stat-untracked'],
      \ 'help': ['help-group', 'help-action']
      \ }
for s:i in range(14)
  let s:ui_areas['main'] += ['palette-' . s:i]
endfor

syntax case ignore
for s:view in s:views
  if s:view == 'generic'
    continue
  endif

  for s:area in s:ui_areas['general'] + get(s:ui_areas, s:view, [])
    let s:pat = '/\<' . s:view . '.' . substitute(s:area, '-', '\\%(-\\|_\\)', 'g') . '\>/'
    execute 'syntax match tigrcUiArea' s:pat 'contained'
  endfor
endfor

for s:view in keys(s:ui_areas)
  for s:area in s:ui_areas[s:view]
    let s:pat = '/\<' . substitute(s:area, '-', '\\%(-\\|_\\)', 'g') . '\>/'
    execute 'syntax match tigrcUiArea' s:pat 'contained'
  endfor
endfor
syntax case match
" }}}

" set {{{
" set variable = value
syntax region tigrcSet matchgroup=Keyword start=/\<set\>/ skip=/\\$/ end=/$/ contains=tigrcVariable,tigrcVariableAssign,tigrcView,tigrcViewAssign,tigrcComment

" variables {{{
syntax keyword tigrcVariable diff-options blame-options log-options main-options reference-format line-graphics truncation-delimiter horizontal-scroll git-colors show-notes show-changes show-untracked vertical-split split-view-height split-view-width status-show-untracked-dirs status-show-untracked-files tab-size diff-context diff-highlight ignore-space commit-order ignore-case mailmap wrap-lines focus-child send-child-enter editor-line-number history-size mouse mouse-scroll mouse-wheel-cursor pgrp start-on-head refresh-mode refresh-interval file-args rev-args contained nextgroup=tigrcVariableAssign skipwhite
syntax region tigrcVariableAssign matchgroup=Operator start=/\s\+\zs=\ze\s\+/ skip=/\\$/ excludenl end=/$/ contains=@tigrcColumnValue,tigrcGitColor,tigrcUiArea,tigrcComment contained
syntax region tigrcVariableAssign matchgroup=Operator start=/\s\+\zs=\ze$/ excludenl end=/$/ contained

syntax case ignore
let s:git_colors = {
      \ 'branch': ['current', 'local', 'remote', 'upstream', 'plain'],
      \ 'diff': ['context', 'meta', 'frag', 'func', 'old', 'new', 'commit', 'whitespace', 'oldMoved', 'newMoved', 'odlMovedDimmed', 'oldMovedAlternative', 'oldMovedAlternativeDimmed', 'newMovedDimmed', 'newMovedAlternative', 'newMovedAlternativeDimmed', 'contextDimmed', 'oldDimmed', 'newDimmed', 'contextBold', 'oldBold', 'newBold'],
      \ 'decorate': ['branch', 'remoteBranch', 'tag', 'stash', 'HEAD'],
      \ 'grep': ['context', 'filename', 'function', 'lineNumber', 'column', 'match', 'matchContext', 'matchSelected', 'selected', 'separator'],
      \ 'interractive': ['prompt', 'header', 'help', 'error'],
      \ 'remote': ['hint', 'warning', 'success', 'error'],
      \ 'status': ['header', 'added', 'updated', 'changed', 'untracked', 'branch', 'nobranch', 'localBranch', 'remoteBranch', 'unmerged']
      \ }

for s:context in keys(s:git_colors)
  let s:keywords = []

  for s:slot in s:git_colors[s:context]
    let s:keywords += [s:context . '.' . s:slot]
  endfor

  execute 'syntax keyword tigrcGitColor' join(s:keywords) 'contained'
endfor
syntax case match
" }}}

" views {{{
let s:view_columns = {
      \ 'blob-view': ['line-number', 'text'],
      \ 'diff-view': ['line-number', 'text'],
      \ 'log-view': ['line-number', 'text'],
      \ 'pager-view': ['line-number', 'text'],
      \ 'stage-view': ['line-number', 'text'],
      \ 'blame-view': ['author', 'date', 'file-name', 'id', 'line-number', 'text'],
      \ 'grep-view': ['file-name', 'line-number', 'text'],
      \ 'main-view': ['author', 'date', 'commit-title', 'id', 'line-number', 'ref'],
      \ 'reflog-view': ['author', 'date', 'commit-title', 'id', 'line-number', 'ref'],
      \ 'refs-view': ['author', 'date', 'commit-title', 'id', 'line-number', 'ref'],
      \ 'stash-view': ['author', 'date', 'commit-title', 'id', 'line-number'],
      \ 'status-view': ['file-name', 'line-number', 'status'],
      \ 'tree-view': ['author', 'date', 'id', 'file-name', 'file-size', 'line-number', 'mode']
      \ }

let s:column_options = {
      \ 'author': ['display', 'width', 'maxwidth'],
      \ 'commit-title': ['graph', 'refs', 'overflow'],
      \ 'date': ['display', 'local', 'format', 'width'],
      \ 'file-name': ['display', 'width', 'maxwidth'],
      \ 'file-size': ['display', 'width'],
      \ 'id': ['display', 'width'],
      \ 'line-number': ['display', 'interval', 'width'],
      \ 'mode': ['display', 'width'],
      \ 'ref': ['display', 'width', 'maxwidth'],
      \ 'status': ['display'],
      \ 'text': ['commit-title-overflow']
      \ }

for s:view in keys(s:view_columns)
  let s:keywords = [s:view]

  for s:column in s:view_columns[s:view]
    let s:keywords += [s:view . '-' . s:column]

    for s:option in s:column_options[s:column]
      let s:keywords += [s:view . '-' . s:column . '-' . s:option]
    endfor
  endfor

  execute 'syntax keyword tigrcView ' . join(s:keywords) 'contained nextgroup=tigrcViewAssign skipwhite'
endfor

syntax region tigrcViewAssign matchgroup=Operator start=/\s\+\zs=\ze\s\+/ skip=/\\$/ excludenl end=/$/ contains=tigrcColumn,tigrcColumnOption,@tigrcColumnValue,tigrcComment
" }}}

" values {{{
syntax match tigrcColumn excludenl /\<\(author\|commit-title\|date\|file-name\|file-size\|id\|line-number\|mode\|ref\|status\|text\)\ze\(:\|\s\|$\)/ contained nextgroup=tigrcColumnOption

syntax match tigrcColumnOption /:\zs/ contained nextgroup=@tigrcColumnValue
syntax match tigrcColumnOption excludenl /\(:\|,\)\=\zs\(display\|width\|maxwidth\|graph\|refs\|overflow\|local\|format\|interval\|commit-title-overflow\)\ze=/ contained nextgroup=@tigrcColumnValue

syntax cluster tigrcColumnValue contains=tigrcBoolean,tigrcNumber,tigrcEnum,tigrcString

syntax keyword tigrcBoolean 1 true yes 0 false no contained

syntax match tigrcNumber /\<\d\+\>/ contained

syntax keyword tigrcEnum ascii default utf-8 auto all some at-eol topo author-date reverse smart-case manual after-command periodic full abbreviated email-user email v1 v2 relative-compact relative custom always units short long head tag local-tag remote tracked-remote replace branch stash other contained
" `date` is also one of column name.
syntax match tigrcEnum /\<date\>\ze[^:]/
" For `set reference-format`
syntax match tigrcEnum /\<hide\ze:\(\w\|-\)\+\>/ contained

syntax region tigrcString matchgroup=Delimiter start=/"/ skip=/\\"/ end=/"/ contained
syntax region tigrcString matchgroup=Delimiter start=/'/ end=/'/ contained
" }}}
" }}}

" bind {{{
" bind keymap key action
syntax region tigrcBind matchgroup=Keyword start=/\<bind\>/ skip=/\\$/ end=/$/ contains=tigrcKeymap,tigrcKey,tigrcActionName,@tigrcAction,tigrcComment

syntax keyword tigrcKeymap main diff log reflog help pager status stage tree blob blame refs stash grep generic search contained nextgroup=tigrcKey skipwhite

syntax case ignore
syntax match tigrcKey /\s\+\zs\(<Esc>\)\=\S\ze\s\+\|<Ctrl-\S>\|\(<\(Enter\|Space\|Backspace\|Tab\|Escape\|Esc\|Left\|Right\|Up\|Down\|Insert\|Ins\|Delete\|Del\|Hash\|LessThan\|LT\|Home\|End\|PageUp\|PgUp\|PageDown\|PgDown\|ScrollBack\|SBack\|ScrollFwd\|SFwd\|ShiftTab\|BackTab\|ShiftLeft\|ShiftRight\|ShiftDelete\|ShiftDel\|ShiftHome\|ShiftEnd\|SingleQuote\|DoubleQuote\|F1\=\d\)>\)/ contained nextgroup=@tigrcAction skipwhite

syntax cluster tigrcAction contains=tigrcActionName,tigrcExternalAction

syntax match tigrcActionName /\<:\=\zs\(view\%(-\|_\|.\)main\|view\%(-\|_\|.\)diff\|view\%(-\|_\|.\)log\|view\%(-\|_\|.\)reflog\|view\%(-\|_\|.\)tree\|view\%(-\|_\|.\)blob\|view\%(-\|_\|.\)blame\|view\%(-\|_\|.\)refs\|view\%(-\|_\|.\)status\|view\%(-\|_\|.\)stage\|view\%(-\|_\|.\)stash\|view\%(-\|_\|.\)grep\|view\%(-\|_\|.\)pager\|view\%(-\|_\|.\)help\|enter\|back\|next\|previous\|parent\|view\%(-\|_\|.\)next\|refresh\|maximize\|view\%(-\|_\|.\)close\|view\%(-\|_\|.\)close\%(-\|_\|.\)no\%(-\|_\|.\)quit\|quit\|status\%(-\|_\|.\)update\|status\%(-\|_\|.\)revert\|status\%(-\|_\|.\)merge\|stage\%(-\|_\|.\)update\%(-\|_\|.\)line\|stage\%(-\|_\|.\)update\%(-\|_\|.\)part\|stage\%(-\|_\|.\)split\%(-\|_\|.\)chunk\|move\%(-\|_\|.\)up\|move\%(-\|_\|.\)down\|move\%(-\|_\|.\)page\%(-\|_\|.\)up\|move\%(-\|_\|.\)page\%(-\|_\|.\)down\|move\%(-\|_\|.\)half\%(-\|_\|.\)page\%(-\|_\|.\)up\|move\%(-\|_\|.\)half\%(-\|_\|.\)page\%(-\|_\|.\)down\|move\%(-\|_\|.\)first\%(-\|_\|.\)line\|move\%(-\|_\|.\)last\%(-\|_\|.\)line\|move\%(-\|_\|.\)next\%(-\|_\|.\)merge\|move\%(-\|_\|.\)prev\%(-\|_\|.\)merge\|scroll\%(-\|_\|.\)line\%(-\|_\|.\)up\|scroll\%(-\|_\|.\)line\%(-\|_\|.\)down\|scroll\%(-\|_\|.\)page\%(-\|_\|.\)up\|scroll\%(-\|_\|.\)page\%(-\|_\|.\)down\|scroll\%(-\|_\|.\)half\%(-\|_\|.\)page\%(-\|_\|.\)up\|scroll\%(-\|_\|.\)half\%(-\|_\|.\)page\%(-\|_\|.\)down\|scroll\%(-\|_\|.\)first\%(-\|_\|.\)col\|scroll\%(-\|_\|.\)left\|scroll\%(-\|_\|.\)right\|search\|search\%(-\|_\|.\)back\|find\%(-\|_\|.\)next\|find\%(-\|_\|.\)prev\|edit\|prompt\|options\|screen\%(-\|_\|.\)redraw\|stop\%(-\|_\|.\)loading\|show\%(-\|_\|.\)version\|none\|goto\|save\%(-\|_\|.\)display\|save\%(-\|_\|.\)options\|save\%(-\|_\|.\)view\|script\|exec\|echo\|source\|toggle\|set\)\>/ nextgroup=tigrcActionArgs skipwhite contained
syntax case match

syntax region tigrcActionArgs start=/\s*/ skip=/\\$/ excludenl end=/$\|\ze#/ contained

syntax region tigrcExternalAction matchgroup=Operator start=/\(!\|@\|+\|?\|<\|>\)\+/ skip=/\\$/ excludenl end=/$/ contained contains=tigrcStateVariable,@Sh

syntax match tigrcStateVariableName /\<\(head\|commit\|blob\|branch\|remote\|tag\|refname\|stash\|directory\|file\|file_old\|lineno\|lineno_old\|ref\|revargs\|fileargs\|cmdlineargs\|diffargs\|blameargs\|logargs\|mainargs\|prompt\|text\|repo:head\|repo:head-id\|repo:remote\|repo:cdup\|repo:prefix\|repo:git-dir\|repo:worktree\|repo:is-inside-work-tree\)\>/ contained
syntax match tigrcStateVariable /%(.\+)/ transparent contains=tigrcStateVariableName contained
" }}}

" color {{{
" color area fgcolor bgcolor [attributes]
syntax region tigrcColor matchgroup=Keyword start=/\<color\>/ skip=/\\$/ end=/$/ contains=tigrcArea,tigrcAreaString,tigrcColorFgBg,tigrcAttribute,tigrcComment

syntax case ignore

syntax match tigrcColorFgBg excludenl /\w\+\(\s\|\\$\)\+\w\+/ transparent contains=@tigrcColorName contained

syntax cluster tigrcColorName contains=tigrcColorNameDefault
syntax keyword tigrcColorNameDefault default contained

for s:color in ['White', 'Black', 'Green', 'Magenta', 'Blue', 'Cyan', 'Yellow', 'Red']
  execute 'syntax keyword tigrcColorName' . s:color s:color 'contained nextgroup=@tigrcColorName,tigrcAttribute'
  execute 'highlight tigrcColorName' . s:color 'ctermfg=' . s:color
  execute 'syntax cluster tigrcColorName add=tigrcColorName' . s:color
endfor

for s:i in range(0, 255)
  execute 'syntax keyword tigrcColorNameColor' . s:i 'color' . s:i 'contained nextgroup=@tigrcColorName,tigrcAttribute'
  execute 'syntax keyword tigrcColorNameColor' . s:i s:i 'contained nextgroup=@tigrcColorName,tigrcAttribute'
  execute 'highlight tigrcColorNameColor' . s:i 'ctermfg=' . s:i
  execute 'syntax cluster tigrcColorName add=tigrcColorNameColor' . s:i
endfor

syntax keyword tigrcAttribute normal blink bold dim reverse standout underline contained

syntax match tigrcArea /\(\w\+\.\)\=\w\+/ transparent contains=tigrcUiArea,tigrcAreaView nextgroup=tigrcColorFgBg skipwhite contained

execute 'syntax keyword tigrcAreaView' join(s:views) 'contained'

syntax region tigrcAreaString matchgroup=Delimiter start=/"/ skip=/\\"/ end=/"/ nextgroup=tigrcColorFgBg skipwhite contained
syntax region tigrcAreaString matchgroup=Delimiter start=/'/ end=/'/ nextgroup=tigrcColorFgBg skipwhite contained

syntax case match
" }}}

" source {{{
" source path
syntax region tigrcSource matchgroup=Keyword start=/\<source\>/ skip=/\\$/ end=/$/ contains=tigrcSourceOption,tigrcComment
syntax match tigrcSourceOption /-q/ contained
" }}}

" misc {{{
syntax match tigrcComment excludenl /#.*$/ contains=tigrcTodo,@Spell
syntax keyword tigrcTodo TODO FIXME XXX NB NOTE contained
" }}}
" }}}

" Highlights {{{
" general
highlight default link tigrcUiArea Identifier

" set
highlight default link tigrcVariable Identifier
highlight default link tigrcColumn Function
highlight default link tigrcGitColor Special
highlight default link tigrcView Identifier
highlight default link tigrcStateVariableName Identifier
highlight default link tigrcColumnOption Special
highlight default link tigrcBoolean Boolean
highlight default link tigrcEnum Boolean
highlight default link tigrcNumber Number
highlight default link tigrcString String

" bind
highlight default link tigrcKeymap Identifier
highlight default link tigrcKey Special
highlight default link tigrcActionName Function

" color
highlight default link tigrcAttribute Special
highlight default link tigrcAreaView Identifier
highlight default link tigrcColorNameDefault Constant
highlight default link tigrcAreaString String

" source
highlight default link tigrcSourceOption Special

" comment
highlight default link tigrcComment Comment
highlight default link tigrcTodo Todo
" }}}

let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions

" vim: set expandtab tabstop=2 shiftwidth=2 foldmethod=marker :
