#INCLUDE "FIVEWIN.CH"
#include "rwmake.ch"
#include "protheus.ch"
#INCLUDE "TOPCONN.CH"

/*
Funcao      : L5EST001
Parametros  : 
Retorno     : 
Objetivos   : Integração de XML NF Entrada baseado no INTPRYOR
Autor       : Renato Rezende
Data/Hora   : 09/09/2014
Módulo		: Estoque
Cliente		: Bioderma / L5
*/

*------------------------*
 User Function L5EST001()
*------------------------*
Local nLin1			:= 0
Local nLin2			:= 0

Private cArq		:= ""
Private cArquivo	:= "C:\"+Space(50)
Private lRet		:= .T.
Private OdlgPrin

//Verifica se está na empresa Bioderma
If !(cEmpAnt) $ "L5"
	MsgInfo("Rotina não implementada para essa empresa!","HLB BRASIL")
	Return .F.
EndIf

OdlgPrin := MSDialog():New(180,180,315,565,'Interface de integração XML Bioderma',,,,,,,,,.T.)

	nLin1:=005
	nLin2 := nLin1+31

	@ nLin1,005 TO nLin2,190  LABEL "Selecione o arquivo de integração" OF OdlgPrin PIXEL  // Caixa do meio 
	nLin1 += 11
	@ nLin1,010 Get cArquivo Size 145,10 OF OdlgPrin PIXEL 
	nLin1 += 1      
	@ nLin1,160 BmpButton Type 14 Action LoadArq()
      
	nLin1 += 22                                                           
	nLin2 := nLin1+24
	
	@ nLin1,005 TO nLin2,190  LABEL "" OF OdlgPrin PIXEL  // Caixa do botao 
	nLin1 += 5

	@ nLin1,050 BUTTON "Cancelar" size 40,15 ACTION Processa({|| OdlgPrin:End()}) of OdlgPrin Pixel
	@ nLin1,094 BUTTON "Integrar" size 40,15 ACTION Processa({|| lRet:=ExistArq(),;
																 If(lRet,lRet:=IntXmlPNF(cArquivo),),;
																 If(lRet,OdlgPrin:End(),"")}) of OdlgPrin Pixel

OdlgPrin:lCentered := .T.
OdlgPrin:Activate()      
   
Return

/*
Funcao      : LoadArq
Objetivos   : Carregar o arquivo
Autor       : Renato Rezende
Obs.        :   
Data        : 10/09/2014
*/       
*------------------------------*
 Static Function LoadArq()
*------------------------------*
Local nPos
Local cType    := "Arq.XML  | *.XML" 

