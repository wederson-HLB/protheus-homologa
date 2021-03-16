#INCLUDE "apwizard.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "topconn.ch"


/*
Funcao      : L5GEN003
Parametros  : 
Retorno     : 
Objetivos   : Envio do arquivo Txt da OE e Cliente para o FTP da Luft
Autor       : Renato Rezende
Data/Hora   : 01/10/2014
Módulo		: Faturamento
Cliente		: Bioderma / L5
*/

*---------------------------*
 User Function L5GEN003()
*---------------------------*
Local oNo 			:= LoadBitmap( GetResources(), "LBNO" )
Local oOk 			:= LoadBitmap( GetResources(), "LBTIK" )
Local oWizard
Local oChkTWiz
Local oChkIWiz
Local oLbxWiz 
Local oFiltro, oClienteA, oClienteD 

Local nPanel

Local aFiltro		:= {}

Local lChkTWiz 		:= .F.
Local lChkIWiz 		:= .F.

Private cFiltro		:= ""
Private cClienteD	:= Space(6) 
Private cClienteA	:= Space(6)

//Verifica se está na empresa Bioderma
If !(cEmpAnt) $ "L5"
	MsgInfo("Rotina não implamentada para empresa!","HLB BRASIL")
	Return .F.
EndIf

//Opções para selecionar o filtro do oLstBx
aFiltro		:= {"Não Enviados","Todos","Enviados"}

//PAINEL 1
DEFINE WIZARD oWizard TITLE "Wizard" HEADER Alltrim(SM0->M0_NOMECOM) MESSAGE " ";		
TEXT "Rotina desenvolvida para envio ao FTP os Pedidos de Vendas" PANEL;
NEXT {|| .T.} FINISH {|| .T.}

//PANEL 2 
//Cria um novo passo (janela) para o wizard

CREATE PANEL oWizard HEADER Alltrim(SM0->M0_NOMECOM) MESSAGE " " PANEL; 
BACK {|| oWizard:nPanel := 2, .T.} NEXT {|| .T.} FINISH {|| (GeraConsulta(),.T.)} EXEC {|| .T.}	

@ 010, 010 TO 125,280 OF oWizard:oMPanel[2] PIXEL
@ 20, 15 SAY oSay1 VAR "Parâmetros:" OF oWizard:oMPanel[2] PIXEL
@ 40, 20 SAY oSay2 VAR "Tipo: " OF oWizard:oMPanel[2] PIXEL
@ 40, 55 MSCOMBOBOX oFiltro VAR cFiltro ITEMS aFiltro OF oWizard:oMPanel[2] SIZE 50,009 PIXEL
@ 70, 20 SAY oSay3 VAR "Cliente de: " OF oWizard:oMPanel[2] PIXEL
@ 70, 55 MSGET oClienteD VAR cClienteD F3 "SA1" OF oWizard:oMPanel[2] SIZE 60,009 PIXEL
@ 100, 20 SAY oSay4 VAR "Cliente Até: " OF oWizard:oMPanel[2] PIXEL
@ 100, 55 MSGET oClienteA VAR cClienteA F3 "SA1" OF oWizard:oMPanel[2] SIZE 60,009 PIXEL

oWizard:oDlg:lEscClose := .F.

ACTIVATE WIZARD oWizard CENTERED VALID {|| .T. }

Return .F.

/*
Funcao      : GeraConsulta()
Parametros  : Nenhum
Retorno     : .F.
Objetivos   : Função para gerar os pedidos que foram e serão enviadas ao FTP
Autor       : Renato Rezende
Data/Hora   : 22/09/2014
*/
*-------------------------------------*
 Static Function GeraConsulta()
*-------------------------------------*
Local aStruSC5 		:= {}
Local aCpos    		:= {}
Local aButtons 		:= {} 
Local aColors  		:= {}
Local aSizFrm 		:= {}
Local aSr			:= ""

Local lInverte		:= .F.

