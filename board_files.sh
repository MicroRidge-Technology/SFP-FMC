set -x
set -e
PROJECT=$1
rm -rf manufacture
mkdir manufacture

#Set commit in silkscreen
githash=$(git describe --tags --always --dirty)
sed -i "s/Git Commit:.*\"/Git Commit:$githash\"/" ${PROJECT}.kicad_pcb 

kicad-cli pcb export drill ${PROJECT}.kicad_pcb  -o manufacture/
kicad-cli pcb export gerbers ${PROJECT}.kicad_pcb  --board-plot-params -o manufacture
(cd manufacture; zip ${PROJECT}-gbr.zip *.drl *.gbr *.gbrjob )
kicad-cli pcb export pos --side front ${PROJECT}.kicad_pcb -o manufacture/front.pos
kicad-cli pcb export pos --side back ${PROJECT}.kicad_pcb -o manufacture/back.pos
(cd manufacture; zip ${PROJECT}-pos.zip *.pos)
(cd manufacture/; rm *.drl *.gbr *.pos)           
kicad-cli sch export bom -o manufacture/bom.csv --group-by Value \
          --fields '${ITEM_NUMBER},Reference,${QUANTITY},MANUFACTURER,MPN,Value,Footprint,${DNP}' \
          --labels 'Item #,Designator,Qty,Manufacture,Mfg Part#,Value,Footprint,dnp' \
          fmc-sfp.kicad_sch