cArquivo := cGetFile(cType,"Selecione arquivo"+Subs(cType,1,6),1,'C:\',.T.,( GETF_LOCALHARD + GETF_LOCALFLOPPY ) ,.T.)
cArquivo := Upper(AllTrim(cArquivo))
                            
nPos:=At("\",Alltrim(cArquivo))   
cArq:=cArquivo   

While 0 < nPos                          
	cArq:=SubStr(cArq,nPos+1,Len(alltrim(cArq)))
	nPos:=At("\",Alltrim(cArq))   
EndDo 

Return

/*
Funcao      : ExistArq()
Objetivos   : Verificar se o arquivo existe 
Autor       : Renato Rezende
Obs.        :   
Data        : 10/09/2014
*/       
*------------------------------*
 Static Function ExistArq()
*------------------------------*        

If Len(Alltrim(cArquivo)) <= 3 
	MsgAlert("Selecione o XML para integração!","HLB BRASIL")
	lRet:=.F.
Else
	lRet:=.T.
EndIf

Return lRet

/*
Funcao      : IntXmlPNF()
Parametros  : cArquivo: Arquivo XML de integração
Retorno     : Nil
Objetivos   : Integração do arquivo XML, gerando a Pre Nota de Entrada.
Autor       : Renato Rezende
Data	  	: 10/09/14
*/
*------------------------------------*
 Static Function IntXmlPNF(cArquivo)
*------------------------------------*
Local lXml		:= .T.
Local lCopy		:= .F. 
Local lRet		:= .F.

Local cProd		:= ""
Local cUM		:= ""
Local cMsg		:= ""  
Local cErro		:= ""
Local cAviso	:= ""
Local cDesc		:= ""
Local cLote		:= ""
Local cInfAdi	:= "" 

Local dVldLote	:= ""

Local nAt    := 0
Local nX     := 0
Local nQtd   := 0
Local nUM    := 0
Local nVlUn  := 0
Local nVlTot := 0

Local aCabec := {}
Local aLinha := {}
Local aItens := {}

Local oXml

Private lMSErroAuto := .F.

Private cDoc     := ""
Private cSerie   := ""
Private cCNPJ    := ""
Private cEmissao := ""
Private cTipoNf  := "N"
Private cCodNFE  := ""
Private cChvNfe  := ""

Private aProd  := {}

//Verifica se o arquivo não está na raiz do ambiente.
If Substr(cArquivo,2,1) == ":" .or. Left(cArquivo,2) == "//"
      	
	//Verifica o nome do arquivo.
    cFile := cArquivo
	nAT   := 1
	For nX := 1 To Len(cArquivo)
		cFile := Substr(cFile,If(nX==1,nAt,nAt+1),Len(cFile))
		nAt := At("\",cFile)
		If nAt == 0
			Exit
		Endif
	Next nX
      	     	
	//Copia o arquivo para o diretorio raiz.
	CpyT2S(cArquivo,"\BKP")
	       	
	cArquivo := "\BKP\"+cFile
	lCopy := .T.
	
EndIf
        	
lXml := .T.
      	
//Leitura do XML
oXml :=  XmlParserFile(cArquivo,"_",@cErro,@cAviso)

If ( Empty(cErro) .And. Empty(cAviso) .And. oXml <> Nil)
	
	bError := ErrorBlock({|| lXml := .F.})     
	
	//TLM 25/05/2011 - Validar se a nota é valida no SEFAZ
	Processa({|| Validar(oXml)},"Integração Grant Thorton","Validando nota no Sefaz,aguarde ...",.F. ) 
		                                              	
	// Código 100 - Nota ok- transmitida
	If cCodNFE<>"100"
		Return .F.
	EndIf	
					
	Begin Sequence 
   		cDoc     := oXml:_NFeProc:_NFe:_infNFe:_ide:_nNf:TEXT
		cSerie   := oXml:_NFeProc:_NFe:_infNFe:_ide:_serie:TEXT 
		cChvNfe  := oXml:_NFeProc:_protNFe:_infProt:_chNFe:TEXT
				
 		cEmissao := oXml:_NFeProc:_NFe:_infNFe:_ide:_dEmi:TEXT
 		cEmissao := Left(cEmissao,4)+Substr(cEmissao,6,2)+Right(cEmissao,2)

		cCNPJ    := oXml:_NFeProc:_NFe:_infNFe:_emit:_CNPJ:TEXT
 		
 		If ValType(oXml:_NFeProc:_NFe:_infNFe:_det) == "A"
 				
	 		For nX := 1 To Len(oXml:_NFeProc:_NFe:_infNFe:_det)
 				cProd  := oXml:_NFeProc:_NFe:_infNFe:_det[nX]:_prod:_cProd:TEXT
 				nQtd   := Val(oXml:_NFeProc:_NFe:_infNFe:_det[nX]:_prod:_qCom:TEXT)
 				cUM    := oXml:_NFeProc:_NFe:_infNFe:_det[nX]:_prod:_uCom:TEXT
	 			nVlUn  := Val(oXml:_NFeProc:_NFe:_infNFe:_det[nX]:_prod:_vUnCom:TEXT)
 				nVlTot := Val(oXml:_NFeProc:_NFe:_infNFe:_det[nX]:_prod:_vProd:TEXT)
 				cCFOP  := oXml:_NFeProc:_NFe:_infNFe:_det[nX]:_prod:_CFOP:TEXT
 				cDesc  := oXml:_NFeProc:_NFe:_infNFe:_det[nX]:_prod:_XPROD:TEXT
 				//Incluindo informacoes do Lote e Validade
 				If XmlChildEx(oXml:_NFeProc:_NFe:_infNFe:_det[nX],"_INFADPROD")<>Nil
 					
 					cInfAdi	:= Alltrim(oXml:_NFeProc:_NFe:_infNFe:_det[nX]:_INFADPROD:TEXT)
	 				cLote	:= Alltrim(SubStr(SubStr(cInfAdi,AT(":",cInfAdi)+1),1,AT("|",SubStr(cInfAdi,AT(":",cInfAdi)+1))-1))
	 			   	dVldLote:= CtoD(Alltrim(SubStr(SubStr(cInfAdi,RAT(":",cInfAdi)+1),1,AT("|",SubStr(cInfAdi,RAT(":",cInfAdi)+1))-1)))
	 			   	
					aAdd(aProd,{cProd,nQtd,cUM,nVlUn,nVlTot,cCFOP,cDesc,cLote,dVldLote}) 
				Else
					aAdd(aProd,{cProd,nQtd,cUM,nVlUn,nVlTot,cCFOP,cDesc})				
 				EndIf
 			Next
 		Else

			cProd  := oXml:_NFeProc:_NFe:_infNFe:_det:_prod:_cProd:TEXT
			nQtd   := Val(oXml:_NFeProc:_NFe:_infNFe:_det:_prod:_qCom:TEXT)
			cUM    := oXml:_NFeProc:_NFe:_infNFe:_det:_prod:_uCom:TEXT
 			nVlUn  := Val(oXml:_NFeProc:_NFe:_infNFe:_det:_prod:_vUnCom:TEXT)
			nVlTot := Val(oXml:_NFeProc:_NFe:_infNFe:_det:_prod:_vProd:TEXT)
			cCFOP  := oXml:_NFeProc:_NFe:_infNFe:_det:_prod:_CFOP:TEXT
 			cDesc  := oXml:_NFeProc:_NFe:_infNFe:_det:_prod:_XPROD:TEXT
 			//Incluindo informacoes do Lote e Validade
 			If XmlChildEx(oXml:_NFeProc:_NFe:_infNFe:_det,"_INFADPROD")<>Nil
 					
 				cInfAdi	:= Alltrim(oXml:_NFeProc:_NFe:_infNFe:_det:_INFADPROD:TEXT)
	 			cLote	:= Alltrim(SubStr(SubStr(cInfAdi,AT(":",cInfAdi)+1),1,AT("|",SubStr(cInfAdi,AT(":",cInfAdi)+1))-1))
	 			dVldLote:= CtoD(Alltrim(SubStr(SubStr(cInfAdi,RAT(":",cInfAdi)+1),1,AT("|",SubStr(cInfAdi,RAT(":",cInfAdi)+1))-1)))
	 			   	
				aAdd(aProd,{cProd,nQtd,cUM,nVlUn,nVlTot,cCFOP,cDesc,cLote,dVldLote}) 
			Else
				aAdd(aProd,{cProd,nQtd,cUM,nVlUn,nVlTot,cCFOP,cDesc})				
 			EndIf			
 		EndIf
 		
	End Sequence
	ErrorBlock(bError)

	//Trata o tipo da NF pelo CFOP.
	If AllTrim(aProd[1,6]) $ "6906|6907"
		cTipoNF := "B" //Beneficiamento
	ElseIf AllTrim(aProd[1,6]) $ "1202|2202|1401|2401"
		cTipoNF := "D" //Devolução
	Else
		cTipoNF := "N" //Normal		
	EndIf
	
	//Validações antes da integração
	cMsg := Validacoes("XML_PNF")
	
	//Exibir a mensagem de erro.
	If Len(cMsg) > 0
		ExibeMsg(cMsg)	
	Else
		
		//Monta os campos da capa da Pre-Nota de Entrada.
		aAdd(aCabec,{"F1_TIPO"   ,cTipoNF})
		aAdd(aCabec,{"F1_FORMUL" ,"N"})
		aAdd(aCabec,{"F1_DOC"    ,cDoc})
		aAdd(aCabec,{"F1_SERIE"  ,cSerie})
		aAdd(aCabec,{"F1_EMISSAO",StoD(cEmissao)})  
		aAdd(aCabec,{"F1_CHVNFE" ,cChvNfe})  
	   
		If  cTipoNF $ "B/D"       
		
			aAdd(aCabec,{"F1_FORNECE",SA1->A1_COD})
			aAdd(aCabec,{"F1_LOJA"   ,SA1->A1_LOJA})
			aAdd(aCabec,{"F1_ESPECIE",""})
			aAdd(aCabec,{"F1_EST"    ,SA1->A1_EST})
			
		Else             
		
			aAdd(aCabec,{"F1_FORNECE",SA2->A2_COD})
			aAdd(aCabec,{"F1_LOJA"   ,SA2->A2_LOJA})
			aAdd(aCabec,{"F1_ESPECIE",""})
			aAdd(aCabec,{"F1_EST"    ,SA2->A2_EST}) 
			
	    EndIf    
	    
		//Monta os campos de itens da Pre-Nota de Entrada.
		For nX := 1 To Len(aProd)
			aLinha := {}
			aAdd(aLinha,{"D1_COD"  ,aProd[nX][1],Nil})
			aAdd(aLinha,{"D1_QUANT",aProd[nX][2],Nil})
			aAdd(aLinha,{"D1_VUNIT",aProd[nX][4],Nil})
			aAdd(aLinha,{"D1_TOTAL",aProd[nX][5],Nil})
			aAdd(aLinha,{"D1_LOTECTL",aProd[nX][8],Nil})
			aAdd(aLinha,{"D1_DTVALID",aProd[nX][9],Nil})
			aAdd(aLinha,{"D1_OBS"  ,"REF.DOC:"+AllTrim(cDoc)+"-"+AllTrim(cSerie),Nil})
			aAdd(aItens,aLinha)
		Next nX
        
    	//Exibe a previa da Pre-Nota de Entrada.
       	If ExibePreNF(@aCabec,@aItens)    
    
			//Gera a pre-nota de entrada.
			MSExecAuto({|x,y,z| MATA140(x,y,z)},aCabec,aItens,3)
		    
      		If lMSErroAuto           
         		MostraErro()
         		Return .F.
      		Else
      			MsgInfo("A pre nota de entrada foi gerada.","HLB BRASIL")
      		EndIf   
		
		EndIf

    EndIf

Else
	MsgInfo("Erro na leitura do arquivo XML: "+ AllTrim(cErro)+".","HLB BRASIL")
	Return .F.

EndIf    

//Apaga o arquivo da raiz do ambiente
If lCopy
	If File(cArquivo)
		fErase(cArquivo)	
	EndIf
EndIf

Return .F.

/*
Funcao      : Validar()
Parametros  : XML da NFE
Retorno     : Nil
Objetivos   : Validar a NFE no Sefaz
Autor       : Renato Rezende
Data	  	: 10/09/14
*/ 
*---------------------------------*
 Static Function Validar(oXml)
*---------------------------------*
Local cChaveNFe := oXml:_NFEPROC:_PROTNFE:_INFPROT:_CHNFE:TEXT
Local cIdEnt 	:= GetIdEnt()

Local cURL      := PadR("http://10.0.30.22:5076",250)
Local cMensagem := ""
Local oWS    

oWs:= WsNFeSBra():New()
oWs:cUserToken   := "TOTVS"
oWs:cID_ENT    	 := "000001"//cIdEnt
ows:cCHVNFE		 := cChaveNFe
oWs:_URL         := AllTrim(cURL)+"/NFeSBRA.apw"              

If oWs:ConsultaChaveNFE() 
	cMensagem := ""   
	If !Empty(oWs:oWSCONSULTACHAVENFERESULT:cVERSAO)
		cMensagem += "Versão NFE :"+oWs:oWSCONSULTACHAVENFERESULT:cVERSAO+CRLF
	EndIf       
	cMensagem += "Ambiente: "+IIf(oWs:oWSCONSULTACHAVENFERESULT:nAMBIENTE==1,"Produção","Homologação")+CRLF 	
	cMensagem += "Codigo Retorno NFe: "+oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE+CRLF
	cMensagem += "Mensagem Retorno NFe : "+oWs:oWSCONSULTACHAVENFERESULT:cMSGRETNFE+CRLF 
	cCodNFE:=oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE 

	If !Empty(oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO)
		cMensagem += "Protocolo : "+oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO+CRLF	
	EndIf  
	
	cMensagem +=+CRLF     
                 
	//Códigos usados disponiveis em http://www.sefaz.ma.gov.br/NFE/codigos_de_mensagens_de_autorizacao_nfe.htm	
	If Alltrim(cCodNFE) == "100"
		cMensagem += "Nota fiscal pode ser integrada "	
	Else
		cMensagem += "ATENÇÃO: Essa nota não pode ser integrada "
	EndIf 
	Aviso("Consulta Nota Fiscal Eletronica Grant Thorton",cMensagem,{"Ok"},,3)   
	
Else
	Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"Ok"},3) 
EndIf

Return

/*
Funcao      : Validacoes()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para validar dados da integração
Autor       : Renato Rezende
Data/Hora   : 16/09/14
*/
*------------------------------------------*
Static Function Validacoes(cTipo,aDados)
*------------------------------------------*
Local cLog 			:= "" 

Local nX 			:= 0  
  
If cTipo == "XML_PNF"
	If cTipoNF $ "B|D" //Devolução ou beneficiamento.
		//Verifica se o cliente está cadastrado na base de dados.
		SA1->(DbSetOrder(3))
		If !SA1->(DbSeek(xFilial("SA1")+AllTrim(cCNPJ)))
			cLog += "O cliente com o CNPJ "+AllTrim(cCNPJ)+" não está cadastrado."+CRLF
		EndIf
	
	Else	
		//Verifica se o fornecedor está cadastrado na base de dados.
		SA2->(DbSetOrder(3))
		If !SA2->(DbSeek(xFilial("SA2")+AllTrim(cCNPJ)))
			cLog += "O fornecedor com o CNPJ "+AllTrim(cCNPJ)+" não está cadastrado."+CRLF
		EndIf
	EndIf
	    
	//Verifica se os produtos estão cadastrados na base.     
	SB1->(DbSetOrder(1))
	For nX := 1 To Len(aProd)
		If !SB1->(DbSeek(xFilial("SB1")+AllTrim(aProd[nX][1])))
	   		//Verifica se o produto está cadastrado com o código de referencia do cliente.
	   		SA5->(DbSetOrder(5))
			If SA5->(DbSeek(xFilial("SA5")+AllTrim(aProd[nX][1])))
	    	    		aProd[nX][1] := SA5->A5_PRODUTO
	           		Else	
	           		cLog += "O produto "+ AllTrim(aProd[nX][1]) +" do item " + AllTrim(Str(nX)) +" não está cadastrado."+CRLF
	   		EndIf
	      
		EndIf
	Next  	   
EndIf
  
Return AllTrim(cLog)

/*
Funcao      : ExibePreNF()
Parametros  : aCabec : Campos da capa da pre nota 
	          aItens : Campos dos itens da pre nota
Retorno     : Nil
Objetivos   : Exibição da tela previa da integração. 
Autor       : Renato Rezende
Data/Hora   : 16/09/14
*/
*---------------------------------------*
Static Function ExibePreNF(aCabec,aItens)
*---------------------------------------*
Local lRet := .F.

Local cTitulo  := "Pre Nota de Entrada"
Local cOldDoc  := ""
Local cOldSer  := ""
Local cTpNota  := ""
Local cFormPro := "" 

Local nPos  := 0
Local nX    := 0
Local nI    := 0

Local dEmissao

Local aAux     := {}
Local aButtons := {}
Local aHeader  := {}
Local aBrowse  := {}
Local aTiposNf := {}
Local aFormPro := {}

Local bOK     := {|| If(VldPreNf(cDoc,cSerie,cForn,cLoja),(lRet := .T.,oDlg:End()),)}
Local bCancel := {|| lRet := .F.,oDlg:End()}

Local oDlg
Local oEnc
Local oBrw
Local oGtDoc
Local oGtSerie
Local oGtEmiss
Local oLsTp
Local oFrmPro

Private cDoc     := ""
Private cSerie   := ""
Private cForn    := ""
Private cLoja    := ""
Private cEspecie := Space(TamSx3("F1_ESPECIE")[1]) 
Private cDesFor  := ""
Private cUf      := ""
Private oGtForn
Private oGtDesFor
Private oGtUF
Private oGtLoja

//Recupera os campos da capa da Pre Nota de Entrada.
nPos    := aScan(aCabec,{|a| Alltrim(a[1]) == "F1_DOC"})
cDoc    := Strzero(Val(aCabec[nPos][2]),9)
cOldDoc := aCabec[nPos][2]
cDoc    := PadR(cDoc,TamSx3("F1_DOC")[1])

nPos    := aScan(aCabec,{|a| Alltrim(a[1]) == "F1_SERIE"})
cSerie  := aCabec[nPos][2]
cOldSer := aCabec[nPos][2]
cSerie  := PadR(cSerie,TamSx3("F1_SERIE")[1])

nPos     := aScan(aCabec,{|a| Alltrim(a[1]) == "F1_EMISSAO"})
dEmissao := aCabec[nPos][2]

nPos  := aScan(aCabec,{|a| Alltrim(a[1]) == "F1_FORNECE"})
cForn := aCabec[nPos][2]

nPos  := aScan(aCabec,{|a| Alltrim(a[1]) == "F1_LOJA"})
cLoja := aCabec[nPos][2]

nPos  := aScan(aCabec,{|a| Alltrim(a[1]) == "F1_EST"})
cUf   := aCabec[nPos][2]

nPos  := aScan(aCabec,{|a| Alltrim(a[1]) == "F1_TIPO"})

aTiposNf := {"Normal","Devolucao","Beneficiamento"}
aFormPro := {"Nao","Sim"}

If aCabec[nPos][2] == "N"
	cTpNota := aTiposNf[1]
ElseIf aCabec[nPos][2] == "D"
	cTpNota := aTiposNf[2]
ElseIf aCabec[nPos][2] == "B"
	cTpNota := aTiposNf[3]
EndIf

SA2->(DbSetOrder(1))
If SA2->(DbSeek(xFilial("SA2")+AvKey(cForn,"A2_COD")+AvKey(cLoja,"A2_LOJA")))
	cDesFor := SA2->A2_NOME
EndIf

//Loop na primeira linha do array de itens para recuperar o nome dos campos dos itens.
For nX := 1 To Len(aItens[1])
	aAdd(aHeader,RetTitle(aItens[1][nX][1]))
Next

//Montagem do array com os itens.
For nX := 1 To Len(aItens)
	aAux := {}
	For nI := 1 To Len(aItens[nX])
		aAdd(aAux,aItens[nX][nI][2])
	Next
	aAdd(aBrowse,aAux)
Next                
 
cEspecie:="NF-E"

//Montagem da tela.
DEFINE MSDIALOG oDlg TITLE cTitulo FROM 000,000 TO 485,900 PIXEL
                   
	@ 017 , 006 TO 053,445 LABEL "" OF oDlg PIXEL                        	

	@ 021 , 010 SAY "Numero" PIXEL SIZE 60,09 OF oDlg
	@ 020 , 075 MSGET oGtDoc VAR cDoc PICTURE PesqPict("SF1","F1_DOC") OF oDlg PIXEL SIZE 34,09
	@ 021 , 119 SAY "Serie" PIXEL SIZE 23,09 OF oDlg
	@ 020 , 147 MSGET oGtSerie VAR cSerie PICTURE PesqPict("SF1","F1_SERIE") OF oDlg PIXEL SIZE 18,09
	@ 021 , 175 SAY "Emissao" PIXEL SIZE 30,09 OF oDlg
	@ 020 , 210 MSGET oGtEmiss VAR dEmissao PICTURE PesqPict("SF1","F1_EMISSAO") WHEN .F. OF oDlg PIXEL SIZE 45,09
	@ 021 , 265 SAY "Especie" PIXEL SIZE 63,09 OF oDlg
	@ 020 , 295 MSGET oGtEsp  VAR cEspecie  PICTURE PesqPict("SF1","F1_ESPECIE") VALID CheckSX3("F1_ESPECIE",cEspecie) F3 CpoRetF3("F1_ESPECIE") OF oDlg PIXEL SIZE 30,09
	@ 021 , 345 SAY "Tipo" PIXEL SIZE 30,09 OF oDlg
	@ 020 , 360 MSCOMBOBOX oLsTp VAR cTpNota ITEMS aTiposNf VALID AltF3(cTpNota) OF oDlg PIXEL SIZE 60,09

	@ 039 , 010 SAY "Forn./Cliente" PIXEL SIZE 43,09 OF oDlg
 	@ 038 , 075 MSGET oGtForn VAR cForn   PICTURE PesqPict("SF1","F1_FORNECE") VALID AltForCli(cTpNota,"1") F3 IIF(cTpNota $ "Devolucao/Beneficiamento","SA1","SA2") OF oDlg PIXEL SIZE 041,09
	@ 038 , 121 MSGET oGtLoja VAR cLoja   PICTURE PesqPict("SF1","F1_LOJA") VALID AltForCli(cTpNota,"2") OF oDlg PIXEL SIZE 015,09
	@ 038 , 143 MSGET oGtDesFor VAR cDesFor PICTURE "@!" WHEN .F. OF oDlg PIXEL SIZE 150,09
	@ 039 , 303 SAY "UF.Origem" PIXEL SIZE 63,09 OF oDlg
	@ 038 , 336 MSGET oGtUF   VAR cUf     PICTURE PesqPict("SF1","F1_EST") WHEN .F. OF oDlg PIXEL SIZE 20,09
	@ 039 , 360 SAY "Form Propr." PIXEL SIZE 40,09 OF oDlg
	@ 038 , 395 MSCOMBOBOX oFrmPro VAR cFormPro ITEMS aFormPro OF oDlg PIXEL SIZE 30,09

    oBrw := TWBrowse():New(057,006,440,175,,aHeader,,oDlg,,,,,,,,,,,,,,.T.)
	oBrw:SetArray(aBrowse)    
	oBrw:bLine := {|| aBrowse[oBrw:nAT]}

ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,bOk,bCancel,,aButtons)) CENTERED

