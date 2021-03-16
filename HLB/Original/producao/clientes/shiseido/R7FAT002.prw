#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.ch"
#INCLUDE "TBICONN.ch" 
#INCLUDE "FILEIO.CH"

/*
Funcao      : R7FAT002()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Relatório de Vendas Shiseido 
Autor       : Renato Rezende
Data/Hora   : 27/05/2014   
*/                          
*-------------------------*
 User Function R7FAT002()
*-------------------------*
Local 	nHandle		:= 0
Private cPerg		:= ""
Private titulo		:= "Relatório Shiseido Vendas"
Private cDest		:= ""
Private cArq		:= ""
Private cQuery		:= ""
Private cArqTMP		:= ''	// Arquivo contendo resultado da CAT17 - U_R461Imp()

Private nBytesSalvo	:= 0 
Private nRecCount	:= 0

Private aMovimentos	:= {}

//Verificando se está na empresa Shiseido
If !(cEmpAnt) $ "R7"
     MsgInfo("Rotina não implementada para essa empresa!","HLB BRASIL")
     Return
EndIf

cPerg := "R7FAT2"
//Criando Pergunte
CriaPerg()
//Chamando Pergunte
If !Pergunte(cPerg,.T.)
	Return  
EndIf

//Gravado no temporário da máquina
cDest	:=  GetTempPath()
cArq	:= "shiseido.xls"

If File(cDest+cArq)
	If FErase(cDest+cArq) <> 0
		MsgAlert("Erro ao tentar apagar arquivo antigo '"+ALLTRIM(cArq)+"', caso esteja aberto, favor fechar e executar novamente!","HLB BRASIL")
		Return .F.
	EndIf
EndIf

If (nHandle:=FCreate(cDest+cArq, 0)) == -1
	MsgAlert("Erro na criação do Arquivo!","HLB BRASIL")
	Return .F.
EndIf
FClose(nHandle)

//Relatório Analítico ou Sintético
If mv_par11 == 1
	//Consulta Temporaria para o registro da Cat17
	Cat17R7()

	//GeraTMPAn()
	Processa({|| GeraTMPAn()},titulo)
	
	//Apaga arquivos temporarios gerado pela função Car17R7
	U_xFsCatFim(cArqTMP)
//Relatório Sintético
ElseIf mv_par11 == 2
	//GeraTMPAn()
	Processa({|| GeraTMPAn()},titulo)
//Relatório Aglutinado
ElseIf mv_par11 == 3
	//GeraTMPAgl()
	Processa({|| GeraTMPAgl()},titulo)
EndIf

Return

/*
Funcao      : GeraHtmAn
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Html gerado para relatório Analítico
Autor     	: Renato Rezende  	 	
Data     	: 29/05/2014
Módulo      : Faturamento.
Cliente     : Shiseido.
*/
*------------------------------*
 Static Function GeraHtmAn()
*------------------------------*
Local cHtml				:= ""
Local cLinha			:= ""
Local cEscrito			:= ""

Local aTitCab			:= ""

Local lCor				:= .T.

Local nTotNetSales		:= 0
Local nTotGrossSales	:= 0
Local nTotIpi			:= 0
Local nTotIcms			:= 0
Local nTotIcmsSt		:= 0
Local nTotPis			:= 0
Local nTotCofins		:= 0
Local nValRessar		:= 0

//Para não causar estouro de variavel.
/*
nHdl		:= FCREATE(cDest+cArq,0 )  //Criação do Arquivo HTML.
nBytesSalvo	:= FWRITE(nHdl, cHtml ) // Gravação do seu Conteudo.
fclose(nHdl) // Fecha o Arquivo que foi Gerado
*/

cHtml	:= ""
aTitCab	:= ""

//Cabeçalho das colunas do relatório
aTitCab1:= {'Cliente',;
			'Nome',;
			'Cod Vend',;
			'Vendedor',;
			'Data',; 
			'No.Pedido',; //RRP - 30/07/2014 - Solicitado pela Sabrina
			'TIPO NF',;
			'NF',;
			'CFOP',;
			'Cod Prod',;
			'Produto',;
			'BRAND',;
			'LINE',;
			'CST',;
			'NCM',;
			'Armazem',;
			'Qtd',;
			'Preco',;
			'Net Sales',;
			'Gross Sales',;
			'COG',;
			'CAT17',;								//RRP - 11/05/2015 - Inclusão de tratamento Cat17 Everton Silva.
			'COG Valor Liquido',;					//RRP - 11/05/2015 - Inclusão de tratamento Cat17 Everton Silva.
			'COG based on Net sales (%)',; 
			'COG based on Net sales (%) Depois',;	//RRP - 11/05/2015 - Inclusão de tratamento Cat17 Everton Silva.
			'Fator',;
			'% IPI',;
			'Val IPI',;
			'% ICMS',;
			'Val ICMS',;
			'IVA',;
			'ICMS-ST',;
			'% PIS',;
			'PIS',;
			'% COFINS',;
			'COFINS'} 
			
cHtml+='	<style type="text/css">'
cHtml+='	<!--'
cHtml+='	.Header {'
cHtml+='		color: #FFFFFF;'
cHtml+='		font-weight: bold;'
cHtml+='		background:#7E64A1;'
cHtml+='		font-family:Verdana;'
cHtml+='		font-size:9pt;
cHtml+='	}'
cHtml+='	.Linha1 {'
cHtml+='		color: #000000;'
cHtml+='		background:#C4B5D2;'
cHtml+='		font-family:Verdana;'
cHtml+='		font-size:9pt;
cHtml+='		white-space:nowrap;'//Para não quebrar a linha 
cHtml+='		text-align: left;'
cHtml+='	}'
cHtml+='	.Linha2 {'
cHtml+='		color: #000000;'
cHtml+='		background:#E0DCED;'
cHtml+='		font-family:Verdana;'
cHtml+='		font-size:9pt;
cHtml+='		white-space:nowrap;'//Para não quebrar a linha
cHtml+='		text-align: left;'
cHtml+='	}'
cHtml+='	-->'
cHtml+='	</style>'	
cHtml+='	<table border="1" bordercolor="#FFFFFF">'
cHtml+='		<tr>'

//Incluindo o cabeçalho no relatório
For xR := 1 to Len(aTitCab1)
	cHtml+='			<td class="Header"><p align="center"><strong>'+aTitCab1[xR]+'</strong></p></td>'
Next xR
cHtml+='		</tr>'

TMP->(DbGoTop())
RCA->(DbGoTop())

cHtml := Grv(cHtml) //Grava e limpa memoria da variavel.

ProcRegua(nRecCount)

