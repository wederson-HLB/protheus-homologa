
#INCLUDE "RWMAKE.CH"
#include 'topconn.ch'    
#include 'colors.ch'

/*
Funcao      : NRGFAT01
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Emitir Nota Fiscal Fatura de Serviços de Comunicação - Modelo 21
Autor     	: Vitor Bedin
Data     	: 09/11/09
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 13/03/2012
Módulo      : Faturamento.
*/            
           
                     
*-------------------------*
 User Function NRGFAT01()   
*-------------------------*

IF SM0->M0_CODIGO $ "RG"
   Begin Sequence         
      TelaFiltro()        
   End Sequence
//RRP - 04/02/2013 - Inclusão de Mensagem caso não seja a empresa RG
Else
	MsgInfo("Relatório customizado apenas para a empresa Satamatics!","Atenção")	
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
                                                                                                   
   DEFINE MSDIALOG oDlg TITLE OemToAnsi("Emissão Nota Fiscal Modelo 21 - Satamatics Brasil") FROM 0,0 TO 300,380 OF oMainWnd PIXEL 

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
   
cQuery := "SELECT F2_DOC,F2_SERIE,F2_EMISSAO,F2_FILIAL,F2_CLIENTE,F2_LOJA,F2_PREFIXO,F2_DUPL, "+Chr(10)+CHR(13)
cQuery += "F2_BASEICM,F2_VALICM,F2_VALMERC,F2_VALBRUT,F2_DESCONT,F2_TIPO,D2_PEDIDO, D2_TES, D2_CF ,D2_PICM ,"+Chr(10)+CHR(13)
cQuery += "A1_COD, A1_LOJA, A1_NOME,A1_END, A1_EST, A1_MUN, A1_BAIRRO, A1_CGC, A1_INSCR , A1_PESSOA, A1_TIPO" +Chr(10)+CHR(13)
cQuery += "FROM "+RetSqlName("SF2")+" SF2, "+RetSqlName("SA1")+" SA1,"+RetSqlName("SD2")+ " SD2  WHERE "+Chr(10)
cQuery += "SF2.F2_FILIAL = '"+xFilial("SF2")+"' AND SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND  SF2.F2_FILIAL = '"+xFilial("SF2")+" ' AND " +Chr(10)
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
                        
//------------------------------------------------------------------------------------------------------------------------------------------------- 
                  
*---------------------------------------
Static Function CriaLayout(cNomeArquivo)   
*--------------------------------------- 
              
//Declara a variável objeto do relatório
Private oPrint

//Cria os objetos fontes que serão utilizadoas através do método TFont()                            
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
   oPrint:= TMSPrinter():New( "Impressão de Nota Fiscal da Satamatics Brasil" )  
      
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
   
   //Logo 
   oPrint:SayBitmap(100,200,"\System\lgrlrg0.jpg",950,300)  
   //RRP - 28/10/2015 - Ajuste no endereço para buscar do Sigamat. Chamado 030323.
   oPrint:Say(170,1455,"NOTA FISCAL FATURA DE SERVIÇOS DE COMUNICAÇÃO ",oFont07,,CLR_BLACK)
   oPrint:Say(200,1600,"MODELO 21 - SÉRIE C ÚNICA",oFont07,,CLR_BLACK)
   oPrint:Say(260,1650,"Nº",oFont20t,,CLR_BLACK)
   oPrint:Say(376,1470,"COD. DIGITAL:",oFont07a,,CLR_BLACK)
   oPrint:Say(460,150,Alltrim(SM0->M0_NOMECOM),oFont07n,,CLR_BLACK)
   oPrint:Say(500,150,Alltrim(SM0->M0_ENDCOB)+" - "+Alltrim(SM0->M0_COMPCOB)+" - "+Alltrim(SM0->M0_BAIRENT),oFont07n,,CLR_BLACK)  // Atualizado endereção para solucionar o caso 029101
   oPrint:Say(540,150,Alltrim(SM0->M0_CIDCOB)+" - "+Alltrim(SM0->M0_ESTCOB)+" - CEP: "+Alltrim(Transform(SM0->M0_CEPCOB,"@R 99999-999")),oFont07n,,CLR_BLACK)
   oPrint:Say(590,150,"CNPJ.:"+Alltrim(Transform(SM0->M0_CGC,"@R 99.999.999/9999-99")),oFont07n,,CLR_BLACK)
   oPrint:Say(590,955,"INSCR. EST.: "+Alltrim(Transform(SM0->M0_INSC,"@R 999.999.999.9999")),oFont07n,,CLR_BLACK)      
   oPrint:Say(470,1470,"NATUREZA DA OPERAÇÃO: ",oFont07a,,CLR_BLACK)
   oPrint:Say(540,1470,"DATA DA EMISSÃO: ",oFont07a,,CLR_BLACK)
   oPrint:Say(700,180,"USUÁRIO: ",oFont10a,,CLR_BLACK)
   oPrint:Say(780,180,"ENDEREÇO: ",oFont10a,,CLR_BLACK)
   oPrint:Say(860,180,"MUNICÍPIO: ",oFont10a,,CLR_BLACK)
   oPrint:Say(860,1150,"U.F.: ",oFont10a,,CLR_BLACK)
   oPrint:Say(940,180,"C.N.P.J: ",oFont10a,,CLR_BLACK)
   oPrint:Say(940,1150,"INSCRIÇÃO ESTADUAL: ",oFont10a,,CLR_BLACK)
   oPrint:Say(1020,180,"Nº DO CONTRATO: ",oFont10a,,CLR_BLACK)
   oPrint:Say(1190,180,"FATURA ",oFont10a,,CLR_BLACK) 
   oPrint:Say(1348,800,"DESCRIÇÃO DOS SERVIÇOS ",oFont10a,,CLR_BLACK)
   oPrint:Say(1348,1920,"VALOR ",oFont10a,,CLR_BLACK)
   oPrint:Say(3150,170,"BASE DE CALC. DO ICMS ",oFont10a,,CLR_BLACK)
   oPrint:Say(3150,685,"ALÍQUOTA",oFont10a,,CLR_BLACK)
   oPrint:Say(3150,980,"VALOR DO ICMS",oFont10a,,CLR_BLACK)
   oPrint:Say(3150,1400,"DATA DO PERIODO",oFont10a,,CLR_BLACK)
   oPrint:Say(3150,1910,"VALOR TOTAL ",oFont10a,,CLR_BLACK)   
   oPrint:Say(3310,150,"Emitida nos termos da Portaria CAT 79 de 10/09/2003.",oFont07n,,CLR_BLACK)              
