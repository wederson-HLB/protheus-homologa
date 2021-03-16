#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.ch"
#INCLUDE "TBICONN.ch"

/*
Funcao      : BHFAT003()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Relatório de vendas mensal SNF.
Autor       : Renato Rezende
Data/Hora   : 10/06/2014
*/                          
*-------------------------*
 User Function BHFAT003()
*-------------------------*
Private titulo		:= "Relatório SNF Vendas"
Private cPerg		:= ""
Private cDest		:= ""
Private cArq		:= ""
Private cQuery		:= ""
Private nBytesSalvo	:= 0 
Private nRecCount	:= 0

//Verificando se está na empresa SNF
If !(cEmpAnt) $ "BH"
     MsgInfo("Rotina não implementada para essa empresa!","HLB BRASIL")
     Return
EndIf

cPerg := "BHFAT3"
//Criando Pergunte
CriaPerg()
//Chamando Pergunte
If !Pergunte(cPerg,.T.)
	Return  
EndIf

//Gravado no temporário da máquina
cDest	:=  GetTempPath()

If FILE (cDest+"SNF.xls")
	FERASE (cDest+"SNF.xls")
EndIf
cArq	:= "SNF.xls"

//Chamada da Query
GeraTMP()

Return

/*
Funcao      : GeraTMP
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Query gerada para relatório de vendas Mensal
Autor     	: Renato Rezende  	 	
Data     	: 10/06/2014
Módulo      : Faturamento.
Cliente     : SNF.
*/
*------------------------------*
 Static Function GeraTMP()
*------------------------------*
// Se as tabelas temporarias estiverem abertas, fecha.
If Select('TMP')>0
	TRT->(DbCloseArea())
EndIf
cQuery		:= ""

//Início do Select
cQuery+= " Select UPPER(A3_EMAIL) AS EMAIL"
cQuery+= " 			,A3_REGIAO AS REGIAO"
cQuery+= " 			,A3_NOME AS VENDEDOR"
cQuery+= "			,F2_VEND1 As CODIGO"
cQuery+= " 				,SubString(D2_EMISSAO,7,2)+'/'+SubString(D2_EMISSAO,5,2)+'/'+SubString(D2_EMISSAO,1,4) As EMISSAO"
cQuery+= "				,D2_SERIE+D2_DOC As DOCUMENTO"              
cQuery+= "				,D2_CLIENTE+'/'+D2_LOJA As CLIENTE"    
cQuery+= "				,A1_NOME  As NOME" 
cQuery+= "				,A1_END+'-'+A1_MUN+'/'+A1_EST  As ENDERECO"
cQuery+= "				,D2_COD As PRODUTO"                       
cQuery+= "				,C6_DESCRI As DESCRICAO"                    
cQuery+= "				,Convert(Numeric(9,2),D2_QUANT) As QUANT"                      
cQuery+= "				,Convert(Numeric(18,2),D2_TOTAL+D2_VALIPI) As TOTAL"
cQuery+= "				From SF2BH0 SF2"
cQuery+= "					,SD2BH0 SD2"
cQuery+= "					,SA1BH0 SA1"
cQuery+= "					,SC6BH0 SC6"
cQuery+= "					,SF4YY0 SF4"
cQuery+= "					,SA3BH0 SA3"
cQuery+= "				Where SF2.D_E_L_E_T_ <> '*'"
cQuery+= "				AND SD2.D_E_L_E_T_ <> '*'"
cQuery+= "				AND SA1.D_E_L_E_T_ <> '*'"
cQuery+= "				AND SC6.D_E_L_E_T_ <> '*'"
cQuery+= "				AND SF4.D_E_L_E_T_ <> '*'"
cQuery+= "				AND SA3.D_E_L_E_T_ <> '*'"
cQuery+= "				AND SA3.A3_EMAIL <> ''"
cQuery+= "				AND SF2.F2_VEND1 = SA3.A3_COD"
cQuery+= "				AND SF2.F2_CLIENTE = SA1.A1_COD"
cQuery+= "				AND SF2.F2_LOJA = SA1.A1_LOJA"
cQuery+= "				AND SF2.F2_SERIE = SD2.D2_SERIE"
cQuery+= "				AND SF2.F2_DOC =  SD2.D2_DOC"
cQuery+= "				AND SD2.D2_TES = SF4.F4_CODIGO"
cQuery+= "				AND SF4.F4_DUPLIC = 'S'"
cQuery+= "				AND SD2.D2_PEDIDO = SC6.C6_NUM"
cQuery+= "				AND SD2.D2_ITEMPV = SC6.C6_ITEM"
If !Empty(mv_par01) .OR. !Empty(mv_par02)
	cQuery += "				AND SF2.F2_EMISSAO >= '"+Dtos(mv_par01)+"' " + CRLF
	cQuery += "				AND SF2.F2_EMISSAO <= '"+Dtos(mv_par02)+"' " + CRLF
