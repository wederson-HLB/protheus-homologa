#include "protheus.ch"
#include "rwmake.ch"
#include "totvs.ch"

#define STATUS_ABERTO "1"
#define STATUS_CONCLUIDO "2"
#define STATUS_CANCELADO "3"
#define STATUS_ATENDIMENTO "4"
#define STATUS_RETORNO "5"
#define STATUS_TOTVS "6"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GTHDA004  ºAutor  ³Eduardo C. Romanini º Data ³  22/07/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina de consulta de chamados de help-desk.                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Grant Thornton                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                

/*
Funcao      : GTHDA004
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Browse da rotina de consulta de chamados.
Autor       : Eduardo C. Romanini
Data/Hora   : 22/07/11 11:20
*/
*----------------------*
User Function GTHDA004()
*----------------------*
Local cAlias := "Z01"

Local aCores    := {{"Z01->Z01_STATUS == '1'","BR_VERDE"   },; //Aberto N1
					{"Z01->Z01_STATUS == '7'","BR_LARANJA" },; //Aberto N2.
					{"Z01->Z01_STATUS == '2'","BR_VERMELHO"},; //Concluido
				    {"Z01->Z01_STATUS == '3'","BR_PRETO"   },; //Cancelado
				    {"Z01->Z01_STATUS == '4'","BR_AMARELO" },; //Em Atendimento
				    {"Z01->Z01_STATUS == '5'","BR_BRANCO"  },; //Aguardando Retorno
				    {"Z01->Z01_STATUS == '6'","BR_AZUL"    } } //Pendente Totvs

Private cCadastro  := "Help-Desk Grant Thornton"
Private cPastaAnexo:= "\DIRDOC\HD\"

Private aRotina	  := {{ "Pesquisar"    ,"U_HDA004Pesq", 0, 1},;
				   	  { "Visualizar"   ,"U_HDA001Man" , 0, 2},;
				   	  { "Enviar Email" ,"U_HDE001Env" , 0, 6},;
					  { "Legenda"      ,"U_HDA001Leg" , 0, 6}}

DbSelectArea(cAlias)
DbSetOrder(1)

//Exibe o browse.
mBrowse( 6,1,22,75,cAlias,,,,,,aCores)

DbSelectArea(cAlias)

Return Nil

/*
Funcao      : HDA004Pesq()
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Rotina de pesquisa de chamados.
Autor       : Eduardo C. Romanini
Data/Hora   : 22/07/11 14:50
*/
*------------------------*
User Function HDA004Pesq()
*------------------------*
Local lRet := .F.

Local cArqTmp := ""
Local cArqInd := ""

Local aCampos := {{"MARCA"  ,"C",02,0},;
				  {"COD"    ,"C",06,0},;
				  {"CSTATUS","C",30,0},;
				  {"DTABER" ,"D",08,0},;
				  {"TITULO" ,"C",30,0},;
				  {"EMPRES" ,"C",30,0},;
				  {"SOLIC"  ,"C",35,0}}

Private cMarca  := GetMark()

If Select("TABPESQ") <> 0 
	TABPESQ->(DbCloseArea())
EndIf

//Cria a tabela temporaria para os resultados da pesquisa.
cArqTmp:=CriaTrab(aCampos,.T.)
dbUseArea( .T.,,cArqTmp,"TABPESQ",, .F. )

//Cria o indice da tabela temporaria
cArqInd := CriaTrab(,.F.)
IndRegua("TABPESQ",cArqInd,"MARCA",,,"Selecionando Registros...")

cArqInd2 := CriaTrab(,.F.)
IndRegua("TABPESQ",cArqInd2,"COD",,,"Selecionando Registros...")

TABPESQ->(DbSetIndex(cArqInd+OrdBagExt()))
TABPESQ->(DbSetIndex(cArqInd2+OrdBagExt()))

//Exibe a tela de pesquisa
lRet := TelaPesq()

//Chama a tela de visualização do chamado.
If lRet
	U_HDA001Man("Z01",,2)
EndIf

//Fecha o alias da tabela temporaria.
TABPESQ->(DbCloseArea())

//Apaga os arquivos utilizados.
FErase(cArqTmp+GetDBExtension())
FErase(cArqInd+OrdBagExt())

Return Nil

/*
Funcao      : TelaPesq()
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Exibe a tela de pesquisa
Autor       : Eduardo C. Romanini
Data/Hora   : 22/07/11 15:00
*/
*------------------------*
Static Function TelaPesq()
*------------------------*
Local lRet     := .F.

