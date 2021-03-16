#include "PROTHEUS.CH"
#include "RWMAKE.CH"
#include 'topconn.ch'    
#include 'colors.ch'

/*
Funcao      : GTFAT007
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Emitir Nota Fiscal Fatura de ServiÁos de ComunicaÁ„o/TelecomunicaÁ„o - Modelo 21/22
Autor       : Renato Rezende
Data        : 28/04/2014
MÛdulo      : Faturamento.
*/   
*----------------------*
User Function GTFAT007()   
*----------------------*                                      
Private oDlg                     
Private cNotaDe   := Space(09)
Private cNotaAte  := Space(09) 
Private cSerie    := Space(03)

Private aItems	:= {"Mod. 21","Mod. 22"}  
Private cModelo	:= aItems[1]

Begin Sequence
                                                                                                   
   DEFINE MSDIALOG oDlg TITLE OemToAnsi("Emiss„o Nota Fiscal Modelo 21/22") FROM 0,0 TO 300,380 OF oMainWnd PIXEL 

      @ 010,012 To 142,178  

      @ 020,023 Say "Nota De:" COLOR CLR_HBLUE, CLR_WHITE
      @ 019,110 Get cNotaDe Size 40,8             
      
      @ 040,023 Say "Nota Ate:" COLOR CLR_HBLUE, CLR_WHITE
      @ 039,110 Get cNotaAte Size 40,8
      
      @ 060,023 Say "SÈrie:" COLOR CLR_HBLUE, CLR_WHITE
      @ 059,110 Get cSerie Size 40,8

      @ 080,023 Say "Modelo:" COLOR CLR_HBLUE, CLR_WHITE
      @ 079,110 ComboBox cModelo Items aItems Size 50,50  

      @ 115, 35  Button "_Ok " Size 50,15 ACTION BuscaDados()
      @ 115, 105 Button "_Cancelar" Size 50,15 ACTION Close(oDlg)
                               
   ACTIVATE MSDIALOG oDlg CENTERED

End Sequence

Return
                  
*--------------------------*
Static Function BuscaDados()
*--------------------------* 
Private cNomeArquivo := ""         

Begin Sequence
   If !Empty(cNotaDe) .Or. !Empty(cNotaAte)
      MontaQuery()
      SQL->(dbGoTop())
   Else
      MsgStop("Verifique os par‚metros preenchidos!","AtenÁ„o!")         
   EndIf                                                      
   
   If SQL->(!EoF()) 
      CriaLayout("SQL")
   Else
      Alert("N„o foram encontrados dados de acordo com o filtro selecionado. Por favor, verifique o filtro!")
   EndIf
   
End Sequence

Return                    
               
*--------------------------*
Static Function MontaQuery()   
*--------------------------*   
If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

aStruSF2 :={}
aStruSD2 :={}
aStruSF2:= SF2->(dbStruct())
aStruSD2:= SD2->(dbStruct())               
   
cQuery := "SELECT F2_DOC,F2_SERIE,F2_EMISSAO,F2_FILIAL,F2_CLIENTE,F2_LOJA,F2_PREFIXO,F2_DUPL, "+Chr(10)+CHR(13)
cQuery += "F2_BASEICM,F2_VALICM,F2_VALMERC,F2_VALBRUT,F2_DESCONT,D2_COD,D2_ITEMPV,D2_PEDIDO, D2_TES, D2_CF ,D2_PICM,D2_FILIAL,D2_DOC,D2_SERIE,"+Chr(10)+CHR(13)
cQuery += "A1_COD, A1_LOJA, A1_NOME,A1_END, A1_EST, A1_MUN, A1_BAIRRO, A1_CGC, A1_INSCR , A1_PESSOA, A1_CEP, A1_COMPLEM, A1_TIPO " +Chr(10)+CHR(13)
cQuery += "FROM "+RetSqlName("SF2")+" SF2, "+RetSqlName("SA1")+" SA1,"+RetSqlName("SD2")+ " SD2  WHERE "+Chr(10)
cQuery += "SF2.F2_FILIAL = '"+xFilial("SF2")+"' AND SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND  SD2.D2_FILIAL = '"+xFilial("SD2")+" ' AND " +Chr(10)
cQuery += "SF2.F2_DOC BETWEEN '"+cNotaDe+"' AND '"+cNotaAte+"' AND "+Chr(10)
cQuery += "SF2.F2_SERIE = '"+cSerie+"' AND "+Chr(10)
cQuery += "SF2.F2_DOC+SF2.F2_SERIE = SD2.D2_DOC+SD2.D2_SERIE AND SF2.F2_CLIENTE+SF2.F2_LOJA = SA1.A1_COD+SA1.A1_LOJA AND "+Chr(10)
cQuery += "SF2.D_E_L_E_T_ <> '*' AND SD2.D_E_L_E_T_ <> '*' AND SA1.D_E_L_E_T_ <> '*' "+Chr(10)
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
                  
