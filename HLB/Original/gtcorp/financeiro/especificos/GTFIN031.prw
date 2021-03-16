#include "TOPCONN.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"  
#include "Protheus.ch"
#include "Rwmake.ch"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FWBROWSE.CH"

#DEFINE ENTER CHR(13)+CHR(10)

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±?Programa  * GTFIN031.PRW *                                                           ≥±?
±±?Autor     * Guilherme Fernandes Pilan - GFP *                                        ≥±?
±±?Data      * 03/04/2017 - 09:28 *                                                     ≥±?
±±√ƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±?Descricao * RelatÛrio de PosiÁ„o Financeira. *                                       ≥±?
±±?          * Este relatÛrio substitui os relatorios "PosiÁ„o Financeira" (GTRELSE1) * ≥±?
±±?          * e "PosiÁ„o Financeira 2" (GTCORP65), unificando as informaÁıes em um *   ≥±?
±±?          * ˙nico relatÛrio para utilizaÁ„o *                                        ≥±?
±±√ƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±?Uso       * FINANCEIRO                                                               ≥±?
±±¿ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
*-----------------------*
User Function GTFIN031()
*-----------------------*
Private cDest, cArq, oSay1, oSay2, oMeter, nMeter := 0, nEmpresa := 1, nTotRegs
Private oUserParams	:= EasyUserCfg():New("GTFIN031")
Private nHdlPrt := AdvConnection(), nHdlMIS := 0

Private dDtEmDe, dDtEmAte, dDtVODe, dDtVOAte, dDtVRDe, dDtVRAte, dDtBxDe, dDtBxAte, nStaTit := 3
Private cTpTit, cTpLanc, cFinInt, cAging, cBanco, cAgencia, cCCDe, cCCAte, cMoeda, cCliDe, cCliAte, cClLjDe, cClLjAte

	GetPrefs()
	WizardRel()

Return NIL

*--------------------------*
Static Function WizardRel()
*--------------------------*
Local oWizArq, oTitulos, oFont := TFont():New("Arial",,16), i
Local oBrowEmp := FwBrowse():New()
Local aAllGroup	:= FWAllGrpCompany() //Empresas
Local aFinInt := {'A=Ambos','I=Interno','E=Externo'}
Local aSituacao := {'T=Todas','0=Carteira','1=Carteira Simples','2=Cob. Descontada','3=Cob. Caucionada','4=Cob. Vinculada','5=Cob. Advogado','6=Cob. Judicial','7=Cob. CauÁ„o Desconto','F=Carteira Protesto','G=PECLD','H=Cob. Cartorio'}
Local aTpLanc := {'T=Todos','D=ND','F=NF','I=Invoice','R=Rec. Antecipado'}
Local aAging := {'T=Todos','V=A Vencer','1=< 10 dias','2=< 30 dias','3=< 60 dias','4=< 90 dias','5=< 120 dias','6=< 150 dias','7=> 150 dias'}
Local aCpEmp := {	{"WKMARCA"  ,"C",01,0},;
					{"M0_CODIGO","C",02,0},;
					{"M0_NOME"  ,"C",15,0}	}

//********************************//
//**	TELA DE BOAS VINDAS		**//
//********************************//
oWizArq := APWizard():New("PosiÁ„o Financeira Integrada", "Grant Thornton", "RelatÛrio",;
							"RelatÛrio de PosiÁ„o Financeira Integrada." + ENTER +;
							"Este wizard coletar· as informaÁıes necess·rias para a geraÁ„o do relatÛrio.",;
							{||  .T.}, {|| .T.},,,,)

@ 75,14 SAY oSay0 VAR "Deseja selecionar as empresas para geraÁ„o?" SIZE 150,20 OF oWizArq:oMPanel[1] PIXEL
oRadio1 := TRadMenu():New(84,15,{"Sim","N„o"},,oWizArq:oMPanel[1],,,,,,,,100,100,,,,.T.)
oRadio1:bSetGet := {|u|Iif (PCount()==0,nEmpresa,nEmpresa := u)}
oRadio1:bWhen := {|| .T. }

//********************************//
//**	SELECAO DE EMPRESAS		**//
//********************************//

If Select("TMPEMP") > 0
	TMPEMP->(DbClosearea())
Endif     	      

cArqTmp := CriaTrab(aCpEmp,.T.)
DbUseArea(.T.,"DBDCDX",cArqTmp,"TMPEMP",.F.,.F.)

For i := 1 To Len(aAllGroup)
	If aAllGroup[i] <> "YY"
		TMPEMP->(DbAppend())
		TMPEMP->WKMARCA   := "2"
		TMPEMP->M0_CODIGO := aAllGroup[i]
		TMPEMP->M0_NOME   := Posicione("SM0",1,aAllGroup[i],"M0_NOME")
	EndIf
Next i

oWizArq:NewPanel( "Empresas", "Selecione as empresas que ser„o consideradas para geraÁ„o!",{ ||.T.}, {|| nEmpresa == 2 .OR. ValidaEmpresas()}, {|| .T.},, {|| If(nEmpresa == 1, oBrowEmp:Show(), oBrowEmp:Hide())})

oPanel1 := TPanel():New(01,01,"",oWizArq:oMPanel[2],,.T.,,,,294,135)
oSay3  := TSay():Create(oWizArq:oMPanel[2],{|| "RelatÛrio ser· impresso com base nos dados da empresa '" + cEmpAnt +"'." },18,05,,oFont,,,,.T.,CLR_BLUE,,200,20)

oBrowEmp:SetOwner(oPanel1)
oBrowEmp:SetDataTable(.T.)
oBrowEmp:SetAlias("TMPEMP")

// Cria uma coluna de marca/desmarca
oColumn := oBrowEmp:AddMarkColumns({|| If(WKMARCA=="1",'LBOK',IIF(WKMARCA=="2",'LBNO',))},{|| Marca()},{|| MarcaTodos("TMPEMP",@oBrowEmp)})
 
// Adiciona as colunas do Browse
oColumn := FWBrwColumn():New()
oColumn:SetData({||M0_CODIGO})
oColumn:SetTitle("Cod.Emp.")
oColumn:SetSize(5)
oBrowEmp:SetColumns({oColumn})
 
oColumn := FWBrwColumn():New()
oColumn:SetData({||M0_NOME})
oColumn:SetTitle("Empresa")
oColumn:SetSize(15)
oBrowEmp:SetColumns({oColumn})

oBrowEmp:DisableConfig()
oBrowEmp:DisableReport()
oBrowEmp:Activate()

//********************************//
//**	FILTROS	DE PESQUISA		**//
//********************************//
oWizArq:NewPanel( "Filtros", "Selecione os Filtros a serem considerados para a geraÁ„o!",{ ||.T.}/*<bBack>*/, {|| .T.}/*<bNext>*/, {|| .T.}/*<bFinish>*/, /*<.lPanel.>*/, {|| .T.}/*<bExecute>*/ )

oPanel := TPanel():New(01,01,"",oWizArq:oMPanel[3],,.T.,,,,294,135)

// Primeira coluna
@ 05,05 SAY oSay0 VAR "SituaÁ„o do TÌtulo?" SIZE 100,10 OF oPanel PIXEL
oCombo := TComboBox():Create(oPanel,{|u|if(PCount()>0,cTpTit := u,cTpTit)},04,70,aSituacao,55,20,,,,,,.T.,,,,,,,,,'cTpTit')

@ 18,05 SAY oSay0 VAR "Tipo de LanÁamento?" SIZE 100,10 OF oPanel PIXEL
oCombo := TComboBox():Create(oPanel,{|u|if(PCount()>0,cTpLanc := u,cTpLanc)},17,70,aTpLanc,55,20,,,,,,.T.,,,,,,,,,'cTpLanc')

@ 31,05 SAY oSay0 VAR "Financeiro?" SIZE 100,10 OF oPanel PIXEL
oCombo := TComboBox():Create(oPanel,{|u|if(PCount()>0,cFinInt := u,cFinInt)},30,70,aFinInt,55,20,,,,,,.T.,,,,,,,,,'cFinInt')

@ 44,05 SAY oSay0 VAR "Aging?" SIZE 100,10 OF oPanel PIXEL
oCombo := TComboBox():Create(oPanel,{|u|if(PCount()>0,cAging := u,cAging)},43,70,aAging,55,20,,,,,,.T.,,,,,,,,,'cAging')

@ 57,05 SAY oSay0 VAR "Centro de Custo Inicial?" SIZE 100,10 OF oPanel PIXEL
@ 56,70 MSGET cCCDe SIZE 55,05 OF oPanel F3 "CTT" PIXEL

