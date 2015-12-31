PY=python3
PELICAN=pelican
PELICANOPTS=
PORT=8800

BASEDIR=$(CURDIR)
INPUTDIR=$(BASEDIR)/content
OUTPUTDIR=$(BASEDIR)/output
CONFFILE=$(BASEDIR)/pelicanconf.py
PUBLISHCONF=$(BASEDIR)/publishconf.py

SSH_HOST=metauser.net
SSH_PORT=22

DEBUG ?= 0
ifeq ($(DEBUG), 1)
	PELICANOPTS += -D
endif

help:
	@echo 'Makefile for a pelican Web site                                        '
	@echo '                                                                       '
	@echo 'Usage:                                                                 '
	@echo '   make html                        (re)generate the web site          '
	@echo '   make clean                       remove the generated files         '
	@echo '   make regenerate                  regenerate files upon modification '
	@echo '   make publish                     generate using production settings '
	@echo '   make serve [PORT=8800]           serve site at http://localhost:8800'
	@echo '   make devserver [PORT=8800]       start/restart develop_server.sh    '
	@echo '   make stopserver                  stop local server                  '
	@echo '   make ssh_upload                  upload the web site via SSH        '
	@echo '   make rsync_upload                upload the web site via rsync+ssh  '
	@echo '                                                                       '
        @echo '   make newpost	                   Create a new blog post             '
        @echo '   make editpost                    Edit a blog post                   '
        @echo '   make newpage                     Create a new page                  '
        @echo '   make editpage                    Edit a page                        '
	@echo 'Set the DEBUG variable to 1 to enable debugging, e.g. make DEBUG=1 html'
	@echo '                                                                       '

html:
	$(PELICAN) $(INPUTDIR) -o $(OUTPUTDIR) -s $(CONFFILE) $(PELICANOPTS)

clean:
	[ ! -d $(OUTPUTDIR) ] || rm -rf $(OUTPUTDIR)

regenerate:
	$(PELICAN) -r $(INPUTDIR) -o $(OUTPUTDIR) -s $(CONFFILE) $(PELICANOPTS)

serve:
ifdef PORT
	cd $(OUTPUTDIR) && $(PY) -m pelican.server $(PORT)
else
	cd $(OUTPUTDIR) && $(PY) -m pelican.server
endif

devserver:
ifdef PORT
	$(BASEDIR)/develop_server.sh restart $(PORT)
else
	$(BASEDIR)/develop_server.sh restart
endif

stopserver:
	kill -9 `cat pelican.pid`
	kill -9 `cat srv.pid`
	rm *.pid
	@echo 'Stopped Pelican and SimpleHTTPServer processes running in background.'

publish:
	$(PELICAN) $(INPUTDIR) -o $(OUTPUTDIR) -s $(PUBLISHCONF) $(PELICANOPTS)

ssh_upload: publish
	scp -P $(SSH_PORT) -r $(OUTPUTDIR)/* $(SSH_USER)@$(SSH_HOST):$(SSH_TARGET_DIR)

rsync_upload: publish
	rsync -e "ssh -p $(SSH_PORT)" -P -rvz --delete $(OUTPUTDIR)/ $(SSH_USER)@$(SSH_HOST):$(SSH_TARGET_DIR) --cvs-exclude

PAGESDIR=$(INPUTDIR)/pages
DATE := $(shell date +'%Y-%m-%d %H:%M:%S')
SLUG := $(shell echo '${NAME}' | sed -e 's/[^[:alnum:]]/-/g' | tr -s '-' | tr A-Z a-z)
EXT ?= md

newpost:
ifdef NAME
        echo "Title: $(NAME)" >  $(INPUTDIR)/$(SLUG).$(EXT)
        echo "Slug: $(SLUG)" >> $(INPUTDIR)/$(SLUG).$(EXT)
        echo "Date: $(DATE)" >> $(INPUTDIR)/$(SLUG).$(EXT)
        echo ""              >> $(INPUTDIR)/$(SLUG).$(EXT)
        echo ""              >> $(INPUTDIR)/$(SLUG).$(EXT)
        ${EDITOR} ${INPUTDIR}/${SLUG}.${EXT} &
else
        @echo 'Variable NAME is not defined.'
        @echo 'Do make newpost NAME='"'"'Post Name'"'"
endif

editpost:
ifdef NAME
        ${EDITOR} ${INPUTDIR}/${SLUG}.${EXT} &
else
        @echo 'Variable NAME is not defined.'
        @echo 'Do make editpost NAME='"'"'Post Name'"'"
endif

newpage:
ifdef NAME
        echo "Title: $(NAME)" >  $(PAGESDIR)/$(SLUG).$(EXT)
        echo "Slug: $(SLUG)" >> $(PAGESDIR)/$(SLUG).$(EXT)
        echo ""              >> $(PAGESDIR)/$(SLUG).$(EXT)
        echo ""              >> $(PAGESDIR)/$(SLUG).$(EXT)
        ${EDITOR} ${PAGESDIR}/${SLUG}.$(EXT)
else
        @echo 'Variable NAME is not defined.'
        @echo 'Do make newpage NAME='"'"'Page Name'"'"
endif

editpage:
ifdef NAME
        ${EDITOR} ${PAGESDIR}/${SLUG}.$(EXT)
else
        @echo 'Variable NAME is not defined.'
        @echo 'Do make editpage NAME='"'"'Page Name'"'"
endif

.PHONY: html help clean regenerate serve devserver publish ssh_upload rsync_upload newpost editpost newpage editpage
