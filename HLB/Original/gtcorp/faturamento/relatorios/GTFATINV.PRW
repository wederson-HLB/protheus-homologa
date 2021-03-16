#include "TOTVS.CH"
#include "TopConn.ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GTFATINV  ºAutor  Tiago Luiz Mendonça  º Data ³  10/10/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Invoice Grant Thornton                                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ 			                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/*
Funcao      : GTFATINV()  
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Impressão de invoice Grant Thornton.
Autor       : Tiago Luiz Mendonça
Data/Hora   : 18/11/2011 
*/
  
*----------------------*
User Function GTFATINV()   
*----------------------*                                      

Private cPerg     := "GTFATINV"                    
Private cPedDe    := Space(06)
Private cPedAte   := Space(06) 

Private nBanco    
       
If !(ChkCpo())
	MsgInfo("O campo C6_P_BRL não existe","GT")
    Return .F.
EndIf

If !(ChkCpo1())
	MsgInfo("O campo CNB_P_BRL não existe","GT")
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
Autor       : Tiago Luiz Mendonça
Data/Hora   : 18/11/2011
*/                  
*----------------------------*
 Static Function BuscaDados()
*----------------------------*  

Private cNomeArquivo := ""         

Begin Sequence


	If Select("SQL") > 0
   		SQL->(dbCloseArea())
	EndIf

    BeginSql Alias 'SQL' 
        
        //Chamados agrupados por módulos não cancelados
/*    	SELECT CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),CND.CND_OBS)) AS CND_OBS,*  
     	FROM %Table:SC5% AS C5
      	JOIN %Table:CND% CND ON CND.CND_CONTRA=C5.C5_MDCONTR AND CND.CND_NUMMED=C5.C5_MDNUMED 
      	JOIN %Table:CNE% CNE ON CND.CND_NUMMED=CNE.CNE_NUMMED
      		WHERE C5.%notDel% AND CND.%notDel% AND CNE.%notDel%
        	AND C5_FILIAL = %exp:xFilial("SC5")%  
        	AND C5_NUM>=%exp:cPedDe%
        	AND C5_NUM<=%exp:cPedAte%    	 
    	Order by C5_NUM     
*/    

    /*  SELECT CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),CND.CND_OBS)) AS CND_OBS,*  
     	FROM %Table:SC5% AS C5
      	JOIN %Table:CND% CND ON CND.CND_CONTRA=C5.C5_MDCONTR AND CND.CND_NUMMED=C5.C5_MDNUMED 
      		WHERE C5.%notDel% AND CND.%notDel%
        	AND C5_FILIAL = %exp:xFilial("SC5")%  
        	AND C5_NUM>=%exp:cPedDe%
        	AND C5_NUM<=%exp:cPedAte%    	 
    	Order by C5_NUM     
    */
    
	    SELECT * 
     	FROM %Table:SC5% AS C5
      		WHERE C5.%notDel%
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
Objetivos   : Inicializa a impressão da invoice
Autor       : Tiago Luiz Mendonça
Data/Hora   : 18/11/2011                                                         
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

Private nPosMais	:= 0  //MSM - 22/02/2013 - Criado para descer o conteúdo para incluir o quadrado de information
Private lTemMsg		:=.F.

    //para saber se deve aparecer o campo information
	cQry3:=" SELECT ISNULL(CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),CN9_P_MENS)),'') AS CN9_P_MENS FROM "+RETSQLNAME("CN9")
	cQry3+=" WHERE D_E_L_E_T_='' AND CN9_FILIAL='"+xFilial("CN9")+"' AND CN9_NUMERO='"+SQL->C5_MDCONTR+"' AND CN9_SITUAC='05'"
		
	if select("QRYTEMP1")>0
		QRYTEMP1->(DbCloseArea())
	endif
		
	DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry3), "QRYTEMP1", .F., .F. )
		
	Count to nRecCount

	if nRecCount >0
		QRYTEMP1->(DbGoTop())
		if !empty(QRYTEMP1->CN9_P_MENS)
			lTemMsg		:= .T.
			nPosMais	:= 230
		endif
	endif


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
   BoxGeral(oPrint,nPosMais,lTemMsg)
      
   //Cria o Cabeçalho do Relatório
   ReportHeader(oPrint,nPosMais,lTemMsg)
      
   //Cria os Detalhes do Relatório
   ReportDetail(oPrint,nPosMais,lTemMsg)
 
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
Autor       : Tiago Luiz Mendonça
Data/Hora   : 18/11/2011
*/
*---------------------------------------------------*
Static Function ReportHeader(oPrint,nPosMais,lTemMsg)   
*---------------------------------------------------*   

Begin Sequence
      

	//Logo 
   	oPrint:SayBitmap(070,50,"\Imagens\GTFATINV\gt.bmp",600,170)  

   
   	oPrint:Say(300,100,SM0->M0_NOMECOM,oFont08a,,CLR_BLACK) 
  	oPrint:Say(350,100,SM0->M0_ENDCOB,oFont08a,,CLR_BLACK) 
   	oPrint:Say(400,100,"Zip code "+Substr(SM0->M0_CEPCOB,1,5)+"-"+Substr(SM0->M0_CEPCOB,6,3)+" - "+Alltrim(SM0->M0_CIDCOB)+" - "+Alltrim(SM0->M0_ESTCOB)+" - Brazil",oFont08a,,CLR_BLACK) 
   	oPrint:Say(450,100,"Phone : +"+Substr(SM0->M0_TEL,1,2)+" "+Substr(SM0->M0_TEL,3,2)+" "+Substr(SM0->M0_TEL,5,4)+" "+Substr(SM0->M0_TEL,9,4),oFont08a,,CLR_BLACK)     
   
   	oPrint:Say(080,1800,"Invoice",oFont22,,CLR_BLACK)
   
   	oPrint:Say(300,1800,"Date:",oFont08a,,CLR_BLACK) 
   	oPrint:Say(350,1800,"Invoice:",oFont08a,,CLR_BLACK) 
   	oPrint:Say(400,1800,"Currency:",oFont08a,,CLR_BLACK) 
    oPrint:Say(450,1800,"Exchange Rate:",oFont08a,,CLR_BLACK)
   	oPrint:Say(500,1800,"Due Date:",oFont08a,,CLR_BLACK)   
   	oPrint:Say(550,1800,"Reference:",oFont08a,,CLR_BLACK) 
   
   	oPrint:Say(600,350,"To:",oFont08a,,CLR_BLACK)
    
	if lTemMsg
   		oPrint:Say(910,1150 ,"Information",oFont08a,,CLR_BLACK)
 	endif

   	oPrint:Say(910+nPosMais,120 ,"Professional Services Rendered - Description ",oFont08a,,CLR_BLACK) 
   	oPrint:Say(910+nPosMais,1300,"BRL",oFont08a,,CLR_BLACK) 
   	oPrint:Say(910+nPosMais,1600,"Qt ",oFont08a,,CLR_BLACK)    
   	oPrint:Say(910+nPosMais,1750,"Unit Price",oFont08a,,CLR_BLACK) 	
   	oPrint:Say(910+nPosMais,2120,"Total",oFont08a,,CLR_BLACK) 		
   
   	oPrint:Say(1900+nPosMais,1900,"Total",oFont08a,,CLR_BLACK)    
     	

End Sequence                                          

Return  
   

/*
Funcao      : ReportDetail()  
Parametros  : oPrint
Retorno     : Nil
Objetivos   : Detalhes do relatorio.
Autor       : Tiago Luiz Mendonça
Data/Hora   : 18/11/2011
*/

*----------------------------------------------------*
 Static Function ReportDetail(oPrint,nPosMais,lTemMsg)   
*----------------------------------------------------*   
Private n         := 0
Private nTotal    := 0 
Private nTaxa     := 0 

Private cSigla    := ""
Private cMoeda    := ""
Private cNum      := ""  

Private nLinha  := 1050+nPosMais

Private cQry	:=""  
Private cQry1	:=""
Private cQry2	:=""
Private cQry3	:=""
      
    SQL->(DbGoTop())   
    
    cNum:=SQL->C5_NUM
    
    While SQL->(!EOF())  
                      
   	   	IncProc("Aguarde, lendo cadastro de produtos ..." +Alltrim(str(N))) 
                               
        If cNum<>SQL->C5_NUM 
        	
        	oPrint:EndPage()   
 	 		oPrint:StartPage() 
  			oPrint:SetPortrait()
   			oPrint:SetpaperSize(9)
   			
	 	    //JSS - para saber se deve aparecer o campo information
		    nPosMais := 0
		    lTemMsg	 := .F.
		    
			cQry3:=" SELECT ISNULL(CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),CN9_P_MENS)),'') AS CN9_P_MENS FROM "+RETSQLNAME("CN9")
			cQry3+=" WHERE D_E_L_E_T_='' AND CN9_FILIAL='"+xFilial("CN9")+"' AND CN9_NUMERO='"+SQL->C5_MDCONTR+"' AND CN9_SITUAC='05'"
				
			if select("QRYTEMP1")>0
				QRYTEMP1->(DbCloseArea())
			endif
				
			DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry3), "QRYTEMP1", .F., .F. )
				
			Count to nRecCount
		
			if nRecCount >0
				QRYTEMP1->(DbGoTop())
				if !empty(QRYTEMP1->CN9_P_MENS)
					lTemMsg		:= .T.
					nPosMais	:= 230
				endif
			endif
	   		         
  			//Molduras externas
    		BoxGeral(oPrint,nPosMais,lTemMsg) 
      
   			//Cria o Cabeçalho do Relatório
   			ReportHeader(oPrint,nPosMais,lTemMsg)
                       
    		//Reseta a linha
  			nLinha       := 1050+nPosMais
  			nTotal       := 0   
        
        EndIf

        MsgBco(SQL->C5_MOEDA,nPosMais)        

    	SYA->(DbSetOrder(1))
        SA1->(DbSetOrder(1))
        SA1->(DbSeek(xFilial("SA1") + SQL->C5_CLIENTE + SQL->C5_LOJACLI))
            	
		Do Case//JVR
			Case cEmpAnt $ "ZB/ZF/ZG" .and. !EMPTY(SQL->C5_MDCONTR) // WFA - 19/12/2016 - Chamado: 037758, inclusão da empresa ZG.
