#include "TOPCONN.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"
#include "Protheus.ch"
#include "Rwmake.ch"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FWBROWSE.CH"
#include "fileio.ch"
#Include "tbiconn.ch"
/*
Funcao      : LWFAT001
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Integração de Pedido de Venda.
Autor       : Jean Victor Rocha
Data/Hora   : 29/01/2014
*/
*----------------------*
User Function LWFAT001()
*----------------------*
Local aCores   := {}
Local cFilSQL  := Nil

PRIVATE aRotina		:= MenuDef()
PRIVATE cCadastro	:= "Pedidos de Venda"

aCores := {	{ "Empty(C5_LIBEROK).And.Empty(C5_NOTA) .And. Empty(C5_BLQ)",'ENABLE' 		},;	//Pedido em Aberto
{ "!Empty(C5_NOTA).Or.C5_LIBEROK=='E' .And. Empty(C5_BLQ)" 	,'DISABLE'		},;	//Pedido Encerrado
{ "!Empty(C5_LIBEROK).And.Empty(C5_NOTA).And. Empty(C5_BLQ)",'BR_AMARELO'	},;
{ "C5_BLQ == '1'"											,'BR_AZUL'		},;	//Pedido Bloquedo por regra
{ "C5_BLQ == '2'"											,'BR_LARANJA'	}}	//Pedido Bloquedo por verba

If ExistTemplate("MT410BRW")
	ExecTemplate("MT410BRW",.F.,.F.)
EndIf

MBrowse( 6,1,22,75,'SC5',,,,,,aCores,,,,,,,,cFilSQL)

Return .T.

/*
Funcao      : MenuDef()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   :
Autor       : Jean Victor Rocha
Data/Hora   : 29/01/2014
*/
*-----------------------------------*
Static Function MenuDef()
*-----------------------------------*
Private aRotina := {	{ "Pesquisar"	,"AxPesqui"		,0,1,0 ,.F.},;		//"Pesquisar"
{ "Visual" 		,"A410Visual"	,0,2,0 ,NIL},;		//"Visual"
{ "Integrar"	,"U_LWFATI"		,0,3,0 ,.F.},;
{ "Legenda"	  	,"GpLegend"  	,0,6,0 ,.F.}}		//"Legenda"
Return(aRotina)

/*
Funcao      : LWFATI()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função Principal para integração.
Autor       : Jean Victor Rocha
Data/Hora   : 29/01/2014
*/
*-----------------------*
User Function LWFATI()
*-----------------------*
Local lWizMan := .F.
Private oWizMan
Private ocDirArq
Private cDirArq := "c:\"+Space(100)

Private nopc := 3
Private aHoBrw1 := {}
Private aCoBrw1 := {}
Private aHoBrw2 := {}
Private aCoBrw2 := {}

Private aLog	:= {}

Private lMsgInv := .F.

SC5->(DbSetOrder(1))
SC6->(DbSetOrder(1))

If SC5->(FieldPos("C5_P_REF")) == 0
	MsgInfo("Ambiente não esta preparado para Integração de Pedido de Venda via .CSV, entrar em contato com o Suporte 'C5_P_REF'","HLB BRASIL")
	Return .T.
EndIf

oWizMan := APWizard():New("Pedido de Vendas", ""/*<chMsg>*/, "Rotina de integração",;
"Rotina de Integração de Pedido de Venda a partir de uma planilha em (.CSV)",;
{||  BlqWizard(1),.T.}/*<bNext>*/, {|| .T.}/*<bFinish>*/, /*<.lPanel.>*/,,,/*<.lNoFirst.>*/ )

//Painel 2
oWizMan:NewPanel( "Seleção do Arquivo", "Selecione o arquivo '.CSV' a ser integrado",{ || .T.}/*<bBack>*/,;
{|| IIF(FILE(cDirArq),(BlqWizard(1),LoadaCols(@oBrw1,@oWizMan),.T.),(Alert("Arquivo não encontrado!"),.F.))}/*<bNext>*/,;
{|| .T.}/*<bFinish>*/, /*<.lPanel.>*/, {|| BlqWizard(2) }/*<bExecute>*/ )

@ 010, 010 TO 125,280 OF oWizMan:oMPanel[2] PIXEL
oSBox1 := TScrollBox():New( oWizMan:oMPanel[2],009,009,124,279,.T.,.T.,.T. )

@ 21,20 SAY oSay3 VAR "Arquivo? " SIZE 100,10 OF oSBox1 PIXEL
ocDirArq:= TGet():New(20,85,{|u| If(PCount()>0,cDirArq:=u,cDirArq)},oSBox1,120,05,'',{|o|},,,,,,.T.,,,,,,,,,"",'cDirArq')
@ 20,204.5 Button "..."	Size 7,10 Pixel of oSBox1 action (GetDir())

//--> PANEL 3
oWizMan:NewPanel( "Visualização", "Visualização do arquivo carregado no sistema!",{ ||.F.}/*<bBack>*/,;
{|| (BlqWizard(1),ValDados(@oBrw2,@oWizMan))}/*<bNext>*/, {|| .T.}/*<bFinish>*/,;
/*<.lPanel.>*/, {|| BlqWizard(2) }/*<bExecute>*/ )

Aadd(aHoBrw1,{"Linha Plan."	,"NLINHA"		,"",06,00,"","","N","",""})
Aadd(aHoBrw1,{"Chave"  		,"C5_P_REF"		,"",TamSX3("C5_P_REF")[1],TamSX3("C5_P_REF")[2],"","",TamSX3("C5_P_REF")[3],"",""})
Aadd(aHoBrw1,{"Tp.Oper"		,"TPOPER1" 		,"",05,00,"","","C","",""})
Aadd(aHoBrw1,{"Tp.OperII"	,"TPOPER2" 		,"",40,00,"","","C","",""})
Aadd(aHoBrw1,{"CNPJ Remet."	,"CNPJSM0" 		,"",18,00,"","","C","",""})
Aadd(aHoBrw1,{"CNPJ Dest."	,"A1_CGC"  		,"",18,00,"","","C","",""})
Aadd(aHoBrw1,{"CNPJ Transp.","A4_CGC"  		,"",18,00,"","","C","",""})
Aadd(aHoBrw1,{"Prazo Pag."	,"E4_CODIGO"	,"",10,00,"","","C","",""})
Aadd(aHoBrw1,{"Dt. Nota"	,"C6_ENTREG"	,"",20,00,"","","C","",""})
Aadd(aHoBrw1,{"Mensagem 1"	,"MENNOTA1"		,"",60,00,"","","C","",""})
Aadd(aHoBrw1,{"Mensagem 2"	,"MENNOTA2"		,"",60,00,"","","C","",""})
Aadd(aHoBrw1,{"Mensagem 3"	,"MENNOTA3"		,"",60,00,"","","C","",""})
Aadd(aHoBrw1,{"Mensagem 4"	,"MENNOTA4"		,"",60,00,"","","C","",""})
Aadd(aHoBrw1,{"Cod.Prod."	,"C6_PRODUTO"	,"",TamSX3("C6_PRODUTO")[1],TamSX3("C6_PRODUTO")[2],"","",TamSX3("C6_PRODUTO")[3],"",""})
Aadd(aHoBrw1,{"Descr.Prod."	,"C6_DESCRI"	,"",TamSX3("C6_DESCRI")[1],TamSX3("C6_DESCRI")[2],"","",TamSX3("C6_DESCRI")[3],"",""})
Aadd(aHoBrw1,{"Serie"		,"C6_NUMSERI"	,"",TamSX3("C6_NUMSERI")[1],TamSX3("C6_NUMSERI")[2],"","",TamSX3("C6_NUMSERI")[3],"",""})
Aadd(aHoBrw1,{"Qtde"		,"C6_QTDVEN"	,"",20,00,"","","C","",""})
Aadd(aHoBrw1,{"Vlr.Unit"	,"C6_PRCVEN"	,"",20,00,"","","C","",""})
Aadd(aHoBrw1,{"Vlr.Total"	,"C6_VALOR"		,"",20,00,"","","C","",""})

