#include "rwmake.ch"
#include "protheus.ch"
#include "tbiconn.ch"
#include "TbiCode.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³RTPRECOB  ³ Autor ³                       ³ Data ³ 07/10/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Disparo de e-mails de Cobranca Preventiva Automatica       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*
Funcao      : RTPRECOB
Parametros  : Nenhum
Retorno     : cCampos
Objetivos   : Disparo de e-mails de Cobranca Preventiva Automatica 
Autor       : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 06/02/2012
Módulo      : Financeiro.
*/    

*-------------------------*
 User Function RTPRECOB() 
*-------------------------* 

Private cAmbiente    := "GTCORP/GTCORPTESTE/ENVGTCORP01/ENVGTCORP02/GTTESTE"
Private lFiltro      := .F.
Private cEmpr        := space(1)
Private xEmpr        := {}
Private xCNPJ        := {}
Private xAlias       := {}
Private cCliente 	 := space(6)
Private cLoja     	 := space(2)
Private cNome        := space(40)
Private cEmailTo  	 := ""
Private cEmailCC     := ""
Private aTit         := {}
Private nEmail       := 0
Private cPerg        := "PREVEN" // PARAMETROS PARA ESCOLHA DO CLIENTE E TITULOS A VENCER
Private aPergs       := {}
Private cTpCob       := ""
	
	////////////////////////////////////////////////
	// De  Cliente
	// Ate Cliente
	// De  Data Vencimento
	// Ate Data Vencimento
	// De  Prefixo
	// Ate Prefixo
	// De  Tipo
	// Ate Tipo
	// De  Gerente de Conta
	// Ate Gerente de Conta
	// Reenvia Preventiva ?
	////////////////////////////////////////////////

If Pergunte(cPerg,.T.)
	
	cTpCob := mv_par12
	
	If MV_PAR12 == 1   // Preventiva
		If (MV_PAR03 < DDATABASE .or. MV_PAR04 < DDATABASE)
			MsgAlert(" Período solicitado refere-se a titulos vencidos!!! A rotina envia email de cobraça PREVENTIVA, portanto os titulos não podem estar vencidos.")
			Return
		Endif
	ElseIf MV_PAR12 == 2  // Cobranca
		If (MV_PAR03 >= DDATABASE .or. MV_PAR04 >= DDATABASE)
			MsgAlert(" Período solicitado refere-se a titulos a vencer!!! A rotina envia email de COBRANCA, portanto os titulos DEVEM estar vencidos.")
			Return
		Endif
	Endif
	// Busca Empresas no cadastro de empresas - sigamat.emp
    Busca_Emp()
    Processa( {|| GeraEmail() } )

Endif

Return	
	// tabelas das empresas
	

