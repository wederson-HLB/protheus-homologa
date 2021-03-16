#include "rwmake.ch"  

/*
Funcao      : ATUND 
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Vinculo automatico de todos os produtos referente a nota de debito no Contrato
Autor       : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 06/02/2012
Módulo      : Contratos.
*/

*---------------------*
 User Function ATUND()
*---------------------* 

Private cND      := ''   
Private xProdND  := {}

cQuery := "" 
cQuery := "SELECT B1_FILIAL, B1_COD, B1_DESC, B1_GRUPO, R_E_C_N_O_ RECNO "
cQuery += ' FROM '+ RetSQLname("SB1")
cQuery += " WHERE D_E_L_E_T_ <> '*' "
cQuery += " AND B1_FILIAL = '"+xFilial("SB1")+ " '"
cQuery += " AND B1_GRUPO = 'ND  ' "
cQuery += " AND B1_MSBLQL <> '1' "
cQuery += " ORDER BY B1_COD+B1_DESC "
MEMOWRIT("SELSB1.SQL",cQuery)
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TMP", .F., .T.)
dbSelectArea("TMP")
DbGoTop()
    
While !Eof()
    cND          += Iif(Empty(cND),Alltrim(SB1->B1_COD),"/"+Alltrim(SB1->B1_COD))
	dbSelectArea("TMP")
	dbSkip()
EndDo 
If !Empty(cND)
    cND += "/"           
Endif    

dbSelectArea("TMP")
dbCloseArea("TMP")

Processa( {|| ProcAtu() } )
                          
Return


Static Function ProcAtu()

Local nCTR := 0 

dbSelectArea("CN9")
dbSetOrder(1)
dbGoTop()

While !Eof()
	If !Empty(CN9->CN9_P_ITND) .OR. !CN9->CN9_SITUAC $ "0205"
		dbSkip()
		Loop
	Endif
	RecLock("CN9")
	CN9->CN9_P_NDRE := "1"
	CN9->CN9_P_ITND := cND
	MsUnlock()
	nCTR := nCTR + 1
	dbSkip()
	
	For i:=1 to Len(ALLTRIM(cND))
		If substr(cND,i,1) <> "/"
			cProd := Alltrim(cProd)+substr(cND,i,1)
		Else
			aadd( xProdND, cProd )
			cProd := ""
		Endif
	Next
	If Len(xProdND) > 0
		dbSelectArea("ZZ7")
		dbSetOrder(1)
		dbGoTop()
		If !dbSeek(xFilial("ZZ7")+CN9->CN9_NUMERO)
			dbSelectArea("ZZ7")
			RecLock("ZZ7",.T.)
			ZZ7->ZZ7_FILIAL := xFilial("ZZ7")
			ZZ7->ZZ7_CONTRA := CN9->CN9_NUMERO
			ZZ7->ZZ7_CODIGO := CN9->CN9_CLIENT
			ZZ7->ZZ7_LOJA   := CN9->CN9_LOJACL
			ZZ7->ZZ7_DESC   := CN9->CN9_P_NOME
			//				ZZ7->ZZ7_ITEM   := CN9->CN9_P_ITEM
			//				ZZ7->ZZ7_DESCI  := Posicione("CTD",1,xFilial("CTD")+CN9->CN9_P_ITEM,"CTD_DESC01")
			MsUnlock()
		Else
			//				dbSelectArea("ZZ7")
			//				RecLock("ZZ7",.F.)
			//				ZZ7->ZZ7_FILIAL := xFilial("ZZ7")
			//				ZZ7->ZZ7_ITEM   := CN9->CN9_P_ITEM
			//				ZZ7->ZZ7_DESCI  := Posicione("CTD",1,xFilial("CTD")+CN9->CN9_P_ITEM,"CTD_DESC01")
			//				MsUnlock()
		Endif
		
		dbSelectArea("ZZ9")
		dbSetOrder(1)
		dbGoTop()
		If dbSeek(xFilial("ZZ9")+CN9->CN9_NUMERO+CN9->CN9_CLIENT)
			While !Eof() .And. CN9->CN9_NUMERO+CN9->CN9_CLIENT == ZZ9->ZZ9_CONTRA+ZZ9->ZZ9_CODCLI
				cProd := Alltrim(ZZ9->ZZ9_CODIGO)
				If cProd $ cND
					dbSkip()
					Loop
				Else
					dbSelectArea("ZZ9")
					RecLock("ZZ9",.F.)
					dbDelete()
					MsUnlock()
				Endif
				dbSkip()
			Enddo
		Endif
		For i:=1 to Len(xProdND)
			If !dbSeek(xFilial("ZZ9")+CN9->CN9_NUMERO+CN9->CN9_CLIENT+xProdND[i])
				dbSelectArea("ZZ9")
				RecLock("ZZ9",.T.)
				ZZ9->ZZ9_FILIAL := xFilial("ZZ9")
				ZZ9->ZZ9_CONTRA := CN9->CN9_NUMERO
				ZZ9->ZZ9_CODCLI := CN9->CN9_CLIENT
				ZZ9->ZZ9_CODIGO := xProdND[i]
				ZZ9->ZZ9_DESCP  := Posicione("SB1",1,xFilial("SB1")+xProdND[i],"B1_DESC")
				ZZ9->ZZ9_CONTA  := Posicione("SB1",1,xFilial("SB1")+xProdND[i],"B1_CONTA")
				ZZ9->ZZ9_DESCC  := Posicione("CT1",1,xFilial("CT1")+Posicione("SB1",1,xFilial("SB1")+xProdND[i],"B1_CONTA"),"CT1_DESC01")
				MsUnlock()
			Else
				dbSelectArea("ZZ9")
				RecLock("ZZ9",.F.)
				ZZ9->ZZ9_DESCP  := Posicione("SB1",1,xFilial("SB1")+xProdND[i],"B1_DESC")
				ZZ9->ZZ9_CONTA  := Posicione("SB1",1,xFilial("SB1")+xProdND[i],"B1_CONTA")
				ZZ9->ZZ9_DESCC  := Posicione("CT1",1,xFilial("CT1")+Posicione("SB1",1,xFilial("SB1")+xProdND[i],"B1_CONTA"),"CT1_DESC01")
				MsUnlock()
			Endif
		Next
	Endif
	dbSelectArea("CN9")
	dbSkip()
Enddo
                     
MsgAlert("Contratos Atualizados "+strzero(nCTR,6))

Return