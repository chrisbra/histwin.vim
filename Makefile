SCRIPT=plugin/histwinPlugin.vim autoload/histwin.vim
DOC=doc/histwin.txt
PLUGIN=histwin

.PHONY : $(PLUGIN).vba

all: $(PLUGIN) vimball

dist-clean: clean

vimball: $(PLUGIN).vba

clean:
	rm -rf *.vba */*.orig *.~* .VimballRecord doc/tags

install:
	vim -N -c':so %' -c':q!' ${PLUGIN}.vba

uninstall:
	vim -N -c':RmVimball ${PLUGIN}.vba'

undo:
	for i in */*.orig; do mv -f "$$i" "$${i%.*}"; done


histwin.vba:
	vim -N -c 'ru! vimballPlugin.vim' -c ':let g:vimball_home=getcwd()'  -c ':call append("0", ["plugin/histwinPlugin.vim", "autoload/histwin.vim", "doc/histwin.txt"])' -c '$$d' -c ':%MkVimball ${PLUGIN}' -c':q!'

histwin:
	rm -f ${PLUGIN}.vba
	perl -i.orig -pne 'if (/Version:/) {s/\.(\d+)/sprintf(".%d", 1+$$1)/e}' ${SCRIPT}
	perl -i -pne 'if (/^let g:loaded_undo_browse/) {s/\.(\d+)/sprintf(".%d", 1+$$1)/e}' ${SCRIPT}
	perl -i -pne 'if (/GetLatestVimScripts:/) {s/(\d+)\s+:AutoInstall:/sprintf("%d :AutoInstall:", 1+$$1)/e}' ${SCRIPT}
	perl -i -pne 'if (/Last Change:/) {s/(:\s+).*\n/sprintf(": %s", `date -R`)/e}' ${SCRIPT}
	perl -i.orig -pne 'if (/Version:/) {s/\.(\d+).*\n/sprintf(".%d %s", 1+$$1, `date -R`)/e}' ${DOC}