@ 70,05 SAY oSay0 VAR "Centro de Custo Final?" SIZE 100,10 OF oPanel PIXEL
@ 69,70 MSGET cCCAte SIZE 55,05 OF oPanel F3 "CTT" PIXEL

@ 83,05 SAY oSay0 VAR "Moeda?" SIZE 100,10 OF oPanel PIXEL
@ 82,70 MSGET cMoeda SIZE 55,05 OF oPanel VALID (Vazio() .OR. cMoeda $ '123456') PIXEL

@ 96,05 SAY oSay0 VAR "Banco/AgÍncia?" SIZE 100,10 OF oPanel PIXEL
@ 95,70 MSGET cBanco SIZE 15,05 OF oPanel F3 "SA6" PIXEL
@ 95,98 MSGET cAgencia SIZE 15,05 OF oPanel PIXEL

oGrpStTit := TGroup():New( 109,005,132,125,"Status dos tÌtulos:",oPanel,CLR_BLACK,CLR_WHITE,.T.,.F. )
oRadio := TRadMenu():New(117,11,{'Em Aberto			','Baixados			','Ambos'},,oGrpStTit,,,,,,,,100,100,,,,.T.,.T.)
oRadio:bchange := {|| iif(nStaTit==1,(oDt7:Disable(),oDt8:Disable(),dDtBxDe:=CTOD("//"),oDt7:Refresh(),dDtBxAte:=CTOD("//"),oDt8:Refresh()) , (oDt7:Enable(),oDt8:Enable()) )}
oRadio:bSetGet := {|u|Iif (PCount()==0,nStaTit,nStaTit:=u)}
oRadio:bWhen := {|| .T. }

// Segunda coluna
@ 05,150 SAY oSay0 VAR "Data Emiss„o Inicial? " SIZE 100,10 OF oPanel PIXEL
oDt1 := TGet():New(04,215,{|u| if(PCount()>0,dDtEmDe := u,dDtEmDe)},oPanel,50,05,'@D',{|o|},,,,,,.T.,,,,,,,,,	 ,'dDtEmDe')

@ 18,150 SAY oSay0 VAR "Data Emiss„o Final? " SIZE 100,10 OF oPanel PIXEL
oDt2:= TGet():New(17,215,{|u| if(PCount()>0,dDtEmAte := u,dDtEmAte)},oPanel,50,05,'@D',{|o|},,,,,,.T.,,,,,,,,,	 ,'dDtEmAte')

@ 31,150 SAY oSay0 VAR "Data Vcto. Original Inicial? " SIZE 100,10 OF oPanel PIXEL
oDt3 := TGet():New(30,215,{|u| if(PCount()>0,dDtVODe := u,dDtVODe)},oPanel,50,05,'@D',{|o|},,,,,,.T.,,,,,,,,,	 ,'dDtVODe')

@ 44,150 SAY oSay0 VAR "Data Vcto. Original Final? " SIZE 100,10 OF oPanel PIXEL
oDt4:= TGet():New(43,215,{|u| if(PCount()>0,dDtVOAte := u,dDtVOAte)},oPanel,50,05,'@D',{|o|},,,,,,.T.,,,,,,,,,	 ,'dDtVOAte')

@ 57,150 SAY oSay0 VAR "Data Vcto. Real Inicial? " SIZE 100,10 OF oPanel PIXEL
oDt5 := TGet():New(56,215,{|u| if(PCount()>0,dDtVRDe := u,dDtVRDe)},oPanel,50,05,'@D',{|o|},,,,,,.T.,,,,,,,,,	 ,'dDtVRDe')

@ 70,150 SAY oSay0 VAR "Data Vcto. Real Final? " SIZE 100,10 OF oPanel PIXEL
oDt6:= TGet():New(69,215,{|u| if(PCount()>0,dDtVRAte := u,dDtVRAte)},oPanel,50,05,'@D',{|o|},,,,,,.T.,,,,,,,,,	 ,'dDtVRAte')

@ 83,150 SAY oSay0 VAR "Data Baixa Inicial? " SIZE 100,10 OF oPanel PIXEL
oDt7 := TGet():New(82,215,{|u| if(PCount()>0,dDtBxDe := u,dDtBxDe)},oPanel,50,05,'@D',{|o|},,,,,,.T.,,,,,,,,,	 ,'dDtBxDe')

@ 96,150 SAY oSay0 VAR "Data Baixa Final? " SIZE 100,10 OF oPanel PIXEL
oDt8:= TGet():New(95,215,{|u| if(PCount()>0,dDtBxAte := u,dDtBxAte)},oPanel,50,05,'@D',{|o|},,,,,,.T.,,,,,,,,,	 ,'dDtBxAte')

@ 109,150 SAY oSay0 VAR "Cliente Inicial?" SIZE 100,10 OF oPanel PIXEL
@ 108,215 MSGET cCliDe SIZE 17,05 OF oPanel F3 "SA1" PIXEL
@ 108,247 MSGET cClLjDe SIZE 14,05 OF oPanel PIXEL

@ 122,150 SAY oSay0 VAR "Cliente Final?" SIZE 100,10 OF oPanel PIXEL
@ 121,215 MSGET cCliAte SIZE 17,05 OF oPanel F3 "SA1" PIXEL
@ 121,247 MSGET cClLjAte SIZE 14,05 OF oPanel PIXEL

//********************************//
//** PROCESSAMENTO DO RELATORIO	**//
//********************************//            
oWizArq:NewPanel( "Processamento...", "Processando registros...",{ || .F.}, , {|| .F.}, , {|| ExecRelat()})

oSay0  := TSay():Create(oWizArq:oMPanel[4],{||"Processando registros..."},18,05,,oFont,,,,.T.,,,200,20)
oSay1  := TSay():Create(oWizArq:oMPanel[4],{||""},30,05,,oFont,,,,.T.,CLR_BLUE,,200,20)
nMeter := 0
oMeter := TMeter():New(42,20,{|u|if(Pcount()>0,nMeter:=u,nMeter)},0,oWizArq:oMPanel[4],250,34,,.T.,,,,,,,,,)
oMeter:Set(0) 
oSay2 := TSay():Create(oWizArq:oMPanel[4],{|| ""},54,05,,oFont,,,,.T.,CLR_RED,,200,100)

oWizArq:oCancel:bAction := {|oWizArq| oWizArq:oWnd:End()}

//Ativa o Wizard
oWizArq:Activate(.T.)

Return NIL

*--------------------------*
Static Function ExecRelat()
*--------------------------*
Local lRet := .T., i := 0, lGera := .F.
Local cMsgErro := "", cMsgOk := "O RelatÛrio em Excel ser· aberto automaticamente."

Begin Sequence

	If nEmpresa == 2
		TMPEMP->(DbGoTop())
		Do While TMPEMP->(!Eof())
			TMPEMP->(DbDelete())
			TMPEMP->(DbSkip())
		EndDo
		TMPEMP->(DbAppend())
		TMPEMP->WKMARCA   := "1"
		TMPEMP->M0_CODIGO := cEmpAnt
		TMPEMP->M0_NOME   := Posicione("SM0",1,cEmpAnt,"M0_NOME")
	EndIf
	
	cDest := GetTempPath() + "\"
	cArq := "PosicaoFinanceira_" + DTOS(Date()) + "_" + StrTran(Time(),":","") + ".xls"

	SavePrefs()

	CabecalhoXML()
	oSay2:SetText(cMsgOk)

	TMPEMP->(DbGoTop())
	Do While TMPEMP->(!Eof())
		If TMPEMP->WKMARCA == "2"
			TMPEMP->(DbSkip())
			Loop
		EndIf

		If !ExecQuery()
			cMsgErro += "Registros n„o localizados para a empresa '" + TMPEMP->M0_CODIGO + "'." + ENTER
			TMPEMP->(DbSkip())
			Loop
		EndIf

		CorpoXML()
		

		lGera := .T.
		TMPEMP->(DbSkip())
	EndDo

	RodapeXML()

	If !Empty(cMsgErro)
		oSay2:SetText(cMsgErro)
		oSay1:SetText("Processamento concluÌdo.")
	Else
		oSay2:SetText(cMsgOk)
	EndIf
	oMeter:Set(oMeter:nTotal)
	
	If lGera
		SHELLEXECUTE("open",(cDest+cArq),"","",5)   // Gera o arquivo em Excel
	EndIf
	
End Sequence

If nHdlMIS > 0
	TCUnlink(nHdlMIS)
EndIf

Return lRet

*--------------------------*
Static Function ExecQuery()
*--------------------------*
Local cQry := ""

