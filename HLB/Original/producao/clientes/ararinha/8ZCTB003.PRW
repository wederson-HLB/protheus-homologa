#include "Protheus.ch"
#include "Rwmake.ch"
#include "TOPCONN.CH"
#INCLUDE "AP5MAIL.CH"
#Include "tbiconn.ch"
/*
Funcao      :8ZCTB003()
Objetivos   :Rotina destina a manuten��o dos lan�amentos contabeis que n�o foram enviados oa cliente Ararinha 
Autor       :Jo�o Silva
Data        :01/12/2015
M�dulo      :Contabilidade Gerencial

Indice
Funcao      : Funcao1()	Objetivo   : Fun��o que limpa o Log do CT2          
Funcao      : Funcao2()	Objetivo   : Fun��o cria linha de altera��o na ZXE  
Funcao      : Funcao3()	Objetivo   : Tratamento de Legendas.   
Funcao      : Funcao4()	Objetivo   : Tratamento de filtro para MsSelect.   
Funcao      : FUNCAO5()	Objetivo   : Cria o Pergunte no SX1
*/

//Fun��o Principal para gera��o da tela.
*-------------------------*
User Function 8ZCTB003()
*-------------------------*
Local aCampos  	:= {}
Local aButtons 	:= {}
Local aColors  	:= {}
Local lInverte 	:= .F.
Local aSize	   	:= {}
Local aObjects 	:= {}

Private cPerg  	:= "8ZCTB003"
Private cVer1  	:= 'N'
Private aStruCT2:= {}
Private cMarca 	:= GetMark()
Private lExibe  := .F.
Private cAlias	:= "Temp1"
Private aIndex	:= {}

//Valida��o de empresa
If !cEmpAnt $ '8Z/TP'
	Alert("Fun��o desenvovida para empresa Ararinha e n�o disponivel para esta empresa","HLB BRASIL")
	Return()
Endif

//Verifico que se existe esta tabela
If Select ("Temp1")>0
	Temp1->(DbCloseArea())
EndIf

//Cor e regra das legendas
aAdd(aColors,{"AllTrim(Temp1->CT2_P_LOG) == ''","BR_VERDE"})

//Campos do MarkBrowse (Cabe�alho da tabela)
aAdd(aCampos,{"cEnvia"    	,"",               	 })
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
aAdd(aStruCT2,{"CT2_P_LOG"		,AvSx3("CT2_P_LOG"	,2),AvSx3("CT2_P_LOG" 	,3)   ,AvSx3("CT2_P_LOG"  	,4)})

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
cQuery1 += " CT2.CT2_FILORI,"
cQuery1 += " CT2.CT2_P_LOG"
cQuery1 += " FROM "+RETSQLNAME("CT2")+" CT2"
cQuery1 += " WHERE "
cQuery1 += " 	CT2.D_E_L_E_T_	<> '*' "   
cQuery1 += "	AND CT2.CT2_MOEDLC 	<> '01'"
cQuery1 += "	AND CT2.CT2_TPSALD 	<> '9' " 
cQuery1 += "	AND CT2.CT2_P_LOG 	=  ''"
cQuery1 += " ORDER BY CT2.CT2_DATA+CT2.CT2_LOTE+CT2.CT2_SBLOTE+CT2.CT2_DOC

TcQuery cQuery1 Alias "QRY1" New

//Coloco os dados da query na tabela tempararia
QRY1->(DbGoTop())
While QRY1->(!EOF())
	
	RecLock("Temp1",.T.)
	
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
	Temp1->CT2_P_LOG	:=QRY1->CT2_P_LOG
	
	Temp1->(MsUnlock())
	QRY1->(DbSkip())
EndDO

//Cra��o de bot�es do a��es relacionadas
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
	// Dados da �rea de trabalho e separa��o
	aInfo 	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
	// Chama MsObjSize e recebe array e tamanhos
	aPosObj := MsObjSize( aInfo, aObjects,.T.)
	
	//Cria��o da janela
	DEFINE MSDIALOG oDlg TITLE "Manunte��o de Lan�amentos" FROM aSize[7],0 To aSize[6],aSize[5] PIXEL
	
	@ aPosObj[1][1],aPosObj[1][2] TO aPosObj[1][3]-20,aPosObj[1][4] LABEL "" OF oDlg PIXEL
	@ aPosObj[1][1]+3,aPosObj[1][2]+5 Say "Selecione os lan�amentos que pretende fazer manuten��o." COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 500,6 OF oDlg
	
	Funcao4(.F.,"Temp1",@aIndex)
	
	oMarkPrd:= MsSelect():New("Temp1","cEnvia",,aCampos,@lInverte,@cMarca,{aPosObj[2,1]-20,aPosObj[2,2],aPosObj[2,3],aPosObj[2,4]},,,oDlg,,aColors)
	ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||cVer1:='N', lRet:=Funcao1(cVer1),If(lret,oDlg:End(),)},{|| oDlg:End()},,aButtons),oMarkPrd:oBrowse:Refresh()) CENTERED
	
