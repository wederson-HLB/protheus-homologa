#include "PROTHEUS.CH"
#include "RWMAKE.CH"
#include 'topconn.ch'    
#include 'colors.ch'

/*
Funcao      : 49FAT002
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Emitir Nota Fiscal Fatura de Serviços/Débito
Autor       : Renato Rezende
Data        : 01/07/2013
TDN         : 
Módulo      : Faturamento.
*/   
                          
*-------------------------*
  User Function 49FAT002()   
*-------------------------*                                      
Private cPerg := "49FAT02"

IF SM0->M0_CODIGO $ "49/48" 
   Begin Sequence         
		
		AjustaSx1()
		If Pergunte(cPerg,.T.)
			cNotaDe		:= mv_par01
			cNotaAte	:= mv_par02
			cSerie		:= mv_par03

			Processa({|| MontaQuery() })

			If SQL->(!EoF()) 
	    	   CriaLayout("SQL")
		    Else
		       Alert("Não foi encontrado registros. Por favor, verifique o filtro!")
	    	EndIf
		EndIf

   End Sequence
EndIf

Return      

*-------------------------*
STATIC Function AjustaSx1()
*-------------------------*
Local aRegs	   		:= {}

U_PUTSX1( cPerg, "01","NF Inicial ?" ,"NF Inicial ?","NF Inicial ?"    				,"mv_ch1","C"   , 6     ,0      ,0     ,"G", "","","","", "mv_par01", " "  		 , "     " , "      " , "" ,"    "		,"     ","      ","     "  ,"   ", "  " , "  " ,"     ","     ","   ", ""     ," ",   	{"Informe o Numero da NF inicial." },     {},         {},        "")
U_PUTSX1( cPerg, "02","NF Final ? "  ,"NF Final ?"  ,"NF Final ?"    	   				,"mv_ch2","C"   , 6     ,0      ,0     ,"G", "","","","", "mv_par02", " "  	     , "     " , "      " , "" ,"    "		,"     ","      ","     "  ,"   ", "  " , "  " ,"     ","     ","   ", ""     ," ",   	{"Informe o Numero da NF Final."   },     {},         {},        "")
U_PUTSX1( cPerg, "03","Serie NF ? "  ,"Serie NF ?"  ,"Serie NF ?"    	   				,"mv_ch3","C"   , 3     ,0      ,0     ,"G", "","","","", "mv_par03", " "  	     , "     " , "      " , "" ,"    "		,"     ","      ","     "  ,"   ", "  " , "  " ,"     ","     ","   ", ""     ," ",   	{"Informe o Numero de Serie da NF."},     {},         {},        "")

Return
                  
*--------------------------*
Static Function MontaQuery()   
*--------------------------*
Local i
Local cQuery := ""

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

aStru := {SF2->(dbStruct()),SD2->(dbStruct()), SE1->(dbStruct())}

ProcRegua(Len(aStru))

