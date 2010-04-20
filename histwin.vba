" Vimball Archiver by Charles E. Campbell, Jr., Ph.D.
UseVimball
finish
doc/histwin.txt	[[[1
202
*histwin.txt*  Plugin to browse the undo-tree          - Vers 0.9  Jan 27, 2009

Author:  Christian Brabandt <cb@256bit.org>
Copyright: (c) 2009 by Christian Brabandt 		    *histwin-copyright*
           The VIM LICENSE applies to histwin.vim and histwin.txt
           (see |copyright|) except use histwin instead of "Vim".
	   NO WARRANTY, EXPRESS OR IMPLIED.  USE AT-YOUR-OWN-RISK.

==============================================================================
1. Contents                                                  *histwin-contents*

1. Contents..................................................|histwin-contents|
2. Functionality.............................................|histwin-plugin|
   Opening the Undo-Tree Window..............................|histwin-browse|
3. Keybindings...............................................|histwin-keys|
4. Configuration.............................................|histwin-config|
   Configuraion Variables....................................|histwin-var|
   Color Configuration.......................................|histwin-syntax|
5. History...................................................|histwin-history|

==============================================================================
                                                              *histwin-plugin*
2. Functionality

This plugin was written to allow an easy way of browsing the |undo-tree|, that
is available with Vim. This allows to go back to any change that has been made
previously, because these states are remembered by Vim within a branch in the
undo-history. You can use |g-| or |g+| to move in Vim within the different
undo-branches.

Unfortunately, going back to any state isn't very comfortable and you always
need to remember at what time you did that change. Therefore the histwin-Plugin
allows to easily view the available states and branch back to any of these
states. It opens a new window, which contains all available states and using
this plugin allows you to tag a previous change or go back to a particular
state.

                                                         *histwin-browse* *:UB*
2.1 Opening the Undo-Tree Window

By default you can open the Undo-Tree Window by issuing :UB (Mnemonic:
UndoBrowse). If you do this the first time, you will see a window that looks
like this:

+------------------------------------------------------+
|Undo-Tree: FILENAME           |#!/bin/bash            |
|======================        |                       |
|                              |                       |
|" actv. keys in this window   |if [ $# -ne 2 ];  the  |
|" I toggles help screen       |    echo "Name: $0: arg|
|" <Enter> goto undo branch    |    echo               |
|" <C-L>   Update view         |    exit 1             |
|" T	   Tag sel. branch     |fi                     |    
|" P	   Toggle view         |                       |    
|" D	   Diff sel. branch    |if true; then          |    
|" R	   Replay sel. branch  |    dir="${1%/*}"      |    
|" C	   Clear all tags      |    file="${1##*/}"    |    
|" Q	   Quit window         |    target="${2}/${di  |    
|"                             |    if [ ! -e "${targ  |
|" Undo-Tree, v0.9             |        mkdir -p "$ta  |
|                              |        mv "$1" "$tar  |
|Nr   Time    Tag              |                       |
|1) 00:00:00 /Start Editing/   |                       |
|2) 22:50:43 /First draft/     |                       |
|3) 23:01:22                   |                       |
|4) 23:02:57                   |                       |
|5) 23:05:04                   |                       |
+------------------------------------------------------+

This shows an extract of a sample file on the right side. The window on the
left side, contains an overview of all available states that are known for
this buffer or that have been tagged to remember that change.

The first line contains 'Undo-Tree: filename' so that the user knows, for
which file this window shows the available undo-branches. This is the heading.

Following the heading is a small information banner, that contains the most
important key combinations, that are available in this window. 

After that list, all available undo-changes are displayed. This is a list,
that contains the number, the time this change was made, the change-number to
use with the |:undo| command (this is by default not shown), and the tags,
that have been entered. A bar shows the selected undo-branch that is active on
the right side.

Please note, that the Time for start-editing will always be shown as 00:00:00,
because currently there is no way to retrieve this time from within vim.

==============================================================================
                                                              *histwin-keys*
3. Keybindings

By default, the following keys are active in Normal mode in the Undo-Tree
window:

'Enter'  Go to the branch, on which is selected with the cursor
'<C-L>'  Update the window
'T'      Tag the branch, that is selected. You'll be prompted for a tag.
'P'      Toggle view (the change-number will be displayed). You can use this
         number to go directly to that change (see |:undo|)