cQry += " SELECT DISTINCT "
cQry += " '" + TMPEMP->M0_CODIGO + "' AS 'CODIGO_EMPRESA', "
cQry += " '" + TMPEMP->M0_NOME + "' AS 'NOME_EMPRESA', "
cQry += " SE1.E1_FILIAL AS 'CODIGO_FILIAL', "
cQry += " CASE WHEN SE1.E1_FILIAL = '' THEN '' ELSE SM0.M0_FILIAL END AS 'NOME_FILIAL', "
cQry += " SE1.E1_FILIAL+SE1.E1_PREFIXO+SE1.E1_NUM AS 'CHAVE_TITULO', "
cQry += " SE1.E1_SITUACA, SE1.E1_NUM, SE1.E1_PREFIXO, "
cQry += " CASE WHEN SE1.E1_CCC = '' THEN '' ELSE SE1.E1_CCC END AS 'E1_CCC', "
cQry += " CONVERT(VARCHAR(10),CONVERT(DateTime, SE1.E1_EMISSAO,103),126) AS 'DT_EMISSAO', "
cQry += " CONVERT(VARCHAR(10),CONVERT(DateTime, SE1.E1_VENCORI,103),126) AS 'DT_VENCORIGI', "
cQry += " CONVERT(VARCHAR(10),CONVERT(DateTime, SE1.E1_VENCREA,103),126) AS 'DT_VENCREAL', "
cQry += " CASE WHEN SE1.E1_BAIXA = '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DateTime, SE1.E1_BAIXA,103),126) END AS 'DATA_BAIXA', "
cQry += " CASE WHEN (SE1.E1_SALDO = 0) THEN '' ELSE DATEDIFF(DAY,SE1.E1_VENCORI,GETDATE()) END AS 'DIAS_VO', "
cQry += " CASE WHEN (SE1.E1_SALDO = 0) THEN '' ELSE DATEDIFF(DAY,SE1.E1_VENCREA,GETDATE()) END AS 'DIAS_VR', "
cQry += " CASE WHEN SE1.E1_SALDO > 0 THEN ROUND((SE1.E1_VLCRUZ * (SE1.E1_SALDO - SE1.E1_DECRESC)) / SE1.E1_VALOR - (CASE WHEN SE1.E1_VALOR >= 215.27 THEN SE1.E1_IRRF+SE1.E1_INSS+SE1.E1_PIS+SE1.E1_CSLL+SE1.E1_COFINS ELSE SE1.E1_IRRF END) ,2) ELSE 0 END AS 'SALDO_RELIQ', "
cQry += " SE1.E1_VALOR, SE1.E1_VLCRUZ, SE1.E1_SALDO, SE1.E1_MOEDA, SE1.E1_TIPO, SE1.E1_PEDIDO, "
cQry += " (SE1.E1_VALOR - SE1.E1_SALDO) AS 'VLR_BMOEDA', "
cQry += " (SE1.E1_VLCRUZ-((SE1.E1_SALDO*SE1.E1_VLCRUZ)/SE1.E1_VALOR)) AS 'VLR_BREAIS',SE1.E1_VALLIQ AS 'VLR_LIQBX', "
cQry += " (SE1.E1_SALDO*SE1.E1_VLCRUZ)/SE1.E1_VALOR AS 'VLR_SREAIS',   '' AS 'SOCIO', '' AS 'GERENTE_CONTA', "
cQry += " SE1.E1_NFELETR, SE1.E1_PORTADO, SE1.E1_AGEDEP, SE1.E1_CONTA, SE1.E1_VENCORI, SE1.E1_VENCREA, "
cQry += " CTT.CTT_DESC01, SA6.A6_NOME, SA3.A3_NOME, "
cQry += " SRA2.RA_NOME AS 'NOME_CONTAB', "
cQry += " SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME, SA1.A1_NREDUZ, SA1.A1_MSBLQL, "
cQry += If(TMPEMP->M0_CODIGO $ "1T|Z3|Z6"," '' AS 'A1_P_EMAIC', "," SA1.A1_P_EMAIC, ")
cQry += " CASE WHEN SC5.C5_MDCONTR = '' THEN '' ELSE SC5.C5_MDCONTR END AS 'C5_MDCONTR', SC5.C5_FILIAL, SC5.C5_P_IDER, "
cQry += " CASE WHEN SE5.E5_ARQCNAB = '' THEN 'Deposito' ELSE 'Arquivo' END AS 'E5_ARQCNAB', ISNULL(SE5.E5_MOTBX,'') AS 'E5_MOTBX', "
cQry += If(TMPEMP->M0_CODIGO $ "1T|Z3"," '' AS 'A1_P_COBND', "," SA1.A1_P_COBND, ")
cQry += If(TMPEMP->M0_CODIGO $ "1T"," '' AS 'A1_P_INTER', "," SA1.A1_P_INTER, ")
cQry += If(TMPEMP->M0_CODIGO $ "1T|Z3|Z5"," '' AS 'CN9_P_NUM' "," ISNULL(LTRIM(CN9.CN9_P_NUM),'') AS 'CN9_P_NUM' ")

cQry += " FROM SE1" + TMPEMP->M0_CODIGO + "0 SE1 "
cQry += " INNER JOIN SIGAMAT SM0 ON SM0.M0_CODIGO = '" + TMPEMP->M0_CODIGO + "' "
cQry += If(!TMPEMP->M0_CODIGO $ "RH|ZB|ZF|ZG|ZA|Z8"," AND SM0.M0_CODFIL = SE1.E1_FILIAL "," ")
cQry += " LEFT JOIN (SELECT TOP 1 * FROM CTT" + TMPEMP->M0_CODIGO + "0 WHERE D_E_L_E_T_ = '') CTT ON CTT.CTT_CUSTO = SE1.E1_CCC AND CTT.D_E_L_E_T_ = '' " 
cQry += " INNER JOIN SA1" + TMPEMP->M0_CODIGO + "0 SA1 ON SA1.A1_COD = SE1.E1_CLIENTE AND SA1.A1_LOJA = SE1.E1_LOJA "
cQry += " LEFT JOIN SC5" + TMPEMP->M0_CODIGO + "0 SC5 ON SC5.C5_NUM = SE1.E1_PEDIDO AND SC5.D_E_L_E_T_ = '' "
cQry += If(!TMPEMP->M0_CODIGO $ "RH|ZB|ZF|ZG|Z8"," AND SC5.C5_FILIAL = SE1.E1_FILIAL "," AND SC5.C5_FILIAL = SE1.E1_FILORIG ")
cQry += " LEFT JOIN CN9" + TMPEMP->M0_CODIGO + "0 CN9 ON CN9.CN9_FILIAL = SC5.C5_FILIAL AND CN9_NUMERO = SC5.C5_MDCONTR "
cQry += "  AND CN9.CN9_CLIENT = SC5.C5_CLIENTE AND CN9.CN9_LOJACL = SC5.C5_LOJACLI AND CN9.D_E_L_E_T_ = '' "
cQry += " LEFT JOIN (SELECT * FROM SE5" + TMPEMP->M0_CODIGO + "0 WHERE D_E_L_E_T_ = '') SE5 ON "
cQry += If(!TMPEMP->M0_CODIGO $ "RH|ZB|ZF|ZG|Z4|Z8"," SE5.E5_FILORIG = SE1.E1_FILIAL AND "," ")
cQry += "  SE5.E5_NUMERO = SE1.E1_NUM AND SE5.E5_PREFIXO = SE1.E1_PREFIXO AND SE5.E5_DATA = SE1.E1_BAIXA AND SE5.E5_PARCELA = SE1.E1_PARCELA "
cQry += "  AND SE5.E5_TIPO = SE1.E1_TIPO AND SE5.E5_CLIFOR = SE1.E1_CLIENTE AND SE5.E5_LOJA = SE1.E1_LOJA AND SE5.D_E_L_E_T_ = '' "
cQry += " LEFT JOIN SA6" + TMPEMP->M0_CODIGO + "0 SA6 ON "
cQry += If(TMPEMP->M0_CODIGO $ "ZG"," SA6.A6_FILIAL = SE1.E1_FILORIG AND ",If(TMPEMP->M0_CODIGO $ "Z8|CH"," "," SA6.A6_FILIAL = SE1.E1_FILIAL AND "))
cQry += " SA6.A6_COD = SE1.E1_PORTADO AND SA6.A6_AGENCIA = SE1.E1_AGEDEP AND SA6.A6_NUMCON = SE1.E1_CONTA AND SA6.D_E_L_E_T_ = '' "
cQry += " LEFT JOIN SA3" + TMPEMP->M0_CODIGO + "0 SA3 ON SA3.A3_COD = SA1.A1_VEND AND SA3.D_E_L_E_T_ = '' "
//cQry += " LEFT JOIN SRA" + TMPEMP->M0_CODIGO + "0 SRA1 ON SRA1.RA_CIC = SA1.A1_P_GECTA "
cQry += " LEFT JOIN (SELECT TOP 1 * FROM SRA" + TMPEMP->M0_CODIGO + "0 WHERE D_E_L_E_T_ = '') SRA2 ON SRA2.RA_CIC = SA1.A1_P_GECTB AND SRA2.D_E_L_E_T_ = '' "
cQry += " WHERE SE1.D_E_L_E_T_ = '' AND SE1.E1_VALOR > 0 AND SA1.D_E_L_E_T_ = '' "
//cQry += " AND SA3.D_E_L_E_T_ = ''  "