Local cQuery		:= ""

Private lRetMain	:= .F.
Private cMarca 		:= GetMark()

If Select("TempSC5") > 0
	TempSC5->(DbCloseArea())	               
EndIf  

aadd(aColors,{"Alltrim(TempSC5->C5_P_ID)<>''","BR_VERMELHO"}) 
aadd(aColors,{"Alltrim(TempSC5->C5_P_ID)==''","BR_VERDE"}) 

Aadd(aCpos, {"cFTP"			,"",					,})
Aadd(aCpos, {"cStatus"  	,"","Status"			,}) 
Aadd(aCpos, {"C5_NUM"		,"","Pedido"			,}) 
Aadd(aCpos, {"C5_P_ID"		,"","Id Envio"			,}) 
Aadd(aCpos, {"C5_TIPO"		,"","Tipo Ped."			,})
Aadd(aCpos, {"C5_CLIENTE"	,"","Cliente/Fornec."	,})
Aadd(aCpos, {"C5_LOJACLI"	,"","Loja Cli."			,})
Aadd(aCpos, {"C5_EMISSAO"	,"","Dt. Emissão"		,})

Aadd(aStruSC5, {"C5_FILIAL"   ,"C", 2,0})
Aadd(aStruSC5, {"cFTP"  	  ,"C", 2,0})
Aadd(aStruSC5, {"cStatus"     ,"C",14,0})
Aadd(aStruSC5, {"C5_NUM"      ,"C", 6,0})
Aadd(aStruSC5, {"C5_EMISSAO"  ,"C", 8,0})
Aadd(aStruSC5, {"C5_P_ID"     ,"C", 9,0})
Aadd(aStruSC5, {"C5_CLIENTE"  ,"C", 6,0})
Aadd(aStruSC5, {"C5_LOJACLI"  ,"C", 2,0})
Aadd(aStruSC5, {"C5_TIPO"	  ,"C", 1,0})
   
cNome := CriaTrab(aStruSC5, .T.)                   
DbUseArea(.T.,"DBFCDX",cNome,'TempSC5',.F.,.F.)       
 	
If Select("C5QRY") > 0
	C5QRY->(DbCloseArea())	               
EndIf

//Verificando os Documentos diponíveis para envio ao FTP.    
cQuery:=" SELECT * FROM "+RetSqlName("SC5")
cQuery+="  WHERE D_E_L_E_T_ <> '*' "
//Filtro de Status
If Alltrim(cFiltro)=="Não Enviados"
	cQuery+="	 AND (C5_P_ID = '') "
ElseIf Alltrim(cFiltro)=="Enviados"
	cQuery+="	 AND (C5_P_ID <> '') "
Else
	cQuery+="	 AND (C5_P_ID = '' OR C5_P_ID <> '') "
EndIf
//Filtro de Pedido
If !Empty(Alltrim(cClienteD)) .OR. !Empty(Alltrim(cClienteA))
	cQuery +="	AND (C5_CLIENTE BETWEEN '"+Alltrim(cClienteD)+"' AND '"+Alltrim(cClienteA)+"') " 
EndIf
cQuery+=" ORDER BY C5_EMISSAO+C5_NUM DESC "

TCQuery cQuery ALIAS "C5QRY" NEW

C5QRY->(DbGoTop())
If !(C5QRY->(!BOF() .and. !EOF()))
	MsgStop("Não existe OR para envio!","HLB BRASIL")
	Return .F.
EndIf

C5QRY->(DbGoTop())
While C5QRY->(!EOF())
	RecLock("TempSC5",.T.)
	TempSC5->C5_FILIAL  := C5QRY->C5_FILIAL
	If Alltrim(C5QRY->C5_P_ID)==""
		TempSC5->cStatus:="Não Enviado"
	Else
		TempSC5->cStatus:="Enviado"
	EndIf	
	TempSC5->C5_NUM  	:= C5QRY->C5_NUM
	TempSC5->C5_TIPO	:= C5QRY->C5_TIPO
	TempSC5->C5_EMISSAO	:= C5QRY->C5_EMISSAO
	TempSC5->C5_CLIENTE	:= C5QRY->C5_CLIENTE   
	TempSC5->C5_LOJACLI	:= C5QRY->C5_LOJACLI
	TempSC5->C5_P_ID	:= C5QRY->C5_P_ID
	TempSC5->(MsUnlock())
	C5QRY->(DbSkip())
