#include "topconn.ch"
#include "rwmake.ch"  
#iNCLUDE "AP5MAIL.CH" 
#include "Fileio.ch"

#DEFINE NEWLINE CHR(13)+CHR(10)

/*
Funcao      : 53FIN001
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Gera arquivo para integração no SAP.
Autor     	: Jean Victor Rocha
Data     	: 05/11/12
Cliente		: Boston
Obs         : 
TDN         : 
*/

*----------------------*
User Function 53FIN001()
*----------------------*
Private cPerg := "53FIN001"

If !(cEmpAnt $ "53|99")
	MsgInfo("Rotina não disponivel para esta empresa!","A T E N C A O")
	Return .F.
endif

//Ajusta o SX1.
AjustaSX1()

If !Pergunte(cPerg,.T.)
	MsgInfo("Erro na criação da tela de Filtro!","A T E N C A O")
	Return .F.	
EndIf

cDataIni	:= DTOS(MV_PAR01)
cDataFim	:= DTOS(MV_PAR02)
cDir		:= ALLTRIM(MV_PAR03)

//Geração do Arquivo TXT.
GeraArq()

Return .T.  

/*
Funcao      : AjustaSX1
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   :
Autor     	: Jean Victor Rocha
Data     	: 05/11/12
Obs         : 
*/
*-------------------------*
Static Function AjustaSX1()
*-------------------------*

U_PUTSX1(cPerg	,"01","Data de            ?","","","mv_ch1","D",08,00,00,"G","","","","","Mv_Par01","","","","","","","","","","","","","","","","",{"Informe a data Inicial"})
U_PUTSX1(cPerg	,"02","Data ate           ?","","","mv_ch2","D",08,00,00,"G","","","","","Mv_Par02","","","","","","","","","","","","","","","","",{"Informe a data final"})
U_PUTSX1(cPerg	,"03","Diretorio          ?","","","mv_ch3","C",30,00,00,"G","","","","","Mv_Par03","","","","","","","","","","","","","","","","",{"Informe o Diretorio de destino."})

Return .T. 

/*
Funcao      : GeraArq
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   :
Autor     	: Jean Victor Rocha
Data     	: 08/11/12
Obs         : 
*/
*-----------------------*
Static Function GeraArq()
*-----------------------*
Local n		:= 0
Local cTxt	:= ""

Private nHandle := 0
Private cArq	:= "BOSTON_"+DTOS(Date())

IF UPPER(cDir) <> "C:\" .and. FILE(cDir)
	MsgInfo("Diretorio invalido!")
	Return .T.
EndIf

While File(cDir+cArq+".TXT")
	n++
	If AT("(",cArq) <> 0
		cArq := SUBSTR(cArq,1,AT("(",cArq))+ALLTRIM(STR(n))+")"
	Else
		cArq += "("+ALLTRIM(STR(n))+")"
	EndIf
EndDo
cArq += ".TXT"
    
If (nHandle:=FCreate(cDir+cArq, FC_NORMAL)) == -1
	ALERT("Erro na criação do arquivo TXT.")
	Return .T.
EndIf

cTxt := BuscaDados()

If EMPTY(cTxt)
	Return .T.	
EndIf

FWrite(nHandle,cTxt)
FClose(nHandle)

MsgInfo("Arquivo gerado com sucesso na pasta informada!")


Return .T. 

/*
Funcao      : BuscaDados
Parametros  : 
Retorno     : 
Objetivos   : Carrega o Arquivo TXT.
Autor       : Jean Victor Rocha
Data/Hora   : 08/11/2012
TDN         : 
*/
*--------------------------*
Static Function BuscaDados()
*--------------------------*
Local i, j
Local cTxt		:= ""
Local cLinha	:= ""
Local aInfos	:= {}
Local aAux		:= {}

Local aOrd := SaveOrd({"SX3"})


//Carrega Work com as informações.
LoadWork()