While TMP->(!Eof())
	IncProc()
	//Alterar cor da linha
	If lCor
		cLinha := "Linha1"
	Else
		cLinha := "Linha2"
	EndIf            
	
	lCor := !lCor	

	cHtml+='		<tr>'             
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TMP->CLIENTE)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TMP->NOME)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+'="'+Alltrim(TMP->CODVEND)+'"</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TMP->VENDEDOR)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(DtoC(StoD(TMP->DATA)))+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TMP->PEDIDO)+'</td>' //RRP - 30/07/2014 - Solicitado pela Sabrina
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TMP->TIPONF)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+'="'+Alltrim(TMP->NF)+'"</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TMP->CFOP)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TMP->CODPROD)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TMP->PRODUTO)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TMP->BRAND)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TMP->LINE)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TMP->CST)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TMP->NCM)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TMP->ARMAZEM)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TRANSFORM((TMP->QTD),"@E 99999999.99"))+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TRANSFORM((TMP->PRECO),"@E 99,999,999,999.99"))+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TRANSFORM((TMP->NETSALES), "@E 99,999,999,999.99"))+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TRANSFORM((TMP->GROSSSALES), "@E 99,999,999,999.99"))+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TRANSFORM((TMP->COG),"@E 99,999,999,999.99"))+'</td>'
	//RRP - 13/05/2015 - Cálculo do Ressarcimento
	nValRessar:= 0
	RCA->(dbSetOrder(3))	//TMP_MERCAD+DTOS(TMP_DATA)+TMP_NUMDOC
	If RCA->(dbSeek( TMP->CODPROD + TMP->DATA + TMP->NF ))
		nValRessar	:= RCA->(((TMP_VAL10 + TMP_VAL13) - TMP_COL16) * (TMP_ALIQS / 100))
	EndIf
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TRANSFORM((nValRessar),"@E 99,999,999,999.99"))+'</td>'//RRP - 11/05/2015 - Inclusão de tratamento Cat17 Everton Silva.
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TRANSFORM((TMP->COG-nValRessar),"@E 99,999,999,999.99"))+'</td>'//RRP - 11/05/2015 - Inclusão de tratamento Cat17 Everton Silva.
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TRANSFORM((TMP->COGNET),"@E 99999999.99%"))+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TRANSFORM((((TMP->COG-nValRessar-TMP->VALICMS)/TMP->NETSALES)*100),"@E 99999.99%"))+'</td>'//RRP - 11/05/2015 - Inclusão de tratamento Cat17 Everton Silva.
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TRANSFORM((TMP->FATOR),"@E 99999.999999999999999"))+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TRANSFORM((TMP->PIPI),"@E 999.99%"))+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TRANSFORM((TMP->VALIPI),"@E 99,999,999,999.99"))+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TRANSFORM((TMP->PICMS),"@E 999.99%"))+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TRANSFORM((TMP->VALICMS),"@E 99,999,999,999.99"))+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TRANSFORM((TMP->IVA),"@E 99,999,999,999.99"))+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TRANSFORM((TMP->ICMSST),"@E 99,999,999,999.99"))+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TRANSFORM((TMP->PPIS),"@E 999.99%"))+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TRANSFORM((TMP->PIS),"@E 99,999,999,999.99"))+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TRANSFORM((TMP->PCOFINS),"@E 999.99%"))+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TRANSFORM((TMP->COFINS),"@E 99,999,999,999.99"))+'</td>'
	cHtml+='		</tr>'
	
	If LEN(cHtml) >= 50000
		cHtml := Grv(cHtml) //Grava e limpa memoria da variavel.
	EndIf	
	
	//Totalizadores
	nTotNetSales	:= nTotNetSales + TMP->NETSALES
	nTotGrossSales	:= nTotGrossSales + TMP->GROSSSALES
	nTotIpi			:= nTotIpi + TMP->VALIPI
	nTotIcms		:= nTotIcms + TMP->VALICMS
	nTotIcmsSt		:= nTotIcmsSt + TMP->ICMSST
	nTotPis			:= nTotPis + TMP->PIS
	nTotCofins		:= nTotCofins + TMP->COFINS
	
	TMP->(DbSkip())
EndDo

//Alterar cor da linha
If lCor
	cLinha := "Linha1"
Else
	cLinha := "Linha2"
EndIf

//Totalizadores
cHtml+='		<tr>'
For xS := 1 to Len(aTitCab1)
	If xS == 18
		cEscrito := "TOTAIS"
	ElseIf xS == 19
		cEscrito := Alltrim(TRANSFORM(nTotNetSales, "@E 99,999,999,999.99"))
	ElseIf xS == 20
		cEscrito := Alltrim(TRANSFORM(nTotGrossSales, "@E 99,999,999,999.99"))	
	ElseIf xS == 28
		cEscrito := Alltrim(TRANSFORM(nTotIpi,"@E 99,999,999,999.99"))	
	ElseIf xS == 30
		cEscrito := Alltrim(TRANSFORM(nTotIcms,"@E 99,999,999,999.99"))	
	ElseIf xS == 32
		cEscrito := Alltrim(TRANSFORM(nTotIcmsSt,"@E 99,999,999,999.99"))	
	ElseIf xS == 34
		cEscrito := Alltrim(TRANSFORM(nTotPis,"@E 99,999,999,999.99"))	
	ElseIf xS == 36
		cEscrito := Alltrim(TRANSFORM(nTotCofins,"@E 99,999,999,999.99"))	
	EndIf
	cHtml+='			<td class="'+cLinha+'"><strong>'+cEscrito+'</strong></td>'
	cEscrito:= ""
Next xS             
cHtml+='		</tr>'
cHtml+='	</table>'

cHtml := Grv(cHtml) //Grava e limpa memoria da variavel.

GeraExcel()

Return cHtml

/*
Funcao      : GeraHtmAgl
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Html gerado para relatório Analítico
Autor     	: Renato Rezende  	 	
Data     	: 04/06/2014
Módulo      : Faturamento.
Cliente     : Shiseido.
*/
*------------------------------*
 Static Function GeraHtmAgl()
*------------------------------*
Local cHtml				:= ""
Local cLinha			:= ""
Local cEscrito			:= ""

Local aTitCab			:= ""

Local lCor				:= .T.

Local nTotNetSales		:= 0
Local nTotGrossSales	:= 0
Local nTotIpi			:= 0
Local nTotIcms			:= 0
Local nTotIcmsSt		:= 0
Local nTotPis			:= 0
Local nTotCofins		:= 0

//Para não causar estouro de variavel.
nHdl		:= FCREATE(cDest+cArq,0 )  //Criação do Arquivo HTML.
nBytesSalvo	:= FWRITE(nHdl, cHtml ) // Gravação do seu Conteudo.
fclose(nHdl) // Fecha o Arquivo que foi Gerado

cHtml	:= ""
aTitCab	:= ""

//Cabeçalho das colunas do relatório
aTitCab1:= {'Cliente',;
			'Nome',;
			'TIPO NF',;
			'Qtd',;
			'Preco',;
			'Net Sales',;
			'Gross Sales',;
			'COG',;
			'Fator',;
			'Val IPI',;
			'Val ICMS',;
			'ICMS-ST',;
			'PIS',;
			'COFINS'} 
			
cHtml+='	<style type="text/css">'
cHtml+='	<!--'
cHtml+='	.Header {'
cHtml+='		color: #FFFFFF;'
cHtml+='		font-weight: bold;'
cHtml+='		background:#7E64A1;'
cHtml+='		font-family:Verdana;'
cHtml+='		font-size:9pt;
cHtml+='	}'
cHtml+='	.Linha1 {'
cHtml+='		color: #000000;'
cHtml+='		background:#C4B5D2;'
cHtml+='		font-family:Verdana;'
cHtml+='		font-size:9pt;
cHtml+='		white-space:nowrap;'//Para não quebrar a linha 
cHtml+='		text-align: left;'
cHtml+='	}'
cHtml+='	.Linha2 {'
cHtml+='		color: #000000;'
cHtml+='		background:#E0DCED;'
cHtml+='		font-family:Verdana;'
cHtml+='		font-size:9pt;
cHtml+='		white-space:nowrap;'//Para não quebrar a linha
cHtml+='		text-align: left;'
cHtml+='	}'
cHtml+='	-->'
cHtml+='	</style>'	
cHtml+='	<table border="1" bordercolor="#FFFFFF">'
cHtml+='		<tr>'

//Incluindo o cabeçalho no relatório
For xR := 1 to Len(aTitCab1)
	cHtml+='			<td class="Header"><p align="center"><strong>'+aTitCab1[xR]+'</strong></p></td>'
Next xR
cHtml+='		</tr>'

TMP->(DbGoTop())

cHtml := Grv(cHtml) //Grava e limpa memoria da variavel.