*--------------------------------------*
Static Function CriaLayout(cNomeArquivo)   
*--------------------------------------* 
//Declara a vari·vel objeto do relatÛrio
Private oPrint

//Cria os objetos fontes que ser„o utilizadoas atravÈs do mÈtodo TFont()                            
Private oFont5      := TFont():New( "Arial",,07,,.F.,,,,,.F. )             // 5        *
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
   oPrint:= TMSPrinter():New( "Impress„o de Nota Fiscal da "+Alltrim(SM0->M0_NOMECOM) )  
      
   //P·gina tipo retrato
   oPrint:SetPortrait()  
   
   //Inicia uma nova p·gina
   oPrint:StartPage()   
   
   //Papel A4
   oPrint:SetpaperSize(9)  
   
   //Molduras externas
   BoxGeral(oPrint) 
      
   //Cria o CabeÁalho do RelatÛrio
   ReportHeader(oPrint)      
      
   //Cria os Detalhes do RelatÛrio
   ReportDetail(oPrint)    
 
   //Preview da Impressao
   oPrint:Preview()   
   
   //Selecionar Impressora
   //oPrint:setup()  
   
   //Imprime direto na impressora padr„o do APx
   //oPrint:Print()   
   
   //Finaliza a p·gina
   oPrint:EndPage()
   
   //Finaliza Objeto 
   oPrint:End() 
   
   //Desativa Impressora
   ms_flush() 
   
   Close(oDlg)
      
   End Sequence

Return

*----------------------------------*
Static Function ReportHeader(oPrint)   
*----------------------------------*   