noBrw1:= Len(aHoBrw1)

aAlter := {}

oGrp := TGroup():New( 004,004,138,296,"",oWizMan:oMPanel[3],,,.T.,.F. )
oBrw1 := MsNewGetDados():New(010,008,134,292,nOpc,'AllwaysTrue()','AllwaysTrue()','',aAlter,0,99999,'AllwaysTrue()','','AllwaysTrue()',oGrp,aHoBrw1,aCoBrw1 )

//--> PANEL 4
oWizMan:NewPanel( "Visualização", "Arquivo processado e validado, linhas em cinza com erros e não serão integradas!",;
{ ||.F.}/*<bBack>*/,{|| IIF(lMsgInv,;
IIF(MsgYesNo("Possui itens invalidos, confirma a execução mesmo assim?"),.T.,.F.),;
.T.)}/*<bNext>*/,;
{|| .T.}/*<bFinish>*/, /*<.lPanel.>*/,{|| BlqWizard(2) }/*<bExecute>*/ )

Aadd(aHoBrw2,{"Motivo"		,"MOTVINV" 		,"",500,00,"","","M","",""})
Aadd(aHoBrw2,{"Linha Plan."	,"NLINHA"		,"",06,00,"","","N","",""})
Aadd(aHoBrw2,{"Chave"  		,"C5_P_REF"		,"",TamSX3("C5_P_REF")[1],TamSX3("C5_P_REF")[2],"","",TamSX3("C5_P_REF")[3],"",""})
Aadd(aHoBrw2,{"Tp.Oper"		,"TPOPER1" 		,"",05,00,"","","C","",""})
Aadd(aHoBrw2,{"Tp.OperII"	,"TPOPER2" 		,"",40,00,"","","C","",""})
Aadd(aHoBrw2,{"TES"			,"F4_CODIGO"	,"",TamSX3("F4_CODIGO")[1],TamSX3("F4_CODIGO")[2],"","",TamSX3("F4_CODIGO")[3],"",""})
Aadd(aHoBrw2,{"CNPJ Remet."	,"CNPJSM0" 		,"",14,00,"","","C","",""})
Aadd(aHoBrw2,{"CNPJ Dest."	,"A1_CGC"  		,"",14,00,"","","C","",""})
Aadd(aHoBrw2,{"Cod. Dest."	,"A1_COD"	  	,"",TamSX3("A1_COD")[1],TamSX3("A1_COD")[2],"","",TamSX3("A1_COD")[3],"",""})
Aadd(aHoBrw2,{"Loja Dest."	,"A1_LOJA"  	,"",TamSX3("A1_LOJA")[1],TamSX3("A1_LOJA")[2],"","",TamSX3("A1_LOJA")[3],"",""})
Aadd(aHoBrw2,{"Nome. Dest."	,"A1_NOME"  	,"",TamSX3("A1_NOME")[1],TamSX3("A1_NOME")[2],"","",TamSX3("A1_NOME")[3],"",""})
Aadd(aHoBrw2,{"CNPJ Transp.","A4_CGC"  		,"",14,00,"","","C","",""})
Aadd(aHoBrw2,{"Cod. Transp.","A4_COD"  		,"",TamSX3("A4_COD")[1],TamSX3("A4_COD")[2],"","",TamSX3("A4_COD")[3],"",""})
Aadd(aHoBrw2,{"Nome Transp.","A4_NOME" 		,"",TamSX3("A4_NOME" )[1],TamSX3("A4_NOME" )[2],"","",TamSX3("A4_NOME" )[3],"",""})
Aadd(aHoBrw2,{"Cond.Pag"	,"E4_CODIGO"	,"",TamSX3("E4_CODIGO" )[1],TamSX3("E4_CODIGO" )[2],"","",TamSX3("E4_CODIGO" )[3],"",""})
Aadd(aHoBrw2,{"Nome Pag"	,"E4_COND"		,"",TamSX3("E4_COND" )[1],TamSX3("E4_COND" )[2],"","",TamSX3("E4_COND" )[3],"",""})
Aadd(aHoBrw2,{"Dt. Nota"	,"C6_ENTREG"	,"",08,00,"","","D","",""})
Aadd(aHoBrw2,{"Mensagem 1"	,"MENNOTA1"		,"",60,00,"","","C","",""})
Aadd(aHoBrw2,{"Mensagem 2"	,"MENNOTA2"		,"",60,00,"","","C","",""})
Aadd(aHoBrw2,{"Mensagem 3"	,"MENNOTA3"		,"",60,00,"","","C","",""})
Aadd(aHoBrw2,{"Mensagem 4"	,"MENNOTA4"		,"",60,00,"","","C","",""})
Aadd(aHoBrw2,{"Cod.Prod."	,"C6_PRODUTO"	,"",TamSX3("C6_PRODUTO")[1],TamSX3("C6_PRODUTO")[2],"","",TamSX3("C6_PRODUTO")[3],"",""})
Aadd(aHoBrw2,{"Descr.Prod."	,"C6_DESCRI"	,"",TamSX3("C6_DESCRI")[1],TamSX3("C6_DESCRI")[2],"","",TamSX3("C6_DESCRI")[3],"",""})
Aadd(aHoBrw2,{"Serie"		,"C6_NUMSERI"	,"",TamSX3("C6_NUMSERI")[1],TamSX3("C6_NUMSERI")[2],"","",TamSX3("C6_NUMSERI")[3],"",""})
Aadd(aHoBrw2,{"Qtde"		,"C6_QTDVEN"	,PesqPict("SC6","C6_QTDVEN"),TamSX3("C6_QTDVEN")[1],TamSX3("C6_QTDVEN")[2],"","",TamSX3("C6_QTDVEN")[3],"",""})
Aadd(aHoBrw2,{"Vlr.Unit"	,"C6_PRCVEN"	,PesqPict("SC6","C6_PRCVEN"),TamSX3("C6_PRCVEN")[1],TamSX3("C6_PRCVEN")[2],"","",TamSX3("C6_PRCVEN")[3],"",""})
Aadd(aHoBrw2,{"Vlr.Total"	,"C6_VALOR"		,PesqPict("SC6","C6_VALOR"),TamSX3("C6_VALOR")[1],TamSX3("C6_VALOR")[2],"","",TamSX3("C6_VALOR")[3],"",""})

noBrw2:= Len(aHoBrw2)

aAlter	:={"MOTVINV"}

oGrp := TGroup():New( 004,004,138,296,"",oWizMan:oMPanel[4],,,.T.,.F. )
oBrw2 := MsNewGetDados():New(010,008,134,292,nOpc,'AllwaysTrue()','AllwaysTrue()','',aAlter,0,99999,'AllwaysTrue()','','AllwaysTrue()',oGrp,aHoBrw2,aCoBrw2 )