Static Function GeraEmail()
// Inicia Query de Seleção de Titulos //
If Upper(GetEnvServer()) $ Upper(cAmbiente)
	If MV_PAR12 == 1 // PREVENTIVA
		If MSGYESNO("Confirma selecao dos titulos para envio de email de PREVENTIVA?","Atencao")
			For i:=1 to Len(xEmpr)
				If i == 1
					cSQL :=""
					cSQL := " (SELECT "+xAlias[i]+".E1_FILIAL,"+xAlias[i]+".E1_PREFIXO,"+xAlias[i]+".E1_NUM,"+xAlias[i]+".E1_PARCELA,"+xAlias[i]+".E1_TIPO,"+xAlias[i]+".E1_NATUREZ,"+xAlias[i]+".E1_CLIENTE,"+xAlias[i]+".E1_LOJA,"+xAlias[i]+".E1_EMISSAO,"+xAlias[i]+".E1_VENCTO,"+xAlias[i]+".E1_VENCREA,"+xAlias[i]+".E1_VALOR,"+xAlias[i]+".E1_SALDO,"+xAlias[i]+".E1_PORTADO,"+xAlias[i]+".E1_VEND1,"+xAlias[i]+".E1_TIPO, '"+xCNPJ [i]+" ' AS EMPRESA,"+xAlias[i]+".R_E_C_N_O_ AS RECNO_"+xAlias[i]+"  "
					cSQL += ' FROM ' + xEmpr[i]
				ElseIf i > 1
					cSQL += " UNION ALL "
					cSQL += " (SELECT "+xAlias[i]+".E1_FILIAL,"+xAlias[i]+".E1_PREFIXO,"+xAlias[i]+".E1_NUM,"+xAlias[i]+".E1_PARCELA,"+xAlias[i]+".E1_TIPO,"+xAlias[i]+".E1_NATUREZ,"+xAlias[i]+".E1_CLIENTE,"+xAlias[i]+".E1_LOJA,"+xAlias[i]+".E1_EMISSAO,"+xAlias[i]+".E1_VENCTO,"+xAlias[i]+".E1_VENCREA,"+xAlias[i]+".E1_VALOR,"+xAlias[i]+".E1_SALDO,"+xAlias[i]+".E1_PORTADO,"+xAlias[i]+".E1_VEND1,"+xAlias[i]+".E1_TIPO, '"+xCNPJ [i]+" ' AS EMPRESA,"+xAlias[i]+".R_E_C_N_O_ AS RECNO_"+xAlias[i]+"  "
					cSQL += ' FROM ' + xEmpr[i]
				Endif
				cSQL += " WHERE "+xAlias[i]+".D_E_L_E_T_ <> '*' "
				cSQL += " AND "+xAlias[i]+".E1_CLIENTE BETWEEN '"+MV_PAR01+ "' AND '"+MV_PAR02+ "' "
				cSQL += " AND "+xAlias[i]+".E1_PREFIXO BETWEEN '"+MV_PAR05+ "' AND '"+MV_PAR06+ "' "
				cSQL += " AND "+xAlias[i]+".E1_TIPO = '"+MV_PAR07+ "' "
				cSQL += " AND "+xAlias[i]+".E1_VENCREA BETWEEN '"+dtos(MV_PAR03)+ "' AND '"+dtos(MV_PAR04)+ "' "
				cSQL += " AND "+xAlias[i]+".E1_SALDO > 0 "
				cSQL += " AND "+xAlias[i]+".E1_VEND1 BETWEEN '"+MV_PAR09+ "' AND '"+MV_PAR10+ "' "
				//If mv_par11 == 1
				//	cSQL += " AND "+xAlias[i]+".E1_P_DTEMP = '' )"
				//Else
    				cSQL += " ) " 
			//	Endif
			Next
			cSQL += " ORDER BY E1_FILIAL,E1_CLIENTE,E1_LOJA,E1_VENCTO"
			MEMOWRIT("SELSE1.SQL",cSQL)
			cQuery := ChangeQuery(cSQL)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSQL),"TMP", .F., .T.)
			dbSelectArea("TMP")
			TCSETFIELD(Alias(),"TMP->E1_EMISSAO","D")
			TCSETFIELD(Alias(),"TMP->E1_VENCTO","D")
			TCSETFIELD(Alias(),"TMP->E1_VENCREA","D")
			TMP->(dbGoTop())
			lFiltro := .T.
		Endif
	ElseIf  MV_PAR12 == 2     // COBRANCA
		If MSGYESNO("Confirma selecao dos titulos para envio de email de COBRANCA?","Atencao")
			For i:=1 to Len(xEmpr)
				If i == 1
					cSQL :=""
					cSQL := " (SELECT "+xAlias[i]+".E1_FILIAL,"+xAlias[i]+".E1_PREFIXO,"+xAlias[i]+".E1_NUM,"+xAlias[i]+".E1_PARCELA,"+xAlias[i]+".E1_TIPO,"+xAlias[i]+".E1_NATUREZ,"+xAlias[i]+".E1_CLIENTE,"+xAlias[i]+".E1_LOJA,"+xAlias[i]+".E1_EMISSAO,"+xAlias[i]+".E1_VENCTO,"+xAlias[i]+".E1_VENCREA,"+xAlias[i]+".E1_VALOR,"+xAlias[i]+".E1_SALDO,"+xAlias[i]+".E1_PORTADO,"+xAlias[i]+".E1_VEND1,"+xAlias[i]+".E1_TIPO, '"+xCNPJ [i]+" ' AS EMPRESA,"+xAlias[i]+".R_E_C_N_O_ AS RECNO_"+xAlias[i]+"  "
					cSQL += ' FROM ' + xEmpr[i]
				ElseIf i > 1
					cSQL += " UNION ALL "
					cSQL += " (SELECT "+xAlias[i]+".E1_FILIAL,"+xAlias[i]+".E1_PREFIXO,"+xAlias[i]+".E1_NUM,"+xAlias[i]+".E1_PARCELA,"+xAlias[i]+".E1_TIPO,"+xAlias[i]+".E1_NATUREZ,"+xAlias[i]+".E1_CLIENTE,"+xAlias[i]+".E1_LOJA,"+xAlias[i]+".E1_EMISSAO,"+xAlias[i]+".E1_VENCTO,"+xAlias[i]+".E1_VENCREA,"+xAlias[i]+".E1_VALOR,"+xAlias[i]+".E1_SALDO,"+xAlias[i]+".E1_PORTADO,"+xAlias[i]+".E1_VEND1,"+xAlias[i]+".E1_TIPO, '"+xCNPJ [i]+" ' AS EMPRESA,"+xAlias[i]+".R_E_C_N_O_ AS RECNO_"+xAlias[i]+"  "
					cSQL += ' FROM ' + xEmpr[i]
				Endif
				cSQL += " WHERE "+xAlias[i]+".D_E_L_E_T_ <> '*' "
				cSQL += " AND "+xAlias[i]+".E1_CLIENTE BETWEEN '"+MV_PAR01+ "' AND '"+MV_PAR02+ "' "
				cSQL += " AND "+xAlias[i]+".E1_PREFIXO BETWEEN '"+MV_PAR05+ "' AND '"+MV_PAR06+ "' "
				cSQL += " AND "+xAlias[i]+".E1_TIPO = '"+MV_PAR07+ "' "
				cSQL += " AND "+xAlias[i]+".E1_VENCREA BETWEEN '"+dtos(MV_PAR03)+ "' AND '"+dtos(MV_PAR04)+ "' "
				cSQL += " AND "+xAlias[i]+".E1_SALDO > 0 "
				cSQL += " AND "+xAlias[i]+".E1_VEND1 BETWEEN '"+MV_PAR09+ "' AND '"+MV_PAR10+ "' "
				//If mv_par11 == 1
				//	cSQL += " AND "+xAlias[i]+".E1_P_DTEMC = '' )"
				//Else
    				cSQL += " ) " 
				//Endif
			Next
			cSQL += " ORDER BY E1_FILIAL,E1_CLIENTE,E1_LOJA,E1_VENCTO"
			MEMOWRIT("SELSE1.SQL",cSQL)
			cQuery := ChangeQuery(cSQL)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSQL),"TMP", .F., .T.)
			dbSelectArea("TMP")
			TCSETFIELD(Alias(),"TMP->E1_EMISSAO","D")
			TCSETFIELD(Alias(),"TMP->E1_VENCTO","D")
			TCSETFIELD(Alias(),"TMP->E1_VENCREA","D")
			TMP->(dbGoTop())
			lFiltro := .T.
		Endif
	Endif
	
	If lFiltro
		While !Eof()
			aTit 	 := {}
			cCliente := TMP->E1_CLIENTE
			cLoja    := TMP->E1_LOJA
			cNome    := Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja,"A1_NOME")
			cVend    := Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja,"A1_VEND")
   			If MV_PAR12 == 1 
       			cEnvM    := Alltrim(Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja,"A1_P_EMAIP"))
   	    	Else 
   		    	cEnvM    := Alltrim(Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja,"A1_P_EMAIC"))
       		Endif
       		If cEnvM <> "S"
	    		dbSelectArea("TMP")
    			dbSkip()
	    		Loop
    		Endif
    		If MSGYESNO("Confirma envio de email ao cliente? Caso nao confirme sera possivel enviar teste para o email que informar","Atencao")
    			cMaiVend := Alltrim(Posicione("SA3",1,xFilial("SA3")+cVend,"A3_EMAIL"))
	    		cEmailTo := Alltrim(Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja,"A1_P_EEMPC"))
		    	cEmailCC := Alltrim(Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja,"A1_P_EECPC"))
			    If !Empty(cMaiVend)
        			//cEmailCC += ";"+cMaiVend // email do gerente de conta 
        		Endif	
        	Else
        	    If Pergunte("TESTEMAIL",.T.)
	        		cEmailTo := alltrim(mv_par01) 
		        Else 
		            Return
		        Endif
        	Endif	
			While TMP->(!Eof()) .And. cCliente+cLoja == TMP->E1_CLIENTE+TMP->E1_LOJA
				If cEnvM == 'N' .Or. Empty(cEmailTo) //.AND. TMP->E1_SALDO > 0 .AND. TMP->E1_TIPO == "NF "
					dbSelectArea("TMP")
					dbSkip()
					Loop
				Endif
				//dbSelectArea("SE1")
				//dBGoTo(TMP->RECNO)
				//RecLock("SE1",.F.)     
				//If MV_PAR12 == 1 // PREVENTIVA
				//   SE1->E1_P_DTEMP := DDATABASE    // data de envio de email de preventiva
				//Else 
				//    SE1->E1_P_DTEMC := DDATABASE    // data de envio de email de preventiva
				//Endif
				//MsUnlock()
				dbSelectArea("TMP")
				AAdd(aTit, {SUBSTR(TMP->E1_PREFIXO,1,3), SUBSTR(TMP->E1_NUM,1,9), TMP->E1_PARCELA, TMP->E1_TIPO, TMP->E1_NATUREZ, TMP->E1_CLIENTE, TMP->E1_LOJA, cNome, cEmailTo, cEmailCC, TMP->E1_EMISSAO, TMP->E1_VENCTO, TMP->E1_VENCREA, TMP->E1_VALOR, TMP->E1_SALDO, TMP->E1_PORTADO, cEmailCC, TMP->EMPRESA })
				dbSkip()
			Enddo
			If len(aTit) > 0 //aalltrim(cCliente) <> ""
				dbSelectArea("SE1")
				u_ENVMAIL(aTit,cTpCob)
				nEmail := nEmail +1
				dbSelectArea("TMP")
			EndIf
		Enddo
		dbSelectArea("TMP")
		dbCloseArea("TMP")
	Endif
	
	If nEmail > 0
		MsgAlert("Enviado(s) "+STRZERO(nEmail,6)+If(cTpCob == 1, " email(s) de PREVENTIVA "," email(s) de COBRANCA "))
	Endif
