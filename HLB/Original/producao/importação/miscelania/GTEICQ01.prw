#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"

/*
Funcao      : GTEICQ01
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : QBG para atualização da base de dados do modulo EIC com as filiais do faturamento e alteração de Dicionario para exclusivo no modulo EIC.
Autor       : Jean Victor Rocha
Data/Hora   : 26/01/12
*/
*----------------------*
User Function GTEICQ01()
*----------------------*
Local i, j
Local cMsg:= "Processo a serem alterados nas tabelas do EIC!" +CHR(13)+CHR(10)

Local bAcaoBKP := {|lFim| BKP(  @lFim)   }
Local bAcaoBUS := {|lFim| Busca(@lFim)   }
Local bAcaoATU := {|lFim| Atualiza(@lFim)}
Local bAcaoSX2 := {|lFim| AtuSX2(@lFim)  }
Local cTitulo := ''
Local cMsg := 'Processando'
Local lAborta := .F.

Private cLog:= ""
Private nTam       := 4
Private aVinculos  := {}//"SF1354","SW01570"

Processa( bAcaoBKP, cTitulo, cMsg, lAborta )
Processa( bAcaoBUS, cTitulo, cMsg, lAborta )

cMsg += "_____________________________________________"  +CHR(13)+CHR(10)
cMsg += "Total de Processos a ser atualizado: " + ALLTRIM(STR(Len(aVinculos)))+CHR(13)+CHR(10)
                   
For i:= 1 To Len(aVinculos)
	SF1->(DbGoTo( val(SuBStr(aVinculos[i][1],nTam,Len(aVinculos[i][1]))) ))
	cMsg += SF1->F1_HAWB +CHR(13)+CHR(10)
	For j:= 1 to Len(aVinculos[i])
       	If VALTYPE(aVinculos[i][j]) == "A"
       		cAlias := LEFT(aVinculos[i][j][1],3)
       	EndIf
	Next i
Next i

EECVIEW(cMsg)

If MsgYESNO("Verifique se o Backup das tabelas foi executado corretamente! Deseja continuar com a atualização?")
	Processa( bAcaoATU, cTitulo, cMsg, lAborta )
EndIf

Processa( bAcaoSX2, cTitulo, cMsg, lAborta )

GRVLOG(cLog) //Grava log no System
	
MsgInfo("Atualização Finalizada!")	
	
Return .T.

*------------------------*
Static Function AtuSX2()
*------------------------*
Local i
Local aTab := {"SF1","SWN","SWD","SWW","SWA","SWB","SW6","SW7","SW8","SW9","SW5","SW4","SW3","SW2","SW1","SW0","SWO"}
  
ProcRegua(LEN(aTab))

SX2->(DbSetOrder(1))
For i:= 1 to len(aTab)
	IncProc("Atualizando o SX2 para a tabela '"+aTab[i]+"'...")
	If SX2->(DbSeek(aTab[i])) .and. SX2->X2_MODO == "C"
		SX2->(RecLock("SX2", .F.))
		SX2->X2_MODO := "E"
		SX2->(MsUnlock())
	EndIf
Next i

Return .t.  
    
*------------------------*
Static Function Atualiza()
*------------------------*
Local i, j
Local cFil    := Space(2)
Local cAlias  := Space(3)
Local bCampo

cLog += "Processo alterados nas tabelas do EIC!"           + CHR(13) + CHR(10)
cLog += "_____________________________________________"    + CHR(13) + CHR(10)
cLog += "Total de Processos atualizados: " + ALLTRIM(STR(Len(aVinculos)))+CHR(13)+CHR(10)
cLog += "Processo          | Alias+Rec| ..." + CHR(13) + CHR(10)

ProcRegua(LEN(aVinculos))

