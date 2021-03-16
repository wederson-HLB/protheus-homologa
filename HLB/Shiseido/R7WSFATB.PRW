//--------------------------------------------------------------------------------------------------------------------------------------------//
// Wederson L. Santana - HLB - 07/08/2020
//--------------------------------------------------------------------------------------------------------------------------------------------//
// Específico Shiseido                                                                                                                        //
// Faturamento                                                                                                                                 //
//--------------------------------------------------------------------------------------------------------------------------------------------//
// Envio de documentos para o operador logístico - SFTP e WS.                                                                                 //
//--------------------------------------------------------------------------------------------------------------------------------------------//

#include 'totvs.ch'
#include 'apwebsrv.ch'
#include 'tbiconn.ch'
#include "topconn.ch"
#include 'protheus.ch' 
#Include "rwmake.ch" 

#DEFINE ENTER CHR(13)+CHR(10)

User Function R7WSFATB()
Local aCampos  := {} 
Local aBotoes	:= {} 

Private oLista           
Private aCabecalho := {} 
Private aColsEx 	 := {} 
Private nOpcao
Private oVerde  	:= LoadBitmap( GetResources(), "BR_VERDE")
Private oVermelho	:= LoadBitmap( GetResources(), "BR_VERMELHO")
Private oAmarelo	:= LoadBitmap( GetResources(), "BR_AMARELO")

DEFINE MSDIALOG oDlg TITLE "Transmissão documentos para o operador logístico" FROM 000, 000  TO 400, 950  PIXEL
	
fCriaCab()

oLista := MsNewGetDados():New( 103, 108, 550, 850, GD_INSERT+GD_DELETE+GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "AllwaysTrue", aCampos,1, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aCabecalho, aColsEx)

fCarga()

oLista:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

oLista:oBrowse:SetFocus()

aadd(aBotoes,{"NG_ICO_LEGENDA", {||Legenda()} ,"Legenda","Legenda"})
aadd(aBotoes,{"NG_ICO_LEGENDA", {||fSendDoc()},"Transmitir","Transmitir"})

EnchoiceBar(oDlg, {|| oDlg:End() }, {|| oDlg:End() },,aBotoes)

ACTIVATE MSDIALOG oDlg CENTERED

Return

//--------------------------------------------------------

Static Function fCriaCab()

 Aadd(aCabecalho, {;
                  "",;//X3Titulo()
                  "IMAGEM",;  //X3_CAMPO
                  "@BMP",;		//X3_PICTURE
                  3,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  ".F.",;			//X3_VALID
                  "",;			//X3_USADO
                  "C",;			//X3_TIPO
                  "",; 			//X3_F3
                  "V",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  "",;			//X3_WHEN
                  "V"})			//
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("Z0G")
While! Eof() .And. SX3->X3_ARQUIVO == "Z0G"
    If! Alltrim(SX3->X3_CAMPO) $ "Z0G_STATUS/Z0G_FILIAL/Z0G_CHAVE"
        Aadd(aCabecalho, {X3Titulo(),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,X3_VALID,X3_USADO,X3_TIPO,X3_F3,X3_CONTEXT,X3_CBOX,X3_RELACAO,X3_WHEN})			
    EndIf
    dbSkip()            
End 
Return

//--------------------------------------------------------

Static Function fCarga()
Local nCont  
Local nLinha  
aColsEx := {} 

dbSelectArea("Z0G")
dbSetOrder(4)
If dbSeek(xFilial("Z0G")+SC5->C5_NUM)

   While !Eof().And. Z0G->Z0G_PEDIDO == SC5->C5_NUM 
         aAdd(aColsEx, Array(Len(aCabecalho)+1))
         nLinha := Len(aColsEx)         

         For nCont:=1 To Len(aCabecalho)
             If aCabecalho[nCont][2] == "IMAGEM"
                aColsEx[nLinha,1]:= Iif(Z0G->Z0G_STATUS=="1",oVermelho,Iif(Z0G->Z0G_STATUS=="2",oAmarelo,oVerde))  
             Else
                aColsEx[nLinha,nCont] := Z0G->&(aCabecalho[nCont][2])
             EndIf
         Next

         aColsEx[nLinha,Len(aCabecalho)+1] := .F.
         dbSkip()
   End
EndIf

oLista:SetArray(aColsEx,.T.)

oLista:Refresh()
Return

//------------------------------------------------------

Static Function fCargaLot(cSerie,cDocDe,cDocAte,dEmissDe,dEmissAte)
Local nCont  
Local nLinha  
aColsEx := {} 