End Sequence                                          

Return  

*--------------------------------------*
 Static Function ReportDetail(oPrint)   
*--------------------------------------*
Local cMensNF    := ''
Local cMenFixo01 := ""
//Local cMenFixo01 := "Contribuição p/ FUST e FUSTEL 1,5 do valor dos serviços não repassados ao cliente conf. Lei nº 9998/00 e 10052/00."

Begin Sequence                                          
   
	dbSelectArea("SQL")
	dbGoTop()
	
	//RRP - 21/01/2015 - Tratamento referente lei transparência.
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
   
	cDoc:= SQL->F2_DOC 
	cSer:= SQL->F2_SERIE
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
			cMenFixo01 := ""
			//RRP - 21/01/2015 - Tratamento referente lei transparência.
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
		EndIf
      oPrint:Say(260,1750,Alltrim(SQL->F2_DOC),oFont20,,CLR_BLACK)
      
      SF3->(DbSetOrder(6))                
      SF3->(dbSeek(xFilial("SF3")+SQL->F2_DOC+SQL->F2_SERIE)) 
      oPrint:Say(375,1660,Alltrim(SF3->F3_MDCAT79),oFont07,,CLR_BLACK)      
        
      dbSelectArea("SF4")
      SF4->(DbSetOrder(1))
      SF4->(dbSeek(xFilial("SF4")+SQL->D2_TES))
      oPrint:Say(470,1810,Alltrim(SF4->F4_TEXTO),oFont07,,CLR_BLACK) 
      //oPrint:Say(545,1730,Substr(DtoC(SQL->F2_EMISSAO),1,6)+"20"+Substr(DtoC(SQL->F2_EMISSAO),7,2),oFont07,,CLR_BLACK) - RRP - 28/02/2013 - Acerto da impressão 
      oPrint:Say(545,1730,DtoC(SQL->F2_EMISSAO),oFont07,,CLR_BLACK)
      oPrint:Say(700,370,Alltrim(SQL->A1_NOME),oFont10,,CLR_BLACK)
      oPrint:Say(780,400,Alltrim(SQL->A1_END),oFont10,,CLR_BLACK)
      oPrint:Say(860,400,Alltrim(SQL->A1_MUN),oFont10,,CLR_BLACK)
      oPrint:Say(860,1360,Alltrim(SQL->A1_EST),oFont10,,CLR_BLACK)
      If SQL->A1_PESSOA = 'J'
         oPrint:Say(940,350,Transform(Alltrim(SQL->A1_CGC),"@R 99.999.999/9999-99"),oFont10,,CLR_BLACK)
      Else 
         oPrint:Say(940,350,Transform(Alltrim(SQL->A1_CGC),"@R 999.999.999-99"),oFont10,,CLR_BLACK)
      EndIf
      oPrint:Say(940,1580,Alltrim(SQL->A1_INSCR),oFont10,,CLR_BLACK)
      dbSelectArea("SC5")
      SC5->(DbSetOrder(1))                
      If SC5->(dbSeek(xFilial("SC5")+SQL->D2_PEDIDO))
         oPrint:Say(1440,180,Substr(Alltrim(SC5->C5_MENNOTA),1,085),oFont10,,CLR_BLACK)   
      EndIf
      
      oPrint:Say(1440,1880,Transform(SQL->F2_VALMERC,"@E 999,999,999,999.99"),oFont10,,CLR_BLACK)
      oPrint:Say(1500,190,Substr(Alltrim(SC5->C5_MENNOTA),86,85),oFont10,,CLR_BLACK)
      oPrint:Say(1560,190,Substr(Alltrim(SC5->C5_MENNOTA),171,85),oFont10,,CLR_BLACK)
                       
      //cMsgNota:=  Alltrim(SC5->C5_P_NOTA1)+Alltrim(SC5->C5_P_NOTA2)
      //If cMsgNota <> ''     
      //   oPrint:Say(2280,190,Substr(cMsgNota,1,85),oFont10,,CLR_BLACK)
      //   oPrint:Say(2340,190,Substr(cMsgNota,86,85),oFont10,,CLR_BLACK)
      //   oPrint:Say(2400,190,Substr(cMsgNota,171,85),oFont10,,CLR_BLACK)
      //   oPrint:Say(2460,190,Substr(cMsgNota,256,85),oFont10,,CLR_BLACK)
      //   oPrint:Say(2520,190,Substr(cMsgNota,340,85),oFont10,,CLR_BLACK)

      //EndIf
      
     // If SQL->A1_P_MENNF <> ''     
     //    dbSelectArea("SM4")
     //    SM4->(DbSetOrder(1)) 
     //    If SM4->(dbSeek(xFilial("SM4")+SQL->A1_P_MENNF))
     //       oPrint:Say(2820,190,Substr(SM4->M4_FORMULA,1,100),oFont10,,CLR_BLACK)
     //       oPrint:Say(2880,190,Substr(SM4->M4_FORMULA,101,100),oFont10,,CLR_BLACK)
     //    EndIf   
     // EndIf
      
      oPrint:Say(3000,180,Substr(Alltrim(cMenFixo01),1,100),oFont10,,CLR_BLACK)   
      oPrint:Say(3060,180,Substr(Alltrim(cMenFixo01),101,100),oFont10,,CLR_BLACK)   
      oPrint:Say(3250,250,Transform(SQL->F2_BASEICM,"@E 999,999,999,999.99"),oFont10,,CLR_BLACK)   
      If !SQL->F2_TIPO $ 'I' // Se for complemento de ICMS não imprime aliquota - ASK 13/01/2010 - 47714
         oPrint:Say(3250,600,Str(SQL->D2_PICM)+"%",oFont10,,CLR_BLACK)                                    
      EndIf
      oPrint:Say(3250,970,Transform(SQL->F2_VALICM,"@E 999,999,999,999.99"),oFont10,,CLR_BLACK) 
      oPrint:Say(3250,1880,Transform(SQL->F2_VALBRUT,"@E 999,999,999,999.99"),oFont10,,CLR_BLACK) 
        
                               
      SQL->(DbSkip())  
      
   EndDo



     
   //Fecha o arquivo
  SQL->(dbCloseArea())