ProcRegua(nRecCount)

While TMP->(!Eof())
	IncProc()
	//Alterar cor da linha
	If lCor
		cLinha := "Linha1"
	Else
		cLinha := "Linha2"
	EndIf            
	
	lCor := !lCor	

	cHtml+='		<tr>'             
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TMP->CLIENTE)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TMP->NOME)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TMP->TIPONF)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TRANSFORM((TMP->QTD),"@E 99999999.99"))+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TRANSFORM((TMP->PRECO),"@E 99,999,999,999.99"))+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TRANSFORM((TMP->NETSALES), "@E 99,999,999,999.99"))+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TRANSFORM((TMP->GROSSSALES), "@E 99,999,999,999.99"))+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TRANSFORM((TMP->COG),"@E 99,999,999,999.99"))+'</td>' 
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TRANSFORM((TMP->FATOR),"@E 99999.999999999999999"))+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TRANSFORM((TMP->VALIPI),"@E 99,999,999,999.99"))+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TRANSFORM((TMP->VALICMS),"@E 99,999,999,999.99"))+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TRANSFORM((TMP->ICMSST),"@E 99,999,999,999.99"))+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TRANSFORM((TMP->PIS),"@E 99,999,999,999.99"))+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TRANSFORM((TMP->COFINS),"@E 99,999,999,999.99"))+'</td>'
	cHtml+='		</tr>'
	
	If LEN(cHtml) >= 50000
		cHtml := Grv(cHtml) //Grava e limpa memoria da variavel.
	EndIf
	
	//Totalizadores
	nTotNetSales	:= nTotNetSales + TMP->NETSALES
	nTotGrossSales	:= nTotGrossSales + TMP->GROSSSALES
	nTotIpi			:= nTotIpi + TMP->VALIPI
	nTotIcms		:= nTotIcms + TMP->VALICMS
	nTotIcmsSt		:= nTotIcmsSt + TMP->ICMSST
	nTotPis			:= nTotPis + TMP->PIS
	nTotCofins		:= nTotCofins + TMP->COFINS
	
	TMP->(DbSkip())
EndDo

//Alterar cor da linha
If lCor
	cLinha := "Linha1"
Else
	cLinha := "Linha2"
EndIf

//Totalizadores
cHtml+='		<tr>'
For xS := 1 to Len(aTitCab1)
	If xS == 5
		cEscrito := "TOTAIS"
	ElseIf xS == 6
		cEscrito := Alltrim(TRANSFORM(nTotNetSales, "@E 99,999,999,999.99"))
	ElseIf xS == 7
		cEscrito := Alltrim(TRANSFORM(nTotGrossSales, "@E 99,999,999,999.99"))	
	ElseIf xS == 10
		cEscrito := Alltrim(TRANSFORM(nTotIpi,"@E 99,999,999,999.99"))	
	ElseIf xS == 11
		cEscrito := Alltrim(TRANSFORM(nTotIcms,"@E 99,999,999,999.99"))	
	ElseIf xS == 12
		cEscrito := Alltrim(TRANSFORM(nTotIcmsSt,"@E 99,999,999,999.99"))	
	ElseIf xS == 13
		cEscrito := Alltrim(TRANSFORM(nTotPis,"@E 99,999,999,999.99"))	
	ElseIf xS == 14
		cEscrito := Alltrim(TRANSFORM(nTotCofins,"@E 99,999,999,999.99"))	
	EndIf
	cHtml+='			<td class="'+cLinha+'"><strong>'+cEscrito+'</strong></td>'
	cEscrito:= ""
Next xS             
cHtml+='		</tr>'
cHtml+='	</table>'

cHtml := Grv(cHtml) //Grava e limpa memoria da variavel.

GeraExcel()

Return cHtml

/*
Funcao      : GeraHtmSn
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Html gerado para relatório Sintético
Autor     	: Renato Rezende  	 	
Data     	: 03/06/2014
Módulo      : Faturamento.
Cliente     : Shiseido.
*/
*------------------------------*
 Static Function GeraHtmSn()
*------------------------------*
Local cHtml				:= ""
Local cLinha			:= ""
Local cEscrito			:= ""

Local aTitCab			:= ""

Local lCor				:= .T.

Local nTotNetSales		:= 0
Local nTotGrossSales	:= 0

//Para não causar estouro de variavel.
nHdl		:= FCREATE(cDest+cArq,0 )  //Criação do Arquivo HTML.
nBytesSalvo	:= FWRITE(nHdl, cHtml ) // Gravação do seu Conteudo.
fclose(nHdl) // Fecha o Arquivo que foi Gerado

cHtml	:= ""
aTitCab	:= ""

//Cabeçalho das colunas do relatório
aTitCab1:= {'Cliente',;
			'Nome',;
			'Cod Vend',;
			'Vendedor',;
			'Data',;
			'TIPO NF',;
			'NF',;
			'CFOP',;
			'Cod Prod',;
			'Produto',;
			'BRAND',;
			'LINE',;
			'CST',;
			'NCM',;
			'Armazem',;
			'Qtd',;
			'Preco',;
			'Net Sales',;
			'Gross Sales',;
			'COG',;
			'COG based on Net sales (%)',;
			'Fator'} 
			
cHtml+='	<style type="text/css">'
cHtml+='	<!--'
cHtml+='	.Header {'
cHtml+='		color: #FFFFFF;'
cHtml+='		font-weight: bold;'
cHtml+='		background:#7E64A1;'
cHtml+='		font-family:Verdana;'
cHtml+='		font-size:9pt;
cHtml+='	}'
cHtml+='	.Linha1 {'
cHtml+='		color: #000000;'
cHtml+='		background:#C4B5D2;'
cHtml+='		font-family:Verdana;'
cHtml+='		font-size:9pt;
cHtml+='		white-space:nowrap;'//Para não quebrar a linha 
cHtml+='		text-align: left;'
cHtml+='	}'
cHtml+='	.Linha2 {'
cHtml+='		color: #000000;'
cHtml+='		background:#E0DCED;'
cHtml+='		font-family:Verdana;'
cHtml+='		font-size:9pt;
cHtml+='		white-space:nowrap;'//Para não quebrar a linha
cHtml+='		text-align: left;'
cHtml+='	}'
cHtml+='	-->'
cHtml+='	</style>'	
cHtml+='	<table border="1" bordercolor="#FFFFFF">'
cHtml+='		<tr>'

//Incluindo o cabeçalho no relatório
For xR := 1 to Len(aTitCab1)
	cHtml+='			<td class="Header"><p align="center"><strong>'+aTitCab1[xR]+'</strong></p></td>'
Next xR
cHtml+='		</tr>'

TMP->(DbGoTop())

cHtml := Grv(cHtml) //Grava e limpa memoria da variavel.

ProcRegua(nRecCount)

