" Vimball Archiver by Charles E. Campbell, Jr., Ph.D.
UseVimball
finish
plugin/histwinPlugin.vim	[[[1
60
" histwin.vim - Vim global plugin for browsing the undo tree {{{1
" -------------------------------------------------------------
" Last Change: Mon, 15 Aug 2011 10:37:51 +0200
" Maintainer:  Christian Brabandt <cb@256bit.org>
" Version:     0.25
" Copyright:   (c) 2009, 2010 by Christian Brabandt
"              The VIM LICENSE applies to histwin.vim 
"              (see |copyright|) except use "histwin.vim" 
"              instead of "Vim".
"              No warranty, express or implied.
"    *** ***   Use At-Your-Own-Risk!   *** ***
"
" GetLatestVimScripts: 2932 18 :AutoInstall: histwin.vim

" Init: {{{2
if exists("g:loaded_undo_browse") || &cp || &ul == -1
  finish
endif

let g:loaded_undo_browse = 0.25
let s:cpo                = &cpo
set cpo&vim

fun! WarningMsg(msg) "{{{2
	let msg = "histwin: " . a:msg
	echomsg msg
	let v:errmsg = msg
endfun "}}}
" Check version "{{{2
if v:version < 703
	call WarningMsg("This plugin requires Vim 7.3 or higher")
	finish
endif

" Enable displaying the differences with Signs
if exists("g:undo_tree_highlight_changes") &&
			\ g:undo_tree_highlight_changes == 1
	call histwin#PreviewAuCmd(1)
endif

" User_Command: {{{2
if exists(":UB") != 2
	com -nargs=0 UB :call histwin#UndoBrowse()
	com -nargs=0 Histwin :UB
else
	call WarningMsg("UB is already defined. May be by another Plugin?")
endif " }}}

if exists(":HistID") != 2
	com -nargs=0 HistID :call histwin#SignChanges(1)
else
	call WarningMsg("HistID is already defined. May be by another Plugin?")
endif " }}}

" ChangeLog: {{{2
" see :h histwin-history
" Restore: {{{2
let &cpo=s:cpo
unlet s:cpo
" vim: ts=4 sts=4 fdm=marker com+=l\:\" fdm=syntax
autoload/histwin.vim	[[[1
1075
" histwin.vim - Vim global plugin for browsing the undo tree
" -------------------------------------------------------------
" Last Change: Mon, 15 Aug 2011 10:37:51 +0200
" Maintainer:  Christian Brabandt <cb@256bit.org>
" Version:     0.25
" Copyright:   (c) 2009, 2010 by Christian Brabandt
"              The VIM LICENSE applies to histwin.vim 
"              (see |copyright|) except use "histwin.vim" 
"              instead of "Vim".
"              No warranty, express or implied.
"    *** ***   Use At-Your-Own-Risk!   *** ***
"    TODO:     - make tags permanent (needs patch for Vim)
"              - Bugfix: Sometimes the histwin window contains invalid data,
"                        not sure how to reproduce it. Closing and reoping is
"                        the workaround.
"
" Init: {{{1
let s:cpo= &cpo
set cpo&vim

" Show help banner?
" per default enabled, you can change it,
" if you set g:undobrowse_help to 0 e.g.
" put in your .vimrc
" :let g:undo_tree_help=0
let s:undo_help=((exists("s:undo_help") ? s:undo_help : 1) )
" This is a little bit confusing. If the variable is set to zero then the
" detailed view will be shown. If it is set to 1 the short view will be
" displayed.
let s:undo_tree_dtl   = (exists('g:undo_tree_dtl')   ? g:undo_tree_dtl  
			\:   (exists("s:undo_tree_dtl") ? s:undo_tree_dtl : 1))

" Functions:
" 
fun! s:Init()"{{{1
	if exists("g:undo_tree_help")
	   let s:undo_help=g:undo_tree_help
	endif
	if !exists("s:undo_winname")
		let s:undo_winname='Undo_Tree'
	endif
	" speed, with which the replay will be played
	" (duration between each change in milliseconds)
	" set :let g:undo_tree_speed=250 in your .vimrc to override
	let s:undo_tree_speed = (exists('g:undo_tree_speed') ?
				\g:undo_tree_speed : 100)
	" Set prefered width
	let s:undo_tree_wdth  = (exists('g:undo_tree_wdth')  ?
				\g:undo_tree_wdth  :  30)
	" Show detail with Change nr?
	let s:undo_tree_dtl   = (exists('g:undo_tree_dtl')   ?
				\g:undo_tree_dtl   :  s:undo_tree_dtl)
	" Set old versions nomodifiable
	let s:undo_tree_nomod = (exists('g:undo_tree_nomod') ?
				\g:undo_tree_nomod :   1)
	" When switching to the undotree() function, be sure to use a Vim that is
	" newer than 7.3.005
	let s:undo_tree_epoch = (v:version > 703 ||
				\(v:version == 703 && has("patch005")) ? 1 : 0)

	" Patch preview window
	let s:undo_tree_preview_aucmd = (exists('g:undo_tree_preview_aucmd') ?
				\g:undo_tree_preview_aucmd : 0)

	let s:undo_tree_signs = (exists('g:undo_tree_highlight_changes') ?
				\g:undo_tree_highlight_changes : 0)

	if !exists("s:undo_tree_wdth_orig")
		let s:undo_tree_wdth_orig = s:undo_tree_wdth
	endif
	if !exists("s:undo_tree_wdth_max")
		let s:undo_tree_wdth_max  = 50
	endif

	if bufname('') != s:undo_winname
		let s:orig_buffer = bufnr('')
	endif
	
	" Make sure we are in the right buffer
	" and this window still exists
	if bufwinnr(s:orig_buffer) == -1
		wincmd p
		let s:orig_buffer=bufnr('')
	endif

	" Move to the buffer, we are monitoring
	exe bufwinnr(s:orig_buffer) . 'wincmd w'

	" initialize the modifiable variable
	if !exists("b:modifiable")
		let b:modifiable=&l:ma
	endif

	" This needs patch 7.3.30. And even with patch 7.3.30 this may not work as
	" expected. So this is experimental.
	if !exists("b:undo_customtags")
		let fpath=fnameescape(fnamemodify(bufname('.'), ':p'))
		if exists("g:UNDO_CTAGS") && type(g:UNDO_CTAGS) == type({})
					\ && has_key(g:UNDO_CTAGS, fpath)
			let b:undo_customtags = g:UNDO_CTAGS[fpath]
		else
			let b:undo_customtags={}
		endif
	endif

	" global variable, that will be stored in the 'viminfo' file
    " TODO: Activate, when viminfo patch has been incorporated into vim
	" (currently, viminfo only stores numbers and strings, no dictionaries)
	" This is enabled with patch 7.3.30
	if !exists("g:UNDO_CTAGS") && s:undo_tree_epoch && 
				\ (v:version > 703 || (v:version == 703 && has("patch030")))
		let filename=fnameescape(fnamemodify(bufname('.'),':p'))
		let g:UNDO_CTAGS={}
		let g:UNDO_CTAGS[filename]=b:undo_customtags
		if (!s:ReturnLastChange(g:UNDO_CTAGS[filename]) <= changenr())
			unlet g:UNDO_CTAGS[filename]
			if !len(g:UNDO_CTAGS)
				unlet g:UNDO_CTAGS
			endif
		endif
	endif
endfun 

fun! histwin#WarningMsg(msg)"{{{1
	echohl WarningMsg
	let msg = "histwin: " . a:msg
	if exists(":unsilent") == 2
		unsilent echomsg msg
	else
		echomsg msg
	endif
	echohl Normal
	let v:errmsg = msg
endfun 
fun! s:ReturnHistList() "{{{1
	let histdict={}
	let customtags=copy(b:undo_customtags)
	redir => a
		sil :undol
	redir end
	" First item contains the header
	let templist=split(a, '\n')[1:]


	if s:undo_tree_epoch  " Vim > 7.3.005
		if empty(templist)
			return {}
		endif
		let ut=[]
		" Vim 7.3 introduced the undotree function, which we'll use to get all save
		" states. Unfortunately, Vim would crash, if you used the undotree()
		" function before version 7.3.005
		"
		" return a list of all the changes and then use only these changes, 
		" that are returned by the :undolist command
		" (it's hard to get the right branches, so we parse the :undolist
		" command and only take these entries (plus the first and last entry)
		let ut=s:GetUndotreeEntries(undotree().entries)
		call sort(ut, 's:SortValues')
		let templist=map(templist, 'split(v:val)[0]')
		let re = '^\%(' . join(templist, '\|') . '\)$'
		let first = ut[0]
		let first.tag='Start Editing'

		if s:undo_tree_dtl
			call filter(ut, 'v:val.change =~ re')
		else
			call filter(ut, 'v:val.change =~ re || v:val.save > 0')
		endif
		let ut= [first] + ut
			
		for item in ut
			if has_key(customtags, item.change)
				let tag=customtags[item.change].tag
				call remove(customtags,item.change)
			else
				let tag=(has_key(item, 'tag') ? item.tag : '')
			endif
			let histdict[item.change]={'change': item.change,
				\'number': item.number,
				\'time': item.time,
				\'tag': tag,
				\'save': (has_key(item, 'save') ? item.save : 0),
				\}
		endfor
		unlet item
		let first_seq = first.change
	else
		" include the starting point as the first change.
		" unfortunately, there does not seem to exist an 
		" easy way to obtain the state of the first change,
		" so we will be inserting a dummy entry and need to
		" check later, if this is called.
		let histdict[0] = {'number': 1, 'change': 0,
					\'time': '00:00:00', 'tag': 'Start Editing' ,'save':0}
		if !empty(templist)
			let first_seq = matchstr(templist[0], '^\s\+\zs\d\+')+0

			let i=1
			for item in templist
				let change	=  matchstr(item, '^\s\+\zs\d\+') + 0
				" Actually the number attribute will not be used, but we store it
				" anyway, since we are already parsing the undolist manually.
				let nr		=  matchstr(item, '^\s\+\d\+\s\+\zs\d\+') + 0
				let time	=  matchstr(item, '^\%(\s\+\d\+\)\{2}\s\+\zs.\{-}\ze\s*\d*$')
				let save	=  matchstr(item, '\s\+\zs\d\+$') + 0
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
				let histdict[change]={'change': change, 'number': nr,
							\'time': time, 'tag': tag, 'save': save}
				let i+=1
			endfor
			unlet item
		endif
	endif
	" Mark invalid entries in the customtags dictionary
	for [key,item] in items(customtags)
		if item.change < first_seq
			let customtags[key].number = -1
		endif
	endfor
	return extend(histdict,customtags,"force")
endfun

fun! s:SortValues(a,b) "{{{1
	return (a:a.change)==(a:b.change) ? 0 : (a:a.change) > (a:b.change) ? 1 : -1
endfun

fun! s:MaxTagsLen() "{{{1
	let tags = getbufvar(s:orig_buffer, 'undo_customtags')
	let d=[]
	" return a list of all tags
	let d=values(map(copy(tags), 'v:val["tag"]'))
	let d+= ["Start Editing"]
	"call map(d, 'strlen(substitute(v:val, ".", "x", "g"))')
	call map(d, 'strlen(v:val)')
	return max(d)
endfu 

fun! s:HistWin() "{{{1
	let undo_buf=bufwinnr('^'.s:undo_winname.'$')
	" Adjust size so that each tag will fit on the screen
	" 16 is just the default length, that should fit within 30 chars
	"let maxlen=s:MaxTagsLen() % (s:undo_tree_wdth_max)
	let maxlen=s:MaxTagsLen()
"	if !s:undo_tree_dtl
"		let maxlen+=20     " detailed pane
"	else
"		let maxlen+=13     " short pane
"	endif
    let rd = (!s:undo_tree_dtl ? 20 : 13)

	if maxlen > 16
		let s:undo_tree_wdth = (s:undo_tree_wdth + maxlen - rd)
					\% s:undo_tree_wdth_max
		let s:undo_tree_wdth = (s:undo_tree_wdth < s:undo_tree_wdth_orig ?
					\s:undo_tree_wdth_orig : s:undo_tree_wdth)
	endif
	" for the detail view, we need more space
	if (!s:undo_tree_dtl) 
		let s:undo_tree_wdth = s:undo_tree_wdth_orig + 10
	else
		let s:undo_tree_wdth = s:undo_tree_wdth_orig
	endif
	if undo_buf != -1
		exe undo_buf . 'wincmd w'
		if winwidth(0) != s:undo_tree_wdth
			exe "vert res " . s:undo_tree_wdth
		endif
	else
		execute ':sil! ' . s:undo_tree_wdth . "vsp " . s:undo_winname
		setl noswapfile buftype=nowrite bufhidden=delete foldcolumn=0 nobuflisted 
		let undo_buf=bufwinnr("")
	endif
	exe bufwinnr(s:orig_buffer) . ' wincmd w'
	return undo_buf
endfun

fun! s:PrintUndoTree(winnr) "{{{1
	let bufname     = (empty(bufname(s:orig_buffer)) ? '[No Name]' :
				\fnamemodify(bufname(s:orig_buffer),':t'))
	let changenr    = changenr()
	let histdict    = b:undo_tagdict
	exe a:winnr . 'wincmd w'
	setl modifiable
	" silent because :%d _ outputs this message:
	" --No lines in buffer--
	silent %d _
	call setline(1,'Undo-Tree: '.bufname)
	put =repeat('=', strlen(getline(1)))
	put =''
	call s:PrintHelp(s:undo_help)
	if s:undo_tree_dtl
		call append('$', printf("%-*s %-8s %2s %s", strlen(len(histdict)), "Nr",
			\"  Time", "Fl", "Tag"))
	else
		call append('$', printf("%-*s %-9s %-6s %-4s %2s %s",
			\strlen(len(histdict)), "Nr", "  Time", "Change", "Save",
			\"Fl", "Tag"))
	endif

	if len(histdict) == 0
		call append('$', "\" No undotree available")
		let list=[]
	else
		let i=1
		let list=sort(values(histdict), 's:SortValues')
		for line in list
			if s:undo_tree_dtl && line.number==0
				continue
			endif
			let tag=line.tag
			" this is only an educated guess.
			" This should be calculated
			let width=winwidth(0) -  (!s:undo_tree_dtl ? 22 : 14)
			if strlen(tag) > width
				let tag=substitute(tag, '.\{'.width.'}', '&\r', 'g')
			endif
			let tag = (empty(tag) ? tag : '/'.tag.'/')
			if !s:undo_tree_dtl
				call append('$', 
				\ printf("%0*d) %8s %6d %4d %1s %s", 
				\ strlen(len(histdict)), i, 
				\ (s:undo_tree_epoch ?
				\ localtime() - line['time'] > 24*3600 ? strftime('%b %d',
					\ line['time']) : strftime('%H:%M:%S', line['time']) :
				\ line['time']),
				\ line['change'], line['save'], 
				\ (line['number']<0 ? '!' : ' '),
				\ tag))
			else
				call append('$', 
				\ printf("%0*d) %8s %1s %s", 
				\ strlen(len(histdict)), i,
				\ (s:undo_tree_epoch ?
				\ localtime() - line['time'] > 24*3600 ? strftime('%b %d',
				\ line['time']) : strftime('%H:%M:%S', line['time']) :
				\ line['time']),
				\ (line['number']<0 ? '!' : (line['save'] ? '*' : ' ')),
				\ tag))
				" DEBUG Version:
	"			call append('$', 
	"			\ printf("%0*d) %8s %1s%1s %s %s", 
	"			\ strlen(len(histdict)), i,
	"			\ localtime() - line['time'] > 24*3600 ? strftime('%b %d',
	"			\ line['time']) : strftime('%H:%M:%S', line['time']),
	"			\(line['save'] ? '*' : ' '),
	"			\(line['number']<0 ? '!' : ' '),
	"			\ tag, line['change']))
			endif
			let i+=1
		endfor
		%s/\r/\=submatch(0).repeat(' ', match(getline('.'), '\/')+1)/eg
	endif
	call s:HilightLines(s:GetLineNr(changenr,list)+1)
	norm! zb
	setl nomodifiable
endfun

fun! s:HilightLines(changenr)"{{{1
	syn match UBTitle      '^\%1lUndo-Tree: \zs.*$'
	syn match UBInfo       '^".*$' contains=UBKEY
	syn match UBKey        '^"\s\zs\%(\(<[^>]*>\)\|\u\)\ze\s'
	syn match UBList       '^\d\+\ze' nextgroup=UBDate,UBTime
	syn match UBDate       '\w\+\s\d\+\ze'
	syn match UBTime       '\d\d:\d\d:\d\d' "nextgroup=UBDelimStart
	syn region UBTag matchgroup=UBDelim start='/' end='/$' keepend
	if a:changenr 
		let search_pattern = '^0*'.a:changenr.')[^/]*'
		"exe 'syn match UBActive "^0*'.a:changenr.')[^/]*"'
		exe 'syn match UBActive "' . search_pattern . '"'
		" Put cursor on the active tag
		call search(search_pattern, 'cW')
	endif

	hi def link UBTitle			 Title
	hi def link UBInfo	 		 Comment
	hi def link UBList	 		 Identifier
	hi def link UBTag	 		 Special
	hi def link UBTime	 		 Underlined
	hi def link UBDate	 		 Underlined
	hi def link UBDelim			 Ignore
	hi def link UBActive		 PmenuSel
	hi def link UBKey            SpecialKey
endfun

fun! s:PrintHelp(...) "{{{1
	let mess=['" actv. keys in this window']
	call add(mess, '" I toggles help screen')
	if a:1
		call add(mess, "\" <Enter> goto undo branch")
		call add(mess, "\" <C-L>\t  Update view")
		call add(mess, "\" T\t  Tag sel. branch")
		call add(mess, "\" P\t  Toggle view")
		call add(mess, "\" D\t  Diff sel. branch")
		call add(mess, "\" U\t  Preview unif. Diff")
		call add(mess, "\" R\t  Replay sel. branch")
		call add(mess, "\" C\t  Clear all tags")
		call add(mess, "\" Q\t  Quit window")
		call add(mess, "\" X\t  Purge Undo history")
		call add(mess, '"')
		call add(mess, "\" Undo-Tree, v" . printf("%.02f",g:loaded_undo_browse))
	endif
	call add(mess, '')
	call append('$', mess)
endfun

fun! s:DiffUndoBranch()"{{{1
	try
		let change = s:ReturnBranch()
	catch /histwin:/
		call histwin#WarningMsg("Please put the cursor on one list item,
					\when switching to a branch!")
		return
	endtry	
	let prevchangenr=<sid>UndoBranch()
	if empty(prevchangenr)
		return ''
	endif
	let cur_ft = &ft
	let buffer=getline(1,'$')
	try
		exe ':u ' . prevchangenr
		setl modifiable
	catch /Vim(undo):E830:Undo number \d\+ not found/
		call s:WarningMsg("Undo Change not found!")
		return ''
	endtry
	exe ':botright vsp '.tempname()
	call setline(1, bufname(s:orig_buffer) . ' undo-branch: ' . change)
	call append('$',buffer)
    exe "setl ft=".cur_ft
	silent w!
	diffthis
	" Fix issue 2 for histwin: http://github.com/chrisbra/histwin/issues/2
	if &splitright
		wincmd x
	endif
	exe bufwinnr(s:orig_buffer) . 'wincmd w'
	diffthis
endfun

fun! s:GetLineNr(changenr,list) "{{{1
	let i=0
	for item in a:list
		if s:undo_tree_dtl && item.number == 0
			continue
		endif
	    if item['change'] >= a:changenr
		   return i
		endif
		let i+=1
	endfor
	return -1
endfun

fun! s:ReplayUndoBranch() "{{{1
	try
		let change    =    s:ReturnBranch()
	catch /histwin:/
		call histwin#WarningMsg("Please put the cursor on one list item,
					\when replaying a branch!")
		return
    endtry	

	let tags       =  getbufvar(s:orig_buffer, 'undo_tagdict')

	if empty(tags)
		call histwin#WarningMsg("No Undotree available. Won't Replay")
		return
	endif
	let tlist      =  sort(values(tags), "s:SortValues")
	if s:undo_tree_dtl
		call filter(tlist, 'v:val.number != 0')
	endif
	let key        =  (len(tlist) > change ? tlist[change].change : '')

	if empty(key)
	   call histwin#WarningMsg("Nothing to do")
	   return
	endif
	exe bufwinnr(s:orig_buffer) . ' wincmd w'
	let change_old = changenr()
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
	catch /Vim(undo):Undo number 0 not found/
		exe ':u ' . change_old
	    call s:WarningMsg("Replay not possible for initial state")
	catch /Vim(undo):Undo number \d\+ not found/
		exe ':u ' . change_old
	    call s:WarningMsg("Replay not possible\nDid you reload the file?")
	endtry
endfun

fun! s:ReturnBranch() "{{{1
	let a=matchstr(getline('.'), '^0*\zs\d\+\ze')+0
	if a == -1
		call search('^\d\+)', 'b')
		let a=matchstr(getline('.'), '^0*\zs\d\+\ze')+0
	endif
	if a <= 0
		throw "histwin: No Branch"
		return 0
	endif
	return a-1
endfun

fun! s:ToggleHelpScreen()"{{{1
	let s:undo_help=!s:undo_help
	exe bufwinnr(s:orig_buffer) . ' wincmd w'
	call s:PrintUndoTree(s:HistWin())
endfun

fun! s:ToggleDetail() "{{{1
	let s:undo_tree_dtl=!s:undo_tree_dtl
	call histwin#UndoBrowse()
endfun 

fun! s:UndoBranchTag() "{{{1

	try
		let change     =    s:ReturnBranch()
	catch /histwin:/
		call histwin#WarningMsg("Please put the cursor on one list item,
					\ when tagging a branch!")
		return
	endtry	
	let tags       =  getbufvar(s:orig_buffer, 'undo_tagdict')
	if empty(tags)
		call histwin#WarningMsg("No Undotree available. Won't tag")
		return
	endif
	let cdict	   =  getbufvar(s:orig_buffer, 'undo_customtags')
	let tlist      =  sort(values(tags), "s:SortValues")
	if s:undo_tree_dtl
		call filter(tlist, 'v:val.number != 0')
	endif
	let key        =  (len(tlist) > change ? tlist[change].change : '')
	if empty(key)
		return
	endif
	call inputsave()
	let tag=input("Tagname " . (change+1) . ": ", tags[key]['tag'])
	call inputrestore()

	let cdict[key]	 		 = {'tag': tag,
				\'number': tags[key].number+0,
				\'time':   tags[key].time+0,
				\'change': key+0,
				\'save': tags[key].save+0}
	let tags[key]['tag']		 = tag
	call setbufvar(s:orig_buffer, 'undo_tagdict', tags)
	call setbufvar(s:orig_buffer, 'undo_customtags', cdict)
endfun

fun! s:UndoBranch() "{{{1
	let dict	=	 getbufvar(s:orig_buffer, 'undo_tagdict')
	if empty(dict)
		call histwin#WarningMsg("No Undotree available.
					\ Can't switch to a different state!")
		return
	endif
	try
		let key     =    s:ReturnBranch()
	catch /histwin:/
		call histwin#WarningMsg("Please put the cursor on one list item,
					\ when switching to a branch!")
		return
    endtry	
	let tlist      =  sort(values(dict), "s:SortValues")
	if s:undo_tree_dtl
		call filter(tlist, 'v:val.number != 0')
	endif
	let key   =  (len(tlist) > key ? tlist[key].change : '')
	if empty(key)
		call histwin#WarningMsg("Nothing to do.")
		return
	endif
	" Last line?
	if line('.') == line('$')
		let tmod = 0
	else
		let tmod = 1
	endif
	exe bufwinnr(s:orig_buffer) . 'wincmd w'
	" Save cursor pos
	let cpos = getpos('.')
	let cmd=''
	let cur_changenr=changenr()
	call <sid>MoveToChange(cur_changenr, dict[key]['change'], tmod)
"	try
"		if key==0
"		   " Jump back to initial state
"			"let cmd=':earlier 9999999'
"			:sil! :u1 
"			if !&modifiable
"				setl modifiable
"			endif
"			sil! :norm 1u
"		else
"			exe 'sil! :u '.dict[key]['change']
"		endif
"		if s:undo_tree_nomod && tmod
"			setl nomodifiable
"		else
"			setl modifiable
"		endif
"	catch /E830: Undo number \d\+ not found/
"		exe ':sil! :u ' . cur_changenr
"	    call histwin#WarningMsg("Undo Change not found.")
"		throw "histwin: abort"
"	endtry
	" this might have changed, so we return to the old cursor
	" position. This could still be wrong, 
	" So this is our best effort approach.
	call setpos('.', cpos)
	return cur_changenr
endfun

fun! s:MoveToChange(cur_change, change, nomodifiable) "{{{1
	try
		if a:change==0
		   " Jump back to initial state
			"let cmd=':earlier 9999999'
			:sil! :u1 
			if !&modifiable
				setl modifiable
			endif
			sil! :norm 1u
		else
			exe 'sil! :u' a:change
		endif
		if s:undo_tree_nomod && a:nomodifiable
			setl nomodifiable
		else
			setl modifiable
		endif
	catch /E830: Undo number \d\+ not found/
		exe ':sil! :u ' . a:cur_change
	    call histwin#WarningMsg("Undo Change not found.")
		throw "histwin: abort"
	endtry
endfun

fun! s:MapKeys() "{{{1
	nnoremap <script> <silent> <buffer> I     :<C-U>silent :call <sid>ToggleHelpScreen()<CR>
	nnoremap <script> <silent> <buffer> <C-L> :<C-U>silent :call histwin#UndoBrowse()<CR>
	nnoremap <script> <silent> <buffer> D     :<C-U>silent :call <sid>DiffUndoBranch()<CR>
	nnoremap <script> <silent> <buffer>	R     :<C-U>call <sid>ReplayUndoBranch()<CR>:silent! :call histwin#UndoBrowse()<CR>
	nnoremap <script> <silent> <buffer> Q     :<C-U>q<CR>
	nnoremap <script> <silent> <buffer> Q     :<C-U>silent :call <sid>CloseHistWin()<CR>
	nnoremap <script> <silent> <buffer> U     :<C-U>silent :call <sid>PreviewDiff()<CR>
	nnoremap <script> <silent> <buffer> <CR>  :<C-U>silent :call <sid>UndoBranch()<CR>:call histwin#UndoBrowse()<CR>
	nmap	 <script> <silent> <buffer> T     :call <sid>UndoBranchTag()<CR>:call histwin#UndoBrowse()<CR>
	nmap     <script> <silent> <buffer>	P     :<C-U>silent :call <sid>ToggleDetail()<CR><C-L>
	nmap	 <script> <silent> <buffer> C     :call <sid>ClearTags()<CR><C-L>
	nmap	 <script> <silent> <buffer> X     :call <sid>PurgeUndoHistory()<CR>
endfun "}}}
fun! s:ClearTags()"{{{1
	exe bufwinnr(s:orig_buffer) . 'wincmd w'
	let b:undo_customtags={}
	call histwin#UndoBrowse()
endfun
fun! histwin#UndoBrowse() "{{{1
	if &ul != -1
		call s:Init()
		let b:undo_win  = s:HistWin()
		call histwin#PreviewAuCmd(s:undo_tree_preview_aucmd || s:undo_tree_signs)
		let b:undo_tagdict=s:ReturnHistList()
		call s:PrintUndoTree(b:undo_win)
		call s:MapKeys()
	else
		echoerr "Histwin: Undo has been disabled. Check your undolevel setting!"
	endif
endfun 
fun! s:ReturnLastChange(histdict) "{{{1
	return max(keys(a:histdict))
endfun

fun! s:GetUndotreeEntries(entry) "{{{1
	let b=[]
	for item in a:entry
		call add(b, { 'change': item.seq, 'time': item.time, 'number': 1,
					\'save': has_key(item, 'save') ? item.save : 0})
		if has_key(item, "alt")
			call extend(b,s:GetUndotreeEntries(item.alt))
		endif
	endfor
	return b
endfun

fun! s:CloseHistWin() "{{{1
	call setbufvar(s:orig_buffer, "&ma", getbufvar(s:orig_buffer, "modifiable"))
	"exe "au! <buffer=".bufnr('')."> BufUnload *"
	aug histwin
		au!
	augroup end
	aug! histwin
	wincmd c
endfun
	
fun! histwin#PreviewAuCmd(enable) "{{{1
	call <sid>Init()
	if !exists("#histwin#BufUnload")
		aug histwin
			au! BufUnload <buffer> :call <sid>CloseHistWin()
		aug end
	endif

	if !executable('diff')
	   call histwin#WarningMsg('No diff executable found!
				   \Disabling auto commands for preview window/changed lines!')
	   return
	endif

	if !has('signs') && s:undo_tree_signs
		call histwin#WarningMsg('You vim has no +signs support. 
					\Not possible to highlight the changes.')
		return
	endif

	if a:enable && !exists("#histwin#CursorHold")
		aug histwin
			au! CursorHold <buffer>
			if (s:undo_tree_preview_aucmd)
				au! CursorHold <buffer> :call <sid>PreviewDiff()
			endif
			if s:undo_tree_signs
				au! CursorHold <buffer> :call histwin#SignChanges(0)
			endif
		aug end

	elseif exists("#histwin#CursorHold") && !a:enable
		aug histwin
			au! CursorHold <buffer>
		augroup end
		aug! histwin
	endif
endfun


fun! s:PreviewDiff() "{{{1
	let s:undo_tree_diffparam = (exists('g:undo_tree_diffparam') ?
				\ g:undo_tree_diffparam : 'diff -ua')
	   
	try
		let change = s:ReturnBranch()
	catch /histwin:/
		call histwin#WarningMsg("Please put the cursor on one list item,
					\when switching to a branch!")
		return
	endtry	
	let file_list = []

	exe bufwinnr(s:orig_buffer) 'wincmd w'

	" This is our best effort, because the line might actually not exist in a
	" previous state and this seems to confuse winsaveview.
	let oldpos = winsaveview()
	wincmd p

	let prevchangenr=<sid>UndoBranch()
	if empty(prevchangenr)
		return
	endif
	let buffer=getline(1,'$')
	try
		exe ':sil! u ' . prevchangenr
		setl modifiable
	catch /Vim(undo):Undo number \d\+ not found/
		call s:WarningMsg("Undo Change not found!")
		return
	endtry

	" write buffer contents to a temporary file, so it can be diffed
	if !exists("s:orig_buf")
		let s:orig_buf = tempname()
	endif
    call writefile(getline(1,'$'), s:orig_buf)
	call add(file_list, fnamemodify(s:orig_buf, ':p'))

	" contains the old undo version of buffer
	if !exists("s:temp_buf")
	   let s:temp_buf = fnamemodify(tempname(), ':p')
	endif
	call writefile(buffer, s:temp_buf)
	call add(file_list, s:temp_buf)

	" contains the diff
	if !exists("s:diff_buf")
	   let s:diff_buf = fnamemodify(tempname(), ':p')
	endif
	call add(file_list, s:diff_buf)
	call map(file_list, 'fnameescape(v:val)')

	call system(s:undo_tree_diffparam . ' ' . file_list[1] .
				\ ' ' . file_list[0] .  '>' . file_list[2])

	if v:shell_error == -1
		call histwin#WarningMsg("Some error occured when diffing: v:errmsg")
		return
	elseif  v:shell_error == 0
		call histwin#WarningMsg("No differences")
		exe s:HistWin() . 'wincmd w'
		return
	endif

	exe 'sil! pedit ' file_list[2]
	" restore old view
	call winrestview(oldpos)

	exe s:HistWin() . 'wincmd p'
endfun


fun! histwin#SignChanges(com) "{{{1
	if a:com
		call <sid>Init()
	endif

	" We are using the undotree() function here, so
	" this only works with Vim > 7.3.005
	if !s:undo_tree_epoch && !len(undotree().entries) 
		if a:com
			call histwin#WarningMsg("Displaying Differences marks not possible")
		endif
		" Nothing to do
		return
	endif

	let oldpos = winsaveview()
	let wwidth = winwidth(0)

	let cur_change  = changenr()
	let last_saved  = undotree()['save_last']
	let save_change = 0
	let lastline    = line('$')

	" holds the lines for changed, modifed and added lines
	let s:signs = {}
	for i in ['Add', 'Chg', 'Del']
		let s:signs[i] = []
	endfor

	let save_change=<sid>GetChangeFromSaveNr(last_saved)
	if (save_change == 0)
		call histwin#WarningMsg("Can't check hilighted lines, if the buffer 
					\hasn't been saved yet!")
		return
	endif

	let o_lz = &lz
	setl lz

	call <sid>MoveToChange(cur_change, save_change, 1)
	let buffer=getline(1,'$')

	try
		exe ':sil! u ' . cur_change
		setl modifiable
	catch /Vim(undo):Undo number \d\+ not found/
		call s:WarningMsg("Undo Change not found!")
	endtry

	" Save buffer options, that will be reset by diff mode
	let buf_opts = {}
	let buf_opts['scrollbind'] = &scrollbind
	let buf_opts['cursorbind'] = &cursorbind
	let buf_opts['scrollopt']  = &scrollopt
	let buf_opts['wrap']  = &wrap
	let buf_opts['fdm']  = &fdm
	let buf_opts['fdc']  = &fdc
	

	exe 'sil botright vsp '.tempname()

	" Now we are in the temp. buffer
	call append(0, buffer)
	sil! $d _
	
	diffthis
	noa wincmd p
	diffthis

    call <sid>CheckLines(1)

	" Back in temp buffer
	noa wincmd p
    call <sid>CheckLines(2, lastline)
	diffoff
	bw!
	" Back in original buffer
	noa wincmd p

	diffoff

	if !empty(s:signs['Add']) || !empty(s:signs['Chg'])
				\ || !empty(s:signs['Del'])
		" Place signs
		call <sid>InitSigns()
		call <sid>PlaceSigns()
	else
		" Deleted old signs anyways
		call <sid>UnPlaceSigns()
	endif

	" Reset options, that have been set by 'diff' mode
	for [opt, item] in items(buf_opts)
		let &l:opt = item
	endfor
	unlet item

	exe "vert res" wwidth
	call winrestview(oldpos)
	let &l:lz = o_lz
endfun

fun! s:InitSigns() "{{{1
	if !exists("s:signs_defined")
		sign define Histwin_Add text=+ texthl=DiffAdd
		sign define Histwin_Del text=- texthl=DiffDelete
		sign define Histwin_Chg text=* texthl=DiffChange
		let s:signs_defined=1
	endif
endfunc


fun! s:UnPlaceSigns() "{{{1
	" Unplaces all Signs defined by the histwin plugin,
	" returns a list of all signs, that must not be touched
	redir => a | exe "sil! sign place buffer=" . bufnr('') |redir end
	let signlist = split(a, "\n")[2:]
	if empty(signlist)
		" No Sings defined, return...
		return []
	endif

	for sign in signlist
		if (sign =~# 'name=Histwin')
			exe "sign unplace" substitute(sign, '^.*id=\(\d\+\).*', '\1', '')
			call remove(signlist, 0)
		endif
	endfor

	call map(signlist, 'substitute(v:val, ''^.*id=\(\d\+\).*'', ''\1'', '''')')
	return sort(signlist)

endfunc

fun! s:PlaceSigns() "{{{1
	let existingSigns = <sid>UnPlaceSigns()

	let i=1
	for [ key, linelist] in items(s:signs)
		for line in linelist
			" Check for next free id, that is not yet used for placing a sign
			if !empty(existingSigns)
				while i >= existingSigns[0]
					if (i == existingSigns[0])
						let i+=1
					endif
					call remove(existingSigns,0)
				endw
			endif
			exe "sign place " . i . " line=" . line . " name=Histwin_" . key . " buffer=" . bufnr('')
			let i+=1
		endfor
	endfor
endfunc

fun! s:CheckLines(orig, ...) "{{{1
	" a:orig == 1: check Lines in original buffer,
	" a:orig == 2: check lines in temp. buffer (we need a:1 here)
	" difference matters for DiffDelete, since syn hi for deleted Text is 
	" not available in original buffer, we need to check temp buffer
	" for added lines and set those to DiffDeleted hilighting.
	"Check lines in original buffer
	let line=1
	if  (a:orig == 1)
		while line <= line('$')
			let id=diff_hlID(line,1)
			if (id == 0)
				let line+=1
				continue
			endif

			if (id == hlID("DiffAdd"))
				call add(s:signs['Add'], line)
			elseif (id == hlID("DiffChange") || id == hlID("DiffText"))
				call add(s:signs['Chg'], line)
			endif
			let line+=1
		endw
	else
	" Check temp. window for deleted lines
	    let stop=1
		while line <= line('$')
			let id=diff_hlID(line,1)
			if (id == 0)
				let line+=1
				if !stop
					let stop=1
				endif
				continue
			endif

			if (id == hlID("DiffAdd")) && stop
				" If the deleted line is past the last line of the original
				" file, put the sign on the last line, else
				" if the deleted line is the first line, put the sign on 
				" the first line, else put it on the line above where the
				" deletion took place.
				call add(s:signs['Del'], (line > a:1 ? a:1 : line==1 ? 1 : line - 1))
				let stop=0
			endif
			let line+=1
		endw
	endif
endfun

fun s:GetChangeFromSaveNr(saved) "{{{1
	for item in undotree().entries
		if has_key(item, "save") && item.save == a:saved
			let save_change = item.seq
			break
		endif
	endfor
	return save_change
endfun

fun s:PurgeUndoHistory() "{{{1
	let _whist=winsaveview()
	exe 'noa' . bufwinnr(s:orig_buffer) . 'wincmd w'
	let _wsav=winsaveview()
	let save={}
	" Not sure, why prefixing the variables with &l: &g: not works.
	let save.ul = &g:ul
	let save.ro = &l:ro
	let save.ma = &l:ma
	let save.mod = &l:mod
	set undolevels=-1
	exe "norm! G$a \<BS>\<Esc>"
	call delete(undofile(@%))

	for [key, value] in items(save)
		call setbufvar('', '&' . key, value)
	endfor
	call winrestview(_wsav)
	redr!
	call histwin#WarningMsg(strftime('%T') . ": Undo history successully removed!")
	call histwin#UndoBrowse()
	call winrestview(_whist)
	unlet! _wsav _whist save
endfun

" Modeline and Finish stuff: {{{1
let &cpo=s:cpo
unlet s:cpo
" vim: ts=4 sts=4 fdm=marker com+=l\:\" fdl=0
doc/histwin.txt	[[[1
474
*histwin.txt*	For Vim version 7.3	Last change: 2010 Nov. 18

Author:  Christian Brabandt <cb@256bit.org>
Copyright: (c) 2009, 2010 by Christian Brabandt           *histwin-copyright*
           The VIM LICENSE applies to histwin.vim and histwin.txt
           (see |copyright|) except use histwin instead of "Vim".
           NO WARRANTY, EXPRESS OR IMPLIED.  USE AT-YOUR-OWN-RISK.

=============================================================================
1. Contents                                                 *histwin-contents*

1. Contents.................................................|histwin-contents|
2. Functionality............................................|histwin-plugin|
   Opening the Undo-Tree Window.............................|histwin-browse|
   Using tags...............................................|histwin-tags|
3. Keybindings..............................................|histwin-keys|
4. Configuration............................................|histwin-config|
   Configuraion Variables...................................|histwin-var|
   Color Configuration......................................|histwin-color|
   Undolevels settings......................................|histwin-ut|
   Configuring the preview window...........................|histwin-prev|
   Highlight changed lines..................................|histwin-highl|
5. Feedback.................................................|histwin-feedback|
6. History..................................................|histwin-history|

=============================================================================
                                                    *histwin-plugin* *histwin*
2. Functionality

This plugin was written to allow an easy way of browsing the |undo-tree|, that
is available with Vim. This allows to go back to any change that has been made
previously, because these states are remembered by Vim within a branch in the
undo-history. You can use |g-| or |g+| to move in Vim within the different
undo-branches.

Unfortunately, going back to any state isn't very comfortable and you always
need to remember at what time you did that change. Therefore the
histwin-Plugin allows to easily view the available states and branch back to
any of these states. It opens a new window, which contains all available
states and using this plugin allows you to tag a previous change or go back to
a particular state.

						*histwin-browse* *:UB* *:Histwin*
2.1 Opening the Undo-Tree Window

By default you can open the Undo-Tree Window by issuing :UB (Mnemonic:
UndoBrowse). Alternatively, you can use the command :Histwin
If you do this, you will see a window that looks like this:

+------------------------------------------------------+ `
|Undo-Tree: FILENAME           |#!/bin/bash            | `
|======================        |                       | `
|                              |                       | `
|" actv. keys in this window   |if [ $# -ne 2 ];  the  | `
|" I toggles help screen       |    echo "Name: $0: arg| `
|" <Enter> goto undo branch    |    echo               | `
|" <C-L>   Update view         |    exit 1             | `
|" T       Tag sel. branch     |fi                     | `
|" P       Toggle view         |                       | `
|" D       Diff sel. branch    |if true; then          | `
|" U       Preview unif. Diff  |                       | `
|" R       Replay sel. branch  |    dir="${1%/*}"      | `
|" C       Clear all tags      |    file="${1##*/}"    | `
|" Q       Quit window         |    target="${2}/${di  | `
|"                             |    if [ ! -e "${targ  | `
|" Undo-Tree, v0.20            |        mkdir -p "$ta  | `
|                              |        mv "$1" "$tar  | `
|Nr   Time   Fl  Tag           |                       | `
|1)   Sep 01    /Start Editing/|                       | `
|2)   Sep 01 !  /First draft/  |                       | `
|3) 23:01:22                   |                       | `
|4) 23:02:57 *  /Release 1/    |                       | `
|5) 23:05:04                   |                       | `
+------------------------------------------------------+ `

This shows an extract of a sample file on the right side. The window on the
left side, contains an overview of all available states that are known for
this buffer or that have been tagged to remember that change.

The first line contains 'Undo-Tree: filename' so that the user knows, for
which file this window shows the available undo-branches. This is the heading.

Following the heading is a small information banner, that contains the most
important key combinations, that are available in this window. 

After that list, all available undo-changes are displayed. This is a list,
that contains the number, the time this change was made, some flags and the
tags, that have been entered.

The flags can be any of '!' or '*'. The '!' indicates, that this particular
undo branch (that was probably tagged before) isn't available any more. The
'*'  indicates, if that particular undo branch has been saved before (but is
only visible in the dense view). See |histwin-ut| on why certain states might
become inaccessible and what can be done against it. 

In the detailed view, that is by default displayed, when you press 'P', the
undo branch list will possibly be much longer. That is, because in this view,
each save state will be displayed (along with it's save number). You
can imagine, that this list might become very long.

Additionally, the Change number, that identifies each change in the undo tree
will be displayed. The change number can be used with the |:undo| command to
jump to a particular change and the save number is useful with the |:earlier|
and |:later| commands. 

The active undo-branch on the right side is highlighted with the UBActive
highlighting and the cursor will be positioned on that line. Use >

:hi UBActive

to see how it will be highlighted. See also |histwin-color|.


                                                               *histwin-tags*

By default, tags that you enter will be volatile. That is, whenever you quit
Vim, these tags are lost. Currently there is no way, to store or retrieve old
tags.

This behaviour was okay, until with Vim 7.3 the new permanent undo feature was
included into Vim which makes undo information available even after restarting
Vim. Starting with Vim 7.3 it is often desirable, to also store the tag
information permanently.

There is an easy way, to store your tag information easily, though. You can
make use of the |viminfo| file, that stores states and search patterns and a
like for later use. If you include the '!' flag when setting the option, vim
will also store global variables, which then will be read back when restarting
Vim (or by use of |rviminfo|). So if you like your tags be stored permanently,
be sure, that you set your viminfo option correctly. See also 'viminfo'

(Note, Storing Dicts and Lists in the viminfo file is supported since Vim
7.3.30 and is currently an experimental feature of the histwin plugin. Since
the histwin plugin stores needs to store a nested Dictionary, Vim might still
fail reading it back correctly)

==============================================================================
                                                               *histwin-keys*
3. Keybindings

By default, the following keys are active in Normal mode in the Undo-Tree
window:

'Enter'  Go to the branch, on which is selected with the cursor. By default,
         if switching to an older branch, the buffer will be set to
         'nomodifiable'. If you don't want that, you need to set the
         g:undo_tree_nomod variable to off (see |histwin-var|).
'<C-L>'  Update the window
'T'      Tag the branch, that is selected. You'll be prompted for a tag.
         To make the tag permanent, see |histwin-tags|
'P'      Toggle view (the change-number and save number will be displayed).
         You can use this number to go directly to that change (see |:undo|).
         Additionally the saved counter will be displayed, which can be used
         to go directly to the text version of a file write using |later| or
         |earlier|.
'D'      Start diff mode with the branch that is selected by the cursor.
         (see |08.7|)
'U'      Open the preview window with a unified diff between the selected
         branch and the current state of the buffer. (This requires that a
         diff executable is found in your path, see |histwin-prev| for
         adjusting the diff-options and also for having the preview-window
         automatically opened after 'updatetime').
'R'      Replay all changes, that have been made from the beginning.
         (see |histwin-config| for adjusting the speed)
'C'      Clear all tags.
'Q'      Quit window
'X'      Purge Undo history

==============================================================================
                                                *histwin-var* *histwin-config*
4.1 Configuration variables

You can adjust several parameters for the Undo-Tree window, by setting some
variables in your .vimrc file.

------------------------------------------------------------------------------

4.1.1 Disable printing the help

To always show only a small information banner, set this in your .vimrc
(by default this variable is 1) >

    :let g:undo_tree_help = 0

------------------------------------------------------------------------------

4.1.2 Display more details

To always display the detailed view (which includes the Change number and the
file save counter), set the g:undo_tree_dtl=0:
(by default, this variable is 1) >

    :let g:undo_tree_dtl = 0

The change number can be used to directly jump to a undo state using |:undo|
and the save counter can be used to directly go to the buffer's state when the
file was written using |:earlier| and |:later|

------------------------------------------------------------------------------

4.1.3 Customize the replay speed

The speed with which to show each change, when replaying a undo-branch can be
adjusted by setting to a value in milliseconds. If not specified, this is
100ms. >

    :let g:undo_tree_speed=200

------------------------------------------------------------------------------

4.1.4 Adjust the window size.

You can adjust the windows size by setting g:undo_tree_wdth to the number of
columns you like. By default this is considered 30. When the change number is
included in the list (see above), this value will increase by 10. >

    :let g:undo_tree_wdth=40

This will change the width of the window to 40 or 50, if the change number
is included.

------------------------------------------------------------------------------

4.1.5 Read-only and writable buffer states

By default, old buffer states are set read only and you cannot modify these.
This was done, since the author of the plugin started browsing the undo
branches and started changing older versions over and over again. This is
really confusing, since you start creating even more branches and you might
end up fixing old bugs over and over.

This is what happened to the author of this plugin, so now there is a
configuration available that will set old buffers to be only read-only.
Currently, this works, by detecting, if the cursor was on the last branch in
the histwin window, and if the cursor was not on the last branch, the buffer
will be set 'nomodifiable'. You can always set the buffer to be modifiable by
issuing: >

    :setl modifiable

The default is to set the buffer read only. To disable this, you can set the
g:undo_tree_nomod variable in your |.vimrc| like this: >

    :let g:undo_tree_nomod = 0

------------------------------------------------------------------------------

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
UBKey     This group defines, how keys are displayed within the information
          banner. By default, this links to SpecialKey (see |hl-SpecialKey|)

Say you want to change the color for the Tag values and you think, it should
look like |IncSerch|, so you can do this in your .vimrc file: >

:hi link UBTag IncSearch

------------------------------------------------------------------------------

                                                               *histwin-ut*
4.3 Undolevel settings

When using Vim's |persistent-undo| feature and making many changes, you might
encounter the situation, when some of your tags will be flagged with an '!'.
This happens, when these undo-states are not available any more. This happens
especially, when making so many changes, that your 'undolevels' setting
interferes. Basically you have done so many changes, that your first changes
will already be deleted. So the obvious fix is to set the 'undolevels' setting
to a much higher value, like 10,000 or even higher. This will however increase
the memory usage quite a lot.

------------------------------------------------------------------------------
                                                                *histwin-prev*
4.4 Configuring diff options, for display in the preview-window

If you press 'U' in the histwin, the |preview-window| will open and display
a diff (by default in unified diff format) of the selected undo branch and
your buffer. This requires however, that a diff executable is found in your
path. The default paramters for the diff executable are: >

    diff -au 

This means, diff will treat all files as text (-a) and create a unified diff
(with 3 lines of unified context). You can however use your own format. If for
example you prefer context diffs, set the g:undo_tree_diffparam variable like
this in your |.vimrc|: >

    let g:undo_tree_diffparam = 'diff -c'

Note, that you need to specify the diff utility explicitly. This enables you
to even use a different tool then diff (but even then to work correctly,
you'll need a diff binary in your path).

Additionally, you can configure the histwin plugin to automatically open the
|preview-window| after 'updatetime' milliseconds have past without a key
press in Normal mode. To enable this, set the  g:undo_tree_preview_aucmd
variable in your |.vimrc| to 1 like this: >

    let g:undo_tree_preview_aucmd = 1

To disable this, simply set g:undo_tree_preview_aucmd to zero and Close and
Reopen the histwin window.

------------------------------------------------------------------------------

						    *histwin-highl*
						    *:HistID*
4.5 Highlight changed lines

The histwin plugin also allows to automatically highlight those lines, that
have been changed since the last save. It does so by placing small signs in
the first column:

  '+' This is the sign for an added line
  '-' This is the sign for a deleted line
  '*' This is the sign for a modified line

This feature needs a Vim with |+signs| support, so if this does not work for
you, check the |:version| output.

To enable this feature, set the g:undo_tree_highlight_changes variable, e.g.
in your |.vimrc| >

  :let g:undo_tree_highlight_changes=1
<
When this variable is set, Vim sets up an |CursorHold| autocommand, thatt will
check your buffer for changes against the last saved version. To disable this
feature, simply set this variable to 0.

If you don't want to have these signs put on permanently, you can also invoke
the command (:HistID, Mnemonic, IndicateDifferences) manually: >

    :HistID
<
which will place the signs in your buffer only once and is not as disturbing
as an auto command is.

==============================================================================
                                                           *histwin-feedback*
5. Feedback

Feedback is always welcome. If you like the plugin, please rate it at the
vim-page:
http://www.vim.org/scripts/script.php?script_id=2932

You can also follow the development of the plugin at github:
http://github.com/chrisbra/histwin.vim

Please don't hesitate to report any bugs to the maintainer, mentioned in the
third line of this document.

==============================================================================
                                                            *histwin-history*
6. histwin History

0.25    - fixes issue 2 from github
	  https://github.com/chrisbra/histwin/issues/2
	  (When 'splitright' is set, Diffing a previous undo branch
	  separates the window layout, reported by bootleq, thanks!)
0.24    - :ID is already defined by visincr plugin
          instead use the command :HistID
0.23    - Purge Undo history with 'X'
0.22    - Display signs for changed lines
        - |:ID|
        - small code improvements
0.21    - more standard like help files
        - make sure, the autoload script is only called when needed
	  (and not on startup)
0.20    - Enable storing the tags as Dicionary in .viminfo
          (this might not work as expected, cause we are storing a nested
          Dictionary)
        - Show a diff in the preview window when pressing P (or on autocommand
          CursorHold if enabled)
        - a little bit code cleanup (as always ;))
        - correctly catch E830 and give an error message (reported by D.
          Fishburn)
0.19    - Make sure the first entry will be tagged "Start Editing"
0.18    - don't leave the buffer in nomodifiable state (reported by Dave
          Doran)
0.17    - don't hide the initial entry (for Vim < 7.3.005)
0.16    - more bugfixing. :UB throws errors in Vim before 7.3.005 fix that
0.15    - Fixed bug when no undo-tree was available (partly by Ben Boeckel.
          Thanks!)
        - More error handling (when the cursor is not on a list item)
        - Commenting out the entry to store the histdict in a global variable,
          that should be written to the .viminfo file (but is not yet
          supported by plain vim)
0.14    - don't fix the width of the histwin window
        - now use the undotree() function by default (if patch 7.3.005 is
          included)
        - display save states in the detailed view
        - display the '!' when a state is not accessible anymore
        - fixed an annoying bug, that when jumping to a particular undo state,
          the plugin would jump to the wrong state (I hate octal mode)
        - Make displaying the time much more reliable and also don't display
          the time, if the change happened more than 24h ago (instead, display
          the date, when this change was done).
        - slightly improved error handling.
        - prepare plugin, to permantly store the undotags in the viminfo file
          (this isn't supported by a plain vanilla vim and requires a patch)
        - A major rewrite (code cleanup, better documentation)
0.13    - New version that uses Vim 7.3 persistent undo features
          |new-persistent-undo|
        - Display saved counter in detailed view
        - Display indicator for saved branches.
        - in diff mode, don't set the original buffer to be nomodifiable
          (so you can always merge chunks).
        - Check for Vim Version 7.3 (the plugin won't work with older versions
          of Vim)
0.12    - Small extension to the help file
        - generate help file with 'et' set, so the README at github looks
          better
        - Highlight the key binding using |hl-SpecialKey|
        - The help tag for the color configuration was wrong.
0.11    - Set old buffers read only (disable the setting via the 
          g:undo_tree_nomod variable
        - Make sure, Warning Messages are really displayed using :unsilent
0.10    - Fixed annoying Resizing bug
        - linebreak tags, if they are too long
        - dynamically grow the histwin window, for longer tags (up
          to a maximum)
        - Bugfix: Always indicate the correct branch
        - Added a few try/catch statements and some error handling
0.9     - Error handling for Replaying (it may not work always)
        - Documentation
        - Use syntax highlighting
        - Tagging finally works
0.8     - code cleanup
        - make speed of the replay adjustable. Use g:undo_tree_speed to set
          time in milliseconds
0.7.2   - make sure, when switching to a different undo-branch, the undo-tree
          will be reloaded
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
vim:tw=78:ts=8:ft=help:norl:
