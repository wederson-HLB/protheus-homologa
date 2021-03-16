#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
/*
Funcao      : JOFAT001
Cliente     : Monster
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Integração de Orçamento
Autor       : Jean Victor Rocha
Data/Hora   : 23/07/2016
Revisao     :
Obs.        : 
*/  
*----------------------*
User Function JOFAT001()          
*----------------------*
Private cDirArq := Space(200)
Private cNameArq := Space(200)
Private cEmailCC := GETMV("MV_P_00080",,Space(100))
Private nConverUM:= GETMV("MV_P_00083",,1)
Private cEmailCli := ""
Private lNotificado := .F.  
Private nHabEmail := 2

Private aGrvOrc := {}
Private aErroOrc := {}

InWizardMan()

Return .T.                          
                                                
/*
Funcao      : InWizardMan()  
Parametros  : 
Retorno     : 
Objetivos   : Wizard para integração
Autor       : Jean Victor Rocha
Data/Hora   : 23/07/2016
*/
*---------------------------*
Static Function InWizardMan()
*---------------------------*
Local lWizMan := .F.

Private oWizMan
Private nOpc := GD_DELETE+GD_UPDATE//+GD_INSERT
Private aCoBrw1 := {}
Private aCoBrw2 := {}
Private aHoBrw2 := {}
Private noBrw2  := 0

oWizMan := APWizard():New("Integração de Orçamentos", ""/*<chMsg>*/, FWEmpName(cEmpAnt)+" / "+FWFilialName(),;
									"Rotina de Integração de orçamentos."+CRLF,;
									 {||  .T.}/*<bNext>*/, {|| .T.}/*<bFinish>*/, /*<.lPanel.>*/,,,/*<.lNoFirst.>*/ )
          
//Painel 2
oWizMan:NewPanel( "Parametros", "Parametros para Integração.",{ ||.T.}/*<bBack>*/,;
					 {|| (VldParam(@oBrw2,@oWizMan),LoadDados(@oBrw2,@oWizMan),VldOrc(@oBrw2,@oWizMan),.T.)}/*<bNext>*/,;
					 {|| .T.}/*<bFinish>*/, /*<.lPanel.>*/, {|| .T.}/*<bExecute>*/ )

@ 010, 010 TO 125,280 OF oWizMan:oMPanel[2] PIXEL
oSBox1 := TScrollBox():New( oWizMan:oMPanel[2],009,009,124,279,.T.,.T.,.T. )

@ 21,20 SAY oSay2 VAR "Arquivo ? " SIZE 100,10 OF oSBox1 PIXEL
ocDirArq:= TGet():New(20,85,{|u| If(PCount()>0,cDirArq:=u,cDirArq)},oSBox1,43,05,'',{|o|},,,,,,.T.,,,,,,,,,"",'cDirArq')
@ 20,127.5 Button "..."	Size 7,10 Pixel of oSBox1 action (GetDir())

@ 41,20 SAY oSay3 VAR "Email CC ? " SIZE 100,10 OF oSBox1 PIXEL
ocDirArq:= TGet():New(40,85,{|u| If(PCount()>0,cEmailCC:=u,cEmailCC)},oSBox1,150,05,'',{|o|},,,,,,.T.,,,,,,,,,"",'cEmailCC')

If FwIsAdmin()
	@ 61,20 SAY oSay3 VAR "Conversão Unid. Med.? " SIZE 100,10 OF oSBox1 PIXEL
	oConvert:= TGet():New(60,85,{|u| If(PCount()>0,nConverUM:=u,nConverUM)},oSBox1,150,05,'',{|o|},,,,,,.T.,,,,,,,,,"",'nConverUM')

	aItens		:= {"Sim","Não"}
	nHabEmail	:= 1
	@ 81,20 SAY oSay4 VAR "Habilita Email ? " SIZE 100,10 OF oSBox1 PIXEL
	oCbx:= TRadMenu():New( 091,020,aItens,,oSBox1,,,CLR_BLACK,CLR_WHITE,"",,,140,32,,.F.,.F.,.T. )
	oCbx:bSetGet := {|u| If(PCount()==0,nHabEmail,nHabEmail:=u)}
EndIf

//--> PANEL 3
oWizMan:NewPanel( "Analise de dados", "Apresentação dos dados do arquivo junto aos valores unitarios."+CRLF+;
										"Caso o valor esteja zero, não foi encontrada tabela de preço para o item e deve"+CRLF+;
										"ser informado manualmente.",;
								{ ||.F.}/*<bBack>*/,{|| Finaliza()}/*<bNext>*/, {|| .T.}/*<bFinish>*/, /*<.lPanel.>*/, /*<bExecute>*/ )

