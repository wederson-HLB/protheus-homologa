#INCLUDE "SPEDNFE.ch"
#INCLUDE "FILEIO.CH"
#INCLUDE "RPTDEF.CH"  
#INCLUDE "FWPrintSetup.ch"
#Include "topconn.ch"
#Include "rwmake.ch"
#Include "protheus.ch"  
#Include "tbiconn.ch"
/*
Funcao      : GTFAT010
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para executar upload de DANFE e XML em um FTP.
Autor     	: Jean Victor Rocha
Data     	: 18/09/2014
Obs         :
*/ 
*-----------------------*
User Function GTFAT010()
*-----------------------*
Private cPath 	:= GETMV("MV_P_FTP",,"")// "200.196.242.81"
Private clogin	:= GETMV("MV_P_USR",,"") // "tiago"
Private cPass 	:= GETMV("MV_P_PSW",,"") // "123" 

Private cEmail 	:= GETMV("MV_P_00019",,"")  //E-mail que recebem notificação de novo arquivo no FTP, GTFAT010

Private cDirFtp := GETMV("MV_P_00020",,"/") //Diretorio no FTP para upload de arquivos DANFE e XML, GTFAT010

Private cDir	:= ""

Return Main()

/*
Funcao      : Main
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função principal
Autor     	: Jean Victor Rocha
Data     	: 18/09/2014
Obs         :
*/ 
*--------------------*
Static Function Main()   
*--------------------*
Local lConnect   := .F.
Local oProcess

Private aArqsImp := {}

