//--------------------------------------------------------------------------------------------------------------------------------------------//
// Wederson L. Santana - HLB - 07/08/2020
//--------------------------------------------------------------------------------------------------------------------------------------------//
// Específico Shiseido                                                                                                                        //
// Faturamento                                                                                                                                //
//--------------------------------------------------------------------------------------------------------------------------------------------//
// Envio de documentos para o operador logístico - WS.                                                                                 //
//--------------------------------------------------------------------------------------------------------------------------------------------//

#include 'totvs.ch'
#include 'apwebsrv.ch'
#include 'tbiconn.ch'
#include "topconn.ch"
#INCLUDE "PROTHEUS.CH"

User Function FISENVNFE()
Local cSoapEnv := ""
Local cXmlNfe  := ""
Local aNFeId   := aClone(PARAMIXB[1])
Local cTransp  := ""
Local cCabArq  := "XML"
Local nConTss
Local aArea
Local nX
Local cTssNom  := SuperGetMV("MV_XXTSSNM", .F.,"MSSQL7/TSS_HOM")
Local cTssLoc  := SuperGetMV("MV_XXTSSLC", .F.,"srvdchomapp01.zion.lan")
Local cTssPor  := SuperGetMV("MV_XXTSSPR", .F.,7895)
Local nRecno   := 0
Local cIdEnt   := ""

Private cR7Pedido := ""