Begin Sequence 
	//Logo 
	If cModelo == aItems[1]
		oPrint:SayBitmap(040,200,"\System\LGRL21"+Alltrim(cEmpAnt)+".bmp",1090,400)
		oPrint:Say(170,1456,"NOTA FISCAL FATURA DE SERVI«OS DE COMUNICA«√O ",oFont07,,CLR_BLACK)
		oPrint:Say(200,1610,"MODELO 21 - S…RIE "+Alltrim(Substr(SQL->F2_SERIE,1,1))+" ⁄NICA",oFont07,,CLR_BLACK)
	Else
		oPrint:SayBitmap(040,200,"\System\LGRL22"+Alltrim(cEmpAnt)+".bmp",1090,400)  
		oPrint:Say(170,1456,"NOTA FISCAL FATURA DE SERVI«OS DE TELECOMUNICA«√O ",oFont07,,CLR_BLACK)
		oPrint:Say(200,1610,"MODELO 22 - S…RIE "+Alltrim(Substr(SQL->F2_SERIE,1,1))+" ⁄NICA",oFont07,,CLR_BLACK)
	EndIf    

   oPrint:Say(260,1650,"N∫",oFont20t,,CLR_BLACK)
   oPrint:Say(260,1750,Alltrim(SQL->F2_DOC),oFont20,,CLR_BLACK)
   oPrint:Say(376,1460,"RESERVADO AO FISCO:",oFont07a,,CLR_BLACK)     
   oPrint:Say(460,150,Alltrim(SM0->M0_NOMECOM),oFont07n,,CLR_BLACK)
   oPrint:Say(500,150,Alltrim(SM0->M0_ENDCOB)+" - "+Alltrim(SM0->M0_COMPCOB)+" - "+Alltrim(SM0->M0_BAIRENT),oFont07n,,CLR_BLACK)
   oPrint:Say(540,150,Alltrim(SM0->M0_CIDCOB)+" - "+Alltrim(SM0->M0_ESTCOB)+" - CEP: "+Alltrim(Transform(SM0->M0_CEPCOB,"@R 99999-999")),oFont07n,,CLR_BLACK)
   oPrint:Say(590,150,"CNPJ.:"+Alltrim(Transform(SM0->M0_CGC,"@R 99.999.999/9999-99")),oFont07n,,CLR_BLACK)
   oPrint:Say(590,955,"INSCR. EST.: "+Alltrim(Transform(SM0->M0_INSC,"@R 999.999.999.9999")),,CLR_BLACK)   
   oPrint:Say(440,1470,"CFOP UTILIZADA: ",oFont07a,,CLR_BLACK)
   oPrint:Say(490,1470,"NATUREZA DA OPERA«√O: ",oFont07a,,CLR_BLACK)
   oPrint:Say(540,1470,"DATA DA EMISS√O: ",oFont07a,,CLR_BLACK)
   oPrint:Say(700,180,"USU¡RIO: ",oFont10a,,CLR_BLACK)
   oPrint:Say(780,180,"ENDERE«O: ",oFont10a,,CLR_BLACK)
   oPrint:Say(780,1470,"COMPL.: ",oFont10a,,CLR_BLACK)
   oPrint:Say(860,180,"BAIRRO: ",oFont10a,,CLR_BLACK)
   oPrint:Say(860,950,"CEP: ",oFont10a,,CLR_BLACK)
   oPrint:Say(860,1260,"MUNICÕPIO: ",oFont10a,,CLR_BLACK)
   oPrint:Say(860,2020,"U.F.: ",oFont10a,,CLR_BLACK)
   oPrint:Say(940,180,"C.N.P.J: ",oFont10a,,CLR_BLACK)
   oPrint:Say(940,1150,"INSCRI«√O ESTADUAL: ",oFont10a,,CLR_BLACK)
  
   //oPrint:Say(1020,180,"N∫ DO CONTRATO: ",oFont10a,,CLR_BLACK)
   oPrint:Say(1190,180,"FATURA ",oFont10a,,CLR_BLACK) 
   oPrint:Say(1348,800,"DESCRI«√O DOS SERVI«OS ",oFont10a,,CLR_BLACK)
   oPrint:Say(1348,2020,"VALOR ",oFont10a,,CLR_BLACK)                
   oPrint:Say(3150,170,"BASE DE C¡LC. DO ICMS ",oFont10a,,CLR_BLACK)
   oPrint:Say(3150,685,"ALÕQUOTA",oFont10a,,CLR_BLACK)
   oPrint:Say(3150,980,"VALOR DO ICMS",oFont10a,,CLR_BLACK)
   //oPrint:Say(3150,1400,"DATA DO PERIODO",oFont10a,,CLR_BLACK)
   oPrint:Say(3150,1910,"VALOR TOTAL ",oFont10a,,CLR_BLACK)   
   oPrint:Say(3310,150,"Emitida nos termos da Portaria CAT 79 de 10/09/2003.",oFont07n,,CLR_BLACK)   
   ImpCapa()     

End Sequence                                          

Return  

*----------------------------------*
Static Function ReportDetail(oPrint)   
*----------------------------------*   
Local cMenFixo01   := ""
Local cMsgCircuito := "" 
Local cMsgPeriodo  := "" 
Local n            := 1   
Local cPedido      := ""

//TLM
Local cCli, cDoc, cSerie
Local nQtdItens    := 0
Local cFil         := xFilial("SD2")

Private nPagina    := 1
Private nLinha     := 0 
Private nTotal     := 0 
//RRP - 18/11/2014 - Retirada empresa NTT conforme chamado 022697.
If cModelo == aItems[2] .AND. !(cEmpAnt) == "0F"//Imprime no modelo 22
	cMenFixo01   := "ContribuiÁ„o p/ FUST e FUNTTEL 1,5 do valor dos serviÁos n„o repassados ao cliente conf. Lei n∫ 9998/00 e 10052/00."
