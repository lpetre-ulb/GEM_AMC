#!/bin/env python
from rw_reg import *
from mcs import *
from time import *
import array
import struct

SLEEP_BETWEEN_COMMANDS=0.1
DEBUG=False
CTP7HOSTNAME = "eagle33"

class Colors:            
    WHITE   = '\033[97m' 
    CYAN    = '\033[96m' 
    MAGENTA = '\033[95m' 
    BLUE    = '\033[94m' 
    YELLOW  = '\033[93m' 
    GREEN   = '\033[92m' 
    RED     = '\033[91m' 
    ENDC    = '\033[0m'  

REG_PA_SHIFT_EN = None
REG_PA_SHIFT_CNT = None
REG_PA_PHASE = None
REG_PA_GTH_SHIFT_EN = None
REG_PA_GTH_SHIFT_CNT = None
REG_PA_GTH_PHASE = None
REG_PLL_RESET = None
REG_PLL_LOCKED = None

PHASE_CHECK_AVERAGE_CNT = 10
PLL_LOCK_WAIT_TIME = 0.0001 # wait 100us to allow the PLL to lock

def main():

    parseXML()
    initRegAddrs()
    # paGthShiftTest()
    # paShiftTest()
    # paCombinedSwShiftTest()
    # paCombinedHwShiftTest()
    alignToTtcPhase()

def initRegAddrs():
    global REG_PA_SHIFT_EN
    global REG_PA_SHIFT_CNT
    global REG_PA_PHASE
    global REG_PA_GTH_SHIFT_EN
    global REG_PA_GTH_SHIFT_CNT
    global REG_PA_GTH_PHASE
    global REG_PLL_RESET
    global REG_PLL_LOCKED

    REG_PA_SHIFT_EN = getNode('GEM_AMC.TTC.CTRL.PA_MANUAL_SHIFT_EN').real_address
    REG_PA_SHIFT_CNT = getNode('GEM_AMC.TTC.STATUS.CLK.PA_MANUAL_SHIFT_CNT').real_address
    REG_PA_PHASE = getNode('GEM_AMC.TTC.STATUS.CLK.TTC_PM_PHASE').real_address
    REG_PA_GTH_SHIFT_EN = getNode('GEM_AMC.TTC.CTRL.PA_GTH_MANUAL_SHIFT_EN').real_address
    REG_PA_GTH_SHIFT_CNT = getNode('GEM_AMC.TTC.STATUS.CLK.PA_MANUAL_GTH_SHIFT_CNT').real_address
    REG_PA_GTH_PHASE = getNode('GEM_AMC.TTC.STATUS.CLK.GTH_PM_PHASE').real_address
    REG_PLL_RESET = getNode('GEM_AMC.TTC.CTRL.PA_MANUAL_PLL_RESET').real_address
    REG_PLL_LOCKED = getNode('GEM_AMC.TTC.STATUS.CLK.PHASE_LOCKED').real_address

def paShiftTest():
    writeReg(getNode('GEM_AMC.TTC.CTRL.DISABLE_PHASE_ALIGNMENT'), 1)
    writeReg(getNode('GEM_AMC.TTC.CTRL.PA_DISABLE_GTH_PHASE_TRACKING'), 1)
    writeReg(getNode('GEM_AMC.TTC.CTRL.PA_MANUAL_OVERRIDE'), 1)
    writeReg(getNode('GEM_AMC.TTC.CTRL.PA_MANUAL_SHIFT_DIR'), 1)
    writeReg(getNode('GEM_AMC.TTC.CTRL.CNT_RESET'), 1)

    shiftCnt = rReg(REG_PA_SHIFT_CNT) & 0xffff

    f = open('phaseShift.log', 'w')

    for i in range(0, 1344):
        wReg(REG_PA_SHIFT_EN, 1)
        shiftCnt += 1
        if shiftCnt != (rReg(REG_PA_SHIFT_CNT) & 0xffff):
            printRed("Reported shift count doesn't match the expected shift count. Expected = %d, reported = %d" % (shiftCnt, rReg(REG_PA_SHIFT_CNT) & 0xffff))
        phase = getPhase(PHASE_CHECK_AVERAGE_CNT)
        phaseNs = phase * 0.01860119
        gthPhase = getGthPhase(PHASE_CHECK_AVERAGE_CNT)
        gthPhaseNs = gthPhase * 0.01860119
        printCyan("Shift #%d, mmcm phase counts = %f, mmcm phase = %fns, gth phase counts = %f, gth phase = %f" % (i, phase, phaseNs, gthPhase, gthPhaseNs))
        f.write("%d,%f,%f,%f,%f\n" % (i, phase, phaseNs, gthPhase, gthPhaseNs))

    f.close()

