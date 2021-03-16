#INCLUDE "RWMAKE.CH"
#include 'topconn.ch'    
#include 'colors.ch'

/*
Funcao      : NS8FAT01
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Emitir Nota de Debito  
Autor     	: Adriane Sayuri Kamiya
Data     	: 13/07/2009 
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 13/03/2012
Módulo      : Faturamento.
*/
                       
*-------------------------*
  User Function NS8FAT02()   
*-------------------------*

IF SM0->M0_CODIGO $ "S8/S9"
   Begin Sequence         
      TelaFiltro()        
   End Sequence
EndIf

Return      

//------------------------------------------------------------------------------------------------------------------------------------------------- 

*---------------------------
Static Function TelaFiltro()   
*---------------------------
Private oDlg                     
Private cNotaDe   := Space(09)
Private cNotaAte  := Space(09) 
Private cSerie    := Space(03)

Begin Sequence
                                                                                                   
   DEFINE MSDIALOG oDlg TITLE OemToAnsi("Emissão Nota de Debito - WDF") FROM 0,0 TO 300,380 OF oMainWnd PIXEL 

      @ 010,012 To 142,178  

      @ 030,023 Say "Nota De:" COLOR CLR_HBLUE, CLR_WHITE
      @ 029,110 Get cNotaDe Size 40,8             
      
      @ 050,023 Say "Nota Ate:" COLOR CLR_HBLUE, CLR_WHITE
      @ 049,110 Get cNotaAte Size 40,8
      
      @ 070,023 Say "Série:" COLOR CLR_HBLUE, CLR_WHITE
      @ 069,110 Get cSerie Size 40,8

      @ 110, 30  Button "_Ok " Size 50,15 ACTION BuscaDados()
      @ 110, 95 Button "_Cancelar    " Size 50,15 ACTION Close(oDlg)
      
                               
   ACTIVATE MSDIALOG oDlg CENTERED

End Sequence

Return               

//------------------------------------------------------------------------------------------------------------------------------------------------- 
                  
*----------------------------------------------------------
Static Function BuscaDados()
*----------------------------------------------------------  

Private cNomeArquivo := ""         

Begin Sequence
                    
   If !Empty(cNotaDe) .Or. !Empty(cNotaAte)
      MontaQuery()
      SQL->(dbGoTop())
   Else
      MsgStop("Verifique os parâmetros preenchidos!","Atenção!")         
   EndIf                                                      
   
   If SQL->(!EoF()) 
      CriaLayout("SQL")
   Else
      Alert("Não foram encontrados dados de acordo com o filtro selecionado. Por favor, verifique o filtro!")
   EndIf
   
End Sequence

Return                    
      
//------------------------------------------------------------------------------------------------------------------------------------------------- 
                  
*---------------------------
Static Function MontaQuery()   
*---------------------------   

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

aStruSF2 :={}
aStruSD2 :={}
aStruSF2:= SF2->(dbStruct())
aStruSD2:= SD2->(dbStruct())            
   
cQuery := "SELECT F2_DOC,F2_SERIE,F2_EMISSAO,F2_FILIAL,F2_CLIENTE,F2_LOJA, "+Chr(10)+CHR(13)
cQuery += "F2_VALMERC,F2_VALBRUT,D2_COD, D2_PRUNIT ,D2_PEDIDO, A1_COD, A1_LOJA, A1_NOME,"+Chr(10)+CHR(13)
cQuery += "A1_P_INV01,A1_P_INV02,A1_P_INV03,A1_P_INV04, B1_DESC, C5_NUM, C5_P_REFNB, C5_TXMOEDA" +Chr(10)+CHR(13)
cQuery += "FROM "+RetSqlName("SF2")+" SF2, "+RetSqlName("SA1")+" SA1,"+RetSqlName("SD2")+ " SD2 ,"+RetSqlName("SB1")+ " SB1 ,"+RetSqlName("SC5")+ " SC5    WHERE "+Chr(10)
cQuery += "SF2.F2_FILIAL = '"+xFilial("SF2")+"' AND SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND "+Chr(10)
cQuery += "SF2.F2_FILIAL = '"+xFilial("SF2")+" ' AND  SB1.B1_FILIAL = '"+xFilial("SB1")+" 'AND  SC5.C5_FILIAL = '"+xFilial("SC5")+" 'AND " +Chr(10)
cQuery += "SF2.F2_DOC BETWEEN '"+cNotaDe+"' AND '"+cNotaAte+"' AND "+Chr(10)
cQuery += "SF2.F2_SERIE = '"+cSerie+"' AND "+Chr(10)
cQuery += "SF2.F2_DOC+SF2.F2_SERIE = SD2.D2_DOC+SD2.D2_SERIE AND SF2.F2_CLIENTE+SF2.F2_LOJA = SA1.A1_COD+SA1.A1_LOJA AND SD2.D2_COD = SB1.B1_COD AND SD2.D2_PEDIDO = SC5.C5_NUM AND "+Chr(10)
cQuery += "SF2.D_E_L_E_T_ <> '*' AND SD2.D_E_L_E_T_ <> '*' AND SA1.D_E_L_E_T_ <> '*' AND SB1.D_E_L_E_T_ <> '*' AND SC5.D_E_L_E_T_ <> '*'"+Chr(10)
cQuery += "ORDER BY SF2.F2_DOC,SF2.F2_SERIE"

