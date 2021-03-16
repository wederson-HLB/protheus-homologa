#INCLUDE "totvs.ch"
#include 'fileio.ch'
#INCLUDE "tbiconn.ch"  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³N6WS007   º Autor ³ WILLIAM SOUZA      º Data ³  30/01/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Interface para leitura do arquivo gerado pelo datatrax     º±±
±±º          ³ e geração do pedido de venda.                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ doTerra                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
#DEFINE CRLF CHR(13)+CHR(10) 
#DEFINE FO_READWRITE 2  // leitura e gravacao
#DEFINE FO_EXCLUSIVE 16 // modo exclusivo
#DEFINE FO_SHARED    64 // modo compartilhado
#DEFINE FS_SET       0  // posiciona no inicio do arquivo
#DEFINE FS_RELATIVE  1  // posiciona no ponteiro corrente
#DEFINE FS_END       2  // posiciona no fim do arquivo
*---------------------------*
User Function N6WS007(aParam) 
*---------------------------*
Local nX,nY,nI
Local cChave         := ""
Local oXml           := ""
Local cDir           := ""
Local cDirFisico     := ""
Local cDoc           := ""
Local cXml           := ""
Local cRetorno       := ""  
Local cError         := ""
Local cWarning       := ""
Local cMensagem      := "<br><b>Pedido de venda não gerado pelos seguintes motivos:</b><br><ul>"
Local cLogErro       := "" 
Local cFile          := ""
Local cOper			 := ""
Local cData		     := ""
Local lJob	         := Type( 'oMainWnd' ) != 'O'  
Local chora          := Time()
Local lOk           := .T.
Local lProcessa      := .T.   
Local nFileStatus    := 0
Local aFiles 	     := {} 
Local aCabec 	     := {}
Local aItens         := {}
Local aLinha         := {}
Local aPvlNfs 	     := {}
Local aBloqueio      := {}
Local aEmail		 := {}
Local aTelefone		 := {}
Local aEnd			 := {}
Local bError         := ErrorBlock()
Local cQry			 := ""

Private cFil		 := ""

Private cCodEndEnt	 := ""

Private lMsErroAuto    := .F.
Private lAutoErrNoFile := .F.
Private lMsHelpAuto	   := .T. 
Private cRetError      := ""

//rotina para deixar a função para ser chamada via menu.
If lJob 
	If ( Valtype( aParam ) != 'A' )
		cFil := FWCodFil() 
	Else            
		cFil := aParam[02]	
	EndIf
	
	RPCSetType(3)	
	RpcSetEnv("N6",cFil,"","",'FAT')
Else
	cFil := FWCodFil() 
EndIf

//Preparação de váriaveis
cDir		:= alltrim(GETMV("MV_P_00119"))
cDirFisico	:= alltrim(GetSrvProfString("ROOTPATH",""))+cDir
cData		:= dtoc(ddatabase)

//limpeza do arquivo de log
FERASE(cDir+"\datatrax.log") 
FERASE(cDir+"\datatrax2.log")                               

//Execução do batch para buscar no sftp os arquivos do datatrax
WaitRunSrv(@cDirFisico+"\datatrax.bat "+cFil,.T.,@cDirFisico) 