Local cTitulo := "Pesquisa de Chamados"

Local nLinIni := 14
Local nLin    := 0
Local nInc    := 12

Local aCposBrw := { {"MARCA"  ,,""           ,},;
					{"COD"    ,,"Tipo"       ,"@!"},;
					{"CSTATUS",,"Status"     ,""},;
					{"DTABER" ,,"Data"       ,"@D"},;
					{"TITULO" ,,"Titulo"     ,"@!"},;
					{"EMPRES" ,,"Empresa"    ,"@!"},;
					{"SOLIC"  ,,"Solicitante","@!"}}

Local bOk     := {|| If(ValidPesq(),(lRet := .T.,oDlg:End()),)}
Local bCancel := {|| oDlg:End()}

Local bCkCod1:= {|| lCkCod   := !lCkCod,;
					lCkTit   := .F.,;
					lCkCorpo := .F.,;
				  	lCkEmp   := .F.,;
				    lCkSolic := .F.,;
				    lCkKnow := .F.}

Local bCkCod2:={||   	cTit  	 := Space(20),;
						cCod     := Space(06),;
				 		cCorpo 	 := Space(40),;
				   		cNomEmp   := Space(14),;
				   		cSolic    := Space(06),;
		 		   		cKnow    := Space(60)}

Local bCkCod3:={||  oGetCod:bWhen   :={||If(lCkCod,.T.,.F.)},;
                    oGetTit:bWhen   :={|| .F.},;
					oGetCorpo:bWhen :={||.F.},;
					oGetEmp:bWhen   :={||.F.},;
					oGetSolic:bWhen :={||.F.},;
					oGetKnow:bWhen  :={||.F.}}

Local bCkTit1:= {|| lCkTit    := !lCkTit,;
					 lCkCod   := .F.,;
					 lCkCorpo := .F.,;
				  	 lCkEmp   := .F.,;
				     lCkSolic := .F.,;
				    lCkKnow := .F.}

Local bCkTit2:={||  	cTit  	 := Space(20),;
						cCod     := Space(06),;
				 		cCorpo 	 := Space(40),;
				   		cNomEmp   := Space(14),;
				   		cSolic    := Space(06),;
		 		   		cKnow    := Space(60)}

Local bCkTit3:={|| oGetTit:bWhen    :={||If(lCkTit,.T.,.F.)},;
					oGetCod:bWhen   :={||.F.},;
					oGetCorpo:bWhen :={||.F.},;
					oGetEmp:bWhen   :={||.F.},;
					oGetSolic:bWhen :={||.F.},;
					oGetKnow:bWhen  :={||.F.}}

Local bCkCorpo1:={|| lCkTit  := .F.,;
					 lCkCorpo := !lCkCorpo,;
					 lCkCod   := .F.,;
					 lCkEmp  := .F.,;
					 lCkSolic   := .F.,;
				    lCkKnow := .F.}

Local bCkCorpo2:={|| cTit   := Space(20),;
					cCod    := Space(06),;
 					 cCorpo  := Space(40),;
					 cNomEmp   := Space(14),;
					 cSolic    := Space(06)}

Local bCkCorpo3:={|| oGetTit:bWhen  :={||.F.},;
					oGetCod:bWhen   :={||.F.},;
					 oGetCorpo:bWhen :={||If(lCkCorpo,.T.,.F.)},;
					 oGetEmp:bWhen  :={||.F.},;
					 oGetSolic:bWhen   :={||.F.},;
					 oGetKnow:bWhen  :={||.F.}}

Local bCkEmp1:={|| lCkTit  := .F.,;
					 lCkCod   := .F.,;
					lCkCorpo := .F.,;
					lCkEmp  := !lCkEmp,;
					lCkSolic   := .F.,;
				    lCkKnow := .F.}

Local bCkEmp2:={||  	cTit  	 := Space(20),;
						cCod     := Space(06),;
				 		cCorpo 	 := Space(40),;
				   		cNomEmp   := Space(14),;
				   		cSolic    := Space(06),;
		 		   		cKnow    := Space(60)}

Local bCkEmp3:={|| oGetTit:bWhen  :={||.F.},;
					oGetCod:bWhen   :={||.F.},;
					oGetCorpo:bWhen :={||.F.},;
					oGetEmp:bWhen  :={||If(lCkEmp,.T.,.F.)},;
					oGetSolic:bWhen   :={||.F.},;
					oGetKnow:bWhen  :={||.F.}}