def paGthShiftTest():
    writeReg(getNode('GEM_AMC.TTC.CTRL.DISABLE_PHASE_ALIGNMENT'), 1)
    writeReg(getNode('GEM_AMC.TTC.CTRL.PA_DISABLE_GTH_PHASE_TRACKING'), 1)
    writeReg(getNode('GEM_AMC.TTC.CTRL.PA_GTH_MANUAL_OVERRIDE'), 1)
    writeReg(getNode('GEM_AMC.TTC.CTRL.PA_GTH_MANUAL_SHIFT_DIR'), 1)
    writeReg(getNode('GEM_AMC.TTC.CTRL.PA_GTH_MANUAL_SHIFT_STEP'), 1)
    writeReg(getNode('GEM_AMC.TTC.CTRL.PA_GTH_MANUAL_SEL_OVERRIDE'), 1)
    writeReg(getNode('GEM_AMC.TTC.CTRL.PA_GTH_MANUAL_COMBINED'), 0)
    writeReg(getNode('GEM_AMC.TTC.CTRL.CNT_RESET'), 1)

    shiftCnt = (rReg(REG_PA_GTH_SHIFT_CNT) & 0xffff0000) >> 16

    f = open('phaseShiftGth.log', 'w')

    for i in range(0, 2560):
        wReg(REG_PA_GTH_SHIFT_EN, 1)
        shiftCnt += 1
        if shiftCnt != ((rReg(REG_PA_GTH_SHIFT_CNT) & 0xffff0000) >> 16):
            printRed("Reported gth shift count doesn't match the expected shift count. Expected = %d, reported = %d" % (shiftCnt, (rReg(REG_PA_GTH_SHIFT_CNT) & 0xffff0000) >> 16))
        phase = getPhase(PHASE_CHECK_AVERAGE_CNT)
        phaseNs = phase * 0.01860119
        gthPhase = getGthPhase(PHASE_CHECK_AVERAGE_CNT)
        gthPhaseNs = gthPhase * 0.01860119
        printCyan("GTH shift #%d, mmcm phase counts = %f, mmcm phase = %fns, gth phase counts = %f, gth phase = %f" % (i, phase, phaseNs, gthPhase, gthPhaseNs))
        f.write("%d,%f,%f,%f,%f\n" % (i, phase, phaseNs, gthPhase, gthPhaseNs))

    f.close()