//--> PANEL 5
oWizMan:NewPanel( "Integração", "Processamento e gravação da integração.",{ ||.F.}/*<bBack>*/,;
/*<bNext>*/, {|| .T.}/*<bFinish>*/, /*<.lPanel.>*/,{|| Main() } /*<bExecute>*/ )

@ 21,20 SAY oSayTxt VAR ""  SIZE 100,10 OF oWizMan:oMPanel[5] PIXEL
nMeter := 0
oMeter := TMeter():New(31,20,{|u|if(Pcount()>0,nMeter:=u,nMeter)},0,oWizMan:oMPanel[5],250,34,,.T.,,,,,,,,,)
oMeter:Set(0)

oBtn1 := TButton():New( 61,20,"Visualizar Log",oWizMan:oMPanel[5],{|| ViewLog()},80,10,,,,.T.,,"",,,,.F. )

oWizMan:Activate( .T./*<.lCenter.>*/,/*<bValid>*/, /*<bInit>*/, /*<bWhen>*/ )


Return .T.

/*
Funcao     : LoadaCols
Parametros : Nenhum
Retorno    :
Objetivos  : Carregar Informações do aCols
Autor      : Jean Victor Rocha
Data/Hora  :
*/
*-------------------------------------------*
Static Function LoadaCols(oBrw,oWizXXX)
*-------------------------------------------*
Local cLinha	:= ""
Local nLinha	:= 0
Local aHeader	:= oBrw:AHEADER
Local lInicio	:= .F.

FT_FUse() 			// Fecha o arquivo
FT_FUse(cDirArq)	// Abre o arquivo
FT_FGoTop()			// Posiciona no inicio do arquivo
While !FT_FEof()
	nLinha++
	cLinha := FT_FReadln()        // Le a linha
	aLinha := separa(UPPER(cLinha),";")  // Sepera para vetor
	
	If UPPER(LEFT(aLinha[1],4)) <> "REFE" .and. !lInicio//Localiza a primeira linha do arquivo.
		FT_FSkip()
		Loop
	ElseIf !lInicio
		lInicio := .T.
		FT_FSkip()
		Loop
	EndIf
	aAux := {}
	For nK:=1 to len(aHeader)
		If nK == 1
			aAdd(aAux, nLinha)
		ElseIf aHeader[nK][2] ==  "MOTVINV"
			aAdd(aAux, "")
		Else
			aAdd(aAux, aLinha[nK-1])//Desconsidera a Primeira linha
		EndIf
	Next nK
	aAdd(aAux, .F.)//Deletado
	aAdd(aCoBrw1,aAux)
	
	FT_FSkip() // Proxima linha
Enddo
FT_FUse() // Fecha o arquivo

oBrw:ACOLS := aCoBrw1

Return .T.

/*
Funcao     : ValDados
Parametros : Nenhum
Retorno    :
Objetivos  : Valida os dados do arquivo
Autor      : Jean Victor Rocha
Data/Hora  :
*/
*-------------------------------------------*
Static Function ValDados(oBrw,oWizXXX)
*-------------------------------------------*
Local i
Local aPVRej := {}
Local aNotEmpty := {	"C5_P_REF","TPOPER1","CNPJSM0","A1_CGC","A4_CGC","E4_CODIGO","C6_ENTREG",;
"C6_PRODUTO","C6_NUMSERI"}

oBrw:ACOLS := {}

