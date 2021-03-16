#include "rwmake.ch"
#include "protheus.ch"
#INCLUDE "TOPCONN.CH"  
/*
Funcao      : K2FAT002()
Parametros  : 
Retorno     : 
Objetivos   : Atualização da Tabela de Preço com o preço medio do ultimo fechamento.
Autor       : Jean Victor Rocha
Data/Hora   : 27/02/2012
Revisao     :
Obs.        :
*/ 
*-----------------------*
User Function K2FAT002()
*-----------------------*
If !(cEmpAnt $ "K2")
	MsgInfo("Geração de Tabela de preço não disponivel para esta empresa!")
	Return .t.
EndIf

Return Processa({|| Main()})

*-----------------------*
Static Function MAIN()
*-----------------------*


If MSGYESNO("Rotina ira atualizar a tabela de preço de acordo com a tabela de Saldos Fisicos. Deseja continuar?")
	CarregaWork()
	AtuTabPreco()
	ImprXLS()
EndIf

Return .T.
                          
*---------------------------*
Static Function CarregaWork()
*---------------------------*
Local cQry := ""

ProcRegua(2)
IncProc("Executando busca no Banco de Dados...")

If Select("SB2WRK") > 0
	SB2WRK->(DbCloseArea())
EndIf

cQry += " Select *"
cQry += " From "+RetSqlName("SB2")+ " B2"
cQry += " Where	B2.D_E_L_E_T_ <> '*' "
cQry += " 		AND B2.B2_CM1 <> 0 "
cQry += " 		AND B2.B2_USAI =	(Select MAX(B2_USAI) "
cQry += " 							From "+RetSqlName("SB2")+ " TEMP "
cQry += " 							Where	D_E_L_E_T_ <> '*' "
cQry += " 									AND TEMP.B2_COD = B2.B2_COD)"
cQry += " Order by B2.B2_COD,B2.B2_USAI"

cQry:=ChangeQuery(cQry)
TcQuery cQry ALIAS "SB2WRK" NEW

IncProc("Busca no Banco de Dados finalizada...")

Return .t.

*---------------------------*
Static Function AtuTabPreco()
*---------------------------*
Local lRec := .T.  
Local cLastUSAI := ""
Local cCod := ""

ProcRegua(2)
IncProc("Atualizando Capa da Tabela de Preço...")

DA0->(DbSetOrder(1))
If !DA0->(DbSeek(xFilial("DA0")+"XXX"))
	DA0->(RecLock("DA0", .T.))
	DA0->DA0_FILIAL := xFilial("DA0")
	DA0->DA0_CODTAB := "XXX"
	DA0->DA0_DESCRI := "AUTOMATICO - PRECO POR CUSTO"
	DA0->DA0_DATDE 	:= DATE()
	DA0->DA0_HORADE := "00:00"
	DA0->DA0_HORATE := "23:59"
	DA0->DA0_TPHORA := "1"
	DA0->DA0_ATIVO 	:= "1"
	DA0->(MsUnlock())
EndIf

IncProc("Atualizado Capa da Tabela de Preço...")
ProcRegua(SB2WRK->(RecCount()))

SB2WRK->(DbGoTop())
DA1->(DbSetOrder(1))
While SB2WRK->(!EOF())
	cLastUSAI := ALLTRIM(SB2WRK->B2_USAI)
	lRec := DA1->(DbSeek(xFilial("DA1")+"XXX"+SB2WRK->B2_COD))
	DA1->(RecLock("DA1", !lRec))
	DA1->DA1_ITEM	:= IF(!lRec, GetLastITEM(), DA1->DA1_ITEM)      
	DA1->DA1_FILIAL := DA0->DA0_FILIAL
	DA1->DA1_CODTAB	:= "XXX"
	DA1->DA1_CODPRO	:= SB2WRK->B2_COD
	DA1->DA1_PRCVEN	:= SB2WRK->B2_CM1
	DA1->DA1_ATIVO	:= IF(SB2WRK->B2_QATU > 0,"1","2")
	DA1->DA1_TPOPER	:= "4"
	DA1->DA1_DATVIG	:= DA0->DA0_DATDE
	DA1->DA1_MOEDA	:= 1
	DA1->DA1_QTDLOT	:= 999999.99
	DA1->(MsUnlock())
	IncProc("Atualizando Item da Tabela de Preço...")
	SB2WRK->(DbSkip())