While TMP->(!Eof())
	IncProc()
	//Alterar cor da linha
	If lCor
		cLinha := "Linha1"
	Else
		cLinha := "Linha2"
	EndIf            
	
	lCor := !lCor	

	cHtml+='		<tr>'             
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TMP->CLIENTE)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TMP->NOME)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+'="'+Alltrim(TMP->CODVEND)+'"</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TMP->VENDEDOR)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(DtoC(StoD(TMP->DATA)))+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TMP->TIPONF)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+'="'+Alltrim(TMP->NF)+'"</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TMP->CFOP)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TMP->CODPROD)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TMP->PRODUTO)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TMP->BRAND)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TMP->LINE)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TMP->CST)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TMP->NCM)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TMP->ARMAZEM)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TRANSFORM((TMP->QTD),"@E 99999999.99"))+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TRANSFORM((TMP->PRECO),"@E 99,999,999,999.99"))+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TRANSFORM((TMP->NETSALES), "@E 99,999,999,999.99"))+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TRANSFORM((TMP->GROSSSALES), "@E 99,999,999,999.99"))+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TRANSFORM((TMP->COG),"@E 99,999,999,999.99"))+'</td>' 
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TRANSFORM((TMP->COGNET),"@E 99999999.99%"))+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TRANSFORM((TMP->FATOR),"@E 99999.999999999999999"))+'</td>'
	cHtml+='		</tr>'
	
	If LEN(cHtml) >= 50000
		cHtml := Grv(cHtml) //Grava e limpa memoria da variavel.	
	EndIf
	
	//Totalizadores
	nTotNetSales	:= nTotNetSales + TMP->NETSALES
	nTotGrossSales	:= nTotGrossSales + TMP->GROSSSALES
	
	TMP->(DbSkip())
EndDo

//Alterar cor da linha
If lCor
	cLinha := "Linha1"
Else
	cLinha := "Linha2"
EndIf

//Totalizadores
cHtml+='		<tr>'
For xS := 1 to Len(aTitCab1)
	If xS == 17
		cEscrito := "TOTAIS"
	ElseIf xS == 18
		cEscrito := Alltrim(TRANSFORM(nTotNetSales, "@E 99,999,999,999.99"))
	ElseIf xS == 19
		cEscrito := Alltrim(TRANSFORM(nTotGrossSales, "@E 99,999,999,999.99"))	
	EndIf
	cHtml+='			<td class="'+cLinha+'"><strong>'+cEscrito+'</strong></td>'
	cEscrito:= ""
Next xS             
cHtml+='		</tr>'
cHtml+='	</table>'

cHtml := Grv(cHtml) //Grava e limpa memoria da variavel.

GeraExcel()

Return cHtml

/*
Funcao      : GeraTMPAgl
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Query gerada para relatório Aglutinado
Autor     	: Renato Rezende  	 	
Data     	: 04/06/2014
Módulo      : Faturamento.
Cliente     : Shiseido.
*/
*------------------------------*
 Static Function GeraTMPAgl()
*------------------------------*

// Se as tabelas temporarias estiverem abertas, fecha.
If Select('TMP')>0
	TMP->(DbCloseArea())
EndIf
cQuery		:= ""

cQuery:= "SELECT "  + CRLF 
cQuery+= "SD2.D2_CLIENTE  AS [Cliente] "  + CRLF
cQuery+= ",SA1.A1_NOME AS [Nome] "  + CRLF
cQuery+= ",SD2.D2_TIPO AS [TIPONF] "  + CRLF
cQuery+= ",SUM(SD2.D2_QUANT) AS [Qtd] "  + CRLF
cQuery+= ",SUM(SD2.D2_PRCVEN)  AS [Preco] "  + CRLF
cQuery+= ",SUM(SD2.D2_VALBRUT -SD2.D2_VALIPI - SD2.D2_VALICM - SD2.D2_ICMSRET - SD2.D2_VALIMP6 - SD2.D2_VALIMP5) AS [NetSales] "  + CRLF
cQuery+= ",SUM(SD2.D2_VALBRUT) AS [GrossSales] "  + CRLF
cQuery+= ",SUM(SD2.D2_CUSTO1) AS COG "  + CRLF
//cQuery+= ",SUM((SD2.D2_VALBRUT -SD2.D2_VALIPI - SD2.D2_VALICM - SD2.D2_ICMSRET - SD2.D2_VALIMP6 - SD2.D2_VALIMP5) / SD2.D2_VALBRUT) AS Fator
cQuery+= ", SUM(SD2.D2_TOTAL / (SD2.D2_TOTAL + SD2.D2_VALIPI +SD2.D2_VALICM+SD2.D2_ICMSRET+SD2.D2_VALIMP6+SD2.D2_VALIMP5)) AS Fator "  + CRLF
cQuery+= ",SUM(SD2.D2_VALIPI) AS [ValIPI] "  + CRLF
cQuery+= ",SUM(SD2.D2_VALICM) AS [ValICMS] "  + CRLF
cQuery+= ",SUM(SD2.D2_ICMSRET) AS [ICMSST] "  + CRLF
cQuery+= ",SUM(SD2.D2_VALIMP6) AS PIS "  + CRLF
cQuery+= ",SUM(SD2.D2_VALIMP5) AS COFINS "  + CRLF
cQuery+= "FROM SD2R70 SD2 "  + CRLF
cQuery+= "	Left Outer Join(Select * From SF2R70 Where D_E_L_E_T_ <> '*') SF2 on SF2.F2_FILIAL = SD2.D2_FILIAL AND SF2.F2_DOC = SD2.D2_DOC AND SF2.F2_SERIE = SD2.D2_SERIE AND SF2.F2_CLIENTE = SD2.D2_CLIENTE AND SF2.F2_LOJA = SD2.D2_LOJA "  + CRLF
cQuery+= "	Left Outer Join(Select * From SA1R70 Where D_E_L_E_T_ <> '*') SA1 on SA1.A1_FILIAL = SD2.D2_FILIAL AND SA1.A1_COD = SD2.D2_CLIENTE AND SA1.A1_LOJA = SD2.D2_LOJA "  + CRLF
cQuery+= "	Left Outer Join(Select * From SB1R70 WHERE D_E_L_E_T_ <> '*') SB1 on SB1.B1_COD = SD2.D2_COD "  + CRLF 
cQuery+= "	Left Outer Join(Select * From ZX4R70 WHERE D_E_L_E_T_ <> '*') ZX4 on SB1.B1_P_MULTB = ZX4.ZX4_CODIGO "  + CRLF 
cQuery+= "	Left Outer Join(Select * From ZX5R70 WHERE D_E_L_E_T_ <> '*') ZX5 on SB1.B1_P_SUBL = ZX5.ZX5_CODIGO "  + CRLF 
cQuery+= "WHERE SD2.D_E_L_E_T_ <> '*' "  + CRLF
cQuery+= "	AND SD2.D2_TIPO = 'N' "  + CRLF
cQuery+= "	AND SD2.D2_CF in ('5102','6102','5405','5403','6108','6403','6109','6404') "  + CRLF
If !Empty(mv_par01) .OR. !Empty(mv_par02)
	cQuery += " AND SD2.D2_EMISSAO >= '"+Dtos(mv_par01)+"' " + CRLF
	cQuery += " AND SD2.D2_EMISSAO <= '"+Dtos(mv_par02)+"' " + CRLF
EndIf
If !Empty(mv_par03) .OR. !Empty(mv_par04)
	cQuery += " AND SD2.D2_COD >= '"+mv_par03+"' " + CRLF
	cQuery += " AND SD2.D2_COD <= '"+mv_par04+"' " + CRLF
EndIf
If !Empty(mv_par07) .OR. !Empty(mv_par08)
	cQuery += " AND SD2.D2_CLIENTE >= '"+mv_par07+"' " + CRLF
	cQuery += " AND SD2.D2_CLIENTE <= '"+mv_par08+"' " + CRLF
EndIf
If !Empty(mv_par05) .OR. !Empty(mv_par06)
	cQuery += " AND ZX4.ZX4_CODIGO >= '"+mv_par05+"' " + CRLF
	cQuery += " AND ZX4.ZX4_CODIGO <= '"+mv_par06+"' " + CRLF
EndIf 
If !Empty(mv_par09) .OR. !Empty(mv_par10)
	cQuery += " AND SD2.D2_LOCAL >= '"+Alltrim(mv_par09)+"' " + CRLF
	cQuery += " AND SD2.D2_LOCAL <= '"+Alltrim(mv_par10)+"' " + CRLF
