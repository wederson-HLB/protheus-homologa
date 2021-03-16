#include "Protheus.ch"
#include "Rwmake.ch"
#include "TOPCONN.CH"
#INCLUDE "AP5MAIL.CH"
#Include "tbiconn.ch"
/*
Funcao      :TPCTB002()
Objetivos   :Rotina destina a manutenção dos lançamentos contabeis que ja foram enviados oa cliente
Autor       :João Silva
Data        :07/10/2015
Módulo      :Contabilidade Gerencial
*/

//Função Principal para geração da tela.
*-------------------------*
User Function TPCTB002()
*-------------------------*
Local aCampos  :={}
Local aButtons :={}
Local aColors  :={}
Local lInverte :=.F.
Local aSize	   :={}
Local aObjects :={}

Private cPerg  :="TPCTB002"
Private cVer1  :='N'
Private aStruCT2 :={}
Private cMarca := GetMark()
Private lExibe  := .F.
Private cAlias:= "Temp1"
Private aIndex:= {}

//Validação de empresa
If cEmpAnt <> "TP"
	Alert("Função desenvovida para empresa Twitter e não disponivel para esta empresa","HLB BRASIL")
	Return()
Endif

//Verifico que se existe esta tabela
If Select ("Temp1")>0
	Temp1->(DbCloseArea())
EndIf

//Cor e regra das legendas
aAdd(aColors,{"AllTrim(Temp1->ZXC_TYPE) =='GERADO'","BR_VERMELHO"})
aAdd(aColors,{"AllTrim(Temp1->ZXC_TYPE) =='ALTERADO'","BR_AMARELO"})

//Campos do MarkBrowse (Cabeçalho da tabela)
aAdd(aCampos,{"cEnvia"    	,"",               	 })
aAdd(aCampos,{"ZXC_TYPE"  	,"","Tipo"			,})
aAdd(aCampos,{"ZXC_DATE"  	,"","Data Ger"		,})
aAdd(aCampos,{"ZXC_USR"  	,"","Usuario"		,})
aAdd(aCampos,{"CT2_FILIAL"	,"","Filial"		,})
aAdd(aCampos,{"CT2_DATA"	,"","Data Lcto"		,})
aAdd(aCampos,{"CT2_LOTE"	,"","Numero Lote"	,})
aAdd(aCampos,{"CT2_SBLOTE"  ,"","Sub Lote"		,})
aAdd(aCampos,{"CT2_DOC"		,"","Numero Doc"	,})
aAdd(aCampos,{"CT2_LINHA"	,"","Numero Linha"	,})
aAdd(aCampos,{"CT2_MOEDLC" 	,"","Moeda Lancto"	,})
aAdd(aCampos,{"CT2_DC"  	,"","Tipo Lctp"		,})
aAdd(aCampos,{"CT2_DEBITO"  ,"","Cta Debito"	,})
aAdd(aCampos,{"CT2_CREDIT"  ,"","Cta Credito"	,})
aAdd(aCampos,{"CT2_VALOR"  	,"","Valor"			,})
aAdd(aCampos,{"CT2_HIST"  	,"","Hist Lanc"		,})


