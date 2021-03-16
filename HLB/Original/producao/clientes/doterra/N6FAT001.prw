#Include 'Protheus.Ch' 
#Include 'TopConn.Ch'      
#include 'parmtype.ch'
#include 'average.ch'

/*
Função.............: N6FAT001
Objetivo...........: Faturar pedidos de venda Doterra
Autor..............: Leandro Diniz de Brito  ( BRL Consulting )
Data...............: 22/01/2018
*/
*----------------------------*
User Function N6FAT001(aParam)
*----------------------------*
Local aArea      	:= GetArea()
Local chTitle    	:= "HLB BRASIL"

Local chMsg      	:= "Do Terra - Faturamento"
Local cTitle

Local cText     	:= "Este programa tem como objetivo faturar os pedidos de venda de acordo com os parametros selecionados."
Local bFinish    	:= {|| .T.}

Local cResHead

Local lNoFirst
Local aCoord

Local cFil 

Local cEmp
Local lJob	:= Type('oMainWnd') != 'O'  

Private oWizard
Private oGetResult

Private aDados     
Private aDadosLog  

If lJob 
	If (Valtype(aParam) != 'A')
		cEmp := 'N6'
		cFil := '01'
	Else            
		cEmp := aParam[01]
		cFil := aParam[02]	
	EndIf
	
	RPCSetType(3)	
	RpcSetEnv(cEmp, cFil, "", "", 'FAT')
EndIf  

If !(cEmpAnt $ 'N6')
	SendMessage('Empresa nao autorizada.' ,lJob)
	Return
EndIf

TelaPedido(lJob)
If lJob
	GeraNf(lJob)
EndIf

RestArea(aArea)

Return

/*
Função...............: ExibeLog
Objetivo.............: Exibe Log da operação
Autor................: Leandro Brito ( BRL Consulting )
Data.................: 22/01/2018
*/
*------------------------*
Static Function ExibeLog()
*------------------------*
Local oLbx
Local oDlgLog
Local cTitulo := "Faturamento - doTerra - Log de processamento"
Private aSizeAut := MsAdvSize()