If cTpTit <> "T"
	cQry +=" AND SE1.E1_SITUACA = '" + cTpTit + "' "
EndIf

If cTpLanc == "T"
	cQry +=" AND (SE1.E1_TIPO = 'ND' OR SE1.E1_TIPO = 'NF' OR SE1.E1_TIPO = 'RA')"
Else
	If cTpLanc == "D"
		cQry +=" AND SE1.E1_TIPO = 'ND' "
	ElseIf cTpLanc == "F"
		cQry +=" AND SE1.E1_TIPO = 'NF' "
	ElseIf cTpLanc == "R"
		cQry +=" AND SE1.E1_TIPO = 'RA' "
	EndIf
EndIf
If cTpLanc == "I" //.OR. cTpLanc == "T"
	cQry +=" AND SE1.E1_MOEDA <> '1' "
ElseIf !Empty(cMoeda)
	cQry +=" AND SE1.E1_MOEDA = '" + cMoeda + "' "
EndIf

If cFinInt == "I"
	cQry +=" AND SA1.A1_P_INTER = '1' "
ElseIf cFinInt == "E"
	cQry +=" AND SA1.A1_P_INTER = '2' "
EndIf

If cAging == "V"
	cQry +=" AND (SE1.E1_SALDO <> 0) AND DATEDIFF(DAY,SE1.E1_VENCORI,GETDATE()) <= 0 "
	cQry +=" AND (SE1.E1_SALDO <> 0) AND DATEDIFF(DAY,SE1.E1_VENCREA,GETDATE()) <= 0 "
ElseIf cAging == "1"
	cQry +=" AND (SE1.E1_SALDO <> 0) AND DATEDIFF(DAY,SE1.E1_VENCORI,GETDATE()) > 0 "
	cQry +=" AND (SE1.E1_SALDO <> 0) AND DATEDIFF(DAY,SE1.E1_VENCORI,GETDATE()) <= 10 "
	cQry +=" AND (SE1.E1_SALDO <> 0) AND DATEDIFF(DAY,SE1.E1_VENCREA,GETDATE()) > 0 "
	cQry +=" AND (SE1.E1_SALDO <> 0) AND DATEDIFF(DAY,SE1.E1_VENCREA,GETDATE()) <= 10 "
ElseIf cAging == "2"
	cQry +=" AND (SE1.E1_SALDO <> 0) AND DATEDIFF(DAY,SE1.E1_VENCORI,GETDATE()) > 10 "
	cQry +=" AND (SE1.E1_SALDO <> 0) AND DATEDIFF(DAY,SE1.E1_VENCORI,GETDATE()) <= 30 "
	cQry +=" AND (SE1.E1_SALDO <> 0) AND DATEDIFF(DAY,SE1.E1_VENCREA,GETDATE()) > 10 "
	cQry +=" AND (SE1.E1_SALDO <> 0) AND DATEDIFF(DAY,SE1.E1_VENCREA,GETDATE()) <= 30 "
ElseIf cAging == "3"
	cQry +=" AND (SE1.E1_SALDO <> 0) AND DATEDIFF(DAY,SE1.E1_VENCORI,GETDATE()) > 30 "
	cQry +=" AND (SE1.E1_SALDO <> 0) AND DATEDIFF(DAY,SE1.E1_VENCORI,GETDATE()) <= 60 "
	cQry +=" AND (SE1.E1_SALDO <> 0) AND DATEDIFF(DAY,SE1.E1_VENCREA,GETDATE()) > 30 "
	cQry +=" AND (SE1.E1_SALDO <> 0) AND DATEDIFF(DAY,SE1.E1_VENCREA,GETDATE()) <= 60 "
ElseIf cAging == "4"
	cQry +=" AND (SE1.E1_SALDO <> 0) AND DATEDIFF(DAY,SE1.E1_VENCORI,GETDATE()) > 60 "
	cQry +=" AND (SE1.E1_SALDO <> 0) AND DATEDIFF(DAY,SE1.E1_VENCORI,GETDATE()) <= 90 "
	cQry +=" AND (SE1.E1_SALDO <> 0) AND DATEDIFF(DAY,SE1.E1_VENCREA,GETDATE()) > 60 "
	cQry +=" AND (SE1.E1_SALDO <> 0) AND DATEDIFF(DAY,SE1.E1_VENCREA,GETDATE()) <= 90 "
ElseIf cAging == "5"
	cQry +=" AND (SE1.E1_SALDO <> 0) AND DATEDIFF(DAY,SE1.E1_VENCORI,GETDATE()) > 90 "
	cQry +=" AND (SE1.E1_SALDO <> 0) AND DATEDIFF(DAY,SE1.E1_VENCORI,GETDATE()) <= 120 "
	cQry +=" AND (SE1.E1_SALDO <> 0) AND DATEDIFF(DAY,SE1.E1_VENCREA,GETDATE()) > 90 "
	cQry +=" AND (SE1.E1_SALDO <> 0) AND DATEDIFF(DAY,SE1.E1_VENCREA,GETDATE()) <= 120 "
ElseIf cAging == "6"
	cQry +=" AND (SE1.E1_SALDO <> 0) AND DATEDIFF(DAY,SE1.E1_VENCORI,GETDATE()) > 120 "
	cQry +=" AND (SE1.E1_SALDO <> 0) AND DATEDIFF(DAY,SE1.E1_VENCORI,GETDATE()) <= 150 "
	cQry +=" AND (SE1.E1_SALDO <> 0) AND DATEDIFF(DAY,SE1.E1_VENCREA,GETDATE()) > 120 "
	cQry +=" AND (SE1.E1_SALDO <> 0) AND DATEDIFF(DAY,SE1.E1_VENCREA,GETDATE()) <= 150 "
ElseIf cAging == "7"
	cQry +=" AND (SE1.E1_SALDO <> 0) AND DATEDIFF(DAY,SE1.E1_VENCORI,GETDATE()) > 150 "
	cQry +=" AND (SE1.E1_SALDO <> 0) AND DATEDIFF(DAY,SE1.E1_VENCREA,GETDATE()) > 150 "
EndIf

If !Empty(cCCDe)
	cQry +=" AND SE1.E1_CCC >= '" + cCCDe + "' "
EndIf
If !Empty(cCCAte)
	cQry +=" AND SE1.E1_CCC <= '" + cCCAte + "' "
EndIf

If !Empty(cBanco)
	cQry +=" AND SE1.E1_PORTADO = '" + cBanco + "' "
EndIf
If !Empty(cAgencia)
	cQry +=" AND SE1.E1_AGEDEP = '" + cAgencia + "' "
EndIf

If !Empty(dDtEmDe)
	cQry +=" AND SE1.E1_EMISSAO >= '" + DTOS(dDtEmDe) + "' "
EndIf
If !Empty(dDtEmAte)
	cQry +=" AND SE1.E1_EMISSAO <= '" + DTOS(dDtEmAte) + "' "
EndIf

If !Empty(dDtVODe)
	cQry +=" AND SE1.E1_VENCORI >= '" + DTOS(dDtVODe) + "' "
EndIf
If !Empty(dDtVOAte)
	cQry +=" AND SE1.E1_VENCORI <= '" + DTOS(dDtVOAte) + "' "
EndIf

If !Empty(dDtVRDe)
	cQry +=" AND SE1.E1_VENCREA >= '" + DTOS(dDtVRDe) + "' "
EndIf
If !Empty(dDtVRAte)
	cQry +=" AND SE1.E1_VENCREA <= '" + DTOS(dDtVRAte) + "' "
EndIf

