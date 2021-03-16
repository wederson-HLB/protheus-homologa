#Include "Protheus.ch"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#Include "tbiconn.ch"  
#Include "TopConn.Ch"
#INCLUDE "XMLXFUN.CH"

/*
Função..................: LGFAT005
Objetivo................: Enviar Xml e Danfe Saida ao ftp Exeltis
Cliente HLB.............: LG ( Exeltis )
Autor...................: BRL Consulting
						  Renato Rezende - Adequação para funcionar via Job.
Data....................: 08/01/2018
*/
*----------------------------------*
 User Function LGFAT005(aEmp)
*----------------------------------*
Local cTitulo		:= 'Envio de Xml e Danfe de Saida ao ftp Exeltis'
Local cDescription	:= 'Esta rotina permite enviar Xml e Danfe de saida ao servidor Ftp da Exeltis .'
Local cMsg			:= ""
Local cSubject		:= ""
Local cAnexos		:= ""
Local cTo			:= ""
Local cToOculto		:= ""
Local oProcess 		:= Nil
Local bProcesso		:= {|| }

Private cCadastro 	:= "Envio de Danfe\Xml ao Ftp"
Private cPerg 	 	:= "LGFAT005"
Private cMarca		:= ""
Private cDate 		:= ""
Private cTime 		:= ""
Private cUser 		:= ""
Private cMsgErro	:= ""
Private lJob		:= (Select("SX3") <= 0)
Private aErro		:= {}

If lJob
	RpcClearEnv()
	RpcSetType(3)

	RpcSetEnv(aEmp[1] , aEmp[2] , "" , "" , "FAT")
	
	cDate 		:= DtoC(Date())
	cTime 		:= SubStr(Time(),1,5)
	cUser 		:= UsrFullName(RetCodUsr())
	cSubject	:= "[EXELTIS] Erro no envio XML e DANFE AGV "+DtoC(Date())
	cTo			:= AllTrim(GetMv("MV_P_00040",," "))
	cToOculto	:= AllTrim(GetMv("MV_P_00041",," "))

	//Envio do XML automático	
	EnviaXml()
	
	If Len(aErro) > 0
		cMsg := HtmlPrc()
		
		//Envio de email
		U_GTGEN045(cMsg,cSubject,cTo,cToOculto,cAnexos)	
		
	EndIf
Else
	If ( !cEmpAnt $ "LG" )
		SendMessage("Empresa nao autorizada para utilizar essa rotina!",lJob)
		Return Nil
	EndIf
	
	AjusSx1()

	bProcesso	:= { |oSelf| SelNf( oSelf ) }
	oProcess 	:= tNewProcess():New( "LGFAT005" , cTitulo , bProcesso , cDescription , cPerg ,,,,,.T.,.T.)
EndIf

Return Nil

/*
Função..........: SelfNf
Objetivo........: Selecionar notas fiscais para impressão
*/
*-------------------------------------------------*
Static Function SelNf( oProcess )
*-------------------------------------------------*
Local cExprFilTop
Local aCores

cMarca	:= GetMark(, "SF2" , "F2_OK" ) 

Pergunte( cPerg , .F. )

aCores := { { "F2_P_ENVD = '1' " , "BR_AZUL" }, {  "!F2_P_ENVD $ '1,3' " , "BR_VERDE" } , {  "F2_P_ENVD = '3' " , "BR_VERMELHO" } }
cExprFilTop := "F2_EMISSAO BETWEEN '" + DtoS( MV_PAR02 ) + "' AND '" + DtoS( MV_PAR03 ) + "' AND F2_CHVNFE <> '' "          

If ( MV_PAR01 = 1  )
	cExprFilTop += " AND F2_P_ENVD = '1' "	
ElseIf ( MV_PAR01 = 2  )
	cExprFilTop += " AND F2_P_ENVD <> '1' "	
EndIf

MarkBrow( 'SF2' ,  'F2_OK' ,, { { "F2_EMISSAO" ,, "Dt.Emissao" , "" },{ "F2_CHVNFE" ,, "Chave Nf-e" , "" } } , .F. , cMarca , "u_LG05All()" ,,,,,, cExprFilTop ,, aCores )

Return


/*
Função..........: MenuDef
Objetivo........: Cadastrar automaticamente as perguntas no arquivo SX1
*/
*-------------------------------------------------*
Static Function MenuDef()
*-------------------------------------------------*
Local aRotina 	:= {}