//listo todos os arquivos do diretorio
aFiles := Directory(cDir+"\Importado\"+cFil+"\*.xml", "D")
For nI := 1 to len(afiles)
	ErrorBlock( { |oError| MyError( oError ) } )
	// Controlo o fluxo da rotina
	BEGIN SEQUENCE
		//Leitura do conteudo do arquivo XML
        nHandle := fopen(cDir+"\Importado\"+cFil+"\"+aFiles[nI,1], FO_READWRITE+FO_SHARED)
        FRead( nHandle, cXml, 500000 )  

        //Realiza o Parser do arquivo XML (validação da estrutura)
        oXml := XmlParser(cXml,"_",@cError,@cWarning)
        
		//PRE-VALIDAÇÃO/PRE-CADASTRO DO CONTEUDO DO ARQUIVO XML, (VALIDAÇÃO MANUAL)
		lProcessa  := PreValidXML(oXml,@cChave,@cMensagem,ALLTRIM(aFiles[nI,1]))

	    If (lProcessa)
			//Carrega o Tipo de operação
			If Valtype(oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD) == "A"
				cOper := oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD[1]:_CODOPERACAO:TEXT
			Else
				cOper := oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD:_CODOPERACAO:TEXT
			EndIf  

			//Posiciona no cadastro do cliente
			SA1->(dbSetOrder(3))
			If !SA1->(DbSeek(xFilial("SA1")+PADR(alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTE:_CNPJCPF:TEXT),TamSX3("A1_CGC")[1],'')))
		   		cMensagem += "<li> Falha ao localizar cadastro do cliente no Protheus. O pedido de venda não foi integrado.</li>"  
				lOk := .F.
			EndIf

			If lOk
				aadd(aCabec,{"C5_TIPO"		,"N" ,Nil})
				aadd(aCabec,{"C5_CLIENTE"	,ALLTRIM(SA1->A1_COD),Nil})
				aadd(aCabec,{"C5_LOJACLI"	,ALLTRIM(SA1->A1_LOJA),Nil})   
				aadd(aCabec,{"C5_CONDPAG"	,oXml:_NF:_BLOCOA:_BLOCOB:_CONDPAGAMENTO:TEXT,Nil})
				aadd(aCabec,{"C5_P_BAND"	,oXml:_NF:_BLOCOA:_BLOCOB:_CONDPAGBAN:TEXT,Nil})
				aadd(aCabec,{"C5_P_TIPAG"	,oXml:_NF:_BLOCOA:_BLOCOB:_TIPOPAGAMENTO:TEXT,Nil})
				aadd(aCabec,{"C5_EMISSAO"	,stod(substr(oXml:_NF:_BLOCOA:_BLOCOB:_dataemisnf:TEXT,7,4)+substr(oXml:_NF:_BLOCOA:_BLOCOB:_dataemisnf:TEXT,1,2)+substr(oXml:_NF:_BLOCOA:_BLOCOB:_dataemisnf:TEXT,4,2)),Nil}) 
				cContent := "{HEADER:{"		+CRLF
				cContent += "C5_TIPO:N,"	+CRLF
				cContent += "C5_CLIENTE:"	+ALLTRIM(SA1->A1_COD)+"," +CRLF
				cContent += "C5_LOJACLI:"	+ALLTRIM(SA1->A1_LOJA)+", "  +CRLF
				cContent += "C5_CONDPAG:"	+oXml:_NF:_BLOCOA:_BLOCOB:_CONDPAGAMENTO:TEXT+"," +CRLF				        
				cContent += "C5_P_BAND:"	+oXml:_NF:_BLOCOA:_BLOCOB:_CONDPAGBAN:TEXT+"," +CRLF  
				cContent += "C5_P_TIPAG:"	+oXml:_NF:_BLOCOA:_BLOCOB:_TIPOPAGAMENTO:TEXT+"," +CRLF  
				cContent += "C5_EMISSAO:"	+oXml:_NF:_BLOCOA:_BLOCOB:_dataemisnf:TEXT+"," +CRLF
				If !Empty(oXml:_NF:_BLOCOA:_BLOCOB:_datavenc1:TEXT) .and. !Empty(oXml:_NF:_BLOCOA:_BLOCOB:_valorparcela1:TEXT)
					aadd(aCabec,{"C5_DATA1"		,stod(substr(oXml:_NF:_BLOCOA:_BLOCOB:_datavenc1:TEXT,7,4)+substr(oXml:_NF:_BLOCOA:_BLOCOB:_datavenc1:TEXT,1,2)+substr(oXml:_NF:_BLOCOA:_BLOCOB:_datavenc1:TEXT,4,2)),Nil}) 
					aadd(aCabec,{"C5_PARC1"		,val(oXml:_NF:_BLOCOA:_BLOCOB:_valorparcela1:TEXT),Nil})
					aadd(aCabec,{"C5_P_TIPG1"	,oXml:_NF:_BLOCOA:_BLOCOB:_TIPOPAGAMENTO1:TEXT,Nil})
					aadd(aCabec,{"C5_P_BAND1"	,oXml:_NF:_BLOCOA:_BLOCOB:_BANDEIRA1:TEXT,Nil})
					cContent += "C5_DATA1:"		+oXml:_NF:_BLOCOA:_BLOCOB:_datavenc1:TEXT+"," +CRLF
					cContent += "C5_PARC1:"		+oXml:_NF:_BLOCOA:_BLOCOB:_valorparcela1:TEXT+"," +CRLF
					cContent += "C5_P_TIPG1:"	+oXml:_NF:_BLOCOA:_BLOCOB:_TIPOPAGAMENTO1:TEXT+"," +CRLF 
					cContent += "C5_P_BAND1:"	+oXml:_NF:_BLOCOA:_BLOCOB:_BANDEIRA1:TEXT+"," +CRLF
				EndIf
				If !Empty(oXml:_NF:_BLOCOA:_BLOCOB:_datavenc2:TEXT) .and. !Empty(oXml:_NF:_BLOCOA:_BLOCOB:_valorparcela2:TEXT)
					aadd(aCabec,{"C5_DATA2"		,stod(substr(oXml:_NF:_BLOCOA:_BLOCOB:_datavenc2:TEXT,7,4)+substr(oXml:_NF:_BLOCOA:_BLOCOB:_datavenc2:TEXT,1,2)+substr(oXml:_NF:_BLOCOA:_BLOCOB:_datavenc2:TEXT,4,2)),Nil}) 
					aadd(aCabec,{"C5_PARC2"		,val(oXml:_NF:_BLOCOA:_BLOCOB:_valorparcela2:TEXT),Nil}) 	
					aadd(aCabec,{"C5_P_TIPG2"	,oXml:_NF:_BLOCOA:_BLOCOB:_TIPOPAGAMENTO2:TEXT,Nil})
					aadd(aCabec,{"C5_P_BAND2"	,oXml:_NF:_BLOCOA:_BLOCOB:_BANDEIRA2:TEXT,Nil})
					cContent += "C5_DATA2:"		+oXml:_NF:_BLOCOA:_BLOCOB:_datavenc2:TEXT+"," +CRLF
					cContent += "C5_PARC2:"		+oXml:_NF:_BLOCOA:_BLOCOB:_valorparcela2:TEXT+"," +CRLF
					cContent += "C5_P_TIPG2:"	+oXml:_NF:_BLOCOA:_BLOCOB:_TIPOPAGAMENTO2:TEXT+"," +CRLF 
					cContent += "C5_P_BAND2:"	+oXml:_NF:_BLOCOA:_BLOCOB:_BANDEIRA2:TEXT+"," +CRLF  
				EndIf
				If !Empty(oXml:_NF:_BLOCOA:_BLOCOB:_datavenc3:TEXT) .and. !Empty(oXml:_NF:_BLOCOA:_BLOCOB:_valorparcela3:TEXT)
					aadd(aCabec,{"C5_DATA3"		,stod(substr(oXml:_NF:_BLOCOA:_BLOCOB:_datavenc3:TEXT,7,4)+substr(oXml:_NF:_BLOCOA:_BLOCOB:_datavenc3:TEXT,1,2)+substr(oXml:_NF:_BLOCOA:_BLOCOB:_datavenc3:TEXT,4,2)),Nil}) 
					aadd(aCabec,{"C5_PARC3"		,val(oXml:_NF:_BLOCOA:_BLOCOB:_valorparcela4:TEXT),Nil}) 	
					aadd(aCabec,{"C5_P_TIPG3"	,oXml:_NF:_BLOCOA:_BLOCOB:_TIPOPAGAMENTO3:TEXT,Nil})
					aadd(aCabec,{"C5_P_BAND3"	,oXml:_NF:_BLOCOA:_BLOCOB:_BANDEIRA3:TEXT,Nil})
					cContent += "C5_DATA3:"		+oXml:_NF:_BLOCOA:_BLOCOB:_datavenc3:TEXT+"," +CRLF
					cContent += "C5_PARC3:"		+oXml:_NF:_BLOCOA:_BLOCOB:_valorparcela4:TEXT+"," +CRLF
					cContent += "C5_P_TIPG3:"	+oXml:_NF:_BLOCOA:_BLOCOB:_TIPOPAGAMENTO3:TEXT+"," +CRLF 
					cContent += "C5_P_BAND3:"	+oXml:_NF:_BLOCOA:_BLOCOB:_BANDEIRA3:TEXT+"," +CRLF  
				EndIf
				If !Empty(oXml:_NF:_BLOCOA:_BLOCOB:_datavenc4:TEXT) .and. !Empty(oXml:_NF:_BLOCOA:_BLOCOB:_valorparcela4:TEXT)
					aadd(aCabec,{"C5_DATA4"		,stod(substr(oXml:_NF:_BLOCOA:_BLOCOB:_datavenc4:TEXT,7,4)+substr(oXml:_NF:_BLOCOA:_BLOCOB:_datavenc4:TEXT,1,2)+substr(oXml:_NF:_BLOCOA:_BLOCOB:_datavenc4:TEXT,4,2)),Nil}) 
					aadd(aCabec,{"C5_PARC4"		,val(oXml:_NF:_BLOCOA:_BLOCOB:_valorparcela4:TEXT),Nil})
					aadd(aCabec,{"C5_P_TIPG4"	,oXml:_NF:_BLOCOA:_BLOCOB:_TIPOPAGAMENTO4:TEXT,Nil})
					aadd(aCabec,{"C5_P_BAND4"	,oXml:_NF:_BLOCOA:_BLOCOB:_BANDEIRA4:TEXT,Nil})
					cContent += "C5_DATA4:"		+oXml:_NF:_BLOCOA:_BLOCOB:_datavenc4:TEXT+"," +CRLF
					cContent += "C5_PARC4:"		+oXml:_NF:_BLOCOA:_BLOCOB:_valorparcela4:TEXT+"," +CRLF 
					cContent += "C5_P_TIPG4:"	+oXml:_NF:_BLOCOA:_BLOCOB:_TIPOPAGAMENTO4:TEXT+"," +CRLF 
					cContent += "C5_P_BAND4:"	+oXml:_NF:_BLOCOA:_BLOCOB:_BANDEIRA4:TEXT+"," +CRLF  
				EndIf
				aadd(aCabec,{"C5_TPFRETE"	,oXml:_NF:_BLOCOA:_BLOCOB:_TIPOFRETE:TEXT,Nil})
				aadd(aCabec,{"C5_TRANSP"	,oXml:_NF:_BLOCOA:_BLOCOB:_TRANSPORTADORA1:TEXT,Nil})
				aadd(aCabec,{"C5_FRETE"		,val(oXml:_NF:_BLOCOA:_BLOCOB:_VALORFRETE1:TEXT),Nil})
				cContent += "C5_TPFRETE:"	+oXml:_NF:_BLOCOA:_BLOCOB:_TIPOFRETE:TEXT+"," +CRLF
				cContent += "C5_TRANSP:"	+oXml:_NF:_BLOCOA:_BLOCOB:_TRANSPORTADORA1:TEXT+"," +CRLF 
				cContent += "C5_FRETE:"		+oXml:_NF:_BLOCOA:_BLOCOB:_VALORFRETE1:TEXT+"," +CRLF 
				if !Empty(oXml:_NF:_BLOCOA:_BLOCOB:_TRANSPORTADORA2:TEXT) .and. !Empty(oXml:_NF:_BLOCOA:_BLOCOB:_VALORFRETE2:TEXT)
					aadd(aCabec,{"C5_P_TRAN2"	,oXml:_NF:_BLOCOA:_BLOCOB:_TRANSPORTADORA2:TEXT,Nil})
					aadd(aCabec,{"C5_P_FRET2"	,val(oXml:_NF:_BLOCOA:_BLOCOB:_VALORFRETE2:TEXT),Nil})
					cContent += "C5_P_TRAN2:"	+oXml:_NF:_BLOCOA:_BLOCOB:_TRANSPORTADORA2:TEXT+"," +CRLF 
					cContent += "C5_P_FRET2:"	+oXml:_NF:_BLOCOA:_BLOCOB:_VALORFRETE2:TEXT+"," +CRLF 
				EndIF
				if !Empty(oXml:_NF:_BLOCOA:_BLOCOB:_TRANSPORTADORA3:TEXT) .and. !Empty(oXml:_NF:_BLOCOA:_BLOCOB:_TRANSPORTADORA3:TEXT)
					aadd(aCabec,{"C5_P_TRAN3"	,oXml:_NF:_BLOCOA:_BLOCOB:_TRANSPORTADORA3:TEXT,Nil})
					aadd(aCabec,{"C5_P_FRET3"	,val(oXml:_NF:_BLOCOA:_BLOCOB:_VALORFRETE3:TEXT),Nil})
					cContent += "C5_P_TRAN3:"	+oXml:_NF:_BLOCOA:_BLOCOB:_TRANSPORTADORA3:TEXT+"," +CRLF 
					cContent += "C5_P_FRET3:"	+oXml:_NF:_BLOCOA:_BLOCOB:_VALORFRETE3:TEXT+"," +CRLF 
				EndIf 
				If SC5->(FieldPos("C5_P_ENDEN")) <> 0
					aadd(aCabec,{"C5_P_ENDEN",cCodEndEnt							 ,NIL})
					cContent += "C5_P_ENDEN:"	+cCodEndEnt+"," +CRLF
				EndIf 
				If SC5->(FieldPos("C5_P_TPPV")) <> 0 .and.;
					VALTYPE(XmlChildEx(oXML:_NF:_BLOCOA:_BLOCOB,"_PROTOCOLO") ) == "O" .and. !EMPTY(oXML:_NF:_BLOCOA:_BLOCOB:_PROTOCOLO:TEXT)
					aadd(aCabec,{"C5_P_TPPV",ALLTRIM(oXML:_NF:_BLOCOA:_BLOCOB:_PROTOCOLO:TEXT),NIL})
					cContent += "C5_P_TPPV:"+ALLTRIM(oXML:_NF:_BLOCOA:_BLOCOB:_PROTOCOLO:TEXT)+"," +CRLF
				EndIf

				aadd(aCabec,{"C5_P_CHAVE"	,cChave,Nil})
				aadd(aCabec,{"C5_P_DTRAX"	,oXml:_NF:_BLOCOA:_BLOCOB:_NUMPEDIDO:TEXT,Nil})
				aadd(aCabec,{"C5_P_WLDPAY"	,oXml:_NF:_BLOCOA:_BLOCOB:_WORLDPAY_ID:TEXT,Nil})
				aadd(aCabec,{"C5_P_NSHIP"	,oXml:_NF:_BLOCOA:_BLOCOB:_NUMSHIPMENT:TEXT,Nil})
				aadd(aCabec,{"C5_MENNOTA"	,"Pedido Datatrax:" + cChave,Nil})
				cContent += "C5_P_CHAVE:"	+cChave+"," +CRLF
				cContent += "C5_P_DTRAX:"	+oXml:_NF:_BLOCOA:_BLOCOB:_NUMPEDIDO:TEXT+"," +CRLF 
				cContent += "C5_P_WLDPAY:"	+oXml:_NF:_BLOCOA:_BLOCOB:_WORLDPAY_ID:TEXT+"," +CRLF 
				cContent += "C5_P_NSHIP:"	+oXml:_NF:_BLOCOA:_BLOCOB:_NUMSHIPMENT:TEXT+"," +CRLF 
				cContent += "C5_MENNOTA: Pedido Datatrax:" +cChave+"," +CRLF 
				cContent += "}ITENS{" +CRLF    

				If Valtype(oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD) == "A"
					For nX := 1 To len(oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD) 
						aLinha := {}
						aadd(aLinha,{"C6_ITEM"		,StrZero(nX,2),Nil})
						aadd(aLinha,{"C6_PRODUTO"	,oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD[nX]:_CODPRODUTO:TEXT,Nil})
						aadd(aLinha,{"C6_QTDVEN"	,val(oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD[nX]:_QUANTIDADE:TEXT),Nil})
						aadd(aLinha,{"C6_PRUNIT"	,val(oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD[nX]:_PRECOUNIT:TEXT),Nil})
						aadd(aLinha,{"C6_OPER"		,oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD[nX]:_CODOPERACAO:TEXT,Nil}) 
						aadd(aLinha,{"C6_PEDCLI"	,oXml:_NF:_BLOCOA:_BLOCOB:_NUMPEDIDO:TEXT,Nil}) 
						cContent += "{C6_ITEM:"		+StrZero(nX,2)+"," +CRLF 
						cContent += "C6_PRODUTO:"	+oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD[nX]:_CODPRODUTO:TEXT+"," +CRLF 
						cContent += "C6_QTDVEN:"	+oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD[nX]:_QUANTIDADE:TEXT+"," +CRLF 
						cContent += "C6_PRUNIT:"	+oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD[nX]:_PRECOUNIT:TEXT+"," +CRLF 
						cContent += "C6_OPER:"		+oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD[nX]:_CODOPERACAO:TEXT+"}" +CRLF 
						cContent += "C6_PEDCLI:"	+oXml:_NF:_BLOCOA:_BLOCOB:_NUMPEDIDO:TEXT+"}" +CRLF 
						If SC6->(FieldPos("C6_P_OPER")) <> 0//Gravação da operação enviada no arquivo.
							aadd(aLinha,{"C6_P_OPER"	,oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD[nX]:_CODOPERACAO:TEXT,Nil}) 
						EndIf 
						aadd(aItens,aLinha)
					Next nX
				Else 
					aLinha := {}																	
					aadd(aLinha,{"C6_ITEM","01",Nil})
					aadd(aLinha,{"C6_PRODUTO"	,oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD:_CODPRODUTO:TEXT,Nil})
					aadd(aLinha,{"C6_QTDVEN"	,val(oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD:_QUANTIDADE:TEXT),Nil})
					aadd(aLinha,{"C6_PRUNIT"	,val(oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD:_PRECOUNIT:TEXT),Nil})
					aadd(aLinha,{"C6_OPER"		,oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD:_CODOPERACAO:TEXT,Nil})                                                                          
					aadd(aLinha,{"C6_PEDCLI"	,oXml:_NF:_BLOCOA:_BLOCOB:_NUMPEDIDO:TEXT,Nil}) 
					cContent += "C6_ITEM:01,"	+CRLF 
					cContent += "C6_PRODUTO:"	+oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD:_CODPRODUTO:TEXT+"," +CRLF 
					cContent += "C6_QTDVEN:"	+oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD:_QUANTIDADE:TEXT+"," +CRLF 
					cContent += "C6_PRUNIT:"	+oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD:_PRECOUNIT:TEXT+"," +CRLF 
					cContent += "C6_OPER:"		+oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD:_CODOPERACAO:TEXT+"}" +CRLF 
					cContent += "C6_PEDCLI:"	+oXml:_NF:_BLOCOA:_BLOCOB:_NUMPEDIDO:TEXT+"}" +CRLF 
					aadd(aItens,aLinha)
				EndIF  
				cContent += "}}" +CRLF 

				//Inicia a transação
				BeginTran()

			    //Trata qual item será enviado de acordo com o estoque
				//N6Item( aItens ) //Considerar o ajuste na variavel de JSON

				//Faz o rateio do frete para os itens do pedido 
				N6RatFret( aCabec , aItens ) 

				//incluindo o pedido de venda via execAuto
 				MSExecAuto({|x,y,z|Mata410(x,y,z)},aCabec,aItens,3)

				IF (lMsErroAuto)
					GrvRastro(cFil,cChave,'',DTOS(aCabec[Ascan(aCabec,{|x|AllTrim(x[1])=="C5_EMISSAO"})][2]),.F.)

				   	//Caso houver algum erro da geração do pedido de venda
				   	//Pego todos os erros e envio para o email.     				              		                         	
					cLogErro := MostraErro()  

					//Envia email com erro
					sendMail(cData,cHora,aFiles[nI,1],cChave,,"Erro na geração do pedido de venda, segue o erro abaixo:<br>"+cLogErro,cFil) 

					//Fecho o arquivo 
					FCLOSE(nHandle)

					//move o arquivo com erro
					frename(cDir+"\Importado\"+cFil+"\"+aFiles[nI,1],cDir+"\Erro\"+cFil+"\"+SubStr(aFiles[nI,1],1,len(aFiles[nI,1])-4)+"p"+DTOS(date())+"h"+SubStr( Time(), 1, 2 )+SubStr( Time(), 4, 2 )+SubStr( Time(), 7, 2 )+".Err")

					//desarma a transação                     
					DisarmTransaction()

					 //destrava os processos
					msUnlockAll() 

					//executo a batch para mover o arquivo processado para a pasta "/nf/error" no servidor de SFTP da doTerra (datatrax)
					cFile := @cDirFisico+"\datatrax2.bat "+ alltrim(aFiles[nI,1])  + " 3 " + cfil
					WaitRunSrv(@cfile,.T.,@cDirFisico)  

					lMsErroAuto := .F.
				Else
					GrvRastro(cFil,cChave,SC5->C5_NUM,DTOS(aCabec[Ascan(aCabec,{|x|AllTrim(x[1])=="C5_EMISSAO"})][2]),.T.)
					
					GrvRastroAdic(cFil,cChave,oXml)
					/*RETIRADO, pois no N6FAT009 esta sendo chamada continuamente uma rotina para liberação de estoque.
					//Validação de Estoque
					aRet := u_retSB2(SC5->C5_NUM,cfil,"2") 

					If len(aRet) == 0  
						// Liberacao de pedido
						Ma410LbNfs(2,@aPvlNfs,@aBloqueio)

						// Checa itens liberados			
						Ma410LbNfs(1,@aPvlNfs,@aBloqueio)    

						//Verificação de Saldo em Estoque (Rotina Padrão) 
						If Empty(aBloqueio) .And. !Empty(aPvlNfs) 
							//Caso não tenha saldo de estoque, concateno os itens sem estoque para envio de email ao usuário
							For nR := 1 To Len( aBloqueio )
								cLogErro += "Pedido " + alltrim(aBloqueio[ nR ][ 1 ]) + " - Produto " + Alltrim(aBloqueio[ nR ][ 4 ]) + " bloqueado por falta de estoque. <br>"
							Next nR

							if !empty(cLogErro)
								//Envio o email com o erro
								sendMail(cData,cHora,aFiles[nI,1],cChave,,cLogErro,cFil)
							EndIf
						Else 
							If oXml:_NF:_BLOCOA:_BLOCOB:_FLAG:TEXT == "02"	
								//Envio o Picking list para a Fedex
								u_N6WS004(cChave) 
							Else
								//Atualizo o status para 03 
								TCSqlExec("UPDATE "+RetSqlName("SC5")+" SET C5_P_STFED='03',C5_P_DTFED='"+DTOS(ddatabase)+"' WHERE C5_P_CHAVE='"+cChave+"' AND D_E_L_E_T_='' AND C5_FILIAL='"+cFil+"'") 
							EndIF 

							aBloqueio := {} 
							aPvlNfs   := {}
						Endif 
					Else
						//Caso não tenha saldo de estoque, concateno os itens sem estoque para envio de email ao usuário
						For nR := 1 To Len( aRet )
							cLogErro += "Pedido " + SC5->C5_NUM + " - Produto " + Alltrim(aRet[nR]) + " bloqueado por falta de estoque. <br>"
						Next nR 

						//Envio o email com o erro
						sendMail(cData,cHora,aFiles[nI,1],cChave,,cLogErro,cFil)
					EndIf*/

					//encerra transação				        
					EndTran()

					//destrava todos os processos
					MsUnlockAll() 

					//executo a batch para mover o arquivo processado para a pasta "/nf/archive" no servidor de SFTP da doTerra (datatrax)
					cFile := @cDirFisico+"\datatrax2.bat "+ alltrim(aFiles[nI,1])  + " 1 " + cFil
					WaitRunSrv(@cfile,.T.,@cDirFisico) 

					//fecha o arquivo importado
					FCLOSE(nHandle)

					//move o arquivo lido para a pasta de processado
					nFileStatus := frename(cDir+"\Importado\"+cFil+"\"+aFiles[nI,1],cDir+"\Processado\"+cFil+"\"+SubStr(aFiles[nI,1],1,len(aFiles[nI,1])-4)+"p"+DTOS(date())+"h"+SubStr( Time(), 1, 2 )+SubStr( Time(), 4, 2 )+SubStr( Time(), 7, 2 )+".PRC")

					/*IF nFileStatus == -1
						cMensagem := "Algum processo interno no servidor, impediu mover o arquivo Datatrax ("+cDir+"\Importado\"+cFil+"\"+aFiles[nI,1]+")<br> para a pasta de arquivos processados, favor comunicar o erro para a equipe de TI."
						sendMail(cData,cHora,aFiles[nI,1],cChave,,cMensagem)
					Endif*/

					aRet :={} 	  
				EndIf
			Else
				//Fecho o arquivo 
				FCLOSE(nHandle)

				//Envio o email 
				sendMail(cData,cHora,aFiles[nI,1],cChave,'',cMensagem+"</ul>",cFil)

				//move o arquivo com erro
				frename(cDir+"\Importado\"+cFil+"\"+aFiles[nI,1],cDir+"\Erro\"+cFil+"\"+SubStr(aFiles[nI,1],1,len(aFiles[nI,1])-4)+"p"+DTOS(date())+"h"+SubStr( Time(), 1, 2 )+SubStr( Time(), 4, 2 )+SubStr( Time(), 7, 2 )+".Err")

				//executo a batch para mover o arquivo processado para a pasta "/nf/error" no servidor de SFTP da doTerra (datatrax)
				cFile := @cDirFisico+"\datatrax2.bat "+ alltrim(aFiles[nI,1]) + " 3 " + cFil
				WaitRunSrv(@cfile,.T.,@cDirFisico) 

			EndIF   
		Else
	   	 	//Fecho o arquivo 
			FCLOSE(nHandle)

			//Envio o email 
			sendMail(cData,cHora,aFiles[nI,1],cChave,'',cMensagem+"</ul>",cFil)

			//move o arquivo com erro no Protheus
			frename(cDir+"\Importado\"+cFil+"\"+aFiles[nI,1],cDir+"\Erro\"+cFil+"\"+SubStr(aFiles[nI,1],1,len(aFiles[nI,1])-4)+"p"+DTOS(date())+"h"+SubStr( Time(), 1, 2 )+SubStr( Time(), 4, 2 )+SubStr( Time(), 7, 2 )+".Err")

			//Execução do batch para mover o arquivo processado para a pasta "/nf/error" no servidor de SFTP da doTerra (datatrax)
			cFile := @cDirFisico+"\datatrax2.bat "+ alltrim(aFiles[nI,1]) + " 3 " + cFil
			WaitRunSrv(@cfile,.T.,@cDirFisico) 
		EndIf

		ErrorBlock(bError)
        
        //Tratamento de erro de smartclient 
		RECOVER 

		//Fecho o arquivo 
		FCLOSE(nHandle)

		//Mensagem 
		cMensagem := "<br>O arquivo ("+aFiles[nI,1]+")  está ocasionando um erro interno na rotina, impossibilitando a importação"
		cMensagem += "do pedido de vendas para o TOTVS. Favor contatar a equipe da doTerra responsável pelo Datatrax e reportar o erro abaixo <br><hr><b>Erro:</b><br>"  
		cMensagem += "<font color = 'red'>"+cRetError+"</font>" 
		If !empty(@cError) .and. !empty(@cWarning)
	   		cMensagem += "<font color = 'blue'><b>XML MESSAGE ERROR</b> <br>"+@cError + @cWarning +"</font>"
	   	EndIF	

		//Envio o email 
		sendMail(cData,cHora,cDir+"\Importado\"+cFil+"\"+aFiles[nI,1],'','',cMensagem,cFil)

		//Aguarda 3s para carregar o anexo e enviar para o email
		Sleep(3000)

		//move o arquivo com erro no Protheus
  		frename(cDir+"\Importado\"+cFil+"\"+aFiles[nI,1],cDir+"\Erro\"+cFil+"\"+SubStr(aFiles[nI,1],1,len(aFiles[nI,1])-4)+"p"+DTOS(date())+"h"+SubStr( Time(), 1, 2 )+SubStr( Time(), 4, 2 )+SubStr( Time(), 7, 2 )+".Err") 

		//Execução do batch para mover o arquivo processado para a pasta "/nf/error" no servidor de SFTP da doTerra (datatrax)
		cFile := @cDirFisico+"\datatrax2.bat "+ alltrim(aFiles[nI,1]) + " 3 " + cFil
	  	WaitRunSrv(@cfile,.T.,@cDirFisico) 

        //limpa variavel 
  		cFile := ""

	   	ErrorBlock( bError )
	END SEQUENCE 

	//limpo as Variaveis e Arrays
	cMensagem 		:= "<br><b>Pedido de venda não gerado pelos seguinte(s) motivo(s):</b><br><ul>"
	cLogErro  		:= ""
	cChave   		:= ""
	aLinha	  		:= {}
	aItens    		:= {}
	aCabec    		:= {}
	aTelefone 		:= {}
	aEmail    		:= {}
	aRet      		:= {}
	aBloqueio 		:= {} 
	aPvlNfs   		:= {}
	lOk      		:= .T.
	lMsErroAuto 	:= .F.
	lAutoErrNoFile 	:= .F.
    lMsHelpAuto	   	:= .T.
    aFiles[nI,1]	:= ""
    oXml			:= nil
    nHandle			:= nil

Next nI

Return 

/*-----------------------------------------------------  
Static function para preparar o corpo do email 
para envio
-------------------------------------------------------*/
*----------------------------------------------------------------------------*
Static Function sendMail(cData,cHora,cArquivo,cChave,cConteudo,cMensagem,cFil)
*----------------------------------------------------------------------------*
Local cEmail   := ""
Local cAssunto := "" 
Local cDir     := GETMV("MV_P_00119")
Local aArquivo := {}

If empty(cChave)
	aArquivo    := StrTokArr(alltrim(cArquivo),"\")
Endif

//Corpo do email
cEmail:="<font size='3' face='Tahoma, Geneva, sans-serif'>"
cEmail+="<p><B>Origem:</b> "+iif(cFil == "01","Venda Presencial","E-Commerce (Datatrax)")+"<br><b>Arquivo:</b> "+IIF (empty(cChave),aArquivo[LEN(aArquivo)],cArquivo)+"<br /><b>Pedido de venda(DataTrax):</b> "+cChave+" <br> <b>Hora:</b> "+cHora+"<br /><b>Data:</b> "+cData+"</p>"
cEmail+="<p>Falha na importação do pedido de venda (Datatrax)</p></font>"

cEmail+="<table width='100%' border='0' cellspacing='1' cellpadding='1' align='center'><tr>"
cEmail+="<td width='231' align='center' bgcolor='#666666'><font size='3' face='Tahoma, Geneva, sans-serif' color='#BABB00'>Mensagem de Erro</font></td></tr>"

cEmail+="<tr><td  bgcolor='#EFEFEF'><font size='2' face='Tahoma, Geneva, sans-serif'>"+cMensagem+"</font></td></tr>" 
cEmail+="</table><br><br><br>"					

//Envio de WorkFlow
IF empty(cChave) // Condição especifica para o RECOVER (TRATAMENTO DE ERRO)
	u_N6GEN001(cEmail,"Erro Importação Pedido Datatrax - "+aArquivo[LEN(aArquivo)],cArquivo,alltrim(GETMV("MV_P_00115")))
	u_N6GEN002("SC5","E",cArquivo,"DataTrax","Totvs",aArquivo[LEN(aArquivo)],cConteudo,cMensagem) 
Else
	If AT(" - Produto ",cMensagem) == 0
	    cAssunto := "Erro Importação Pedido Datatrax - "+cArquivo
	Else 
		cAssunto := "Pedido importado com falta de produto - "+cChave
	EndIf

	u_N6GEN001(cEmail,cAssunto,,alltrim(GETMV("MV_P_00115"))) 
	u_N6GEN002("SC5","E",cArquivo,"DataTrax","Totvs",cChave,cConteudo,cMensagem) 
Endif

Return     

/*
Função		: N6Item
Autor 		: Anderson Arais
Objetivo 	: Trata qual item será enviado de acordo com o estoque
Data 		: 02/07/2018
*/                        
*----------------------------*
Static Function N6Item(aItens)                                        
*----------------------------*  
  //Fazer tratamento aqui
Return

/*
Função........: N6RatFret
Autor.........: Leandro Brito 
Objetivo......: Efetuar rateio do frete para os itens e calculo do IPI
Data..........: 16/04/2018
*/                        
*------------------------------------*
Static Function N6RatFret(aCab,aItens)
*------------------------------------*  
Local nPosFrete := Ascan(aCab, {|x| AllTrim(x[1]) == "C5_FRETE" } )  
Local nPosCli 	:= Ascan(aCab, {|x| AllTrim(x[1]) == "C5_CLIENTE" } )  
Local nPosLjCli := Ascan(aCab, {|x| AllTrim(x[1]) == "C5_LOJACLI" } )  
Local nPosPrc   := Ascan(aItens[1], {|x| AllTrim(x[1]) == "C6_PRUNIT" } )  
Local nPosQtd   := Ascan(aItens[1], {|x| AllTrim(x[1]) == "C6_QTDVEN" } ) 
Local nPosCod   := Ascan(aItens[1], {|x| AllTrim(x[1]) == "C6_PRODUTO" } ) 
Local nPosOper  := Ascan(aItens[1], {|x| AllTrim(x[1]) == "C6_OPER" } ) 

Local i                                 
Local lFreteBas
Local cTes

Local nTotVal   := 0  
Local nValFrete

Local nDecPrc   := TamSX3('C6_PRCVEN')[2]
Local nAliq 

Local nFreteItem
Local nBaseIPI

Local nNewPrc
Local cCodProd

If ( nPosFrete > 0 ) .And.  ( nPosPrc > 0 ) .And. ( nPosQtd > 0 )
	nValFrete := aCab[ nPosFrete ][ 2 ]

	For i := 1 To Len( aItens )
		nTotVal  += ( aItens[ i ][ nPosPrc ][ 2 ] * aItens[ i ][ nPosQtd ][ 2 ] )
	Next i
	
	/** Faz rateio do frete pela quantidade e insere no valor do produto somente para calculo do IPI*/
	dbSelectArea("SB1")
	SB1->( DbSetOrder( 1 ) )
	For i := 1 To Len( aItens )
		cCodProd := aItens[ i ][ nPosCod ][ 2 ]

		If  /*cCodProd $ "I|IPA"*/(RIGHT(cCodProd,1) == "I" .or. RIGHT(cCodProd,3) == "IPA" ) .And. SB1->( DbSeek( xFilial( 'SB1' ) + cCodProd ) ) .And. SB1->B1_IPI > 0 
			nAliq := SB1->B1_IPI                      

			/** Retorna TES Inteligente dependendo do tipo de operação, pois preciso saber se a TES considera o Frete na base de calculo do IPI*/                                             
			cTes := ""
			If !Empty( aItens[ i ][ nPosOper ][ 2 ] )
				cTes := MaTesInt( 2,aItens[ i ][ nPosOper ][ 2 ],aCab[ nPosCli ][ 2 ],aCab[ nPosLjCli ][ 2 ],"C",cCodProd , "" )          
			EndIf			

			lFreteBas := .F.
			If !Empty( cTes ) .And. nValFrete > 0 .And. SF4->( DbSeek( xFilial( 'SF4' ) + cTes ) ) .And. SF4->F4_IPIFRET $ 'S,1' 
				lFreteBas := .T.
			EndIf   
			
			/** Efetua rateio do frete pelo Valor*/
			nFreteItem := 0
			If ( lFreteBas )
				nFreteItem := ( aItens[ i ][ nPosPrc ][ 2 ] * aItens[ i ][ nPosQtd ][ 2 ] ) / nTotVal * nValFrete 
			EndIf

			/** Calcula base do IPI retirando o IPI que está embutido no preço*/		
			nBaseIPI := ( aItens[ i ][ nPosPrc ][ 2 ] * aItens[ i ][ nPosQtd ][ 2 ] ) / ( 1 + ( nAliq / 100 ) ) 
			nBaseIPI += ( ( nFreteItem ) / ( 1 + ( nAliq / 100 ) )  )
			/** Tira o Frete do preço unitario para o sistema calcula novamente pela Tes*/
			nNewPrc  :=  ( nBaseIPI - nFreteItem ) / aItens[ i ][ nPosQtd ][ 2 ]
			 
			aItens[ i ][ nPosPrc ][ 2 ] := Round( nNewPrc , nDecPrc ) 
		EndIf	
	Next i
    SB1->(DbCloseArea())
EndIf  

Return

/*-----------------------------------------------------  
User function para retornar o saldo do estoque
Produto
-----------------------------------------------------*/
*-------------------------------------* 
User Function retSB2(cValue,cFil,cTipo)
*-------------------------------------*
Local aRet :={} 
Local cSQL := ""
Local AreaTMP  := "TMPSC6"//GetNextAlias()

If Select(AreaTMP)>0
	(AreaTMP)->(DbCloseArea())
EndIf

SB2->(dbSetOrder(1))
If cTipo == "1" 
	SB2->(dbSeek(xFilial("SB2") + cValue + "01"))
	IF SaldoSb2() > 0
       	Aadd(aRet,SB2->B2_COD)
    EndIf        
Else
	cSQL := "SELECT C6_PRODUTO 
	cSQL += " FROM "+retsqlname("SC6")
	cSQL += " WHERE C6_NUM = '"+cValue+"'
	cSQL += " 	AND C6_FILIAL = '"+cFil+"'
	cSQL += " 	AND D_E_L_E_T_ = ''" 

	DbUseArea(.T., "TOPCONN", TcGenQry(,,ChangeQuery(cSQL)), AreaTMP, .F., .T.)

	While !(AreaTMP)->(EOF())
		SB2->(dbSeek(xFilial("SB2") + (AreaTMP)->C6_PRODUTO + "01"))
		//caso houver algum item com saldo negativo gravo o produto no array
		If SaldoSb2() <= 0
	       	Aadd(aRet,(AreaTMP)->C6_PRODUTO)
	    EndIf
		(AreaTMP)->(dbSkip())	        
	EndDo    
EndIf

If Select(AreaTMP)>0
	(AreaTMP)->(DbCloseArea())
EndIf
  
Return aRet    

//Static function para retornar o erro de smartclient
*-----------------------------*
Static Function MyError(oError)
*-----------------------------*
cRetError := oError:Description + oError:ErrorStack
BREAK
Return (Nil)
                    
//Manutenção de cadastro de cliente
*--------------------------------*
Static Function ManutCliente(oXml)
*--------------------------------*
Local cMsgRet	:= ""
Local cLogErro	:= ""
Local aCliente	:= {}

Private lMsErroAuto    := .F.
Private lAutoErrNoFile := .F.
Private lMsHelpAuto	   := .T. 

dbSelectArea("SA1")
SA1->(dbSetOrder(3))

aadd(aCliente,{"A1_CGC"		,alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTE:_CNPJCPF:TEXT)    	  			  														,NIL}) 
aadd(aCliente,{"A1_NATUREZ"	,"1001"                                               							  													,NIL})
aadd(aCliente,{"A1_CONTA"	,"11211001"                                           					  															,NIL})
aadd(aCliente,{"A1_CODPAIS"	,"01058"                                             					  								 							,NIL})
aadd(aCliente,{"A1_TIPO"	,"F"																	  															,NIL}) 
aadd(aCliente,{"A1_CONTRIB" ,"2"																	  					  			  							,NIL})
aadd(aCliente,{"A1_PESSOA"	,alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTE:_pessoaFisJur:TEXT)  							  					  					,NIL})
aadd(aCliente,{"A1_NOME"	,alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTE:_razaoSocial:TEXT)   							  					  					,NIL})
aadd(aCliente,{"A1_NREDUZ"	,alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTE:_razaoSocial:TEXT)  							  					  					  	,NIL})
aadd(aCliente,{"A1_END"		,alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTE:_endereco:TEXT)+" "+alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTE:_numero:TEXT)				,NIL})  				
aadd(aCliente,{"A1_EST"		,alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTE:_uf:TEXT)            							  					  					,NIL})
aadd(aCliente,{"A1_COD_MUN"	,alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTE:_codMunicipio:TEXT)  							  					  					,NIL})
aadd(aCliente,{"A1_BAIRRO"	,alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTE:_bairro:TEXT)      				  			  					  					  	,NIL}) 
aadd(aCliente,{"A1_CEP"		,alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTE:_CEP:TEXT)										  					  					,NIL})
aadd(aCliente,{"A1_ENDCOB"	,alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTECOB:_enderecocob:TEXT)+" "+alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTECOB:_numerocob:TEXT)	,NIL}) 
aadd(aCliente,{"A1_ESTC"	,alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTECOB:_ufcob:TEXT)          																,NIL}) 
aadd(aCliente,{"A1_MUNC"	,alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTECOB:_descMunicipiocob:TEXT)					  					  					  	,NIL})
aadd(aCliente,{"A1_CEPC"	,alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTECOB:_cepcob:TEXT)								  					  					  	,NIL})
aadd(aCliente,{"A1_EMAIL"	,alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTE:_email:TEXT)									  					  					  	,NIL})
aadd(aCliente,{"A1_TEL"		,alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTE:_telefone:TEXT)								  					  					  	,NIL})
If SA1->(FieldPos("A1_P_DTRAX")) <> 0 .and. valtype(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTE:_codCliente:TEXT)=="C"
	aadd(aCliente,{"A1_P_DTRAX",alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTE:_codCliente:TEXT) 				  					  					  			,NIL})
