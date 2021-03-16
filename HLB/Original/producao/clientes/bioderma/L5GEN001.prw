#INCLUDE "apwizard.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "topconn.ch"


/*
Funcao      : L5GEN001
Parametros  : 
Retorno     : 
Objetivos   : Envio do arquivo Txr da OR e Produto para o FTP da Luft
Autor       : Renato Rezende
Data/Hora   : 26/09/2014
Módulo		: Estoque
Cliente		: Bioderma / L5
*/

*---------------------------*
 User Function L5GEN001()
*---------------------------*
Local oNo 		:= LoadBitmap( GetResources(), "LBNO" )
Local oOk 		:= LoadBitmap( GetResources(), "LBTIK" )
Local oWizard
Local oChkTWiz
Local oChkIWiz
Local oLbxWiz 
Local oFiltro

Local nPanel

Local aFiltro	:= {}

Local lChkTWiz 	:= .F.
Local lChkIWiz 	:= .F.

Private cFiltro	:= ""
Private cSerie	:= Space(50)

//Verifica se está na empresa Bioderma
If !(cEmpAnt) $ "L5"
	MsgInfo("Rotina não implamentada para empresa!","HLB BRASIL")
	Return .F.
EndIf

//Opções para selecionar o filtro do oLstBx
aFiltro		:= {"Não Enviados","Todos","Enviados"}

//PAINEL 1
DEFINE WIZARD oWizard TITLE "Wizard" HEADER Alltrim(SM0->M0_NOMECOM) MESSAGE " ";		
TEXT "Rotina desenvolvida para envio ao FTP as notas fiscais de Entrada/Saída" PANEL;
NEXT {|| .T.} FINISH {|| .T.}

//PANEL 2 
//Cria um novo passo (janela) para o wizard

CREATE PANEL oWizard HEADER Alltrim(SM0->M0_NOMECOM) MESSAGE " " PANEL; 
BACK {|| oWizard:nPanel := 2, .T.} NEXT {|| .T.} FINISH {|| (GeraConsulta(),.T.)} EXEC {|| .T.}	

@ 010, 010 TO 125,280 OF oWizard:oMPanel[2] PIXEL                                                       	
@ 20, 15 SAY oSay1 VAR "Parâmetros:" OF oWizard:oMPanel[2] PIXEL
@ 40, 20 SAY oSay2 VAR "Tipo: " OF oWizard:oMPanel[2] PIXEL
@ 40, 55 MSCOMBOBOX oFiltro VAR cFiltro ITEMS aFiltro OF oWizard:oMPanel[2] SIZE 50,009 PIXEL
@ 60, 55 SAY oSay3 VAR "(Separar as Séries por ;. Ex.:1;2;3;;)" OF oWizard:oMPanel[2] PIXEL	
@ 70, 20 SAY oSay4 VAR "Série: " OF oWizard:oMPanel[2] PIXEL
@ 70, 55 MSGET oSerie VAR cSerie VALID Vld(cSerie) OF oWizard:oMPanel[2] SIZE 120,009 PIXEL

oWizard:oDlg:lEscClose := .F.

ACTIVATE WIZARD oWizard CENTERED VALID {|| .T. }

Return .F.

/*
Funcao      : GeraConsulta()
Parametros  : Nenhum
Retorno     : .F.
Objetivos   : Função para gerar as notas que foram e serão enviadas ao FTP
Autor       : Renato Rezende
Data/Hora   : 22/09/2014
*/
*-------------------------------------*
 Static Function GeraConsulta()
*-------------------------------------*
Local aStruSF1 		:= {}
Local aCpos    		:= {}
Local aButtons 		:= {} 
Local aColors  		:= {}
Local aSizFrm 		:= {}
Local aSr			:= ""

Local lInverte		:= .F.

Local cQuery		:= ""

Private lRetMain	:= .F.
Private cMarca 		:= GetMark()

If Select("TempSF1") > 0
	TempSF1->(DbCloseArea())	               
EndIf  

aadd(aColors,{"Alltrim(TempSF1->F1_P_ID)<>''","BR_VERMELHO"}) 
aadd(aColors,{"Alltrim(TempSF1->F1_P_ID)==''","BR_VERDE"}) 

Aadd(aCpos, {"cFTP"			,"",				,})
Aadd(aCpos, {"cStatus"  	,"","Status"		,}) 
Aadd(aCpos, {"F1_TIPO"		,"","Tipo Doc."		,})  
Aadd(aCpos, {"F1_DOC"		,"","Documento"		,}) 
Aadd(aCpos, {"F1_SERIE"		,"","Série"			,}) 
Aadd(aCpos, {"F1_FORNECE"	,"","Fornecedor"	,})
Aadd(aCpos, {"F1_LOJA"		,"","Loja"			,})
Aadd(aCpos, {"F1_P_ID"		,"","Id Envio"		,})
Aadd(aCpos, {"F1_EMISSAO"	,"","Dt. Emissão"	,})
                 