End Sequence

Return  
       
//-------------------------------------------------------------------------------------------------------------------------------------------------      

*------------------------------*
Static Function BoxGeral(oPrint)   
*------------------------------*
Local L:= 1420
//Private oPen := TPen():New(,7,CLR_BLACK,oPrint)
Private oPen := TPen():New(,7,CLR_BLACK)

Begin Sequence 

   oPrint:Box(160,1450,350,2250)   //Numero nota  
   oPrint:Box(420,1450,600,2250)   //CFOP e DT Emissao  

   oPrint:Line(500,1790,500,2200)   //Linha   
   oPrint:Line(580,1700,580,2200)   //Linha   
   
   oPrint:Box(650,150,1100,2250)     //Cabeçalho
   oPrint:Box(1120,150,1300,2250)    //Fatura
   oPrint:Box(1320,150,3100,2250)    //Itens
   oPrint:Box(3120,150,3300,2250)    //Rodapé
   

   oPrint:Line(1320,1750,3100,1750)   //Coluna 1                        
   oPrint:Line(3120,650,3300,650)     //Coluna 2 
   oPrint:Line(3120,900,3300,900)     //Coluna 3 
   oPrint:Line(3120,1350,3300,1350)   //Coluna 4
   oPrint:Line(3120,1750,3300,1750)   //Coluna 5 
   
   oPrint:Line(580,150,580,1410)   //Linha   
      
   oPrint:Line(743,340,743,2210)   //Usuário  
   oPrint:Line(823,360,823,2210)   //Endereço
   oPrint:Line(903,360,903,1130)   //Municipio  
   oPrint:Line(903,1230,903,2210)  //UF
   oPrint:Line(983,300,983,1130)   //CNPJ  
   oPrint:Line(983,1525,983,2210)  //IE
   oPrint:Line(1063,470,1063,2210) //Contrato

   oPrint:Line(1420,150,1420,2250) 
    
                          
   For h:=1 to 58
      oPrint:Line(L,150,L,2250)   //Linha  
      L:= L +60
      h++
   Next                                    


End Sequence

Return
