#include "TOPCONN.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"  
#include "Protheus.ch"
#include "Rwmake.ch"       

/*
Funcao      : DarfAdObs
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Ponto de entrada que permite adicionar informações ao campo observações no DARF.
Autor       : Jean Victor Rocha.
Data/Hora   : 01/07/2013
*/                        
*----------------------*
User Function DarfAdObs()
*----------------------*
Local cObs		:= ""
Local aOrd		:= Saveord({"FI9","SE2"})
Local lValid	:= .F.
Local nNumArray	:= ParamIXB[2]
Private cGet	:= Space(70)

//Validar se existe o campo customizado para gravar as observações no DARF
If FI9->(FieldPos("FI9_P_OBS")) <> 0
	lValid:= .T.
EndIf

FI9->(DbSetOrder(1))//FI9_FILIAL+FI9_IDDARF+FI9_STATUS
SE2->(DbSetOrder(1))//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA

SetPrvt("oDlg1","oSay1","oSay2","oGet1","oSBtn1","oSBtn2")

cPrefixo	:= SubStr(ParamIXB[1][nNumArray][13],											 1,TamSx3("E2_PREFIXO")[1])
cNum		:= SubStr(ParamIXB[1][nNumArray][13],Len(cPrefixo)								+1,TamSx3("E2_NUM")[1]	)
cParcela	:= SubStr(ParamIXB[1][nNumArray][13],Len(cPrefixo+cNum)	 						+1,TamSx3("E2_PARCELA")[1])
cTipo		:= SubStr(ParamIXB[1][nNumArray][13],Len(cPrefixo+cNum+cParcela)				+1,TamSx3("E2_TIPO")[1]	)
cFornec		:= SubStr(ParamIXB[1][nNumArray][13],Len(cPrefixo+cNum+cParcela+cTipo)	 		+1,TamSx3("E2_FORNECE")[1])
cLoja		:= SubStr(ParamIXB[1][nNumArray][13],Len(cPrefixo+cNum+cParcela+cTipo+cFornec)	+1,TamSx3("E2_LOJA")[1])

//Em caso de re-impressão.
If IsInCallStack("FINA373") .And. SE2->(DbSeek(xFilial("SE2")+cPrefixo+cNum+cParcela+cTipo+cFornec+cLoja))
	If FI9->(DbSeek(xFilial("FI9")+SE2->E2_IDDARF)) .and. FI9->(FieldPos("FI9_P_OBS")) <> 0
	    While FI9->(!EOF()) .and. FI9->FI9_FILIAL == xFilial("FI9") .and. FI9->FI9_IDDARF == SE2->E2_IDDARF		    	
			If !EMPTY(FI9->FI9_P_OBS)
				Return FI9->FI9_P_OBS
			EndIf
			FI9->(DbSkip())
		EndDo
	EndIf	
EndIf

oDlg1      := MSDialog():New( 243,485,463,848,"HLB BRASIL.",,,.F.,,,,,,.T.,,,.T. )
oGrp1      := TGroup():New( 004,002,018,180,"",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
oSay1      := TSay():New( 008,004,{||"Inclusão de Observação na  DARF (Opcional)."},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,112,008)

oGrp2      := TGroup():New( 019,002,058,180,"",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
oSay2      := TSay():New( 020,004,{||"DARF: "									},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,112,008)
oSay3      := TSay():New( 028,020,{||"Prefixo: "+cPrefixo						},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,112,008)
//	oSay4      := TSay():New( 028,100,{||"Parcela: "+cParcela					},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,112,008)
oSay5      := TSay():New( 036,020,{||"Num.:"+cNum								},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,112,008)
oSay6      := TSay():New( 036,100,{||"Tipo: "+cTipo							},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,112,008)
oSay7      := TSay():New( 044,020,{||"Forn.:"+cFornec							},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,112,008)
oSay8      := TSay():New( 044,100,{||"loja: "+cLoja							},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,112,008)

oSay9      := TSay():New( 060,004,{||"Obs: "	  								},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,112,008)
oGet1      := TGet():New( 068,004,{|u| If(PCount()>0,cGet:=u,cGet)},oDlg1,168,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cGet",,)
oSBtn2     := SButton():New( 084,144,1,{||oDlg1:End()},oDlg1,,"", )

oDlg1:Activate(,,,.T.)
 
If !EMPTY(cGet)
	cObs:= cGet
EndIf

//Gravação da Obs na Tabela de DARF.
If !EMPTY(cObs) .and. SE2->(DbSeek(xFilial("SE2")+cPrefixo+cNum+cParcela+cTipo+cFornec+cLoja))
	If FI9->(DbSeek(xFilial("FI9")+SE2->E2_IDDARF)) .and. FI9->(FieldPos("FI9_P_OBS")) <> 0
	    While FI9->(!EOF()) .and. FI9->FI9_FILIAL == xFilial("FI9") .and. FI9->FI9_IDDARF == SE2->E2_IDDARF
	    	FI9->(RecLock("FI9",.F.))
	   		FI9->FI9_P_OBS := cGet
	    	FI9->(MsUnlock())
			FI9->(DbSkip())
		EndDo
	EndIf	
ElseIf !EMPTY(cObs)
	Alert("Não foi possivel a gravação da Observação na DARF!","HLB BRASIL.")
	Return ""
EndIf

//RRP - 02/07/2015 - Impressão da validade como observação no DARF.
If Empty(Alltrim(cObs)) .AND. SE2->(DbSeek(xFilial("SE2")+cPrefixo+cNum+cParcela+cTipo+cFornec+cLoja))
	cObs:= "DARF válido para pagamento até "+Alltrim(DtoC(SE2->E2_VENCREA))
EndIf
                                      
Restord(aOrd)

Return cObs