EndIf     

nLinha := 1438

   	dbSelectArea("SQL")
   	dbGoTop()      
   	
	//Tratamento referente lei transparÍncia  - TLM 20141223
	If SQL->A1_TIPO == "F" 
		SF2->(DbSetOrder(1))                                                                                                  
	 	If SF2->(DbSeek(xFilial("SF2")+SQL->F2_DOC+SQL->F2_SERIE+SQL->F2_CLIENTE+SQL->F2_LOJA))
			If (SF2->(FieldPos("F2_TOTIMP")) > 0)
				If SF2->F2_TOTIMP > 0   
				 	cMenFixo01   += "Valor Aproximado dos Tributos: R$ "+Alltrim(Transform(SF2->F2_TOTIMP,"@E 999,999,999,999.99"))+" ("+Alltrim(Transform((SF2->F2_TOTIMP/SF2->F2_VALBRUT)*100,"@E 999,999,999,999.99"))+"%) Fonte: IBPT."
	    		EndIf
	   		EndiF
		EndIf
	EndIf
  	   	
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
			//Impress„o da Mensagem para nota
			Memnota(nLinha,cPedido,CMENFIXO01)   
         
			oPrint:EndPage()   
			oPrint:StartPage() 
			oPrint:SetPortrait()
			oPrint:SetpaperSize(9)
			BoxGeral(oPrint) 
			ReportHeader(oPrint)  
			cDoc:= SQL->F2_DOC 
			cSer:= SQL->F2_SERIE
			cPedido := SQL->D2_PEDIDO
			//RRP - 19/01/2015 - Ajuste para impress„o de 2 ou mais notas no filtro
			If cModelo == aItems[2] .AND. !(cEmpAnt) == "0F"//Imprime no modelo 22
				cMenFixo01   := "ContribuiÁ„o p/ FUST e FUNTTEL 1,5 do valor dos serviÁos n„o repassados ao cliente conf. Lei n∫ 9998/00 e 10052/00."
			Else
				cMenFixo01   := ""	
			EndIf
			If SQL->A1_TIPO == "F"
				SF2->(DbSetOrder(1))
				If SF2->(DbSeek(xFilial("SF2")+SQL->F2_DOC+SQL->F2_SERIE+SQL->F2_CLIENTE+SQL->F2_LOJA))
					If (SF2->(FieldPos("F2_TOTIMP")) > 0)
						If SF2->F2_TOTIMP > 0
						 	cMenFixo01   += " Valor Aproximado dos Tributos: R$ "+Alltrim(Transform(SF2->F2_TOTIMP,"@E 999,999,999,999.99"))+" ("+Alltrim(Transform((SF2->F2_TOTIMP/SF2->F2_VALBRUT)*100,"@E 999,999,999,999.99"))+"%) Fonte: IBPT."
			    		EndIf
			   		EndiF
				EndIf
			EndIf
			nLinha:= 1438
		EndIf        
      SC6->(DbSetOrder(2))                
      If SC6->(dbSeek(xFilial("SC6")+SQL->D2_COD+SQL->D2_PEDIDO+SQL->D2_ITEMPV))               
      	SC5->(DbSetOrder(1))
       	SC5->(DbSeek(xFilial("SC5")+SC6->C6_NUM))  
      	// TLM 19/04/2013  - Tratamento de complemento de ICMS - chamado 011137
      	If Alltrim(SC5->C5_TIPO) == "I"
       		oPrint:Say(nLinha,177,Substr(Alltrim(SC5->C5_MENNOTA),1,084),oFont10,,CLR_BLACK)    
	        nLinha+=60 
	    	oPrint:Say(nLinha,177,Substr(Alltrim(SC5->C5_MENNOTA),85,170),oFont10,,CLR_BLACK)        
	        nLinha+=60
	     	oPrint:Say(nLinha,177,Substr(Alltrim(SC5->C5_MENNOTA),171,250),oFont10,,CLR_BLACK)        
	        nLinha+=60
	     
      	Else
	         cMsgCircuito:= alltrim(SQL->D2_COD)+" "+Alltrim(SC6->C6_DESCRI)
	         nLinha+= 20         
	         //oPrint:Say(1438,180,Substr(Alltrim(cMsgNota),1,065),oFont10,,CLR_BLACK)           
	         oPrint:Say(nLinha,177,Substr(Alltrim(cMsgCircuito),1,084),oFont10,,CLR_BLACK)    
	         oPrint:Say(nLinha,1900,Transform(SC6->C6_VALOR,"@E 999,999,999,999.99"),oFont10,,CLR_BLACK)
	         If Len(Alltrim(cMsgCircuito)) > 84
	            nLinha+=20 
	            cMsgCircuito:=Substr(Alltrim(cMsgCircuito),85,85)+cMsgPeriodo  
	            oPrint:Say(nLinha,177,Substr(Alltrim(cMsgCircuito),85,85),oFont10,,CLR_BLACK) 
	         EndIf  
	         
	         nLinha+=20
	         oPrint:Say(nLinha,177,Substr(Alltrim(cMsgPeriodo),1,084),oFont10,,CLR_BLACK)    
	         nLinha+=20
	     
	 	EndIf
	         
   		nLinha+=60  
      	nLinha := ChkLinha(nLinha)
        
      EndIf   
      	    
      oPrint:Say(3310,2100,"Pagina "+(Alltrim(str(nPagina)))+"/"+(Alltrim(str(nTOTAL))),oFont07n,,CLR_BLACK)  	

      nQtdItens++
                               
      SQL->(DbSkip())  
      
	EndDo
	//Impress„o da Mensagem para nota
	Memnota(nLinha,cPedido,CMENFIXO01)
  
  //Fecha o arquivo
  SQL->(dbCloseArea())