//Aadd(aHoBrw1je,{Trim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"ALLWAYSTRUE()",SX3->X3_USADO, SX3->X3_TIPO,SX3->X3_F3, SX3->X3_CONTEXT,SX3->X3_CBOX } )
Aadd(aHoBrw2,{"Dt. Pedido" 			,"DTPEDIDO"		,"@D"						,08,00,""	,"","D",""	,""})
Aadd(aHoBrw2,{"Pedido Cli."			,"PEDIDOCLI" 	,"@!"	   					,06,00,""	,"","C",""	,""})
Aadd(aHoBrw2,{"Item Cli."  			,"ITEMCLI"		,"@!"						,02,00,""	,"","C",""	,""})
Aadd(aHoBrw2,{"C¢digo" 				,"PRODUTO" 		,"@!"						,15,00,""	,"","C",""	,""})
Aadd(aHoBrw2,{"Qtde em PT" 			,"QTDE"			,"@E 99999999" 				,08,00,""	,"","N",""	,""})
Aadd(aHoBrw2,{"Descrição"			,"DESCRICAO"	,"@X"	   					,30,00,""	,"","C",""	,""})
Aadd(aHoBrw2,{"CNPJ"				,"CNPJ"	   		,"@R 99.999.999/9999-99"	,14,00,""	,"","C",""	,""})
Aadd(aHoBrw2,{"Dt. Carregamento"	,"DTCARGA"		,"@D"						,08,00,""	,"","D",""	,""})
Aadd(aHoBrw2,{"Vlr Unitario"   		,"VLUNIT"		,"@E 99,999,999,999.9999"	,16,04,""	,"","N",""	,""})

noBrw2:= Len(aHoBrw2)
aAlter2 := {"VLUNIT"}
                                                                                                 
oGrp2 := TGroup():New( 004,004,134,296,"Dados para integração",oWizMan:oMPanel[3],,,.T.,.F. )
oBrw2 := MsNewGetDados():New(012,008,130,292,nOpc,'AllwaysTrue()','AllwaysTrue()','',aAlter2,0,9999,'AllwaysTrue()','','AllwaysTrue()',oGrp2,aHoBrw2,aCoBrw2 )

//--> PANEL 4
oWizMan:NewPanel( "Processamento finalizado", "",;
								{ ||.F.}/*<bBack>*/,{|| }/*<bNext>*/, {|| .T.}/*<bFinish>*/, /*<.lPanel.>*/,{|| Main() } /*<bExecute>*/ )

@ 21,20 SAY oSayTxt1 VAR ""  SIZE 300,10 OF oWizMan:oMPanel[4] PIXEL
@ 31,20 SAY oSayTxt2 VAR ""  SIZE 300,10 OF oWizMan:oMPanel[4] PIXEL
@ 41,20 SAY oSayTxt3 VAR ""  SIZE 300,10 OF oWizMan:oMPanel[4] PIXEL
           
nMeter2 := 0
oMeter2 := TMeter():New(51,20,{|u|if(Pcount()>0,nMeter2:=u,nMeter2)},0,oWizMan:oMPanel[4],250,34,,.T.,,,,,,,,,)
oMeter2:Set(0)

oBtn1 := TButton():New( 81,200,"Visualizar Log",oWizMan:oMPanel[4],{|| ViewLog()},80,10,,,,.T.,,"",,,,.F. )

oWizMan:Activate( .T./*<.lCenter.>*/,/*<bValid>*/, /*<bInit>*/, /*<bWhen>*/ )
                                          
Return .T.  

/*
Funcao      : GetDir
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Busca de diretorio.
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*----------------------*
Static Function GetDir()
*----------------------*
Local aNameFile := {}
Local cTitle:= "Selecione o arquivo"
Local cFile := "Arquivos| *.csv|"
Local nDefaultMask := 0
Local cDefaultDir  := cDirArq
Local nOptions:= GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE

cDirArq := cGetFile(cFile,cTitle,nDefaultMask,cDefaultDir,.T.,nOptions,.F.)+Space(200)

aNameFile := separa(UPPER(cDirArq),"\")
cNameArq := aNameFile[Len(aNameFile)]

Return 

/*
Funcao     : VldParam
Parametros : Nenhum
Retorno    : 
Objetivos  : Valida os parametros digitados em tela
Autor      : Jean Victor Rocha
Data/Hora  : 
*/
*------------------------*
Static Function VldParam()
*------------------------*

