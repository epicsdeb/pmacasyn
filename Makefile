#Makefile at top of application tree
TOP = .
include $(TOP)/configure/CONFIG
DIRS := $(DIRS) $(filter-out $(DIRS), configure)
DIRS := $(DIRS) $(filter-out $(DIRS), $(wildcard *App))
DIRS := $(DIRS) $(filter-out $(DIRS), $(wildcard *app))
#DIRS := $(DIRS) $(filter-out $(DIRS), $(wildcard iocBoot))
#DIRS := $(DIRS) $(filter-out $(DIRS), $(wildcard iocboot))
#DIRS += pmc
#DIRS += example
include $(TOP)/configure/RULES_TOP