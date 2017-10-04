#!/bin/bash

BASE_DIR=$1

if [ -z "$BASE_DIR" ]; then
        BASE_DIR=".."
fi

mkdir $BASE_DIR/sigasi
mkdir $BASE_DIR/sigasi/gem_ctp7

#sorry, I hardcoded my paths here, you have to change these to point to your vivado instalation and the directory where you've cloned https://github.com/sigasi/SigasiProjectCreator.git

SCRIPTS_DIR=`pwd`
cd $BASE_DIR/sigasi/gem_ctp7
source /opt/Xilinx/Vivado/2017.2/settings64.sh
#generate a list of files in CSV format
vivado -mode batch -source $HOME/programs/dev/sigasi/SigasiProjectCreator/convertVivadoProjectToCsv.tcl $SCRIPTS_DIR/../ctp7/work_dir/gem_amc.xpr

#generate the sigasi project
$HOME/programs/dev/sigasi/SigasiProjectCreator/convertCsvFileToTree.py gem_ctp7 vivado_files.csv

#remove all IP files
sed -i "/\/ip\//d" .library_mapping.xml

#add unisim libs
sed -i -e "/xmlns:com.sigasi/a"$'\\\n'"  <Mappings Location=\"Common Libraries/unisim\" Library=\"unisim\"/>"$'\n' .library_mapping.xml
sed -i -e "/xmlns:com.sigasi/a"$'\\\n'"  <Mappings Location=\"Common Libraries/unisim/secureip\" Library=\"not mapped\"/>"$'\n' .library_mapping.xml
sed -i -e "/xmlns:com.sigasi/a"$'\\\n'"  <Mappings Location=\"Common Libraries/unisim/primitive\" Library=\"not mapped\"/>"$'\n' .library_mapping.xml
sed -i -e "/xmlns:com.sigasi/a"$'\\\n'"  <Mappings Location=\"Common Libraries/unimacro/unimacro_VCOMP.vhd\" Library=\"unimacro\"/>"$'\n' .library_mapping.xml
sed -i -e "/<linkedResources>/a"$'\\\n'"		<link>\n			<name>Common Libraries/unisim</name>\n			<type>2</type>\n			<locationURI>SIGASI_TOOLCHAIN_XILINX_VIVADO/ids_lite/ISE/vhdl/src/unisims</locationURI>\n		</link>"$'\n' .project
sed -i -e "/<linkedResources>/a"$'\\\n'"		<link>\n			<name>Common Libraries/unimacro</name>\n			<type>2</type>\n			<locationURI>SIGASI_TOOLCHAIN_XILINX_VIVADO/ids_lite/ISE/vhdl/src/unimacro</locationURI>\n		</link>"$'\n' .project