If UPPER(ALLTRIM(cEmailCC)) <> UPPER(ALLTRIM(GETMV("MV_P_00080",,Space(100))))
	If MsgYesNo("Dados do email alterado, deseja continuar e gravar o novo conteudo?","HLB BRASIL")
		lSeek := !SX6->(DbSeek(xFilial("SX6") + "MV_P_00080"))
		SX6->(RecLock("SX6", lSeek))
		SX6->X6_VAR		:= "MV_P_00080"
		SX6->X6_TIPO	:= "C"
		SX6->X6_DESCRIC := "Email para notificações Monster."		
		SX6->X6_CONTEUD := ALLTRIM(cEmailCC)
		SX6->X6_CONTSPA := ALLTRIM(cEmailCC)
		SX6->X6_CONTENG := ALLTRIM(cEmailCC)
		SX6->(MSUNLOCK())
	Else
		Return .F.
	EndIf
EndIf

If nConverUM <> GETMV("MV_P_00083",,1)
	If MsgYesNo("Valor de conversão de unidade de Medida alterado, deseja continuar e gravar o novo conteudo no parametro?","HLB BRASIL")
		lSeek := !SX6->(DbSeek(xFilial("SX6") + "MV_P_00083"))
		SX6->(RecLock("SX6", lSeek))
		SX6->X6_VAR		:= "MV_P_00083"
		SX6->X6_TIPO	:= "N"
		SX6->X6_DESCRIC := "Taxa de conversão UM Monster"		
		SX6->X6_CONTEUD := ALLTRIM(STR(nConverUM))
		SX6->X6_CONTSPA := ALLTRIM(STR(nConverUM))
		SX6->X6_CONTENG := ALLTRIM(STR(nConverUM))
		SX6->(MSUNLOCK())
	Else
		Return .F.
	EndIf
EndIf

Return .T.
 
/*
Funcao     : LoadaCols
Parametros : Nenhum
Retorno    : 
Objetivos  : Carregar Informações
Autor      : Jean Victor Rocha
Data/Hora  : 
*/
*-------------------------*
Static Function LoadDados()        
*-------------------------*
Local nPos		:= 0
Local cLinha	:= ""
Local aLinha	:= {}

If !TcCanOpen(RetSQLName("SA1"))
	MsgInfo("Falha na Abertura da tabela de clientes 'SA1'!","HLB BRASIL")
	Return .T.
EndIf

If !File(cDirArq)
	MsgInfo("Falha na localização do arquivo!","HLB BRASIL")
	Return .T.	
EndIf

If FT_FUse(cDirArq) < 0 // Abre o arquivo
	MsgInfo("Falha na Abertura do arquivo!","HLB BRASIL")
	Return .T.	
EndIf

FT_FGOTO(nPos)    // Posiciona no inicio do arquivo
While !FT_FEof()
	cLinha := FT_FReadln()        // Le a linha
 	aLinha := separa(UPPER(cLinha),";")  // Separa para o array 
    If Len(aLinha) >= 8
		
		if !(empty(aLinha[1]) .and. empty(ALLTRIM(aLinha[2])))
			aAdd(aCoBrw1,{	aLinha[1],;//CJ_EMISSAO
							ALLTRIM(aLinha[2]),;//CJ_P_REF
							aLinha[3],;//CK_ITEM
							aLinha[4],;//CK_PRODUTO
					   		Val(aLinha[5])*nConverUM,;//CK_QTDVEN
							aLinha[6],;//CK_DESCRI
							ALLTRIM(STRTRAN(STRTRAN(STRTRAN(aLinha[7],".",""),"/",""),"-","")),;//CJ_CLIENTE
							aLinha[8],;//CK_ENTREG
							.F.})//DELET
		endif
	Else
		MsgInfo("Estrutura do arquivo invalida!","HLB BRASIL")
		aCoBrw1 := {}
		Exit
	EndIf
	FT_FSkip() // Proxima linha
Enddo
FT_FUse() // Fecha o arquivo       

If Len(aCoBrw1) == 0 .And. !lNotificado
	MsgInfo("Não foi encontrado dados para serem integrados, verifique o arquivo!","HLB BRASIL")
EndIf

Return .T.

/*
Função  : VldOrc
Objetivo: Validação da Integração
Autor   : Jean Victor Rocha
Data    : 
*/
*-----------------------------------*
Static Function VldOrc(oBrw2,oWizXXX)
*-----------------------------------*
Local i
Local aCli := {}
Local aProd := {}
Local lRet := .T.
Local aGrvOrcAux := {}
Local cMsgErro := ""
             
Local nPosEmissao	:= 1
Local nPosPedido	:= 2
Local nPosItem		:= 3
Local nPosProduto	:= 4
Local nPosQTD		:= 5
Local nPosDescr		:= 6
Local nPosCNPJCli	:= 7
Local nPosEntrega	:= 8

oWizXXX:OBACK:LVISIBLECONTROL		:= .F.
oWizXXX:OCANCEL:BACTION := {|| IIF(MSGYESNO("Deseja sair e perder as alterações?","HLB BRASIL") ,oWizXXX:ODLG:END(),) }	
                 