ADD OPTION aRotina TITLE 'Enviar' ACTION 'u_EnvDanfe()' OPERATION 10 ACCESS 0 
ADD OPTION aRotina TITLE 'Bol. Santander' ACTION 'u_LGFIN001(.T.,.T.)' OPERATION 10 ACCESS 0  
//ADD OPTION aRotina TITLE 'Bol. Bradesco' ACTION 'u_LGFIN002(.T.,.T.)' OPERATION 10 ACCESS 0  
ADD OPTION aRotina TITLE 'Legenda' ACTION 'u_LG005Leg()' OPERATION 10 ACCESS 0 

Return aRotina

/*
Função..........: EnvDanfe
Objetivo........: Enviar de Danfe e Xml ao Ftp Exeltis
*/
*-------------------------------------------------*
User Function EnvDanfe 
*-------------------------------------------------*

If MsgYesNo( 'Confirma envio dos arquivos ?' )
	Processa( { || EnviaXml() } , 'Aguarde, enviando Xml\Danfe'  )
EndIf

Return

*-------------------------------------------------*
Static Function EnviaXml
*-------------------------------------------------*
Local lMarcou	:= .F.
Local nRecCount	:= 0

Private cIdEnt 	:= RetIdEnti( .F. )
Private cAlias	:= "TMPSF2"

If !ConectaFTP()
	cMsgErro:= "Nao foi possivel conectar ao servidor Ftp."
	SendMessage(cMsgErro,lJob)
	Aadd(aErro,{"","",cMsgErro})
	Return
EndIf

DbSelectArea("SF2")
SF2->(DbSetOrder(1))
SF2->(DbGoTop())

//Monta a Query das notas selecionadas para envio
AutoQuery(cMarca)

Count to nRecCount

(cAlias)->(DbGoTop())

If nRecCount > 0

	If !lJob
		ProcRegua( (cAlias)->( LastRec() ) )
	EndIf

	(cAlias)->( DbGoTop() )
	While (cAlias)->(!Eof() )    
    	SF2->( DbGoTo( ( cAlias )->RECSF2 ) )
	    
	    lMarcou:= .T.
    	
    	If !lJob
    		IncProc()
   	 	EndIf
    	
    	If Envia()
    		SF2->( RecLock( 'SF2' , .F. ) , F2_P_ENVD := '1' , MSUnlock() )
    	Else
    		SF2->( RecLock( 'SF2' , .F. ) , F2_P_ENVD := '3' , MSUnlock() )

   			cMsgErro:= "Erro ao ao enviar a nota e boleto abaixo:"
			Aadd(aErro,{SF2->F2_DOC,SF2->F2_SERIE,cMsgErro})
    		
    	EndIf	
		(cAlias)->( DbSkip() )
	EndDo
EndIf

FTPDisconnect()  

If lMarcou
	SendMessage("Termino do processamento",lJob)
Else
	SendMessage("Nenhuma nota selecionada",lJob)
EndIf

Return          
 

/*
Função..........: Fat5MarkAll
Objetivo........: Executado ao clicar no Header da coluna
*/
*-------------------------------------------------*
User Function LG05All
*-------------------------------------------------*

SF2->( DbGoTop() )
While SF2->(!Eof() )   
    SF2->( RecLock( 'SF2' , .F. ) , If( F2_OK == cMarca , F2_OK := "" , F2_OK := cMarca ) , MSUnlock() )
	SF2->( DbSkip() )
EndDo             

Return( .T. )          

/*
Função..........: AjustaSx1
Objetivo........: Cadastrar automaticamente as perguntas no arquivo SX1
*/
*-------------------------------------------------*
Static Function AjusSx1
*-------------------------------------------------*

U_PUTSX1( cPerg ,'01' , 'Status' ,'Status'/*cPerSpa*/,'Status'/*cPerEng*/,'mv_ch1','C' , 20 ,0 ,0/*nPresel*/,'C'/*cGSC*/,/*cValid*/,/*cF3*/, /*cGrpSxg*/,/*cPyme*/,'MV_PAR01'/*cVar01*/,'Enviados'/*cDef01*/,/*cDefSpa1*/,/*cDefEng1*/,/*cCnt01*/,'Nao enviados'	/*cDef02*/,/*cDefSpa2*/,/*cDefEng2*/,'Ambos'/*cDef03*/,/*cDefSpa3*/,/*cDefEng3*/,	/*cDef04*/,/*cDefSpa4*/,/*cDefEng4*/,/*	cDef05*/,/*cDefSpa5*/,/*cDefEng5*/,/*aHelpPor*/,/*aHelpEng*/,/*aHelpSpa*/,/*cHelp*/ )