EndDo

aAdd(aButtons,{"Marcar", {|| MarcaTds("TempSC5")},"Marca/Desmarca Todos ","Marca/Desmarca Todos",{|| .T.}})

// Faz o calculo automatico de dimensoes de objetos  
aSizFrm := MsAdvSize()

TempSC5->(DbGoTop())
DEFINE MSDIALOG oDlg TITLE "Envio de OE ao FTP" From aSizFrm[7],0 To aSizFrm[6],aSizFrm[5] of oMainWnd PIXEL
	@ 010, 006 TO 035,(aSizFrm[5]/2)-5 LABEL "" OF oDlg PIXEL
	@ 020, 015 Say  "SELECIONE APENAS AS ORDENS DE EXPEDIÇÕES QUE SERÃO ENVIADOS AO FTP." COLOR CLR_HBLUE,CLR_WHITE PIXEL SIZE 500,6 OF oDlg

	oMarkPrd:= MsSelect():New("TempSC5","cFTP",,aCpos,@lInverte,@cMarca,{40,6,(aSizFrm[6]/2)-15,(aSizFrm[5]/2)-5},,,,,aColors)
	oMarkPrd:bMark:= {|| Disp()}  

ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,	{||	Processa({|| If(GeraTxt(),oDlg:End(),.F.)})},;     	   
													{|| oDlg:End()},,aButtons),oMarkPrd:oBrowse:Refresh()) CENTERED   

Return .F.
/*
Funcao      : GeraTxt
Parametros  : Nenhum
Retorno     : .T.
Objetivos   : Gera o TXT da OE e Cliente
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
Private cDirFtp1 	:= GETMV("MV_P_00020",,"/") //Diretorio no FTP para upload de arquivos txt

Private cDirOE		:= "\FTP\L5\OE\" 
Private cDirCli		:= "\FTP\L5\CLI\"

ProcRegua(nRecCount)

TempSC5->(DbGoTop())
While TempSC5->(!EOF())
	//Start Regua de Processamento
	IncProc("Processando...") 
	//Checa se marcou pelo menos um item.
	If !Empty(Alltrim(TempSC5->cFTP))
		lMarcado:=.T.
		nRecCount++
	EndIf
	TempSC5->(DbSkip()) 
EndDo

If !lMarcado
	MsgStop("Não foi selecionado nenhuma OR!","HLB BRASIL")
	TempSC5->(DbGoTop()) 
	Return .F.
Else
	//Ajusta a Pasta de Origem no Servidor - Temporaria
	If ExistDir("\FTP")
		If !ExistDir("\FTP\"+cEmpAnt)
			MakeDir("\FTP\"+cEmpAnt)
			MakeDir("\FTP\"+cEmpAnt+"\OE\")
			MakeDir("\FTP\"+cEmpAnt+"\CLI\")
		EndIf
	Else
		MakeDir("\FTP")
		MakeDir("\FTP\"+cEmpAnt)
		MakeDir("\FTP\"+cEmpAnt+"\OE\")
		MakeDir("\FTP\"+cEmpAnt+"\CLI\")
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

	//Chamando a Função para Gerar o Arquivo Txt do Cliente/Forn
	TxtCli()
	//Chamando a Função para Gerar o Arquivo Txt da OR
	//TxtOr()
	SendMail()
	
	//Upload
	//oProcess := MsNewProcess():New({|| UP2FTP(@oProcess) },"Upload","Processando...",.F.)
	//oProcess:Activate()

	//Encerra conexão com FTP
	FTPDisconnect()	
EndIf

Return .T.

/*
Funcao      : TxtOe
Parametros  : Nenhum
Retorno     : .T.
Objetivos   : Gera TXT com as Oe
Autor     	: Renato Rezende
Data     	: 02/10/2014
*/
*---------------------------------*
 Static Function TxtOe()