Endif

Return



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Static Function AjustaSX1()

cPerg    :="PREVEN"
aReturn  := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
nLastKey := 0

Aadd(aPergs,{"De Cliente","","","mv_ch1","C",6,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","SA1","","","",""})
Aadd(aPergs,{"Ate Cliente","","","mv_ch2","C",6,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","SA1","","","",""})
Aadd(aPergs,{"De Vencimento","","","mv_ch3","D",8,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Vencimento","","","mv_ch4","D",8,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"De Prefixo","","","mv_ch5","C",3,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Prefixo","","","mv_ch6","C",3,0,0,"G","","MV_PAR06","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"De Tipo","","","mv_ch7","C",3,0,0,"G","","MV_PAR07","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Tipo","","","mv_ch8","C",3,0,0,"G","","MV_PAR08","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"De Gerente","","","mv_ch9","C",6,0,0,"G","","MV_PAR09","","","","","","","","","","","","","","","","","","","","","","","","","SA3","","","",""})
Aadd(aPergs,{"Ate Gerente","","","mv_cha","C",6,0,0,"G","","MV_PAR10","","","","","","","","","","","","","","","","","","","","","","","","","SA3","","","",""})
Aadd(aPergs,{"Reenvia(S/N)?","","","mv_chb","C",1,0,0,"G","","MV_PAR11","","","","S","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Envia email de ?","","","mv_chc","C",1,0,0,"G","","MV_PAR12","","","","P","","","","","","","","","","","","","","","","","","","","","","","","",""})

Return

//*********************************************************************************************************************************************************
                 
Static Function Busca_Emp() // MarkBrowse para selecao das empresas

Private cCodEmp
          
aProd  := {}

If ! SelecaoFiltros()
	Return
EndIf
	       
cCodEmp := ""
AEVAL(aProd,{|x| If(x[1],cCodEmp += StrZero(x[6],6),)})
	
	cArq:=""
	_aStru:={}
	AADD(_aStru,{"RB_OK"       , "C" , 2, 0})
	AADD(_aStru,{"RB_CODIGO"   , "C" ,02, 0})
	AADD(_aStru,{"RB_FILIAL"   , "C" ,02, 0})
	AADD(_aStru,{"RB_CGC"      , "C" ,18, 0})
	AADD(_aStru,{"RB_NOME"     , "C" ,15, 0})

	cArq:=CriaTrab(_aStru,.T.)
	dbUseArea(.T.,,cArq,"TRB")
	
	Processa({|| ESBPR01()})      // Alimenta Arq. Temp.de bancos com saldos
	
	
	dbSelectArea("TRB")
	dbGoTop()
	
	aCampos2 := {}
	AADD(aCampos2,{"RB_OK"       ,, " "                 , "@!"})
	AADD(aCampos2,{"RB_CODIGO"   ,, "Empresa"       , "@!"})
	AADD(aCampos2,{"RB_FILIAL"   ,, "Filial"         , "@!"})
	AADD(aCampos2,{"RB_CGC"      ,, "Cgc"         , "@R 99.999.999.9999/99"}) 
	AADD(aCampos2,{"RB_NOME"     ,, "Nome"         , "@!"})

	lInverte   := .F.
	cmarca     := GetMark()
	lInvert1   := .F.
	cmarc1     := GetMark()
                       
    dbSelectArea("TRB")
    dbCloseArea("TRB")

Return()

***************

*************************
Static Function ESBPR01()

dbSelectArea("SM0")
DbGoTop()

While !Eof()
	
	If ! Alltrim(STRZERO(RECNO(),6)) $ cCodEmp   // Filtro dos produtos de ND
		IncProc("Selecionando Empresas... ")
		dbSkip()
		Loop
	EndIf
	
	dbSelectArea("TRB")
	RecLock("TRB",.T.)
	RB_CODIGO    := SM0->M0_CODIGO
	RB_FILIAL    := SM0->M0_CODFIL
	RB_CGC       := SM0->M0_CGC
	RB_NOME      := SM0->M0_NOME
	MsUnLock()

	If Empty(cEmpr) .Or. !SM0->M0_CODIGO $ cEmpr
     	cEmpr += SM0->M0_CODIGO
    	aadd(xEmpr, "SE1"+SM0->M0_CODIGO+"0")
    	aadd(xCNPJ, SM0->M0_CGC)
    	aadd(xAlias, "SE1"+SM0->M0_CODIGO+"0")
    Endif
   	dbSelectArea("SM0")
	dbSkip()
	
EndDo
Return NIL

///////////////////////////////
Static Function SelecaoFiltros()
Local oDlgSelec, nOpc := 1
Local   oOk        := LoadBitMap(GetResources(),"LBOK")
Local   oNo        := LoadBitMap(GetResources(),"LBNO")
Local aAmbiente := GetArea(), lReturn := .T.

aProd := {}

dbSelectArea("SM0")
DbGoTop()

While !Eof() 
   	AADD( aProd, { .F., SM0->M0_CODIGO,SM0->M0_CODFIL,SM0->M0_CGC,SM0->M0_NOME,RECNO() } )
	dbSkip()
EndDo

If Len(aProd) == 0
	
	MsgStop("Não há Empresas definidas !!! Favor verificar")
	
	RestArea( aAmbiente )
	Return(.F.)
EndIf

@ 080,080 TO 450,550 DIALOG oDlgSelec TITLE "Filtro de Empresas"
@ 038,010 TO 137,222 TITLE "Selecao de Empresas"
@ 3.5,1.7 LISTBOX oListBox1 VAR cListBox1 FIELDS HEADER "  ", "CODIGO", "FILIAL","CGC","NOME" SIZE 200,52 ON DBLCLICK;
(aProd := MarcaItem(oListBox1:nAt,aProd),oListBox1:Refresh()) //NOSCROLL

oListBox1:SetArray(aProd)
oListBox1:bLine := { || {If(aProd[oListBox1:nAt,1],oOk,oNo),aProd[oListBox1:nAt,2],aProd[oListBox1:nAt,3],aProd[oListBox1:nAt,4],aProd[oListBox1:nAt,5],aProd[oListBox1:nAt,6]}}

@ 137,156 BMPBUTTON TYPE 1  ACTION (nOpc:=1,Close(oDlgSelec)) OBJECT oBtn1
@ 137,196 BMPBUTTON TYPE 2  ACTION (nOpc:=2,Close(oDlgSelec)) OBJECT oBtn2

oBtn1:Enable()
oBtn2:Enable()

ACTIVATE DIALOG oDlgSelec CENTERED

RestArea( aAmbiente )

If nOpc == 2 //Fechar
	lReturn := .F.
EndIf

Return lReturn

////////////////////////////////////
Static Function MarcaItem(nAt,aList)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Marca somente uma opcao 								         	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aList[nAt,1] := !aList[nAt,1]

Return aList


/////////////////////////////////
Static Procedure MarcaTudo(aList)

Aeval(aList,{|aElem|aElem[1] := lMarcaItem})

lMarcaItem := !lMarcaItem

Return

                    