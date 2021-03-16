#include 'protheus.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GTRELSE1  ºAutor  ³Eduardo C. Romanini º Data ³  01/02/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Exibição de informações de contas a receber que possuem     º±±
±±º          ³saldo positivo. ,                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GT                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*
Funcao      : GTRELSE1
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Imprimir Contas a Receber em Aberto
Autor       : Gestao Dinamica
Data/Hora   : 02/16/12 
TDN         : Não disponivel
Histórico	: MSM - 21/09/2012 - Adicionado tratamento de moedas
            : MSM - 10/10/2012 - Adicionado campo pedido para exibição no relatório
            : MSM - 15/04/2013 - Adicionado campo Vencto Origem, Valor R$, Saldo R$
Revisão     : 
Data/Hora   : 16/02/12 
Módulo      : Financeiro.
*/


*----------------------*
User Function GTRELSE1()
*----------------------*
Local cTitulo := "Contas a Receber em Aberto"
Local cArqTmp := ""
Local cArqTot := ""
Local cArqSit := ""
Local cIndSE1 := ""

Local nI   := 0
Local nP   := 0

Local aSizeAut := {}
Local aObjects := {}
Local aInfo    := {}
Local aPosObj  := {}
Local aButtons := {}
Local aCampos  := {}
Local aExibe   := {}
Local aExbTot  := {}
Local aCord    := {}
Local aCrdTot  := {}

Local bOk     := {|| oDlg:End()}
Local bCancel := {|| oDlg:End()}

Local oDlg
Local oSCli
Local oSTot
Local oFont

Private cMarca  := GetMark()

Private nTotal  := 0 

Private dDataDe  := AvCtoD("  /  /  ")
Private dDataAte := AvCtoD("  /  /  ")
Private nStaTit	 := 3

Private oBrw
Private oTot
Private oGetTot

// Maximizacao da tela em relação a area de trabalho
aSizeAut := MsAdvSize()

aAdd(aObjects,{100,250,.T.,.F.})
aAdd(aObjects,{100,100,.T.,.T.})

aInfo   := {aSizeAut[1],aSizeAut[2],aSizeAut[3],aSizeAut[4],3,3}
aPosObj := MsObjSize(aInfo,aObjects)

aCord   := aPosObj[1]

aCrdTot := aPosObj[2] 
aCrdTot[1] += 20

//Adiciona os botões na Enchoice Bar
aAdd(aButtons,{"PARAMETROS",{|| TelaParam()  },"Parametros" })
aAdd(aButtons,{"S4WB010N"  ,{|| TelaImprime()},"Imprimir"   })
aAdd(aButtons,{"PMSEXCEL"  ,{|| GeraExcel()  },"Gerar Excel"})

//RRP - 31/10/2014 - Inclusão da coluna vencimento real. Chamado 021597.
//RRP - 19/02/2015 - Inclusão da coluna centro de custo. Chamado 024418.
//AOA - 26/04/2016 - Inclusão da coluna razão social.    Chamado 033028.
//AOA - 30/12/2016 - Inclusão da coluna descrição de centro de custo. Chamado 036079
aCampos := {"E1_CLIENTE","E1_LOJA","A1_NREDUZ","A1_NOME","A1_P_INTER","CN9_P_NUM","E1_NOMCLI","E1_NUM","E1_PREFIXO","E1_CCC","E1_CCD","CTT_DESC01","E1_EMISSAO","E1_VENCORI","E1_VENCTO","E1_VENCREA","E1_VALOR","E1_VALLIQ ","E1_VLCRUZ","E1_SALDO","A3_NOME","A2_NOME","E1_MOEDA","E1_PEDIDO","E1_P_INVOI,E1_MDCONTR,E1_MDREVIS","A1_P_GECTA","A1_P_GECTB","A1_P_SORES","E1_BAIXA","E5_MOTBX","F2_NFELETR"}

//Campos adicionais das tabelas temporarias
aCpTmp  := {{"EMPRESA","C",15,0},;
	    	{"FILDES" ,"C",15,0},;
	    	{"CNPJ"   ,"C",15,0}}

aCpTot  := {{"CLIENTE","C",60,0},;
			{"TOTAL"  ,"N",20,2}}

aCpEmp := {	{"WKMARCA"  ,"C",02,0},;
			{"M0_CODIGO","C",02,0},;
	    	{"M0_CODFIL","C",02,0},;
			{"M0_FILIAL","C",15,0},;
			{"M0_NOME"  ,"C",15,0},;
			{"M0_CGC"   ,"C",14,0}}

aCpSit := {	{"WKMARCA","C",02,0},;
			{"CODIGO" ,"C",02,0},;
			{"DESC"   ,"C",30,0}}

//MSM -21/09/2012 - Array com campos para seleção das moedas
aCpMoed:={	{"WKMARCA","C",02,0},;
			{"MOEDA"  ,"C",02,0},;
			{"SIMBOLO","C",05,0}}

//Campos de exibição das MSSelect.
aExibe  := {{"EMPRESA",,"Empresa","@!"},;
			{"FILDES" ,,"Filial" ,"@!"},;
			{"CNPJ"   ,,"CNPJ"   ,"@R 99.999.999/9999-99"}}

aExbTot := {{"CLIENTE",,"Cliente","@!"},;
			{"TOTAL"  ,,"Total"  ,"@E 999,999,999.99"}}

//Tratamento dos campos da tela.
For nI := 1 To Len(aCampos)
	SX3->(DbSetOrder(2))
	If SX3->(DbSeek(aCampos[nI]))
       If Alltrim(SX3->X3_CAMPO) == "A1_NREDUZ"
       cTitulo2 := "Situacao de Cobranca"
       ElseIf Alltrim(SX3->X3_CAMPO) == "A1_NOME"     
       cTitulo2 := "Razão Social"
       ElseIf Alltrim(SX3->X3_CAMPO) == "A2_NOME"     
       cTitulo2 := "Vendedor"
       ElseIf Alltrim(SX3->X3_CAMPO) == "A3_NOME"
       cTitulo2 := "Gerente de Conta"
       ElseIf Alltrim(SX3->X3_CAMPO) == "CTT_DESC01"
       cTitulo2 := "Descri. Centro Custo"
       Else
       cTitulo2 := SX3->X3_TITULO
	   EndIf 	
	   
	   
		//Campos da MsSelect
		aAdd(aExibe,{SX3->X3_CAMPO,,AllTrim(cTitulo2),SX3->X3_PICTURE})

		if Alltrim(SX3->X3_CAMPO) == "A1_P_GECTA" .OR. 	Alltrim(SX3->X3_CAMPO) == "A1_P_GECTB" .OR. Alltrim(SX3->X3_CAMPO) == "A1_P_SORES"
			//Campos da Tabela Temporaria.
			aAdd(aCpTmp,{SX3->X3_CAMPO,SX3->X3_TIPO,50,SX3->X3_DECIMAL})				
		else
			//Campos da Tabela Temporaria.
			aAdd(aCpTmp,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})		
        endif
        
		//**Tratamento para saldo em reais - Matheus		
		if Alltrim(SX3->X3_CAMPO) == "E1_SALDO"		
			//Coluna de saldo R$
			aAdd(aCpTmp,{"SALDORE","N",17,2})
			aAdd(aExibe,{"SALDORE",,"Saldo R$","@E 99,999,999,999.99"})

			//Coluna de saldo liq R$
			aAdd(aCpTmp,{"SALDOLQRE","N",17,2})
			aAdd(aExibe,{"SALDOLQRE",,"Saldo Liq R$","@E 99,999,999,999.99"})

			//Coluna de saldo liq R$
			aAdd(aCpTmp,{"VALORLQRE","N",17,2})
			aAdd(aExibe,{"VALORLQRE",,"Valor Baixado R$","@E 99,999,999,999.99"})

		endif	
		
	EndIf
