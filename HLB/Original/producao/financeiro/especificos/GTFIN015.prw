#include "Protheus.ch"
#include "Rwmake.ch"
#include "TopConn.ch"
#Include "tbiconn.ch"        
/*
Funcao      : VALIDSED()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Valida se naureza existe na tabela de natureza.
Autor     	: João Silva
Data     	: 09/12/2015
*/
*--------------------------*
User function VALIDSED() 
*--------------------------*
Do Case
	Case ReadVar() == "M->CODRE"
		If AllTrim(&(ReadVar())) <> ""
			DbSelectArea("SX5")
			SX5->(DbSetOrder(1)) 
			If	SX5->(!DbSeeK(xFilial("SX5")+"37"+&(ReadVar()),.T.))  
				MsgInfo("Codigo informado não existe!")
				Return (.F.)
			EndIf
		EndIf
EndCase

Return (.T.)
/*
----------------------------------------------------------------------------------------------------------------------------------------------
Funcao    	: GTFIN015()
Parametros  : Nenhum
Retorno     : Nil                                                                                 '
Objetivos 	: Relatório de balanço das contas contábeis para que esse seja integrado ao ERP Oracle do TWITTER
Data      	: 09/12/2015
----------------------------------------------------------------------------------------------------------------------------------------------
*/
*------------------------*
User Function GTFIN015()
*------------------------*
Local 	aObjects 	:= {}//Variável com os dados
Local 	aBotoes		:= {}//Variável onde será incluido o botão para a legenda
Local 	aSize	   	:= {}//Variável para dimencionar a tela

Private cPerg  		:= "GTFIN015"
Private oLista           //Declarando o objeto do browser
Private aCabecalho  := {}//Variavel que montará o aHeader do grid
Private aColsEx 	:= {}//Variável que receberá os dados
Private	aaCampos	:= {"E2_DIRF","CODRE"}//Variável contendo o campo editável no Grid