dbSelectArea("SQL")
dbGotop()
While! EOF()

   dbSelectArea("Z0G")
   dbSetOrder(4)
   If dbSeek(xFilial("Z0G")+SQL->C5_NUM)

      While !Eof().And. Z0G->Z0G_PEDIDO <= SQL->C5_NUM
            aAdd(aColsEx, Array(Len(aCabecalho)+1))
            nLinha := Len(aColsEx)         

            For nCont:=1 To Len(aCabecalho)
               If aCabecalho[nCont][2] == "IMAGEM"
                   aColsEx[nLinha,1]:= Iif(Z0G->Z0G_STATUS=="1",oVermelho,Iif(Z0G->Z0G_STATUS=="2",oAmarelo,oVerde))  
               Else
                   aColsEx[nLinha,nCont] := Z0G->&(aCabecalho[nCont][2])
               EndIf
            Next

            aColsEx[nLinha,Len(aCabecalho)+1] := .F.
            dbSelectArea("Z0G")
            dbSkip()
      End
   EndIf
   dbSelectArea("SQL")
   dbSkip() 
End
oLista:SetArray(aColsEx,.T.)

oLista:Refresh()
If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

Return

//-------------------------------------------------------

Static function Legenda()
Local aLegenda := {}

AADD(aLegenda,{"BR_VERMELHO" 	,"Não enviado" })
AADD(aLegenda,{"BR_AMARELO"   ,"Aguardando transmissão" })
AADD(aLegenda,{"BR_VERDE"    	,"Transmitido com sucesso" })

BrwLegenda("Legenda", "Legenda", aLegenda)
Return Nil

//--------------------------------------------------------

Static Function fSendDoc()
Local aItens  := {}
Local cOpc    := ""
Local nItens
Private nOpcao

aAdd(aItens , "1=[Transmissão XML (em lote)] ")
aAdd(aItens , "2=[Transmitir CANCELAMENTO] ")
aAdd(aItens , "B=[Boleto] ")
aAdd(aItens , "G=[Guia] ")
aAdd(aItens , "C=[Comprovante] ")

DEFINE 	MSDIALOG oSftp FROM  1,1 TO 150,350	TITLE "Selecione o documento para transmissão" PIXEL 
	
@ 20, 10	MSCOMBOBOX oCores VAR cOpc ITEMS aItens SIZE 100,10	PIXEL	Valid If(nOpcao = 1, 0, 1)
	
DEFINE 	SBUTTON oBtnOk FROM 20,130 TYPE 1 ENABLE OF oSftp Action (nOpc:=1, fOkProc(cOpc) )
DEFINE 	SBUTTON oBtnCn FROM 40,130 TYPE 2 ENABLE OF oSftp Action (nOpc:=0,oSftp:End())
ACTIVATE MSDIALOG oSftp Centered

Return

//-------------------------------------------

Static Function fOkProc(cOpc)
Local cPerg:= "R7WSFATB"+Space(02)
If nOpc ==1
   Do Case 
      Case cOpc == '1'
           fCriaPerg(cPerg)
           If Pergunte(cPerg,.T.)
               R7WSFAT1(cOpc,Mv_Par01,Mv_Par02,Mv_Par03,Mv_par04,Mv_Par05)
               fCargaLot(Mv_Par01,Mv_Par02,Mv_Par03,Mv_par04,Mv_Par05)
           EndIf
      Case cOpc == '2'
           MsgInfo("Aguardando liberação pela IDL.","A t e n ç ã o")
           // Aguardando recepação pela IDL.
           //R7WSFAT2(cOpc)
           //fCarga()
      Case cOpc $ 'B/G/C'
           R7WSFAT3(cOpc)
           fCarga()
   EndCase    
EndIf
Return

//----------------------------------

Static Function R7WSFAT1(cOpc,cSerie,cDocDe,cDocAte,dEmissDe,dEmissAte)
Local cSoapEnv := ""
Local cXmlNfe  := ""
Local cPedido  := ""
Local cTransp  := ""
Local nConTss
Local aArea
Local cTssNom  := SuperGetMV("MV_XXTSSNM", .F.,"MSSQL7/TSS_02")
Local cTssLoc  := SuperGetMV("MV_XXTSSLC", .F.,"172.16.16.56")
Local nTssPor  := SuperGetMV("MV_XXTSSPR", .F.,7892)
Private nSendOk := 0
Private nSendEr := 0