Local bCkSolic1:={||  lCkTit  := .F.,;
					 lCkCod   := .F.,;
					lCkCorpo := .F.,;
					lCkEmp  := .F.,;
					lCkSolic   := !lCkSolic,;
				    lCkKnow := .F.}

Local bCkSolic2:={|| 	cTit  	 := Space(20),;
						cCod     := Space(06),;
				 		cCorpo 	 := Space(40),;
				   		cNomEmp   := Space(14),;
				   		cSolic    := Space(06),;
		 		   		cKnow    := Space(60)}

Local bCkSolic3:={|| oGetTit:bWhen  :={||.F.},;
					oGetCod:bWhen   :={||.F.},;
				   oGetCorpo:bWhen :={||.F.},;
				   oGetEmp:bWhen  :={||.F.},;
				   oGetSolic:bWhen   :={||If(lCkSolic,.T.,.F.)},;
				   oGetKnow:bWhen  :={||.F.}}

Local bCkKnow1:={||  lCkTit  := .F.,;
					 lCkCod   := .F.,;
					lCkCorpo := .F.,;
					lCkEmp  := .F.,;
					lCkSolic   := .F.,;
				    lCkKnow := !lCkKnow}

Local bCkKnow2:={|| 	cTit  	 := Space(20),;
						cCod     := Space(06),;
				 		cCorpo 	 := Space(40),;
				   		cNomEmp   := Space(14),;
				   		cSolic    := Space(06),;
		 		   		cKnow    := Space(60)}

Local bCkKnow3:={|| oGetTit:bWhen  	:={||.F.},;
					oGetCod:bWhen   :={||.F.},;
				   oGetCorpo:bWhen 	:={||.F.},;
				   oGetEmp:bWhen  	:={||.F.},;
				   oGetSolic:bWhen  :={||.F.},;
				   oGetKnow:bWhen  :={||If(lCkKnow,.T.,.F.)}}


Local oDlg
Local oGrpPesq
Local oCkTit
Local cCkCorpo
Local oCkCnpj
Local oCkSolic
Local oGetTit
Local oGetCorpo
Local oGetEmp
Local oGetSolic
Local oGetKnow
Local oGetLoja
Local oSayLoja
Local oBtPesq
Local oBrw

Private lCkCod  := .F.
Private lCkTit  := .F.
Private lCkCorpo := .F.
Private lCkEmp  := .F.
Private lCkSolic   := .F.
Private lCkKnow   := .F.

Private cCod      := Space(06)
Private cTit      := Space(40)
Private cCorpo    := Space(40)
Private cNomEmp   := Space(40)
Private cSolic    := Space(06)
Private cKnow     := Space(60)

Private aItems
Private cCombo
Private oCombo

oDlg       := MSDialog():New( 006,284,591,804,cTitulo,,,.F.,,,,,,.T.,,,.T. )
oDlg:bInit := {||EnchoiceBar(oDlg,bOk,bCancel,.F.,{})}

nLin := nLinIni

oGrpPesq    := TGroup():New( nLin,004,101,252,"Pesquisa",oDlg,CLR_BLACK,CLR_WHITE,.T.,.F. )

nLin += nInc
oBtPesq := TButton():New( nLin-3,205,"Pesquisar",oGrpPesq,,037,012,,,,.T.,,"",,,,.F. )
oBtPesq:bAction := {|| PesqGet(),oBrw:oBrowse:Refresh()}

oCkCod    := TCheckBox():New( nLin,016,"Código",,oGrpPesq,055,008,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )
oCkCod:cVariable := "lCkCod"
oCkCod:bSetGet	 :={|| lCkCod }
oCkCod:bLClicked :={|| Eval(bCkCod1),Eval(bCkCod2),Eval(bCkCod3),oGetCod:SetFocus()}

nLin += nInc
oCkTit    := TCheckBox():New( nLin,016,"Resumo",,oGrpPesq,055,008,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )
oCkTit:cVariable := "lCkTit"
oCkTit:bSetGet	  :={|| lCkTit }
oCkTit:bLClicked :={|| Eval(bCkTit1),Eval(bCkTit2),Eval(bCkTit3),oGetTit:SetFocus()}

nLin += nInc
cCkCorpo   := TCheckBox():New( nLin,016,"Movimentações",,oGrpPesq,055,008,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )
cCkCorpo:cVariable := "lCkCorpo"
cCkCorpo:bSetGet   :={|| lCkCorpo }
cCkCorpo:bLClicked :={|| Eval(bCkCorpo1), Eval(bCkCorpo2),Eval(bCkCorpo3),oGetCorpo:SetFocus()}	

