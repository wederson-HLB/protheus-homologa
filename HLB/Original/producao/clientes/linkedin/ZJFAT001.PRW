#include "PROTHEUS.CH"
#include "RWMAKE.CH"
#include 'topconn.ch'    
#include 'colors.ch'

/*
Funcao      : ZJFAT001
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Emitir Novo Modelo Nota Fiscal Fatura de Serviços/Débito
Autor       : Juliana Mellao
Data        : 13/07/2012
TDN         : 
Revisão     : Jean Victor Rocha 
Data/Hora   : 26/07/2012
Objetivos   : Acerto geral da customização.
Módulo      : Faturamento.
*/   
                          
*-------------------------*
  User Function ZJFAT001()   
*-------------------------*                                      
Private cPerg := "NZJFAT01"

IF SM0->M0_CODIGO $ "4C/ZJ/99" 
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
cQuery += "		SD2.D2_QUANT,SD2.D2_PRUNIT,SD2.D2_COD,SD2.D2_ITEMPV,SD2.D2_PEDIDO, SD2.D2_TES,SD2.D2_CLIENTE,"
cQuery += "		SD2.D2_CF ,SD2.D2_PICM,SD2.D2_FILIAL,SD2.D2_DOC,SD2.D2_SERIE,SD2.D2_LOJA,"
cQuery += "		SA1.A1_CEP, SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME,SA1.A1_END, SA1.A1_EST, SA1.A1_MUN, "
cQuery += "		SA1.A1_BAIRRO, SA1.A1_CGC, SA1.A1_INSCR , SA1.A1_PESSOA, SA1.A1_TIPO,"
cQuery += "		SC5.C5_FILIAL,SC5.C5_NUM,SC5.C5_CLIENTE,SC5.C5_LOJACLI,SC5.C5_P_PI,C5_P_AG,SC5.C5_P_COMIS,"
cQuery += "		SC6.C6_VALOR,SC6.C6_FILIAL,SC6.C6_CLI,SC6.C6_LOJA,"
cQuery += "		SE1.E1_FILIAL, SE1.E1_NUM, SE1.E1_CLIENTE, SE1.E1_LOJA, SE1.E1_VENCREA, SE1.E1_TIPO, SE1.E1_PARCELA, SE1.E1_IRRF, SE1.E1_CSLL, SE1.E1_COFINS, SE1.E1_PIS"
cQuery += " From "+RetSqlName("SF2")+" SF2 inner join (Select D2_QUANT,D2_PRUNIT,D2_COD,D2_ITEMPV,D2_PEDIDO, D2_TES, D2_CF ,"
cQuery += "								   						D2_PICM,D2_FILIAL,D2_DOC,D2_SERIE,D2_CLIENTE,D2_LOJA"
cQuery += "							From "+RetSqlName("SD2")
cQuery += "							Where D_E_L_E_T_ <> '*') as SD2 on SF2.F2_DOC+SF2.F2_SERIE = SD2.D2_DOC+SD2.D2_SERIE"
cQuery += "				left outer join(Select A1_CEP, A1_COD, A1_LOJA, A1_NOME,A1_END, A1_EST, A1_MUN, A1_BAIRRO, A1_CGC, A1_INSCR , A1_PESSOA, A1_TIPO"
cQuery += "								From "+RetSqlName("SA1")
cQuery += "								Where D_E_L_E_T_ <> '*' AND A1_FILIAL = '"+xFilial("SA1")+"'"
cQuery += "								) as SA1 on SF2.F2_CLIENTE+SF2.F2_LOJA = SA1.A1_COD+SA1.A1_LOJA"
cQuery += "				left outer join(Select C5_FILIAL,C5_NUM,C5_CLIENTE,C5_LOJACLI,C5_P_PI,C5_P_AG,C5_P_COMIS"
cQuery += "								From "+RetSqlName("SC5")
cQuery += "								Where D_E_L_E_T_ <> '*' AND C5_FILIAL = '"+xFilial("SC5")+"'"
cQuery += "								) as SC5 on SD2.D2_PEDIDO = SC5.C5_NUM"
cQuery += "				left outer join(Select C6_NUM,C6_ITEM,C6_VALOR,C6_FILIAL,C6_CLI,C6_LOJA"
cQuery += "								From "+RetSqlName("SC6")
cQuery += "								Where D_E_L_E_T_ <> '*' AND C6_FILIAL = '"+xFilial("SC6")+"'"
cQuery += "								) as SC6 on SD2.D2_PEDIDO = SC6.C6_NUM AND SD2.D2_ITEMPV = SC6.C6_ITEM"
cQuery += "				left outer join(Select E1_FILIAL,E1_PREFIXO, E1_NUM, E1_CLIENTE, E1_LOJA, E1_VENCREA, E1_TIPO, E1_PARCELA, E1_IRRF, E1_CSLL, E1_COFINS, E1_PIS"
cQuery += "								From "+RetSqlName("SE1")
cQuery += "								Where D_E_L_E_T_ <> '*' AND E1_FILIAL = '"+xFilial("SE1")+"'"
//AOA - 23/08/2013 - Alteração para pegar apenas uma parcela nas faturas parceladas. 
cQuery += "								) as SE1 on SD2.D2_DOC = SE1.E1_NUM AND SD2.D2_SERIE = SE1.E1_PREFIXO AND (SE1.E1_PARCELA ='A' OR SE1.E1_PARCELA ='') AND SE1.E1_TIPO = 'NF'"
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
cQuery += "ORDER BY F2_DOC " 

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
Private oFont5      := TFont():New( "Tahoma",,07,,.F.,,,,,.F. )             // 5        *
Private oFont07     := TFont():New('Arial',,07,,.F.,,,,.T.,.F.)    // 07
Private oFont07n    := TFont():New('Arial',,08,,.T.,,,,.T.,.F.)    // 07       *
Private oFont07a    := TFont():New( "Arial",,07,,.t.,,,,,.f. )             // 07
Private oFont08     := TFont():New('Courier New',08,10,,.F.,,,,.T.,.F.)    // 08
Private oFont08a    := TFont():New( "Arial",,10,,.t.,,,,,.f. )             // 08
Private oFont08n    := TFont():New('Courier New',08,10,,.T.,,,,.T.,.F.)    // 08
Private oFont10a    := TFont():New( "Arial",,10,,.t.,,,,,.f. )             // 10
Private oFont10     := TFont():New('Tahoma',10,11,,.F.,,,,.T.,.F.)  // 11
Private oFont10n    := TFont():New('Tahoma',10,11,,.T.,,,,.T.,.F.)  // 11    
Private oFont11     := TFont():New('Tahoma',11,13,,.F.,,,,.T.,.F.)  // 11
Private oFont11n    := TFont():New('Tahoma',11,13,,.T.,,,,.T.,.F.)  // 11    
Private oFont11a    := TFont():New( "Arial",,13,,.t.,,,,,.f. )      // 11
Private oFont12     := TFont():New("Arial",12,12,,,,,,.T.,.F.)  // 12
Private oFont12n    := TFont():New('Tahoma',12,14,,.F.,,,,.T.,.F.)  // 12
Private oFont12a    := TFont():New( "Arial",,12,,.t.,,,,,.f. )      // 12
Private oFont13     := TFont():New('Tahoma',13,15,,.T.,,,,.T.,.F.)  // 13
Private oFont14     := TFont():New('Tahoma',14,16,,.T.,,,,.T.,.F.)  // 14
Private oFont14a    := TFont():New('Arial' ,,14,,.T.,,,,.T.,.F.)  // 14
Private oFont15     := TFont():New('Courier New',15,16,,.T.,,,,.T.,.F.)  // 15
Private oFont18     := TFont():New('Arial',18,20,,.T.,,,,.T.,.T.)   // 18  
Private oFont16     := TFont():New('Arial',16,18,,.T.,,,,.T.,.F.)   // 16  
Private oFont20t    := TFont():New('Tahoma',20,20,,.T.,,,,.T.,.F.)  // 20       *
Private oFont20     := TFont():New('Arial',20,20,,.F.,,,,.T.,.F.)   // 20
Private oFont22     := TFont():New('Arial',22,20,,.T.,,,,.T.,.F.)   // 20
Private nPagina     := 1