//Declarando os objetos de cores para usar na coluna de status do grid
Private oVermelho	:= LoadBitmap( GetResources(), "BR_VERMELHO")
// Faz o calculo automatico de dimensoes de objetos
aSize := MsAdvSize()
// Dados da área de trabalho e separação
aInfo 	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
// Dados da Enchoice
AAdd( aObjects, { 50, 30, .T., .T. } )
// Dados da getdados
AAdd( aObjects, { 50,180, .T., .T. } )
// Chama MsObjSize e recebe array e tamanhos
aPosObj := MsObjSize( aInfo, aObjects,.T.)
//Criação da janela
DEFINE MSDIALOG oDlg TITLE "Manutenção de Titulos a Pagar" FROM aSize[7],0 To aSize[6],aSize[5] PIXEL
//Filtro
CriaFilt()
//chamar a função que cria a estrutura do aHeader                 
CriaHead()
//Carregar os itens que irão compor o conteudo do grid
CriaGrid()
//Monta o browser com inclusão, remoção e atualização
oLista := MsNewGetDados():New( aPosObj[2,1]-20,aPosObj[2,2],aPosObj[2,3],aPosObj[2,4], GD_INSERT+GD_DELETE+GD_UPDATE,;
"AllwaysTrue", "AllwaysTrue", "AllwaysTrue", aACampos,1, 9999999,"U_VALIDSED()", "", "AllwaysTrue", oDlg, aCabecalho, aColsEx) 
//Alinho o grid para ocupar todo o meu formulário
oLista:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
//Ao abrir a janela o cursor está posicionado no meu objeto
oLista:oBrowse:SetFocus()
//Crio o menu que irá aparece no botão Ações relacionadas
aadd(aBotoes,{"NG_ICO_LEGENDA", {||Legenda()},"Legenda","Legenda"})
EnchoiceBar(oDlg, {|| AtuSE2() }, {|| oDlg:End() },,aBotoes)
ACTIVATE MSDIALOG oDlg CENTERED
Return
/*
----------------------------------------------------------------------------------------------------------------------------------------------
Funcao    	: CriaHead()
Parametros  : Nenhum
Retorno     : Nil
Objetivos 	: Função que cria a estrutura do aHeader
Data      	: 09/12/2015
----------------------------------------------------------------------------------------------------------------------------------------------
*/
*--------------------------*
Static Function CriaHead()
*--------------------------*
//X3Titulo()	,//X3_CAMPO		 //X3_PICTURE				//X3_TAMANHO//X3_DECIMAL//X3_VALID	//X3_USADO			//X3_TIPO	//X3_F3	//X3_CONTEXT//X3_CBOX	//X3_RELACAO	//X3_WHEN
Aadd(aCabecalho, {""			,"IMAGEM"		,"@BMP"						,3			,0			,".F."	 	,""			 	  	,"C"		,""		,"V"		,""			,""	 			,"","V"})
Aadd(aCabecalho, {"Prefixo"		,"E2_PREFIXO"	,"@!"						,3			,0			,""			,"ÇÇÇÇÇÇÇÇÇÇÇÇÇÇá"	,"C"		,""		,""			,""			,""	 			,""})
Aadd(aCabecalho, {"No. Titulo"	,"E2_NUM"		,"@!"						,9			,0			,""			,"ÇÇÇÇÇÇÇÇÇÇÇÇÇÇ¦"	,"C"		,""		,""	  		,""			,""	 			,""})
Aadd(aCabecalho, {"Parcela"		,"E2_PARCELA"	,"@!"						,1			,0			,""			,"ÇÇÇÇÇÇÇÇÇÇÇÇÇÇá"	,"C"		,""		,""			,""			,""	 			,""})
Aadd(aCabecalho, {"Tipo"		,"E2_TIPO"		,"@!"						,3			,0			,""			,"ÇÇÇÇÇÇÇÇÇÇÇÇÇÇ¦"	,"C"		,""		,""	 		,""			,""	 			,""})
Aadd(aCabecalho, {"Natureza"	,"E2_NATUREZ"	,"@!"						,10			,0			,""			,"ÇÇÇÇÇÇÇÇÇÇÇÇÇÇá"	,"C"		,"SED"	,""	 		,""			,""	 			,""})
Aadd(aCabecalho, {"Gera DIRF"	,"E2_DIRF"		,"@!"						,1			,0			,""			,"ÇÇÇÇÇÇÇÇÇÇÇÇÇÇá"	,"C"		,""		,""	 		,"1=Sim;2=Nao",""	 		,""})
Aadd(aCabecalho, {"Cd. Retenção","CODRE"		,"9999"						,4			,0			,""			,"ÇÇÇÇÇÇÇÇÇÇÇÇÇÇá"	,"C"		,"37 "	,""	 		,""			,""	 			,""})
Aadd(aCabecalho, {"Fornecedor"	,"E2_FORNECE"	,"@!"						,6	 		,0			,""			,"ÇÇÇÇÇÇÇÇÇÇÇÇÇÇá"	,"C"		,"SA2"	,""	 		,""			,""	 			,""})
Aadd(aCabecalho, {"Loja"		,"E2_LOJA"		,"@!"						,2			,0			,""			,"ÇÇÇÇÇÇÇÇÇÇÇÇÇÇá"	,"C"		,""		,""	  		,""			,""	 			,""})
Aadd(aCabecalho, {"Nome Fornece","E2_NOMFOR"	,"@!"						,20			,0			,""			,"ÇÇÇÇÇÇÇÇÇÇÇÇÇÇá"	,"C"		,""		,""	 		,""			,""	 			,""})
Aadd(aCabecalho, {"DT Emissao"	,"E2_EMISSAO"	,""							,8			,0			,""			,"ÇÇÇÇÇÇÇÇÇÇÇÇÇÇá"	,"D"		,""		,""			,""			,""	 			,""})
Aadd(aCabecalho, {"Vencimento"	,"E2_VENCTO"	,""							,8			,0			,""			,"ÇÇÇÇÇÇÇÇÇÇÇÇÇÇá"	,"D"		,""		,""	 		,""			,""	 			,""})
Aadd(aCabecalho, {"Vencto Real"	,"E2_VENCREA"	,""							,8	  		,0			,""			,"ÇÇÇÇÇÇÇÇÇÇÇÇÇÇá"	,"D"		,""		,""			,""			,""	 			,""})
Aadd(aCabecalho, {"Vlr.Titulo"	,"E2_VALOR"		,"@E 9,999,999,999,999.99"	,16			,2			,""			,"ÇÇÇÇÇÇÇÇÇÇÇÇÇÇá"	,"N"		,""		,""			,""			,""	 			,""})
Aadd(aCabecalho, {"DT Baixa"	,"E2_BAIXA"		,""							,8			,0			,""			,"ÇÇÇÇÇÇÇÇÇÇÇÇÇÇÇ"	,"D"		,""		,""			,""			,""	 			,""})
Aadd(aCabecalho, {"Saldo"		,"E2_SALDO"		,"@E 9,999,999,999,999.99"	,16			,2			,""			,"ÇÇÇÇÇÇÇÇÇÇÇÇÇÇ¿"	,"N"		,""		,""			,""			,""	 			,""})
Return
/*
----------------------------------------------------------------------------------------------------------------------------------------------
Funcao    	: CriaGrid()
Parametros  : Nenhum
Retorno     : Nil
Objetivos 	: Função que carregar os itens que irão compor o conteudo do grid
Data      	: 09/12/2015
----------------------------------------------------------------------------------------------------------------------------------------------
*/
*-------------------------*
Static Function CriaGrid()
*-------------------------*
//Verifico se ja existe esta Query
If Select("QRY1") > 0
	QRY1->(DbCloseArea())