EndIf 

//Verifica o Tipo de Manutenção
nTipo := 3
If SA1->(DbSeek(xFilial("SA1")+PADR(alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTE:_CNPJCPF:TEXT),TamSX3("A1_CGC")[1],'')))
	nTipo := 4
	aadd(aCliente,{"A1_COD"    ,ALLTRIM(SA1->A1_COD)									,NIL})
  	aadd(aCliente,{"A1_LOCAL"  ,"01"								  					,NIL})
EndIf

//Ajusta o inicializador padrão, quando estiver errado.
SX3->(DbSetOrder(2))
If SX3->(DbSeek("A1_COD"))
	If ALLTRIM(SX3->X3_CAMPO) == "A1_COD" .and. ALLTRIM(SX3->X3_RELACAO) <> 'GETSX8NUM("SA1")'
		SX3->(RecLock("SX3",.F.))
		SX3->X3_RELACAO := 'GETSX8NUM("SA1")'
		SX3->(MsUnlock())
	EndIf
EndIf

//Execauto
MSExecAuto({|x,y| Mata030(x,y)},aCliente,nTipo) //3=Inclusão/4=Alteração

IF lMsErroAuto
	cLogErro  := MostraErro()
	RollBackSX8()                                
	cMsgRet += "Houve um problema na "+IIF(nTipo==3,"Inclusão","Alteração")+" do cadastro do cliente. <br><hr><br><b>Erro</b><br>"+cLogErro