TCQuery cQuery ALIAS "SQL" NEW

TCSetField("SQL","F2_EMISSAO","D",08,0)

For nX := 1 To Len(aStruSF2)
    If aStruSF2[nX,2]<>"C"
 	    TcSetField("SQL",aStruSF2[nX,1],aStruSF2[nX,2],aStruSF2[nX,3],aStruSF2[nX,4])
    EndIf
Next nX

For nX := 1 To Len(aStruSD2)
    If aStruSD2[nX,2]<>"C"
	    TcSetField("SQL",aStruSD2[nX,1],aStruSD2[nX,2],aStruSD2[nX,3],aStruSD2[nX,4])
    EndIf
Next nX

Return 
                        
//------------------------------------------------------------------------------------------------------------------------------------------------- 
                  
*---------------------------------------
Static Function CriaLayout(cNomeArquivo)   
*--------------------------------------- 
              
//Declara a variável objeto do relatório
Private oPrint

//Cria os objetos fontes que serão utilizadoas através do método TFont()                            
Private oFont5      := TFont():New( "Arial",,07,,.F.,,,,,.F. )             // 5        *
Private oFont07     := TFont():New('Courier New',07,09,,.F.,,,,.T.,.F.)    // 07
Private oFont07n    := TFont():New('Courier New',07,09,,.T.,,,,.T.,.F.)    // 07       *
Private oFont07a    := TFont():New( "Arial",,08,,.t.,,,,,.f. )             // 07
Private oFont08     := TFont():New('Courier New',08,10,,.F.,,,,.T.,.F.)    // 08
Private oFont08a    := TFont():New( "Arial",,10,,.t.,,,,,.f. )             // 08
Private oFont08n    := TFont():New('Courier New',08,10,,.T.,,,,.T.,.F.)    // 08
Private oFont10a    := TFont():New( "Arial",,11,,.t.,,,,,.f. )             // 10
Private oFont10     := TFont():New('Tahoma',11,11,,.F.,,,,.T.,.F.)  // 11
Private oFont10n    := TFont():New('Tahoma',11,11,,.T.,,,,.T.,.F.)  // 11    
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
   oPrint:= TMSPrinter():New( "Impressão de Nota de Débito da WDF" )  
      
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
   ReportDetail(oPrint)    
 
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
   
   Close(oDlg)
      
   End Sequence

Return

//-------------------------------------------------------------------------------------------------------------------------------------------------      

*------------------------------------
Static Function ReportHeader(oPrint)   
*------------------------------------   

Begin Sequence 
   
   oPrint:Say(230,220,"WDF SERVIÇOS AEROPORTUÁRIOS LTDA.",oFont11n,,CLR_BLACK)
   oPrint:SayBitmap(200,1400,"\System\lgrls90.jpg",800,210)
   oPrint:Say(280,220,"Rod. Helio Smidt s/n - ASA B - TPS 1",oFont11n,,CLR_BLACK)
   oPrint:Say(330,220,"Guarulhos - São Paulo - Brasil",oFont11n,,CLR_BLACK)     
   oPrint:Say(570,950,"NOTA DE DÉBITO",oFont22,,CLR_BLACK)     

           
End Sequence                                          

Return  

*--------------------------------------------------------
Static Function ReportDetail(oPrint)   
*--------------------------------------------------------    
Local nLin     := 1350                                          
Local nTaxa    := 1  
Local nTotal   := 0
Local nTotalUS := 0