Return  

*------------------------------*
Static Function BoxGeral(oPrint)   
*------------------------------*    
//Local L:= 1420
//Private oPen := TPen():New(,7,CLR_BLACK,oPrint)
Private oPen := TPen():New(,7,CLR_BLACK)

Begin Sequence 
   oPrint:Box(160,1450,350,2250)   //Numero nota  
   oPrint:Box(420,1450,600,2250)   //CFOP e DT Emissao  

   oPrint:Line(470,1690,470,2200)   //Linha CFOP 
   oPrint:Line(520,1800,520,2200)   //Linha NATUREZA OP
   oPrint:Line(570,1710,570,2200)   //Linha DT EMISSAO     
   
   oPrint:Box(650,150,1100,2250)     //CabeÁalho
   
   oPrint:Box(1120,150,1300,2250)    //Fatura
   oPrint:Line(1120,330,1300,330)     //Coluna 1
    
   oPrint:Box(1320,150,3100,2250)    //Itens
   oPrint:Box(3120,150,3300,2250)    //RodapÈ

   oPrint:Line(1320,1950,3100,1950)   //Coluna 1                        
   oPrint:Line(3120,650,3300,650)     //Coluna 2 
   oPrint:Line(3120,900,3300,900)     //Coluna 3 
   oPrint:Line(3120,1400,3300,1400)   //Coluna 4
   oPrint:Line(3120,1750,3300,1750)   //Coluna 5 
   
   oPrint:Line(580,150,580,1410)   //Linha   
      
   oPrint:Line(743,340,743,2210)   //Usu·rio
   oPrint:Line(823,360,823,1450)   //EndereÁo
   oPrint:Line(823,1610,823,2210)  //Complemento EndereÁo
   oPrint:Line(903,340,903,930)    //Bairro
   oPrint:Line(903,1025,903,1245)  //Cep 
   oPrint:Line(903,1455,903,1990)  //Municipio  
   oPrint:Line(903,2090,903,2210)  //UF
   oPrint:Line(983,300,983,1130)   //CNPJ  
   oPrint:Line(983,1525,983,2210)  //IE
   //oPrint:Line(1063,470,1063,2210) //Contrato

   oPrint:Line(1420,150,1420,2250) 
   /*                       
   For h:=1 to 58
      oPrint:Line(L,150,L,2250)   //Linha  
      L:= L +60
      h++
   Next                                    
   */

End Sequence

Return