Else
	ConfirmSX8()
EndIf

lMsErroAuto    := .F. 
lAutoErrNoFile := .F.
lMsHelpAuto	   := .T.

SA1->(DbCloseArea())    

Return cMsgRet

/*
Funcao      : PreValidXML
Parametros  : 
Retorno     : 
Objetivos   : Pre-Validação de Arquivo XML
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*------------------------------------------------------*
Static Function PreValidXML(oXml,cChave,cMensagem,cFile)
*------------------------------------------------------*
Local nY, i
Local lRet		:= .T.
Local lCliOK	:= .T.
Local lCliEntOK	:= .T.
Local lXMLOk	:= .T.
Local cLogZX2	:= ""
Local cOper		:= ""
Local cCPF		:= ""
Local cCombo	:= ""
Local cMsgCombo := ""
Local aTAGBlocoB:= {}
Local aTAGCli	:= {}
Local aCombo	:= {}
             
//Gravação do nome do arquivo em processamento
cLogZX2 := "LOG DE PROCESSAMENTO:"+CRLF
cLogZX2 += "Arquivo: "+cFile+CRLF

//Validação da Estrutura e campos obrigatorios.
//Dependendo do erro de estrutura, não continua as validações
If VALTYPE(oXML)=="O"
	If VALTYPE(XmlChildEx(oXML,"_NF") )=="O"
		If VALTYPE(XmlChildEx(oXML:_NF,"_BLOCOA") )=="O"
			If VALTYPE(XmlChildEx(oXML:_NF:_BLOCOA,"_BLOCOB") )=="O"
				aTAGBlocoB := {"_NUMPEDIDO","_CONDPAGBAN","_CONDPAGAMENTO","_WORLDPAY_ID","_TIPOFRETE","_FLAG",;
							"_TRANSPORTADORA1","_TIPOPAGAMENTO","_CLIENTE","_CLIENTECOB","_CLIENTEENT",;
							"_CONDPAGBAN","_BANDEIRA1","_BANDEIRA2","_BANDEIRA3","_BANDEIRA4"}
				For nY:=1 to len(aTAGBlocoB)
					If VALTYPE(XmlChildEx(oXML:_NF:_BLOCOA:_BLOCOB,aTAGBlocoB[nY]) )<>"O"
						cMensagem	+= "<li>Arquivo com estrutura inválida (TAG ausente: 'oXML:_NF:_BLOCOA:_BLOCOB:"+aTAGBlocoB[nY]+"').</li>" 
						cLogZX2		+= "+ Arquivo com estrutura inválida (TAG ausente: 'oXML:_NF:_BLOCOA:_BLOCOB:"+aTAGBlocoB[nY]+"')."+CRLF
						lXMLOk		:= .F.
					Else
						DO CASE 
							CASE aTAGBlocoB[nY] == "_NUMPEDIDO"
								If EMPTY(cChave := ALLTRIM(oXml:_NF:_BLOCOA:_BLOCOB:_NUMPEDIDO:TEXT))
									cChave		:= cFile//torna a chave o nome do arquivo
									cMensagem	+= "<li> O campo número do pedido de venda do Datatrax está vazio e o pedido de venda não foi gravado.</li>" 
									cLogZX2		+= "+ O número do pedido de venda do Datatrax está vazio, pedido não foi integrado."+CRLF
									u_N6GEN002("SC5","E","GTPREVALID","DataTrax","Totvs",cChave,'',cLogZX2) 
									Return .F.
								EndIf
								//Executa a validação de Duplicidade aqui, e força a saida para evitar a continuidade das validações e processamento desnecessario.
								If Select("_TMP001") > 0 
									_TMP001->(DbCloseArea())
								EndIf 
								cQry := "SELECT COUNT(*) AS 'TOT'
								cQry += " FROM "+RetSqlName("SC5")
								cQry += " WHERE C5_P_DTRAX = '"+cChave+"'
								cQry += "	AND C5_FILIAL = '"+cFil+"'
								cQry += "	AND D_E_L_E_T_ = ''"
								DbUseArea(.T., "TOPCONN", TcGenQry(,,ChangeQuery(cQry)), "_TMP001", .F., .T.)
								If _TMP001->TOT > 0 
									cMensagem	+= "<li> Pedido de venda já enviada e/ou processada pelo webservice da FedEx.</li>"
									Return .F.
								EndIf 
								_TMP001->(DbCloseArea())

							CASE aTAGBlocoB[nY] $ "_CONDPAGAMENTO"
								If Len(ALLTRIM(oXml:_NF:_BLOCOA:_BLOCOB:_CONDPAGAMENTO:TEXT)) > TamSX3("C5_CONDPAG")[1]
									cMensagem	+= "<li>A TAG 'oXml:_NF:_BLOCOA:_BLOCOB:_CONDPAGAMENTO:TEXT' está com conteudo invalido.</li>" 
									cLogZX2		+= "+ A TAG 'oXml:_NF:_BLOCOA:_BLOCOB:_CONDPAGAMENTO:TEXT' está com conteudo invalido"+CRLF
									lRet		:= .F.
								EndIf

							CASE aTAGBlocoB[nY] $ "_CONDPAGBAN"
								If Len(ALLTRIM(oXml:_NF:_BLOCOA:_BLOCOB:_CONDPAGBAN:TEXT)) > TamSX3("C5_P_BAND")[1] .or. !(ALLTRIM(oXml:_NF:_BLOCOA:_BLOCOB:_CONDPAGBAN:TEXT) $ "01|02|03")
									cMensagem	+= "<li>A TAG 'oXml:_NF:_BLOCOA:_BLOCOB:_CONDPAGBAN:TEXT' está com conteudo invalido.</li>" 
									cLogZX2		+= "+ A TAG 'oXml:_NF:_BLOCOA:_BLOCOB:_CONDPAGBAN:TEXT' está com conteudo invalido"+CRLF
									lRet		:= .F.
								EndIf

							CASE aTAGBlocoB[nY] $ "_BANDEIRA1"
								If Len(ALLTRIM(oXml:_NF:_BLOCOA:_BLOCOB:_BANDEIRA1:TEXT)) > TamSX3("C5_P_BAND1")[1] 
									cMensagem	+= "<li>A TAG 'oXml:_NF:_BLOCOA:_BLOCOB:_BANDEIRA1:TEXT' está com conteudo invalido.</li>" 
									cLogZX2		+= "+ A TAG 'oXml:_NF:_BLOCOA:_BLOCOB:_BANDEIRA1:TEXT' está com conteudo invalido"+CRLF
									lRet		:= .F.
								EndIf

							CASE aTAGBlocoB[nY] $ "_BANDEIRA2"
								If Len(ALLTRIM(oXml:_NF:_BLOCOA:_BLOCOB:_BANDEIRA2:TEXT)) > TamSX3("C5_P_BAND2")[1] 
									cMensagem	+= "<li>A TAG 'oXml:_NF:_BLOCOA:_BLOCOB:_BANDEIRA2:TEXT' está com conteudo invalido.</li>" 
									cLogZX2		+= "+ A TAG 'oXml:_NF:_BLOCOA:_BLOCOB:_BANDEIRA2:TEXT' está com conteudo invalido"+CRLF
									lRet		:= .F.
								EndIf

							CASE aTAGBlocoB[nY] $ "_BANDEIRA3"
								If Len(ALLTRIM(oXml:_NF:_BLOCOA:_BLOCOB:_BANDEIRA3:TEXT)) > TamSX3("C5_P_BAND3")[1] 
									cMensagem	+= "<li>A TAG 'oXml:_NF:_BLOCOA:_BLOCOB:_BANDEIRA3:TEXT' está com conteudo invalido.</li>" 
									cLogZX2		+= "+ A TAG 'oXml:_NF:_BLOCOA:_BLOCOB:_BANDEIRA3:TEXT' está com conteudo invalido"+CRLF
									lRet		:= .F.
								EndIf

							CASE aTAGBlocoB[nY] $ "_BANDEIRA4"
								If Len(ALLTRIM(oXml:_NF:_BLOCOA:_BLOCOB:_BANDEIRA4:TEXT)) > TamSX3("C5_P_BAND4")[1] 
									cMensagem	+= "<li>A TAG 'oXml:_NF:_BLOCOA:_BLOCOB:_BANDEIRA4:TEXT' está com conteudo invalido.</li>" 
									cLogZX2		+= "+ A TAG 'oXml:_NF:_BLOCOA:_BLOCOB:_BANDEIRA4:TEXT' está com conteudo invalido"+CRLF
									lRet		:= .F.
								EndIf

							CASE aTAGBlocoB[nY] == "_CLIENTE"
								aTAGCli := {"_CNPJCPF","_RAZAOSOCIAL","_ENDERECO","_NUMERO","_CODMUNICIPIO","_BAIRRO","_DESCMUNICIPIO","_CEP","_UF"}
								For i:=1 to len(aTAGCli)
									If VALTYPE(XmlChildEx(oXML:_NF:_BLOCOA:_BLOCOB:_CLIENTE,aTAGCli[i]) )<>"O"
										cMensagem	+= "<li>Arquivo com estrutura inválida (TAG ausente: 'oXML:_NF:_BLOCOA:_BLOCOB:_CLIENTE:"+aTAGCli[i]+"').</li>" 
										cLogZX2		+= "+ Arquivo com estrutura inválida (TAG ausente: 'oXML:_NF:_BLOCOA:_BLOCOB:_CLIENTE:"+aTAGCli[i]+"')."+CRLF
										lXMLOk		:= .F.
									Else
										DO CASE
											CASE aTAGCli[i] == "_BAIRRO"
												oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTE:_bairro:TEXT := RemoveChar(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTE:_bairro:TEXT)
											CASE aTAGCli[i] == "_NUMERO"
										   		oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTE:_numero:TEXT := RemoveChar(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTE:_numero:TEXT)
											CASE aTAGCli[i] == "_RAZAOSOCIAL"
												oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTE:_RAZAOSOCIAL:TEXT := ALLTRIM(StrTran(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTE:_RAZAOSOCIAL:TEXT,"'"," "))
												If EMPTY(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTE:_RAZAOSOCIAL:TEXT)
													cMensagem	+= "<li>A TAG 'oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTE:_razaoSocial:TEXT' não pode estar com conteudo em branco.</li>" 
													cLogZX2		+= "+ A TAG 'oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTE:_razaoSocial:TEXT' não pode estar com conteudo em branco."+CRLF
													lRet		:= .F.
													lCliOK		:= .F.
												EndIf
											
											CASE aTAGCli[i] == "_ENDERECO"
												oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTE:_endereco:TEXT := RemoveChar(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTE:_endereco:TEXT)
												If EMPTY(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTE:_ENDERECO:TEXT)
													cMensagem	+= "<li>A TAG 'oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTE:_ENDERECO:TEXT' não pode estar com conteudo em branco.</li>" 
													cLogZX2		+= "+ A TAG 'oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTE:_ENDERECO:TEXT' não pode estar com conteudo em branco."+CRLF
													lRet		:= .F.
													lCliOK		:= .F.
												ElseIf LEN(ALLTRIM(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTE:_ENDERECO:TEXT))>TamSX3("A1_END")[1]
													cMensagem	+= "<li>A TAG 'oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTE:_ENDERECO:TEXT' aceita até "+ALLTRIM(STR(TamSX3("A1_END")[1]))+" caracteres.</li>" 
													cLogZX2		+= "+ A TAG 'oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTE:_ENDERECO:TEXT' aceita até "+ALLTRIM(STR(TamSX3("A1_END")[1]))+" caracteres."+CRLF
													lRet		:= .F.
													lCliOK		:= .F.
												EndIf
											CASE aTAGCli[i] == "_CEP"
												oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTE:_CEP:TEXT := RemoveChar(StrTran(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTE:_cep:TEXT,"-",""),.T.)
												If EMPTY(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTE:_CEP:TEXT)
													cMensagem	+= "<li>A TAG 'oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTE:_CEP:TEXT' não pode estar com conteudo em branco.</li>" 
													cLogZX2		+= "+ A TAG 'oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTE:_CEP:TEXT' não pode estar com conteudo em branco."+CRLF
													lRet		:= .F.
													lCliOK		:= .F.
												ElseIf !IsNumeric(ALLTRIM(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTE:_CEP:TEXT))
													cMensagem	+= "<li>A TAG 'oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTE:_CEP:TEXT' com conteudo inválido, permitido apenas [0-9].</li>" 
													cLogZX2		+= "+ A TAG 'oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTE:_CEP:TEXT' com conteudo inválido, permitido apenas [0-9]."+CRLF
													lRet		:= .F.
													lCliOK		:= .F.
												ElseIf LEN(ALLTRIM(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTE:_CEP:TEXT)) > TamSX3("A1_CEP")[1]
													cMensagem	+= "<li>A TAG 'oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTE:_CEP:TEXT' conteudo do campo maior que o permitido.</li>" 
													cLogZX2		+= "+ A TAG 'oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTE:_CEP:TEXT' conteudo do campo maior que o permitido."+CRLF
													lRet		:= .F.
													lCliOK		:= .F.
												EndIf
										ENDCASE
									EndIf
								Next i

							CASE aTAGBlocoB[nY] == "_CLIENTECOB"
								aTAGCli := {"_ENDERECOCOB","_NUMEROCOB","_CODMUNICIPIOCOB","_DESCMUNICIPIOCOB","_CEPCOB","_UFCOB"}
								For i:=1 to len(aTAGCli)
									If VALTYPE(XmlChildEx(oXML:_NF:_BLOCOA:_BLOCOB:_CLIENTECOB,aTAGCli[i]) )<>"O"
										cMensagem	+= "<li>Arquivo com estrutura inválida (TAG ausente: 'oXML:_NF:_BLOCOA:_BLOCOB:_CLIENTECOB:"+aTAGCli[i]+"').</li>" 
										cLogZX2		+= "+ Arquivo com estrutura inválida (TAG ausente: 'oXML:_NF:_BLOCOA:_BLOCOB:_CLIENTECOB:"+aTAGCli[i]+"')."+CRLF
										lXMLOk		:= .F.
									Else
										DO CASE
											CASE aTAGCli[i] == "_ENDERECOCOB"
												oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTECOB:_enderecocob:TEXT	:= RemoveChar(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTECOB:_enderecocob:TEXT)
											CASE aTAGCli[i] == "_NUMEROCOB"
												oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTECOB:_numerocob:TEXT	:= RemoveChar(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTECOB:_numerocob:TEXT)
											CASE aTAGCli[i] == "_CEP"
												oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTECOB:_CEPCOB:TEXT := RemoveChar(StrTran(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTECOB:_CEPCOB:TEXT,"-",""),.T.)
												If EMPTY(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTECOB:_CEPCOB:TEXT)
													cMensagem	+= "<li>A TAG 'oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTECOB:_CEPCOB:TEXT' não pode estar com conteudo em branco.</li>" 
													cLogZX2		+= "+ A TAG 'oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTECOB:_CEPCOB:TEXT' não pode estar com conteudo em branco."+CRLF
													lRet		:= .F.
													lCliOK		:= .F.
												ElseIf !IsNumeric(ALLTRIM(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTECOB:_CEPCOB:TEXT))
													cMensagem	+= "<li>A TAG 'oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTECOB:_CEPCOB:TEXT' com conteudo inválido, permitido apenas [0-9].</li>" 
													cLogZX2		+= "+ A TAG 'oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTECOB:_CEPCOB:TEXT' com conteudo inválido, permitido apenas [0-9]."+CRLF
													lRet		:= .F.
													lCliOK		:= .F.
												ElseIf LEN(ALLTRIM(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTECOB:_CEPCOB:TEXT)) > TamSX3("A1_CEPC")[1]
													cMensagem	+= "<li>A TAG 'oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTECOB:_CEPCOB:TEXT' conteudo do campo maior que o permitido.</li>" 
													cLogZX2		+= "+ A TAG 'oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTECOB:_CEPCOB:TEXT' conteudo do campo maior que o permitido."+CRLF
													lRet		:= .F.
													lCliOK		:= .F.
												EndIf
										ENDCASE
									EndIf
								Next i

							CASE aTAGBlocoB[nY] == "_CLIENTEENT"
								aTAGCli := {"_RAZAOSOCIAL","_ENDERECO","_COMPLEMENTO","_NUMERO","_BAIRRO","_CODMUNICIPIO","_DESCMUNICIPIO","_NOMEESTADO","_CEP","_UF"}
								For i:=1 to len(aTAGCli)
									If VALTYPE(XmlChildEx(oXML:_NF:_BLOCOA:_BLOCOB:_CLIENTEENT,aTAGCli[i]) )<>"O"
										cMensagem	+= "<li>Arquivo com estrutura inválida (TAG ausente: 'oXML:_NF:_BLOCOA:_BLOCOB:_CLIENTEENT:"+aTAGCli[i]+"').</li>" 
										cLogZX2		+= "+ Arquivo com estrutura inválida (TAG ausente: 'oXML:_NF:_BLOCOA:_BLOCOB:_CLIENTEENT:"+aTAGCli[i]+"')."+CRLF
										lXMLOk		:= .F.
									Else
										DO CASE
											CASE aTAGCli[i] == "_BAIRRO"
												oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTEENT:_bairro:TEXT := RemoveChar(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTEENT:_bairro:TEXT)
											CASE aTAGCli[i] == "_CODMUNICIPIO"
												oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTEENT:_codMunicipio:TEXT := RemoveChar(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTEENT:_codMunicipio:TEXT)
											CASE aTAGCli[i] == "_DESCMUNICIPIO"
												oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTEENT:_descMunicipio:TEXT := RemoveChar(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTEENT:_descMunicipio:TEXT)
											CASE aTAGCli[i] == "_NOMEESTADO"
										   		oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTEENT:_nomeEstado:TEXT := RemoveChar(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTEENT:_nomeEstado:TEXT)
											CASE aTAGCli[i] == "_NUMERO"
										   		oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTEENT:_numero:TEXT := RemoveChar(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTEENT:_numero:TEXT)
										 	CASE aTAGCli[i] == "_COMPLEMENTO"
											 	oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTEENT:_complemento:TEXT := RemoveChar(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTEENT:_complemento:TEXT)
											CASE aTAGCli[i] == "_UF"
												oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTEENT:_uf:TEXT := RemoveChar(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTEENT:_uf:TEXT)
											CASE aTAGCli[i] == "_RAZAOSOCIAL"
												oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTEENT:_RAZAOSOCIAL:TEXT := ALLTRIM(StrTran(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTEENT:_RAZAOSOCIAL:TEXT,"'"," "))
												If EMPTY(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTEENT:_RAZAOSOCIAL:TEXT)
													cMensagem	+= "<li>A TAG 'oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTEENT:_razaoSocial:TEXT' não pode estar com conteudo em branco.</li>" 
													cLogZX2		+= "+ A TAG 'oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTEENT:_razaoSocial:TEXT' não pode estar com conteudo em branco."+CRLF
													lRet		:= .F.
													lCliOK		:= .F.
												EndIf
											CASE aTAGCli[i] == "_ENDERECO"   
												oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTEENT:_endereco:TEXT := RemoveChar(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTEENT:_endereco:TEXT)
												If EMPTY(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTEENT:_ENDERECO:TEXT)
													cMensagem	+= "<li>A TAG 'oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTEENT:_ENDERECO:TEXT' não pode estar com conteudo em branco.</li>" 
													cLogZX2		+= "+ A TAG 'oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTEENT:_ENDERECO:TEXT' não pode estar com conteudo em branco."+CRLF
													lRet		:= .F.
													lCliOK		:= .F.
												ElseIf LEN(ALLTRIM(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTEENT:_ENDERECO:TEXT))>TamSX3("ZX4_END")[1]
													cMensagem	+= "<li>A TAG 'oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTEENT:_ENDERECO:TEXT' aceita até "+ALLTRIM(STR(TamSX3("ZX4_END")[1]))+" caracteres.</li>" 
													cLogZX2		+= "+ A TAG 'oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTEENT:_ENDERECO:TEXT' aceita até "+ALLTRIM(STR(TamSX3("ZX4_END")[1]))+" caracteres."+CRLF
													lRet		:= .F.
													lCliOK		:= .F.
												EndIf
											CASE aTAGCli[i] == "_CEP"
												oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTEENT:_CEP:TEXT := RemoveChar(StrTran(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTEENT:_CEP:TEXT,"-",""),.T.)
												If EMPTY(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTEENT:_CEP:TEXT)
													cMensagem	+= "<li>A TAG 'oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTEENT:_CEP:TEXT' não pode estar com conteudo em branco.</li>" 
													cLogZX2		+= "+ A TAG 'oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTEENT:_CEP:TEXT' não pode estar com conteudo em branco."+CRLF
													lRet		:= .F.
													lCliOK		:= .F.
												ElseIf !IsNumeric(ALLTRIM(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTEENT:_CEP:TEXT))
													cMensagem	+= "<li>A TAG 'oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTEENT:_CEP:TEXT' com conteudo inválido, permitido apenas [0-9].</li>" 
													cLogZX2		+= "+ A TAG 'oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTEENT:_CEP:TEXT' com conteudo inválido, permitido apenas [0-9]."+CRLF
													lRet		:= .F.
													lCliOK		:= .F.
												ElseIf LEN(ALLTRIM(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTEENT:_CEP:TEXT)) > TamSX3("ZX4_CEP")[1]
													cMensagem	+= "<li>A TAG 'oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTEENT:_CEP:TEXT' conteudo do campo maior que o permitido.</li>" 
													cLogZX2		+= "+ A TAG 'oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTEENT:_CEP:TEXT' conteudo do campo maior que o permitido."+CRLF
													lRet		:= .F.
													lCliOK		:= .F.
												EndIf
										ENDCASE
									EndIf
								Next i		
						EndCase
					EndIf
				Next nY
	
				If VALTYPE(XmlChildEx(oXML:_NF:_BLOCOA:_BLOCOB,"_BLOCOC") )=="O"
					//Caso precisar de validação dentro do BlocoC
				Else
					cMensagem	+= "<li>Arquivo com estrutura inválida (TAG ausente: 'oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC').</li>" 
					cLogZX2		+= "+ Arquivo com estrutura inválida (TAG ausente: 'oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC')."+CRLF
					lXMLOk		:= .F.
				EndIf 
			Else
				cMensagem	+= "<li>Arquivo com estrutura inválida (TAG ausente: 'oXml:_NF:_BLOCOA:_BLOCOB').</li>" 
				cLogZX2		+= "+ Arquivo com estrutura inválida (TAG ausente: 'oXml:_NF:_BLOCOA:_BLOCOB')."+CRLF
	  			lXMLOk		:= .F.
			EndIf 
		Else
			cMensagem	+= "<li>Arquivo com estrutura inválida (TAG ausente: 'oXml:_NF:_BLOCOA').</li>" 
			cLogZX2		+= "+ Arquivo com estrutura inválida (TAG ausente: 'oXml:_NF:_BLOCOA')."+CRLF
			lXMLOk		:= .F.
		EndIf 
	Else
		cMensagem	+= "<li>Arquivo com estrutura inválida (TAG ausente: 'oXml:_NF').</li>" 
		cLogZX2		+= "+ Arquivo com estrutura inválida (TAG ausente: 'oXml:_NF')."+CRLF
		lXMLOk		:= .F.
	EndIf
Else
	cMensagem	+= "<li>Falha ao carregar arquivo, estrutura inválida.</li>" 
	cLogZX2		+= "+ Falha ao carregar arquivo, estrutura inválida."+CRLF
	lXMLOk		:= .F.
EndIf
If !lXMLOk
	cMensagem	+= "<li> Erro critico de estrutura, impede a continuidade da execução da validação e/ou processamento.</li>" 
	cLogZX2		+= "+ Erro critico de estrutura, impede a continuidade da execução da validação e/ou processamento."+CRLF
	u_N6GEN002("SC5","E","GTPREVALID","DataTrax","Totvs",cFile,'',cLogZX2) 
	Return .F.
EndIf

//Validação se o campo flag(aponta a filial a ser processada) está no diretório correto
IF alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_FLAG:TEXT) <> cFil
	cMensagem	+= "<li> A filial(Flag) informada no XML "+ IIF(EMPTY(alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_FLAG:TEXT)),"esta vazia"," é diferente da pasta de Filial para processamento.")+". O pedido de venda não foi gerado no TOTVS ERP.</li>" 
	cLogZX2		+= "+ Campo FLAG do arquivo é diferente do diretorio do arquivo."+CRLF
	lRet		:= .F.
EndIf

//CADASTRO DE CLIENTE
If Empty(cCPF := alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTE:_CNPJCPF:TEXT))
	cMensagem	+= "<li>A TAG do CPF/CNPJ está em branco impedindo a importação do arquivo Datatrax.</li>" 
	cLogZX2		+= "+ O CPF/CNPJ do cliente está em branco no arquivo XML enviado pelo Datatrax."+CRLF
	lRet		:= .F.
	lCliOK		:= .F.
Else
	If !ValidDigCPF(cCPF)
		cMensagem	+= "<li>CPF/CNPJ ("+cCPF+") enviado no arquivo XML de importação do datatrax é inválido.</li>" 
		cLogZX2		+= "+ CPF/CNPJ ("+cCPF+") enviado no arquivo XML de importação do datatrax é inválido."+CRLF
		lRet		:= .F.
		lCliOK		:= .F.
	EndIf
EndIf

//Validação de codigo de municipio para o estado informado - Cliente
If !ValidMunEst(alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTE:_uf:TEXT),alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTE:_codMunicipio:TEXT))
	cMensagem	+= "<li> Codigo de municipio ('"+alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTE:_codMunicipio:TEXT)+"') inválido para o estado informado ('"+alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTE:_uf:TEXT)+"').</li>"
	cLogZX2		+= "+ Codigo de municipio ('"+alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTE:_codMunicipio:TEXT)+"') inválido para o estado informado ('"+alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTE:_uf:TEXT)+"')."+CRLF
	lRet		:= .F.
	lCliOK		:= .F.
EndIf
//Validação de codigo de municipio para o estado informado - Cliente Entrega
If !ValidMunEst(alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTEENT:_uf:TEXT),alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTEENT:_codMunicipio:TEXT))
	cMensagem	+= "<li> Codigo de municipio ('"+alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTEENT:_codMunicipio:TEXT)+"') inválido para o estado informado ('"+alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTEENT:_uf:TEXT)+"').</li>"
	cLogZX2		+= "+ Codigo de municipio ('"+alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTEENT:_codMunicipio:TEXT)+"') inválido para o estado informado ('"+alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTEENT:_uf:TEXT)+"')."+CRLF
	lRet		:= .F.
	lCliEntOK	:= .F.
EndIf

//Manutenção do cadastro do cliente
If lCliOK
	If !EMPTY(cMsgCliente := ManutCliente(oXml))
		cMensagem	+= cMsgCliente
		cLogZX2		+= "+ Falha na atualização do cadastro de cliente."+CRLF
		lRet		:= .F.
	EndIf
Else
	cMensagem	+= "<li> Cadastro de cliente não foi atualizado.</li>"
	cLogZX2		+= "+ Cadastro de cliente não foi atualizado."+CRLF
	lRet		:= .F.
	lCliEntOK	:= .F.
EndIf

//Manutenção de endereço de entrega
If lCliEntOK .and. !EMPTY(cCPF)
	SA1->(dbSetOrder(3))
	If SA1->(DbSeek(xFilial("SA1")+PADR(cCPF,	TamSX3("A1_CGC")[1],'')))
		aMsgEndEnt := ManutEndEnt(oXml,cCPF)
		If EMPTY(aMsgEndEnt[1])
			cMensagem	+= aMsgEndEnt[2]
			cLogZX2		+= "+ Falha na atualização do Endereço de entrega para o cadastro de cliente."+CRLF
			lRet		:= .F.
		Else
			//Atualização de Variavel Private (da chamada principal)
			cCodEndEnt := aMsgEndEnt[1]
		EndIf
	Else
		cMensagem	+= "<li> Cadastro de cliente (CPF:"+cCPF+") não localizado para atualização do endereço de entrega.</li>"
		cLogZX2		+= "+ Cadastro de cliente (CPF:"+cCPF+") não localizado para atualização do endereço de entrega."+CRLF
		lRet		:= .F.
	EndIf
Else
	cMensagem	+= "<li> Cadastro de endereço de entrega não foi atualizado.</li>"
	cLogZX2		+= "+ Cadastro de endereço de entrega não foi atualizado."+CRLF
	lRet		:= .F.
EndIf	

//####################################### PROVISORIO ####################################### - INICIO
aSubsIPA	:= {"60204593","60206955","60206956","60206957","60206957","60206958",;
				"60206958","60207009","60207031","60207033","60207125","60207429",;
				"60207480","60205345","60207158","60207174"}
If cFil == "01"
	aAdd(aSubsIPA,"60205334")
ElseIf cFil == "02"
	aAdd(aSubsIPA,"60207048")
EndIf
aSubsI		:= {""}
//####################################### PROVISORIO ####################################### - FIM

//VALIDAÇÃO DE PRODUTO
If Valtype(oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD) == "A" //Verifica se a estrutura é do tipo Array (A)
	For nY:=1 to len(oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD)
		If EMPTY(alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD[nY]:_CODPRODUTO:TEXT))//Código de produto
	   		cMensagem	+= "<li>O <b>código do produto não está presente no arquivo de dados importado do Datatrax. (Item "+cvaltochar(nY)+" do pedido)</li>"
   			cLogZX2		+= "+ Codigo do Produto está em branco no arquivo XML (Item "+cvaltochar(nY)+" do pedido)."+CRLF
			lRet		:= .F.
		Else
			//####################################### PROVISORIO ####################################### - INICIO
			If aScan(aSubsIPA,{|x| x == alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD[nY]:_CODPRODUTO:TEXT) } ) <> 0
				oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD[nY]:_CODPRODUTO:TEXT := alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD[nY]:_CODPRODUTO:TEXT)+"IPA"
			ElseIf aScan(aSubsI,{|x| x == alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD[nY]:_CODPRODUTO:TEXT) } ) <> 0
				oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD[nY]:_CODPRODUTO:TEXT := alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD[nY]:_CODPRODUTO:TEXT)+"I"
			EndIf
			//####################################### PROVISORIO ####################################### - FIM
			If !ValidProd(alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD[nY]:_CODPRODUTO:TEXT))
				cMensagem	+= "<li>Produto "+alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD[nY]:_CODPRODUTO:TEXT)+" não está cadastrado.</li>"
				cLogZX2		+= "+ Produto ("+alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD[nY]:_CODPRODUTO:TEXT)+") não cadastrado no Protheus."+CRLF
				lRet		:= .F.
			EndIf
			If val(oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD[nY]:_QUANTIDADE:TEXT) == 0
		   		cMensagem	+= "<li>Produto "+alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD[nY]:_CODPRODUTO:TEXT)+" não pode estar com quantidade 0(zero) no arquivo XML.</li>"
				cLogZX2		+= "+ Produto ("+alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD[nY]:_CODPRODUTO:TEXT)+") não pode estar com quantidade 0(zero) no arquivo XML."+CRLF
				lRet		:= .F.
			EndIf
			If val(oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD[nY]:_PRECOUNIT:TEXT) == 0
		   		cMensagem	+= "<li>Produto "+alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD[nY]:_CODPRODUTO:TEXT)+" não pode estar com o preço unitário 0(zero) no arquivo XML.</li>"
				cLogZX2		+= "+ Produto ("+alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD[nY]:_CODPRODUTO:TEXT)+") não pode estar com o preço unitário 0(zero) no arquivo XML."+CRLF
				lRet		:= .F.
			EndIf
		EndIf
	Next nY
Else
	If EMPTY(alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD:_CODPRODUTO:TEXT))//Código de produto
   		cMensagem	+= "<li>O <b>código do produto não está presente no arquivo de dados importado do Datatrax. (Item 1 do pedido)</li>"
   		cLogZX2		+= "+ Codigo do Produto está em branco no arquivo XML (Item 1 do pedido)."+CRLF 
		lRet		:= .F.
	Else
		//####################################### PROVISORIO ####################################### - INICIO
		If aScan(aSubsIPA,{|x| x == alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD:_CODPRODUTO:TEXT) } ) <> 0
			oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD:_CODPRODUTO:TEXT := alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD:_CODPRODUTO:TEXT)+"IPA"
		ElseIf aScan(aSubsI,{|x| x == alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD:_CODPRODUTO:TEXT) } ) <> 0
			oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD:_CODPRODUTO:TEXT := alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD:_CODPRODUTO:TEXT)+"I"
		EndIf
		//####################################### PROVISORIO ####################################### - FIM
   		If !ValidProd(alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD:_CODPRODUTO:TEXT))
			cMensagem	+= "<li>Produto "+alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD:_CODPRODUTO:TEXT)+" não está cadastrado.</li>" 
			cLogZX2		+= "+ Produto ("+alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD:_CODPRODUTO:TEXT)+") não cadastrado no Protheus."+CRLF 
			lRet		:= .F.
		EndIf
		If val(oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD:_QUANTIDADE:TEXT) == 0
	   		cMensagem	+= "<li>Produto "+alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD:_CODPRODUTO:TEXT)+" não pode estar com quantidade 0(zero) no arquivo XML.</li>" 
			cLogZX2		+= "+ Produto ("+alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD:_CODPRODUTO:TEXT)+") não pode estar com quantidade 0(zero) no arquivo XML."+CRLF 
			lRet		:= .F.
		EndIf
		If val(oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD:_PRECOUNIT:TEXT) == 0
	   		cMensagem	+= "<li>Produto "+alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD:_CODPRODUTO:TEXT)+" não pode estar com o preço unitário 0(zero) no arquivo XML.</li>" 
			cLogZX2		+= "+ Produto ("+alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD:_CODPRODUTO:TEXT)+") não pode estar com o preço unitário 0(zero) no arquivo XML."+CRLF 
			lRet		:= .F.
		EndIf
	EndIf
EndIf

//VALIDAÇÃO DE CONDIÇÃO DE PAGAMENTO
DbSelectArea("SE4")
SE4->(dbSetOrder(1))                  	
If EMPTY(alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_CONDPAGAMENTO:TEXT))
	cMensagem	+= "<li> A TAG da condição de pagamento está em branco/vazia na importação do arquivo do Datatrax.<li>" 
	cLogZX2		+= "+ A TAG da condição de pagamento está em branco/vazia na importação do arquivo do Datatrax."+CRLF 
	lRet		:= .F.
Else
	If !SE4->(dbSeek(xFilial("SE4")+alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_CONDPAGAMENTO:TEXT)))
		cMensagem	+= "<li> A condição de pagamento "+alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_CONDPAGAMENTO:TEXT)+" não está cadastrada.</li>"
		cLogZX2		+= "+ A condição de pagamento  ("+alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_CONDPAGAMENTO:TEXT)+") não cadastrada no Protheus."+CRLF 
		lRet		:= .F.
	EndIf
EndIF
//De-para de condição de pagamento 
If Alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_CONDPAGAMENTO:TEXT) == "001" .or. Alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_CONDPAGAMENTO:TEXT) == "002"
	//Solicitado pela Marcelle para atender um ajuste a qual o Jonathan (Datatrax) não consegue antender
	If Alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_CONDPAGAMENTO:TEXT) == "001" .and. Alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_TIPOPAGAMENTO:TEXT) == "CC" 
		oXml:_NF:_BLOCOA:_BLOCOB:_CONDPAGAMENTO:TEXT := "002"		        
	EndIf	
	oXml:_NF:_BLOCOA:_BLOCOB:_CONDPAGAMENTO:TEXT := "11"+RIGHT(alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_CONDPAGAMENTO:TEXT),1) //Transforma para 111 ou 112
	//Validar a condição de pagamento
	If !SE4->(dbSeek(xFilial("SE4")+alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_CONDPAGAMENTO:TEXT)))
		cMensagem	+= "<li> A condição de pagamento (após DExPARA) "+alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_CONDPAGAMENTO:TEXT)+" não está cadastrada.</li>"
		cLogZX2		+= "+ A condição de pagamento (após DExPARA)  ("+alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_CONDPAGAMENTO:TEXT)+") não cadastrada no Protheus."+CRLF 
		lRet		:= .F.
	EndIf
EndIf
SE4->(DbCloseArea())
                 
//VALIDAÇÃO WORDPAY
If Valtype(oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD) == "A"
	cOper := oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD[1]:_CODOPERACAO:TEXT
Else
	cOper := oXml:_NF:_BLOCOA:_BLOCOB:_BLOCOC:_BLOCOD:_CODOPERACAO:TEXT
EndIf  
If EMPTY(cOper)//Da forma que esta hoje, não permite o Mesmo pedido possuir dois itens com operações diferentes(Bonificação e venda)
	cMensagem	+= "<li> O Tipo de operação não foi informado no arquivo XML.</li>"
	cLogZX2		+= "+ O Tipo de operação não foi informado no arquivo XML."+CRLF 
	lRet		:= .F.
Else
	If EMPTY(alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_WORLDPAY_ID:TEXT)) .And. cOper == "01"
		cMensagem += "<li> O pedido de venda não teve a confirmação de pagamento (WorldPay ID) o pedido de venda ("+cChave+") não foi gravado.</li>" 
	 	cLogZX2		+= "+ Não foi informado a confirmação de pagamento (WorldPay ID) no arquivo XML, pedido não foi integrado."+CRLF
		lRet		:= .F.
	EndIf
EndIf

//VALIDAÇÃO DE TIPO DE FRETE
//Carrega conteudo dinamico.
aCombo := RetSX3Box(GetSX3Cache("C5_TPFRETE","X3_CBOX"),,,1)
cCombo := ""
cMsgCombo := ""
For i:=1 to len(aCombo)
	cCombo += IIF(EMPTY(cCombo),"","/")
	cCombo += ALLTRIM(aCombo[i][2])
	cMsgCombo += IIF(EMPTY(cMsgCombo),"","/")
	cMsgCombo += ALLTRIM(aCombo[i][1])
Next i
If EMPTY(alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_TIPOFRETE:TEXT))
	cMensagem += "<li> O campo tipo frete está em branco. Conteúdo permitido "+cMsgCombo+".</li>"
	cLogZX2		+= "+ O número do pedido de venda do Datatrax está vazio, pedido não foi integrado."+CRLF
	lRet		:= .F.
Else
	If alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_TIPOFRETE:TEXT) $ cCombo
		//Solicitado pelo Silvio (doTerra) para atender uma regra nova da FEDEX 18.06.18
		If oXml:_NF:_BLOCOA:_BLOCOB:_FLAG:TEXT == "02" .and. alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_TIPOFRETE:TEXT) == "F"
			oXml:_NF:_BLOCOA:_BLOCOB:_TIPOFRETE:TEXT := "C"
		EndIf

		If alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_TIPOFRETE:TEXT) $ "C/F" .and. EMPTY(oXml:_NF:_BLOCOA:_BLOCOB:_TRANSPORTADORA1:TEXT)
			cMensagem += "<li> O campo código da transportadora está em branco e é obrigatório para os fretes do tipo "+cMsgCombo+".</li>"
			cLogZX2		+= "+ O campo código da transportadora está em branco e é obrigatório para os fretes do tipo "+cMsgCombo+"."+CRLF
   	   		lRet		:= .F.
		EndIf
	Else
		cMensagem	+= "<li> O campo tipo frete está com a informação inválida. Conteúdo permitido "+cMsgCombo+".</li>"
		cLogZX2		+= "+ O campo tipo frete está com a informação inválida. Conteúdo permitido "+cMsgCombo+"."+CRLF
   		lRet		:= .F.
	EndIf
EndIf

//Validação aplicada para verificar se o SO é venda(cOper=01) ou de bonificação(cOper=04) com frete
If !EMPTY(cOper)//já validado anteriormente
	IF (cOper == "01") .OR. (cOper == "04" .and. Alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_TIPOFRETE:TEXT) <> "S")
		//Validação da bandeira de pagamento 
		If EMPTY(Alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_CONDPAGBAN:TEXT))
			cMensagem += "<li> A TAG de bandeira é obrigatório e o pedido de venda não foi criado.</li>" 
			cLogZX2		+= "+ A TAG de bandeira é obrigatória, pedido não foi integrado."+CRLF
   	   		lRet		:= .F.
		EndIf
		//Validação do tipo de pagamento
		If EMPTY(Alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_TIPOPAGAMENTO:TEXT))
			cMensagem	+= "<li> A TAG de tipo de pagamento é obrigatório e o pedido de venda não foi criado.</li>" 
			cLogZX2		+= "+ A TAG de tipo de pagamento é obrigatória, pedido não foi integrado."+CRLF
   			lRet		:= .F.
		EndIf
	EndIf
EndIf

//Validação de cadastro de Transportadora para e-commerce, quando informada
If oXml:_NF:_BLOCOA:_BLOCOB:_FLAG:TEXT == "02" .And. !EMPTY(Alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_TRANSPORTADORA1:TEXT))
	If Select("_TMP001") > 0 
		_TMP001->(DbCloseArea())
	EndIf 
	cQry := "SELECT COUNT(*) AS 'TOT'
	cQry += " FROM "+RetSqlName("SA4")
	cQry += " WHERE A4_COD = '"+Alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_TRANSPORTADORA1:TEXT)+"'
	cQry += "	AND D_E_L_E_T_ = ''"
	DbUseArea(.T., "TOPCONN", TcGenQry(,,ChangeQuery(cQry)), "_TMP001", .F., .T.)
	If _TMP001->TOT == 0 
		cMensagem	+= "<li> Transportadora informada no arquivo XML é invalida (Transp: '"+Alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_TRANSPORTADORA1:TEXT)+"').</li>"
		cLogZX2		+= "+ Transportadora informada no arquivo XML é invalida (Transp: '"+Alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_TRANSPORTADORA1:TEXT)+"')."+CRLF
		lRet		:= .F. 	
	EndIf 
	_TMP001->(DbCloseArea())  
EndIf

//Gravação de LOG de pre-validação
If !lRet .and. !EMPTY(cLogZX2)
	u_N6GEN002("SC5","E","GTPREVALID","DataTrax","Totvs",IIF(cChave<>"INVALIDA",cChave,cFile),'',cLogZX2) 
EndIf

Return lRet

/*
Funcao      : ValidDigCPF
Parametros  : 
Retorno     : 
Objetivos   : Validação do CPF/CNPJ
Autor       : Jean Victor Rocha
Data/Hora   : 
*/ 
*-------------------------------*
Static Function ValidDigCPF(cCPF)
*-------------------------------*
Local i

