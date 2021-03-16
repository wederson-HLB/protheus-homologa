#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"    
#Include "topconn.ch"

/*
Funcao      : GTLOJ001
Parametros  : Nil
Retorno     : Nil
Objetivos   : Rotina de Integração Loja
Autor       : Jean Victor Rocha
Data/Hora   : 28/04/2014
*/
*----------------------*
User Function GTLOJ001()
*----------------------*
Private lAvisoLGI := .F.

//CloseThread()//Thread fica em execução...

//Update das Tabelas de Cancelamento de Cupom Loja.
SX2->(DbSetOrder(1))
If !SX2->(DbSeek("Z31"))
	MsgInfo("Ambiente deve ser atualizado com o Update 'UZ31001'. Entre em contato com a equipe de Sistemas!","HLB BRASIL")
	Return .F.
EndIf

//Valida se possui campos personalizados.
SL4->(DbSetOrder(1))
If SL4->(FieldPos("L4_P_SERIE")) == 0 .or. SL4->(FieldPos("L4_P_DOC")) == 0
	MsgInfo("Ambiente deve ser atualizado com o Update 'UZ31001'. Entre em contato com a equipe de Sistemas!","HLB BRASIL")
	Return .F.
EndIf

//Return Processa({|| MainGT() },"Processando aguarde...")
Return MainGt()

*----------------------*
Static Function MainGT()
*----------------------*
Private oDlg
Private aSize 	:= MsAdvSize()
Private oLayer	:= FWLayer():new()

Private nMax := 99999999999

Private aCposSL1 := {"L1_FILIAL","L1_DOC","L1_SERIE","L1_VEND","L1_CLIENTE","L1_LOJA","L1_VLRTOT","L1_DESCONT","L1_VLRLIQ",;
						"L1_EMISSAO","L1_CGCCLI","L1_FORMPG","L1_SITUA"}
Private aCposSL2 := {"L2_FILIAL","L2_DOC","L2_SERIE","L2_PRODUTO","L2_ITEM","L2_DESCRI","L2_QUANT","L2_VRUNIT","L2_VLRITEM"}
Private aCposSL4 := {"L4_FILIAL","L4_P_DOC","L4_P_SERIE","L4_VALOR","L4_FORMA","L4_ITEM"}
Private aCposSFI := {"FI_FILIAL","FI_DTMOVTO","FI_SERPDV","FI_NUMREDZ","FI_NUMINI","FI_GTINI","FI_GTFINAL",;
						"FI_NUMFIM","FI_CANCEL","FI_VALCON","FI_SUBTRIB","FI_DTREDZ"}

Private aObrSL1 := {}
Private aObrSL2 := {}
Private aObrSL4 := {}
Private aObrSFI := {}

Private cDtIni := DTOS(DATE()-30)
Private cDtFim := DTOS(DATE())

Private cDirArq := "C:\"

Private nCorOri := 0

Private aArqSL1 := {}
Private aArqSL2 := {}
Private aArqSL4 := {}
Private aArqSFI := {}
Private aLogInt := {}

Private aCpoSL1 := {}
Private aCpoSL2 := {}
Private aCpoSL4 := {}
Private aCpoSFI := {}

Private cMenuAtu := ""

Private lCpoDev	:= .F.
Private lCpoCan	:= .F.

Private lGravaOk:= .F.

Private aNameArqOri := {}

SL1->(DbSetOrder(1))
SL2->(DbSetOrder(1))
SL4->(DbSetOrder(1))
SFI->(DbSetOrder(1))

//INTERFACE Integração ---------------------------------------------------------------------------------------------------------------
oDlg := MSDialog():New( aSize[7],0,aSize[6],aSize[5],"HLB BRASIL - Integração LOJA",,,.F.,,,,,,.T.,,,.T. )

oLayer:Init(oDlg,.F.)

oLayer:addLine( '1', 100 , .F. )

oLayer:addCollumn('1',5.5,.F.,'1')
oLayer:addCollumn('2',6.5,.F.,'1')
oLayer:addCollumn('3',88 ,.F.,'1')

oLayer:setColSplit('2',CONTROL_ALIGN_LEFT,'1',{|| ResizeCol()})

oLayer:addWindow('1','Win11','Menu'					,100,.F.,.T.,{|| },'1',{|| })
oLayer:addWindow('2','Win21','SubMenu'					,100,.F.,.T.,{|| },'1',{|| })
oLayer:addWindow('3','Win31','Painel'					,100,.F.,.T.,{|| },'1',{|| })

//Definição das janelas para objeto.
oWin11 := oLayer:getWinPanel('1','Win11','1')
oWin21 := oLayer:getWinPanel('2','Win21','1')
oWin31 := oLayer:getWinPanel('3','Win31','1')

//Menu
oBtn10 := TBtnBmp2():New(aSize[6]-84	,03,26,26,'FINAL'   	   	,,,,{|| oDlg:end()}		, oWin11,"Sair"				,,.T.)
oBtn11 := TBtnBmp2():New(004			,03,26,26,'HISTORIC'   	  	,,,,{|| CUPOM()}		, oWin11,"Cupons"				,,.T.)
oBtn12 := TBtnBmp2():New(044			,03,26,26,'S4WB010N'   		,,,,{|| REDUC()}		, oWin11,"Redução Z"			,,.T.)
oBtn14 := TBtnBmp2():New(084			,03,26,26,'DESTINOS'   		,,,,{|| INTEG()}		, oWin11,"Integração"		,,.T.)

//SubMenu

//Cupom
oBtn21 := TBtnBmp2():New(004			,06,26,26,'FILTRO'   		,,,,{|| LoadBase(.T.)}			, oWin21,"Filtro"					,,.T.)

//Reducao
oBtn26 := TBtnBmp2():New(004			,06,26,26,'FILTRO'   		,,,,{|| LoadRed(.T.)	}			, oWin21,"Filtro"					,,.T.)

//Integração
oBtn28 := TBtnBmp2():New(004	,06,26,26,'MATERIAL'   	,,,,{|| ChangeInt()	}											, oWin21,"Troca Tp. Integ."	,,.T.)
oBtn22 := TBtnBmp2():New(044	,06,26,26,'TK_NOVO'   	,,,,{|| CleanInt()	}											, oWin21,"Limpar"			,,.T.)
oBtn23 := TBtnBmp2():New(084	,06,26,26,'OPEN'   	    ,,,,{|| GetDir()	}											, oWin21,"Diretorio"		,,.T.)
oBtn24 := TBtnBmp2():New(124	,06,26,26,'ENGRENAGEM'  ,,,,{|| Processa({|| LoadArq() },"Processando aguarde...")	}	, oWin21,"Carregar"			,,.T.)
oBtn25 := TBtnBmp2():New(164	,06,26,26,'SALVAR'   	,,,,{|| Processa({|| SaveArq() },"Processando aguarde...")	}	, oWin21,"Gravar"			,,.T.)
oBtn27 := TBtnBmp2():New(204	,06,26,26,'BMPVISUAL'   ,,,,{|| Processa({|| GetLog()  },"Processando aguarde...")	}	, oWin21,"Gerar Log Erros"	,,.T.)
oBtn29 := TBtnBmp2():New(244	,06,26,26,'BMPCPO'   	,,,,{|| GetModelo()	}											, oWin21,"Gerar Modelo"		,,.T.)
	
oBtn22:LVISIBLECONTROL := .F.
oBtn23:LVISIBLECONTROL := .F.
oBtn24:LVISIBLECONTROL := .F.
oBtn25:LVISIBLECONTROL := .F.
oBtn26:LVISIBLECONTROL := .F.
oBtn27:LVISIBLECONTROL := .F.
oBtn28:LVISIBLECONTROL := .F.
oBtn29:LVISIBLECONTROL := .F.

cMenuAtu := UPPER(LEFT(oBtn11:CTOOLTIP,3))

//Criação de Browses 
//Cupons Fiscais
oSayCupom	:= TSay():New( 02,01,{|| "Cupons:"},oWin31,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,176,008)
aHCupom    := {}//SL1->(dbStruct())
aCCupom	:= {}
SX3->(DbSetOrder(1))
If SX3->(DbSeek("SL1"))
	While SX3->(!EOF()) .and. SX3->X3_ARQUIVO == "SL1"
		If aScan(aCposSL1,{|X| ALLTRIM(X) == ALLTRIM(SX3->X3_CAMPO) }) <> 0 .And. SL1->(FieldPos(SX3->X3_CAMPO)) <> 0
			AADD(aHCupom,{ TRIM(SX3->X3_TITULO),"WRK"+SUBSTR(SX3->X3_CAMPO,AT("_",SX3->X3_CAMPO),50),;
									SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"","",SX3->X3_TIPO,"",""})
		EndIf
		SX3->(DbSkip())
	EndDo
EndIf
aACupom	:= {}
oCupom := MsNewGetDados():New(10,01,(oWin31:NHEIGHT/2)-2,((oWin31:NRIGHT/2)/3)-2,GD_UPDATE,"AllwaysTrue()","AllwaysTrue()",;
							"", aACupom,,nMax, "AllwaysTrue()", "AllwaysTrue()","AllwaysTrue()", oWin31,aHCupom, aCCupom, {|| AtuCupom()})

oCupom:oBrowse:SetBlkBackColor({|| GETDCLR(oCupom:ACOLS,oCupom:NAT,oCupom:aHeader,.T.)})

oCupom:LCANEDITLINE	:= .F.//não possibilita troca de tipo de edição.
oCupom:LEDITLINE	:= .F.//Não abre linha de edição de linha quando clicar na linha.
oCupom:ForceRefresh()

//Itens Cupons Fiscais.
oSayItem	:= TSay():New( 02,((oWin31:NRIGHT/2)/3),{|| "Itens Cupons:"},oWin31,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,176,008)
aHItem := {}
aCItem	:= {}
If SX3->(DbSeek("SL2"))
	While SX3->(!EOF()) .and. SX3->X3_ARQUIVO == "SL2"
		If aScan(aCposSL2,{|X| ALLTRIM(X) == ALLTRIM(SX3->X3_CAMPO) }) <> 0 .And. SL2->(FieldPos(SX3->X3_CAMPO)) <> 0
			AADD(aHItem,{ TRIM(SX3->X3_TITULO),"WRK"+SUBSTR(SX3->X3_CAMPO,AT("_",SX3->X3_CAMPO),50),;
											SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"","",SX3->X3_TIPO,"",""})
		EndIf
		SX3->(DbSkip())
	EndDo
EndIf
aAItem	:= {}
oItem := MsNewGetDados():New(10,((oWin31:NRIGHT/2)/3),(oWin31:NHEIGHT/2)-2,((oWin31:NRIGHT/2)/3*2)-2,;
									GD_UPDATE,"AllwaysTrue()","AllwaysTrue()",;
									"", aAItem,,nMax, "AllwaysTrue()", "AllwaysTrue()","AllwaysTrue()", oWin31,aHItem, aCItem)

oItem:oBrowse:SetBlkBackColor({|| GETDCLR(oItem:ACOLS,oItem:NAT,oItem:aHeader,.T.)})
oItem:LCANEDITLINE	:= .F.//não possibilita troca de tipo de edição.
oItem:LEDITLINE		:= .F.//Não abre linha de edição de linha quando clicar na linha.
oItem:ForceRefresh()

//Formas de Pagamentos Cupons Fiscais.
oSayPagam	:= TSay():New( 02,((oWin31:NRIGHT/2)/3*2),{|| "Formas Pagamentos:"},oWin31,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,176,008)
aHPagam := {}
aCPagam	:= {}
If SX3->(DbSeek("SL4"))
	While SX3->(!EOF()) .and. SX3->X3_ARQUIVO == "SL4"
		If aScan(aCposSL4,{|X| ALLTRIM(X) == ALLTRIM(SX3->X3_CAMPO) }) <> 0 .And. SL4->(FieldPos(SX3->X3_CAMPO)) <> 0
			AADD(aHPagam,{ TRIM(SX3->X3_TITULO),"WRK"+SUBSTR(SX3->X3_CAMPO,AT("_",SX3->X3_CAMPO),50),;
										SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"","",SX3->X3_TIPO,"",""})
		EndIf
		SX3->(DbSkip())
	EndDo
EndIf
aAPagam	:= {}
oPagam := MsNewGetDados():New(10,((oWin31:NRIGHT/2)/3*2),(oWin31:NHEIGHT/2)-3,(oWin31:NRIGHT/2)-2,;
									GD_UPDATE,"AllwaysTrue()","AllwaysTrue()",;
									"", aAPagam,,nMax, "AllwaysTrue()", "AllwaysTrue()","AllwaysTrue()", oWin31,aHPagam, aCPagam)

oPagam:oBrowse:SetBlkBackColor({|| GETDCLR(oPagam:ACOLS,oPagam:NAT,oPagam:aHeader,.T.)})
oPagam:LCANEDITLINE	:= .F.//não possibilita troca de tipo de edição.
oPagam:LEDITLINE		:= .F.//Não abre linha de edição de linha quando clicar na linha.
oPagam:ForceRefresh()

//Redução Z
oSayRed	:= TSay():New( 02,01,{|| "Redução Z:"},oWin31,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,176,008)
oSayRed:LVISIBLECONTROL := .F.
aHRed := {}
aCRed	:= {}
If SX3->(DbSeek("SFI"))
	While SX3->(!EOF()) .and. SX3->X3_ARQUIVO == "SFI"
		If aScan(aCposSFI,{|X| ALLTRIM(X) == ALLTRIM(SX3->X3_CAMPO) }) <> 0 .And. SFI->(FieldPos(SX3->X3_CAMPO)) <> 0
			AADD(aHRed,{ TRIM(SX3->X3_TITULO),"WRK"+SUBSTR(SX3->X3_CAMPO,AT("_",SX3->X3_CAMPO),50),;
						SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"","",SX3->X3_TIPO,"",""})
		EndIf
		SX3->(DbSkip())
	EndDo
EndIf
aARed:= {}
oRed := MsNewGetDados():New(10,01,(oWin31:NHEIGHT/2)-2,((oWin31:NRIGHT/2))-3,GD_UPDATE,"AllwaysTrue()","AllwaysTrue()",;
						"", aARed,,nMax, "AllwaysTrue()", "AllwaysTrue()","AllwaysTrue()", oWin31,aHRed, aCRed, {|| ColorLine(oRed)})
oRed:oBrowse:SetBlkBackColor({|| GETDCLR(oRed:ACOLS,oRed:NAT,oRed:aHeader,.T.)})
oRed:LCANEDITLINE	:= .F.//não possibilita troca de tipo de edição.
oRed:LEDITLINE	:= .F.//Não abre linha de edição de linha quando clicar na linha.
oRed:ForceRefresh()
oRed:OBROWSE:LVISIBLECONTROL := .F.

//Validação dos campos Obrigatorios.
aAdd(aObrSL1,"L1_FILIAL")
aAdd(aObrSL1,"L1_DOC")
aAdd(aObrSL1,"L1_SERIE")
aAdd(aObrSL1,"L1_VALBRUT")

aAdd(aObrSL2,"L2_FILIAL")
aAdd(aObrSL2,"L2_DOC")
aAdd(aObrSL2,"L2_SERIE")

aAdd(aObrSL4,"L4_FILIAL")
aAdd(aObrSL4,"L4_P_DOC")
aAdd(aObrSL4,"L4_P_SERIE")

aAdd(aObrSFI,"FI_FILIAL")
aAdd(aObrSFI,"FI_NUMREDZ")
aAdd(aObrSFI,"FI_DTMOVTO")
aAdd(aObrSFI,"FI_PDV")

//Carrega Informações dos Cupons do Sistema
LoadBase()

oDlg:Activate(,,,.T.)

If lGravaOk
	aArqDir := Directory(cDirArq+"*.CSV")
	For i:=1 to len(aArqDir)
		If LEN(aArqDir[i][1]) == 7
			AjustaNomeArq(aArqDir[i][1],"2")
		Endif
	Next i
Else
	aArqDir := Directory(cDirArq+"*.CSV")
	For i:=1 to len(aArqDir)
		AjustaNomeArq(aArqDir[i][1],"2")
	Next i
EndIf


Return .T.

/*
Funcao      : CUPOM
Parametros  : Nil
Retorno     : Nil
Objetivos   : Rotina de Ajuste do Espacamento das colunas em caso de ocultar uma coluna.
Autor       : Jean Victor Rocha
Data/Hora   : 28/04/2014
*/
*-------------------------*
Static Function ResizeCol()
*-------------------------*
oRed:oBrowse:nLeft  := oWin31:NLEFT
oRed:oBrowse:nRight := ((oWin31:NRIGHT))-3

oCupom:oBrowse:nLeft  := oWin31:NLEFT
oCupom:oBrowse:nRight := ((oWin31:NRIGHT)/3)-2
oItem:oBrowse:nLeft   := ((oWin31:NRIGHT)/3)
oItem:oBrowse:nRight  := ((oWin31:NRIGHT)/3*2)-2
oPagam:oBrowse:nLeft  := ((oWin31:NRIGHT)/3*2)
oPagam:oBrowse:nRight := ((oWin31:NRIGHT))-3

oSayCupom:NLEFT := oWin31:NLEFT
oSayItem:NLEFT  := ((oWin31:NRIGHT)/3)
oSayPagam:NLEFT := ((oWin31:NRIGHT)/3*2)
oSayRed:NLEFT   := oWin31:NLEFT

oRed:ForceRefresh()
oCupom:ForceRefresh()
oItem:ForceRefresh()
oPagam:ForceRefresh()
Return .T.

/*
Funcao      : CUPOM
Parametros  : Nil
Retorno     : Nil
Objetivos   : Rotina de Visualização dos Cupons no Sistema
Autor       : Jean Victor Rocha
Data/Hora   : 28/04/2014
*/
*---------------------*
Static Function CUPOM()
*---------------------*
//Caso ja esteja na rotina, não executa novamente.
If cMenuAtu == UPPER(LEFT(oBtn11:CTOOLTIP,3))
	Return .T.
EndIf

If !CleanInt()
	Return .T.
EndIf

cMenuAtu := UPPER(LEFT(oBtn11:CTOOLTIP,3))

oCupom:oBrowse:LVISIBLECONTROL := .T.
oItem:oBrowse:LVISIBLECONTROL := .T.
oPagam:oBrowse:LVISIBLECONTROL := .T.
oRed:oBrowse:LVISIBLECONTROL := .F.

oSayCupom:LVISIBLECONTROL := .T.
oSayItem:LVISIBLECONTROL := .T.
oSayPagam:LVISIBLECONTROL := .T.
oSayRed:LVISIBLECONTROL := .F.

oBtn21:LVISIBLECONTROL := .T.
oBtn22:LVISIBLECONTROL := .F.
oBtn23:LVISIBLECONTROL := .F.
oBtn24:LVISIBLECONTROL := .F.
oBtn25:LVISIBLECONTROL := .F.
oBtn26:LVISIBLECONTROL := .F.
oBtn27:LVISIBLECONTROL := .F.
oBtn28:LVISIBLECONTROL := .F.
oBtn29:LVISIBLECONTROL := .F.

//Atualiza os Browses
LoadBase()

oRed:ForceRefresh()
oCupom:ForceRefresh()
oItem:ForceRefresh()
oPagam:ForceRefresh()

Return .T.

/*
Funcao      : REDUC
Parametros  : Nil
Retorno     : Nil
Objetivos   : Rotina De visualização de Redução Z no Sistema
Autor       : Jean Victor Rocha
Data/Hora   : 28/04/2014
*/
*---------------------*
Static Function REDUC()
*---------------------*
//Caso ja esteja na rotina, não executa novamente.
If cMenuAtu == UPPER(LEFT(oBtn12:CTOOLTIP,3))
	Return .T.
EndIf

If !CleanInt()
	Return .T.
EndIf
cMenuAtu := UPPER(LEFT(oBtn12:CTOOLTIP,3))

oCupom:oBrowse:LVISIBLECONTROL := .F.
oItem:oBrowse:LVISIBLECONTROL := .F.
oPagam:oBrowse:LVISIBLECONTROL := .F.
oRed:oBrowse:LVISIBLECONTROL := .T.

oSayCupom:LVISIBLECONTROL := .F.
oSayItem:LVISIBLECONTROL := .F.
oSayPagam:LVISIBLECONTROL := .F.
oSayRed:LVISIBLECONTROL := .T.

oBtn21:LVISIBLECONTROL := .F.
oBtn22:LVISIBLECONTROL := .F.
oBtn23:LVISIBLECONTROL := .F.
oBtn24:LVISIBLECONTROL := .F.
oBtn25:LVISIBLECONTROL := .F.
oBtn26:LVISIBLECONTROL := .T.
oBtn27:LVISIBLECONTROL := .F.
oBtn28:LVISIBLECONTROL := .F.
oBtn29:LVISIBLECONTROL := .F.

//Carrega Informações da Reducao Z
LoadRed()

oRed:ForceRefresh()
oCupom:ForceRefresh()
oItem:ForceRefresh()
oPagam:ForceRefresh()

Return .T.

