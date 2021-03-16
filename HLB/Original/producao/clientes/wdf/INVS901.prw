#INCLUDE "RWMAKE.CH"
#include 'topconn.ch'    
#include 'colors.ch'
   
/*
Funcao      : INVS901
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Emitir Invoice  
Autor     	: Adriane Sayuri Kamiya
Data     	: 13/04/2009
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 13/03/2012
Módulo      : Faturamento.
*/   
   
                     
*-------------------------*
  User Function INVS901()   
*-------------------------*
     
Private nTaxa     := 0 
Private aInvoice := {}   
Private n15PerServ:= 0     
Private nSalesTx  := 0
Private nAcrescimo:= 0

IF SM0->M0_CODIGO $ "S8/S9/99"
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
Private cDoPedido   := Space(20)
Private dDatade  := AVCTOD("  /  /  ") 
Private dDataAte := AVCTOD("  /  /  ")

Begin Sequence
                                                                                                   
   DEFINE MSDIALOG oDlg TITLE OemToAnsi("Emissão de Invoices - WDF") FROM 0,0 TO 300,380 OF oMainWnd PIXEL 

      @ 010,012 To 142,178  

      @ 030,023 Say "Order:" COLOR CLR_HBLUE, CLR_WHITE
      @ 029,110 Get cDoPedido F3 "SC5WDF"             
      
      @ 050,023 Say "Dt Invoice From:" COLOR CLR_HBLUE, CLR_WHITE
      @ 049,110 Get dDatade Size 40,8 
      
      @ 070,023 Say "Dt Invoice To:" COLOR CLR_HBLUE, CLR_WHITE
      @ 069,110 Get dDataAte Size 40,8

      @ 110, 30  Button "_Ok " Size 50,15 ACTION BuscaDados()
      @ 110, 95 Button "_Close    " Size 50,15 ACTION Close(oDlg)
      
                               
   ACTIVATE MSDIALOG oDlg CENTERED

End Sequence

Return               

//------------------------------------------------------------------------------------------------------------------------------------------------- 
                  
*----------------------------------------------------------
Static Function BuscaDados()
*----------------------------------------------------------  

Private cNomeArquivo := ""         

Begin Sequence
                    
   If cDoPedido <> SPACE(20) .Or. (dDatade <> AVCTOD("  /  /  ") .Or. dDataAte <> AVCTOD("  /  /  ") )
      cNomeArquivo := MontaQuery()
      (cNomeArquivo)->(dbGoTop())
   Else
      MsgStop("Verifique os parâmetros preenchidos!","Atenção!")         
   EndIf                                                      
   
   If cNomeArquivo <> ""      
      If (cNomeArquivo)->(!EoF()) 
         CriaLayout(cNomeArquivo)
      Else
         Alert("Não foram encontrados dados de acordo com o filtro selecionado. Por favor, verifique o filtro!")
      EndIf
   EndIf           
End Sequence

Return                    
      
//------------------------------------------------------------------------------------------------------------------------------------------------- 
                  
*---------------------------
Static Function MontaQuery()   
*---------------------------   

Local cQuery := "" 
Local cNivel      := ""   
Local cArqTrb	  := CriaTrab(,.F.)