If cEmpAnt == "R7"

   MontaQuery(cSerie,cDocDe,cDocAte,dEmissDe,dEmissAte)   

   dbSelectArea("SQL")
   dbGotop()
   While! EOF()
  
         conout("Início transmissão PV: "+SQL->C5_NUM)

         SD2->(dbSetOrder(8))
         If SD2->(dbSeek(xFilial("SD2")+SQL->C5_NUM))

            SF2->(dbSetOrder(1))
            If SF2->(dbSeek(xFilial("SF2")+SD2->D2_DOC+SD2->D2_SERIE))
               cTransp:= SF2->F2_TRANSP
            EndIf
 
            //--- ACESSO BANCO TSS - INÍCIO
            aArea := GetArea()  
            nConTss := TcLink( cTssNom,cTssLoc,nTssPor )

            If Select("TMP") <> 0
	            TMP->(DbCloseArea())
            EndIf     

            If Select("TRB_TS0") <> 0
	            TRB_TS0->(DbCloseArea())
            EndIf

            If Select("TRB_TS4") <> 0
	            TRB_TS4->(DbCloseArea())
            EndIf

            cQry := " SELECT T2.DOC_CHV,T2.R_E_C_N_O_ AS R_E_C050 ,T3.R_E_C_N_O_ AS R_E_C054"
            cQry += " From TSS_02.dbo.SPED001 T1 , TSS_02.dbo.SPED050 T2,TSS_02.dbo.SPED054 T3"
            cQry += " WHERE T1.CNPJ = '"+AllTrim(SM0->M0_CGC)+"'"
            cQry += " AND T1.ID_ENT = T2.ID_ENT "
            cQry += " AND T2.NFE_ID = '"+SD2->D2_SERIE+SD2->D2_DOC+"' AND T2.STATUS = '6' "
            cQry += " AND T2.ID_ENT = T3.ID_ENT "
            cQry += " AND T3.NFE_ID = '"+SD2->D2_SERIE+SD2->D2_DOC+"' AND T3.CSTAT_SEFR = '100'  "
              
            dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),"TMP",.F.,.F.)

            cPedido := SQL->C5_NUM
            cChave  := TMP->DOC_CHV 
            cNF     := SF2->F2_DOC  
            
            cXmlNfe :='<nfeProc xmlns="http://www.portalfiscal.inf.br/nfe" versao="4.00">'
            
            If nConTss # 0
               dbUseArea( .T., "TOPCONN", "SPED050", "TRB_TS0", .T., .T. )

               dbSelectAre("TRB_TS0")
               dbGoto(TMP->R_E_C050)
               If! Empty(TRB_TS0->XML_SIG) 
                   cXmlNfe += TRB_TS0->XML_SIG
                   
                   dbUseArea( .T., "TOPCONN", "SPED054", "TRB_TS4", .T., .T. )

                   dbSelectAre("TRB_TS4")
                   dbGoto(TMP->R_E_C054)
                   If! Empty(TRB_TS4->XML_PROT) 
                       cXmlNfe += TRB_TS4->XML_PROT

                   EndIf
               EndIf        

            EndIf

            cXmlNfe +='</nfeProc>'

            TCunLink(nConTss)
            aArea := RestArea(aArea)
            //--- ACESSO BANCO TSS - FIM

            SA4->(dbSetOrder(1))
            SA4->(dbSeek(xFilial("SA4")+cTransp))

            cSoapEnv:='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:shis="http://eai/Shiseido/">'
            cSoapEnv+='<soapenv:Header/>'
            cSoapEnv+='<soapenv:Body>'
            cSoapEnv+='<shis:setRecebeNFe>'
            cSoapEnv+='<NFE>'
            cSoapEnv+='<nrPedido>'+cPedido+'</nrPedido>'
            cSoapEnv+='<nrNotaFiscal>'+cNf+'</nrNotaFiscal>'
            cSoapEnv+='<cnpjTransportador>'+SA4->A4_CGC+'</cnpjTransportador>'
            cSoapEnv+='<nomeTransportador>'+AllTrim(SA4->A4_NOME)+'</nomeTransportador>'
            cSoapEnv+='<chaveNFe>'+cChave+'</chaveNFe>'
            cSoapEnv+='<xmlNFe>'+cXmlNFe+'</xmlNFe>'
            cSoapEnv+='</NFE>'
            cSoapEnv+='</shis:setRecebeNFe>'
            cSoapEnv+='</soapenv:Body>'
            cSoapEnv+='</soapenv:Envelope>'

            fPostWs(cSoapEnv,cOpc)

            If Select("TMP") <> 0
	            TMP->(DbCloseArea())
            EndIf     
         Else
            MsgInfo("Faturamento não encontrado para o pedido: "+SQL->C5_NUM+".","Integração com operador logístico.")
            conout("Faturamento não encontrado para o pedido: "+SQL->C5_NUM+".")
         EndIf
         conout("Fim transmissão PV: "+SQL->C5_NUM)

         dbSelectArea("SQL")
         dbSkip()
   End

   If nSendOk>0

      MsgInfo("Documentos transmitidos com sucesso: "+Transform(nSendOk,"@E 999,999"),"Integração com operador logístico")

   Else   

       MsgInfo("Documento(s) não encontrado(s) e/ou não integrado(s).","Integração com operador logístico")

   EndIf

   If nSendEr>0
   
      MsgInfo("Verifique os dados obrigatórios para o envio.","Integração com operador logístico")

   EndIf