cQuery += " Select F2_DOC,F2_SERIE,F2_EMISSAO,F2_FILIAL,F2_CLIENTE,F2_LOJA,F2_PREFIXO,F2_DUPL,"
cQuery += "		F2_BASEICM,F2_VALICM,F2_VALMERC,F2_VALBRUT,F2_DESCONT,"
cQuery += "		SD2.D2_QUANT,SD2.D2_PRUNIT,SD2.D2_COD,SD2.D2_ITEMPV,SD2.D2_PEDIDO, SD2.D2_TES,"
cQuery += "		SD2.D2_CF ,SD2.D2_PICM,SD2.D2_FILIAL,SD2.D2_DOC,SD2.D2_SERIE,"
cQuery += "		SA1.A1_CEP,SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME,SA1.A1_END, SA1.A1_EST, SA1.A1_MUN, "
cQuery += "		SA1.A1_BAIRRO, SA1.A1_CGC, SA1.A1_INSCR , SA1.A1_PESSOA,"
cQuery += "		SC5.C5_FILIAL,SC5.C5_NUM,SC5.C5_CLIENTE,SC5.C5_LOJACLI,SC5.C5_P_VINCU,SC5.C5_P_VIANO,"
cQuery += "		SC6.C6_VALOR,SC6.C6_FILIAL,SC6.C6_CLI,SC6.C6_LOJA,"
cQuery += "		SE1.E1_FILIAL, SE1.E1_NUM, SE1.E1_CLIENTE, SE1.E1_LOJA, SE1.E1_VENCTO, SE1.E1_TIPO, SE1.E1_NATUREZ, SE1.E1_IRRF, SE1.E1_CSLL, SE1.E1_COFINS, SE1.E1_PIS"
cQuery += " From "+RetSqlName("SF2")+" SF2 inner join (Select D2_QUANT,D2_PRUNIT,D2_COD,D2_ITEMPV,D2_PEDIDO, D2_TES, D2_CF ,"
cQuery += "								   						D2_PICM,D2_FILIAL,D2_DOC,D2_SERIE"
cQuery += "							From "+RetSqlName("SD2")
cQuery += "							Where D_E_L_E_T_ <> '*') as SD2 on SF2.F2_DOC+SF2.F2_SERIE = SD2.D2_DOC+SD2.D2_SERIE"
cQuery += "				left outer join(Select A1_CEP,A1_COD, A1_LOJA, A1_NOME,A1_END, A1_EST, A1_MUN, A1_BAIRRO, A1_CGC, A1_INSCR , A1_PESSOA"
cQuery += "								From "+RetSqlName("SA1")
cQuery += "								Where D_E_L_E_T_ <> '*' AND A1_FILIAL = '"+xFilial("SA1")+"'"
cQuery += "								) as SA1 on SF2.F2_CLIENTE+SF2.F2_LOJA = SA1.A1_COD+SA1.A1_LOJA"
cQuery += "				left outer join(Select C5_FILIAL,C5_NUM,C5_CLIENTE,C5_LOJACLI,C5_P_VINCU,C5_P_VIANO"
cQuery += "								From "+RetSqlName("SC5")
cQuery += "								Where D_E_L_E_T_ <> '*' AND C5_FILIAL = '"+xFilial("SC5")+"'"
cQuery += "								) as SC5 on SD2.D2_PEDIDO = SC5.C5_NUM"
cQuery += "				left outer join(Select C6_NUM,C6_ITEM,C6_VALOR,C6_FILIAL,C6_CLI,C6_LOJA"
cQuery += "								From "+RetSqlName("SC6")
cQuery += "								Where D_E_L_E_T_ <> '*' AND C6_FILIAL = '"+xFilial("SC6")+"'"
cQuery += "								) as SC6 on SD2.D2_PEDIDO = SC6.C6_NUM AND SD2.D2_ITEMPV = SC6.C6_ITEM"
cQuery += "				left outer join(Select E1_FILIAL,E1_PREFIXO, E1_NUM, E1_CLIENTE, E1_LOJA, E1_VENCTO, E1_TIPO, E1_NATUREZ, E1_IRRF, E1_CSLL, E1_COFINS, E1_PIS"
cQuery += "								From "+RetSqlName("SE1")
cQuery += "								Where D_E_L_E_T_ <> '*' AND (E1_PARCELA=''OR E1_PARCELA='A') AND E1_FILIAL = '"+xFilial("SE1")+"'"//JSS - 01/10/2015 - Ajustado para trazer apenas um registro de cada nota. Chamado: 029848
cQuery += "								) as SE1 on SD2.D2_DOC = SE1.E1_NUM AND SD2.D2_SERIE = SE1.E1_PREFIXO AND SE1.E1_TIPO = 'NF'" //RRP - 07/08/2013 - Ajuste para não trazer os impostos.
cQuery += " Where"
cQuery += "		SF2.D_E_L_E_T_ <> '*'""
cQuery += " 	AND SF2.F2_FILIAL = '"+xFilial("SF2")+"'"