Begin Sequence
   //Cria objeto TMSPrinter()               
   oPrint:= TMSPrinter():New( "Impressão de Nota Fiscal da Linkedin Brasil" )  
      
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
   oPrint:SayBitmap(180,350,"\System\ZJlogo.jpg",620,220) 
   oPrint:Say(480,400,"LINKEDIN REPRESENTAÇÕES DO BRASIL LTDA",oFont5,,CLR_BLACK) 

   //Cabeçalho 
   oPrint:Say(170,1310,"FATURA",oFont10n,,CLR_BLACK)
   oPrint:Say(170,1830,"Nº",oFont10n,,CLR_BLACK)
   //RRP - 01/07/2013 - Alteração para buscar do SM0 as informações da empresa        	
   oPrint:Say(260,1310,Alltrim(SM0->M0_ENDCOB)+"     -     "+Alltrim(SM0->M0_COMPCOB)+"     -     "+Alltrim(SM0->M0_BAIRENT),oFont07n,,CLR_BLACK) 
   oPrint:Say(300,1310,Alltrim(SM0->M0_CIDCOB)+"                         -                        ESTADO: "+Alltrim(SM0->M0_ESTCOB),oFont07n,,CLR_BLACK) 
   oPrint:Say(350,1310,"CNPJ: "+Alltrim(Transform(SM0->M0_CGC,"@R 99.999.999/9999-99")),oFont07n,,CLR_BLACK)
   
   IF !EMPTY(SM0->M0_INSC)
	   oPrint:Say(350,1800,"INSCR. EST.: "+Alltrim(Transform(SM0->M0_INSC,"@R 999.999.999.9999")),oFont07n,,CLR_BLACK)  
   ENDIF
   
   oPrint:Say(400,1310,"NATUREZA DA OPERAÇÃO: ",oFont07n,,CLR_BLACK)
   oPrint:Say(450,1310,"DATA DE EMISSÃO: ",oFont07n,,CLR_BLACK)  

   //Destinatario                                                
   oPrint:Say(600,1060,"DESTINATÁRIO",oFont10n,,CLR_BLACK)  
   oPrint:Say(700,180,"NOME: ",oFont07n,,CLR_BLACK)
   oPrint:Say(750,180,"ENDEREÇO: ",oFont07n,,CLR_BLACK)
   oPrint:Say(750,1250,"CEP: ",oFont07n,,CLR_BLACK)
   oPrint:Say(800,180,"MUNICÍPIO: ",oFont07n,,CLR_BLACK)
   oPrint:Say(800,1250,"UF: ",oFont07n,,CLR_BLACK)
   oPrint:Say(850,180,"CNPJ: ",oFont07n,,CLR_BLACK)
   
   IF !EMPTY(SQL->A1_CGC)
   		oPrint:Say(850,1250,"INSCRIÇÃO ESTADUAL: ",oFont07n,,CLR_BLACK)
   ENDIF
   
   oPrint:Say(900,180,"VENC.",oFont07n,,CLR_BLACK)  

   //Serviços
   oPrint:Say(1040,150,"QUANT.",oFont07n,,CLR_BLACK)
   oPrint:Say(1040,400,"UNID.",oFont07n,,CLR_BLACK)
   oPrint:Say(1040,880,"DESCRIÇÃO DOS SERVIÇOS",oFont07n,,CLR_BLACK)
   oPrint:Say(1040,1600,"PREÇO UNITÁRIO",oFont07n,,CLR_BLACK)
   oPrint:Say(1040,1965,"PREÇO TOTAL",oFont07n,,CLR_BLACK)   
   oPrint:Say(3100,1700,"VALOR R$",oFont07n,,CLR_BLACK)   
   oPrint:Say(3200,1440,"VALOR TOTAL DA FATURA R$",oFont07n,,CLR_BLACK) //RRP - 21/02/2013 - Acerto ao imprimir PDF.  