Do Case
	Case nStaTit == 1	//Em Aberto
		cQry += " AND SE1.E1_SALDO > 0 "
	Case nStaTit == 2	//Baixado
		cQry += " AND SE1.E1_SALDO = 0 "
		If !Empty(dDtBxDe) .and. !Empty(dDtBxAte)
			cQry += " AND SE1.E1_BAIXA BETWEEN '"+DtoS(dDtBxDe)+"' AND '"+DtoS(dDtBxAte)+"' "
		ElseIf !Empty(dDtBxDe)
			cQry += " AND SE1.E1_BAIXA >= '"+DtoS(dDtBxDe)+"' "
		ElseIf !Empty(dDtBxAte)
			cQry += " AND SE1.E1_BAIXA <= '"+DtoS(dDtBxAte)+"' "
		EndIf
	Case nStaTit == 3	//Ambos
		If !Empty(dDtBxDe) .and. !Empty(dDtBxAte)
			cQry += " AND ( SE1.E1_BAIXA BETWEEN '"+DtoS(dDtBxDe)+"' AND '"+DtoS(dDtBxAte)+"' OR SE1.E1_BAIXA='' ) "
		ElseIf !Empty(dDtBxDe)
			cQry += " AND ( SE1.E1_BAIXA >= '"+DtoS(dDtBxDe)+"' OR SE1.E1_BAIXA='' ) "
		ElseIf !Empty(dDtBxAte)
			cQry += " AND ( SE1.E1_BAIXA <= '"+DtoS(dDtBxAte)+"' OR SE1.E1_BAIXA='' ) "
		EndIf
EndCase	

If !Empty(cCliDe)
	cQry +=" AND SE1.E1_CLIENTE >= '" + cCliDe + "' "
	If !Empty(cClLjDe)
		cQry +=" AND SE1.E1_LOJA >= '" + cClLjDe + "' "
	EndIf
EndIf
If !Empty(cCliAte)
	cQry +=" AND SE1.E1_CLIENTE <= '" + cCliAte + "' "
	If !Empty(cClLjAte)
		cQry +=" AND SE1.E1_LOJA <= '" + cClLjAte + "' "
	EndIf
EndIf

cQry += " ORDER BY SE1.E1_FILIAL, SE1.E1_NUM, SE1.E1_PREFIXO "

If Select("QRY") # 0
	QRY->(DbCloseArea())
EndIf

DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"QRY",.T.,.T.)
TCSetField("QRY","E1_VENCORI","D")
TCSetField("QRY","E1_VENCREA","D")

QRY->(DbGoTop())
nTotRegs := Contar("QRY","!Eof()")
QRY->(DbGoTop())

oSay1:SetText("Empresa '" + TMPEMP->M0_CODIGO + "' - Localizando registros...")

Return (QRY->(!Bof()) .AND. QRY->(!Eof()))

*-----------------------------*
Static Function CabecalhoXML()
*-----------------------------*
Local cXML := ""
// Tratamento de estilos da Planilha.
cXML += '<?xml version="1.0"?>'
cXML += '<?mso-application progid="Excel.Sheet"?>'
cXML += '<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"'
cXML += ' xmlns:o="urn:schemas-microsoft-com:office:office"'
cXML += ' xmlns:x="urn:schemas-microsoft-com:office:excel"'
cXML += ' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"'
cXML += ' xmlns:html="http://www.w3.org/TR/REC-html40">'
cXML += ' <Styles>'
cXML += '  <Style ss:ID="Default" ss:Name="Normal">'
cXML += '   <Alignment ss:Vertical="Bottom"/>'
cXML += '   <Borders/>'
cXML += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>'
cXML += '   <Interior/>'
cXML += '   <NumberFormat/>'
cXML += '   <Protection/>'
cXML += '  </Style>'
cXML += '  <Style ss:ID="Cabecalho">'
cXML += '   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>'
cXML += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="12.5" ss:Color="#7B68EE"'
cXML += '    ss:Bold="1"/>'
cXML += '  </Style>'
cXML += '  <Style ss:ID="Titulo">'
cXML += '   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>'
cXML += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#FFFFFF"'
cXML += '    ss:Bold="1"/>'
cXML += '   <Interior ss:Color="#7B68EE" ss:Pattern="Solid"/>'
cXML += '  </Style>'
cXML += '  <Style ss:ID="Linha1">'	// Cor 1 - String
cXML += '   <Interior ss:Color="#C2C2DC" ss:Pattern="Solid"/>'
cXML += '   <NumberFormat ss:Format="@"/>'
cXML += '  </Style>'
cXML += '  <Style ss:ID="Linha2">'	// Cor 2 - String
cXML += '   <Interior ss:Color="#E6E6FA" ss:Pattern="Solid"/>'
cXML += '   <NumberFormat ss:Format="@"/>'
cXML += '  </Style>'
cXML += '  <Style ss:ID="Linha3">'	// Cor 1 - Data
cXML += '   <Interior ss:Color="#C2C2DC" ss:Pattern="Solid"/>'
cXML += '   <NumberFormat ss:Format="Short Date"/>'
cXML += '  </Style>'
cXML += '  <Style ss:ID="Linha4">'	// Cor 2 - Data
cXML += '   <Interior ss:Color="#E6E6FA" ss:Pattern="Solid"/>'
cXML += '   <NumberFormat ss:Format="Short Date"/>'
cXML += '  </Style>'
cXML += '  <Style ss:ID="Linha5">'	// Cor 1 - Numero (2 casas decimais)
cXML += '   <Interior ss:Color="#C2C2DC" ss:Pattern="Solid"/>'
cXML += '   <NumberFormat ss:Format="Standard"/>'
cXML += '  </Style>'
cXML += '  <Style ss:ID="Linha6">'	// Cor 2 - Numero (2 casas decimais)
cXML += '   <Interior ss:Color="#E6E6FA" ss:Pattern="Solid"/>'
cXML += '   <NumberFormat ss:Format="Standard"/>'
cXML += '  </Style>'
cXML += '  <Style ss:ID="Linha7">'	// Cor 1 - Numero (Inteiro)
cXML += '   <Interior ss:Color="#C2C2DC" ss:Pattern="Solid"/>'
cXML += '   <NumberFormat ss:Format="0"/>'
cXML += '  </Style>'
cXML += '  <Style ss:ID="Linha8">'	// Cor 2 - Numero (Inteiro)
cXML += '   <Interior ss:Color="#E6E6FA" ss:Pattern="Solid"/>'
cXML += '   <NumberFormat ss:Format="0"/>'
cXML += '  </Style>'
cXML += ' </Styles>'
cXML := GrvXML(cXML)

// CriaÁ„o de Pasta de Trabalho
cXML += ' <Worksheet ss:Name="Posicao Financeira">'
cXML += '  <Table ss:ExpandedColumnCount="51" ss:ExpandedRowCount="999999" x:FullColumns="1"'
cXML += '   x:FullRows="1" ss:DefaultRowHeight="15">'
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="80"/>'	//Codigo Empresa
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="150"/>'	//Nome Empresa
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="62"/>'	//Filial
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="150"/>'	//Nome Filial
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="72"/>'	//CÛdigo Cliente
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="62"/>'	//Loja Cliente
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="250"/>'	//Nome Cliente
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="150"/>'	//Nome Fantasia
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="250"/>'	//Email
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="100"/>'	//Cliente Bloqueado?
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="100"/>'	//Emite ND?
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="150"/>'	//Chave TÌtulo
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="100"/>'	//SituaÁ„o TÌtulo
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="64"/>'	//N˙mero TÌtulo
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="62"/>'	//Prefixo
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="64"/>'	//Centro Custo
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="200"/>'	//DescriÁ„o Centro Custo
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="64"/>'	//Data Emiss„o
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="100"/>'	//Data Vencimento Original
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="72"/>'	//Data Vencimento Real
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="100"/>'	//Valor
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="100"/>'	//Valor R$
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="100"/>'	//Valor Baixado
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="100"/>'	//Valor Baixado R$
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="100"/>'	//Valor Liq. Baixado R$
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="100"/>'	//Valor Saldo
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="100"/>'	//Valor Saldo R$
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="100"/>'	//Valor Saldo R$
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="72"/>'	//Moeda
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="72"/>'	//Tipo
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="72"/>'	//Pedido de Venda
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="150"/>'	//SÛcio
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="150"/>'	//Gerente de Conta
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="150"/>'	//Gerente Contabil
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="64"/>'	//Data Baixa
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="72"/>'	//Motivo Baixa
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="100"/>'	//NFS-e
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="100"/>'	//Tipo Baixa
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="62"/>'	//Banco
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="72"/>'	//Agencia
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="150"/>'	//Nome Banco
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="72"/>'	//Conta Corrente
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="100"/>'	//Dias Atraso Vencimento Original
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="100"/>'	//Dias Atraso Vencimento Real
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="150"/>'	//Aging Vencimento Original
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="150"/>'	//Aging Vencimento Real
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="62"/>'	//Financeiro Interno
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="100"/>'	//Contrato
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="72"/>'	//Projeto
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="100"/>'	//Proposta
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="72"/>'	//¡rea

