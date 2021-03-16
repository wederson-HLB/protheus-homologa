#Include"Totvs.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF590COK() บAutor  ณJoใo Silva         บ Data ณ  17/02/2016  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPonto de entrada que valida o cancelamento/retirada de um   บฑฑ
ฑฑบ          ณ determinado t๚‘ulo de um borderE              			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ  AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
*------------------------*
User Function F060VLOK() 
*------------------------*

Local cPortado 	:= paramixb[2]
Local cAgencia	:= paramixb[3]
Local cConta 	:= paramixb[4]  
Local lRet		:= .T.

Local cDefbank 	:= ""//Banco padrใo.
Local cDefAgen	:= ""//Agencia padrใo.
Local cDefCont 	:= ""//Conta padrใo.

If cEmpAnt = "TP"//Verifica se Ea empresa Twitter.   
	cDefbank 	:= SUPERGETMV("MV_P_00067",.F. )
	cDefAgen	:= SUPERGETMV("MV_P_00066",.F. ) 
	cDefCont 	:= SUPERGETMV("MV_P_00065",.F. ) 

	If	cConta	<> cDefCont .Or. cAgencia <> cDefAgen .Or. cPortado <> cDefbank	
		MsgInfo("Para gera็ใo dos border๔s da empresa Twitter Enecessario utilizar o Banco: "+cDefbank+" Agencia: "+cDefAgen+" Conta: "+cDefCont+" (MV_P_00065, MV_P_00066, MV_P_00067)","HLB BRASIL")
		lRet:=.F.
	EndIf
EndIf

Return (lRet)