For i:=1 to Len(oBrw1:ACOLS)
	aAdd(oBrw:ACOLS,Array(Len(oBrw:aHeader)+1) )//Adiciona uma linha em Branco
	
	//Marca como não deletado a linha
	oBrw:ACOLS[i][Len(oBrw:aHeader)+1] := .F.
	
	//Ajusta Inicio de Variavel Memo
	If EMPTY(oBrw:ACOLS[i][aScan(oBrw:AHEADER,{|x| x[2] ==  "MOTVINV"})])
		oBrw:ACOLS[i][aScan(oBrw:AHEADER,{|x| x[2] ==  "MOTVINV"})] := ""
	EndIf
	
	//Preenche o Array e trata os seus conteudos.
	For j:=1 to Len(oBrw:aHeader)
		If (nPos:=aScan(oBrw1:aHeader,{|x| x[2] == oBrw:aHeader[j][2]})   ) <> 0//gera conteudo em branco para campos novos.
			Do Case//Tratamento para Ajuste dos conteudos dos campos.
				Case oBrw:aHeader[j][2] == "C6_QTDVEN" .or. oBrw:aHeader[j][2] == "C6_PRCVEN" .or.  oBrw:aHeader[j][2] == "C6_VALOR"
					oBrw:ACOLS[i][j] := Val(oBrw1:ACOLS[i][nPos])
					//Validação de Valores Zerados.
					If oBrw:ACOLS[i][j] == 0
						lMsgInv := .T.
						oBrw:ACOLS[i][Len(oBrw:ACOLS[i])] := .T.
						oBrw:ACOLS[i][aScan(oBrw:AHEADER,{|x| x[2] ==  "MOTVINV"})] += "- Campo "+ALLTRIM(oBrw:aHeader[j][2])+" com valor Zero!"+CHR(13)+CHR(10)
					EndIf
					
				Case oBrw:aHeader[j][2] == "CNPJSM0" .or. oBrw:aHeader[j][2] == "A1_CGC" .or.  oBrw:aHeader[j][2] == "A4_CGC"
					oBrw:ACOLS[i][j] := oBrw1:ACOLS[i][nPos]
					oBrw:ACOLS[i][j] := STRTRAN(oBrw:ACOLS[i][j],"-" ,"")
					oBrw:ACOLS[i][j] := STRTRAN(oBrw:ACOLS[i][j],"." ,"")
					oBrw:ACOLS[i][j] := STRTRAN(oBrw:ACOLS[i][j],"/" ,"")
					oBrw:ACOLS[i][j] := STRZERO(VAL(oBrw:ACOLS[i][j]),14)
					
				Case oBrw:aHeader[j][2] == "C6_ENTREG"
					oBrw:ACOLS[i][j] := CTOD(LEFT(oBrw1:ACOLS[i][nPos],10))
					
				Case oBrw:aHeader[j][2] == "MENNOTA1" .or. oBrw:aHeader[j][2] == "MENNOTA2" .or.;
					oBrw:aHeader[j][2] == "MENNOTA3"  .or.  oBrw:aHeader[j][2] == "MENNOTA4" .or.;
					oBrw:aHeader[j][2] == "C6_DESCRI"  .or.  oBrw:aHeader[j][2] == "C6_NUMSERI"
					
					oBrw:ACOLS[i][j] :=	Encoding(oBrw1:ACOLS[i][nPos])
					
				OtherWise
					oBrw:ACOLS[i][j] := oBrw1:ACOLS[i][nPos]
			EndCase
			
		ElseIf EMPTY(oBrw:ACOLS[i][j])
			If oBrw:aHeader[j][8] == "C"
				oBrw:ACOLS[i][j] := ""
			ElseIf oBrw:aHeader[j][8] == "N"
				oBrw:ACOLS[i][j] := 0
			ElseIf oBrw:aHeader[j][8] == "D"
				oBrw:ACOLS[i][j] := CTOD("  /  /   ")
			EndIf
		EndIf
		
		//Validação de Campos preenchidos.
		If aScan(aNotEmpty,{|x| x == oBrw:aHeader[j][2]}) <> 0
			If EMPTY(oBrw:ACOLS[i][j])
				lMsgInv := .T.
				oBrw:ACOLS[i][Len(oBrw:ACOLS[i])] := .T.
				oBrw:ACOLS[i][aScan(oBrw:AHEADER,{|x| x[2] ==  "MOTVINV"})] += "- Campo "+ALLTRIM(oBrw:aHeader[j][2])+" em branco!"+CHR(13)+CHR(10)
			EndIf
		EndIf
		
		//Validação de produto cadastrado
		If oBrw:aHeader[j][2] == "C6_PRODUTO"
			If select("QRY")>0
				QRY->(DbCloseArea())
			Endif
			cTab := "%"+RetSqlName("SB1") +"%"
			cWhere := "% B1_COD = '"+ALLTRIM(oBrw:ACOLS[i][j])+"' AND B1_FILIAL = '"+xFilial("SB1")+"'%"
			BeginSql Alias 'QRY'
				Select COUNT(*) as Count
				FROM %exp:cTab%
				WHERE %notDel%
				AND %exp:cWhere%
			EndSql
			QRY->(DbGoTop())
			If QRY->COUNT == 0
				lMsgInv := .T.
				oBrw:ACOLS[i][Len(oBrw:ACOLS[i])] := .T.
				oBrw:ACOLS[i][aScan(oBrw:AHEADER,{|x| x[2] ==  "MOTVINV"})] += "- Produto não encontrado!"+CHR(13)+CHR(10)
			EndIf
		EndIf
		
		//Validação de Chave - C5_P_REF
		If oBrw:aHeader[j][2] == "C5_P_REF"
			If select("QRY")>0
				QRY->(DbCloseArea())
			Endif
			cTab := "%"+RetSqlName("SC5") +"%"
			cWhere := "% C5_P_REF = '"+ALLTRIM(oBrw:ACOLS[i][j])+"' AND C5_FILIAL = '"+xFilial("SC5")+"'%"
			BeginSql Alias 'QRY'
				SELECT TOP 1 C5_P_REF
				FROM %exp:cTab%
				WHERE %notDel%
				AND %exp:cWhere%
			EndSql
			QRY->(DbGoTop())
			If QRY->(!BOF() .and. !EOF())
				lMsgInv := .T.
				oBrw:ACOLS[i][Len(oBrw:ACOLS[i])] := .T.
				oBrw:ACOLS[i][aScan(oBrw:AHEADER,{|x| x[2] ==  "MOTVINV"})] += "- Chave duplicada:'C5_P_REF'!"+CHR(13)+CHR(10)
			EndIf
		EndIf
		
		//Validação de Remetente
		If oBrw:aHeader[j][2] == "CNPJSM0"
			If SM0->M0_CGC <> oBrw:ACOLS[i][j]
				lMsgInv := .T.
				oBrw:ACOLS[i][Len(oBrw:ACOLS[i])] := .T.
				oBrw:ACOLS[i][aScan(oBrw:AHEADER,{|x| x[2] ==  "MOTVINV"})] += "- Remetente invalido/empresa logada divergente!"+CHR(13)+CHR(10)
			EndIf
		EndIf
		
		//Validação de Condição de Pagamento
		If oBrw:aHeader[j][2] == "E4_CODIGO"
			If select("QRY")>0
				QRY->(DbCloseArea())
			Endif
			cTab := "%"+RetSqlName("SE4") +"%"
			cWhere := "% E4_CODIGO = '"+ALLTRIM(oBrw:ACOLS[i][j])+"' AND E4_FILIAL = '"+xFilial("SE4")+"'%"
			BeginSql Alias 'QRY'
				SELECT TOP 1 *
				FROM %exp:cTab%
				WHERE %notDel%
				AND %exp:cWhere%
			EndSql
			QRY->(DbGoTop())
			If QRY->(!EOF())
				oBrw:ACOLS[i][aScan(oBrw:AHEADER,{|x| x[2] ==  "E4_CODIGO"})]	:= QRY->E4_CODIGO
				oBrw:ACOLS[i][aScan(oBrw:AHEADER,{|x| x[2] ==  "E4_COND"})]		:= QRY->E4_COND
			Else
				lMsgInv := .T.
				oBrw:ACOLS[i][Len(oBrw:ACOLS[i])] := .T.
				oBrw:ACOLS[i][aScan(oBrw:AHEADER,{|x| x[2] ==  "MOTVINV"})] += "- Condição de Pagamento invalida/não encontrada!"+CHR(13)+CHR(10)
			EndIf
		EndIf
		
		//Validação de TES
		If oBrw:aHeader[j][2] == "TPOPER1"
			If select("QRY")>0
				QRY->(DbCloseArea())
			Endif
			cTab := "%"+RetSqlName("ZX1") +"%"
			cWhere := "% ZX1_BEP = '"+UPPER(ALLTRIM(oBrw:ACOLS[i][j]))+"' "
			cWhere += " AND ZX1_BEPDES = '"+UPPER(ALLTRIM(oBrw:ACOLS[i][aScan(oBrw:AHEADER,{|x| x[2] ==  "TPOPER2"})]))+"'%"  //TABELA DE/PARA - ALTERAR
			BeginSql Alias 'QRY'
				SELECT TOP 1 *
				FROM %exp:cTab%
				WHERE %notDel%
				AND %exp:cWhere%
			EndSql
			QRY->(DbGoTop())
			If QRY->(!EOF())
				oBrw:ACOLS[i][aScan(oBrw:AHEADER,{|x| x[2] ==  "F4_CODIGO"})]	:= QRY->ZX1_TES
			Else
				lMsgInv := .T.
				oBrw:ACOLS[i][Len(oBrw:ACOLS[i])] := .T.
				oBrw:ACOLS[i][aScan(oBrw:AHEADER,{|x| x[2] ==  "MOTVINV"})] += "- TES invalida/não encontrada!"+CHR(13)+CHR(10)
			EndIf
		EndIf
		
		//Validação de Destinatario
		If oBrw:aHeader[j][2] == "A1_CGC"
			If select("QRY")>0
				QRY->(DbCloseArea())
			Endif
			cTab := "%"+RetSqlName("SA1") +"%"
			cWhere := "% A1_CGC = '"+oBrw:ACOLS[i][j]+"' AND A1_FILIAL = '"+xFilial("SA1")+"'%"
			BeginSql Alias 'QRY'
				SELECT TOP 1 *
				FROM %exp:cTab%
				WHERE %notDel%
				AND %exp:cWhere%
			EndSql
			QRY->(DbGoTop())
			If QRY->(!EOF())
				oBrw:ACOLS[i][aScan(oBrw:AHEADER,{|x| x[2] ==  "A1_COD"})]	:= QRY->A1_COD
				oBrw:ACOLS[i][aScan(oBrw:AHEADER,{|x| x[2] ==  "A1_LOJA"})]	:= QRY->A1_LOJA
				oBrw:ACOLS[i][aScan(oBrw:AHEADER,{|x| x[2] ==  "A1_NOME"})]	:= QRY->A1_NOME
			Else
				lMsgInv := .T.
				oBrw:ACOLS[i][Len(oBrw:ACOLS[i])] := .T.
				oBrw:ACOLS[i][aScan(oBrw:AHEADER,{|x| x[2] ==  "MOTVINV"})] += "- Destinatario invalido/não encontrado!"+CHR(13)+CHR(10)
			EndIf
		EndIf
		
		//Validação de Transportadora
		If oBrw:aHeader[j][2] == "A4_CGC"
			If select("QRY")>0
				QRY->(DbCloseArea())
			Endif
			cTab := "%"+RetSqlName("SA4") +"%"
			cWhere := "% A4_CGC = '"+oBrw:ACOLS[i][j]+"' AND A4_FILIAL = '"+xFilial("SA4")+"'%"
			BeginSql Alias 'QRY'
				SELECT TOP 1 *
				FROM %exp:cTab%
				WHERE %notDel%
				AND %exp:cWhere%
			EndSql
			QRY->(DbGoTop())
			If QRY->(!EOF())
				oBrw:ACOLS[i][aScan(oBrw:AHEADER,{|x| x[2] ==  "A4_COD"})]	:= QRY->A4_COD
				oBrw:ACOLS[i][aScan(oBrw:AHEADER,{|x| x[2] ==  "A4_NOME"})]	:= QRY->A4_NOME
			Else
				lMsgInv := .T.
				oBrw:ACOLS[i][Len(oBrw:ACOLS[i])] := .T.
				oBrw:ACOLS[i][aScan(oBrw:AHEADER,{|x| x[2] ==  "MOTVINV"})] += "- Transportadora invalida/não encontrada!"+CHR(13)+CHR(10)
			EndIf
		EndIf
		
		//Valida se o pedido possui algum item rejeitado.
		If oBrw:ACOLS[i][Len(oBrw:ACOLS[i])]//Adiciona no array o Pedido Rejeitado.
			If aScan(aPVRej, {|x| x == oBrw:ACOLS[i][aScan(oBrw:AHEADER,{|x| x[2] ==  "C5_P_REF"})]  }) == 0
				aAdd(aPVRej, oBrw:ACOLS[i][aScan(oBrw:AHEADER,{|x| x[2] ==  "C5_P_REF"})] )
			EndIf
		EndIf
		
	Next j