/*
Funcao      : INTEG
Parametros  : Nil
Retorno     : Nil
Objetivos   : Rotina de Integração
Autor       : Jean Victor Rocha
Data/Hora   : 28/04/2014
*/
*---------------------*
Static Function INTEG()
*---------------------*

//Aviso de gravação do Log de inclusão.
If !lAvisoLGI
	If SL1->(FieldPos("L1_USERLGI")) == 0 .or.;
		SL2->(FieldPos("L2_USERLGI")) == 0 .or.;
		SL4->(FieldPos("L4_USERLGI")) == 0 .or.;
		SFI->(FieldPos("FI_USERLGI")) == 0
		cMsg := "Empresa não configurada para a gravação de Log de Inclusão!"+CHR(13)+CHR(10)
		cMsg += "Entrar em contato com a Equipe de Sistemas da HLB BRASIL"+CHR(13)+CHR(10)
		cMsg += "e solicitar para habilitar!"+CHR(13)+CHR(10)
		cMsg += "Habilitar 'USERLGI' Tabela(s): "
		If SL1->(FieldPos("L1_USERLGI")) == 0
			cMsg += "'SL1' ; "
		EndIf
		If SL2->(FieldPos("L2_USERLGI")) == 0
			cMsg += "'SL2' ; "
		EndIf
		If SL4->(FieldPos("L4_USERLGI")) == 0
			cMsg += "'SL4' ; "
		EndIf
		If SFI->(FieldPos("FI_USERLGI")) == 0
			cMsg += "'SFI' ; "
		EndIf
		cMsg := LEFT(cMsg,Len(cMsg)-2)
		
		EECVIEW(cMsg)
		
		lAvisoLGI := .T.
	EndIf
EndIf

//Caso ja esteja na rotina, não executa novamente.
If cMenuAtu == UPPER(LEFT(oBtn14:CTOOLTIP,3))
	Return .T.
EndIf

CleanInt()
cMenuAtu := UPPER(LEFT(oBtn14:CTOOLTIP,3))

oCupom:oBrowse:LVISIBLECONTROL := .T.
oItem:oBrowse:LVISIBLECONTROL := .T.
oPagam:oBrowse:LVISIBLECONTROL := .T.
oRed:oBrowse:LVISIBLECONTROL := .F.
  
oSayCupom:LVISIBLECONTROL := .T.
oSayItem:LVISIBLECONTROL := .T.
oSayPagam:LVISIBLECONTROL := .T.
oSayRed:LVISIBLECONTROL := .F.

oCupom:oBrowse:lUseDefaultColors := .F.

oBtn21:LVISIBLECONTROL := .F.
oBtn22:LVISIBLECONTROL := .T.
oBtn23:LVISIBLECONTROL := .T.
oBtn24:LVISIBLECONTROL := .T.
oBtn25:LVISIBLECONTROL := .T.
oBtn26:LVISIBLECONTROL := .F.
oBtn27:LVISIBLECONTROL := .T.
oBtn28:LVISIBLECONTROL := .T.
oBtn29:LVISIBLECONTROL := .T.

oCupom:ACOLS := {}
oItem:ACOLS := {}
oPagam:ACOLS := {}

oRed:ForceRefresh()
oCupom:ForceRefresh()
oItem:ForceRefresh()
oPagam:ForceRefresh()

Return .T.


/*
Funcao      : ChangeInt
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para tratamento do tipo de integração selecionada
Autor       : Jean Victor Rocha.
Data/Hora   : 13/05/2014
*/
*-------------------------*
Static Function ChangeInt()
*-------------------------*
If !CleanInt()
	Return .T.
EndIf

If oCupom:oBrowse:LVISIBLECONTROL
	oCupom:oBrowse:LVISIBLECONTROL	:= .F.
	oItem:oBrowse:LVISIBLECONTROL	:= .F.
	oPagam:oBrowse:LVISIBLECONTROL	:= .F.
	oRed:oBrowse:LVISIBLECONTROL	:= .T.
	
	oSayCupom:LVISIBLECONTROL	:= .F.
	oSayItem:LVISIBLECONTROL		:= .F.
	oSayPagam:LVISIBLECONTROL	:= .F.
	oSayRed:LVISIBLECONTROL		:= .T.
Else
	oCupom:oBrowse:LVISIBLECONTROL	:= .T.
	oItem:oBrowse:LVISIBLECONTROL	:= .T.
	oPagam:oBrowse:LVISIBLECONTROL	:= .T.
	oRed:oBrowse:LVISIBLECONTROL	:= .F.

	oSayCupom:LVISIBLECONTROL	:= .T.
	oSayItem:LVISIBLECONTROL		:= .T.
	oSayPagam:LVISIBLECONTROL	:= .T.
	oSayRed:LVISIBLECONTROL		:= .F.
EndIf

oCupom:ACOLS	:= {}
oItem:ACOLS	:= {}
oPagam:ACOLS	:= {}
oRed:ACOLS		:= {}

oRed:ForceRefresh()
oCupom:ForceRefresh()
oItem:ForceRefresh()
oPagam:ForceRefresh()

Return .T.

/*
Funcao      : GETDCLR()  
Parametros  : aLinha,nLinha,aHeader,lCtrl
Retorno     : Nil
Objetivos   : Função para tratamento das regras de cores para a grid da MsNewGetDados
Autor       : Matheus Massarotto
Data/Hora   : 14/02/2012
*/
*--------------------------------------------------*
Static Function GETDCLR(aLinha,nLinha,aHeader,lCtrl)
*--------------------------------------------------*
Local nCor  := RGB(240,128,128)//Vermelho claro
Local nCor2 := RGB(192,192,192)//Cinza claro
Local nCor3 := RGB(222,184,135)//marrom claro
Local nCor4 := RGB(255,255,255)//Branco
Local nRet := nCor4

If lCtrl
	If cMenuAtu == "INT"
		If aLinha[nLinha][LEN(aLinha[nLinha])]
			nRet := nCor
		EndIf
	ElseIf cMenuAtu == "CUP" .or. cMenuAtu == "RED"
		If aLinha[nLinha][LEN(aLinha[nLinha])]
			nRet := nCor3
		EndIf
	Else
		If aLinha[nLinha][LEN(aLinha[nLinha])]
			nRet := nCor2
		EndIf
	EndIf
EndIf

Return nRet

/*
Funcao      : GetModelo
Parametros  : Nil
Retorno     : Nil
Objetivos   : Rotina para geração de arquivos modelos.
Autor       : Jean Victor Rocha
Data/Hora   : 14/05/2014
*/
*-------------------------*
Static Function GetModelo()
*-------------------------*
Local i
Local cArq := ""
Local aModSL1 := {'L1_FILIAL','L1_VLRTOT','L1_VLRLIQ','L1_DTLIM','L1_DOC','L1_SERIE','L1_EMISNF','L1_VALBRUT','L1_VALMERC',;
					'L1_PARCELA','L1_FORMPG','L1_EMISSAO','L1_IMPRIME','L1_HORA','L1_SITUA'}
Local aModSL2 := {'L2_FILIAL','L2_PRODUTO','L2_ITEM','L2_DESCRI','L2_QUANT','L2_VRUNIT','L2_VLRITEM','L2_LOCAL','L2_UM','L2_CF',;
					'L2_VENDIDO','L2_DOC','L2_SERIE','L2_PDV','L2_TABELA','L2_EMISSAO','L2_VEND','L2_SITUA','L2_SITTRIB','L2_VDMOST'}
Local aModSL4 := {'L4_FILIAL','L4_DATA','L4_VALOR','L4_FORMA','L4_SITUA','L4_MOEDA','L4_ITEM','L4_P_DOC','L4_P_SERIE'}
Local aModSFI := {'FI_FILIAL','FI_DTMOVTO','FI_SERPDV','FI_NUMREDZ','FI_GTINI','FI_GTFINAL','FI_NUMINI','FI_NUMFIM','FI_VALCON',;
					'FI_COO','FI_SITUA','FI_CRO','FI_DTREDZ','FI_HRREDZ'}

If !MsgYesNo("Deseja gerar os arquivos modelo na pasta: '"+ALLTRIM(cDirArq)+"'","HLB BRASIL")
	Return .T.
EndIf

SX3->(DBSetOrder(2))

If oCupom:oBrowse:LVISIBLECONTROL
	If FILE(cDirArq+"SL1_MODELO.CSV")
		FERASE(cDirArq+"SL1_MODELO.CSV")
	EndIf
	If FILE(cDirArq+"SL2_MODELO.CSV")
		FERASE(cDirArq+"SL2_MODELO.CSV")
	EndIf
	If FILE(cDirArq+"SL4_MODELO.CSV")
		FERASE(cDirArq+"SL4_MODELO.CSV")
	EndIf

	cArq := ""
	For i:=1 to Len(aModSL1)
		If SX3->(DbSeek(aModSL1[i]))
			cArq += aModSL1[i]+";"
		EndIf
	Next i
	cArq	:= LEFT(cArq,LEN(cArq)-1)
	nHdl	:= FCREATE(cDirArq+"SL1_MODELO.CSV",0 )
	nBytesSalvo := FWRITE(nHdl, cArq )
	fclose(nHdl)
	
	cArq := ""
	For i:=1 to Len(aModSL2)
		If SX3->(DbSeek(aModSL2[i]))
			cArq += aModSL2[i]+";"
		EndIf
	Next i
	cArq	:= LEFT(cArq,LEN(cArq)-1)
	nHdl	:= FCREATE(cDirArq+"SL2_MODELO.CSV",0 )
	nBytesSalvo := FWRITE(nHdl, cArq )
	fclose(nHdl)
	
	cArq := ""
	For i:=1 to Len(aModSL4)
		If SX3->(DbSeek(aModSL4[i]))
			cArq += aModSL4[i]+";"
		EndIf
	Next i
	cArq	:= LEFT(cArq,LEN(cArq)-1)
	nHdl	:= FCREATE(cDirArq+"SL4_MODELO.CSV",0 )
	nBytesSalvo := FWRITE(nHdl, cArq )
	fclose(nHdl)
	
	If File(cDirArq+"SL1_MODELO.CSV") .and. File(cDirArq+"SL2_MODELO.CSV") .and. File(cDirArq+"SL4_MODELO.CSV")
		MsgInfo("Arquivo(s) gerado(s) na pasta: '"+ALLTRIM(cDirArq)+"'","HLB BRASIL")	
	Else
		MsgInfo("Falha na geração de arquivo(s)! Verifique a pasta: '"+ALLTRIM(cDirArq)+"'","HLB BRASIL")
	EndIf
Else
	If FILE(cDirArq+"SFI_MODELO.CSV")
		FERASE(cDirArq+"SFI_MODELO.CSV")
	EndIf
	cArq := ""
	For i:=1 to Len(aModSFI)
		If SX3->(DbSeek(aModSFI[i]))
			cArq += aModSFI[i]+";"
		EndIf
	Next i
	cArq	:= LEFT(cArq,LEN(cArq)-1)
	nHdl	:= FCREATE(cDirArq+"SFI_MODELO.CSV",0 )
	nBytesSalvo := FWRITE(nHdl, cArq )
	fclose(nHdl)
	If File(cDirArq+"SFI_MODELO.CSV")
		MsgInfo("Arquivo gerado na pasta: '"+ALLTRIM(cDirArq)+"'","HLB BRASIL")	
	Else
		MsgInfo("Falha na geração de arquivo(s)! Verifique a pasta: '"+ALLTRIM(cDirArq)+"'","HLB BRASIL")
	EndIf
EndIf

Return .T.

/*
Funcao      : LoadBase
Parametros  : Nil
Retorno     : Nil
Objetivos   : Rotina para carregar arrays com os cupons do sistema
Autor       : Jean Victor Rocha
Data/Hora   : 05/05/2014
*/
*-----------------------------*
Static Function LoadBase(lPerg)
*-----------------------------*
Local lRet := .F.
Local cQuery := ""

Local dDataDe := STOD(cDtIni)
Local dDataAte := STOD(cDtFim)

Default lPerg := .F.

//Zera as Variaveis
oCupom:ACOLS := {}
oItem:ACOLS := {}
oPagam:ACOLS := {}