Next        

//**Tratamento para dias em atraso - Matheus
aAdd(aCpTmp,{"DIASATR","C",4,0})
aAdd(aExibe,{"DIASATR",,"Dias Atraso",""})

aAdd(aCpTmp,{"DIASATO","C",4,0})
aAdd(aExibe,{"DIASATO",,"Dias Atraso Orig.",""})


//Cria o arquivo temporário dos títulos.
cArqTmp := CriaTrab(aCpTmp,.T.)
DbUseArea(.T.,"DBDCDX",cArqTmp,"TMPSE1",.F.,.F.)

cIndSE1 := CriaTrab(Nil,.F.)
IndRegua("TMPSE1",cIndSE1,"E1_NOMCLI",,,"Selecionando Registros...")

//Cria o arquivo temporário dos totais.
cArqTot := CriaTrab(aCpTot,.T.)
DbUseArea(.T.,"DBDCDX",cArqTot,"TMPTOT",.F.,.F.)

//Cria o arquivo temporário das empresas
cArqTmp := CriaTrab(aCpEmp,.T.)
DbUseArea(.T.,"DBDCDX",cArqTmp,"TMPEMP",.T.,.F.)

//Cria o arquivo temporário das situações
cArqSit := CriaTrab(aCpSit,.T.)
DbUseArea(.T.,"DBDCDX",cArqSit,"TMPSIT",.T.,.F.)

//MSM -21/09/2012 - Criação do temporário das moedas
//Cria o arquivo temporário das moedas
cArqMoed := CriaTrab(aCpMoed,.T.)
DbUseArea(.T.,"DBDCDX",cArqMoed,"TMPMOED",.T.,.F.)

//Carrega o browse com as situações
SX3->(DbSetOrder(2))
If SX3->(DbSeek("E1_SITUACA"))
	
	If !Empty(SX3->X3_CBOX)
		cAuxSit := AllTrim(SX3->X3_CBOX)
		
		While (nI := At(";",cAuxSit)) > 0
			cOpcSit := Substr(cAuxSit,1,nI-1)
								
			nP := At ("=",cOpcSit)
			
			TMPSIT->(DbAppend())
	
			TMPSIT->WKMARCA := cMarca
			TMPSIT->CODIGO  := AllTrim(Substr(cOpcSit,1,nP-1))
			TMPSIT->DESC    := AllTrim(Substr(cOpcSit,nP+1))
		
			cAuxSit := Substr(cAuxSit,nI+1,Len(cAuxSit))    
		
		EndDo	
	    
		nP := At ("=",cAuxSit)
	
		TMPSIT->(DbAppend())
	
		TMPSIT->WKMARCA := cMarca
		TMPSIT->CODIGO  := AllTrim(Substr(cAuxSit,1,nP-1))
		TMPSIT->DESC    := AllTrim(Substr(cAuxSit,nP+1))    
	EndIf
		
EndIf

//Carrega o browse com as empresas
SM0->(DbGoTop())
While SM0->(!EOF())
    
	If !ALLTRIM(SM0->M0_CODIGO) $ "YY" // MSM - 18/11/2014 - Chamado: 022180 //AOA - 30/12/2016 - Voltar empresas ZB e ZF bloqueada anteriormente.
		TMPEMP->(DbAppend())
	
		TMPEMP->WKMARCA   := cMarca
		TMPEMP->M0_CODIGO := SM0->M0_CODIGO
		TMPEMP->M0_CODFIL := SM0->M0_CODFIL
		TMPEMP->M0_FILIAL := SM0->M0_FILIAL
		TMPEMP->M0_NOME   := SM0->M0_NOME	        
	    TMPEMP->M0_CGC    := SM0->M0_CGC
	EndIf
	
	SM0->(DbSkip())	
EndDo

//MSM -21/09/2012 - //Carrega as moedas
DbSelectArea("CTO")
CTO->(DbGoTop())
While CTO->(!EOF())
	TMPMOED->(DbAppend())
	
	TMPMOED->WKMARCA 	:= cMarca
	TMPMOED->MOEDA		:= CTO->CTO_MOEDA
	TMPMOED->SIMBOLO	:= CTO->CTO_SIMB

	CTO->(DbSkip())
EndDo


//Carrega e atualiza os dados da tela.
//Processa(AtuTela(),"Aguarde...","Carregando dados de empresas...",.F.)
//MsgRun(	"Favor Aguardar.....", "Carregando dados de empresas...",;
//	 	{|| AtuTela()})

//Chama a tela de paramentros
TelaParam()

//Exibição da tela
Define MsDialog oDlg From aSizeAut[7],aSizeAut[1] TO aSizeAut[6],aSizeAut[5] Title cTitulo Of oMainWnd Pixel
    
	//Browse com os títulos em aberto
	TMPSE1->(DbSetOrder(1))
	TMPSE1->(DbGoTop())
	oBrw := MsSelect():New("TMPSE1",,,aExibe,,"",aCord,,,oDlg)
    
    //Browse com os totais por cliente. 
	oFont := TFont():New(,,-14,,.T.)
	oSCli := TSay():New(aCord[3]+7,aCord[2],{|| "Totais por Clientes:"},oDlg,,oFont,,,,.T.,CLR_RED)

	oSTot := TSay():New(aCord[3]+7,aCord[4]-160,{|| "Total Geral:"},oDlg,,oFont,,,,.T.,CLR_RED)
	oGetTot := TGet():New(aCord[3]+6,aCord[4]-090,{|u| If(PCount()>0,nTotal:=u,nTotal)},oDlg,060,008,'@E 999,999,999.99',,,,,,,.T.) 
    oGetTot:lReadOnly := .T.
    
    TMPTOT->(DbGoTop())
	oTot := MsSelect():New("TMPTOT",,,aExbTot,,"",aCrdTot,,,oDlg)

Activate MsDialog oDlg On Init EnchoiceBar(oDlg,bOk,bCancel,,aButtons) Centered


//Fecha as tabelas temporárias
TMPSE1->(DbCloseArea())
fErase(cArqTmp)
fErase(cIndSE1)