def paCombinedSwShiftTest():
    writeReg(getNode('GEM_AMC.TTC.CTRL.PA_DISABLE_GTH_PHASE_TRACKING'), 1)
    writeReg(getNode('GEM_AMC.TTC.CTRL.PA_MANUAL_OVERRIDE'), 0)
    writeReg(getNode('GEM_AMC.TTC.CTRL.DISABLE_PHASE_ALIGNMENT'), 0)
    sleep(2)
    writeReg(getNode('GEM_AMC.TTC.CTRL.PA_DISABLE_GTH_PHASE_TRACKING'), 1)
    writeReg(getNode('GEM_AMC.TTC.CTRL.PA_MANUAL_OVERRIDE'), 1)
    writeReg(getNode('GEM_AMC.TTC.CTRL.PA_MANUAL_SHIFT_DIR'), 1)
    writeReg(getNode('GEM_AMC.TTC.CTRL.PA_GTH_MANUAL_OVERRIDE'), 1)
    writeReg(getNode('GEM_AMC.TTC.CTRL.PA_GTH_MANUAL_SHIFT_DIR'), 0)
    writeReg(getNode('GEM_AMC.TTC.CTRL.PA_GTH_MANUAL_SHIFT_STEP'), 1)
    writeReg(getNode('GEM_AMC.TTC.CTRL.PA_GTH_MANUAL_SEL_OVERRIDE'), 1)
    writeReg(getNode('GEM_AMC.TTC.CTRL.PA_GTH_MANUAL_COMBINED'), 0)
    writeReg(getNode('GEM_AMC.TTC.CTRL.GTH_TXDLYBYPASS'), 1)
    writeReg(getNode('GEM_AMC.TTC.CTRL.CNT_RESET'), 1)


    f = open('phaseShiftCombinedSw.csv', 'w')

    mmcmShiftCnt = rReg(REG_PA_SHIFT_CNT) & 0xffff
    gthShiftCnt = (rReg(REG_PA_GTH_SHIFT_CNT) & 0xffff0000) >> 16

    localIdx = 1
    mmcmShiftTable = getMmcmShiftTable()

    for i in range(0, 256000):
        wReg(REG_PA_GTH_SHIFT_EN, 1)
        if gthShiftCnt == 39:
            gthShiftCnt = 0
        else:
            gthShiftCnt += 1

        while gthShiftCnt != ((rReg(REG_PA_GTH_SHIFT_CNT) & 0xffff0000) >> 16):
            wReg(REG_PA_GTH_SHIFT_EN, 1)
            printRed("Repeating a GTH PI shift because the shift count doesn't match the expected value. Expected shift cnt = %d, ctp7 returned %d" % (gthShiftCnt, ((rReg(REG_PA_GTH_SHIFT_CNT) & 0xffff0000) >> 16)))

        if mmcmShiftTable[localIdx]:
            wReg(REG_PA_SHIFT_EN, 1)
            if (mmcmShiftCnt == 0xffff):
                mmcmShiftCnt = 0
            else:
                mmcmShiftCnt += 1

            while mmcmShiftCnt != (rReg(REG_PA_SHIFT_CNT) & 0xffff):
                wReg(REG_PA_SHIFT_EN, 1)
                printRed("Repeating an MMCM shift because the shift count doesn't match the expected value. Expected shift cnt = %d, ctp7 returned %d" % (mmcmShiftCnt, (rReg(REG_PA_SHIFT_CNT) & 0xffff)))

        if localIdx >= 40:
            localIdx = 1
        else:
            localIdx += 1

        phase = getPhase(PHASE_CHECK_AVERAGE_CNT)
        phaseNs = phase * 0.01860119
        gthPhase = getGthPhase(PHASE_CHECK_AVERAGE_CNT)
        gthPhaseNs = gthPhase * 0.01860119
        printCyan("GTH shift #%d (mmcm shift cnt = %d), mmcm phase counts = %f, mmcm phase = %fns, gth phase counts = %f, gth phase = %f" % (i, mmcmShiftCnt, phase, phaseNs, gthPhase, gthPhaseNs))
        f.write("%d,%f,%f,%f,%f\n" % (i, phase, phaseNs, gthPhase, gthPhaseNs))

    f.close()

def paCombinedHwShiftTest():
    writeReg(getNode('GEM_AMC.TTC.CTRL.DISABLE_PHASE_ALIGNMENT'), 1)
    writeReg(getNode('GEM_AMC.TTC.CTRL.PA_DISABLE_GTH_PHASE_TRACKING'), 1)
    writeReg(getNode('GEM_AMC.TTC.CTRL.PA_MANUAL_OVERRIDE'), 1)
    writeReg(getNode('GEM_AMC.TTC.CTRL.PA_MANUAL_SHIFT_DIR'), 1)
    writeReg(getNode('GEM_AMC.TTC.CTRL.PA_GTH_MANUAL_OVERRIDE'), 1)
    writeReg(getNode('GEM_AMC.TTC.CTRL.PA_GTH_MANUAL_SHIFT_DIR'), 0)
    writeReg(getNode('GEM_AMC.TTC.CTRL.PA_GTH_MANUAL_SHIFT_STEP'), 1)
    writeReg(getNode('GEM_AMC.TTC.CTRL.PA_GTH_MANUAL_SEL_OVERRIDE'), 1)
    writeReg(getNode('GEM_AMC.TTC.CTRL.PA_GTH_MANUAL_COMBINED'), 1)
    writeReg(getNode('GEM_AMC.TTC.CTRL.GTH_TXDLYBYPASS'), 1)
    writeReg(getNode('GEM_AMC.TTC.CTRL.CNT_RESET'), 1)


    if (parseInt(readReg(getNode('GEM_AMC.TTC.CTRL.DISABLE_PHASE_ALIGNMENT'))) == 0):
        printRed("fail: automatic phase alignment is turned on!!")
        return

    f = open('phaseShiftCombinedHw.csv', 'w')

    mmcmShiftCnt = rReg(REG_PA_SHIFT_CNT) & 0xffff
    gthShiftCnt = (rReg(REG_PA_GTH_SHIFT_CNT) & 0xffff0000) >> 16

    mmcmShiftTable = getMmcmShiftTable()

    for i in range(0, 256000):
        wReg(REG_PA_GTH_SHIFT_EN, 1)
        mmcmShiftRequired = mmcmShiftTable[gthShiftCnt+1]

        if gthShiftCnt == 39:
            gthShiftCnt = 0
        else:
            gthShiftCnt += 1

        while gthShiftCnt != ((rReg(REG_PA_GTH_SHIFT_CNT) & 0xffff0000) >> 16):
            wReg(REG_PA_GTH_SHIFT_EN, 1)
            printRed("Repeating a GTH PI shift because the shift count doesn't match the expected value. Expected shift cnt = %d, ctp7 returned %d" % (gthShiftCnt, ((rReg(REG_PA_GTH_SHIFT_CNT) & 0xffff0000) >> 16)))

        if mmcmShiftRequired:
            if (mmcmShiftCnt == 0xffff):
                mmcmShiftCnt = 0
            else:
                mmcmShiftCnt += 1

        if mmcmShiftCnt != (rReg(REG_PA_SHIFT_CNT) & 0xffff):
            printRed("Reported MMCM shift count doesn't match the expected MMCM shift count. Expected shift cnt = %d, ctp7 returned %d, gth shift cnt = %d" % (mmcmShiftCnt, (rReg(REG_PA_SHIFT_CNT) & 0xffff), gthShiftCnt))

        phase = getPhase(PHASE_CHECK_AVERAGE_CNT)
        phaseNs = phase * 0.01860119
        gthPhase = getGthPhase(PHASE_CHECK_AVERAGE_CNT)
        gthPhaseNs = gthPhase * 0.01860119
        printCyan("GTH shift #%d (mmcm shift cnt = %d, gth shift cnt = %d), mmcm phase counts = %f, mmcm phase = %fns, gth phase counts = %f, gth phase = %f" % (i, mmcmShiftCnt, gthShiftCnt, phase, phaseNs, gthPhase, gthPhaseNs))
        f.write("%d,%f,%f,%f,%f\n" % (i, phase, phaseNs, gthPhase, gthPhaseNs))

    f.close()