//Estrutura da tabela
aAdd(aStruCT2,{"cEnvia"    		,"C"				,2  	  				,0							   })
aAdd(aStruCT2,{"ZXC_TYPE"  		,AvSx3("ZXC_TYPE"  	,2),AvSx3("ZXC_TYPE"  	,3)   ,AvSx3("ZXC_TYPE"  	,4)})
aAdd(aStruCT2,{"ZXC_DATE"  		,AvSx3("ZXC_DATE"  	,2),AvSx3("ZXC_DATE"  	,3)   ,AvSx3("ZXC_DATE"  	,4)})
aAdd(aStruCT2,{"ZXC_USR"  		,AvSx3("ZXC_USR"  	,2),AvSx3("ZXC_USR"  	,3)   ,AvSx3("ZXC_USR"  	,4)})
aAdd(aStruCT2,{"CT2_FILIAL"		,AvSx3("CT2_FILIAL"	,2),AvSx3("CT2_FILIAL"	,3)   ,AvSx3("CT2_FILIAL"	,4)})
aAdd(aStruCT2,{"CT2_DATA"		,AvSx3("CT2_DATA"	,2),AvSx3("CT2_DATA"	,3)   ,AvSx3("CT2_DATA"		,4)})
aAdd(aStruCT2,{"CT2_LOTE"		,AvSx3("CT2_LOTE"	,2),AvSx3("CT2_LOTE"	,3)   ,AvSx3("CT2_LOTE"		,4)})
aAdd(aStruCT2,{"CT2_SBLOTE"  	,AvSx3("CT2_SBLOTE" ,2),AvSx3("CT2_SBLOTE"  ,3)   ,AvSx3("CT2_SBLOTE"  	,4)})
aAdd(aStruCT2,{"CT2_DOC"		,AvSx3("CT2_DOC"	,2),AvSx3("CT2_DOC"		,3)   ,AvSx3("CT2_DOC"		,4)})
aAdd(aStruCT2,{"CT2_LINHA"		,AvSx3("CT2_LINHA"	,2),AvSx3("CT2_LINHA"	,3)   ,AvSx3("CT2_LINHA"	,4)})
aAdd(aStruCT2,{"CT2_MOEDLC" 	,AvSx3("CT2_MOEDLC" ,2),AvSx3("CT2_MOEDLC" 	,3)   ,AvSx3("CT2_MOEDLC" 	,4)})
aAdd(aStruCT2,{"CT2_DC"  		,AvSx3("CT2_DC"  	,2),AvSx3("CT2_DC"  	,3)	  ,AvSx3("CT2_DC"  		,4)})
aAdd(aStruCT2,{"CT2_DEBITO"  	,AvSx3("CT2_DEBITO" ,2),AvSx3("CT2_DEBITO"  ,3)	  ,AvSx3("CT2_DEBITO"  	,4)})
aAdd(aStruCT2,{"CT2_CREDIT"  	,AvSx3("CT2_CREDIT" ,2),AvSx3("CT2_CREDIT"  ,3)   ,AvSx3("CT2_CREDIT"  	,4)})
aAdd(aStruCT2,{"CT2_VALOR"  	,AvSx3("CT2_VALOR"  ,2),AvSx3("CT2_VALOR"  	,3)   ,AvSx3("CT2_VALOR"  	,4)})
aAdd(aStruCT2,{"CT2_HIST"  		,AvSx3("CT2_HIST"  	,2),AvSx3("CT2_HIST"  	,3)   ,AvSx3("CT2_HIST"  	,4)})
aAdd(aStruCT2,{"CT2_TPSALD"  	,AvSx3("CT2_TPSALD" ,2),AvSx3("CT2_TPSALD"	,3)   ,AvSx3("CT2_TPSALD"  	,4)})
aAdd(aStruCT2,{"CT2_EMPORI"		,AvSx3("CT2_EMPORI"	,2),AvSx3("CT2_EMPORI" 	,3)   ,AvSx3("CT2_EMPORI"  	,4)})
aAdd(aStruCT2,{"CT2_FILORI"		,AvSx3("CT2_FILORI"	,2),AvSx3("CT2_FILORI" 	,3)   ,AvSx3("CT2_FILORI"  	,4)})

//Cria tabela temporaria
cNome	:=	CriaTrab(aStruCT2, .T.)
DbUseArea(.T.,"DBFCDX",cNome,'Temp1',.F.,.F.)

IndRegua("Temp1", cNome, "CT2_DOC", , , "Selecionando Registros...")

//Verifico se ja existe esta Query
If Select("QRY1") > 0
	QRY1->(DbCloseArea())
EndIf

//Qyery para pegar os dados que seram apresentados