If lRet
	
	//Atualiza o número da pre nota com o valor informado
	If !(Upper(AllTrim(cDoc)) == Upper(AllTrim(cOldDoc))) //Utilizado o comando "!(==)" para diferenciar numeros parecidos.
		nPos := aScan(aCabec,{|a| Alltrim(a[1]) == "F1_DOC"})
		aCabec[nPos][2] := cDoc
	EndIf

	//Atualiza a serie da pre nota com o valor informado
	If !(Upper(AllTrim(cSerie)) == Upper(AllTrim(cOldSer))) //Utilizado o comando "!(==)" para diferenciar numeros parecidos.
		nPos := aScan(aCabec,{|a| Alltrim(a[1]) == "F1_SERIE"})
		aCabec[nPos][2] := cSerie
	EndIf
    
	//Atualiza a especie da pre nota com o valor informado
	If !Empty(cEspecie)
		nPos := aScan(aCabec,{|a| Alltrim(a[1]) == "F1_ESPECIE"})
		aCabec[nPos][2] := cEspecie
	EndIf
    
    //Atualiza o tipo da nota fiscal
	If !Empty(cTpNota)
		cTpNota := Upper(Left(cTpNota,1))
		nPos := aScan(aCabec,{|a| Alltrim(a[1]) == "F1_TIPO"})
		aCabec[nPos][2] := cTpNota
	EndIf
	
	//Inclusao do formulario proprio
	If cFormPro == "Sim"
		nPos := aScan(aCabec,{|a| Alltrim(a[1]) == "F1_FORMUL"})
		aCabec[nPos][2] := "S"	
	EndIf
	//Permitir alteração do Forn/Cliente
	If !Empty(cForn).AND.!Empty(cLoja)
   		nPos := aScan(aCabec,{|a| Alltrim(a[1]) == "F1_FORNECE"})
   		aCabec[nPos][2] := cForn
   		nPos := aScan(aCabec,{|a| Alltrim(a[1]) == "F1_LOJA"})
   		aCabec[nPos][2] := cLoja
   		nPos := aScan(aCabec,{|a| Alltrim(a[1]) == "F1_EST"}) 
   		aCabec[nPos][2] := cUf
 	EndIf

