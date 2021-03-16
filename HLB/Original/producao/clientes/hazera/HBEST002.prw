#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
/*
Funcao      : HBEST002
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Tratamento customizado para manutenção de campos no D1.
Autor       : Jean Victor Rocha
Data/Hora   : 13/09/2012
*/
*-----------------------*
User Function HBEST002()
*-----------------------*         
Local i
Local oDlg
Local oGetDados, oSBtn1,oSBtn2
Local nUsado := 0
Local aAux := {}
Private lRefresh := .T.
Private aHeader := {}
Private aCols := {}

aCampos := {"D1_DOC","D1_SERIE","D1_FORNECE","D1_LOJA","D1_COD","D1_ITEM","D1_QUANT","D1_P_ENTRY","D1_P_TEST","D1_P_PER"}
SX3->(DbSelectArea("SX3"))
SX3->(DbSetOrder(2))
For i:=1 to Len(aCampos)
	nUsado++
	SX3->(DbSeek(aCampos[i]))
	Aadd(aHeader,{Trim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,""/*SX3->X3_VALID*/,"",SX3->X3_TIPO,"","" })	
Next i

SW9->(DbSetOrder(3))
SD1->(DbSetOrder(1))//D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
SD1->(DbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA   ))
While SD1->(!EOF()) .and. SF1->F1_FILIAL == SD1->D1_FILIAL .and. SF1->F1_DOC     == SD1->D1_DOC     .and.;
						  SF1->F1_SERIE  == SD1->D1_SERIE  .and. SF1->F1_FORNECE == SD1->D1_FORNECE .and.;
						  SF1->F1_LOJA   == SD1->D1_LOJA
	If LEFT(SD1->D1_COD,3) == "RNC"
		aAux := {}
		For i := 1 To len(aCampos)
			aAdd(aAux,&("SD1->"+aCampos[i]))
		Next
		Aadd(aCols,aAux)
	EndIf
	SD1->(DbSkip()	)
EndDo

If Len(aCols) == 0
	MsgInfo("NF não possui itens autorizados para manutenção!")
	Return .F.
EndIf

DEFINE MSDIALOG oDlg TITLE "HLB BRASIL" FROM 00,00 TO 350,800 PIXEL
	oGetDados := MSGETDADOS():NEW(05, 05, 145, 395, 4, "U_LINHAOK", "","", .F., {"D1_P_ENTRY","D1_P_TEST","D1_P_PER","W9_INVOICE"}, , .F., Len(aCols), "U_FIELDOK", "", , "", oDlg)
	
	oSBtn1     := SButton():New( 160,334,1,{|| ( Grava(),	oDlg:END())},oDlg,,"", )
	oSBtn2     := SButton():New( 160,370,2,{|| ( 			oDlg:END())},oDlg,,"", )
	
ACTIVATE MSDIALOG oDlg CENTERED

Return .T.

*---------------------*         
Static Function Grava()
*---------------------*
Local lRet := .T.
Local i

SD1->(DbSetOrder(1))//D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
For i:=1 to Len(aCols)
	If SD1->(DbSeek(xFilial("SD1")+aCols[i][1]+aCols[i][2]+aCols[i][3]+aCols[i][4]+aCols[i][5]+aCols[i][6] ))	
		SD1->(RecLock("SD1", .F.))
		SD1->D1_P_ENTRY := aCols[i][8]
		SD1->D1_P_TEST	:= aCols[i][9]
		SD1->D1_P_PER   := aCols[i][10]
		SD1->(MsUnlock())
	EndIf
Next i

Return lRet 

*---------------------*
User Function LINHAOK()
Return .T.

*---------------------*
User Function FIELDOK()
Return .T.