If !Empty(aDadosLog)
	DEFINE MSDIALOG oDlgLog TITLE cTitulo FROM aSizeAut[7],aSizeAut[1] TO aSizeAut[6],aSizeAut[5] PIXEL
		oLbx := TWBrowse():New( ,,,,,,,oDlgLog,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
		oLbx:Align := CONTROL_ALIGN_ALLCLIENT
		oLbx:SetArray(aDadosLog)
		oLbx:AddColumn(TCColumn():New('Pedido'	,{|| aDadosLog[oLbx:nAt,01]},,,,"LEFT" ,,.F.,.T.,,,,.F.,))
		oLbx:AddColumn(TCColumn():New('Mensagem',{|| aDadosLog[oLbx:nAt,02]},,,,"LEFT" ,,.F.,.T.,,,,.F.,)) 
		oLbx:Refresh()
	ACTIVATE MSDIALOG oDlgLog ON INIT (EnchoiceBar(oDlgLog,{|| oDlgLog:End()},{|| oDlgLog:End()},,aButtons)) CENTERED
EndIf

Return

/*
Função...............: TelaPedido
Objetivo.............: Exibir pedidos de venda a Faturar
Autor................: Leandro Brito ( BRL Consulting )
Data.................: 22/01/2018
*/
*------------------------------*
Static Function TelaPedido(lJob)
*------------------------------*
Local aArea		:= GetArea()
Local cSql  	:= ''
Local lRet		:= .T.
Local cAliasTemp := "N6FAT001_01"

Local oDlg
Local nOp		:= 0
Local cTitulo	:= "Faturamento - doTerra"
Local aAlter	:= {"OK"}
Private oNewGetDb
Private aButtons	:= {}
Private aHeader		:= {}

Private aSizeAut := MsAdvSize()

Private oOk := LoadBitmap( GetResources(), "LBOK")
Private oNo := LoadBitmap( GetResources(), "LBNO")
Private oVerde := LoadBitmap( GetResources(), "BR_VERDE")

Begin Sequence
	cSql := "SELECT C5.C5_NUM,C5.C5_P_DTRAX,C5.C5_EMISSAO,C5.C5_CLIENTE,C5.C5_LOJACLI,SA1.A1_NOME,SA1.A1_CGC,C5.C5_TRANSP,SA4.A4_NOME,C5.C5_CONDPAG,C5.R_E_C_N_O_ RECSC5  "
	cSql += "FROM "+RetSqlName('SC5')+" C5 "
	cSql += "LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 on SA1.D_E_L_E_T_ <> '*' AND SA1.A1_COD = C5.C5_CLIENTE AND SA1.A1_LOJA = C5.C5_LOJACLI "
	cSql += "LEFT OUTER JOIN "+RetSqlName("SA4")+" SA4 on SA4.D_E_L_E_T_ <> '*' AND SA4.A4_COD = C5.C5_TRANSP "
	cSql += "WHERE C5.D_E_L_E_T_ = '' "
	cSql += "AND C5.C5_FILIAL = '"+xFilial('SC5')+"' "
	cSql += "AND C5.C5_NOTA = '' "
	If SC5->( FieldPos( 'C5_P_STFED' ) ) > 0 
		cSql += "AND C5.C5_P_STFED = '03' "
	EndIf
	cSql += "ORDER BY C5.C5_NUM "

	TCQuery cSql ALIAS (cAliasTemp) NEW

	TCSetField(cAliasTemp ,'C5_EMISSAO','D',8)

	aDados := {}
	(cAliasTemp)->(DbEval({|| Aadd(aDados, {oVerde,oOk,C5_NUM,C5_P_DTRAX,C5_EMISSAO,C5_CLIENTE,C5_LOJACLI,A1_NOME,A1_CGC,C5_TRANSP,A4_NOME,C5_CONDPAG,RECSC5,.F.})}))

	If !lJob
		DbSelectArea('SC5')//Abre alias para função de geração de NF
		If Len(aDados) == 0
			MsgStop( 'Nao existem dados para exibição.' )
			lRet := .F.
			Break
		EndIf

		aHeader := {}
		//            cTitulo				   		, cCampo    	, cPicture                      , nTamanho                      ,nDecimais	, cValidação, cReservado      , cTipo                   	,xReservado1, xReservado2
		AADD(aHeader,{TRIM("Sts.")						,"STS"			,"@BMP"							, 2								,0			, NIL		,"€€€€€€€€€€€€€€ ","C"                      	, NIL		, NIL   })
		AADD(aHeader,{TRIM("Chk")						,"OK"			,"@BMP"							, 2								,0			, NIL		,"€€€€€€€€€€€€€€ ","C"                      	, NIL		, NIL   })
		Aadd(aHeader,{AvSX3("C5_NUM",AV_TITULO)		,"C5_NUM"		,AvSX3("C5_NUM",AV_PICTURE)		, AvSX3("C5_NUM",AV_TAMANHO)	,0			, NIL		, NIL             ,AvSX3("C5_NUM",AV_TIPO)		, NIL		, NIL   })
		Aadd(aHeader,{AvSX3("C5_P_DTRAX",AV_TITULO)	,"C5_P_DTRAX"	,AvSX3("C5_P_DTRAX",AV_PICTURE)	, AvSX3("C5_P_DTRAX",AV_TAMANHO),0			, NIL		, NIL             ,AvSX3("C5_P_DTRAX",AV_TIPO)	, NIL		, NIL   })
		Aadd(aHeader,{AvSX3("C5_EMISSAO",AV_TITULO)	,"C5_EMISSAO"	,AvSX3("C5_EMISSAO",AV_PICTURE)	, AvSX3("C5_EMISSAO",AV_TAMANHO),0			, NIL		, NIL             ,AvSX3("C5_EMISSAO",AV_TIPO)	, NIL		, NIL   })
		Aadd(aHeader,{AvSX3("C5_CLIENTE",AV_TITULO)	,"C5_CLIENTE"	,AvSX3("C5_CLIENTE",AV_PICTURE)	, AvSX3("C5_CLIENTE",AV_TAMANHO),0			, NIL		, NIL             ,AvSX3("C5_CLIENTE",AV_TIPO)	, NIL		, NIL   })
		Aadd(aHeader,{AvSX3("C5_LOJACLI",AV_TITULO)	,"C5_LOJACLI"	,AvSX3("C5_LOJACLI",AV_PICTURE)	, AvSX3("C5_LOJACLI",AV_TAMANHO),0			, NIL		, NIL             ,AvSX3("C5_LOJACLI",AV_TIPO)	, NIL		, NIL   })
		Aadd(aHeader,{AvSX3("A1_NOME",AV_TITULO)	,"A1_NOME"		,AvSX3("A1_NOME",AV_PICTURE)	, AvSX3("A1_NOME",AV_TAMANHO)	,0			, NIL		, NIL             ,AvSX3("A1_NOME",AV_TIPO)		, NIL		, NIL   })
		Aadd(aHeader,{AvSX3("A1_CGC",AV_TITULO)		,"A1_CGC"		,"@!"							, AvSX3("A1_CGC",AV_TAMANHO)	,0			, NIL		, NIL             ,AvSX3("A1_CGC",AV_TIPO)		, NIL		, NIL   })
		Aadd(aHeader,{AvSX3("C5_TRANSP",AV_TITULO)	,"C5_TRANSP"	,AvSX3("C5_TRANSP",AV_PICTURE)	, AvSX3("C5_TRANSP",AV_TAMANHO)	,0			, NIL		, NIL             ,AvSX3("C5_TRANSP",AV_TIPO)	, NIL		, NIL   })
		Aadd(aHeader,{AvSX3("A4_NOME",AV_TITULO)	,"A4_NOME" 		,AvSX3("A4_NOME",AV_PICTURE)	, AvSX3("A4_NOME",AV_TAMANHO)	,0			, NIL		, NIL             ,AvSX3("A4_NOME",AV_TIPO)	, NIL		, NIL   })
		Aadd(aHeader,{AvSX3("C5_CONDPAG",AV_TITULO)	,"C5_CONDPAG"	,AvSX3("C5_CONDPAG",AV_PICTURE)	, AvSX3("C5_CONDPAG",AV_TAMANHO),0			, NIL		, NIL             ,AvSX3("C5_CONDPAG",AV_TIPO)	, NIL		, NIL   })
		Aadd(aHeader,{"R_E_C_N_O_" 					,"R_E_C_N_O_"	,""								, 10							,0			, NIL		, NIL             ,"N"							, NIL		, NIL   })
		
		DEFINE MSDIALOG oDlg TITLE cTitulo FROM aSizeAut[7],aSizeAut[1] TO aSizeAut[6],aSizeAut[5] PIXEL
			oNewGetDb := MsNewGetDados():New(0,0,0,0,2,,,,aAlter,,120,,,,oDlg,aHeader,aDados,{|| (oNewGetDb:Refresh())})
			oNewGetDb:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
			oNewGetDb:aCols := aClone(aDados)
			oNewGetDb:oBrowse:lUseDefaultColors := .F.
			oNewGetDb:OnChange()
			oNewGetDb:AddAction("OK",{|| MarcaDesmarca(.F.), oNewGetDb:oBrowse:ColPos-=1 ,oNewGetDb:Refresh()})
			oNewGetDb:oBrowse:bHeaderClick := {|| MarcaDesmarca(.T.), oNewGetDb:Refresh()}  
			oNewGetDb:Refresh()
		ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{|| nOp := 1, oDlg:End()},{||nOp := 0, oDlg:End()},,aButtons)) CENTERED

		If nOp == 1 .AND. MsgYesNo("Confirmar a geração dos faturamentos para os pedidos selecionados?","HLB BRASIL")
			aDados := oNewGetDb:aCols
			Processa({|| GeraNF(.F.) } ,"Geração de Faturamento","Processando gravação dos registros...")
			ExibeLog()
		EndIf

	EndIf