Next i

//Valida se o Pedido Possui todos os itens Validados para integração.
For i:=1 to Len(oBrw1:ACOLS)
	If aScan(aPVRej, {|x| x == oBrw:ACOLS[i][aScan(oBrw:AHEADER,{|x| x[2] ==  "C5_P_REF"})]  }) <> 0
		If !oBrw:ACOLS[i][Len(oBrw:ACOLS[i])]
			oBrw:ACOLS[i][Len(oBrw:ACOLS[i])] := .T.
			oBrw:ACOLS[i][aScan(oBrw:AHEADER,{|x| x[2] ==  "MOTVINV"})] += "- Pedido possui item(ns) reijeitado(s)!"+CHR(13)+CHR(10)
		EndIf
	EndIf
Next i


Return .T.

/*
Funcao      : GetDir
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Busca de diretorio.
Autor       : Jean Victor Rocha.
Data/Hora   :
*/
*---------------------------*
Static Function GetDir()
*---------------------------*
Local cTitle:= "Selecionar arquivo"
Local cFile := "Arq.  | *.CSV"

cDirArq := ALLTRIM(cGetFile(cFile,cTitle))

Return

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

oSayTxt:CCAPTION 				:= "0/"+ALLTRIM(STR(Len(oBrw2:ACOLS)))+" Processando, aguarde..."
oMeter:LVISIBLE 				:= .T.
oBtn1:LVISIBLE					:= .F.
oWizMan:OBACK:LVISIBLECONTROL	:= .F.
oWizMan:OCANCEL:LVISIBLECONTROL	:= .F.
oWizMan:ONEXT:LVISIBLECONTROL	:= .F.
oWizMan:OFINISH:LVISIBLECONTROL	:= .F.

oMeter:NTOTAL := LEN(oBrw2:ACOLS)

//Ordena pelo Numero do pedido/Numero de Referencia.
aAux := oBrw2:ACOLS
ASORT(aAux,,,{|x,y| x[aScan(oBrw2:AHEADER,{|x| x[2] == "C5_P_REF"})] > y[aScan(oBrw2:AHEADER,{|x| x[2] == "C5_P_REF"})] })
oBrw2:ACOLS := aAux

aDados	:= {}
aItem	:= {}

cChave	:= ""

SA1->(DbSetOrder(1))