EndIf
cQuery+= "	Group By SD2.D2_CLIENTE ,SD2.D2_TIPO,SA1.A1_NOME "  + CRLF 
//Impressão NF de devolução
If mv_par12 == 2
	cQuery+= "Union ALL "  + CRLF
	cQuery+= "SELECT "  + CRLF 
	cQuery+= "SD1.D1_FORNECE AS [Cliente] "  + CRLF
	cQuery+= ",SA1.A1_NOME AS [Nome] "  + CRLF
	cQuery+= ",SD1.D1_TIPO AS [TIPONF] "  + CRLF
	cQuery+= ",SUM(SD1.D1_QUANT*(-1)) AS [Qtd] "  + CRLF
	cQuery+= ",SUM(SD1.D1_VUNIT)  AS [Preco] "  + CRLF
	cQuery+= ",SUM(SD1.D1_TOTAL*(-1)) AS [NetSales] "  + CRLF
	cQuery+= ",SUM((SD1.D1_TOTAL + SD1.D1_VALIPI +SD1.D1_VALICM+SD1.D1_ICMSRET+SD1.D1_VALIMP6+SD1.D1_VALIMP5)*(-1)) AS [GrossSales] "  + CRLF
	cQuery+= ",SUM(SD1.D1_CUSTO*(-1)) AS COG "  + CRLF
	cQuery+= ",SUM((SD1.D1_TOTAL / (SD1.D1_TOTAL + SD1.D1_VALIPI +SD1.D1_VALICM+SD1.D1_ICMSRET+SD1.D1_VALIMP6+SD1.D1_VALIMP5))*(-1)) AS Fator "  + CRLF
	cQuery+= ",SUM(SD1.D1_VALIPI*(-1)) AS [ValIPI] "  + CRLF
	cQuery+= ",SUM(SD1.D1_VALICM*(-1)) AS [ValICMS] "  + CRLF
	cQuery+= ",SUM(SD1.D1_ICMSRET*(-1)) AS [ICMSST] "  + CRLF
	cQuery+= ",SUM(SD1.D1_VALIMP6*(-1)) AS PIS "  + CRLF
	cQuery+= ",SUM(SD1.D1_VALIMP5*(-1)) AS COFINS "  + CRLF
	cQuery+= "FROM SD1R70 SD1 "  + CRLF
	cQuery+= "	Join (Select * From SD2R70) SD2 on SD2.D2_DOC = SD1.D1_NFORI AND SD2.D2_ITEM = SD1.D1_ITEMORI AND SD2.D2_SERIE = SD1.D1_SERIORI "  + CRLF
	cQuery+= "	Left Outer Join(Select * From SF2R70 Where D_E_L_E_T_ <> '*') SF2 on SF2.F2_FILIAL = SD2.D2_FILIAL AND SF2.F2_DOC = SD2.D2_DOC AND SF2.F2_SERIE = SD2.D2_SERIE AND SF2.F2_CLIENTE = SD2.D2_CLIENTE AND SF2.F2_LOJA = SD2.D2_LOJA "  + CRLF
	cQuery+= "	Left Outer Join(Select * From SF1R70 Where D_E_L_E_T_ <> '*') SF1 on SF1.F1_FILIAL = SD1.D1_FILIAL AND SF1.F1_DOC = SD1.D1_DOC AND SF1.F1_SERIE = SD1.D1_SERIE AND SF1.F1_FORNECE = SD1.D1_FORNECE AND SF1.F1_LOJA = SD1.D1_LOJA "  + CRLF
	cQuery+= "	Left Outer Join(Select * From SA1R70 Where D_E_L_E_T_ <> '*') SA1 on SA1.A1_FILIAL = SD1.D1_FILIAL AND SA1.A1_COD = SD1.D1_FORNECE AND SA1.A1_LOJA = SD1.D1_LOJA "  + CRLF 
	cQuery+= "	Left Outer Join(Select * From SB1R70 WHERE D_E_L_E_T_ <> '*') SB1 on SB1.B1_COD = SD1.D1_COD "  + CRLF 
	cQuery+= "	Left Outer Join(Select * From ZX4R70 WHERE D_E_L_E_T_ <> '*') ZX4 on SB1.B1_P_MULTB = ZX4.ZX4_CODIGO "  + CRLF 
	cQuery+= "	Left Outer Join(Select * From ZX5R70 WHERE D_E_L_E_T_ <> '*') ZX5 on SB1.B1_P_SUBL = ZX5.ZX5_CODIGO "  + CRLF
	cQuery+= "WHERE SD1.D_E_L_E_T_ <> '*' "  + CRLF
	cQuery+= "	and D1_TIPO = 'D' "  + CRLF
    //VYB - 19/17/2016 - Solicitado pelo cliente por email - retirar o filtro de CFOP
	//cQuery+= "	and D1_CF NOT IN ('1949','2949') "  + CRLF
	cQuery+= "	and D1_TP = 'ME' " + CRLF
	If !Empty(mv_par01) .OR. !Empty(mv_par02)
   		cQuery += " AND ((SD1.D1_EMISSAO BETWEEN '"+Dtos(mv_par01)+"'AND'"+Dtos(mv_par02)+"') OR (SD1.D1_DTDIGIT BETWEEN '"+Dtos(mv_par01)+"'AND'"+Dtos(mv_par02)+"')) " + CRLF 
	EndIf
	If !Empty(mv_par03) .OR. !Empty(mv_par04)
		cQuery += " AND SD1.D1_COD >= '"+mv_par03+"' " + CRLF
		cQuery += " AND SD1.D1_COD <= '"+mv_par04+"' " + CRLF
	EndIf
	If !Empty(mv_par07) .OR. !Empty(mv_par08)
		cQuery += " AND SD1.D1_FORNECE >= '"+mv_par07+"' " + CRLF
		cQuery += " AND SD1.D1_FORNECE <= '"+mv_par08+"' " + CRLF
	EndIf
	If !Empty(mv_par05) .OR. !Empty(mv_par06)
		cQuery += " AND ZX4.ZX4_CODIGO >= '"+mv_par05+"' " + CRLF
   		cQuery += " AND ZX4.ZX4_CODIGO <= '"+mv_par06+"' " + CRLF
	EndIf  
	If !Empty(mv_par09) .OR. !Empty(mv_par10)
   		cQuery += " AND SD1.D1_LOCAL >= '"+Alltrim(mv_par09)+"' " + CRLF
		cQuery += " AND SD1.D1_LOCAL <= '"+Alltrim(mv_par10)+"' " + CRLF
	EndIf	
	cQuery+= "Group By SD1.D1_FORNECE,SD1.D1_TIPO,SA1.A1_NOME "  + CRLF
EndIf
cQuery+= "ORDER BY [TIPONF] DESC,[Nome] "  + CRLF

DbUseArea(.T., "TOPCONN",TCGENQRY(,,cQuery),'TMP',.F.,.T.) //execução da query
//Verificando se foi gerado algum resultado
count to nRecCount
If nRecCount > 0 
	//Processa({|| GeraHtmAgl()},titulo)
	GeraHtmAgl()
Else
	If Select('TMP')>0
		TMP->(DbCloseArea())
	EndIf
	MsgInfo("Nao existem dados para serem gerados !","HLB BRASIL")
Endif

Return

/*
Funcao      : GeraTMPAn
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Query gerada para relatório Analítico
Autor     	: Renato Rezende  	 	
Data     	: 29/05/2014
Módulo      : Faturamento.
Cliente     : Shiseido.
*/
*------------------------------*
 Static Function GeraTMPAn()
*------------------------------*

// Se as tabelas temporarias estiverem abertas, fecha.
If Select('TMP')>0
	TMP->(DbCloseArea())