End Sequence                                          

Return  

*-------------------------------------*
Static Function ReportDetail(oPrint)   
*-------------------------------------*   
Local cMenFixo01   := ""  
Local cMsgCircuito := "" 
Local cPedido      := ""

Local cCli, cDoc, cLojaCli, nBTotal, cSer, cTipoCli
Local nQtdItens    := 0
Local cFil         := xFilial("SD2")

Private nPagina    := 1
Private nLinha     := 1080  
Private nTotal     := 0
Private aForImp	   := SEPARA(AllTrim(GetMV("MV_P_00003",.F.,)),"/",.F.)

   	dbSelectArea("SQL")
   	dbGoTop()
   	
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

		cCli	:= SQL->F2_CLIENTE
		cLojaCli:= SQL->F2_LOJA
		cTipoCli:= SQL->A1_TIPO
		nBTotal	:= SQL->F2_VALBRUT    
		cDoc	:= SQL->F2_DOC 
		cSer 	:= SQL->F2_SERIE
		cPedido	:= SQL->D2_PEDIDO

      SC6->(DbSetOrder(2))                
      If SC6->(dbSeek(xFilial("SC6")+SQL->D2_COD+SQL->D2_PEDIDO+SQL->D2_ITEMPV))               
         cMsgCircuito:= Alltrim(SQL->D2_COD)+" "+Alltrim(SC6->C6_DESCRI)
         nLinha+=40 

         oPrint:Say(nLinha,115,Transform(SC6->C6_QTDVEN,"@E 99999999.9999"),oFont08,,CLR_BLACK)    
         oPrint:Say(nLinha,600,Substr(Alltrim(cMsgCircuito),1,66),oFont07,,CLR_BLACK)  
         oPrint:Say(nLinha,1575,Transform(SC6->C6_PRCVEN,"@E 999,999,999,999.99"),oFont07,,CLR_BLACK)           
         oPrint:Say(nLinha,1960,Transform(SC6->C6_VALOR,"@E 999,999,999,999.99"),oFont07,,CLR_BLACK)

        If Len(Alltrim(cMsgCircuito)) > 66
			nLinha+=30 
			oPrint:Say(nLinha,600,Substr(Alltrim(cMsgCircuito),67,66),oFont07,,CLR_BLACK) 
        EndIf
		nLinha+=60      
        nLinha := ChkLinha(@nLinha)
      EndIf  
      oPrint:Say(3350,2100,"Pagina "+(Alltrim(str(nPagina)))+"/"+(Alltrim(str(nTOTAL))),oFont5,,CLR_BLACK) 
      

		IncProc("Imprimindo...")
		SQL->(DbSkip())	    

		//RRP - 06/02/2015 - Novo tratamento para impressão da Lei da Transparência e Impostos
		If cDoc+cSer <> SQL->F2_DOC+SQL->F2_SERIE .OR. SQL->(Eof())

			cMenFixo01:= ""
			If cTipoCli == "F"
				SF2->(DbSetOrder(1))
			 	If SF2->(DbSeek(xFilial("SF2")+cDoc+cSer+cCli+cLojaCli))
					If (SF2->(FieldPos("F2_TOTIMP")) > 0)
						If SF2->F2_TOTIMP > 0
						 	cMenFixo01   += " Valor Aproximado dos Tributos: R$ "+Alltrim(Transform(SF2->F2_TOTIMP,"@E 999,999,999,999.99"))+" ("+Alltrim(Transform((SF2->F2_TOTIMP/SF2->F2_VALBRUT)*100,"@E 999,999,999,999.99"))+"%) Fonte: IBPT."
			    		EndIf
			   		EndiF
				EndIf
			EndIf
			//Chamada para preencher a mensagem da nota no corpo.
			MenNota(@nLinha,cPedido,CMENFIXO01)
			
			//Impressão dos impostos caso necessário
			ImpImpos(@nLinha, cCli, cDoc, cLojaCli,nBTotal, cSer)
			
			oPrint:EndPage()
			//Nova Nota
			If SQL->(!Eof())
				oPrint:StartPage() 
				oPrint:SetPortrait()
				oPrint:SetpaperSize(9)
				BoxGeral(oPrint) 
				ReportHeader(oPrint)
				ImpCapa()
				nLinha	:= 1080
			EndIf		
		EndIf
		
	EndDo