Aadd(aStruSF1, {"F1_FILIAL"   ,"C", 2,0})
Aadd(aStruSF1, {"cFTP"  	  ,"C", 2,0})
Aadd(aStruSF1, {"cStatus"     ,"C",14,0})
Aadd(aStruSF1, {"F1_TIPO"     ,"C", 1,0})
Aadd(aStruSF1, {"F1_DOC"      ,"C", 9,0})
Aadd(aStruSF1, {"F1_SERIE "   ,"C", 3,0})
Aadd(aStruSF1, {"F1_EMISSAO"  ,"C", 8,0})
Aadd(aStruSF1, {"F1_FORNECE"  ,"C", 6,0})
Aadd(aStruSF1, {"F1_LOJA"     ,"C", 2,0})
Aadd(aStruSF1, {"F1_P_ID"     ,"C", 9,0})
   
cNome := CriaTrab(aStruSF1, .T.)                   
DbUseArea(.T.,"DBFCDX",cNome,'TempSF1',.F.,.F.)       
 	
If Select("F1QRY") > 0
	F1QRY->(DbCloseArea())	               
EndIf

//Verificando os Documentos diponíveis para envio ao FTP.    
cQuery:=" SELECT * FROM "+RetSqlName("SF1")+" AS F1 "
cQuery+="  WHERE F1.D_E_L_E_T_ <> '*' "
//Filtro de Status
If Alltrim(cFiltro)=="Não Enviados"
	cQuery+="	 AND (F1.F1_P_ID = '') "
ElseIf Alltrim(cFiltro)=="Enviados"
	cQuery+="	 AND (F1.F1_P_ID <> '') "
Else
	cQuery+="	 AND (F1.F1_P_ID = '' OR F1.F1_P_ID <> '') "
EndIf
//Filtro de Serie
If !Empty(Alltrim(cSerie))
	aSr 	:= SEPARA(Alltrim(cSerie) , ';') 
	cSerie 	:= "("
	For nX := 1 To Len( aSr )
		cSerie += "'" + Alltrim(aSr[nX]) + "',"
	Next nX
	cSerie := Substr( cSerie, 1, Len(cSerie)-1) + ")"
	cQuery += "	 AND F1.F1_SERIE IN " + cSerie
EndIf
cQuery+=" ORDER BY F1.F1_EMISSAO+F1.F1_DOC DESC "

TCQuery cQuery ALIAS "F1QRY" NEW

F1QRY->(DbGoTop())
If !(F1QRY->(!BOF() .and. !EOF()))
	MsgStop("Não existe OR para envio!","HLB BRASIL")
	Return .F.
EndIf

F1QRY->(DbGoTop())
While F1QRY->(!EOF())
	RecLock("TempSF1",.T.)
	TempSF1->F1_FILIAL  := F1QRY->F1_FILIAL
	TempSF1->F1_DOC  	:= F1QRY->F1_DOC
	TempSF1->F1_TIPO	:= F1QRY->F1_TIPO
	TempSF1->F1_SERIE	:= F1QRY->F1_SERIE
	If Alltrim(F1QRY->F1_P_ID)==""
		TempSF1->cStatus:="Não Enviado"
	Else
		TempSF1->cStatus:="Enviado"
	EndIf	
	TempSF1->F1_EMISSAO	:= F1QRY->F1_EMISSAO
	TempSF1->F1_FORNECE	:= F1QRY->F1_FORNECE   
	TempSF1->F1_LOJA	:= F1QRY->F1_LOJA
	TempSF1->F1_P_ID	:= F1QRY->F1_P_ID
	TempSF1->(MsUnlock())
	F1QRY->(DbSkip())
EndDo

aAdd(aButtons,{"Marcar", {|| MarcaTds("TempSF1")},"Marca/Desmarca Todos ","Marca/Desmarca Todos",{|| .T.}})

// Faz o calculo automatico de dimensoes de objetos  
aSizFrm := MsAdvSize()

TempSF1->(DbGoTop())
DEFINE MSDIALOG oDlg TITLE "Envio de OR ao FTP" From aSizFrm[7],0 To aSizFrm[6],aSizFrm[5] of oMainWnd PIXEL
	@ 010, 006 TO 035,(aSizFrm[5]/2)-5 LABEL "" OF oDlg PIXEL
	@ 020, 015 Say  "SELECIONE APENAS AS ORDENS DE RECEBIMENTOS QUE SERÃO ENVIADOS AO FTP." COLOR CLR_HBLUE,CLR_WHITE PIXEL SIZE 500,6 OF oDlg

	oMarkPrd:= MsSelect():New("TempSF1","cFTP",,aCpos,@lInverte,@cMarca,{40,6,(aSizFrm[6]/2)-15,(aSizFrm[5]/2)-5},,,,,aColors)
	oMarkPrd:bMark:= {|| Disp()}  

ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,	{||	Processa({|| If(GeraTxt(),oDlg:End(),.F.)})},;     	   
													{|| oDlg:End()},,aButtons),oMarkPrd:oBrowse:Refresh()) CENTERED   

Return .F.

/*
Funcao      : GeraTxt
Parametros  : Nenhum
Retorno     : .T.
Objetivos   : Gera o TXT da OR e Produto
Autor     	: Renato Rezende
Data     	: 23/09/2014
*/
*---------------------------*
 Static Function GeraTxt() 
*---------------------------*
Local lMarcado 		:= .F.
Local lConnect   	:= .F.

Local oProcess

Private nRecCount	:= 0 