CT1->(DbSetOrder(1)) //CT1_FILIAL+CT1_CONTA
CTT->(DbSetOrder(1)) //CTT_FILIAL+CTT_CUSTO
lNovo := .T.
nLinha := 0
While WRK->(!EOF())
	For i:=1 to 2 //Quebra de partida dobrada.
		cConta := cCC := cPost := ""
		If i == 1
			cConta := WRK->CT2_DEBITO
			cCC := WRK->CT2_CCD
			cPost := "40"
		Else
			cConta := WRK->CT2_CREDITO
			cCC := WRK->CT2_CCC
			cPost := "50"
		EndIf

		//Busca a COnta do SAP, campo personalizado no cadastro de Plano de COntas.
		If CT1->(DbSeek(xFilial("CT1")+cConta))
			cConta := ALLTRIM(CT1->CT1_P_CONT)
		Else
			cConta := ""
		EndIf

		//Busca o centro de Custo do SAP, campo personalizado no cadastro de centro de custo.
		If LEFT(cConta,1) == "5" 
			If CTT->(DbSeek(xFilial("CTT")+cCC))
				cCC := ALLTRIM(CTT->CTT_P_CC)
			Else
				cCc := ""
			EndIf
		Else
			cCc := ""
		EndIF
        
		If !EMPTY(cConta)

			//Quebra de quantidade de documentos. - Retirado a quebra de quantidade a pedido no projeto.
			/*If nLinha >= 900
				lNovo	:= .T.
				nLinha	:= 0
			EndIf*/

			aAux := {}
			//Definição do layout do Cliente
			//          POS,TAM,INFO
            If lNovo
				aAdd(aAux, {001,010,ALLTRIM(STR(MONTH(WRK->CT2_DATA)))+"/"+ALLTRIM(STR(DAY(WRK->CT2_DATA)))+"/"+ALLTRIM(STR(YEAR(WRK->CT2_DATA)))	})//Data do documento
				aAdd(aAux, {002,010,ALLTRIM(STR(MONTH(WRK->CT2_DATA)))+"/"+ALLTRIM(STR(DAY(WRK->CT2_DATA)))+"/"+ALLTRIM(STR(YEAR(WRK->CT2_DATA)))	})//Data da Publicação
				aAdd(aAux, {003,002,"SW"  		})//Tipo de Documento
				aAdd(aAux, {004,004,"2310" 		})//empresa
				aAdd(aAux, {005,003,"BRL" 		})//moeda
				aAdd(aAux, {006,016,WRK->CT2_LOTE})//referência
				aAdd(aAux, {007,025,"FECHAMENTO FOLHA"	})//Texto do cabeçalho do documento
				aAdd(aAux, {008,001,""})//calcular o imposto
				aAdd(aAux, {009,001,"X"})//novo documento
				lNovo := .F.
			Else
				aAdd(aAux, {001,010,""})//Data do documento
				aAdd(aAux, {002,010,""})//Data da Publicação
				aAdd(aAux, {003,002,""})//Tipo de Documento
				aAdd(aAux, {004,004,""})//empresa
				aAdd(aAux, {005,003,""})//moeda
				aAdd(aAux, {006,016,""})//referência
				aAdd(aAux, {007,025,""})//Texto do cabeçalho do documento
				aAdd(aAux, {008,001,""})//calcular o imposto
				aAdd(aAux, {009,001,""})//novo documento
			EndIf
			
			aAdd(aAux, {010,002,cPost})//postagem chave
			aAdd(aAux, {011,010,cConta})//Número de Conta
			aAdd(aAux, {012,004,""})//Código de nova empresa
			aAdd(aAux, {013,013,	PadL(ALLTRIM(STRTRAN(Transform(WRK->CT2_VALOR, "@E 9999999999.99" ),",",".")), 13, "0")})//quantidade 
			aAdd(aAux, {014,001,""})//Forma de Pagamento
			aAdd(aAux, {015,015,""})//código de jurisdição
			aAdd(aAux, {016,002,""})//Código Tributário
			aAdd(aAux, {017,004,""})//Área de Negócios
			aAdd(aAux, {018,010,cCC})//Centro de Custos
			aAdd(aAux, {019,010,""})//Centro de lucro
			aAdd(aAux, {020,012,""})//Ordem / Projeto
			aAdd(aAux, {021,050,WRK->CT2_HIST})//Texto item de linha
			aAdd(aAux, {022,001,""})//método de pagamento
			aAdd(aAux, {023,004,""})//As condições de pagamento
			aAdd(aAux, {024,008,""})//data-base
			aAdd(aAux, {025,001,""})//Bloco de pagamento
			aAdd(aAux, {026,001,""})//Moeda para pagamento automático
			aAdd(aAux, {027,030,""})//Referência de pagamento
			aAdd(aAux, {028,013,""})//Montante em Moeda Local
			aAdd(aAux, {029,001,""})//Contabilidade doc
			aAdd(aAux, {030,004,""})//código da fábrica
			aAdd(aAux, {031,006,""})//parceiro comercial

			//Adiciona ao array que possui todas as informações.
			aAdd(aInfos,aAux)
			nLinha++
		EndIf
	Next i

	WRK->(DbSkip())