Begin Sequence                                          
   
   dbSelectArea("SQL")
   dbGoTop()   
   cDoc:= SQL->F2_DOC 
   cSer:= SQL->F2_SERIE       
   SM2->(DbSetOrder(1))
   If SM2->(DbSeek(SQL->F2_EMISSAO))
      If !Empty(SM2->M2_MOEDA2)
         nTaxa      := SM2->M2_MOEDA2
       EndIf 
   Else 
      nTaxa := 1
   EndIF   

      oPrint:Say(790,280,"Documento",oFont12a,,CLR_BLACK)
      oPrint:Say(790,530,Alltrim(SQL->F2_DOC),oFont12a,,CLR_BLACK) 
      oPrint:Say(790,930,"Emissão",oFont12a,,CLR_BLACK)
      oPrint:Say(790,1150,DtoC(SQL->F2_EMISSAO),oFont12a,,CLR_BLACK)
      oPrint:Say(790,1640,"Ref. NBR",oFont12a,,CLR_BLACK)
      oPrint:Say(790,1810,SQL->C5_P_REFNB,oFont12a,,CLR_BLACK)   
      
      oPrint:Say(950 ,220,SQL->A1_NOME,oFont12a,,CLR_BLACK)   
      oPrint:Say(1000,220,SQL->A1_P_INV01,oFont12a,,CLR_BLACK)   
      oPrint:Say(1050,220,SQL->A1_P_INV02,oFont12a,,CLR_BLACK)   
      oPrint:Say(1100,220,SQL->A1_P_INV03,oFont12a,,CLR_BLACK)   
      oPrint:Say(1150,220,SQL->A1_P_INV04,oFont12a,,CLR_BLACK)                                
                                                       
      oPrint:Say(1250,490,"Produto",oFont12a,,CLR_BLACK)
      oPrint:Say(1250,1590,"US$",oFont12a,,CLR_BLACK)
      oPrint:Say(1250,2000,"R$",oFont12a,,CLR_BLACK)

      
   
   While SQL->F2_DOC <> '' .And. SQL->(!EOF())
      If cDoc+cSer <> SQL->F2_DOC+SQL->F2_SERIE
         oPrint:EndPage()   
         oPrint:StartPage() 
         oPrint:SetPortrait()
         oPrint:SetpaperSize(9)
         BoxGeral(oPrint) 
         ReportHeader(oPrint)  
         cDoc:= SQL->F2_DOC 
         cSer:= SQL->F2_SERIE
      EndIf

   
      If cDoc+cSer == SQL->F2_DOC+SQL->F2_SERIE                                                  
         
         oPrint:Say(nLin,220,Alltrim(SQL->B1_DESC),oFont12a,,CLR_BLACK)                            
         oPrint:Say(nLin,1520,Transform(SQL->D2_PRUNIT/ntaxa,"@E 999,999,999,999.99"),oFont12a,,CLR_BLACK)   
         nTotalUS+= SQL->D2_PRUNIT/ntaxa
         oPrint:Say(nLin,1880,Transform(SQL->D2_PRUNIT,"@E 999,999,999,999.99"),oFont12a,,CLR_BLACK)    
         nTotal+=SQL->D2_PRUNIT
         nLin += 70    
         
      EndIf                                        
      
      SQL->(DbSkip())  
      
   EndDo
      
   oPrint:Say(3040,220,"Total",oFont12a,,CLR_BLACK)                                           
   oPrint:Say(3040,1520,Transform(nTotalUS,"@E 999,999,999,999.99"),oFont12a,,CLR_BLACK)                                                      
   oPrint:Say(3040,1890,Transform(nTotal,"@E 999,999,999,999.99"),oFont12a,,CLR_BLACK)
      
   //Fecha o arquivo
  SQL->(dbCloseArea())

End Sequence

Return  
       
//-------------------------------------------------------------------------------------------------------------------------------------------------      

*------------------------------------------------
Static Function BoxGeral(oPrint)   
*------------------------------------------------    

Begin Sequence 

   
   //Caixas Gerais
   oPrint:Box(760,200,860,2200)     //Box Geral 1 
   oPrint:Box(900,200,3100,2200)    //Box Geral 2 
  //oPrint:Box(2350,200,2920,2200)   //Box Geral 3 
 
   //Separação das Colunas      
   oPrint:Line(760, 780 ,860 ,780)   //Coluna 1                        
   oPrint:Line(760, 1420,860 ,1420)    //Coluna 2                            
   oPrint:Line(1230,1450,3100,1450)   //Coluna 3
   oPrint:Line(1230,1825,3100,1825)   //Coluna 4   
   
   oPrint:Line(1230,200,1230,2200)     //Linha  
   oPrint:Line(1310,200,1310,2200)     //Linha  
   oPrint:Line(3020,200,3020,2200)   //Linha  
   
   

End Sequence

Return