EndIf
cQuery+= "				Order By F2_VEND1,A3_EMAIL,A3_REGIAO,D2_EMISSAO,D2_SERIE,D2_DOC"

DbUseArea(.T., "TOPCONN",TCGENQRY(,,cQuery),'TMP',.F.,.T.) 

count to nRecCount

If nRecCount > 0 
	Processa({|| GeraHtm()},titulo)
Else
	If Select('TMP')>0               	
		TMP->(DbCloseArea())
	EndIf
EndIf

/*
Funcao      : GeraHtm
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Html gerado para relatório Analítico
Autor     	: Renato Rezende  	 	
Data     	: 29/05/2014
Módulo      : Faturamento.
Cliente     : SNF.
*/
*------------------------------*
 Static Function GeraHtm()
*------------------------------*
Local nQTotal 		:= 0
Local nVTotal 		:= 0

Local cVendedor		:= ""
Local cHtml			:= ""
Local cRegiao		:= ""

//Para não causar estouro de variavel.
nHdl		:= FCREATE(cDest+cArq,0 )  //Criação do Arquivo HTML.
nBytesSalvo	:= FWRITE(nHdl, cHtml ) // Gravação do seu Conteudo.
fclose(nHdl) // Fecha o Arquivo que foi Gerado

cHtml := Grv(cHtml) //Grava e limpa memoria da variavel.

TMP->(DbGoTop())

ProcRegua(nRecCount)

While TMP->(!Eof())
	IncProc()
	If cVendedor <> TMP->CODIGO
		If !EMPTY(cHtml)
			cHtml+='		<tr>'
  			cHtml+='			<td></td>'
  			cHtml+='			<td></td>'
  			cHtml+='			<td></td>'
  			cHtml+='			<td></td>'
   			cHtml+='			<td></td>'
   			cHtml+='			<td></td>'
			cHtml+='			<td></td>'
			cHtml+='			<td>Totais</td>'
			cHtml+='			<td>'+Alltrim(TRANSFORM(nQTotal, "@R 99999999999.99"))+'</td>'
			cHtml+='			<td>'+Alltrim(TRANSFORM(nVTotal, "@R 99999999999.99"))+'</td>'
			cHtml+='		</tr>'	
			cHtml+='	</table>'
			
			cHtml := Grv(cHtml) //Grava e limpa memoria da variavel.
			
		EndIf
		
		nQTotal := 0
		nVTotal := 0
		
		cHtml := ""
		cHtml+='<H1><font face="Verdana" color="#0000FF" size="2">Vendas realizadas no mês: '+MesExtenso(CtoD(TMP->EMISSAO))+'/'+Alltrim(Str(Year(CtoD(TMP->EMISSAO))))+CRLF+CRLF
		cHtml+='Vendedor : '+TMP->CODIGO+'/'+TMP->VENDEDOR+'</font></H1>'
		cHtml+='	<table border="1" style="font-family: Verdana; font-size: 8pt">'
		cHtml+='		<tr>'
		cHtml+='			<td><p align="center"><strong>Vendedor</strong></p></td>'
		cHtml+='			<td><p align="center"><strong>Data</strong></p></td>'
		cHtml+='			<td><p align="center"><strong>Documento</strong></p></td>'
		cHtml+='			<td><p align="center"><strong>Cliente</strong></p></td>'
		cHtml+='			<td><p align="center"><strong>Nome Cliente</strong></p></td>'
		cHtml+='			<td><p align="center"><strong>Endereço</strong></p></td>'
		cHtml+='			<td><p align="center"><strong>Produto</strong></p></td>'
		cHtml+='			<td><p align="center"><strong>Descrição</strong></p></td>'
		cHtml+='			<td><p align="center"><strong>Quantidade</strong></p></td>'
		cHtml+='			<td><p align="center"><strong>Total</strong></p></td>'
		cHtml+='		</tr>'
		cRegiao 	:= TMP->REGIAO+" - "
		cVendedor 	:= TMP->CODIGO

	EndIf
	cHtml+='		<tr>'
	cHtml+='			<td>="'+Alltrim(TMP->CODIGO)+'"</td>'
	cHtml+='			<td>'+TMP->EMISSAO+'</td>'
	cHtml+='			<td>'+Alltrim(TMP->DOCUMENTO)+'</td>'
	cHtml+='			<td>'+Alltrim(TMP->CLIENTE)+'</td>'
	cHtml+='			<td>'+Alltrim(TMP->NOME)+'</td>'
	cHtml+='			<td>'+Alltrim(TMP->ENDERECO)+'</td>'
	cHtml+='			<td>'+Alltrim(TMP->PRODUTO)+'</td>'
	cHtml+='			<td>'+Alltrim(TMP->DESCRICAO)+'</td>'
	cHtml+='			<td>'+Alltrim(TRANSFORM(TMP->QUANT, "@R 99999999999.99"))+'</td>'
	cHtml+='			<td>'+Alltrim(TRANSFORM(TMP->TOTAL, "@R 99999999999.99"))+'</td>'
	cHtml+='		</tr>'
	
	nQTotal := nQTotal + TMP->QUANT
	nVTotal := nVTotal + TMP->TOTAL
	
	If LEN(cHtml) >= 50000
		cHtml := Grv(cHtml) //Grava e limpa memoria da variavel.
	EndIf

	TMP->(DbSkip())