def alignToTtcPhase():
    writeReg(getNode('GEM_AMC.TTC.CTRL.DISABLE_PHASE_ALIGNMENT'), 1)
    writeReg(getNode('GEM_AMC.TTC.CTRL.PA_DISABLE_GTH_PHASE_TRACKING'), 1)
    writeReg(getNode('GEM_AMC.TTC.CTRL.PA_MANUAL_OVERRIDE'), 1)
    writeReg(getNode('GEM_AMC.TTC.CTRL.PA_MANUAL_SHIFT_DIR'), 1)
    writeReg(getNode('GEM_AMC.TTC.CTRL.PA_GTH_MANUAL_OVERRIDE'), 1)
    writeReg(getNode('GEM_AMC.TTC.CTRL.PA_GTH_MANUAL_SHIFT_DIR'), 0)
    writeReg(getNode('GEM_AMC.TTC.CTRL.PA_GTH_MANUAL_SHIFT_STEP'), 1)
    writeReg(getNode('GEM_AMC.TTC.CTRL.PA_GTH_MANUAL_SEL_OVERRIDE'), 1)
    writeReg(getNode('GEM_AMC.TTC.CTRL.PA_GTH_MANUAL_COMBINED'), 1)
    writeReg(getNode('GEM_AMC.TTC.CTRL.GTH_TXDLYBYPASS'), 1)
    writeReg(getNode('GEM_AMC.TTC.CTRL.PA_MANUAL_PLL_RESET'), 1)
    writeReg(getNode('GEM_AMC.TTC.CTRL.CNT_RESET'), 1)

    if (parseInt(readReg(getNode('GEM_AMC.TTC.CTRL.DISABLE_PHASE_ALIGNMENT'))) == 0):
        printRed("fail: automatic phase alignment is turned on!!")
        return

    f = open('phaseShiftCombinedHw.csv', 'w')

    mmcmShiftCnt = rReg(REG_PA_SHIFT_CNT) & 0xffff
    gthShiftCnt = (rReg(REG_PA_GTH_SHIFT_CNT) & 0xffff0000) >> 16
    pllLocked = False
    phase = 0
    phaseNs = 0.0

    mmcmShiftTable = getMmcmShiftTable()

    for i in range(0, 23040): # this will allow up to 3 times 360 degree shifts to find the lock (should only require 1x 360 in theory)
        wReg(REG_PA_GTH_SHIFT_EN, 1)
        mmcmShiftRequired = mmcmShiftTable[gthShiftCnt+1]

        if gthShiftCnt == 39:
            gthShiftCnt = 0
        else:
            gthShiftCnt += 1

        while gthShiftCnt != ((rReg(REG_PA_GTH_SHIFT_CNT) & 0xffff0000) >> 16):
            wReg(REG_PA_GTH_SHIFT_EN, 1)
            printRed("Repeating a GTH PI shift because the shift count doesn't match the expected value. Expected shift cnt = %d, ctp7 returned %d" % (gthShiftCnt, ((rReg(REG_PA_GTH_SHIFT_CNT) & 0xffff0000) >> 16)))

        if mmcmShiftRequired:
            if (mmcmShiftCnt == 0xffff):
                mmcmShiftCnt = 0
            else:
                mmcmShiftCnt += 1

        if mmcmShiftCnt != (rReg(REG_PA_SHIFT_CNT) & 0xffff):
            printRed("Reported MMCM shift count doesn't match the expected MMCM shift count. Expected shift cnt = %d, ctp7 returned %d" % (mmcmShiftCnt, (rReg(REG_PA_SHIFT_CNT) & 0xffff)))

        pllLocked = checkPllLock()
        phase = getPhase(PHASE_CHECK_AVERAGE_CNT)
        phaseNs = phase * 0.01860119
        gthPhase = getGthPhase(PHASE_CHECK_AVERAGE_CNT)
        gthPhaseNs = gthPhase * 0.01860119
        printCyan("GTH shift #%d (mmcm shift cnt = %d), mmcm phase counts = %f, mmcm phase = %fns, gth phase counts = %f, gth phase = %f, PLL locked = %r" % (i, mmcmShiftCnt, phase, phaseNs, gthPhase, gthPhaseNs, pllLocked))
        f.write("%d,%f,%f,%f,%f\n" % (i, phase, phaseNs, gthPhase, gthPhaseNs))

        if (pllLocked):
            break;

    f.close()

    print("")
    print("=============================================================")
    if (pllLocked):
        printGreen("==== Lock was found at phase count = %d, phase ns = %fns ====" % (phase, phaseNs))
    else:
        printRed("====              Lock was not found.... :(              ====")
    print("=============================================================")
    print("")