//Fecha o arquivo
SQL->(dbCloseArea())

Return  

*--------------------------------*
 Static Function BoxGeral(oPrint)   
*--------------------------------*
Local L:= 1420
Private oPen := TPen():New(,7,CLR_BLACK) //,oPrint) TLM - 29/05/2015 Apos atualização o função TPen() passou a utizar a seguinte estrutura oPen := TPen():New(,7,CLR_BLACK) caso contrario gera erro.  

Begin Sequence 
                                                  
   oPrint:Box(155,90,530,1250)    //Logo  
   oPrint:Box(155,1270,530,2250)   //Numero nota  
                                          
   oPrint:Box(570,90,970,2250)     //Destinatário
   oPrint:Box(1010,90,3050,2250)    //Itens
   oPrint:Box(3150,1880,3050,2250)    //valor
   oPrint:Box(3250,1880,3150,2250)    //valor total da fatura
                                            
   oPrint:Line(1080,90,1080,2250)   //Linha destinatário

   oPrint:Line(1010,320,3050,320)   //Coluna 1                        
   oPrint:Line(1010,570,3050,570)   //Coluna 2  
   oPrint:Line(1010,1550,3050,1550)   //Coluna 3  
   oPrint:Line(1010,1880,3050,1880)   //Coluna 4  
     