*---------------------------------*
Local cMsg			:= ""
Local cSeek			:= "" 
Local cChave		:= ""
Local cTxtOE		:= ""
Local cCtrlEstoque	:= ""
Local cConteudo		:= ""

Local nHdl			:= 0
Local nItem			:= 0

TempSC5->(DbGoTop())
While TempSC5->(!EOF())
    //Valida se está marcado o produto
	If !Empty(Alltrim(TempSC5->cFTP))
		
		//Criando 1 arquivo por documento no FTP
		cTxtOE := "FDOC_"+DTOS(dDataBase)+"_PED_"+Alltrim(TempSC5->C5_NUM)+".txt"
		nHdl:= fCreate(cDirOE+cTxtOE)
		If nHdl == -1 // Testa se o arquivo foi gerado 
			cMsg:="O arquivo "+cTxtOE+" nao pode ser executado." 
			MsgAlert(cMsg,"Atenção")
			Return .F.  
		EndIf
		//Guardando as NF para enviar no corpo do email
		cNota+= "PEDIDO: "+TempSC5->C5_NUM+"<br />"
		//Header - Ordem de Recebimento
		DbSelectArea("SC5")
		SC5->(DbSetOrder(1))
		If SC5->(DbSeek(xFilial("SC5")+TempSC5->C5_NUM))
			//Header Ordem de Expedição
			cConteudo:= "ERP"+Space(7)								//Código do Sistema de Origem. Fixo
			cConteudo+= "FDOC"										//Nome do Arquivo. Fixo
			cConteudo+= "FDOC00"+Space(2)							//Nome da Interface. Fixo
			cConteudo+= "00"										//Tipo de Registro. Fixo
			cConteudo+= Space(6)									
			cConteudo+= Space(16)
			cConteudo+= Space(6)
			cConteudo+= Space(16)
			cConteudo+= "2"+Space(2)								//Armazém (Site). VERIFICAR			
			cConteudo+= "PEDIDO"									//Tipo do Documento
			cConteudo+= PADR(Alltrim(SC5->C5_NUM),30)				//Id do Documento
			cConteudo+= Space(6)									//Modelo do Documento.
			cConteudo+= Space(3)									//Serie do Documento.
			cConteudo+= Space(2)									//Subserie
			cConteudo+= PADR(Alltrim(SC5->C5_NUM),30)				//Pedido
			cConteudo+= Space(44)									//Chave NF-e
			cConteudo+= "S"									   		//Doc. Saída
			cConteudo+= STRTRAN(DtoC(SC5->C5_EMISSAO),"/")  		//Data de Recebimento
			cConteudo+= STRTRAN(DtoC(SC5->C5_EMISSAO),"/")			//Data de Emissao
			
			//Verificando se é cliente ou fornecedor
			If SC5->C5_TIPO $ "B"
		        //Posicionando no Emitente
		    	DbSelectArea("SA2")
		    	SA2->(DbSetOrder(1))
		    	SA2->(DbSeek(xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA))
		    		cConteudo+= PADR(Alltrim(SA2->A2_CGC),16)		//CNPJ Emitente
		    	SA2->(DbCloseArea())
		 	//Cliente
	  		Else
		        //Posicionando no Emitente
		    	DbSelectArea("SA1")
		    	SA1->(DbSetOrder(1))
		    	SA1->(DbSeek(xFilial("SA1")+SF1->F1_FORNECE+SF1->F1_LOJA))
		    		cConteudo+= PADR(Alltrim(SA1->A1_CGC),16)		//CNPJ Emitente
		    	SA1->(DbCloseArea())	  		
	  		EndIf
	    	//Verificando quantos itens possuem a nota
	    	cChave := TempSC5->F1_FILIAL+TempSC5->F1_DOC+TempSC5->F1_SERIE+TempSC5->F1_FORNECE+TempSC5->F1_LOJA 
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
		If SD1->(DbSeek(xFilial("SD1")+TempSC5->F1_DOC+TempSC5->F1_SERIE+TempSC5->F1_FORNECE+TempSC5->F1_LOJA))
			While SD1->(!EOF()) .AND. TempSC5->F1_DOC+TempSC5->F1_SERIE+TempSC5->F1_FORNECE+TempSC5->F1_LOJA==SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
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
				If cSeek <> TempSC5->C5_FILIAL+TempSC5->C5_NUM
					ChkFile("ZX1")
					ZX1->(DbSetOrder(1))
					If !ZX1->(DbSeek(xFilial("ZX1")+TempSC5->C5_NUM+"CF"))
						RecLock("ZX1", .T.)//Inclusão
							ZX1->ZX1_FILIAL	:= xFilial("ZX1")	
							ZX1->ZX1_NUM	:= TempSC5->C5_NUM
							ZX1->ZX1_CLIENT	:= TempSC5->C5_CLIENTE
							ZX1->ZX1_LOJACL	:= TempSC5->C5_LOJACLI
							ZX1->ZX1_TIPO	:= "OE"
							ZX1->ZX1_USER	:= cUserName
							ZX1->ZX1_DATA	:= Date()
							ZX1->ZX1_HORA	:= Time()
							ZX1->ZX1_ARQN	:= cTxtCli
							ZX1->ZX1_ID		:= GetSxeNum("ZX1","ZX1->ZX1_ID") 
						ZX1->(MsUnlock())
						//Gravando o Registro utilizado no SXE e SXF pelo GetSxeNum.
						ConfirmSX8()
						//Gravando o ID de vínculo com a Tabela ZX1 na SC5
						DbSelectArea("SC5")
						SC5->(DbSetOrder(1))
						If SC5->(DbSeek(xFilial("SC5")+TempSC5->C5_NUM))
							RecLock("SC5",.F.)
								SC5->C5_P_ID := ZX1->ZX1_ID
							SC5->(MsUnlock())	
						EndIf
						cSeek:=TempSC5->C5_FILIAL+TempSC5->C5_NUM
						//Gravando conteúdo que será mostrado no corpo do email
						AADD(aArq,{cDirCli+"ENV\",Alltrim(cTxtCli)})
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
	TempSC5->(DbSkip())
EndDo

Return .T.

/*
Funcao      : TxtCli
Parametros  : Nenhum
Retorno     : .T.
Objetivos   : Gera TXT com Cliente da OE
Autor     	: Renato Rezende
Data     	: 01/10/2014
*/
*---------------------------------*
 Static Function TxtCli()
*---------------------------------*
Local cMsg			:= ""
Local cSeek			:= ""
Local cTxtCli		:= ""
Local cConteudo		:= ""

Local nHdl			:= 0

TempSC5->(DbGoTop())
While TempSC5->(!EOF())
    //Valida se está marcado o pedido
	If !Empty(Alltrim(TempSC5->cFTP))
		//Verificando se é Cliente ou Fornecedor
		If TempSC5->C5_TIPO == "B"
			cTxtCli := "CCLI_"+DTOS(dDataBase)+"_PED_"+Alltrim(TempSC5->C5_NUM)+".txt"
		Else
			cTxtCli := "CFOR_"+DTOS(dDataBase)+"_PED_"+Alltrim(TempSC5->C5_NUM)+".txt"
		EndIf
		nHdl:= fCreate(cDirCli+cTxtCli)
		If nHdl == -1 //Testa se o arquivo foi gerado 
			cMsg:="O arquivo "+cTxtCli+" nao pode ser executado." 
			MsgAlert(cMsg,"Atenção")  
			Return .F.  
		EndIf
		//Gravando Cliente
		If TempSC5->C5_TIPO <> "B"
			SA1->(DbSetOrder(1))
			If SA1->(DbSeek(xFilial("SA1")+TempSC5->C5_CLIENTE+TempSC5->C5_LOJACLI))
				//Header Cliente
				cConteudo:= "ERP"+Space(7)								//Código do Sistema de Origem. Fixo
				cConteudo+= "CCLI"										//Nome do Arquivo. Fixo
				cConteudo+= "CCLIH"+Space(3)							//Nome da Interface. Fixo
				cConteudo+= "10"+Space(10)			
				cConteudo+= PADR(Alltrim(SA1->A1_COD),12)				//Código Cliente
				cConteudo+= PADR(Alltrim(SA1->A1_CGC),16)				//CNPJ
				cConteudo+= PADR(Alltrim(SA1->A1_NOME),80)				//Razão Social
				cConteudo+= PADR(Alltrim(SA1->A1_NOME),60)          	//Nome Fantasia
				cConteudo+= IIF(Alltrim(SA1->A1_PESSOA)=="F","2","1")	//Tipo da Pessoa
				cConteudo+= PADR(Alltrim(SA1->A1_INSCR),16)          	//Incricao Estadual
				cConteudo+= Chr(13)+Chr(10)
				//Endereco
				cConteudo+= "ERP"+Space(7)								//Código do Sistema de Origem. Fixo
				cConteudo+= "CCLI"										//Nome do Arquivo. Fixo
				cConteudo+= "CCLIB"+Space(3)							//Nome da Interface. Fixo
				cConteudo+= "10"+Space(10)
				cConteudo+= PADR(Alltrim(SA1->A1_CGC),16)				//CNPJ
				cConteudo+= "1"										   	//Tipo de Endereço 1- comercial
				cConteudo+= PADR(Alltrim(SA1->A1_CEP),9)				//CEP
				cConteudo+= PADR(Alltrim(Substr(Alltrim(SA1->A1_END),At(",",Alltrim(SA1->A1_END))+1)),10)//Número
				cConteudo+= PADR(Alltrim(SA1->A1_COMPLEM),40)			//Complemento do Endereço
				cConteudo+= Chr(13)+Chr(10)
				//Contatos
				cConteudo+= "ERP"+Space(7)								//Código do Sistema de Origem. Fixo
				cConteudo+= "CCLI"										//Nome do Arquivo. Fixo
				cConteudo+= "CCLIC"+Space(3)							//Nome da Interface. Fixo
				cConteudo+= "10"+Space(10)
				cConteudo+= PADR(Alltrim(SA1->A1_CGC),16)				//CNPJ
				cConteudo+= PADR(Alltrim("CADASTRO"),50)				//Tipo de Contato
				cConteudo+= PADR(Alltrim(SA1->A1_CONTATO),80) 			//Contato
				cConteudo+= PADR(Alltrim(SA1->A1_TEL),15)				//Telefone
				cConteudo+= Space(15)									//Telefone
				cConteudo+= PADR(Alltrim(SA1->A1_EMAIL),60)				//Email
				cConteudo+= Space(60)									//Email
				cConteudo+= PADR(Alltrim(SA1->A1_FAX),15)				//Fax
				cConteudo+= Chr(13)+Chr(10)
				 				
				fWrite(nHdl,cConteudo)
			
			EndIf
		EndIf
		//Gravando dados na tabela de controle de arquivos enviados ao FTP da Luft
		If cSeek <> TempSC5->C5_FILIAL+TempSC5->C5_NUM
			ChkFile("ZX1")
			ZX1->(DbSetOrder(1))
			If !ZX1->(DbSeek(xFilial("ZX1")+TempSC5->C5_NUM+"CF"))
				RecLock("ZX1", .T.)//Inclusão
					ZX1->ZX1_FILIAL	:= xFilial("ZX1")	
					ZX1->ZX1_NUM	:= TempSC5->C5_NUM
					ZX1->ZX1_CLIENT	:= TempSC5->C5_CLIENTE
					ZX1->ZX1_LOJACL	:= TempSC5->C5_LOJACLI
					ZX1->ZX1_TIPO	:= "CF"
					ZX1->ZX1_USER	:= cUserName
					ZX1->ZX1_DATA	:= Date()
					ZX1->ZX1_HORA	:= Time()
					ZX1->ZX1_ARQN	:= cTxtCli
					ZX1->ZX1_ID		:= GetSxeNum("ZX1","ZX1->ZX1_ID") 
				ZX1->(MsUnlock())
				//Gravando o Registro utilizado no SXE e SXF pelo GetSxeNum.
				ConfirmSX8()
				//Gravando o ID de vínculo com a Tabela ZX1 na SC5
				DbSelectArea("SC5")
				SC5->(DbSetOrder(1))
				If SC5->(DbSeek(xFilial("SC5")+TempSC5->C5_NUM))
					RecLock("SC5",.F.)
						SC5->C5_P_ID := ZX1->ZX1_ID
					SC5->(MsUnlock())	
				EndIf
				cSeek:=TempSC5->C5_FILIAL+TempSC5->C5_NUM
				//Gravando conteúdo que será mostrado no corpo do email
				AADD(aArq,{cDirCli+"ENV\",Alltrim(cTxtCli)})
			EndIf	
		EndIf
		fClose(nHdl)
	EndIf
	TempSC5->(DbSkip())
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
	If Alltrim(TempSC5->cStatus) == "Não Enviado"
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
RecLock("TempSC5",.F.)
If Alltrim(TempSC5->cStatus) == "Não Enviado"
	If Marked("cFTP")        
       TempSC5->cFTP := cMarca
	Else        
       TempSC5->cFTP := ""
	Endif
Else
	TempSC5->cFTP := ""            
Endif  
TempSC5->(MsUnlock())

Return

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

If EMPTY(cEmail)
	Return .T.
EndIf

oEmail          := DEmail():New()
oEmail:cFrom   	:= "totvs@hlb.com.br"
oEmail:cTo		:= PADR(cEmail,200)
oEmail:cSubject	:= padr("Notificacao do txt de OR e Prod no FTP.",200)
oEmail:cBody   	:= cMsg
oEmail:Envia()

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

aArqs := Directory(cDirCli+"*.txt")
For i:=1 to Len(aArqs)
	FTPUpLoad(cDirCli+alltrim(aArqs[i][1]),alltrim(aArqs[i][1]))
	//Copiando arquivo para a pasta de enviados
	__CopyFile(cDirCli+alltrim(aArqs[i][1]),cDirCli+"ENV\"+alltrim(aArqs[i][1]))
	//Excluindo arquivo da pasta principal
	FERASE(cDirCli+alltrim(aArqs[i][1]))
Next i               
oProcess:IncRegua1("Processando FTP:'"+ALLTRIM(cPath)+"' Aguarde...")

aArqs := Directory(cDirOE+"*.txt")
For i:=1 to Len(aArqs)
	FTPUpLoad(cDirOE+alltrim(aArqs[i][1]),alltrim(aArqs[i][1]))
	//Copiando arquivo para a pasta de enviados
	__CopyFile(cDirOE+alltrim(aArqs[i][1]),cDirOE+"ENV\"+alltrim(aArqs[i][1]))
	//Excluindo arquivo da pasta principal
	FERASE(cDirOE+alltrim(aArqs[i][1]))
Next i
oProcess:IncRegua1("Processando FTP:'"+ALLTRIM(cPath)+"' Aguarde...")

//Mandando email
SendMail()
oProcess:IncRegua1("Processando FTP:'"+ALLTRIM(cPath)+"' Aguarde...")

Return .T.