EndDo

Return .t.  

*---------------------------*
Static Function GetLastITEM()
*---------------------------*
Local cItem := "0001"
Local cQry	:= ""

If Select("WORK") > 0
	WORK->(DbCloseArea())
EndIf

cQry += " Select MAX(DA1_ITEM) as DA1_ITEM"
cQry += " From "+RetSqlName("DA1")
cQry += " Where D_E_L_E_T_ <> '*' AND DA1_CODTAB = 'XXX'"

cQry:=ChangeQuery(cQry)
TcQuery cQry ALIAS "WORK" NEW
 
If !EMPTY(WORK->DA1_ITEM)
	cItem := STRZERO(VAL(WORK->DA1_ITEM)+1,4)
EndIf

WORK->(DbCloseArea())

Return cItem

*-----------------------*
Static Function ImprXLS() 
*-----------------------*
Local nHdl
Local cHtml		:= ""
Local aArquivos := {}
Local nPos		:= 0
Private cDest	:=  GetTempPath()
Private cArq	:= "Tabela_de_preco_"+DTOS(date())+".xls"
Private nBytesSalvo:=0

aArquivos := Directory(cDest+"\*.XLS","D")
While aScan(aArquivos, {|x|  LEFT(UPPER(x[1]),16)  == UPPER("Tabela_de_preco_") } ) <> 0
	npos := aScan(aArquivos, {|x|  LEFT(UPPER(x[1]),16)  == UPPER("Tabela_de_preco_") } )
	FERASE(cDest+aArquivos[npos][1])
	aArquivos := Directory(cDest+"\*.XLS","D")
EndDo

nHdl		:= FCREATE(cDest+cArq,0 )  //Criação do Arquivo HTML.
nBytesSalvo	:= FWRITE(nHdl, cHtml ) // Gravação do seu Conteudo.
fclose(nHdl) // Fecha o Arquivo que foi Gerado

Montaxls()
	
If nBytesSalvo <= 0   // Verificação do arquivo (GRAVADO OU NAO) e definição de valor de Bytes retornados.
	MsgStop("Erro de gravação do Destino. Error = "+ str(ferror(),4),'Erro')
else
	fclose(nHdl) // Fecha o Arquivo que foi Gerado
	cExt := '.xls'
	SHELLEXECUTE("open",(cDest+cArq),"","",5)   // Gera o arquivo em Excel
endif
          
//FErase(cDest+cArq)
Return .t.

//Foi quebrado em etapas para não causar estouro de variavel.
*----------------------------*
Static Function Montaxls(cOpc)
*----------------------------*
Local cMsg := ""
Local cAliasWork := "SB2WRK"

cMsg += "<html>"
cMsg += "	<body>"
cMsg += "	<table height='361' width='844' bgColor='#ffffff' border='0' bordercolor='#ffffff' style='border-collapse: collapse' cellpadding='0' cellspacing='0'>"
cMsg += "		<td colspan='2'>Data da execução em:</td><td>"+Dtoc(DATE())+" - "+TIME()+"</td>"
cMsg += "		<tr></tr><tr>"
cMsg += "			<td colspan='7' bgcolor='#ffffff' border='0' bordercolor='#ffffff' align = 'Left'><font face='times' color='black' size='4'><b> Log de atualização da tabela de preço Harris. </b></font></td>"
cMsg += "		</tr>"
cMsg += "		<tr></tr>"
cMsg += "		 <tr>"
cMsg += "	</table>"
cMsg += "	<table height='361' width='844' bgColor='#ffffff' border='2' bordercolor='#000000' style='border-collapse: collapse' cellpadding='0' cellspacing='0'>"
cMsg += "			 <td width='150' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
cMsg += "				 <font face='times' color='black' size='3'> <b> Cod. Prod. </b></font>"
cMsg += "			 </td>"
cMsg += "			 <td width='250' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
cMsg += "				 <font face='times' color='black' size='3'> <b> Desc. Prod. </b></font>"
cMsg += "			 </td>"
cMsg += "			 <td width='150' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
cMsg += "				 <font face='times' color='black' size='3'> <b> Qtde Atual </b></font>"
cMsg += "			 </td>"
cMsg += "			 <td width='150' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
cMsg += "				 <font face='times' color='black' size='3'> <b> Local </b></font>"
cMsg += "			 </td>"
cMsg += "			 <td width='150' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
cMsg += "				 <font face='times' color='black' size='3'> <b> Vlr. Unit. </b></font>"
cMsg += "			 </td>"
cMsg += "			 <td width='150' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
cMsg += "				 <font face='times' color='black' size='3'> <b> Status </b></font>"
cMsg += "			 </td>"
cMsg += "		 </tr>"

