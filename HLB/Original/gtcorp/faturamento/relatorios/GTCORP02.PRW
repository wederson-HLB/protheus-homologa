#include "TOTVS.CH"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GTCORP02  ºAutor  Matheus Massarottoº     Data ³  31/01/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Debit Note Grant Thornton                                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºObs       ³Este fonte é a cópia do fonte GTFATINV.prw criado por Tiago º±±
±±º          ³Mendonça, a pedido da Patricia Velasco, chamado: 002770.    º±±
±±º          ³O objetivo desta cópia é somente para alterar algumas       º±±
±±º          ³informações impressas para um modelo de Nota de Débito      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*
Funcao      : GTCORP02()  
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Impressão de Debit Note Grant Thornton.
Autor       : Matheus Massarotto
Data/Hora   : 31/01/2012
*/
*----------------------*
User Function GTCORP02()   
*----------------------*                                      
Private cPerg     := "GTFATND"                    
Private cPedDe    := Space(06)
Private cPedAte   := Space(06) 

Private nBanco    
       
If !(ChkCpo())
	MsgInfo("O campo C6_P_BRL não existe","GT")
    Return .F.
EndIf

If Pergunte(cPerg,.T.)
	cPedDe  := Mv_Par01
 	cPedAte := Mv_Par02
Else  
	Return .F.
Endif      

nBanco:= Mv_Par03  

If Empty(cPedAte)
    MsgStop("Parâmentro 'Pedido Ate' deve ser preechido","Grant Thornton")
	Return .F.
Else
	BuscaDados()
EndIf                                                                      

Return               
        
/*
Funcao      : BuscaDados()  
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Select com o range de pedido informado no parâmetros.
Autor       : Matheus Massarotto
Data/Hora   : 31/01/2012
*/                  
*--------------------------*
Static Function BuscaDados()
*--------------------------*  
Private cNomeArquivo := ""         

Begin Sequence

	If Select("SQL") > 0
   		SQL->(dbCloseArea())
	EndIf

    BeginSql Alias 'SQL' 
        
        //Chamados agrupados por módulos não cancelados
    	SELECT *  
     	FROM %Table:SC5%
      		WHERE %notDel%
        	AND C5_FILIAL = %exp:xFilial("SC5")%  
        	AND C5_NUM>=%exp:cPedDe%
        	AND C5_NUM<=%exp:cPedAte%    	 
    	Order by C5_NUM     
    
    EndSql                      
                                                     
   
   If SQL->(!EoF()) 
      CriaLayout("SQL")
   Else
      Alert("Não foram encontrados pedidos de acordo com o parâmetro selecionado. Por favor, verifique o filtro!")
   EndIf 
   
   
End Sequence

Return                    
      
/*
Funcao      : CriaLayout()  
Parametros  : cNomeArquivo
Retorno     : Nil
Objetivos   : Inicializa a impressão da Debit Note
Autor       : Matheus Massarotto
Data/Hora   : 31/01/2012                                                
*/

*---------------------------------------*
Static Function CriaLayout(cNomeArquivo)   
*---------------------------------------* 
              
//Declara a variável objeto do relatório
Private oPrint

//Cria os objetos fontes que serão utilizadoas através do método TFont()                            
Private oFont5      := TFont():New( "Arial",,07,,.F.,,,,,.F. )            	    // 5        
Private oFont07     := TFont():New('Arial',,07,,.F.,,,,.T.,.F.)   			    // 07
Private oFont07n    := TFont():New('Arial',,08,,.T.,,,,.T.,.F.)   			    // 07       
Private oFont07a    := TFont():New( "Arial",,07,,.t.,,,,,.f. )           		// 07
Private oFont08     := TFont():New('Courier New',08,10,,.F.,,,,.T.,.F.)	  	  	// 08
Private oFont08a    := TFont():New( "Arial",,10,,.t.,,,,,.f. )           	  	// 08
Private oFont08n    := TFont():New('Courier New',08,10,,.T.,,,,.T.,.F.)       	// 08
Private oFont10a    := TFont():New( "Arial",,10,,.t.,,,,,.f. )            	  	// 10
Private oFont10     := TFont():New('Tahoma',10,11,,.F.,,,,.T.,.F.)  	      	// 11
Private oFont10n    := TFont():New('Tahoma',10,11,,.T.,,,,.T.,.F.) 			  	// 11    
Private oFont11     := TFont():New('Tahoma',11,13,,.F.,,,,.T.,.F.) 			  	// 11
Private oFont11n    := TFont():New('Tahoma',11,13,,.T.,,,,.T.,.F.) 			  	// 11    
Private oFont11a    := TFont():New( "Arial",,13,,.t.,,,,,.f. )      			// 11
Private oFont12     := TFont():New("Arial",12,12,,,,,,.T.,.F.) 					// 12
Private oFont12n    := TFont():New('Tahoma',12,14,,.F.,,,,.T.,.F.)  			// 12
Private oFont12a    := TFont():New( "Arial",,12,,.t.,,,,,.f. )      			// 12
Private oFont13     := TFont():New('Tahoma',13,15,,.T.,,,,.T.,.F.)  			// 13
Private oFont14     := TFont():New('Tahoma',14,16,,.T.,,,,.T.,.F.)  			// 14
Private oFont14a    := TFont():New('Arial' ,,14,,.T.,,,,.T.,.F.)  				// 14
Private oFont15     := TFont():New('Courier New',15,16,,.T.,,,,.T.,.F.)  		// 15
Private oFont18     := TFont():New('Ariall',18,20,,.T.,,,,.T.,.T.)   			// 18  
Private oFont16     := TFont():New('Arial',16,18,,.T.,,,,.T.,.F.)   			// 16  
Private oFont20     := TFont():New('Arial',20,20,,.F.,,,,.T.,.F.,.T.)        	// 20       
Private oFont22     := TFont():New('Arial',22,20,,.T.,,,,.T.,.F.,.T.)   			// 20
Private nPagina     := 1

Begin Sequence
   
   //Cria objeto TMSPrinter()               
   oPrint:= TMSPrinter():New( "Relatório de endereçamento - Espectris" )  
      
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
   
      
   End Sequence

Return

/*
Funcao      : ReportHeader()  
Parametros  : oPrint
Retorno     : Nil
Objetivos   : Cabeçario do relatorio.
Autor       : Matheus Massarotto
Data/Hora   : 31/01/2012
*/
*------------------------------------*
Static Function ReportHeader(oPrint)   
*------------------------------------*   