//Tela Para Filtro dos Cupons.
If lPerg
	oDlg1      := MSDialog():New( 279,530,381,824,"Filtro Cupons - Grant Thorton Brasil",,,.F.,,,,,,.T.,,,.T. )
	oSay1      := TSay():New( 008,004,{||"Data De"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oSay2      := TSay():New( 024,004,{||"Data Ate"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oGet1      := TGet():New( 008,036,{|u| IF(PCount()>0,dDataDe:=u,dDataDe)},oDlg1,060,008,'',,;
												CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
	oGet2      := TGet():New( 024,036,{|u| IF(PCount()>0,dDataAte:=u,dDataAte)},oDlg1,060,008,'',,;
												CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
	oSBtn1     := SButton():New( 004,108,1,{|| oDlg1:End()},oDlg1,,"", )
	oSBtn2     := SButton():New( 020,108,2,{|| oDlg1:End(),lRet := .T.},oDlg1,,"", )
	oDlg1:Activate(,,,.T.)
	
	If lRet
		Return .T.
	Else
		cDtIni := DTOS(dDataDe)
		cDtFim := DTOS(dDataAte)
	EndIf
EndIf

//Carrega SL1
If Select("QRY") > 0
	QRY->(DbClosearea())
Endif  
cQuery += "Select *
cQuery += " From "+RETSQLNAME("SL1")
cQuery += " Where D_E_L_E_T_ <> '*'
If !EMPTY(cDtIni)
	cQuery += " AND L1_EMISSAO >= '"+cDtIni+"'
EndIf
If !EMPTY(cDtFim)
	cQuery += " AND L1_EMISSAO <= '"+cDtFim+"'
EndIf

dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)

QRY->(DbGoTop())
While QRY->(!EOF())
	aAux := {}
	For i:=1 to len(oCupom:AHEADER)
		aAdd(aAux, QRY->(&(ALLTRIM( "L1"+SUBSTR(oCupom:AHEADER[i][2],AT("_",oCupom:AHEADER[i][2]),50) ))) )
	Next i
	aAdd(aAux,.F.)
	aAdd(oCupom:ACOLS,aAux)
	QRY->(DbSkip())
EndDo

If lPerg .and. LEN(oCupom:ACOLS) == 0
	MSGINFO("Sem Dados a serem carregados!")
	Return .F.
EndIf

oCupom:ForceRefresh()

//Atualiza os browses de cupons e Pagamentos.
AtuCupom()

Return .T.

/*
Funcao      : AtuCupom
Parametros  : Nil
Retorno     : Nil
Objetivos   : Rotina que Atualiza os browses de cupons e Pagamentos.
Autor       : Jean Victor Rocha
Data/Hora   : 05/05/2014
*/
*------------------------*
Static Function AtuCupom()
*------------------------*
Local cQuery := ""
Local nPos := 0

If cMenuAtu <> "CUP" .or. LEN(oCupom:ACOLS) == 0
	Return .T.
EndIf

oItem:ACOLS := {}
oPagam:ACOLS := {}

//Muda a cor da linha selecionada para cinza, apenas para destacar.
ColorLine(@oCupom)

//Carrega SL2
If Select("QRY") > 0
	QRY->(DbClosearea())
Endif  
cQuery := "Select *
cQuery += " From "+RETSQLNAME("SL2")
cQuery += " Where D_E_L_E_T_ <> '*'
cQuery += " AND L2_FILIAL = '"	+oCupom:ACOLS[oCupom:NAT][aScan(oCupom:AHEADER,{|x| ALLTRIM(x[2])=="WRK_FILIAL"})]+"'
cQuery += " AND L2_DOC = '"		+oCupom:ACOLS[oCupom:NAT][aScan(oCupom:AHEADER,{|x| ALLTRIM(x[2])=="WRK_DOC"})]+"'
cQuery += " AND L2_SERIE = '"	+oCupom:ACOLS[oCupom:NAT][aScan(oCupom:AHEADER,{|x| ALLTRIM(x[2])=="WRK_SERIE"})]+"'
cQuery += " AND L2_EMISSAO = '"	+oCupom:ACOLS[oCupom:NAT][aScan(oCupom:AHEADER,{|x| ALLTRIM(x[2])=="WRK_EMISSAO"})]+"'
cQuery += " AND L2_VEND = '"	+oCupom:ACOLS[oCupom:NAT][aScan(oCupom:AHEADER,{|x| ALLTRIM(x[2])=="WRK_VEND"})]+"'

dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)

QRY->(DbGoTop())
While QRY->(!EOF())
	aAux := {}
	For i:=1 to len(oItem:AHEADER)
		aAdd(aAux, QRY->(&(ALLTRIM( "L2"+SUBSTR(oItem:AHEADER[i][2],AT("_",oItem:AHEADER[i][2]),50) ))) )
	Next i
	aAdd(aAux,.F.)
	aAdd(oItem:ACOLS,aAux)
	QRY->(DbSkip())
EndDo

//Carrega SL4
If Select("QRY") > 0
	QRY->(DbClosearea())
Endif  
cQuery := "Select *
cQuery += " From "+RETSQLNAME("SL4")
cQuery += " Where D_E_L_E_T_ <> '*'
cQuery += " AND L4_FILIAL = '"	+oCupom:ACOLS[oCupom:NAT][aScan(oCupom:AHEADER,{|x| ALLTRIM(x[2])=="WRK_FILIAL"})]+"'
cQuery += " AND L4_P_DOC = '"	+oCupom:ACOLS[oCupom:NAT][aScan(oCupom:AHEADER,{|x| ALLTRIM(x[2])=="WRK_DOC"})]+"'
cQuery += " AND L4_P_SERIE = '"	+oCupom:ACOLS[oCupom:NAT][aScan(oCupom:AHEADER,{|x| ALLTRIM(x[2])=="WRK_SERIE"})]+"'
cQuery += " AND L4_DATA = '"	+oCupom:ACOLS[oCupom:NAT][aScan(oCupom:AHEADER,{|x| ALLTRIM(x[2])=="WRK_EMISSAO"})]+"'
cQuery += " AND L4_FORMA = '"	+oCupom:ACOLS[oCupom:NAT][aScan(oCupom:AHEADER,{|x| ALLTRIM(x[2])=="WRK_FORMPG"})]+"'

dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)

QRY->(DbGoTop())
While QRY->(!EOF())
	aAux := {}
	For i:=1 to len(oPagam:AHEADER)
		aAdd(aAux, QRY->(&(ALLTRIM( "L4"+SUBSTR(oPagam:AHEADER[i][2],AT("_",oPagam:AHEADER[i][2]),50) ))) )
	Next i
	aAdd(aAux,.F.)
	aAdd(oPagam:ACOLS,aAux)
	QRY->(DbSkip())
EndDo

oItem:ForceRefresh()
oPagam:ForceRefresh()

Return .T.

/*
Funcao      : LoadRed
Parametros  : Nil
Retorno     : Nil
Objetivos   : Rotina para carregar dados da Redução Z.
Autor       : Jean Victor Rocha
Data/Hora   : 28/04/2014
*/
*----------------------------*
Static Function LoadRed(lPerg)
*----------------------------*
Local lRet := .F.
Local cQuery := ""
Local dDataDe := STOD(cDtIni)
Local dDataAte := STOD(cDtFim)

Default lPerg := .F.

//Tela Para Filtro dos Cupons.
If lPerg
	oDlg1      := MSDialog():New( 279,530,381,824,"Filtro Cupons - Grant Thorton Brasil",,,.F.,,,,,,.T.,,,.T. )
	oSay1      := TSay():New( 008,004,{||"Data De"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oSay2      := TSay():New( 024,004,{||"Data Ate"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oGet1      := TGet():New( 008,036,{|u| IF(PCount()>0,dDataDe:=u,dDataDe)},oDlg1,060,008,'',,;
										CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
	oGet2      := TGet():New( 024,036,{|u| IF(PCount()>0,dDataAte:=u,dDataAte)},oDlg1,060,008,'',,;
										CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
	oSBtn1     := SButton():New( 004,108,1,{|| oDlg1:End()},oDlg1,,"", )
	oSBtn2     := SButton():New( 020,108,2,{|| oDlg1:End(),lRet := .T.},oDlg1,,"", )
	oDlg1:Activate(,,,.T.)
	
	If lRet
		Return .T.
	Else
		cDtIni := DTOS(dDataDe)
		cDtFim := DTOS(dDataAte)
	EndIf
EndIf

oRed:ACOLS := {}

If Select("QRY") > 0
	QRY->(DbClosearea())
Endif  
cQuery := "Select *
cQuery += " From "+RETSQLNAME("SFI")
cQuery += " Where D_E_L_E_T_ <> '*'
cQuery += " AND FI_DTMOVTO >= '"+cDtIni+"'
cQuery += " AND FI_DTMOVTO <= '"+cDtFim+"'

dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)

QRY->(DbGoTop())
While QRY->(!EOF())
	aAux := {}
	For i:=1 to len(oRed:AHEADER)
		aAdd(aAux, QRY->(&(ALLTRIM( "FI"+SUBSTR(oRed:AHEADER[i][2],AT("_",oRed:AHEADER[i][2]),50) ))) )
	Next i
	aAdd(aAux,.F.)
	aAdd(oRed:ACOLS,aAux)
	QRY->(DbSkip())
EndDo

ColorLine(oRed)

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
Local cTitle:= "Salvar arquivo"
Local cFile := ""
Local nDefaultMask := 0
Local cDefaultDir  := ALLTRIM(cDirArq)
Local nOptions:= GETF_NETWORKDRIVE+GETF_RETDIRECTORY+GETF_LOCALHARD

If !MsgYesNo("Diretorio Atual esta como '"+cDirArq+"'. Deseja alterar mesmo assim?")
	Return .T.
EndIf

cDirArq := ALLTRIM(cGetFile(cFile,cTitle,nDefaultMask,cDefaultDir,.T.,nOptions,.F.))

MsgInfo("Diretorio selecionado: '"+cDirArq+"'","HLB BRASIL")

Return .T.

/*
Funcao      : ColorLine
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para mudar a linha do objeto MsNewGetDados passado como Paramentro.
Autor       : Jean Victor Rocha.
Data/Hora   : 05/05/2014
*/
*--------------------------------*
Static Function ColorLine(oObjeto)
*--------------------------------*
Local nPos := 0

If LEN(oObjeto:ACOLS) == 0 .or. cMenuAtu == "INT"
	Return .T.
EndIf

If (nPos:=aScan(oObjeto:ACOLS,{|x|  x[LEN(x)] })) <> 0
	oObjeto:ACOLS[nPos][LEN(oObjeto:ACOLS[oCupom:NAT])] := .F.
EndIf

oObjeto:ACOLS[oObjeto:NAT][LEN(oObjeto:ACOLS[oCupom:NAT])] := .T.
oObjeto:Refresh()

Return .T.

/*
Funcao      : CleanInt
Parametros  : Nil
Retorno     : Nil
Objetivos   : Limpa os Browses para integração
Autor       : Jean Victor Rocha
Data/Hora   : 05/05/2014
*/
*------------------------------*
Static Function CleanInt(lForce)
*------------------------------*
Default lForce := .F.

If !lForce .and. cMenuAtu == "INT" .and. (Len(oCupom:ACOLS) <> 0 .or. Len(oRed:ACOLS) <> 0) .And.;
						 !MsgYesNo("Deseja Apagar os Dados processados?","HLB BRASIL")
	Return .F.
EndIf

aArqSL1 := {}
aArqSL2 := {}
aArqSL4 := {}
aArqSFI := {}

aCpoSL1 := {}
aCpoSL2 := {}
aCpoSL4 := {}
aCpoSFI := {}

aLogInt := {}

oCupom:ACOLS	:= {}
oItem:ACOLS	:= {}
oPagam:ACOLS	:= {}
oRed:ACOLS		:= {}

Return .T.

/*
Funcao      : LoadArq
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para carregar os arquivos para a tela e para os arrays que serão futuramente salvos.
Autor       : Jean Victor Rocha.
Data/Hora   : 05/05/2014
*/
*------------------------------------------*
Static Function LoadArq(lSL1,lSL2,lSL4,lSFI)
*------------------------------------------*
Local lRet := .T.
Local cRet := ""
Local i, j
Local aObrig := {}

Local oFT   := fT():New()//FUNCAO GENERICA

ProcRegua(100)
IncProc("Aguarde...")

If oCupom:oBrowse:LVISIBLECONTROL
	Default lSL1 := .T.
	Default lSL2 := .T.
	Default lSL4 := .T.
	Default lSFI := .F.
Else
	Default lSL1 := .F.
	Default lSL2 := .F.
	Default lSL4 := .F.
	Default lSFI := .T.
EndIf

aArqDir := Directory(cDirArq+"*.CSV")
For i:=1 to len(aArqDir)
	AjustaNomeArq(aArqDir[i][1],"1")
Next i

If lSL1
	If Len(oCupom:ACOLS) <> 0
		Alert("Deve ser selecionado a opção 'novo' no submenu para carregar uma nova integração!","HLB BRASIL")
		Return .F.
	EndIf
	aAdd(aObrig,{aObrSL1,ALLTRIM(cDirArq)+"SL1.CSV","SL1",0})
EndIf
If lSL2
	If Len(oItem:ACOLS) <> 0
		Alert("Deve ser selecionado a opção 'novo' no submenu para processar uma nova integração!","HLB BRASIL")
		Return .F.
	EndIf
	aAdd(aObrig,{aObrSL2,ALLTRIM(cDirArq)+"SL2.CSV","SL2",0})
EndIf
If lSL4
	If Len(oPagam:ACOLS) <> 0
		Alert("Deve ser selecionado a opção 'novo' no submenu para processar uma nova integração!","HLB BRASIL")
		Return .F.
	EndIf
	aAdd(aObrig,{aObrSL4,ALLTRIM(cDirArq)+"SL4.CSV","SL4",0})
EndIf
If lSFI
	If Len(oRed:ACOLS) <> 0
		Alert("Deve ser selecionado a opção 'novo' no submenu para processar uma nova integração!","HLB BRASIL")
		Return .F.
	EndIf
	aAdd(aObrig,{aObrSFI,ALLTRIM(cDirArq)+"SFI.CSV","SFI",0})
EndIf

If len(aObrig) == 0
	MSGINFO("Nenhum Arquivo selecionado para ser carregado!","HLB BRASIL")
	Return lRet
EndIf

//Validação dos Arquivos-----------------------------------
cRet += "Validação dos Arquivos -------------"+CHR(13)+CHR(10)
For i:=1 to len(aObrig)
	cRet += "Arquivo '"+aObrig[i][2]+"':"+CHR(13)+CHR(10)
	cCpoFaltantes := ""
	If File(aObrig[i][2])
		If oFT:FT_FUse(aObrig[i][2]) >= 0// Abre o arquivo
			oFT:FT_FGOTOP()      		// Posiciona no inicio do arquivo
			While !oFT:FT_FEof()
				cLinha := oFT:FT_FReadln()					//Le a linha

				//Tratamento especifico para SL1
				If "L1_P_TOTDEV" $ UPPER(cLinha)
					cLinha := STRTRAN(cLinha,"L1_P_TOTDEV","L1_P_TOTDE")
					lCpoDev	:= .T.
				EndIf
				If "L1_P_TOTCAN" $ UPPER(cLinha)
					cLinha := STRTRAN(cLinha,"L1_P_TOTCAN","L1_P_TOTCA")
					lCpoCan	:= .T.
				EndIf

				//Tratamento especifico para SL4
				If "L4_DOC" $ UPPER(cLinha)
					cLinha := STRTRAN(cLinha,"L4_DOC","L4_P_DOC")
				EndIf
				If "L4_SERIE" $ UPPER(cLinha)
					cLinha := STRTRAN(cLinha,"L4_SERIE","L4_P_SERIE")
				EndIf

				aLinha := separa(UPPER(cLinha),";")	//Sepera para vetor 
				If LEFT(aObrig[i][1][1],3) $ UPPER(aLinha[1])
					//Verifica se os campos base estão no arquivo
					For j:=1 to len(aObrig[i][1])
						If !(alltrim(aObrig[i][1][j]) $ UPPER(cLinha))
							cCpoFaltantes += aObrig[i][1][j]+","
						Endif
					Next j
					If !Empty(cCpoFaltantes)
						cRet += " - Campos Base Faltantes no arquivo: "+cCpoFaltantes+CHR(13)+CHR(10)
						lRet := .F.
					Endif
					If LEFT(aObrig[i][1][1],3) $ aLinha[1]
						aCampos := {}
						lTemDup := .F.
						cTemDup := ""
						lCmpNExt:= .F.
						cCmpNExt:= ""
						For j:=1 to len(aLinha)
							If LEFT(aObrig[i][1][1],3) $ aLinha[j]
								cCampo := Alltrim(aLinha[j])
								SX3->(Dbsetorder(2))
								If SX3->(Dbseek(cCampo))
									If aScan(aCampos, { |x| alltrim(x[1]) == cCampo} ) <> 0
										lTemDup := .T.
										cTemDup += cCampo+","
									Endif
									AADD(aCampos ,{cCampo,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_TITULO})
									AADD(&("aCpo"+aObrig[i][3]),{cCampo,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_TITULO})
								Else
									//lCmpNExt := .T.//RETIRADO VALIDAÇÂO QUE IMPEDE INTEGRACAO EM CASOS QUE NAO ESTA NO SX3
									//cCmpNExt += cCampo+","
									AADD(aCampos ,{cCampo,"C",1,0,cCampo})
									AADD(&("aCpo"+aObrig[i][3]),{cCampo,"C",1,0,cCampo})
								EndIf 
								lCrt:=.T.
							Else
								AADD(&("aCpo"+aObrig[i][3]),{"","","","",""})
							EndIf
						Next j
						If lTemDup
							cRet += " - Campos Duplicados no Arquivo:"+cTemDup+CHR(13)+CHR(10)
							lRet := .F.
						EndIf
						If lCmpNExt
							cRet += " - Campos nao encontrados no Dicionario de Dados:"+cCmpNExt+CHR(13)+CHR(10)
							lRet := .F.
						EndIf
					Else
						oFT:FT_FSkip() //Proxima linha
					EndIf	
					
					If lCrt
						oFT:FT_FSkip() //Proxima linha
						aObrig[i][4] := oFT:FT_FRECNO()
						Exit
					EndIf 
				Else
					oFT:FT_FSkip() //Proxima linha
				EndIf
			Enddo
			oFT:FT_FUse()
		Else
			cRet += " - Não foi possivel a Abertura exclusiva do arquivo."+CHR(13)+CHR(10)
			lRet := .F.
		EndIf
	Else
		cRet += " - Arquivo '"+aObrig[i][2]+"' não encontrado ou Não foi possivel manutenção no nome do arquivo existente de forma exclusiva!"+CHR(13)+CHR(10)
		lRet := .F.
	EndIf	
Next i
oFT:FT_FUse()

If !lRet
	EECVIEW(cRet)
	CleanInt(.T.)
	Return lRet
EndIf

//Carregar Informações nos Arrays	---------------------------------------------
cRet += "Lendo Informações -------------"+CHR(13)+CHR(10)
For i:=1 to len(aObrig)
	cRet += "Arquivo '"+aObrig[i][2]+"':"+CHR(13)+CHR(10)
	If oFT:FT_FUse(aObrig[i][2]) >= 0
		oFT:FT_FGOTO(aObrig[i][4])
		While !oFT:FT_FEof()
		   	cLinha := oFT:FT_FReadln()
		 	If !EMPTY(ALLTRIM(STRTRAN(cLinha,";","")))
		 		aLinha := separa(UPPER(cLinha),";") 
				aAdd(&("aArq"+aObrig[i][3]),aLinha)
			EndIf
			oFT:FT_FSkip()
		Enddo
		oFT:FT_FUse()
		If len(&("aArq"+aObrig[i][3])) == 0
			cRet += " - Não foi possivel efetuar a leitura das linhas do arquivo."+CHR(13)+CHR(10)
			lRet := .F.
		EndIf  
	Else
		cRet += " - Não foi possivel a Abertura exclusiva do arquivo."+CHR(13)+CHR(10)
		lRet := .F.
	EndIf
Next i

If !lRet
	EECVIEW(cRet)
	CleanInt(.T.)
	Return lRet
EndIf

//Carregar para Browse ---------------------------------------------
cRet += "Carregando Dados -------------"+CHR(13)+CHR(10)
For i:=1 to len(aObrig)
	cRet += "Arquivo '"+aObrig[i][2]+"':"+CHR(13)+CHR(10)
	//Atualização do Browse
	Do Case
		Case aObrig[i][3] == "SL1"
			For j:=1 to len(&("aArq"+aObrig[i][3]))
				aAux := {}
				For k:=1 to len(oCupom:AHEADER)
					If (nPos:=aScan(&("aCpo"+aObrig[i][3]),;
										{|x| ALLTRIM(x[1]) == ALLTRIM(STRTRAN(oCupom:AHEADER[k][2],"WRK",RIGHT(aObrig[i][3],2)))})) <> 0
						aAdd(aAux,ConvertDado(&("aArq"+aObrig[i][3])[j][nPos],oCupom:AHEADER[k]))
					Else
						aAdd(aAux,ConvertDado("",oCupom:AHEADER[k]))
					EndIf
				Next k
				aAdd(aAux,.F.)
				aAdd(oCupom:ACOLS,aAux)		
			Next j

		Case aObrig[i][3] == "SL2"
			For j:=1 to len(&("aArq"+aObrig[i][3]))
				aAux := {}
				For k:=1 to len(oItem:AHEADER)
					If (nPos:=aScan(&("aCpo"+aObrig[i][3]),;
										{|x| ALLTRIM(x[1]) == ALLTRIM(STRTRAN(oItem:AHEADER[k][2],"WRK",RIGHT(aObrig[i][3],2)))})) <> 0
						aAdd(aAux,ConvertDado(&("aArq"+aObrig[i][3])[j][nPos],oItem:AHEADER[k]))
					Else
						aAdd(aAux,ConvertDado("",oItem:AHEADER[k]))
					EndIf
				Next k
				aAdd(aAux,.F.)
				aAdd(oItem:ACOLS,aAux)		
			Next j
			
		Case aObrig[i][3] == "SL4"
			For j:=1 to len(&("aArq"+aObrig[i][3]))
				aAux := {}
				For k:=1 to len(oPagam:AHEADER)
					If (nPos:=aScan(&("aCpo"+aObrig[i][3]),;
										{|x| ALLTRIM(x[1]) == ALLTRIM(STRTRAN(oPagam:AHEADER[k][2],"WRK",RIGHT(aObrig[i][3],2)))})) <> 0
						aAdd(aAux,ConvertDado(&("aArq"+aObrig[i][3])[j][nPos],oPagam:AHEADER[k]))
					Else
						aAdd(aAux,ConvertDado("",oItem:AHEADER[k]))
					EndIf
				Next k
				aAdd(aAux,.F.)
				aAdd(oPagam:ACOLS,aAux)		
			Next j
			
		Case aObrig[i][3] == "SFI"
			For j:=1 to len(&("aArq"+aObrig[i][3]))
				aAux := {}
				For k:=1 to len(oRed:AHEADER)
					If (nPos:=aScan(&("aCpo"+aObrig[i][3]),;
										{|x| ALLTRIM(x[1]) == ALLTRIM(STRTRAN(oRed:AHEADER[k][2],"WRK",RIGHT(aObrig[i][3],2)))})) <> 0
						aAdd(aAux,ConvertDado(&("aArq"+aObrig[i][3])[j][nPos],oRed:AHEADER[k]))
					Else
						aAdd(aAux,ConvertDado("",oRed:AHEADER[k]))
					EndIf
				Next k
				aAdd(aAux,.F.)
				aAdd(oRed:ACOLS,aAux)		
			Next j
	EndCase
Next i

If !lRet
	EECVIEW(cRet)
	CleanInt(.T.)
	Return lRet
EndIf

//Validação dos Dados ---------------------------------------------
ValidDados(aObrig)

//Atualização do Browse com os arquivos Validados
AtuBrowse()

//Atualização dos arrays que possuem as informações da integração
AtuArqs()

Return .T.

/*
Funcao      : ConvertDado
Parametros  : XDado = Dado
				xdefine = Tipo de retorno necessato
Retorno     : Nenhum
Objetivos   : Função para tratamento do conteudo;
Autor       : Jean Victor Rocha.
Data/Hora   : 08/05/2014
*/
*----------------------------------------*
Static Function ConvertDado(xDado,xdefine)
*----------------------------------------*
Local xRet
Default xDado := ""
Default xdefine := {}

If ValType(xDefine) == "C"
	If Len(xDefine) == 1
		xDefine := {"","","","","","","",xdefine}
	Else
		SX3->(DbSetOrder(2))
		If SX3->(DbSeek(xdefine))
			xDefine := {TRIM(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"","",SX3->X3_TIPO}
		EndIf
	EndIf
EndIf

If Len(xDefine) <> 0
	Do Case
		Case xDefine[8] == "C"
			xRet := Transform(xDado,"@!")
		Case xDefine[8] == "N"
			If ValType(xDado) == "N"
				xRet := xDado
			Else
				If AT(",",xDado) <> 0
					xRet := VAL(STRTRAN(xDado,",","."))
				Else
					xRet := VAL(xDado)
				EndIf
			EndIf
		Case xDefine[8] == "D"
			If AT("/",xDado) <> 0
				xRet := CTOD(xDado)
			Else
				xRet := STOD(xDado)
			EndIf
	EndCase
EndIf

Return xRet

/*
Funcao      : ValidDados
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para Validar os Cupons
Autor       : Jean Victor Rocha.
Data/Hora   : 08/05/2014
*/
*--------------------------------*
Static Function ValidDados(aObrig)
*--------------------------------*
Local i
Local nPos := 0
Local nPosVal := 0
Local aVldProd:={}

nL1_FILIAL	:= aScan(aCpoSL1,{|x| ALLTRIM(x[1]) == "L1_FILIAL"})
nL1_DOC		:= aScan(aCpoSL1,{|x| ALLTRIM(x[1]) == "L1_DOC"})
nL1_SERIE	:= aScan(aCpoSL1,{|x| ALLTRIM(x[1]) == "L1_SERIE"})
nL1_PDV		:= aScan(aCpoSL1,{|x| ALLTRIM(x[1]) == "L1_PDV"})
nL2_FILIAL	:= aScan(aCpoSL2,{|x| ALLTRIM(x[1]) == "L2_FILIAL"})
nL2_DOC		:= aScan(aCpoSL2,{|x| ALLTRIM(x[1]) == "L2_DOC"})
nL2_SERIE	:= aScan(aCpoSL2,{|x| ALLTRIM(x[1]) == "L2_SERIE"})
nL2_VALIPI	:= aScan(aCpoSL2,{|x| ALLTRIM(x[1]) == "L2_VALIPI"})
nL4_FILIAL	:= aScan(aCpoSL4,{|x| ALLTRIM(x[1]) == "L4_FILIAL"})
nL4_DOC		:= aScan(aCpoSL4,{|x| ALLTRIM(x[1]) == "L4_P_DOC"})
nL4_SERIE	:= aScan(aCpoSL4,{|x| ALLTRIM(x[1]) == "L4_P_SERIE"})
nFI_FILIAL	:= aScan(aCpoSFI,{|x| ALLTRIM(x[1]) == "FI_FILIAL"})
nFI_SERPDV	:= aScan(aCpoSFI,{|x| ALLTRIM(x[1]) == "FI_SERPDV"})
nFI_DTMOVTO	:= aScan(aCpoSFI,{|x| ALLTRIM(x[1]) == "FI_DTMOVTO"})

//Cupons------------------------------
If aScan(aObrig,{|x| x[3] == "SL1"}) <> 0
	//Valida se as integrações de Itens foi Selecionada
	If aScan(aObrig,{|x| x[3] == "SL2"}) == 0
		For i:=1 to len(aArqSL1)
			aAdd(aLogInt,{aArqSL1[i][nL1_FILIAL],aArqSL1[i][nL1_DOC]+aArqSL1[i][nL1_SERIE],;
																"SL1 - Falta da integracao de Itens do Cupom!"})
		Next i	
	Else
		For i:=1 to len(aArqSL1)    
		
			//Valida se o Tipo SUTUA esta com 'RX'
			If (nPosVal := aScan(aCpoSL1,{|x| ALLTRIM(x[1]) == "L1_SITUA"}) ) <> 0 .And.;
				(aArqSL1[i][nPosVal] <> 'RX' .AND. aArqSL1[i][nPosVal] <> 'TR')
				If aArqSL1[i][nPosVal] == 'CA'
					//Validação de Cancelamento de Cupons.
					//If !ExisteCupom("SL1",aArqSL1[i][nL1_FILIAL],aArqSL1[i][nL1_DOC],aArqSL1[i][nL1_SERIE])
					//	aAdd(aLogInt,{aArqSL1[i][nL1_FILIAL],aArqSL1[i][nL1_DOC]+aArqSL1[i][nL1_SERIE]+"/CA",;
					//												"SL1 - Cupom nao existe no sistema para cancelamento!"})
					//EndIf
				Else				
					aAdd(aLogInt,{aArqSL1[i][nL1_FILIAL],aArqSL1[i][nL1_DOC]+aArqSL1[i][nL1_SERIE],;
																	"SL1 - com tipo de SITUA diferente do permitido ('RX','TR','CA')!"})
				EndIF
			
			//Validar se Cupons ja existe no sistema
			ElseIf ExisteCupom("SL1",aArqSL1[i][nL1_FILIAL],aArqSL1[i][nL1_DOC],aArqSL1[i][nL1_SERIE],aArqSL1[i][nL1_PDV])
				aAdd(aLogInt,{aArqSL1[i][nL1_FILIAL],aArqSL1[i][nL1_DOC]+aArqSL1[i][nL1_SERIE],;
																	"SL1 - Cupom ja existe no sistema!"})
			ElseIf ExisteCupom("SF3",aArqSL1[i][nL1_FILIAL],aArqSL1[i][nL1_DOC],aArqSL1[i][nL1_SERIE],aArqSL1[i][nL1_PDV])
				aAdd(aLogInt,{aArqSL1[i][nL1_FILIAL],aArqSL1[i][nL1_DOC]+aArqSL1[i][nL1_SERIE],;
																	"SL1 - Cupom ja integrado e cancelado no sistema!"})
			Else                        
				/*If (nPosVal := aScan(aCpoSL1,{|x| ALLTRIM(x[1]) == "L1_COMIS"}) ) <> 0
					SX3->(DbSetOrder(2))
					If SX3->(DbSeek("L1_COMIS"))
						If LEN(ALLTRIM(aArqSL1[i][nPosVal])) > SX3->X3_TAMANHO
						eLSE
							aAdd(aLogInt,{aArqSL1[i][nL1_FILIAL],aArqSL1[i][nL1_DOC]+aArqSL1[i][nL1_SERIE],;
																	"SL1 - Campo comisssao com valor invalido, maximo permitido - 99,99 (%)!"})
						EndIf
					EndIf
				EndIf*/
			
				//Validar se Cupons possui itens
				If (nPos := aScan(aArqSL2, {|x|  x[nL2_FILIAL] == aArqSL1[i][nL1_FILIAL] .and.;
																		x[nL2_DOC] == aArqSL1[i][nL1_DOC] .and.;
																		x[nL2_SERIE] == aArqSL1[i][nL1_SERIE]}) ) <> 0
					//Validar se total de Itens confere com o Cupom
					nValDesc  := 0
					nValItens := 0
					nDescItens:= 0
					nTotDev   := 0
					nDescIten2:= 0//L2_DESCPRO
					nVrUnit	  := 0//L2_VRUNIT
					nValBrut  := 0//L1_VALBRUT
					nValAtu	  := 0
					lDescont  := .F.
					For j:=1 to Len(aArqSL2)
						If aArqSL2[j][nL2_FILIAL] == aArqSL1[i][nL1_FILIAL]	.and.;
							aArqSL2[j][nL2_DOC] == aArqSL1[i][nL1_DOC]		.and.;
							aArqSL2[j][nL2_SERIE] == aArqSL1[i][nL1_SERIE]
							
							If (nPosVal := aScan(aCpoSL2,{|x| ALLTRIM(x[1]) == "L2_VLRITEM"}) ) <> 0
								nValItens += ConvertDado(aArqSL2[j][nPosVal],"N")
								nValAtu	  += ConvertDado(aArqSL2[j][nPosVal],"N")
							EndIf
							If (nPosVal := aScan(aCpoSL2,{|x| ALLTRIM(x[1]) == "L2_VRUNIT"}) ) <> 0
								nVrUnit += ConvertDado(aArqSL2[j][nPosVal],"N")
							EndIf
							//RRP - Carregar o valor do desconto no campo L2_VALDESC para o L2_DESCPRO
							If (nPosVal := aScan(aCpoSL2,{|x| ALLTRIM(x[1]) == "L2_VALDESC"}) ) <> 0
								If ConvertDado(aArqSL2[j][nPosVal],"N") <> 0
									nDescItens:= ABS(ConvertDado(aArqSL2[j][nPosVal],"N"))//Transformar valor positivo
									aArqSL2[j][nPosVal]:= 0
									If (nPosVal := aScan(aCpoSL2,{|x| ALLTRIM(x[1]) == "L2_DESCPRO"}) ) <> 0
										aArqSL2[j][nPosVal]:= nDescItens 
									EndIf
								EndIf
							EndIf
							If (nPosVal := aScan(aCpoSL2,{|x| ALLTRIM(x[1]) == "L2_DESCPRO"}) ) <> 0
								nDescIten2 += ConvertDado(aArqSL2[j][nPosVal],"N")
								If nDescIten2 <> 0
									lDescont:=.T.
								EndIf
							EndIf
						EndIf
					Next j  
					
					//RRP - Ajuste nos campos do SL1 de valor
					//Verifica o campo de devolução.
				   	If (nPosVal := aScan(aCpoSL1,{|x| ALLTRIM(x[1]) == "L1_P_TOTDE"}) ) <> 0
						nTotDev := ConvertDado(aArqSL1[i][nPosVal],"N")
					EndIf
					If (nPosVal := aScan(aCpoSL1,{|x| ALLTRIM(x[1]) == "L1_DESCONT"}) ) <> 0
						aArqSL1[i][nPosVal] := ABS(ConvertDado(aArqSL1[i][nPosVal],"N"))//Transformar valor positivo
						nValDesc := ABS(ConvertDado(aArqSL1[i][nPosVal],"N"))//Transformar valor positivo
					EndIf
					If (nPosVal := aScan(aCpoSL1,{|x| ALLTRIM(x[1]) == "L1_VALBRUT"}) ) <> 0
						aArqSL1[i][nPosVal] := ConvertDado(aArqSL1[i][nPosVal],"N")+nValDesc+nTotDev//Ajusta o Valor bruto tem que somar o desconto
						nValBrut := aArqSL1[i][nPosVal] 
					EndIf
					If (nPosVal := aScan(aCpoSL1,{|x| ALLTRIM(x[1]) == "L1_VLRLIQ"}) ) <> 0
						aArqSL1[i][nPosVal] := ConvertDado(aArqSL1[i][nPosVal],"N")+nTotDev//Ajusta o Valor de acordo com o que foi devolvido.
					EndIf
					If (nPosVal := aScan(aCpoSL1,{|x| ALLTRIM(x[1]) == "L1_VLRTOT"}) ) <> 0
						aArqSL1[i][nPosVal] := ConvertDado(aArqSL1[i][nPosVal],"N")+nTotDev+nValDesc//Ajusta o Valor de acordo com o que foi devolvido.
					EndIf
					//RRP - 10/03/2016 - Truncando o valor do campo L1_COMIS.
					If (nPosVal := aScan(aCpoSL1,{|x| ALLTRIM(x[1]) == "L1_COMIS"}) ) <> 0
						If Len(ALLTRIM(aArqSL1[i][nPosVal])) > TamSX3("L1_COMIS")[1]
							aArqSL1[i][nPosVal] := NoRound(ConvertDado(aArqSL1[i][nPosVal],"N"),2)
						EndIf
					EndIf
					
					/*If (nPosVal := aScan(aCpoSL1,{|x| ALLTRIM(x[1]) == "L1_DESCONT"}) ) <> 0
						nValDesc := ConvertDado(aArqSL1[i][nPosVal],"N")
						If nDescItens <> 0
							If ConvertDado(aArqSL1[i][nPosVal],"N") <> nDescItens
								aAdd(aLogInt,{aArqSL1[i][nL1_FILIAL],aArqSL1[i][nL1_DOC]+aArqSL1[i][nL1_SERIE],;
																	"SL1 - Desconto de Cupom nao confere com a somatoria dos Descontos de Itens!"})
							EndIf
						EndIf
					EndIf*/
					//--------------------------------------TRATAMENTO NOVO----------------------------------
					//RRP - Ajustando valores do SL2 nos campos L2_VRUNIT,L2_VLRITEM e L2_DESCPRO caso o cupom tenha desconto
					If nValDesc <> 0
						nValItens:= 0//Calcular o valor do item novamente
						For nR:=1 to Len(aArqSL2)
							If aArqSL2[nR][nL2_FILIAL] == aArqSL1[i][nL1_FILIAL]	.and.;
								aArqSL2[nR][nL2_DOC] == aArqSL1[i][nL1_DOC]		.and.;
								aArqSL2[nR][nL2_SERIE] == aArqSL1[i][nL1_SERIE]
								//Verifica desconto preenchido no SL2
								nDescLiq:= 0
								nPrecIte:= 0
								If lDescont
									If (nPosVal := aScan(aCpoSL2,{|x| ALLTRIM(x[1]) == "L2_DESCPRO"}) ) <> 0
										nDescLiq:= ABS(ConvertDado(aArqSL2[nR][nPosVal],"N"))
									EndIf
									//Verificar se o campo L2_VLRITEM está com valor bruto ou líquido
									If nValAtu == nValBrut
										If (nPosVal := aScan(aCpoSL2,{|x| ALLTRIM(x[1]) == "L2_VLRITEM"}) ) <> 0
											aArqSL2[nR][nPosVal] := ConvertDado(aArqSL2[nR][nPosVal],"N")-nDescLiq
											nValItens+= ConvertDado(aArqSL2[nR][nPosVal],"N")
										EndIf
									EndIf
									//Verificar se o campo L2_VRUNIT está com valor bruto ou líquido 
									If nVrUnit == nValBrut
										If (nPosVal := aScan(aCpoSL2,{|x| ALLTRIM(x[1]) == "L2_VRUNIT"}) ) <> 0
									   		aArqSL2[nR][nPosVal] := ConvertDado(aArqSL2[nR][nPosVal],"N")-nDescLiq
										EndIf
									EndIf
								//Preencher desconto rateado no SL2
								Else
									//Achar porcentagem do valor do item representado no total
									If (nPosVal := aScan(aCpoSL2,{|x| ALLTRIM(x[1]) == "L2_VLRITEM"}) ) <> 0
										nPrecIte := ConvertDado(aArqSL2[nR][nPosVal],"N")/nValBrut*100
									EndIf
									
									If (nPosVal := aScan(aCpoSL2,{|x| ALLTRIM(x[1]) == "L2_DESCPRO"}) ) <> 0
										//Cálculo do campo desconto DescontoTotal*PercentualItem/100
										aArqSL2[nR][nPosVal] := nValDesc*nPrecIte/100
										nDescLiq:= ConvertDado(aArqSL2[nR][nPosVal],"N")
										nDescIten2+= ConvertDado(aArqSL2[nR][nPosVal],"N")
									EndIf
									//Verificar se o campo L2_VLRITEM está com valor bruto ou líquido
									If nValAtu == nValBrut
										If (nPosVal := aScan(aCpoSL2,{|x| ALLTRIM(x[1]) == "L2_VLRITEM"}) ) <> 0
											aArqSL2[nR][nPosVal] := ConvertDado(aArqSL2[nR][nPosVal],"N")-nDescLiq
											nValItens+= ConvertDado(aArqSL2[nR][nPosVal],"N")
										EndIf
									EndIf
									//Verificar se o campo L2_VRUNIT está com valor bruto ou líquido 
									If nVrUnit == nValBrut
										If (nPosVal := aScan(aCpoSL2,{|x| ALLTRIM(x[1]) == "L2_VRUNIT"}) ) <> 0
									   		aArqSL2[nR][nPosVal] := ConvertDado(aArqSL2[nR][nPosVal],"N")-nDescLiq
										EndIf
									EndIf
								EndIf
							EndIf
						Next nR
					EndIf
					//Verificando se a somatória do L2_DESCPRO está igual ao L1_DESCONT
					If (nPosVal := aScan(aCpoSL1,{|x| ALLTRIM(x[1]) == "L1_DESCONT"}) ) <> 0
						If nDescIten2 <> 0
							If ConvertDado(aArqSL1[i][nPosVal],"N") <> nDescIten2
								aAdd(aLogInt,{aArqSL1[i][nL1_FILIAL],aArqSL1[i][nL1_DOC]+aArqSL1[i][nL1_SERIE],;
																	"SL1 - Desconto de Cupom (L1_DESCONT)nao confere com a somatoria dos Descontos de Itens (L2_DESCPRO)!"})
							EndIf
						EndIf
					EndIf					
					//--------------------------------------FINAL TRATAMENTO NOVO----------------------------										
					If (nPosVal := aScan(aCpoSL1,{|x| ALLTRIM(x[1]) == "L1_COMIS"}) ) <> 0
						If Len(ALLTRIM(aArqSL1[i][nPosVal])) > TamSX3("L1_COMIS")[1]
							aAdd(aLogInt,{aArqSL1[i][nL1_FILIAL],aArqSL1[i][nL1_DOC]+aArqSL1[i][nL1_SERIE],;
																"SL1 - Campo comisssao com valor invalido, maximo permitido - 99,99 (%)!"})
						EndIf
					EndIf					
					If (nPosVal := aScan(aCpoSL1,{|x| ALLTRIM(x[1]) == "L1_VALMERC"}) ) <> 0
						//RRP - 11/01/2016 - Ajuste na validação do desconto no SL2 o valor deve estar sem desconto
						If ConvertDado(aArqSL1[i][nPosVal],"N")-nValDesc <> nValItens
							aAdd(aLogInt,{aArqSL1[i][nL1_FILIAL],aArqSL1[i][nL1_DOC]+aArqSL1[i][nL1_SERIE],;
																"SL1 - Valor Mercadoria do Cupom nao confere com o Valor dos Itens!"})
						EndIf
					EndIf
					If (nPosVal := aScan(aCpoSL1,{|x| ALLTRIM(x[1]) == "L1_VLRLIQ"}) ) <> 0
						//RRP - 11/01/2016 - Ajuste na validação do desconto no SL2 o valor deve estar sem desconto
						If ConvertDado(aArqSL1[i][nPosVal],"N") <> nValItens
							aAdd(aLogInt,{aArqSL1[i][nL1_FILIAL],aArqSL1[i][nL1_DOC]+aArqSL1[i][nL1_SERIE],;
																"SL1 - Valor Liquido(+Desconto)(+Devolucoes) do Cupom nao confere com o Valor dos Itens!"})
						EndIf
					EndIf
					If (nPosVal := aScan(aCpoSL1,{|x| ALLTRIM(x[1]) == "L1_VALBRUT"}) ) <> 0
						//RRP - 11/01/2016 - Ajuste na validação do desconto no SL2 o valor deve estar sem desconto
						If ConvertDado(aArqSL1[i][nPosVal],"N")-nValDesc <> nValItens
							aAdd(aLogInt,{aArqSL1[i][nL1_FILIAL],aArqSL1[i][nL1_DOC]+aArqSL1[i][nL1_SERIE],;
																"SL1 - Valor Bruto(-Desconto) do Cupom nao confere com o Valor dos Itens!"})
						EndIf
					EndIf
					If (nPosVal := aScan(aCpoSL1,{|x| ALLTRIM(x[1]) == "L1_VLRTOT"}) ) <> 0
						//RRP - 11/01/2016 - Ajuste na validação do desconto no SL2 o valor deve estar sem desconto
						If ConvertDado(aArqSL1[i][nPosVal],"N")-nValDesc <> nValItens
							aAdd(aLogInt,{aArqSL1[i][nL1_FILIAL],aArqSL1[i][nL1_DOC]+aArqSL1[i][nL1_SERIE],;
																"SL1 - Valor Total(-Desconto)(+Devolucoes) do Cupom nao confere com o Valor dos Itens!"})
						EndIf
					EndIf 
				Else
					aAdd(aLogInt,{aArqSL1[i][nL1_FILIAL],aArqSL1[i][nL1_DOC]+aArqSL1[i][nL1_SERIE],;
																"SL1 - Nao encontrado Item para o Cupom!"})
				EndIF
				
				//Validar se os campos obrigatorios não estão vazios.
				For j:=1 to Len(aObrSL1)
					If (nPosVal := aScan(aCpoSL1,{|x| ALLTRIM(x[1]) ==  ALLTRIM(aObrSL1[j])}) ) <> 0 .and.;
						EMPTY(aArqSL1[i][nPosVal])
						aAdd(aLogInt,{aArqSL1[i][nL1_FILIAL],aArqSL1[i][nL1_DOC]+aArqSL1[i][nL1_SERIE],;
														"SL1 - Campo '"+ALLTRIM(aObrSL1[j])+"' com valor em branco!"})
					EndIf
				Next j
			EndIf
		Next i
	EndIf
	//Valida se as integrações de Pagamentos foi Selecionada
	If aScan(aObrig,{|x| x[3] == "SL4"}) == 0
		For i:=1 to len(aArqSL1)
			aAdd(aLogInt,{aArqSL1[i][nL1_FILIAL],aArqSL1[i][nL1_DOC]+aArqSL1[i][nL1_SERIE],;
																"SL1 - Falta da integracao de Pagamentos do Cupom!"})
		Next i	
	Else
		For i:=1 to len(aArqSL1)
			If (nPosVal := aScan(aCpoSL1,{|x| ALLTRIM(x[1]) == "L1_SITUA"}) ) <> 0 .And.;
				(aArqSL1[i][nPosVal] == 'RX' .or. aArqSL1[i][nPosVal] == 'TR')
			
				//Validar se Cupons ja existe no sistema
				If ExisteCupom("SL1",aArqSL1[i][nL1_FILIAL],aArqSL1[i][nL1_DOC],aArqSL1[i][nL1_SERIE],aArqSL1[i][nL1_PDV])
					//aAdd(aLogInt,{aArqSL1[i][nL1_FILIAL],aArqSL1[i][nL1_DOC],"SL1 - Cupom ja existe no sistema!"})
				Else
					//Validar se Cupons possui Pagamentos
					If (nPos := aScan(aArqSL4, {|x| x[nL4_FILIAL] == aArqSL1[i][nL1_FILIAL] .and.;
														x[nL4_DOC] == aArqSL1[i][nL1_DOC]  .and.;
														x[nL4_SERIE] == aArqSL1[i][nL1_SERIE] }) ) <> 0
						//Validar se total de Pagamentos confere com o Cupom
						nValPagam := 0
						nQtdeParc := 0
						nTotDev   := 0
						nLastPos  := 0
						//Verifica o campo de devolução.
					   	If (nPosVal := aScan(aCpoSL1,{|x| ALLTRIM(x[1]) == "L1_P_TOTDE"}) ) <> 0
							nTotDev := ConvertDado(aArqSL1[i][nPosVal],"N")
						EndIf	

						For j:=1 to Len(aArqSL4)
							If aArqSL4[j][nL4_FILIAL] == aArqSL1[i][nL1_FILIAL] .and.;
								aArqSL4[j][nL4_DOC] == aArqSL1[i][nL1_DOC] .and.;
								aArqSL4[j][nL4_SERIE] == aArqSL1[i][nL1_SERIE]
								If (nPosVal := aScan(aCpoSL4,{|x| ALLTRIM(x[1]) == "L4_VALOR"}) ) <> 0
									nValPagam += ConvertDado(aArqSL4[j][nPosVal],"N")
									nLastPos := j
									nQtdeParc++
								EndIf 
							EndIf
						Next j
		                //RRP - 10/03/2016 - Ajuste para SL4 com valor zerado.
						//Coloca o Valor devolvido na ultima Parcela, caso tenha mais de 1 parcela.
						If nTotDev <> 0 .and. nPosVal <> 0 .and. nLastPos <> 0 //.and. aArqSL1[i][aScan(aCpoSL1,{|x| ALLTRIM(x[1]) == "L1_SITUA"})] <> 'TR'
							If nValPagam == 0
								aArqSL4[nLastPos][nPosVal] := ConvertDado(aArqSL4[nLastPos][nPosVal],"N")+nTotDev//Ajusta o Valor de acordo com o que foi devolvido.
								nValPagam:=	aArqSL4[nLastPos][nPosVal]
							ElseIf aArqSL1[i][aScan(aCpoSL1,{|x| ALLTRIM(x[1]) == "L1_SITUA"})] <> 'TR' 
								aArqSL4[nLastPos][nPosVal] := ConvertDado(aArqSL4[nLastPos][nPosVal],"N")+nTotDev//Ajusta o Valor de acordo com o que foi devolvido.
								nValPagam += nTotDev
							EndIf
						EndIf
						
						
						//RRP - 12/01/2015 - O desconto está sendo tratado no SL1, portanto no SL4 só tem o líquido.
						If (nPosVal := aScan(aCpoSL1,{|x| ALLTRIM(x[1]) == "L1_VLRLIQ"}) ) <> 0
							If ConvertDado(aArqSL1[i][nPosVal],"N") <> nValPagam
								aAdd(aLogInt,{aArqSL1[i][nL1_FILIAL],aArqSL1[i][nL1_DOC]+aArqSL1[i][nL1_SERIE],;
																"SL1 - Valor do Cupom (Vlr. Bruto) nao confere com o Valor da somatoria dos Pagamentos!"})
							EndIf
						EndIf
						If (nPosVal := aScan(aCpoSL1,{|x| ALLTRIM(x[1]) == "L1_PARCELA"}) ) <> 0
							If ConvertDado(aArqSL1[i][nPosVal],"N") <> nQtdeParc
								aAdd(aLogInt,{aArqSL1[i][nL1_FILIAL],aArqSL1[i][nL1_DOC]+aArqSL1[i][nL1_SERIE],;
																"SL1 - Quantidade de Parcelas informada nao confere com arquivo de Pagamentos!"})
							EndIf
						EndIf
						
					Else
						aAdd(aLogInt,{aArqSL1[i][nL1_FILIAL],aArqSL1[i][nL1_DOC]+aArqSL1[i][nL1_SERIE],;
																"SL1 - Nao encontrado Pagamentos para o Cupom!"})
					EndIf
				EndIf
			EndIf
		Next i
	EndIf
	
	//Validação dos Cancelamentos
	For i:=1 to len(aArqSL1)
		If (nPosVal := aScan(aCpoSL1,{|x| ALLTRIM(x[1]) == "L1_SITUA"}) ) <> 0 .And.;
			aArqSL1[i][nPosVal] == 'CA'
			//Validação de Cancelamento de Cupons.
			If ExisteCupom("SL1",aArqSL1[i][nL1_FILIAL],aArqSL1[i][nL1_DOC],aArqSL1[i][nL1_SERIE],aArqSL1[i][nL1_PDV])
				//Validar se o Cupom no sistema ja não esta cancelado
				If CupomCancel(aArqSL1[i][nL1_FILIAL],aArqSL1[i][nL1_DOC],aArqSL1[i][nL1_SERIE])
					aAdd(aLogInt,{aArqSL1[i][nL1_FILIAL],aArqSL1[i][nL1_DOC]+aArqSL1[i][nL1_SERIE]+"/CA",;
													"SL1 - Cupom a ser cancelado ja foi cancelado/deletado no sistema!"})
				ElseIf ExisteCancel(aArqSL1[i][nL1_FILIAL],aArqSL1[i][nL1_DOC],aArqSL1[i][nL1_SERIE])
					//Validar se ja não existe um cancelamento a ser processado no sistema.
					aAdd(aLogInt,{aArqSL1[i][nL1_FILIAL],aArqSL1[i][nL1_DOC]+aArqSL1[i][nL1_SERIE]+"/CA",;
													"SL1 - Cupom a ser cancelado ja foi integrado e aguarda processamento!"})			
				EndIf
			Else
				If (nPosA := aScan(oCupom:AHEADER,{|x|  ALLTRIM(x[2]) == "WRK_FILIAL"})   ) <> 0 .and.;
					(nPosB := aScan(oCupom:AHEADER,{|x|  ALLTRIM(x[2]) == "WRK_DOC"})   ) <> 0 .and.;
					(nPosC := aScan(oCupom:AHEADER,{|x|  ALLTRIM(x[2]) == "WRK_SERIE"})   ) <> 0 .and.;
					(nPosD := aScan(oCupom:AHEADER,{|x|  ALLTRIM(x[2]) == "WRK_SITUA"})   ) <> 0

					If (nPosE := aScan(aLogInt,{|x| ALLTRIM(x[1]) == oCupom:ACOLS[i][nPosA] .and.;
												ALLTRIM(x[2]) == oCupom:ACOLS[i][nPosB]+oCupom:ACOLS[i][nPosC] })  ) <> 0
							aAdd(aLogInt,{aArqSL1[i][nL1_FILIAL],aArqSL1[i][nL1_DOC]+aArqSL1[i][nL1_SERIE]+"/CA",;
													"SL1 - Cupom a ser cancelado esta rejeitado na integracao!"})
					ElseIf (nPosE := aScan(oCupom:ACOLS,{|x| x[nPosA] == oCupom:ACOLS[i][nPosA] .and.;
												x[nPosB]+x[nPosC] == oCupom:ACOLS[i][nPosB]+oCupom:ACOLS[i][nPosC] .and.;
												x[nPosD] <> 'CA' })  ) == 0
							aAdd(aLogInt,{aArqSL1[i][nL1_FILIAL],aArqSL1[i][nL1_DOC]+aArqSL1[i][nL1_SERIE]+"/CA",;
													"SL1 - Cupom nao existe no sistema/Arquivo para cancelamento!"})
						
					EndIf
				Else
					aAdd(aLogInt,{aArqSL1[i][nL1_FILIAL],aArqSL1[i][nL1_DOC]+aArqSL1[i][nL1_SERIE]+"/CA",;
														"SL1 - Cupom nao existe no sistema/Arquivo para cancelamento!"})
				EndIf
			EndIf
		EndIf
	Next i
EndIf

//Itens---------------------------------
If aScan(aObrig,{|x| x[3] == "SL2"}) <> 0
	//Valida se as integrações de Cupons foi selecionada
	If aScan(aObrig,{|x| x[3] == "SL1"}) == 0
		For i:=1 to len(aArqSL2)
			aAdd(aLogInt,{aArqSL2[i][nL2_FILIAL],aArqSL2[i][nL2_DOC]+aArqSL2[i][nL2_SERIE],;
															"SL2 - Falta da integracao de Cupons!"})
		Next i
	Else
		//Valida se o Item possui Cupons	
		For i:=1 to len(aArqSL2)
			//Validar se Cupons ja existe no sistema
			If (nPos := aScan(aArqSL1, {|x|  x[nL1_FILIAL] == aArqSL2[i][nL2_FILIAL] .and.;
												 x[nL1_DOC] == aArqSL2[i][nL2_DOC] .and.;
												 x[nL1_SERIE] == aArqSL2[i][nL2_SERIE] }) ) == 0
				aAdd(aLogInt,{aArqSL2[i][nL2_FILIAL],aArqSL2[i][nL2_DOC]+aArqSL2[i][nL2_SERIE],;
															"SL2 - Nao encontrado Cupom para o Item!"})
			EndIf
            
			//RRP - 16/02/2016 - Ajuste para inclusão automática de produtos
			If (nPosVal := aScan(aCpoSL2,{|x| ALLTRIM(x[1]) == "L2_PRODUTO"}) ) <> 0
				
				aVldProd:= ViewProd(aArqSL2[i][nL2_FILIAL],aArqSL2[i][nPosVal])
				//Valida Se existe o Produto.
				If Len(aVldProd) == 0 
					//RRP - 29/02/2016 - Inclusão de produto automático.
					If !ExecAutB1(aArqSL2[i],aCpoSL2)
						aAdd(aLogInt,{aArqSL2[i][nL2_FILIAL],aArqSL2[i][nL2_DOC]+aArqSL2[i][nL2_SERIE],;
											"SL2 - Nao encontrado o produto e nao foi incluso pela rotina Automatica '"+ALLTRIM(aArqSL2[i][nPosVal])+"'!"})
					EndIf
				//Valida Se o Produto possui TES.
				ElseIf EMPTY(GetTes(aArqSL2[i][nL2_FILIAL],aArqSL2[i][nPosVal]))
					aAdd(aLogInt,{aArqSL2[i][nL2_FILIAL],aArqSL2[i][nL2_DOC]+aArqSL2[i][nL2_SERIE],;
										"SL2 - Nao encontrado a TES para o produto '"+ALLTRIM(aArqSL2[i][nPosVal])+"'!"})
				//Valida Se o Produto possui IPI - AOA Anderson Arrais 31/07/2015
				ElseIf aVldProd[2] <> 0 .And. Val(aArqSL2[i][nL2_VALIPI]) == 0
					aAdd(aLogInt,{aArqSL2[i][nL2_FILIAL],aArqSL2[i][nL2_DOC]+aArqSL2[i][nL2_SERIE],;
										"SL2 - Produto sem IPI com aliquota no cadastro '"+ALLTRIM(aArqSL2[i][nPosVal])+"'!"})
				EndIf			
			Else
				aAdd(aLogInt,{aArqSL2[i][nL2_FILIAL],aArqSL2[i][nL2_DOC]+aArqSL2[i][nL2_SERIE],;
															"SL2 - Campo de produto nao encontrado!"})
			EndIf

			If (nPosVal := aScan(aCpoSL2,{|x| ALLTRIM(x[1]) == "L2_QUANT"}) ) <> 0
				//Valida Se o Produto possui quantidade.
				If VAL(aArqSL2[i][nPosVal]) <= 0
					aAdd(aLogInt,{aArqSL2[i][nL2_FILIAL],aArqSL2[i][nL2_DOC]+aArqSL2[i][nL2_SERIE],;
										"SL2 - Quantidade zerada paraa o produto!"})
				EndIf			
			EndIf
			
			//Validar se os campos obrigatorios não estão vazios.
			For j:=1 to Len(aObrSL2)
				If (nPosVal := aScan(aCpoSL2,{|x| ALLTRIM(x[1]) == ALLTRIM(aObrSL2[j]) }) ) <> 0 .and.;
					EMPTY(aArqSL2[i][nPosVal])
					aAdd(aLogInt,{aArqSL2[i][nL2_FILIAL],aArqSL2[i][nL2_DOC]+aArqSL2[i][nL2_SERIE],;
															"SL2 - Campo '"+ALLTRIM(aObrSL2[j])+"' com valor em branco!"})
				EndIf
			Next j
		Next i
	EndIf
	//Valida se as integrações de Pagamentos foi selecionada
	If aScan(aObrig,{|x| x[3] == "SL4"}) == 0
		For i:=1 to len(aArqSL2)
			aAdd(aLogInt,{aArqSL2[i][nL2_FILIAL],aArqSL2[i][nL2_DOC]+aArqSL2[i][nL2_SERIE],;
															"SL2 - Falta da integracao de Pagamentos do Cupom!"})
		Next i	
	Else
		//Valida se o Item possui Pagamentos
		For i:=1 to len(aArqSL2)
			If (nPos := aScan(aArqSL4, {|x|  x[nL4_FILIAL] == aArqSL2[i][nL2_FILIAL] .and.;
												 x[nL4_DOC] == aArqSL2[i][nL2_DOC] .and.;
												 x[nL4_SERIE] == aArqSL2[i][nL2_SERIE] }) ) == 0
				aAdd(aLogInt,{aArqSL2[i][nL2_FILIAL],aArqSL2[i][nL2_DOC]+aArqSL2[i][nL2_SERIE],;
															"SL2 - Nao encontrado Pagamentos para o Item!"})
			EndIf
		Next i
	EndIf
EndIf

//Pagamentos------------------------------
If aScan(aObrig,{|x| x[3] == "SL4"}) <> 0
	//Valida se as integrações de Cupons e Itens foram Selecionadas
	If aScan(aObrig,{|x| x[3] == "SL1"}) == 0
		For i:=1 to len(aArqSL4)
			aAdd(aLogInt,{aArqSL4[i][nL4_FILIAL],aArqSL4[i][nL4_DOC]+aArqSL4[i][nL4_SERIE],;
															"SL4 - Falta da integracao de Cupons!"})
		Next i	
	Else
		//Valida se o Pagamento possui Cupons
		For i:=1 to len(aArqSL4)
			If (nPos := aScan(aArqSL1, {|x|  x[nL1_FILIAL] == aArqSL4[i][nL4_FILIAL] .and.;
												 x[nL1_DOC] == aArqSL4[i][nL4_DOC] .and.;
												 x[nL1_SERIE] == aArqSL4[i][nL4_SERIE] }) ) == 0
				aAdd(aLogInt,{aArqSL4[i][nL4_FILIAL],aArqSL4[i][nL4_DOC]+aArqSL4[i][nL4_SERIE],;
														"SL4 - Nao encontrado Cupom para o Pagamento!"})
			EndIf
						
			//Validar se os campos obrigatorios não estão vazios.
			For j:=1 to Len(aObrSL4)
				If (nPosVal := aScan(aCpoSL4,{|x| ALLTRIM(x[1]) == ALLTRIM(aObrSL4[j])}) ) <> 0 .and.;
					EMPTY(aArqSL4[i][nPosVal])
					aAdd(aLogInt,{aArqSL4[i][nL4_FILIAL],aArqSL4[i][nL4_DOC]+aArqSL4[i][nL4_SERIE],;
														"SL4 - Campo '"+ALLTRIM(aObrSL4[j])+"' com valor em branco!"})
				EndIf
			Next j
			If (nPosVal := aScan(aCpoSL4,{|x| ALLTRIM(x[1]) == "L4_ADMINIS"}) ) <> 0
				If !EMPTY(aArqSL4[i][nPosVal])
					If !AdmCartao(aArqSL4[i][nPosVal],"EXISTE")
						aAdd(aLogInt,{aArqSL4[i][nL4_FILIAL],aArqSL4[i][nL4_DOC]+aArqSL4[i][nL4_SERIE],;
														"SL4 - Administradora do cartao nao encontrada no sistema: '"+ALLTRIM(aArqSL4[i][nPosVal])+"'!"})
					EndIf
				EndIf
			EndIf
		Next i
	EndIf
	If aScan(aObrig,{|x| x[3] == "SL2"}) == 0
		For i:=1 to len(aArqSL4)
			aAdd(aLogInt,{aArqSL4[i][nL4_FILIAL],aArqSL4[i][nL4_DOC]+aArqSL4[i][nL4_SERIE],;
														"SL4 - Falta da integracao de Itens do Cupom!"})
		Next i
	Else
		//Valida se o Pagamento possui Itens
		For i:=1 to len(aArqSL4)
			If (nPos := aScan(aArqSL2, {|x|  x[nL2_FILIAL] == aArqSL4[i][nL4_FILIAL] .and.;
												 x[nL2_DOC] == aArqSL4[i][nL4_DOC] .and.;
												 x[nL2_SERIE] == aArqSL4[i][nL4_SERIE] }) ) == 0
				aAdd(aLogInt,{aArqSL4[i][nL4_FILIAL],aArqSL4[i][nL4_DOC]+aArqSL4[i][nL4_SERIE],;
														"SL4 - Nao encontrado Itens para o Pagamento!"})
			EndIf
		Next i
	EndIf
EndIf

//Reducao Z------------------------------
If aScan(aObrig,{|x| x[3] == "SFI"}) <> 0
	For i:=1 to len(aArqSFI)
		//Valida se o Tipo SUTUA esta com 'RX'
		If (nPosVal := aScan(aCpoSFI,{|x| ALLTRIM(x[1]) == "FI_SITUA"}) ) <> 0 .And.;
			aArqSFI[i][nPosVal] <> 'RX'
			aAdd(aLogInt,{aArqSFI[i][nFI_FILIAL],ALLTRIM(aArqSFI[i][nFI_DTMOVTO]+"-"+aArqSFI[i][nFI_SERPDV]),;
														"SFI - com tipo de SITUA diferente de 'RX'!"})
		
		//Validar se Reducao ja existe no sistema
		ElseIf ExisteCupom("SFI",aArqSFI[i][nFI_FILIAL],DTOS(ConvertDado(aArqSFI[i][nFI_DTMOVTO],"D")),aArqSFI[i][nFI_SERPDV],"")
			aAdd(aLogInt,{aArqSFI[i][nFI_FILIAL],ALLTRIM(aArqSFI[i][nFI_DTMOVTO]+"-"+aArqSFI[i][nFI_SERPDV]),;
														"SFI - Reducao ja existe no sistema!"})
		Else
			//Validar se os campos obrigatorios não estão vazios.
			For j:=1 to Len(aObrSFI)
				If (nPosVal := aScan(aCpoSFI,{|x| ALLTRIM(x[1]) ==  ALLTRIM(aObrSFI[j])}) ) <> 0 .and.;
					EMPTY(aArqSFI[i][nPosVal])
					aAdd(aLogInt,{aArqSFI[i][nFI_FILIAL],ALLTRIM(aArqSFI[i][nFI_DTMOVTO]+"-"+aArqSFI[i][nFI_SERPDV]),;
															"SFI - Campo '"+ALLTRIM(aArqSFI[j])+"' com valor em branco!"})
				EndIf
			Next j
			If (nPosVal := aScan(aCpoSFI,{|x| ALLTRIM(x[1]) == "FI_VALCON"}) ) <> 0
				If ConvertDado(aArqSFI[i][nPosVal],"N") < 0
					aAdd(aLogInt,{aArqSFI[i][nFI_FILIAL],ALLTRIM(aArqSFI[i][nFI_DTMOVTO]+"-"+aArqSFI[i][nFI_SERPDV]),;
															"SFI - Valor Contabil Invalido!"})
				EndIf
			EndIf
		EndIf
	Next i
EndIf

Return .T.

/*
Funcao      : AdmCartao
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para validar/retornar informações da adiministradora do cartao de credito.
Autor       : Jean Victor Rocha.
Data/Hora   : 25/06/2014
*/
*--------------------------------------------*
Static Function AdmCartao(xVarA,cTipo)
*--------------------------------------------*
Local xRet
Local cQry := ""

Default xVarA := ""

Do Case
	Case cTipo == "EXISTE"
		cQry += " Select COUNT(*) AS COUNT"
		cQry += " From "+RETSQLNAME("SAE")
		cQry += " Where 
		cQry += " AE_DESC like '%"+xVarA+"%'

		If Select("TMP") > 0
			TMP->(DbClosearea())
		Endif 
		dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQry),"TMP",.F.,.T.)
		xRet := TMP->COUNT <> 0
		TMP->(DbClosearea())
	Case cTipo == "CHAVE"
		cQry += " Select AE_COD+' - '+AE_DESC AS CHAVE"
		cQry += " From "+RETSQLNAME("SAE")
		cQry += " Where 
		cQry += " AE_DESC like '%"+xVarA+"%'

		If Select("TMP") > 0
			TMP->(DbClosearea())
		Endif 
		dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQry),"TMP",.F.,.T.)
		xRet := TMP->CHAVE
		TMP->(DbClosearea())
EndCase

Return xRet

/*
Funcao      : ExisteCancel
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para verificar se possui cupom cancelado/deletado no sistema
Autor       : Jean Victor Rocha.
Data/Hora   : 03/06/2014
*/
*--------------------------------------------*
Static Function ExisteCancel(xVarA,xVarB,xVarC)
*--------------------------------------------*
Local lRet := .F.
Local cQry := ""

Default xVarA := ""
Default xVarB := ""
Default xVarC := ""

cQry += " Select COUNT(*) AS COUNT"
cQry += " From "+RETSQLNAME("Z31")
cQry += " Where 
cQry += " Z31_FILIAL	= '"+xVarA+"'
cQry += " AND Z31_DOC	= '"+xVarB+"'
cQry += " AND Z31_SERIE	= '"+xVarC+"'
cQry += " AND Z31_SITUA	= 'CA'

If Select("TMP") > 0
	TMP->(DbClosearea())
Endif 
dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQry),"TMP",.F.,.T.)

lRet := TMP->COUNT <> 0

TMP->(DbClosearea())

Return lRet

/*
Funcao      : CupomCancel
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para verificar se possui cancelamento no sistema aguardando a ser processado.
Autor       : Jean Victor Rocha.
Data/Hora   : 03/06/2014
*/
*---------------------------------------------*
Static Function CupomCancel(xVarA,xVarB,xVarC)
*---------------------------------------------*
Local lRet := .F.
Local cQry := ""

Default xVarA := ""
Default xVarB := ""
Default xVarC := ""

cQry += " Select COUNT(*) AS COUNT"
cQry += " From "+RETSQLNAME("SL1")
cQry += " Where D_E_L_E_T_ = '*'
cQry += " AND L1_FILIAL	= '"+xVarA+"'
cQry += " AND L1_DOC	= '"+xVarB+"'
cQry += " AND L1_SERIE	= '"+xVarC+"'

If Select("TMP") > 0
	TMP->(DbClosearea())
Endif 
dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQry),"TMP",.F.,.T.)

lRet := TMP->COUNT <> 0

TMP->(DbClosearea())

Return lRet

/*
Funcao      : ExisteCupom
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para verificar no sistema se possui Cupom
Autor       : Jean Victor Rocha.
Data/Hora   : 12/05/2014
*/
*---------------------------------------------------*
Static Function ExisteCupom(cAlias,xVarA,xVarB,xVarC,xVarD)
*---------------------------------------------------*
Local lRet := .F.
Local cQry := ""

Default xVarA := ""
Default xVarB := ""
Default xVarC := ""
Default xVarD := ""

cQry += " Select COUNT(*) AS COUNT"
cQry += " From "+RETSQLNAME(cAlias)
cQry += " Where "
cQry += " D_E_L_E_T_ <> '*' AND "             

// TLM 2014/09/10  
If Alltrim(xVarA) == '02' .Or. Alltrim(xVarA) == '2'  // 2-> CODIGO 01 / IG 
	xVarA:='01'
ElseIf Alltrim(xVarA) == '03' .Or. Alltrim(xVarA) == '3'  // 3-> CODIGO 02 / JK
	xVarA:='02'
EndIf   

//TLM 20141125 ajuste tamanho documento 
If  Len(xVarA) <>  9 .And.  cAlias <> "SFI"   
	xVarB:=Replicate("0",9-len(alltrim(xVarB)))+xVarB
EndIf
		                       
Do Case
	Case cAlias == "SL1"
		cQry += " L1_FILIAL		= '"+Alltrim(xVarA)+"'
		cQry += " AND L1_DOC	= '"+Alltrim(xVarB)+"'
		cQry += " AND L1_SERIE	= '"+Alltrim(xVarC)+"'
		cQry += " AND L1_PDV	= '"+Alltrim(xVarD)+"'		
	Case cAlias == "SFI"
		cQry += " FI_FILIAL	 		= '"+xVarA+"'
		cQry += " AND FI_DTMOVTO 	= '"+xVarB+"'
		cQry += " AND FI_SERPDV 	= '"+xVarC+"'      
	Case cAlias == "SF3"
		cQry += " F3_FILIAL	 		= '"+xVarA+"'
		cQry += " AND F3_NFISCAL 	= '"+xVarB+"'
		cQry += " AND F3_SERIE    	= '"+xVarC+"'	
		cQry += " AND F3_PDV    	= '"+xVarD+"'			
		cQry += " AND F3_DTCANC     <> ' ' "
		
EndCase

If Select("TMP") > 0
	TMP->(DbClosearea())
Endif 
dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQry),"TMP",.F.,.T.)

