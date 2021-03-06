### See also: bootShow, bootChange
###
### vxWorks startup script
  loginUserAdd "gmca", "RceeQSdRSb"
  loginUserDelete "vw5"
### Set shell prompt
  shellPromptSet "23b:ioc1> "

### This is routeAdd, hostAdd, hostShow, nfsMount...
#  < ../nfsCommands
# nfsAuthUnixSet "bl3dl380upper", 500, 100
# nfsMount("bl3dl380upper", "/home/gmca/epics_synApps/synApps_5_2", "/ioc")
  nfsAuthUnixSet "bl3dl380lower", 500, 100
  nfsMount("bl3dl380lower", "/home/gmca/epics_synApps/synApps_5_2", "/ioc")


### Add gateway to be visible from 23ID-in network:
### routeAdd     "destaddr",      "gateaddr"
### Route from BM-net to lab:
  routeAdd  "164.54.210.0",   "164.54.210.193"
### Route from BM-net to ID-in:
# routeAdd  "164.54.210.64",  "164.54.210.193"
# routeShow

  location  = "23-BM"
  engineer  = "O.Makarov"

  < iocEnv

  putenv ("EPICS_TS_NTP_INET=164.54.210.2")
  putenv ("EPICS_CA_AUTO_ADDR_LIST=YES")
### 215=bl3ws6 (directnet) 217=bl3ioc1 218=bl3ioc2 219=keithley3 220=mar3
# putenv ("EPICS_CA_ADDR_LIST=164.54.210.2 164.54.210.215 164.54.210.218")
  putenv ("EPICS_CA_ADDR_LIST=164.54.210.2")
  printf "EPICS_CA_ADDR_LIST=%s\n",getenv("EPICS_CA_ADDR_LIST")

################################################################################

### If the VxWorks kernel was built using the project facility, the following must
### be added before any C++ code is loaded (see SPR #28980).
  sysCplusEnable=1

### Load EPICS software
  cd appbin
  ld < xxx.munch

### Increase size of buffer for error logging from default 1256
  errlogInit(5000)
################################################################################
### Register all support components
  cd startup
  dbLoadDatabase("../../dbd/iocxxxVX.dbd",0,0)
  iocxxxVX_registerRecordDeviceDriver(pdbbase)

  iocLogDisable=1

###############################################################################
  dbLoadRecords("$(VXSTATS)/vxStats-template.db", "IOCNAME=23b:1")
### medm -x -attach -macro P=23b:2 std/2-5-4/stdApp/op/adl/IOC_Status_full.adl

##############################################################################
### dbrestore setup
### status-PV prefix
  save_restoreSet_status_prefix("23b:ioc1")
### Debug-output level
  save_restoreSet_Debug(0)

### Ok to save/restore save sets with missing values (no CA connection to PV)?
  save_restoreSet_IncompleteSetsOk(1)
### Save dated backup files?
  save_restoreSet_DatedBackupFiles(0)

### Number of sequenced backup files to write
  save_restoreSet_NumSeqFiles(3)
### Time interval between sequenced backups
  save_restoreSet_SeqPeriodInSeconds(600)

### If you want save_restore to manage its own NFS mount, specify the name and
### IP address of the file server to which save files should be written.
### This currently is supported only on vxWorks.
# save_restoreSet_NFSHost("oxygen", "164.54.52.4")

### specify where save files should be
  set_savefile_path(startup, "autosave")

### Specify what save files should be restored.  Note these files must be
### in the directory specified in set_savefile_path(), or, if that function
### has not been called, from the directory current when iocInit is invoked.
### Specify which save files are to be restored before record initialization (pass 0)
### and which are to be restored after record initialization (pass 1)
### This is the default: restore positios before record init and settings both before and after:
# set_pass0_restoreFile("auto_positions.sav")
  set_pass0_restoreFile("auto_settings.sav")
  set_pass1_restoreFile("auto_settings.sav")
# set_pass0_restoreFile("triggered_settings.sav")

### specify directories in which to to search for included request files
  set_requestfile_path(startup, "dbSave")

### Save_restore status database:
  dbLoadRecords("$(AUTOSAVE)/save_restoreStatus.db", "P=23b:ioc1")
  dbLoadRecords("$(GMCA)/generic_bo.db", "BL=23b,NAME=ioc1:saveTrigger")

### need more entries in wait/scan-record channel-access queue?
# recDynLinkQsize = 1024

###############################################################################
### Scan-support software
### crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
### 1D data, but it doesn`t store anything to disk.  (See 'saveData' below
### for that.)
# dbLoadRecords("$(SSCAN)/scan.db","P=23b:1:,MAXPTS1=2000,MAXPTS2=20,MAXPTS3=1,MAXPTS4=1,MAXPTSH=2000")

#vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
### Load Keithley-428 Current Amplifier databases:
# < st_keithley.cmd
#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

#vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
### Load PMAC databases:
  < st_pmac.cmd

################################################################################
### IP stuff:
# < st_ip.cmd

#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  iocInit

  taskDelay 240
# create_monitor_set("auto_positions.req", 5, "P=23b:ioc1")
# create_monitor_set("auto_settings.req", 30, "P=23b:ioc1")
# create_periodic_set("auto_settings.req", 600, "P=23b:ioc1")
# create_triggered_set("triggered_settings.req", "23b:ioc1:saveTrigger.PROC", "P=23b:ioc1")
  create_monitor_set("auto_positions.req", 1800, "P=23b:ioc1")
  create_monitor_set("auto_settings.req", 18000, "P=23b:ioc1")
  create_triggered_set("auto_settings.req", "23b:ioc1:saveTrigger.PROC", "P=23b:ioc1")

### For security reasons it is recommended to unmount the drive space,
### but then backup_restore fails. Therefore commented until further
### decision be made:

### Clear Macro Faults:
  taskDelay 30

  dbpf ("23b:pmac10:StrCmd","msclrf0")
  taskDelay 60
  dbpf ("23b:pmac10:StrCmd","msclrf32")
  taskDelay 30

  dbpf ("23b:pmac11:StrCmd","msclrf0")
  taskDelay 30

### Disable Telnet:
# ts tTelnetd
############################# END 23b:ioc1 ##########################
### ALL DONE!
### Enter ^X or "reboot" to reboot!
### Debugging: dbcar(0,5), i, dbgrep
### Also use: memShow, bootChange, lkup, dbgrep, i, ts, tr
###