EndIf
cQuery		:= ""

//Início do Select
cQuery:= "SELECT "  + CRLF 
cQuery+= "SD2.D2_CLIENTE AS [Cliente] "  + CRLF
cQuery+= ",SA1.A1_NOME AS [Nome] "  + CRLF
cQuery+= ",SF2.F2_VEND1 AS [CodVend] "  + CRLF
cQuery+= ",SA3.A3_NOME AS [Vendedor] "  + CRLF
cQuery+= ",SD2.D2_EMISSAO AS [Data] "  + CRLF
cQuery+= ",SD2.D2_PEDIDO AS [PEDIDO] "  + CRLF //RRP - 30/07/2014 - Solicitado pela Sabrina
cQuery+= ",SD2.D2_TIPO AS [TIPONF] "  + CRLF
cQuery+= ",SD2.D2_DOC AS [NF] "  + CRLF
cQuery+= ",SD2.D2_CF AS [CFOP] "  + CRLF
cQuery+= ",SD2.D2_COD AS [CodProd] "  + CRLF
cQuery+= ",SB1.B1_DESC AS [Produto] "  + CRLF
cQuery+= ",ZX4.ZX4_NOME AS [BRAND] "  + CRLF
cQuery+= ",ZX5.ZX5_NOME AS [LINE] "  + CRLF
cQuery+= ",SD2.D2_CLASFIS AS [CST] "  + CRLF
cQuery+= ",SB1.B1_POSIPI AS [NCM] "  + CRLF
cQuery+= ",SD2.D2_LOCAL AS [Armazem] "  + CRLF                                      
cQuery+= ",SD2.D2_QUANT AS [Qtd] "  + CRLF
cQuery+= ",SD2.D2_PRCVEN  AS [Preco] "  + CRLF
cQuery+= ",SD2.D2_VALBRUT -SD2.D2_VALIPI - SD2.D2_VALICM - SD2.D2_ICMSRET - SD2.D2_VALIMP6 - SD2.D2_VALIMP5 AS [NetSales] "  + CRLF
cQuery+= ",SD2.D2_VALBRUT AS [GrossSales] "  + CRLF
cQuery+= ",SD2.D2_CUSTO1 AS COG "  + CRLF
cQuery+= ",(SD2.D2_CUSTO1/ SD2.D2_TOTAL ) *100 AS [COGNet] "  + CRLF
//cQuery+= ",(SD2.D2_VALBRUT -SD2.D2_VALIPI - SD2.D2_VALICM - SD2.D2_ICMSRET - SD2.D2_VALIMP6 - SD2.D2_VALIMP5) / SD2.D2_VALBRUT AS Fator
cQuery+= ", (SD2.D2_TOTAL / (SD2.D2_TOTAL + SD2.D2_VALIPI +SD2.D2_VALICM+SD2.D2_ICMSRET+SD2.D2_VALIMP6+SD2.D2_VALIMP5)) AS Fator "  + CRLF
cQuery+= ",SD2.D2_IPI AS [PIPI] "  + CRLF
cQuery+= ",SD2.D2_VALIPI AS [ValIPI] "  + CRLF
cQuery+= ",SD2.D2_PICM AS [PICMS] "  + CRLF
cQuery+= ",SD2.D2_VALICM AS [ValICMS] "  + CRLF
cQuery+= ",SD2.D2_MARGEM AS IVA "  + CRLF
cQuery+= ",SD2.D2_ICMSRET AS [ICMSST] "  + CRLF
cQuery+= ",SD2.D2_ALQIMP6 AS [PPIS] "  + CRLF
cQuery+= ",SD2.D2_VALIMP6 AS PIS "  + CRLF
cQuery+= ",SD2.D2_ALQIMP5 AS [PCOFINS] "  + CRLF
cQuery+= ",SD2.D2_VALIMP5 AS COFINS "  + CRLF
cQuery+= "FROM SD2R70 SD2 "  + CRLF
cQuery+= "	Left Outer Join(Select * From SF2R70 WHERE D_E_L_E_T_ <> '*') SF2 on SF2.F2_FILIAL = SD2.D2_FILIAL AND SF2.F2_DOC = SD2.D2_DOC AND SF2.F2_SERIE = SD2.D2_SERIE AND SF2.F2_CLIENTE = SD2.D2_CLIENTE AND SF2.F2_LOJA = SD2.D2_LOJA "  + CRLF
cQuery+= "	Left Outer Join(Select * From SA1R70 WHERE D_E_L_E_T_ <> '*') SA1 on SA1.A1_FILIAL = SD2.D2_FILIAL AND SA1.A1_COD = SD2.D2_CLIENTE AND SA1.A1_LOJA = SD2.D2_LOJA
cQuery+= "	Left Outer Join(Select * From SA3R70 WHERE D_E_L_E_T_ <> '*') SA3 on SA3.A3_COD = SF2.F2_VEND1 "  + CRLF
cQuery+= "	Left Outer Join(Select * From SB1R70 WHERE D_E_L_E_T_ <> '*') SB1 on SB1.B1_COD = SD2.D2_COD "  + CRLF 
cQuery+= "	Left Outer Join(Select * From ZX4R70 WHERE D_E_L_E_T_ <> '*') ZX4 on SB1.B1_P_MULTB = ZX4.ZX4_CODIGO "  + CRLF 
cQuery+= "	Left Outer Join(Select * From ZX5R70 WHERE D_E_L_E_T_ <> '*') ZX5 on SB1.B1_P_SUBL = ZX5.ZX5_CODIGO "  + CRLF 
cQuery+= "WHERE SD2.D_E_L_E_T_ <> '*' "  + CRLF
cQuery+= "	AND SD2.D2_TIPO = 'N' "  + CRLF
If !Empty(mv_par01) .OR. !Empty(mv_par02)
	cQuery += " AND SD2.D2_EMISSAO >= '"+Dtos(mv_par01)+"' " + CRLF
	cQuery += " AND SD2.D2_EMISSAO <= '"+Dtos(mv_par02)+"' " + CRLF
EndIf
If !Empty(mv_par03) .OR. !Empty(mv_par04)
	cQuery += " AND SD2.D2_COD >= '"+mv_par03+"' " + CRLF
	cQuery += " AND SD2.D2_COD <= '"+mv_par04+"' " + CRLF
EndIf
If !Empty(mv_par07) .OR. !Empty(mv_par08)
	cQuery += " AND SD2.D2_CLIENTE >= '"+mv_par07+"' " + CRLF
	cQuery += " AND SD2.D2_CLIENTE <= '"+mv_par08+"' " + CRLF
EndIf
If !Empty(mv_par05) .OR. !Empty(mv_par06)
	cQuery += " AND ZX4.ZX4_CODIGO >= '"+mv_par05+"' " + CRLF
	cQuery += " AND ZX4.ZX4_CODIGO <= '"+mv_par06+"' " + CRLF
EndIf 
If !Empty(mv_par09) .OR. !Empty(mv_par10)
	cQuery += " AND SD2.D2_LOCAL >= '"+Alltrim(mv_par09)+"' " + CRLF
	cQuery += " AND SD2.D2_LOCAL <= '"+Alltrim(mv_par10)+"' " + CRLF
EndIf
cQuery+= "	AND SD2.D2_CF in ('5102','6102','5405','5403','6108','6403','6109','6404') "  + CRLF 