lRet := TMP->COUNT <> 0

TMP->(DbClosearea())

Return lRet                  

/*
Funcao      : AtuBrowse
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para Atualizar o Browse da Integração.
Autor       : Jean Victor Rocha.
Data/Hora   : 12/05/2014
*/
*-------------------------*
Static Function AtuBrowse()
*-------------------------*
Local i
Local nPosA := 0
Local nPosB := 0
Local nPosc := 0
Local nPosD := 0
Local nPosE := 0

If LEN(aLogInt) <> 0
	For i:=1 to len(oCupom:ACOLS)
		If (nPosA := aScan(oCupom:AHEADER,{|x|  ALLTRIM(x[2]) == "WRK_FILIAL"})   ) <> 0 .and.;
			(nPosB := aScan(oCupom:AHEADER,{|x|  ALLTRIM(x[2]) == "WRK_DOC"})   ) <> 0 .and.;
			(nPosC := aScan(oCupom:AHEADER,{|x|  ALLTRIM(x[2]) == "WRK_SERIE"})   ) <> 0 .and.;
			(nPosD := aScan(oCupom:AHEADER,{|x|  ALLTRIM(x[2]) == "WRK_SITUA"})   ) <> 0
			If (nPosE := aScan(aLogInt,{|x| ALLTRIM(x[1]) == oCupom:ACOLS[i][nPosA] .and.;
												ALLTRIM(x[2]) == oCupom:ACOLS[i][nPosB]+oCupom:ACOLS[i][nPosC]+;
																	IIF(oCupom:ACOLS[i][nPosD]=="CA","/CA","") })  ) <> 0
					oCupom:ACOLS[i][LEN(oCupom:ACOLS[i])]:= .T.
			EndIf
		EndIf
	Next i
	
	For i:=1 to len(oItem:ACOLS)
		If (nPosA := aScan(oItem:AHEADER,{|x|  ALLTRIM(x[2]) == "WRK_FILIAL"})   ) <> 0 .and.;
			(nPosB := aScan(oItem:AHEADER,{|x|  ALLTRIM(x[2]) == "WRK_DOC"})   ) <> 0 .and.;
			(nPosC := aScan(oItem:AHEADER,{|x|  ALLTRIM(x[2]) == "WRK_SERIE"})   ) <> 0
			If (nPosD := aScan(aLogInt,{|x| ALLTRIM(x[1]) == oItem:ACOLS[i][nPosA] .and.;
												 ALLTRIM(x[2]) == oItem:ACOLS[i][nPosB]+oItem:ACOLS[i][nPosC]})  ) <> 0
				oItem:ACOLS[i][LEN(oItem:ACOLS[i])]:= .T.
			EndIf
		EndIf
	Next i
	
	For i:=1 to len(oPagam:ACOLS)
		If (nPosA := aScan(oPagam:AHEADER,{|x|  ALLTRIM(x[2]) == "WRK_FILIAL"})   ) <> 0 .and.;
			(nPosB := aScan(oPagam:AHEADER,{|x|  ALLTRIM(x[2]) == "WRK_P_DOC"})   ) <> 0 .and.;
			(nPosC := aScan(oPagam:AHEADER,{|x|  ALLTRIM(x[2]) == "WRK_P_SERIE"})   ) <> 0
			If (nPosD := aScan(aLogInt,{|x| ALLTRIM(x[1]) == oPagam:ACOLS[i][nPosA] .and.;
												 ALLTRIM(x[2]) == oPagam:ACOLS[i][nPosB]+oPagam:ACOLS[i][nPosC]})  ) <> 0
				oPagam:ACOLS[i][LEN(oPagam:ACOLS[i])]:= .T.
			EndIf
		EndIf
	Next i
	
	For i:=1 to len(oRed:ACOLS)
		If (nPosA := aScan(oRed:AHEADER,{|x|  ALLTRIM(x[2]) == "WRK_FILIAL"})   ) <> 0 .and.;
			(nPosB := aScan(oRed:AHEADER,{|x|  ALLTRIM(x[2]) == "WRK_DTMOVTO"})   ) <> 0 .and.;
			(nPosC := aScan(oRed:AHEADER,{|x|  ALLTRIM(x[2]) == "WRK_SERPDV"})   ) <> 0
			If (nPosE := aScan(aLogInt,{|x| ALLTRIM(x[1]) == oRed:ACOLS[i][nPosA] .and.;
											ALLTRIM(x[2]) == ALLTRIM(DTOS(oRed:ACOLS[i][nPosB])+"-"+oRed:ACOLS[i][nPosC])})  ) <> 0
				oRed:ACOLS[i][LEN(oRed:ACOLS[i])]:= .T.
			EndIf
		EndIf
	Next i
