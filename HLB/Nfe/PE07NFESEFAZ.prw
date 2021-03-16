#include "totvs.ch"

/*
Funcao      : PE07NFESEFAZ
Parametros  : Nenhum
Retorno     : aRet
Objetivos   : P.E. para tratamento do Destinatario
Autor       : Jean Victor Rocha
Data/Hora   : 03/08/2017
Módulo      : Faturamento
Cliente		: Todos
*/

/*	aDest[1] - CGC Destinatario
	aDest[2] - Nome destinatario
	aDest[3] - Endereço
	aDest[4] - Numero do endereço
	aDest[5] - Complemento
	aDest[6] - Bairro
	aDest[7] - Codigo municipio
	aDest[8] - Descrição Municipio
	aDest[9] - Estado A1_EST
	aDest[10] - CEP
	aDest[11] - Pais
	aDest[12] - Descrição Pais
	aDest[13] - Telefone (SA1->A1_DDD+SA1->A1_TEL)
	aDest[14] - Inscrição (em caso de Extrangeiro)
	aDest[15] - Suframa
	aDest[16] - Email
	aDest[17] - Contribuinte
	aDest[18] - A1_IENCONT
	aDest[19] - Inscrição Municipal
	aDest[20] - A1_TIPO - Posição 20
	aDest[21] - 21-Identificação estrangeiro*/
*--------------------------*
User Function PE07NFESEFAZ()
*--------------------------*
Local aRet		:= {}
Local aDest		:= ParamIXB[01]
Local cDoc		:= ParamIXB[02]
Local cSerie	:= ParamIXB[03]

Local aArea1	:= {}
Local aArea2	:= {}

Local cQry		:= ""

Local nRecCount	:= 0

If cEmpAnt == "N6"//doTerra
	aArea1 := SC5->(GetArea())	
	aArea2 := SC6->(GetArea())

	SC6->(dbSetOrder(4))
	SC5->(dbSetOrder(1))
	If SC5->(FieldPos("C5_P_ENDEN")) <> 0 .and.;
		SC6->(DbSeek(xFilial("SC6")+cDoc+cSerie)) .and.;
		SC5->(DbSeek(xFilial("SC5")+SC6->C6_NUM)) .and.;
		!EMPTY(SC5->C5_P_ENDEN)

		If Select("ZX4") > 0 
			ZX4->(DbCloseArea())
		EndIf 

		cQry := "SELECT TOP 1 *
		cQry += " FROM "+RetSqlName("ZX4")
		cQry += " WHERE D_E_L_E_T_ <> '*'
		cQry += "	AND ZX4_CODEND	= '"+SC5->C5_P_ENDEN+"'

		DbUseArea(.T., "TOPCONN", TcGenQry(,,ChangeQuery(cQry)), "ZX4", .F., .T.)

		Count to nRecCount
		ZX4->(DbGoTop())
		If nRecCount > 0
			aDest[3] := FisGetEnd(ALLTRIM(ZX4->ZX4_END),ALLTRIM(ZX4->ZX4_EST))[1]//Endereço
			aDest[4] := IIF(FisGetEnd(ALLTRIM(ZX4->ZX4_END),ALLTRIM(ZX4->ZX4_EST))[3]<>"",FisGetEnd(ALLTRIM(ZX4->ZX4_END),ALLTRIM(ZX4->ZX4_EST))[3],"SN")//Numero do endereço
			aDest[5] := ALLTRIM(ZX4->ZX4_COMPLE)//Complemento
			aDest[6] := ALLTRIM(ZX4->ZX4_BAIRRO)//Bairro
			aDest[7] := ALLTRIM(ZX4->ZX4_CODMUN)//Codigo municipio
			aDest[8] := ALLTRIM(ZX4->ZX4_MUN)//Descrição Municipio
			aDest[9] := ALLTRIM(ZX4->ZX4_EST)//Estado A1_EST
			aDest[10]:= ALLTRIM(ZX4->ZX4_CEP)//CEP
		EndIf
		ZX4->(DbCloseArea())
	EndIf

	If LEN(aRet) == 0
		aadd(aRet,aDest)
		aadd(aRet,cDoc)
		aadd(aRet,cSerie)
	EndIf

	RestArea(aArea1)
	RestArea(aArea2)
EndIf

Return aRet