'D'      Start diff mode with the branch that is selected by the cursor.
         (see |08.7|)
'R'      Replay all changes, that have been made from the beginning.
         (see |histwin-config| for adjusting the speed)
'C'      Clear all tags.
'Q'      Quit window

==============================================================================
                                                  *histwin-var* *histwin-config*
4.1 Configuration variables

You can adjust several parameters for the Undo-Tree window, by setting some
variables in your .vimrc file.

To always show only a small information banner, set this in your .vimrc
(by default this variable is 1)

:let g:undo_tree_help = 0

To have the Change number always included, set the g:undo_tree_dtl=0:
(by default, this variable is 1)

:let g:undo_tree_dtl = 0

The speed with which to show each change, when replaying a undo-branch can be
adjusted by setting to a value in milliseconds. If not specified, this is
100ms.

:let g:undo_tree_speed=200

You can adjust the windows size by setting g:undo_tree_wdth to the number of
columns you like. By default this is considered 30. When the change number is
included in the list (see above), this value will increase by 10.

:let g:undo_tree_wdth=40

This will change the width of the window to 40 or 50, if the change number
is included.

                                                                *histwin-color*
4.2 Color configuration

If you want to customize the colors, you can simply change the following
groups, that are defined by the Undo-Tree Browser:

UBTitle   this defines the color of the title file-name. By default this links
          to Title (see |hl-Title|)
UBInfo    this defines how the information banner looks like. By default this
          links to Comment.
UBList    this group defines the List items at the start e.g. 1), 2), This
          links  to Identifier.
UBTime    this defines, how the time is displayed. This links to Underlined.
UBTag     This defines, how the tag should be highlighted. By default this
          links to Special
UBDelim   This group defines the look of the delimiter for the tag. By default
          this links to Ignore
UBActive  This group defines how the active selection is displayed. By default
          this links to PmenuSel (see |hl-PmenuSel|)

Say you want to change the color for the Tag values and you think, it should
look like |IncSerch|, so you can do this in your .vimrc file:

:hi link UBTag IncSearch

==============================================================================
                			        		*histwin-history*
5. histwin History


0.9     - Error handling for Replaying (it may not work always)
        - Documentation
        - Use syntax highlighting
        - Tagging finally works
0.8     - code cleanup
        - make speed of the replay adjustable. Use g:undo_tree_speed to set
          time in milliseconds
0.7.2   - make sure, when switching to a different undo-branch, the undo-tree will be reloaded
        - check 'undolevel' settings  