EndDo

For i:=1 to Len(aInfos)
	cLinha	:= ""
	//Carrega os dados da linha
	For j:=1 to len(aInfos[i])
		cLinha += SUBSTR(aInfos[i][j][3],1,aInfos[i][j][2])+CHR(9)//TAB
	Next j
	//Carrega o Arquivo
	cTxt += cLinha + NEWLINE
Next i

RestOrd(aOrd)

Return cTxt  

/*
Funcao      : LoadWork
Parametros  : 
Retorno     : 
Objetivos   : Carrega o Arquivo TXT.
Autor       : Jean Victor Rocha
Data/Hora   : 08/11/2012
TDN         : 
*/
*--------------------------*
Static Function LoadWork()
*--------------------------*
Local cAlias := "WRK"

aStru:= {CT2->(DbStruct())}

If Select(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf

//Busca Primeira data da
cQry := "Select TOP 2 CT2_DATA"
cQry += " From "+RetSqlName("CT2")
cQry += " Where D_E_L_E_T_ <> '*'"
cQry += " AND CT2_FILIAL = '"+xFilial("CT2")+"'"
cQry += " AND CT2_LOTE = '004400'"
cQry += " AND CT2_MOEDLC = '04'"
If !EMPTY(cDataIni) //Data de
	cQry += " AND CT2_DATA >= '"+ALLTRIM(cDataIni)+"'"
EndIf
If !EMPTY(cDataFim) //Data Ate
	cQry += " AND CT2_DATA <= '"+ALLTRIM(cDataFim)+"'"
EndIf  
cQry += " Group by CT2_DATA"

DbUseArea(.T.,"TOPCONN",TCGENQry(,,ChangeQuery(cQry)),cAlias,.F.,.T.)

For i := 1 To Len(aStru)
	For j := 1 To Len(aStru[i])
		If aStru[i][j][2] <> "C" .and.  FieldPos(aStru[i][j][1]) > 0
			TcSetField(cAlias,aStru[i][j][1],aStru[i][j][2],aStru[i][j][3],aStru[i][j][4])
		EndIf
	Next j
Next i

n:=0
(cAlias)->(DbGoTop())
While (cAlias)->(!EOF())//Reccount nao funciona com query.
	n++
	(cAlias)->(DbSkip())
EndDo

(cAlias)->(DbGoTop())
If n > 1
	MsgInfo("Encontrado mais de 1 data de lançamento para o periodo informado, será considerado apenas a data de: '"+DTOC((cAlias)->CT2_DATA)+"'")
	cData := DTOS((cAlias)->CT2_DATA)
ElseIf n == 1
	cData := DTOS((cAlias)->CT2_DATA)
Else
	cData := "99999999"//para nao encontrar nenhum valor.
EndIf


If Select(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf
            
cQry := " SELECT *"
cQry += " FROM "+RetSqlName("CT2")
cQry += " WHERE D_E_L_E_T_ <> '*' AND CT2_FILIAL = '"+xFilial("CT2")+"'"
cQry += " AND CT2_DATA = '"+ALLTRIM(cData)+"'"
cQry += " AND CT2_LOTE = '004400'"
cQry += " AND CT2_MOEDLC = '04'"

DbUseArea(.T.,"TOPCONN",TCGENQry(,,ChangeQuery(cQry)),cAlias,.F.,.T.)

For i := 1 To Len(aStru)
	For j := 1 To Len(aStru[i])
		If aStru[i][j][2] <> "C" .and.  FieldPos(aStru[i][j][1]) > 0
			TcSetField(cAlias,aStru[i][j][1],aStru[i][j][2],aStru[i][j][3],aStru[i][j][4])
		EndIf
	Next j
Next i

Return .T.