If !EMPTY(cNotaDe)
	cQuery += "		AND SF2.F2_DOC >= '"+cNotaDe+"'"
EndIf
If !EMPTY(cNotaAte)
	cQuery += "		AND SF2.F2_DOC <= '"+cNotaAte+"'"
EndIf
If !EMPTY(cSerie)
	cQuery += "		AND SF2.F2_SERIE = '"+cSerie+"'"
EndIf
//RRP - 01/10/2013 - Ordenando pelos números dos documentos. Chamado 014487.
cQuery += "Order by SF2.F2_DOC"

TCQuery cQuery ALIAS "SQL" NEW

For i:=1 to len(aStru)
	For nX := 1 To Len(aStru[i])
	    If aStru[i][nX,2]<>"C"
	 	    TcSetField("SQL",aStru[i][nX,1],aStru[i][nX,2],aStru[i][nX,3],aStru[i][nX,4])
	    EndIf
	Next nX  
	IncProc("Buscando dados...")
Next i

Return 

*---------------------------------------
Static Function CriaLayout(cNomeArquivo)   
*--------------------------------------- 
//Declara a variável objeto do relatório
Private oPrint

//Cria os objetos fontes que serão utilizadoas através do método TFont()                            
Private oFont5      := TFont():New('Arial',,07,,.F.,,,,,.F. )       // 5
Private oFont07     := TFont():New('Arial',07,07,,.F.,,,,.T.,.F.)	// 07
Private oFont07n    := TFont():New('Arial',07,07,,.T.,,,,.T.,.F.)   // 07
Private oFont08     := TFont():New('Arial',08,08,,.F.,,,,.T.,.F.)  	// 08
Private oFont08n    := TFont():New('Arial',08,08,,.T.,,,,.T.,.F.)   // 08
Private oFont09     := TFont():New('Arial',09,09,,.F.,,,,.T.,.F.)  	// 09
Private oFont09n    := TFont():New('Arial',09,09,,.T.,,,,.T.,.F.)   // 09
Private oFont10     := TFont():New('Tahoma',10,10,,.F.,,,,.T.,.F.)  // 11
Private oFont10n    := TFont():New('Tahoma',10,10,,.T.,,,,.T.,.F.)  // 11  


Private nPagina     := 1

Begin Sequence
   //Cria objeto TMSPrinter()               
   oPrint:= TMSPrinter():New( "Impressão de Nota Fiscal da Discovery Networks" )  
      
   //Página tipo retrato
   oPrint:SetPortrait()  
   
   //Inicia uma nova página
   oPrint:StartPage()   
   
   //Papel A4
   oPrint:SetpaperSize(9)  
   
   //Molduras externas
   BoxGeral(oPrint) 
      
   //Cria o Cabeçalho do Relatório
   ReportHeader(oPrint)      
      
   //Cria os Detalhes do Relatório
   Processa({||ReportDetail(oPrint)    })
 
   //Preview da Impressao
   oPrint:Preview()   
   
   //Selecionar Impressora
   //oPrint:setup()  
   
   //Imprime direto na impressora padrão do APx
   //oPrint:Print() 
     
   //Finaliza a página
   oPrint:EndPage()
   
   //Finaliza Objeto 
   oPrint:End() 
   
   //Desativa Impressora
   ms_flush() 

End Sequence

Return

*------------------------------------
Static Function ReportHeader(oPrint)   
*------------------------------------   