Begin Sequence     

   _Datade  := "'"+"20" + Substr(DtoC(dDatade),7,2) + Substr(DtoC(dDatade),4,2) + Substr(DtoC(dDatade),1,2)+"'"
   _DataAte := "'"+"20" + Substr(DtoC(dDataAte),7,2) + Substr(DtoC(dDataAte),4,2) + Substr(DtoC(dDataAte),1,2)+"'"   
   

   cQuery := "SELECT  A.C5_NUM 											 									AS 'NUMPEDIDO'"+Chr(13) 
   cQuery += ",A.C5_FILIAL     											  							   		AS 'FILIAL'"+Chr(13)
   cQuery += ",A.C5_CLIENT      										   							   		AS 'CODCLIENTE'"+Chr(13)
   cQuery += ",A.C5_LOJACLI     										   							   		AS 'LOJACLI'"+Chr(13)
   cQuery += ",A.C5_EMISSAO    										   							   	    	AS 'EMISSAO'"+Chr(13)
   cQuery += ",A.C5_P_REFNB      									  							   	   		AS 'REFERENCE'"+Chr(13)
   cQuery += ",A.C5_P_INVOI      									  							   	   		AS 'INVOICE'"+Chr(13)
   cQuery += ",A.C5_P_REGIS        										  							   		AS 'REGISTRO'"+Chr(13)
   cQuery += ",A.C5_P_TIPO        										  							   		AS 'TYPE'"+Chr(13)
   cQuery += ",A.C5_P_OPERA        										  							   		AS 'OPERADOR'"+Chr(13)
   cQuery += ",A.C5_P_CAPIT        										   							   		AS 'CAPTAIN'"+Chr(13)
   cQuery += ",A.C5_P_CAIRP        										   							   		AS 'CODAIRPORT'"+Chr(13)
   cQuery += ",A.C5_P_AIRPO        										   							   		AS 'DSCAIRPORT'"+Chr(13)
   cQuery += ",A.C5_P_CODFR        										   							   		AS 'CODFR'"+Chr(13)
   cQuery += ",A.C5_P_FR        										   							   		AS 'DSCFR'"+Chr(13)
   cQuery += ",A.C5_P_CTO        										   									AS 'CODTO'"+Chr(13)
   cQuery += ",A.C5_P_TO        										  							        AS 'DSCTO'"+Chr(13)
   cQuery += ",A.C5_P_DTCH                                                                                  AS 'DTARRIVAL'"+Chr(13)      
   cQuery += ",A.C5_P_DTSAI 																				AS 'DTDEPART'"+Chr(13) 
   cQuery += ",A.C5_P_DTINV  																				AS 'DTINVOICE'"+Chr(13) 
   cQuery += ",A.C5_ACRSFIN  																				AS 'ACRSFIN'"+Chr(13) 
   cQuery += ",A.C5_MOEDA  																			    	AS 'MOEDA'"+Chr(13) 
   cQuery += ",B.C6_ITEM         									  										AS 'ITEM'"+Chr(13)
   cQuery += ",B.C6_PRODUTO      									  										AS 'PRODUTO'"+Chr(13)
   cQuery += ",B.C6_DESCRI         																			AS 'DESCPRODUTO'"+Chr(13)
   cQuery += ",D.B1_P_ORDEM																			   		AS 'ORDEM'"+Chr(13)
   cQuery += ",B.C6_P_CODE																			   		AS 'CODE'"+Chr(13)
   cQuery += ",B.C6_QTDVEN																					AS 'QUANTIDADE'"+Chr(13)
   cQuery += ",B.C6_VALOR																			   		AS 'VALOR'"+Chr(13)
   cQuery += ",B.C6_P_V3RD																			   		AS 'V3RD'"+Chr(13)
   cQuery += ",B.C6_NOTA																			   		AS 'NOTA'"+Chr(13)   
   cQuery += ",B.C6_SERIE																			   		AS 'SERIE'"+Chr(13)   
   cQuery += ",C.A1_NOME																			   		AS 'NOMECLI'"+Chr(13)
   cQuery += ",C.A1_P_INV01																			   		AS 'DSCINV01'"+Chr(13)
   cQuery += ",C.A1_P_INV02																			   		AS 'DSCINV02'"+Chr(13)
   cQuery += ",C.A1_P_INV03																			   		AS 'DSCINV03'"+Chr(13)
   cQuery += ",C.A1_P_INV04																			   		AS 'DSCINV04'"+Chr(13)   
   cQuery += "FROM "+RetSqlName("SC5")+" A, "+Chr(13)
   cQuery += RetSqlName("SC6")+" B, "+Chr(13)
   cQuery += RetSqlName("SA1")+" C, "+Chr(13)                                                                            
   cQuery += RetSqlName("SB1")+" D "+Chr(13)                                                                            
   cQuery += "WHERE "+Chr(13) 
   cQuery += "A.D_E_L_E_T_ <> '*'"+Chr(13) 
   cQuery += "AND B.D_E_L_E_T_ <> '*'"+Chr(13) 
   cQuery += "AND D.D_E_L_E_T_ <> '*'"+Chr(13) 
   cQuery += "AND A.C5_NUM = B.C6_NUM"+Chr(13)
   cQuery += "AND A.C5_FILIAL = B.C6_FILIAL"+Chr(13) 
   cQuery += "AND A.C5_CLIENT = C.A1_COD"+Chr(13) 
   cQuery += "AND B.C6_PRODUTO = D.B1_COD"+Chr(13)
   

   
   If !Empty(cDoPedido)
      cQuery += "AND A.C5_NUM = '" + cDoPedido + "'" +Chr(13)
   Else  
      cQuery += "AND A.C5_P_DTINV BETWEEN "+ _Datade + " AND "+ _DataAte +" "+Chr(13)
   EndIf
   cQuery += "ORDER BY A.C5_NUM+B.C6_P_ORDEM"
      
   cQuery := ChangeQuery(cQuery)
   DbUseArea(.T.,"TopConn",TCGenQry(,,cQuery),cArqTrb,.F.,.F.)
      
End Sequence

Return (cArqTrb) 
                        
//------------------------------------------------------------------------------------------------------------------------------------------------- 
                  
*---------------------------------------
Static Function CriaLayout(cNomeArquivo)   
*--------------------------------------- 
              
//Declara a variável objeto do relatório
Private oPrint
              
//Cria os objetos fontes que serão utilizadoas através do método TFont()                            
Private oFont5      := TFont():New( "Arial",,07,,.F.,,,,,.F. )             // 5
Private oFont07     := TFont():New('Courier New',07,09,,.F.,,,,.T.,.F.)    // 07
Private oFont07n    := TFont():New('Courier New',07,09,,.T.,,,,.T.,.F.)    // 07
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
Private oFont20t    := TFont():New('Tahoma',20,20,,.T.,,,,.T.,.F.)  // 20
Private oFont20     := TFont():New('Arial',20,20,,.F.,,,,.T.,.F.)   // 20
Private oFont22     := TFont():New('Arial',22,20,,.T.,,,,.T.,.F.)   // 20
Private nPagina     := 1

Begin Sequence
   
   //Cria objeto TMSPrinter()               
   oPrint:= TMSPrinter():New( "Invoice - WDF" )  
      
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
   ReportDetail(oPrint,cNomeArquivo,nPagina)    
 
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
   
   //Logo 
   oPrint:SayBitmap(100,900,"\System\lgrls90.jpg",800,210)
                 
End Sequence   

Return  

//-------------------------------------------------------------------------------------------------------------------------------------------------      