PROCREGUA( len(aCoBrw1) )    
    
For i:=1 to len(aCoBrw1)
	INCPROC(ALLTRIM(STR(i))+"\"+ALLTRIM(STR(len(aCoBrw1)))+" - Validando '"+aCoBrw1[i][1]+"'. Aguarde...")
	cMsgErro := ""
	cProduto := "" 
	aGrvOrcAux := {}
	cTabela := ""
	//Valida se todos os campos estao preenchidos
	For j:=1 to Len(aCoBrw1[i])-1//desconsireda o campo de Delete
		If EMPTY(aCoBrw1[i][j]) .AND. j<>nPosItem
			cMsgErro +=	"Registro["+ALLTRIM(STR(i))+"] - Possui campo["+ALLTRIM(STR(j))+"] com conteudo em branco."+CRLF
		EndIf
	Next j
	If orcDupl(aCoBrw1[i][nPosPedido],aCoBrw1[i][nPosCNPJCli])
   		cMsgErro +=	"Registro["+ALLTRIM(STR(i))+;
   					"] - Já existe orçamento com o numero do pedido informado para o cliente. '"+ALLTRIM(aCoBrw1[i][nPosCNPJCli])+"'"+CRLF
	EndIf                            
	aadd(aGrvOrcAux,{"CJ_EMISSAO"	,CTOD(aCoBrw1[i][nPosEmissao])})
	aadd(aGrvOrcAux,{"CJ_P_REF"		,aCoBrw1[i][nPosPedido]})
   	If !EMPTY(aCoBrw1[i][nPosCNPJCli])
		If Len(aCli := getCliente(aCoBrw1[i][nPosCNPJCli])) <> 0
			aadd(aGrvOrcAux,{"CJ_CLIENTE"	,aCli[1]})
			aadd(aGrvOrcAux,{"CJ_LOJA"		,aCli[2]})
			aadd(aGrvOrcAux,{"CJ_CLIENT"	,aCli[1]})
			aadd(aGrvOrcAux,{"CJ_LOJAENT"	,aCli[2]})
			aadd(aGrvOrcAux,{"CK_CLIENTE"	,aCli[2]})
			aadd(aGrvOrcAux,{"CK_LOJA"		,aCli[2]})
			cTabela := aCli[3]
		Else
			cMsgErro +=	"Registro["+ALLTRIM(STR(i))+"] - Não foi encontrado o cliente com o CNPJ '"+aCoBrw1[i][nPosCNPJCli]+"'."+CRLF			
		EndIf		
	EndIF                   
	If !EMPTY(aCoBrw1[i][nPosProduto])
		If Len(aProd := getProduto(aCoBrw1[i][nPosProduto])) <> 0
			cProduto := ALLTRIM(aProd[1])
			aadd(aGrvOrcAux,{"CK_PRODUTO"	,cProduto})
			aadd(aGrvOrcAux,{"CK_TES"		,aProd[2]})
		Else
			cMsgErro +=	"Registro["+ALLTRIM(STR(i))+"] - Não foi encontrado o produto para o codigo '"+aCoBrw1[i][nPosProduto]+"'."+CRLF			
		EndIf		
	EndIf
	//If EMPTY(cNumOrc := getNumOrc())
	//	cMsgErro +=	"Registro["+ALLTRIM(STR(i))+"] - Não foi possivel gerar o numero de orçamento."+CRLF			
	//EndIf
	//aadd(aGrvOrcAux,{"CJ_NUM"		,cNumOrc})//Orcamento sera preenchido na Gravação
	aadd(aGrvOrcAux,{"CJ_FILIAL"	,xFilial("SCJ")})
	//aadd(aGrvOrcAux,{"CJ_CONDPAG"	,"99999"})
	aadd(aGrvOrcAux,{"CJ_TIPLIB"	,"1"})
	aadd(aGrvOrcAux,{"CJ_TPCARGA"	,"2"})
	aadd(aGrvOrcAux,{"CJ_STATUS"	,"A"})
	aadd(aGrvOrcAux,{"CJ_MOEDA"		,1})
	aadd(aGrvOrcAux,{"CJ_TXMOEDA"	,1})
	aAdd(aGrvOrcAux,{"CJ_TABELA"	,cTabela})

	aadd(aGrvOrcAux,{"CK_P_ITEM"	,aCoBrw1[i][nPosItem]})
	aadd(aGrvOrcAux,{"CK_DESCRI"	,STRTRAN(LEFT(aCoBrw1[i][nPosDescr],30),"'","") })
	aadd(aGrvOrcAux,{"CK_QTDVEN"	,aCoBrw1[i][nPosQTD]})
	aadd(aGrvOrcAux,{"CK_ENTREG"	,CTOD(aCoBrw1[i][nPosEntrega]) })
	//aadd(aGrvOrcAux,{"CK_NUM"		,cNumOrc})//Orcamento sera preenchido na Gravação
	//aadd(aGrvOrcAux,{"CK_ITEM" 	,StrZero(i,2)})//Item sera preenchido na Gravação
	aadd(aGrvOrcAux,{"CK_FILIAL"	,xFilial("SCK")})
	aadd(aGrvOrcAux,{"CK_FILVEN"	,xFilial("SCK")})
	aadd(aGrvOrcAux,{"CK_FILENT"	,xFilial("SCK")})
	
	//Tabela de preço
	nValor := getTabela(cTabela,cProduto)
	aadd(aGrvOrcAux,{"CK_PRCVEN"	,nValor})
	aadd(aGrvOrcAux,{"CK_VALOR"		,nValor*aCoBrw1[i][nPosQTD]})   
    
    //Grava erro caso exista
	If !EMPTY(cMsgErro)
		aAdd(aErroOrc,{i,cMsgErro})
	EndIf
	//Grava dados editados no array que sera utilizado na gravação do orçamento.
	aAdd(aGrvOrc, aGrvOrcAux)

	//Adicão no array da tela de tratamento de valor.
	aAdd(aCoBrw2,{	aCoBrw1[i][nPosEmissao],;//CJ_EMISSAO
					aCoBrw1[i][nPosPedido],;//CJ_P_REF
					aCoBrw1[i][nPosItem],;//CK_ITEM
					aCoBrw1[i][nPosProduto],;//CK_PRODUTO
			   		aCoBrw1[i][nPosQTD],;//CK_QTDVEN
					aCoBrw1[i][nPosDescr],;//CK_DESCRI
					aCoBrw1[i][nPosCNPJCli],;//CJ_CLIENTE
					aCoBrw1[i][nPosEntrega],;//CK_ENTREG
					nValor,;
					.F.})//DELET
	
Next i

oBrw2:ACOLS := aCoBrw2

Return lRet

/*
Função  : getCliente
Objetivo: Busca os dados do cliente
Autor   : Jean Victor Rocha
Data    : 
*/
*-------------------------------*
Static Function getCliente(cCNPJ)
*-------------------------------*
Local aRet := {}

If Select("TMP") <> 0
	TMP->(DbCloseArea())
EndIf

cCNPJ := STRTRAN(cCNPJ,"/","")
cCNPJ := STRTRAN(cCNPJ,".","")
cCNPJ := STRTRAN(cCNPJ,"-","")

cQry := " Select A1_COD,A1_LOJA,A1_TABELA,A1_EMAIL
cQry += " From "+RetSQLName("SA1")
cQry += " Where D_E_L_E_T_ <> '*'
cQry += " 		AND A1_CGC like '%"+cCNPJ+"%'

dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQry), 'TMP', .F., .T.)
  