EndIf 
 
Return()

//--------------------------------------

Static Function R7WSFAT2(cOpc)
Local cSoapEnv := ""
Local cXmlNfe  := ""
Local cPedido  := ""
Local cTransp  := ""
Local nConTss
Local aArea
Local cTssNom  := SuperGetMV("MV_XXTSSNM", .F.,"MSSQL7/TSS_HOM")
Local cTssLoc  := SuperGetMV("MV_XXTSSLC", .F.,"srvdchomapp01.zion.lan")
Local cTssPor  := SuperGetMV("MV_XXTSSPR", .F.,7895)
Local cURLSoap := SuperGetMV("MV_XXURLSP", .F.,"http://schemas.xmlsoap.org/soap/envelope/")
Local cURLEai  := SuperGetMV("MV_XXURLEI", .F.,"http://eai/Shiseido/")

If cEmpAnt == "R7"
   conout("Início transmissão CANCELAMENTO PV: "+SC5->C5_NUM)

   If Select("TMPSD2") <> 0
	   TMPSD2->(DbCloseArea())
   EndIf     
   If Select("TMP") <> 0
	   TMP->(DbCloseArea())
   EndIf     

   cQry := " SELECT TOP 1 D2_SERIE,D2_DOC,F2_TRANSP"
   cQry += " From "+RetSqlName("SD2")+" SD2 "
   cQry +=  ","+RetSqlName("SF2")+" SF2 "
   cQry += " WHERE D2_PEDIDO = '"+SC5->C5_NUM+"' "
   cQry += " AND SD2.D_E_L_E_T_ = '*' "
   cQry += " AND SF2.D_E_L_E_T_ = '*' "
   cQry += " AND SD2.D2_FILIAL = SF2.F2_FILIAL "
   cQry += " AND SD2.D2_DOC = SF2.F2_DOC "
   cQry += " AND SD2.D2_SERIE = SF2.F2_SERIE "
   
   DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),"TMPSD2",.F.,.F.)

   cQry := " SELECT T1.DOC_CHV,T1.R_E_C_N_O_ "
   cQry += " From TSS_HOM.dbo.SPED050 T1 , TSS_HOM.dbo.SPED001 T2"
   cQry += " WHERE T1.NFE_ID = '"+TMPSD2->D2_SERIE+TMPSD2->D2_DOC+"' AND T1.STATUS = '7' "
   cQry += " AND T1.ID_ENT = T2.ID_ENT "
   cQry += " AND T2.CNPJ = '"+AllTrim(SM0->M0_CGC)+"'"

   DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),"TMP",.F.,.F.)

   cPedido := SC5->C5_NUM
   cChave  := Alltrim(TMP->DOC_CHV) 
   cNF     := TMPSD2->D2_DOC  

   aArea := GetArea()  
   nConTss := TcLink( cTssNom,cTssLoc,cTssPor )

   If nConTss # 0
      dbUseArea( .T., "TOPCONN", "SPED050", "TRB_TSS", .T., .T. )
      TRB_TSS->(dbGoto(TMP->R_E_C_N_O_))
      cXmlNfe := TRB_TSS->XML_SIGCAN
   EndIf
   TCunLink(nConTss)
   aArea := RestArea(aArea)
   
   SA4->(dbSetOrder(1))
   SA4->(dbSeek(xFilial("SA4")+TMPSD2->F2_TRANSP))

   cSoapEnv:='<soapenv:Envelope xmlns:soapenv="'+AllTrim(cURLSoap)+'" xmlns:shis="'+Alltrim(cURLEai)+'">'
   cSoapEnv+='<soapenv:Header/>'
   cSoapEnv+='<soapenv:Body>'
   cSoapEnv+='<shis:setRecebeNFe>'
   cSoapEnv+='<NFE>'
   cSoapEnv+='<nrPedido>'+cPedido+'</nrPedido>'
   cSoapEnv+='<nrNotaFiscal>'+cNf+'</nrNotaFiscal>'
   cSoapEnv+='<cnpjTransportador>'+SA4->A4_CGC+'</cnpjTransportador>'
   cSoapEnv+='<nomeTransportador>'+AllTrim(SA4->A4_NOME)+'</nomeTransportador>'
   cSoapEnv+='<chaveNFe>'+cChave+'</chaveNFe>'
   cSoapEnv+='<xmlNFe>'+cXmlNFe+'</xmlNFe>'
   cSoapEnv+='</NFE>'
   cSoapEnv+='</shis:setRecebeNFe>'
   cSoapEnv+='</soapenv:Body>'
   cSoapEnv+='</soapenv:Envelope>'

   fPostWs(cSoapEnv,cOpc)

   If Select("TMP") <> 0
	   TMP->(DbCloseArea())
   EndIf     
   If Select("TMPSD2") <> 0
	   TMPSD2->(DbCloseArea())
   EndIf     
      
   conout("Fim transmissão CANCELAMENTO PV: "+SC5->C5_NUM)
