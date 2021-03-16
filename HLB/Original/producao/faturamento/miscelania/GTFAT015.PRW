#include "PROTHEUS.CH"
#include "RWMAKE.CH"
#include 'topconn.ch'    
#include 'colors.ch'

/*
Funcao      : GTFAT015
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Emitir Nota Fiscal Fatura de Serviços/Débito Genérico.
Autor       : Renato Rezende
Data        : 15/04/2016
TDN         : 
Módulo      : Faturamento.
*/   
                          
*-------------------------*
  User Function GTFAT015()   
*-------------------------*                                      
Private cPerg := "GTFAT015"

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
Local cQuery 	:= "" 

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

aStru := {SF2->(dbStruct()),SD2->(dbStruct()), SE1->(dbStruct())}

ProcRegua(Len(aStru))

cQuery += " Select F2_DOC,F2_PREFIXO,F2_SERIE,F2_EMISSAO,F2_FILIAL,F2_CLIENTE,F2_LOJA,F2_PREFIXO,F2_DUPL,"
cQuery += "		F2_BASEICM,F2_VALICM,F2_VALMERC,F2_VALBRUT,F2_DESCONT,"
cQuery += "		SD2.D2_QUANT,SD2.D2_PRUNIT,SD2.D2_COD,SD2.D2_ITEMPV,SD2.D2_PEDIDO, SD2.D2_TES,"
cQuery += "		SD2.D2_CF ,SD2.D2_PICM,SD2.D2_FILIAL,SD2.D2_DOC,SD2.D2_SERIE,"
cQuery += "		SA1.A1_CEP,SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME,SA1.A1_END, SA1.A1_EST, SA1.A1_MUN, "
cQuery += "		SA1.A1_BAIRRO, SA1.A1_CGC, SA1.A1_INSCR , SA1.A1_PESSOA,"
cQuery += "		SC5.C5_FILIAL,SC5.C5_NUM,SC5.C5_CLIENTE,SC5.C5_LOJACLI,"
cQuery += "		SC6.C6_VALOR,SC6.C6_FILIAL,SC6.C6_CLI,SC6.C6_LOJA,"
cQuery += "		SE1.E1_FILIAL, SE1.E1_NUM, SE1.E1_CLIENTE, SE1.E1_LOJA, SE1.E1_VENCREA, SE1.E1_TIPO, SE1.E1_VALOR "    			//CAS - 21/11/2017 - Adicionado campo SE1.E1_VALOR - Ticket 19113 
cQuery += " From "+RetSqlName("SF2")+" SF2 inner join (Select D2_QUANT,D2_PRUNIT,D2_COD,D2_ITEMPV,D2_PEDIDO, D2_TES, D2_CF ,"
cQuery += "								   						D2_PICM,D2_FILIAL,D2_DOC,D2_SERIE"
cQuery += "							From "+RetSqlName("SD2")
cQuery += "							Where D_E_L_E_T_ <> '*') as SD2 on SF2.F2_DOC+SF2.F2_SERIE = SD2.D2_DOC+SD2.D2_SERIE"
cQuery += "				left outer join(Select A1_CEP,A1_COD, A1_LOJA, A1_NOME,A1_END, A1_EST, A1_MUN, A1_BAIRRO, A1_CGC, A1_INSCR , A1_PESSOA"
cQuery += "								From "+RetSqlName("SA1")
cQuery += "								Where D_E_L_E_T_ <> '*' AND A1_FILIAL = '"+xFilial("SA1")+"'"
cQuery += "								) as SA1 on SF2.F2_CLIENTE+SF2.F2_LOJA = SA1.A1_COD+SA1.A1_LOJA"
cQuery += "				left outer join(Select C5_FILIAL,C5_NUM,C5_CLIENTE,C5_LOJACLI"
cQuery += "								From "+RetSqlName("SC5")
cQuery += "								Where D_E_L_E_T_ <> '*' AND C5_FILIAL = '"+xFilial("SC5")+"'"
cQuery += "								) as SC5 on SD2.D2_PEDIDO = SC5.C5_NUM"
cQuery += "				left outer join(Select C6_NUM,C6_ITEM,C6_VALOR,C6_FILIAL,C6_CLI,C6_LOJA"
cQuery += "								From "+RetSqlName("SC6")
cQuery += "								Where D_E_L_E_T_ <> '*' AND C6_FILIAL = '"+xFilial("SC6")+"'"
cQuery += "								) as SC6 on SD2.D2_PEDIDO = SC6.C6_NUM AND SD2.D2_ITEMPV = SC6.C6_ITEM"
cQuery += "				left outer join(Select E1_FILIAL,E1_PREFIXO, E1_NUM, E1_CLIENTE, E1_LOJA, E1_VENCREA, E1_TIPO, E1_VALOR " 		//CAS - 21/11/2017 - Adicionado campo E1_VALOR - Ticket 19113
cQuery += "								From "+RetSqlName("SE1")
cQuery += "								Where D_E_L_E_T_ <> '*' AND E1_FILIAL = '"+xFilial("SE1")+"'"
cQuery += "								) as SE1 on SD2.D2_DOC = SE1.E1_NUM AND SF2.F2_PREFIXO = SE1.E1_PREFIXO AND SE1.E1_TIPO = 'NF'"
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
   oPrint:= TMSPrinter():New( "Impressão de Fatura ")  
      
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
   oPrint:SayBitmap(230,110,"\System\"+cEmpAnt+"logo.jpg",526,178) 
   
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
   oPrint:Say(3080,750,"VALOR LÍQUIDO DA FATURA = R$",oFont10n,,CLR_BLACK)   

End Sequence                                          

Return  

*-------------------------------------*
Static Function ReportDetail(oPrint)   
*-------------------------------------*   
  
Local n            := 1   

Local cCli, cDoc, cSerie
Local nQtdItens		:= 0
Local cFil			:= xFilial("SD2")

Private nPagina    := 1
Private nLinha     := 1100 
Private nTotal     := 0
Private cPedido      := ""

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

			//Função para preencher caso tenha conteudo no C5_MENNOTA
			If cEmpAnt == "BI"
				MenNotaBI(@nLinha,cPedido)
			Else
				MenNota(@nLinha,cPedido)	
			EndIf	
			oPrint:Say(nLinha,121,"PRODUTO: "+Alltrim(SC6->C6_DESCRI),oFont10,,CLR_BLACK)
			nLinha+=50

			//CAS - 21/11/2017 - Trocado o campo SC6->C6_VALOR pelo SQL->E1_VALOR, para atender a Cond.Pgto 09 (Várias parcelas) - Ticket 19113.
//			oPrint:Say(nLinha,121,"VALOR: R$ "+Alltrim(Transform(SC6->C6_VALOR+SC6->C6_VALDESC,"@E 999,999,999,999.99"))+" ("+Alltrim(Extenso(SC6->C6_VALOR+SC6->C6_VALDESC))+")",oFont10,,CLR_BLACK)
			oPrint:Say(nLinha,121,"VALOR: R$ "+Alltrim(Transform(SQL->E1_VALOR,"@E 999,999,999,999.99"))+" ("+Alltrim(Extenso(SQL->E1_VALOR))+")",oFont10,,CLR_BLACK)

			nLinha+=50
			oPrint:Say(nLinha,121,"VENCIMENTO: "+DtoC(SQL->E1_VENCREA),oFont10,,CLR_BLACK) 
			nLinha+=100
			
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
	oPrint:Say(835,395,DtoC(SQL->E1_VENCREA),oFont10n,,CLR_BLACK) 
    
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
		If Len(Alltrim(SC5->C5_MENNOTA))>94           		
       		nPosMenN:=1 //controla a posição de corte da msg
           	While !Empty(Substr(Alltrim(SC5->C5_MENNOTA),nPosMenN,93))
            	oPrint:Say(nLinha,121,Substr(Alltrim(SC5->C5_MENNOTA),nPosMenN,93),oFont10,,CLR_BLACK)
            	nPosMenN+=93
            	nLinha+=50
            	ChkLinha()
			EndDo
			ChkLinha()
		Else
			oPrint:Say(nLinha,121,Alltrim(SC5->C5_MENNOTA),oFont10,,CLR_BLACK)
       		nLinha+=50
       		ChkLinha()		
		EndIf
		nLinha+=50
	EndIf
EndIf  

Return

//VYB - 16/09/2016 - Chamado 036200 - Inclusão do campo C5_P_REF na descrição
*---------------------------------------*             
Static Function MenNotaBI(nLinha,cPedido)
*---------------------------------------*
cMenNota := ""
cMenNot2 := ""
SC5->(DbSetOrder(1))                
If SC5->(dbSeek(xFilial("SC5")+cPedido))
	If Alltrim(SC5->C5_MENNOTA) <> ""
		cMenNota := IIf(Empty(SC5->C5_P_REF),"PO: ","PO: " + Alltrim(SC5->C5_P_REF) + "/") + Alltrim(SC5->C5_MENNOTA)
		cMenNot2 := IIf(Empty(SC5->C5_P_RNUM),"","FATURA: " + SC5->C5_P_RNUM)              
		If Len(cMenNota)>94           		
       		nPosMenN:=1 //controla a posição de corte da msg
           	While !Empty(Substr(cMenNota,nPosMenN,93))          	             		
            	oPrint:Say(nLinha,121,Substr(cMenNota,nPosMenN,93),oFont10,,CLR_BLACK)
            	oPrint:Say(nLinha,121,Substr(cMenNot2,nPosMenN,93),oFont10,,CLR_BLACK)            	
            	nPosMenN+=93
            	nLinha+=50
            	ChkLinha()
			EndDo
			ChkLinha()
		Else
  			oPrint:Say(nLinha,121, cMenNota ,oFont10,,CLR_BLACK)
			nLinha+=50  			
  			oPrint:Say(nLinha,121, cMenNot2 ,oFont10,,CLR_BLACK) 
       		nLinha+=50
       		ChkLinha()		
		EndIf
		nLinha+=50
	EndIf
EndIf  

Return