End Sequence

Return

*--------------------------*
 Static Function ImpCapa() 
*--------------------------*
    
	oPrint:Say(170,1910,Alltrim(SQL->F2_DOC),oFont10n,,CLR_BLACK)
      
 	SF3->(DbSetOrder(6))                
  	SF3->(dbSeek(xFilial("SF3")+SQL->F2_DOC+SQL->F2_SERIE)) 
        
    dbSelectArea("SF4")
    SF4->(DbSetOrder(1))
    SF4->(dbSeek(xFilial("SF4")+SQL->D2_TES))
    oPrint:Say(400,1700,"SERVIÇOS",oFont07,,CLR_BLACK) 
    //oPrint:Say(450,1600,Substr(DtoC(SQL->F2_EMISSAO),1,6)+"20"+Substr(DtoC(SQL->F2_EMISSAO),7,2),oFont07,,CLR_BLACK) - RRP - 19/02/2013 - Acerto da impressão
    oPrint:Say(450,1600,DtoC(SQL->F2_EMISSAO),oFont07,,CLR_BLACK) 
    oPrint:Say(700,300,Alltrim(SQL->A1_NOME),oFont07,,CLR_BLACK)                
    oPrint:Say(750,370,Alltrim(SQL->A1_END),oFont07,,CLR_BLACK)
    oPrint:Say(750,1400,Alltrim(SQL->A1_CEP),oFont07,,CLR_BLACK)
    oPrint:Say(800,365,Alltrim(SQL->A1_MUN),oFont07,,CLR_BLACK)
    oPrint:Say(800,1340,Alltrim(SQL->A1_EST),oFont07,,CLR_BLACK)
	//oPrint:Say(900,290,Substr(DtoC(SQL->E1_VENCREA),1,6)+"20"+Substr(DtoC(SQL->E1_VENCREA),7,2),oFont07,,CLR_BLACK) - RRP - 19/02/2013 - Acerto da impressão 
	oPrint:Say(900,290,DtoC(SQL->E1_VENCREA),oFont07,,CLR_BLACK) 
    
	If !EMPTY(SQL->A1_CGC)    
    	If Len(SQL->A1_CGC) == 14
    		oPrint:Say(850,290,Transform(Alltrim(SQL->A1_CGC),"@R 99.999.999/9999-99"),oFont07,,CLR_BLACK)
	    Else 
    		oPrint:Say(850,290,Transform(Alltrim(SQL->A1_CGC),"@R 999.999.999-99"),oFont07,,CLR_BLACK)
	    EndIf
    EndIf
    
    oPrint:Say(850,1600,Alltrim(SQL->A1_INSCR),oFont07,,CLR_BLACK) 
    
    //VALORES DO FINAL DA FATURA
    oPrint:Say(3100,1960,Transform(SQL->F2_VALBRUT,"@E 999,999,999,999.99"),oFont07,,CLR_BLACK) 
    oPrint:Say(3200,1960,Transform(SQL->F2_VALBRUT,"@E 999,999,999,999.99"),oFont07,,CLR_BLACK) 
    
    //MENSAGEM DO FINAL DA NOTA 
    /*
    PI 903
	valor de referência do Desconto-Padrão (remuneração da
	Agência -Item 1.11 das Normas-Padrão da Atividade Publicitária):
	Agência XXXXXXX: R$ 1,000.00
	*/
    oPrint:Say(2800,600,"PI "+Alltrim(SubStr(Alltrim(SQL->C5_P_PI),1,60)),oFont5,,CLR_BLACK)//RRP - 05/02/2016 - Campo alterado o tamanho para 80. Chamado 031967.
	oPrint:Say(2850,600,Alltrim(SubStr(Alltrim(SQL->C5_P_PI),61,20)),oFont5,,CLR_BLACK)    
    //oPrint:Say(2850,600,"valor de referência do Desconto-Padrão (remuneração da",oFont5,,CLR_BLACK)   JSS - Removido pela solicitação do chamdo :009445          
    //oPrint:Say(2900,600,"Agência-Item 1.11 das Normas-Padrão da Atividade Publicitária)",oFont5,,CLR_BLACK)  JSS - Removido pela solicitação do chamdo :009445  
    oPrint:Say(2900,600,"Agência: "+Alltrim(SQL->C5_P_AG)+"     R$ "+Alltrim(Transform(SQL->C5_P_COMIS,"@E 99,999,999,999.99")),oFont5,,CLR_BLACK)
    //RRP - 04/12/2012 - Inclusão do texto abaixo conforme chamado 008514
    oPrint:Say(2950,600,"Dispensada de emissão de nota fiscal conforme Lei Complementar",oFont5,,CLR_BLACK)
    oPrint:Say(3000,600,"Nº116 de 31 de julho de 2003.",oFont5,,CLR_BLACK)  
  