TMP->(DbGoTop())
If TMP->(!EOF())
	aAdd(aRet,TMP->A1_COD)
	aAdd(aRet,TMP->A1_LOJA)
	aAdd(aRet,TMP->A1_TABELA)
	cEmailCli := TMP->A1_EMAIL
EndIf

Return aRet

/*
Função  : getProduto
Objetivo: Busca os dados do produto
Autor   : Jean Victor Rocha
Data    : 
*/
*----------------------------------*
Static Function getProduto(cProduto)
*----------------------------------*
Local aRet := {}

If Select("TMP") <> 0
	TMP->(DbCloseArea())
EndIf

cQry := " Select B1_COD,B1_TS
cQry += " From "+RetSQLName("SB1")
cQry += " Where D_E_L_E_T_ <> '*'
cQry += " 		AND B1_COD = '"+cProduto+"'

dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQry), 'TMP', .F., .T.)
  
TMP->(DbGoTop())
If TMP->(!EOF())
	aAdd(aRet,TMP->B1_COD) 
	aAdd(aRet,TMP->B1_TS)
EndIf

Return aRet

/*
Função  : getNumOrc
Objetivo: Busca o numero do orçamento
Autor   : Jean Victor Rocha
Data    : 
*/
*-------------------------*
Static Function getNumOrc()
*-------------------------*
Local cRet := ""

cRet := GetSxeNum("SCJ","CJ_NUM")
ConfirmSX8()

Return cRet

/*
Função  : getTabela
Objetivo: Busca o valor da tabela de preço do produto
Autor   : Jean Victor Rocha
Data    : 
*/
*-----------------------------------------*
Static Function getTabela(cTabela,cProduto)
*-----------------------------------------*
Local nRet := 0
Local cQry := ""
   