Begin Sequence
      

	//Logo 
   	oPrint:SayBitmap(070,50,"\Logos\gt.bmp",600,170)  

   
   	oPrint:Say(300,100,SM0->M0_NOMECOM,oFont08a,,CLR_BLACK) 
  	oPrint:Say(350,100,SM0->M0_ENDCOB,oFont08a,,CLR_BLACK) 
   	oPrint:Say(400,100,"Zip code "+Substr(SM0->M0_CEPCOB,1,5)+"-"+Substr(SM0->M0_CEPCOB,6,3)+" - "+Alltrim(SM0->M0_CIDCOB)+" - "+Alltrim(SM0->M0_ESTCOB)+" - Brazil",oFont08a,,CLR_BLACK) 
   	oPrint:Say(450,100,"Phone : +"+Substr(SM0->M0_TEL,1,2)+" "+Substr(SM0->M0_TEL,3,2)+" "+Substr(SM0->M0_TEL,5,4)+" "+Substr(SM0->M0_TEL,9,4),oFont08a,,CLR_BLACK)     
   
   	oPrint:Say(080,1800,"Debit Note",oFont22,,CLR_BLACK)
   
   	oPrint:Say(300,1800,"Date:",oFont08a,,CLR_BLACK) 
   	oPrint:Say(350,1800,"Debit Note:",oFont08a,,CLR_BLACK) 
   	oPrint:Say(400,1800,"Currency:",oFont08a,,CLR_BLACK) 
    oPrint:Say(450,1800,"Exchange Rate:",oFont08a,,CLR_BLACK)
   	oPrint:Say(500,1800,"Due Date:",oFont08a,,CLR_BLACK)   
//   	oPrint:Say(550,1800,"Reference:",oFont08a,,CLR_BLACK) 
   
   	oPrint:Say(600,350,"To:",oFont08a,,CLR_BLACK)

   	oPrint:Say(910,120 ,"Description ",oFont08a,,CLR_BLACK) 
   	oPrint:Say(910,1300,"BRL",oFont08a,,CLR_BLACK) 
   	oPrint:Say(910,1600,"Qt ",oFont08a,,CLR_BLACK)    
   	oPrint:Say(910,1750,"Unit Price",oFont08a,,CLR_BLACK) 	
   	oPrint:Say(910,2120,"Total",oFont08a,,CLR_BLACK) 		
   
   	oPrint:Say(1900,1900,"Total",oFont08a,,CLR_BLACK)    
     	

End Sequence                                          

Return  
   

/*
Funcao      : ReportDetail()  
Parametros  : oPrint
Retorno     : Nil
Objetivos   : Detalhes do relatorio.
Autor       : Matheus Massarotto
Data/Hora   : 31/01/2012
*/

*-------------------------------------*
 Static Function ReportDetail(oPrint)   
*-------------------------------------*   


Private n         := 0
Private nTotal    := 0 
Private nTaxa     := 0 

Private cSigla    := ""
Private cMoeda    := ""
Private cNum      := ""  