//Valida se o CPF/CNPJ não são caracteres repetidos (passa pelo calculo como OK mas não invalidos).
For i:=1 to 10
	If cCPF == REPLICATE( ALLTRIM(STR(i-1)),11) .or. cCPF == REPLICATE( ALLTRIM(STR(i-1)),14)
   		Return .F.
	EndIf
Next i

//Valida se o CPF/CNPJ não possui caracter diferente de Numerico
For i:=1 to len(cCPF)
	If !(ASC(SUBSTR(cCPF,i,1)) >= 48 .and. ASC(SUBSTR(cCPF,i,1)) <= 57)
		Return .F.
	EndIf
Next i
		
Return CGC(cCPF)

/*
Funcao      : ValidMunEst
Parametros  : 
Retorno     : 
Objetivos   : Validação do Codigo do monucipio para o estado
Autor       : Jean Victor Rocha
Data/Hora   : 
*/ 
*-------------------------------------*
Static Function ValidMunEst(cUf,cCodMun)
*-------------------------------------*
Local lRet := .T.

If Select("VLDMUN_EST") > 0 
	VLDMUN_EST->(DbCloseArea())
EndIf 
cQry := "SELECT COUNT(*) AS 'QTDE'
cQry += " FROM "+RetSqlName("CC2")
cQry += " WHERE CC2_EST = '"+cUf+"'
cQry += " 	AND CC2_CODMUN = '"+cCodMun+"'
cQry += "	AND D_E_L_E_T_ = ''"
DbUseArea(.T., "TOPCONN", TcGenQry(,,ChangeQuery(cQry)), "VLDMUN_EST", .F., .T.)
If VLDMUN_EST->QTDE == 0 
	lRet := .F.
