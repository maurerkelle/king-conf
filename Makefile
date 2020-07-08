# -*- coding: utf-8; mode: makefile; -*-
MACHINE = PUCK
OS 	= OPENBSD
GPP	= ./gpp -DOS=$(OS) -DMACHINE=$(MACHINE)


all:
.if ($(OS) == "OPENBSD")
	@echo "Targets: xsession"
.endif


# Session Files ================================================================
.if ($(OS) == "OPENBSD")
xsession: $(HOME)/.xsession
$(HOME)/.xsession: _xsession
	install -b _xsession $(HOME)/.xsession
.endif


# xinitrc: $(HOME)/.xinitrc $(HOME)/.Xresources
# $(HOME)/.xinitrc: _xinitrc
# 	install -b _xinitrc $(HOME)/.xinitrc


# # Xresources ===================================================================
# xres: $(HOME)/.Xresources
# $(HOME)/.Xresources: _Xresources
# 	install -b _Xresources $(HOME)/.Xresources


# # fvwm =========================================================================
# fvwm: $(HOME)/.fvwm/config
# $(HOME)/.fvwm/config: _fvwmrc
# 	install -b _fvwmrc $(HOME)/.fvwm/config


# # EMACS ========================================================================
# emacs: $(HOME)/.emacs.d/init.el
# $(HOME)/.emacs.d/init.el: _emacs.d/init.el
# 	install -b _emacs.d/init.el $(HOME)/.emacs.d/init.el


# # GPP ==========================================================================
# gpp: gpp.c
# 	$(CC) -o gpp $< 


# # BASHRC =======================================================================
# bashrc: $(HOME)/.bashrc gpp
# _bashrc.out: _bashrc.in
# 	$(GPP) _bashrc.in -o $@
# $(HOME)/.bashrc: _bashrc.out
# 	install -b _bashrc.out $(HOME)/.bashrc


# # TESTCNF ======================================================================
# testcnf: $(HOME)/.testcnf gpp
# _testcnf.out: _testcnf.in
# 	$(GPP) _testcnf.in -o $@
# $(HOME)/.testcnf: _testcnf.out
# 	install -b _testcnf.out $@


# # bckpit =======================================================================
# bckpit: $(HOME)/bin/bckpit

# $(HOME)/bin/backpit: bckpit.sh
# 	install -b bckpit.sh $@
# 	chmod +x $@

# CLEAN +=======================================================================

clean:
	rm -f *.out *~ *.o gpp

.PHONY: clean