EndIf

Return .T.

/*
Funcao      : AtuArqs
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para ajuste dos arrays que possuem informações dos arquivos
Autor       : Jean Victor Rocha.
Data/Hora   : 13/05/2014
*/
*-----------------------*
Static Function AtuArqs()
*-----------------------*
Local i
Local nPosA := 0
Local nPosB := 0
Local nPosC := 0
Local nPosD := 0
Local nPosE := 0

//Caso não tenha Log, retorna.
If Len(aLogInt) == 0
	Return .T.
EndIf

//Zera o Conteudo caso alguma variavel esteja em branco.
If Len(aArqSL1) == 0 .or. Len(aArqSL2) == 0 .or. Len(aArqSL4) == 0
	aArqSL1 := {}
	aArqSL2 := {}
	aArqSL4 := {}
EndIf

If Len(aArqSL1) <> 0
	If (nPosA := aScan(aCpoSL1,{|x|  ALLTRIM(x[1]) == "L1_FILIAL"})   ) <> 0 .and.;
		(nPosB := aScan(aCpoSL1,{|x|  ALLTRIM(x[1]) == "L1_DOC"})   ) <> 0 .and.;
		(nPosC := aScan(aCpoSL1,{|x|  ALLTRIM(x[1]) == "L1_SERIE"})   ) <> 0 .and.;
		(nPosD := aScan(aCpoSL1,{|x|  ALLTRIM(x[1]) == "L1_SITUA"})   ) <> 0
		For i:=1 to Len(aLogInt)
			If AT("/CA",aLogInt[i][2]) <> 0
				While (nPosE := aScan(aArqSL1,{|x|	x[nPosD] == "CA" .and. x[nPosA] == aLogInt[i][1] .And.;
													x[nPosB]+x[nPosC]+"/CA" == aLogInt[i][2]}) ) <> 0
					aDel(aArqSL1,nPosE)
					aSize(aArqSL1,Len(aArqSL1)-1)					
				EndDo			
			Else
				While (nPosE := aScan(aArqSL1,{|x|	x[nPosD] <> "CA" .and. x[nPosA] == aLogInt[i][1] .And.;
													x[nPosB]+x[nPosC] == aLogInt[i][2]}) ) <> 0
					aDel(aArqSL1,nPosE)
					aSize(aArqSL1,Len(aArqSL1)-1)					
				EndDo
			EndIf
		Next i           
	EndIf
	
	If (nPosA := aScan(aCpoSL2,{|x|  ALLTRIM(x[1]) == "L2_FILIAL"})   ) <> 0 .and.;
		(nPosB := aScan(aCpoSL2,{|x|  ALLTRIM(x[1]) == "L2_DOC"})   ) <> 0 .and.;
		(nPosC := aScan(aCpoSL2,{|x|  ALLTRIM(x[1]) == "L2_SERIE"})   ) <> 0
		For i:=1 to Len(aLogInt)
			While (nPosD := aScan(aArqSL2,{|x| x[nPosA] == aLogInt[i][1] .And. x[nPosB]+x[nPosC] == aLogInt[i][2]}) ) <> 0 
				aDel(aArqSL2,nPosD)
				aSize(aArqSL2,Len(aArqSL2)-1)					
			EndDo
		Next i
	EndIf
	
	If (nPosA := aScan(aCpoSL4,{|x|  ALLTRIM(x[1]) == "L4_FILIAL"})   ) <> 0 .and.;
		(nPosB := aScan(aCpoSL4,{|x|  ALLTRIM(x[1]) == "L4_P_DOC"})   ) <> 0 .and.;
		(nPosC := aScan(aCpoSL4,{|x|  ALLTRIM(x[1]) == "L4_P_SERIE"})   ) <> 0
		For i:=1 to Len(aLogInt)
			While (nPosD := aScan(aArqSL4,{|x| x[nPosA] == aLogInt[i][1] .And. x[nPosB]+x[nPosC] == aLogInt[i][2]}) ) <> 0 
				aDel(aArqSL4,nPosD)
				aSize(aArqSL4,Len(aArqSL4)-1)					
			EndDo
		Next i
	EndIf