cMsg := GrvXLS(cMsg) //Grava e limpa memoria da variavel.

ProcRegua(SB2WRK->(RecCount()))

SB1->(DbSetOrder(1))

SB2WRK->(DbGoTop())
DA1->(DbSetOrder(1))
While SB2WRK->(!EOF())
	SB1->(DbSeek(xFilial("SB1")+(cAliasWork)->B2_COD))
	cMsg += "		 <tr>"
	cMsg += "			 <td width='150' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
	cMsg += "				<font face='times' color='black' size='3'> "+FormulaTEXTO((cAliasWork)->B2_COD)
	cMsg += "			</td>"
	cMsg += "			 <td width='250' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
	cMsg += "				<font face='times' color='black' size='3'> "+SB1->B1_DESC
	cMsg += "			</td>"
	cMsg += "			 <td width='150' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
	cMsg += "				<font face='times' color='black' size='3'> "+ALLTRIM(STR((cAliasWork)->B2_QATU))
	cMsg += "			</td>"                                         	
	cMsg += "			 <td width='150' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
	cMsg += '				<font face="times" color="black" size="3"> '+FormulaTEXTO((cAliasWork)->B2_LOCAL)
	cMsg += "			</td>"
	cMsg += "			 <td width='150' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
	cMsg += "				<font face='times' color='black' size='3'> "+NumtoExcel((cAliasWork)->B2_CM1)
	cMsg += "			</td>"
	cMsg += "			 <td width='150' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
	cMsg += "				<font face='times' color='black' size='3'>Atualizado com sucesso."
	cMsg += "			</td>"
	cMsg += "		 </tr>"                                  
	cMsg := GrvXLS(cMsg) //Grava e limpa memoria da variavel.
	IncProc("Gerando arquivo Excel...")	
	SB2WRK->(DbSkip())
EndDo

cMsg += "	</table>"
cMsg += "	<BR?>"
cMsg += "</html> "

cMsg := GrvXLS(cMsg) //Grava e limpa memoria da variavel.

Return cMsg

*------------------------------*
Static Function GrvXLS(cMsg)
*------------------------------*
Local nHdl		:= Fopen(cDest+cArq)

FSeek(nHdl,0,2)
nBytesSalvo += FWRITE(nHdl, cMsg )
fclose(nHdl)

Return ""

*-------------------------------*
Static Function NumtoExcel(nCont)
*-------------------------------*
Local cRet := ""
Local nValor:= nCont
Local cValor:= TRANSFORM(nValor, "@R 99999999999.99")
Local nLen := LEN(ALLTRIM(cValor))

cRet := SUBSTR(ALLTRIM(cValor),0,nLen-3)+","+RIGHT(ALLTRIM(cValor),2)

Return cRet

*---------------------------------*
Static Function FormulaTEXTO(cCont)
*---------------------------------*
Local cRet  := ""
Local cCont := ALLTRIM(cCont)
Local nLen  := Len(cCont)

For i:=1 to Len(cCont)
	If ASC(SubStr(cCont, i,1)) < 48 .or. ASC(SubStr(cCont, i,1)) > 57
		cRet := cCont
		Exit
	EndIf
Next i      

If EMPTY(cRet)
	cRet := '=TEXTO('+cCont+';"'+Replicate(CHR(48), nLen)+'")'
EndIf

Return cRet