*--------------------------------------------------------
Static Function ReportDetail(oPrint,cNomeArquivo,nPagina)   
*--------------------------------------------------------    
Local I :=0      
Local aDescrServ:= { "BASIC HANDLING FEE", "LAVATORY SERVICE", "POTABLE WATER", "G.P.U.", "STAIRS", "BELT LOADER", "PUSH BACK", "OTHER", "OTHER",       ;
                     "LANDING FEE", "APRON CHARGE","PARKING AREA/OFF-APRON CHARGE","PAN/AIR NAVIGATION CHARGE","PAT/VISUAL AND RADIO","ATAERO(50%)",;
                     "CATERING", "RAMP TRANSPORT", "FUEL", "OVERFLIGHT PERMIT","LANDING PERMIT / ARPT AUTHORITIES", ;
                     "CREW TRANSPORT", "PAX TRANSPORT", "COMMUNICATIONS", "NEWSPAPERS", "LAUNDRY", "DISHES WASHING", "ICE", "OTHER", "OTHER","OTHER"}
   
Private cPedido   := "" 
Private cDtInvoice:= ""
Private cOperador := ""
Private cInvoice  := ""
Private nSubThird := 0
Private nAgentFee := 0
Private n3rdPlus  := 0
Private nTotal    := 0
Private nGrandTt  := 0  
Private nTotalR   := 0
Private cDtInv    :=""
Private cNota     :=""
Private cSerie    :=""
Private cCodCli   :=""
Private cLojaCli  :="" 
Private nTotalS   := 0

I:= 990