End Sequence

If Select(cAliasTemp) > 0
	(cAliasTemp)->(DbCloseArea())
EndIf 

RestArea(aArea)

Return( lRet )
        
*-----------------------------------*
Static Function MarcaDesmarca(lTodos)
*-----------------------------------*
Local i
Local oAtual := oNewGetDb:aCols[oNewGetDb:oBrowse:nAt][2]
Local nColuna := oNewGetDb:oBrowse:ColPos

If lTodos
	If nColuna == 2
		oNewGetDb:GoTop()
		For i := 1 To Len(oNewGetDb:aCols)
			oNewGetDb:aCols[i][2] := If(oAtual == oOk,oNo,oOk)
		Next i
		oNewGetDb:GoTop()
		oNewGetDb:ForceRefresh()
	EndIf
Else
	oNewGetDb:aCols[oNewGetDb:oBrowse:nAt][2] := If(oAtual == oOk, oNo, oOk)
EndIf

Return NIL

/*
Função...............: GeraNF
Objetivo.............: Gerar Nota Fiscal 
Autor................: Leandro Brito ( BRL Consulting )
Data.................: 22/01/2018
*/
*--------------------------*
Static Function GeraNF(lJob)
*--------------------------*
Local i,j
Local cPedido 		:= '' 
Local cSerieNF 		:= GetMV('MV_P_SERNF',,'1  ')
Local cRet   
Local cEspecie
Local cNfIni        := ""
Local cNfFim        := ""
Local lEnd 