For i:=1 to LEN(oBrw2:ACOLS)
	oMeter:Set(i)
	oSayTxt:CCAPTION := ALLTRIM(STR(i))+"/"+ALLTRIM(STR(Len(oBrw2:ACOLS)))+" Processando, aguarde..."
	
	If (!EMPTY(cChave) .And. cChave <> oBrw2:ACOLS[i][aScan(oBrw2:AHEADER,{|x| x[2] ==  "C5_P_REF"})] ) 	//executa quando trocar de PV
		//Execução do MSExecAuto.
		GrvPedido(aDados,aItem)
		aDados	:= {}
		aItem	:= {}
	EndIf
	
	If !oBrw2:ACOLS[i][Len(oBrw2:ACOLS[i])]//Executa apenas os que não possuem erros.
		If LEN(aDados) == 0
			SA1->(DbSeek(xFilial("SA1")+oBrw2:ACOLS[i][aScan(oBrw2:AHEADER,{|x| x[2] ==  "A1_COD"	})]+;
			oBrw2:ACOLS[i][aScan(oBrw2:AHEADER,{|x| x[2] ==  "A1_LOJA"	})] ))
			
			aadd(aDados,{"C5_P_REF"   	,oBrw2:ACOLS[i][aScan(oBrw2:AHEADER,{|x| x[2] ==  "C5_P_REF"})]		,	Nil})
			AADD(aDados,{"C5_TIPO" 		,"N"   																,	nil})
			AADD(aDados,{"C5_CLIENTE"	,SA1->A1_COD														,	nil})
			AADD(aDados,{"C5_LOJACLI"	,SA1->A1_LOJA														,	nil})
			AADD(aDados,{"C5_TIPOCLI"	,SA1->A1_TIPO														,	nil})
			AADD(aDados,{"C5_CONDPAG"	,oBrw2:ACOLS[i][aScan(oBrw2:AHEADER,{|x| x[2] ==  "E4_CODIGO"})]	,	nil})
			AADD(aDados,{"C5_EMISSAO"	,oBrw2:ACOLS[i][aScan(oBrw2:AHEADER,{|x| x[2] ==  "C6_ENTREG"})]	,	nil})
			AADD(aDados,{"C5_TRANSP"	,oBrw2:ACOLS[i][aScan(oBrw2:AHEADER,{|x| x[2] ==  "A4_COD"})] 		,	nil})
			AADD(aDados,{"C5_MENNOTA"	,""			  														,	nil})
			
			aDados[aScan(aDados,{|x| x[1] == "C5_MENNOTA"})][2] += ALLTRIM(oBrw2:ACOLS[i][aScan(oBrw2:AHEADER,{|x| x[2] ==  "MENNOTA1"})])
			aDados[aScan(aDados,{|x| x[1] == "C5_MENNOTA"})][2] += ALLTRIM(oBrw2:ACOLS[i][aScan(oBrw2:AHEADER,{|x| x[2] ==  "MENNOTA2"})])
			aDados[aScan(aDados,{|x| x[1] == "C5_MENNOTA"})][2] += ALLTRIM(oBrw2:ACOLS[i][aScan(oBrw2:AHEADER,{|x| x[2] ==  "MENNOTA3"})])
			aDados[aScan(aDados,{|x| x[1] == "C5_MENNOTA"})][2] += ALLTRIM(oBrw2:ACOLS[i][aScan(oBrw2:AHEADER,{|x| x[2] ==  "MENNOTA4"})])
			
			aAdd(aLog,{	aDados[1][2],;//"C5_P_REF"
			"",;//"C5_NUM"
			aDados[2][2],;//"C5_TIPO"
			aDados[3][2],;//"C5_CLIENTE"
			aDados[4][2],;//"C5_LOJACLI"
			aDados[5][2],;//"C5_TIPOCLI"
			aDados[6][2],;//"C5_CONDPAG"
			aDados[7][2],;//"C5_EMISSAO"
			aDados[8][2],;//"C5_TRANSP"
			aDados[9][2],;//"C5_MENNOTA"
			"",;//"RESUMO"
			"",;//"DETALHE"
			.F.})//Deletado
		EndIf
		
		cChave := oBrw2:ACOLS[i][aScan(oBrw2:AHEADER,{|x| x[2] ==  "C5_P_REF"})]
		
		AADD(aItem,{ 	{"C6_ITEM"		,STRZERO(LEN(aItem)+1,TAMSX3("C6_ITEM")[1])							,	nil},;
		{"C6_PRODUTO"	,oBrw2:ACOLS[i][aScan(oBrw2:AHEADER,{|x| x[2] ==  "C6_PRODUTO"})]	,	nil},;
		{"C6_DESCRI"	,oBrw2:ACOLS[i][aScan(oBrw2:AHEADER,{|x| x[2] ==  "C6_DESCRI"})]	,	nil},;
		{"C6_QTDVEN"	,oBrw2:ACOLS[i][aScan(oBrw2:AHEADER,{|x| x[2] ==  "C6_QTDVEN"})]	,	nil},;
		{"C6_PRCVEN"	,oBrw2:ACOLS[i][aScan(oBrw2:AHEADER,{|x| x[2] ==  "C6_PRCVEN"})]	,	nil},;
		{"C6_VALOR"		,oBrw2:ACOLS[i][aScan(oBrw2:AHEADER,{|x| x[2] ==  "C6_VALOR"})]		,	nil},;
		{"C6_TES"		,oBrw2:ACOLS[i][aScan(oBrw2:AHEADER,{|x| x[2] ==  "F4_CODIGO"})]	,	nil},;
		{"C6_ENTREG"	,oBrw2:ACOLS[i][aScan(oBrw2:AHEADER,{|x| x[2] ==  "C6_ENTREG"})]	,	nil},;
		{"C6_NUMSERI"	,oBrw2:ACOLS[i][aScan(oBrw2:AHEADER,{|x| x[2] ==  "C6_NUMSERI"})]	,	nil}	})
	EndIf
Next i

If (LEN(aDados) <> 0 .and. LEN(aItem) <> 0)	//Executa quando Identificar o Ultimo PV
	GrvPedido(aDados,aItem)
EndIf

oSayTxt:CCAPTION 				:= "Integração finalizada com Sucesso!"
oMeter:LVISIBLE 				:= .F.
oWizMan:OFINISH:LVISIBLECONTROL	:= .T.
oBtn1:LVISIBLE					:= .T.

Return .T.

/*
Funcao     : GrvPedido
Parametros : Nenhum
Retorno    :
Objetivos  : Grava o Pedido de Venda atraves do ExecAuto
Autor      : Jean Victor Rocha
Data/Hora  :
*/
*-------------------------------------*
Static Function	GrvPedido(aCab,aItens)
*-------------------------------------*
Local cRet := ""
Local i

lMsErroAuto		:= .F.
lMSHelpAuto		:= .F.
lAutoErrNoFile	:= .T.

BEGIN Transaction
//--Tratamento para o número sequencial do pedido de venda--//
lUsouGetC5:=.F.
If aScan(aDados, {|x| x[1] == "C5_NUM"}) == 0
	ChkIn("C5_NUM")
	aadd(aCab,{"C5_NUM", GETSXENUM("SC5","C5_NUM"),	Nil})
	lUsouGetC5:=.T.
Endif

MSExecAuto( {|x,y,z| MATA410(x,y,z) }, aCab, aItens, 3)
If lMsErroAuto
	If lUsouGetC5
		ROLLBACKSXE()
	Endif
	
	aAutoErro := GETAUTOGRLOG()
	
	aLog[Len(aLog)][LEN(aLog[Len(aLog)])-2] := "Erro no EXECAUTO"
	aLog[Len(aLog)][LEN(aLog[Len(aLog)])-1] := ""
	For i:=1 to Len(aAutoErro)
		aLog[Len(aLog)][LEN(aLog[Len(aLog)])-1] += ALLTRIM(aAutoErro[i])+CHR(13)+CHR(10)
	Next i
	
	aLog[Len(aLog)][LEN(aLog[Len(aLog)])] := .T.
	
	DisarmTransaction()
Else
	aLog[Len(aLog)][2] := aCab[aScan(aCab, {|x| x[1] == "C5_NUM"})][2]
	aLog[Len(aLog)][LEN(aLog[Len(aLog)])-2] := "Incluido com Sucesso"
	If lUsouGetC5
		Confirmsx8()
	Endif
EndIf
END Transaction

Return cRet

/*
Funcao      : ChkIn()
Parametros  : cCampo
Retorno     : Nenhum
Objetivos   : Verificando tratamento no Inicializador Padrão do A1_COD e C5_NUM.
Observações : Tratamento Migrado do IntPryor.
Autor       :
Data/Hora   :
*/
*----------------------------------*
Static Function ChkIn(cCampo)
*----------------------------------*
If cCampo=="C5_NUM"
	SX3->(DbSetOrder(2))
	If SX3->(Dbseek("C5_NUM"))
		If ALLTRIM(SX3->X3_RELACAO) <> 'IIF(ALLTRIM(FUNNAME())=="MATA410",GETSXENUM("SC5","C5_NUM"),"")'
			RECLOCK("SX3",.F.)
			SX3->X3_RELACAO := 'IIF(ALLTRIM(FUNNAME())=="MATA410",GETSXENUM("SC5","C5_NUM"),"")'
			SX3->(MSUNLOCK())
		EndIf
	EndIf
EndIf
Return .T.

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
Local aAlter := {"C5_MENNOTA","DETALHE"}
Private noBrw3  := 0
Private aHoBrw3 := {}

