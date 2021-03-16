#include 'totvs.ch'

*--------------------*
User Function AtuCT1()
*--------------------*
Local cVisao  := Space(3)

Local lAtuPlano := .T.
Local lAtuVisao := .T.
Local lAtuDepara:= .T.
Local lAtu      := .F.
 
Local oDlg,oGrp,oLblVisao,oGetVisao,oCBPlano,oCBVisao,oSBtnOk,oSBCan

oDlg       := MSDialog():New( 142,386,315,749,"Atualização",,,.F.,,,,,,.T.,,,.T. )
oGrp       := TGroup():New( 004,004,060,172,"Parâmetros",oDlg,CLR_BLACK,CLR_WHITE,.T.,.F. )

oCBPlano   := TCheckBox():New( 016,012,"Atualizar Plano de Contas?",{|u| If(PCount()>0,lAtuPlano:=u,lAtuPlano)},oGrp,140,008,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )
oCBVisao   := TCheckBox():New( 026,012,"Atualiza Visão Gerencial?",{|u| If(PCount()>0,lAtuVisao:=u,lAtuVisao)},oGrp,150,008,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )
oCBDepara  := TCheckBox():New( 036,012,"Ajuste Plano de Contas Ref. ?",{|u| If(PCount()>0,lAtuDepara:=u,lAtuDepara)},oGrp,160,008,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )

oLblVisao  := TSay():New( 048,024,{||"Selecione a Visão Gerencial:"},oGrp,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,080,008)
oGetVisao  := TGet():New( 044,096,{|u| If(PCount()>0,cVisao:=u,cVisao)},oGrp,052,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"CTS","cVisao",,)

oSBtnOk    := SButton():New( 064,116,1,{|| lAtu := .T.,oDlg:End()},oDlg,,"", )
oSBCan     := SButton():New( 064,144,2,{|| oDlg:End()},oDlg,,"", )

oDlg:Activate(,,,.T.)

If lAtu
	
	If !lAtuPlano .and. !lAtuVisao .and. !lAtuDepara
		MsgInfo("Nenhuma atualização foi selecionada.")
	Else
		IncProc("Atualizando...")

		If lAtuPlano
			AtuPlano()
		EndIf
	
		If lAtuVisao
			AtuVisao(cVisao)
		EndIf   
		
		If lAtuDepara
			AtuDepara()
		EndIf
	EndIf

EndIf


*------------------------*
Static Function AtuPlano()
*------------------------*            
Local lSPEDST  := .F.

Local cTexto  := ''

//////////////////////////////////
//Atualização do Plano de Contas//
//////////////////////////////////

    SX3->(DbSetOrder(2))
    SX3->(DbGotop()) 
    If SX3->(MsSeek("CT1_SPEDST"))
       lSPEDST:= .T.
       cTexto += 'Campo CT1_SPEDST atualizado!!'+CHR(13)+CHR(10)
    Else
       lSPEDST:= .F.
       cTexto += 'Campo CT1_SPEDST não encontrado!!'+CHR(13)+CHR(10)       
    EndIf
    If SX3->(MsSeek("CT1_NTSPED"))
       DBSELECTAREA("CT1")
       CT1->(DbSetOrder(1))
       CT1->(DbGoTop())
       Do While !CT1->(EOF()) 
          RecLock("CT1",.F.) 
          If EMPTY(CT1->CT1_NTSPED)   
             If Substr(CT1->CT1_CONTA, 1,1) = '1'   
                CT1->CT1_NTSPED := '01'
             ElseIf Substr(CT1->CT1_CONTA, 1,1) = '2'   
                If Val(Substr(CT1->CT1_CONTA, 2,1)) > 2
	               CT1->CT1_NTSPED := '03'
	            Else
	               CT1->CT1_NTSPED := '02'
	            EndIF
	         Else
	            CT1->CT1_NTSPED := '04'
             EndIf                  
          EndIf
          If EMPTY(CT1->CT1_SPEDST) .And. lSPEDST
             CT1->CT1_SPEDST := CT1->CT1_CLASSE                 
	      EndIf   
          MsUnlock()                
          CT1->(DbSkip())
       EndDo                 
       cTexto += 'Campo CT1_NTSPED atualizado!!'+CHR(13)+CHR(10)
    Else
       cTexto += 'Campo CT1_NTSPED não encontrado!!'+CHR(13)+CHR(10)
    EndIf     
          
    MsgInfo(cTexto,"Atenção!")

Return Nil

*-------------------------------*
Static Function AtuVisao(cVisao)
*-------------------------------*
Local lAtu := .F.

Local cOrdem  := ""
Local cOrdSup := ""

Local nPos := 0

Local aBkp := {}

IncProc("Atualizando Visao Contabil...")                     

BeginSql Alias "QRY"
	SELECT CTS_ORDEM, CTS_CONTAG, CTS_CTASUP,CTS_DESCCG,CTS_CLASSE,R_E_C_N_O_
	FROM %table:CTS%
	WHERE %notDel%
	  AND CTS_CODPLA = %exp:cVisao%
EndSql

QRY->(DbGoTop())
While QRY->(!EOF())
    
    cOrdem  := ""
    cOrdSup := ""
    
    If aScan(aBkp,{|a| AllTrim(a[1]) ==  AllTrim(QRY->CTS_CONTAG)} ) == 0
		aAdd(aBkp,{AllTrim(QRY->CTS_CONTAG),AllTrim(QRY->CTS_ORDEM)})
	EndIf
     
	If !Empty(QRY->CTS_CTASUP)
		nPos := aScan(aBkp,{|a| AllTrim(a[1]) == AllTrim(QRY->CTS_CTASUP)})			
		
		If nPos > 0
			cOrdSup := Right(aBkp[nPos][2],4) 
		Else
			cOrdSup := QRY->CTS_CTASUP
		EndIf
	EndIf

	cOrdem := Right(QRY->CTS_ORDEM,4)
		
	CTS->(DbGoTo(QRY->R_E_C_N_O_))	
	CTS->(RecLock("CTS",.F.))
	
	CTS->CTS_CONTAG := cOrdem
	CTS->CTS_CTASUP := cOrdSup

	lAtu := .T.
	               
	CTS->(MsUnlock())
	
	QRY->(DbSkip())
EndDo   
   
//JSS - 20150518 - Add função para correção dos arquivo do sped. Função elimina as contas que existem no CVD e não existem no CT1
*---------------------------*
Static Function AtuDepara()    
*---------------------------*            
Local cConta := ''
Local cTexto := ''

////////////////////////////
//Atualização do De/ Para //
////////////////////////////

       DbSelectArea("CVD")
       CVD->(DbSetOrder(1))
       CVD->(DbGoTop())
       Do While !CVD->(EOF())
       RecLock("CVD",.F.) 
	        DbSelectArea("CT1")
    	    CT1->(DbSetOrder(1))
    	    CT1->(DbGoTop())
 		   	If !CT1->(DbSeek(xFilial("CVD") + CVD->CVD_CONTA,.T.))
                CVD->(DbDelete())                
            EndIf    	        		 		             			
 	   MsUnlock()              
       CVD->(DbSkip())
       EndDo                 
       cTexto += 'Ajustado plano de conta referencial!!'+CHR(13)+CHR(10)   
       MsgInfo(cTexto,"Atenção!")

Return Nil

QRY->(DbCloseArea())

If lAtu
	MsgInfo("Excluído as contas do plano de contas referencial que não existiam no plano de contas.","Atenção")
Else
	MsgInfo("Não foi possível realizar a atualização","Atenção")
EndIf


Return Nil