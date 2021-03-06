#INCLUDE 'TOTVS.CH'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'TOPCONN.CH'
#INCLUDE "TBICONN.CH"

#DEFINE INTEGRAR 1
#DEFINE VISUALIZAR 2

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GTCORP82  �Autor  �Eduardo C. Romanini � Data �  29/08/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina de integra��o de expense report                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Financeiro - GT                                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
*----------------------*
User Function GTCORP82()
*----------------------*
Local oBrw

//Instaciamento
oBrw := FWMBrowse():New()

//tabela que ser� utilizada
oBrw:SetAlias( "Z37" )

//Titulo
oBrw:SetDescription( "Integra��o de Expense Report" )

//ativa
Z37->(DbSetOrder(1))
oBrw:Activate()

Return Nil

/*
Fun��o  : MenuDef()
Objetivo: Carrega as op��es de manuten��o no browser principal.
Autor   : Eduardo C. Romanini
Data    : 06/09/13
*/
*-----------------------*
Static Function MenuDef()
*-----------------------*
Local aRotina := {}

ADD OPTION aRotina Title 'Integrar' Action 'U_GT82Man' OPERATION 3 ACCESS 0    
ADD OPTION aRotina Title 'Visualizar' Action 'U_GT82Man' OPERATION 2 ACCESS 0

Return aRotina  

/*
Fun��o  : Gt82Man()
Objetivo: Exibir a tela principal de intergra��o de E.R.
Autor   : Eduardo C. Romanini
Data    : 06/09/13
*/
*-------------------------------------*
User Function Gt82Man(cAlias,nReg,nOpc)
*-------------------------------------*
Local lIntegra := .F.
Local lIntOK   := .F.

Local aCabec := {"Data","Despesa","Descri��o","Valor","Complemento","Reembolso"}

Private cGetIdER   := Space(10)
Private cProposta  := ""
Private cGetCC     := ""    
Private cGetCli    := ""
Private cCodCli    := ""
Private cLojCli    := ""
Private cGetColab  := ""
Private cCicColab  := ""
Private cMailColab := ""
Private cGetFinal  := ""
Private cGetIni    := ""
Private cGetProj   := ""
Private nGetTotal  := 0
Private nGetTotR   := 0
Private nGetTotNR  := 0
Private dDtVenc    := STOD("")
Private cMGetObs   := ""
Private cEmpresa   := ""
Private cFilEmp    := ""
Private cGetNome   := ""
Private cGetTipo   := "" 
Private cBancMIS   := ""
Private cNomBanc   := ""
Private cAgenMIS   := ""
Private cCCMIS     := ""

Private aItens := {}

Private oBrwDesp

//Tela de dialogo principal
oDlg       := MSDialog():New(000,002,480,850,"Integra��o de Expense Report",,,.F.,,,,,,.T.,,,.T. )