EndIf

If Len(aArqSFI) <> 0
	If (nPosA := aScan(aCpoSFI,{|x|  ALLTRIM(x[1]) == "FI_FILIAL"	})   ) <> 0 .and.;
		(nPosB := aScan(aCpoSFI,{|x|  ALLTRIM(x[1]) == "FI_DTMOVTO"	})   ) <> 0 .and.;
		(nPosC := aScan(aCpoSFI,{|x|  ALLTRIM(x[1]) == "FI_SERPDV"	})   ) <> 0
		For i:=1 to Len(aLogInt)
			While (nPosE := aScan(aArqSFI,{|x| x[nPosA] == aLogInt[i][1] .And. ALLTRIM(x[nPosB]+"-"+x[nPosC]) == aLogInt[i][2]}) ) <> 0 
				aDel(aArqSFI,nPosE)
				aSize(aArqSFI,Len(aArqSFI)-1)					
			EndDo
		Next i
	EndIf
EndIf	

Return .T.

/*
Funcao      : SaveArq
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para salvar nas tabelas os arrays carregados dos arquivos.
Autor       : Jean Victor Rocha.
Data/Hora   : 08/05/2014
*/
*-----------------------*
Static Function SaveArq()
*-----------------------*
Local i, j
Local nPos		:= 0   
Local nPerc     := 0
Local nTotal    := 0  
Local nTotIPI   := 0
Local aDefSL1 := {	{"L1_TIPOCLI"	,"R"},;
					{"L1_TIPO"		,"V"},;
					{"L1_OPERADO"	,"CL2"},;
					{"L1_CONDPG"	,"CN"},;
					{"L1_CONFVEN"	,"SSSSSSSSNSSS"},;
					{"L1_IMPRIME"	,"1S"},;
					{"L1_ESTACAO"	,"001"},;
					{"L1_NUMMOV"	,"1 "},;
					{"L1_VEND"		,"000001"},;
					{"L1_CLIENTE"	,"000001"},;
					{"L1_LOJA"		,"07"},;
					{"L1_CGCCLI"	,"46548574000795"}}
Local aDefSL2 := {	{"L2_VENDIDO"	,"S"},;
					{"L2_TABELA"	,"1"},;
					{"L2_GRADE"		,"N"},;
					{"L2_VEND"		,"000001"},;
					{"L2_ITEMSD1"	,"000000"},;
					{"L2_LOCAL"		,"01"},;
					{"L2_SITTRIB"	,"F"}}
Local aDefSL4 := {}
Local aDefSFI := {}

Local aNumXDoc := {} 
Local cFilial  := ""
Local cSeqi    := ""
Local cFilAtu  := ""

lGravaOk:= .F.

ProcRegua(100)
IncProc("Aguarde...")

//Valida se possui informação a ser gravada.
If Len(aArqSL1) + Len(aArqSL2) + Len(aArqSL1) + Len(aArqSFI) == 0
	MsgInfo("Sem informação valida a ser gravada!","HLB BRASIL")
	Return .T.
EndIf