EndIf 
 
Return()

//--------------------------------------

Static function fPostWs(cSoapEnv,cOpc)
Local cURL  := SuperGetMV("MV_XXURLWS", .F.,"https://dtceai03.id-logistics.com.br/wsShiseido/wsShiseido.php?wsdl")
//Local cURL := "https://dtceai03.id-logistics.com.br/wsShiseido/wsShiseido.php?wsdl"
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
	lRet := .F.
ElseIf Empty(cPostRet)
	If !Empty(XMLHeadRet)
		conout("WSCERR045 / Retorno Vazio de POST : URL "+cURL+' ['+XMLHeadRet+']')
		lRet := .F.
	Else
		conout("WSCERR045 / Retorno Vazio de POST : URL "+cURL)
		lRet := .F.
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
			   lRet := .F.
		   EndIf
	   Else
		   conout("WSCERR065 / EMPTY Content-Type return ("+cHeaderRet+") from "+cURL+CHR(13)+CHR(10)+;
						" HEADER:["+XMLHeadRet+"] POST-RETURN:["+XMLPostRet+"]")
		   lRet := .F.
	   EndIf
   EndIf

   If lRet
      fSoapCall(cUrl,cSoapEnv,cSoapAction,cOpc)
   Else
       MsgInfo("Atenção erro ao iniciar a transmissão.","Integração com operador logístico.")   
   EndIf

Else
    MsgInfo("Atenção erro ao realizar a conexão."+Chr(13)+Chr(10)+"Verifique a conexão com a internet ou tente mais tarde.","Integração com operador logístico.")   
EndIf

Return

//-------------------------------

Static Function fSoapCall(cUrl, cSoapSend, cSoapAction,cOpc)
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
	lRet:= .F.
ElseIf Empty(XMLPostRet)
	If !Empty(XMLHeadRet)
		conout("WSCERR045 / Retorno Vazio de POST : URL "+cURL+' ['+XMLHeadRet+']')
		lRet:= .F.
	Else
		conout("WSCERR045 / Retorno Vazio de POST : URL "+cURL)
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
      nSendOk ++
      fGeraLog(cOpc,Iif(cOpc=="1","XML retransmitido com sucesso.","XML cancelamento enviado com sucesso."),"XML"+SQL->C5_NUM+".xml",'','3',SQL->C5_NUM)
   Else
      //MsgInfo("Verifique os dados obrigatórios para o envio."+Chr(13)+Chr(10)+SubStr(xmlHeadRet,1,15),"Integração com operador logístico")
      nSendEr ++
      fGeraLog(cOpc,Iif(cOpc=="1","XML não transmitido.","XML cancelamento não transmitido."),"XML"+SQL->C5_NUM+".xml",'','1',SQL->C5_NUM)
   EndIf    
EndIf

Return

//----------------------------------

Static Function R7WSFAT3(cTipo) 
 Local cMascara  := "*.pdf|*.pdf"
 Local cTitulo   := "Escolha o arquivo"
 Local nMascpad  := 0
 Local cDirini   := "c:\"
 Local lSalvar   := .F. /*.T. = Salva || .F. = Abre*/
 Local nOpcoes   := GETF_LOCALHARD // GETF_RETDIRECTORY
 Local lArvore   := .F. /*.T. = apresenta o árvore do servidor || .F. = não apresenta*/
 Local cDirLoc   := ""
 Local cDirSrv   := "\ftpIDL\"+Iif(cTipo=="B","BOL",Iif(cTipo=="G","GUI","COM"))+SC5->C5_NUM+".pdf"
 