U_PUTSX1( cPerg ,'02' , 'Data Inicial' ,'Data Inicial'/*cPerSpa*/,'Data Inicial'/*cPerEng*/,'mv_ch2','D' , 8 ,0 ,0/*nPresel*/,'G'/*cGSC*/,/*cValid*/,/*cF3*/, /*cGrpSxg*/,/*cPyme*/,'MV_PAR02'/*cVar01*/,/*cDef01*/,/*cDefSpa1*/,/*cDefEng1*/,/*cCnt01*/,/*cDef02*/,/*cDefSpa2*/,/*cDefEng2*/,/*cDef03*/,/*cDefSpa3*/,/*cDefEng3*/,	/*cDef04*/,/*cDefSpa4*/,/*cDefEng4*/,/*	cDef05*/,/*cDefSpa5*/,/*cDefEng5*/,/*aHelpPor*/,/*aHelpEng*/,/*aHelpSpa*/,/*cHelp*/ )
U_PUTSX1( cPerg ,'03' , 'Data Final' ,'Data Final'/*cPerSpa*/,'Data Final'/*cPerEng*/,'mv_ch3','D' , 8 ,0 ,0/*nPresel*/,'G'/*cGSC*/,/*cValid*/,/*cF3*/, /*cGrpSxg*/,/*cPyme*/,'MV_PAR03'/*cVar01*/,/*cDef01*/,/*cDefSpa1*/,/*cDefEng1*/,/*cCnt01*/,/*cDef02*/,/*cDefSpa2*/,/*cDefEng2*/,/*cDef03*/,/*cDefSpa3*/,/*cDefEng3*/,	/*cDef04*/,/*cDefSpa4*/,/*cDefEng4*/,/*	cDef05*/,/*cDefSpa5*/,/*cDefEng5*/,/*aHelpPor*/,/*aHelpEng*/,/*aHelpSpa*/,/*cHelp*/ )

Return

*-------------------------------*
User Function LG005Leg         
*-------------------------------*

Local aLegenda	 := {}

aAdd(aLegenda,{"BR_VERDE"		,'Nao Enviado'})  
aAdd(aLegenda,{"BR_AZUL"	,'Enviado'})
aAdd(aLegenda,{"BR_VERMELHO"	,'Erro no Envio'})


BrwLegenda('Legenda',cCadastro, aLegenda )

Return .T.

/*
Função............: Envia
Objetivo..........: Enviar Xml\Danfe ao servidor Ftp
Autor.............: Leandro Diniz de Brito
*/                                        
*-------------------------------*
Static Function Envia
*-------------------------------*
Local lRet			:= .F.

Local cErro			:= ""                                       
Local cAviso		:= ""
Local cModel		:= '55'
Local cModalidade	:= "" 
Local cDirXml		:= '\Ftp\' + cEmpAnt + '\'
Local cArquivo		:= 'Nf_' + AllTrim( SF2->F2_DOC ) + AllTrim( SF2->F2_SERIE ) 

Local aNotas		:= {}
Local aXml			:= {}

Local oDanfe		:= Nil
Local oFile         := Nil

Local cNFftp 		:={}
Local nTamArq 		:={0}
//Variaveis do fonte DANFEIII
Private PixelX		:= 0
Private PixelY		:= 0
Private nConsTex 	:= 0.56 // Constante para concertar o cálculo retornado pelo GetTextWidth.
Private nConsNeg 	:= 0.43 // Constante para concertar o cálculo retornado pelo GetTextWidth para fontes em negrito.

If !ExistDir( cDirXml )
	MakeDir( cDirXml )
EndIf
	
Begin Sequence                                                                  

/*
	* Geração do arquivo .xml
*/
cModalidade := getCfgModalidade( @cErro , cIdEnt, cModel)				

