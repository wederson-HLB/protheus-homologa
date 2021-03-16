#include 'protheus.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMTMODNOT  บAutor  ณEduardo C. Romanini บ Data ณ  19/01/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPonto de Entrada para retornar o codigo do modelo de doc.   บฑฑ
ฑฑบ          ณfiscal customizado.                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ HLB - Sped                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
*----------------------*
User Function MTMODNOT()
*----------------------*
Local cRet     := "01"
Local cEspecie := PARAMIXB

//JSS - 31/01/2013 - Tratamento para que a especie 'NF' seja considerada no arquivo do SPED.  
If AllTrim(Upper(cEspecie)) $ "NF/NFF/"   
	cRet := "01"
//JSS - 19/10/2012 - Tratamento para que as especies entre aspแs nใo seja considerada no arquivo do SPED.   
//JSS - 08/11/2012 - Tratamente para que as especies que estiverem em branco nใo seja consideradas no SPED.	
ElseIf AllTrim(Upper(cEspecie)) $ "EXTR/FAT/FORA/NADA/NFCF/NFCFG/NFDS/NFFA/NFPS/NFS/NFSS/NFST/OUTRO/R/RED/RPA/RPS/" .OR. Empty(cEspecie)       
	cRet := "  "

//Tratamento para que a especie NF-E seja considerada como nota fiscal eletronica.
ElseIf AllTrim(Upper(cEspecie)) == "NF-E"   
	cRet := "55"

EndIf

Return cRet 