/*				aDadosCob := {}
				cQryCN9 := " Select * 
				cQryCN9 += " From "+RETSQLNAME("CN9")+" CN9
				cQryCN9 += " 	Left Outer Join(Select * From "+RETSQLNAME("Z55")+" Where D_E_L_E_T_ <> '*') as Z55 On Z55.Z55_FILIAL = CN9.CN9_FILIAL
				cQryCN9 += " 									AND Z55.Z55_NUM = CN9.CN9_P_NUM
				cQryCN9 += " 									AND Z55.Z55_REVISA = (Case when CN9.CN9_REVISA = '' then '000' else CN9.CN9_REVISA end)
				cQryCN9 += " Where CN9.D_E_L_E_T_ <> '*'
				cQryCN9 += " 	AND Z55.Z55_FILIAL <> ''
				cQryCN9 += " 	AND Z55.Z55_REVATU = ''
				cQryCN9 += " 	AND CN9.CN9_NUMERO = '"+SQL->C5_MDCONTR+"'
  */            //JSS - Ajustado para atender o chamado 026371
  				//Inicio da alteração 
  				aDadosCob := {"","","","","",""}
				cQryCN9 := " Select * 
				cQryCN9 += " From "+RETSQLNAME("CN9")+" CN9
				cQryCN9 += " 	Left Outer Join(Select * From "+RETSQLNAME("Z55")+" Where D_E_L_E_T_ <> '*') as Z55 On Z55.Z55_FILIAL = CN9.CN9_FILIAL
				cQryCN9 += " 									AND Z55.Z55_NUM = CN9.CN9_P_NUM
				cQryCN9 += " 									AND Z55.Z55_REVATU = ''
				cQryCN9 += " Where CN9.D_E_L_E_T_ <> '*'
				cQryCN9 += " 	AND Z55.Z55_FILIAL <> ''
				cQryCN9 += " 	AND CN9.CN9_NUMERO = '"+SQL->C5_MDCONTR+"'
				cQryCN9 += " 	AND CN9_FILIAL='"+xFilial("CN9")+"'"
				
				//Fim da alteração
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
            //MSM - 06/01/2015 - Chamado: 030195, adicionado tratamendo para buscar dados da proposta caso o pedido tenha sido incluído manualmente
            Case cEmpAnt $ "ZB/ZF/ZG" .and. !EMPTY(SQL->C5_P_NUM)  // WFA - 19/12/2016 - Chamado: 037758, inclusão da empresa ZG.
				
				aDadosCob := {"","","","","",""}
				cQryZ55 := " SELECT Z55_CLIENT,Z55_LOJA,Z55_CLIGLO,Z55_COBEND,Z55_COBBAI,Z55_COBMUN,Z55_COBRES,Z55_COBEMA
				cQryZ55 += " FROM "+RETSQLNAME("Z55")+" Z55
				cQryZ55 += " WHERE D_E_L_E_T_=''
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
    	//RRP - 15/07/2013 - Inclusão do Dolar Canadense.
    	ElseIf SQL->C5_MOEDA==6
    		cMoeda:="Dolar Canadense" 
    		nTaxa := SM2->M2_MOEDA6 
    		cSigla:="CA$"
    	EndIf	

	    if lTemMsg
	    
		    //MSM - 22/02/2013 - Tratamento para observações dos itens gerados através das medições automáticas(contratos), buscando as informações dos contratos
			
			cQry3:=" SELECT ISNULL(CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),CN9_P_MENS)),'') AS CN9_P_MENS FROM "+RETSQLNAME("CN9")
			cQry3+=" WHERE D_E_L_E_T_='' AND CN9_FILIAL='"+xFilial("CN9")+"' AND CN9_NUMERO='"+SQL->C5_MDCONTR+"' AND CN9_SITUAC='05'"
			
			if select("QRYTEMP1")>0
				QRYTEMP1->(DbCloseArea())
			endif
			
			DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry3), "QRYTEMP1", .F., .F. )
			
			Count to nRecCount
	
			if nRecCount >0
	
				QRYTEMP1->(DbGotop())
				cMsg:=STRTRAN(alltrim(QRYTEMP1->CN9_P_MENS),CRLF," ")
	
				l:=0
				For k:=1 to len(cMsg) STEP 130
					
					oPrint:Say(1002+l,120,Substr(alltrim(cMsg),k,130),oFont08,,CLR_BLACK)
					l:=30
				Next
			endif

    	endif 
    	
    	//Tratamento para dados da cabeçalho da medição dos contratos MSM - 31/05/2012
    	cQry2:=" SELECT CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),CND.CND_OBS)) AS CND_OBS,*  
     	cQry2+=" FROM "+RETSQLNAME("CND")+" CND"
      	cQry2+=" WHERE CND.D_E_L_E_T_=''
      	cQry2+=" AND CND.CND_CONTRA='"+SQL->C5_MDCONTR+"' AND CND.CND_NUMMED='"+SQL->C5_MDNUMED+"' 
      	
		if select("SQL11")>0
			SQL11->(DbCloseArea())
		endif
				
		DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry2), "SQL11", .F., .F. )
    	
    	
    	//oPrint:Say(300,2000,SubStr(Alltrim(SQL->C5_EMISSAO),1,4)+"-"+substr(Alltrim(SQL->C5_EMISSAO),5,2)+"-"+SubStr(Alltrim(SQL->C5_EMISSAO),7,2),oFont08a,,CLR_BLACK) 
   		oPrint:Say(300,2020,SubStr(Alltrim(SQL->C5_EMISSAO),7,2)+"/"+substr(Alltrim(SQL->C5_EMISSAO),5,2)+"/"+SubStr(Alltrim(SQL->C5_EMISSAO),1,4),oFont08a,,CLR_BLACK) 
   		oPrint:Say(350,2020,SQL->C5_NUM,oFont08a,,CLR_BLACK) 
   		oPrint:Say(400,2020,cMoeda,oFont08a,,CLR_BLACK) 		
  		oPrint:Say(450,2075,Transform(nTaxa,"@E 9.9999"),oFont08a,,CLR_BLACK)
  		If !Empty(SQL->C5_DATA1)
  			oPrint:Say(500,2020,SubStr(Alltrim(SQL->C5_DATA1),7,2)+"/"+substr(Alltrim(SQL->C5_DATA1),5,2)+"/"+SubStr(Alltrim(SQL->C5_DATA1),1,4),oFont08a,,CLR_BLACK) 
   		Else
   		    
   		    //Tratamento para data de vencimento do contrato MSM - 31/05/2012
	   		/*
	   		if !empty(SQL11->CND_COMPET)

		   		cQry1:=" SELECT CNF_DTVENC FROM "+RETSQLNAME("CNF")
				cQry1+=" WHERE CNF_CONTRA='"+SQL->C5_MDCONTR+"' AND D_E_L_E_T_='' AND CNF_SALDO = '0' AND CNF_COMPET='"+SQL11->CND_COMPET+"'
				
				if select("QRYTEMP")>0
					QRYTEMP->(DbCloseArea())
				endif
					
				DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry1), "QRYTEMP", .F., .F. )
				if !empty(QRYTEMP->CNF_DTVENC)
			   		oPrint:Say(500,2020,SubStr(Alltrim(QRYTEMP->CNF_DTVENC),7,2)+"/"+substr(Alltrim(QRYTEMP->CNF_DTVENC),5,2)+"/"+SubStr(Alltrim(QRYTEMP->CNF_DTVENC),1,4),oFont08a,,CLR_BLACK) 			   		   	
		    */
   		     //Tratamento para data de vencimento do contrato JSS - 15/04/2015 Alterado para solução do chamado 025671
	   		if !empty(SQL11->CND_COMPET)

		   		cQry1:=" SELECT E1_VENCREA FROM "+RETSQLNAME("SE1")
				//RSB - 30/10/2017 - Alteração realizada devido ao Ticket: #17329 - 
				//Compartilhamento da tabela do financeiro.				
			   /*If cEmpAnt $ "Z8/ZB"
					cQry1+=" WHERE D_E_L_E_T_ = '' AND E1_FILORIG = '"+SQL->C5_FILIAL+"' AND E1_PEDIDO='"+SQL->C5_NUM+"'"
				Else
					cQry1+=" WHERE D_E_L_E_T_ = '' AND E1_FILIAL = '"+xFilial("SE1")+"' AND E1_PEDIDO='"+SQL->C5_NUM+"'"
				Endif*/
				//WFA - 08/12/2017 - Ajuste para atender ambos os cenarios. Ticket: #20850  
				cQry1+=" WHERE D_E_L_E_T_ = '' AND E1_FILORIG = '"+cFilAnt+"' AND E1_PEDIDO='"+SQL->C5_NUM+"'"
				
				if select("QRYTEMP")>0
					QRYTEMP->(DbCloseArea())
				endif
					
				DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry1), "QRYTEMP", .F., .F. )
				if !empty(QRYTEMP->E1_VENCREA)
			   		oPrint:Say(500,2020,SubStr(Alltrim(QRYTEMP->E1_VENCREA),7,2)+"/"+substr(Alltrim(QRYTEMP->E1_VENCREA),5,2)+"/"+SubStr(Alltrim(QRYTEMP->E1_VENCREA),1,4),oFont08a,,CLR_BLACK) 
			   	else
			   	
					//MSM - 28/12/2012 - Alterado para tratar o chamado: 008085
			        //Pega a condição o vencimento no estilo da planilha financeira
			
					DbSelectArea("SE4")
					DbSetOrder(1)
					MsSeek(xFilial("SE4")+SQL->C5_CONDPAG)
					If ((SE4->E4_TIPO=="9".AND.!(INCLUI.OR.ALTERA)).OR.SE4->E4_TIPO<>"9")				
					
						dDataCnd  := STOD(SQL->C5_EMISSAO)
						nlValor	:=100
						nAcresTot := 0
						
						aDupl := Condicao(nlValor,SQL->C5_CONDPAG,0,dDataCnd,0,,,nAcresTot)
			
					Else
						aDupl := {{Ctod(""),0}}
					EndIf
                        
					if len(aDupl)>0
						oPrint:Say(500,2020,DTOC(aDupl[1][1]),oFont08a,,CLR_BLACK) 
					endif

			   	endif
   		    endif
   		    
   		EndIf
   		oPrint:Say(550,2020,cMonth(CTOD(SubStr(Alltrim(SQL->C5_EMISSAO),7,2)+"/"+substr(Alltrim(SQL->C5_EMISSAO),5,2)+"/"+SubStr(Alltrim(SQL->C5_EMISSAO),1,4)))+" - "+SubStr(Alltrim(SQL->C5_EMISSAO),3,2),oFont08a,,CLR_BLACK)  
     	// WFA - 19/12/2016 - Chamado: 037758, inclusão da empresa ZG.
     	If cEmpAnt $ "ZB/ZF/ZG" .and. ( !EMPTY(SQL->C5_MDCONTR) .OR. !EMPTY(SQL->C5_P_NUM)) //JVR
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

	    oPrint:Say(1900+nPosMais,2030,alltrim(cSigla),oFont08a,,CLR_BLACK)  	

  		If SYA->(DbSeek(xFilial("SYA")+SA1->A1_PAIS))
    		oPrint:Say(750,450,SYA->YA_DESCR,oFont08a,,CLR_BLACK)
        EndIf 
        
        SC6->(DbSetOrder(1))
        SB1->(DbSetOrder(1))  
                  
        If SC6->(DbSeek(xFilial("SC6")+SQL->C5_NUM))
           
        	While SC6->(!EOF()) .And. SC6->C6_NUM == SQL->C5_NUM  
        	
        		SB1->(DbSeek(xFilial("SB1")+SC6->C6_PRODUTO))
	   		    
	   		    cQry:=" "
	   		    //Tratamento para pegar descrição dos itens da medição MSM - 31/05/2012        	    
                cQry+=" SELECT CNE_POBS FROM "+RETSQLNAME("CNE")
                //JSS - 18/04/2013 : Ajustado SELECT pois estava transendo o mesmo nosme para todo os produtos.
        		cQry+=" WHERE CNE_NUMMED='"+SQL->C5_MDNUMED+"' AND CNE_FILIAL='"+xFilial("CNE")+"' AND D_E_L_E_T_=''AND CNE_ITEM='"+'0'+SC6->C6_ITEM+"'"
				
				if select("QRYTEMP")>0
					QRYTEMP->(DbCloseArea())
				endif
				
				DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )                
        	     
        	    cDescreProd:=iif(empty(SC6->C6_DESCRIC),QRYTEMP->CNE_POBS,SC6->C6_DESCRIC)
        	    
        	    oPrint:Say(nLinha,120,Substr(alltrim(SB1->B1_P_IDESC)+" "+alltrim(cDescreProd),1,50),oFont08,,CLR_BLACK)  
        		If Len(alltrim(alltrim(SB1->B1_P_IDESC)+" "+alltrim(cDescreProd)))>50 
        			oPrint:Say(nLinha+=50,120,Substr(alltrim(SB1->B1_P_IDESC)+" "+alltrim(cDescreProd),51,50),oFont08,,CLR_BLACK)	
        		 	If Len(alltrim(alltrim(SB1->B1_P_IDESC)+" "+alltrim(cDescreProd)))>100 
        				oPrint:Say(nLinha+=50,120,Substr(alltrim(SB1->B1_P_IDESC)+" "+alltrim(cDescreProd),101,50),oFont08,,CLR_BLACK)	
        			EndIf       		
        		EndIf
        		
        		If !Empty(SC6->C6_P_BRL)
        			if cEmpAnt $ "Z4" //MSM - 01/08/2016 - Tratamento para não exibir os valores da empresa Z4	
        				oPrint:Say(nLinha,1250,"",oFont08) 
        			else 
	        			oPrint:Say(nLinha,1250,Transform(SC6->C6_P_BRL,"@E 9,999,999.99"),oFont08) 
        			endif
        		Else
        			//Tratamento para pegar valor da moeda em reais criado no cadastro de planilha MSM - 05/06/2012 
        			cQry3:=" SELECT CNB_P_BRL FROM "+RETSQLNAME("CNB")
					cQry3+=" WHERE CNB_CONTRA='"+SQL->C5_MDNUMED+"' AND CNB_PRODUT='"+SC6->C6_PRODUTO+"' AND CNB_FILIAL='"+xFilial("CNB")+"' AND D_E_L_E_T_=''"
					                                                        
						if select("SQL12")>0
							SQL12->(DbCloseArea())
						endif
				
						DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry3), "SQL12", .F., .F. )
	       			if cEmpAnt $ "Z4" //MSM - 01/08/2016 - Tratamento para não exibir os valores da empresa Z4	
						oPrint:Say(nLinha,1250,Transform(SQL12->CNB_P_BRL,"@E 9,999,999.99"),oFont08) 
					else
						oPrint:Say(nLinha,1250,"",oFont08) 
					endif
        		EndIf
        		
        		oPrint:Say(nLinha,1550,Transform(SC6->C6_QTDVEN,"@E 999.99"),oFont08) 	  
        		
	       		//WFA - 10/09/2018 - Inclusão da empresa ZP no tratamento.
	       		if cEmpAnt $ "Z4/ZP" //MSM - 01/08/2016 - Tratamento para não exibir os valores da empresa Z4	        	    
        	    	oPrint:Say(nLinha,1720,"",oFont08) 
        	 		oPrint:Say(nLinha,2050,"",oFont08)
        	 	else
        	    	oPrint:Say(nLinha,1720,Transform(SC6->C6_PRCVEN,"@E 9,999,999.99"),oFont08) 
        	 		oPrint:Say(nLinha,2050,Transform(SC6->C6_VALOR,"@E 9,999,999.99"),oFont08)
        	 	endif
        	 	
        	 	nLinha+=100
        	 	
        	 	ChkLinha(nPosMais,lTemMsg)   
        	 	      	 	
        	                 
        	    nTotal+=SC6->C6_VALOR
        	    
        		SC6->(DbSkip())
        		       		        		   
        	EndDo 
             
            oPrint:Say(1950+nPosMais,2050,Transform(nTotal,"@E 9,999,999.99"),oFont08) 
                              
       EndIf
       n++
       cMSgNota:=iif(empty(SQL->C5_MENNOTA),IIF(EMPTY(SQL11->CND_OBS),"",SQL11->CND_OBS),SQL->C5_MENNOTA)
       cObs:=iif(empty(SQL->C5_OBS),IIF(EMPTY(SQL11->CND_OBS),"",SQL11->CND_OBS),SQL->C5_OBS)
       oPrint:Say(1980+nPosMais,100,Substr(cMSgNota,1,75),oFont08)   
       oPrint:Say(2030+nPosMais,100,Substr(cMSgNota,76,75),oFont08)     
       oPrint:Say(2080+nPosMais,100,Substr(cMSgNota,151,75),oFont08) 
       oPrint:Say(2130+nPosMais,100,Substr(cObs,1,75),oFont08) 
       oPrint:Say(2130+nPosMais,100,Substr(cObs,76,75),oFont08)  
         
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
Autor       : Tiago Luiz Mendonça
Data/Hora   : 18/11/2011
*/
  