aadd(aNotas,{})
aadd(Atail(aNotas),.F.)
aadd(Atail(aNotas),"S")
aadd(Atail(aNotas),SF2->F2_DTDIGIT)
aadd(Atail(aNotas),SF2->F2_SERIE)
aadd(Atail(aNotas),SF2->F2_DOC)
aadd(Atail(aNotas),SF2->F2_CLIENTE)
aadd(Atail(aNotas),SF2->F2_LOJA)

aXml := GetXML( cIdEnt , aNotas , @cModalidade )            

//lValid:= StaticCall(SPEDNFE,SpedPExp,cIdEnt,SF2->F2_SERIE,SF2->F2_DOC,SF2->F2_DOC,cDirXml,lEnd,cToD("01/01/1980"),cToD("01/01/2090"),"","")

If Empty( aXml[ 1 ][ 2 ] )
	SendMessage("Nao foi possivel buscar xml para nota fiscal." + SF2->F2_DOC ,lJob)
	Break
EndIf                                 

If File( cDirXml + cArquivo + '.xml' )
	FErase( cDirXml + cArquivo + '.xml' )	
EndIf     

MemoWrit( cDirXml + cArquivo + '.xml' , aXml[ 1 ][ 2 ] ) 

If !File( cDirXml + cArquivo + '.xml' )
	SendMessage('Nao foi possivel gravar no Protheus arquivo xml (' + cDirXml + cArquivo + '.xml' + ') . Nota fiscal ' + SF2->F2_DOC,lJob)
	Break
EndIf 

If File( cDirXml + cArquivo + '.pdf' )
	FErase( cDirXml + cArquivo + '.pdf' )
EndIf 

If File( cDirXml + cArquivo + '.rel' )
	FErase( cDirXml + cArquivo + '.rel' )
EndIf


/*
	* Geração Danfe em pdf 
*/
MV_PAR01 := SF2->F2_DOC 
MV_PAR02 := SF2->F2_DOC
MV_PAR03 := SF2->F2_SERIE
MV_PAR04 := 2	// [Operacao] NF de Saida
MV_PAR05 := 1	// [Frente e Verso] Sim
MV_PAR06 := 2	// [DANFE simplificado] Nao 

//WFA -26/03/19 - Gera o arquivo de novo caso tenha sido gerado com 0 bytes. Ticket: #2213.
While nTamArq[1] <= 0
	If File( cDirXml + cArquivo + '.pdf' )
		FErase( cDirXml + cArquivo + '.pdf' )
	EndIf

	FreeObj( oDanfe )

	oDanfe   := FWMSPrinter():New( cArquivo , IMP_PDF , .F. ,, .T. )
	oDanfe:SetPortrait()
	oDanfe:SetResolution(78) //Tamanho estipulado para a Danfe
	oDanfe:SetLandscape()//Paisagem
	oDanfe:SetPaperSize(DMPAPER_A4)
	oDanfe:SetMargin(60,60,60,60)
	oDanfe:cPathPDF := cDirXml
	oDanfe:SetViewPDF(.F.)     
	oDanfe:nDevice := IMP_PDF                                                         
	oDanfe:lServer := .T.
	oDanfe:lInJob := .T.

	PixelX := odanfe:nLogPixelX()
	PixelY := odanfe:nLogPixelY()

	StaticCall(DANFEIII,DANFEProc,@oDanfe, .F. , cIDEnt, Nil, Nil, .F. /*@lExistNFe*/, .F. /*lIsLoja */)

	oDanfe:Print()
	Sleep(10000)
 	ADir(cDirXml+cArquivo+".pdf", cNFftp, nTamArq)
EndDo

FreeObj( oDanfe )

If !File( cDirXml + cArquivo + '.pdf' )
	SendMessage("Nao foi possivel gerar pdf ( Danfe ) para a nota fiscal "+ SF2->F2_DOC + SF2->F2_SERIE,lJob)	
	lRet := .F.  
	Break
EndIf

/*
	* Inclusao geração boleto .pdf
*/
//WFA -26/03/19 - Gera o arquivo de novo caso tenha sido gerado com 0 bytes. Ticket: #2213.
nTamArq := {0}
While nTamArq[1] <= 0
	cBoleto := u_LGFin001( .T. , .F. )
	If Empty(cBoleto)
		nTamArq:= {1}
	Else
		Sleep(10000)
		ADir(cDirXml+cBoleto, cNFftp, nTamArq)
	EndIf