Begin Sequence 
   //Logo
   oPrint:SayBitmap(230,110,"\System\49logo.jpg",526,178) 
   
   //Cabeçalho 
   oPrint:Say(170,695,"FATURA DE VEÍCULAÇÃO DE PUBLICIDADE",oFont10n,,CLR_BLACK)
   oPrint:Say(170,1830,"Nº",oFont10n,,CLR_BLACK)
   oPrint:Say(270,695,"Razão Social: ",oFont10n,,CLR_BLACK)
   oPrint:Say(270,1035,Alltrim(SM0->M0_NOMECOM),oFont10,,CLR_BLACK)
   oPrint:Say(310,695,"Endereço: ",oFont10n,,CLR_BLACK)
   oPrint:Say(310,1035,Alltrim(SM0->M0_ENDCOB)+" - "+Alltrim(SM0->M0_COMPCOB)+" - "+Alltrim(SM0->M0_BAIRENT)+" - CEP: "+Alltrim(SM0->M0_CEPCOB),oFont10,,CLR_BLACK)
   oPrint:Say(350,695,"Município: ",oFont10n,,CLR_BLACK)
   oPrint:Say(350,1035,Alltrim(SM0->M0_CIDCOB)+" - UF: "+Alltrim(SM0->M0_ESTCOB),oFont10,,CLR_BLACK)
   oPrint:Say(390,695,"CNPJ: ",oFont10n,,CLR_BLACK)
   oPrint:Say(390,1035,Alltrim(Transform(SM0->M0_CGC,"@R 99.999.999/9999-99")),oFont10,,CLR_BLACK)
   oPrint:Say(430,695,"Data de Emissão: ",oFont10n,,CLR_BLACK)
   
   //Destinatario                                                
   oPrint:Say(635,121,"Razão Social: ",oFont10n,,CLR_BLACK)
   oPrint:Say(685,121,"Endereço: ",oFont10n,,CLR_BLACK)
   oPrint:Say(735,1250,"CEP: ",oFont10n,,CLR_BLACK)
   oPrint:Say(735,121,"Município: ",oFont10n,,CLR_BLACK)
   oPrint:Say(785,1250,"UF: ",oFont10n,,CLR_BLACK)
   oPrint:Say(785,121,"CNPJ: ",oFont10n,,CLR_BLACK)
   oPrint:Say(835,1250,"Inscr. Estadual: ",oFont10n,,CLR_BLACK)
   
   oPrint:Say(835,121,"Vencimento: ",oFont10n,,CLR_BLACK)  

   //Serviços
   oPrint:Say(980,990,"DESCRIÇÃO DA ENTREGA",oFont10n,,CLR_BLACK)
   oPrint:Say(1100,121,"CESSÃO DE ESPAÇO PARA VEICULAÇÃO DE PUBLICIDADE",oFont10,,CLR_BLUE)
   oPrint:Say(3080,750,"VALOR LÍQUIDO DA FATURA = R$",oFont10n,,CLR_BLACK)   

End Sequence                                          

Return  

*-------------------------------------*
Static Function ReportDetail(oPrint)   
*-------------------------------------*   
  
Local n			:= 1
Local o			:= 1   
Local nQtdItens	:= 0
Local nMes		:= ""
Local nAno		:= ""

Local cCli, cDoc, cSerie
Local cFil		:= xFilial("SD2")
Local cVend		:= ""

Private nPagina := 1
Private nLinha  := 1150  
Private nTotal  := 0