cQuery1 := " SELECT	"
cQuery1 += " ZXC.ZXC_TYPE,"
cQuery1 += " ZXC.ZXC_DATE,"
cQuery1 += " ZXC.ZXC_USR,"
cQuery1 += " CT2.CT2_FILIAL,"
cQuery1 += " CT2.CT2_DATA,"
cQuery1 += " CT2.CT2_LOTE,"
cQuery1 += " CT2.CT2_SBLOTE,"
cQuery1 += " CT2.CT2_DOC,"
cQuery1 += " CT2.CT2_LINHA,"
cQuery1 += " CT2.CT2_MOEDLC,"
cQuery1 += " CT2.CT2_DC,"
cQuery1 += " CT2.CT2_DEBITO,"
cQuery1 += " CT2.CT2_CREDIT,"
cQuery1 += " CT2.CT2_VALOR,"
cQuery1 += " CT2.CT2_HIST,"
cQuery1 += " CT2.CT2_TPSALD,"
cQuery1 += " CT2.CT2_EMPORI,"
cQuery1 += " CT2.CT2_FILORI"
cQuery1 += " FROM "+RETSQLNAME("CT2")+" CT2"
cQuery1 += " INNER JOIN "+RETSQLNAME("ZXC")+" ZXC"
cQuery1 += " ON ZXC.ZXC_KEYCTB =CT2.CT2_FILIAL+CT2.CT2_DATA+CT2.CT2_LOTE+CT2.CT2_SBLOTE+CT2.CT2_DOC+CT2.CT2_LINHA+CT2.CT2_TPSALD+"
cQuery1 += " CT2.CT2_EMPORI+CT2.CT2_FILORI+CT2.CT2_MOEDLC"
//cQuery1 += " WHERE CT2.CT2_P_LOG <> '' "
cQuery1 += " ORDER BY CT2.CT2_DATA+CT2.CT2_LOTE+CT2.CT2_SBLOTE+CT2.CT2_DOC

TcQuery cQuery1 Alias "QRY1" New

//Coloco os dados da query na tabela tempararia
QRY1->(DbGoTop())
While QRY1->(!EOF())
	
	RecLock("Temp1",.T.)
	
	Temp1->ZXC_TYPE		:=QRY1->ZXC_TYPE
	Temp1->ZXC_DATE		:=STOD(QRY1->ZXC_DATE)
	Temp1->ZXC_USR		:=QRY1->ZXC_USR
	Temp1->CT2_FILIAL	:=QRY1->CT2_FILIAL
	Temp1->CT2_DATA		:=STOD(QRY1->CT2_DATA)
	Temp1->CT2_LOTE		:=QRY1->CT2_LOTE
	Temp1->CT2_SBLOTE	:=QRY1->CT2_SBLOTE
	Temp1->CT2_DOC		:=QRY1->CT2_DOC
	Temp1->CT2_LINHA	:=QRY1->CT2_LINHA
	Temp1->CT2_MOEDLC	:=QRY1->CT2_MOEDLC
	Temp1->CT2_DC		:=QRY1->CT2_DC
	Temp1->CT2_DEBITO	:=QRY1->CT2_DEBITO
	Temp1->CT2_CREDIT	:=QRY1->CT2_CREDIT
	Temp1->CT2_VALOR	:=QRY1->CT2_VALOR
	Temp1->CT2_HIST		:=QRY1->CT2_HIST
	Temp1->CT2_TPSALD	:=QRY1->CT2_TPSALD
	Temp1->CT2_EMPORI	:=QRY1->CT2_EMPORI
	Temp1->CT2_FILORI	:=QRY1->CT2_FILORI
	
	Temp1->(MsUnlock())
	QRY1->(DbSkip())
EndDO

//Cração de botões do ações relacionadas
aAdd(aButtons,{"Legenda"		,{||Funcao3()},"Legenda"		,"Legenda"		,{|| .T.}})

SetKey(VK_F12,{|| Funcao4(.T.,"Temp1",@aIndex)} )

Temp1->(DbGoTop())
If Temp1->(!BOF() .AND. !EOF())
	
	// Faz o calculo automatico de dimensoes de objetos
	aSize := MsAdvSize()
	// Dados da Enchoice
	AAdd( aObjects, { 50, 30, .T., .T. } )
	// Dados da getdados
	AAdd( aObjects, { 50,180, .T., .T. } )
	// Dados da área de trabalho e separação
	aInfo 	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
	// Chama MsObjSize e recebe array e tamanhos
	aPosObj := MsObjSize( aInfo, aObjects,.T.)
	
	//Criação da janela
	DEFINE MSDIALOG oDlg TITLE "Manunteção de Lançamentos" FROM aSize[7],0 To aSize[6],aSize[5] PIXEL
	
	@ aPosObj[1][1],aPosObj[1][2] TO aPosObj[1][3]-20,aPosObj[1][4] LABEL "" OF oDlg PIXEL
	@ aPosObj[1][1]+3,aPosObj[1][2]+5 Say "Selecione os lançamentos que pretende fazer manutenção." COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 500,6 OF oDlg
	
	Funcao4(.F.,"Temp1",@aIndex)
	
	oMarkPrd:= MsSelect():New("Temp1","cEnvia",,aCampos,@lInverte,@cMarca,{aPosObj[2,1]-20,aPosObj[2,2],aPosObj[2,3],aPosObj[2,4]},,,oDlg,,aColors)
	ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||cVer1:='N', lRet:=Funcao1(cVer1),If(lret,oDlg:End(),)},{|| oDlg:End()},,aButtons),oMarkPrd:oBrowse:Refresh()) CENTERED
	