Local cQry			:= ""

Begin Sequence

aDadosLog := {}

cSerieNf := PadR( cSerieNf , 3 )
cEspecie := cSerieNf  + "=SPED;"  

SX6->( DbSetorder(1))
If SX6->(!DbSeek(cFilAnt+'MV_ESPECIE'))
	SX6->(RecLock('SX6',.T.))
	SX6->X6_FIL := cFilAnt
	SX6->X6_VAR := 'MV_ESPECIE'
	SX6->X6_TIPO := 'C'
	SX6->X6_DESCRIC := 'Contem tipos de documentos fiscais utilizados na'
	SX6->X6_DESC1	:= 'emissao de notas fiscais' 
	SX6->X6_CONTEUD := cEspecie  
	SX6->(MSUnlock())

ElseIf At(cEspecie,SX6->X6_CONTEUD) == 0
	SX6->(RecLock('SX6' ,.F.))
	SX6->X6_CONTEUD := AllTrim(SX6->X6_CONTEUD)+";"+cEspecie
	SX6->(MSUnlock()) 

EndIf              

ProcRegua(Len(aDados))
For i := 1 To Len(aDados)
	//AOA - 18/09/2018 - Se vinher via job não entra no IF 
	If !lJob
		If !aDados[i][2] == oOk
			Loop
		EndIf
	
		IncProc()
	EndIf
	
	SC5->(DbSetOrder(1))
	SC5->(DbSeek(xFilial("SC5")+aDados[i][3]))//C5_NUM

	/*	** Liberacao do Pedido de Venda*/
	aPvlNfs:={} ;aBloqueio:={}
	Ma410LbNfs(2,@aPvlNfs,@aBloqueio)
	Ma410LbNfs(1,@aPvlNfs,@aBloqueio)
	//AOA - 18/09/2018 - Verifica se tem informação no array com dados do pedido também	
	If !Empty( aBloqueio ) .AND. Empty(aPvlNfs)
		/*** Se houve algum bloqueio nao gera NF e guarda no Log 		*/
		For j := 1 To Len(aBloqueio)
			Aadd(aDadosLog, {aBloqueio[j][1], 'Produto '+aBloqueio[j][4]+' : '+If(!Empty(aBloqueio[j][6]), 'Bloqueio credito.', '')+;
							If(!Empty(aBloqueio[j][7]), 'Bloqueio Estoque.', '')})
							
			u_N6GEN002( "SC5"/*TABELA*/,"R"/*E=ENVIO/R=RETORNO*/,"N6FAT001"/*TIPO DE SERVIÇO*/,	""/*DE*/,""/*PARA*/,Atail(aDadosLog)[1]/*CHAVE DE PESQUISA*/,;
						""/*CONTEUDO EM JSON RECEBIDO OU ENVIADO*/,Atail(aDadosLog)[2]/*CAMPO OBS*/)
		Next

	Else
		/*** Gera Nota Fiscal de Saida		*/
		Begin Transaction 
			cRet := MaPvlNfs( aPvlNfs ,;
							cSerieNf ,;
							.F. ,; //** Mostra Lancamentos Contabeis
							.F. ,; //** Aglutina Lanuamentos
							.F. ,; //** Cont. On Line ?
							.F. ,; //** Cont. Custo On-line ?
							.F. ,; //** Reaj. na mesma N.F.?
							3,; //** Metodo calc.acr.fin? Taxa defl/Dif.lista/% Acrs.ped
							1,; //** Arred.prc unit vist?  Sempre/Nunca/Consumid.final
							.F.,;  //** Atualiza Cli.X Prod?
							.F. ,,,,,,; //** Ecf ?
							dDataBase )   
		End Transaction

		If Empty(cRet)
			Aadd(aDadosLog, {aDados[i][3], 'Pedido nao faturado.'})
			u_N6GEN002( "SC5"/*TABELA*/,"R"/*E=ENVIO/R=RETORNO*/,"N6FAT001"/*TIPO DE SERVIÇO*/,	""/*DE*/,""/*PARA*/,Atail(aDadosLog)[1]/*CHAVE DE PESQUISA*/,;
						""/*CONTEUDO EM JSON RECEBIDO OU ENVIADO*/,Atail(aDadosLog)[2]/*CAMPO OBS*/) 

		    //TCSqlExec("UPDATE "+RetSqlName("SC5")+" SET C5_P_STFED='08' WHERE C5_P_DTRAX='"+SC5->C5_P_DTRAX+"' AND C5_FILIAL='"+xFilial("SC5")+"'")
		    TCSqlExec("UPDATE "+RetSqlName("SC5")+" SET C5_P_STFED='08' WHERE R_E_C_N_O_="+ALLTRIM(STR(SC5->(RECNO()) )))
		Else
			If SF2->(DbSetOrder(1), DbSeek(xFilial("SF2")+PadR(cRet, Len(SF2->F2_DOC))+PadR(cSerieNf, Len(SF2->F2_SERIE))))
				SF2->(RecLock('SF2',.F.))
				SF2->F2_HORA := Left(Time(),5)
				SF2->(MSUnlock()) 

				Aadd(aDadosLog, {aDados[i][3], 'N6FAT001 - Faturado com sucesso. NF: '+cRet+' Serie: '+cSerieNf+' Filial: '+cFilAnt })
				u_N6GEN002("SC5"/*TABELA*/,"R"/*E=ENVIO/R=RETORNO*/,"N6FAT001"/*TIPO DE SERVIÇO*/, ""/*DE*/,""/*PARA*/,Atail(aDadosLog)[1]/*CHAVE DE PESQUISA*/,;
							Atail(aDadosLog)[2]/*CONTEUDO EM JSON RECEBIDO OU ENVIADO*/,"" /*CAMPO OBS*/)

				//TCSqlExec("UPDATE "+RetSqlName("SC5")+" SET C5_P_STFED='07' WHERE C5_P_DTRAX='"+SC5->C5_P_DTRAX+"' AND C5_FILIAL='"+xFilial("SC5")+"'")
				TCSqlExec("UPDATE "+RetSqlName("SC5")+" SET C5_P_STFED='07' WHERE R_E_C_N_O_="+ALLTRIM(STR(SC5->(RECNO()) )))

				//Gravação da tabela de Rastro
				cQry := " UPDATE "+RetSqlName("ZX6")
				cQry += " 	SET ZX6_DTFAT='"+DTOS(Date())+"',
				cQry += " 		ZX6_HRFAT='"+TIME()+"',
				cQry += " 		ZX6_DOC='"+cRet+"',
				cQry += " 		ZX6_SERIE='"+cSerieNf+"'
				cQry += " WHERE ZX6_FILIAL = '"+xFilial("SC5")+"'
				cQry += "		AND ZX6_DTRAX = '"+SC5->C5_P_DTRAX+"'
				TCSQLEXEC(cQry)
				InsertZX7(xFilial("SC5"),SC5->C5_P_DTRAX,SC5->C5_NUM,"Atualizado data e hora do processamento na etapa","Faturamento")

				If Empty( cNfIni )
					cNfIni := cRet 
				EndIf 

				cNfFim := cRet
			EndIf		
		EndIf
		
	EndIf