Else
	MsgInfo("Nenhum dado encontrado para gera��o do arquivo"," Aten��o")
	Return .F.
EndIf

Return
/*
Funcao      : Funcao1
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Fun��o que marca o Log do CT2
Autor       : Joao Silva
Data/Hora   : 01/12/2015
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
	MsgStop("N�o foi selecionado nenhum lan�amento","HLB BRASIL")
	Return .F.
Else
	Temp1->(DbGoTop())
	While Temp1->(!EOF())
		IncProc("Processando...")
		//Valida se est� marcado o produto
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
				CT2->CT2_P_LOG :='S'
				MsUnLock()
			Else
				MsgInfo("N�o foi possivel localizar o lan�amento","HLB BRASIL")
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
Objetivos   : Fun��o cria linha de altera��o na ZXE
Autor       : Joao Silva
Data/Hora   : 01/12/2015
*/
*-------------------------------------------------*
Static Function Funcao2()
*-------------------------------------------------*
/*JSS - Grava��o da tabela de log (ZXE)
Layout do campo ZXE_KEYCTB
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
If Select("ZXE") > 0
	ZXE->(dbCloseArea())
EndIf
DbSelectArea("ZXE")
ZXE->(DbSetOrder(1))
ZXE->(DbGoTop())
RecLock("ZXE",.T.)
ZXE->ZXE_FILIAL:=Temp1->CT2_FILIAL
ZXE->ZXE_ID:=AllTrim(RetCodUsr())
ZXE->ZXE_USR:=AllTrim(cUserName)
ZXE->ZXE_HOUR:=TIME()
ZXE->ZXE_DATE:=DATE()
ZXE->ZXE_KEYCTB:=xFilial("CT2")+DtoS(TEMP1->CT2_DATA)+TEMP1->CT2_LOTE+TEMP1->CT2_SBLOTE+TEMP1->CT2_DOC+TEMP1->CT2_LINHA+TEMP1->CT2_TPSALD+TEMP1->CT2_EMPORI+TEMP1->CT2_FILORI+TEMP1->CT2_MOEDLC
ZXE->ZXE_TYPE:="GERADO"
MsUnLock()

Return .T.
/*
Funcao      : Funcao3
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Tratamento de Legendas.
Autor       : Joao Silva
Data/Hora   : 01/12/2015
*/
*-------------------------------------------------*
Static Function Funcao3()
*-------------------------------------------------*
Local:= aLegenda := {}

aLegenda := {	{"BR_VERDE"  ,"Lcto N�o Enviado." }}

BrwLegenda("Legenda","Legenda",aLegenda)

Return()
/*
Funcao      : Funcao4
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Tratamento de filtro para MsSelect.
Autor       : Joao Silva
Data/Hora   : 01/12/2015
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
	IF !(Pergunte(cPerg,lExibe,"Filtro de exibi��o"))
		Return .F.
	EndIf
Else
	Pergunte(cPerg,lExibe,"Filtro de exibi��o")
EndIf

If	mv_par01 > mv_par02
	MsgInfo("A data 'De' n�o pode ser maior que a data 'Ate'. ","HLB BRASIL")
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
Autor     	: Jo�o Silva
Data     	: 01/12/2015
*/
*------------------------*
Static Function Funcao5()
*------------------------*
U_PUTSX1(cPerg,"01" ,"Data Lcto De: ? "	,"Data Lcto De: ? "		,"Data Lcto De: ? "		,"mv_ch1","D",08,0, 0,"G","","","","","mv_par01",""		,""		,""		,"01012000"	,""		,""		,""		,"","","","","","","","","",{"Data Inicial dos lctos" } 		,{},{})
U_PUTSX1(cPerg,"02" ,"Data Lcto Ate: ?"	,"Data Lcto Ate: ?"		,"Data Lcto Ate: ?"	  	,"mv_ch2","D",08,0, 0,"G","","","","","mv_par02",""		,""		,""		,"01012030"	,""		,""		,""		,"","","","","","","","","",{"Data Final dos lctos" }			,{},{})
U_PUTSX1(cPerg,"03" ,"Valor De: ? "		,"Valor De: ? "			,"Valor De: ? "	  		,"mv_ch3","N",14,2, 0,"G","","","","","mv_par03",""		,""		,""		,"0"		,""		,""		,""		,"","","","","","","","","",{"Valor dos lctos" }				,{},{})
U_PUTSX1(cPerg,"04" ,"Valor Ate: ?"		,"Valor Ate: ?" 		,"Valor Ate: ?"	  		,"mv_ch4","N",14,2, 0,"G","","","","","mv_par04",""		,""		,""		,"999999"	,""		,""		,""		,"","","","","","","","","",{"Valor dos lctos" }				,{},{})
U_PUTSX1(cPerg,"05" ,"Historico contem: ?","Historico contem: ?"  ,"Historico contem: ?"	,"mv_ch5","C",30,0, 0,"G","","","","","mv_par05",""		,""		,""		,""			,""		,""		,""		,"","","","","","","","","",{"Historico contemA express�o " }	,{},{})