cXML += '   <Row ss:AutoFitHeight="0" ss:Height="15.75">'
cXML += '    <Cell ss:MergeAcross="49" ss:StyleID="Cabecalho"><Data ss:Type="String">Posi&ccedil;&atilde;o Financeira</Data></Cell>'
cXML += '   </Row>'
cXML += '   <Row ss:AutoFitHeight="0">'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">C&oacute;digo Empresa</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">Nome Empresa</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">C&oacute;digo Filial</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">Nome Filial</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">C&oacute;digo Cliente</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">Loja</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">Nome Cliente</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">Nome Fantasia</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">E-mail</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">Cliente Bloqueado&#63;</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">Cliente emite ND&#63;</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">Chave T&iacute;tulo</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">Situa&#231;&atilde;o T&iacute;tulo</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">T&iacute;tulo</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">Prefixo</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">Centro Custo</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">Descri&#231;&atilde;o Centro Custo</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">Data Emiss&atilde;o</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">Data Venc. Original</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">Data Venc. Real</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">Valor Moeda</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">Valor R&#36;</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">Valor Baixado Moeda</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">Valor Baixado R&#36;</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">Valor Liq. Baixado R&#36;</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">Valor Saldo Moeda</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">Valor Saldo R&#36;</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">Valor Saldo Liq. R&#36;</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">Moeda</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">Tipo</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">Pedido Venda</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">S&oacute;cio</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">Gerente Conta</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">Gerente Contabil</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">Data Baixa</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">Motivo Baixa</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">NFS-e</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">Tipo Baixa</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">Banco</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">Ag&ecirc;ncia</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">Nome Banco</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">Conta Corrente</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">Dias Atraso V.O.</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">Dias Atraso V.R.</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">Aging V.O.</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">Aging V.R.</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">Financeiro</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">Contrato</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">Projeto</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">Proposta</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">&Aacute;rea</Data></Cell>'
cXML += '   </Row>'
cXML := GrvXML(cXML)

Return NIL

*-------------------------*
Static Function CorpoXML()
*-------------------------*
Local i := 1, nReg := 0
Local cXML := ""

oMeter:SetTotal(nTotRegs)

Do While QRY->(!Eof())
	nReg++
	oSay1:SetText("Empresa '" + QRY->CODIGO_EMPRESA + "' - Registro: " + cValToChar(nReg) + " / " + cValToChar(nTotRegs))
	oMeter:Set(nReg)
	cXML += '   <Row ss:AutoFitHeight="0">'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"S",i) + '"><Data ss:Type="String">'  + QRY->CODIGO_EMPRESA				+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"S",i) + '"><Data ss:Type="String">'  + QRY->NOME_EMPRESA				+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"S",i) + '"><Data ss:Type="String">'  + QRY->CODIGO_FILIAL				+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"S",i) + '"><Data ss:Type="String">'  + QRY->NOME_FILIAL				+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"S",i) + '"><Data ss:Type="String">'  + QRY->A1_COD						+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"S",i) + '"><Data ss:Type="String">'  + QRY->A1_LOJA					+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"S",i) + '"><Data ss:Type="String">'  + QRY->A1_NOME					+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"S",i) + '"><Data ss:Type="String">'  + CharXML(QRY->A1_NREDUZ)			+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"S",i) + '"><Data ss:Type="String">'  + CharXML(Lower(QRY->A1_P_EMAIC))	+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"S",i) + '"><Data ss:Type="String">'  + DePara(3,QRY->A1_MSBLQL)		+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"S",i) + '"><Data ss:Type="String">'  + DePara(9,QRY->A1_P_COBND)		+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"S",i) + '"><Data ss:Type="String">'  + AllTrim(QRY->CHAVE_TITULO)		+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"S",i) + '"><Data ss:Type="String">'  + DePara(4)						+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"S",i) + '"><Data ss:Type="String">'  + QRY->E1_NUM						+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"S",i) + '"><Data ss:Type="String">'  + QRY->E1_PREFIXO					+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"S",i) + '"><Data ss:Type="String">'  + QRY->E1_CCC						+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"S",i) + '"><Data ss:Type="String">'  + QRY->CTT_DESC01					+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"D",i) + '"><Data ss:Type="DateTime">'+ QRY->DT_EMISSAO					+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"D",i) + '"><Data ss:Type="DateTime">'+ QRY->DT_VENCORIGI				+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"D",i) + '"><Data ss:Type="DateTime">'+ QRY->DT_VENCREAL				+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"N",i) + '"><Data ss:Type="Number">'  + cValToChar(QRY->E1_VALOR)		+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"N",i) + '"><Data ss:Type="Number">'  + cValToChar(QRY->E1_VLCRUZ)		+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"N",i) + '"><Data ss:Type="Number">'  + cValToChar(QRY->VLR_BMOEDA)		+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"N",i) + '"><Data ss:Type="Number">'  + cValToChar(QRY->VLR_BREAIS)		+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"N",i) + '"><Data ss:Type="Number">'  + cValToChar(QRY->VLR_LIQBX)		+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"N",i) + '"><Data ss:Type="Number">'  + cValToChar(QRY->E1_SALDO)		+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"N",i) + '"><Data ss:Type="Number">'  + cValToChar(QRY->VLR_SREAIS)		+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"N",i) + '"><Data ss:Type="Number">'  + cValToChar(QRY->SALDO_RELIQ)	+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"S",i) + '"><Data ss:Type="String">'  + DePara(1)						+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"S",i) + '"><Data ss:Type="String">'  + QRY->E1_TIPO					+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"S",i) + '"><Data ss:Type="String">'  + QRY->E1_PEDIDO					+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"S",i) + '"><Data ss:Type="String">'  + EmailSocio()					+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"S",i) + '"><Data ss:Type="String">'  + QRY->A3_NOME					+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"S",i) + '"><Data ss:Type="String">'  + QRY->NOME_CONTAB				+ '</Data></Cell>'
	If !Empty(QRY->DATA_BAIXA)
		cXML += '    <Cell ss:StyleID="' + DePara(0,"D",i) + '"><Data ss:Type="DateTime">'+ QRY->DATA_BAIXA				+ '</Data></Cell>'
	Else
		cXML += '    <Cell ss:StyleID="' + DePara(0,"D",i) + '"/>'
	EndIf
	cXML += '    <Cell ss:StyleID="' + DePara(0,"S",i) + '"><Data ss:Type="String">'  + DePara(6)						+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"S",i) + '"><Data ss:Type="String">'  + QRY->E1_NFELETR					+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"S",i) + '"><Data ss:Type="String">'  + QRY->E5_ARQCNAB					+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"S",i) + '"><Data ss:Type="String">'  + QRY->E1_PORTADO					+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"S",i) + '"><Data ss:Type="String">'  + QRY->E1_AGEDEP					+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"S",i) + '"><Data ss:Type="String">'  + QRY->A6_NOME					+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"S",i) + '"><Data ss:Type="String">'  + QRY->E1_CONTA					+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"I",i) + '"><Data ss:Type="Number">'  + cValToChar(QRY->DIAS_VO)		+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"I",i) + '"><Data ss:Type="Number">'  + cValToChar(QRY->DIAS_VR)		+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"S",i) + '"><Data ss:Type="String">'  + DePara(8,QRY->DIAS_VO)			+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"S",i) + '"><Data ss:Type="String">'  + DePara(8,QRY->DIAS_VR)			+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"S",i) + '"><Data ss:Type="String">'  + DePara(3,QRY->A1_P_INTER)		+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"S",i) + '"><Data ss:Type="String">'  + DePara(2,QRY->C5_MDCONTR)		+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"S",i) + '"><Data ss:Type="String">'  + DePara(2,QRY->C5_P_IDER)		+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"S",i) + '"><Data ss:Type="String">'  + DePara(2,QRY->CN9_P_NUM)		+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"S",i) + '"><Data ss:Type="String">'  + DePara(7)						+ '</Data></Cell>'
	cXML += '   </Row>'
	i++
	QRY->(DbSkip())
	
	If Len(cXML) >= 1000000		//Proximo a 1Mega
		cXML := GrvXML(cXML)
	EndIf
EndDo

cXML := GrvXML(cXML)
Return NIL

*--------------------------*
Static Function RodapeXML()
*--------------------------*
Local cXML := ""

cXML += '  </Table>'

// Tratamento para travar as duas primeiras linhas do cabeÁalho, mantendo-as sempre visÌveis.
cXML += '  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">'
cXML += '   <FreezePanes/>'
cXML += '   <FrozenNoSplit/>'
cXML += '   <SplitHorizontal>2</SplitHorizontal>'
cXML += '   <TopRowBottomPane>2</TopRowBottomPane>'
cXML += '   <ActivePane>2</ActivePane>'
cXML += '   <Panes>'
cXML += '    <Pane><Number>3</Number></Pane>'
cXML += '    <Pane><Number>2</Number><ActiveRow>0</ActiveRow></Pane>'
cXML += '   </Panes>'
cXML += '  </WorksheetOptions>'

