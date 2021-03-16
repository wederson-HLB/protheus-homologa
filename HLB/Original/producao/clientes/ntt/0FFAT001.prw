#INCLUDE "PROTHEUS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "topconn.ch"


/*
Funcao      : 0FFAT001
Parametros  : 
Retorno     : 
Objetivos   : Impressao de Recibo de pagamento
Autor       : Renato Rezende
Data/Hora   : 01/12/2014
M�dulo		: Faturamento
Cliente		: NTT / 0F
*/
*-------------------------*
User Function 0FFAT001()   
*-------------------------*                                      
Private cPerg		:= "0FFAT1"
Private cNotaDe		:= ""
Private cNotaAte	:= ""
Private cSerie		:= ""

//Verifica se esta na empresa NTT
IF cEmpAnt $ "0F" 
	//Criando Pergunte
	CriaPerg()
	
	//Chamando Pergunte
	If !Pergunte(cPerg,.T.)
		Return  
	EndIf
	cNotaDe		:= mv_par01
	cNotaAte	:= mv_par02
	cSerie		:= mv_par03
    
	//Gerando consulta dos parametros selecionados
	Processa({|| GeraConsulta() })
Else
	MsgInfo("Rotina n�o implamentada para empresa!","HLB BRASIL")
	Return .F.
EndIf

Return .T.  

/*
Funcao      : CriaRecibo
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Carrega os dados para impressao do Recibo
Autor     	: Renato Rezende  	 	
Data     	: 01/12/2014
M�dulo      : Faturamento.
Cliente     : NTT
*/
*-----------------------------*
 Static Function CriaRecibo()
*-----------------------------*
Local oRecibo

Local cLocal			:= GetTempPath()

Local lAdjustToLegacy	:= .F.
Local lDisableSetup		:= .T.

Local aDadosRec			:= {}

If File(cLocal+"totvsprinter\recibo.pdf")
	FErase(cLocal+"totvsprinter\recibo.pdf")	
EndIf

//Relatorio 
oRecibo:= FWMSPrinter():New("Recibo", IMP_PDF, lAdjustToLegacy,, lDisableSetup, , , , , , .F., )
//Define orientacao de pagina do relatorio como retrato
oRecibo:SetPortrait()

SQL->(DbGoTop())
ProcRegua(SQL->(RecCount()))
Do While SQL->(!EOF())
	aDadosRec := {	AllTrim(SQL->F2_DOC),;							// [1] Numero do Titulo
					SQL->F2_EMISSAO,;								// [2] Data da Emissao do Titulo
					SQL->E1_VENCREA,;								// [3] Data do Vencimento
					SQL->E1_VALOR,;									// [4] Valor do Titulo
					SQL->F2_MENNOTA,;								// [5] Mensagem Nota	
					SQL->A1_NOME,;									// [6] Nome Cliente
					SQL->A1_CGC,;									// [7] CGC do Cliente
					SQL->A1_TIPO,;									// [8] Tipo do Cliente
					SQL->F2_SERIE}									// [9] Serie do Documento
	
	Imprimir(oRecibo,aDadosRec)

	SQL->(DbSkip())
EndDo
oRecibo:Preview()	// Visualiza antes de Imprimir.

SQL->(DbCloseArea())

Return .T.

/*
Funcao      : Imprimir
Parametros  : oRecibo,aDadosRec
Retorno     : Nenhum
Objetivos   : Imprimi o Recibo na tela
Autor     	: Renato Rezende  	 	
Data     	: 01/12/2014
M�dulo      : Faturamento.
Cliente     : NTT
*/
*--------------------------------------------*
 Static Function Imprimir(oRecibo,aDadosRec)
*--------------------------------------------*
Local oFont1,oFont2,oFont3

Local nLin		:= 100
Local nCol		:= 80
Local nDolar	:= 0

Local cTexto	:= "" 
Local cMenFixa	:= ""

//Fontes
//Fonte Courier New  Monospace, ou seja, todos os caracteres contem o mesmo tamanho.
oFont1 := TFont():New('Courier New',,-16,,.T.)
oFont2 := TFont():New('Courier New',,-14,,.F.)

//Inicia a impressao de uma nova p�gina
oRecibo:StartPage()

//Inicia a Impressao do Arquivo PDF.
If File("FAT_LGRL"+cEmpAnt+".bmp")
	oRecibo:SayBitmap(nLin,nCol+250,"FAT_LGRL"+cEmpAnt+".bmp",177,44)