If Len(aArqSL1) <> 0
	//Gravação dos Cupons
	For i:=1 to Len(aArqSL1)
		If (nPos := aScan(aCpoSL1,{|x| ALLTRIM(x[1]) == "L1_SITUA"}) ) <> 0 .And.;
			(aArqSL1[i][nPos] == 'RX' .or. aArqSL1[i][nPos] == 'TR')

			SL1->(RecLock("SL1",.T.))     
			    
			//cOrc := GetSx8Num("SL1","L1_NUM")
			cOrc := L1NUMORC()
			//AOA - 16/07/2015 - Pegar e manter o número do primeiro documento.
			If empty(cSeqi)
				cSeqi := cOrc
			EndIf
			SL1->L1_NUM := cOrc

			For j:=1 to len(aCpoSL1)
				If SL1->(FieldPos(aCpoSL1[j][1])) <> 0 .and. "L1_NUM" <> aCpoSL1[j][1]
					SL1->(&(aCpoSL1[j][1])) := ConvertDado(aArqSL1[i][j],aCpoSL1[j][1])
				EndIf
			Next j

			//Atualiza com informações Default e Fixas
			If !Empty(SL1->L1_CGCCLI)
				aAux := CliLoja(SL1->L1_FILIAL,SL1->L1_CGCCLI)
				SL1->L1_CLIENTE	:= aAux[1]
				SL1->L1_LOJA	:= aAux[2]
			Else
				SL1->L1_CLIENTE	:= ""
				SL1->L1_LOJA	:= ""
			EndIf

			SL1->L1_OPERADO := ""//Zera para pegar sempre o Default.

			For j:=1 to Len(aDefSL1)
				If SL1->(FieldPos(aDefSL1[j][1])) <> 0 .and. ;
						(aScan(aCpoSL1,{|x| x[1] == aDefSL1[j][1] }) == 0 .or. EMPTY(SL1->(&(aDefSL1[j][1]))))
					SL1->(&(aDefSL1[j][1])) := aDefSL1[j][2]
				EndIf
			Next j
			If SL1->(FieldPos("L1_DTLIM")) == 0 .and. aScan(aCpoSL1,{|x| x[1] == "L1_DTLIM" }) == 0
				SL1->L1_DTLIM := SL1->L1_EMISSAO
			EndIf
			If SL1->(FieldPos("L1_NUMCFIS")) == 0 .and. aScan(aCpoSL1,{|x| x[1] == "L1_NUMCFIS" }) == 0
				SL1->L1_NUMCFIS := SL1->L1_DOC
			EndIf
			If Alltrim(SL1->L1_FORMPG) == "R$" 
				SL1->L1_DINHEIR := SL1->L1_VALMERC  
				SL1->L1_OUTROS  := 0
				SL1->L1_ENTRADA := SL1->L1_VALMERC  
			Else
		   		SL1->L1_OUTROS  := SL1->L1_VALMERC		
			EndIf
			If !EMPTY(SL1->L1_DESCONT)//Tratamento de desconto        
				If Alltrim(SL1->L1_FORMPG) == "R$" 
					SL1->L1_DINHEIR := SL1->L1_VALMERC  
					SL1->L1_OUTROS  := 0
			   		SL1->L1_ENTRADA := SL1->L1_VLRTOT  - SL1->L1_DESCONT   //Valor de entrada deve considerar o total com o desconto
				Else
		   	   		SL1->L1_OUTROS  := SL1->L1_VLRTOT  - SL1->L1_DESCONT 
				EndIf
				//RRP - 11/01/2016 - Ajuste na validação do desconto no SL1 o valor deve estar sem desconto	
				/*SL1->L1_VLRTOT  := SL1->L1_VLRTOT  - SL1->L1_DESCONT   //Valor total deve considerar o desconto.            
		   		SL1->L1_VALBRUT := SL1->L1_VALBRUT - SL1->L1_DESCONT   //Valor bruto deve considerar o desconto.*/
				SL1->L1_VLRTOT  := SL1->L1_VLRTOT  //Valor total deve considerar o desconto.            
		   		SL1->L1_VALBRUT := SL1->L1_VALBRUT //Valor bruto deve considerar o desconto.
			EndIf
			If SL1->L1_PARCELA <> 1//Existem cupons com mais de uma parcela com forma de Pg "R$" isso causa problema na gravação do SE1   
				SL1->L1_FORMPG := "CC"	
			EndIf

			//Gravação de Log de inclusão				
			If SL1->(FieldPos("L1_USERLGI")) <> 0
				SL1->L1_USERLGI := Embaralha("#@"+__cUserId+SPACE(13-LEN(__cUserId))+Save4in2(MsDate()-Ctod("01/01/96")) ,0)
			EndIf
			
			SL1->L1_SITUA := "PR" //Atualiza o Campo para provisorio, para que ainda não seja processado pelo sistema.
					
			If aScan(aNumXDoc, {|x| ALLTRIM(x[1]) == ALLTRIM(SL1->L1_DOC) .And.;
										ALLTRIM(x[2]) == ALLTRIM(SL1->L1_SERIE)  }) == 0
				aAdd(aNumXDoc,{SL1->L1_DOC,SL1->L1_SERIE,SL1->L1_NUM})
			EndIf    
		
			SL1->L1_PDV   := Replicate("0",3-len(alltrim(SL1->L1_PDV)))+SL1->L1_PDV  //TLM 20140929 ajuste do código do PDV  
			SL1->L1_DOC   := Replicate("0",9-len(alltrim(SL1->L1_DOC)))+SL1->L1_DOC  //TLM 20141127
			
			// TLM 2014/09/10 
			If Alltrim(SL1->L1_FILIAL) == '02' .Or. Alltrim(SL1->L1_FILIAL) == '2'  // 2-> CODIGO 01 / IG 
				SL1->L1_FILIAL:='01'
			ElseIf Alltrim(SL1->L1_FILIAL) == '03' .Or. Alltrim(SL1->L1_FILIAL) == '3'  // 3-> CODIGO 02 / JK
				SL1->L1_FILIAL:='02'
			EndIf                   
			
			//AOA - 16/07/2015 - Pegar e manter o número da filial.
			If empty(cFilAtu)
				cFilAtu := SL1->L1_FILIAL
			EndIf

			SL1->(MsUnLock())
			
		ElseIf (nPos := aScan(aCpoSL1,{|x| ALLTRIM(x[1]) == "L1_SITUA"}) ) <> 0 .And.;
				aArqSL1[i][nPos] == 'CA'
			//Gravação da Tabela de Cancelamento
			Z31->(RecLock("Z31",.T.))
			If aArqSL1[i][aScan(aCpoSL1,{|x| ALLTRIM(x[1]) == "L1_FILIAL"})] =='02' .Or. aArqSL1[i][aScan(aCpoSL1,{|x| ALLTRIM(x[1]) == "L1_FILIAL"})] =='2' //TLM 20150128
				Z31->Z31_FILIAL	:='01' 
			ElseIf aArqSL1[i][aScan(aCpoSL1,{|x| ALLTRIM(x[1]) == "L1_FILIAL"})] =='03' .Or. aArqSL1[i][aScan(aCpoSL1,{|x| ALLTRIM(x[1]) == "L1_FILIAL"})] =='3'  //TLM 20150128
				Z31->Z31_FILIAL	:='02'
			EndIf
			
			Z31->Z31_NUM	:= aArqSL1[i][aScan(aCpoSL1,{|x| ALLTRIM(x[1]) == "L1_NUM"})] //TLM 20150128
			Z31->Z31_DOC	:= aArqSL1[i][aScan(aCpoSL1,{|x| ALLTRIM(x[1]) == "L1_DOC"})]
			Z31->Z31_DOC    := Replicate("0",9-len(alltrim(Z31->Z31_DOC)))+Z31->Z31_DOC  //TLM 20141127
			Z31->Z31_SERIE	:= aArqSL1[i][aScan(aCpoSL1,{|x| ALLTRIM(x[1]) == "L1_SERIE"})]
			Z31->Z31_DATA	:= 	STOD(aArqSL1[i][aScan(aCpoSL1,{|x| ALLTRIM(x[1]) == "L1_EMISSAO"})])
			Z31->Z31_SITUA	:= "CA"
			Z31->Z31_USERLG	:= Embaralha("#@"+__cUserId+SPACE(13-LEN(__cUserId))+Save4in2(MsDate()-Ctod("01/01/96")) ,0)
			Z31->Z31_PDV	:= aArqSL1[i][aScan(aCpoSL1,{|x| ALLTRIM(x[1]) == "L1_PDV"})] //RRP - Incluir número do PDV.
			Z31->(MsUnLock())
			Loop
		EndIf		
	Next i

	//Gravação dos Itens
	For i:=1 to Len(aArqSL2)
		SL2->(RecLock("SL2",.T.))     
		If (npos := aScan(aNumXDoc, {|x|	ALLTRIM(x[1]) == ALLTRIM(aArqSL2[i][aScan(aCpoSL2,{|x| x[1] == "L2_DOC" })]) .And.;
											ALLTRIM(x[2]) == ALLTRIM(aArqSL2[i][aScan(aCpoSL2,{|x| x[1] == "L2_SERIE" })])  })) <> 0
			SL2->L2_NUM := aNumXDoc[npos][3]
		EndIf

		For j:=1 to len(aCpoSL2)
			If SL2->(FieldPos(aCpoSL2[j][1])) <> 0 .and. aCpoSL2[j][1] <> "L2_NUM" 
		 		If "L2_DESC" <> aCpoSL2[j][1] // TLM 20140912	
					SL2->(&(aCpoSL2[j][1])) := ConvertDado(aArqSL2[i][j],aCpoSL2[j][1])
				EndIf
			EndIf
		Next j

		SL2->L2_VEND := SL1->L1_VEND
		SL2->L2_LOCAL	:= ""
		SL2->L2_SITTRIB := ""
		
		//Atualiza com informações Default.
		For j:=1 to Len(aDefSL2)
			If SL2->(FieldPos(aDefSL2[j][1])) <> 0 .and. aScan(aCpoSL2,{|x| x[1] == aDefSL2[j][1] }) == 0
				If "L2_DESC" <> aCpoSL2[j][1] // TLM 20140912	
			   		SL2->(&(aDefSL2[j][1])) := aDefSL2[j][2]
				EndIf
			EndIf
		Next j
		//RRP - 12/01/2015 - Ajuste para somar o desconto do campo L2_DESCPRO
		If SL2->L2_DESCPRO <> 0
			SL2->L2_PRCTAB  :=  SL2->L2_VRUNIT  + SL2->L2_DESCPRO
		Else
			SL2->L2_PRCTAB  :=  SL2->L2_VRUNIT 	
		EndIf

		/*If !Empty(SL2->L2_VALDESC)
			SL2->L2_PRCTAB  :=  SL2->L2_VRUNIT  + SL2->L2_VALDESC
		Else
			SL2->L2_PRCTAB  :=  SL2->L2_VRUNIT 	
		EndIf*/
		                    
		If Empty(SL2->L2_LOCAL)                    
			SL2->L2_LOCAL := '01'   // TLM 2014/09/10 
		EndIf	
		
		//If EMPTY(SL2->L2_TES)
			//SL2->L2_TES := GetTes(SL2->L2_FILIAL,SL2->L2_PRODUTO)  
		//EndIf  
		
        //Tratamento de cupons de troca.
		//If SL2->L2_SITUA == "TR" - TLM 20141014
	   	//	SL2->L2_TES := "XXX"
		//Else
			SL2->L2_TES := GetTes(SL2->L2_FILIAL,SL2->L2_PRODUTO)  
		//EndIf

		SL2->L2_SITUA := "PR"//Atualiza o Campo para provisorio, para que ainda não seja processado pelo sistema.
		SL2->L2_PDV   := Replicate("0",3-len(alltrim(SL2->L2_PDV)))+SL2->L2_PDV //TLM 20140929 ajuste do código do PDV  
		SL2->L2_DOC   := Replicate("0",9-len(alltrim(SL2->L2_DOC)))+SL2->L2_DOC  //TLM 20141127		  
		
		//Gravação de Log de inclusão
		If SL2->(FieldPos("L2_USERLGI")) <> 0
			SL2->L2_USERLGI := Embaralha("#@"+__cUserId+SPACE(13-LEN(__cUserId))+Save4in2(MsDate()-Ctod("01/01/96")) ,0)
		EndIf 
		
		// TLM 2014/09/10 
		If Alltrim(SL2->L2_FILIAL) == '02' .Or. Alltrim(SL2->L2_FILIAL) == '2'   // 2-> CODIGO 01 / IG 
			SL2->L2_FILIAL:='01'
		ElseIf Alltrim(SL2->L2_FILIAL) == '03' .Or. Alltrim(SL2->L2_FILIAL) == '3'  // 3-> CODIGO 02 / JK
			SL2->L2_FILIAL:='02'
		EndIf   
 	      
		// Ajuste do valor do item, sem o IPI - TLM 20141014
		//RRP - 20/01/2016 - Ajuste no cálculo do valor do item com IPI
		SB1->(DbSetOrder(1))
		If SB1->(DbSeek(xFilial("SB1")+SL2->L2_PRODUTO)) 
		 	If SB1->B1_IPI <> 0
		 		nPerc			:= SB1->B1_IPI 
		 		nTotal          := SL2->L2_VLRITEM + SL2->L2_DESCPRO
		 		SL2->L2_VRUNIT	:= SL2->L2_VLRITEM + SL2->L2_DESCPRO
		 	    nPerc           := (100+nPerc)/100
		 	    SL2->L2_VRUNIT  := SL2->L2_VRUNIT / nPerc 
		 	    SL2->L2_PRCTAB  := SL2->L2_VRUNIT  
		 	    SL2->L2_BASEICM := SL2->L2_VRUNIT
		 	    SL2->L2_VLRITEM := SL2->L2_VRUNIT * SL2->L2_QUANT      
		 	    SL2->L2_VALIPI  := nTotal - SL2->L2_VLRITEM    
		 	    nTotIPI         += SL2->L2_VALIPI
		 	EndIf   
		//RRP - 24/03/2017 - Ajuste após atualização do sistema. Execauto Mata010 parou de incluir produtos.
		Else
			SB1->(DbGoTop())
		EndIf
 
 		//TLM 20141023 - Ajuste do SL2->L2_SITTRIB - SPED             
        SF4->(DbSetOrder(1))
        If SF4->(DbSeek(xFilial("SF4")+	SL2->L2_TES))   

			If SB1->B1_COD == SL2->L2_PRODUTO      
        		
        		MaFisIni(SL1->L1_CLIENTE, SL1->L1_LOJA, "C", "S", "F",,, .F., "SB1")
            	MaFisAdd(SB1->B1_COD, SF4->F4_CODIGO, SL2->L2_QUANT,SL2->L2_VRUNIT , 0, "", "",, 0, 0, 0, 0, SL2->L2_VLRITEM, 0, SB1->(RecNo()))
                
		   		If SBI->BI_PICMRET > 0 .AND. SF4->F4_BSICMST <> 100
   		   			SL2->L2_SITTRIB := 'F'
	   			ElseIf SF4->F4_BASEICM > 0 .AND. SF4->F4_BASEICM < 100
					SL2->L2_SITTRIB := 'T' + Alltrim(Str(MaFisRet(1,'IT_ALIQICM'),5,0))+"00" //Str(SBI->BI_ALIQRED,5,2)
	   			Elseif SF4->F4_LFICM == 'I'
		   			SL2->L2_SITTRIB := 'I' // Isento
				Elseif SF4->F4_LFICM == 'N' .OR. SF4->F4_LFICM == 'O'
					SL2->L2_SITTRIB:= 'N' // Não sujeito a ICMS
				Else
		   			SL2->L2_SITTRIB:= 'T' + Alltrim(Str(MaFisRet(1,'IT_ALIQICM'),5,0))+"00"
				Endif
		      
		 	EndIf
		 
		EndIf          
	  
		SL2->(MsUnLock())  
		
	Next i
    
    /*
	//Estava alterando apenas a ultima linha, removido.
   	// Ajuste do valor do item, sem o IPI - TLM 20141014  
	SL1->(RecLock("SL1",.F.))   
	SL1->L1_VALMERC:= SL1->L1_VALMERC -nTotIPI   
	SL1->L1_VALIPI := nTotIPI 
	SL1->(MsUnLock())
	nTotIPI:= 0
    */
             
	//Gravação dos Pagamentos
	For i:=1 to Len(aArqSL4)
		SL4->(RecLock("SL4",.T.)) 		
		
		If (npos := aScan(aNumXDoc, {|x|	ALLTRIM(x[1]) == ALLTRIM(aArqSL4[i][aScan(aCpoSL4,{|x| x[1] == "L4_P_DOC" })]) .And.;
												ALLTRIM(x[2]) == ALLTRIM(aArqSL4[i][aScan(aCpoSL4,{|x| x[1] == "L4_P_SERIE" })]) })) <> 0
			SL4->L4_NUM := aNumXDoc[npos][3]
		EndIf

		For j:=1 to len(aCpoSL4)
			If SL4->(FieldPos(aCpoSL4[j][1])) <> 0 .and. aCpoSL4[j][1] <> "L4_NUM"
				SL4->(&(aCpoSL4[j][1])) := ConvertDado(aArqSL4[i][j],aCpoSL4[j][1])
			EndIf
		Next j

		//Atualiza com informações Default.
		For j:=1 to Len(aDefSL4)
			If SL4->(FieldPos(aDefSL4[j][1])) <> 0 .and. aScan(aCpoSL4,{|x| x[1] == aDefSL4[j][1] }) == 0
				SL4->(&(aDefSL4[j][1])) := aDefSL4[j][2]
			EndIf
		Next j

		//Preenche a administradora na forma de pagamento            
		If !EMPTY(SL4->L4_ADMINIS)
			SL4->L4_ADMINIS := AdmCartao(SL4->L4_ADMINIS,"CHAVE")
		EndIf

		SL4->L4_SITUA   := "PR"//Atualiza o Campo para provisorio, para que ainda não seja processado pelo sistema.
		SL4->L4_P_DOC   := Replicate("0",9-len(alltrim(SL4->L4_P_DOC)))+SL4->L4_P_DOC  //TLM 20141127

		//Gravação de Log de inclusão
		If SL4->(FieldPos("L4_USERLGI")) <> 0
			SL4->L4_USERLGI := Embaralha("#@"+__cUserId+SPACE(13-LEN(__cUserId))+Save4in2(MsDate()-Ctod("01/01/96")) ,0)
		EndIf  
		
		// TLM 2014/09/10 
		If Alltrim(SL4->L4_FILIAL) == '02' .Or. Alltrim(SL4->L4_FILIAL) == '2'   // 2-> CODIGO 01 / IG 
			SL4->L4_FILIAL:='01'
		ElseIf Alltrim(SL4->L4_FILIAL) == '03' .Or. Alltrim(SL4->L4_FILIAL) == '3' // 3-> CODIGO 02 / JK
			SL4->L4_FILIAL:='02'
		EndIf     
		
		//TLM 20141128
		If Alltrim(SL4->L4_FORMA) == "CC" .AND. Empty(SL4->L4_ADMINIS)
			SL4->L4_ADMINIS:="011 - SEM BANDEIRA  "
		EndIf	 
		
		//TLM 20141128             
		If Alltrim(SL4->L4_FORMA) == "CD" .AND. Empty(SL4->L4_ADMINIS)
			SL4->L4_ADMINIS:="012 - SEM BANDEIRA  "
		EndIf	  		

		SL4->(MsUnLock())
	Next i
	lGravaOk := .T.
EndIf

If Len(aArqSFI) <> 0
	//Gravação da Reducao Z
	For i:=1 to Len(aArqSFI)
		SFI->(RecLock("SFI",.T.))
		For j:=1 to len(aCpoSFI)
			If SFI->(FieldPos(aCpoSFI[j][1])) <> 0
				SFI->(&(aCpoSFI[j][1])) := ConvertDado(aArqSFI[i][j],aCpoSFI[j][1])
			EndIf
		Next j
		//Atualiza com informações Default. o99i
		For j:=1 to Len(aDefSFI)
			If SFI->(FieldPos(aDefSFI[j][1])) <> 0 .and. aScan(aCpoSFI,{|x| x[1] == aDefSFI[j][1] }) == 0
				SFI->(&(aDefSFI[j][1])) := aDefSFI[j][2]
			EndIf
		Next j
		
		SFI->FI_SITUA := "PR"//Atualiza o Campo para provisorio, para que ainda não seja processado pelo sistema.
		SFI->FI_PDV   := Replicate("0",3-len(alltrim(SFI->FI_PDV)))+SFI->FI_PDV //TLM 20140910 ajuste do código do PDV  
		
		//Gravação de Log de inclusão
		If SFI->(FieldPos("LI_USERLGI")) <> 0
			SFI->LI_USERLGI := Embaralha("#@"+__cUserId+SPACE(13-LEN(__cUserId))+Save4in2(MsDate()-Ctod("01/01/96")) ,0)
		EndIf  
		
		If Alltrim(SFI->FI_FILIAL) == '02' .Or. Alltrim(SFI->FI_FILIAL) == '2'  // 2-> CODIGO 01 / IG 
			SFI->FI_FILIAL:='01'
		ElseIf Alltrim(SFI->FI_FILIAL) == '03' .Or. Alltrim(SFI->FI_FILIAL) == '3' // 3-> CODIGO 02 / JK
			SFI->FI_FILIAL:='02'
		EndIf 		 
		      
		SFI->FI_NUMERO  := Replicate("0",6-len(alltrim(SFI->FI_NUMREDZ)))+Alltrim(SFI->FI_NUMREDZ)
		SFI->FI_IMPDEBT := SFI->FI_VALCON * (Val(SFI->FI_COD18)/100)				    			
		
		SFI->(MsUnLock())
	Next i
	lGravaOk := .T.
EndIf
	
// AOA - 16/07/2015 - Ajusta a situação dos cupons cancelados, assim não vai gerar tabelas SD2,SF2,SFT,SF3. (Chamado 025647)
SL1->(DbSetOrder(1))
SL1->(DbGoTop())                            	
If SL1->(DbSeek(cFilAtu+cSeqi)) 
	While SL1->(!EOF())
		Z31->(DbSetOrder(2))
		If Z31->(DbSeek(cFilAtu+SL1->L1_DOC+SL1->L1_SERIE))
			SL1->(RecLock("SL1",.F.))
			SL1->L1_SITUA := "08" //Cupons cancelados tem código 08 no SL1 e não entra no JOB de integração.
			SL1->(MsUnLock())
		EndIf
		SL1->(DbSkip())
	EndDo
EndIf

If lGravaOk
	//Processamento de Cupons/ Uso da Função LJGRVBATCH
	ChangeSit("PR","RX")
	ProcCupom()
		
	//Processamento de Cupons Cancelados.
	AtuNum()
	ProcCancel()
                                 
	//Ajusta o Nome dos Arquivos integrados.
	aArqDir := Directory(cDirArq+"*.CSV")
	For i:=1 to len(aArqDir)
		If AT("SL1",aArqDir[i][1]) <> 0
			If Len(aArqSL1) <> 0
				AjustaNomeArq(aArqDir[i][1],"3")
			EndIf
		ElseIf AT("SL2",aArqDir[i][1]) <> 0
			If Len(aArqSL2) <> 0
				AjustaNomeArq(aArqDir[i][1],"3")
			EndIf
		ElseIf AT("SL4",aArqDir[i][1]) <> 0
			If Len(aArqSL4) <> 0
				AjustaNomeArq(aArqDir[i][1],"3")
			EndIf
		ElseIf AT("SFI",aArqDir[i][1]) <> 0
			If Len(aArqSFI) <> 0
				AjustaNomeArq(aArqDir[i][1],"3")
			EndIf
		EndIf
	Next i

	//Limpeza do Browse de processamento
	CleanInt(.T.)

	//Mensagem de Gravação Finalizada	
	MsgInfo("Gravação finalizada com sucesso!"+CHR(13)+CHR(10)+;
			 "A geração das Notas pode levar alguns minutos, aguarde para uma nova consulta!",;
			 "HLB BRASIL")
EndIf

Return .T.

/*
Funcao      : AtuNum
Parametros  :
Retorno     : Nenhum
Objetivos   : Função responsavel pela atualização do Numero do Orçamento para executar o cancelamento atraves da função. 
Autor       : Jean Victor Rocha.
Data/Hora   : 05/06/2014
*/
*----------------------*
Static Function AtuNum()
*----------------------*
Local cUpdate := ""

cUpdate += " Update "+RetSQLName("Z31") 
cUpdate += " Set Z31_NUM = (Select Top 1 L1_NUM 
cUpdate += " 				From "+RetSQLName("SL1")
cUpdate += " 				Where D_E_L_E_T_ <> '*' AND 
cUpdate += " 						L1_FILIAL = Z31_FILIAL AND 
cUpdate += " 						L1_DOC = Z31_DOC AND 
cUpdate += " 						L1_SERIE = Z31_SERIE) 
cUpdate += " Where Z31_SITUA = 'CA' AND Z31_NUM = ''
TCSQLExec(cUpdate)

Return .T.

/*
Funcao      : ProcCancel
Parametros  :
Retorno     : Nenhum
Objetivos   : Função responsavel pela execução do cancelamento do Cupom. 
Autor       : Jean Victor Rocha.
Data/Hora   : 05/06/2014
*/
*--------------------------*
Static Function ProcCancel()
*--------------------------*

Local cQryJOB := ""
Local cUpdate := ""      

//Marca como erro os cancelamentos que não possuem numero de orçamento.
cUpdate += " Update "+RetSQLName("Z31") 
cUpdate += " Set Z31_SITUA = 'ER' 
cUpdate += " Where Z31_SITUA = 'CA' AND Z31_NUM = ''
TCSQLExec(cUpdate)

//Busca pelos cancelamentos para a chamada do JOB
cQryJOB += "Select *"
cQryJOB += " From "+RetSQLName("Z31")
cQryJOB += " Where D_E_L_E_T_ <> '*'
cQryJOB += "		AND Z31_SITUA = 'CA'

If Select("JOB") > 0
	JOB->(DbClosearea())
Endif 
dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQryJOB),"JOB",.F.,.T.)

JOB->(DbGoTop())
While JOB->(!EOF())
	StartJob("U_CANLOJ001()",GetEnvServer(),.T.,cEmpAnt,JOB->Z31_FILIAL,JOB->R_E_C_N_O_)
	JOB->(DbSkip())
EndDo

Return .T.

/*
Funcao      : CANLOJ001
Parametros  :
Retorno     : Nenhum
Objetivos   : Função auxiliar para cancelamento de cupom de acordo com a tabela Z31 - Chamada via MultiThread 
Autor       : Jean Victor Rocha.
Data/Hora   : 06/06/2014
*/
*----------------------------------------------*
User Function CANLOJ001(cEmpJOB,cFilJOB,nRecZ31)
*----------------------------------------------*

Local nCount := 0    
Local lJob   := .F.

Private LEXCAUTO := .T.  //TLM 20150128 - Exclusao manual pelo formulas 

If Select("SX3")<=0
	RpcSetType(3)       
	RpcSetEnv(cEmpJOB,cFilJOB) 
	lJob:=.T.  //TLM 20150128 - Exclusao manual pelo formulas 
EndIf				                        

SL1->(DbSetOrder(1))
Z31->(DbSetOrder(1))

Z31->(DbGoTo(nRecZ31))
If Z31->(!EOF()) .and. Z31->(!BOF())
	If SL1->(DbSeek(cFilJOB+Z31->Z31_NUM))
		If SL1->L1_SITUA == "RX"
			While .T.
				Sleep(2000)
				If SL1->L1_SITUA == "OK"
					FRTEXCLUSA(Z31->Z31_NUM)
					Z31->(RecLock("Z31",.F.))
					Z31->Z31_SITUA = 'OK'
					Z31->(MsUnlock())
					Exit
				EndIf
				If nCount >= 20
					Z31->(RecLock("Z31",.F.))
					Z31->Z31_SITUA = 'ER'
					Z31->(MsUnlock())
					Conout("GTLOJ001 - Erro Cancelamento do cupom '"+Z31->Z31_NUM+"': Time Out!")
					Exit
				EndIf
				nCount++
			EndDo
		ElseIf SL1->L1_SITUA == "OK" 
		     
			If !(lJob)
				////TLM 20150128 - Exclusao manual pelo formulas - Necessário apagar o SD2 na mão.
				If !Empty(SL1->L1_PDV) 
	 				RecLock("SL1",.F.) 
	 		 		SL1->L1_PDV:=""
		 			SL1->(MsUnlock())
				EndIf
			EndIf
			
			FRTEXCLUSA(Z31->Z31_NUM)
			Z31->(RecLock("Z31",.F.))
			Z31->Z31_SITUA = 'OK'
			Z31->(MsUnlock())
		EndIf	
	Else
		Z31->(RecLock("Z31",.F.))
		Z31->Z31_SITUA = 'ER'
		Z31->(MsUnlock())
		Conout("GTLOJ001 - Erro Cancelamento do cupom '"+Z31->Z31_NUM+"': cupom não encontrado!")
	EndIf
EndIf

If lJob //TLM 20150128 - Exclusao manual pelo formulas
	RpcClearEnv()
EndIf

Return .T.

/*
Funcao      : ProcCupom
Parametros  :
Retorno     : Nenhum
Objetivos   : função respontavel por Iniciar os Jobs de processamentos para as Filiais que possuem L1_SITUA = RX 
Autor       : Jean Victor Rocha.
Data/Hora   : 05/06/2014
*/
*-----------------------------------*
Static Function ProcCupom(cDe,cPara)
*-----------------------------------*
Local cQryJOB := ""

cQryJOB += "Select L1_FILIAL"
cQryJOB += " From "+RetSQLName("SL1")
cQryJOB += " Where D_E_L_E_T_ <> '*'
cQryJOB += "		AND L1_SITUA = 'RX'
cQryJOB += " Group By L1_FILIAL

If Select("JOB") > 0
	JOB->(DbClosearea())
Endif 
dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQryJOB),"JOB",.F.,.T.)

JOB->(DbGoTop())
While JOB->(!EOF())
	StartJob("LJGRVBATCH()",GetEnvServer(),.F.,cEmpAnt,JOB->L1_FILIAL)//Não aguarda o Final
	JOB->(DbSkip())