Else
	MsgInfo("Nenhum dado encontrado para geração do arquivo"," Atenção")
	Return .F.
EndIf

Return
/*
Funcao      : Funcao1
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Função que limpa o Log do CT2
Autor       : Joao Silva
Data/Hora   : 08/10/2015
*/
*-------------------------------------------------*
Static Function Funcao1(cVer1)
*-------------------------------------------------*
//INI
Local lMarcado 	:= .F.
Local nRecCount	:= 0

Private lMsErroAuto	:= .F.

Temp1->(DbGoTop())
While Temp1->(!EOF())
	//Checa se marcou pelo menos um item.
	If !Empty(Alltrim(Temp1->cEnvia))
		lMarcado:=.T.
		nRecCount++
	EndIf
	Temp1->(DbSkip())
EndDo

ProcRegua(nRecCount)

If !lMarcado
	MsgStop("Não foi selecionado nenhum lançamento","HLB BRASIL")
	Return .F.
Else
	Temp1->(DbGoTop())
	While Temp1->(!EOF())
		IncProc("Processando...")
		//Valida se está marcado o produto
		If !Empty(Alltrim(Temp1->cEnvia))
			//FIM
			
			//If Select("CT2") > 0
			CT2->(dbCloseArea())
			//EndIf
			DbSelectArea("CT2")
			CT2->(DbSetOrder(1))
			CT2->(DbGoTop())
			If DbSeek(xFilial("CT2")+DtoS(TEMP1->CT2_DATA)+TEMP1->CT2_LOTE+TEMP1->CT2_SBLOTE+TEMP1->CT2_DOC+TEMP1->CT2_LINHA+TEMP1->CT2_TPSALD+TEMP1->CT2_EMPORI+TEMP1->CT2_FILORI+TEMP1->CT2_MOEDLC)
				RecLock("CT2",.F.)
				CT2->CT2_P_LOG :=' '
				MsUnLock()
			Else
				MsgInfo("Não foi possivel localizar o lançamento","HLB BRASIL")
			EndIf
			
			Funcao2()
			Temp1->(DbSkip())
		Else
			Temp1->(DbSkip())
		EndIf
	EndDo
EndIf

Return .T.
/*
Funcao      : Funcao2
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Função cria linha de alteração na ZXC
Autor       : Joao Silva
Data/Hora   : 08/10/2015
*/
*-------------------------------------------------*
Static Function Funcao2()
*-------------------------------------------------*
/*JSS - Gravação da tabela de log (ZXC)
Layout do campo ZXC_KEYCTB
CT2_FILIAL	=2
CT2_DATA	=8
CT2_LOTE	=6
CT2_SBLOTE	=3
CT2_DOC		=6
CT2_LINHA	=3
CT2_TPSALD	=1
CT2_EMPORI	=2
CT2_FILORI	=2
CT2_MOEDLC	=5
*/
If Select("ZXC") > 0
	ZXC->(dbCloseArea())
EndIf
DbSelectArea("ZXC")
ZXC->(DbSetOrder(1))
ZXC->(DbGoTop())
RecLock("ZXC",.T.)
ZXC->ZXC_FILIAL:=Temp1->CT2_FILIAL
ZXC->ZXC_ID:=AllTrim(RetCodUsr())
ZXC->ZXC_USR:=AllTrim(cUserName)
ZXC->ZXC_HOUR:=TIME()
ZXC->ZXC_DATE:=DATE()
ZXC->ZXC_KEYCTB:=xFilial("CT2")+DtoS(TEMP1->CT2_DATA)+TEMP1->CT2_LOTE+TEMP1->CT2_SBLOTE+TEMP1->CT2_DOC+TEMP1->CT2_LINHA+TEMP1->CT2_TPSALD+TEMP1->CT2_EMPORI+TEMP1->CT2_FILORI+TEMP1->CT2_MOEDLC
ZXC->ZXC_TYPE:="ALTERADO"
MsUnLock()