EndDo
/*
	* Se gerou xml e pdf , envia para o servidor Ftp
*/                                                  
lRet := EnviaFtp( cDirXml , cArquivo + '.xml' , cArquivo + '.pdf' , cBoleto ) 

End Sequence

Return( lRet )

*-----------------------------------------------------*
 Static Function GetXML(cIdEnt,aIdNFe,cModalidade)  
*-----------------------------------------------------*

Local aRetorno		:= {}
Local aDados		:= {}

Local cURL			:= PadR(GetNewPar("MV_SPEDURL","http://localhost:8080/sped"),250)
Local cModel		:= "55"


Local nZ			:= 0
Local nCount		:= 0

Local oWS

If Empty(cModalidade)    

	oWS := WsSpedCfgNFe():New()
	oWS:cUSERTOKEN := "TOTVS"
	oWS:cID_ENT    := cIdEnt
	oWS:nModalidade:= 0
	oWS:_URL       := AllTrim(cURL)+"/SPEDCFGNFe.apw"
	oWS:cModelo    := cModel 
	If oWS:CFGModalidade()
		cModalidade    := SubStr(oWS:cCfgModalidadeResult,1,1)
	Else
		cModalidade    := ""
	EndIf  
	
EndIf  
         
oWs := nil

For nZ := 1 To len(aIdNfe) 
	nCount++

	aDados := executeRetorna( aIdNfe[nZ], cIdEnt )
	
	if ( nCount == 10 )
		delClassIntF()
		nCount := 0
	endif
	
	aAdd(aRetorno,aDados)
	
Next nZ

Return(aRetorno)
                                                                                                  
*-----------------------------------------------------------*
 Static Function executeRetorna( aNfe, cIdEnt, lUsacolab )
*-----------------------------------------------------------*

Local aExecute		:= {}  
Local aFalta		:= {}
Local aResposta		:= {}
Local aRetorno		:= {}
Local aDados		:= {} 
Local aIdNfe		:= {}

Local cAviso		:= "" 
Local cDHRecbto		:= ""
Local cDtHrRec		:= ""
Local cDtHrRec1		:= ""
Local cErro			:= "" 
Local cModTrans		:= ""
Local cProtDPEC		:= ""
Local cProtocolo	:= ""
Local cMsgNFE		:= ""
Local cRetDPEC		:= ""
Local cRetorno		:= ""
Local cCodRetNFE	:= ""
Local cURL			:= PadR(GetNewPar("MV_SPEDURL","http://localhost:8080/sped"),250)
Local cModel		:= "55"

//RRP - 04/07/2018 - Ajuste no layout do XML
Local cCab1			:= ""
Local cRodap		:= ""
Local cVerNfe		:= ""

Local dDtRecib		:= CToD("")

Local lFlag			:= .T.

Local nDtHrRec1		:= 0
Local nL			:= 0
Local nX			:= 0
Local nY			:= 0
Local nZ			:= 1
Local nCount		:= 0
Local nLenNFe
Local nLenWS

Local oWS

Private oDHRecbto
Private oNFeRet
Private oDoc

default lUsacolab	:= .F.

aAdd(aIdNfe,aNfe)