If cEmpAnt == "R7"
   
   For nX:=1 To Len(aNFeId) 
       conout("Início transmissão NFe: "+aNFeId[nX])

       If Select("TRB_TSS1") <> 0
	      TRB_TSS1->(DbCloseArea())
       EndIf     
       If Select("TRB_TSS2") <> 0
	      TRB_TSS2->(DbCloseArea())
       EndIf     
              
       //nRecno:=fConsulta(aNFeId[nX],AllTrim(SM0->M0_CGC))

      //If nRecno>0
         SF2->(dbSetOrder(1))
         If SF2->(dbSeek(xFilial("SF2")+SubStr(aNFeId[nX],4,9)+SubStr(aNFeId[nX],1,3)))
            cTransp:= SF2->F2_TRANSP
   
            SD2->(dbSetOrder(3))
            If SD2->(dbSeek(xFilial("SD2")+SubStr(aNFeId[nX],4,9)+SubStr(aNFeId[nX],1,3)))
               cR7Pedido := SD2->D2_PEDIDO
            EndIf

            aArea := GetArea()  
            nConTss := TcLink( cTssNom,cTssLoc,cTssPor )
            If nConTss # 0
               dbUseArea( .T., "TOPCONN", "SPED001", "TRB_TSS1", .T., .T. )
               dbSelectArea("TRB_TSS1")
               While !Eof()
                  If AllTrim(TRB_TSS1->CNPJ) == AllTrim(SM0->M0_CGC)
                     cIdEnt:= TRB_TSS1->ID_ENT
                  EndIf
                  dbSkip()
               End

               dbUseArea( .T., "TOPCONN", "SPED050", "TRB_TSS2", .T., .F. )
               If! TCCanOpen( "SPED050", "SPED05001" )
                  // dbCreateIndex("SPED050Z", "ID_ENT+NFE_ID+DOC_CHV"  , {|| ID_ENT+NFE_ID+DOC_CHV   })
               EndIf
               dbClearind()
		         dbSetIndex("SPED05001)
               
               dbSelectArea("TRB_TSS2")
               If dbSeek(cIdEnt+aNFeId[nX])
                  cXmlNfe := TRB_TSS2->XML_SIG
                  cChave  := Alltrim(TRB_TSS2->DOC_CHV) 
               EndIf
               
            EndIf
            TCunLink(nConTss)
            RestArea(aArea)
           
            cNf     := SF2->F2_DOC  
            cCabArq += cR7Pedido
      
            SA4->(dbSetOrder(1))
            SA4->(dbSeek(xFilial("SA4")+cTransp))

            cSoapEnv:='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:shis="http://eai/Shiseido/">'
            cSoapEnv+='<soapenv:Header/>'
            cSoapEnv+='<soapenv:Body>'
            cSoapEnv+='<shis:setRecebeNFe>'
            cSoapEnv+='<NFE>'
            cSoapEnv+='<nrPedido>'+cR7Pedido+'</nrPedido>'
            cSoapEnv+='<nrNotaFiscal>'+cNf+'</nrNotaFiscal>'
            cSoapEnv+='<cnpjTransportador>'+SA4->A4_CGC+'</cnpjTransportador>'
            cSoapEnv+='<nomeTransportador>'+AllTrim(SA4->A4_NOME)+'</nomeTransportador>'
            cSoapEnv+='<chaveNFe>'+cChave+'</chaveNFe>'
            cSoapEnv+='<xmlNFe>'+cXmlNFe+'</xmlNFe>'
            cSoapEnv+='</NFE>'
            cSoapEnv+='</shis:setRecebeNFe>'
            cSoapEnv+='</soapenv:Body>'
            cSoapEnv+='</soapenv:Envelope>'
         
            If! Empty(cXmlNFe)
               fPostWs(cSoapEnv,cCabArq)
            Else  
               conout(cR7Pedido+"-Chave:"+cChave+"- confirme Sefaz.")
	            fGeraLog(cCabArq,cR7Pedido+"-Chave:"+cChave+"- confirme Sefaz.","1") 
            EndIf 

         Else
            fGeraLog(cCabArq,"Verifique transmissão NFe do pedido.","1")
         EndIf
      //Else
      //    fGeraLog(cCabArq,"Verifique transmissão do documento.","1")
      //EndIf

      If Select("TRB_TSS") <> 0
	      TRB_TSS->(DbCloseArea())
      EndIf     
                
      conout("Fim transmissão NFe: "+aNFeId[nX])
   Next
EndIf 
 
Return()

//-----------------------------------

Static Function fPostWs(cSoapEnv,cCabArq)
Local cURL := "https://dtceai03.id-logistics.com.br/wsShiseido/wsShiseido.php?wsdl"
Local cPostRet := ""
Local XMLHeadRet := ""
Local nPosCType := 0
Local	nPosCTEnd := 0
Local cHeaderRet:= ""
Local lRet := .T.

Private cSoapAction :=""

cPostRet := HTTPGet(cURL)
 
If cPostRet == NIL
	conout("WSCERR044 / Não foi possível POST : URL " + cURL)
	fGeraLog(cCabArq,"WSCERR044 / Não foi possível POST","1")
ElseIf Empty(cPostRet)
	If !Empty(XMLHeadRet)
		conout("WSCERR045 / Retorno Vazio de POST : URL "+cURL+' ['+XMLHeadRet+']')
      fGeraLog(cCabArq,"WSCERR045 / Retorno Vazio de POST XMLHeadRet","1")
		lRet:= .F.
	Else
		//Wserrolog("WSCERR045 / Retorno Vazio de POST : URL "+cURL)
      fGeraLog(cCabArq,"WSCERR045 / Retorno Vazio de POST","1")
		lRet:= .F.
	EndIf
EndIf

// --------------------------------------------------------
// Antes de Mandar o XML para o PArser , Verifica se o Content-Type é XML !
// --------------------------------------------------------
If lRet
  If !Empty(XMLHeadRet)
	  cHeaderRet := XMLHeadRet
	  nPosCType  := at("CONTENT-TYPE:",Upper(cHeaderRet))
	  If nPosCType > 0
		  cHeaderRet := Substr(cHeaderRet,nPosCType)
		  nPosCTEnd := at(CHR(13)+CHR(10) , cHeaderRet)
		  cHeaderRet := Substr(cHeaderRet,1,IIF(nPosCTEnd > 0 ,nPosCTEnd-1, NIL ) )
		  If !"XML"$upper(cHeaderRet)
			   conout("WSCERR064 / Invalid Content-Type return ("+cHeaderRet+") from "+cURL+CHR(13)+CHR(10)+;
						" HEADER:["+XMLHeadRet+"] POST-RETURN:["+XMLPostRet+"]")
			    lRet:= .F.
             fGeraLog(cCabArq,"WSCERR064 / Invalid Content-Type return","1")
		  EndIf
	  Else
		  conout("WSCERR065 / EMPTY Content-Type return ("+cHeaderRet+") from "+cURL+CHR(13)+CHR(10)+;
			  			" HEADER:["+XMLHeadRet+"] POST-RETURN:["+XMLPostRet+"]")
        fGeraLog(cCabArq,"WSCERR065 / EMPTY Content-Type return","1")            
		  lRet:= .F.
	  EndIf
  EndIf

  If lRet
     fSoapCall(cUrl,cSoapEnv,cSoapAction,cCabArq)
  Else
       MsgInfo("Atenção erro ao iniciar a transmissão.","Integração com operador logístico.")
       fGeraLog(cCabArq,"Atenção erro ao iniciar a transmissão.","1")      
  EndIf   

Else
   MsgInfo("Atenção erro ao realizar a conexão.","Integração com operador logístico.")
   fGeraLog(cCabArq,"Atenção erro ao realizar a conexão.","1") 
EndIf
Return

//-------------------------------

Static Function fSoapCall(cUrl, cSoapSend, cSoapAction,cCabArq)
// variaveis para o request e reponse do post
Local XMLPostRet := ""
Local nTimeOut	:= 120
Local aHeadOut	:= {}
Local XMLHeadRet := ""
// variaveis para checar o header response
Local cHeaderRet := ""
Local nPosCType := 0
Local nPosCTEnd := 0
// variaveis para o parser XML
Local oXmlRet := NIL
Local cError := ""
Local cWarning := ""
// variaveis para retirar ENVELOPE e BODY
Local cEnvSoap := ""
Local cEnvBody := ""
Local cSoapPrefix := ""
// variaveis para determinar soapfault
Local cFaultString := ""
Local cFaultCode := ""
Local lRet := .T.

// Adiciona informaçoes no header HTTP
aadd(aHeadOut,'SOAPAction: '+cSoapAction)
aadd(aHeadOut,'Content-Type: text/xml; charset=utf-8' )
// Acrescenta o UserAgent na requisição ...
aadd(aHeadOut,'User-Agent: Mozilla/4.0 (compatible; Protheus '+GetBuild()+')')

// REALIZANDO O POST
XMLPostRet := HttpPost(cUrl,"",cSoapSend,nTimeOut,aHeadOut,@XMLHeadRet)

// Verifica Retorno
If XMLPostRet == NIL
	conout("WSCERR044 / Não foi possível POST : URL " + cURL)
   fGeraLog(cCabArq,"WSCERR044 / Não foi possível POST : URL ","1") 
	lRet:= .F.
ElseIf Empty(XMLPostRet)
	If !Empty(XMLHeadRet)
		conout("WSCERR045 / Retorno Vazio de POST : URL "+cURL+' ['+XMLHeadRet+']')
      fGeraLog(cCabArq,"WSCERR045 / Retorno Vazio de POST : XMLHeadRet ","1")
		lRet:= .F.
	Else
		conout("WSCERR045 / Retorno Vazio de POST : URL "+cURL)
		fGeraLog(cCabArq,"WSCERR045 / Retorno Vazio de POST ","1")
		lRet:= .F.
	EndIf
EndIf

If !Empty(XMLHeadRet)
   conout(padc(" POST RETURN ",79,'='))
	 conout(XMLHeadRet)
	 conout(replicate('-',79))
EndIf

If lRet
   If UPPER(SubStr(xmlHeadRet,1,15)) == "HTTP/1.1 200 OK"
      //MsgInfo("Dados transmitidos com sucesso","Integração com operador logístico")
      fGeraLog(cCabArq,"XML transmitido com sucesso.","3")		
   Else
      //MsgInfo("Dados não transmitidos.","Integração com operador logístico")
      fGeraLog(cCabArq,"XML não transmitido.","1")		
   EndIf    
EndIf

conout(XMLPostRet)
conout(replicate('=',79))

Return

//-----------------------------------

Static Function fGeraLog(cChaveArq,cMensagem,cStatus)
Local aArea := GetArea()

Reclock("Z0G",.T.)
Z0G->Z0G_FILIAL := xFilial("Z0G")
Z0G->Z0G_PEDIDO := cR7Pedido
Z0G->Z0G_DATA   := dDataBase
Z0G->Z0G_HORA   := Time()
Z0G->Z0G_USER   := CUSERNAME
Z0G->Z0G_TABELA := "XML"
Z0G->Z0G_CHAVE  := cChaveArq
Z0G->Z0G_PROCES := "XML NFE"
Z0G->Z0G_STATUS := cStatus
Z0G->Z0G_MENSAG := cMensagem
Z0G->Z0G_ARQUIV := cChaveArq+".xml"
MsUnlock()

RestArea(aArea)
Return

//-----------------------------

Static Function fConsulta(cNota,cCNPJ)       
Local nRetorno:=0
Local cAlias := "TMP"

cQry := " SELECT T1.R_E_C_N_O_ "
cQry += " From TSS_HOM.dbo.SPED050 T1 , TSS_HOM.dbo.SPED001 T2"
cQry += " WHERE T1.NFE_ID = '"+cNota+"' AND T1.STATUS = '6' "
cQry += " AND T1.ID_ENT = T2.ID_ENT "
cQry += " AND T2.CNPJ = '"+AllTrim(cCNPJ)+"'"
  
dbUseArea(.F.,"TOPCONN",TCGENQRY(,,cQry),"TMP",.F.,.T.)

dbSelectArea("TMP")
nRetorno:= TMP->R_E_C_N_O_

DBCloseArea()
  

Return(nRetorno)	