EndIf

Return lRet

/*
Funcao      : ExibeMsg()
Parametros  : cMsg: Mensagens de erro.
Retorno     : Nil
Objetivos   : Integração do arquivo XML, gerando a Pre Nota de Entrada.
Autor       : Eduardo C. Romanini
Data/Hora   : 11/01/11 13:30
*/
*----------------------------*
Static Function ExibeMsg(cMsg)
*----------------------------*
Local cTexto := ""
Local cMask := "Arquivos Texto (*.TXT) |*.txt|"

Local oFont
Local oDlg
Local oMemo

cTexto := "Foram encontradas divergencias na integração do arquivo." + CRLF + CRLF
cTexto += cMsg

Define FONT oFont NAME "Mono AS" Size 5,12
Define MsDialog oDlg Title "Log da Integração" From 3,0 to 340,417 Pixel

@ 5,5 Get oMemo  Var cTexto MEMO Size 200,145 Of oDlg Pixel
oMemo:bRClicked := {||AllwaysTrue()}
oMemo:oFont:=oFont

Define SButton  From 153,175 Type 1 Action oDlg:End() Enable Of oDlg Pixel //Apaga
Define SButton  From 153,145 Type 13 Action (cFile:=cGetFile(cMask,""),If(cFile="",.t.,MemoWrite(cFile,cTexto))) ENABLE OF oDlg PIXEL //Salva e Apaga //"Salvar Como..."