Aadd(aHoBrw3,{"Chave"  		,"C5_P_REF"		,"",TamSX3("C5_P_REF")[1]	,TamSX3("C5_P_REF")[2]	,"","",TamSX3("C5_P_REF")[3]	,"",""})
Aadd(aHoBrw3,{"Num. PV"		,"C5_NUM"		,"",TamSX3("C5_NUM")[1]		,TamSX3("C5_NUM")[2]	,"","",TamSX3("C5_NUM")[3]		,"",""})
Aadd(aHoBrw3,{"Tp. PV"		,"C5_TIPO" 		,"",TamSX3("C5_TIPO")[1]	,TamSX3("C5_TIPO")[2]	,"","",TamSX3("C5_TIPO")[3]		,"",""})
Aadd(aHoBrw3,{"Cliente"	   	,"C5_CLIENTE"	,"",TamSX3("C5_CLIENTE")[1]	,TamSX3("C5_CLIENTE")[2],"","",TamSX3("C5_CLIENTE")[3]	,"",""})
Aadd(aHoBrw3,{"Lj. Cli."   	,"C5_LOJACLI"	,"",TamSX3("C5_LOJACLI")[1]	,TamSX3("C5_LOJACLI")[2],"","",TamSX3("C5_LOJACLI")[3]	,"",""})
Aadd(aHoBrw3,{"Tp. Cli"	  	,"C5_TIPOCLI"	,"",TamSX3("C5_TIPOCLI")[1]	,TamSX3("C5_TIPOCLI")[2],"","",TamSX3("C5_TIPOCLI")[3]	,"",""})
Aadd(aHoBrw3,{"Cond. Pag"  	,"C5_CONDPAG"	,"",TamSX3("C5_CONDPAG")[1]	,TamSX3("C5_CONDPAG")[2],"","",TamSX3("C5_CONDPAG")[3]	,"",""})
Aadd(aHoBrw3,{"Emissao"	   	,"C5_EMISSAO"	,"",TamSX3("C5_EMISSAO")[1]	,TamSX3("C5_EMISSAO")[2],"","",TamSX3("C5_EMISSAO")[3]	,"",""})
Aadd(aHoBrw3,{"Transp."	   	,"C5_TRANSP"	,"",TamSX3("C5_TRANSP")[1]	,TamSX3("C5_TRANSP")[2],"","",TamSX3("C5_TRANSP")[3]	,"",""})
Aadd(aHoBrw3,{"Mens. Nota" 	,"C5_MENNOTA"	,"",500,00,"","","M","",""})
Aadd(aHoBrw3,{"Resumo"		,"RESUMO" 		,"",045,00,"","","C","",""})
Aadd(aHoBrw3,{"Detalhes"	,"DETALHE" 		,"",500,00,"","","M","",""})
noBrw3:= Len(aHoBrw3)


oDlg1      := MSDialog():New( 109,308,568,992,"Log de Integração de Pedidos de Vendas - HLB BRASIL.",,,.F.,,,,,,.T.,,,.T. )
oBrw3      := MsNewGetDados():New(004,004,204,332,nOpc,'AllwaysTrue()','AllwaysTrue()','',aAlter,0,9999,'AllwaysTrue()','','AllwaysTrue()',oDlg1,aHoBrw3,aLog )
oSBtn1     := SButton():New( 208,304,1,{|| oDlg1:end()},oDlg1,,"", )
oBtnSlv    := TButton():New( 208,004,"Salvar",oDlg1,{|| ARRAYtoEXCEL()},037,008,,,,.T.,,"",,,,.F. )

oDlg1:Activate(,,,.T.)


Return .T.

/*
Funcao      : BlqWizard()
Parametros  : cCampo
Retorno     : Nenhum
Objetivos   : Altera o Status dos botões do Wizard durante os processamentos.
Observações : Tratamento Migrado do IntPryor.
Autor       :
Data/Hora   :
*/
*-----------------------------*
Static Function BlqWizard(nOpc)
*-----------------------------*

If nopc == 1
	oWizMan:OBACK:LACTIVE	:= .F.
	oWizMan:OCANCEL:LACTIVE	:= .F.
	oWizMan:ONEXT:LACTIVE	:= .F.
	oWizMan:OFINISH:LACTIVE	:= .F.
	
ElseIf nOpc == 2
	oWizMan:OBACK:LACTIVE	:= .T.
	oWizMan:OCANCEL:LACTIVE	:= .T.
	oWizMan:ONEXT:LACTIVE	:= .T.
	oWizMan:OFINISH:LACTIVE	:= .T.
	
EndIf

Return .T.

/*
Funcao      : Encoding()
Parametros  : cTexto
Retorno     : Nenhum
Objetivos   : Altera
Observações : Table for Debugging Common UTF-8 Character Encoding Problems.
Autor       : Jean Victor Rocha
Data/Hora   : 10/02/2014
*/
*-----------------------------*
Static Function Encoding(cTexto)
*-----------------------------*
Local cRet := ""
Local aConvert := {	{'€', 'â‚'}, {'‚', 'â€'}, {'ƒ', 'Æ’'}, {'„', 'â€'}, {'…', 'â€'}, {'†', 'â€'}, {'‡', 'â€'}, {'ˆ', 'Ë†'}, {'‰', 'â€'},;
{'Š', 'Å'},  {'‹', 'â€'}, {'Œ', 'Å’'}, {'Ž', 'Å½'}, {'‘', 'â€˜'}, {'’', 'â€'}, {'“', 'â€'}, {'”', 'â€'}, {'•', 'â€'},;
{'–', 'â€'}, {'—', 'â€'}, {'™', 'â„'}, {'š', 'Å¡'}, {'›', 'â€'}, {'œ', 'Å“'}, {'ž', 'Å¾'}, {'Ÿ', 'Å¸'}, {'¡', 'Â¡'},;
{'¢', 'Â¢'}, {'£', 'Â£'}, {'¤', 'Â¤'}, {'¥', 'Â¥'}, {'¦', 'Â¦'}, {'§', 'Â§'}, {'¨', 'Â¨'}, {'©', 'Â©'}, {'ª', 'Âª'},;
{'«', 'Â«'}, {'¬', 'Â¬'}, {'®', 'Â®'}, {'¯', 'Â¯'}, {'°', 'Â°'}, {'±', 'Â±'}, {'²', 'Â²'}, {'³', 'Â³'}, {'´', 'Â´'},;
{'µ', 'Âµ'}, {'¶', 'Â¶'}, {'·', 'Â·'}, {'¸', 'Â¸'}, {'¹', 'Â¹'}, {'º', 'Âº'}, {'»', 'Â»'}, {'¼', 'Â¼'}, {'½', 'Â½'},;
{'¾', 'Â¾'}, {'¿', 'Â¿'}, {'À', 'Ã€'}, {'Á', 'Ã'},  {'Â', 'Ã‚'}, {'Ã', 'Ãƒ'}, {'Ä', 'Ã„'}, {'Å', 'Ã…'}, {'Æ', 'Ã†'},;
{'Ç', 'Ã‡'}, {'È', 'Ãˆ'}, {'É', 'Ã‰'}, {'Ê', 'ÃŠ'}, {'Ë', 'Ã‹'}, {'Ì', 'ÃŒ'}, {'Í', 'Ã'},  {'Î', 'ÃŽ'}, {'Ï', 'Ã'},;
{'Ð', 'Ã'},  {'Ñ', 'Ã‘'}, {'Ò', 'Ã’'}, {'Ó', 'Ã“'}, {'Ô', 'Ã”'}, {'Õ', 'Ã•'}, {'Ö', 'Ã–'}, {'×', 'Ã—'}, {'Ø', 'Ã˜'},;
{'Ù', 'Ã™'}, {'Ú', 'Ãš'}, {'Û', 'Ã›'}, {'Ü', 'Ãœ'}, {'Ý', 'Ã'},  {'Þ', 'Ãž'}, {'ß', 'ÃŸ'}, {'à', 'Ã'},  {'á', 'Ã¡'},;
{'â', 'Ã¢'}, {'ã', 'Ã£'}, {'ä', 'Ã¤'}, {'å', 'Ã¥'}, {'æ', 'Ã¦'}, {'ç', 'Ã§'}, {'è', 'Ã¨'}, {'é', 'Ã©'}, {'ê', 'Ãª'},;
{'ë', 'Ã«'}, {'ì', 'Ã¬'}, {'í', 'Ã­'}, {'î', 'Ã®'}, {'ï', 'Ã¯'}, {'ð', 'Ã°'}, {'ñ', 'Ã±'}, {'ò', 'Ã²'}, {'ó', 'Ã³'},;
{'ô', 'Ã´'}, {'õ', 'Ãµ'}, {'ö', 'Ã¶'}, {'÷', 'Ã·'}, {'ø', 'Ã¸'}, {'ù', 'Ã¹'}, {'ú', 'Ãº'}, {'û', 'Ã»'}, {'ü', 'Ã¼'},;
{'ý', 'Ã½'}, {'þ', 'Ã¾'}, {'ÿ', 'Ã¿'}	}