For i:= 1 To Len(aVinculos)
	IncProc(ALLTRIM(STR(i))+"\"+ALLTRIM(STR(Len(aVinculos)))+" - Atualizando vinculos de processos...")
	SF1->(DbGoTo( val(SuBStr(aVinculos[i][1],nTam,Len(aVinculos[i][1]))) ))
	cFil := SF1->F1_FILIAL
	cLog += SF1->F1_HAWB + " | " + aVinculos[i][1] +SPACE(8-LEN(aVinculos[i][1])) + " | "

	If Len(aVinculos[i]) > 0
		For j:= 1 to Len(aVinculos[i])
        	If VALTYPE(aVinculos[i][j]) == "A"
        		cAlias := LEFT(aVinculos[i][j][1],3)
				bCampo := &("{|| " + cAlias + "->" + RIGHT(cAlias,2) + "_FILIAL := '" + cFil + "' }")
        		(cAlias)->(DbGoTO( val(SuBStr(aVinculos[i][j][1],nTam,Len(aVinculos[i][j][1]))) ))
        		(cAlias)->(RecLock(cAlias, .F.))
				eval(bCampo)
        		(cAlias)->(MsUnlock())
       			cLog += aVinculos[i][j][1] +SPACE(8-LEN(aVinculos[i][j][1])) + " | "
        	EndIf
		Next i
		cLog += CHR(13) + CHR(10)
	EndIf
Next i

Return cLog

*----------------------*
Static Function Busca()
*----------------------*
Local aTab := {"SF1","SWN","SWD","SWW","SWA","SWB","SW6","SW7","SW8","SW9","SW5","SW4","SW3","SW2","SW1","SW0","SWO"}
ProcRegua(SF1->(RECCOUNT()))

SF1->(dbSetOrder(1))//F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
SWN->(dbSetOrder(2))//WN_FILIAL+WN_DOC+WN_SERIE+WN_FORNECE+WN_LOJA
SWD->(dbSetOrder(1))//WD_FILIAL+WD_HAWB+WD_DESPESA+DTOS(WD_DES_ADI)
SWW->(dbSetOrder(2))//WW_FILIAL+WW_HAWB+WW_TIPO_NF        
SWA->(dbSetOrder(1))//WA_FILIAL+WA_HAWB+WA_PO_DI
SWB->(dbSetOrder(1))//WB_FILIAL+WB_HAWB+WB_PO_DI+WB_INVOICE+WB_FORN+WB_LOJA+WB_LINHA 
SW6->(dbSetOrder(1))//W6_FILIAL+W6_HAWB
SW7->(dbSetOrder(4))//W7_FILIAL+W7_HAWB+W7_PO_NUM+W7_POSICAO+W7_PGI_NUM
SW8->(dbSetOrder(1))//W8_FILIAL+W8_HAWB+W8_INVOICE+W8_FORN
SW9->(dbSetOrder(3))//W9_FILIAL+W9_HAWB
SW5->(dbSetOrder(2))//W5_FILIAL+W5_HAWB 
SW4->(dbSetOrder(1))//W4_FILIAL+W4_PGI_NUM 
SW3->(dbSetOrder(1))//W3_FILIAL+W3_PO_NUM+W3_CC+W3_SI_NUM+W3_COD_I
SW2->(dbSetOrder(1))//W2_FILIAL+W2_PO_NUM
SW1->(dbSetOrder(1))//W1_FILIAL+W1_CC+W1_SI_NUM+W1_COD_I
SW0->(dbSetOrder(1))//W0_FILIAL+W0__CC+W0__NUM
SWO->(dbSetOrder(1))//WO_FILIAL+WO_PO_NUM 

SF1->(DbGoTop())
While SF1->(!EOF())
	IncProc("Buscando vinculos de processos...")
	If EMPTY(SF1->F1_HAWB)
		SF1->(DbSkip())
		Loop
	EndIf
	//SF1 - base paa buscas...
	aAdd(aVinculos, {"SF1"+ALLTRIM(STR(SF1->(RECNO()) )) })
	nPos := Len(aVinculos)
	//Itens NF.
	If SWN->(DbSeek(xFilial("SWN")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))
		While SWN->(!EOF()) .and. SWN->(WN_DOC+WN_SERIE+WN_FORNECE+WN_LOJA) == SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
			aAdd(aVinculos[nPos], {"SWN"+ALLTRIM(STR(SWN->(RECNO()) )) } )
			SWN->(DbSkip())
		EndDo
	EndIf	 
	//Despesas do desembaraço
	If SWD->(DbSeek(xFilial("SWD")+SF1->F1_HAWB ))
		While SWD->(!EOF()) .and. SWD->WD_HAWB == SF1->F1_HAWB
			aAdd(aVinculos[nPos], {"SWD"+ALLTRIM(STR(SWD->(RECNO()) )) } )
			SWD->(DbSkip())
		EndDo
	EndIf
	//Despesas da NF
	If SWW->(DbSeek(xFilial("SWW")+SF1->F1_HAWB ))  
		While SWW->(!EOF()) .and. SWW->WW_HAWB == SF1->F1_HAWB
			aAdd(aVinculos[nPos], {"SWW"+ALLTRIM(STR(SWW->(RECNO()) )) } )
			SWW->(DbSkip())
		EndDo
	EndIf   
	//Cambio - Capa.
	If SWA->(DbSeek(xFilial("SWA")+SF1->F1_HAWB ))  
		While SWA->(!EOF()) .and. SWA->WA_HAWB == SF1->F1_HAWB
			aAdd(aVinculos[nPos], {"SWA"+ALLTRIM(STR(SWA->(RECNO()) )) } )
			//Cambio - Itens
			If SWB->(DbSeek(xFilial("SWB")+SF1->F1_HAWB ))
				While SWB->(!EOF()) .and. SWB->WB_HAWB == SF1->F1_HAWB
					aAdd(aVinculos[nPos], {"SWB"+ALLTRIM(STR(SWB->(RECNO()) )) } )
					SWB->(DbSkip())
				EndDo
			EndIf
			SWA->(DbSkip())
		EndDo
	EndIf
	//Desembaraço - Capa
	If SW6->(DbSeek(xFilial("SW6")+SF1->F1_HAWB ))
		While SW6->(!EOF()) .and. SW6->W6_HAWB == SF1->F1_HAWB
			aAdd(aVinculos[nPos], {"SW6"+ALLTRIM(STR(SW6->(RECNO()) )) } )
			SW6->(DbSkip())
		EndDo
	EndIf 

	//Invoice
	IF !SW8->(DBSEEK(xFilial("SW8")+SF1->F1_HAWB))
		While SW8->(!EOF()) .and. SW8->W8_HAWB == SF1->F1_HAWB
			aAdd(aVinculos[nPos], {"SW8"+ALLTRIM(STR(SW8->(RECNO()) )) } )
			SW8->(DbSkip())
		EndDo
	ENDIF			
	IF !SW9->(DBSEEK(xFilial("SW9")+SF1->F1_HAWB))
		While SW9->(!EOF()) .and. SW9->W9_HAWB == SF1->F1_HAWB
			aAdd(aVinculos[nPos], {"SW9"+ALLTRIM(STR(SW8->(RECNO()) )) } )
			SW9->(DbSkip())
		EndDo
	ENDIF

	//Desembaraço - Itens
	If SW7->(DbSeek(xFilial("SW7")+SF1->F1_HAWB ))
		While SW7->(!EOF()) .and. SW7->W7_HAWB == SF1->F1_HAWB
			aAdd(aVinculos[nPos], {"SW7"+ALLTRIM(STR(SW7->(RECNO()) )) } )
			   	//Ocorrencias
				If SWO->(DbSeek(xFilial("SWO")+SW7->W7_PO_NUM ))
					While SWO->(!EOF()) .and. SWO->WO_PO_NUM == SW7->W7_PO_NUM
						aAdd(aVinculos[nPos], {"SWO"+ALLTRIM(STR(SWO->(RECNO()) )) } )
						SWO->(DbSkip())
					EndDo
				EndIf
				//PO - Capa
				If SW2->(DbSeek(xFilial("SW2")+SW7->W7_PO_NUM ))
					While SW2->(!EOF()) .and. SW2->W2_PO_NUM == SW7->W7_PO_NUM
						aAdd(aVinculos[nPos], {"SW2"+ALLTRIM(STR(SW2->(RECNO()) )) } )
						SW2->(DbSkip())
					EndDo
				EndIf
				//PO - Itens
				If SW3->(DbSeek(xFilial("SW3")+SW7->W7_PO_NUM ))
					While SW3->(!EOF()) .and. SW3->W3_PO_NUM == SW7->W7_PO_NUM
						aAdd(aVinculos[nPos], {"SW3"+ALLTRIM(STR(SW3->(RECNO()) )) } )
						//SI - Capa
						If SW0->(DbSeek(xFilial("SW0")+SW3->W3_CC+SW3->W3_SI_NUM ))
							While SW0->(!EOF()) .and. SW0->W0__NUM == SW3->W3_SI_NUM .and. SW0->W0__CC == SW3->W3_CC
								aAdd(aVinculos[nPos], {"SW0"+ALLTRIM(STR(SW0->(RECNO()) )) } )
								SW0->(DbSkip())
							EndDo
						EndIf
						//SI - Itens
						If SW1->(DbSeek(xFilial("SW1")+SW3->W3_CC+SW3->W3_SI_NUM ))
							While SW1->(!EOF()) .and. SW1->W1_SI_NUM == SW3->W3_SI_NUM .and. SW1->W1_CC == SW3->W3_CC
								aAdd(aVinculos[nPos], {"SW1"+ALLTRIM(STR(SW1->(RECNO()) )) } )
								SW1->(DbSkip())
							EndDo
						EndIf								
						SW3->(DbSkip())
					EndDo
				EndIf   
			SW7->(DbSkip())
		EndDo
	EndIf	
	
	//LI - Itens
	If SW5->(DbSeek(xFilial("SW5")+SF1->F1_HAWB ))
		While SW5->(!EOF()) .and. SW5->W5_HAWB == SF1->F1_HAWB
			aAdd(aVinculos[nPos], {"SW5"+ALLTRIM(STR(SW5->(RECNO()) )) } )
			//LI- capa
			If SW4->(DbSeek(xFilial("SW4")+SF1->F1_HAWB ))
				While SW4->(!EOF()) .and. SW4->W4_HAWB == SF1->F1_HAWB
					aAdd(aVinculos[nPos], {"SW4"+ALLTRIM(STR(SW4->(RECNO()) )) } )
					SW4->(DbSkip())
				EndDo
			EndIf			
			SW5->(DbSkip())
		EndDo
	EndIf 
	SF1->(DbSkip())
EndDo

Return .t.

*--------------------------*
Static Function GRVLOG(cLog)
*--------------------------*
Local cDirLog:= "\BKP\JVR\QBG_"+DTOS(DATE())+"\"
Local nLogHdl

If !File(Alltrim(cDirLog)+"QBGEIC_LOG.txt")//Cria ou abre o arquivo de log
	nLogHdl := FCreate(Alltrim(cDirLog)+"QBGEIC_LOG.txt")
Else
	nLogHdl := FOpen(Alltrim(cDirLog)+"QBGEIC_LOG.txt", 18)		
	nFSeek  := FSeek(nLogHdl, 0, 2)
EndIf 


FWrite(nLogHdl, cLog)
FClose(nLogHdl)


Return .T. 

*-------------------*
Static Function BKP()
*-------------------*
Local i
Local aTab := {"SWN","SWD","SWW","SWA","SWB","SW6","SW7","SW8","SW9","SW5","SW4","SW3","SW2","SW1","SW0","SWO"}

ProcRegua(Len(aTab))

For i:= 1 to Len(aTab)  
	IncProc(ALLTRIM(STR(i))+"\"+ALLTRIM(STR(Len(aTab)))+" - Efetuando Backup da tabela '"+aTab[i]+"'...")
	GeraBKP(aTab[i])
Next i

Return .T.

*-----------------------------*
Static Function GeraBKP(cAlias)
*-----------------------------*
Local cNome := ""
Local cDirBKP := "\BKP\JVR\QBG_"+DTOS(DATE())+"\"

If Select("WORK") > 0
	WORK->(DbCloseArea())
EndIf

cNome := CriaTrab((cAlias)->(DBSTRUCT()),.t.)
dbUseArea(.T.,, cNome, "WORK",.F.,.F.)
DbSelectArea("WORK")

(cAlias)->(DbGoTop())
While (cAlias)->(!Eof())
	WORK->(DbAppend())
	AvReplace((cAlias),"WORK")
	WORK->(MsUnlock())
	(cAlias)->(DbSkip())
EndDo 
     
DbSelectArea("WORK")
DbCloseArea()

If !EXISTDIR(cDirBKP)
	MontaDIR(cDirBKP)
EndIf

cArqOrig	:= "\SYSTEM\"+cNome+".DBF"
cArqDest	:= cDirBKP+cAlias+SM0->M0_CODIGO+"0.DBF"

__CopyFile( cArqOrig, cArqDest )

Return .T.