Private nLinha  := 1050  
      
    SQL->(DbGoTop())   
    
    cNum:=SQL->C5_NUM
    
    While SQL->(!EOF())  
                      
   	   	IncProc("Aguarde, lendo cadastro de produtos ..." +Alltrim(str(N))) 
                               
        If cNum<>SQL->C5_NUM 
        	
        	oPrint:EndPage()   
 	 		oPrint:StartPage() 
  			oPrint:SetPortrait()
   			oPrint:SetpaperSize(9)
         
  			//Molduras externas
    		BoxGeral(oPrint) 
      
   			//Cria o Cabeçalho do Relatório
   			ReportHeader(oPrint)      
                       
    		//Reseta a linha
  			nLinha       := 1050
  			nTotal       := 0   
        
        EndIf
                     
        MsgBco(SQL->C5_MOEDA)        

		SYA->(DbSetOrder(1))
        SA1->(DbSetOrder(1))   
        SA1->(DbSeek(xFilial("SA1") + SQL->C5_CLIENTE + SQL->C5_LOJACLI))

		Do Case
			Case cEmpAnt $ "ZB/ZF" .and. !EMPTY(SQL->C5_MDCONTR)
				aDadosCob := {"","","","","",""}
				cQryCN9 := " Select *
				cQryCN9 += " From "+RETSQLNAME("CN9")+" CN9
				cQryCN9 += " 	Left Outer Join(Select * From "+RETSQLNAME("Z55")+" Where D_E_L_E_T_ <> '*') as Z55 On Z55.Z55_FILIAL = CN9.CN9_FILIAL
				cQryCN9 += " 									AND Z55.Z55_NUM = CN9.CN9_P_NUM
				cQryCN9 += " 									AND Z55.Z55_REVATU = ''
				cQryCN9 += " Where CN9.D_E_L_E_T_ <> '*'
				cQryCN9 += " 	AND Z55.Z55_FILIAL <> ''
				cQryCN9 += " 	AND CN9.CN9_NUMERO = '"+SQL->C5_MDCONTR+"'
                cQryCN9 += "    AND CN9_FILIAL='"+xFilial("CN9")+"'"

				If Select("QRYCN9")>0
					QRYCN9->(DbCloseArea())
				EndIf
				DbUseArea( .T., "TOPCONN", TcGenqry(,,cQryCN9), "QRYCN9", .F., .F. )

				QRYCN9->(DbGoTop())
				If QRYCN9->(!EOF())
					If !(SA1->(DbSeek(xFilial("SA1") + QRYCN9->Z55_CLIENTE + QRYCN9->Z55_LOJA)))  
						MsgAlert("Cliente não encontrado")
			    	EndIf
   					aDadosCob := {	ALLTRIM(QRYCN9->Z55_CLIGLO),;//Nome cliente
  									ALLTRIM(QRYCN9->Z55_COBEND),;//Endereço de cobrança
									ALLTRIM(QRYCN9->Z55_COBBAI),;//Bairro de cobrança
									ALLTRIM(QRYCN9->Z55_COBMUN),;//Municipio de cobrança.
									ALLTRIM(QRYCN9->Z55_COBRES),;//Responsavel de cobrança.
									ALLTRIM(QRYCN9->Z55_COBEMA);//Email de cobrança.
   								}
				Else
			   		MsgAlert("Proposta/contrato não encontrado")
				EndIf
            //MSM - 11/08/2015 - Chamado: 028186, adicionado tratamendo para buscar dados da proposta caso o pedido tenha sido incluído manualmente
            Case cEmpAnt $ "ZB/ZF" .and. !EMPTY(SQL->C5_P_NUM)
				
				aDadosCob := {"","","","","",""}
				cQryZ55 := " SELECT Z55_CLIENT,Z55_LOJA,Z55_CLIGLO,Z55_COBEND,Z55_COBBAI,Z55_COBMUN,Z55_COBRES,Z55_COBEMA
				cQryZ55 += " FROM "+RETSQLNAME("Z55")+" Z55
				cQryZ55 += " WHERE D_E_L_E_T_=''
				//cQryZ55 += " 	AND Z55.Z55_FILIAL = '"+ALLTRIM(SQL->C5_FILIAL)+"'" //MSM - 15/10/2015 - Chamado: 029721
				cQryZ55 += " 	AND Z55.Z55_REVATU = ''
				cQryZ55 += " 	AND Z55.Z55_NUM='"+ALLTRIM(SQL->C5_P_NUM)+"'"

				If Select("QRYZ55")>0
					QRYZ55->(DbCloseArea())
				EndIf
				DbUseArea( .T., "TOPCONN", TcGenqry(,,cQryZ55), "QRYZ55", .F., .F. )

				QRYZ55->(DbGoTop())
				If QRYZ55->(!EOF())
					If !(SA1->(DbSeek(xFilial("SA1") + QRYZ55->Z55_CLIENT + QRYZ55->Z55_LOJA)))  
						MsgAlert("Cliente não encontrado")
			    	EndIf
   					aDadosCob := {	ALLTRIM(QRYZ55->Z55_CLIGLO),;//Nome cliente
  									ALLTRIM(QRYZ55->Z55_COBEND),;//Endereço de cobrança
									ALLTRIM(QRYZ55->Z55_COBBAI),;//Bairro de cobrança
									ALLTRIM(QRYZ55->Z55_COBMUN),;//Municipio de cobrança.
									ALLTRIM(QRYZ55->Z55_COBRES),;//Responsavel de cobrança.
									ALLTRIM(QRYZ55->Z55_COBEMA);//Email de cobrança.
   								}
				Else
			   		MsgAlert("Proposta não encontrada")
				EndIf
								
			OtherWise
		    	If !(SA1->(DbSeek(xFilial("SA1")+SQL->C5_CLIENT+SQL->C5_LOJACLI)))  
		    	   MsgAlert("Cliente não encontrado")
		    	Endif
		EndCase
    	   
    	SM2->(DbSetOrder(1))
    	If !(SM2->(DbSeek(SQL->C5_EMISSAO)))
    		MsgInfo("Taxa para o dia "+SQL->C5_EMISSAO+" (yyyy/mm/dd) não econtrado.","GT")         	   
    	EndIf
    	             
    	If SQL->C5_MOEDA==1
    		cMoeda:="Real"
    		nTaxa :=1   
    		cSigla:="R$"
    	ElseIf SQL->C5_MOEDA==2
    		cMoeda:="Dolar"    
    		nTaxa := SM2->M2_MOEDA2
    		cSigla:="USD"   
    	ElseIf SQL->C5_MOEDA==3
    		cMoeda:="Libra" 
    		nTaxa := SM2->M2_MOEDA3 
    		cSigla:="GBP"	
    	ElseIf SQL->C5_MOEDA==5
    		cMoeda:="Euro" 
    		nTaxa := SM2->M2_MOEDA5 
    		cSigla:="EUR"
    	EndIf	
    	
    	//oPrint:Say(300,2000,SubStr(Alltrim(SQL->C5_EMISSAO),1,4)+"-"+substr(Alltrim(SQL->C5_EMISSAO),5,2)+"-"+SubStr(Alltrim(SQL->C5_EMISSAO),7,2),oFont08a,,CLR_BLACK) 
   		oPrint:Say(300,2020,SubStr(Alltrim(SQL->C5_EMISSAO),7,2)+"/"+substr(Alltrim(SQL->C5_EMISSAO),5,2)+"/"+SubStr(Alltrim(SQL->C5_EMISSAO),1,4),oFont08a,,CLR_BLACK) 
   		oPrint:Say(350,2020,SQL->C5_NUM,oFont08a,,CLR_BLACK) 
   		oPrint:Say(400,2020,cMoeda,oFont08a,,CLR_BLACK) 		
  		oPrint:Say(450,2075,Transform(nTaxa,"@E 9.9999"),oFont08a,,CLR_BLACK)
  		If !Empty(SQL->C5_DATA1)
  			oPrint:Say(500,2020,SubStr(Alltrim(SQL->C5_DATA1),7,2)+"/"+substr(Alltrim(SQL->C5_DATA1),5,2)+"/"+SubStr(Alltrim(SQL->C5_DATA1),1,4),oFont08a,,CLR_BLACK) 
   		EndIf
   		//oPrint:Say(550,2020,cMonth(CTOD(SubStr(Alltrim(SQL->C5_EMISSAO),7,2)+"/"+substr(Alltrim(SQL->C5_EMISSAO),5,2)+"/"+SubStr(Alltrim(SQL->C5_EMISSAO),1,4)))+" - "+SubStr(Alltrim(SQL->C5_EMISSAO),3,2),oFont08a,,CLR_BLACK)  
     	If cEmpAnt $ "ZB/ZF" .and. ( !EMPTY(SQL->C5_MDCONTR) .OR. !EMPTY(SQL->C5_P_NUM))  //JVR
	     	oPrint:Say(600,450,Substr(Alltrim(SA1->A1_NOME)+" - "+aDadosCob[1]+" ("+Alltrim(SA1->A1_COD)+"/"+Alltrim(SA1->A1_LOJA)+")",1,95),oFont08a,,CLR_BLACK)
	   		If !EMPTY(aDadosCob[2])
		   		oPrint:Say(650,450,Substr(aDadosCob[2],1,95),oFont08a,,CLR_BLACK)
		   		oPrint:Say(700,450,aDadosCob[3]+" -  "+aDadosCob[4],oFont08a,,CLR_BLACK)
	   		Else
		   		oPrint:Say(650,450,Substr(Alltrim(SA1->A1_P_END),1,95),oFont08a,,CLR_BLACK) 
		   		oPrint:Say(700,450,Alltrim(SA1->A1_P_CID)+" -  "+Alltrim(SA1->A1_P_PAIS),oFont08a,,CLR_BLACK)	   		
	   		EndIf
	   		oPrint:Say(750,450,aDadosCob[5],oFont08a,,CLR_BLACK)
   			oPrint:Say(800,450,aDadosCob[6],oFont08a,,CLR_BLACK)
		Else
	     	oPrint:Say(600,450,Substr(Alltrim(SA1->A1_P_CUSTO)+" ("+Alltrim(SA1->A1_COD)+"/"+Alltrim(SA1->A1_LOJA)+")",1,95),oFont08a,,CLR_BLACK)		
	   		oPrint:Say(650,450,Substr(Alltrim(SA1->A1_P_END),1,95),oFont08a,,CLR_BLACK) 
	   		oPrint:Say(700,450,Alltrim(SA1->A1_P_CID)+" -  "+Alltrim(SA1->A1_P_PAIS),oFont08a,,CLR_BLACK)
	   		If !Empty(SA1->A1_P_ATT)
	        	oPrint:Say(750,450,Alltrim(SA1->A1_P_ATT),oFont08a,,CLR_BLACK)
	        EndIf
			If !Empty(SA1->A1_P_EMAIL)
    	    	oPrint:Say(800,450,Alltrim(SA1->A1_P_EMAIL),oFont08a,,CLR_BLACK)
	        EndIf  
		EndIf
        
	    oPrint:Say(1900,2030,alltrim(cSigla),oFont08a,,CLR_BLACK)  	
  		
  		If SYA->(DbSeek(xFilial("SYA")+SA1->A1_PAIS))
    		oPrint:Say(750,450,SYA->YA_DESCR,oFont08a,,CLR_BLACK)
        EndIf 
        
        SC6->(DbSetOrder(1))
        SB1->(DbSetOrder(1))  
                  
        If SC6->(DbSeek(xFilial("SC6")+SQL->C5_NUM))
           
        	While SC6->(!EOF()) .And. SC6->C6_NUM == SQL->C5_NUM  
        	
        		SB1->(DbSeek(xFilial("SB1")+SC6->C6_PRODUTO))
        	   
        		oPrint:Say(nLinha,120,Substr(alltrim(SB1->B1_P_IDESC)+" "+alltrim(SC6->C6_DESCRIC),1,50),oFont08,,CLR_BLACK)  
        		If Len(alltrim(alltrim(SB1->B1_P_IDESC)+" "+alltrim(SC6->C6_DESCRIC)))>50 
        			oPrint:Say(nLinha+=50,120,Substr(alltrim(SB1->B1_P_IDESC)+" "+alltrim(SC6->C6_DESCRIC),51,50),oFont08,,CLR_BLACK)	
        		 	If Len(alltrim(alltrim(SB1->B1_P_IDESC)+" "+alltrim(SC6->C6_DESCRIC)))>100 
        				oPrint:Say(nLinha+=50,120,Substr(alltrim(SB1->B1_P_IDESC)+" "+alltrim(SC6->C6_DESCRIC),101,50),oFont08,,CLR_BLACK)	
        			EndIf       		
        		EndIf
        		
        		If !Empty(SC6->C6_P_BRL)
        			oPrint:Say(nLinha,1250,Transform(SC6->C6_P_BRL,"@E 9,999,999.99"),oFont08) 
        		EndIf
        		
        		oPrint:Say(nLinha,1550,Transform(SC6->C6_QTDVEN,"@E 999.99"),oFont08) 	
        	    oPrint:Say(nLinha,1720,Transform(SC6->C6_PRCVEN,"@E 9,999,999.99"),oFont08) 
        	 	oPrint:Say(nLinha,2050,Transform(SC6->C6_VALOR,"@E 9,999,999.99"),oFont08)
        	 	
        	 	nLinha+=100
        	 	
        	 	ChkLinha()   
        	 	      	 	
        	                 
        	    nTotal+=SC6->C6_VALOR
        	    
        		SC6->(DbSkip())
        		       		        		   
        	EndDo 
             
            oPrint:Say(1950,2050,Transform(nTotal,"@E 9,999,999.99"),oFont08) 
                              
       EndIf
       n++
            
       oPrint:Say(1980,100,Substr(SQL->C5_MENNOTA,1,75),oFont08)   
       oPrint:Say(2030,100,Substr(SQL->C5_MENNOTA,76,75),oFont08)     
       oPrint:Say(2080,100,Substr(SQL->C5_MENNOTA,151,75),oFont08) 
       oPrint:Say(2130,100,Substr(SQL->C5_OBS,1,75),oFont08) 
       oPrint:Say(2130,100,Substr(SQL->C5_OBS,76,75),oFont08)  
         
       SQL->(DbSkip())
  EndDo 
  

   //Fecha o arquivo
  SQL->(dbCloseArea())

