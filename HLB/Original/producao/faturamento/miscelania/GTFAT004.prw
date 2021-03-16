#include "rwmake.ch"
#include "protheus.ch"
#INCLUDE "TOPCONN.CH"  
  
/*
Funcao      : GTFAT004
Parametros  : 
Retorno     : 
Objetivos   : Preço medio do Armazem selecionado.
Autor       : Jean Victor Rocha
Data/Hora   : 25/05/2012
TDN         : 
*/

*-----------------------*
User Function GTFAT004()      
*-----------------------* 
//Empresas autorizadas a imprimir este relatorio!
/*If !cEmpAnt $ '99|6H'//teste|Chery
	Alert("Função não está disponível para esta empresa!")
	return .F.
Endif*/
Return Processa({|| Main()})

*-----------------------*
Static Function MAIN()
*-----------------------*
Local cPerg  := "GTFAT004"

Private cArm := ""

U_PUTSX1( cPerg, "01", "Armazem ?"	, "Armazem ?", "Armazem ?", "", "C",02,00,00,"G","" , "","","","MV_PAR01")

If !pergunte(cPerg,.T.)
	ALERT("Pergunte '"+cPerg+"' não encontrado, entrar em contato com a Equipe de Sistemas da HLB BRASIL!")
	return .F.
Endif

cArm := "" := MV_PAR01

CarregaWork()
ImprXLS()

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

If !EMPTY(cArm)
cQry += "		AND B2.B2_LOCAL = '"+ ALLTRIM(cArm) +"'"
EndIf
cQry += " Order by B2.B2_COD,B2.B2_USAI"

cQry:=ChangeQuery(cQry)
TcQuery cQry ALIAS "SB2WRK" NEW

IncProc("Busca no Banco de Dados finalizada...")

Return .t.

*-----------------------*
Static Function ImprXLS() 
*-----------------------*
Local nHdl
Local cHtml		:= ""
Private cDest	:=  GetTempPath()
Private cArq	:= "Custo_"+DTOS(date())+".xls"
Private nBytesSalvo:=0
	
IF FILE(cDest+cArq)
	FERASE(cDest+cArq)
ENDIF

nHdl		:= FCREATE(cDest+cArq,0 )	//Criação do Arquivo HTML.
nBytesSalvo	:= FWRITE(nHdl, cHtml )		// Gravação do seu Conteudo.
fclose(nHdl)							// Fecha o Arquivo que foi Gerado

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
cMsg += "		<td colspan='2'>Extração em:</td><td>"+Dtoc(DATE())+" - "+TIME()+"</td>"
cMsg += "		<tr></tr><tr>"
cMsg += "			<td colspan='7' bgcolor='#ffffff' border='0' bordercolor='#ffffff' align = 'Left'><font face='times' color='black' size='4'><b> "+SM0->M0_NOME+"</b></font></td>"
cMsg += "		</tr>"
cMsg += "		<tr></tr>"
cMsg += "		 <tr>"
cMsg += "	</table>"
cMsg += "	<table height='361' width='844' bgColor='#ffffff' border='2' bordercolor='#000000' style='border-collapse: collapse' cellpadding='0' cellspacing='0'>"
cMsg += "			 <td width='150' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
cMsg += "				 <font face='times' color='black' size='3'> <b> Cod. Prod. </b></font>"
cMsg += "			 </td>"
cMsg += "			 <td width='350' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
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
	cMsg += "			 <td width='350' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
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