cDirLoc := cGetFile( cMascara, cTitulo, nMascpad, cDirIni, lSalvar, nOpcoes, lArvore)

If! Empty(cDirLoc) 
   If __CopyFile( cDirLoc, cDirSrv )
      fGeraLog(cTipo,"Arquivo enviado ao servidor",cDirSrv,cDirLoc,'2',SC5->C5_NUM)
      R7WSFAT4(cTipo,cDirLoc)
   Else
      MsgInfo("Erro ao copiar o arquivo !")
      fGeraLog(cTipo,"Erro ao enviar arquivo ao servidor",cDirSrv,cDirLoc,'1',SC5->C5_NUM)
   EndIf    
EndIf
Return

//---------------------------------

Static Function R7WSFAT4(cTipo,cDirLoc) 
Local cRootPath := GetSrvProfString("RootPath", "\undefined")   											   
Local cINTBOLn  := Iif(cTipo == "B",'/boleto/',Iif(cTipo == "G",'/gnre/','/pgnre/'))
Local cLocArq   := '\FtpIDL\'
Local cLocRet   := '\FtpIDL\'                                                                          
Local cLocLogs  := '\FtpIDL\logs\'
Local cLocLgEr  := '\FtpIDL\logs\erro\'
Local nR        := 0  
Local cArq
Local nCont     := 0

Private lRet