EndIf 
VLDMUN_EST->(DbCloseArea())  

Return lRet
       
/*
Funcao      : ManutEndEnt
Parametros  : 
Retorno     : 
Objetivos   : Manutenção de endereço de entrega de acordo com o cliente
Autor       : Jean Victor Rocha
Data/Hora   : 
*/                
*------------------------------------*
Static Function ManutEndEnt(oXml,cCPF)
*------------------------------------*
Local cIdEnd	:= ""
Local cMsgRet	:= ""
Local cQry 		:= ""
Local cIns 		:= ""

Local nRecCount	:= 0

Local cRazao	:= LEFT(alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTEENT:_razaoSocial:TEXT),TamSX3("ZX4_NOME")[1])  
Local cEnd		:= LEFT(alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTEENT:_endereco:TEXT)+" "+alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTEENT:_numero:TEXT),TamSX3("ZX4_END")[1])
Local cComplem	:= LEFT(alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTEENT:_complemento:TEXT),TamSX3("ZX4_COMPLE")[1])
Local cUf		:= UPPER(alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTEENT:_uf:TEXT))
Local cCodMun	:= alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTEENT:_codMunicipio:TEXT)
Local cDescMun	:= alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTEENT:_descMunicipio:TEXT) 
Local cEstado	:= alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTEENT:_nomeEstado:TEXT) 
Local cBairro	:= LEFT(alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTEENT:_bairro:TEXT),TamSX3("ZX4_BAIRRO")[1])
Local cCEP		:= alltrim(oXml:_NF:_BLOCOA:_BLOCOB:_CLIENTEENT:_cep:TEXT)