Private cPedido := ""

   	dbSelectArea("SQL")
   	dbGoTop()   
   	cDoc    := SQL->F2_DOC 
  	cSer	:= SQL->F2_SERIE 
  	cPedido := SQL->D2_PEDIDO 
   
	If Select("CONT") > 0
		CONT->(dbCloseArea())
	EndIf                        

	cQuery := "SELECT COUNT(*)  AS QTD"+Chr(10)
	cQuery += " FROM "+RetSqlName("SD2")+Chr(10)
	cQuery += " WHERE  D2_FILIAL ="+cFil+Chr(10)
	cQuery += " AND D2_PEDIDO ='"+Alltrim(cPedido)+"'"
	cQuery += " AND D2_SERIE  ='"+Alltrim(cSer)+"'"
	cQuery += " AND D2_DOC    ='"+Alltrim(cDoc)+"'"
	cQuery += " AND D_E_L_E_T_ <> '*' "

	TCQuery cQuery ALIAS "CONT" NEW
 
    nQtdItens := CONT->QTD
    
    ProcRegua(nQtdItens)
   
    CONT->(DbCloseArea())
    
    If nQtdItens <= 5
    	nTotal:=1
    ElseIf nQtdItens <=11	               
    	nTotal:=2
    ElseIf nQtdItens <=16	               
    	nTotal:=3	
    EndIf

	ImpCapa()

    While SQL->F2_DOC <> '' .And. SQL->(!EOF())  
		If cDoc+cSer <> SQL->F2_DOC+SQL->F2_SERIE
			oPrint:EndPage()   
         	oPrint:StartPage() 
         	oPrint:SetPortrait()
         	oPrint:SetpaperSize(9)
         	BoxGeral(oPrint) 
         	ReportHeader(oPrint)
         	ImpCapa()
         	nLinha := 1150  
         	cDoc:= SQL->F2_DOC 
         	cSer:= SQL->F2_SERIE
         	cPedido:= SQL->D2_PEDIDO  
		EndIf        

		SC6->(DbSetOrder(2))                
		If SC6->(dbSeek(xFilial("SC6")+SQL->D2_COD+SQL->D2_PEDIDO+SQL->D2_ITEMPV))
			
			//Imprimindo primeiro bloco do serviço
			//RRP - 05/08/2013 - Solicitação do chamado 013701.
			nMes := SQL->C5_P_VINCU
			//RRP - 09/01/2014 - Solicitação do chamado 016306.
			If !Empty(Alltrim(SQL->C5_P_VIANO))
				nAno := Alltrim(SQL->C5_P_VIANO)
			Else
		   		nAno := Alltrim(STR(YEAR(SQL->F2_EMISSAO)))
			EndIf
			
			oPrint:Say(nLinha,121,"Veiculação: "+MesExtenso(nMes)+"/"+nAno,oFont10,,CLR_BLACK)
			nLinha+=50
			oPrint:Say(nLinha,121,"CANAL: "+Alltrim(SC6->C6_DESCRI),oFont10,,CLR_BLACK)
			nLinha+=50
			oPrint:Say(nLinha,121,"Valor: R$ "+Alltrim(Transform(SC6->C6_VALOR+SC6->C6_VALDESC,"@E 999,999,999,999.99")),oFont10,,CLR_BLACK)
			//RRP - 10/09/2013 - Inclusão dos impostos para as faturas do governo. Chamado 014501
			If Alltrim(SQL->E1_NATUREZ) == '1097'
				nLinha+=50
				oPrint:Say(nLinha,121,"IMPOSTOS:",oFont10n,,CLR_BLACK)				
				nLinha+=50
				oPrint:Say(nLinha,140,"PIS: R$ "+Alltrim(Transform(SQL->E1_PIS,"@E 999,999,999,999.99")),oFont10,,CLR_BLACK)
				nLinha+=50
				oPrint:Say(nLinha,140,"COFINS: R$ "+Alltrim(Transform(SQL->E1_COFINS,"@E 999,999,999,999.99")),oFont10,,CLR_BLACK)
				nLinha+=50
				oPrint:Say(nLinha,140,"CSLL: R$ "+Alltrim(Transform(SQL->E1_CSLL,"@E 999,999,999,999.99")),oFont10,,CLR_BLACK)
				nLinha+=50
				oPrint:Say(nLinha,140,"IR: R$ "+Alltrim(Transform(SQL->E1_IRRF,"@E 999,999,999,999.99")),oFont10,,CLR_BLACK)
				nLinha+=50
				oPrint:Say(nLinha,140,"Valor Líquido Considerando Retenção: R$ "+Alltrim(Transform((SC6->C6_VALOR)-(SQL->E1_PIS+SQL->E1_COFINS+SQL->E1_CSLL+SQL->E1_IRRF),"@E 999,999,999,999.99")),oFont10,,CLR_BLACK)
			EndIf
			nLinha+=100
			
			//Se o item possui desconto imprimir o bloco abaixo
			If SC6->C6_DESCONT <> 0
				oPrint:Say(nLinha,121,"REFERÊNCIA PADRÃO (REMUNERAÇÃO DA AGÊNCIA ITEM 1,11 DAS NORMAS PADRÕES DA ATIVIDADE",oFont10,,CLR_BLACK)
				nLinha+=50
				oPrint:Say(nLinha,121,"PUBLICITÁRIA): ("+Transform(SC6->C6_DESCONT,"@E 999.99")+"%) R$ "+Alltrim(Transform(SC6->C6_VALDESC,"@E 999,999,999,999.99")),oFont10,,CLR_BLACK)
				nLinha+=50
				oPrint:Say(nLinha,121,"Valor Liquído: R$ "+Alltrim(Transform(SC6->C6_VALOR,"@E 999,999,999,999.99")),oFont10,,CLR_BLACK)
				nLinha+=100	
			EndIf
		
		//Função para preencher caso tenha conteudo no C5_MENNOTA
		MenNota(@nLinha,cPedido)
			
    	//Montando o bloco do SC5
		SC5->(DbSetOrder(1))
		If SC5->(dbSeek(xFilial("SC5")+cPedido))
			oPrint:Say(nLinha,121,"P.I. Nº "+Alltrim(SC5->C5_P_PI),oFont10,,CLR_BLACK)
			nLinha+=50
			oPrint:Say(nLinha,121,"Agência: "+Alltrim(SC5->C5_P_NMAGC),oFont10,,CLR_BLACK)
			nLinha+=50
			//RRP - 11/09/2013 - Tratamento para puxar o Vendedor.
			cVend:= ""
			For o := 1 to 5
				If !Empty(SC5->(&("C5_VEND"+Alltrim(STR(o)))))
					cVend := SC5->(&("C5_VEND"+Alltrim(STR(o))))
					Exit
				EndIf					
			Next
			//RRP - 02/10/2013 - Ajuste para impressão do vendedor.
			oPrint:Say(nLinha,121,"Vendedor (s): "+IIF(cVend == "","",Alltrim(Posicione("SA3", 1, xFilial("SA3")+cVend, "A3_NOME"))),oFont10,,CLR_BLACK)
			nLinha+=100
		EndIf
		
        ChkLinha()
		 
		EndIf

		oPrint:Say(3350,2100,"Pagina "+(Alltrim(str(nPagina)))+"/"+(Alltrim(str(nTOTAL))),oFont5,,CLR_BLACK)   

		IncProc("Imprimindo...")
		SQL->(DbSkip())
	EndDo	