Return .T.
/*
Funcao      : Funcao3
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Tratamento de Legendas.
Autor       : Joao Silva
Data/Hora   : 08/10/2015
*/
*-------------------------------------------------*
Static Function Funcao3()
*-------------------------------------------------*
Local:= aLegenda := {}

aLegenda := {	{"BR_VERMELHO"  ,"Lcto Enviado." },;
{"BR_AMARELO"	,"Lcto Alterado."}}

BrwLegenda("Legenda","Legenda",aLegenda)

Return()
/*
Funcao      : Funcao4
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Tratamento de filtro para MsSelect.
Autor       : Joao Silva
Data/Hora   : 08/10/2015
*/
*--------------------------------------------*
Static Function Funcao4(lExibe,cAlias,aIndex)
*--------------------------------------------*
Local cFiltro 	:= ""
Local cHist		:= " "

//Criando Pergunte
Funcao5()

//Inicializa as variaveis de pergunta.
If lExibe
	IF !(Pergunte(cPerg,lExibe,"Filtro de exibição"))
		Return .F.
	EndIf
Else
	Pergunte(cPerg,lExibe,"Filtro de exibição")
EndIf

If	mv_par01 > mv_par02
	MsgInfo("A data 'De' não pode ser maior que a data 'Ate'. ","HLB BRASIL")
	Return(.F.)
EndIf
If !Empty(AllTrim(MV_PAR05))
	cHist	  := AllTrim(MV_PAR05)
EndIF

//Atualiza campos
//MV_PAR03:=0
//MV_PAR04:=99999

bCondicao := {|| DtoS(Temp1->CT2_DATA) >= DtoS(MV_PAR01) .AND. DtoS(Temp1->CT2_DATA) <= DToS(MV_PAR02)}
cCondicao := "DtoS(Temp1->CT2_DATA)>= '"+DtoS(MV_PAR01)+"' .AND. DtoS(Temp1->CT2_DATA)<= '"+DtoS(MV_PAR02);
+"' .AND. Temp1->CT2_VALOR >= "+cValToChar(MV_PAR03)+" .AND. Temp1->CT2_VALOR <= "+cValToChar(MV_PAR04);
+" .AND. cHist $ Temp1->CT2_HIST "

DbSelectArea("Temp1")
DbSetFilter(bCondicao,cCondicao)


Temp1->(DbGoTop())

Return()
/*
Funcao      : FUNCAO5
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Cria o Pergunte no SX1
Autor     	: João Silva
Data     	: 08/10/2015
*/
*------------------------*
Static Function Funcao5()
*------------------------*
U_PUTSX1(cPerg,"01" ,"Data Lcto De: ? "	,"Data Lcto De: ? "		,"Data Lcto De: ? "		,"mv_ch1","D",08,0, 0,"G","","","","","mv_par01",""		,""		,""		,"01012000"	,""		,""		,""		,"","","","","","","","","",{"Data Inicial dos lctos" } 		,{},{})
U_PUTSX1(cPerg,"02" ,"Data Lcto Ate: ?"	,"Data Lcto Ate: ?"		,"Data Lcto Ate: ?"	  	,"mv_ch2","D",08,0, 0,"G","","","","","mv_par02",""		,""		,""		,"01012030"	,""		,""		,""		,"","","","","","","","","",{"Data Final dos lctos" }			,{},{})
U_PUTSX1(cPerg,"03" ,"Valor De: ? "		,"Valor De: ? "			,"Valor De: ? "	  		,"mv_ch3","N",14,2, 0,"G","","","","","mv_par03",""		,""		,""		,"0"		,""		,""		,""		,"","","","","","","","","",{"Valor dos lctos" }				,{},{})
U_PUTSX1(cPerg,"04" ,"Valor Ate: ?"		,"Valor Ate: ?" 		,"Valor Ate: ?"	  		,"mv_ch4","N",14,2, 0,"G","","","","","mv_par04",""		,""		,""		,"999999"	,""		,""		,""		,"","","","","","","","","",{"Valor dos lctos" }				,{},{})
U_PUTSX1(cPerg,"05" ,"Historico contem: ?","Historico contem: ?"  ,"Historico contem: ?"	,"mv_ch5","C",30,0, 0,"G","","","","","mv_par05",""		,""		,""		,""			,""		,""		,""		,"","","","","","","","","",{"Historico contemA expressão " }	,{},{})
