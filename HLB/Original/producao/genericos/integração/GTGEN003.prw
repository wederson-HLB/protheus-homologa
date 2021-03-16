#Include "topconn.ch"
#Include "tbiconn.ch"
#Include "rwmake.ch"
#Include "colors.ch"
#include "fileio.ch"  
#include "protheus.ch"


/*
Funcao      : GTGEN003
Parametros  : cChaveNFe
Retorno     : Nenhum
Objetivos   : Validar a chave da NFE .
Autor     	: Tiago Luiz Mendonça
Data     	: 14/05/2012 
Obs         : 
TDN         : 
Revisão     : Jean Victor Rocha
Data/Hora   : 14/08/2012
Módulo      : Generico. 
Cliente     : Todos.
*/

*----------------------------------*
 User Function GTGEN003(cChaveNFe)
*----------------------------------*
 
Local cURL      := PadR("http://10.0.30.55:5159",250)
Local lRet      := .T.  
Local oWS            

oWs:= WsNFeSBra():New()
oWs:cUserToken   := "TOTVS"
oWs:cID_ENT    	 := GetIdEnt() //"000001"
ows:cCHVNFE		 := cChaveNFe
oWs:_URL         := AllTrim(cURL)+"/NFeSBRA.apw"              

If oWs:ConsultaChaveNFE() 

	cCodNFE:=oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE 
	
	If Alltrim(cCodNFE) == "100"
		//MsgInfo("Consulta Nota Fiscal Eletronica HLB BRASIL: Chave "+alltrim(cChaveNFe)+" validada no SEFAZ","HLB BRASIL")
		lRet := MSGYESNO("Consulta Nota Fiscal Eletronica HLB BRASIL: Chave "+alltrim(cChaveNFe)+" validada no SEFAZ."+CHR(13)+CHR(10)+" Deseja prosseguir com a gravação? Será gerado LOG de processamento.","HLB BRASIL")
	ElseIf Alltrim(cCodNFE) == "999"
		//MsgAlert("Houve um erro na consulta Nota Fiscal Eletronica HLB BRASIL: Chave "+alltrim(cChaveNFe)+" - Verificar o STATUS no SEFAZ (Ref:999)","HLB BRASIL") 
		lRet := MSGYESNO("Erro na consulta da Nota Fiscal Eletronica HLB BRASIL: Chave "+alltrim(cChaveNFe)+" - Verificar o STATUS no SEFAZ (Ref:999)."+CHR(13)+CHR(10)+" Deseja prosseguir com a gravação? Será gerado LOG de processamento.","HLB BRASIL") 
	ElseIf Alltrim(cCodNFE) == "101" .Or. Alltrim(cCodNFE) == "102" 
		MsgStop("Consulta Nota Fiscal Eletronica HLB BRASIL: Chave "+alltrim(cChaveNFe)+" cancelada no SEFAZ, verificar","HLB BRASIL")   
		lRet := .F.
	Else
		//MsgAlert("Consulta Nota Fiscal Eletronica HLB BRASIL retornou erro indeterminado: "+cCodNFE+" ,mas não impede a gravação da nota","HLB BRASIL")
		lRet := MSGYESNO("Consulta Nota Fiscal Eletronica HLB BRASIL retornou erro indeterminado: "+cCodNFE+" ,mas não impede a gravação da nota."+CHR(13)+CHR(10)+" Deseja prosseguir com a gravação? Será gerado LOG de processamento.","HLB BRASIL")
	EndIf 
	
	
Else
	//MsgAlert("Atenção : Não foi possível validar a chave da NFE digitada :"+alltrim(cChaveNFe),"HLB BRASIL")
	lRet := MSGYESNO("Atenção : Não foi possível validar a chave da NFE digitada :"+alltrim(cChaveNFe)+"."+CHR(13)+CHR(10)+" Deseja prosseguir com a gravação? Será gerado LOG de processamento.","HLB BRASIL")
	
EndIf

Return lRet 

/*
Funcao      :  GetIdEnt()
Autor       : Tiago Luiz Mendonça
Data/Hora   : 25/08/11 10:00
*/
*---------------------------*
Static Function GetIdEnt()
*---------------------------*
Local aArea  := GetArea()
Local cIdEnt := ""
Local cURL   := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local oWs

	oWS := WsSPEDAdm():New()
	oWS:cUSERTOKEN := "TOTVS"
	
	oWS:oWSEMPRESA:cCNPJ       := IIF(SM0->M0_TPINSC==2 .Or. Empty(SM0->M0_TPINSC),SM0->M0_CGC,"")	
	oWS:oWSEMPRESA:cCPF        := IIF(SM0->M0_TPINSC==3,SM0->M0_CGC,"")
	oWS:oWSEMPRESA:cIE         := SM0->M0_INSC
	oWS:oWSEMPRESA:cIM         := SM0->M0_INSCM		
	oWS:oWSEMPRESA:cNOME       := SM0->M0_NOMECOM
	oWS:oWSEMPRESA:cFANTASIA   := SM0->M0_NOME
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
	EndIf

	RestArea(aArea)

Return (cIdEnt)