EndIf

cQuery1:="	SELECT E2_FILIAL,E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO,E2_NATUREZ,E2_DIRF,E2_CODRET,E2_FORNECE,E2_LOJA,E2_NOMFOR,E2_EMISSAO,E2_VENCTO,E2_VENCREA,E2_VALOR,E2_BAIXA,E2_SALDO"
cQuery1+=" 	FROM "+RETSQLNAME("SE2")
cQuery1+="	WHERE"
cQuery1+="	D_E_L_E_T_ <> '*'"
cQuery1+="	AND E2_PREFIXO	>= '"+mv_par01+"'"
cQuery1+="	AND E2_PREFIXO	<= '"+mv_par02+"'"
cQuery1+="	AND E2_NUM		>= '"+mv_par03+"'"
cQuery1+="	AND E2_NUM		<= '"+mv_par04+"'"
cQuery1+="	AND E2_PARCELA	>= '"+mv_par05+"'"
cQuery1+="	AND E2_PARCELA	<= '"+mv_par06+"'"
cQuery1+="	AND E2_FORNECE	>= '"+mv_par07+"'"
cQuery1+="	AND E2_FORNECE	<= '"+mv_par08+"'"
cQuery1+="	AND E2_VENCTO	>= '"+DtoS(mv_par09)+"'"
cQuery1+="	AND E2_VENCTO	<= '"+DtoS(mv_par10)+"'"
cQuery1+="	AND E2_VALOR	>=  "+cValToChar(mv_par11)+""
cQuery1+="	AND E2_VALOR	<=  "+cValToChar(mv_par12)+""    
cQuery1+="	AND E2_NATUREZ	>=  '"+mv_par13+"'"
cQuery1+="	AND E2_NATUREZ	<=  '"+mv_par14+"'"
If mv_par15 == 1
	cQuery1+="	AND E2_DIRF	= '1' 	"
ElseIf mv_par15 == 2
	cQuery1+="	AND E2_DIRF	= '2' 	"	
EndIf

TcQuery cQuery1 Alias "QRY1" New

QRY1->(DbGoTop())
While QRY1->(!EOF())
	aadd(aColsEx,{oVermelho,QRY1->E2_PREFIXO,QRY1->E2_NUM,QRY1->E2_PARCELA,QRY1->E2_TIPO,QRY1->E2_NATUREZ,QRY1->E2_DIRF,QRY1->E2_CODRET,;
	QRY1->E2_FORNECE,QRY1->E2_LOJA,QRY1->E2_NOMFOR,QRY1->E2_EMISSAO,QRY1->E2_VENCTO,QRY1->E2_VENCREA,QRY1->E2_VALOR,;
	QRY1->E2_BAIXA,QRY1->E2_SALDO,.F.})
	QRY1->(DbSkip())