cXML += ' </Worksheet>'
cXML += ' </Workbook>'

cXML := GrvXML(cXML)
Return 

*-------------------------------------*
Static Function DePara(nTipo,cCampo,i)
*-------------------------------------*
Local xRet

Do Case
	Case nTipo == 0	//Tratamento de tipo de celula
		/*******************************************************************************/
		/* Tratamento para definir cor da linha, mantendo o tipo de conteudo da celula */
		/*******************************************************************************/
		If cCampo == "S"		// String
			xRet :=  If(i % 2 == 0,"Linha1","Linha2")
		ElseIf cCampo == "D"	// Data
			xRet :=  If(i % 2 == 0,"Linha3","Linha4")
		ElseIf cCampo == "N"	// Numero com casas decimais
			xRet :=  If(i % 2 == 0,"Linha5","Linha6")
		ElseIf cCampo == "I"	// Numero inteiro
			xRet :=  If(i % 2 == 0,"Linha7","Linha8")
		EndIf

	Case nTipo == 1		//Moeda
		xRet := QRY->E1_MOEDA
		Do Case
			Case QRY->E1_MOEDA == 1
				xRet := "Real"
			Case QRY->E1_MOEDA == 2
				xRet := "D&oacute;lar"
			Case QRY->E1_MOEDA == 3
				xRet := "Libra"
			Case QRY->E1_MOEDA == 4
				xRet := "Real Gerencial"
			Case QRY->E1_MOEDA == 5
				xRet := "Euro"
			Case QRY->E1_MOEDA == 6
				xRet := "D&oacute;lar Canadense"
		End Case

	Case nTipo == 2		//Tratamento para devolver valor vazio, caso n„o possua conteudo no campo (String)
		xRet := If(!Empty(AllTrim(cCampo)),cCampo,"")

	Case nTipo == 3		//Tratamento Sim/N„o
		xRet := If(cCampo == "1","Sim","N&atilde;o")
	
	Case nTipo == 4		//Campo SituaÁ„o do TÌtulo
		xRet := QRY->E1_SITUACA
		Do Case
			Case QRY->E1_SITUACA == "0"
				xRet := "Carteira"
			Case QRY->E1_SITUACA == "1"
				xRet := "Cob.Simples"
			Case QRY->E1_SITUACA == "2"
				xRet := "Descontada"
			Case QRY->E1_SITUACA == "3"
				xRet := "Caucionada"
			Case QRY->E1_SITUACA == "4"
				xRet := "Vinculada"
			Case QRY->E1_SITUACA == "5"
				xRet := "Advogado"
			Case QRY->E1_SITUACA == "6"
				xRet := "Judicial"
			Case QRY->E1_SITUACA == "7"
				xRet := "CauÁ„o Desconto"
			Case QRY->E1_SITUACA == "F"
				xRet := "Protesto"
			Case QRY->E1_SITUACA == "G"
				xRet := "PECLD"
			Case QRY->E1_SITUACA == "H"
				xRet := "Cartorio"
		End Case
	
	Case nTipo == 6		//Motivo de Baixa
		If Empty(AllTrim(QRY->DATA_BAIXA))
			xRet := ""
		Else
			xRet := QRY->E5_MOTBX
			Do Case
				Case QRY->E5_MOTBX == "CAN"
					xRet := "Cancelado"
				Case QRY->E5_MOTBX == "NOR"
					xRet := "Normal"
				Case QRY->E5_MOTBX == "DEV"
					xRet := "Devolu&ccedil;&atilde;o"
			End Case
		EndIf
	
	Case nTipo == 7		//¡rea
		xRet := ""
		Do Case
			Case Left(QRY->CN9_P_NUM,3) == "AUD"
				xRet := "Auditoria"
			Case Left(QRY->CN9_P_NUM,3) == "ADV"
				xRet := "Advisory"
			Case Left(QRY->CN9_P_NUM,3) == "DUE"
				xRet := "Due Diligence"
			Case Left(QRY->CN9_P_NUM,3) == "TAX"
				xRet := "TAX"
			Case Left(QRY->CN9_P_NUM,3) == "TAS"
				xRet := "TAS"
		End Case
	
	Case nTipo == 8		//Aging Vencimento Original / Vencimento Real
		Do Case
			Case cCampo <= 0
				xRet := "A vencer"
			Case cCampo > 0 .AND. cCampo <= 10
				xRet := "< 10 dias"
			Case cCampo > 10 .AND. cCampo <= 30
				xRet := "< 30 dias"
			Case cCampo > 30 .AND. cCampo <= 60
				xRet := "< 60 dias"
			Case cCampo > 60 .AND. cCampo <= 90
				xRet := "< 90 dias"
			Case cCampo > 90 .AND. cCampo <= 120
				xRet := "< 120 dias"
			Case cCampo > 120 .AND. cCampo <= 150
				xRet := "< 150 dias"
			Case cCampo > 150
				xRet := "> 150 dias"
			Otherwise
				xRet := "Sem range planejado"
		End Case
	Case nTipo == 9		//Tratamento Sim/N„o
		xRet := If(cCampo == "S","Sim","N&atilde;o")
	
End Case

Return xRet

*----------------------*
Static Function Marca()
*----------------------*
Local cRec	:= TMPEMP->(RECNO())

TMPEMP->(DbGoTo(cRec))
If RecLock("TMPEMP",.F.)
	TMPEMP->WKMARCA:=IIF(TMPEMP->WKMARCA=="1","2","1") 
	TMPEMP->(MsUnlock())
EndIf

Return .T.

*-----------------------------------*
Static Function MarcaTodos(cAlias,o)
*-----------------------------------*
Local cAux := ""
(cAlias)->(DbGoTop())

cAux := IIF((cAlias)->WKMARCA=="1","2","1")

While (cAlias)->(!EOF())
	(cAlias)->(RecLock(cAlias,.F.))
	(cAlias)->WKMARCA := cAux 
	(cAlias)->(MsUnlock())
	(cAlias)->(DbSkip())
EndDo
                   
o:Refresh(.T.)
Return .T.

*-----------------------------*
Static Function CharXML(cData)
*-----------------------------*                         
Local i
Local aChar := {{"&","&amp;"},;
				{'¡','&Aacute;'},{'·','&aacute;'},{'¬','&Acirc;'} ,{'‚','&acirc;'} ,{'¿','&Agrave;'},{'‡','&agrave;'},;
				{'≈','&Aring;'} ,{'Â','&aring;'} ,{'√','&Atilde;'},{'„','&atilde;'},{'ƒ','&Auml;'}  ,{'‰','&auml;'}  ,;
				{'∆','&AElig;'} ,{'Ê','&aelig;'} ,{'…','&Eacute;'},{'È','&eacute;'},{' ','&Ecirc;'} ,{'Í','&ecirc;'} ,;
				{'»','&Egrave;'},{'Ë','&egrave;'},{'À','&Euml;'}  ,{'Î','&euml;'}  ,{'–','&ETH;'}   ,{'','&eth;'}   ,;
				{'Õ','&Iacute;'},{'Ì','&iacute;'},{'Œ','&Icirc;'} ,{'Ó','&icirc;'} ,{'Ã','&Igrave;'},{'Ï','&igrave;'},;
				{'œ','&Iuml;'}  ,{'Ô','&iuml;'}  ,{'”','&Oacute;'},{'Û','&oacute;'},{'‘','&Ocirc;'} ,{'Ù','&ocirc;'} ,;
				{'“','&Ograve;'},{'Ú','&ograve;'},{'ÿ','&Oslash;'},{'¯','&oslash;'},{'’','&Otilde;'},{'ı','&otilde;'},;
				{'÷','&Ouml;'}  ,{'ˆ','&ouml;'}  ,{'⁄','&Uacute;'},{'˙','&uacute;'},{'€','&Ucirc;'} ,{'˚','&ucirc;'} ,;
				{'Ÿ','&Ugrave;'},{'˘','&ugrave;'},{'‹','&Uuml;'}  ,{'¸','&uuml;'}  ,{'«','&Ccedil;'},{'Á','&ccedil;'},;
				{'—','&Ntilde;'},{'Ò','&ntilde;'},{'›','&Yacute;'},{'˝','&yacute;'},{'"','&quot;'}  ,{'<','&lt;'}    ,;
				{'>','&gt;'}    ,{'Æ','&reg;'}   ,{'©','&copy;'}  ,{'ﬁ','&THORN;'} ,{'˛','&thorn;'} ,{'ﬂ','&szlig;'}	}

For i := 1 To Len(aChar)
	cData := STRTRAN(cData,aChar[i][1],aChar[i][2])
Next i

Return ALLTRIM(cData)

*-------------------------------*
Static Function ValidaEmpresas()
*-------------------------------*
Local lRet := .F.
Local aOrd := SaveOrd("TMPEMP")