Begin Sequence                         
   
   dbSelectArea(cNomeArquivo)
   dbGoTop()   
   cPedido:= (cNomeArquivo)->NUMPEDIDO
   
    If cPedido == (cNomeArquivo)->NUMPEDIDO 
      //If Empty((cNomeArquivo)->NOTA)
      //   MsgStop("Pedido "+cPedido+" não faturado.","Atenção!")
      //   Break
      //Else
         SD2->(DbSetOrder(8))
         If SD2->(DbSeek(xFilial("SD2")+cPedido))
            cDtEmiss   := SD2->D2_EMISSAO
         End If 
         
         cEmissao   := Substr((cNomeArquivo)->EMISSAO,7,2)+"/"+Substr((cNomeArquivo)->EMISSAO,5,2)+"/"+Substr((cNomeArquivo)->EMISSAO,1,4)
         
         cOperador  := (cNomeArquivo)->OPERADOR  
         cRegistro  := (cNomeArquivo)->REGISTRO
         cReference := (cNomeArquivo)->REFERENCE
         cType      := (cNomeArquivo)->TYPE
         cDtInvoice := Substr((cNomeArquivo)->DTINVOICE,7,2)+"/"+Substr((cNomeArquivo)->DTINVOICE,5,2)+"/"+Substr((cNomeArquivo)->DTINVOICE,1,4)
         cDtInv     := (cNomeArquivo)->DTINVOICE  
         cCaptain   := (cNomeArquivo)->CAPTAIN  
         cCodAirpt  := (cNomeArquivo)->CODAIRPORT
         cDescAirp  := Alltrim((cNomeArquivo)->DSCAIRPORT)
         cDtArrival := Substr((cNomeArquivo)->DTARRIVAL,7,2)+"/"+Substr((cNomeArquivo)->DTARRIVAL,5,2)+"/"+Substr((cNomeArquivo)->DTARRIVAL,1,4)
         cCodFrom   := (cNomeArquivo)->CODFR
         cFrom      := Alltrim((cNomeArquivo)->DSCFR)
         cDeparture := Substr((cNomeArquivo)->DTDEPART,7,2)+"/"+Substr((cNomeArquivo)->DTDEPART,5,2)+"/"+Substr((cNomeArquivo)->DTDEPART,1,4)
         cCodTo     := (cNomeArquivo)->CODTO
         cTo        := Alltrim((cNomeArquivo)->DSCTO)
         cInvoice   := (cNomeArquivo)->INVOICE
         cNomeCli   := (cNomeArquivo)->NOMECLI
         cDescInv01 := (cNomeArquivo)->DSCINV01  
         cDescInv02 := (cNomeArquivo)->DSCINV02
         cDescInv03 := (cNomeArquivo)->DSCINV03
         cDescInv04 := (cNomeArquivo)->DSCINV04
         cNota      := (cNomeArquivo)->NOTA
         cSerie     := (cNomeArquivo)->SERIE
         cCodCli    := (cNomeArquivo)->CODCLIENTE
         cLojaCli   := (cNomeArquivo)->LOJACLI
         nAcrescimo := (cNomeArquivo)->ACRSFIN         
         nMoeda     := (cNomeArquivo)->MOEDA
                  

       //Cabeçalho                                         
         oPrint:Say(320,1268,"SBGR /   ",oFont11n,,CLR_BLACK)
         oPrint:Say(320,1450,Substr(cPedido,3,4)+ " /" + Substr(cEmissao,7,4),oFont11n,,CLR_BLACK)  
    
         oPrint:Say(360,948,"CHARGE FORM",oFont20t,,CLR_BLACK)       
 
         oPrint:Say(480,223,"OPERATOR:",oFont12a,,CLR_BLACK)
         oPrint:Say(480,490,cOperador,oFont12,,CLR_BLACK)
      
         oPrint:Say(480,1305,"REGISTRATION:",oFont12a,,CLR_BLACK)
         oPrint:Say(480,1660,cRegistro,oFont12,,CLR_BLACK)
      
         oPrint:Say(530,223,"REFERENCE NBR:",oFont12a,,CLR_BLACK)                
         oPrint:Say(530,610,cReference,oFont12,,CLR_BLACK)
     
         oPrint:Say(530,1305,"AIRCRAFT TYPE:",oFont12a,,CLR_BLACK)                
         oPrint:Say(530,1670,cType,oFont12,,CLR_BLACK)
         
         oPrint:Say(580,223,"DATE OF INVOICE:",oFont12a,,CLR_BLACK)  
         oPrint:Say(580,620,DataFormat(cEmissao,.T.),oFont12,,CLR_BLACK)
      
         oPrint:Say(580,1305,"CAPTAIN:",oFont12a,,CLR_BLACK)  
         oPrint:Say(580,1520,cCaptain,oFont12,,CLR_BLACK)
        
         oPrint:Say(650,223,"(LANDING DETAILS)",oFont12a,,CLR_BLACK)        
   
         oPrint:Say(650,1305,"AIRPORT:",oFont12a,,CLR_BLACK)                
         oPrint:Say(650,1520,cDescAirp+" - "+cCodAirpt,oFont12,,CLR_BLACK)
      
         oPrint:Say(700,223,"ARRIVAL DATE:",oFont12a,,CLR_BLACK)            
         oPrint:Say(700,550,DataFormat(cDtArrival,.T.),oFont12,,CLR_BLACK)
   
         oPrint:Say(700,1305,"FROM:",oFont12a,,CLR_BLACK)                   
         oPrint:Say(700,1470,cFrom +" - "+ cCodFrom,oFont12,,CLR_BLACK)
                                                     
         oPrint:Say(790,223,"DEPARTURE DATE:",oFont12a,,CLR_BLACK)          
         oPrint:Say(790,630,DataFormat(cDeparture,.T.),oFont12,,CLR_BLACK)
   
         oPrint:Say(790,1305,"TO:",oFont12a,,CLR_BLACK)  
         oPrint:Say(790,1390,cTo+" - "+cCodTo,oFont12,,CLR_BLACK)
      //EndIf
   EndIf   
      
   //While !(cNomeArquivo)->(Eof())
      If Alltrim(cPedido) <> Alltrim((cNomeArquivo)->NUMPEDIDO)
         cPedido := (cNomeArquivo)->NUMPEDIDO
      //   If Empty((cNomeArquivo)->NOTA)
      //      MsgStop("Pedido "+cPedido+" não faturado.","Atenção!")
      //      Break
      //   Else
            //Nova Página
            oPrint:EndPage()   
            oPrint:StartPage() 
            oPrint:SetPortrait()
            oPrint:SetpaperSize(9)
            BoxGeral(oPrint) 
            ReportHeader(oPrint)       
            nPagina++    
            I := 990    
            j := 0   
            nSubThird := 0
            nAgentFee := 0
            n15PerServ:= 0 
            n3rdPlus  := 0
            nTotal    := 0
            nSalesTx  := 0
            nGrandTt  := 0
            nTaxa     := 0
            nTotalR   := 0               
            //Informações capa pedido
            cEmissao   := Substr((cNomeArquivo)->EMISSAO,7,2)+"/"+Substr((cNomeArquivo)->EMISSAO,5,2)+"/"+Substr((cNomeArquivo)->EMISSAO,1,4)
            cOperador  := (cNomeArquivo)->OPERADOR  
            cRegistro  := (cNomeArquivo)->REGISTRO
            cReference := (cNomeArquivo)->REFERENCE
            cType      := (cNomeArquivo)->TYPE
            cDtInvoice := Substr((cNomeArquivo)->DTINVOICE,7,2)+"/"+Substr((cNomeArquivo)->DTINVOICE,5,2)+"/"+Substr((cNomeArquivo)->DTINVOICE,1,4)
            cCaptain   := (cNomeArquivo)->CAPTAIN    
            cCodAirpt  := (cNomeArquivo)->CODAIRPORT 
            cDescAirp  := Alltrim((cNomeArquivo)->DSCAIRPORT)
            cDtArrival := Substr((cNomeArquivo)->DTARRIVAL,7,2)+"/"+Substr((cNomeArquivo)->DTARRIVAL,5,2)+"/"+Substr((cNomeArquivo)->DTARRIVAL,1,4)
            cCodFrom   := (cNomeArquivo)->CODFR    
            cCodTo     := (cNomeArquivo)->CODTO
            cFrom      := Alltrim((cNomeArquivo)->DSCFR)
            cTo        := Alltrim((cNomeArquivo)->DSCTO)
            cDeparture := Substr((cNomeArquivo)->DTDEPART,7,2)+"/"+Substr((cNomeArquivo)->DTDEPART,5,2)+"/"+Substr((cNomeArquivo)->DTDEPART,1,4)
            cInvoice   := (cNomeArquivo)->INVOICE
            cNomeCli   := (cNomeArquivo)->NOMECLI
            cDescInv01 := (cNomeArquivo)->DSCINV01  
            cDescInv02 := (cNomeArquivo)->DSCINV02
            cDescInv03 := (cNomeArquivo)->DSCINV03
            cDescInv04 := (cNomeArquivo)->DSCINV04
            cNota      := (cNomeArquivo)->NOTA
            cSerie     := (cNomeArquivo)->SERIE
            cCodCli    := (cNomeArquivo)->CODCLIENTE
            cLojaCli   := (cNomeArquivo)->LOJACLI
         
         
            //Cabeçalho                                         
            oPrint:Say(320,1368,"SBGR /      ",oFont11n,,CLR_BLACK)
            oPrint:Say(320,180,Substr(cPedido,3,4) + " /" + Substr(cEmissao,7,4),oFont11n,,CLR_BLACK)  
 
            oPrint:Say(360,1048,"CHARGE FORM",oFont20t,,CLR_BLACK)       
        
            oPrint:Say(480,223,"OPERATOR:",oFont12a,,CLR_BLACK)
            oPrint:Say(480,480,cOperador,oFont12,,CLR_BLACK)
      
            oPrint:Say(480,1305,"REGISTRATION:",oFont12a,,CLR_BLACK)
            oPrint:Say(480,1620,cRegistro,oFont12,,CLR_BLACK)
      
            oPrint:Say(530,223,"REFERENCE NBR:",oFont12a,,CLR_BLACK)                
            oPrint:Say(530,580,cReference,oFont12,,CLR_BLACK)
     
            oPrint:Say(530,1305,"AIRCRAFT TYPE:",oFont12a,,CLR_BLACK)                
            oPrint:Say(530,1640,cType,oFont12,,CLR_BLACK)
         
            oPrint:Say(580,223,"DATE OF INVOICE:",oFont12a,,CLR_BLACK)  
            oPrint:Say(580,590,DataFormat(cEmissao,.T.),oFont12,,CLR_BLACK)
      
            oPrint:Say(580,1305,"CAPTAIN:",oFont12a,,CLR_BLACK)  
            oPrint:Say(580,1500,cCaptain,oFont12,,CLR_BLACK)
   
            oPrint:Say(650,223,"(LANDING DETAILS)",oFont12a,,CLR_BLACK)        
   
            oPrint:Say(650,1305,"AIRPORT:",oFont12a,,CLR_BLACK)                
            oPrint:Say(650,1500,cDescAirp+" - "+cCodAirpt,oFont12,,CLR_BLACK)
      
            oPrint:Say(700,223,"ARRIVAL DATE:",oFont12a,,CLR_BLACK)            
            oPrint:Say(700,520,DataFormat(cDtArrival,.T.),oFont12,,CLR_BLACK)
   
            oPrint:Say(700,1305,"FROM:",oFont12a,,CLR_BLACK)                   
            oPrint:Say(700,1460,cFrom+" - "+cCodFrom,oFont12,,CLR_BLACK)
                                                     
            oPrint:Say(790,223,"DEPARTURE DATE:",oFont12a,,CLR_BLACK)          
            oPrint:Say(790,610,DataFormat(cDeparture,.T.),oFont12,,CLR_BLACK)
   
            oPrint:Say(790,1305,"TO:",oFont12a,,CLR_BLACK)  
            oPrint:Say(790,1400,cTo+" - "+cCodTo,oFont12,,CLR_BLACK)
         //EndIf      
      EndIf
      
         //Cabeçalho dos Detalhes
         oPrint:Say(870,310,"DESCRIPTION OF SERVICES",oFont12a,,CLR_HBLUE)
         oPrint:Say(925,370,"GROUND HANDLING",oFont12a,,CLR_HBLUE)
         oPrint:Say(870,980,"SERVICES",oFont12a,,CLR_HBLUE) 
         oPrint:Say(925,970,"RENDERED",oFont12a,,CLR_HBLUE) 
         
         If nMoeda = 2
            oPrint:Say(870,1370,"US$",oFont12a,,CLR_HBLUE) 
         Else 
            oPrint:Say(870,1370,"R$",oFont12a,,CLR_HBLUE)             
         EndIf
         
         oPrint:Say(925,1235,"3rd PARTY FEES",oFont12a,,CLR_HBLUE) 
         
         If nMoeda = 2
            oPrint:Say(870,1730,"US$",oFont12a,,CLR_HBLUE)  
         Else 
            oPrint:Say(870,1730,"R$",oFont12a,,CLR_HBLUE)  
         EndIf             
         
         oPrint:Say(925,1630,"UA SERVICES",oFont12a,,CLR_HBLUE)      
         oPrint:Say(870,1970,"PRODUCT",oFont12a,,CLR_HBLUE)    
         oPrint:Say(925,2023,"CODE",oFont12a,,CLR_HBLUE)

         
         For j:= 1 to len(aDescrServ)
            If J = 1
               oPrint:Say(I,220,"HANDLING SERVICES",oFont10n,,CLR_BLACK) 
               I := I + 45          
            EndIf
            If J = 10
               oPrint:Say(I,220,"AIRPORT / ATC / SERVICES",oFont10n,,CLR_BLACK)
               I := I + 45          
            EndIf
            If J = 21
               oPrint:Say(I,220,"MISCELLANEOUS SERVICES",oFont10n,,CLR_BLACK)
               I := I + 45          
            EndIf   
           
            oPrint:Say(I,220,aDescrServ[j],oFont10,,CLR_BLACK) 
            
            If j = val((cNomeArquivo)->ORDEM)     
               oPrint:Say(I,220,IIF(AT('OTHER', (cNomeArquivo)->PRODUTO) > 0 .and. aDescrServ[j]=='OTHER', aDescrServ[j], aDescrServ[j]) ,oFont10,,CLR_WHITE)
               oPrint:Say(I,220,IIF(AT('OTHER', (cNomeArquivo)->PRODUTO) > 0 .and. aDescrServ[j]=='OTHER', (cNomeArquivo)->DESCPRODUTO, aDescrServ[j]) ,oFont10,,CLR_BLACK) 
               
               AADD(aInvoice, {IIF(AT('OTHER', (cNomeArquivo)->PRODUTO) > 0 .and. aDescrServ[j]=='OTHER', (cNomeArquivo)->DESCPRODUTO, aDescrServ[j]), (cNomeArquivo)->VALOR-(cNomeArquivo)->V3RD})
 		       oPrint:Say(I,900,Str((cNomeArquivo)->QUANTIDADE),oFont10,,CLR_BLACK)
 		       If UPPER(Substr((cNomeArquivo)->PRODUTO,1,3)) == '3RD'
  		          oPrint:Say(I,1210,Transform((cNomeArquivo)->VALOR-(cNomeArquivo)->V3RD,"@E 999,999,999,999.99"),oFont10,,CLR_BLACK)
                  nSubThird +=(cNomeArquivo)->VALOR - (cNomeArquivo)->V3RD 
		          AADD(aInvoice, {aDescrServ[j], (cNomeArquivo)->VALOR})
   		       Else
   		          oPrint:Say(I,1590,Transform((cNomeArquivo)->VALOR,"@E 999,999,999,999.99"),oFont10,,CLR_BLACK)
   		          nAgentFee += (cNomeArquivo)->VALOR   
   		          AADD(aInvoice, {aDescrServ[j], (cNomeArquivo)->VALOR})
               EndIf                            
               
               oPrint:Say(I,2020,(cNomeArquivo)->CODE,oFont10,,CLR_BLACK)
               (cNomeArquivo)->(DbSkip())                                                       
               
            EndIf                                      
            //(cNomeArquivo)->(DbSkip())  
            I := I + 45 
         Next
                                            
         n15PerServ := nSubThird * 0.15
         n3rdPlus   := nSubThird + n15PerServ 
         nTotal     := nAgentFee + n3rdPlus
         nSalesTx   := nTotal * nAcrescimo / 100
         nGrandTt   := nTotal + nSalesTx

         If nMoeda = 2 .AND. !Empty(cNota)
            SM2->(DbSetOrder(1))
               If SM2->(DbSeek(cDtEmiss))
                  If !Empty(SM2->M2_MOEDA2)
                     nTaxa      := SM2->M2_MOEDA2
                  EndIf 
               EndIf
         Else 
            nTaxa := 1
         EndIF                    
         
         //nTotalR    := nGrandTt * nTaxa //alterado conforme solicitação da WDF - MSM 14/12/2011
         nTotalR    := nGrandTt
         nTotalS	:= nGrandTt * nTaxa
         
         I++
         
         oPrint:Say(I,220,"SUB-TOTAL THIRD PARTY",oFont10n,,CLR_BLACK) 
         If nSubThird > 0
            oPrint:Say(I,1210,Transform(nSubThird,"@E 999,999,999,999.99"),oFont10n,,CLR_BLACK)
         EndIf
         I := I + 45
         
         oPrint:Say(I,220,"( 15% ) PERCENTAGE SERVICE CHARGE",oFont10n,,CLR_BLACK)
         If n15PerServ > 0
            oPrint:Say(I,1210,Transform(n15PerServ,"@E 999,999,999,999.99"),oFont10n,,CLR_BLACK)     
         EndIf
         I := I + 45
          
         oPrint:Say(I,220,"TOTAL 3rd PARTY PLUS SERVICE CHARGE",oFont10n,,CLR_BLACK)
         If n3rdPlus > 0
            oPrint:Say(I,1210,Transform(n3rdPlus,"@E 999,999,999,999.99"),oFont10n,,CLR_BLACK)
         EndIf              
         I := I + 45

         oPrint:Say(I,220,"TOTAL AGENT FEES",oFont10n,,CLR_BLACK)  
         oPrint:Say(I,1590,Transform(nAgentFee,"@E 999,999,999,999.99"),oFont10n,,CLR_BLACK)
         I := I + 45                       
   
         oPrint:Say(I,220,"TOTAL",oFont10n,,CLR_BLACK)    
         oPrint:Say(I,1590,Transform(nTotal,"@E 999,999,999,999.99"),oFont10n,,CLR_BLACK)
         I := I + 45            
   
         oPrint:Say(I,220,"SALES TAXES "+Alltrim(Str(nAcrescimo))+"%",oFont10n,,CLR_BLACK)  
         oPrint:Say(I,1590,Transform(nSalesTx,"@E 999,999,999,999.99"),oFont10n,,CLR_BLACK)
         I := I + 45                         
    
         If nMoeda = 2
            oPrint:Say(I,220,"GRAND TOTAL US$",oFont10n,,CLR_BLACK)    
         Else
            oPrint:Say(I,220,"GRAND TOTAL R$",oFont10n,,CLR_BLACK)    
         EndIf                             
         
         oPrint:Say(I,1590,Transform(nGrandTt,"@E 999,999,999,999.99"),oFont10n,,CLR_BLACK)
         I := I + 45                      
         
         If nMoeda = 2
 			oPrint:Say(I,220,"EXCHANGE RATE Ref. "+DataFormat(cEmissao,.T.)+" (R$): " + AllTrim(IIF(nTaxa > 1 ,Str(nTaxa), '###')),oFont10n,,CLR_BLACK)
            //oPrint:Say(I,1590,Transform(nTotalR,"@E 999,999,999,999.99"),oFont10n,,CLR_BLACK) //alterado conforme solicitação da WDF - MSM 14/12/2011
            oPrint:Say(I,1590,Transform(nTotalS,"@E 999,999,999,999.99"),oFont10n,,CLR_BLACK)
         EndIf
         
         If Empty(cNota)
          //  SF2->(DbSetOrder(1))
          //  SF2->(DbGoTop())
          //  If SF2->(DbSeek(xFilial("SF2")+cNota+cSerie+cCodCli+cLojaCli))
          //     If (SM2->M2_MOEDA2 * nGrandTt) <> SF2->F2_VALBRUT 
          //        MsgInfo("Total da Invoice "+ Alltrim(Transform(nTotalR,"@E 999,999,999,999.99"))+" está diferente do total da Nota. "+;
          //        Alltrim(Transform(SF2->F2_VALBRUT,"@E 999,999,999,999.99"))+"."+chr(10)+chr(13)+"Verifique com o Faturamento."  )
          //     EndIf        
          //  EndIf
      //   Else 
            MsgInfo("Atenção!"+chr(10)+chr(13)+"Pedido  "+cPedido+"  não Faturado!")
         EndIf   
         
         I := I + 45
         oPrint:EndPage()   
         oPrint:StartPage() 
         oPrint:SetPortrait()
         oPrint:SetpaperSize(9)
         BoxTotal(oPrint) 
         ReportTotal(oPrint)  

   //(cNomeArquivo)->(DbSkip())

