#Include "Protheus.ch"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#Include "tbiconn.ch"  
#Include "TopConn.Ch"
#INCLUDE "XMLXFUN.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �N6GEN005    Autor � William Souza      � Data �  08/05/18   ���
�������������������������������������������������������������������������͹��
���Descricao � Fonte gen�rico para gera��o do XML da NF-e                 ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
*---------------------------------*
User Function N6GEN005(cNota,dData)
*---------------------------------*
Local cXml      := "" 
Local cNfe      := ""
Local sPostRet  := "" 
Local cHeadRet  := ""
Local cError    := ""
Local cWarning  := ""
Local aHeadStr 	:= {}
Local nTimeOut 	:= nil
Local cURL     	:= Alltrim(getMV("MV_SPEDURL"))+"/NFeSBRA.apw" 
Local lCTe      := (FunName()$"SPEDCTE,TMSA500,TMSA200,TMSAE70,TMSA050") 
Local lUsaColab := UsaColaboracao( IIF(lCte,"2","1") )
Local cIdEnt    := GetIdEnt(lUsaColab)

//header do xml
aadd(aHeadStr,'Content-Type: text/xml;charset=UTF-8')
aadd(aHeadStr,"SOAPAction: http://webservices.totvs.com.br/nfsebra.apw/RETORNAFX")     
aadd(aHeadStr,'User-Agent: Mozilla/4.0 (compatible; Protheus '+GetBuild()+')') 

cXml := "<soapenv:Envelope xmlns:soapenv='http://schemas.xmlsoap.org/soap/envelope/' xmlns:nfs='http://webservices.totvs.com.br/nfsebra.apw'>"
cXml += "<soapenv:Header/>"
   cXml += "<soapenv:Body>"
      cXml += "<nfs:RETORNAFX>"
         cXml += "<nfs:USERTOKEN>TOTVS</nfs:USERTOKEN>"
         cXml += "<nfs:ID_ENT>"+cIdEnt+"</nfs:ID_ENT>"
         cXml += "<nfs:IDINICIAL>"+cNota+"</nfs:IDINICIAL>"
         cXml += "<nfs:IDFINAL>"+cNota+"</nfs:IDFINAL>"
         cXml += "<nfs:DIASPARAEXCLUSAO>0</nfs:DIASPARAEXCLUSAO>"
         cXml += "<nfs:DATADE>"+dtos(dData)+"</nfs:DATADE>"
         cXml += "<nfs:DATAATE>"+dtos(dData)+"</nfs:DATAATE>"
         cXml += "<nfs:CNPJDESTINICIAL></nfs:CNPJDESTINICIAL>"
         cXml += "<nfs:CNPJDESTFINAL></nfs:CNPJDESTFINAL>"
      cXml += "</nfs:RETORNAFX>"
   cXml += "</soapenv:Body>"
cXml += "</soapenv:Envelope>"

//Grava log Transacao 
u_N6GEN002("SPED","E","SPEDTSS","Totvs","TSS",cNota,cXml,"")

//envio NFE para o TSS
sPostRet := HttpPost(cUrl,'',cXML,nTimeOut,aHeadStr,@cHeadRet) 
If AT("DOCTYPE HTML PUBLIC",sPostRet) == 0 
	If AT("<faultcode>",sPostRet) == 0
	    If !empty(sPostRet)
			oXml     := XmlParser( sPostRet, "_", @cError, @cWarning )

			IF  valtype(XmlChildEx(oXml:_SOAP_ENVELOPE:_SOAP_BODY:_RETORNAFXRESPONSE:_RETORNAFXRESULT:_NOTAS,"_NFES3")) == "O"
				oXmlExp  := XmlParser( oXml:_SOAP_ENVELOPE:_SOAP_BODY:_RETORNAFXRESPONSE:_RETORNAFXRESULT:_NOTAS:_NFES3:_NFE:_XML:TEXT, "_", @cError, @cWarning)
				
				If valtype(oXmlExp) == "O"
					cNFe   := '<?xml version="1.0" encoding="UTF-8"?>' 
					cNFe   += '<nfeProc xmlns="http://www.portalfiscal.inf.br/nfe" versao="' + oXmlExp:_NFE:_INFNFE:_VERSAO:TEXT + '">' 
					cNFe   += oXml:_SOAP_ENVELOPE:_SOAP_BODY:_RETORNAFXRESPONSE:_RETORNAFXRESULT:_NOTAS:_NFES3:_NFE:_XML:TEXT  
					cNFe   += oXml:_SOAP_ENVELOPE:_SOAP_BODY:_RETORNAFXRESPONSE:_RETORNAFXRESULT:_NOTAS:_NFES3:_NFE:_XMLPROT:TEXT
					cNFe   += '</nfeProc>'
				Else
					cMsg := "N�o h� retorno de XML para essa NFe " + cNota
				EndIf
			Else
				cMsg := "N�o h� XML gerado para essa NFe " + cNota
			EndIf	
		Else
			cMsg := "O response do TSS retornou em branco, favor verificar" + cUrl
		EndIf
	Else
		cMsg := "O TSS retornou no response do XML uma mensagem de erro"
	EndIf
Else
	cMsg := "O TSS fora do ar" + cUrl
EndIf	
			
//Grava log Transacao 
u_N6GEN002("SPED","R","SPEDTSS","TSS","Totvs",cNota,IIF(!empty(cNFe),cNFe,sPostRet),IIF(!empty(cNFe),"XML NFe gerado com sucesso!",cMsg))
			
Return cNFe

//-------------------------------------------------------
//Static function para verificar se usa o 
//Totvs Colabora��o
//-------------------------------------------------------
*-------------------------------------*
Static function UsaColaboracao(cModelo)
*-------------------------------------*
Local lUsa := .F.

If FindFunction("ColUsaColab")
	lUsa := ColUsaColab(cModelo)
EndIf
Return (lUsa)

//-------------------------------------------------------
//Static function para verificar o ID da entidade
//-------------------------------------------------------
*---------------------------------*
Static Function GetIdEnt(lUsaColab)
*---------------------------------*
Local cIdEnt := ""
Local cError := ""

Default lUsaColab := .F.

If !lUsaColab
	cIdEnt := getCfgEntidade(@cError)
	If(empty(cIdEnt))
		conout(cError)
	EndIf	

Else
	If !( ColCheckUpd() )
		conout("SPED","UPDATE do TOTVS Colabora��o 3.0 n�o aplicado. Desativado o uso do TOTVS Colabora��o 3.0")	
	Else
		cIdEnt := "000000"
	EndIf	 
EndIf	

Return(cIdEnt)