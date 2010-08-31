" histwin.vim - Vim global plugin for browsing the undo tree
" -------------------------------------------------------------
" Last Change: Tue, 31 Aug 2010 13:58:01 +0200
" Maintainer:  Christian Brabandt <cb@256bit.org>
" Version:     0.13
" Copyright:   (c) 2009, 2010 by Christian Brabandt
"              The VIM LICENSE applies to histwin.vim 
"              (see |copyright|) except use "histwin.vim" 
"              instead of "Vim".
"              No warranty, express or implied.
"    *** ***   Use At-Your-Own-Risk!   *** ***
"
" GetLatestVimScripts: 2932 7 :AutoInstall: histwin.vim

" Init:
if exists("g:loaded_undo_browse") || &cp || &ul == -1
  finish
endif

if v:version < 703
	call histwin#WarningMsg("This plugin requires Vim 7.3 or higher")
	finish
endif

let g:loaded_undo_browse = 0.13
let s:cpo                = &cpo
set cpo&vim

" User_Command:
if exists(":UB") != 2
	com -nargs=0 UB :call histwin#UndoBrowse()
else
	call histwin#WarningMsg("UB is already defined. May be by another Plugin?")
endif

" ChangeLog:
" see :h histwin-history

" Restore:
let &cpo=s:cpo
unlet s:cpo
" vim: ts=4 sts=4 fdm=marker com+=l\:\" fdm=syntax