Return                                                                                                     

*----------------------------------*             
 Static Function ChkLinha(nRet)
*----------------------------------*
Default nRet := 0

If nRet > 2790   
	oPrint:EndPage()   
 	oPrint:StartPage() 
  	oPrint:SetPortrait()
   	oPrint:SetpaperSize(9)
   	
  	//Molduras externas
    BoxGeral(oPrint)
       	  	
   	//Cria o Cabeçalho do Relatório
   	ReportHeader(oPrint)      
  	ImpCapa() 
	
	nRet := 1080

	nPagina++
	oPrint:Say(3350,2100,"Pagina "+(Alltrim(str(nPagina)))+"/"+(Alltrim(str(nTOTAL))),oFont5,,CLR_BLACK)
EndIf

Return nRet 

*----------------------------------------------------*             
 Static Function MenNota(nLinha,cPedido,CMENFIXO01)
*----------------------------------------------------*  
Local nR := 0

    SC5->(DbSetOrder(1))                
 	If SC5->(dbSeek(xFilial("SC5")+cPedido))            
  		SM4->(DbSetOrder(1))
    	If SM4->(DbSeek(xFilial("SM4")+SC5->C5_MENPAD))
     		oPrint:Say(nLinha,600,Substr(Alltrim(SM4->M4_FORMULA),1,53),oFont07,,CLR_BLACK)  
     		
     		nLinha+=30  
     		nLinha := ChkLinha(@nLinha)
     		
      		oPrint:Say(nLinha,600,Substr(Alltrim(SM4->M4_FORMULA),54,106),oFont07,,CLR_BLACK) //RRP - 04/02/2013 - Acerto para carregar a msg da fórmula corretamente.
     		
     		nLinha+=30 //RRP - 04/02/2013 - Acerto para saltar linha. Chamado 009837.            
            nLinha := ChkLinha(@nLinha)
     	EndIf
     	
     	//RRP - 21/02/2013 - Aumento de caracter por linha - valor anterior 54
     	If !Empty(Alltrim(SC5->C5_MENNOTA))
 	       	If len(Alltrim(SC5->C5_MENNOTA))>67 

	        	nLMenN:=0 //controla a posição da coluna
	        	nPosMenN:=1 //controla a posição de corte da msg

				While !empty(Substr(Alltrim(SC5->C5_MENNOTA),nPosMenN,66)) //valor anterior 53                 		
	            	cMenNota:=Substr(Alltrim(SC5->C5_MENNOTA),nPosMenN,66) //valor anterior 53 
	            	oPrint:Say(nLinha,600,cMenNota,oFont07,,CLR_BLACK)
	            	nLMenN+=15
	            	nPosMenN+=66 //valor anterior 53 
	            	nLinha+=60
	            	nLinha := ChkLinha(@nLinha)
	            EndDo
	   		Else
	        	oPrint:Say(nLinha,600,Substr(Alltrim(SC5->C5_MENNOTA),1,66),oFont07,,CLR_BLACK) 
	        	nLinha+=60    
	        	nLinha := ChkLinha(@nLinha)
	        Endif
        EndIf
        
        //RRP - 28/01/2015 - Inclusão da Mensagem para Lei da Transparencia. Chamado 023986.
		for nR:=1 to len(cMenFixo01)
			nLinha := ChkLinha(@nLinha)
			oPrint:Say(nLinha,600,Substr(Alltrim(cMenFixo01),nR,66),oFont07,,CLR_BLACK)
			nLinha+=60
			nR+=86
		next nR
        
    EndIf    
      