//Fecha o arquivo
SQL->(dbCloseArea())

Return  

*------------------------------*
Static Function BoxGeral(oPrint)   
*------------------------------*
Local L:= 1420
//Private oPen := TPen():New(,7,CLR_BLACK,oPrint)     
Private oPen := TPen():New(,7,CLR_BLACK)

Begin Sequence 
                                                  
   oPrint:Box(155,90,530,650)    //Logo  
   oPrint:Box(155,670,530,2250)   //Numero nota  
                                          
   oPrint:Box(570,90,920,2250)     //Destinatário
   oPrint:Box(960,90,3050,2250)    //Itens
   oPrint:Box(3150,90,3050,2250)    //Valor
                                            
   oPrint:Line(1030,90,1030,2250)   //Linha Descrição da Entrega
    
End Sequence

Return

*------------------------*
Static Function ImpCapa() 
*------------------------*
    
	oPrint:Say(170,1910,Alltrim(SQL->F2_DOC),oFont10n,,CLR_BLACK)
      
 	SF3->(DbSetOrder(6))                
  	SF3->(dbSeek(xFilial("SF3")+SQL->F2_DOC+SQL->F2_SERIE)) 
        
    oPrint:Say(430,1035,DtoC(SQL->F2_EMISSAO),oFont10n,,CLR_BLACK) 
    oPrint:Say(635,395,Alltrim(SQL->A1_NOME),oFont10n,,CLR_BLACK)                
    oPrint:Say(685,395,Alltrim(SQL->A1_END)+" - "+Alltrim(SQL->A1_BAIRRO),oFont10,,CLR_BLACK)
    oPrint:Say(735,1560,Alltrim(SQL->A1_CEP),oFont10,,CLR_BLACK)
    oPrint:Say(735,395,Alltrim(SQL->A1_MUN),oFont10,,CLR_BLACK)
    oPrint:Say(785,1560,Alltrim(SQL->A1_EST),oFont10,,CLR_BLACK)
	oPrint:Say(835,395,DtoC(SQL->E1_VENCTO),oFont10n,,CLR_BLACK)//RRP - 06/11/2013 - Ajuste para buscar no E1_VENCTO e não do E1_VENCREA. Chamado 015402. 
    
	If !EMPTY(SQL->A1_CGC)    
    	If Len(SQL->A1_CGC) == 14
    		oPrint:Say(785,395,Transform(Alltrim(SQL->A1_CGC),"@R 99.999.999/9999-99"),oFont10,,CLR_BLACK)
	    Else 
    		oPrint:Say(785,395,Transform(Alltrim(SQL->A1_CGC),"@R 999.999.999-99"),oFont10,,CLR_BLACK)
	    EndIf
    EndIf
    
    If !Empty(SQL->A1_INSCR)
    	oPrint:Say(835,1560,Alltrim(SQL->A1_INSCR),oFont10,,CLR_BLACK)
    Else 
		oPrint:Say(835,1560,"ISENTO",oFont10,,CLR_BLACK)
    EndIf 
    
    //VALORES DO FINAL DA FATURA
    oPrint:Say(3080,1330,Transform(SQL->F2_VALBRUT,"@E 999,999,999,999.99"),oFont10n,,CLR_BLACK) 
    
    //MENSAGEM DO FINAL DA NOTA
   	oPrint:Say(2950,121,"Dispensada de emissao de nota fiscal pela LCP 116/03, que excluiu o item 86 da Lista de Servicos anexa a LCP 56/87 .",oFont10,,CLR_BLUE)
  