//Grupo de Integra��o
oGrpIdER   := TGroup():New( 002,004,034,210,"Id do Expense Report",oDlg,CLR_BLACK,CLR_WHITE,.T.,.F. )
oGetIdER   := TGet():New( 016,010,{|u| If(PCount()>0,cGetIdER:=u,cGetIdER)},oGrpIdER,156,008,'@E 99999999999',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cGetIdER",,)
oGetIdER:bLostFocus := {|| If(!Empty(cGetIdER),CarregaER(nOpc),),oBtnGrv:SetFocus()}
oBtLimpar  := TButton():New( 016,170,"Limpar",oGrpIdER,{|| LimpaTela()},30,10,,,,.T.)

//Grupo de controle
oGrpCtr    := TGroup():New( 002,214,034,420,"Controle",oDlg,CLR_BLACK,CLR_WHITE,.T.,.F. )
oBtnGrv    := TButton():New( 016,346,"Gravar"  ,oGrpCtr,{|| If(ConfirmaER(),(lIntegra := .T.,oDlg:End()),)},30,10,,,,.T.)
oBtnCancel := TButton():New( 016,380,"Cancelar",oGrpCtr,{|| lIntegra := .F., oDlg:End()},30,10,,,,.T.)

//Grupo de cabe�alho
oGrpCabec  := TGroup():New( 036,004,090,420,"Cabe�alho",oDlg,CLR_BLACK,CLR_WHITE,.T.,.F. )
oSayColab  := TSay():New( 048,010,{||"Colaborador:"},oGrpCabec,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oGetColab  := TGet():New( 048,044,{|u| If(PCount()>0,cGetColab:=u,cGetColab)},oGrpCabec,156,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cGetColab",,)
oSayProj   := TSay():New( 062,010,{||"Projeto:"},oGrpCabec,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oGetProj   := TGet():New( 062,044,{|u| If(PCount()>0,cGetProj:=u,cGetProj)},oGrpCabec,156,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cGetProj",,)
oSayNome   := TSay():New( 076,010,{||"Nome Proj:"},oGrpCabec,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oGetNome   := TGet():New( 076,044,{|u| If(PCount()>0,cGetNome:=u,cGetNome)},oGrpCabec,156,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cGetNome",,)
oSayCC     := TSay():New( 048,218,{||"C.C.:"},oGrpCabec,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oGetCC     := TGet():New( 048,248,{|u| If(PCount()>0,cGetCC:=u,cGetCC)},oGrpCabec,164,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cGetCC",,)
oSayCli    := TSay():New( 062,218,{||"Cliente:"},oGrpCabec,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oGetCli    := TGet():New( 062,248,{|u| If(PCount()>0,cGetCli:=u,cGetCli)},oGrpCabec,164,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cGetCli",,)
oSayTipo   := TSay():New( 076,218,{||"Tipo:"},oGrpCabec,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oGetTipo   := TGet():New( 076,248,{|u| If(PCount()>0,cGetTipo:=u,cGetTipo)},oGrpCabec,164,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cGetTipo",,)

//Grupo de grid de despesas
oGrpGrid   := TGroup():New( 092,004,184,420,"Despesas",oDlg,CLR_BLACK,CLR_WHITE,.T.,.F. )
CarregaCols()
oBrwDesp := TWBrowse():New(102,010,402,76,,aCabec,,oGrpGrid,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
oBrwDesp:SetArray(aItens)    
oBrwDesp:bLine := { || aItens[ oBrwDesp:nAT ] }
                     
//Grupo de Titulo
oGrpTit   := TGroup():New( 186,004,238,210,"Titulo",oDlg,CLR_BLACK,CLR_WHITE,.T.,.F. )
oSayDtTit := TSay():New( 196,010,{||"Dt. Vecto.:"},oGrpTit,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,080,008)
oGetDtTit := TGet():New( 196,044,{|u| If(PCount()>0,dDtVenc:=u,dDtVenc)},oGrpTit,156,008,'@D',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","dDtVenc",,)
oGetDtTit:bLostFocus := {|| VldDtVencto(dDtVenc),oBtnGrv:SetFocus()}

//Grupo de totais 
oGrpTot    := TGroup():New(186,214,238,420,"Totais",oDlg,CLR_BLACK,CLR_WHITE,.T.,.F. )
oSayTotDe  := TSay():New( 196,224,{||"Total N�o Reemb.:"},oGrpTot,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,080,008)
oGetTotDe  := TGet():New( 196,284,{|u| If(PCount()>0,nGetTotNR:=u,nGetTotNR)},oGrpTot,128,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nGetTotNR",,)
oSayTotAd  := TSay():New( 210,224,{||"Total Reemb.:"},oGrpTot,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,080,008)
oGetTotAd  := TGet():New( 210,284,{|u| If(PCount()>0,nGetTotR:=u,nGetTotR)},oGrpTot,128,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nGetTotR",,)
oSayTotGe  := TSay():New( 224,224,{||"Total Geral:"},oGrpTot,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,080,008)
oGetTotGe  := TGet():New( 224,284,{|u| If(PCount()>0,nGetTotal:=u,nGetTotal)},oGrpTot,128,008,'@E 9,999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nGetTotal",,)

//Tratamento para visualiza��o
If nOpc == 2
	cGetIdER := Z37->Z37_ID
	
	oGetIdER:Disable()
	oBtnGrv:bAction := {|| oDlg:End()}
	oBtLimpar:Disable()
	
	CarregaER(nOpc)
EndIf

//Ativa��o centralizada da tela
oDlg:Activate(,,,.T.)

//Realiza a integra��o
If lIntegra
	Processa({|| lIntOk:=IntegraER()}, "Integrando Expense Report...")     
	If lIntOk
		//Grava o log
		Z37->(RecLock("Z37",.T.))
		Z37->Z37_ID     := StrZero(Val(cGetIdER),6)
		Z37->Z37_USERRE := cCicColab
		Z37->Z37_USERNO := cGetColab
		Z37->Z37_CLIENT := cCodCli
		Z37->Z37_LOJA   := cLojCli
		Z37->Z37_DATA   := dDataBase
		Z37->Z37_HORA   := Time()
		If Z37->(FieldPos("Z37_PROJ")) # 0    //GFP - 13/01/29017
			Z37->Z37_PROJ   := cGetProj
		EndIf
		Z37->(MsUnlock())
	EndIf
EndIf

Return Nil

/*
Fun��o  : CarregaER()
Objetivo: Carregar os campos para integra��o
Autor   : Eduardo C. Romanini
Data    : 09/09/13
*/
*------------------------------*
Static Function CarregaER(nOpc)
*------------------------------*
Local cBanco := "MSSQL/dbMIS"
Local cIp    := "10.0.30.5
Local cCcUsr := "" 
Local nCon := 0

Local nPorta := 7894

aItens := {}

cGetIdER := AllTrim(StrTran(cGetIdER,"-",""))

If Empty(cGetIdER)
	MsgInfo("A identifica��o do Expense Report n�o foi informada.","Aten��o")
	Return
EndIf

If nOpc <> 2
	Z37->(DbSetOrder(1))
	If Z37->(DbSeek(xFilial("Z37")+StrZero(Val(cGetIdER),6)))
		MsgInfo("Esse Expense Report j� foi integrado.","Aten��o")
		Return
	EndIf
EndIf
	
//Define o tipo de conex�o que ser� utilizado.
TCCONTYPE("TCPIP")

//Realiza a conex�o com o banco de dados.
nCon := TCLink(cBanco,cIp,nPorta)

//Verifica se foi conectado.
If nCon < 0
    MsgInfo("Erro ("+str(nCon,4)+") ao conectar com "+cBanco+" em "+cIp)
    Return          	
EndIf

//Query de consulta da capa do expense report
BeginSql Alias 'TABER'
	SELECT tbColaboradores.CPFColaborador,
	       tbColaboradores.NmColaborador,
		   Case 
		       When CCProjeto.CdCentroCusto is null
			   Then CCColaborador.CdCentroCusto
			   Else CCProjeto.CdCentroCusto
		   End as CdCentroCusto,
		   tbColaboradores.EmailColaborador,
		   tbColaboradores.CdAgencia,
	       tbColaboradores.NrContaCorrente,
	       tbColaboradores.idBanco,
	       tbBancos.CdBanco,
	       tbBancos.NmBanco,
	       tbExpenseReport.IdExpenseReport, 
	       tbExpenseReport.CdVersaoExpenseReport,
		   tbExpenseReport.IdStatusExpenseReport,
		   tbStatusExpenseReport.NmStatusExpenseReport,
		   tbExpenseReport.IdProjeto,
		   tbProjetos.NmProjeto,
		   Case 
		       When tbEmpProjeto.CdEmpresa is null
			   Then tbEmpColaborador.CdEmpresa
			   Else tbEmpProjeto.CdEmpresa
		   End as CdEmpresa,
		   Case 
		       When tbEmpProjeto.LjEmpresa is null
			   Then tbEmpColaborador.LjEmpresa
			   Else tbEmpProjeto.LjEmpresa
		   End as LjEmpresa,
		   Case 
		       When tbProjetos.IdTipoProjeto = 1 Then 'ADM'
			   When LinNegProj.IdLinhaNegocio = 1 Then 'ATA'
			   When LinNegProj.IdLinhaNegocio = 2 Then 'OUT'
			   Else ''
		   End as [TpProj],
		   Case 
		       When tbClientesERP.CdClienteERP is null Then '999999'
			   Else tbClientesERP.CdClienteERP
		   End as CdClienteERP,
		   tbClientesERP.LjClienteERP,
		   tbExpenseReport.VlExpenseReport as 'VlERTotal',
		   tbExpenseReport.VlExpenseReportReembolsavel as 'VlERTrem',
		   tbExpenseReport.VlExpenseReportNaoReembolsavel as 'VlERTNRem'
	FROM tbExpenseReport
	LEFT JOIN tbUsuarios on tbUsuarios.IdUsuario = tbExpenseReport.IdUsuario
	LEFT JOIN tbColaboradores on tbColaboradores.IdColaborador = tbUsuarios.IdColaborador
	LEFT JOIN tbEmpresas tbEmpColaborador on tbEmpColaborador.IdEmpresa = tbColaboradores.IdEmpresa
	LEFT JOIN tbStatusExpenseReport on tbStatusExpenseReport.IdStatusExpenseReport = tbExpenseReport.IdStatusExpenseReport
	LEFT JOIN tbProjetos on tbProjetos.IdProjeto = tbExpenseReport.IdProjeto
	LEFT JOIN tbEmpresas tbEmpProjeto on tbEmpProjeto.IdEmpresa = tbProjetos.IdEmpresa
	LEFT JOIN tbClientes on tbClientes.IdCliente = tbProjetos.IdCliente
	LEFT JOIN tbClientesERP on tbClientesERP.IdCliente = tbClientes.IdCliente
	                       and EmpClienteERP = Case 
		                                           When tbEmpProjeto.CdEmpresa is null
			                                       Then tbEmpColaborador.CdEmpresa
			                                       Else tbEmpProjeto.CdEmpresa
											    End
	LEFT JOIN tbCentrosCusto CCColaborador on CCColaborador.IdCentroCusto = tbColaboradores.IdCentroCusto
	LEFT JOIN tbCentrosCusto CCProjeto on CCProjeto.IdCentroCusto = tbProjetos.IdCentroCusto
	LEFT JOIN tbEmpresasLinhasNegocio LinNegProj on LinNegProj.IdEmpresa = tbEmpProjeto.IdEmpresa
	LEFT JOIN tbBancos on tbBancos.idBanco = tbColaboradores.idBanco
	WHERE tbExpenseReport.IdExpenseReport = %exp:cGetIdER%
EndSql

TABER->(DbGoTop())

//Valida a numera��o do expense report
If TABER->(EOF() .or. BOF())
	MsgInfo("N�o foi encontrado Expense Report com a identifica��o informada.","Aten��o")
	TcUnlink(nCon)
	Return .F.
EndIf

//Valida o status do Expense Report
If nOpc <> 2
	If TABER->IdStatusExpenseReport <> 2
		MsgInfo("O status do expense report n�o permite a integra��o.","Aten��o")
		TcUnlink(nCon)
		Return .F.
	EndIf
	
	//Verifica se o E.R. foi alterado.
	If TABER->CdVersaoExpenseReport > 1
		If !MsgYesNo("Esse Expense Report sofreu altera��es ap�s ser impresso. "+CRLF+;
		             "A ultima vers�o desse E.R. no sistema � a "+AllTrim(Str(TABER->CdVersaoExpenseReport))+", por favor, "+CRLF+; 
		             "confirme se � essa a vers�o que est� sendo integrada."+CRLF+;
		             "Confirma a integra��o do Expense Report?")
			TcUnlink(nCon)
			Return .F.
		EndIf
	EndIf
EndIf

//Carrega o n�mero do projeto
cGetProj  := AllTrim(Str(TABER->IdProjeto))
cGetNome  := AllTrim(TABER->NmProjeto)
cGetTipo  := Alltrim(TABER->TpProj)

//Carrega a data Inicial e Final de Apontamentos
cGetIni   := "  /  /  "
cGetFinal := "  /  /  "

//Carrega o total de adiantamento
cGetTotAd := ""

//Carrega as observa��es
cMGetObs  := ""

//Armazena o n�mero do CPF ou RG do colaborador
cCicColab := TABER->CPFColaborador

//Carrega o nome do funcion�rio que realizou o E.R.
cGetColab := Capital(TABER->NmColaborador)

//Retorna o e-mail do colaborador
cMailColab := AllTrim(TABER->EmailColaborador)
 
//Empresa e filial
cEmpresa := TABER->CdEmpresa
cFilEmp  := TABER->LjEmpresa

If AllTrim(SM0->M0_CODIGO) <> "99" .AND. ! ("TESTE" $ alltrim(UPPER(GetEnvServer())))
	If AllTrim(SM0->M0_CODIGO) <> AllTrim(cEmpresa) .or. AllTrim(SM0->M0_CODFIL) <> AllTrim(cFilEmp)
		MsgInfo("O Expense Report n�o � dessa empresa.","Aten��o")
		TcUnlink(nCon)
		Return .F.
	EndIf
EndIf
			
//Carrega o Centro de Custo
cGetCC := TABER->CdCentroCusto

//Carrega o cliente        
cCodCli := TABER->CdClienteERP
cLojCli := TABER->LjClienteERP

//Carrega dados do titulo
dDtVenc := getDtVencto()

//Carrega informa��es de Banco/Agencia/Conta para reembolso.
cBancMIS := TABER->CdBanco
cNomBanc := TABER->NmBanco
cAgenMIS := TABER->CdAgencia
cCCMIS   := TABER->NrContaCorrente

//Atualiza os totais
nGetTotal	:= TABER->VlERTotal
nGetTotR	:= TABER->VlERTRem
nGetTotNR	:= TABER->VlERTNRem

//Carrega o grid de despesas
CarregaCols()

TABER->(DbCloseArea())

//Fecha a conex�o com o banco
TcUnlink(nCon)

//Verifica o cadastro de cliente
SA1->(DbSetOrder(1))
If SA1->(DbSeek(xFilial("SA1")+cCodCli+cLojCli))
	cGetCli := AllTrim(SA1->A1_NOME)
EndIf

Return Nil            

*---------------------------*
Static Function CarregaCols()
*---------------------------*

//Carrega os dados
If !Empty(cGetIdER)
	//Query de consulta do projeto
	BeginSql Alias 'TABITER'
		SELECT tbItensExpenseReport.DtItemExpenseReport,
		       tbProdutos.CdProduto,
			   tbDespesas.NmDespesa,
			   tbItensExpenseReport.VlItemExpenseReport,
			   tbItensExpenseReport.DsObservacaoItemExpenseReport,
			   tbItensExpenseReport.ReembolsavelItemExpenseReport,
			   tbNaturezasFinanceira.CdNaturezaFinanceira
		FROM tbItensExpenseReport
		LEFT JOIN tbExpenseReport on tbExpenseReport.IdExpenseReport = tbItensExpenseReport.IdExpenseReport
		LEFT JOIN tbDespesasProjeto on tbDespesasProjeto.IdDespesa = tbItensExpenseReport.IdDespesa
		                           and tbDespesasProjeto.IdProjeto = tbExpenseReport.IdProjeto
		LEFT JOIN tbDespesas on tbDespesas.IdDespesa = tbItensExpenseReport.IdDespesa
		LEFT JOIN tbProdutos on tbProdutos.IdProduto = tbDespesas.IdProduto
		LEFT JOIN tbNaturezasFinanceira on tbNaturezasFinanceira.IdNaturezaFinanceira = Case
		                                                                                    When tbItensExpenseReport.ReembolsavelItemExpenseReport = 1
																							Then tbDespesas.IdReembolsavelNatFin
																							Else tbDespesas.IdNaoReembolsavelNatFin
																					    End
		WHERE tbItensExpenseReport.IdExpenseReport = %exp:cGetIdER%
	EndSql
	
	TABITER->(DbGoTop())
	While TABITER->(!EOF())
	    
	    aAdd(aItens,{TABITER->DtItemExpenseReport,;
	                 StrZero(Val(TABITER->CdProduto),6),;
	                 AllTrim(TABITER->NmDespesa),;
	                 TABITER->VlItemExpenseReport,;
	                 AllTrim(TABITER->DsObservacaoItemExpenseReport),;
	                 If(TABITER->ReembolsavelItemExpenseReport=="1","Sim","N�o"),;
	                 TABITER->CdNaturezaFinanceira})
	    
		TABITER->(DbSkip())
	EndDo
    
    //Atualiza o grid
	oBrwDesp:SetArray(aItens)
	oBrwDesp:bLine := { || aItens[ oBrwDesp:nAT ] }
	oBrwDesp:Refresh()     
Else
	aItens := {{" /  /  ","","",0,"",""}}
EndIf

Return aItens    

*--------------------------*
Static Function ConfirmaER()
*--------------------------*

//Valida a data de vencimento informada.
If !VldDtVencto(dDtVenc)
	Return .F.	
EndIf

//Mensagem de confirma��o
If !MsgYesNo("Confirma a integra��o do Expense Report?")
	Return .F.	
EndIf                   
	
Return .T.	

*-------------------------*
Static Function IntegraER()
*-------------------------*
Local lRateio := .F.

Local cNaturez := ""
Local cCodVend := ""
Local cVlTotal := ""
Local cVlAdi   := ""
Local cTes     := "53X"
Local cBanco   := "MSSQL/dbMis"

Local cIp      := "10.0.30.5"
Local nPorta   := 7894

Local nCon     := 0
Local nPos     := 0
Local nX       := 0
Local nI       := 1
Local nVlTotal := 0
Local nVlPer   := 0
Local nVlAdi   := 0

Local aCab     := {}
Local aAuxEv   := {}
Local aRatEvEz := {}
Local aAuzEz   := {}
Local aRatEz   := {}
Local aCabPV   := {}
Local aItemPV  := {}
Local aLinPV   := {}
Local aITReemb := {}
Local aRatNat  := {}

Local lAglutSC6:= .T.	//.T. = Aglutina os itens do pedido de venda, .F. = N�o aglutina os itens do pedido de venda

Private lMsErroAuto := .F.

Private xPreSel

//Tratamento de Valor Total
nVlTotal := nGetTotal

//Tratamento de Valor de Adiantamento
/*
cVlAdi := StrTran(cGetTotAd,".","")
cVlAdi := StrTran(cVlAdi,",",".")
nVlAdi := Val(cVlAdi)
*/
ProcRegua(1)

//Pesquisa o vendedor
If Select("TMPSA3") > 0
	TMPSA3->(DbCloseArea())
EndIf

//Retorna o c�digo do vendedor
BeginSql Alias "TMPSA3" 
	SELECT TOP 1 A3_COD
	FROM %table:SA3%
	WHERE %notDel%
	  AND ( A3_EMAIL = %exp:cMailColab%
	    OR  A3_CGC = %exp:cCicColab% )
EndSql

TMPSA3->(DbGoTop())
If TMPSA3->(!EOF() .and. !BOF())
	cCodVend := AllTrim(TMPSA3->A3_COD)
Else
    cCodVend := GrvVend(cGetColab,cCicColab,cMailColab)
EndIf

TMPSA3->(DbCloseArea())

//Verifica se a TES est� habilidata para a empresa
SZ2->(dbSetOrder(3))
If !SZ2->(DbSeek(xfilial("SZ2")+AllTrim(cEmpresa)+AllTrim(cFilEmp)+cTes))
	MsgInfo("A TES " + AllTrim(cTes) + " n�o est� cadastrada para a empresa "+AllTrim(cEmpresa)+"-"+AllTrim(cFilEmp))
	Return .F.	
EndIf
//Se n�o existir, grava o item cont�bil
If cGetTipo <> "ADM"
	//Verifica o cadastro de cliente
	SA1->(DbSetOrder(1))
	If !SA1->(DbSeek(xFilial("SA1")+cCodCli+cLojCli))
		MsgInfo("O Cliente '"+ALLTRIM(cCodCli)+"' n�o est� cadastrado","Aten��o")
		Return .F.
	EndIf

EndIf

//Se n�o existir, grava o item contabil.
GrvItCtb(cCodCli,cGetCli)

//Se n�o existir, grava a classe de valor.
GrvClVl(cGetTipo+cGetProj,cGetNome)

//Verifica se haver� rateio de naturezas
If Len(aItens) > 1
	lRateio := .T.

	//Cria o array de rateio	
	For nI:=1 To Len(aItens)
        
		cNaturez := AllTrim(aItens[nI][7])
		
		//Retorna a natureza, de acordo com a informa��o de Reembols�vel e n�o Reembols�vel.
		If AllTrim(aItens[nI][6]) == "Sim"
		
			if !lAglutSC6
			
				aAdd(aITReemb,{aItens[nI][2],aItens[nI][4]})	
			
			else
			
				//MSM - 07/01/2014 - Atualizado para aglutinar os itens no pedido de venda, chamado: 021129			
				nPosExist := aScan(aITReemb,{|x| alltrim(x[1]) == alltrim(aItens[nI][2])})
				
				if nPosExist > 0
					aITReemb[nPosExist][2]+=aItens[nI][4]
				else
					aAdd(aITReemb,{aItens[nI][2],aItens[nI][4]})	
				endif
			endif	
		EndIf
		
		//Alimenta o array de rateio
		nPos := aScan(aRatNat,{|x| x[1] == cNaturez})
		
		If nPos == 0
			aAdd(aRatNat,{cNaturez,aItens[nI][4],0})
		Else
			aRatNat[nPos][2] += aItens[nI][4]
		EndIf
				
	Next

	If Len(aRatNat) == 1 
    	lRateio := .F.
    	
    	cNaturez := aRatNat[1][1]
    	
	Else
	 
		//Calcula o rateio
		For nI:=1 To Len(aRatNat)
    		nVlPer := (aRatNat[nI][2]*100)/nVlTotal
    	
	    	aRatNat[nI][3] := Round(nVlPer,2)
		Next
	EndIf	    
Else

	//Retorna a natureza, de acordo com a informa��o de Reembols�vel e n�o Reembols�vel.
	//cNaturez := AllTrim(Z56->Z56_NATSIM)
	cNaturez := AllTrim(aItens[nI][7])

	If AllTrim(aItens[nI][6]) == "Sim"
			
		if !lAglutSC6
		
			aAdd(aITReemb,{aItens[nI][2],aItens[nI][4]})			
		
		else
		
			//MSM - 07/01/2014 - Atualizado para aglutinar os itens no pedido de venda, chamado: 021129			
			nPosExist := aScan(aITReemb,{|x| alltrim(x[1]) == alltrim(aItens[nI][2])})
			
			if nPosExist > 0
				aITReemb[nPosExist][2]+=aItens[nI][4]
			else
				aAdd(aITReemb,{aItens[nI][2],aItens[nI][4]})	
			endif

		endif
	EndIf

EndIf

//Inclui Contas a Pagar de acordo com as despesas.
aadd( aCab ,{"E2_PREFIXO" ,AllTrim(cFilEmp)+"E", Nil })
aadd( aCab ,{"E2_NUM" ,StrZero(Val(cGetIdER),6), Nil })
aadd( aCab ,{"E2_PARCELA" , '1', Nil })
aadd( aCab ,{"E2_TIPO" , 'RED', Nil })
	
//Pesquisa se o funcion�rio est� cadastrado como fornecedor.
SA2->(DbSetOrder(3))
If !(SA2->(DbSeek(xFilial("SA2")+cCicColab)))
	MsgInfo("O colaborador n�o est� cadastrado como fornecedor. O E.R. n�o poder� ser integrado.","Aten��o")
	Return	.F.
Else
	//GFP - 11/01/2017 - Verifica divergencias entre Banco/Agencia/CC MIS x Protheus
	If (!Empty(cBancMIS) .AND. !Empty(cAgenMIS) .AND. !Empty(cCCMIS)) .AND.;
	   (AllTrim(SA2->A2_BANCO) <> AllTrim(cBancMIS) .OR. AllTrim(SA2->A2_AGENCIA) <> AllTrim(cAgenMIS) .OR. AllTrim(SA2->A2_NUMCON) <> AllTrim(cCCMIS)) .AND.;
	   ((AllTrim(SA2->A2_AGENCIA) == AllTrim(StrTran(cAgenMIS,"-","")) .AND. AllTrim(SA2->A2_NUMCON) == AllTrim(StrTran(cCCMIS,"-",""))) .OR.;
	   MsgYesNo("Identificado diverg�ncias referente a informa��es de Banco/Ag�ncia/Conta Corrente MIS x Protheus." +CHR(13)+CHR(10)+;
				"Informa��o presente no MIS: " + AllTrim(cBancMIS)+"/"+AllTrim(StrTran(cAgenMIS,"-",""))+"/"+AllTrim(StrTran(cCCMIS,"-","")) +CHR(13)+CHR(10)+;
				"Informa��o presente no Protheus: " + AllTrim(SA2->A2_BANCO)+"/"+AllTrim(SA2->A2_AGENCIA)+"/"+AllTrim(SA2->A2_NUMCON) +CHR(13)+CHR(10)+;
				"Deseja atualizar as informa��es?","Grant Thornton Brasil."))
		/*SA6->(DbSetOrder(1))
		lAchou := 	SA6->(DbSeek(xFilial("SA6")+AvKey(cBancMIS,"A6_COD")+AvKey(cAgenMIS,"A6_AGENCIA")+AvKey(cCCMIS,"A6_NUMCON"))) .OR.;
					SA6->(DbSeek(xFilial("SA6")+AvKey(cBancMIS,"A6_COD")+AvKey(StrTran(cAgenMIS,"-",""),"A6_AGENCIA")+AvKey(cCCMIS,"A6_NUMCON"))) .OR.;
					SA6->(DbSeek(xFilial("SA6")+AvKey(cBancMIS,"A6_COD")+AvKey(cAgenMIS,"A6_AGENCIA")+AvKey(StrTran(cCCMIS,"-",""),"A6_NUMCON"))) .OR.;
					SA6->(DbSeek(xFilial("SA6")+AvKey(cBancMIS,"A6_COD")+AvKey(StrTran(cAgenMIS,"-",""),"A6_AGENCIA")+AvKey(StrTran(cCCMIS,"-",""),"A6_NUMCON")))
		*/
		cAgenMIS := StrTran(cAgenMIS,"-","")
		cAgenMIS := StrTran(cAgenMIS,"@","")
		cAgenMIS := StrTran(cAgenMIS,"/","")
		cAgenMIS := StrTran(cAgenMIS,"\","")
		cAgenMIS := StrTran(cAgenMIS,"|","")
		cAgenMIS := StrTran(cAgenMIS,".","")
		cAgenMIS := StrTran(cAgenMIS," ","")
		
		cCCMIS := StrTran(cCCMIS,"-","")
		cCCMIS := StrTran(cCCMIS,"@","")
		cCCMIS := StrTran(cCCMIS,"/","")
		cCCMIS := StrTran(cCCMIS,"\","")
		cCCMIS := StrTran(cCCMIS,"|","")
		cCCMIS := StrTran(cCCMIS,".","")
		cCCMIS := StrTran(cCCMIS," ","")
		/*If RecLock("SA6",!lAchou)
			SA6->A6_FILIAL  := xFilial("SA6")
			SA6->A6_COD     := AllTrim(cBancMIS)
			SA6->A6_AGENCIA := AllTrim(cAgenMIS)
			SA6->A6_NUMCON  := AllTrim(cCCMIS)
			SA6->A6_NOME    := AllTrim(cNomBanc)
			SA6->A6_NREDUZ  := AllTrim(cNomBanc)
			SA6->(MsUnlock())
		EndIf*/
		If RecLock("SA2",.F.)
			SA2->A2_BANCO   := AllTrim(cBancMIS)  //SA6->A6_COD
			SA2->A2_AGENCIA := AllTrim(cAgenMIS)  //SA6->A6_AGENCIA
			SA2->A2_NUMCON  := AllTrim(cCCMIS)    //SA6->A6_NUMCON
			SA2->(MsUnlock())
		EndIf
	EndIf
EndIf

aadd( aCab ,{"E2_FORNECE" , SA2->A2_COD	, Nil })                                                                                                                                  
aadd( aCab ,{"E2_LOJA"    , SA2->A2_LOJA, Nil })
aadd( aCab ,{"E2_EMISSAO" , Date()		, Nil })
//aadd( aCab ,{"E2_VENCTO"  , DaySum(dDataBase,3), Nil })
aadd( aCab ,{"E2_VENCTO"  , dDtVenc		, Nil })
aadd( aCab ,{"E2_VALOR"   , nVlTotal	, Nil })
aadd( aCab ,{"E2_HIST"    , AllTrim(cGetIdER) + " - " + DtoC(Date()), Nil })

//Valida��o de Contas a pagar ja existe, evitando erro na tela do usuario.
SE2->(DbSetOrder(1))//E2_FILIAL +E2_PREFIXO           + E2_NUM              +E2_PARCELA+ E2_TIPO+E2_FORNECE+E2_LOJA
If SE2->(DbSeek(xFilial("SE2")+AllTrim(cFilEmp)+"A" + StrZero(Val(cGetIdER),6) + '1' + 'RED' + SA2->A2_COD+SA2->A2_LOJA))
	MsgInfo("J� existe um registro de Contas a pagar com estes dados. O E.R. n�o poder� ser integrado.","Aten��o")
	Return	.F.
EndIf

//If cGetTipo <> "ADM"
	aadd( aCab ,{"E2_ITEMD"   ,AllTrim(cCodCli)  , Nil }) //C�digo do cliente
//Else
//	aadd( aCab ,{"E2_ITEMD"   ,"999999"  , Nil }) //C�digo do cliente
//EndIf

aadd( aCab ,{"E2_CLVLDB"  ,AllTrim(cGetTipo+cGetProj) , Nil })
aadd( aCab ,{"E2_CCD"     ,Right(AllTrim(cGetCC),4) , Nil })
	
If !lRateio
	aadd( aCab ,{"E2_NATUREZ" ,AllTrim(cNaturez) , Nil }) 
Else
       //MSM - 18/02/2016 - Tratamento para preencher natureza no t�tulo e consequentemente levar para movimento banc�rio, chamado: 031351. Haidde disse para pegar a primeira natureza.
	aadd( aCab ,{"E2_NATUREZ" ,AllTrim(aRatNat[1][1]) , Nil }) 
	aadd( aCab ,{"E2_MULTNAT" , '1', Nil })//rateio multinaturezas = sim	
	     
	For nI:=1 To Len(aRatNat)
		aAuxEv := {}
		aRatEz := {}
		//Adicionando o vetor da natureza
		aadd( aAuxEv ,{"EV_NATUREZ" , aRatNat[nI][1], Nil })//natureza a ser rateada
		aadd( aAuxEv ,{"EV_VALOR"   , aRatNat[nI][2], Nil })//valor do rateio na natureza
		aadd( aAuxEv ,{"EV_PERC"    , aRatNat[nI][3], Nil })//percentual do rateio na natureza
		aadd( aAuxEv ,{"EV_RATEICC" , "2", Nil })//indicando que h� rateio por centro de custo
	     
		/*
		//Adicionando multiplos centros de custo
		//primeiro centro de custo
		aAuxEz:={}
		aadd( aAuxEz ,{"EZ_CCUSTO" , AllTrim(cGetCC)   , Nil })//centro de custo da natureza
		aadd( aAuxEz ,{"EZ_VALOR"  , aRatNat[nI][2]     , Nil })//valor do rateio neste centro de custo
		aadd( aAuxEz ,{"EZ_CLVL"   , AllTrim(cProposta), Nil })//valor do rateio neste centro de custo
		aadd( aAuxEz ,{"EZ_ITEMCTA", AllTrim(cCodCli)  , Nil })//valor do rateio neste centro de custo
		aadd(aRatEz,aAuxEz)
		aadd(aAuxEv,{"AUTRATEICC" , aRatEz, Nil })//recebendo dentro do array da natureza os multiplos centros de custo
		*/    
		
		aAdd(aRatEvEz,aAuxEv)//adicionando a natureza ao rateio de multiplas naturezas
	Next
	
	aAdd(aCab,{"AUTRATEEV",ARatEvEz,Nil})//adicionando ao vetor aCab o vetor do rateio
	
EndIf

//Tratamento para aglutinar lan�amento cont�bil
GrvProfSX1("FIN050","07",1)

Begin Transaction
	
MsExecAuto( { |x,y,z| FINA050(x,y,z)} , aCab, ,3)//inclusao

//Tratamento para retornar parametro de aglutinar lan�amento cont�bil
GrvProfSX1("FIN050","07",xPreSel)
	
If lMsErroAuto
    MostraErro()
    DisarmTransaction()
Else
    MsgInfo("T�tulo inclu�do com sucesso!","Aten��o")
    u_GtFin013( 'CP' ) //Emiss�o de Ordem de Pagamento
Endif

End Transaction
	
If lMsErroAuto
	Return .F.
EndIf

//Inclui o Pedido de Venda para as despesas reembols�veis
lMsErroAuto := .F.

If Len(aITReemb) > 0

	aCabPV:={{"C5_FILIAL" ,xFilial("SC5"),Nil},;
			 {"C5_TIPO"   ,"N"           ,Nil},; // Tipo de pedido
			 {"C5_CLIENTE",cCodCli       ,Nil},; // Codigo do cliente
			 {"C5_LOJACLI",cLojCli       ,Nil},; // Loja do cliente
			 {"C5_EMISSAO",Date()	     ,Nil},; // Data de emissao
			 {"C5_CONDPAG","069"         ,Nil},; // Codigo da condicao de pagamanto* - MSM - 22/04/14 - Chamado: 017684
			 {"C5_NNDMES" ,"01"          ,Nil},; 
			 {"C5_VEND1"  ,cCodVend      ,Nil},; 
			 {"C5_TIPOND" ,"NOR"         ,Nil},;
			 If(SC5->(FieldPos("C5_P_MIS")) # 0,{"C5_P_MIS",cGetProj,Nil},),;  // N�mero do Projeto MIS - GFP - 11/01/2017
			 If(SC5->(FieldPos("C5_P_IDER")) # 0,{"C5_P_IDER",StrZero(Val(cGetIdER),6),Nil},)}   // N�mero do ID ER - GFP - 14/02/2017
	
	aItemPV := {}		 
	
	For nI:=1 To Len(aItReemb)
		aLinPV := {}
		aAdd( aLinPV, { "C6_ITEM"	 , StrZero( nI, 2 )				    , Nil } )
		aAdd( aLinPV, { "C6_PRODUTO" , aItReemb[nI][1]				    , Nil } )
		aAdd( aLinPV, { "C6_QTDVEN"	 , 1				  		   		, Nil } )
		aAdd( aLinPV, { "C6_PRCVEN"	 , A410Arred(aItReemb[nI][2], "C6_PRCVEN" ), Nil } )
		aAdd( aLinPV, { "C6_PRUNIT"	 , A410Arred(aItReemb[nI][2], "C6_PRCVEN" ), Nil } )
		aAdd( aLinPV, { "C6_VALOR"	 , A410Arred(aItReemb[nI][2], "C6_PRCVEN" ), Nil } )
		aAdd( aLinPV, { "C6_TES"	 , cTes							    , Nil } )	
		
		aAdd( aItemPV, aLinPV )
	Next

	Begin Transaction	
	
	MSExecAuto({|x,y| Mata410(x,y)},aCabPv,aItemPV,3)
	
	If lMSErroAuto
		MostraErro()
	    DisarmTransaction()
	Else
		MsgInfo("O pedido de venda " +AllTrim(SC5->C5_NUM)+ " foi inclu�do com sucesso!","Aten��o")
	EndIf		 
	
	End Transaction

	If lMsErroAuto
		Return .F.
	EndIf   	
	
EndIf

If AllTrim(SM0->M0_CODIGO) <> "99" .AND. !("TESTE" $ alltrim(UPPER(GetEnvServer())))
	//Atualiza o Status do Expense Report
	cCmd := " UPDATE tbExpenseReport "
	cCmd += " SET IdStatusExpenseReport = 3 "
	cCmd += " WHERE IdExpenseReport = '"+AllTrim(cGetIdER)+"' "
	
	//Define o tipo de conex�o que ser� utilizado.
	TCCONTYPE("TCPIP")
	
	//Realiza a conex�o com o banco de dados.
	nCon := TCLink(cBanco,cIp,nPorta)
	
	//Executa o comando de atualiza��o
	If (TCSQLExec(cCmd) < 0)
		MsgStop("Erro na atualiza��o do status: " + TCSQLError())
	    Return .F. 
	EndIf
	
	//Fecha a conex�o com o banco
	TcUnlink(nCon)
EndIf

Return .T.  

*-------------------------*
Static Function LimpaTela()
*-------------------------*
cGetIdER   := Space(10)
cProposta  := ""
cGetCC     := ""    
cGetCli    := ""
cCodCli    := ""
cLojCli    := ""
cGetColab  := ""
cCicColab  := ""
cMailColab := ""
cGetFinal  := ""
cGetIni    := ""
cGetProj   := ""
cGetTotAd  := ""
cGetTotDe  := ""
cGetTotGe  := ""
dDtVenc    := STOD("")
cGetNome   := ""
cGetTipo   := ""
cMGetObs   := ""
cEmpresa   := ""
cFilEmp    := ""
cBancMIS   := ""
cAgenMIS   := ""
cCCMIS     := ""

oDlg:Refresh()

Return Nil 

*---------------------------------------------*
Static Function GrvProfSX1(cGrupo,cPerg,xValor)
*---------------------------------------------*
Local cUserName := ""
Local cMemoProf := ""
Local cLinha    := ""

Local nLin := 0

Local aLinhas := {}

cGrupo := PadR(cGrupo,Len(SX1->X1_GRUPO)," ")

SX1->(DbSetOrder(1))
If SX1->(DbSeek(cGrupo+cPerg,.F.))
	If Type("__cUserId") == "C" .and. !Empty(__cUserId)
		PswOrder(1)
  		PswSeek(__cUserID)
		cUserName := cEmpAnt+PswRet(1)[1,2]

		//Pesquisa o pergunte no Profile
		If FindProfDef(cUserName,cGrupo,"PERGUNTE","MV_PAR")
			//Armazena o memo de parametros do pergunte
			cMemoProf := RetProfDef(cUserName,cGrupo,"PERGUNTE","MV_PAR")

			//Gera array com todas as linhas dos parametros	        
			For nLin:=1 To MlCount(cMemoProf)
				aAdd(aLinhas,AllTrim(MemoLine(cMemoProf,,nLin))+ CHR(13) + CHR(10))
			Next
			
			//Guarda o back-up do valor do par�metro selecionado
			xPreSel := Substr(aLinhas[Val(cPerg)],5,1) 
			
			//Monta uma linha com o novo conteudo do parametro atual.
			// Pos 1 = tipo (numerico/data/caracter...)
			// Pos 2 = '#'
			// Pos 3 = GSC
			// Pos 4 = '#'
			// Pos 5 em diante = conteudo.
            cLinha = SX1->X1_TIPO + "#" + SX1->X1_GSC + "#" + If(SX1->X1_GSC == "C", cValToChar(xValor),AllTrim(Str(xValor)))+ CHR(13) + CHR(10)
			
			//Grava a linha no array
			aLinhas[Val(cPerg)] = cLinha
			
			//Monta o memo atualziado
			cMemoProf := ""
			For nLin:=1 To Len(aLinhas)
   				cMemoProf += aLinhas[nLin]
       		Next
            
			//Grava o profile com o novo memo
			WriteProfDef(cUserName,cGrupo,"PERGUNTE", "MV_PAR", ; 	// Chave antiga
                    	 cUserName,cGrupo, "PERGUNTE", "MV_PAR", ; 	// Chave nova
     					 cMemoProf) 								// Novo conteudo do memo.
			
		EndIf
	EndIf
EndIf

Return Nil                                         

/*
Funcao      : GrvClVl
Parametros  : 
Retorno     : Nil
Objetivos   : Grava Classe de Valor ao integrar expense report
Autor       : Eduardo Romanini
Data/Hora   : 13/09/16 14:00
*/
*---------------------------------*
Static function GrvClVl(cNum,cNome)
*---------------------------------*
Default cNome	:=""

DbSelectArea("CTH")
CTH->(DbSetOrder(1))
//Inclus�o da Classe de Valor caso n�o exista nenhum c�digo igual no CTH
If !(CTH->(DbSeek(xFilial("CTH")+cNum)))
	RecLock("CTH",.T.)
	CTH->CTH_FILIAL	:= xFilial("CTH")
	CTH->CTH_CLVL	:= cNum
	CTH->CTH_CLASSE	:= '2'
	CTH->CTH_NORMAL	:= '1'
	CTH->CTH_DESC01	:= cNome
	CTH->CTH_BLOQ	:= '2'
	CTH->CTH_DTEXIS	:= CtoD('01/01/1980')
	CTH->CTH_CLVLLP	:= cNum
	CTH->(MsUnlock())

EndIf

Return

/*
Funcao      : GrvItCtb
Parametros  : 
Retorno     : Nil
Objetivos   : Grava Item cont�bil ao integrar expense report
Autor       : Eduardo Romanini
Data/Hora   : 14/10/16 11:00
*/
*---------------------------------*
Static function GrvItCtb(cNum,cNome)
*---------------------------------*
Default cNome	:=""

DbSelectArea("CTD")
CTD->(DbSetOrder(1))
//Inclus�o do Item cont�bil caso n�o exista nenhum c�digo igual no CTD
If !(CTD->(DbSeek(xFilial("CTD")+cNum)))
	RecLock("CTD",.T.)
	CTD->CTD_FILIAL	:= xFilial("CTD")
	CTD->CTD_ITEM	:= cNum
	CTD->CTD_CLASSE	:= '2'
	CTD->CTD_DESC01	:= cNome
	CTD->CTD_BLOQ	:= '2'
	CTD->CTD_DTEXIS	:= CtoD('01/01/1980')
	CTD->CTD_ITLP	:= cNum
	CTD->CTD_CLOBRG := '2'
	CTD->CTD_ACCLVL := '1'
	CTD->(MsUnlock())

EndIf

Return

/*
Funcao      : GrvVend
Parametros  : 
Retorno     : Nil
Objetivos   : Grava vendendot ao integrar expense report
Autor       : Eduardo Romanini
Data/Hora   : 14/10/16 11:00
*/
*---------------------------------------*
Static function GrvVend(cNome,cCPF,cMail)
*---------------------------------------*
Local aDados := {}
Private lMsErroAuto

aAdd(aDados, {"A3_FILIAL", xFilial("SA3")		, nil})
aAdd(aDados, {"A3_COD"   , GetSXENum("SA3","A3_COD")  , nil})
aAdd(aDados, {"A3_NOME"  , cNome	, nil})
aAdd(aDados, {"A3_NREDUZ", cNome	, nil})
aAdd(aDados, {"A3_CGC"   , cCPF		, nil})
aAdd(aDados, {"A3_EMAIL" , cMail	, nil})

ConfirmSx8()

MSExecAuto({|x,y|mata040(x,y)},aDados,3) 	

If lMsErroAuto		
	MsgStop("Erro na grava��o do vendedor")	
	MostraErro()
EndIf

Return

/*
Funcao      : getDtVencto
Parametros  : 
Retorno     : Nil
Objetivos   : Retorna a data de vencimento de acordo com a regra estabelecida pela opera��o
OBS			: Regra: vencimento sempre na quarta feira, com um minimo de 3 dias de processamento
Autor       : Jean Victor Rocha
Data/Hora   : 08/12/2016
*/
*---------------------------*
Static function getDtVencto()
*---------------------------*
Local dRet := STOD("")
           
/* Fun��o DOW
Dia da semana/N�mero
Segunda-feira /2
Ter�a-feira   /3
Quarta-feira  /4
Quinta-feira  /5
Sexta-feira   /6
S�bado        /7
Domingo       /1
*/

//Tabela de referencia para calcular a data de vencimento de acordo com a data atual
//{<Data base>,<valor para Dt.Venc.>}
aRefData :=  {  {1,3},;
				{2,9},;
				{3,8},;
				{4,7},;
				{5,6},;
				{6,5},;
				{7,4}} 

dRet := DATE()+aRefData[DOW(DATE())][2]

Return dRet

/*
Funcao      : VldDtVencto
Parametros  : 
Retorno     : Nil
Objetivos   : Valida a data digitada de vencimento.
Autor       : Jean Victor Rocha
Data/Hora   : 08/12/2016
*/
*----------------------------------*
Static function VldDtVencto(dDtVenc)
*----------------------------------*
Local lRet := .T.

//Caso n�o tenha nada em tela carregado, n�o valida a data de vencimento.        
If EMPTY(cGetColab)
	Return lRet
EndIf
      
//Valida a data de vencimento, caso esteja em branco
If lRet .and. EMPTY(dDtVenc)
	MsgInfo("Data de vencimento deve ser informada!","Grant Thornton Brasil.")
	lRet := .F.
EndIf

//Valida a data de vencimento quando informada uma data menor que a atual.
If lRet .and. dDtVenc < DATE() 
	MsgInfo("Data de vencimento n�o pode ser anterior a data atual!","Grant Thornton Brasil.")
	lRet := .F.
EndIf

Return lRet