*-----------------------*
Static Function ImpCapa()
*-----------------------*      
Local cQry := ""

 	SF3->(DbSetOrder(6))                
  	SF3->(dbSeek(xFilial("SF3")+SQL->F2_DOC+SQL->F2_SERIE)) 
   	oPrint:Say(376,1760,Alltrim(Transform(SF3->F3_MDCAT79,"@R XXXX.XXXX.XXXX.XXXX.XXXX.XXXX.XXXX.XXXX")),oFont07,,CLR_BLACK)      
        
    dbSelectArea("SF4")
    SF4->(DbSetOrder(1))
    SF4->(dbSeek(xFilial("SF4")+SQL->D2_TES))
    oPrint:Say(440,1730,Alltrim(SQL->D2_CF),oFont07,,CLR_BLACK)
	If cModelo == aItems[1]
    	oPrint:Say(490,1800," SERVI«O COMUNICA«’ES",oFont07,,CLR_BLACK)
	Else
    	oPrint:Say(490,1800," SERVI«O TELECOMUNICA«’ES",oFont07,,CLR_BLACK)
	EndIf	

    oPrint:Say(540,1730,DtoC(SQL->F2_EMISSAO),oFont07,,CLR_BLACK)    
    oPrint:Say(700,370,Alltrim(SQL->A1_NOME),oFont10,,CLR_BLACK)                
    oPrint:Say(780,400,Alltrim(SQL->A1_END),oFont10,,CLR_BLACK)
    oPrint:Say(780,1650,Alltrim(Substr(SQL->A1_COMPLEM,1,21)),oFont10,,CLR_BLACK)
    oPrint:Say(860,350,Alltrim(SQL->A1_BAIRRO),oFont10,,CLR_BLACK)
    oPrint:Say(860,1050,Transform(Alltrim(SQL->A1_CEP),"@R 99999-999"),oFont10,,CLR_BLACK)
    oPrint:Say(860,1480,Alltrim(SQL->A1_MUN),oFont10,,CLR_BLACK)
    oPrint:Say(860,2140,Alltrim(SQL->A1_EST),oFont10,,CLR_BLACK)
    If SQL->A1_PESSOA = 'J'
    	oPrint:Say(940,350,Transform(Alltrim(SQL->A1_CGC),"@R 99.999.999/9999-99"),oFont10,,CLR_BLACK)
    Else 
    	oPrint:Say(940,350,Transform(Alltrim(SQL->A1_CGC),"@R 999.999.999-99"),oFont10,,CLR_BLACK)
    EndIf
    oPrint:Say(940,1575,Alltrim(SQL->A1_INSCR),oFont10,,CLR_BLACK)
    
    //MSM - 06/01/2015 - Tratamento para demonstraÁ„o das parcelas,valores,datas de vencimento, Chamado: 023296 
    //RRP - 18/09/2017 - Ajustado para E1_FILORIG, empresas com o SE1 compartilhado.
	//Tratamento para as informaÁıes da fatura
	cQry:=" SELECT E1_PARCELA,E1_VENCREA,E1_VALOR FROM "+RETSQLNAME("SE1")
	cQry+=" WHERE E1_NUM='"+alltrim(SQL->F2_DUPL)+"' AND E1_PREFIXO='"+alltrim(SQL->F2_PREFIXO)+"' AND E1_FILORIG='"+alltrim(SQL->F2_FILIAL)+"' AND E1_CLIENTE='"+alltrim(SQL->F2_CLIENTE)+"' AND E1_LOJA='"+alltrim(SQL->F2_LOJA)+"' AND D_E_L_E_T_=''"
    
	if select("QRYTEMP")>0
		QRYTEMP->(DbCloseArea())
	endif
	
	DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )
	
	Count to nRecCount
    
    nLinFat:= 1140    
	nColFat:= 380
	
	if nRecCount >0
  		oPrint:Say(nLinFat,nColFat,"Parcela:" ,oFont10,,CLR_BLACK) 
   		oPrint:Say(nLinFat+45,nColFat,"Vencto:" ,oFont10,,CLR_BLACK) 
   		oPrint:Say(nLinFat+90,nColFat,"Valor:" ,oFont10,,CLR_BLACK) 
      	
      	nColFat+=180
      	
       	QRYTEMP->(DbGotop())
        	
    	While QRYTEMP->(!EOF())
    	
    		oPrint:Say(nLinFat,nColFat,QRYTEMP->(E1_PARCELA) ,oFont10,,CLR_BLACK) 
    		oPrint:Say(nLinFat+45,nColFat,DTOC(STOD((QRYTEMP->E1_VENCREA))) ,oFont10,,CLR_BLACK) 
     		oPrint:Say(nLinFat+90,nColFat,alltrim(Transform(QRYTEMP->E1_VALOR,"@E 999,999,999,999.99")) ,oFont10,,CLR_BLACK) 
    		
    		nColFat+=200
    		    		        
        	QRYTEMP->(DbSkip())
    	Enddo
    endif
    
    // TLM 19/04/2013  - Tratamento de complemento de ICMS - chamado 011137      	
    SC6->(DbSetOrder(2))                
    If SC6->(dbSeek(xFilial("SC6")+SQL->D2_COD+SQL->D2_PEDIDO+SQL->D2_ITEMPV))               
    	SC5->(DbSetOrder(1))
       	If SC5->(DbSeek(xFilial("SC5")+SC6->C6_NUM))
			If Alltrim(SC5->C5_TIPO) == "I"
    			oPrint:Say(3250,970,Transform(SQL->F2_VALICM,"@E 999,999,999,999.99"),oFont10,,CLR_BLACK) 
    		Else
    			oPrint:Say(3250,250,Transform(SQL->F2_BASEICM,"@E 999,999,999,999.99"),oFont10,,CLR_BLACK)   
    			//oPrint:Say(3250,700,Alltrim(Str(SQL->D2_PICM))+"%",oFont10,,CLR_BLACK)             											 //CAS - 24/05/2017 - Ato Cotepe-Aliquota Zero-Nf Modelo 22                       
    			oPrint:Say(3250,700,Alltrim(Str( IIF((SQL->F2_BASEICM == 0 .AND. SQL->F2_VALICM==0), 0, SQL->D2_PICM) ))+"%",oFont10,,CLR_BLACK) //CAS - 24/05/2017 - Ato Cotepe-Aliquota Zero-Nf Modelo 22                                    
    			oPrint:Say(3250,970,Transform(SQL->F2_VALICM,"@E 999,999,999,999.99"),oFont10,,CLR_BLACK) 
    			oPrint:Say(3250,1880,Transform(SQL->F2_VALBRUT,"@E 999,999,999,999.99"),oFont10,,CLR_BLACK)        		
        	EndIf
        EndIf
     EndIf    
         