nLin += nInc
oCkEmp    := TCheckBox():New( nLin,016,"Nome da Empresa",,oGrpPesq,055,008,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )
oCkEmp:cVariable := "lCkEmp"
oCkEmp:bSetGet   :={|| lCkEmp }
oCkEmp:bLClicked :={|| Eval(bCkEmp1),Eval(bCkEmp2),Eval(bCkEmp3),oGetEmp:SetFocus()}	

nLin += nInc
oCkSolic     := TCheckBox():New( nLin,016,"Solicitante",,oGrpPesq,055,008,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )
oCkSolic:cVariable := "lCkSolic"
oCkSolic:bSetGet   :={|| lCkSolic }
oCkSolic:bLClicked :={|| Eval(bCkSolic1),Eval(bCkSolic2),Eval(bCkSolic3),oGetSolic:SetFocus()}	

nLin += nInc

aItems:= {'Todos Arg.','Qualquer arg.'}
cCombo:= aItems[1]
oCombo:= TComboBox():Create(oGrpPesq,{|u|if(PCount()>0,cCombo:=u,cCombo)},nLin-0.2,203,aItems,40,15,,{||},,,,.T.,,,,,,,,,'cCombo')

oGetKnow:= TCheckBox():New( nLin,016,"Parecer Tec.",,oGrpPesq,055,008,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )
oGetKnow:cVariable := "lCkKnow"
oGetKnow:bSetGet   :={|| lCkKnow }
oGetKnow:bLClicked :={|| Eval(bCkKnow1),Eval(bCkKnow2),Eval(bCkKnow3),oGetKnow:SetFocus()}                    

nLin := nLinIni

nLin += nInc
oGetCod := TGet():New( nLin,084,{|u| If(Pcount()>0,cCod:= u,cCod)  },oGrpPesq,50,008,"999999",,CLR_BLACK,CLR_WHITE,,,,.T.)
oGetCod:bWhen :={||.F.}

nLin += nInc
oGetTit := TGet():New( nLin,084,{|u| If(Pcount()>0,cTit:= u,cTit)  },oGrpPesq,160,008,"@!",,CLR_BLACK,CLR_WHITE,,,,.T.)
oGetTit:bWhen :={||.F.}

nLin += nInc
oGetCorpo:= TGet():New( nLin,084,{|u| If(Pcount()>0,cCorpo:= u,cCorpo)},oGrpPesq,160,008,"@!",,CLR_BLACK,CLR_WHITE,,,,.T.)
oGetCorpo:bWhen :={||.F.}

nLin += nInc
oGetEmp := TGet():New( nLin,084,{|u| If(Pcount()>0,cNomEmp:= u,cNomEmp)},oGrpPesq,160,008,"@!",,CLR_BLACK,CLR_WHITE,,,,.T.)
oGetEmp:bWhen :={||.F.}

nLin += nInc
oGetSolic  := TGet():New( nLin,084,{|u| If(Pcount()>0,cSolic:= u,cSolic)},oGrpPesq,50,008,"@!",,CLR_BLACK,CLR_WHITE,,,,.T.)
oGetSolic:cF3 := "USR"
oGetSolic:bWhen :={||.F.}

nLin += nInc
oGetKnow := TGet():New( nLin,084,{|u| If(Pcount()>0,cKnow:= u,cKnow)},oGrpPesq,119,008,"@!",,CLR_BLACK,CLR_WHITE,,,,.T.)
oGetKnow:bWhen :={||.F.}

oBrw := MsSelect():New("TABPESQ","MARCA","",aCposBrw,.F.,@cMarca,{104,004,284,252},,, oDlg )
oBrw:bMark := {|| MarcPesq(),oBrw:oBrowse:Refresh()}

oDlg:Activate(,,,.T.)

//Posiciona no registro selecionado.
If lRet
	TABPESQ->(DbSetOrder(2))
	If TABPESQ->(DbSeek(cMarca))
    	Z01->(DbSetOrder(1))
    	Z01->(DbSeek(xFilial("Z01")+TABPESQ->COD))
	EndIf
EndIf

Return lRet     

/*
Funcao      : ValidPesq()
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Valida os parametros de pesquisa.
Autor       : Eduardo C. Romanini
Data/Hora   : 26/07/11 17:13
*/
*-------------------------*
Static Function ValidPesq()
*-------------------------*
Local lRet := .T.