//Impressão NF de devolução
If mv_par12 == 2
	cQuery+= "Union ALL "  + CRLF
	cQuery+= "SELECT "  + CRLF 
	cQuery+= "SD1.D1_FORNECE AS [Cliente] "  + CRLF
	cQuery+= ",SA1.A1_NOME AS [Nome] "  + CRLF
	cQuery+= ",SF2.F2_VEND1 AS [CodVend] "  + CRLF
	cQuery+= ",SA3.A3_NOME AS [Vendedor] "  + CRLF
	cQuery+= ",SD1.D1_DTDIGIT AS [Data] "  + CRLF  //VYB - 27/07/2016 - Carregar a data de Digitação, não a de emissão
	cQuery+= ",SD1.D1_PEDIDO AS [PEDIDO] "  + CRLF //RRP - 30/07/2014 - Solicitado pela Sabrina
	cQuery+= ",SD1.D1_TIPO AS [TIPONF] "  + CRLF
	cQuery+= ",SD1.D1_DOC AS [NF] "  + CRLF
	cQuery+= ",SD1.D1_CF AS [CFOP] "  + CRLF
	cQuery+= ",SD1.D1_COD AS [CodProd] "  + CRLF
	cQuery+= ",SB1.B1_DESC AS [Produto] "  + CRLF
	cQuery+= ",ZX4.ZX4_NOME AS [BRAND] "  + CRLF
	cQuery+= ",ZX5.ZX5_NOME AS [LINE] "  + CRLF
	cQuery+= ",SD1.D1_CLASFIS AS [CST] "  + CRLF
	cQuery+= ",SB1.B1_POSIPI AS [NCM] "  + CRLF
	cQuery+= ",SD1.D1_LOCAL AS [Armazem] "  + CRLF                                      
	cQuery+= ",SD1.D1_QUANT*(-1) AS [Qtd] "  + CRLF
	cQuery+= ",SD1.D1_VUNIT  AS [Preco] "  + CRLF
	cQuery+= ",SD1.D1_TOTAL*(-1) AS [NetSales] "  + CRLF
	//VYB - 21/17/2016 - Não incluir ICMS - PIS - COFINS no cálculo da coluna Gross Sales do relatório para bater com a NF
	//cQuery+= ",(SD1.D1_TOTAL + SD1.D1_VALIPI +SD1.D1_VALICM+SD1.D1_ICMSRET+SD1.D1_VALIMP6+SD1.D1_VALIMP5)*(-1) AS [GrossSales] "  + CRLF
	cQuery+= ",((SD1.D1_TOTAL + SD1.D1_VALIPI + SD1.D1_ICMSRET) - (SD1.D1_VALDESC))*(-1) AS [GrossSales] "  + CRLF
	cQuery+= ",SD1.D1_CUSTO*(-1) AS COG "  + CRLF
	cQuery+= ",((SD1.D1_CUSTO/ SD1.D1_TOTAL ) *100)*(-1) AS [COGNet] "  + CRLF
	cQuery+= ",(SD1.D1_TOTAL / (SD1.D1_TOTAL + SD1.D1_VALIPI +SD1.D1_VALICM+SD1.D1_ICMSRET+SD1.D1_VALIMP6+SD1.D1_VALIMP5))*(-1) AS Fator "  + CRLF
	cQuery+= ",SD1.D1_IPI AS [PIPI] "  + CRLF
	cQuery+= ",SD1.D1_VALIPI*(-1) AS [ValIPI] "  + CRLF
	cQuery+= ",SD1.D1_PICM AS [PICMS] "  + CRLF
	cQuery+= ",SD1.D1_VALICM*(-1) AS [ValICMS] "  + CRLF
	cQuery+= ",SD1.D1_MARGEM AS IVA "  + CRLF
	cQuery+= ",SD1.D1_ICMSRET*(-1) AS [ICMSST] "  + CRLF
	cQuery+= ",SD1.D1_ALQIMP6 AS [PPIS] "  + CRLF
	cQuery+= ",SD1.D1_VALIMP6*(-1) AS PIS "  + CRLF
	cQuery+= ",SD1.D1_ALQIMP5 AS [PCOFINS] "  + CRLF
	cQuery+= ",SD1.D1_VALIMP5*(-1) AS COFINS "  + CRLF
	cQuery+= "FROM SD1R70 SD1 "  + CRLF
	cQuery+= "	Join (Select * From SD2R70) SD2 on SD2.D2_DOC = SD1.D1_NFORI AND SD2.D2_ITEM = SD1.D1_ITEMORI AND SD2.D2_SERIE = SD1.D1_SERIORI "  + CRLF
	cQuery+= "	Left Outer Join(Select * From SF2R70 WHERE D_E_L_E_T_ <> '*') SF2 on SF2.F2_FILIAL = SD2.D2_FILIAL AND SF2.F2_DOC = SD2.D2_DOC AND SF2.F2_SERIE = SD2.D2_SERIE AND SF2.F2_CLIENTE = SD2.D2_CLIENTE AND SF2.F2_LOJA = SD2.D2_LOJA "  + CRLF
	cQuery+= "	Left Outer Join(Select * From SF1R70 WHERE D_E_L_E_T_ <> '*') SF1 on SF1.F1_FILIAL = SD1.D1_FILIAL AND SF1.F1_DOC = SD1.D1_DOC AND SF1.F1_SERIE = SD1.D1_SERIE AND SF1.F1_FORNECE = SD1.D1_FORNECE AND SF1.F1_LOJA = SD1.D1_LOJA "  + CRLF
	cQuery+= "	Left Outer Join(Select * From SA1R70 WHERE D_E_L_E_T_ <> '*') SA1 on SA1.A1_FILIAL = SD1.D1_FILIAL AND SA1.A1_COD = SD1.D1_FORNECE AND SA1.A1_LOJA = SD1.D1_LOJA "  + CRLF
	cQuery+= "	Left Outer Join(Select * From SA3R70 WHERE D_E_L_E_T_ <> '*') SA3 on SA3.A3_COD = SF2.F2_VEND1 "  + CRLF
	cQuery+= "	Left Outer Join(Select * From SB1R70 WHERE D_E_L_E_T_ <> '*') SB1 on SB1.B1_COD = SD1.D1_COD "  + CRLF 
	cQuery+= "	Left Outer Join(Select * From ZX4R70 WHERE D_E_L_E_T_ <> '*') ZX4 on SB1.B1_P_MULTB = ZX4.ZX4_CODIGO "  + CRLF 
	cQuery+= "	Left Outer Join(Select * From ZX5R70 WHERE D_E_L_E_T_ <> '*') ZX5 on SB1.B1_P_SUBL = ZX5.ZX5_CODIGO "  + CRLF
	//AOA - 20/10/2016 - Ajuste para verificar se está deletado no SD2
	cQuery+= "WHERE SD1.D_E_L_E_T_ <> '*'  AND SD2.D_E_L_E_T_ <> '*' "  + CRLF
	If !Empty(mv_par01) .OR. !Empty(mv_par02)
   		cQuery += " AND SD1.D1_DTDIGIT >= '"+Dtos(mv_par01)+"' " + CRLF
		cQuery += " AND SD1.D1_DTDIGIT <= '"+Dtos(mv_par02)+"' " + CRLF
	EndIf
	If !Empty(mv_par03) .OR. !Empty(mv_par04)
		cQuery += " AND SD1.D1_COD >= '"+mv_par03+"' " + CRLF
		cQuery += " AND SD1.D1_COD <= '"+mv_par04+"' " + CRLF
	EndIf
	If !Empty(mv_par07) .OR. !Empty(mv_par08)
		cQuery += " AND SD1.D1_FORNECE >= '"+mv_par07+"' " + CRLF
		cQuery += " AND SD1.D1_FORNECE <= '"+mv_par08+"' " + CRLF
	EndIf
	If !Empty(mv_par05) .OR. !Empty(mv_par06)                          
		cQuery += " AND ZX4.ZX4_CODIGO >= '"+mv_par05+"' " + CRLF
   		cQuery += " AND ZX4.ZX4_CODIGO <= '"+mv_par06+"' " + CRLF
	EndIf  
	If !Empty(mv_par09) .OR. !Empty(mv_par10)
   		cQuery += " AND SD1.D1_LOCAL >= '"+Alltrim(mv_par09)+"' " + CRLF
		cQuery += " AND SD1.D1_LOCAL <= '"+Alltrim(mv_par10)+"' " + CRLF
	EndIf
	cQuery+= "	and D1_TIPO = 'D' "  + CRLF
	//VYB - 19/17/2016 - Solicitado pelo cliente por email - retirar o filtro de CFOP
	//cQuery+= "	and D1_CF NOT IN ('1949','2949') "  + CRLF
	cQuery+= "	and D1_TP = 'ME' " + CRLF