cRet := cTexto

//Caso esteja vazio, não executa o tratamento.
If EMPTY(cRet)
	Return cRet
EndIf

//Caso esteja habilitado a conversão.
If !GETMV("MV_P_00011",,.F.)
	Return cRet
EndIf

For i:=1 to Len(aConvert)
	//While AT(aConvert[i][2], cRet) <> 0
	cRet := STRTRAN(cRet, aConvert[i][2], aConvert[i][1])
	//EndDo
Next i

Return cRet

/*
Funcao      : ARRAYtoEXCEL()
Parametros  :
Retorno     : Nenhum
Objetivos   : Altera
Observações : Exporta para o Excel as informações do array de Log.
Autor       : Jean Victor Rocha
Data/Hora   : 11/02/2014
*/
*-----------------------------*
Static Function ARRAYtoEXCEL()
*-----------------------------*
Local cArq		:= GetTempPath()+"\LOG.xls"
Private nHdl	:= 0
Private nBytesSalvo := 0
Private cHtml	:= ""

If Len(oBrw3:ACOLS) == 0
	MsgInfo("Sem informação a ser gravada")
	Return .T.
EndIf

If FILE(cArq)
	FERASE(cArq)
EndIf

cHtml := GETHTML()

nHdl 		:= FCREATE(cArq,0 )  //Criação do Arquivo HTML.
nBytesSalvo := FWRITE(nHdl, cHtml ) // Gravação do seu Conteudo.
fclose(nHdl) // Fecha o Arquivo que foi Gerado


If nBytesSalvo <= 0	// Verificação do arquivo (GRAVADO OU NAO) e definição de valor de Bytes retornados.
	MsgStop("Erro de gravação do Destino. Error = "+ str(ferror(),4),'Erro')
Else
	fclose(nHdl)	// Fecha o Arquivo que foi Gerado
	cExt := '.xls'
	SHELLEXECUTE("open",(cArq),"","",5)// Gera o arquivo em Excel
Endif

Return .T.

/*
Funcao      : GETHTML()
Parametros  :
Retorno     : Nenhum
Objetivos   : Altera
Observações : Monta o HTML para o log.
Autor       : Jean Victor Rocha
Data/Hora   : 11/02/2014
*/
*-----------------------------*
Static Function GETHTML()
*-----------------------------*
Local cMsg := ""
cMsg += "<html>"
cMsg += "	<body>"
cMsg += "	<table height='361' width='844' bgColor='#ffffff' border='0' bordercolor='#ffffff' style='border-collapse: collapse' cellpadding='0' cellspacing='0'>"
cMsg += "		<td>Data Execução:</td><td></td><td width='400' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"+Dtoc(DATE())+"</td>"
cMsg += "		<tr><td></td><td></td><td></td>"
cMsg += "			<td  width='100' height='41' bgcolor='#ffffff' border='0' bordercolor='#ffffff' align = 'Left'><font face='times' color='black' size='4'><b>LOG de Integração</b></font></td>"
cMsg += "		</tr>"
cMsg += "		<tr></tr>"
cMsg += "		 <tr>"
cMsg += "	</table>"
cMsg += "	<table height='361' width='844' bgColor='#ffffff' border='1' bordercolor='#000000' style='border-collapse: collapse' cellpadding='0' cellspacing='0'>"
For i:=1 to Len(oBrw3:AHEADER)
	cMsg += "		<td width='400' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
	cMsg += "		<font face='times' color='black' size='3'> <b> "+ oBrw3:AHEADER[i][1] +"</b></font>"
	cMsg += "		</td>"
Next i
cMsg += "	</tr>"


For i:=1 to Len(oBrw3:ACOLS)
	cMsg += "		 <tr>"
	For j:=1 to Len(oBrw3:ACOLS[i])-1//Desconsidera a marca de deletado
		If ValType(oBrw3:ACOLS[i][j]) == "D"
			cCont := DtoC(oBrw3:ACOLS[i][j])
		ElseIf ValType(oBrw3:ACOLS[i][j]) == "N"
			cCont := NumtoExcel(oBrw3:ACOLS[i][j])
		ElseIf ValType(oBrw3:ACOLS[i][j]) == "C"
			cCont := ALLTRIM(oBrw3:ACOLS[i][j])
		EndIf
		cMsg += "			 <td width='400' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
		cMsg += "				<font face='times' color='black' size='3'>"+cCont
		cMsg += "			</td>"
	Next j
	cMsg += "		 </tr>"
Next i

cMsg += "	</table>"
cMsg += "	<BR?>"
cMsg += "</html> "

Return cMsg

//Altera para formato excel.
//Maximo 4 casas decimais.
*----------------------------------*
Static Function NumtoExcel(nValor,lValor)
*----------------------------------*
Local cRet		:= ""

Default lValor	:= .F.
Default nValor	:= 0

If !lValor
	nValor := (cAlias)->(&((cAlias)->(Fieldname(nValor))))
EndIf

nValor := ROUND(nValor,4)

If RIGHT(TRANSFORM(nValor, "@R 99999999999.9999"),4) == "0000"
	cRet := ALLTRIM(STR(nValor))
ElseIf RIGHT(TRANSFORM(nValor, "@R 99999999999.9999"),3) == "000"
	cRet := SUBSTR(ALLTRIM(STR(nValor)),0,LEN(ALLTRIM(STR(nValor)))-2)+","+RIGHT(ALLTRIM(STR(nValor)),1)
ElseIf RIGHT(TRANSFORM(nValor, "@R 99999999999.9999"),2) == "00"
	cRet := SUBSTR(ALLTRIM(STR(nValor)),0,LEN(ALLTRIM(STR(nValor)))-3)+","+RIGHT(ALLTRIM(STR(nValor)),2)
ElseIf RIGHT(TRANSFORM(nValor, "@R 99999999999.9999"),1) == "0"
	cRet := SUBSTR(ALLTRIM(STR(nValor)),0,LEN(ALLTRIM(STR(nValor)))-4)+","+RIGHT(ALLTRIM(STR(nValor)),3)
Else
	cRet := SUBSTR(ALLTRIM(STR(nValor)),0,LEN(ALLTRIM(STR(nValor)))-5)+","+RIGHT(ALLTRIM(STR(nValor)),4)
EndIf

Return cRet