*-------------------------------------------------*
 Static Function BoxGeral(oPrint,nPosMais,lTemMsg)   
*-------------------------------------------------*  

Local oBrush

	oBrush := TBrush():New( , CLR_GRAY )
    
	if lTemMsg
		oPrint:FillRect({895 , 99, 955 , 2370}, oBrush)//Brush nformation
	
		oPrint:Line(895,100,895,2370)     //Linha Information
		oPrint:Line(955,100,955,2370)     //Linha Information
		oPrint:Line(1095,100,1095,2370)  //Linha Information
	
		oPrint:Line(895,101 ,1095,101)   //Coluna Information
		oPrint:Line(895,2370,1095,2370)  //Coluna Information
	endif

	oPrint:FillRect({895+nPosMais , 99, 955+nPosMais , 2370}, oBrush)   
	oPrint:FillRect({2275+nPosMais, 99, 2350+nPosMais, 2370}, oBrush) 
	oPrint:FillRect({2500+nPosMais, 99, 2595+nPosMais, 2370}, oBrush) 
	
	oPrint:Line(895+nPosMais,100,895+nPosMais,2370)     //Linha 
	oPrint:Line(955+nPosMais,100,955+nPosMais,2370)     //Linha 
	oPrint:Line(2000+nPosMais,2000,2000+nPosMais,2370)  //Linha 
	
	oPrint:Line(895+nPosMais,101 ,1900+nPosMais,101)   //Coluna
	oPrint:Line(895+nPosMais,1250,1900+nPosMais,1250)  //Coluna
   	oPrint:Line(895+nPosMais,1550,1900+nPosMais,1550)  //Coluna
   	oPrint:Line(895+nPosMais,1700,1900+nPosMais,1700)  //Coluna
   	oPrint:Line(895+nPosMais,2000,2000+nPosMais,2000)  //Coluna
	oPrint:Line(895+nPosMais,2370,2000+nPosMais,2370)  //Coluna
	  
	oPrint:Line(1900+nPosMais,100,1900+nPosMais,2370)   //Linha   
                      