If lCkCod
	If Empty(cCod)
		MsgInfo("Preencher o codigo a ser pesquisado.","Atenção")
		lRet := .F.
	EndIf

ElseIf lCkTit
	If Empty(cTit)
		MsgInfo("Preencher o resumo a ser pesquisado.","Atenção")
		lRet := .F.
	EndIf

ElseIf lCkCorpo
	If Empty(cCorpo)
		MsgInfo("Preencher a descrição a ser pesquisada.","Atenção")
		lRet := .F.
	EndIf
ElseIf lCkEmp
	If Empty(cNomEmp)
		MsgInfo("Preencher a empresa a ser pesquisada.","Atenção")
		lRet := .F.
	EndIf

ElseIf lCkSolic	
	If Empty(cSolic)
		MsgInfo("Preencher o solicitante a ser pesquisado.","Atenção")
		lRet := .F.
	EndIf
EndIf	

If lRet
	TABPESQ->(DbSetOrder(2))
	If !TABPESQ->(DbSeek(cMarca))
		MsgInfo("Nenhum registro selecionado.","Atenção")
		lRet := .F.        
	EndIf
	TABPESQ->(DbSetOrder(1))	
EndIf

Return lRet

*-----------------------*
Static Function PesqGet()
*-----------------------*
Local cCond  := ""

//Apaga os registros da busca anterior
TABPESQ->(DbGoTop())
While TABPESQ->(!EOF())
	TABPESQ->(RecLock("TABPESQ"),.F.)
	TABPESQ->(DbDelete())
	TABPESQ->(MsUnlock())
	TABPESQ->(DbSkip())
EndDo
		
//Busca pelo codigo
If lCkCod
	If Empty(cCod)
		MsgInfo("Preencher o código a ser pesquisado.","Atenção")
		Return
	EndIf
	cCond  := "% Z01_CODIGO like '%" + Alltrim(cCod) + "%' %"

//Busca pelo titulo
ElseIf lCkTit
	If Empty(cTit)
		MsgInfo("Preencher o resumo a ser pesquisado.","Atenção")
		Return
	EndIf
	cCond  := "% UPPER(Z01_RESUMO) like '%" + Alltrim(cTit) + "%' %"

//Busca pelas movimentações do chamado.	
ElseIf lCkCorpo
	If Empty(cCorpo)
		MsgInfo("Preencher a descrição a ser pesquisada.","Atenção")
		Return
	EndIf
	cCond  := "% UPPER(CAST(CAST(Z02_DESCRI AS VARBINARY(8000)) as VARCHAR(8000))) like '%" + Alltrim(cCorpo) + "%' %"

//Busca pela empresa
ElseIf lCkEmp
	If Empty(cNomEmp)
		MsgInfo("Preencher a empresa a ser pesquisado.","Atenção")
		Return
	EndIf
	cCond  := "% UPPER(Z04_NOMFIL+Z04_NOME) like '%" + Alltrim(cNomEmp) + "%' %"

//Busca por solicitante
ElseIf lCkSolic	
	If Empty(cSolic)
		MsgInfo("Preencher o solicitante a ser pesquisado.","Atenção")
		Return
	EndIf
	cCond := "% Z01_CODUSR = '"+Alltrim(cSolic)+"' %"

//Busca por Banco de conhecimento
ElseIf lCkKnow
	If Empty(cKnow)
		MsgInfo("Preencher o Parecer Tecnico a ser pesquisado.","Atenção")
		Return
	EndIf
	lTemPeq := .F.
	cAux := ALLTRIM(cKnow)
	
	cCond := ""
	While Len(cAux) > 0
		If (AT(CHR(32),cAux) <> 0 .and. LEN(SUBSTR(cAux,1,AT(CHR(32),cAux)-1)) <= 2) .or.;
			(AT(CHR(32),cAux) == 0 .and. LEN(cAux) <= 2)
			lTemPeq := .T.
		Else
	   		If AT(CHR(32),cAux) == 0
	   			cCond += " UPPER(CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),Z01_KNOW))) like '%%%"+cAux+"%%%' "+IIF(aItems[1]==cCombo,"AND","OR")
	   		Else 
	   			cCond += " UPPER(CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),Z01_KNOW))) like '%%%"+SUBSTR(cAux,1,AT(CHR(32),cAux)-1)+"%%%' "+IIF(aItems[1]==cCombo,"AND","OR")
	   		EndIf
		EndIf
		If AT(CHR(32),cAux) == 0
			cAux := ""
		Else
			cAux := ALLTRIM(SUBSTR(cAux,AT(CHR(32),cAux)+1,LEN(cAux)))
		EndIf
	EndDo
	If EMPTY(cCond) .And. lTemPeq
		MsgInfo("Só é aceito palavras com mais de 3 letras para busca!")
		Return
	EndIf
	cCond := "% "+LEFT(cCond,LEN(cCond)-3)+" %"
	//cCond := "%	UPPER(CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),Z01_KNOW))) like '%%%"+Alltrim(cKnow)+"%%%' %"