TMPEMP->(DbGoTop())
Do While TMPEMP->(!Eof())
	If TMPEMP->WKMARCA == "1"  //Marcado
		lRet := .T.
	EndIf
	TMPEMP->(DbSkip())
EndDo
If !lRet
	MsgAlert("Marque ao menos uma empresa para continuar.","Grant Thornton")
EndIf

RestOrd(aOrd,.T.)
Return lRet

*-------------------------*
Static Function GetPrefs()
*-------------------------*
	
dDtEmDe  := If(!Empty(oUserParams:LoadParam("dDtEmDe" ,"","GTFIN031")),CTOD(oUserParams:LoadParam("dDtEmDe")) , CTOD(""))
dDtEmAte := If(!Empty(oUserParams:LoadParam("dDtEmAte","","GTFIN031")),CTOD(oUserParams:LoadParam("dDtEmAte")), CTOD(""))
dDtVODe  := If(!Empty(oUserParams:LoadParam("dDtVODe" ,"","GTFIN031")),CTOD(oUserParams:LoadParam("dDtVODe")) , CTOD(""))
dDtVOAte := If(!Empty(oUserParams:LoadParam("dDtVOAte","","GTFIN031")),CTOD(oUserParams:LoadParam("dDtVOAte")), CTOD(""))
dDtVRDe  := If(!Empty(oUserParams:LoadParam("dDtVRDe" ,"","GTFIN031")),CTOD(oUserParams:LoadParam("dDtVRDe")) , CTOD(""))
dDtVRAte := If(!Empty(oUserParams:LoadParam("dDtVRAte","","GTFIN031")),CTOD(oUserParams:LoadParam("dDtVRAte")), CTOD(""))
dDtBxDe  := If(!Empty(oUserParams:LoadParam("dDtBxDe" ,"","GTFIN031")),CTOD(oUserParams:LoadParam("dDtBxDe")) , CTOD(""))
dDtBxAte := If(!Empty(oUserParams:LoadParam("dDtBxAte","","GTFIN031")),CTOD(oUserParams:LoadParam("dDtBxAte")), CTOD(""))

cTpTit	:= If(!Empty(oUserParams:LoadParam("cTpTit"  ,"","GTFIN031")),oUserParams:LoadParam("cTpTit")  , "T")
cTpLanc	:= If(!Empty(oUserParams:LoadParam("cTpLanc" ,"","GTFIN031")),oUserParams:LoadParam("cTpLanc") , "T")
cFinInt	:= If(!Empty(oUserParams:LoadParam("cFinInt" ,"","GTFIN031")),oUserParams:LoadParam("cFinInt") , "A")
cAging	:= If(!Empty(oUserParams:LoadParam("cAging"  ,"","GTFIN031")),oUserParams:LoadParam("cAging")  , "T")
cBanco	:= If(!Empty(oUserParams:LoadParam("cBanco"  ,"","GTFIN031")),oUserParams:LoadParam("cBanco")  , Space(AvSX3("E1_PORTADO",3)))
cAgencia:= If(!Empty(oUserParams:LoadParam("cAgencia","","GTFIN031")),oUserParams:LoadParam("cAgencia"), Space(AvSX3("E1_AGEDEP",3)))
cCCDe	:= If(!Empty(oUserParams:LoadParam("cCCDe"   ,"","GTFIN031")),oUserParams:LoadParam("cCCDe")   , Space(AvSX3("E1_CCC",3)))
cCCAte	:= If(!Empty(oUserParams:LoadParam("cCCAte"  ,"","GTFIN031")),oUserParams:LoadParam("cCCAte")  , Space(AvSX3("E1_CCC",3)))
cMoeda	:= If(!Empty(oUserParams:LoadParam("cMoeda"  ,"","GTFIN031")),oUserParams:LoadParam("cMoeda")  , "1")
cCliDe	:= If(!Empty(oUserParams:LoadParam("cCliDe"  ,"","GTFIN031")),oUserParams:LoadParam("cCliDe")  , Space(AvSX3("E1_CLIENTE",3)))
cCliAte	:= If(!Empty(oUserParams:LoadParam("cCliAte" ,"","GTFIN031")),oUserParams:LoadParam("cCliAte") , Space(AvSX3("E1_CLIENTE",3)))
cClLjDe	:= If(!Empty(oUserParams:LoadParam("cClLjDe" ,"","GTFIN031")),oUserParams:LoadParam("cClLjDe") , Space(AvSX3("E1_LOJA",3)))
cClLjAte:= If(!Empty(oUserParams:LoadParam("cClLjAte","","GTFIN031")),oUserParams:LoadParam("cClLjAte"), Space(AvSX3("E1_LOJA",3)))

Return NIL

*--------------------------*
Static Function SavePrefs()
*--------------------------*

oUserParams:SetParam("dDtEmDe" , DTOC(dDtEmDe) , "GTFIN031")
oUserParams:SetParam("dDtEmAte", DTOC(dDtEmAte), "GTFIN031")
oUserParams:SetParam("dDtVODe" , DTOC(dDtVODe) , "GTFIN031")
oUserParams:SetParam("dDtVOAte", DTOC(dDtVOAte), "GTFIN031")
oUserParams:SetParam("dDtVRDe" , DTOC(dDtVRDe) , "GTFIN031")
oUserParams:SetParam("dDtVRAte", DTOC(dDtVRAte), "GTFIN031")
oUserParams:SetParam("dDtBxDe" , DTOC(dDtBxDe) , "GTFIN031")
oUserParams:SetParam("dDtBxAte", DTOC(dDtBxAte), "GTFIN031")

oUserParams:SetParam("cTpTit"  , cTpTit  , "GTFIN031")
oUserParams:SetParam("cTpLanc" , cTpLanc , "GTFIN031")
oUserParams:SetParam("cFinInt" , cFinInt , "GTFIN031")
oUserParams:SetParam("cAging"  , cAging  , "GTFIN031")
oUserParams:SetParam("cBanco"  , cBanco  , "GTFIN031")
oUserParams:SetParam("cAgencia", cAgencia, "GTFIN031")
oUserParams:SetParam("cCCDe"   , cCCDe   , "GTFIN031")
oUserParams:SetParam("cCCAte"  , cCCAte  , "GTFIN031")
oUserParams:SetParam("cMoeda"  , cMoeda  , "GTFIN031")
oUserParams:SetParam("cCliDe"  , cCliDe  , "GTFIN031")
oUserParams:SetParam("cCliAte" , cCliAte , "GTFIN031")
oUserParams:SetParam("cClLjDe" , cClLjDe , "GTFIN031")
oUserParams:SetParam("cClLjAte", cClLjAte, "GTFIN031")

Return NIL

*---------------------------*
Static Function EmailSocio()
*---------------------------*
Local cEmail := ""
Local cProc := "uspObterEmailSocioProjeto"

Begin Sequence
	If nHdlMIS == 0
		nHdlMIS := TCLink("MSSQL/dbMIS","10.0.30.5",7894)
	EndIf
	
	TCSetConn( nHdlMIS )

	If TCSpExist( cProc )
		If !Empty(QRY->C5_MDCONTR)
			cQuery := "EXEC " + cProc + " 0, '"
			cQuery += QRY->C5_MDCONTR + "', '"
			cQuery += TMPEMP->M0_CODIGO  + "', '"
			cQuery += QRY->C5_FILIAL + "'"
		ElseIf !Empty(QRY->C5_P_IDER)
			cQuery := "EXEC " + cProc + " '"
			cQuery += QRY->C5_P_IDER + "',0, '"
			cQuery += TMPEMP->M0_CODIGO  + "', '"
			cQuery += QRY->C5_FILIAL + "'"
		Else
			Break
		EndIf
		
		TCQuery cQuery ALIAS "TRB" NEW
		
		TRB->(DbgoTop())
		Do While TRB->(!Eof())
			If !Empty(AllTrim(TRB->EMAILUSUARIO))
				cEmail += AllTrim(TRB->EMAILUSUARIO) + ";"
			EndIf
			TRB->(DbSkip())
		EndDo
	EndIf

End Sequence

If Select("TRB") # 0
	TRB->(DbCloseArea())
EndIf

TCSetConn( nHdlPrt )

Return cEmail

*---------------------------*
Static Function GrvXML(cMsg)
*---------------------------*
Local nHdl

If !File(cDest+cArq)
	nHdl := FCreate(cDest+cArq,0 )  	//CriaÁ„o do Arquivo.
Else
	nHdl := FOpen(cDest+cArq)			//Abertura do Arquivo.
EndIf

FSeek(nHdl,0,2)
FWrite(nHdl, cMsg )
FClose(nHdl)

Return ""