TMPTOT->(DbCloseArea())
fErase(cArqTot)

TMPEMP->(DbCloseArea())
fErase(cArqTmp)

TMPSIT->(DbCloseArea())
fErase(cArqSit)

TMPMOED->(DbCloseArea())
fErase(cArqMoed)

Return Nil

/*
Funcao      : TelaParam
Objetivos   : Exibe a tela de parametros.
Autor       : Eduardo C. Romanini
Data        : 02/02/2011 
*/
*-------------------------*
Static Function TelaParam()
*-------------------------*
Local lInverte := .F.

Local cArqTmp := ""

Local aCpTmp  := {}
Local aExibe  := {}
Local aCpsSit := {}

Local bOk := {|| MsgRun("Favor Aguardar.....","Carregando dados de empresas...",{|| AtuTela()}),;
 				 If(ValType(oBrw) == "O",oBrw:oBrowse:Refresh(),),;
 				 If(ValType(oTot) == "O",oTot:oBrowse:Refresh(),),;
 				 oDlg:End()}

Local oDlg
Local oGrp
Local oGrp1
Local oGrp2
Local oSel
Local oSelSit
Local oSay1
Local oGet1
Local oSay2
Local oGet2
Local oBtOk
Local oBtCan

Local aCpsMoed //MSM -21/09/2012 - Criação da variavel para os campos de seleção da moeda

//Campos de exibição das MSSelect.
aExibe  := {{"WKMARCA"  ,,""       ,""  },;
			{"M0_NOME"  ,,"Empresa","@!"},;
			{"M0_FILIAL",,"Filial" ,"@!"},;
			{"M0_CGC"   ,,"CNPJ"   ,"@R 99.999.999/9999-99"}}

aCpsSit := {{"WKMARCA",,""        ,""  },;
			{"DESC"   ,,"Situação","@!"}}

//MSM -21/09/2012 - Criação do array com os campos de seleção da moeda
aCpsMoed:= {{"WKMARCA" ,,""        	,""  },;
			{"MOEDA"   ,,"Moeda"	,"@!"},;
			{"SIMBOLO" ,,"Simbolo"	,"@!"}}

oDlg := MSDialog():New( 091,232,606,841,"Parâmetros",,,.F.,,,,,,.T.,,,.T. )

oGrp := TGroup():New( 008,008,184,202,"Marque as empresas/filiais",oDlg,,,.T.,.F. )

TMPEMP->(DbGoTop())
oSel := MsSelect():New("TMPEMP","WKMARCA","",aExibe,@lInverte,@cMarca,{020,016,176,198},,, oGrp ) 
//oSel:oBrowse:bHeaderClick := {|oBrow,nCol|  MarkAll("TMPEMP", cMarca, @oDlg) }
oSel:oBrowse:lHasMark := .T.
oSel:oBrowse:lCanAllMark:=.T.
oSel:oBrowse:bAllMark := {|| MarkAll("TMPEMP",cMarca,@oDlg)}

//oGrp1 := TGroup():New( 008,206,184,292,"Situação:",oDlg,,,.T.,.F. )
oGrp1 := TGroup():New( 008,206,104,292,"Situação:",oDlg,,,.T.,.F. )

TMPSIT->(DbGoTop())
//oSelSit := MsSelect():New("TMPSIT","WKMARCA","",aCpsSit,@lInverte,@cMarca,{020,212,176,287},,, oGrp ) 
oSelSit := MsSelect():New("TMPSIT","WKMARCA","",aCpsSit,@lInverte,@cMarca,{020,212,96,287},,, oGrp1 ) 
oSelSit:oBrowse:lHasMark := .T.
oSelSit:oBrowse:lCanAllMark:=.T.
oSelSit:oBrowse:bAllMark := {|| MarkAll("TMPSIT",cMarca,@oDlg)}

//MSM -21/09/2012 - Criação do grupo de seleção de moedas
oGrp3 := TGroup():New( 110,206,184,292,"Moeda:",oDlg,,,.T.,.F. )

TMPMOED->(DbGoTop())
oSelSit := MsSelect():New("TMPMOED","WKMARCA","",aCpsMoed,@lInverte,@cMarca,{122,212,176,287},,, oGrp3 ) 
oSelSit:oBrowse:lHasMark := .T.
oSelSit:oBrowse:lCanAllMark:=.T.
oSelSit:oBrowse:bAllMark := {|| MarkAll("TMPMOED",cMarca,@oDlg)}

// MSM - 13/08/2015 - Chamado: 028429
oGrp2 := TGroup():New( 188,008,224,148,"Status dos títulos:",oDlg,CLR_BLACK,CLR_WHITE,.T.,.F. )
// Variavel numerica que guarda o item selecionado do Radio
nStaTit := 3
// Cria o Objeto
oRadio := TRadMenu():New(196,14,{'Em Aberto','Baixados','Ambos'},,oDlg,,,,,,,,100,100,,,,.T.)
// Seta Eventos
oRadio:bchange := {|| iif(nStaTit==1,(oGet1:Disable(),oGet2:Disable(),dDataDe:=CTOD("//"),oGet1:Refresh(),dDataAte:=CTOD("//"),oGet2:Refresh()) , (oGet1:Enable(),oGet2:Enable()) )}
oRadio:bSetGet := {|u|Iif (PCount()==0,nStaTit,nStaTit:=u)}
oRadio:bWhen := {|| .T. }

oGrp4 := TGroup():New( 188,152,224,292,"Data da Baixa:",oDlg,CLR_BLACK,CLR_WHITE,.T.,.F. )

