#!/usr/bin/env python

from rw_reg import *
from time import *
import array
import struct

DEBUG=False

class Colors:            
    WHITE   = '\033[97m' 
    CYAN    = '\033[96m' 
    MAGENTA = '\033[95m' 
    BLUE    = '\033[94m' 
    YELLOW  = '\033[93m' 
    GREEN   = '\033[92m' 
    RED     = '\033[91m' 
    ENDC    = '\033[0m'  

ADDR_IC_ADDR = None
ADDR_IC_WRITE_DATA = None
ADDR_IC_EXEC_WRITE = None
ADDR_IC_EXEC_READ = None

ADDR_LINK_RESET = None

ADDRESS_TABLE_SLOW_CTRL_ONLY = '/mnt/persistent/texas/gem_amc_top_SLOW_CTRL_ONLY.xml'

V3B_GBT0_ELINK_TO_VFAT = {0: 15, 1: 14, 2: 13, 3: 12, 6: 7, 8: 23}
V3B_GBT1_ELINK_TO_VFAT = {1: 4, 2: 2, 3: 3, 4: 8, 5: 0, 6: 6, 7: 16, 8: 5, 9: 1}
V3B_GBT2_ELINK_TO_VFAT = {1: 9, 2: 20, 3: 21, 4: 11, 5: 10, 6: 18, 7: 19, 8: 17, 9: 22}
V3B_GBT_ELINK_TO_VFAT = [V3B_GBT0_ELINK_TO_VFAT, V3B_GBT1_ELINK_TO_VFAT, V3B_GBT2_ELINK_TO_VFAT]
GBT_ELINK_SAMPLE_PHASE_REGS = [[69, 73, 77], [67, 71, 75], [93, 97, 101], [91, 95, 99], [117, 121, 125], [115, 119, 123], [141, 145, 149], [139, 143, 147], [165, 169, 173], [163, 167, 171]]

def main():

    command = ""
    ohSelect = 0
    gbtSelect = 0

    if len(sys.argv) < 4:
        print('Usage: gbt.py <oh_num> <gbt_num> <command>')
        print('available commands:')
        print('  config <config_filename_txt>:   Configures the GBT with the given config file (must use the txt version of the config file, can be generated with the GBT programmer software)')
        print('  v3b-phase-scan <base_config_filename_txt>:   Configures the GBT with the given config file, and performs an elink phase scan while checking the VFAT communication for each phase')
        return
    else:
        ohSelect = int(sys.argv[1])
        gbtSelect = int(sys.argv[2])
        command = sys.argv[3]

    if ohSelect > 11:
        printRed("The given OH index (%d) is out of range (must be 0-11)" % ohSelect)
        return
    if gbtSelect > 2:
        printRed("The given GBT index (%d) is out of range (must be 0-2)" % gbtSelect)
        return

    if os.path.isfile(ADDRESS_TABLE_SLOW_CTRL_ONLY) and (command != 'v3b-phase-scan'):
        parseXML('/mnt/persistent/texas/gem_amc_top_SLOW_CTRL_ONLY.xml')
    else:
        parseXML()

    initGbtRegAddrs()

    heading("Hello, I'm your GBT controller :)")

    if (checkGbtReady(ohSelect, gbtSelect) == 1):
        selectGbt(ohSelect, gbtSelect)
    else:
        printRed("Sorry, OH%d GBT%d link is not ready.. check the following: your OH is on, the fibers are plugged in correctly, the CTP7 TX polarity is correct, and muy importante, check that your GBTX is fused with at least the minimal config.." % (ohSelect, gbtSelect))
        return

    if (command == 'config') or (command == 'v3b-phase-scan') :
        if len(sys.argv) < 5:
            print("For this command, you also need to provide a config file")
            return

        subheading('Configuring OH%d GBT%d' % (ohSelect, gbtSelect))
        filename = sys.argv[4]
        if filename[-3:] != "txt":
            printRed("Seems like the file is not a txt file, please provide a txt file generated with the GBT programmer software")
            return
        if not os.path.isfile(filename):
            printRed("Can't find the file %s" % filename)
            return

        timeStart = clock()

        regs = downloadConfig(ohSelect, gbtSelect, filename)

        totalTime = clock() - timeStart
        print('time took = ' + str(totalTime) + 's')

        if (command == 'v3b-phase-scan'):
            initVfatRegAddrs()
            for elink, vfat in V3B_GBT_ELINK_TO_VFAT[gbtSelect].items():
                subheading('Scanning elink %d phase, corresponding to VFAT%d' % (elink, vfat))
                for phase in range(0, 16):
                    # set phase
                    for subReg in range(0, 3):
                        addr = GBT_ELINK_SAMPLE_PHASE_REGS[elink][subReg]
                        value = (regs[addr] & 0xf0) + phase
                        wReg(ADDR_IC_ADDR, addr)
                        wReg(ADDR_IC_WRITE_DATA, value)
                        wReg(ADDR_IC_EXEC_WRITE, 1)
                    # reset the link, give some time to lock and accumulate any sync errors and then check VFAT comms
                    sleep(0.1)
                    writeReg(getNode('GEM_AMC.GEM_SYSTEM.CTRL.LINK_RESET'), 1)
                    # wReg(ADDR_LINK_RESET, 1)
                    sleep(0.3)
                    linkGood = parseInt(readReg(getNode('GEM_AMC.OH_LINKS.OH%d.VFAT%d.LINK_GOOD' % (ohSelect, vfat))))
                    syncErrCnt = parseInt(readReg(getNode('GEM_AMC.OH_LINKS.OH%d.VFAT%d.SYNC_ERR_CNT' % (ohSelect, vfat))))
                    cfgRun = readReg(getNode('GEM_AMC.OH.OH%d.GEB.VFAT%d.CFG_RUN' % (ohSelect, vfat)))
                    color = Colors.GREEN
                    prefix = 'GOOD: '
                    if (linkGood == 0) or (syncErrCnt > 0) or (cfgRun != '0x00000000' and cfgRun != '0x00000001'):
                        color = Colors.RED
                        prefix = '>>>>>>>> BAD <<<<<<<< '
                    print color, prefix, 'Phase = %d, VFAT%d LINK_GOOD=%d, SYNC_ERR_CNT=%d, CFG_RUN=%s' % (phase, vfat, linkGood, syncErrCnt, cfgRun), Colors.ENDC

    elif command == 'destroy':
        subheading('Destroying configuration of OH%d GBT%d' % (ohSelect, gbtSelect))
        destroyConfig()

    else:
        printRed("Unrecognized command '%s'" % command)
        return

    print("")
    print("bye now..")