0.7.1   - fixed a problem with mapping the keys which broke the Undo-Tree keys
          (I guess I don't fully understand, when to use s: and <sid>)
0.7     - created autoloadPlugin (patch by Charles Campbell) Thanks!
        - enabled GLVS (patch by Charles Campbell) Thanks!
        - cleaned up old comments
        - deleted :noautocmd which could cause trouble with other plugins
        - small changes in coding style (<sid> to s:, fun instead of fu)
        - made Plugin available as histwin.vba
        - Check for availability of :UB before defining it
          (could already by defined Blockquote.vim does for example)
0.6     - fix missing bufname() when creating the undo_tree window
        - make undo_tree window a little bit smaller
      	  (size is adjustable via g:undo_tree_wdth variable)
0.5     - add missing endif (which made version 0.4 unusuable)
0.4     - Allow diffing with selected branch
        - highlight current version
        - Fix annoying bug, that displays 
          --No lines in buffer--
0.3     - Use changenr() to determine undobranch
        - <C-L> updates view
        - allow switching to initial load state, before
          buffer was edited
==============================================================================
vim:tw=78:ts=8:ft=help
plugin/histwinPlugin.vim	[[[1
70
" histwin.vim - Vim global plugin for browsing the undo tree
" -------------------------------------------------------------
" Last Change: 2010, Jan 27
" Maintainer:  Christian Brabandt <cb@256bit.org>
" Version:     0.9
" Copyright:   (c) 2009 by Christian Brabandt
"              The VIM LICENSE applies to histwin.vim 
"              (see |copyright|) except use "histwin.vim" 
"              instead of "Vim".
"              No warranty, express or implied.
"    *** ***   Use At-Your-Own-Risk!   *** ***
"
" GetLatestVimScripts: 2932 2 :AutoInstall: histwin.vim
" TODO: - write documentation
"       - don't use matchadd for syntax highlighting but use
"         appropriate syntax highlighting rules

" Init:
if exists("g:loaded_undo_browse") || &cp || &ul == -1
  finish
endif

let g:loaded_undo_browse = 0.9
let s:cpo                = &cpo
set cpo&vim

" User_Command:
if exists(":UB") != 2
	com -nargs=0 UB :call histwin#UndoBrowse()
else
	echoerr ":UB is already defined. May be by another Plugin?"
endif

" ChangeLog:
" 0.9     - Error handling for Replaying (it may not work always)
"         - Documentation
"         - Use syntax highlighting
"         - Tagging finally works
" 0.8     - code cleanup
"         - make speed of the replay adjustable. Use g:undo_tree_speed to set
"           time in milliseconds
" 0.7.2   - make sure, when switching to a different undo-branch, the undo-tree will be reloaded
"         - check 'undolevel' settings  
" 0.7.1   - fixed a problem with mapping the keys which broke the Undo-Tree keys
"           (I guess I don't fully understand, when to use s: and <sid>)
" 0.7     - created autoloadPlugin (patch by Charles Campbell) Thanks!
"         - enabled GLVS (patch by Charles Campbell) Thanks!
"         - cleaned up old comments
"         - deleted :noautocmd which could cause trouble with other plugins
"         - small changes in coding style (<sid> to s:, fun instead of fu)
"         - made Plugin available as histwin.vba
"         - Check for availability of :UB before defining it
"           (could already by defined Blockquote.vim does for example)
" 0.6     - fix missing bufname() when creating the undo_tree window
"		  - make undo_tree window a little bit smaller
"		    (size is adjustable via g:undo_tree_wdth variable)
" 0.5     - add missing endif (which made version 0.4 unusuable)
" 0.4     - Allow diffing with selected branch
"         - highlight current version
"         - Fix annoying bug, that displays 
"           --No lines in buffer--
" 0.3     - Use changenr() to determine undobranch
"         - <C-L> updates view
"         - allow switching to initial load state, before
"           buffer was edited

" Restore:
let &cpo=s:cpo
unlet s:cpo
" vim: ts=4 sts=4 fdm=marker com+=l\:\" spell spelllang=en fdm=syntax
autoload/histwin.vim	[[[1
374
" histwin.vim - Vim global plugin for browsing the undo tree
" -------------------------------------------------------------
" Last Change: 2010, Jan 27
" Maintainer:  Christian Brabandt <cb@256bit.org>
" Version:     0.9
" Copyright:   (c) 2009 by Christian Brabandt
"              The VIM LICENSE applies to histwin.vim 
"              (see |copyright|) except use "histwin.vim" 
"              instead of "Vim".
"              No warranty, express or implied.
"    *** ***   Use At-Your-Own-Risk!   *** ***
"
" TODO: - write documentation

" Init:
let s:cpo= &cpo
set cpo&vim

" Show help banner?
" per default enabled, you can change it,
" if you set g:undobrowse_help to 0 e.g.
" put in your .vimrc
" :let g:undo_tree_help=0
let s:undo_help=((exists("s:undo_help") ? s:undo_help : 1) )"}}}
let s:undo_tree_dtl   = (exists('g:undo_tree_dtl')   ? g:undo_tree_dtl   :   1)

" Functions:
fun! s:Init()"{{{
	if exists("g:undo_tree_help")
	   let s:undo_help=g:undo_tree_help
	endif
	if !exists("s:undo_winname")
		let s:undo_winname='Undo_Tree'
	endif
	" speed, with which the replay will be played
	" (duration between each change in milliseconds)
	" set :let g:undo_tree_speed=250 in your .vimrc to override
	let s:undo_tree_speed = (exists('g:undo_tree_speed') ? g:undo_tree_speed : 100)
	let s:undo_tree_wdth  = (exists('g:undo_tree_wdth')  ? g:undo_tree_wdth  :  30)
	let s:undo_tree_dtl   = (exists('g:undo_tree_dtl')   ? g:undo_tree_dtl   :  s:undo_tree_dtl)

	if bufname('') != s:undo_winname
		let s:orig_buffer = bufnr('')
	endif
	
	" Make sure we are in the right buffer
	" and this window still exists
	if bufwinnr(s:orig_buffer) == -1
		wincmd p
		let s:orig_buffer=bufnr('')
	endif

	exe bufwinnr(s:orig_buffer) . 'wincmd w'
	" Move to the buffer, we are monitoring
	if !exists("b:undo_customtags")
		let b:undo_customtags={}
	endif
	if !exists("b:undo_dict")
	    let b:undo_dict={}
	endif
endfun "}}}

fun! s:ReturnHistList(winnr)"{{{
	redir => a
	sil :undol
	redir end
	" First item contains the header
	let templist=split(a, '\n')[1:]
	let customtags=copy(b:undo_customtags)
	let histdict={}
	" include the starting point as the first change.
	" unfortunately, there does not seem to exist an 
	" easy way to obtain the state of the first change,
	" so we will be inserting a dummy entry and need to
	" check later, if this is called.
	"if exists("b:undo_dict") && !empty(get(b:undo_dict,0,''))
		"call add(histdict, b:undo_dict[0])
"	else
"    if !has_key(b:undo_tagdict, '0')
		"let b:undo_customtags['0'] = {'number': 0, 'change': 0, 'time': '00:00:00', 'tag': 'Start Editing'}
	let histdict[0] = {'number': 0, 'change': 0, 'time': '00:00:00', 'tag': 'Start Editing'}
"	endif

	let i=1
	for item in templist
		let change	=  matchstr(item, '^\s\+\zs\d\+') + 0
		let nr		=  matchstr(item, '^\s\+\d\+\s\+\zs\d\+') + 0
		let time	=  matchstr(item, '^\%(\s\+\d\+\)\{2}\s\+\zs.*$')
		if time !~ '\d\d:\d\d:\d\d'
		   let time=matchstr(time, '^\d\+')
		   let time=strftime('%H:%M:%S', localtime()-time)
		endif
		if has_key(customtags, change)
			let tag=customtags[change].tag
			call remove(customtags,change)
		else
			let tag=''
		endif
	   let histdict[change]={'change': change, 'number': nr, 'time': time, 'tag': tag}
	   let i+=1
	endfor
	return extend(histdict,customtags,"force")
endfun "}}}

fun! s:SortValues(a,b)"{{{
	return a:a.change==a:b.change ? 0 : a:a.change > a:b.change ? 1 : -1
endfun"}}}

fun! s:HistWin()"{{{
	let undo_buf=bufwinnr('^'.s:undo_winname.'$')
	if !s:undo_tree_dtl
		let s:undo_tree_wdth+=10
	endif
	if undo_buf != -1
		exe undo_buf . 'wincmd w'
		if winwidth(0) != s:undo_tree_wdth
			exe "vert res " . s:undo_tree_wdth
		endif
	else
	execute s:undo_tree_wdth . "vsp " . s:undo_winname
	setl noswapfile buftype=nowrite bufhidden=delete foldcolumn=0 nobuflisted nospell
	let undo_buf=bufwinnr("")
	endif
	exe bufwinnr(s:orig_buffer) . ' wincmd w'
	return undo_buf
endfun "}}}

fun! s:PrintUndoTree(winnr)"{{{
	let bufname     = (empty(bufname(s:orig_buffer)) ? '[No Name]' : fnamemodify(bufname(s:orig_buffer),':t'))
	let changenr    = changenr()
	let histdict    = b:undo_tagdict
	exe a:winnr . 'wincmd w'
	let save_cursor=getpos('.')
	setl modifiable
	" silent because :%d outputs this message:
	" --No lines in buffer--
	silent %d _
	call setline(1,'Undo-Tree: '.bufname)
	put =repeat('=', strlen(getline(1)))
	put =''
	call s:PrintHelp(s:undo_help)
	if s:undo_tree_dtl
		call append('$', printf("%-*s %-9s %s", strlen(len(histdict)), "Nr", "  Time", "Tag"))
	else
		call append('$', printf("%-*s %-9s %-6s %s", strlen(len(histdict)), "Nr", "  Time", "Change", "Tag"))
	endif

	let i=1
	"for line in histdict+values(tagdict)
	let list=sort(values(histdict), 's:SortValues')
	for line in list
		let tag=line.tag
		let tag = (empty(tag) ? tag : '/'.tag.'/')
		if !s:undo_tree_dtl
			call append('$', 
			\ printf("%0*d) %8s %6.d %s", 
			\ strlen(len(histdict)), i, line['time'], line['change'],
			\ tag))
		else
			call append('$', 
			\ printf("%0*d) %8s %s", 
			\ strlen(len(histdict)), i, line['time'], 
			\ tag))
		endif
		let i+=1
	endfor
	call s:MapKeys()
	call s:HilightLines(s:GetLineNr(changenr,list)+1)
	setl nomodifiable
	call setpos('.', save_cursor)
endfun "}}}

fun! s:HilightLines(changenr)"{{{
	syn match UBTitle      '^\%1lUndo-Tree: \zs.*$'
	syn match UBInfo       '^".*$'
	syn match UBList       '^\d\+\ze'
	syn match UBTime       '\d\d:\d\d:\d\d' "nextgroup=UBDelimStart
	syn region UBTag matchgroup=UBDelim start='/' end='/$' keepend
	if a:changenr 
		exe 'syn match UBActive "^0*'.a:changenr.')[^/]*"'
	endif

	hi def link UBTitle			 Title
	hi def link UBInfo	 		 Comment
	hi def link UBList	 		 Identifier
	hi def link UBTag	 		 Special
	hi def link UBTime	 		 Underlined
	hi def link UBDelim			 Ignore
	hi def link UBActive		 PmenuSel
endfun "}}}

fun! s:PrintHelp(...)"{{{
	let mess=['" actv. keys in this window']
	call add(mess, '" I toggles help screen')
	if a:1
		call add(mess, "\" <Enter> goto undo branch")
		call add(mess, "\" <C-L>\t  Update view")
		call add(mess, "\" T\t  Tag sel. branch")
		call add(mess, "\" P\t  Toggle view")
		call add(mess, "\" D\t  Diff sel. branch")
		call add(mess, "\" R\t  Replay sel. branch")
		call add(mess, "\" C\t  Clear all tags")
		call add(mess, "\" Q\t  Quit window")
		call add(mess, '"')
		call add(mess, "\" Undo-Tree, v" . string(g:loaded_undo_browse))
	endif
	call add(mess, '')
	call append('$', mess)
endfun "}}}

fun! s:DiffUndoBranch(change)"{{{
	let prevchangenr=<sid>UndoBranch()
	let buffer=getline(1,'$')
	exe ':u ' . prevchangenr
	exe ':botright vsp '.tempname()
	call setline(1, bufname(s:orig_buffer) . ' undo-branch: ' . a:change)
	call append('$',buffer)
	silent w!
	diffthis
	exe bufwinnr(s:orig_buffer) . 'wincmd w'
	diffthis
endfun "}}}

fun! s:ReturnTime()"{{{
	return matchstr(getline('.'),'^\d\+)\s\+\zs\d\d:\d\d:\d\d\ze\s')
endfun"}}}

fun! s:ReturnItem(time, histdict)"{{{
	for [key, item] in items(a:histdict)
		if item['time'] == a:time
			return key
		endif
	endfor
	return ''
endfun"}}}

fun! s:GetLineNr(changenr,list)"{{{
	let i=0
	for item in a:list
	    if item['change'] == a:changenr
		   return i
		endif
		let i+=1
	endfor
	return -1
endfun!"}}}

fun! s:ReplayUndoBranch()"{{{
	let time	   =  s:ReturnTime()
	exe bufwinnr(s:orig_buffer) . ' wincmd w'
	let change_old = changenr()
	let key        =  s:ReturnItem(time, b:undo_tagdict)
	if empty(key)
	   echo "Nothing to do"
	endif
	try
		exe ':u '     . b:undo_tagdict[key]['change']
		exe 'earlier 99999999'
		redraw
		while changenr() < b:undo_tagdict[key]['change']
			red
			redraw
			exe ':sleep ' . s:undo_tree_speed . 'm'
		endw
	"catch /Undo number \d\+ not found/
	catch /Vim(undo):Undo number \d\+ not found/
		exe ':u ' . change_old
	    echohl WarningMsg | echo "Replay not possible\nDid you reload the file?" |echohl Normal
	endtry
endfun "}}}

fun! s:ReturnBranch()"{{{
	return matchstr(getline('.'), '^\d\+\ze')+0
endfun "}}}

fun! s:ToggleHelpScreen()"{{{
	let s:undo_help=!s:undo_help
	exe bufwinnr(s:orig_buffer) . ' wincmd w'
	call s:PrintUndoTree(s:HistWin())
endfun "}}}

fun! s:ToggleDetail()"{{{
	let s:undo_tree_dtl=!s:undo_tree_dtl
	call s:PrintUndoTree(s:HistWin())
endfun "}}}

fun! s:UndoBranchTag(change, time)"{{{
""	exe bufwinnr(s:orig_buffer) . 'wincmd w'
"	let changenr=changenr()
"    exe b:undo_win . 'wincmd w'

	let tags       =  getbufvar(s:orig_buffer, 'undo_tagdict')
	let cdict	   =  getbufvar(s:orig_buffer, 'undo_customtags')
	let key        =  s:ReturnItem(a:time, tags)
	if empty(key)
		return
	endif
	call inputsave()
	let tag=input("Tagname " . a:change . ": ", tags[key]['tag'])
	call inputrestore()

	let cdict[key]	 		 = {'tag': tag, 'number': 0, 'time': strftime('%H:%M:%S'), 'change': key}
	"let tags[changenr]		 = {'tag': cdict[changenr][tag], 'change': changenr, 'number': tags[key]['number'], 'time': tags[key]['time']}
	let tags[key][tag]		 = tag
	call setbufvar(s:orig_buffer, 'undo_tagdict', tags)
	call setbufvar(s:orig_buffer, 'undo_customtags', cdict)
	call s:PrintUndoTree(s:HistWin())
endfun "}}}

fun! s:UndoBranch()"{{{
	let dict			 =	 getbufvar(s:orig_buffer, 'undo_tagdict')
	let cur_changenr	 =	 changenr()
	let key=s:ReturnItem(s:ReturnTime(),dict)
	if empty(key)
		echo "Nothing to do"
	endif
	exe bufwinnr(s:orig_buffer) . 'wincmd w'
	" Save cursor pos
	let cpos = getpos('.')
	let cmd=''
	let cur_changenr=changenr()
	let list=sort(values(b:undo_tagdict), 's:SortValues')
	let len = len(b:undo_tagdict)
	" if len==1, then there is no
	" undo branch available, which means
	" we can't undo anyway
	if key==0
	   " Jump back to initial state
		"let cmd=':earlier 9999999'
		:u1 
		:norm 1u
	else
		exe ':u '.dict[key]['change']
	endif
	" this might have changed, so we return to the old cursor
	" position. This could still be wrong, so
	" So this is our best effort approach.
	call setpos('.', cpos)
	return cur_changenr
endfun "}}}

fun! s:MapKeys()"{{{
	nnoremap <script> <silent> <buffer> I     :<C-U>silent :call <sid>ToggleHelpScreen()<CR>
	nnoremap <script> <silent> <buffer> P     :<C-U>silent :call <sid>ToggleDetail()<CR>:call histwin#UndoBrowse()<CR>
	nnoremap <script> <silent> <buffer> <CR>  :<C-U>silent :call <sid>UndoBranch()<CR>:call histwin#UndoBrowse()<CR>
	nnoremap <script> <silent> <buffer> T     :call <sid>UndoBranchTag(<sid>ReturnBranch(),<sid>ReturnTime())<CR>:call histwin#UndoBrowse()<CR>
	nnoremap <script> <silent> <buffer> D     :<C-U>silent :call <sid>DiffUndoBranch(<sid>ReturnBranch())<CR>
	nnoremap <script> <silent> <buffer> <C-L> :<C-U>silent :call histwin#UndoBrowse()<CR>
	nnoremap <script> <buffer>			R     :<C-U>call <sid>ReplayUndoBranch()<CR>
	nnoremap <script> <silent> <buffer> C     :call <sid>ClearTags()<CR>:call histwin#UndoBrowse()<CR>
	nnoremap <script> <silent> <buffer> Q     :<C-U>q<CR>
endfun "}}}

fun! s:ClearTags()"{{{
	exe bufwinnr(s:orig_buffer) . 'wincmd w'
	let b:undo_customtags={}
endfun"}}}


fun! histwin#UndoBrowse()"{{{
	if &ul != -1
		call s:Init()
		let b:undo_win  = s:HistWin()
		let b:undo_tagdict=s:ReturnHistList(bufwinnr(s:orig_buffer))
		call s:PrintUndoTree(b:undo_win)
	else
		echoerr "Undo has been disabled. Check your undolevel setting!"
	endif
endfun "}}}

" Restore:
let &cpo=s:cpo
unlet s:cpo
" vim: ts=4 sts=4 fdm=marker com+=l\:\" spell spelllang=en