EndIf	

If EMPTY(cCond)
	MsgInfo("Busca interrompida devido a falta da condição!")
	Return
EndIf

//Query de busca na tabela de prospects
BeginSql alias 'PESQ'
	SELECT Z01_CODIGO,Z01_DTABER,Z01_RESUMO,Z01_CODUSR,Z01_STATUS,Z04_NOMFIL,Z04_NOME
	FROM %table:Z01% Z01
	LEFT JOIN %table:Z02% Z02 ON Z02_FILIAL = Z01_FILIAL AND Z02_CODIGO = Z01_CODIGO AND Z02.%notDel%
	LEFT JOIN %table:Z04% Z04 ON Z04_CODFIL = Z01_FILEMP AND Z04_CODIGO = Z01_CODEMP AND Z04.%notDel%
	WHERE Z01.%notDel%
	  AND %Exp:cCond%
	GROUP BY Z01_CODIGO,Z01_DTABER,Z01_RESUMO,Z01_CODUSR,Z01_STATUS,Z04_NOMFIL,Z04_NOME
	ORDER BY Z01_CODIGO,Z01_DTABER	
EndSql

PESQ->(DbGoTop())
If PESQ->(BOF() .or. EOF())
	MsgInfo("Nenhum registro foi encontrado.","Atenção")
EndIf

While PESQ->(!EOF())
	TABPESQ->(DbAppend())
	TABPESQ->COD     := PESQ->Z01_CODIGO
	TABPESQ->CSTATUS := RetStatus(PESQ->Z01_STATUS)
	TABPESQ->DTABER  := StoD(PESQ->Z01_DTABER)
	TABPESQ->TITULO  := PESQ->Z01_RESUMO
	TABPESQ->EMPRES  := AllTrim(PESQ->Z04_NOMFIL)+"-"+AllTrim(PESQ->Z04_NOME)
	TABPESQ->SOLIC   := UsrRetName(PESQ->Z01_CODUSR)

	PESQ->(DbSkip())
EndDo	

TABPESQ->(DbSetOrder(1))
TABPESQ->(DbGoTop())

If Select("PESQ") > 0 
	PESQ->(DbCloseArea())
EndIf

Return Nil                                        

*--------------------------------*
Static Function RetStatus(cStatus)
*--------------------------------*
Local cRet := ""

If cStatus == STATUS_ABERTO
	cRet := "Aberto"                	
ElseIf cStatus == STATUS_CONCLUIDO
	cRet := "Concluido"                	
ElseIf cStatus == STATUS_CANCELADO
	cRet := "Cancelado"                	
ElseIf cStatus == STATUS_ATENDIMENTO
	cRet := "Em Atendimento"                	
ElseIf cStatus == STATUS_RETORNO
	cRet := "Aguardando Retorno"                	
ElseIf cStatus == STATUS_TOTVS
	cRet := "Pendente Totvs"                	
EndIf

Return cRet   

*------------------------*
Static Function MarcPesq()
*------------------------*
Local nRec := TABPESQ->(RecNo())

TABPESQ->(DbGoTop())
While TABPESQ->(!EOF())
	
	If TABPESQ->(RecNo()) <> nRec
	
		If !Empty(TABPESQ->MARCA)
			TABPESQ->(RecLock("TABPESQ"),.F.)
	 		TABPESQ->MARCA := Space(2)
			TABPESQ->(MsUnlock())
		EndIf
	Else
		If Empty(TABPESQ->MARCA)
			TABPESQ->(RecLock("TABPESQ"),.F.)
	 		TABPESQ->MARCA := cMarca
			TABPESQ->(MsUnlock())
		EndIf
	EndIf
	TABPESQ->(DbSkip())
EndDo

TABPESQ->(DbSetOrder(1))
TABPESQ->(DbGoTo(nRec))               

Return