If EMPTY(cCPF)
	Return {cIdEnd,"CPF ('"+cCPF+"') Informado para manutenção de cadastro de endereço inválido."}
EndIf
If VALTYPE(oXml) <> "O"
	Return {cIdEnd,"Dados do XML enviado para a manutenção do cadastro de endereço possui inconsistência."}
EndIf

SA1->(dbSetOrder(3))
If SA1->(DbSeek(xFilial("SA1")+PADR(cCPF,	TamSX3("A1_CGC")[1],'')))
	If Select("MNT_END") > 0 
		MNT_END->(DbCloseArea())
	EndIf 
	cQry := "SELECT TOP 1 ZX4_CODEND
	cQry += " FROM "+RetSqlName("ZX4")
	cQry += " WHERE D_E_L_E_T_ <> '*'
	cQry += "	AND ZX4_FILIAL 	   		= '"+SA1->A1_FILIAL+"'
	cQry += "	AND ZX4_CODCLI 	   		= '"+SA1->A1_COD+"'
	cQry += " 	AND ZX4_LOJA	   		= '"+SA1->A1_LOJA+"'
	cQry += "	AND UPPER(ZX4_NOME)		= '"+UPPER(cRazao)+"'
	cQry += "	AND UPPER(ZX4_END) 		= '"+UPPER(cEnd)+"'
	cQry += "	AND UPPER(ZX4_COMPLE)	= '"+UPPER(cComplem)+"'
	cQry += "	AND UPPER(ZX4_BAIRRO)	= '"+UPPER(cBairro)+"'
	cQry += "	AND ZX4_CODMUN			= '"+cCodMun+"'
	cQry += "	AND ZX4_EST				= '"+cUf+"'
	cQry += "	AND ZX4_CEP				= '"+cCEP+"'

	DbUseArea(.T., "TOPCONN", TcGenQry(,,ChangeQuery(cQry)), "MNT_END", .F., .T.)

	Count to nRecCount
	MNT_END->(DBGOTOP())

	If nRecCount == 0//Inclusão
		cIns := "	Insert into "+RetSqlName("ZX4")+" (ZX4_FILIAL,ZX4_CODCLI,ZX4_LOJA,ZX4_CODEND,ZX4_NOME,ZX4_END,ZX4_BAIRRO,ZX4_EST,ZX4_CEP,ZX4_CODMUN,ZX4_MUN,ZX4_PAIS,ZX4_COMPLE,D_E_L_E_T_,R_E_C_N_O_)
		cIns += "	VALUES(	'"+SA1->A1_FILIAL+"'
		cIns += "  			,'"+SA1->A1_COD+"'
		cIns += "  			,'"+SA1->A1_LOJA+"'
		cIns += " 			,(Select REPLICATE('0',6-LEN(ISNULL(MAX(CONVERT(INT,ZX4_CODEND)),0)+1))+RTrim(ISNULL(MAX(CONVERT(INT,ZX4_CODEND)),0)+1) From "+RetSqlName("ZX4")+")
		cIns += " 			,'"+cRazao+"'
		cIns += " 			,'"+cEnd+"'
		cIns += " 			,'"+cBairro+"'
		cIns += " 			,'"+cUf+"'
		cIns += " 			,'"+cCEP+"'
		cIns += " 			,'"+cCodMun+"'
		cIns += " 			,(Select CC2_MUN From "+RetSqlName("CC2")+" Where D_E_L_E_T_ <> '*' AND CC2_EST='"+cUf+"' AND CC2_CODMUN='"+cCodMun+"')
		cIns += " 			,'105'
		cIns += " 			,'"+cComplem+"'
		cIns += "			,''
		cIns += "			,(Select ISNULL(MAX(R_E_C_N_O_),0)+1 From "+RetSqlName("ZX4")+") )
		TCSQLEXEC(cIns)
		
		If Select("MNT_END") > 0 
	   		MNT_END->(DbCloseArea())
		EndIf 
		cQry := "SELECT TOP 1 ZX4_CODEND
		cQry += " FROM "+RetSqlName("ZX4")
		cQry += " WHERE D_E_L_E_T_ <> '*'
		cQry += "	AND ZX4_FILIAL 	   		= '"+SA1->A1_FILIAL+"'
		cQry += "	AND ZX4_CODCLI 	   		= '"+SA1->A1_COD+"'
		cQry += " 	AND ZX4_LOJA	   		= '"+SA1->A1_LOJA+"'
		cQry += "	AND UPPER(ZX4_NOME)		= '"+UPPER(cRazao)+"'
		cQry += "	AND UPPER(ZX4_END) 		= '"+UPPER(cEnd)+"'
		cQry += "	AND UPPER(ZX4_COMPLE)	= '"+UPPER(cComplem)+"'
		cQry += "	AND UPPER(ZX4_BAIRRO)	= '"+UPPER(cBairro)+"'
		cQry += "	AND ZX4_CODMUN			= '"+cCodMun+"'
		cQry += "	AND ZX4_EST				= '"+cUf+"'
		cQry += "	AND ZX4_CEP				= '"+cCEP+"'
	
		DbUseArea(.T., "TOPCONN", TcGenQry(,,ChangeQuery(cQry)), "MNT_END", .F., .T.)
		Count to nRecCount
		
		MNT_END->(DBGOTOP())
		If nRecCount <> 0
			cIdEnd := MNT_END->ZX4_CODEND
		Else
			cMsgRet := "Falha na busca do cadastro do cliente para manutenção do cadastro de endereço."
		EndIf
	Else
		cIdEnd := MNT_END->ZX4_CODEND
	EndIf 
	If Select("MNT_END") > 0 
		MNT_END->(DbCloseArea())
	EndIf 