Return

/*
Funcao      : ImpImpos
Parametros  : nLinha,cCli, cDoc, cLojaCli,nBTotal, cSer
Retorno     : Nenhum
Objetivos   : Inclusão dos impostos para as faturas dos clientes contidos no parâmetro MV_P_00003. Chamado 014734.
Autor       : Renato Rezende
Data/Hora   : 28/01/2015
*/   
*--------------------------------*
 Static Function ImpImpos(nLinha,cCli, cDoc, cLojaCli,nBTotal, cSer)
*--------------------------------*
Local lRet			:=.F.
Local nR, nP, nQ	:= 0
Local aAreaSE1		:= {}

//Inclusão dos impostos para as faturas dos clientes contidos no parâmetro MV_P_00003. 
For nR:=1 to Len(aForImp)
	If cCli == aForImp[nR]
		lRet := .T.
	EndIf
Next nR
//RRP - 09/05/2014 - Ajuste para impressão do PCC.
If lRet
	aTp := {{"PI-","PIS",0},;
			{"CF-","COFINS",0},;
			{"CS-","CSLL",0},;
			{"IR-","IR",0}}
	
	aAreaSE1  := SE1->(GetArea())
	nVlPcc := 0
	
	DbSelectArea("SE1")
	SE1->(DbSetOrder(2))
    //Verificando se possui títulos no financeiro
	For nP:=1 to Len(aTp)
		If SE1->(DbSeek(xFilial("SE1")+cCli+cLojaCli+cSer+cDoc+" "+aTp[nP][1])) 
	 		aTp[nP][3] += SE1->E1_VALOR
			nVlPcc += SE1->E1_VALOR 
  		EndIf
	Next nP
	//Ajuste para as novas notas, pois parâmetro MV_BR10925 foi alterado
	If nVlPcc <> 0 .AND. DtoS(SC6->C6_DATFAT) >= "20140509" 
		nLinha := ChkLinha(@nLinha)
		nLinha+=40
  		oPrint:Say(nLinha,600,"IMPOSTOS:",oFont07n,,CLR_BLACK)				
  		nLinha+=40
		For nQ:=1 to Len(aTp)
 			oPrint:Say(nLinha,620,aTp[nQ][2]+": R$ "+Alltrim(Transform(aTp[nQ][3],"@E 999,999,999,999.99")),oFont07,,CLR_BLACK)
			nLinha+=40
		Next nQ 
		oPrint:Say(nLinha,620,"Val.Líq. p/ Retenção: R$ "+Alltrim(Transform((nBTotal)-(nVlPcc),"@E 999,999,999,999.99")),oFont07,,CLR_BLACK)
	EndIf

	RestArea(aAreaSE1)
EndIf

Return  
