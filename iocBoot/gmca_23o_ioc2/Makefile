TOP = ../..
include $(TOP)/configure/CONFIG
ARCH = vxWorks-ppc604_long
IOCS_APPL_TOP = /ioc/xxx2
TARGETS = cdCommands
include $(TOP)/configure/RULES.ioc

### Sergey:
buildInstall: localbuild
build: localbuild
install: localbuild
clean: localclean

### If no arguments after "-t $(IOCS_APPL_TOP)", all definitions from local RELEASE are included:
localbuild:
	$(PERL) ./generateEnvIOC.pl -a $(ARCH) -t $(IOCS_APPL_TOP) GMCA AUTOSAVE CALC MCA SSCAN STD TPMAC VXSTATS

localclean:
	rm -f iocEnv
