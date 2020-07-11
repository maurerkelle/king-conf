# -*- coding: utf-8; mode: makefile; -*-
MACHINE = PUCK
OS 	= OPENBSD
GPP	= ./gpp -DOS=$(OS) -DMACHINE=$(MACHINE)


all:
.if ($(OS) == "OPENBSD")
# TODO: make this a phony "help" target and all means all
	@echo OS: $(OS)
	@echo MACHINE: $(MACHINE)
	@echo GPP: $(GPP)
	@echo "Targets: gpp xsession xres i3 emacs bashrc profile"
.endif



# GPP PREPROCESSOR =============================================================
gpp: gpp.c
	$(CC) -o gpp $< 


# Session Files ================================================================
.if ($(OS) == "OPENBSD")
xsession: $(HOME)/.xsession
$(HOME)/.xsession: _xsession
	install -b _xsession $(HOME)/.xsession
.endif


# Xresources ===================================================================
xres: $(HOME)/.Xresources
$(HOME)/.Xresources: _Xresources
	install -b _Xresources $(HOME)/.Xresources



# i3 ============================================================================
i3: $(HOME)/.config/i3/config
$(HOME)/.config/i3/config: _i3_config.out
	install -b _i3_config.out $(HOME)/.config/i3/config
_i3_config.out: _i3_config.in gpp
	$(GPP) _i3_config.in -o _i3_config.out



# # fvwm =========================================================================
# fvwm: $(HOME)/.fvwm/config
# $(HOME)/.fvwm/config: _fvwmrc
# 	install -b _fvwmrc $(HOME)/.fvwm/config


# EMACS ========================================================================
emacs: $(HOME)/.emacs.d/init.el
$(HOME)/.emacs.d/init.el: _emacs.d/init.el
	install -b _emacs.d/init.el $(HOME)/.emacs.d/init.el


# BASHRC =======================================================================
bashrc: $(HOME)/.bashrc gpp
_bashrc.out: _bashrc.in
	$(GPP) _bashrc.in -o $@
$(HOME)/.bashrc: _bashrc.out
	install -b _bashrc.out $(HOME)/.bashrc


# PROFILE =======================================================================
profile: $(HOME)/.profile
$(HOME)/.profile: _profile
	install -b _profile $(HOME)/.profile


# bckpit =======================================================================
bckbee: $(HOME)/bin/bckbee
$(HOME)/bin/bckbee: bckbee.sh
	install -b bckbee.sh $@
	chmod +x $@

# CLEAN +=======================================================================

clean:
	rm -f *.out *~ *.o gpp

.PHONY: clean