EndDo

If !EMPTY(cHtml)//Garante que o ultimo vendedor recebe o email.
	cHtml+='		<tr>'
	cHtml+='			<td></td>'
	cHtml+='			<td></td>'
	cHtml+='			<td></td>'
	cHtml+='			<td></td>'
	cHtml+='			<td></td>'
	cHtml+='			<td></td>'
	cHtml+='			<td></td>'
	cHtml+='			<td>Totais</td>'
	cHtml+='			<td>'+Alltrim(TRANSFORM(nQTotal, "@R 99999999999.99"))+'</td>'
	cHtml+='			<td>'+Alltrim(TRANSFORM(nVTotal, "@R 99999999999.99"))+'</td>'
	cHtml+='		</tr>'	
	cHtml+='	</table>'
	
	cHtml := Grv(cHtml) //Grava e limpa memoria da variavel. 
	
EndIf

GeraExcel()
 
Return cHtml 

/*
Funcao      : Grv
Parametros  : cHtml
Retorno     : Nenhum
Objetivos   : Grava o conteudo da variável cHtml em partes para não causar estouro de variavel
Autor     	: Renato Rezende  	 	
Data     	: 10/06/2014
Módulo      : Faturamento.
Cliente     : SNF.
*/
*------------------------------*
 Static Function Grv(cHtml)
*------------------------------*
Local nHdl		:= Fopen(cDest+cArq)

FSeek(nHdl,0,2)
nBytesSalvo += FWRITE(nHdl, cHtml )
fclose(nHdl)

Return ""

/*
Funcao      : GeraExcel
Parametros  : cHtml
Retorno     : Nenhum
Objetivos   : Gera o Excel com o Html gravado.
Autor     	: Renato Rezende  	 	
Data     	: 10/06/2014
Módulo      : Faturamento.
Cliente     : SNF.
*/
*---------------------------------*
 Static Function GeraExcel(cHtml)
*---------------------------------*

//Verificação do arquivo (GRAVADO OU NAO) e definição de valor de Bytes retornados.
If nBytesSalvo <= 0
	if ferror()	== 516
		MsgStop("Erro de gravação do Destino, o arquivo deve estar aberto. Error = "+ str(ferror(),4),'Erro')
	Else
		MsgStop("Erro de gravação do Destino. Error = "+ str(ferror(),4),'Erro')
    EndIf
Else
	fclose(nHdl) // Fecha o Arquivo que foi Gerado
	
	SHELLEXECUTE("open",(cDest+cArq),"","",5)   // Gera o arquivo em Excel ou Html
EndIf
 
TMP->(DbSkip())

TMP->(DbCloseArea())

Return

/*
Funcao      : CriaPerg
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Cria o Pergunte no SX1
Autor     	: Renato Rezende  	 	
Data     	: 10/06/2014
Módulo      : Faturamento.
Cliente     : SNF.
*/
*-------------------------------*
 Static Function CriaPerg()
*-------------------------------*

U_PUTSX1(cPerg, "01", "Data de ?",        "Data de ?",        	"Data de ?",         "mv_ch1","D",10,0,0, "G","","",	"","","mv_par01","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "02", "Data Ate ?",       "Data Ate ?",       	"Data Ate ?",        "mv_ch2","D",10,0,0, "G","","",	"","","mv_par02","","","","","","","","","","","","","","","","",{},{},{},"")

Return 