Return  
       

/*
Funcao      : BOXGeral()  
Parametros  : oPrint
Retorno     : Nil
Objetivos   : Criar o layout do relatório.
Autor       : Matheus Massarotto
Data/Hora   : 31/01/2012
*/
  
*--------------------------------*
 Static Function BoxGeral(oPrint)   
*--------------------------------*  

Local oBrush

	oBrush := TBrush():New( , CLR_GRAY )


	oPrint:FillRect({895 , 99, 955 , 2370}, oBrush)   
	oPrint:FillRect({2275, 99, 2350, 2370}, oBrush) 
	oPrint:FillRect({2500, 99, 2595, 2370}, oBrush) 
	
	oPrint:Line(895,100,895,2370)     //Linha 
	oPrint:Line(955,100,955,2370)     //Linha 
	oPrint:Line(2000,2000,2000,2370)  //Linha 
	
	oPrint:Line(895,101 ,1900,101)   //Coluna
	oPrint:Line(895,1250,1900,1250)  //Coluna
   	oPrint:Line(895,1550,1900,1550)  //Coluna
   	oPrint:Line(895,1700,1900,1700)  //Coluna
   	oPrint:Line(895,2000,2000,2000)  //Coluna
	oPrint:Line(895,2370,2000,2370)  //Coluna
	  
	oPrint:Line(1900,100,1900,2370)   //Linha   
                      
Return
    

/*
Funcao      : ChkLinha()  
Parametros  :
Retorno     : Nil
Objetivos   : Validar o limite do relatorio.
Autor       : Matheus Massarotto
Data/Hora   : 31/01/2012
*/
     
*--------------------------*             
 Static Function ChkLinha()
*--------------------------*

If nLinha > 1900  
         
	oPrint:EndPage()   
 	oPrint:StartPage() 
  	oPrint:SetPortrait()
   	oPrint:SetpaperSize(9)
         
  	//Molduras externas
    BoxGeral(oPrint) 
      
   	//Cria o Cabeçalho do Relatório
   	ReportHeader(oPrint)      
                       
    //Reseta a linha
  	nLinha       := 1050   
                    
 
 
        MsgBco(SQL->C5_MOEDA)        
                                 
        SA1->(DbSetOrder(1))
    	SYA->(DbSetOrder(1))
    	
    	If !(SA1->(DbSeek(xFilial("SA1")+SQL->C5_CLIENT+SQL->C5_LOJACLI)))  
    	   MsgAlert("Cliente não encontrado")
    	EndiF
    	   
    	SM2->(DbSetOrder(1))
    	If !(SM2->(DbSeek(SQL->C5_EMISSAO)))
    		MsgInfo("Taxa para o dia "+SQL->C5_EMISSAO+" (yyyy/mm/dd) não econtrado.","GT")         	   
    	EndIf
    	             
    	If SQL->C5_MOEDA==1
    		cMoeda:="Real"
    		nTaxa :=1   
    		cSigla:="R$"
    	ElseIf SQL->C5_MOEDA==2
    		cMoeda:="Dolar"    
    		nTaxa := SM2->M2_MOEDA2
    		cSigla:="USD"
 		ElseIf SQL->C5_MOEDA==3
    		cMoeda:="Libra" 
    		nTaxa := SM2->M2_MOEDA3 
    		cSigla:="GBP"  		
    	ElseIf SQL->C5_MOEDA==5
    		cMoeda:="Euro" 
    		nTaxa := SM2->M2_MOEDA5 
    		cSigla:="EUR"
    	EndIf	
    	
    	//oPrint:Say(300,2000,SubStr(Alltrim(SQL->C5_EMISSAO),1,4)+"-"+substr(Alltrim(SQL->C5_EMISSAO),5,2)+"-"+SubStr(Alltrim(SQL->C5_EMISSAO),7,2),oFont08a,,CLR_BLACK) 
   		oPrint:Say(300,2020,SubStr(Alltrim(SQL->C5_EMISSAO),7,2)+"/"+substr(Alltrim(SQL->C5_EMISSAO),5,2)+"/"+SubStr(Alltrim(SQL->C5_EMISSAO),1,4),oFont08a,,CLR_BLACK) 
   		oPrint:Say(350,2020,SQL->C5_NUM,oFont08a,,CLR_BLACK) 
   		oPrint:Say(400,2020,cMoeda,oFont08a,,CLR_BLACK) 		
  		oPrint:Say(450,2075,Transform(nTaxa,"@E 9.9999"),oFont08a,,CLR_BLACK)
  		If !Empty(SQL->C5_DATA1)
  			oPrint:Say(500,2020,SubStr(Alltrim(SQL->C5_DATA1),7,2)+"/"+substr(Alltrim(SQL->C5_DATA1),5,2)+"/"+SubStr(Alltrim(SQL->C5_DATA1),1,4),oFont08a,,CLR_BLACK) 
   		EndIf
   		oPrint:Say(550,2020,cMonth(CTOD(SubStr(Alltrim(SQL->C5_EMISSAO),7,2)+"/"+substr(Alltrim(SQL->C5_EMISSAO),5,2)+"/"+SubStr(Alltrim(SQL->C5_EMISSAO),1,4)))+" - "+SubStr(Alltrim(SQL->C5_EMISSAO),3,2),oFont08a,,CLR_BLACK)  
     	oPrint:Say(600,450,Substr(Alltrim(SA1->A1_P_CUSTO),1,95),oFont08a,,CLR_BLACK) 
   		oPrint:Say(650,450,Substr(Alltrim(SA1->A1_P_END),1,95),oFont08a,,CLR_BLACK) 
   		oPrint:Say(700,450,Alltrim(SA1->A1_P_CID)+" -  "+Alltrim(SA1->A1_P_PAIS),oFont08a,,CLR_BLACK)
   		If !Empty(SA1->A1_P_ATT)
        	oPrint:Say(750,450,Alltrim(SA1->A1_P_ATT),oFont08a,,CLR_BLACK)
        EndIf   
        If !Empty(SA1->A1_P_EMAIL)
        	oPrint:Say(800,450,Alltrim(SA1->A1_P_EMAIL),oFont08a,,CLR_BLACK)
        EndIf 
        
	    oPrint:Say(1900,2030,alltrim(cSigla),oFont08a,,CLR_BLACK)  	
  		
  		If SYA->(DbSeek(xFilial("SYA")+SA1->A1_PAIS))
    		oPrint:Say(750,450,SYA->YA_DESCR,oFont08a,,CLR_BLACK)
        EndIf 
 
                                              