Next       

/** Envio a Sefaz das Nfs geradas*/                                 
If !Empty(cNfIni) .And. !Empty(cNfFim)
	u_EnvNfSef(cNfIni, cNfFim, cSerieNf,SC5->C5_P_DTRAX)	
EndIf

End Sequence

Return

/*
Função..........: EnvNfSef
Objetivo........: Transmitir notas fiscais a Sefaz
Autor...........: Leandro Diniz de Brito ( LDB )
Data............: 28/01/2018
*/
*---------------------------------------------------*
User Function EnvNfSef(cNfIni,cNfFim,cSerieNf,cDtrax)
*---------------------------------------------------*
Local cIdEnt 
Local cErro 

Local cModalidade
Local cAmbiente 

Local cRetorno 		:= ""    
Local cModel 		:= '55'

Begin Sequence
	cIdEnt 		:= RetIdEnti(.F.)         
	cErro 		:= ""
	cModalidade	:= getCfgModalidade(@cErro, cIdEnt, cModel)				
	
	If !Empty(cErro)
		cRetorno := "Erro : nao foi possivel obter modalidade de transmissao." 
		Break
	EndIf
	
	cErro 		:= ""
	cAmbiente 	:= getCfgAmbiente(@cErro, cIdEnt, cModel)
	If !Empty(cErro)
		cRetorno := "Erro : nao foi possivel obter configuração do ambiente." 
		Break
	EndIf
	
	cErro 		:= ""
	cVersao		:= getCfgVersao(@cErro, cIdEnt, cModel)
	If !Empty(cErro)
		cRetorno := "Erro : nao foi possivel obter versao da Nfe." 
		Break
	EndIf
	
	If Empty(cErro)
		cRetorno := SpedNFeTrf('SF2',cSerieNF,cNfIni,cNfFim,cIdEnt,cAmbiente,cModalidade,cVersao,,.F.,.T.)
	EndIf