If !lUsacolab

	oWS:= WSNFeSBRA():New()
	oWS:cUSERTOKEN        := "TOTVS"
	oWS:cID_ENT           := cIdEnt
	oWS:nDIASPARAEXCLUSAO := 0
	oWS:_URL 			  := AllTrim(cURL)+"/NFeSBRA.apw"
	oWS:oWSNFEID          := NFESBRA_NFES2():New()
	oWS:oWSNFEID:oWSNotas := NFESBRA_ARRAYOFNFESID2():New()  
	
	aadd(aRetorno,{"","",aIdNfe[nZ][4]+aIdNfe[nZ][5],"","","",CToD(""),"","",""})
	
	aadd(oWS:oWSNFEID:oWSNotas:oWSNFESID2,NFESBRA_NFESID2():New())
	Atail(oWS:oWSNFEID:oWSNotas:oWSNFESID2):cID := aIdNfe[nZ][4]+aIdNfe[nZ][5]
	
	If oWS:RETORNANOTASNX()
		If Len(oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5) > 0
			For nX := 1 To Len(oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5)
				cRetorno        := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSNFE:CXML
				cProtocolo      := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSNFE:CPROTOCOLO								
				cDHRecbto  		:= oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSNFE:CXMLPROT
				oNFeRet			:= XmlParser(cRetorno,"_",@cAviso,@cErro)
				cModTrans		  := IIf(Type("oNFeRet:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT") <> "U",IIf (!Empty("oNFeRet:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT"),oNFeRet:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT,1),1)
				If ValType(oWs:OWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:OWSDPEC)=="O"
					cRetDPEC        := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSDPEC:CXML
					cProtDPEC       := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSDPEC:CPROTOCOLO
				EndIf
				
	
				//Tratamento para gravar a hora da transmissao da NFe
				If !Empty(cProtocolo)
					oDHRecbto		:= XmlParser(cDHRecbto,"","","")
					cDtHrRec		:= IIf(Type("oDHRecbto:_ProtNFE:_INFPROT:_DHRECBTO:TEXT")<>"U",oDHRecbto:_ProtNFE:_INFPROT:_DHRECBTO:TEXT,"")
					nDtHrRec1		:= RAT("T",cDtHrRec)
					
					If nDtHrRec1 <> 0
						cDtHrRec1   :=	SubStr(cDtHrRec,nDtHrRec1+1)
						dDtRecib	:=	SToD(StrTran(SubStr(cDtHrRec,1,AT("T",cDtHrRec)-1),"-",""))
					EndIf
					
					AtuSF2Hora(cDtHrRec1,aIdNFe[nZ][5]+aIdNFe[nZ][4]+aIdNFe[nZ][6]+aIdNFe[nZ][7])
					
				EndIf
	
				nY := aScan(aIdNfe,{|x| x[4]+x[5] == SubStr(oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:CID,1,Len(x[4]+x[5]))})
	
				oWS:cIdInicial    := aIdNfe[nZ][4]+aIdNfe[nZ][5]
				oWS:cIdFinal      := aIdNfe[nZ][4]+aIdNfe[nZ][5]
				If oWS:MONITORFAIXA()
					cCodRetNFE := oWS:oWsMonitorFaixaResult:OWSMONITORNFE[1]:OWSERRO:OWSLOTENFE[len(oWS:oWsMonitorFaixaResult:OWSMONITORNFE[1]:OWSERRO:OWSLOTENFE)]:CCODRETNFE
					cMsgNFE	:= oWS:oWsMonitorFaixaResult:OWSMONITORNFE[1]:OWSERRO:OWSLOTENFE[len(oWS:oWsMonitorFaixaResult:OWSMONITORNFE[1]:OWSERRO:OWSLOTENFE)]:CMSGRETNFE
				EndIf
	            
				//RRP - 04/07/2018 - Ajuste no layout do XML exportado
				cVerNfe := IIf(Type("oNFeRet:_NFE:_INFNFE:_VERSAO:TEXT") <> "U", oNFeRet:_NFE:_INFNFE:_VERSAO:TEXT, '')
				cCab1 := '<?xml version="1.0" encoding="UTF-8"?>'
				Do Case
					Case cVerNfe <= "1.07"
						cCab1 += '<nfeProc xmlns="http://www.portalfiscal.inf.br/nfe" xmlns:ds="http://www.w3.org/2000/09/xmldsig#" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.portalfiscal.inf.br/nfe procNFe_v1.00.xsd" versao="1.00">'
					Case cVerNfe >= "2.00" .And. "cancNFe" $ cRetorno
						cCab1 += '<procCancNFe xmlns="http://www.portalfiscal.inf.br/nfe" versao="' + cVerNfe + '">'
					OtherWise
						cCab1 += '<nfeProc xmlns="http://www.portalfiscal.inf.br/nfe" versao="' + cVerNfe + '">'
				EndCase
				cRodap := '</nfeProc>'
				cRetorno:= AllTrim(cCab1)+AllTrim(cRetorno)+Alltrim(cDHRecbto)+AllTrim(cRodap) 
				
				If nY > 0
					aRetorno[nY][1] := cProtocolo
					aRetorno[nY][2] := cRetorno
					aRetorno[nY][4] := cRetDPEC
					aRetorno[nY][5] := cProtDPEC
					aRetorno[nY][6] := cDtHrRec1
					aRetorno[nY][7] := dDtRecib
					aRetorno[nY][8] := cModTrans
					aRetorno[nY][9] := cCodRetNFE
					aRetorno[nY][10]:= cMsgNFE
					
					//aadd(aResposta,aIdNfe[nY])
				EndIf
				cRetDPEC := ""
				cProtDPEC:= ""
			Next nX
		EndIf
	Else
		Aviso("DANFE",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"OK"},3)
	EndIf 