//End 
     
   //Fecha o arquivo
   (cNomeArquivo)->(dbCloseArea())  

End Sequence

Return  
       
//-------------------------------------------------------------------------------------------------------------------------------------------------      

*------------------------------------------------
Static Function BoxGeral(oPrint)   
*------------------------------------------------    
Local L:= 1030
Begin Sequence 

   //Caixas Gerais
   oPrint:Box(860,200,3045,2200)   //Box Geral 6 
   
   //Separação das Colunas                                  
   oPrint:Line(860, 950,2478,950)   //Coluna 1                        
   oPrint:Line(860,1225,3045,1225) //Coluna 2
   oPrint:Line(860,1588,3045,1588) //Coluna 3   
   oPrint:Line(860,1951,3045,1951) //Coluna 3   

   
   oPrint:Line(455,200,455,2200)   //Linha  
   oPrint:Line(460,200,460,2200)   //Linha  

  // oPrint:Line(635,200,635,2200)   //Linha  
  // oPrint:Line(640,200,640,2200)   //Linha  
 //  oPrint:Line(770,200,770,2200)   //Linha  
                                              
//   oPrint:Line(970,200,978,2200)   //Linha  
                           
   For h:=1 to 63
      oPrint:Line(L,200,L,2200)   //Linha  
      L:= L +45
      h++
   Next                                    
   
     oPrint:Line(2475,200,2475,2200)   //Linha  
     oPrint:Line(2476,200,2476,2200)   //Linha  
     oPrint:Line(2477,200,2477,2200)   //Linha  
     L:= 2478 
   
    For h:=1 to 24
      oPrint:Line(L,200,L,2200)   //Linha  
      L:= L +45
      h++
   Next   
           