End Sequence

If !Empty(cErro)
	u_N6GEN002("SF2"/*TABELA*/,"E"/*E=ENVIO/R=RETORNO*/,"N6FAT001"/*TIPO DE SERVIÇO*/,	""/*DE*/,""/*PARA*/,cNfIni + cSerieNF/*CHAVE DE PESQUISA*/,;
				""/*CONTEUDO EM JSON RECEBIDO OU ENVIADO*/,cErro+"/"+cRetorno /*CAMPO OBS*/)	

	//Atualização de Status 10= Erro transmissao
	TCSqlExec("UPDATE "+RetSqlName("SC5")+" SET C5_P_STFED = '10' WHERE C5_P_DTRAX = '"+cDtrax+"' AND C5_FILIAL = '"+xFilial("SC5")+"' AND C5_NOTA = '"+cNfIni+"' ")
EndIf 

If !Empty(cRetorno)
	u_N6GEN002("SF2"/*TABELA*/,"E"/*E=ENVIO/R=RETORNO*/,"N6FAT001"/*TIPO DE SERVIÇO*/,	""/*DE*/,""/*PARA*/,cNfIni + cSerieNF/*CHAVE DE PESQUISA*/,;
				cRetorno/*CONTEUDO EM JSON RECEBIDO OU ENVIADO*/,cRetorno /*CAMPO OBS*/)

	//Atualização de Status 09 = transmitido			
	TCSqlExec("UPDATE "+RetSqlName("SC5")+" SET C5_P_STFED = '09' WHERE C5_P_DTRAX = '"+cDtrax+"' AND C5_FILIAL = '"+xFilial("SC5")+"' AND C5_NOTA = '"+cNfIni+"' ") 											
EndIf

Return (cRetorno)

/*
Função..........: SendMessage
Objetivo........: Enviar mensagem na tela ou console
*/
*----------------------------------------*
Static Function SendMessage(cMessage,lJob)    
*----------------------------------------*
Default lJob := .F.
Return (If( lJob,ConOut(cMessage),MsgStop(cMessage)))

/*
Funcao      : InsertZX7
Parametros  : 
Retorno     : 
Objetivos   : Gravação do Log de movimentação
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*-------------------------------------------------------*
Static Function InsertZX7(cFil,cDtrax,cNum,cOcorr,cEtapa)
*-------------------------------------------------------*
Local cInsert := ""

If EMPTY(cFil) .or. EMPTY(cDtrax) .or. EMPTY(cNum)
	Return .F.
EndIf

cInsert := " INSERT INTO "+RETSQLNAME("ZX7") 
cInsert += " VALUES('"+LEFT(cFil	,TamSX3("ZX7_FILIAL")[1])+"',
cInsert += " 		'"+LEFT(cDtrax	,TamSX3("ZX7_DTRAX")[1])+"',
cInsert += " 		'"+LEFT(cNum	,TamSX3("ZX7_NUM")[1])+"',
cInsert += " 		(SELECT ISNULL(MAX(ZX7_SEQ),0)+1 FROM "+RETSQLNAME("ZX7")+" WHERE ZX7_DTRAX = '"+LEFT(cDtrax,TamSX3("ZX7_DTRAX")[1])+"'),
cInsert += " 		'"+DTOS(date())+"',
cInsert += " 		'"+LEFT(Time()	,8)+"',
cInsert += " 		'"+LEFT(cOcorr	,TamSX3("ZX7_OCORR")[1])+"',
cInsert += " 		'"+LEFT(cEtapa	,TamSX3("ZX7_ETAPA")[1])+"',
cInsert += " 		'',
cInsert += " 		(SELECT ISNULL(MAX(R_E_C_N_O_),0)+1 FROM "+RETSQLNAME("ZX7")+"))
TCSQLEXEC(cInsert)

Return .T.