Return                                                                                                     

*------------------------*             
Static Function ChkLinha()
*------------------------*
If nLinha > 2790   
	oPrint:EndPage()   
 	oPrint:StartPage() 
  	oPrint:SetPortrait()
   	oPrint:SetpaperSize(9)
  	//Molduras externas
    BoxGeral(oPrint) 
   	//Cria o Cabeçalho do Relatório
   	ReportHeader(oPrint)      
  	ImpCapa() 

  	nLinha       := 1150
	nPagina++
	oPrint:Say(3350,2100,"Pagina "+(Alltrim(str(nPagina)))+"/"+(Alltrim(str(nTOTAL))),oFont5,,CLR_BLACK)
EndIf  

*---------------------------------------*             
Static Function MenNota(nLinha,cPedido)
*---------------------------------------* 
    
SC5->(DbSetOrder(1))                
If SC5->(dbSeek(xFilial("SC5")+cPedido))
	
	If Alltrim(SC5->C5_MENNOTA) <> ""             

		If Len(Alltrim(SC5->C5_MENNOTA))>84
               		
       		nPosMenN:=1 //controla a posição de corte da msg
               		
			While !Empty(Substr(Alltrim(SC5->C5_MENNOTA),nPosMenN,83))             		
            	oPrint:Say(nLinha,121,Substr(Alltrim(SC5->C5_MENNOTA),nPosMenN,83),oFont10,,CLR_BLACK)
            	nPosMenN+=83
            	nLinha+=50
            	ChkLinha()
			EndDo
			nLinha+=50
			ChkLinha()
		Else
       		oPrint:Say(nLinha,121,Alltrim(SC5->C5_MENNOTA),oFont10,,CLR_BLACK) 
       		nLinha+=100
       		ChkLinha()		
		EndIf
	EndIf
EndIf  

Return