EndIf

oWS       := Nil
oDHRecbto := Nil
oNFeRet   := Nil

return aRetorno[len(aRetorno)]

static function atuSf2Hora( cDtHrRec,cSeek )

local aArea := GetArea()
 
dbSelectArea("SF2")
dbSetOrder(1)
If MsSeek(xFilial("SF2")+cSeek)
	If SF2->(FieldPos("F2_HORA"))<>0 .And. ( Empty(SF2->F2_HORA) .Or. SF2->F2_HORA <> cDtHrRec )
		RecLock("SF2")
		SF2->F2_HORA := cDtHrRec
		MsUnlock()
	EndIf
EndIf
dbSelectArea("SF1")
dbSetOrder(1)
If MsSeek(xFilial("SF1")+cSeek)
	If SF1->(FieldPos("F1_HORA"))<>0 .And. ( Empty(SF1->F1_HORA) .Or. SF1->F1_HORA <> cDtHrRec )
		RecLock("SF1")
		SF1->F1_HORA := cDtHrRec
		MsUnlock()
	EndIf
EndIf

RestArea(aArea)

return nil


/*
Funcao.........: ConectaFTP
Objetivo.......: Conexão ao servidor FTP   
Autor..........: Leandro Diniz de Brito
*/
*-----------------------------------------*
Static Function ConectaFTP
*-----------------------------------------*  
Local lRet 		:= .T.  
Local i,j
Local nTry 		:= 3 
Local cFtp 		:= GETMV("MV_P_FTP",,'ftp.agv.com.br') 
Local cLogin	:= GETMV("MV_P_USR",,'exeltis') 
Local cPass		:= GETMV("MV_P_PSW",,'7Tp@ex3lt!s') 

Begin Sequence

	For i := 1 To nTry 
		If ( lRet := FTPConnect(cFtp,,cLogin,cPass) )
			Exit
		EndIf   
		Sleep( 5000 )
	Next

End Sequence   

Return( lRet )

/*
Funcao.........: EnviaFtp
Objetivo.......: Conexão ao servidor FTP   
Autor..........: Leandro Diniz de Brito
*/
*-----------------------------------------*
Static Function EnviaFtp( cDirXml , cXml , cPdf , cBoleto )
*-----------------------------------------*  
Local lRet := .T.
Local cDirFtpXml := GetNewPar( 'MV_P_DRXML' , '/TEST/XMLDEPARA/' )
Local cDirFtpPdf := GetNewPar( 'MV_P_DRPDF' , '/TEST/PDF NF/' )


Begin Sequence


If !FtpDirChange( cDirFtpXml )
	SendMessage("Erro na mudança de pasta do Ftp ( XMLDEPARA )",lJob)
	lRet := .F.	
	Break
EndIf    

If !FtpUpLoad( cDirXml + cXml , cXml )
	SendMessage("Erro ao efetuar upload do arquivo " + cXml + " ao servidor Ftp.",lJob)
	lRet := .F.	
	Break
EndIf     


If !FtpDirChange( cDirFtpPdf )
	SendMessage("Erro ao na mudança de pasta do Ftp ( PDF NF )",lJob)
	lRet := .F.	
	Break
EndIf    

If !FtpUpLoad( cDirXml + cPdf , cPdf )
	SendMessage("Erro ao efetuar upload do arquivo " + cPdf + " ao servidor Ftp.",lJob)
	lRet := .F.	
	Break
EndIf 

If !Empty( cBoleto )
	If !FtpUpLoad( cDirXml + cBoleto , cBoleto )
		SendMessage("Erro ao efetuar upload do arquivo " + cBoleto + " ao servidor Ftp.",lJob)
		lRet := .F.	
		Break
	EndIf 
EndIf              

End Sequence

Return( lRet )

/*
Funcao      : SendMessage
Objetivos   : Enviar mensagem na tela ou console
Autor       : Renato Rezende
*/
*--------------------------------------------*
 Static Function SendMessage(cMensagem,lJob)
*--------------------------------------------*
Default lJob := .F.