EndDo
Return
/*
Funcao      : AtuSE2()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Atualiza a tabela SE2
Autor     	: João Silva
Data     	: 09/12/2015
*/
*------------------------*
Static Function AtuSE2()
*------------------------*
Local i:=0 
QRY1->(DbGoTop())
While QRY1->(!EOF())
	SE2->(DbSetOrder(1))//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
	SE2->(DbGoTop())
	i+=1
	If SE2->(DbSeek(QRY1->E2_FILIAL+QRY1->E2_PREFIXO+QRY1->E2_NUM+QRY1->E2_PARCELA+QRY1->E2_TIPO+QRY1->E2_FORNECE+QRY1->E2_LOJA))
		If SE2->E2_DIRF<>OLISTA:ACOLS[i][7]  //Atualiza a informação da dirf
				RecLock("SE2",.F.)
				SE2->E2_DIRF := OLISTA:ACOLS[i][7]
				MsUnLock()
		EndIf  
		If	SE2->E2_CODRET<>OLISTA:ACOLS[i][8]//Atualiza a informação do codigo de rentenção.
				RecLock("SE2",.F.)
				SE2->E2_CODRET :=OLISTA:ACOLS[i][8]
				MsUnLock()			
		EndIf
			QRY1->(DbSkip())			  			              
	Else
		MsgInfo("Titulo "+QRY1->E2_PREFIXO+" "+QRY1->E2_NUM+" não localisado.")
		Return()
	EndIf
EndDo
Msginfo("Titulos alterados com sucesso!","HLB BRASIL")   
Return()
/*
Funcao      : CriaFilt()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Cria o Pergunte no SX1
Autor     	: João Silva
Data     	: 09/12/2015
*/
*------------------------*
Static Function CriaFilt()
*------------------------*
CriaX1()
Pergunte(cPerg,.T.,"Filtro de exibição")
If	mv_par09 > mv_par10
	MsgInfo("A vencimento 'De' não pode ser maior que a vencimento 'Ate'. ","HLB BRASIL")
