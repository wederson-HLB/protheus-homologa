#Include "Protheus.ch"
#Include "rwmake.ch"

/*
Funcao      : MT410CPY
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Ponto de entrada utilizado para forçar apagar o conteudo de alguns campos para que o usuario informe corretamente.
Autor       : Jean Victor Rocha.
Data/Hora   : 04/04/2013
*/
*----------------------*
User Function MT410CPY()
*----------------------*
Local i
Local aParc := {"1","2","3","4","5","6","7","8","9","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}

If cEmpAnt $ "MN/R7"
	Return .T.
EndIf

For i:=1 to Len(aParc)
	If SC5->(FieldPOs("C5_PARC"+aParc[i])) <> 0
		&("M->(C5_PARC"+aParc[i]+")") := 0
	EndIf
	If SC5->(FieldPOs("C5_DATA"+aParc[i])) <> 0
		&("M->(C5_DATA"+aParc[i]+")") := STOD("")
	EndIf
Next i
//RRP - 12/11/2015 - Ajuste para carregar a data base do sistema na cópia do pedido. Chamado 030581.
For i:=1 to Len(aCols)
	aCols[i][GDFIELDPOS("C6_ENTREG")]	:= dDatabase//STOD("")
	aCols[i][GDFIELDPOS("C6_SUGENTR")]	:= dDatabase//STOD("")
	aCols[i][GDFIELDPOS("C6_DTFIMNT")]	:= dDatabase//STOD("")
Next i

//RRP - 30/08/2016 - Limpa os campos enviados pelo Sistech na integracao Vogel
If ( cEmpAnt $  u_EmpVogel() )
	If SC5->(FieldPOs("C5_P_REF")) <> 0
		&("M->(C5_P_REF)")	:= ""
	EndIf
	If SC5->(FieldPOs("C5_P_CONSU")) <> 0
		&("M->(C5_P_CONSU)") := "" 
	EndIf
	If SC5->(FieldPOs("C5_P_BOL")) <> 0
		&("M->(C5_P_BOL)") 	:= ""
	EndIf
	If SC5->(FieldPOs("C5_P_DTINI")) <> 0
		&("M->(C5_P_DTINI)") := STOD("")
	EndIf
	If SC5->(FieldPOs("C5_P_DTFIM")) <> 0
		&("M->(C5_P_DTFIM)") := STOD("")
	EndIf
	If SC5->(FieldPOs("C5_P_AM")) <> 0
		&("M->(C5_P_AM)") 	:= ""
	EndIf
	If SC5->(FieldPOs("C5_P_CONTA")) <> 0
		&("M->(C5_P_CONTA)") := ""
	EndIf
	If SC5->(FieldPOs("C5_P_CID")) <> 0
		&("M->(C5_P_CID)") := ""
	EndIf
	If SC5->(FieldPOs("C5_P_PROJ")) <> 0
		&("M->(C5_P_PROJ)") := ""
	EndIf
	If SC5->(FieldPOs("C5_P_REG")) <> 0
		&("M->(C5_P_REG)") := ""
	EndIf
EndIf

//RRP - 27/07/2018 - Limpa o campo de status da AGV
If cEmpAnt $  "LG"
	If SC5->(FieldPOs("C5_P_ENV1")) <> 0
		&("M->(C5_P_ENV1)") := ""
	EndIf
EndIf

Return .T.