EndDo

Return .T.

/*
Funcao      : ChangeSit
Parametros  :
Retorno     : Nenhum
Objetivos   : função respontavel por trocar o LX_SITUA de acordo com os Parametros 
Autor       : Jean Victor Rocha.
Data/Hora   : 05/06/2014
*/
*-----------------------------------*
Static Function ChangeSit(cDe,cPara)
*-----------------------------------*
Local cUpdate := ""

Default cDe := ""
Default cPara := ""

cUpdate := "Update "+RetSQLName("SL1")+" Set L1_SITUA = '"+ALLTRIM(cPara)+"' Where L1_SITUA = '"+ALLTRIM(cDe)+"'"
TCSQLExec(cUpdate)
cUpdate := "Update "+RetSQLName("SL2")+" Set L2_SITUA = '"+ALLTRIM(cPara)+"' Where L2_SITUA = '"+ALLTRIM(cDe)+"'"
TCSQLExec(cUpdate)
cUpdate := "Update "+RetSQLName("SL4")+" Set L4_SITUA = '"+ALLTRIM(cPara)+"' Where L4_SITUA = '"+ALLTRIM(cDe)+"'"
TCSQLExec(cUpdate)
cUpdate := "Update "+RetSQLName("SFI")+" Set FI_SITUA = '"+ALLTRIM(cPara)+"' Where FI_SITUA = '"+ALLTRIM(cDe)+"'"
TCSQLExec(cUpdate)

Return .T.

/*
Funcao      : ViewProd
Parametros  :
Retorno     : Nenhum
Objetivos   : Retorna se possui o Produto
Autor       : Jean Victor Rocha.
Data/Hora   : 23/05/2014
*/
*-------------------------------------*
Static Function ViewProd(cFilCli,cProd)
*-------------------------------------*
Local aProd :={}
Local cQuery := ""
Local cFilLocal := ""

SX2->(DbSetOrder(1))
If SX2->(DbSeek("SB1"))
	cModo := SX2->X2_MODO
Endif
If cModo == "C"
	cFilLocal := "  "
ElseIf cModo == "E"
	cFilLocal := cFilCli
EndIf

If Select("QRYSB1") > 0
	QRYSB1->(DbClosearea())
EndIf
cQuery += "Select Top 1 *
cQuery += " From "+RETSQLNAME("SB1")
cQuery += " Where D_E_L_E_T_ <> '*'
cQuery += " AND B1_FILIAL 	= '"+cFilLocal+"'
cQuery += " AND B1_COD 		= '"+cProd+"'

dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRYSB1",.F.,.T.)

QRYSB1->(DbGoTop())
If QRYSB1->(!EOF())
	aAdd(aProd,QRYSB1->B1_COD)
	aAdd(aProd,QRYSB1->B1_IPI)
EndIf

Return aProd

/*
Funcao      : GetTes
Parametros  :
Retorno     : Nenhum
Objetivos   : Retorna o Codigo TES Cadastrado no Produto. Campo customizado especifico para cupom Fiscal.
Autor       : Jean Victor Rocha.
Data/Hora   : 23/05/2014
*/
*-----------------------------------*
Static Function GetTes(cFilCli,cProd)
*-----------------------------------*
Local cRet := ""
Local cQuery := ""
Local cFilLocal := ""

If SB1->(FieldPos("B1_P_CFTES")) == 0
	Return cRet
EndIf

SX2->(DbSetOrder(1))
If SX2->(DbSeek("SB1"))
	cModo := SX2->X2_MODO
Endif
If cModo == "C"
	cFilLocal := "  "
ElseIf cModo == "E"
	cFilLocal := cFilCli
EndIf

If Select("QRYSB1") > 0
	QRYSB1->(DbClosearea())
EndIf
cQuery += "Select Top 1 *
cQuery += " From "+RETSQLNAME("SB1")
cQuery += " Where D_E_L_E_T_ <> '*'
cQuery += " 	AND B1_FILIAL 	= '"+cFilLocal+"'
cQuery += " 	AND B1_COD 		= '"+cProd+"'

dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRYSB1",.F.,.T.)

QRYSB1->(DbGoTop())
If QRYSB1->(!EOF())
	cRet := QRYSB1->B1_P_CFTES
	Return cRet
	QRYSB1->(DbSkip())
EndIf

Return cRet

/*
Funcao      : CliLoja
Parametros  : cFilCli,cCGC)
Retorno     : Nenhum
Objetivos   : Retorna o codigo do cliente de acordo com loja/CGC, caso não exista grava um novo e retorna o novo codigo.
Autor       : Jean Victor Rocha.
Data/Hora   : 08/05/2014
*/
*-----------------------------------*
Static Function CliLoja(cFilCli,cCGC)
*-----------------------------------*
Local aRet   := {}
Local cQuery := ""
Local cModo	 := "C"
Default cFilCli	:= ""
Default cCGC	:= ""

If EMPTY(cCGC)
	Return {"",""}
EndIf

SX2->(DbSetOrder(1))
If SX2->(DbSeek("SA1"))
	cModo := SX2->X2_MODO
Endif
If cModo == "C"
	cFilLocal := "  "
ElseIf cModo == "E"
	cFilLocal := cFilCli
EndIf

SA1->(DbSetOrder(3))//A1_FILIAL+A1_CGC
If SA1->(DbSeek(cFilLocal+cCGC))
	aRet := {SA1->A1_COD,SA1->A1_LOJA}
Else
	If Select("QRYSA1") > 0
		QRYSA1->(DbClosearea())
	EndIf
	cQuery += "Select MAX(A1_COD) AS A1_COD
	cQuery += " From "+RETSQLNAME("SA1")
	cQuery += " Where D_E_L_E_T_ <> '*'
	cQuery += " 	AND A1_FILIAL 	= '"+cFilLocal+"'

	dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRYSA1",.F.,.T.)
	QRYSA1->(DbGoTop())
	If QRYSA1->(!EOF())
		SA1->(RecLock("SA1",.T.))
		SA1->A1_FILIAL	:= cFilLocal
		SA1->A1_COD		:= SOMA1(QRYSA1->A1_COD)
		SA1->A1_LOJA	:= '01'
		SA1->A1_NOME	:= FWEmpName(cEmpAnt)
		SA1->A1_CGC		:= cCGC
		SA1->A1_TIPO	:= 'F'
		SA1->(MsUnlock())
		aRet := {SOMA1(QRYSA1->A1_COD),'01'}
	EndIf
EndIf

Return aRet

/*
Funcao      : GetLog
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função que gera arquivo de log do Browse
Autor       : Jean Victor Rocha.
Data/Hora   : 08/05/2014
*/
*-----------------------*
Static Function GetLog()
*-----------------------*
Local i
Local cXml := ""

If LEN(aLogInt) == 0
	MsgInfo("Não foi encontrado erro para geração de Log de Erros!","HLB BRASIL")
	Return .T.
EndIf

ProcRegua(100)
IncProc("Aguarde...")

cXml += ' <?xml version="1.0"?>
cXml += ' <?mso-application progid="Excel.Sheet"?>
cXml += ' <Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"
cXml += ' xmlns:o="urn:schemas-microsoft-com:office:office"
cXml += ' xmlns:x="urn:schemas-microsoft-com:office:excel"
cXml += ' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
cXml += '  xmlns:html="http://www.w3.org/TR/REC-html40">
cXml += '  <Styles>
cXml += '   <Style ss:ID="Default" ss:Name="Normal">
cXml += '    <Alignment ss:Vertical="Bottom"/>
cXml += '    <Borders/>
cXml += '    <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>
cXml += '    <Interior/>
cXml += '    <NumberFormat/>
cXml += '    <Protection/>
cXml += '   </Style>
cXml += '   <Style ss:ID="s17">
cXml += '    <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000" ss:Bold="1"/>
cXml += '    <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml += '   </Style>
cXml += '   <Style ss:ID="s18">
cXml += '    <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml += '   </Style>
cXml += '   <Style ss:ID="s19">
cXml += '    <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>
cXml += '    <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml += '    <NumberFormat ss:Format="Short Date"/>
cXml += '   </Style>
cXml += '   <Style ss:ID="s20">
cXml += '    <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml += '    <NumberFormat ss:Format="Short Time"/>
cXml += '   </Style>
cXml += '   <Style ss:ID="s21">
cXml += '    <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXml += '    <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="14" ss:Color="#000000" ss:Bold="1"/>
cXml += '    <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml += '   </Style>
cXml += '   <Style ss:ID="s22">
cXml += '    <NumberFormat ss:Format="@"/>
cXml += '   </Style>
cXml += '   <Style ss:ID="s107">
cXml += '    <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#FFFFFF" ss:Bold="1"/>
cXml += '    <Interior ss:Color="#7030A0" ss:Pattern="Solid"/>
cXml += '   </Style>
cXml += '   <Style ss:ID="s123">
cXml += '    <Borders>
cXml += '     <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml += '    </Borders>
cXml += '    <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml += '    <NumberFormat ss:Format="@"/>
cXml += '   </Style>
cXml += '  </Styles>
cXml += '  <Worksheet ss:Name="LOG">
cXml += '     <Table ss:ExpandedColumnCount="3" ss:ExpandedRowCount="999999" x:FullColumns="1"  x:FullRows="1" ss:DefaultRowHeight="15">
cXml += '    <Column ss:Width="69"/>
cXml += '    <Column ss:Width="75.75"/>
cXml += '    <Column ss:AutoFitWidth="0" ss:Width="552.75"/>
cXml += '    <Row ss:Height="18.75">
cXml += '     <Cell ss:StyleID="s17"><Data ss:Type="String">Interface Loja</Data></Cell>
cXml += '     <Cell ss:StyleID="s18"></Cell>
cXml += '     <Cell ss:StyleID="s21"><Data ss:Type="String">HLB BRASIL</Data></Cell>
cXml += '    </Row>
cXml += '    <Row>
cXml += '     <Cell ss:StyleID="s18"><Data ss:Type="String">Data:</Data></Cell>
cXml += '     <Cell ss:StyleID="s19"><Data ss:Type="DateTime">'+STRZERO(YEAR(Date()),4)+'-'+STRZERO(MONTH(Date()),2)+'-'+STRZERO(DAY(Date()),2)+'T00:00:00.000</Data></Cell>
cXml += '     <Cell ss:StyleID="s18"></Cell>
cXml += '    </Row>
cXml += '    <Row>
cXml += '     <Cell ss:StyleID="s18"><Data ss:Type="String">Hora:</Data></Cell>
cXml += '     <Cell ss:StyleID="s20"><Data ss:Type="DateTime">1899-12-31T'+TIME()+'.000</Data></Cell>
cXml += '     <Cell ss:StyleID="s18"></Cell>
cXml += '    </Row>
cXml += '    <Row>
cXml += '     <Cell ss:StyleID="s107"><Data ss:Type="String">Filial</Data></Cell>
cXml += '     <Cell ss:StyleID="s107"><Data ss:Type="String">Chave</Data></Cell>
cXml += '     <Cell ss:StyleID="s107"><Data ss:Type="String">Descricao Ocorrencia</Data></Cell>
cXml += '    </Row>

For i:=1 to len(aLogInt)
	cXml += '    <Row>
	cXml += '     <Cell ss:StyleID="s123"><Data ss:Type="String">'+ALLTRIM(aLogInt[i][1])+'</Data></Cell>
	cXml += '     <Cell ss:StyleID="s123"><Data ss:Type="String">'+ALLTRIM(aLogInt[i][2])+'</Data></Cell>
	cXml += '     <Cell ss:StyleID="s123"><Data ss:Type="String">'+ALLTRIM(aLogInt[i][3])+'</Data></Cell>
	cXml += '    </Row>
Next i

cXml += '   </Table>
cXml += '   <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">
cXml += '    <PageSetup>
cXml += '     <Header x:Margin="0.31496062000000002"/>
cXml += '     <Footer x:Margin="0.31496062000000002"/>
cXml += '     <PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024" x:Right="0.511811024" x:Top="0.78740157499999996"/>
cXml += '    </PageSetup>
cXml += '    <Print>
cXml += '     <ValidPrinterInfo/>
cXml += '     <PaperSizeIndex>9</PaperSizeIndex>
cXml += '     <Scale>65</Scale>
cXml += '     <HorizontalResolution>600</HorizontalResolution>
cXml += '     <VerticalResolution>600</VerticalResolution>
cXml += '    </Print>
cXml += '    <ShowPageBreakZoom/>
cXml += '    <PageBreakZoom>130</PageBreakZoom>
cXml += '    <Selected/>
cXml += '    <Panes>
cXml += '     <Pane>
cXml += '      <Number>3</Number>
cXml += '      <ActiveRow>8</ActiveRow>
cXml += '      <ActiveCol>2</ActiveCol>
cXml += '     </Pane>
cXml += '    </Panes>
cXml += '    <ProtectObjects>False</ProtectObjects>
cXml += '    <ProtectScenarios>False</ProtectScenarios>
cXml += '   </WorksheetOptions>
cXml += '  </Worksheet>
cXml += ' </Workbook>

If FILE(cDirArq+DTOS(Date())+".XLS")
	FERASE(cDirArq+DTOS(Date())+".XLS")
EndIf
nHdl 		:= FCREATE(cDirArq+DTOS(Date())+".XLS",0 )
nBytesSalvo := FWRITE(nHdl, cXml )
fclose(nHdl)

SHELLEXECUTE("open",(cDirArq+DTOS(Date())+".XLS"),"","",5)

Return .T.

/*
Funcao      : L1NUMORC
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Funcão para retornar o numero do cupom L1_NUM
Obs         :
*/              
*------------------------*
Static Function L1NUMORC()  
*------------------------*
Local cQuery	:= ""
Local cOrcam	:= "" 
Local cMay		:= ""
Local nTent	:= 0

cOrcam := GetSx8Num("SL1","L1_NUM")

If Select("QRYNUM") > 0
	QRYNUM->(DbClosearea())
Endif

cQuery += "Select L1_NUM
cQuery += " From "+RETSQLNAME("SL1")
cQuery += " Where D_E_L_E_T_ <> '*'
cQuery += "	AND L1_NUM >= '"+cOrcam+"'
cQuery += " Group By L1_NUM
cQuery += " Order By L1_NUM

dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRYNUM",.F.,.T.)

QRYNUM->(DbGoTop())
While QRYNUM->(!EOF()) .AND. QRYNUM->L1_NUM == cOrcam
	ConfirmSX8()
	cOrcam := GetSx8Num("SL1","L1_NUM")
	
	QRYNUM->(DbSkip())
EndDo

ConfirmSX8()

Return cOrcam

/*
Funcao      : CloseThread
Parametros  : Nil
Retorno     : Nil
Objetivos   : Rotina para encerramento de Thread Aberta para processamento de NF
Autor       : Jean Victor Rocha
Data/Hora   : 28/04/2014
*/
*---------------------------*
Static Function CloseThread()
*---------------------------*
Local nPos := 0
Local aThread := GetUserInfoArray()
Local nStart  := SECONDS()

While (nPos := aScan(aThread,{|x| "LJGRVBATCH" $ x[5] })) <> 0
	nId		:= aThread[nPos][3] // ID da Thread
	nInstru := aThread[nPos][9] // Número de instruções
	Sleep(3000)
	aThread := GetUserInfoArray()
	If (nPos := aScan(aThread,{|x| x[3] == nId})) <> 0
		If nInstru == aThread[nPos][9]
			KillUser ( aThread[nPos][1],aThread[nPos][2],aThread[nPos][3],aThread[nPos][4])
		EndIf		
	EndIf 
	aThread := GetUserInfoArray()
	If (SECONDS()-nStart ) > 10
		Return .T.
	EndIf
EndDo

Return .T.


/*
Funcao      : AjustaNomeArq
Parametros  : Nil
Retorno     : Nil
Objetivos   : Rotina para troca dos nomes de arquivos.
Autor       : Jean Victor Rocha
Data/Hora   : 12/08/2014
*/
*-------------------------------------------*
Static Function AjustaNomeArq(cArquivo,cTipo)
*-------------------------------------------*
Default cArquivo := ""
Default cTipo := ""

Do Case
	Case cTipo == "1"//Troca os Nomes para Ex.: SL1.CSV
		If AT("INT",cArquivo) == 0
			If (nPos:=aScan(aNameArqOri,{|x| UPPER(ALLTRIM(x[1])) == UPPER(ALLTRIM(cArquivo))}) ) == 0
				aAdd(aNameArqOri,{cArquivo,LEFT(cArquivo,3)+".CSV"})
			EndIf
			FRename(cDirArq+cArquivo,UPPER(cDirArq+LEFT(cArquivo,3)+".CSV"))
		EndIf

	Case cTipo == "2"//Restaura Os nomes para o Olriginal.
		If (nPos:= aScan(aNameArqOri,{|x| UPPER(ALLTRIM(x[2])) == UPPER(ALLTRIM(cArquivo))}) ) <> 0
			FRename(cDirArq+cArquivo,UPPER(cDirArq+aNameArqOri[nPos][1]))
		EndIf

	Case cTipo == "3"//Troca os nomes para Ex.> SL1_INT_20140812_1031.CSV
		FRename(cDirArq+cArquivo,UPPER(cDirArq+LEFT(cArquivo,3)+"_INT_"+DTOS(Date())+"_"+STRTRAN(Time(),":","")+".CSV"))
EndCase

Return .T.


/*
Funcao      : ExecAutB1()
Parametros  : aArqSL2,aCpoSL2
Retorno     : Lógico
Objetivos   : Função para gravar produto ou alterar
Autor       : Renato Rezende
Data/Hora   : 26/02/16 15:56
*/                          
*---------------------------------------------*
 Static Function ExecAutB1(aArqSL2,aCpoSL2)  
*---------------------------------------------*
Local lRet		:= .T.
Local aVetor	:= {}
Local cCodPro	:= ""
Local cDesc		:= ""
Local cTes		:= ""
Local cNCM		:= ""
Local cFilAtu	:= ""
Local nIPI		:= 0
Local nPosVal	:= 0

Private lMsErroAuto:= .F.

If (nPosVal := aScan(aCpoSL2,{|x| ALLTRIM(x[1]) == "L2_PRODUTO"}) ) <> 0
	cCodPro := Alltrim(aArqSL2[nPosVal])
	cCodPro := cCodPro+(space(TamSx3("L2_PRODUTO")[1]-Len(cCodPro)))
EndIf
If (nPosVal := aScan(aCpoSL2,{|x| ALLTRIM(x[1]) == "L2_FILIAL"}) ) <> 0
	cFilAtu := Alltrim(Alltrim(aArqSL2[nPosVal]))
	If cFilAtu == '02'                                                     
		cFilAtu:= '01'
	Else
		cFilAtu:= '02'
	EndIf 
EndIf
If (nPosVal := aScan(aCpoSL2,{|x| ALLTRIM(x[1]) == "L2_P_DESC"}) ) <> 0
	cDesc := Alltrim(aArqSL2[nPosVal])
EndIf
If (nPosVal := aScan(aCpoSL2,{|x| ALLTRIM(x[1]) == "L2_P_NCM"}) ) <> 0
	cNCM := Alltrim(aArqSL2[nPosVal])
EndIf
If (nPosVal := aScan(aCpoSL2,{|x| ALLTRIM(x[1]) == "L2_P_IPIP"}) ) <> 0
	nIPI := ConvertDado(aArqSL2[nPosVal],"N")
	If nIPI <> 0
		cTes := "74A"
	Else
		cTes := "5RP"
	EndIf
EndIf

aVetor:= {{"B1_FILIAL"  ,cFilAtu 	     ,NIL},;
		 {"B1_COD"      ,cCodPro 	     ,NIL},;
         {"B1_DESC"	    ,cDesc			 ,NIL},;
         {"B1_TIPO"    	,"ME"            ,Nil},;
         {"B1_UM"      	,"PC"            ,Nil},;
         {"B1_LOCPAD"  	,"01"            ,Nil},;
         {"B1_PICM"    	,0               ,Nil},;
         {"B1_POSIPI" 	,cNCM            ,Nil},;
         {"B1_IPI"     	,nIPI            ,Nil},;
         {"B1_CONTRAT" 	,"N"             ,Nil},;
		 {"B1_APROPRI" 	,"D"             ,Nil},;
         {"B1_LOCALIZ" 	,"N"             ,Nil},;
         {"B1_ORIGEM"	,"1"			 ,Nil},;
         {"B1_GRUPO"	,""				 ,Nil},;
         {"B1_P_CFTES"	,cTes			 ,Nil},;
         {"B1_CONTA"	,"11418001"		 ,Nil},; 
         {"B1_GARANT"	,"2"			 ,Nil},;
		 {"B1_P_TIP"	,"1"			 ,Nil},;
         {"B1_TIPCONV"  ,"M"			 ,Nil}}
	         
MSExecAuto({|x,y| Mata010(x,y)},aVetor,3)
	
If lMsErroAuto
	lRet:= .F.
EndIf

Return lRet