End Sequence

Return

 
*------------------------------------
Static Function ReportTotal(oPrint)   
*------------------------------------   
Local lin := 980

Begin Sequence 
   
   oPrint:Say(130,220,"WDF SERVIÇOS AEROPORTUÁRIOS LTDA.",oFont11n,,CLR_BLACK)
   oPrint:SayBitmap(100,1400,"\System\lgrls90.jpg",800,210)
   oPrint:Say(180,220,"Rod. Helio Smidt s/n - ASA B - TPS 1",oFont11n,,CLR_BLACK)
   oPrint:Say(230,220,"Guarulhos - São Paulo - Brasil",oFont11n,,CLR_BLACK)     
   oPrint:Say(410,250,"Invoice Number",oFont12a,,CLR_BLACK)
   oPrint:Say(410,590,cInvoice,oFont12a,,CLR_BLACK) 
   oPrint:Say(410,950,"Date",oFont12a,,CLR_BLACK)
   oPrint:Say(410,1100,DataFormat(cEmissao,.F.),oFont12a,,CLR_BLACK)

   //alterado conforme solicitação da WDF - MSM 14/12/2011
   if nMoeda==2
   	oPrint:Say(410,1700,"US$",oFont12a,,CLR_BLACK) 
   else
   	oPrint:Say(410,1700,"R$",oFont12a,,CLR_BLACK)
   endif

   oPrint:Say(410,1700,Transform(nTotalR,"@E 999,999,999,999.99"),oFont12a,,CLR_BLACK)   

   oPrint:Say(550,220,cNomeCli,oFont12a,,CLR_BLACK)   
   oPrint:Say(600,220,cDescInv01,oFont12a,,CLR_BLACK)   
   oPrint:Say(650,220,cDescInv02,oFont12a,,CLR_BLACK)   
   oPrint:Say(700,220,cDescInv03,oFont12a,,CLR_BLACK)   
   oPrint:Say(750,220,cDescInv04,oFont12a,,CLR_BLACK)   

   oPrint:Say(850,850,"Description",oFont12a,,CLR_BLACK)   

	//alterado conforme solicitação da WDF - MSM 14/12/2011
   if nMoeda==2
   	oPrint:Say(850,2000,"US$",oFont12a,,CLR_BLACK)   
   else
   	oPrint:Say(850,2000,"R$",oFont12a,,CLR_BLACK)   
   endif

   oPrint:Say(920,220,"Operator:",oFont12a,,CLR_BLACK)   
   oPrint:Say(920,420,Alltrim(cOperador) +" - Ref. "+Alltrim(cReference) +" - "+Alltrim(cRegistro)+"/"+ Alltrim(cCodAirpt),oFont12a,,CLR_BLACK)
   //oPrint:Say(920,1900,Transform(nTotalR,"@E 999,999,999,999.99"),oFont12a,,CLR_BLACK)  
   
   //Descricao dos servicos
   For i := 1 to Len(aInvoice)
       oPrint:Say(lin,220,aInvoice[i][1],oFont12a,,CLR_BLACK) 
       //oPrint:Say(lin,1860,Transform(aInvoice[i][2]*nTaxa,"@E 999,999,999,999.99"),oFont12a,,CLR_BLACK) //alterado conforme solicitação da WDF - MSM 14/12/2011 
		oPrint:Say(lin,1860,Transform(aInvoice[i][2],"@E 999,999,999,999.99"),oFont12a,,CLR_BLACK) 
       lin := lin + 50
       i++
   Next   
   
   oPrint:Say(lin,220,"TOTAL 15% 3rd SERVICES" ,oFont12a,,CLR_BLACK)  
   //oPrint:Say(lin,1860,Transform(n15PerServ*nTaxa,"@E 999,999,999,999.99"),oFont12a,,CLR_BLACK)  //alterado conforme solicitação da WDF - MSM 14/12/2011 
   oPrint:Say(lin,1860,Transform(n15PerServ,"@E 999,999,999,999.99"),oFont12a,,CLR_BLACK) 
   lin := lin + 50                            
   oPrint:Say(lin,220,"TOTAL SALES TAXES "+Alltrim(Str(nAcrescimo))+"%",oFont12a,,CLR_BLACK)  
   //oPrint:Say(lin,1860,Transform(nSalesTx*nTaxa,"@E 999,999,999,999.99"),oFont12a,,CLR_BLACK) //alterado conforme solicitação da WDF - MSM 14/12/2011 
   oPrint:Say(lin,1860,Transform(nSalesTx,"@E 999,999,999,999.99"),oFont12a,,CLR_BLACK) 
   oPrint:Say(2250,220,"Please   make   payment   to  ,   WDF SERVIÇOS AEROPORTUÁRIOS LTDA   ,  and   arrange  for  a",oFont12a,,CLR_BLACK)   
   oPrint:Say(2300,220,"direct deposit in our account as follows :",oFont12a,,CLR_BLACK)   
   
   oPrint:Say(2380,220,"Wire Transfer :",oFont12a,,CLR_BLACK)   
   oPrint:Say(2430,220,"Bank of America Na - New York, EUA",oFont12a,,CLR_BLACK) 
   oPrint:Say(2480,220,"Swift Code : BOFAUS3N",oFont12a,,CLR_BLACK) 
   oPrint:Say(2530,220,"ABA Code - 026009593",oFont12a,,CLR_BLACK) 
   oPrint:Say(2580,220,"Credit Account Number - 6550422632",oFont12a,,CLR_BLACK) 
   oPrint:Say(2630,220,"Banco Itaú S/A",oFont12a,,CLR_BLACK) 
   oPrint:Say(2680,220,"Swift Code : ITAUBRSP",oFont12a,,CLR_BLACK) 
   oPrint:Say(2730,220,"For further credit : WDF Serviços Aeroportuários Ltda.",oFont12a,,CLR_BLACK) 
   oPrint:Say(2780,220,"Banco Itaú - 341  Branch : Cumbica - 1600  Account : 29623-8",oFont12a,,CLR_BLACK) 

   //alterado conforme solicitação da WDF - MSM 14/12/2011
   if nMoeda==2 
   	oPrint:Say(2150,220,"PS - Amount in American Currency US$",oFont12a,,CLR_BLACK)   
   else
   	oPrint:Say(2150,220,"PS - Amount in Brazilian Currency R$",oFont12a,,CLR_BLACK)   
   endif
      
   oPrint:Say(2150,1860,Transform(nTotalR,"@E 999,999,999,999.99"),oFont12a,,CLR_BLACK)   
                 