Activate MsDialog oDlg Center

Return Nil   

/*
Funcao      : VldPreNf()
Parametros  : Nenhum
Retorno     : lRet
Objetivos   : Validação da tela previa da integração.
Autor       : Eduardo C. Romanini
Data/Hora   : 11/01/11 15:50
*/
*---------------------------------------------------*
 Static Function VldPreNf(cDoc,cSerie,cForn,cLoja)
*---------------------------------------------------*

Local lRet := .T.

If Empty(cDoc)
	MsgInfo("O número da pre-nota deve ser informado.","HLB BRASIL")	
	Return .F.
EndIf

SF1->(DbSetOrder(1))
If SF1->(DbSeek(xFilial("SF1")+AvKey(cDoc,"F1_DOC")+AvKey(cSerie,"F1_SERIE")+AvKey(cForn,"F1_FORNECE")+AvKey(cLoja,"F1_LOJA")))
	MsgInfo("O número e série informados já estão cadastrados em outra nota.","HLB BRASIL")
	Return .F.
EndIf

If Empty(cEspecie) 
	MsgInfo("A especie deve ser informado.","HLB BRASIL")	
	Return .F.
EndIf

If !MsgYesNo("Confirma a geração da pre-nota de entrada: " + AllTrim(cDoc) + If(!Empty(cSerie)," - " + AllTrim(cSerie),""),"HLB BRASIL")
	Return .F.	