Private cNota		:= ""
Private aArq		:= {}
Private cPath 		:= GETMV("MV_P_FTP",,"")//Caminho do FTP
Private clogin		:= GETMV("MV_P_USR",,"")//Usuario do FTP
Private cPass  		:= GETMV("MV_P_PSW",,"")//Senha do FTP
Private cEmail 		:= GETMV("MV_P_00019",,"")  //E-mail que recebem notificação de novo arquivo no FTP 
Private cDirFtp1 	:= GETMV("MV_P_00020",,"/") //Diretorio no FTP para upload de arquivos txt Prod

Private cDirOR		:= "\FTP\L5\OR\" 
Private cDirProd	:= "\FTP\L5\PROD\"

ProcRegua(nRecCount)

TempSF1->(DbGoTop())
While TempSF1->(!EOF())
	//Start Regua de Processamento
	IncProc("Processando...") 
	//Checa se marcou pelo menos um item.
	If !Empty(Alltrim(TempSF1->cFTP))
		lMarcado:=.T.
		nRecCount++
	EndIf
	TempSF1->(DbSkip()) 
EndDo

If !lMarcado
	MsgStop("Não foi selecionado nenhuma OR!","HLB BRASIL")
	TempSF1->(DbGoTop()) 
	Return .F.
Else
	//Ajusta a Pasta de Origem no Servidor - Temporaria
	If ExistDir("\FTP")
		If !ExistDir("\FTP\"+cEmpAnt)
			MakeDir("\FTP\"+cEmpAnt+"\OR\")
			MakeDir("\FTP\"+cEmpAnt+"\PROD\")
		EndIf
	Else
		MakeDir("\FTP")
		MakeDir("\FTP\"+cEmpAnt)
	EndIf
	If !ExistDir("\FTP\"+cEmpAnt)
		MsgInfo("Falha ao carregar diretório FTP no Servidor!","HLB BRASIL")
		Return .F.
	EndIf
	
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
	FTPDirChange(cDirFtp1)

	//Chamando a Função para Gerar o Arquivo Txt do Produto
	TxtProd()
	//Chamando a Função para Gerar o Arquivo Txt da OR
	TxtOr()
	
	//Upload
	oProcess := MsNewProcess():New({|| UP2FTP(@oProcess) },"Upload","Processando...",.F.)
	oProcess:Activate()

	//Encerra conexão com FTP
	FTPDisconnect()	
EndIf

Return .T.

/*
Funcao      : TxtOr
Parametros  : Nenhum
Retorno     : .T.
Objetivos   : Gera TXT com as OR
Autor     	: Renato Rezende
Data     	: 24/09/2014
*/
*---------------------------------*
 Static Function TxtOr()
*---------------------------------*
Local cMsg			:= ""
Local cSeek			:= "" 
Local cChave		:= ""
Local cTxtOR		:= ""
Local cCtrlEstoque	:= ""

Local nHdl			:= 0
Local nItem			:= 0

//ProcRegua(nRecCount)

TempSF1->(DbGoTop())
While TempSF1->(!EOF())
	//IncProc("Processando...")
    //Valida se está marcado o produto
	If !Empty(Alltrim(TempSF1->cFTP))
		
		//Criando 1 arquivo por documento no FTP
		cTxtOR := "RDOC_"+DTOS(dDataBase)+"_DOC_"+Alltrim(TempSF1->F1_DOC)+".txt"
		nHdl:= fCreate(cDirOR+cTxtOR)
		If nHdl == -1 // Testa se o arquivo foi gerado 
			cMsg:="O arquivo "+cTxtOR+" nao pode ser executado." 
			MsgAlert(cMsg,"Atenção")
			Return .F.  
		EndIf
		//Guardando as NF para enviar no corpo do email
		cNota+= "NF: "+TempSF1->F1_DOC+" / SÉRIE: "+TempSF1->F1_SERIE+"<br />"
		//Header - Ordem de Recebimento
		DbSelectArea("SF1")
		SF1->(DbSetOrder(1))
		If SF1->(DbSeek(xFilial("SF1")+TempSF1->F1_DOC+TempSF1->F1_SERIE+TempSF1->F1_FORNECE+TempSF1->F1_LOJA)) 
			fWrite(nHdl,"ERP"+Space(7);								//Código do Sistema de Origem. Fixo
						+"RDOC"; 									//Nome do Arquivo. Fixo
						+"RDOC00"+Space(2);							//Nome da Interface. Fixo
						+"00";										//Tipo de Registro. Fixo
						+Space(6);									
						+Space(16);
						+Space(6);
						+Space(16);
						+"2"+Space(2);								//Armazém (Site). VERIFICAR			
						+PADR(Alltrim(SF1->F1_ESPECIE),6);			//Tipo do Documento
						+PADR(Alltrim(SF1->F1_DOC),30);				//Id do Documento
						+Space(6);									//Modelo do Documento.
						+PADR(Alltrim(SF1->F1_SERIE),3);			//Serie do Documento.
						+Space(2);									//Subserie
						+PADR(Alltrim(SF1->F1_CHVNFE),44);			//Chave Nfe
						+"E";								   		//Doc. Entrada
						+STRTRAN(DtoC(SF1->F1_EMISSAO),"/");  		//Data de Recebimento
						+STRTRAN(DtoC(SF1->F1_EMISSAO),"/");		//Data de Emissao
						)
			//Verificando se é cliente ou fornecedor
			If SF1->F1_TIPO $ "N/B"
		        //Posicionando no Emitente
		    	DbSelectArea("SA2")
		    	SA2->(DbSetOrder(1))
		    	SA2->(DbSeek(xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA))
		    		fWrite(nHdl,PADR(Alltrim(SA2->A2_CGC),16))			//CNPJ Emitente
		    	SA2->(DbCloseArea())
		 	//Devolução
	  		Else
		        //Posicionando no Emitente
		    	DbSelectArea("SA1")
		    	SA1->(DbSetOrder(1))
		    	SA1->(DbSeek(xFilial("SA1")+SF1->F1_FORNECE+SF1->F1_LOJA))
		    		fWrite(nHdl,PADR(Alltrim(SA1->A1_CGC),16))			//CNPJ Emitente
		    	SA1->(DbCloseArea())	  		
	  		EndIf
	    	//Verificando quantos itens possuem a nota
	    	cChave := TempSF1->F1_FILIAL+TempSF1->F1_DOC+TempSF1->F1_SERIE+TempSF1->F1_FORNECE+TempSF1->F1_LOJA 
	    	fWrite(nHdl,PADR(Alltrim(SM0->M0_CGC),16);					//CNPJ Destinatario
						+StrZero(QtdItemOR(cChave),5);					//Qtd. Itens da nota.
	    				+Space(22);										//Frete						
	    				+Space(22);										//Seguro
	    				+Space(22);										//Desconto
	    				+Space(22);										//Despesas Acessórias
	    				+StrZero(ROUND(SF1->F1_VALMERC,2)*100,22);		//Total do Produto
	    				+StrZero(ROUND(SF1->F1_VALBRUT,2)*100,22);		//Total da Nota
	    				+"ENT_DEF1"+Space(2)+Chr(13)+Chr(10);			//Tipo de movimento
	    				)
	    	
	    	//Transportadora
	    	fWrite(nHdl,"ERP"+Space(7);								//Código do Sistema de Origem. Fixo
						+"RDOC"; 									//Nome do Arquivo. Fixo
						+"RDOC04"+Space(2);							//Nome da Interface. Fixo
						+"04";										//Tipo de Registro. Fixo
						+"67546671000123  ";						//CNPJ da Transportadora									
						+"0"+Space(1);								//Tipo de Transporte
						+Space(155);								//Qtd.-Espécie-Marca-Numeração-Peso Bruto-Peso Líquido.(Volume) Opcional
						+"3"+Space(2);								//Tipo de Frete
						+"ABC1234"+Space(1);						//Placa do Veículo
						+Space(3)+Chr(13)+Chr(10);					//UF do Veículo
						)
		EndIf
		
		//Montando os Itens da OR			
		DbSelectArea("SD1")
		SD1->(DbSetOrder(1))
		//Verificando os itens da nota
		If SD1->(DbSeek(xFilial("SD1")+TempSF1->F1_DOC+TempSF1->F1_SERIE+TempSF1->F1_FORNECE+TempSF1->F1_LOJA))
			While SD1->(!EOF()) .AND. TempSF1->F1_DOC+TempSF1->F1_SERIE+TempSF1->F1_FORNECE+TempSF1->F1_LOJA==SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
				SB1->(DbSetOrder(1))
				If SB1->(DbSeek(xFilial("SB1")+SD1->D1_COD))
					nItem+= 1
					fWrite(nHdl,"ERP"+Space(7);						  	  			//Código do Sistema de Origem. Fixo
				   				+"RDOC"; 							  	  			//Nome do Arquivo. Fixo
				   				+"RDOC20"+Space(2);					  	  			//Nome da Interface. Fixo
				   				+"20";								   	  			//Tipo de Registro. Fixo
				   				+StrZero(nItem,5);					   	  			//Numero do item
				   				+PADR(Alltrim(SB1->B1_COD),40);		   	   			//Código do Produto
				   				+PADR(Alltrim(SB1->B1_DESC),500);	   	   			//Descrição do Produto
				   				+"UN"+Space(8);	  						   			//Unidade de Medida. Fixo
				   				+StrZero(ROUND(SD1->D1_QUANT,9)*1000000000,18); 	//Quantidade
				   				+StrZero(ROUND(SD1->D1_VUNIT,9)*1000000000,22); 	//Valor Unitário
				   				+StrZero(ROUND(SD1->D1_TOTAL,9)*1000000000,22); 	//Valor Total
				   				+PADR(Alltrim(SB1->B1_POSIPI),10);	  	 			//NCM
				   				+PADR(Alltrim(SD1->D1_LOTECTL),20);					//Lote
				   				+PADR(Alltrim(SB1->B1_ORIGEM),1);					//Origem da mercadoria	
				   				+"00"+Space(1);						  				//Situação Tributária. Fixo
								+StrZero(ROUND(SD1->D1_BASEICM,9)*1000000000,22);	//Base ICMS
								+StrZero(ROUND(SD1->D1_VALICM,9)*1000000000,22); 	//Valor ICMS
								+StrZero(ROUND(SD1->D1_PICM,7)*10000000,10);		//Alíquota ICMS
								+StrZero(ROUND(SD1->D1_BASEIPI,9)*1000000000,22);	//Base IPI
								+StrZero(ROUND(SD1->D1_VALIPI,9)*1000000000,22);	//Valor IPI
								+StrZero(ROUND(SD1->D1_IPI,7)*1000000000,10);		//Aliquota IPI
				   				+"00";							   	  	  			//Situação do Item
				   				+"00"+Space(28)+Chr(13)+Chr(10);   	  	  			//Motivo Bloqueio
				   				)
				   				
					//Gravando na Variável cCtrlEstoque para ser gravado no final do arquivo
					cCtrlEstoque += "ERP"+Space(7)										//Sistema de Origem
					cCtrlEstoque +=	"RDOC"												//Nome do arquivo
					cCtrlEstoque +=	"RDOC21"+Space(2)									//Nome da Interface
					cCtrlEstoque +=	"21"												//Tipo de registro
					cCtrlEstoque +=	StrZero(nItem,5)						   			//Numero Sequencial.
					cCtrlEstoque +=	STRTRAN(DtoC(SD1->D1_DTVALID),"/")+Chr(13)+Chr(10)	//Data de Recebimento
													
				EndIf
				//Gravando dados na tabela de controle de arquivos enviados ao FTP da Luft
				If cSeek <> TempSF1->F1_FILIAL+TempSF1->F1_DOC+TempSF1->F1_FORNECE+TempSF1->F1_SERIE+TempSF1->F1_LOJA
					ChkFile("ZX0")
					ZX0->(DbSetOrder(1))
					If !ZX0->(DbSeek(xFilial("ZX0")+TempSF1->F1_DOC+TempSF1->F1_SERIE+TempSF1->F1_FORNECE+TempSF1->F1_LOJA+"OR"))
						RecLock("ZX0", .T.)//Inclusão
							ZX0->ZX0_FILIAL	:= xFilial("ZX0")
							ZX0->ZX0_DOC	:= TempSF1->F1_DOC
							ZX0->ZX0_SERIE	:= TempSF1->F1_SERIE
							ZX0->ZX0_FORNEC	:= TempSF1->F1_FORNECE
							ZX0->ZX0_LOJA	:= TempSF1->F1_LOJA
							ZX0->ZX0_TIPO	:= "OR"
							ZX0->ZX0_USER	:= cUserName
							ZX0->ZX0_DATA	:= Date()
							ZX0->ZX0_HORA	:= Time()
							ZX0->ZX0_ARQN	:= cTxtOR
							ZX0->ZX0_ID		:= SF1->F1_P_ID
						ZX0->(MsUnlock())
						cSeek:=TempSF1->F1_FILIAL+TempSF1->F1_DOC+TempSF1->F1_FORNECE+TempSF1->F1_SERIE+TempSF1->F1_LOJA
						//Gravando conteúdo que será mostrado no corpo do email
						AADD(aArq,{cDirOR+"ENV\",Alltrim(cTxtOR)})
					EndIf	
				EndIf
		   		SD1->(DbSkip())
			EndDo
			//Gravando o controle de estoque no final do arquivo da OR
			fWrite(nHdl,cCtrlEstoque)
			//Limpa a variável
			cCtrlEstoque:=""
			nItem		:=0
			//Fechando o Arquivo
			fClose(nHdl)
		EndIf
	EndIf
	TempSF1->(DbSkip())
EndDo

Return .T.

/*
Funcao      : TxtProd
Parametros  : Nenhum
Retorno     : .T.
Objetivos   : Gera TXT com os produtos da OR
Autor     	: Renato Rezende
Data     	: 23/09/2014
*/
*---------------------------------*
 Static Function TxtProd()
*---------------------------------*
Local cMsg			:= ""
Local cSeek			:= ""
Local cChave		:= ""
Local cTxtProd		:= ""

Local nHdl			:= 0

TempSF1->(DbGoTop())
While TempSF1->(!EOF())
    //Valida se está marcado a nota
	If !Empty(Alltrim(TempSF1->cFTP))
		cTxtProd := "CPRD_"+DTOS(dDataBase)+"_DOC_"+Alltrim(TempSF1->F1_DOC)+".txt"
		nHdl:= fCreate(cDirProd+cTxtProd)
		If nHdl == -1 // Testa se o arquivo foi gerado 
			cMsg:="O arquivo "+cTxtProd+" nao pode ser executado." 
			MsgAlert(cMsg,"Atenção")  
			Return .F.  
		EndIf
		cChave := TempSF1->F1_FILIAL+TempSF1->F1_DOC+TempSF1->F1_SERIE+TempSF1->F1_FORNECE+TempSF1->F1_LOJA
		//Verificando os itens da nota
		ItensProd(cChave)
		//Posicionando no primeiro registro do retorno da função ItensProd
		D1SQL->(DbGoTop())
		While D1SQL->(!EOF())
			SB1->(DbSetOrder(1))
			If SB1->(DbSeek(xFilial("SB1")+D1SQL->D1_COD))
				//Verificando se o produto já foi enviado ao FTP
				If SB1->B1_P_ENV <> "S"
					fWrite(nHdl,"ERP"+Space(7);							//Código do Sistema de Origem. Fixo
				   				+"CPRD"; 								//Nome do Arquivo. Fixo
				   				+"CPRDH"+Space(3);						//Nome da Interface. Fixo
				   				+"1"+Space(2);							//Site. Fixo
				   				+"1"+Space(11);							//Proprietário. Fixo
				   				+PADR(Alltrim(SB1->B1_COD),40);			//Código do Produto
				   				+PADR(Alltrim(SB1->B1_DESC),80);		//Descrição do Produto
				   				+"UN"+Space(8);	  						//Unidade de Medida. Fixo
				   				+PADR(Alltrim(SB1->B1_POSIPI),10);		//NCM
				   				+Space(30);								//Familia
				   				+Space(8);								//Grupo
				   				+Space(30);						   		//Sub-Grupo
				   				+"P3"+Space(8);					   		//Perfil. P3 - controla por lote e data de validade. Fixo
				   				)
					DbSelectArea("SB5")
					SB5->(DbSetOrder(1))
					If SB5->(DbSeek(xFilial("SB5")+D1SQL->D1_COD))
						fWrite(nHdl,+PADR(Alltrim(SB5->B5_CEME),80);	//Descrição do Produto 2
									+Space(6);							//Classe de Risco
				   					+Space(30);							//Código ONU
				   					+PADR(Alltrim(SB1->B1_CODBAR),30);	//Código de Barras
				   					+StrZero(0,18);						//Comprimento 
				   					+StrZero(0,18);						//Largura 
				   					+StrZero(0,18);						//Altura
				   					)
					Else
						fWrite(nHdl,+Space(80);							//Descrição do Produto 2
									+Space(6);							//Classe de Risco
				   					+Space(30);							//Código ONU
				   					+PADR(Alltrim(SB1->B1_CODBAR),30);	//Código de Barras
				   					+StrZero(0,18);						//Comprimento 
				   					+StrZero(0,18);						//Largura 
				   					+StrZero(0,18);						//Altura
				   					)					
					EndIf
					fWrite(nHdl,"UN"+Space(16);									//Volume do Produto. Fixo
								+"1"+Space(4);									//Volume
								+StrZero(ROUND(SB1->B1_PESO,9)*1000000000,18);	//Peso do Produto
								+StrZero(0,9);								
								+StrZero(0,9);
								+Space(14);
								+StrZero(0,5);
								+Space(1)+Chr(13)+Chr(10);
								)
					//Marcando que o produto foi enviado ao FTP
					RecLock("SB1",.F.)
						SB1->B1_P_ENV := "S"
					SF1->(MsUnlock())
				EndIf
			EndIf
			//Gravando dados na tabela de controle de arquivos enviados ao FTP da Luft
			If cSeek <> TempSF1->F1_FILIAL+TempSF1->F1_DOC+TempSF1->F1_FORNECE+TempSF1->F1_SERIE+TempSF1->F1_LOJA
				ChkFile("ZX0")
				ZX0->(DbSetOrder(1))
				If !ZX0->(DbSeek(xFilial("ZX0")+TempSF1->F1_DOC+TempSF1->F1_SERIE+TempSF1->F1_FORNECE+TempSF1->F1_LOJA+"P"))
					RecLock("ZX0", .T.)//Inclusão
						ZX0->ZX0_FILIAL	:= xFilial("ZX0")	
						ZX0->ZX0_DOC	:= TempSF1->F1_DOC
						ZX0->ZX0_SERIE	:= TempSF1->F1_SERIE
						ZX0->ZX0_FORNEC	:= TempSF1->F1_FORNECE
						ZX0->ZX0_LOJA	:= TempSF1->F1_LOJA
						ZX0->ZX0_TIPO	:= "P"
						ZX0->ZX0_USER	:= cUserName
						ZX0->ZX0_DATA	:= Date()
						ZX0->ZX0_HORA	:= Time()
						ZX0->ZX0_ARQN	:= cTxtProd
						ZX0->ZX0_ID		:= GetSxeNum("ZX0","ZX0->ZX0_ID") 
					ZX0->(MsUnlock())
					//Gravando o Registro utilizado no SXE e SXF pelo GetSxeNum.
					ConfirmSX8()
					//Gravando o ID de vínculo com a Tabela ZX0 na SF1
					DbSelectArea("SF1")
					SF1->(DbSetOrder(1))
					If SF1->(DbSeek(xFilial("SF1")+TempSF1->F1_DOC+TempSF1->F1_SERIE+TempSF1->F1_FORNECE+TempSF1->F1_LOJA))
						RecLock("SF1",.F.)
							SF1->F1_P_ID := ZX0->ZX0_ID 
						SF1->(MsUnlock())	
					EndIf
					cSeek:=TempSF1->F1_FILIAL+TempSF1->F1_DOC+TempSF1->F1_FORNECE+TempSF1->F1_SERIE+TempSF1->F1_LOJA
					//Gravando conteúdo que será mostrado no corpo do email
					AADD(aArq,{cDirProd+"ENV\",Alltrim(cTxtProd)})
				EndIf	
			EndIf
	   		D1SQL->(DbSkip())
		EndDo
		fClose(nHdl)
	EndIf
	TempSF1->(DbSkip())
EndDo

Return .T. 

/*
Funcao      : MarcaTds
Parametros  : PAlias
Retorno     : Nenhum
Objetivos   : Marcar/Desmarcar todos os itens da tela.
Autor     	: Renato Rezende
Data     	: 22/09/2014
*/
*---------------------------------*
 Static Function MarcaTds(PAlias)
*---------------------------------* 
DbSelectArea(PAlias)   
(PAlias)->(DbGoTop())  
While (PAlias)->(!EOF())
	If Alltrim(TempSF1->cStatus) == "Não Enviado"
		RecLock(PAlias,.F.)     
		If (PAlias)->cFTP == cMarca     		
			(PAlias)->cFTP:=Space(02)         		
		Else
			(PAlias)->cFTP:= cMarca       
		EndIf 
		(PAlias)->(MsUnlock())
	EndIf
	(PAlias)->(DbSkip())
EndDo      
(PAlias)->(DbGoTop())      
      
Return

/*
Funcao      : Disp
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Marcar/Desmarcar itens da tela.
Autor     	: Renato Rezende
Data     	: 22/09/2014
*/
*----------------------*
 Static Function Disp() 
*----------------------*
RecLock("TempSF1",.F.)
If Alltrim(TempSF1->cStatus) == "Não Enviado"
	If Marked("cFTP")        
       TempSF1->cFTP := cMarca
	Else        
       TempSF1->cFTP := ""
	Endif
Else
	TempSF1->cFTP := ""            
Endif  
TempSF1->(MsUnlock())

Return

/*
Funcao      : Vld()
Parametros  : cSerie
Retorno     : lRet
Objetivos   : Função para validar o conteudo digitado no cSerie
Autor       : Renato Rezende
Data/Hora   : 19/09/2014
*/
*--------------------------------*
 Static Function Vld(cCampo)
*--------------------------------*
Local lRet 		:= .T.
Local aCaract	:= {}
Local nPos 		:= 0
Local nR		:= 0

aCaract := {".","-"," ","/","\","*","#","_","+",","}
If !Empty(Alltrim(cCampo))
	For nR := 1 to Len(aCaract)
		nPos:=At(aCaract[nR],Alltrim(cCampo))
		If nPos > 0
			lRet := .F.
		EndIf 
	Next
 	//Campo Serie
	IF !lRet
   		msgInfo("Favor utilizar ; para separar as Séries. Obrigado!","HLB BRASIL")	
	EndIf
EndIf

Return lRet

/*
Funcao      : QtdItemOR()
Parametros  : cChave
Retorno     : SQL->QTD
Objetivos   : Função para contar a quantidade de itens da OR
Autor       : Renato Rezende
Data/Hora   : 26/09/2014
*/   
*----------------------------------------*
 Static Function QtdItemOR(cChave)
*----------------------------------------* 
Local cQuery2	:= ""

If Select("SQL") > 0
	SQL->(DbCloseArea())
EndIf                        

cQuery2 := "SELECT COUNT(*) AS QTD"+Chr(10)
cQuery2 += " FROM "+RetSqlName("SD1")+Chr(10)
cQuery2 += " WHERE D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA='"+cChave+"'"+Chr(10)
cQuery2 += " AND D_E_L_E_T_ <> '*' "

TCQuery cQuery2 ALIAS "SQL" NEW

Return SQL->QTD

/*
Funcao      : ItensProd()
Parametros  : cChave
Retorno     : D1SQL
Objetivos   : Função para carregar os produtos da OR
Autor       : Renato Rezende
Data/Hora   : 30/09/2014
*/   
*----------------------------------------*
 Static Function ItensProd(cChave)
*----------------------------------------* 
Local cQuery3	:= ""

If Select("D1SQL") > 0
	D1SQL->(DbCloseArea())
EndIf                        

cQuery3 := "SELECT D1_COD,D1_LOCAL"
cQuery3 += " FROM "+RetSqlName("SD1")+Chr(10)
cQuery3 += " WHERE D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA='"+cChave+"'"+Chr(10)
cQuery3 += " AND D_E_L_E_T_ <> '*' "
cQuery3 += " GROUP BY  D1_COD,D1_LOCAL"

TCQuery cQuery3 ALIAS "D1SQL" NEW

Return

/*
Funcao      : SendMail
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Enviar Email de Notificação
Autor       : Renato Rezende
Data/Hora   : 26/09/2014
*/
*-----------------------------*
 Static Function SendMail()
*-----------------------------*
Local cMsg 		:= Email()
Local cFile		:= ""

Local nS		:= 0

If EMPTY(cEmail)
	Return .T.
EndIf

cFile :="\FTP\L5\ANEXOS.ZIP"

//Compactando Arquivos
For nS:=1 To Len(aArq)
	compacta(aArq[nS][1]+aArq[nS][2],cFile)
Next nS

oEmail          := DEmail():New()
oEmail:cFrom   	:= "totvs@hlb.com.br"
oEmail:cTo		:= PADR(cEmail,200)
oEmail:cSubject	:= padr("Notificacao do txt de OR e Prod no FTP.",200)
oEmail:cBody   	:= cMsg
oEmail:cAnexos := cFile
oEmail:Envia()

FERASE(cFile)

Return .T.

/*
Funcao      : Email()
Parametros  : Nenhum
Retorno     : cHtml
Objetivos   : Modelo-Email
Autor       : Renato Rezende
Data/Hora   : 26/09/2014
*/   
*------------------------*
 Static Function Email()
*------------------------*
Local cHtml := ""

Local nP	:= 0

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
cHtml += '				<td width="631" height="25"> <font size="3" face="tahoma" color="#551A8B"><b>Tipo: Ordem de Recebimento e Produtos</b></font>   </td>
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
cHtml += '				<td width="631" height="25"><font size="2" face="tahoma" color="#8064A1">Conteudo:</font>
cHtml += '											<BR>
cHtml += '										<br><font size="2" face="tahoma">'+ALLTRIM(cNota)+'</font>
cHtml += '				</td>
cHtml += '			</tr>
cHtml += '			<tr><td width="631" height="20"></td></tr>
cHtml += '			<tr><td width="631" height="1" bgcolor="#8064A1"></td></tr>
cHtml += '			<tr><td width="631" height="20"></td></tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="25"><font size="2" face="tahoma" color="#8064A1">Arquivos Gerados:</font>
cHtml += '											<BR>
For nP:=1 to Len(aArq)
	cHtml += '										<font size="2" face="tahoma">'+aArq[nP][2]+'</font><br />
Next nP
cHtml += '				</td>
cHtml += '			</tr>
cHtml += '			<tr><td width="631" height="20"></td></tr>
cHtml += '			<tr><td width="631" height="1" bgcolor="#8064A1"></td></tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="20"><p align=center><font size="2" face="tahoma">Mensagem automatica, nao responder.</p></td></font>
cHtml += '			</tr>
cHtml += '		</table>
cHtml += '	</body>
cHtml += '</html>

Return cHtml

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
   
Return lRet

/*
Funcao      : UP2FTP
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para fazer upload de arquivos no FTP
Obs         :
*/ 
*---------------------------------*
 Static Function UP2FTP(oProcess)
*---------------------------------*
//Barra de incremeto
oProcess:SetRegua1(4)
oProcess:IncRegua1("Processando FTP:'"+ALLTRIM(cPath)+"' Aguarde...")

aArqs := Directory(cDirProd+"*.txt")
For i:=1 to Len(aArqs)
	FTPUpLoad(cDirProd+alltrim(aArqs[i][1]),alltrim(aArqs[i][1]))
	//Copiando arquivo para a pasta de enviados
	__CopyFile(cDirProd+alltrim(aArqs[i][1]),cDirProd+"ENV\"+alltrim(aArqs[i][1]))
	//Excluindo arquivo da pasta principal
	FERASE(cDirProd+alltrim(aArqs[i][1]))
Next i               
oProcess:IncRegua1("Processando FTP:'"+ALLTRIM(cPath)+"' Aguarde...")

aArqs := Directory(cDirOr+"*.txt")
For i:=1 to Len(aArqs)
	FTPUpLoad(cDirOr+alltrim(aArqs[i][1]),alltrim(aArqs[i][1]))
	//Copiando arquivo para a pasta de enviados
	__CopyFile(cDirOr+alltrim(aArqs[i][1]),cDirOr+"ENV\"+alltrim(aArqs[i][1]))
	//Excluindo arquivo da pasta principal
	FERASE(cDirOr+alltrim(aArqs[i][1]))
Next i
oProcess:IncRegua1("Processando FTP:'"+ALLTRIM(cPath)+"' Aguarde...")

//Mandando email
SendMail()
oProcess:IncRegua1("Processando FTP:'"+ALLTRIM(cPath)+"' Aguarde...")

Return .T.

/*
Funcao      : compacta
Parametros  : cArquivo,cArqRar
Retorno     : lRet
Objetivos   : Função para compactar os arquivos
Autor       : 
Data/Hora   : 
*/
*------------------------------------------*
 Static Function compacta(cArquivo,cArqRar)
*------------------------------------------*
Local lRet		:=.F.
Local cRootPath	:=GetSrvProfString("RootPath", "\undefined")//retorna o caminho do rootpath
Local cCommand 	:= 'C:\Program Files (x86)\WinRAR\WinRAR.exe a -ep1 -o+ "'+cRootPath+cArqRar+'" "'+cRootPath+cArquivo+'"'
Local lWait  	:= .T.
Local cPath     := "C:\Program Files (x86)\WinRAR\"

lRet:=WaitRunSrv( cCommand , lWait , cPath )
/* COMANDOS RAR
    a       Adicionar arquivos ao arquivo.
            Exemplo:
            criar ou atualizar o arquivo existente myarch, adicionado todos os
            arquivos no diretório atual
            rar a myarch
   -ep1    Excluir diretório base dos nomes. Não salvar o caminho fornecido na
            linha de comandos.
            Exemplo:
            todos os arquivos e diretórios do diretório tmp serão adicionados
            ao arquivo 'pasta', mas o caminho não incluirá 'tmp\'
            rar a -ep1 -r pasta 'tmp\*'
            Isto é equivalente aos comandos:
            cd tmp
            rar a -r pasta
            cd ..
    -o+     Substituir arquivos existentes.
    m[f]    Mover para o arquivo [apenas arquivos]. Ao mover arquivos e
            diretórios irá resultar numa eliminação dos arquivos e
            diretórios após uma operação de compressão bem sucedida.
            Os diretórios não serão removidos se o modificador 'f' for
            utilizado e/ou o comando adicional '-ed' for aplicado.    */

Return lRet