EndIf

//Inicio do Recibo
nLin += 80
oRecibo:Say(nLin,nCol,"Sao Paulo, "+Day2Str(StoD(aDadosRec[2]))+" de "+MesExtenso(Month2Str(StoD(aDadosRec[2])))+" de "+Alltrim(Str(Year(StoD(aDadosRec[2])))),oFont2)
nLin += 60
oRecibo:Say(nLin,nCol,PADC("RECIBO - R$ "+Alltrim(TRANSFORM((aDadosRec[4]),"@E 99,999,999,999.99")),57),oFont1)
nLin += 15
oRecibo:Say(nLin,nCol,PADC("("+Alltrim(aDadosRec[1])+")",57),oFont1)
nLin += 60
//Montando texto Justificado
cTexto:= "Recebemos da Empresa "+ UPPER(Alltrim(aDadosRec[6]))
// CNPJ do Cliente Preenchido
If !Empty(aDadosRec[7])
	cTexto+= " (CNPJ.:"+Alltrim(TRANSFORM((aDadosRec[7]),"@R 99.999.999/9999-99"))+")"
EndIf
cTexto+= ", a importancia supra de R$"+Alltrim(TRANSFORM((aDadosRec[4]),"@E 99,999,999,999.99"))+" ("+Alltrim(Extenso(aDadosRec[4]))+")"
//Mensagem do Pedido de Venda. 
If !Empty(Alltrim(aDadosRec[5]))
	cTexto+= ", "+Alltrim(aDadosRec[5])	
EndIf
cTexto+= ". Valor referente a Locacao de Equipamento com o vencimento para o dia: " 
cTexto+= DtoC(StoD(aDadosRec[3]))+", conforme a Portaria SF 74/2003."

//Imprimindo o Texto quebrando por linha
For nR:=1 to Len(Alltrim(cTexto))
	oRecibo:Say(nLin,nCol,SubStr(cTexto,nR,65),oFont2) 
	nLin += 15
	nR += 64
Next nR

nLin += 45
oRecibo:Say(nLin,nCol,"Para maior clareza, firmamos o presente recibo.",oFont2)
nLin += 120

//WFA - 13/02/2019 - Alteracao da assinatura para a serie R. Ticket: 2911.
If Alltrim(aDadosRec[9]) == 'R'
	oRecibo:Say(nLin,nCol,"Valter Santos de Carvalho",oFont2)
	nLin += 15
	oRecibo:Say(nLin,nCol,"Controller.",oFont2)
Else
	oRecibo:Say(nLin,nCol,"Yoshimoto Yazawa",oFont2)
	nLin += 15
	oRecibo:Say(nLin,nCol,"Diretor Presidente.",oFont2) //JSS - 14/01/2015 Alterado de "Country Manager Brazil." para "Diretor Presidente." chamado 031395
EndIf
nLin += 15
oRecibo:Say(nLin,nCol,"NTT do Brasil Telecomunicacoes Ltda.",oFont2)

//Lei da transpar�ncia
If aDadosRec[8] == "F" //Tipo do Cliente
	SF2->(DbSetOrder(1))                                                                                                  
 	If SF2->(DbSeek(xFilial("SF2")+SQL->F2_DOC+SQL->F2_SERIE+SQL->F2_CLIENTE+SQL->F2_LOJA))
		If (SF2->(FieldPos("F2_TOTIMP")) > 0)
			If SF2->F2_TOTIMP > 0   
			 	cMenFixa := "Valor Aproximado dos Tributos: R$ "+Alltrim(Transform(SF2->F2_TOTIMP,"@E 999,999,999,999.99"))+" ("+Alltrim(Transform((SF2->F2_TOTIMP/SF2->F2_VALBRUT)*100,"@E 999,999,999,999.99"))+"%) Fonte: IBPT."
    		EndIf
   		EndiF
	EndIf
EndIf

nLin += 120
oRecibo:Say(nLin,nCol,cMenFixa,oFont2)

//Indica o fim da pagina.
oRecibo:EndPage()
 
Return .T.

/*
Funcao      : GeraConsulta
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Gera consulta para criacao do Recibo
Autor     	: Renato Rezende  	 	
Data     	: 01/12/2014
M�dulo      : Faturamento.
Cliente     : NTT
*/
*---------------------------------*
 Static Function GeraConsulta()
*---------------------------------*
Local cQuery := ""