If Select("TMP") <> 0
	TMP->(DbCloseArea())
EndIf

cQry := " Select DA1_PRCVEN 
cQry += " From "+RETSQLNAME("DA1")+CRLF
cQry += " Where D_E_L_E_T_ <> '*' AND DA1_FILIAL = '"+xFilial("DA1")+"' AND DA1_CODTAB='"+cTabela+"' AND DA1_CODPRO='"+cProduto+"'
        
dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQry), 'TMP', .F., .T.)
           
TMP->(DbGoTop())
If TMP->(!EOF())
	nRet := TMP->DA1_PRCVEN
EndIf

Return nRet

/*
Função  : vldFinaliza
Objetivo: Retorna se é possivel finalizar ou não.
Autor   : Jean Victor Rocha
Data    : 
*/
*------------------------*
Static Function Finaliza()
*------------------------*
Local lRet := .T.

For i:=1 to len(oBrw2:ACOLS)
	If oBrw2:ACOLS[i][9] <= 0//valor
		lRet := .F.
		MsgInfo("Existe item que não foi informado o valor, ajustar antes de continuar!","HLB BRASIL")
		Return lRet
	EndIf
Next i

Return lRet

/*
Funcao      : ViewLog()
Parametros  : cCampo
Retorno     : Nenhum
Objetivos   : Visualizador de Log de integração
Observações : Tratamento Migrado do IntPryor.
Autor       :
Data/Hora   :
*/
*-----------------------*
Static Function ViewLog()
*-----------------------*
Local cErro := ""

For i:=1 to Len(aErroOrc)
	cErro += aErroOrc[i][2]
Next i

EECVIEW(cErro)

Return .T.

/*
Funcao     : Main
Parametros : Nenhum
Retorno    :
Objetivos  : Rotina de Integração dos Itens.
Autor      : Jean Victor Rocha
Data/Hora  :
*/
*--------------------*
Static Function Main()
*--------------------*
Local i,j
Local acab := {}
Local aIte := {}
Local cMailErro := ""

oSayTxt1:CCAPTION 	:= "Processando, aguarde..."
oSayTxt2:CCAPTION 	:= ""
oSayTxt3:CCAPTION 	:= ""
oMeter2:LVISIBLE 	:= .F.
oBtn1:LVISIBLE		:= .F.

If Len(aErroOrc) <> 0
	oSayTxt1:CCAPTION	:= "Integração apresendou erro."
	oSayTxt2:CCAPTION	:= "Email de notificação enviado para o cliente."
	oBtn1:LVISIBLE		:= .T.
	For i:=1 to Len(aErroOrc)
		cMailErro += aErroOrc[i][2]+"<br>"
	Next i
	SendMail("ERRO",cMailErro)
	Return .T.
EndIf

//Atualização do preço de venda de acordo com o que foi digitado em tela.
For i:=1 to len(oBrw2:ACOLS)
	nNewVal := oBrw2:ACOLS[i][LEN(oBrw2:ACOLS[i])-1]
 
	nPosA := aScan(aGrvOrc[1],{|x| x[1] == "CK_QTDVEN"})
	nPosB := aScan(aGrvOrc[1],{|x| x[1] == "CK_PRCVEN"})
	nPosC := aScan(aGrvOrc[1],{|x| x[1] == "CK_VALOR"})

	If nNewVal <> aGrvOrc[i][nPosB][2]
		aGrvOrc[i][nPosB][2] := nNewVal
		aGrvOrc[i][nPosC][2] := nNewVal*aGrvOrc[i][nPosA][2]
	EndIf
Next i
                                          
//Ordena pelo numero do orçamento.
aSort(aGrvOrc, , , {|x,y|x[2][2] < y[2][2]})

If Len(aGrvOrc) > 0
	nPosCJ_P_REF := aScan(aGrvOrc[1],{|x| x[1] == "CJ_P_REF"})
EndIf

cNumOrcAux := ""

oMeter2:LVISIBLE 	:= .T.
oMeter2:NTOTAL := LEN(aGrvOrc)
For i:=1 to LEN(aGrvOrc)
	oMeter2:Set(i)
	oSayTxt1:CCAPTION := ALLTRIM(STR(i))+"/"+ALLTRIM(STR(Len(oBrw2:ACOLS)))+" Processando, aguarde..."
	
	If cNumOrcAux <> ALLTRIM(aGrvOrc[i][nPosCJ_P_REF][2]) .And. cNumOrcAux <> ""
		GrvORC(acab,aIte)
		acab := {}
		aIte := {}
	EndIf
	cNumOrcAux := ALLTRIM(aGrvOrc[i][nPosCJ_P_REF][2])
	aIteAUX := {}
	aCabAUX := {}
	for j:=1 to len(aGrvOrc[i])
	    If LEFT(aGrvOrc[i][j][1],2) == "CJ"
			aadd(aCabAUX,{aGrvOrc[i][j][1],aGrvOrc[i][j][2]})
		ElseIf LEFT(aGrvOrc[i][j][1],2) == "CK"
	   		aadd(aIteAUX,{aGrvOrc[i][j][1],aGrvOrc[i][j][2]})
		EndIf
	Next j
	If Len(aCab) == 0
		aCab := aCabAUX
	EndIf
	aAdd(aIte,aIteAUX)