def getMmcmShiftTable():
    pi_step_size=(1000./4800.)/64.
    mmcm_step_size=(1000./960.)/56.
    pi_steps=[i*pi_step_size for i in range(0,41)]
    mmcm_steps=[i*mmcm_step_size  for i in range(0,8)]
    mmcm=0

    mmcm_val=0
    shiftNext=False
    res = []
    for i,pistep in enumerate(pi_steps):
        shiftNow=False
        mmcm_comp=mmcm_steps[mmcm]+(mmcm_step_size/2)
        try:
            if mmcm_comp >= (pi_steps[i]) and mmcm_comp <= (pi_steps[i+1]):
                shiftNext=True
            else:
                if shiftNext:
                    mmcm += 1
                    mmcm_val = mmcm_steps[mmcm]
                    shiftNow=True
                    shiftNext=False
        except IndexError:
            pass
        res.append(shiftNow)
        print("{:d}  {:8.6f}  {:8.6f}  {:10.6f}  {:d}  {}".format(i,pistep,mmcm_val,pistep-mmcm_val,mmcm,shiftNow))

    print(len(res),res)
    return res

def checkPllLock():
    wReg(REG_PLL_RESET, 1)
    sleep(PLL_LOCK_WAIT_TIME)
    if ((rReg(REG_PLL_LOCKED) & 0x4) >> 2) == 0:
        return False
    else:
        return True

def getPhase(numIterations):
    phase = 0
    for i in range(0, numIterations):
        phase += rReg(REG_PA_PHASE) & 0xfff

    phase = phase / numIterations
    return phase

def getGthPhase(numIterations):
    phase = 0
    for i in range(0, numIterations):
        phase += rReg(REG_PA_GTH_PHASE) & 0xfff

    phase = phase / numIterations
    return phase

def checkStatus():
    rxReady       = parseInt(readReg(getNode('GEM_AMC.SLOW_CONTROL.SCA.STATUS.READY')))
    criticalError = parseInt(readReg(getNode('GEM_AMC.SLOW_CONTROL.SCA.STATUS.CRITICAL_ERROR')))
    return (rxReady == 1) and (criticalError == 0)

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

def printGreen(string):
    print Colors.GREEN
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