Return
    

/*
Funcao      : ChkLinha()  
Parametros  :
Retorno     : Nil
Objetivos   : Validar o limite do relatorio.
Autor       : Tiago Luiz Mendonça
Data/Hora   : 18/11/2011
*/
     
*-----------------------------------------*             
 Static Function ChkLinha(nPosMais,lTemMsg)
*-----------------------------------------*

If nLinha > 1900  
         
	oPrint:EndPage()   
 	oPrint:StartPage() 
  	oPrint:SetPortrait()
   	oPrint:SetpaperSize(9)
         
  	//Molduras externas
    BoxGeral(oPrint,nPosMais,lTemMsg)
      
   	//Cria o Cabeçalho do Relatório
   	ReportHeader(oPrint,nPosMais,lTemMsg)
                       
    //Reseta a linha
  	nLinha       := 1050+nPosMais   
                    
 
 
        MsgBco(SQL->C5_MOEDA,nPosMais)        
                                 
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
     	//RRP - 15/07/2013 - Inclusão do Dolar Canadense.
    	ElseIf SQL->C5_MOEDA==6
    		cMoeda:="Dolar Canadense" 
    		nTaxa := SM2->M2_MOEDA6 
    		cSigla:="CA$"
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
Autor       : Tiago Luiz Mendonça
Data/Hora   : 18/11/2011
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
Funcao      : ChkCpo1()  
Parametros  : 
Retorno     : .T. ou .F.
Objetivos   : Validar campos para o relatório
Autor       : Matheus Massarotto
Data/Hora   : 05/06/2012
*/
     
*--------------------------*             
 Static Function ChkCpo1()
*--------------------------*     

Local lRet :=.F. 

//Campo valor reais
If CNB->(FieldPos("CNB_P_BRL"))>0        
	lRet :=.T.                                          
EndIF


Return lRet

  /*
Funcao      : MsgBco()  
Parametros  : 
Retorno     : .T. ou .F.
Objetivos   : Mensagens de banco por empresa
Autor       : Tiago Luiz Mendonça
Data/Hora   : 18/11/2011
*/

*-------------------------------*             
 Static Function MsgBco(cMoe,nPosMais)
*-------------------------------*   