EndIf         


Return  
       
  
  /*
Funcao      : ChkCpo()  
Parametros  : 
Retorno     : .T. ou .F.
Objetivos   : Validar campos para o relatório
Autor       : Matheus Massarotto
Data/Hora   : 31/01/2012
*/
     
*--------------------------*             
 Static Function ChkCpo()
*--------------------------*     

Local lRet :=.F. 

//Campo valor reais
If SC6->(FieldPos("C6_P_BRL"))>0        
	lRet :=.T.                                          
EndIF


Return lRet

  /*
Funcao      : MsgBco()  
Parametros  : 
Retorno     : .T. ou .F.
Objetivos   : Mensagens de banco por empresa
Autor       : Matheus Massarotto
Data/Hora   : 31/01/2012
*/

*-------------------------------*             
 Static Function MsgBco(cMoe)
*-------------------------------*   

If SM0->M0_CODIGO $ "Z4" 

    
 	If nBanco == 1
	 
		If  cMoe == 2    
		
		   	oPrint:Say(2200,100,"Please make payment arranging a direct deposit in our our account as follows: ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2300,500,"Wire transfer ( PLEASE PAY VIA REMITTANCE - WE CANNOT A ACCEPT CHECKS ) ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2350,800,"Account with  : Deutsche Bank Trust Company Américas - New York ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2400,800,"Swift Code      : BKTRUS33 ",oFont08a,,CLR_BLACK)      
	   		oPrint:Say(2450,800,"Account Nr      : 04004949 ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2500,800,"In favor of       : Banco Itaú S.A. ",oFont08a,,CLR_BLACK)     
	   		oPrint:Say(2550,800,"Swift Code      : ITAUBRSP ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2600,800,"For Further Credit to:	GRANT THORNTON CONSULTING SERVICES LTDA. ",oFont08a,,CLR_BLACK)  	
	   		oPrint:Say(2650,800,"Branch Number   : 0190 ",oFont08a,,CLR_BLACK)
	   		
	   		If SM0->M0_CODFIL $ "01/02/03"  //Lapa , Rio de Janeiro e Porto Alegre
	   			oPrint:Say(2700,800,"Account Number : 41.473-0 ",oFont08a,,CLR_BLACK) 
	   		Else
	   			oPrint:Say(2700,800,"Account Number : 38.560-9 ",oFont08a,,CLR_BLACK) 
	   		EndIf
	   		
	   	   
	 	ElseIf cMoe == 5 .Or. cMoe == 3  
	 	
	 		oPrint:Say(2200,100,"Please make payment arranging a direct deposit in our our account as follows: ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2300,500,"Wire transfer ( PLEASE PAY VIA REMITTANCE - WE CANNOT A ACCEPT CHECKS ) ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2350,800,"Account with  : ING Belgium NV - Bruxelas ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2400,800,"Swift Code      : BBRUBEBB010 ",oFont08a,,CLR_BLACK)      
	   		oPrint:Say(2450,800,"Account Nr      : 301-0104579-94 ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2500,800,"In favor of       : Banco Itaú S.A. ",oFont08a,,CLR_BLACK)     
	   		oPrint:Say(2550,800,"Swift Code      : ITAUBRSP ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2600,800,"For Further Credit to:	GRANT THORNTON CONSULTING SERVICES LTDA. ",oFont08a,,CLR_BLACK)  	
	   		oPrint:Say(2650,800,"Branch Number   : 0190 ",oFont08a,,CLR_BLACK)
	    		
	   		If SM0->M0_CODFIL == "01/02/03"  //Lapa , Rio de Janeiro e Porto Alegre 
	   			oPrint:Say(2700,800,"Account Number : 41.473-0 ",oFont08a,,CLR_BLACK) 
	   		Else
	   			oPrint:Say(2700,800,"Account Number : 38.560-9 ",oFont08a,,CLR_BLACK) 
	   		EndIf
	
		EndIf 
		
	Else
	
		If  cMoe == 2    
		
		   	oPrint:Say(2200,100,"Please make payment arranging a direct deposit in our our account as follows: ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2300,500,"Wire transfer ( PLEASE PAY VIA REMITTANCE - WE CANNOT A ACCEPT CHECKS ) ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2350,800,"Account with  : Standard Chartered Bank – New York – USA ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2400,800,"Swift(Bic Code): SCBLUS33XXX ",oFont08a,,CLR_BLACK)      
	   		oPrint:Say(2450,800,"Clearing Code: ABA 026002561 / CHIPS UID 0256",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2500,800,"In favor of       : Banco Santander (Brasil) S.A. ",oFont08a,,CLR_BLACK)     
	   		oPrint:Say(2550,800,"Swift Code      : BSCHBRSP ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2600,800,"For Further Credit to:	GRANT THORNTON CONSULTING SERVICES LTDA. ",oFont08a,,CLR_BLACK)  	
	   		oPrint:Say(2650,800,"Branch Number   : 3853 ",oFont08a,,CLR_BLACK)
	   		
	   		If SM0->M0_CODFIL == "01/02/03"  //Lapa , Rio de Janeiro e Porto Alegre 
	   			oPrint:Say(2700,800,"Account Number : 13-000316-7 ",oFont08a,,CLR_BLACK) 
	   		Else
	   			oPrint:Say(2700,800,"Account Number : 13-000515-2 ",oFont08a,,CLR_BLACK) 
	   		EndIf
	   		
	   	   
	 	ElseIf cMoe == 5 .Or. cMoe == 3 
	 	
		   	oPrint:Say(2200,100,"Please make payment arranging a direct deposit in our our account as follows: ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2300,500,"Wire transfer ( PLEASE PAY VIA REMITTANCE - WE CANNOT A ACCEPT CHECKS ) ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2350,800,"Account with  : Banco Santander S/A – Madrid – España  ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2400,800,"Swift(Bic Code): BSCHESMMXXX ",oFont08a,,CLR_BLACK)      
	   		oPrint:Say(2450,800,"Clearing Code: 15439",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2500,800,"In favor of       : Banco Santander (Brasil) S.A. ",oFont08a,,CLR_BLACK)     
	   		oPrint:Say(2550,800,"Swift Code      : BSCHBRSP ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2600,800,"For Further Credit to:	GRANT THORNTON CONSULTING SERVICES LTDA. ",oFont08a,,CLR_BLACK)  	
	   		oPrint:Say(2650,800,"Branch Number   : 3853 ",oFont08a,,CLR_BLACK)
	   		
	   		If SM0->M0_CODFIL == "01/02/03"  //Lapa , Rio de Janeiro e Porto Alegre 
	   			oPrint:Say(2700,800,"Account Number : 13-000316-7 ",oFont08a,,CLR_BLACK) 
	   		Else
	   			oPrint:Say(2700,800,"Account Number : 13-000515-2 ",oFont08a,,CLR_BLACK) 
	   		EndIf
	
		EndIf

	
	EndIf   

ElseIf SM0->M0_CODIGO $ "ZF"

	If nBanco == 1

		If  cMoe == 2    
		
		   	oPrint:Say(2200,100,"Please make payment arranging a direct deposit in our our account as follows: ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2300,500,"Wire transfer ( PLEASE PAY VIA REMITTANCE - WE CANNOT A ACCEPT CHECKS ) ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2350,800,"Account with  : Deutsche Bank Trust Company Américas - New York ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2400,800,"Swift Code      : BKTRUS33 ",oFont08a,,CLR_BLACK)      
	   		oPrint:Say(2450,800,"Account Nr      : 04004949 ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2500,800,"In favor of       : Banco Itaú S.A. ",oFont08a,,CLR_BLACK)     
	   		oPrint:Say(2550,800,"Swift Code      : ITAUBRSP ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2600,800,"For Further Credit to:	GRANT THORNTON CORPORATE CONSULTORES DE NEGÓCIOS LTDA.",oFont08a,,CLR_BLACK)  	
	   		oPrint:Say(2650,800,"Branch Number   : 0190 ",oFont08a,,CLR_BLACK)
			oPrint:Say(2700,800,"Account Number : 38.560-9 ",oFont08a,,CLR_BLACK) 
	
	   		
	   	   
	 	ElseIf cMoe == 5 .Or. cMoe == 3 
	 	
	 		oPrint:Say(2200,100,"Please make payment arranging a direct deposit in our our account as follows: ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2300,500,"Wire transfer ( PLEASE PAY VIA REMITTANCE - WE CANNOT A ACCEPT CHECKS ) ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2350,800,"Account with  : ING Belgium NV - Bruxelas ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2400,800,"Swift Code      : BBRUBEBB010 ",oFont08a,,CLR_BLACK)      
	   		oPrint:Say(2450,800,"Account Nr      : 301-0104579-94 ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2500,800,"In favor of       : Banco Itaú S.A. ",oFont08a,,CLR_BLACK)     
	   		oPrint:Say(2550,800,"Swift Code      : ITAUBRSP ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2600,800,"For Further Credit to: GRANT THORNTON CORPORATE CONSULTORES DE NEGÓCIOS LTDA. ",oFont08a,,CLR_BLACK)  	
	   		oPrint:Say(2650,800,"Branch Number   : 0190 ",oFont08a,,CLR_BLACK)
	    	oPrint:Say(2700,800,"Account Number : 38.560-9 ",oFont08a,,CLR_BLACK) 
	   	
		EndIf   
	
	Else
	
		If  cMoe == 2    
		
		   	oPrint:Say(2200,100,"Please make payment arranging a direct deposit in our our account as follows: ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2300,500,"Wire transfer ( PLEASE PAY VIA REMITTANCE - WE CANNOT A ACCEPT CHECKS ) ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2350,800,"Account with  : Standard Chartered Bank – New York – USA ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2400,800,"Swift(Bic Code): SCBLUS33XXX ",oFont08a,,CLR_BLACK)      
	   		oPrint:Say(2450,800,"Clearing Code: ABA 026002561 / CHIPS UID 0256",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2500,800,"In favor of       : Banco Santander (Brasil) S.A. ",oFont08a,,CLR_BLACK)     
	   		oPrint:Say(2550,800,"Swift Code      : BSCHBRSP ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2600,800,"For Further Credit to:	GRANT THORNTON CORPORATE CONSULTORES DE NEGÓCIOS LTDA. ",oFont08a,,CLR_BLACK)  	
	   		oPrint:Say(2650,800,"Branch Number   : 3853 ",oFont08a,,CLR_BLACK)
	 		oPrint:Say(2700,800,"Account Number : 13-005983-8 ",oFont08a,,CLR_BLACK) 	   		
	   	   
	 	ElseIf cMoe == 5 .Or. cMoe == 3 
	 	
		   	oPrint:Say(2200,100,"Please make payment arranging a direct deposit in our our account as follows: ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2300,500,"Wire transfer ( PLEASE PAY VIA REMITTANCE - WE CANNOT A ACCEPT CHECKS ) ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2350,800,"Account with  : Banco Santander S/A – Madrid – España  ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2400,800,"Swift(Bic Code): BSCHESMMXXX ",oFont08a,,CLR_BLACK)      
	   		oPrint:Say(2450,800,"Clearing Code: 15439",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2500,800,"In favor of       : Banco Santander (Brasil) S.A. ",oFont08a,,CLR_BLACK)     
	   		oPrint:Say(2550,800,"Swift Code      : BSCHBRSP ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2600,800,"For Further Credit to:	GRANT THORNTON CORPORATE CONSULTORES DE NEGÓCIOS LTDA. ",oFont08a,,CLR_BLACK)  	
	   		oPrint:Say(2650,800,"Branch Number   : 3853 ",oFont08a,,CLR_BLACK)
	 		oPrint:Say(2700,800,"Account Number : 13-005983-8 ",oFont08a,,CLR_BLACK) 
	
		EndIf
	
	EndIf  
	
	
ElseIf SM0->M0_CODIGO $ "ZB"

	If nBanco == 1


		If  cMoe == 2    
		
		   	oPrint:Say(2200,100,"Please make payment arranging a direct deposit in our our account as follows: ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2300,500,"Wire transfer ( PLEASE PAY VIA REMITTANCE - WE CANNOT A ACCEPT CHECKS ) ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2350,800,"Account with  : Deutsche Bank Trust Company Américas - New York ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2400,800,"Swift Code      : BKTRUS33 ",oFont08a,,CLR_BLACK)      
	   		oPrint:Say(2450,800,"Account Nr      : 04004949 ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2500,800,"In favor of       : Banco Itaú S.A. ",oFont08a,,CLR_BLACK)     
	   		oPrint:Say(2550,800,"Swift Code      : ITAUBRSP ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2600,800,"For Further Credit to:	GRANT THORNTON AUDITORES INDEPENDENTES. ",oFont08a,,CLR_BLACK)  	
	   		oPrint:Say(2650,800,"Branch Number   : 0190 ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2700,800,"Account Number : 38.560-9 ",oFont08a,,CLR_BLACK) 
	   		
	 	ElseIf cMoe == 5 .Or. cMoe == 3 
	 	
	 		oPrint:Say(2200,100,"Please make payment arranging a direct deposit in our our account as follows: ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2300,500,"Wire transfer ( PLEASE PAY VIA REMITTANCE - WE CANNOT A ACCEPT CHECKS ) ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2350,800,"Account with  : ING Belgium NV - Bruxelas ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2400,800,"Swift Code      : BBRUBEBB010 ",oFont08a,,CLR_BLACK)      
	   		oPrint:Say(2450,800,"Account Nr      : 301-0104579-94 ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2500,800,"In favor of       : Banco Itaú S.A. ",oFont08a,,CLR_BLACK)     
	   		oPrint:Say(2550,800,"Swift Code      : ITAUBRSP ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2600,800,"For Further Credit to:	GRANT THORNTON AUDITORES INDEPENDENTES.",oFont08a,,CLR_BLACK)  	
	   		oPrint:Say(2650,800,"Branch Number   : 0190 ",oFont08a,,CLR_BLACK)
	    	oPrint:Say(2700,800,"Account Number : 38.560-9 ",oFont08a,,CLR_BLACK) 
	   	
		EndIf   
	
	Else
	
		If  cMoe == 2    
		
		   	oPrint:Say(2200,100,"Please make payment arranging a direct deposit in our our account as follows: ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2300,500,"Wire transfer ( PLEASE PAY VIA REMITTANCE - WE CANNOT A ACCEPT CHECKS ) ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2350,800,"Account with  : Standard Chartered Bank – New York – USA ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2400,800,"Swift(Bic Code): SCBLUS33XXX ",oFont08a,,CLR_BLACK)      
	   		oPrint:Say(2450,800,"Clearing Code: ABA 026002561 / CHIPS UID 0256",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2500,800,"In favor of       : Banco Santander (Brasil) S.A. ",oFont08a,,CLR_BLACK)     
	   		oPrint:Say(2550,800,"Swift Code      : BSCHBRSP ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2600,800,"For Further Credit to:	GRANT THORNTON AUDITORES INDEPENDENTES . ",oFont08a,,CLR_BLACK)  	
	   		oPrint:Say(2650,800,"Branch Number   : 3853 ",oFont08a,,CLR_BLACK)
	 		oPrint:Say(2700,800,"Account Number : 13-005941-2",oFont08a,,CLR_BLACK) 	   		
	   	   
	 	ElseIf cMoe == 5 .Or. cMoe == 3 
	 	
		   	oPrint:Say(2200,100,"Please make payment arranging a direct deposit in our our account as follows: ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2300,500,"Wire transfer ( PLEASE PAY VIA REMITTANCE - WE CANNOT A ACCEPT CHECKS ) ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2350,800,"Account with  : Banco Santander S/A – Madrid – España  ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2400,800,"Swift(Bic Code): BSCHESMMXXX ",oFont08a,,CLR_BLACK)      
	   		oPrint:Say(2450,800,"Clearing Code: 15439",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2500,800,"In favor of       : Banco Santander (Brasil) S.A. ",oFont08a,,CLR_BLACK)     
	   		oPrint:Say(2550,800,"Swift Code      : BSCHBRSP ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2600,800,"For Further Credit to:	GRANT THORNTON AUDITORES INDEPENDENTES. ",oFont08a,,CLR_BLACK)  	
	   		oPrint:Say(2650,800,"Branch Number   : 3853 ",oFont08a,,CLR_BLACK)
	 		oPrint:Say(2700,800,"Account Number : 13-005941-2",oFont08a,,CLR_BLACK) 
	
		EndIf
	
	EndIf  
	

ElseIf SM0->M0_CODIGO $ "Z8"


	If nBanco == 1

		If  cMoe == 2 
		
			oPrint:Say(2200,100,"Please make payment arranging a direct deposit in our our account as follows: ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2300,500,"Wire transfer ( PLEASE PAY VIA REMITTANCE - WE CANNOT A ACCEPT CHECKS ) ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2350,800,"Account with  : Deutsche Bank Trust Company Américas - New York ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2400,800,"Swift Code      : BKTRUS33 ",oFont08a,,CLR_BLACK)      
	   		oPrint:Say(2450,800,"Account Nr      : 04004949 ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2500,800,"In favor of       : Banco Itaú S.A. ",oFont08a,,CLR_BLACK)     
	   		oPrint:Say(2550,800,"Swift Code      : ITAUBRSP ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2600,800,"For Further Credit to: GRANT THORNTON CONSULTORES LTDA. ",oFont08a,,CLR_BLACK)  	
	   		oPrint:Say(2650,800,"Branch Number   : 0190 ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2700,800,"Account Number : 38.798-5 ",oFont08a,,CLR_BLACK)         
	
	        
	 	ElseIf cMoe == 5 .Or. cMoe == 3 
	 	
	 		oPrint:Say(2200,100,"Please make payment arranging a direct deposit in our our account as follows: ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2300,500,"Wire transfer ( PLEASE PAY VIA REMITTANCE - WE CANNOT A ACCEPT CHECKS ) ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2350,800,"Account with  : ING Belgium NV - Bruxelas ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2400,800,"Swift Code      : BBRUBEBB010 ",oFont08a,,CLR_BLACK)      
	   		oPrint:Say(2450,800,"Account Nr      : 301-0104579-94 ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2500,800,"In favor of       : Banco Itaú S.A. ",oFont08a,,CLR_BLACK)     
	   		oPrint:Say(2550,800,"Swift Code      : ITAUBRSP ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2600,800,"For Further Credit to:	GRANT THORNTON CONSULTORES LTDA. ",oFont08a,,CLR_BLACK)  	
	   		oPrint:Say(2650,800,"Branch Number   : 0190 ",oFont08a,,CLR_BLACK)
	 		oPrint:Say(2700,800,"Account Number : 38.798-5 ",oFont08a,,CLR_BLACK)      
	 	
	  	
	   	EndIf
	
	Else
	
		If  cMoe == 2    
		
		   	oPrint:Say(2200,100,"Please make payment arranging a direct deposit in our our account as follows: ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2300,500,"Wire transfer ( PLEASE PAY VIA REMITTANCE - WE CANNOT A ACCEPT CHECKS ) ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2350,800,"Account with  : Standard Chartered Bank – New York – USA ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2400,800,"Swift(Bic Code): SCBLUS33XXX ",oFont08a,,CLR_BLACK)      
	   		oPrint:Say(2450,800,"Clearing Code: ABA 026002561 / CHIPS UID 0256",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2500,800,"In favor of       : Banco Santander (Brasil) S.A. ",oFont08a,,CLR_BLACK)     
	   		oPrint:Say(2550,800,"Swift Code      : BSCHBRSP ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2600,800,"For Further Credit to:	GRANT THORNTON CONSULTORES LTDA. ",oFont08a,,CLR_BLACK)  	
	   		oPrint:Say(2650,800,"Branch Number   : 3853 ",oFont08a,,CLR_BLACK)
	 		oPrint:Say(2700,800,"Account Number : 13-005923-0",oFont08a,,CLR_BLACK) 	   		
	   	   
	 	ElseIf cMoe == 5 .Or. cMoe == 3 
	 	
		   	oPrint:Say(2200,100,"Please make payment arranging a direct deposit in our our account as follows: ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2300,500,"Wire transfer ( PLEASE PAY VIA REMITTANCE - WE CANNOT A ACCEPT CHECKS ) ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2350,800,"Account with  : Banco Santander S/A – Madrid – España  ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2400,800,"Swift(Bic Code): BSCHESMMXXX ",oFont08a,,CLR_BLACK)      
	   		oPrint:Say(2450,800,"Clearing Code: 15439",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2500,800,"In favor of       : Banco Santander (Brasil) S.A. ",oFont08a,,CLR_BLACK)     
	   		oPrint:Say(2550,800,"Swift Code      : BSCHBRSP ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2600,800,"For Further Credit to:	GRANT THORNTON CONSULTORES LTDA. ",oFont08a,,CLR_BLACK)  	
	   		oPrint:Say(2650,800,"Branch Number   : 3853 ",oFont08a,,CLR_BLACK)
	 		oPrint:Say(2700,800,"Account Number : 13-005923-0",oFont08a,,CLR_BLACK) 
	
		EndIf
	
	EndIf  
	
	   		
ElseIf SM0->M0_CODIGO $ "RH"
        
	If nBanco == 1

		If  cMoe == 2
		
			oPrint:Say(2200,100,"Please make payment arranging a direct deposit in our our account as follows: ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2300,500,"Wire transfer ( PLEASE PAY VIA REMITTANCE - WE CANNOT A ACCEPT CHECKS ) ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2350,800,"Account with  : Deutsche Bank Trust Company Américas - New York ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2400,800,"Swift Code      : BKTRUS33 ",oFont08a,,CLR_BLACK)      
	   		oPrint:Say(2450,800,"Account Nr      : 04004949 ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2500,800,"In favor of       : Banco Itaú S.A. ",oFont08a,,CLR_BLACK)     
	   		oPrint:Say(2550,800,"Swift Code      : ITAUBRSP ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2600,800,"For Further Credit to:	PRYOR CONSULTORIA DE RECURSOS HUMANOS LTDA. ",oFont08a,,CLR_BLACK)  	
	   		oPrint:Say(2650,800,"Branch Number   : 0190 ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2700,800,"Account Number : 30.984-9 ",oFont08a,,CLR_BLACK)           
		
	        
	 	ElseIf cMoe == 5 .Or. cMoe == 3
	 	
	 		oPrint:Say(2200,100,"Please make payment arranging a direct deposit in our our account as follows: ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2300,500,"Wire transfer ( PLEASE PAY VIA REMITTANCE - WE CANNOT A ACCEPT CHECKS ) ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2350,800,"Account with  : ING Belgium NV - Bruxelas ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2400,800,"Swift Code      : BBRUBEBB010 ",oFont08a,,CLR_BLACK)      
	   		oPrint:Say(2450,800,"Account Nr      : 301-0104579-94 ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2500,800,"In favor of       : Banco Itaú S.A. ",oFont08a,,CLR_BLACK)     
	   		oPrint:Say(2550,800,"Swift Code      : ITAUBRSP ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2600,800,"For Further Credit to:	PRYOR CONSULTORIA DE RECURSOS HUMANOS LTDA ",oFont08a,,CLR_BLACK)  	
	   		oPrint:Say(2650,800,"Branch Number   : 0190 ",oFont08a,,CLR_BLACK)
	 		oPrint:Say(2700,800,"Account Number : 30.984-9 ",oFont08a,,CLR_BLACK)      
	
	    EndIf
	
	Else
	
		If  cMoe == 2    
		
		   	oPrint:Say(2200,100,"Please make payment arranging a direct deposit in our our account as follows: ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2300,500,"Wire transfer ( PLEASE PAY VIA REMITTANCE - WE CANNOT A ACCEPT CHECKS ) ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2350,800,"Account with  : Standard Chartered Bank – New York – USA ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2400,800,"Swift(Bic Code): SCBLUS33XXX ",oFont08a,,CLR_BLACK)      
	   		oPrint:Say(2450,800,"Clearing Code: ABA 026002561 / CHIPS UID 0256",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2500,800,"In favor of       : Banco Santander (Brasil) S.A. ",oFont08a,,CLR_BLACK)     
	   		oPrint:Say(2550,800,"Swift Code      : BSCHBRSP ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2600,800,"For Further Credit to:	PRYOR CONSULTORIA DE RECURSOS HUMANOS LTDA.",oFont08a,,CLR_BLACK)  	
	   		oPrint:Say(2650,800,"Branch Number   : 3853 ",oFont08a,,CLR_BLACK)
	 		oPrint:Say(2700,800,"Account Number : 13-000388-2",oFont08a,,CLR_BLACK) 	   		
	   	   
	 	ElseIf cMoe == 5 .Or. cMoe == 3 
	 	
		   	oPrint:Say(2200,100,"Please make payment arranging a direct deposit in our our account as follows: ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2300,500,"Wire transfer ( PLEASE PAY VIA REMITTANCE - WE CANNOT A ACCEPT CHECKS ) ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2350,800,"Account with  : Banco Santander S/A – Madrid – España  ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2400,800,"Swift(Bic Code): BSCHESMMXXX ",oFont08a,,CLR_BLACK)      
	   		oPrint:Say(2450,800,"Clearing Code: 15439",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2500,800,"In favor of       : Banco Santander (Brasil) S.A. ",oFont08a,,CLR_BLACK)     
	   		oPrint:Say(2550,800,"Swift Code      : BSCHBRSP ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2600,800,"For Further Credit to:	PRYOR CONSULTORIA DE RECURSOS HUMANOS LTDA.",oFont08a,,CLR_BLACK)  	
	   		oPrint:Say(2650,800,"Branch Number   : 3853 ",oFont08a,,CLR_BLACK)
	 		oPrint:Say(2700,800,"Account Number : 13-000388-2",oFont08a,,CLR_BLACK) 
	
		EndIf
	
	EndIf  
	
	
EndIf	
	
Return          

	