//Ajusta a Pasta de Origem no Servidor - Temporaria
If ExistDir("\FTP")
	If !ExistDir("\FTP\"+cEmpAnt)
		MakeDir("\FTP\"+cEmpAnt)
	EndIf
Else
	MakeDir("\FTP")
	MakeDir("\FTP\"+cEmpAnt)
EndIf
If !ExistDir("\FTP\"+cEmpAnt)
	MsgInfo("Falha ao carregar diretório FTP no Servidor!","HLB BRASIL")
	Return .F.
EndIf

cDir := "\FTP\"+cEmpAnt

//Conexao do FTP interno
For i:=1 to 3// Tenta 3 vezes.
	lConnect := ConectaFTP()
	If lConnect
 		i:=3
   	EndIf
Next   
If !lConnect
	MsgAlert("Não foi possivel estabelecer conexão com FTP.","HLB BRASIL")
 	Return .F.
EndIf

// Monta o diretório do FTP, será gravado na raiz "/"
FTPDirChange(cDirFtp)

//Gera os Arquivos
SpedDanfe()
SpedExport()

//Meter
oProcess := MsNewProcess():New({|| UP2FTP(@oProcess) },"Upload","Processando...",.F.)
oProcess:Activate()

//Encerra conexão com FTP
FTPDisconnect()

Return .T. 

*------------------------------*
Static Function UP2FTP(oProcess)
*------------------------------*
//Barra de incremeto
oProcess:SetRegua1(4)
oProcess:SetRegua2(1)
oProcess:IncRegua1("Processando FTP:'"+ALLTRIM(cPath)+"' Aguarde...")

aArqs := Directory(cDir+"\*.PDF")
For i:=1 to Len(aArqs)
	FTPUpLoad(cDir+"\"+alltrim(aArqs[i][1]),alltrim(aArqs[i][1]))
	FERASE(cDir+"\"+alltrim(aArqs[i][1]))
	aAdd(aArqsImp, alltrim(aArqs[i][1]) )
Next i               
oProcess:IncRegua1("Processando FTP:'"+ALLTRIM(cPath)+"' Aguarde...")

aArqs := Directory(cDir+"\*.XML")
For i:=1 to Len(aArqs)
	FTPUpLoad(cDir+"\"+alltrim(aArqs[i][1]),alltrim(aArqs[i][1]))
	FERASE(cDir+"\"+alltrim(aArqs[i][1]))
	aAdd(aArqsImp, alltrim(aArqs[i][1]) )
Next i
oProcess:IncRegua1("Processando FTP:'"+ALLTRIM(cPath)+"' Aguarde...")

SendMail()
oProcess:IncRegua1("Processando FTP:'"+ALLTRIM(cPath)+"' Aguarde...")
oProcess:IncRegua2("")

Return .T.

/*
Funcao      : SendMail
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Enviar Email de Notificação
Autor       : Jean Victor Rocha	
Data/Hora   : 
*/
*------------------------*
Static Function SendMail()
*------------------------*
Local cMsg := Email()

If EMPTY(cEmail)
	Return .T.
EndIf

oEmail          := DEmail():New()
oEmail:cFrom   	:= "totvs@hlb.com.br"
oEmail:cTo		:= PADR(cEmail,200)
oEmail:cSubject	:= padr("Notificacao de Danfe e XML no FTP.",200)
oEmail:cBody   	:= cMsg
oEmail:Envia()

Return .T. 


/*
Funcao      : ConectaFTP
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Funcão para conectar no FTP
Obs         :
*/          
*--------------------------*
Static Function ConectaFTP()
*--------------------------*
Local lRet		:= .F.

cPath  := Alltrim(cPath)
cLogin := Alltrim(cLogin)
cPass  := Alltrim(cPass) 

// Conecta no FTP
lRet := FTPConnect(cPath,,cLogin,cPass) 
   
Return (lRet)         

/*/
±±³Programa  ³SpedDanfe ³ Autor ³Eduardo Riera          ³ Data ³27.06.2007³±±
±±³Descri‡…o ³Rotina de chamada do WS de impressao da DANFE               ³±±
/*/
*-------------------------*
Static Function SpedDanfe()
*-------------------------*
Local cIdEnt := GetIdEnt()
Local aIndArq   := {}
Local oDanfe
Local nHRes  := 0
Local nVRes  := 0
Local nDevice
Local cFilePrint := "DANFE_"+cIdEnt+Dtos(MSDate())+StrTran(Time(),":","")
Local oSetup
Local aDevice  := {}
Local cSession     := GetPrinterSession()
Local nRet := 0

PRIVATE aFilBrw   := {}

If findfunction("U_DANFE_V")
	nRet := U_Danfe_v()
EndIf

AADD(aDevice,"DISCO") // 1
AADD(aDevice,"SPOOL") // 2
AADD(aDevice,"EMAIL") // 3
AADD(aDevice,"EXCEL") // 4
AADD(aDevice,"HTML" ) // 5
AADD(aDevice,"PDF"  ) // 6
                                                                        
nLocal       	:= 1//If(GetProfString(cSession,"LOCAL","SERVER",.T.)=="SERVER",1,2 )
nOrientation 	:= If(GetProfString(cSession,"ORIENTATION","PORTRAIT",.T.)=="PORTRAIT",1,2)
cDevice     	:= GetProfString(cSession,"PRINTTYPE","SPOOL",.T.)
nPrintType      := aScan(aDevice,{|x| x == cDevice })

If IsReady()
	dbSelectArea("SF2")
	RetIndex("SF2")
	dbClearFilter() 
	If nRet >= 20100824
		lAdjustToLegacy := .F. // Inibe legado de resolução com a TMSPrinter
		//oDanfe := FWMSPrinter():New(cFilePrint, IMP_PDF, lAdjustToLegacy, "C:\"/*cPathInServer*/, .T.,,,,,,,.F.)
		oDanfe := FWMSPrinter():New(cFilePrint, IMP_PDF, lAdjustToLegacy, cDir+"\"/*cPathInServer*/, .T.,,,,,,,.F.)
		nFlags := PD_ISTOTVSPRINTER + PD_DISABLEPAPERSIZE + PD_DISABLEPREVIEW + PD_DISABLEMARGIN
		If ( !oDanfe:lInJob )
			oSetup := FWPrintSetup():New(nFlags, "DANFE")
			oSetup:SetPropert(PD_PRINTTYPE   , nPrintType)
			oSetup:SetPropert(PD_ORIENTATION , nOrientation)
			oSetup:SetPropert(PD_DESTINATION , nLocal)
			oSetup:SetPropert(PD_MARGIN      , {60,60,60,60})
			oSetup:SetPropert(PD_PAPERSIZE   , 2)
			oSetup:aOptions[PD_VALUETYPE] :=  cDir+"\"
		EndIf
        //WriteProfString( cSession, "LOCAL"      , If(oSetup:GetProperty(PD_DESTINATION)==1 ,"SERVER"    ,"CLIENT"    ), .T. )
        WriteProfString( cSession, "LOCAL"      , "SERVER", .T. )
        WriteProfString( cSession, "PRINTTYPE"  , If(oSetup:GetProperty(PD_PRINTTYPE)==1   ,"SPOOL"     ,"PDF"       ), .T. )
        WriteProfString( cSession, "ORIENTATION", If(oSetup:GetProperty(PD_ORIENTATION)==1 ,"PORTRAIT"  ,"LANDSCAPE" ), .T. )
		u_PrtNfeSef(cIdEnt,,,oDanfe, oSetup, cFilePrint,.F.)		
	Else
	 	u_PrtNfeSef(cIdEnt,,,,,,.F.)
	EndIf		
EndIf

oDanfe := Nil
oSetup := Nil

Return()

/*/
±±³Programa  ³GetIdEnt  ³ Autor ³Eduardo Riera          ³ Data ³18.06.2007³±±
±±³Descri‡…o ³Obtem o codigo da entidade apos enviar o post para o Totvs  ³±±
±±³          ³Service                                                     ³±±
/*/
*------------------------*
Static Function GetIdEnt()
*------------------------*
Local aArea  := GetArea()
Local cIdEnt := ""
Local cURL   := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local oWs
Local lUsaGesEmp := IIF(FindFunction("FWFilialName") .And. FindFunction("FWSizeFilial") .And. FWSizeFilial() > 2,.T.,.F.)

oWS := WsSPEDAdm():New()
oWS:cUSERTOKEN := "TOTVS"
	
oWS:oWSEMPRESA:cCNPJ       := IIF(SM0->M0_TPINSC==2 .Or. Empty(SM0->M0_TPINSC),SM0->M0_CGC,"")	
oWS:oWSEMPRESA:cCPF        := IIF(SM0->M0_TPINSC==3,SM0->M0_CGC,"")
oWS:oWSEMPRESA:cIE         := SM0->M0_INSC
oWS:oWSEMPRESA:cIM         := SM0->M0_INSCM		
oWS:oWSEMPRESA:cNOME       := SM0->M0_NOMECOM
oWS:oWSEMPRESA:cFANTASIA   := IIF(lUsaGesEmp,FWFilialName(),Alltrim(SM0->M0_NOME))
oWS:oWSEMPRESA:cENDERECO   := FisGetEnd(SM0->M0_ENDENT)[1]
oWS:oWSEMPRESA:cNUM        := FisGetEnd(SM0->M0_ENDENT)[3]
oWS:oWSEMPRESA:cCOMPL      := FisGetEnd(SM0->M0_ENDENT)[4]
oWS:oWSEMPRESA:cUF         := SM0->M0_ESTENT
oWS:oWSEMPRESA:cCEP        := SM0->M0_CEPENT
oWS:oWSEMPRESA:cCOD_MUN    := SM0->M0_CODMUN
oWS:oWSEMPRESA:cCOD_PAIS   := "1058"
oWS:oWSEMPRESA:cBAIRRO     := SM0->M0_BAIRENT
oWS:oWSEMPRESA:cMUN        := SM0->M0_CIDENT
oWS:oWSEMPRESA:cCEP_CP     := Nil
oWS:oWSEMPRESA:cCP         := Nil
oWS:oWSEMPRESA:cDDD        := Str(FisGetTel(SM0->M0_TEL)[2],3)
oWS:oWSEMPRESA:cFONE       := AllTrim(Str(FisGetTel(SM0->M0_TEL)[3],15))
oWS:oWSEMPRESA:cFAX        := AllTrim(Str(FisGetTel(SM0->M0_FAX)[3],15))
oWS:oWSEMPRESA:cEMAIL      := UsrRetMail(RetCodUsr())
oWS:oWSEMPRESA:cNIRE       := SM0->M0_NIRE
oWS:oWSEMPRESA:dDTRE       := SM0->M0_DTRE
oWS:oWSEMPRESA:cNIT        := IIF(SM0->M0_TPINSC==1,SM0->M0_CGC,"")
oWS:oWSEMPRESA:cINDSITESP  := ""
oWS:oWSEMPRESA:cID_MATRIZ  := ""
oWS:oWSOUTRASINSCRICOES:oWSInscricao := SPEDADM_ARRAYOFSPED_GENERICSTRUCT():New()
oWS:_URL := AllTrim(cURL)+"/SPEDADM.apw"
If oWs:ADMEMPRESAS()
	cIdEnt  := oWs:cADMEMPRESASRESULT
Else
	Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"ATENCAO"},3)
EndIf

RestArea(aArea)
Return(cIdEnt)

/*
Funcao      : IsReady
Data     	: 18/09/2014
*/ 
*---------------------------------------*
Static Function IsReady(cURL,nTipo,lHelp)
*---------------------------------------*
Local nX       := 0
Local cHelp    := ""
Local oWS
Local lRetorno := .F.
DEFAULT nTipo := 1
DEFAULT lHelp := .F.
If !Empty(cURL) .And. !PutMV("MV_SPEDURL",cURL)
	RecLock("SX6",.T.)
	SX6->X6_FIL     := xFilial( "SX6" )
	SX6->X6_VAR     := "MV_SPEDURL"
	SX6->X6_TIPO    := "C"
	SX6->X6_DESCRIC := "URL SPED NFe"
	MsUnLock()
	PutMV("MV_SPEDURL",cURL)
EndIf
SuperGetMv() //Limpa o cache de parametros - nao retirar
DEFAULT cURL      := PadR(GetNewPar("MV_SPEDURL","http://"),250)

//³Verifica se o servidor da Totvs esta no ar                              ³
oWs := WsSpedCfgNFe():New()
oWs:cUserToken := "TOTVS"
oWS:_URL := AllTrim(cURL)+"/SPEDCFGNFe.apw"
If oWs:CFGCONNECT()
	lRetorno := .T.
Else
	If lHelp
		Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"O certificado digital irá vencer em: "},3)
	EndIf
	lRetorno := .F.
EndIf

//³Verifica se o certificado digital ja foi transferido                    ³
If nTipo <> 1 .And. lRetorno
	oWs:cUserToken := "TOTVS"
	oWs:cID_ENT    := GetIdEnt()
	oWS:_URL := AllTrim(cURL)+"/SPEDCFGNFe.apw"		
	If oWs:CFGReady()
		lRetorno := .T.
	Else
		If nTipo == 3
			cHelp := IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
			If lHelp .And. !"003" $ cHelp
				Aviso("SPED",cHelp,{"O certificado digital irá vencer em: "},3)
				lRetorno := .F.
			EndIf		
		Else
			lRetorno := .F.
		EndIf
	EndIf
EndIf

//³Verifica se o certificado digital ja foi transferido
If nTipo == 2 .And. lRetorno
	oWs:cUserToken := "TOTVS"
	oWs:cID_ENT    := GetIdEnt()
	oWS:_URL := AllTrim(cURL)+"/SPEDCFGNFe.apw"		
	If oWs:CFGStatusCertificate()
		If Len(oWs:oWSCFGSTATUSCERTIFICATERESULT:OWSDIGITALCERTIFICATE) > 0
			For nX := 1 To Len(oWs:oWSCFGSTATUSCERTIFICATERESULT:OWSDIGITALCERTIFICATE)
				If oWs:oWSCFGSTATUSCERTIFICATERESULT:OWSDIGITALCERTIFICATE[nx]:DVALIDTO-30 <= Date()
					Aviso("SPED","O certificado digital irá vencer em: "+Dtoc(oWs:oWSCFGSTATUSCERTIFICATERESULT:OWSDIGITALCERTIFICATE[nX]:DVALIDTO),{"Atenção"},3)
			    EndIf
			Next nX		
		EndIf
	EndIf
EndIf

Return(lRetorno)

/*/
±±³Programa  ³SpedExport³ Autor ³Eduardo Riera          ³ Data ³02.03.2008³±±
±±³Descri‡…o ³Rotina de exportacao das notas fiscaiss eletronicas         ³±±
/*/
*--------------------------*
Static Function SpedExport()
*--------------------------*
Local cIdEnt   := ""
Local aPerg    := {}
Local aParam   := {Space(Len(SF2->F2_SERIE)),Space(Len(SF2->F2_DOC)),Space(Len(SF2->F2_DOC)),Space(60),CToD(""),CToD(""),Space(14),Space(14)}
Local cParNfeExp := SM0->M0_CODIGO+SM0->M0_CODFIL+"SPEDNFEEXP"

aParam[01] := MV_PAR03
aParam[02] := MV_PAR01
aParam[03] := MV_PAR02
aParam[04] := cDir+"\"
aParam[05] := STOD("20000101")
aParam[06] := STOD("20491231")

If IsReady()
	cIdEnt := GetIdEnt()
	If !Empty(cIdEnt)
		If !Empty(cIdEnt)
			Processa({|lEnd| SpedPExp(cIdEnt,aParam[01],aParam[02],aParam[03],aParam[04],lEnd,aParam[05],IIF(Empty(aParam[06]),dDataBase,aParam[06]),aParam[07],aParam[08])},"Processando","Aguarde, exportando arquivos",.F.)
		EndIf
	Else
		Aviso("SPED","Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!",{"Atencao"},3)	//"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
	EndIf
Else
	Aviso("SPED","Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!",{"Atencao"},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
EndIf

Return

*-----------------------------------------------------------------------------------------------------------*
Static Function SpedPExp(cIdEnt,cSerie,cNotaIni,cNotaFim,cDirDest,lEnd, dDataDe,dDataAte,cCnpjDIni,cCnpjDFim)
*-----------------------------------------------------------------------------------------------------------*
Local aDeleta  := {}
Local nHandle  := 0
Local cURL     := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cChvNFe  := ""
Local cDestino := ""
Local cDrive   := ""
Local cModelo  := ""
Local cPrefixo := ""
Local cCNPJDEST := Space(14)                
Local cNFes     := ""
Local cIdflush  := cSerie+cNotaIni
Local cXmlInut  := ""
Local cXml		:= ""
Local cAnoInut  := ""
Local cAnoInut1 := ""
Local nX        := 0 
Local oWS
Local oRetorno
Local oXML
Local lOk      := .F.
Local lFlush   := .T.
Local lFinal   := .F.

//ProcRegua(Val(cNotaFim)-Val(cNotaIni))
SplitPath(cDirDest,@cDrive,@cDestino,"","")
cDestino := cDrive+cDestino

Do While lFlush
		oWS:= WSNFeSBRA():New()
		oWS:cUSERTOKEN        := "TOTVS"
		oWS:cID_ENT           := cIdEnt 
		oWS:_URL              := AllTrim(cURL)+"/NFeSBRA.apw"
		oWS:cIdInicial        := cIdflush // cNotaIni
		oWS:cIdFinal          := cSerie+cNotaFim
		oWS:dDataDe           := dDataDe
		oWS:dDataAte          := dDataAte
		oWS:cCNPJDESTInicial  := cCnpjDIni
		oWS:cCNPJDESTFinal    := cCnpjDFim
		oWS:nDiasparaExclusao := 0
		lOk:= oWS:RETORNAFX()
		oRetorno := oWS:oWsRetornaFxResult
	
		If lOk
//			ProcRegua(Len(oRetorno:OWSNOTAS:OWSNFES3))
		    For nX := 1 To Len(oRetorno:OWSNOTAS:OWSNFES3)
		 		oXml    := oRetorno:OWSNOTAS:OWSNFES3[nX]
				oXmlExp := XmlParser(oRetorno:OWSNOTAS:OWSNFES3[nX]:OWSNFE:CXML,"","","")
				cXML	:= "" 
				If Type("oXmlExp:_NFE:_INFNFE:_DEST:_CNPJ")<>"U" 
					cCNPJDEST := AllTrim(oXmlExp:_NFE:_INFNFE:_DEST:_CNPJ:TEXT)
				ElseIF Type("oXmlExp:_NFE:_INFNFE:_DEST:_CPF")<>"U"
					cCNPJDEST := AllTrim(oXmlExp:_NFE:_INFNFE:_DEST:_CPF:TEXT)				
				Else
	    			cCNPJDEST := ""
    			EndIf	
    				cVerNfe := IIf(Type("oXmlExp:_NFE:_INFNFE:_VERSAO:TEXT") <> "U", oXmlExp:_NFE:_INFNFE:_VERSAO:TEXT, '')                                 
	  				cVerCte := Iif(Type("oXmlExp:_CTE:_INFCTE:_VERSAO:TEXT") <> "U", oXmlExp:_CTE:_INFCTE:_VERSAO:TEXT, '')
		 		If !Empty(oXml:oWSNFe:cProtocolo)
			    	cNotaIni := oXml:cID	 		
					cIdflush := cNotaIni
			 		cNFes := cNFes+cNotaIni+CRLF
			 		cChvNFe  := NfeIdSPED(oXml:oWSNFe:cXML,"Id")	 			
					cModelo := cChvNFe
					cModelo := StrTran(cModelo,"NFe","")
					cModelo := StrTran(cModelo,"CTe","")
					cModelo := SubStr(cModelo,21,02)
					
					Do Case
						Case cModelo == "57"
							cPrefixo := "CTe"
						OtherWise
							cPrefixo := "NFe"
					EndCase	 				
					
		 			nHandle := FCreate(cDestino+SubStr(cChvNFe,4,44)+"-"+cPrefixo+".xml")
		 			If nHandle > 0
		 				cCab1 := '<?xml version="1.0" encoding="UTF-8"?>'
		 				If cModelo == "57"
							cCab1  += '<cteProc xmlns="http://www.portalfiscal.inf.br/cte" xmlns:ds="http://www.w3.org/2000/09/xmldsig#" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.portalfiscal.inf.br/cte procCTe_v'+cVerCte+'.xsd" versao="'+cVerCte+'">'
							cRodap := '</cteProc>'
						Else
							Do Case
								Case cVerNfe <= "1.07"
									cCab1 += '<nfeProc xmlns="http://www.portalfiscal.inf.br/nfe" xmlns:ds="http://www.w3.org/2000/09/xmldsig#" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.portalfiscal.inf.br/nfe procNFe_v1.00.xsd" versao="1.00">'
								Case cVerNfe >= "2.00" .And. "cancNFe" $ oXml:oWSNFe:cXML
									cCab1 += '<procCancNFe xmlns="http://www.portalfiscal.inf.br/nfe" versao="' + cVerNfe + '">'
								OtherWise
									cCab1 += '<nfeProc xmlns="http://www.portalfiscal.inf.br/nfe" versao="' + cVerNfe + '">'
							EndCase
							cRodap := '</nfeProc>'
						EndIf
						FWrite(nHandle,AllTrim(cCab1))							
			 			FWrite(nHandle,AllTrim(oXml:oWSNFe:cXML))
			 			FWrite(nHandle,AllTrim(oXml:oWSNFe:cXMLPROT))
						FWrite(nHandle,AllTrim(cRodap))	 
			 			FClose(nHandle)
			 			aadd(aDeleta,oXml:cID)
			 			cXML := AllTrim(cCab1)+AllTrim(oXml:oWSNFe:cXML)+AllTrim(cRodap)
			 			If !Empty(cXML)
				 			If ExistBlock("FISEXPNFE")
	                   			ExecBlock("FISEXPNFE",.f.,.f.,{cXML})			                    
	               			Endif	
			 			EndIF
			 			
			 		EndIf					
			 	EndIf
			 	
			 	If oXml:OWSNFECANCELADA<>Nil .And. !Empty(oXml:oWSNFeCancelada:cProtocolo)
				 	cChvNFe  := NfeIdSPED(oXml:oWSNFeCancelada:cXML,"Id")
				 	cNotaIni := oXml:cID	 		
					cIdflush := cNotaIni
			 		cNFes := cNFes+cNotaIni+CRLF
				 	If !"INUT"$oXml:oWSNFeCancelada:cXML
			 			nHandle := FCreate(cDestino+SubStr(cChvNFe,3,44)+"-ped-can.xml")
			 			If nHandle > 0
			 				oXml:oWSNFeCancelada:cXML := '<procCancNFe xmlns="http://www.portalfiscal.inf.br/nfe" versao="' + cVerNfe + '">' + oXml:oWSNFeCancelada:cXML + "</procCancNFe>"
				 			FWrite(nHandle,oXml:oWSNFeCancelada:cXML)
				 			FClose(nHandle)
				 			aadd(aDeleta,oXml:cID)
				 		EndIf
			 			nHandle := FCreate(cDestino+"\"+SubStr(cChvNFe,3,44)+"-can.xml")
			 			If nHandle > 0
				 			FWrite(nHandle,oXml:oWSNFeCancelada:cXMLPROT)
				 			FClose(nHandle)
				 		EndIf
				 	Else 
						
				 	    cXmlInut  := oXml:OWSNFECANCELADA:CXML
				 	    cAnoInut1 := At("<ano>",cXmlInut)+5
				 	    cAnoInut  := SubStr(cXmlInut,cAnoInut1,2)
			 			nHandle := FCreate(cDestino+SubStr(cChvNFe,3,2)+cAnoInut+SubStr(cChvNFe,5,38)+"-ped-inu.xml")
			 			If nHandle > 0
				 			FWrite(nHandle,oXml:oWSNFeCancelada:cXML)
				 			FClose(nHandle)
				 			aadd(aDeleta,oXml:cID)
				 		EndIf
			 			nHandle := FCreate(cDestino+"\"+cAnoInut+SubStr(cChvNFe,5,38)+"-inu.xml")
			 			If nHandle > 0
				 			FWrite(nHandle,oXml:oWSNFeCancelada:cXMLPROT)
				 			FClose(nHandle)
				 		EndIf		 	
				 	EndIf
				EndIf
				IncProc()
		    Next nX
			If !Empty(aDeleta) .And. GetNewPar("MV_SPEDEXP",0)<>0
				oWS:= WSNFeSBRA():New()
				oWS:cUSERTOKEN        := "TOTVS"
				oWS:cID_ENT           := cIdEnt
				oWS:nDIASPARAEXCLUSAO := GetNewPar("MV_SPEDEXP",0)
				oWS:_URL              := AllTrim(cURL)+"/NFeSBRA.apw"		
				oWS:oWSNFEID          := NFESBRA_NFES2():New()
				oWS:oWSNFEID:oWSNotas := NFESBRA_ARRAYOFNFESID2():New()
			    For nX := 1 To Len(aDeleta)	    
					aadd(oWS:oWSNFEID:oWSNotas:oWSNFESID2,NFESBRA_NFESID2():New())
					Atail(oWS:oWSNFEID:oWSNotas:oWSNFESID2):cID := aDeleta[nX]
			    Next nX
				If !oWS:RETORNANOTAS()
					Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0046},3)
					lFlush := .F.	
				EndIf
			EndIf
			aDeleta  := {}
		    If Len(oRetorno:OWSNOTAS:OWSNFES3) == 0 .And. Empty(cNfes)
			   	Aviso("SPED",STR0106,{"Ok"})	// "Não há dados"
				lFlush := .F.	
		    EndIf
		Else
			Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))+CRLF+STR0046,{"OK"},3)
			lFinal := .T.
		EndIf

		cIdflush := AllTrim(Substr(cIdflush,1,3) + StrZero((Val( Substr(cIdflush,4,Len(AllTrim(mv_par02))))) + 1 ,Len(AllTrim(mv_par02))))
		If cIdflush <= AllTrim(cNotaIni) .Or. Len(oRetorno:OWSNOTAS:OWSNFES3) == 0 .Or. Empty(cNfes) .Or. ;
		   cIdflush <= Substr(cNotaIni,1,3)+Replicate('0',Len(AllTrim(mv_par02))-Len(Substr(Rtrim(cNotaIni),4)))+Substr(Rtrim(cNotaIni),4)// Importou o range completo
			lFlush := .F.
			If !Empty(cNfes)	
			EndIf
		EndIf
EndDo

Return(.T.)

*---------------------*
Static Function Email()
*---------------------*
Local cHtml := ""

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
cHtml += '				<td width="631" height="25"> <font size="3" face="tahoma" color="#551A8B"><b>Tipo: Danfe e XML </b></font>   </td>
cHtml += '			</tr>
cHtml += '			<tr><td width="631" height="1" bgcolor="#8064A1"></td></tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="25" bgcolor="#E5DFEB"><font size="2" face="tahoma" color="#8064A1">DATE: '+DTOC(Date())+'</font></td>
cHtml += '			</tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="26"><font size="2" face="tahoma" color="#8064A1">TIME: '+ALLTRIM(Time())+'</font></td>
cHtml += '			</tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="25" bgcolor="#E5DFEB"><font size="2" face="tahoma" color="#8064A1">USER: '+ALLTRIM(cUserName)+'</font></td>
cHtml += '			</tr>
cHtml += '			<tr><td width="631" height="1" bgcolor="#8064A1"></td></tr>
cHtml += '			<tr><td width="631" height="20"></td></tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="25"><font size="3" face="tahoma" color="#8064A1">Filtro de extração:</font>
cHtml += '											<BR>
cHtml += '											<br><font size="2" face="tahoma">Da NF:'+MV_PAR01+'</font>
cHtml += '											<br><font size="2" face="tahoma">Ate NF:'+MV_PAR02+'</font>
cHtml += '											<br><font size="2" face="tahoma">Da Serie:'+MV_PAR03+'</font>
cHtml += '				</td>
cHtml += '			</tr>
cHtml += '			<tr><td width="631" height="20"></td></tr>
cHtml += '			<tr><td width="631" height="1" bgcolor="#8064A1"></td></tr>
cHtml += '			<tr><td width="631" height="20"></td></tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="25"><font size="3" face="tahoma" color="#8064A1">Arquivos Gerados:</font>
cHtml += '											<BR>
For i:=1 to Len(aArqsImp)
	cHtml += '										<br><font size="2" face="tahoma">'+ALLTRIM(aArqsImp[i])+'</font>
Next i
cHtml += '				</td>
cHtml += '			</tr>
cHtml += '			<tr><td width="631" height="20"></td></tr>
cHtml += '			<tr><td width="631" height="1" bgcolor="#8064A1"></td></tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="20"><p align=center>Mensagem automatica, nao responder.</p></td>
cHtml += '			</tr>
cHtml += '		</table>
cHtml += '	</body>
cHtml += '</html>

Return cHtml