Return  
             
*----------------------------*
Static Function ChkLinha(nRet)
*----------------------------*
Default nRet := 0

If nRet > 3057
    oPrint:EndPage()   
 	oPrint:StartPage() 
  	oPrint:SetPortrait()
   	oPrint:SetpaperSize(9)
         
  	//Molduras externas
    BoxGeral(oPrint)
    //RRP - 03/02/2014 - Ajuste para impress„o de uma nova p·gina mesmo que chegou no final da nota. 
    If Alltrim(SQL->F2_DOC) = '' .And. SQL->(EOF())
	    DbSelectArea("SQL")
	   	DbGoTop()
	EndIf
	nRet:= 1438      
   	//Cria o CabeÁalho do RelatÛrio
   	ReportHeader(oPrint)
  	ImpCapa() 
            
	nPagina++ 
            
 	oPrint:Say(3310,2100,"Pagina "+ (Alltrim(str(nPagina)))+"/"+(Alltrim(str(nTOTAL))),oFont07n,,CLR_BLACK)  
            
EndIf 

Return nRet 

/*
Funcao      : Memnota
Parametros  : Valor da linha tual, numero do pedido e mensagem
Retorno     : Nenhum
Objetivos   : Informar abaixo dos itens a mensagems padr„o e mensagems do pedido.
Autor       : Jo„o Dos Santos Silva 
Data        : 22/03/2013
*/    
*-------------------------------------------------*
Static Function  Memnota(nLinha,cPedido,CMENFIXO01)    
*-------------------------------------------------*
Local cMenNota := ""
Local cSubMen := ""
	SC5->(DbSetOrder(1))                
 	If SC5->(dbSeek(xFilial("SC5")+cPedido))
	//WFA - 31/01/2019 - Inclus„o de tratamento para utilizar a mensagem de um campo MEMO. Ticket: #2752.
 	cMenNota := IIF(cEmpAnt == "M6", SC5->C5_P_MEMOM, SC5->C5_MENNOTA)            

  	  	// TLM 19/04/2013  - Tratamento de complemento de ICMS - chamado 011137	
  		If Alltrim(SC5->C5_TIPO) <> "I"
	  		SM4->(DbSetOrder(1))
	    	If SM4->(DbSeek(xFilial("SM4")+SC5->C5_MENPAD)) 
	     		oPrint:Say(nLinha,180,Substr(Alltrim(SM4->M4_FORMULA),1,83),oFont10,,CLR_BLACK)
	     		nLinha+=60   
	     		oPrint:Say(nLinha,180,Substr(Alltrim(SM4->M4_FORMULA),84,170),oFont10,,CLR_BLACK) 
	     		nLinha+=60 
	     		oPrint:Say(nLinha,180,Substr(Alltrim(SM4->M4_FORMULA),171,250),oFont10,,CLR_BLACK) 
    			nLinha+=60  
    			
	     		nLinha := ChkLinha(nLinha)
	     		
	      		oPrint:Say(nLinha,180,Substr(Alltrim(SM4->M4_FORMULA),84,83),oFont10,,CLR_BLACK)
	            nLinha := ChkLinha(nLinha)   
	               
	       		//ALTERADO MATHEUS
	        	if len(Alltrim(cMenNota))>84 
	               		
	           		nLMenN:=0 //controla a posiùùo da coluna
	          		nPosMenN:=1 //controla a posiùùo de corte da msg
	               		
	            	while !empty(Substr(Alltrim(cMenNota),nPosMenN,83))                		
	            		cSubMen:=Substr(Alltrim(cMenNota),nPosMenN,83)
	               		oPrint:Say(nLinha,180,cSubMen,oFont10,,CLR_BLACK)
	               		nLMenN+=35 
	               		nPosMenN+=83 
	               		nLinha+=60
	               		nLinha := ChkLinha(nLinha)
	            	 enddo              
	         	else
	               		oPrint:Say(nLinha,180,Substr(Alltrim(cMenNota),1,83),oFont10,,CLR_BLACK)
	               		nLinha+=60
	               		nLinha := ChkLinha(nLinha)   		
	        	endif                                                                                            
	     	Else     
	     	
	      		//ALTERADO MATHEUS
	       		if len(Alltrim(cMenNota))>84 
	         		nLMenN:=0 //controla a posiùùo da coluna
	           		nPosMenN:=1 //controla a posiùùo de corte da msg
	               		
	             	while !empty(Substr(Alltrim(cMenNota),nPosMenN,83))                		
	              		cSubMen:=Substr(Alltrim(cMenNota),nPosMenN,83)
	               		oPrint:Say(nLinha,180,cSubMen,oFont10,,CLR_BLACK)
	               		nLMenN+=35
	               		nPosMenN+=83 
	               		nLinha+=60
	               		nLinha := ChkLinha(nLinha)
	               	enddo
	            else
	           		oPrint:Say(nLinha,180,Substr(Alltrim(cMenNota),1,83),oFont10,,CLR_BLACK) 
	           		nLinha+=60    
	           		nLinha := ChkLinha(nLinha)		
	            endif                              
	        EndIf                     
	    
	    EndIf        
    
		//RRP - 16/01/2015 - Ajuste para nùo encavalar e cortar a impressùo do cMenFixo01
		for nR:=1 to len(cMenFixo01)
			nLinha := ChkLinha(nLinha)
			oPrint:Say(nLinha,180,Substr(Alltrim(cMenFixo01),nR,87),oFont10,,CLR_BLACK)
			nLinha+=60
			nR+=86
		next nR
   	EndIf   
	
Return