If !ExistDir('\FtpIDL\')
	MakeDir('\FtpIDL\')
EndIf
	
If !ExistDir(cLocArq)
	MakeDir(cLocArq)
EndIf 

If !ExistDir(cLocRet)
	MakeDir(cLocRet)
Endif                                                                                                                                        

If !ExistDir(cLocLogs)
   MakeDir(cLocLogs)
EndIf
    
If !ExistDir(cLocLgEr)
   MakeDir(cLocLgEr)
EndIf

aFileRet := {}
aDir(cLocRet+"*.pdf",aFileRet,,,,,.F.) //Carrega os arquivos encriptados na pasta retorno 
cArq := ''

If Len(aFileRet) > 0
   For nR := 1 To Len(aFileRet)
      cArq := aFileRet[nR]
      UplSFTP('PUT',cArq,cLocRet,cINTBOLn,cLocLogs,cLocLgEr)  //Envia os arquivos para a pasta no SFTP. 
      If lRet
         fGeraLog(cTipo,"Arquivo enviado com sucesso.",cLocRet+cArq,cDirLoc,'3',SC5->C5_NUM)
         fErase(cLocRet+cArq)
         nCont ++
      Else   
         fGeraLog(cTipo,"Arquivo não enviado.",cLocRet+cArq,cDirLoc,'1',SC5->C5_NUM)
      EndIf   
   Next nR	        

   MsgInfo(Transform(nCont,"@E 9999")+" arquivo(s) transmitido(s) com sucesso.","Transmissão arquivos SFTP.")

Else 
   MsgInfo("Não há arquivos para processar !!'")   
EndIf

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} UplSFTP.
Realiza a conexï¿½o com SFTP Shiseido
 
@author    
@version   
@since     24/07/2020
/*/
//------------------------------------------------------------------------------------------
Static Function UplSFTP(cOper,cArqSFPT,cDirSRV,cDirSFTP,cLocLogs,cLocLgEr)
Local cSFTP     := SuperGetMV("MV_XXSFTP", .F.,"sftp://shiseido:Sh1%%24IDL20@177.47.18.54:2203/")
Local cCommando := ""
Local lWait     := .T.
Local cPath     := 'C:\Program Files (x86)\WinSCP\'
Local cRootPath := GetSrvProfString("RootPath", "\undefined")
Local cBat      := ""                                            
Local cArqLog   := ""
Local cBatWscpS := "" 
Local cDataLog  := StrTran(dTos(dDataBase), '/', '-')+StrTran(Time(), ':','')
Local nR        := 0

lRet := .F.

cBatWscpS := "\WiscpconnectS.bat"
 
//Cria arquivo bat para subir arquivo no FTP.
nHdl := FCREATE(cBatWscpS,0 )  //Criaï¿½ï¿½o do Arquivo txt.                                                  
If nHdl == -1 // Testa se o arquivo foi gerado
   cMsg :="O bat "+cBatWscpS+" nao pode ser executado."
   conout(cMsg)
   Return lRet
EndIf  
cCommando:= '@echo off'+ENTER
cCommando+= ENTER
cCommando+= '"C:\Program Files (x86)\WinSCP\WinSCP.com" ^'+ENTER
cCommando+= '  /log="'+cRootPath+cLocLogs+'WinSCPconnect.log" /ini=nul ^'+ENTER   
cCommando+= '  /command ^'+ENTER
cCommando+= ' "open '+Alltrim(cSFTP)+' -hostkey=""ssh-rsa 2048 ZLSRR368So0OwmX+EooAa8iNnlO1YpxMsJPymbVZtzg=""" ^'+ENTER
If cOper = 'GET' .Or. cOper = 'DEL' 
   cCommando+= '    "cd '+cDirSFTP+'" ^'+ENTER       
EndIf 
If cOper = 'GET'  
   cCommando+= '    "'+cOper+' *.pgp '+cRootPath+cDirSRV+'" ^'+ENTER
ElseIf cOper = 'DEL'  
   cCommando+= '    "get -delete '+Alltrim(cArqSFPT)+'" ^'+ENTER   
ElseIf cOper = 'PUT'
   cCommando+= '    "lcd '+cRootPath+cDirSRV+'" ^'+ENTER   
   cCommando+= '    "cd '+cDirSFTP+'" ^'+ENTER
   cCommando+= '    "'+cOper+' '+cRootPath+cDirSRV+Alltrim(cArqSFPT)+'" ^'+ENTER
EndIf                 
cCommando+= '    "exit"' +ENTER
cCommando+= ENTER
cCommando+= 'set WINSCP_RESULT=%ERRORLEVEL%'+ENTER
cCommando+= 'if %WINSCP_RESULT% equ 0 ('+ENTER
cCommando+= '  echo Success'+ENTER
cCommando+= ') else ('+ENTER
cCommando+= '  echo Error'+ENTER
cCommando+= '  Move '+cRootPath+cLocLogs+'WinSCPconnect.log '+cRootPath+cLocLgEr+'WinSCPconnect.log'+ENTER  
cCommando+= ')'+ENTER
cCommando+= ENTER
cCommando+= 'exit /b %WINSCP_RESULT%'+ENTER
fWrite(nHdl,cCommando)//Escreve no arquivo 
fclose(nHdl)//Fecha o arquivo
lRet := WaitRunSrv( @cRootPath+cBatWscpS , @lWait , @cPath )
fErase(cBatWscpS)//Apaga o .Bat
Return lRet

//----------------------------------------------

Static Function IDLLOG(cTabela, cChaveDoc, cProcesso, cStatus, cArquivo, cMensagem)
Local   _aArea 	 := GetArea()
Default cMensagem  := ""

Z0G->(DBSelectArea("Z0G"))
RecLock("Z0G", .T.)
Z0G->Z0G_FILIAL := xFilial("Z0G")
Z0G->Z0G_PEDIDO := SC5->C5_NUM
Z0G->Z0G_DATA	:= Date()
Z0G->Z0G_HORA	:= Time()
Z0G->Z0G_USER	:= CUSERNAME
Z0G->Z0G_TABELA := cTabela
Z0G->Z0G_CHAVE	:= cChaveDoc
Z0G->Z0G_PROCES := cProcesso
Z0G->Z0G_STATUS := cStatus
Z0G->Z0G_ARQUIV := cArquivo
Z0G->Z0G_MENSAG := cMensagem
Z0G->(MSUnLock())

RestArea(_aArea)
 
Return

//----------------------------------

Static Function fGeraLog(cChaveArq,cMensagem,cDirSrv,cDirLoc,cStatus,cPedido)
Local aArea := GetArea()

Reclock("Z0G",.T.)
Z0G->Z0G_FILIAL := xFilial("Z0G")
Z0G->Z0G_PEDIDO := cPedido
Z0G->Z0G_DATA   := dDataBase
Z0G->Z0G_HORA   := Time()
Z0G->Z0G_USER   := CUSERNAME
Z0G->Z0G_TABELA := Iif(cChaveArq=="B","BOL",Iif(cChaveArq=="G","GUI",Iif(cChaveArq=="C","COM","XML")))
Z0G->Z0G_CHAVE  := Iif(cChaveArq=="B","BOL",Iif(cChaveArq=="G","GUI",Iif(cChaveArq=="C","COM","XML")))+cPedido
Z0G->Z0G_PROCES := Iif(cChaveArq=="B","BOLETOS",Iif(cChaveArq=="G","GUIA",Iif(cChaveArq=="C","COMPROVANTE","XML NFE")))
Z0G->Z0G_STATUS := cStatus
Z0G->Z0G_MENSAG := cMensagem
Z0G->Z0G_ARQUIV := cDirSrv
Z0G->Z0G_ARQLOC := cDirLoc
MsUnlock()

RestArea(aArea)
Return

//------------------------------------------

Static Function fCriaPerg(_cPerg)
aSvAlias:={Alias(),IndexOrd(),Recno()}
i:=j:=0
aRegistros:={}

AADD(aRegistros,{_cPerg,"01","Série                       ?","","","mv_ch1","C",03,00,00,"G","","Mv_Par01","","","",""        ,"","","",""               ,"","","",""     ,"","","","","","","","","","","","","","","","","",""})
AADD(aRegistros,{_cPerg,"02","Documento de                ?","","","mv_ch2","C",09,00,00,"G","","Mv_Par02","","","",""        ,"","","",""               ,"","","",""     ,"","","","","","","","","","","","","SF2","","","","",""})
AADD(aRegistros,{_cPerg,"03","Documento ate               ?","","","mv_ch3","C",09,00,00,"G","","Mv_Par03","","","",""        ,"","","",""               ,"","","",""     ,"","","","","","","","","","","","","SF2","","","","",""})
AADD(aRegistros,{_cPerg,"04","Emissão de                  ?","","","mv_ch4","D",08,00,00,"G","","Mv_Par04","","","",""        ,"","","",""               ,"","","",""     ,"","","","","","","","","","","","","","","","","",""})
AADD(aRegistros,{_cPerg,"05","Emissão ate                 ?","","","mv_ch5","D",08,00,00,"G","","Mv_Par05","","","",""        ,"","","",""               ,"","","",""     ,"","","","","","","","","","","","","","","","","",""})

dbSelectArea("SX1")
dbSetOrder(1)
For i := 1 to Len(aRegistros)
	If !dbSeek(aRegistros[i,1]+aRegistros[i,2])
		While !RecLock("SX1",.T.)
		End
		For j:=1 to FCount()
			FieldPut(j,aRegistros[i,j])
		Next
		MsUnlock()
	Endif
Next i

If! Empty(aSvAlias[1]) 
   dbSelectArea(aSvAlias[1])
   dbSetOrder(aSvAlias[2])
   dbGoto(aSvAlias[3])
EndIf
Return(Nil)

//--------------------------------------

Static Function MontaQuery(cSerie,cDocDe,cDocAte,dEmissDe,dEmissAte)   
*--------------------------*   
If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf
   
cQuery := "SELECT C5_NUM "+Chr(10)+CHR(13)
cQuery += "FROM "+RetSqlName("SC5")+" SC5 "+Chr(10)+CHR(13)
cQuery += ","+RetSqlName("SC6")+" SC6 "+Chr(10)+CHR(13)
cQuery += ","+RetSqlName("SD2")+" SD2 "+Chr(10)+CHR(13)
cQuery += "WHERE C5_FILIAL = '"+xFilial("SC5")+"' "+Chr(10)+CHR(13)
cQuery += "AND C5_FILIAL = C6_FILIAL "+Chr(10)+CHR(13)
cQuery += "AND C5_NUM = C6_NUM "+Chr(10)+CHR(13)
cQuery += "AND C6_FILIAL = D2_FILIAL "+Chr(10)+CHR(13)
cQuery += "AND C6_NUM = D2_PEDIDO "+Chr(10)+CHR(13)
cQuery += "AND C6_ITEM = D2_ITEMPV "+Chr(10)+CHR(13)
cQuery += "AND D2_SERIE = '"+cSerie+"' "+Chr(10)+CHR(13)
cQuery += "AND D2_DOC >= '"+cDocDe+"' AND  D2_DOC <= '"+cDocAte+"' "+Chr(10)+CHR(13)
cQuery += "AND D2_EMISSAO >= '"+Dtos(dEmissDe)+"' AND  D2_EMISSAO <= '"+Dtos(dEmissAte)+"' "+Chr(10)+CHR(13)
cQuery += "AND SC5.D_E_L_E_T_ = '' "+Chr(10)+CHR(13)
cQuery += "AND SC6.D_E_L_E_T_ = '' "+Chr(10)+CHR(13)
cQuery += "AND SD2.D_E_L_E_T_ = '' "+Chr(10)+CHR(13)
cQuery += "GROUP BY C5_NUM  "+Chr(10)+CHR(13)
cQuery += "ORDER BY C5_NUM "+Chr(10)+CHR(13)

TCQuery cQuery ALIAS "SQL" NEW

Return