oSay1 := TSay():New( 198,158,{||"De:"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,016,008)
oGet1 := TGet():New( 196,183,{|u| If(PCount()>0,dDataDe:=u,dDataDe)},oGrp2,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","","dDataDe",)

oSay2 := TSay():New( 212,158,{||"Ate:"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,016,008)
oGet2 := TGet():New( 210,183,{|u| If(PCount()>0,dDataAte:=u,dDataAte)},oGrp2,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","","dDataAte",)


oBtOk  := SButton():New( 228,232,1,bOk,oDlg,,"Confirmar", )
oBtCan := SButton():New( 228,264,2,{|| oDlg:End()},oDlg,,"Cancelar" , )

oDlg:Activate(,,,.T.)

Return Nil                                       

/*
Funcao      : AtuTela
Objetivos   : Atualiza as tabelas temporárias que formam a tela de consulta.
Autor       : Eduardo C. Romanini
Data        : 02/02/2011 
*/
*-----------------------*
Static Function AtuTela()
*-----------------------*
Local cTabSE1 := ""
Local cTabSA1 := ""
Local cTabSA3 := ""
Local cFilTab := ""
Local cWhereF2  := ""
Local cWhere  := ""
Local cPreTit := ""
Local cNumTit := ""
Local cAuxSit := ""
Local cCodCli := ""
Local cLoja   := ""

Local nI := 0
Local nP := 0

Local aTotais  := {}

Local cModo		:= ""
Local cEmpAtual	:= ""

Local nCtlMoe	:=0

Local cWhereSE5	:= ""

//Apaga todos os registros das tabelas temporarias. 
TMPSE1->(__DbZap())
TMPTOT->(__DbZap())

nTotal := 0

ProcRegua(TMPEMP->(RecCount()))

//Recupera os dados.
TMPEMP->(DbGoTop())
While TMPEMP->(!EOF())
    
    IncProc()	
    
    //Verifica se a empresa está selecionada.
    If Empty(TMPEMP->WKMARCA)
    	TMPEMP->(DbSkip())
    	Loop
    EndIf
    
	cTabSE1  := "%SE1"+AllTrim(TMPEMP->M0_CODIGO)+"0%"
    cTabSE5	 := "%SE5"+AllTrim(TMPEMP->M0_CODIGO)+"0%"
    cTabSF2  := "%SF2"+AllTrim(TMPEMP->M0_CODIGO)+"0%"
	
	// -- MSM - 25/06/2012 - Tratamento para verificar se a tabela da empresa está como exclusiva ou compartilhada.
    
    //Verifica se foi selecionado mais de uma filial no qual o financeiro é compartilhado, para não exibir títulos duplicados
	if cEmpAtual==AllTrim(TMPEMP->M0_CODIGO) .AND. cModo=="C"
		TMPEMP->(DbSkip())
		Loop
	endif
	
	cEmpAtual:=AllTrim(TMPEMP->M0_CODIGO)

	if select("TRBEC")>0
		TRBEC->(DbCloseArea())
	endif
	dbUseArea( .T.,"dbfcdxads", "\"+curdir()+"SX2"+AllTrim(TMPEMP->M0_CODIGO)+"0.dbf","TRBEC",.T., .F. )
    
    DbSelectArea("TRBEC")
	cArqInd := CriaTrab(Nil,.F.)
	IndRegua("TRBEC",cArqInd,"X2_CHAVE",,"","Selecionando registros ...")
    
    TRBEC->(DbSeek("SE1"))
	if TRBEC->X2_MODO=='C'
    	cFilTab := ""
    	cModo	:="C"
	else
		cFilTab := AllTrim(TMPEMP->M0_CODFIL) 
		cModo	:="E"
    endif
	
	// -- MSM -- Fim tratamento de verificação E ou C
	
	//Filtro da query
	cWhere := "%"
	
	/*
	If !Empty(dDataDe) .and. !Empty(dDataAte)
		cWhere += " AND E1_VENCTO >= '"+DtoS(dDataDe)+"' AND  E1_VENCTO <= '"+DtoS(dDataAte)+"'"
	ElseIf !Empty(dDataDe)
		cWhere += " AND E1_VENCTO >= '"+DtoS(dDataDe)+"'"
	ElseIf !Empty(dDataAte)
		cWhere += " AND E1_VENCTO <= '"+DtoS(dDataAte)+"'"
	EndIf
	*/
	// -- MSM -- 13/08/2015 - Tratamento do status de título e data de venciemtno, Chamado: 028429 
	
	Do Case
		Case nStaTit==1 //em aberto
			cWhere += " AND E1_SALDO > 0"
		Case nStaTit==2 //baixado
			cWhere += " AND E1_SALDO = 0"
			if !Empty(dDataDe) .and. !Empty(dDataAte)
				cWhere += " AND E1_BAIXA BETWEEN '"+DtoS(dDataDe)+"' AND '"+DtoS(dDataAte)+"'"
			elseif !Empty(dDataDe)
				cWhere += " AND E1_BAIXA >= '"+DtoS(dDataDe)+"'"
			elseif !Empty(dDataAte)
				cWhere += " AND E1_BAIXA <= '"+DtoS(dDataAte)+"'"
			endif
		Case nStaTit==3 //ambos
			if !Empty(dDataDe) .and. !Empty(dDataAte)
				cWhere += " AND ( E1_BAIXA BETWEEN '"+DtoS(dDataDe)+"' AND '"+DtoS(dDataAte)+"' OR E1_BAIXA='')"
			elseif !Empty(dDataDe)
				cWhere += " AND ( E1_BAIXA >= '"+DtoS(dDataDe)+"' OR E1_BAIXA='')"
			elseif !Empty(dDataAte)
				cWhere += " AND ( E1_BAIXA <= '"+DtoS(dDataAte)+"' OR E1_BAIXA='')"
			endif
	EndCase
	
	
	cAuxSit := ""
	
	TMPSIT->(DbGoTop())
	While TMPSIT->(!EOF())
    	
		If !Empty(TMPSIT->WKMARCA)
			
			If Empty(cAuxSit)
				cAuxSit := "'"+AllTrim(TMPSIT->CODIGO)+"'"	
			Else
				cAuxSit += ",'"+AllTrim(TMPSIT->CODIGO)+"'"	
			EndIf            

		EndIf

		TMPSIT->(DbSkip())	
	EndDo
	
	If !Empty(cAuxSit)
		cWhere += " AND E1_SITUACA IN ("+cAuxSit+")"
	EndIf

	// -- MSM - 21/09/2012 - Tratamento para where com as moedas selecionadas
	nCtlMoe:=0
	
	TMPMOED->(DbGoTop())
	While TMPMOED->(!EOF())
    	
		If !Empty(TMPMOED->WKMARCA)
			nCtlMoe++
			if nCtlMoe==1
				cWhere += " AND ("
			endif
			if nCtlMoe>1
				cWhere += " OR "
			endif
			cWhere += " E1_MOEDA = "+alltrim(cvaltochar(val(TMPMOED->MOEDA)))
		EndIf
		
		TMPMOED->(DbSkip())	
	EndDo

	if nCtlMoe>0
		cWhere += " )"
	endif
	// -- MSM - 21/09/2012 - FIM Tratamento para where com as moedas selecionadas

	cWhere += "%"
    
	//RSB - 24/11/2017 - Adicionado a opção de filial de origem no caso da empresa ter o E1 Exclusivo e o F2 Compartilhado
	cWhereF2 := "%"
	If AllTrim(TMPEMP->M0_CODIGO) $ "Z8" 
		cWhereF2 += "AND SF2.F2_FILIAL = SE1.E1_FILORIG"
	Else	
		cWhereF2 += "AND SF2.F2_FILIAL = '"+cFilTab+"'"
	Endif
	cWhereF2 += "%"

	//AND SF2.F2_FILIAL = %exp:cFilTab% 

	//Query com os dados de cada empresa.
	
	BeginSql Alias 'QRY'
    	                                                                                                                              											//** Alterado para data atual - Matheus
    	SELECT E1_FILIAL,E1_NUM,E1_PREFIXO,E1_PARCELA,E1_TIPO,E1_CLIENTE,E1_SALDO,E1_SITUACA,E1_LOJA,E1_NOMCLI,E1_EMISSAO,E1_VENCTO,E1_VENCORI,E1_VENCREA,E1_VALOR,E1_VLCRUZ,E1_IRRF,E1_INSS,E1_PIS,E1_CSLL,E1_COFINS,E1_PEDIDO,E1_MDCONTR,E1_MDREVIS, CONVERT(VARCHAR(12),GETDATE(),112) AS 'DATAATU',E1_MOEDA,E1_PEDIDO,E1_CCC,E1_CCD,E1_BAIXA,F2_NFELETR
    	FROM %exp:cTabSE1% SE1 
    	INNER JOIN %exp:cTabSF2% SF2 
    	ON SF2.%NotDel%
    		AND SF2.F2_DUPL = SE1.E1_NUM
    		AND SF2.F2_PREFIXO = SE1.E1_PREFIXO
   			%exp:cWhereF2%	
    	WHERE SE1.%NotDel%
    	  AND SE1.E1_FILIAL = %exp:cFilTab%
    	  AND SE1.E1_TIPO = 'NF'
    	  %exp:cWhere%
    	ORDER BY E1_VENCTO
	
	EndSql
    
    //cTst:=GetLastQuery()[2]
    //MemoWrite( "c:/teste/query_GTRELSE1.txt", cTst )
        
	//Grava os dados na tabela temporaria de títulos.	
	QRY->(DbGoTop())
	While QRY->(!EOF())
		
		TMPSE1->(DbAppend())	

		TMPSE1->EMPRESA    := TMPEMP->M0_NOME
		TMPSE1->FILDES     := TMPEMP->M0_FILIAL
        TMPSE1->CNPJ       := TMPEMP->M0_CGC
        TMPSE1->E1_NUM     := QRY->E1_NUM
        TMPSE1->E1_PREFIXO := QRY->E1_PREFIXO
		TMPSE1->E1_CLIENTE := QRY->E1_CLIENTE
		TMPSE1->E1_LOJA    := QRY->E1_LOJA
		TMPSE1->E1_NOMCLI  := QRY->E1_NOMCLI 
		//0=Carteira;1=Cob.Simples;2=Descontada;3=Caucionada;4=Vinculada;5=Advogado;6=Judicial                                            
		If QRY->E1_SITUACA = '1'
		cAx :="Cobranca Simples"
		EndIf      
		If QRY->E1_SITUACA = '0'
		cAx :="Carteira"
		EndIf 
		If QRY->E1_SITUACA = '2'
		cAx :="Descontada"
		EndIf
		If QRY->E1_SITUACA = '3'
		cAx :="Caucionada"
		EndIf         
		If QRY->E1_SITUACA = '4'
		cAx :="Vinculada"
		EndIf 
		If QRY->E1_SITUACA = '5'
		cAx :="Advogado"
		EndIf        
		If QRY->E1_SITUACA = '6'
		cAx :="Judicial"
		EndIf
		//RRP - 03/12/2015 - Inclusão da nova situação. Chamado 030949
		If QRY->E1_SITUACA = 'G'
			cAx :="PECLD"		
		EndIf 
		TMPSE1->A1_NREDUZ  := Alltrim(cAx)
		//	cVend :=
		
		//RRP - 19/02/2015 - Inclusão da coluna centro de custo. Chamado 024418.
		TMPSE1->E1_CCC     := QRY->E1_CCC
		TMPSE1->E1_CCD	   := QRY->E1_CCD
		
		//AOA - 30/12/2016 - Inclusão da coluna descrição de centro de custo. Chamado 036079
		DbSelectArea("CTT")
		CTT->(DbGoTop())
		CTT->(DbSetOrder(1))
		If !EMPTY(QRY->E1_CCC)
			CTT->(DbSeek(xFilial("CTT")+QRY->E1_CCC))
			TMPSE1->CTT_DESC01 := CTT->CTT_DESC01
		Else
			CTT->(DbSeek(xFilial("CTT")+QRY->E1_CCD))
			TMPSE1->CTT_DESC01 := CTT->CTT_DESC01
		EndIf
				
		TMPSE1->E1_EMISSAO := StoD(QRY->E1_EMISSAO)
		TMPSE1->E1_VENCTO  := StoD(QRY->E1_VENCTO)
		
		TMPSE1->E1_VENCORI := StoD(QRY->E1_VENCORI)
		//RRP - 31/10/2014 - Inclusão da coluna vencimento real. Chamado 021597.
		TMPSE1->E1_VENCREA := StoD(QRY->E1_VENCREA)

		TMPSE1->E1_VALOR   := QRY->E1_VALOR		
		TMPSE1->E1_VLCRUZ  := QRY->E1_VLCRUZ

		TMPSE1->E1_MOEDA   := QRY->E1_MOEDA
		TMPSE1->E1_PEDIDO  := QRY->E1_PEDIDO
		
		if empty(QRY->E1_BAIXA) .OR. QRY->E1_SALDO>0
			//**Tratamento dias em atraso - Matheus
			//RRP - 31/10/2014 - Retirado o tratamento dos dias em atraso. Chamado 021597.		
			//TMPSE1->DIASATR	:= IIF((StoD(QRY->DATAATU)-StoD(QRY->E1_VENCTO)) < 0,"0",cvaltochar(StoD(QRY->DATAATU)-StoD(QRY->E1_VENCTO)))
			TMPSE1->DIASATR	:= cvaltochar(StoD(QRY->DATAATU)-StoD(QRY->E1_VENCREA))
			//023982 - Dias atraso Venc. Orig.
			TMPSE1->DIASATO	:= cvaltochar(StoD(QRY->DATAATU)-StoD(QRY->E1_VENCORI))
		endif        

		TMPSE1->E1_VALLIQ  := IIF(QRY->E1_SALDO>0,QRY->(E1_VALOR - E1_IRRF - E1_INSS - E1_PIS - E1_CSLL - E1_COFINS),0)
		TMPSE1->E1_SALDO  := QRY->E1_SALDO

		//**Tratamento saldo em reais - Matheus		
		TMPSE1->SALDORE	:= ROUND((QRY->E1_VLCRUZ*QRY->E1_SALDO)/QRY->E1_VALOR,2)

		//**Tratamento saldo liq em reais - Matheus		
		TMPSE1->SALDOLQRE:= IIF(QRY->E1_SALDO>0, ROUND((QRY->E1_VLCRUZ*QRY->E1_SALDO)/QRY->E1_VALOR - (IIF(QRY->E1_VALOR>=215.27,QRY->E1_IRRF+QRY->E1_INSS+QRY->E1_PIS+QRY->E1_CSLL+QRY->E1_COFINS,QRY->E1_IRRF)) ,2)  ,0)
        
        TMPSE1->VALORLQRE:= ROUND(QRY->E1_VLCRUZ-ROUND(QRY->E1_SALDO*(QRY->E1_VLCRUZ/QRY->E1_VALOR),2),2)
        
		TMPSE1->E1_BAIXA := StoD(QRY->E1_BAIXA)
		
		TMPSE1->F2_NFELETR := QRY->F2_NFELETR
        
		if !empty(QRY->E1_BAIXA)
			
			cWhereSE5:= "%E5_FILIAL='"+QRY->E1_FILIAL+"' AND E5_PREFIXO='"+QRY->E1_PREFIXO+"' AND E5_NUMERO='"+QRY->E1_NUM+"' AND E5_PARCELA='"+QRY->E1_PARCELA+"' AND E5_TIPO='"+QRY->E1_TIPO+"' AND E5_DATA='"+QRY->E1_BAIXA+"' AND E5_CLIFOR='"+QRY->E1_CLIENTE+"' AND E5_LOJA='"+QRY->E1_LOJA+"'  %"			
			
			//Query para descontar os valores dos impostos e assim calcular o valor liquido.		
			BeginSql Alias 'QRYAUXE5'

				SELECT TOP 1 E5_MOTBX FROM %exp:cTabSE5% SE5
				WHERE 
				SE5.%NotDel%
				AND %exp:cWhereSE5%
				ORDER BY R_E_C_N_O_ DESC	
			
			EndSql

			QRYAUXE5->(DbGoTop())
			if QRYAUXE5->(!EOF())		
	            /*
				Do Case
				
					Case UPPER(alltrim(QRYAUXE5->E5_MOTBX)) == "CAN"
						TMPSE1->E5_MOTBX := "Cancelado"
					Case UPPER(alltrim(QRYAUXE5->E5_MOTBX)) == "NOR"
						TMPSE1->E5_MOTBX := "Normal"
					Case UPPER(alltrim(QRYAUXE5->E5_MOTBX)) == "DEV"
						TMPSE1->E5_MOTBX := "Devolução"		    	
			    	OTHERWISE
						TMPSE1->E5_MOTBX := QRYAUXE5->E5_MOTBX		    	
			    EndCase
			    */
			    TMPSE1->E5_MOTBX := QRYAUXE5->E5_MOTBX
			endif
		QRYAUXE5->(DbCloseArea())
		endif

		//TLM  - 17/04/2012 - Inclusão de numero de contrato                   
		SC5->(DbSetOrder(1))
		If SC5->(DbSeek(xFilial("SC5")+QRY->E1_PEDIDO))
			CN9->(DbSetOrder(1))
			If CN9->(DbSeek(xFilial("CN9")+SC5->C5_MDCONTR))
		   		TMPSE1->CN9_P_NUM:=CN9->CN9_P_NUM
			EndIf
		EndIf  
		
		cPreTit := QRY->E1_PREFIXO
		cNumTit := QRY->E1_NUM
		
		//Query para descontar os valores dos impostos e assim calcular o valor liquido.		
		BeginSql Alias 'QRYAUXE1'
    		SELECT E1_VALOR
    		FROM %exp:cTabSE1%
    		WHERE %NotDel%
    	  	  AND E1_FILIAL  = %exp:cFilTab%
	    	  AND E1_PREFIXO = %exp:cPreTit%
    		  AND E1_NUM     = %exp:cNumTit%
			  AND E1_TIPO IN ('IR-','CF-','PI-','CS-')
		EndSql
		
	 /*	QRYAUXE1->(DbGoTop())
		While QRYAUXE1->(!EOF())
		    
			TMPSE1->E1_VALLIQ  -= QRYAUXE1->E1_VALOR
		
			QRYAUXE1->(DbSkip())
		EndDo
       */
		QRYAUXE1->(DbCloseArea())	
        
        //Totaliza o valor
		nTotal += TMPSE1->E1_SALDO

		cTabSA1 := "%SA1"+AllTrim(TMPEMP->M0_CODIGO)+"0%"
		cTabSA3 := "%SA3"+AllTrim(TMPEMP->M0_CODIGO)+"0%"
        
		if !(Alltrim(TMPEMP->M0_CODIGO)) $ "Z3"
		//if (TMPEMP->M0_CODIGO)->(FIELDPOS("A1_P_GECTA"))>0
 			//Pesquisa o cliente e o vendedor
		    BeginSql Alias 'QRYSA1SA3'
				SELECT A3_COD,A3_NOME,A1_CGC,A1_NOME,A1_P_INTER,A1_P_VEND,A1_P_GECTA,A1_P_GECTB,A1_P_SORES
			 	FROM %exp:cTabSA1% SA1
				LEFT JOIN %exp:cTabSA3% SA3 ON SA3.A3_COD = SA1.A1_VEND and SA3.%notDel%
				WHERE SA1.%notDel%
				  AND SA1.A1_COD  = %exp:QRY->E1_CLIENTE%
				  AND SA1.A1_LOJA = %exp:QRY->E1_LOJA%
			EndSql        
		else
		
			//Pesquisa o cliente e o vendedor
		    BeginSql Alias 'QRYSA1SA3'
				SELECT A3_COD,A3_NOME,A1_CGC,A1_NOME,A1_P_INTER,A1_P_VEND
			 	FROM %exp:cTabSA1% SA1
				LEFT JOIN %exp:cTabSA3% SA3 ON SA3.A3_COD = SA1.A1_VEND and SA3.%notDel%
				WHERE SA1.%notDel%
				  AND SA1.A1_COD  = %exp:QRY->E1_CLIENTE%
				  AND SA1.A1_LOJA = %exp:QRY->E1_LOJA%
			EndSql 
					
        endif
        
        QRYSA1SA3->(DbGoTop())
        If QRYSA1SA3->(!BOF() .and. !EOF())

			nP := aScan(aTotais,{|a| AllTrim(a[1])==AllTrim(QRYSA1SA3->A1_CGC)})
			
			If nP == 0
				aAdd(aTotais,{QRYSA1SA3->A1_CGC,TMPSE1->E1_SALDO,QRY->E1_NOMCLI})
			Else
				aTotais[nP][2] += TMPSE1->E1_SALDO
			EndIf
            //AOA - 26/04/2016 - Inclusão da coluna razão social.    Chamado 033028.
			TMPSE1->A1_NOME := QRYSA1SA3->A1_NOME
		
			If !Empty(QRYSA1SA3->A3_NOME)
	    		
		    	TMPSE1->A3_NOME := QRYSA1SA3->A3_NOME
		    	TMPSE1->A1_P_INTER := QRYSA1SA3->A1_P_INTER
		    	//Acrescentado Vendedor//
		    	//RRP - 31/10/2014 - Ajuste para buscar o SA3 corretamente.
		    	/*cChave	:=  xFilial("SA3") + QRYSA1SA3->A1_P_VEND
		    	dbSelectArea( "SA3" )
				SA3->( dbSetOrder(1) )
		    	if SA3->(DbSeek(cChave ))
		    		TMPSE1->A2_NOME  := SA3->A3_NOME
		    	EndIF
		    	SA3->(DbCloseArea())*/
		    	BeginSql Alias 'QRYSA3'
					SELECT A3_FILIAL,A3_COD,A3_NOME
					FROM %exp:cTabSA3%
					WHERE %notDel%
					AND A3_COD  = %exp:QRYSA1SA3->A1_P_VEND%
				EndSql   
		    	TMPSE1->A2_NOME:= QRYSA3->A3_NOME
				//Fechando o Alias como não será mais usado.
				If Select("QRYSA3") > 0
					QRYSA3->(DbCloseArea())	               
				EndIf 
	    		//Fim Vendedor
			EndIf
		    
			If !(Alltrim(TMPEMP->M0_CODIGO)) $ "Z3" 
			//if (TMPEMP->M0_CODIGO)->(FIELDPOS("A1_P_GECTA"))>0
				TMPSE1->A1_P_GECTA:= U_GTSXB002(QRYSA1SA3->A1_P_GECTA)
				TMPSE1->A1_P_GECTB:= U_GTSXB002(QRYSA1SA3->A1_P_GECTB)
				TMPSE1->A1_P_SORES:= U_GTSXB002(QRYSA1SA3->A1_P_SORES)
			endif
		
		EndIf

		QRYSA1SA3->(DbCloseArea())

		QRY->(DbSkip())				 	
	EndDo
        
	QRY->(DbCloseArea())

	TMPEMP->(DbSkip())
EndDo

//Atualiza a tabela com os totais.
aTotais := aSort (aTotais,,,{|x, y| x[3]<y[3]})
For nI:=1 To Len(aTotais)
	TMPTOT->(DbAppend())
    
	TMPTOT->CLIENTE := aTotais[nI][3]
	TMPTOT->TOTAL   := aTotais[nI][2]
Next

TMPSE1->(DbSetOrder(1))
TMPSE1->(DbGoTop())

TMPTOT->(DbGoTop())

Return Nil  

/*
Funcao      : MarkAll
Objetivos   : Inverter a marcação do MSSelect.
Autor       : Eduardo C. Romanini
Data        : 02/02/2011 
*/
*--------------------------------------------*
Static Function MarkAll(cAlias, cMarca, oDlg)
*--------------------------------------------*
Local nReg := (cAlias)->(RecNo())

(cAlias)->(dbGoTop())
While (cAlias)->(!EOF())

    (cAlias)->(RecLock(cAlias,.F.))
	
	If Empty((cAlias)->WKMARCA)
		(cAlias)->WKMARCA := cMarca
	Else
		(cAlias)->WKMARCA := "  "
	EndIf
	
	(cAlias)->(MsUnlock())
	
	(cAlias)->(DbSkip())
EndDo

(cAlias)->(dbGoto(nReg))

oDlg:Refresh()

Return Nil        

/*
Funcao      : TelaImprime
Objetivos   : Impressão do relatório
Autor       : Eduardo C. Romanini
Data        : 02/02/2011 
*/
*---------------------------*
Static Function TelaImprime()
*---------------------------*
Private cString  := "TMPSE1"
Private cTitulo  := "Contas a receber em aberto"
Private cDesc1   := "Contas a receber em aberto"
Private cDesc2   := ""
Private cDesc3   := ""   
Private Cabec1   := "" 
Private Cabec2   := "" 
Private m_pag    := 1
Private nivel    := 1
Private nPagina  := 1
Private limite   := 132//220
Private tamanho  := "M"//"G"
Private nLastKey := 0
Private lin      := 0
Private aReturn  := { "Zebrado",1,"Administracao", 1, 2, 1,"",1 }
Private wnrel    := "GTRELSE1" 

//                     1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19
//           012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
cabec1   := "Empresa         Filial          CNPJ            Título       Emissão  Vencto       Vlr.Titulo         Vlr.Liq.    Gerente                                    D. Atraso"
cabec2   := ""                                                                                                                                                           //** alterado para cab Dias atraso - Matheus

wnrel:=SetPrint(cString,wnrel,,cTitulo,cDesc1,cDesc2,cDesc3,.F.)

If LastKey()== 27 .or. nLastKey== 27 
	Return
Endif
         
SetDefault(aReturn,cString)

If LastKey()== 27 .Or. nLastKey==27
   Return
Endif

RptStatus({|| GeraDados()},cTitulo)

Set Device To Screen

If aReturn[5] = 1
	Set Printer TO
	dbCommitAll()
	Ourspool(wnrel)
Endif
MS_FLUSH()

/*
Funcao      : GeraDados
Objetivos   : Gera os dados para impressão.
Autor       : Eduardo C. Romanini
Data        : 02/02/2011 
*/
*-------------------------*
Static Function GeraDados()
*-------------------------*
Local lFirst := .T.

Local cVar := ""

Local nReg    :=  TMPSE1->(RecNo())
Local nTotCli := 0
Local nTotal  := 0

TMPSE1->(DbSetOrder(1))
TMPSE1->(DbGoTop())

If TMPSE1->(BOF()).or. TMPSE1->(EOF())
	MsgAlert("Sem dados para consulta, revise os parâmetros.","Atenção")
    Return .F.
EndIf

lin := 80

While TMPSE1->(!EOF())
	
	If lin > 58
		lin := cabec(ctitulo,cabec1,cabec2,wnrel,tamanho,18)
		lin++
	Endif

 	cVar:= AllTrim(TMPSE1->E1_NOMCLI)

    nTotCli := 0
    
    While !TMPSE1->(EOF()) .and. cVar == AllTrim(TMPSE1->E1_NOMCLI)

		If lin > 58
			lin := cabec(ctitulo,cabec1,cabec2,wnrel,tamanho,18)
			lin++
		Endif
    
		If lFirst
			@lin,000 PSAY "CLIENTE: " + AllTrim(TMPSE1->E1_CLIENTE) + " - " + AllTrim(TMPSE1->E1_LOJA) + ":"+ AllTrim(TMPSE1->E1_NOMCLI)
			lFirst := .F.
			lin+=2	
		Endif		

   		@lin,000 PSAY TMPSE1->EMPRESA
		@lin,016 PSAY TMPSE1->FILDES
		@lin,032 PSAY TMPSE1->CNPJ
		@lin,048 PSAY TMPSE1->E1_NUM
		@lin,057 PSAY TMPSE1->E1_PREFIXO
		@lin,061 PSAY DtoC(TMPSE1->E1_EMISSAO)
		@lin,070 PSAY DtoC(TMPSE1->E1_VENCTO)
		@lin,079 PSAY Transform(TMPSE1->E1_VALOR,"@E 999,999,999.99")
		@lin,097 PSAY Transform(TMPSE1->E1_SALDO,"@E 999,999,999.99")
		@lin,114 PSAY TMPSE1->A3_NOME
		@lin,157 PSAY TMPSE1->DIASATR
		        
		nTotCli += TMPSE1->E1_SALDO
		nTotal  += TMPSE1->E1_SALDO

		lin++
		
		TMPSE1->(DbSkip())
	Enddo
	
	lFirst := .T.   
	
	lin++
	@lin,000 PSAY "TOTAL DO CLIENTE " + AllTrim(cVar) + " :" 
	@lin,097 PSAY Transform(nTotCli,"@E 999,999,999.99")
	lin+=2

EndDo 

@lin,000 PSAY Replicate("-",220)
lin++
@lin,000 PSAY "TOTAL GERAL :" 
@lin,097 PSAY Transform(nTotal,"@E 999,999,999.99")

TMPSE1->(DbGoTo(nReg))

Return Nil

/*
Funcao      : GeraExcel
Objetivos   : Exporta os dados para o Excel
Autor       : Eduardo C. Romanini
Data        : 03/02/2011 
*/
*-------------------------*
Static Function GeraExcel()
*-------------------------*
Local nI := 0

Local aCabExcel   :={} 
Local aItensExcel :={}

Private lSubTotal := .F.

If MsgYesNo("Deseja imprimir os sub-totais?","Atenção")
	lSubTotal := .T. 
EndIf

//Os campos do cabeçalho do excel são os mesmos da tela.
//RRP - 19/02/2015 -  Retirada das colunas: Filial, CNPJ, Loja, Fin. Interno e Num.Ct.Pryor. Chamado 024418.
//AOA - 30/12/2016 - Inclusão novamente do campo Filial. Chamado 036079.
//aCabExcel := aClone(aCpTmp)
For nR:=1 to Len(aCpTmp)
	If !(Alltrim(aCpTmp[nR][1])$'E1_LOJA/A1_P_INTER/CN9_P_NUM/CNPJ')
		Aadd(aCabExcel, {aCpTmp[nR][1],aCpTmp[nR][2],aCpTmp[nR][3]})	
	EndIf
Next nR

 //Inclui a coluna de deletado.
aAdd(aCabExcel,{"","L",1,0})

MsgRun(	"Favor Aguardar.....", "Selecionando os Registros",;
	 	{|| GProcItens(aCabExcel, @aItensExcel)})

//Altera o nome dos campos pelo seu título.
For nI:=1 To Len(aCabExcel)
	SX3->(DbSetOrder(2))
	If !Empty(aCabExcel[nI][1]) .and. SX3->(DbSeek(aCabExcel[nI][1]))	
		If Alltrim(SX3->X3_CAMPO) =="A1_NREDUZ"
		  cAux2:= "Situacao Cobranca"
		ElseIf Alltrim(SX3->X3_CAMPO) =="A1_NOME" //AOA - 26/04/2016 - Inclusão da coluna razão social.    Chamado 033028.
		  cAux2:= "Razão Social"
		ElseIf Alltrim(SX3->X3_CAMPO) =="CTT_DESC01" //AOA - 30/12/2016 - Inclusão da coluna descrição centro de custo. Chamado 036079.
		  cAux2:= "Descri. Centro Custo"
		Else
		  cAux2:= Alltrim(SX3->X3_TITULO)
		EndIf
		aCabExcel[nI][1]:= Upper(AllTrim(cAux2))
	EndIf
	//**Alterado para tratar dias aberto -Matheus
	If alltrim(aCabExcel[nI][1]) == "DIASATR"
		aCabExcel[nI][1]:= Upper("Dias Atraso")		
	Endif
	If alltrim(aCabExcel[nI][1]) == "DIASATO"
		aCabExcel[nI][1]:= Upper("Dias Atraso Orig.")		
	Endif		
	//**Alterado para tratar saldo reais -Matheus
	If alltrim(aCabExcel[nI][1]) == "SALDORE"
		aCabExcel[nI][1]:= Upper("Saldo R$")		
	Endif	             
	//**Alterado para tratar saldo liquido reais -Matheus
	If alltrim(aCabExcel[nI][1]) == "SALDOLQRE"
		aCabExcel[nI][1]:= Upper("Saldo Liq R$")		
	Endif	 
	
Next

MsgRun(	"Favor Aguardar.....", "Exportando os Registros para o Excel",;
		{||DlgToExcel({{"GETDADOS",;
		"CONTAS A RECEBER EM ABERTO",;
		aCabExcel,aItensExcel}})}) 

Return Nil  

/*
Funcao      : GProcItens
Objetivos   : Carrega os dados que vão para o Excel.
Autor       : Eduardo C. Romanini
Data        : 03/02/2011 
*/
*----------------------------------------*
Static Function GProcItens(aHeader, aCols)
*----------------------------------------*
Local cCli  := ""
Local cLoja := ""

Local nX      := 0
Local nP      := 0
Local nReg    := TMPSE1->(RecNo())
Local nTotCli := 0
Local nTotal  := 0

Local aItem := {}

If lSubTotal

	While TMPSE1->(!EOF())

		aItem := Array(Len(aHeader))

    	cCli  := AllTrim(TMPSE1->E1_CLIENTE)
    	cLoja := AllTrim(TMPSE1->E1_LOJA)
        
		nTotCli := 0

    	While !TMPSE1->(EOF()) .and. cCli+cLoja == AllTrim(TMPSE1->E1_CLIENTE)+AllTrim(TMPSE1->E1_LOJA) 
	
			For nX := 1 to Len(aHeader)-1
				 IF aHeader[nX][2] == "C"
				 	aItem[nX] := CHR(160)+TMPSE1->&(aHeader[nX][1])
				 ELSE
				 	aItem[nX] := TMPSE1->&(aHeader[nX][1])
				 ENDIF
			Next nX 
		    aItem[Len(aHeader)] := .F.        

			AADD(aCols,aItem)
			aItem := Array(Len(aHeader))
            
			nTotCli += TMPSE1->E1_SALDO
            nTotal  += TMPSE1->E1_SALDO

			TMPSE1->(dbSkip())
		EndDo    	
    	
    	aItem[1] := "TOTAL CLIENTE:"
    	
    	nP := aScan(aHeader,{|e| AllTrim(e[1]) == "E1_SALDO"})
    	aItem[nP] := nTotCli

		AADD(aCols,aItem)
	EndDo
    
	aItem := Array(Len(aHeader))
   	aItem[1] := "TOTAL GERAL:"
    	
   	nP := aScan(aHeader,{|e| AllTrim(e[1]) == "E1_SALDO"})
   	aItem[nP] := nTotal

	AADD(aCols,aItem)

Else

	While TMPSE1->(!EOF())

		aItem := Array(Len(aHeader))

		For nX := 1 to Len(aHeader)-1
			 IF aHeader[nX][2] == "C"
			 	aItem[nX] := CHR(160)+AllTrim(TMPSE1->&(aHeader[nX][1]))
			 ELSE
			 	aItem[nX] := TMPSE1->&(aHeader[nX][1])
			 ENDIF
		Next nX 
	    aItem[Len(aHeader)] := .F.  

		AADD(aCols,aItem)
		aItem := {}
		
		TMPSE1->(dbSkip())
		
	EndDo

EndIf

TMPSE1->(DbGoTo(nReg))		

Return