Return( If(lJob , ConOut(cMensagem) , MsgStop(cMensagem,"HLB BRASIL")))

/*
Funcao      : AutoQuery
Objetivos   : Query para envio de notas atuomáticas
Autor       : Renato Rezende
*/
*--------------------------------------------*
 Static Function AutoQuery(cMarca)
*--------------------------------------------*
Local cQuery:= "" 

If Select(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf

If lJob
	cQuery:= "	SELECT R_E_C_N_O_ RECSF2,* FROM "+RetSqlName("SF2")+" " 
	cQuery+= "	 WHERE D_E_L_E_T_ <> '*' AND F2_FILIAL = '"+FwxFilial("SF2")+"' AND F2_P_ENVD <> '1' AND F2_ESPECIE = 'SPED' AND F2_CHVNFE <> ''  AND F2_TIPO = 'N' ORDER BY F2_DOC "
Else
	cQuery:= "	SELECT R_E_C_N_O_ RECSF2,* FROM "+RetSqlName("SF2")+" WHERE D_E_L_E_T_ <> '*' AND F2_OK = '"+cMarca+"' AND F2_FILIAL = '"+FwxFilial("SF2")+"' ORDER BY F2_DOC"
EndIf

DbUseArea(.T.,"TOPCONN",TCGENQry(,,cQuery),(cAlias),.F.,.T.)

(cAlias)->(DbGoTop())

Return cAlias

/*
Funcao      : HtmlPrc
Retorno     : cHtml
Objetivos   : Criar corpo do email de arquivo enviado para processar
Autor       : Renato Rezende
Data/Hora   : 20/07/2018
*/
*--------------------------------------------*
 Static Function HtmlPrc()
*--------------------------------------------*
Local cHtml	:= ""
Local nR	:= 0

cHtml += '<html>
cHtml += '	<head>
cHtml += '	<title>Modelo-Email</title>
cHtml += '	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
cHtml += '	</head>
cHtml += '	<body bgcolor="#FFFFFF" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
cHtml += '		<table id="Tabela_01" width="631" height="342" border="0" cellpadding="0" cellspacing="0">
cHtml += '			<tr><td width="631" height="10"></td></tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="1" bgcolor="#8064A1"></td>
cHtml += '			</tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="25"> <font size="2" face="tahoma" color="#551A8B"><b>PROCESSAMENTO</b></font>   </td>
cHtml += '			</tr>
cHtml += '			<tr><td width="631" height="1" bgcolor="#8064A1"></td></tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="25" bgcolor="#E5DFEB"><font size="2" face="tahoma" color="#8064A1">DATE: '+ALLTRIM(cDate)+'</font></td>
cHtml += '			</tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="26"><font size="2" face="tahoma" color="#8064A1">TIME: '+ALLTRIM(cTime)+'</font></td>
cHtml += '			</tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="25" bgcolor="#E5DFEB"><font size="2" face="tahoma" color="#8064A1">USER: '+IIF(Empty(ALLTRIM(cUser)),"JOB", Alltrim(cUser))+'</font></td>
cHtml += '			</tr>
cHtml += '			<tr><td width="631" height="1" bgcolor="#8064A1"></td></tr>
//Download de pedidos aprovados
If Len(aErro) > 0
	cHtml += '			<tr>
	cHtml += '				<td width="631" height="26"><font size="2" face="tahoma" color="#8064A1">LOG DO PROCESSAMENTO:</font></td>
	cHtml += '			</tr>
	//Log gerado do processamento
	For nR:= 1 to Len(aErro)
		cHtml += '			<tr>
		cHtml += '				<td width="631" height="26"><font size="2" face="tahoma" color="#8064A1">
		cHtml += '				Mensagem: '+Alltrim(aErro[nR][3])+' <br/>
		cHtml += '				Nota: '+Alltrim(aErro[nR][1])+' / Serie: '+Alltrim(aErro[nR][2])+' <br/>
		cHtml += '				------------------</font></td>
		cHtml += '			</tr>
	Next nR
EndIf
cHtml += '			<tr><td width="631" height="1" bgcolor="#8064A1"></td></tr>
cHtml += '			<tr><td width="631" height="20"></td></tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="20"><p align=center>Mensagem automatica, nao responder.</p></td>
cHtml += '			</tr>
cHtml += '		</table>
cHtml += '	</body>
cHtml += '</html>

Return cHtml