Next i
If Len(acab) <> 0
	GrvORC(acab,aIte)
	acab := {}
	aIte := {}
EndIf
oMeter2:Set(i+1)
oMeter2:LVISIBLE 	:= .F.

oSayTxt1:CCAPTION 	:= "Processando finalizado!"
oSayTxt2:CCAPTION 	:= "Email de notificação enviado para o cliente."

SendMail("OK","Processamento finalizado com Sucesso!")

Return .T.

/*
Função  : GrvOrc
Objetivo: Gravação do Orçamento
Autor   : Jean Victor Rocha
Data    : 
*/
*---------------------------------*
Static Function GrvOrc(acab,aItens)
*---------------------------------*
Local i,j
Local aArea := GetArea()
Local cInsert := ""

cNumOrc := GETSXENUM("SCJ","CJ_NUM")
ConfirmSX8()

//Header
cInsert := " "
cInsert += " Insert Into "+RetSQLName("SCJ")
cInsert += " (CJ_NUM, "
For i := 1 to Len(aCab)
	cInsert += " "+aCab[i][1]+", "
Next i
cInsert += " R_E_C_N_O_ ) "
cInsert += " Values( '"+cNumOrc+"', "
For i := 1 to Len(aCab)
	Do Case
		Case ALLTRIM(aCab[i][1]) == "CJ_MOEDA"
			cInsert += " '"+ALLTRIM(STR(aCab[i][2]))+"', "
		Case ValType(aCab[i][2]) == "N"
			cInsert += " "+STRTRAN(TRANSFORM(aCab[i][2], "9999999999999.9999"),",",".")+", "
		Case ValType(aCab[i][2]) == "D"
			If !EMPTY(aCab[i][2])
				cInsert += " '"+DTOS(aCab[i][2])+"', "
			Else
				cInsert += " '"+ALLTRIM(aCab[i][2])+"', "
			EndIf
		Case ValType(aCab[i][2]) == "C"
			cInsert += " '"+ALLTRIM(aCab[i][2])+"', "	
	EndCase
Next i
cInsert += " (Select ISNULL(MAX(R_E_C_N_O_)+1,1) From "+RetSQLName("SCJ")+") ) "

TcSqlExec(cInsert)
                    
//Detail
For j:=1 To Len(aItens)
	cInsert := " "
	cInsert += " Insert Into "+RetSQLName("SCK")
	cInsert += " ( CK_NUM,CK_ITEM, "
	For i := 1 to Len(aItens[j])
		cInsert += " "+aItens[j][i][1]+", "
	Next i
	cInsert += " R_E_C_N_O_ ) "
	cInsert += " Values( '"+cNumOrc+"', '"+StrZero(i,2)+"', "
	For i := 1 to Len(aItens[j])
		Do Case
			Case ValType(aItens[j][i][2]) == "N"
				cInsert += " "+STRTRAN(TRANSFORM(aItens[j][i][2], "9999999999999.9999"),",",".")+", "
			Case ValType(aItens[j][i][2]) == "D"
				cInsert += " '"+DTOS(aItens[j][i][2])+"', "
			Case ValType(aItens[j][i][2]) == "C"
				cInsert += " '"+ALLTRIM(aItens[j][i][2])+"', "	
		EndCase
	Next i
	cInsert += " (Select ISNULL(MAX(R_E_C_N_O_)+1,1) From "+RetSQLName("SCK")+") ) "
	TcSqlExec(cInsert)
Next j

Return .T.

/*
Função  : orcDupl
Objetivo: verifica se o orçamento ja existe no sistema.
Autor   : Jean Victor Rocha
Data    : 
*/
*---------------------------------*
Static Function orcDupl(cOrc,cCNPJ)
*---------------------------------*
Local lRet := .F.
Local cQry := ""
   
If Select("TMP") <> 0
	TMP->(DbCloseArea())
EndIf
        