Else
	Return {cIdEnd,"Falha na busca do cadastro do cliente para manutenção do cadastro de endereço."}
EndIf

Return {cIdEnd,cMsgRet}

/*
Funcao      : RemoveChar
Parametros  : 
Retorno     : 
Objetivos   : Remover caracteres invalidos
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*---------------------------------------------*
static Function RemoveChar(cTexto,lRemoveSpace)
*---------------------------------------------*
Local i
Local aChar		:= {"'",",","|","º","  "}//Manter os Espaços duplos sempre por ultimo, para limpeza de espaço duplo da string
Local cRet		:= cTexto
Local nMaxTime	:= 15//execuções maximas.
Local nTime		:= 1

Default lRemoveSpace := .F.

If lRemoveSpace
	aAdd(aChar," ")
EndIf

For i:=1 to Len(aChar)
	nTime :=1
	While AT(aChar[i],cRet) <> 0 .And. nTime <= nMaxTime
		cRet := StrTran(cRet,aChar[i]," ")
		nTime++
	Enddo
Next i

Return ALLTRIM(cRet)

/*
Funcao      : ValidProd
Parametros  : 
Retorno     : 
Objetivos   : Validação se cadastro do produto existe
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*------------------------------*
Static Function ValidProd(cProd)
*------------------------------*
Local lRet := .T.

If Select("VLDPROD") > 0
	VLDPROD->(DbCloseArea())
EndIf
cQry := "SELECT COUNT(*) AS 'QTDE'
cQry += " FROM "+RetSqlName("SB1")
cQry += " WHERE B1_COD		= '"+ALLTRIM(cProd)+"'
cQry += " 	AND B1_MSBLQL	<> '1'
cQry += "	AND D_E_L_E_T_	= ''"
DbUseArea(.T., "TOPCONN", TcGenQry(,,ChangeQuery(cQry)), "VLDPROD", .F., .T.)
If VLDPROD->QTDE == 0
	lRet := .F.
EndIf
VLDPROD->(DbCloseArea())

Return lRet

/*
Funcao      : GrvRastro
Parametros  : 
Retorno     : 
Objetivos   : Gravar dados das tabelas de rastreio
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*---------------------------------------------------------*
Static Function GrvRastro(cFil,cDatatrax,cNum,cEmissao,lOk)
*---------------------------------------------------------*
Local cAlias	:= "N6WS007_01"
Local cQry		:= ""
Local cEtapa	:= "Integração Datatrax"

DEFAULT lOk := .T.

//Verifica se o pedido ja existe.
If Select(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf
cQry := "SELECT COUNT(*) AS 'QTDE'
cQry += " FROM "+RetSqlName("ZX6")
cQry += " WHERE D_E_L_E_T_	= ''
cQry += " 	AND ZX6_FILIAL	= '"+cFil+"'
cQry += "	AND ZX6_DTRAX	= '"+cDatatrax+"'
DbUseArea(.T., "TOPCONN", TcGenQry(,,ChangeQuery(cQry)), cAlias, .F., .T.)
If (cAlias)->QTDE == 0
	cQry := " INSERT INTO "+RetSqlName("ZX6")
	cQry += " VALUES ('"+cFil+"','"+cDatatrax+"','"+cEmissao+"','"+cNum+"',"//4
	cQry += "		'','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','ENABLE','',"//48 campos
	cQry += " 		(SELECT ISNULL(MAX(R_E_C_N_O_),0)+1 FROM "+RetSqlName("ZX6")+"))
	TCSQLEXEC(cQry)
	
	InsertZX7(cFil,cDatatrax,cNum,"Gravado numero de pedido na etapa",cEtapa)
Else
	cQry := " UPDATE "+RetSqlName("ZX6")
	cQry += " SET ZX6_EMISSA='"+cEmissao+"',ZX6_NUM='"+cNum+"'
	cQry += " WHERE ZX6_FILIAL = '"+cFil+"'
	cQry += "		AND ZX6_DTRAX = '"+cDatatrax+"'
	TCSQLEXEC(cQry)
	
	InsertZX7(cFil,cDatatrax,cNum,"Reprocessado pedido na etapa",cEtapa)
EndIf
(cAlias)->(DbCloseArea())

If lOk
	cQry := " UPDATE "+RetSqlName("ZX6")
	cQry += " SET 	ZX6_DTDTX='"+DTOS(Date())+"',
	cQry += " 		ZX6_HRDTX='"+TIME()+"',
	cQry += " 		ZX6_NUM='"+cNum+"'
	cQry += " WHERE ZX6_FILIAL = '"+cFil+"'
	cQry += "		AND ZX6_DTRAX = '"+cDatatrax+"'
	TCSQLEXEC(cQry)
	
	InsertZX7(cFil,cDatatrax,cNum,"Atualizado data e hora do processamento na etapa",cEtapa)
EndIf

Return .T.

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

/*
Funcao      : GrvRastroAdic
Parametros  : 
Retorno     : 
Objetivos   : Gravar dados das tabelas de rastreio adicionais, informações apenas para rastro, informativo apenas no Protheus.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*---------------------------------------------*
Static Function GrvRastroAdic(cFil,cChave,oXml)
*---------------------------------------------*
Local cQry	:= ""
Local cData	:= ""
Local cHora	:= ""

//Gravação da informação de Data/Hora em que o Pedido foi gravado no Datatrax.
If VALTYPE(XmlChildEx(oXml:_NF:_BLOCOA:_BLOCOB,"_DATAENT") ) == "O" .and. !EMPTY(ALLTRIM(oXml:_NF:_BLOCOA:_BLOCOB:_DATAENT:TEXT))
	If LEN(ALLTRIM(oXml:_NF:_BLOCOA:_BLOCOB:_DATAENT:TEXT)) >= 10
		cData	:= substr(ALLTRIM(oXml:_NF:_BLOCOA:_BLOCOB:_DATAENT:TEXT),7,4)+substr(ALLTRIM(oXml:_NF:_BLOCOA:_BLOCOB:_DATAENT:TEXT),1,2)+substr(ALLTRIM(oXml:_NF:_BLOCOA:_BLOCOB:_DATAENT:TEXT),4,2)
		If LEN(ALLTRIM(oXml:_NF:_BLOCOA:_BLOCOB:_DATAENT:TEXT)) > 10
	  		cHora	:= RIGHT(ALLTRIM(oXml:_NF:_BLOCOA:_BLOCOB:_DATAENT:TEXT),8)
  		EndIf
 	EndIf
	cQry := " UPDATE "+RetSqlName("ZX6")
	cQry += " SET 	ZX6_DTENT='"+cData+"',
	cQry += " 		ZX6_HRENT='"+cHora+"'
	cQry += " WHERE ZX6_FILIAL = '"+cFil+"'
	cQry += "		AND ZX6_DTRAX = '"+cChave+"'
	TCSQLEXEC(cQry)
EndIf

cData	:= ""
cHora	:= ""
//Gravação da informação de Data/Hora em que o pedido foi liberado para processamento pelo Datatrax
If VALTYPE(XmlChildEx(oXml:_NF:_BLOCOA:_BLOCOB,"_DATAINI") ) == "O" .and. !EMPTY(ALLTRIM(oXml:_NF:_BLOCOA:_BLOCOB:_DATAINI:TEXT))
	If LEN(ALLTRIM(oXml:_NF:_BLOCOA:_BLOCOB:_DATAINI:TEXT)) >= 10
		cData	:= substr(ALLTRIM(oXml:_NF:_BLOCOA:_BLOCOB:_DATAINI:TEXT),7,4)+substr(ALLTRIM(oXml:_NF:_BLOCOA:_BLOCOB:_DATAINI:TEXT),1,2)+substr(ALLTRIM(oXml:_NF:_BLOCOA:_BLOCOB:_DATAINI:TEXT),4,2)
		If LEN(ALLTRIM(oXml:_NF:_BLOCOA:_BLOCOB:_DATAINI:TEXT)) > 10
	  		cHora	:= RIGHT(ALLTRIM(oXml:_NF:_BLOCOA:_BLOCOB:_DATAINI:TEXT),8)
  		EndIf
 	EndIf
	cQry := " UPDATE "+RetSqlName("ZX6")
	cQry += " SET 	ZX6_DTINI='"+cData+"',
	cQry += " 		ZX6_HRINI='"+cHora+"'
	cQry += " WHERE ZX6_FILIAL = '"+cFil+"'
	cQry += "		AND ZX6_DTRAX = '"+cChave+"'
	TCSQLEXEC(cQry)
EndIf

Return .T.