End Sequence   

Return 


*------------------------------------------------
Static Function BoxTotal(oPrint)   
*------------------------------------------------    
Begin Sequence 

   //Caixas Gerais
   oPrint:Box(400,200,460,2200)     //Box Geral 1 
   oPrint:Box(520,200,2200,2200)    //Box Geral 2 
   oPrint:Box(2350,200,2920,2200)   //Box Geral 3 
 
   //Separação das Colunas                                  
   oPrint:Line(400, 830 ,460 ,830)   //Coluna 1                        
   oPrint:Line(400,1525,460,1525)    //Coluna 2
   oPrint:Line(820,1825,2200,1825)   //Coluna 2
   
   oPrint:Line(820,200,820,2200)     //Linha  
   oPrint:Line(900,200,900,2200)     //Linha  
   oPrint:Line(2130,200,2130,2200)   //Linha  
   
End Sequence

Return                                                     



*------------------------------------------------
Static Function DataFormat(cData,lAbreviado)   
*------------------------------------------------                                   
Local cDataORI := cData 
Local cDia := ""  
Local nDia := 0
Local cMes := ""
Local cAno := ""      
Local cDataFormat := ""   
Local lAbrevia := lAbreviado
Local aMes := {"January", "February", "March", "April", "May", "June", "July", 	"August", "September", "October", "November", "December"}
If !empty(cData)
   cDia := Substr(cDataOri,1,2)
   cMes := Substr(cDataOri,4,2)
   cAno := Substr(cDataOri,9,2)
EndIf

If AllTrim(cMes) <> ""  
   If lAbrevia
      cDataFormat := Substr(Alltrim(aMes[Val(cMes)] ),1,3) +" "
   Else 
      cDataFormat := Alltrim(aMes[Val(cMes)] ) +" "   
   EndIf   
EndIf


If cDia <> ""
   nDia := Val(cDia)
   Do Case          
      Case nDia = 1 .Or. nDia = 21 .Or.  nDia = 31
         cDia = Str(nDia)+"st'  "
      Case nDia = 2 .Or. nDia = 22 
        cDia = Str(nDia)+"nd'  "
      Case nDia = 3 .Or. nDia = 23 
        cDia = Str(nDia)+"rd'  "
      Otherwise
        cDia = Str(nDia)+"th'  "
   End          
   cDataFormat += Alltrim(cDia)
EndIF
   
cDataFormat += Alltrim(cAno)


Return cDataFormat              