If SM0->M0_CODIGO $ "Z4" 

    
 	If nBanco == 1
	 
		If  cMoe == 2    
		
		   	oPrint:Say(2200+nPosMais,100,"Please make payment arranging a direct deposit in our our account as follows: ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2300+nPosMais,500,"Wire transfer ( PLEASE PAY VIA REMITTANCE - WE CANNOT A ACCEPT CHECKS ) ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2350+nPosMais,800,"Account with  : Deutsche Bank JPMorgan Chase Bank, N.A ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2400+nPosMais,800,"Swift Code      : CHASUS33 ",oFont08a,,CLR_BLACK)      
	   		oPrint:Say(2450+nPosMais,800,"Account Nr      : 544705690  ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2500+nPosMais,800,"In favor of       : Banco Itaú S.A. ",oFont08a,,CLR_BLACK)     
	   		oPrint:Say(2550+nPosMais,800,"Swift Code      : ITAUBRSP ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2600+nPosMais,800,"For Further Credit to:	GRANT THORNTON CONSULTING SERVICES LTDA. ",oFont08a,,CLR_BLACK)  	
	   		oPrint:Say(2650+nPosMais,800,"Branch Number   : 0190 ",oFont08a,,CLR_BLACK)
	   		
	   		If SM0->M0_CODFIL $ "01/02/03"  //Lapa , Rio de Janeiro e Porto Alegre
	   			oPrint:Say(2700+nPosMais,800,"Account Number : 41.473-0 ",oFont08a,,CLR_BLACK) 
	   		Else
	   			oPrint:Say(2700+nPosMais,800,"Account Number : 38.560-9 ",oFont08a,,CLR_BLACK) 
	   		EndIf

	   		oPrint:Say(2750+nPosMais,800,"Fee          : OUR ",oFont08a,,CLR_BLACK) //AOA - 20/09/2016 - Inclusão de instrução, chamado 036262 	   		
	   	   
	 	ElseIf cMoe == 5 .Or. cMoe == 3  
	 	
	 		oPrint:Say(2200+nPosMais,100,"Please make payment arranging a direct deposit in our our account as follows: ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2300+nPosMais,500,"Wire transfer ( PLEASE PAY VIA REMITTANCE - WE CANNOT A ACCEPT CHECKS ) ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2350+nPosMais,800,"Account with  : ING Belgium NV - Bruxelas ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2400+nPosMais,800,"Swift Code      : BBRUBEBB010 ",oFont08a,,CLR_BLACK)      
	   		oPrint:Say(2450+nPosMais,800,"Account Nr      : 301-0104579-94 ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2500+nPosMais,800,"In favor of       : Banco Itaú S.A. ",oFont08a,,CLR_BLACK)     
	   		oPrint:Say(2550+nPosMais,800,"Swift Code      : ITAUBRSP ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2600+nPosMais,800,"For Further Credit to:	GRANT THORNTON CONSULTING SERVICES LTDA. ",oFont08a,,CLR_BLACK)  	
	   		oPrint:Say(2650+nPosMais,800,"Branch Number   : 0190 ",oFont08a,,CLR_BLACK)
	    		
	   		If SM0->M0_CODFIL $ "01/02/03"  //Lapa , Rio de Janeiro e Porto Alegre 
	   			oPrint:Say(2700+nPosMais,800,"Account Number : 41.473-0 ",oFont08a,,CLR_BLACK) 
	   		Else
	   			oPrint:Say(2700+nPosMais,800,"Account Number : 38.560-9 ",oFont08a,,CLR_BLACK) 
	   		EndIf
	   	   
	   		oPrint:Say(2750+nPosMais,800,"Fee             : OUR ",oFont08a,,CLR_BLACK) //AOA - 20/09/2016 - Inclusão de instrução, chamado 036262
	   			
		EndIf 
		
	Else
	
		If  cMoe == 2    
		
		   	oPrint:Say(2200+nPosMais,100,"Please make payment arranging a direct deposit in our our account as follows: ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2300+nPosMais,500,"Wire transfer ( PLEASE PAY VIA REMITTANCE - WE CANNOT A ACCEPT CHECKS ) ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2350+nPosMais,800,"Account with  : Standard Chartered Bank – New York – USA ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2400+nPosMais,800,"Swift(Bic Code): SCBLUS33XXX ",oFont08a,,CLR_BLACK)      
	   		oPrint:Say(2450+nPosMais,800,"Clearing Code: ABA 026002561 / CHIPS UID 0256",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2500+nPosMais,800,"In favor of       : Banco Santander (Brasil) S.A. ",oFont08a,,CLR_BLACK)     
	   		oPrint:Say(2550+nPosMais,800,"Swift Code      : BSCHBRSP ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2600+nPosMais,800,"For Further Credit to:	GRANT THORNTON CONSULTING SERVICES LTDA. ",oFont08a,,CLR_BLACK)  	
	   		oPrint:Say(2650+nPosMais,800,"Branch Number   : 3853 ",oFont08a,,CLR_BLACK)
	   		
	   		If SM0->M0_CODFIL $ "01/02/03"  //Lapa , Rio de Janeiro e Porto Alegre 
	   			oPrint:Say(2700+nPosMais,800,"Account Number : 13-000316-7 ",oFont08a,,CLR_BLACK) 
	   		Else
	   			oPrint:Say(2700+nPosMais,800,"Account Number : 13-000515-2 ",oFont08a,,CLR_BLACK) 
	   		EndIf
	   		
	   		oPrint:Say(2750+nPosMais,800,"Fee             : OUR ",oFont08a,,CLR_BLACK) //AOA - 20/09/2016 - Inclusão de instrução, chamado 036262	   		
	   	 	
	   	 	//RSB - 27/11/2017 - Alteração na conta da empresa 4K e Adicionar o IBAN CODE - Ticket #17247.
	   		If SM0->M0_CODFIL $ "01/02/03"  //Lapa , Rio de Janeiro e Porto Alegre 
	 			oPrint:Say(2800+nPosMais,800,"IBAN Code: BR9790400888038530130003167C1",oFont08a,,CLR_BLACK) 		                       
	   		Endif
	   	   
	 	ElseIf cMoe == 5 .Or. cMoe == 3 
	 	
		   	oPrint:Say(2200+nPosMais,100,"Please make payment arranging a direct deposit in our our account as follows: ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2300+nPosMais,500,"Wire transfer ( PLEASE PAY VIA REMITTANCE - WE CANNOT A ACCEPT CHECKS ) ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2350+nPosMais,800,"Account with  : Banco Santander S/A – Madrid – España  ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2400+nPosMais,800,"Swift(Bic Code): BSCHESMMXXX ",oFont08a,,CLR_BLACK)      
	   		oPrint:Say(2450+nPosMais,800,"Clearing Code: 15439",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2500+nPosMais,800,"In favor of       : Banco Santander (Brasil) S.A. ",oFont08a,,CLR_BLACK)     
	   		oPrint:Say(2550+nPosMais,800,"Swift Code      : BSCHBRSP ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2600+nPosMais,800,"For Further Credit to:	GRANT THORNTON CONSULTING SERVICES LTDA. ",oFont08a,,CLR_BLACK)  	
	   		oPrint:Say(2650+nPosMais,800,"Branch Number   : 3853 ",oFont08a,,CLR_BLACK)
	   		
	   		If SM0->M0_CODFIL $ "01/02/03"  //Lapa , Rio de Janeiro e Porto Alegre 
	   			oPrint:Say(2700+nPosMais,800,"Account Number : 13-000316-7 ",oFont08a,,CLR_BLACK) 
	   		Else
	   			oPrint:Say(2700+nPosMais,800,"Account Number : 13-000515-2 ",oFont08a,,CLR_BLACK) 
	   		EndIf

	   		oPrint:Say(2750+nPosMais,800,"Fee             : OUR ",oFont08a,,CLR_BLACK) //AOA - 20/09/2016 - Inclusão de instrução, chamado 036262
			
			//RSB - 27/11/2017 - Alteração na conta da empresa 4K e Adicionar o IBAN CODE - Ticket #17247.
	   		If SM0->M0_CODFIL $ "01/02/03"  //Lapa , Rio de Janeiro e Porto Alegre 
	 			oPrint:Say(2800+nPosMais,800,"IBAN Code: BR9790400888038530130003167C1",oFont08a,,CLR_BLACK) 		                       
	   		Endif
	   			
		EndIf

	
	EndIf   

ElseIf SM0->M0_CODIGO $ "ZF"

	If nBanco == 1

		If  cMoe == 2    
		
		   	oPrint:Say(2200+nPosMais,100,"Please make payment arranging a direct deposit in our our account as follows: ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2300+nPosMais,500,"Wire transfer ( PLEASE PAY VIA REMITTANCE - WE CANNOT A ACCEPT CHECKS ) ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2350+nPosMais,800,"Account with  : Deutsche Bank JPMorgan Chase Bank, N.A ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2400+nPosMais,800,"Swift Code      : CHASUS33 ",oFont08a,,CLR_BLACK)      
	   		oPrint:Say(2450+nPosMais,800,"Account Nr      : 544705690  ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2500+nPosMais,800,"In favor of       : Banco Itaú S.A. ",oFont08a,,CLR_BLACK)     
	   		oPrint:Say(2550+nPosMais,800,"Swift Code      : ITAUBRSP ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2600+nPosMais,800,"For Further Credit to:	GRANT THORNTON CORPORATE CONSULTORES DE NEGÓCIOS LTDA.",oFont08a,,CLR_BLACK)  	
	   		oPrint:Say(2650+nPosMais,800,"Branch Number   : 0190 ",oFont08a,,CLR_BLACK)
			oPrint:Say(2700+nPosMais,800,"Account Number : 19.382-1 ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2750+nPosMais,800,"Fee             : OUR ",oFont08a,,CLR_BLACK) //AOA - 20/09/2016 - Inclusão de instrução, chamado 036262	
	   		
	   	   
	 	ElseIf cMoe == 5 .Or. cMoe == 3 
	 	
	 		oPrint:Say(2200+nPosMais,100,"Please make payment arranging a direct deposit in our our account as follows: ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2300+nPosMais,500,"Wire transfer ( PLEASE PAY VIA REMITTANCE - WE CANNOT A ACCEPT CHECKS ) ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2350+nPosMais,800,"Account with  : ING Belgium NV - Bruxelas ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2400+nPosMais,800,"Swift Code      : BBRUBEBB010 ",oFont08a,,CLR_BLACK)      
	   		oPrint:Say(2450+nPosMais,800,"Account Nr      : 301-0104579-94 ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2500+nPosMais,800,"In favor of       : Banco Itaú S.A. ",oFont08a,,CLR_BLACK)     
	   		oPrint:Say(2550+nPosMais,800,"Swift Code      : ITAUBRSP ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2600+nPosMais,800,"For Further Credit to: GRANT THORNTON CORPORATE CONSULTORES DE NEGÓCIOS LTDA. ",oFont08a,,CLR_BLACK)  	
	   		oPrint:Say(2650+nPosMais,800,"Branch Number   : 0190 ",oFont08a,,CLR_BLACK)
	    	oPrint:Say(2700+nPosMais,800,"Account Number : 19.382-1 ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2750+nPosMais,800,"Fee             : OUR ",oFont08a,,CLR_BLACK) //AOA - 20/09/2016 - Inclusão de instrução, chamado 036262
	   			   	
		EndIf   
	
	Else
	
		If  cMoe == 2    
		
		   	oPrint:Say(2200+nPosMais,100,"Please make payment arranging a direct deposit in our our account as follows: ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2300+nPosMais,500,"Wire transfer ( PLEASE PAY VIA REMITTANCE - WE CANNOT A ACCEPT CHECKS ) ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2350+nPosMais,800,"Account with  : Standard Chartered Bank – New York – USA ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2400+nPosMais,800,"Swift(Bic Code): SCBLUS33XXX ",oFont08a,,CLR_BLACK)      
	   		oPrint:Say(2450+nPosMais,800,"Clearing Code: ABA 026002561 / CHIPS UID 0256",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2500+nPosMais,800,"In favor of       : Banco Santander (Brasil) S.A. ",oFont08a,,CLR_BLACK)     
	   		oPrint:Say(2550+nPosMais,800,"Swift Code      : BSCHBRSP ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2600+nPosMais,800,"For Further Credit to:	GRANT THORNTON CORPORATE CONSULTORES DE NEGÓCIOS LTDA. ",oFont08a,,CLR_BLACK)  	
	   		oPrint:Say(2650+nPosMais,800,"Branch Number   : 3853 ",oFont08a,,CLR_BLACK)
	 		oPrint:Say(2700+nPosMais,800,"Account Number : 13-005983-8 ",oFont08a,,CLR_BLACK) 	   		
	   		oPrint:Say(2750+nPosMais,800,"Fee             : OUR ",oFont08a,,CLR_BLACK) //AOA - 20/09/2016 - Inclusão de instrução, chamado 036262
	   			   	   
	 	ElseIf cMoe == 5 .Or. cMoe == 3  
	 	
		   	oPrint:Say(2200+nPosMais,100,"Please make payment arranging a direct deposit in our our account as follows: ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2300+nPosMais,500,"Wire transfer ( PLEASE PAY VIA REMITTANCE - WE CANNOT A ACCEPT CHECKS ) ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2350+nPosMais,800,"Account with  : Banco Santander S/A – Madrid – España  ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2400+nPosMais,800,"Swift(Bic Code): BSCHESMMXXX ",oFont08a,,CLR_BLACK)      
	   		oPrint:Say(2450+nPosMais,800,"Clearing Code: 15439",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2500+nPosMais,800,"In favor of       : Banco Santander (Brasil) S.A. ",oFont08a,,CLR_BLACK)     
	   		oPrint:Say(2550+nPosMais,800,"Swift Code      : BSCHBRSP ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2600+nPosMais,800,"For Further Credit to:	GRANT THORNTON CORPORATE CONSULTORES DE NEGÓCIOS LTDA. ",oFont08a,,CLR_BLACK)  	
	   		oPrint:Say(2650+nPosMais,800,"Branch Number   : 3853 ",oFont08a,,CLR_BLACK)
	 		oPrint:Say(2700+nPosMais,800,"Account Number : 13-005983-8 ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2750+nPosMais,800,"Fee             : OUR ",oFont08a,,CLR_BLACK) //AOA - 20/09/2016 - Inclusão de instrução, chamado 036262
	   			 		
	 	ElseIf cMoe == 6
	 	
		   	oPrint:Say(2200+nPosMais,100,"Please make payment arranging a direct deposit in our our account as follows: ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2300+nPosMais,500,"Wire transfer ( PLEASE PAY VIA REMITTANCE - WE CANNOT A ACCEPT CHECKS ) ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2350+nPosMais,800,"Account with			: Royal Bank of Canada – Toronto – Canada  ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2400+nPosMais,800,"Swift(Bic Code)		: ROYCCAT2XXX ",oFont08a,,CLR_BLACK)      
	   		oPrint:Say(2450+nPosMais,800,"Account Number		: 095912051720",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2500+nPosMais,800,"Beneficiary Bank		: Banco Santander (Brasil) S.A. ",oFont08a,,CLR_BLACK)     
	   		oPrint:Say(2550+nPosMais,800,"Swift Code			: BSCHBRSP ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2600+nPosMais,800,"For Further Credit to	: GRANT THORNTON CORPORATE CONSULTORES DE NEGÓCIOS LTDA. ",oFont08a,,CLR_BLACK)  	
	   		oPrint:Say(2650+nPosMais,800,"Branch Number			: 3853 ",oFont08a,,CLR_BLACK)
	 		oPrint:Say(2700+nPosMais,800,"Account Number		: 13-005983-8 ",oFont08a,,CLR_BLACK)	 	 
	   		oPrint:Say(2750+nPosMais,800,"Fee             : OUR ",oFont08a,,CLR_BLACK) //AOA - 20/09/2016 - Inclusão de instrução, chamado 036262
	   			
		EndIf
	
	EndIf  
	
	
ElseIf SM0->M0_CODIGO $ "ZB"

	If nBanco == 1


		If  cMoe == 2    
		
		   	oPrint:Say(2200+nPosMais,100,"Please make payment arranging a direct deposit in our our account as follows: ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2300+nPosMais,500,"Wire transfer ( PLEASE PAY VIA REMITTANCE - WE CANNOT A ACCEPT CHECKS ) ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2350+nPosMais,800,"Account with  : Deutsche Bank JPMorgan Chase Bank, N.A ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2400+nPosMais,800,"Swift Code      : CHASUS33 ",oFont08a,,CLR_BLACK)      
	   		oPrint:Say(2450+nPosMais,800,"Account Nr      : 544705690  ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2500+nPosMais,800,"In favor of       : Banco Itaú S.A. ",oFont08a,,CLR_BLACK)     
	   		oPrint:Say(2550+nPosMais,800,"Swift Code      : ITAUBRSP ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2600+nPosMais,800,"For Further Credit to:	GRANT THORNTON AUDITORES INDEPENDENTES. ",oFont08a,,CLR_BLACK)  	
	   		oPrint:Say(2650+nPosMais,800,"Branch Number   : 0190 ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2700+nPosMais,800,"Account Number : 19.380-5 ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2750+nPosMais,800,"Fee             : OUR ",oFont08a,,CLR_BLACK) //AOA - 20/09/2016 - Inclusão de instrução, chamado 036262
	   			   		
	 	ElseIf cMoe == 5 .Or. cMoe == 3 
	 	
	 		oPrint:Say(2200+nPosMais,100,"Please make payment arranging a direct deposit in our our account as follows: ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2300+nPosMais,500,"Wire transfer ( PLEASE PAY VIA REMITTANCE - WE CANNOT A ACCEPT CHECKS ) ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2350+nPosMais,800,"Account with  : ING Belgium NV - Bruxelas ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2400+nPosMais,800,"Swift Code      : BBRUBEBB010 ",oFont08a,,CLR_BLACK)      
	   		oPrint:Say(2450+nPosMais,800,"Account Nr      : 301-0104579-94 ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2500+nPosMais,800,"In favor of       : Banco Itaú S.A. ",oFont08a,,CLR_BLACK)     
	   		oPrint:Say(2550+nPosMais,800,"Swift Code      : ITAUBRSP ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2600+nPosMais,800,"For Further Credit to:	GRANT THORNTON AUDITORES INDEPENDENTES.",oFont08a,,CLR_BLACK)  	
	   		oPrint:Say(2650+nPosMais,800,"Branch Number   : 0190 ",oFont08a,,CLR_BLACK)
    		oPrint:Say(2700+nPosMais,800,"Account Number : 19.380-5 ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2750+nPosMais,800,"Fee             : OUR ",oFont08a,,CLR_BLACK) //AOA - 20/09/2016 - Inclusão de instrução, chamado 036262
	   			   	
		EndIf   
	
	Else
	
		If  cMoe == 2    
		
		   	oPrint:Say(2200+nPosMais,100,"Please make payment arranging a direct deposit in our our account as follows: ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2300+nPosMais,500,"Wire transfer ( PLEASE PAY VIA REMITTANCE - WE CANNOT A ACCEPT CHECKS ) ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2350+nPosMais,800,"Account with  : Standard Chartered Bank – New York – USA ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2400+nPosMais,800,"Swift(Bic Code): SCBLUS33XXX ",oFont08a,,CLR_BLACK)      
	   		oPrint:Say(2450+nPosMais,800,"Clearing Code: ABA 026002561 / CHIPS UID 0256",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2500+nPosMais,800,"In favor of       : Banco Santander (Brasil) S.A. ",oFont08a,,CLR_BLACK)     
	   		oPrint:Say(2550+nPosMais,800,"Swift Code      : BSCHBRSP ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2600+nPosMais,800,"For Further Credit to:	GRANT THORNTON AUDITORES INDEPENDENTES . ",oFont08a,,CLR_BLACK)  	
	   		oPrint:Say(2650+nPosMais,800,"Branch Number   : 3853 ",oFont08a,,CLR_BLACK)
	 		oPrint:Say(2700+nPosMais,800,"Account Number : 13-005941-2",oFont08a,,CLR_BLACK) 	   		
	   		oPrint:Say(2750+nPosMais,800,"Fee             : OUR ",oFont08a,,CLR_BLACK) //AOA - 20/09/2016 - Inclusão de instrução, chamado 036262
	   			   	   
	 	ElseIf cMoe == 5 .Or. cMoe == 3 
	 	
		   	oPrint:Say(2200+nPosMais,100,"Please make payment arranging a direct deposit in our our account as follows: ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2300+nPosMais,500,"Wire transfer ( PLEASE PAY VIA REMITTANCE - WE CANNOT A ACCEPT CHECKS ) ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2350+nPosMais,800,"Account with  : Banco Santander S/A – Madrid – España  ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2400+nPosMais,800,"Swift(Bic Code): BSCHESMMXXX ",oFont08a,,CLR_BLACK)      
	   		oPrint:Say(2450+nPosMais,800,"Clearing Code: 15439",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2500+nPosMais,800,"In favor of       : Banco Santander (Brasil) S.A. ",oFont08a,,CLR_BLACK)     
	   		oPrint:Say(2550+nPosMais,800,"Swift Code      : BSCHBRSP ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2600+nPosMais,800,"For Further Credit to:	GRANT THORNTON AUDITORES INDEPENDENTES. ",oFont08a,,CLR_BLACK)  	
	   		oPrint:Say(2650+nPosMais,800,"Branch Number   : 3853 ",oFont08a,,CLR_BLACK)
	 		oPrint:Say(2700+nPosMais,800,"Account Number : 13-005941-2",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2750+nPosMais,800,"Fee             : OUR ",oFont08a,,CLR_BLACK) //AOA - 20/09/2016 - Inclusão de instrução, chamado 036262
	   			 		
	 	ElseIf cMoe == 6

		   	oPrint:Say(2200+nPosMais,100,"Please make payment arranging a direct deposit in our our account as follows: ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2300+nPosMais,500,"Wire transfer ( PLEASE PAY VIA REMITTANCE - WE CANNOT A ACCEPT CHECKS ) ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2350+nPosMais,800,"Account with			: Royal Bank of Canada – Toronto – Canada  ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2400+nPosMais,800,"Swift(Bic Code)		: ROYCCAT2XXX ",oFont08a,,CLR_BLACK)      
	   		oPrint:Say(2450+nPosMais,800,"Account Number		: 095912051720",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2500+nPosMais,800,"Beneficiary Bank		: Banco Santander (Brasil) S.A. ",oFont08a,,CLR_BLACK)     
	   		oPrint:Say(2550+nPosMais,800,"Swift Code			: BSCHBRSP ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2600+nPosMais,800,"For Further Credit to	: GRANT THORNTON AUDITORES INDEPENDENTES. ",oFont08a,,CLR_BLACK)  	
	   		oPrint:Say(2650+nPosMais,800,"Branch Number			: 3853 ",oFont08a,,CLR_BLACK)
	 		oPrint:Say(2700+nPosMais,800,"Account Number		: 13-005941-2",oFont08a,,CLR_BLACK)	 	
	   		oPrint:Say(2750+nPosMais,800,"Fee             : OUR ",oFont08a,,CLR_BLACK) //AOA - 20/09/2016 - Inclusão de instrução, chamado 036262
	   			
		EndIf
	
	EndIf  
	

ElseIf SM0->M0_CODIGO $ "Z8"


	If nBanco == 1

		If cMoe == 2 .Or. cMoe == 5
			
		   	oPrint:Say(2200+nPosMais,100,"Please make payment arranging a direct deposit in our our account as follows: ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2300+nPosMais,500,"Wire transfer ( PLEASE PAY VIA REMITTANCE - WE CANNOT A ACCEPT CHECKS ) ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2350+nPosMais,800,"Account with          : Sunstate Bank ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2400+nPosMais,800,"Swift           	           : SUTTUS33 ",oFont08a,,CLR_BLACK) //AOA - 20/09/2016 - Inclusão de instrução, chamado 035751     
	   		oPrint:Say(2450+nPosMais,800,"Bank address         : 2901 S LeJeune Road - Coral Gables, FL 33134 ",oFont08a,,CLR_BLACK)      
	   		oPrint:Say(2500+nPosMais,800,"ABA/Routing           : 067 014 592 ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2550+nPosMais,800,"In favor of               : PRYOR LOCATELLI CONSULTORES LTDA. ",oFont08a,,CLR_BLACK) //AOA - 13/04/2018 - Alterado razao social, ticket 30952     
	   		oPrint:Say(2600+nPosMais,800,"Account Number     : 90004466 ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2650+nPosMais,800,"Fee          	               : OUR ",oFont08a,,CLR_BLACK) //AOA - 20/09/2016 - Inclusão de instrução, chamado 036262
	   			   		
		EndIf
	
	EndIf  
	
	   		
ElseIf SM0->M0_CODIGO $ "RH"
        
	If nBanco == 1

		If  cMoe == 2
		
			oPrint:Say(2200+nPosMais,100,"Please make payment arranging a direct deposit in our our account as follows: ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2300+nPosMais,500,"Wire transfer ( PLEASE PAY VIA REMITTANCE - WE CANNOT A ACCEPT CHECKS ) ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2350+nPosMais,800,"Account with  : Deutsche Bank JPMorgan Chase Bank, N.A ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2400+nPosMais,800,"Swift Code      : CHASUS33 ",oFont08a,,CLR_BLACK)      
	   		oPrint:Say(2450+nPosMais,800,"Account Nr      : 544705690  ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2500+nPosMais,800,"In favor of       : Banco Itaú S.A. ",oFont08a,,CLR_BLACK)     
	   		oPrint:Say(2550+nPosMais,800,"Swift Code      : ITAUBRSP ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2600+nPosMais,800,"For Further Credit to:	PRYOR CONSULTORIA DE RECURSOS HUMANOS LTDA. ",oFont08a,,CLR_BLACK)  	
	   		oPrint:Say(2650+nPosMais,800,"Branch Number   : 0190 ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2700+nPosMais,800,"Account Number : 30.984-9 ",oFont08a,,CLR_BLACK)           
	   		oPrint:Say(2750+nPosMais,800,"Fee             : OUR ",oFont08a,,CLR_BLACK) //AOA - 20/09/2016 - Inclusão de instrução, chamado 036262		
	        
	 	ElseIf cMoe == 5 .Or. cMoe == 3
	 	
	 		oPrint:Say(2200+nPosMais,100,"Please make payment arranging a direct deposit in our our account as follows: ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2300+nPosMais,500,"Wire transfer ( PLEASE PAY VIA REMITTANCE - WE CANNOT A ACCEPT CHECKS ) ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2350+nPosMais,800,"Account with  : ING Belgium NV - Bruxelas ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2400+nPosMais,800,"Swift Code      : BBRUBEBB010 ",oFont08a,,CLR_BLACK)      
	   		oPrint:Say(2450+nPosMais,800,"Account Nr      : 301-0104579-94 ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2500+nPosMais,800,"In favor of       : Banco Itaú S.A. ",oFont08a,,CLR_BLACK)     
	   		oPrint:Say(2550+nPosMais,800,"Swift Code      : ITAUBRSP ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2600+nPosMais,800,"For Further Credit to:	PRYOR CONSULTORIA DE RECURSOS HUMANOS LTDA ",oFont08a,,CLR_BLACK)  	
	   		oPrint:Say(2650+nPosMais,800,"Branch Number   : 0190 ",oFont08a,,CLR_BLACK)
	 		oPrint:Say(2700+nPosMais,800,"Account Number : 30.984-9 ",oFont08a,,CLR_BLACK)      
	   		oPrint:Say(2750+nPosMais,800,"Fee             : OUR ",oFont08a,,CLR_BLACK) //AOA - 20/09/2016 - Inclusão de instrução, chamado 036262
	   			
	    EndIf
	
	Else
	
		If  cMoe == 2    
		
		   	oPrint:Say(2200+nPosMais,100,"Please make payment arranging a direct deposit in our our account as follows: ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2300+nPosMais,500,"Wire transfer ( PLEASE PAY VIA REMITTANCE - WE CANNOT A ACCEPT CHECKS ) ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2350+nPosMais,800,"Account with  : Standard Chartered Bank – New York – USA ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2400+nPosMais,800,"Swift(Bic Code): SCBLUS33XXX ",oFont08a,,CLR_BLACK)      
	   		oPrint:Say(2450+nPosMais,800,"Clearing Code: ABA 026002561 / CHIPS UID 0256",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2500+nPosMais,800,"In favor of       : Banco Santander (Brasil) S.A. ",oFont08a,,CLR_BLACK)     
	   		oPrint:Say(2550+nPosMais,800,"Swift Code      : BSCHBRSP ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2600+nPosMais,800,"For Further Credit to:	PRYOR CONSULTORIA DE RECURSOS HUMANOS LTDA.",oFont08a,,CLR_BLACK)  	
	   		oPrint:Say(2650+nPosMais,800,"Branch Number   : 3853 ",oFont08a,,CLR_BLACK)
	 		oPrint:Say(2700+nPosMais,800,"Account Number : 13-000388-2",oFont08a,,CLR_BLACK) 	   		
	   		oPrint:Say(2750+nPosMais,800,"Fee             : OUR ",oFont08a,,CLR_BLACK) //AOA - 20/09/2016 - Inclusão de instrução, chamado 036262
	   			   	   
	 	ElseIf cMoe == 5 .Or. cMoe == 3 
	 	
		   	oPrint:Say(2200+nPosMais,100,"Please make payment arranging a direct deposit in our our account as follows: ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2300+nPosMais,500,"Wire transfer ( PLEASE PAY VIA REMITTANCE - WE CANNOT A ACCEPT CHECKS ) ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2350+nPosMais,800,"Account with  : Banco Santander S/A – Madrid – España  ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2400+nPosMais,800,"Swift(Bic Code): BSCHESMMXXX ",oFont08a,,CLR_BLACK)      
	   		oPrint:Say(2450+nPosMais,800,"Clearing Code: 15439",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2500+nPosMais,800,"In favor of       : Banco Santander (Brasil) S.A. ",oFont08a,,CLR_BLACK)     
	   		oPrint:Say(2550+nPosMais,800,"Swift Code      : BSCHBRSP ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2600+nPosMais,800,"For Further Credit to:	PRYOR CONSULTORIA DE RECURSOS HUMANOS LTDA.",oFont08a,,CLR_BLACK)  	
	   		oPrint:Say(2650+nPosMais,800,"Branch Number   : 3853 ",oFont08a,,CLR_BLACK)
	 		oPrint:Say(2700+nPosMais,800,"Account Number : 13-000388-2",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2750+nPosMais,800,"Fee             : OUR ",oFont08a,,CLR_BLACK) //AOA - 20/09/2016 - Inclusão de instrução, chamado 036262
	   			
		EndIf
	
	EndIf

//RRP - 01/04/2013 - Inclusão da Empresa OUTSOURCING RJ
//RRP - 02/04/2013 - Inclusão da Empresa SERVICOS DE APOIO RJ	
ElseIf SM0->M0_CODIGO $ "4K/4C"
        
	If nBanco == 1

		MsgInfo("Empresa não possui parametrização para o Banco Itaú."+CHR(13)+CHR(10)+;
				"Será impresso a invoice sem informações do banco no rodapé!")
	
	Else
	
		If cMoe == 2 .OR. cMoe == 3 .OR. cMoe == 5 
	 	
		   	oPrint:Say(2200+nPosMais,100,"Please make payment arranging a direct deposit in our our account as follows: ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2300+nPosMais,500,"Wire transfer ( PLEASE PAY VIA REMITTANCE - WE CANNOT A ACCEPT CHECKS ) ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2350+nPosMais,800,"Account with  : Standard Chartered Bank – New York – USA ",oFont08a,,CLR_BLACK)
   	   		oPrint:Say(2400+nPosMais,800,"Swift(Bic Code): SCBLUS33XXX ",oFont08a,,CLR_BLACK)      
	   		oPrint:Say(2450+nPosMais,800,"Clearing Code: ABA 026002561 / CHIPS UID 0256 ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2500+nPosMais,800,"In favor of       : Banco Santander (Brasil) S.A. ",oFont08a,,CLR_BLACK)     
	   		oPrint:Say(2550+nPosMais,800,"Swift Code      : BSCHBRSP ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2600+nPosMais,800,"For Further Credit to:	GRANT THORNTON OUTSOURCING SERVIÇOS CONTABEIS LTDA.",oFont08a,,CLR_BLACK)	
	 		//RSB - 27/11/2017 - Alteração na conta da empresa 4K e Adicionar o IBAN CODE - Ticket #17247.
	 		If SM0->M0_CODIGO $ "4K"
				//WFA - 02/01/2018 - Alteração no Branch Number da empresa 4K - Ticket #22526
				oPrint:Say(2650+nPosMais,800,"Branch Number   : 3853 ",oFont08a,,CLR_BLACK)
	 			oPrint:Say(2700+nPosMais,800,"Account Number : 13-006387-9",oFont08a,,CLR_BLACK) 
	 			oPrint:Say(2750+nPosMais,800,"Fee             : OUR ",oFont08a,,CLR_BLACK) //AOA - 20/09/2016 - Inclusão de instrução, chamado 036262
	 			oPrint:Say(2800+nPosMais,800,"IBAN Code: BR4990400888038530130063879C1",oFont08a,,CLR_BLACK)
	   		Else
				oPrint:Say(2650+nPosMais,800,"Branch Number   : 3981 ",oFont08a,,CLR_BLACK)
	 			oPrint:Say(2700+nPosMais,800,"Account Number : 13-001261-1",oFont08a,,CLR_BLACK)//JSS - Alterado conta de 13-001259-4 para 13-001261-1 solucionar o chamado:017839  
	   			oPrint:Say(2750+nPosMais,800,"Fee             : OUR ",oFont08a,,CLR_BLACK) //AOA - 20/09/2016 - Inclusão de instrução, chamado 036262
	   		Endif
	
	   			
		EndIf
	
	EndIf  
	
//AOA - 25/02/2016 - Inclusão da Empresa GT ASSESSORIA	
ElseIf SM0->M0_CODIGO $ "ZA"
        
	If nBanco == 1

		If cMoe == 2 .OR. cMoe == 3 .OR. cMoe == 5 

	 	    // AOA - 20/04/2016 - Alteração de dados bancarios conforme chamado 033368
		   	oPrint:Say(2200+nPosMais,100,"Please make payment arranging a direct deposit in our our account as follows: ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2300+nPosMais,500,"Wire transfer ( PLEASE PAY VIA REMITTANCE - WE CANNOT A ACCEPT CHECKS ) ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2350+nPosMais,800,"Account with          : Sunstate Bank ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2400+nPosMais,800,"Swift           	           : SUTTUS33 ",oFont08a,,CLR_BLACK) //AOA - 20/09/2016 - Inclusão de instrução, chamado 035751     
	   		oPrint:Say(2450+nPosMais,800,"Bank address         : 2901 S LeJeune Road - Coral Gables, FL 33134 ",oFont08a,,CLR_BLACK)      
	   		oPrint:Say(2500+nPosMais,800,"ABA/Routing           : 067 014 592 ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2550+nPosMais,800,"In favor of               : GRANT THORNTON ASSESSORIA EMPRESARIAL LTDA.",oFont08a,,CLR_BLACK)     
	   		oPrint:Say(2600+nPosMais,800,"Account Number     : 90004649 ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2650+nPosMais,800,"Fee          	               : OUR ",oFont08a,,CLR_BLACK) //AOA - 20/09/2016 - Inclusão de instrução, chamado 036262
	   		        
		EndIf

	EndIf

//AOA - 02/03/2016 - Inclusão da Empresa GT CONSULTORIA	
ElseIf SM0->M0_CODIGO $ "ZG"
        
	If nBanco == 1

		MsgInfo("Empresa não possui parametrização para o Banco Itaú."+CHR(13)+CHR(10)+;
				"Será impresso a invoice sem informações do banco no rodapé!")
	
	Else
	
		If cMoe == 2 .OR. cMoe == 3 .OR. cMoe == 5 
	 	
		   	oPrint:Say(2200+nPosMais,100,"Please make payment arranging a direct deposit in our our account as follows: ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2300+nPosMais,500,"Wire transfer ( PLEASE PAY VIA REMITTANCE - WE CANNOT A ACCEPT CHECKS ) ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2350+nPosMais,800,"Account with  : Standard Chartered Bank – New York – USA ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2400+nPosMais,800,"Swift(Bic Code): SCBLUS33XXX ",oFont08a,,CLR_BLACK)      
	   		oPrint:Say(2450+nPosMais,800,"Clearing Code: ABA 026002561 / CHIPS UID 0256",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2500+nPosMais,800,"In favor of       : Banco Santander (Brasil) S.A. ",oFont08a,,CLR_BLACK)     
	   		oPrint:Say(2550+nPosMais,800,"Swift Code      : BSCHBRSP ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2600+nPosMais,800,"For Further Credit to:	GRANT THORNTON AUDITORES INDEPENDENTES . ",oFont08a,,CLR_BLACK)  	
	   		oPrint:Say(2650+nPosMais,800,"Branch Number   : 3853 ",oFont08a,,CLR_BLACK)
	 		oPrint:Say(2700+nPosMais,800,"Account Number : 13-005941-2",oFont08a,,CLR_BLACK) 	   		
	   		oPrint:Say(2750+nPosMais,800,"Fee             : OUR ",oFont08a,,CLR_BLACK) //AOA - 20/09/2016 - Inclusão de instrução, chamado 036262
	   			
		EndIf

	EndIf
	
//WFA - 28/05/2018 - Inclusão da empresa ZP (GT Solutions). Ticket: #35422.
ElseIf SM0->M0_CODIGO $ "ZP"
	
	If nBanco == 1
		MsgInfo("Empresa não possui parametrização para o Banco Itaú."+CHR(13)+CHR(10)+;
			"Será impresso a invoice sem informações do banco no rodapé!")
	Else
		If  cMoe == 2    
		
		   	oPrint:Say(2200+nPosMais,100,"Please make payment arranging a direct deposit in our our account as follows: ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2300+nPosMais,500,"Wire transfer ( PLEASE PAY VIA REMITTANCE - WE CANNOT A ACCEPT CHECKS ) ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2350+nPosMais,800,"Account with  : Standard Chartered Bank – New York – USA ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2400+nPosMais,800,"Swift(Bic Code): SCBLUS33XXX ",oFont08a,,CLR_BLACK)      
	   		oPrint:Say(2450+nPosMais,800,"Clearing Code: ABA 026002561 / CHIPS UID 0256 ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2500+nPosMais,800,"In favor of       : Banco Santander (Brasil) S.A. ",oFont08a,,CLR_BLACK)     
	   		oPrint:Say(2550+nPosMais,800,"Swift Code      : BSCHBRSP ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2600+nPosMais,800,"For Further Credit to:	 GRANT THORNTON CONSULTING SOLUTIONS LTDA ",oFont08a,,CLR_BLACK)  	
	   		oPrint:Say(2650+nPosMais,800,"Branch Number   : 3853 ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2700+nPosMais,800,"Account Number : 13-005933-3 ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2750+nPosMais,800,"Fee             : OUR ",oFont08a,,CLR_BLACK)   		
	 		oPrint:Say(2800+nPosMais,800,"IBAN Code: BR9290400888038530130059333C1",oFont08a,,CLR_BLACK) 	
			
		ElseIf cMoe == 3
			
		   	oPrint:Say(2200+nPosMais,100,"Please make payment arranging a direct deposit in our our account as follows: ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2300+nPosMais,500,"Wire transfer ( PLEASE PAY VIA REMITTANCE - WE CANNOT A ACCEPT CHECKS ) ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2350+nPosMais,800,"Account with  : Royal Bank of Scotland PLC - London - Inglaterra ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2400+nPosMais,800,"Swift(Bic Code): RBOSGB2LXXX ",oFont08a,,CLR_BLACK)      
	   		//oPrint:Say(2450+nPosMais,800,"Clearing Code: ABA 026002561 / CHIPS UID 0256 ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2500+nPosMais,800,"In favor of       : Banco Santander (Brasil) S.A. ",oFont08a,,CLR_BLACK)     
	   		oPrint:Say(2550+nPosMais,800,"Swift Code      : BSCHBRSP ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2600+nPosMais,800,"For Further Credit to:	 GRANT THORNTON CONSULTING SOLUTIONS LTDA ",oFont08a,,CLR_BLACK)  	
	   		oPrint:Say(2650+nPosMais,800,"Branch Number   : 3853 ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2700+nPosMais,800,"Account Number : 13-005933-3 ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2750+nPosMais,800,"Fee             : OUR ",oFont08a,,CLR_BLACK)   		
	 		oPrint:Say(2800+nPosMais,800,"IBAN Code: BR9290400888038530130059333C1",oFont08a,,CLR_BLACK) 
		
		ElseIf cMoe == 5
		
			oPrint:Say(2200+nPosMais,100,"Please make payment arranging a direct deposit in our our account as follows: ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2300+nPosMais,500,"Wire transfer ( PLEASE PAY VIA REMITTANCE - WE CANNOT A ACCEPT CHECKS ) ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2350+nPosMais,800,"Account with  : Banco Santander S/A – Madrid – España ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2400+nPosMais,800,"Swift(Bic Code): BSCHESMMXXX ",oFont08a,,CLR_BLACK)      
	   		//oPrint:Say(2450+nPosMais,800,"Clearing Code: ABA 026002561 / CHIPS UID 0256 ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2500+nPosMais,800,"In favor of       : Banco Santander (Brasil) S.A. ",oFont08a,,CLR_BLACK)     
	   		oPrint:Say(2550+nPosMais,800,"Swift Code      : BSCHBRSP ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2600+nPosMais,800,"For Further Credit to:	 GRANT THORNTON CONSULTING SOLUTIONS LTDA ",oFont08a,,CLR_BLACK)  	
	   		oPrint:Say(2650+nPosMais,800,"Branch Number   : 3853 ",oFont08a,,CLR_BLACK)
	   		oPrint:Say(2700+nPosMais,800,"Account Number : 13-005933-3 ",oFont08a,,CLR_BLACK) 
	   		oPrint:Say(2750+nPosMais,800,"Fee             : OUR ",oFont08a,,CLR_BLACK)   		
	 		oPrint:Say(2800+nPosMais,800,"IBAN Code: BR9290400888038530130059333C1",oFont08a,,CLR_BLACK) 
		EndIf
	EndIf
EndIf
	
Return