//Alias SQL esta em uso
If Select("SQL") > 0
	SQL->(DbCloseArea())
EndIf

cQuery += " SELECT F2_DOC,F2_SERIE,F2_EMISSAO,F2_FILIAL,F2_CLIENTE,F2_LOJA,F2_PREFIXO,F2_DUPL,F2_MENNOTA," + CRLF
cQuery += "		SE1.E1_FILIAL, SE1.E1_NUM, SE1.E1_CLIENTE, SE1.E1_LOJA, SE1.E1_VENCREA, SE1.E1_VALOR," + CRLF
cQuery += "		SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME, SA1.A1_EST, SA1.A1_CGC, SA1.A1_TIPO "+ CRLF
cQuery += " FROM "+RetSqlName("SF2")+" SF2 " + CRLF 
cQuery += "				left outer join(Select E1_FILIAL,E1_PREFIXO, E1_NUM, E1_CLIENTE, E1_LOJA, E1_VENCREA, E1_VALOR, E1_TIPO" + CRLF
cQuery += "								From "+RetSqlName("SE1") + CRLF
cQuery += "								Where D_E_L_E_T_ <> '*' AND E1_FILIAL = '"+xFilial("SE1")+"'" + CRLF
cQuery += "								) as SE1 on SF2.F2_DOC = SE1.E1_NUM AND SF2.F2_SERIE = SE1.E1_PREFIXO AND E1_TIPO = 'NF' " + CRLF
cQuery += "				left outer join(Select A1_COD, A1_LOJA, A1_NOME, A1_EST, A1_CGC, A1_TIPO" + CRLF
cQuery += "								From "+RetSqlName("SA1") + CRLF
cQuery += "								Where D_E_L_E_T_ <> '*' AND A1_FILIAL = '"+xFilial("SA1")+"'" + CRLF
cQuery += "								) as SA1 on SF2.F2_CLIENTE+SF2.F2_LOJA = SA1.A1_COD+SA1.A1_LOJA" + CRLF
cQuery += " WHERE SF2.D_E_L_E_T_ <> '*'" + CRLF
cQuery += "   AND SF2.F2_FILIAL = '"+xFilial("SF2")+"'" + CRLF

If !EMPTY(Alltrim(cNotaDe))
	cQuery += "   AND SF2.F2_DOC >= '"+cNotaDe+"'" + CRLF
EndIf
If !EMPTY(Alltrim(cNotaAte))
	cQuery += "   AND SF2.F2_DOC <= '"+cNotaAte+"'" + CRLF
EndIf
If !EMPTY(Alltrim(cSerie))
	cQuery += "   AND SF2.F2_SERIE = '"+cSerie+"'" + CRLF
	cQuery += " ORDER BY F2_DOC " + CRLF // Vitor EZ4 - inclusao em 04/03/2020
EndIf

TCQuery cQuery ALIAS "SQL" NEW

SQL->(DbGoTop())
//Verificando se gerou resultado para os par�metros selecionados
If SQL->(!EOF()) .OR. SQL->(!BOF()) 
	CriaRecibo("SQL")
Else
	Alert("Nao foi encontrado registros. Por favor, verifique o filtro!")
	Return .F.
EndIf

Return

/*
Funcao      : CriaPerg
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Cria o Pergunte 0FFAT1 no SX1
Autor     	: Renato Rezende  	 	
Data     	: 01/12/2014
Modulo      : Faturamento.
Cliente     : NTT
*/
*-------------------------------*
 Static Function CriaPerg()
*-------------------------------*

U_PUTSX1(cPerg, "01","NF Inicial ?" ,"NF Inicial ?","NF Inicial ?"    				,"mv_ch1","C", 9,0,0,"G", "","SF2","","","mv_par01","","","","","","","","","","","","","","","","",{"Informe o Numero da NF inicial." },{},{},"")
U_PUTSX1(cPerg, "02","NF Final ? "  ,"NF Final ?"  ,"NF Final ?"    	   				,"mv_ch2","C", 9,0,0,"G", "","SF2","","","mv_par02","","","","","","","","","","","","","","","","",{"Informe o Numero da NF Final."   },{},{},"")
U_PUTSX1(cPerg, "03","Serie NF ? "  ,"Serie NF ?"  ,"Serie NF ?"    	   				,"mv_ch3","C", 3,0,0,"G", "","","","","mv_par03","","","","","","","","","","","","","","","","",{"Informe o Numero de Serie da NF."},{},{},"")

Return