EndIf

Return lRet

/*
Funcao      : AltF3()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Alteração F3 do Cliente/Fornecedor na tela pre-nota
Autor       : Renato Rezende
Data/Hora   : 18/06/14 
*/
*-------------------------------------*
Static Function AltF3(cTpNota)
*-------------------------------------*
If cTpNota $ "Devolucao/Beneficiamento"
	oGtForn:cF3:="SA1"
Else
	oGtForn:cF3:="SA2"
EndIf

Return

/*
Funcao      : AltForCli()
Parametros  : Nenhum
Retorno     : lCpo
Objetivos   : Alteração do Cliente/Fornecedor na tela pre-nota
Autor       : Renato Rezende
Data/Hora   : 18/06/14 
*/
*-------------------------------------*
Static Function AltForCli(cTpNota,cTipo)
*-------------------------------------*
Local lCpo	:= .F.
Local cSeek := ""

If cTipo == "1" 
	cSeek := cForn
Else
	cSeek := cForn+cLoja
EndIf

If cTpNota $ "Devolucao/Beneficiamento"
	SA1->(DbSetOrder(1))

	If SA1->(DbSeek(xFilial("SA1")+cSeek))
		cDesFor := SA1->A1_NOME
		cUf		:= SA1->A1_EST
		cLoja	:= SA1->A1_LOJA
		lCpo	:= .T.
	Else
		MsgInfo("Cliente não encontrado!","HLB BRASIL")
	EndIf	
	
Else 
	SA2->(DbSetOrder(1))
	If SA2->(DbSeek(xFilial("SA2")+cSeek))
		cDesFor := SA2->A2_NOME
		cUf		:= SA2->A2_EST
		cLoja	:= SA2->A2_LOJA 
		lCpo	:= .T.
	Else
		MsgInfo("Fornecedor não encontrado!","HLB BRASIL") 
	EndIf
EndIf

Return lCpo