cQry := " Select CJ_P_REF 
cQry += " From "+RETSQLNAME("SCJ")+" SCJ
cQry += " 	inner join "+RETSQLNAME("SA1")+" as SA1 on SA1.A1_COD = SCJ.CJ_CLIENTE AND SA1.A1_LOJA = SCJ.CJ_LOJA
cQry += " Where SA1.D_E_L_E_T_ <> '*'
cQry += " 	AND SCJ.D_E_L_E_T_ <> '*' 
cQry += " 	AND SCJ.CJ_P_REF = '"+ALLTRIM(cOrc)+"'
cQry += " 	AND SA1.A1_CGC = '"+ALLTRIM(cCNPJ)+"'

dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQry), 'TMP', .F., .T.)
           
lRet := TMP->(!EOF())

return lRet

/*
Funcao      : SendMail
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Envia notificações
Autor       : Jean Victor Rocha 
Data/Hora   : 
*/
*----------------------------------*
Static Function	SendMail(cTipo,cMsg)
*----------------------------------*
Local cObs	:= ""
Local cNf	:= ""
Local lEnvioOK := .T.

If nHabEmail <> 1
	Return .T.
EndIf

cMailUser	:= GETMV("MV_RELAUSR",,"totvs@hlb.com.br")
cMailConta	:= GETMV("MV_EMCONTA",,"totvs@hlb.com.br")
cMailServer	:= GETMV("MV_RELSERV",,"mail.hlb.com.br")
cMailSenha	:= GETMV("MV_EMSENHA",,"Email@14")

cTexto		:= ""
cSubject := "[GT] - Novo processamento de orçamento finalizado"
cTexto := "<p>Olá ,</p><br>"
cTexto += "<p>Foi finalizado um processamento de integração de orçamento e "
If cTipo == "OK"
	cTexto += "foi finalizado com sucesso!</p> "
Else
	cTexto += "apresentou os seguintes erros:</p> "
	cTexto += "<p>"+cMsg+"</p>"
EndIf

cTexto += "<br>"
cTexto += "<br>"
cTexto += "<p>Este e-mail foi enviado automaticamente, não responder!"
cTexto += "<br><b>HLB BRASIL.</b></p>"
cTexto += "<img src='http://www.grantthornton.com.br/globalassets/1.-member-firms/global/logos/logo.png'>"

oMessage			:= TMailMessage():New()
oMessage:Clear()
oMessage:cDate		:= cValToChar(Date())
oMessage:cFrom		:= cMailConta
oMessage:cTo		:= ALLTRIM(cEmailCli)
oMessage:cCC 		:= ALLTRIM(cEmailCC)
oMessage:cBCC 		:= "log.sistemas@hlb.com.br"
//oMessage:cReplyTo	:= ""//responder para...
oMessage:cSubject	:= cSubject
oMessage:cBody		:= cTexto

//aArquivos := DIRECTORY(cDestServer+"\*.*","A")
//For i:=1 to len(aArquivos)
//	xRet := oMessage:AttachFile(cDestServer+"\"+aArquivos[i][1])
//	If xRet < 0
//		conout( "Could not attach file " + cDestServer+"\"+aArquivos[i][1] )
//	EndIf
//Next j

oServer				:= tMailManager():New()
oServer:SetUseTLS(.T.)
cUser				:= cMailUser
cPass				:= cMailSenha
//AOA - 19/10/2017 - Alterado validação para envio de e-mail
If AT(":", cMailServer) > 0
	cMailServer := SUBSTR(cMailServer, 1, AT(":", cMailServer) - 1)
EndIf
xRet := oServer:Init( "", cMailServer, cUser, cPass, 0, 587 )
If xRet != 0
	conout( "Could not initialize SMTP server: " + oServer:GetErrorString( xRet ) )
	lEnvioOK := .F.
EndIf
xRet := oServer:SetSMTPTimeout( 60 )
If xRet != 0
    conout( "Could not set timeout to " + cValToChar( 60 ) ) 
	lEnvioOK := .F.
EndIf
xRet := oServer:SMTPConnect()
If xRet <> 0
	conout( "Could not connect on SMTP server: " + oServer:GetErrorString( xRet ) )
	lEnvioOK := .F.
EndIf
xRet := oServer:SmtpAuth( cUser, cPass )
If xRet <> 0
    conout( "Could not authenticate on SMTP server: " + oServer:GetErrorString( xRet ) )
    lEnvioOK := .F.
    oServer:SMTPDisconnect()
EndIf      
//Envio
xRet := oMessage:Send( oServer )
If xRet <> 0
    conout( "Could not send message: " + oServer:GetErrorString( xRet ))
    lEnvioOK := .F.
EndIf
//Encerra
xRet := oServer:SMTPDisconnect()
If xRet <> 0
    conout("Could not disconnect from SMTP server: " + oServer:GetErrorString(xRet))
    lEnvioOK := .F.
EndIf

Return lEnvioOK