def downloadConfig(ohIdx, gbtIdx, filename):
    f = open(filename, 'r')

    #for now we'll operate with 8 bit words only
    writeReg(getNode("GEM_AMC.SLOW_CONTROL.IC.READ_WRITE_LENGTH"), 1)

    ret = []

    lines = 0
    addr = 0
    for line in f:
        value = int(line, 16)
        wReg(ADDR_IC_ADDR, addr)
        wReg(ADDR_IC_WRITE_DATA, value)
        wReg(ADDR_IC_EXEC_WRITE, 1)
        addr += 1
        lines += 1
        ret.append(value)

    print("Wrote %d registers to OH%d GBT%d" % (lines, ohIdx, gbtIdx))
    if lines < 366:
        printRed("looks like you gave me an incomplete file, since I found only %d registers, while a complete config should contain 366 registers")

    f.close()

    return ret

def destroyConfig():
    for i in range(0, 369):
        wReg(ADDR_IC_ADDR, i)
        wReg(ADDR_IC_WRITE_DATA, 0)
        wReg(ADDR_IC_EXEC_WRITE, 1)

def initGbtRegAddrs():
    global ADDR_IC_ADDR
    global ADDR_IC_WRITE_DATA
    global ADDR_IC_EXEC_WRITE
    global ADDR_IC_EXEC_READ
    ADDR_IC_ADDR = getNode('GEM_AMC.SLOW_CONTROL.IC.ADDRESS').real_address
    ADDR_IC_WRITE_DATA = getNode('GEM_AMC.SLOW_CONTROL.IC.WRITE_DATA').real_address
    ADDR_IC_EXEC_WRITE = getNode('GEM_AMC.SLOW_CONTROL.IC.EXECUTE_WRITE').real_address
    ADDR_IC_EXEC_READ = getNode('GEM_AMC.SLOW_CONTROL.IC.EXECUTE_READ').real_address

def initVfatRegAddrs():
    global ADDR_LINK_RESET
    ADDR_LINK_RESET = getNode('GEM_AMC.GEM_SYSTEM.CTRL.LINK_RESET').real_address

def selectGbt(ohIdx, gbtIdx):
    linkIdx = ohIdx * 3 + gbtIdx

    writeReg(getNode('GEM_AMC.SLOW_CONTROL.IC.GBTX_LINK_SELECT'), linkIdx)

    return 0

def checkGbtReady(ohIdx, gbtIdx):
    return parseInt(readReg(getNode('GEM_AMC.OH_LINKS.OH%d.GBT%d_READY' % (ohIdx, gbtIdx))))

def check_bit(byteval,idx):
    return ((byteval&(1<<idx))!=0);

def debug(string):
    if DEBUG:
        print('DEBUG: ' + string)

def debugCyan(string):
    if DEBUG:
        printCyan('DEBUG: ' + string)

def heading(string):                                                                    
    print Colors.BLUE                                                             
    print '\n>>>>>>> '+str(string).upper()+' <<<<<<<'
    print Colors.ENDC                   
                                                      
def subheading(string):                         
    print Colors.YELLOW                                        
    print '---- '+str(string)+' ----',Colors.ENDC                    
                                                                     
def printCyan(string):                                                
    print Colors.CYAN                                    
    print string, Colors.ENDC                                                                     
                                                                      
def printRed(string):                                                                                                                       
    print Colors.RED                                                                                                                                                            
    print string, Colors.ENDC                                           

def hex(number):
    if number is None:
        return 'None'
    else:
        return "{0:#0x}".format(number)

def binary(number, length):
    if number is None:
        return 'None'
    else:
        return "{0:#0{1}b}".format(number, length + 2)

if __name__ == '__main__':
    main()
