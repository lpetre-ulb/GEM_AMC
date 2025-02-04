import xml.etree.ElementTree as xml
import sys, os, subprocess

DEBUG = True
ADDRESS_TABLE_TOP = '/mnt/persistent/texas/gem_amc_top.xml'
nodes = []

class Node:
    name = ''
    vhdlname = ''
    address = 0x0
    real_address = 0x0
    permission = ''  
    mask = 0x0
    isModule = False
    parent = None

    def __init__(self):
        self.children = []

    def addChild(self, child):
        self.children.append(child)

    def getVhdlName(self):
        return self.name.replace(TOP_NODE_NAME + '.', '').replace('.', '_')

    def output(self):
        print 'Name:',self.name
        print 'Address:','{0:#010x}'.format(self.address)
        print 'Permission:',self.permission
        print 'Mask:','{0:#010x}'.format(self.mask)
        print 'Module:',self.isModule
        print 'Parent:',self.parent.name

def main():
    configure()
    print 'Example:'
    random_node = nodes[76]
    #print str(random_node.__class__.__name__)
    print 'Node:',random_node.name
    print 'Parent:',random_node.parent.name
    kids = []
    getAllChildren(random_node, kids)
    print len(kids), kids.name

def parseXML():
    tree = xml.parse(ADDRESS_TABLE_TOP)
    root = tree.getroot()[0]
    vars = {}
    makeTree(root,'',0x0,nodes,None,vars,False)

def makeTree(node,baseName,baseAddress,nodes,parentNode,vars,isGenerated):
    
    if (isGenerated == None or isGenerated == False) and node.get('generate') is not None and node.get('generate') == 'true':
        generateSize = parseInt(node.get('generate_size'))
        generateAddressStep = parseInt(node.get('generate_address_step'))
        generateIdxVar = node.get('generate_idx_var')
        for i in range(0, generateSize):
            vars[generateIdxVar] = i
            #print('generate base_addr = ' + hex(baseAddress + generateAddressStep * i) + ' for node ' + node.get('id'))
            makeTree(node, baseName, baseAddress + generateAddressStep * i, nodes, parentNode, vars, True)
        return

    newNode = Node()
    name = baseName
    if baseName != '':
        name += '.'
    name += node.get('id')
    name = substituteVars(name, vars)
    newNode.name = name
    #print len(nodes), name
    #print newNode.name
    address = baseAddress
    if node.get('address') is not None:
        address = baseAddress + parseInt(node.get('address'))
    newNode.address = address
    newNode.real_address = (address<<2)+0x64000000


    newNode.permission = node.get('permission')
    newNode.mask = parseInt(node.get('mask'))

    newNode.isModule = node.get('fw_is_module') is not None and node.get('fw_is_module') == 'true'
    
    nodes.append(newNode)
    if parentNode is not None:
        parentNode.addChild(newNode)
        newNode.parent = parentNode

    for child in node:
        makeTree(child,name,address,nodes,newNode,vars,False)


def getAllChildren(node,kids=[]):
    if node.children==[]:
        kids.append(node)
        return kids
    else:
        for child in node.children:
            getAllChildren(child,kids)

def getNode(nodeName):
    return next((node for node in nodes if node.name == nodeName),None)

def getNodeFromAddress(nodeAddress):
    return next((node for node in nodes if node.real_address == nodeAddress),None)


def getNodesContaining(nodeString):
    nodelist = [node for node in nodes if nodeString in node.name]
    if len(nodelist): return nodelist
    else: return None

def getRegsContaining(nodeString):
    nodelist = [node for node in nodes if ((nodeString in node.name) and (node.permission is not None) and ('r' in node.permission))]
    if len(nodelist): return nodelist
    else: return None


def readAddress(address):
    try: 
        output = subprocess.check_output('mpeek '+str(hex(address)), stderr=subprocess.STDOUT , shell=True)
        value = ''.join(s for s in output if s.isalnum())
    except subprocess.CalledProcessError as e: value = parseError(int(str(e)[-1:]))
    return '{0:#010x}'.format(parseInt(str(value)))

def readRawAddress(raw_address):
    address = raw_address
    address = address << 2
    address = address + 0x64000000
    return readAddress(address)

def readReg(reg):
    address = reg.real_address
    if 'r' not in reg.permission:
        return 'No read permission!'

    # mpeek
    try: 
        output = subprocess.check_output('mpeek '+str(address), stderr=subprocess.STDOUT , shell=True)
        value = ''.join(s for s in output if s.isalnum())
    except subprocess.CalledProcessError as e: return parseError(int(str(e)[-1:]))
    # Apply Mask
    if reg.mask is not None:
        shift_amount=0
        for bit in reversed('{0:b}'.format(reg.mask)):
            if bit=='0': shift_amount+=1
            else: break
        final_value = (parseInt(str(reg.mask))&parseInt(value)) >> shift_amount
    else: final_value = value
    final_int =  parseInt(str(final_value))
    return '{0:#010x}'.format(final_int)

def writeReg(reg, value):
    try: address = reg.real_address
    except:
        print 'Reg',reg,'not a Node'
        return
    if 'w' not in reg.permission:
        return 'No write permission!'

    # Apply Mask
    if reg.mask is not None:
        shift_amount=0
        for bit in reversed('{0:b}'.format(reg.mask)):
            if bit=='0': shift_amount+=1
            else: break
        #if DEBUG: print 'shift_amount:',shift_amount
        shifted_value = value << shift_amount
        #if DEBUG: print 'shifted_value:','{0:#010x}'.format(shifted_value)
        if 'r' not in reg.permission:
            if DEBUG: print 'No read permission.'
            final_value = shifted_value
        else: 
            initial_value = readReg(reg)
            try: initial_value = parseInt(initial_value) 
            except: return 'Error reading initial value: '+initial_value
            final_value = (shifted_value & reg.mask) | (initial_value & ~reg.mask)
    else: final_value = value
    
    print 'Writing:',hex(final_value),'to',reg.name

    # mpoke
    try: 
        output = subprocess.check_output('mpoke '+str(address)+' '+str(final_value), stderr=subprocess.STDOUT , shell=True)
        return '{0:#010x}'.format(final_value)+' written to register.'
    except subprocess.CalledProcessError as e: return parseError(int(str(e)[-1:]))
    


def isValid(address):
    try: subprocess.check_output('mpeek '+str(hex(address)), stderr=subprocess.STDOUT , shell=True)
    except subprocess.CalledProcessError as e: return False
    return True

def parseError(e):
    if e==1:
        return "Failed to parse address"
    if e==2:
        return "Bus error"
    else:
        return "Unknown error: "+str(e)

def parseInt(string):
    if string is None:
        return None
    elif string.startswith('0x'):
        return int(string, 16)
    elif string.startswith('0b'):
        return int(string, 2)
    else:
        return int(string)


def substituteVars(string, vars):
    if string is None:
        return string
    ret = string
    for varKey in vars.keys():
        ret = ret.replace('${' + varKey + '}', str(vars[varKey]))
    return ret

def tabPad(s,maxlen):
    return s+"\t"*((8*maxlen-len(s)-1)/8+1) 

if __name__ == '__main__':
    main()