EndIf
cQuery+= "Order By [TIPONF] DESC, [Data], [NF] "  + CRLF

DbUseArea(.T., "TOPCONN",TCGENQRY(,,cQuery),'TMP',.F.,.T.) //execução da query
//Verificando se foi gerado algum resultado
count to nRecCount
If nRecCount > 0 
	//Relatório Analítico
	If mv_par11 == 1
		//Processa({|| GeraHtmAn()},titulo)
		GeraHtmAn()
	//Relatório Sintético	
	ElseIf mv_par11 == 2
		//Processa({|| GeraHtmSn()},titulo)
		GeraHtmSn()
	EndIf                            
Else
	If Select('TMP')>0
		TMP->(DbCloseArea())
	EndIf
	MsgInfo("Nao existem dados para serem gerados !","HLB BRASIL")
Endif	

Return

/*
Funcao      : Grv
Parametros  : cHtml
Retorno     : Nenhum
Objetivos   : Grava o conteudo da variável cHtml em partes para não causar estouro de variavel
Autor     	: Renato Rezende  	 	
Data     	: 27/05/2014
Módulo      : Faturamento.
Cliente     : Shiseido.
*/
*------------------------------*
 Static Function Grv(cHtml)
*------------------------------*
Local nHdl		:= Fopen(cDest+cArq,FO_READWRITE)

FSeek(nHdl,0,2)
nBytesSalvo += FWRITE(nHdl, cHtml ) 

If nBytesSalvo <= 0
	if ferror()	== 516
		MsgStop("Erro de gravação do Destino, o arquivo deve estar aberto. Error = "+ str(ferror(),4),'Erro')
	Else
		MsgStop("Erro de gravação do Destino. Error = "+ str(ferror(),4),'Erro')
    EndIf
EndIf

fclose(nHdl)

Return ""

/*
Funcao      : GeraExcel
Parametros  : cHtml
Retorno     : Nenhum
Objetivos   : Gera o Excel com o Html gravado.
Autor     	: Renato Rezende  	 	
Data     	: 29/05/2014
Módulo      : Faturamento.
Cliente     : Shiseido.
*/
*---------------------------------*
 Static Function GeraExcel(cHtml)
*---------------------------------*

//Verificação do arquivo (GRAVADO OU NAO) e definição de valor de Bytes retornados.
If nBytesSalvo > 0
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
Data     	: 29/05/2014
Módulo      : Faturamento.
Cliente     : Shiseido.
*/
*-------------------------------*
 Static Function CriaPerg()
*-------------------------------*

U_PUTSX1(cPerg, "01", "Data de ?",        "Data de ?",        	"Data de ?",         "mv_ch1","D",10,0,0, "G","","",	"","","mv_par01","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "02", "Data Ate ?",       "Data Ate ?",       	"Data Ate ?",        "mv_ch2","D",10,0,0, "G","","",	"","","mv_par02","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "03", "Produto de ?",     "Produto de ?",        	"Produto de ?",      "mv_ch3","C",15,0,0, "G","","SB1" ,"","","mv_par03","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "04", "Produto Ate ?",    "Produto Ate ?",       	"Produto Ate ?",     "mv_ch4","C",15,0,0, "G","","SB1" ,"","","mv_par04","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "05", "Marca de ?",	    "Marca de ?",        	"Marca de ?",        "mv_ch5","C",15,0,0, "G","","ZX4" ,"","","mv_par05","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "06", "Marca Ate ?",		"Marca Ate ?",       	"Marca Ate ?",       "mv_ch6","C",15,0,0, "G","","ZX4" ,"","","mv_par06","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "07", "Cliente de ?",     "Cliente de ?",       	"Cliente de ?",	     "mv_ch7","C",06,0,0, "G","","SA1" ,"","","mv_par07","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "08", "Cliente Ate ?",    "Cliente Ate ?",       	"Cliente Ate ?",     "mv_ch8","C",06,0,0, "G","","SA1" ,"","","mv_par08","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "09", "Do Armazem ?",     "Do Armazem ?",       	"Do Armazem ?",    	 "mv_ch9","C",02,0,0, "G","","",	"","","mv_par09","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "10", "Ate Armazem ?",    "Ate Armazem ?",       	"Ate Armazem ?",     "mv_cha","C",02,0,0, "G","","",	"","","mv_par10","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "11", "Tipo Rel. ?",      "Tipo Rel. ?",         	"Tipo Rel. ?",       "mv_chb","N",01,0,0, "C","","",	"","","mv_par11","Analítico","Analítico","Analítico","","Sintético","Sintético","Sintético","Aglt. Cliente","Aglt. Cliente","Aglt. Cliente","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "12", "Dev. Vendas ?",    "Dev. Vendas ?",      	"Dev. Vendas ?",     "mv_chc","N",01,0,0, "C","","",	"","","mv_par12","Nao","Nao","Nao","","Sim","Sim","Sim","","","","","","","","","",{},{},{},"")

Return

/*
Funcao      : Cat17R7
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Geração temporária do Alias RCA contendo as informações da cat17.
Autor     	: Renato Rezende  	 	
Data     	: 13/05/2014
Módulo      : Faturamento.
Cliente     : Shiseido.
*/
*-------------------------------*
 Static Function Cat17R7()
*-------------------------------* 
Local uPar01		:= nil
Local uPar02		:= nil
Local uPar05		:= nil
Local uPar06		:= nil

SaveInter()	// Salva variáveis públicas (Entre elas os parâmetros MV_PAR**).
uPar01	:= MV_PAR01
uPar02	:= MV_PAR02
uPar03	:= MV_PAR03
uPar04	:= MV_PAR04

//* Carrega as Perguntas (MTR461) da rotina MATR46BX.
Pergunte('MTR461',.F.)
//* mv_par01	MES APURACAO
//* mv_par02	ANO APURACAO
//* mv_par03	DO PRODUTO    '
//* mv_par04	ATE O PRODUTO
//* mv_par05	MODELO
//* mv_par06	IMPRIME APURACAO
//* mv_par07	PROCESSA CDM
//* mv_par08	OPERACOES COM PAUTA
//* mv_par09	SEPARADOR DE MILHARES
// Substitue apenas as posições correspondentes ao período e a faixa de produtos.
MV_PAR03 := uPAR03
MV_PAR04 := uPAR04
MV_PAR01 := uPAR01
MV_PAR02 := uPAR02
MV_PAR05 := 1
MV_PAR06 := 1
MV_PAR07 := 2
MV_PAR08 := 2
MV_PAR09 := 1

// Executa o CAT17 para gerar apenas o arquivo temporario alias RCA
U_R461Imp(.F./*Imprime Apuracao*/,MV_PAR01,MV_PAR02,@cArqTmp)
// Restaura o array aMovimentos
aMovimentos := {}

RestInter()	// Restaura as variáveis públicas (Entre elas os parâmetros MV_PAR**).  

Return NIL