EndIf 
Return()
/*
Funcao      : CriaX1()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Cria o Pergunte no SX1
Autor     	: João Silva
Data     	: 09/12/2015
*/
*------------------------*
Static Function CriaX1()
*------------------------*
U_PUTSX1(cPerg,"01" ,"Prefixo De: ? "		,"Prefixo De: ? "		,"Prefixo De: ? "		,"mv_ch01","C",03,0, 0,"G","","","","","mv_par01",""		,""		,""		,"	 "				,""		,""		,""		,"","","","","","","","","",{"Prefixo inicial dos titulos" 	}	,{},{})
U_PUTSX1(cPerg,"02" ,"Prefixo Ate: ? "	,"Prefixo Ate: ? "		,"Prefixo Ate: ? "		,"mv_ch02","C",03,0, 0,"G","","","","","mv_par02",""		,""		,""		,"ZZZ"				,""		,""		,""		,"","","","","","","","","",{"Prefixo final dos titulos" 	} 	,{},{})
U_PUTSX1(cPerg,"03" ,"Nº Titulo De: ?"	,"Nº Titulo De: ?"		,"Nº Titulo De: ?"	  	,"mv_ch03","C",09,0, 0,"G","","","","","mv_par03",""		,""		,""		,"         "		,""		,""		,""		,"","","","","","","","","",{"Numero inicial dos titulos" 	}	,{},{})
U_PUTSX1(cPerg,"04" ,"Nº Titulo Ate: ? "	,"Nº Titulo Ate: ? "	,"Nº Titulo Ate: ? "	,"mv_ch04","C",09,0, 0,"G","","","","","mv_par04",""		,""		,""		,"999999999"		,""		,""		,""		,"","","","","","","","","",{"Numero final dos titulos"	 	}	,{},{})
U_PUTSX1(cPerg,"05" ,"Parcela De: ?"		,"Parcela De: ?" 		,"Parcela De:?"	  		,"mv_ch05","C",01,0, 0,"G","","","","","mv_par05",""		,""		,""		," "				,""		,""		,""		,"","","","","","","","","",{"Parcela inicial" 				}	,{},{})
U_PUTSX1(cPerg,"06" ,"Parcela Ate: ?"		,"Parcela Ate: ?"  		,"Parcela Ate: ?"		,"mv_ch06","C",01,0, 0,"G","","","","","mv_par06",""		,""		,""		,"Z"				,""		,""		,""		,"","","","","","","","","",{"Parcela final " 				}	,{},{})
U_PUTSX1(cPerg,"07" ,"Fornecedor De: ? "	,"Fornecedor De: ? "	,"Fornecedor De: ? "	,"mv_ch07","C",06,0, 0,"G","","","","","mv_par07",""		,""		,""		,"000000"			,""		,""		,""		,"","","","","","","","","",{"Data Inicial dos lctos" 		}	,{},{})
U_PUTSX1(cPerg,"08" ,"Fornecedor Ate: ?"	,"Fornecedor Ate: ?"	,"Fornecedor Ate: ?"  	,"mv_ch08","C",06,0, 0,"G","","","","","mv_par08",""		,""		,""		,"ZZZZZZ"			,""		,""		,""		,"","","","","","","","","",{"Data Final dos lctos" 		}	,{},{})
U_PUTSX1(cPerg,"09" ,"Vencimento De: ? "	,"Vencimento De: ? "	,"Vencimento De: ? "	,"mv_ch09","D",08,0, 0,"G","","","","","mv_par09",""		,""		,""		,"01012000"			,""		,""		,""		,"","","","","","","","","",{"Data de vencimento inicial"	}	,{},{})
U_PUTSX1(cPerg,"10" ,"Vencimento Ate: ?"	,"Vencimento Ate: ?"	,"Vencimento Ate: ?"	,"mv_ch10","D",08,0, 0,"G","","","","","mv_par10",""		,""		,""		,"31122030"			,""		,""		,""		,"","","","","","","","","",{"Data de vencimento final" 	}	,{},{})
U_PUTSX1(cPerg,"11" ,"Valor De: ? "		,"Valor De: ? "			,"Valor De: ? "	  		,"mv_ch11","N",16,2, 0,"G","","","","","mv_par11",""		,""		,""		,"0"				,""		,""		,""		,"","","","","","","","","",{"Valor dos lctos" 				}	,{},{})
U_PUTSX1(cPerg,"12" ,"Valor Ate: ?"		,"Valor Ate: ?" 		,"Valor Ate: ?"	  		,"mv_ch12","N",16,2, 0,"G","","","","","mv_par12",""		,""		,""		,"9999999999999"	,""		,""		,""		,"","","","","","","","","",{"Valor dos lctos" 				}	,{},{})
U_PUTSX1(cPerg,"13" ,"Natureza De: ?"		,"Natureza De: ?" 		,"Natureza De:?"  		,"mv_ch13","C",10,0, 0,"G","","SED","","S","mv_par13",""		,""		,""		," "				,""		,""		,""		,"","","","","","","","","",{"Natureza inicial" 			}	,{},{})
U_PUTSX1(cPerg,"14" ,"Natureza Ate: ?"	,"Natureza Ate: ?" 		,"Natureza Ate: ?"		,"mv_ch14","C",10,0, 0,"G","","SED","","S","mv_par14",""		,""		,""		,"ZZZZZZZZZZ"		,""		,""		,""		,"","","","","","","","","",{"Natureza final" 				}	,{},{})
U_PUTSX1(cPerg,"15" ,"Status DIRF: ?"		,"Status DIRF : ?" 		,"Status DIRF : ?"		,"mv_ch15","N",01,0,01,"C","","","","","mv_par15","Sim"		,"Sim"	,"Sim"	,"Sim"				,"Não"	,"Não"	,"Não"	,"Ambas","Ambas","Ambas","","","","","","",{"Informar se deja que aparecão so titulos com o campo DIRF preenchido como 'Não','Sim' ou Ambas"				}	,{},{})

/*
Funcao      : Legenda()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Cria o painel de legenda
Autor     	: João Silva
Data     	: 09/12/2015
*/
*------------------------*
Static function Legenda() 
*------------------------*
Local aLegenda := {}
AADD(aLegenda,{"BR_VERMELHO" 	,"   Titulo de contas a pagar." })
BrwLegenda("Legenda", "Legenda", aLegenda)
Return Nil      
