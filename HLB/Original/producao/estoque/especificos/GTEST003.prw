#INCLUDE  "protheus.ch"
#INCLUDE  "average.ch"
/*
Funcao      : GTEST003()  
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Rotina de transferência automatica de armazem baseado em nota fiscal de entrada
Autor       : Jean Victor Rocha /Adequação do Fonte EDEST002
Data/Hora   : 
*/
*----------------------*                            
User Function GTEST003()
*----------------------*
Local aItens := {"Transferencia por Nota","Transferencia por Armazem"}

Private nTipo := 0
Private oDlg1
Private oSay1
Private oRMenu1
Private oSBtn1

Private lFci := GETMV("MV_FCICALC",,2) == 1

oDlg1      := MSDialog():New( 156,512,360,867,"HLB BRASIL",,,.F.,,,,,,.T.,,,.T. )
oSay1      := TSay():New( 008,004,{||"Selecione o Tipo de Transferencia:"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,132,008)
GoRMenu1   := TGroup():New( 024,004,088,164,"",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
oRMenu1    := TRadMenu():New( 028,010,aItens,,oDlg1,,,CLR_BLACK,CLR_WHITE,"",,,140,32,,.F.,.F.,.T. )
oSBtn1     := SButton():New( 004,140,1,{|| IIF(nTipo<>0,oDlg1:End(),MsgInfo("Selecione uma opção!")) },oDlg1,,"", )

oRMenu1:bSetGet := {|u| If(PCount()==0,nTipo,nTipo:=u)}
oRMenu1:bWhen   := {|| .T.}
oRMenu1:bValid  := {|| .T.}

oDlg1:Activate(,,,.T.)

If nTipo == 1
	PorNota()
ElseIf nTipo == 2
	PorArmazem()
EndIf

Return .T.

/*
Funcao      : PorNota()  
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Rotina de transferência automatica de armazem baseado em nota fiscal de entrada
Autor       : 
Data/Hora   : 
*/
*-----------------------*
Static Function PorNota()
*-----------------------*
Local oFont
Local oTMsgBar
Local oTMsgItem2
Local oTMsgItem3 
Local oTBtnBmp1    
Local oTBtnBmp2 

Local lRet:=.F.             

Private cDoc   := "" 

Private cNota  :=space(9)
Private cSerie :=space(3) 
Private cLocDes:=space(2)   

Private oDlg
Private lOk     :=.F.
Private aBrowse := Array(0,0,0)    

Private aAuto   := {}
Private aItem   := {}  

DEFINE MSDIALOG oDlg TITLE "Rotina de transferência automatica - Por Nota" FROM 000,000 TO 350,692 PIXEL   
      @ 010,010 Say "Nota :" 			OF oDlg PIXEL 
      @ 009,025 Get cNota  Size 40,10   OF oDlg PIXEL   
      
      @ 010,075 Say "Serie :"   		OF oDlg PIXEL 
      @ 009,100 Get cSerie Size 10,10  Valid  FindSF1() OF oDlg PIXEL          
      
      @ 010,130 Say "Armazem Destino :"   		OF oDlg PIXEL 
      @ 009,180 Get cLocDes Size 10,10   OF oDlg PIXEL   

      oFont := TFont():New('Courier new',,-14,.T.)
      oTMsgBar := TMsgBar():New(oDlg, ' HLB BRASIL',.F.,.F.,.F.,.F., RGB(116,116,116),,oFont,.F.)   
   
      oTMsgItem2 := TMsgItem():New( oTMsgBar,SM0->M0_NOME, 100,,,,.T., {||}) 
      oTMsgItem3 := TMsgItem():New( oTMsgBar,CVERSAO, 100,,,,.T.,{||})
      
      @ 002,002 TO 030,300 LABEL "" OF oDlg PIXEL
      @ 002,303 TO 030,346 LABEL "" OF oDlg PIXEL
      @ 033,002 TO 158,346 LABEL "" OF oDlg PIXEL
                        
      oTBtnBmp1  := TBtnBmp2():New( 16, 615, 26, 26, 'reload'   ,,,,{|| If(lRet:=Valida(),oDlg:End(),"")},oDlg,'Realiza a transferência'    ,,.F.,.F. ) 
      oTBtnBmp2  := TBtnBmp2():New( 16, 645, 26, 26, 'CANCEL'   ,,,,{|| oDlg:End()},oDlg,'Cancela operação'    ,,.F.,.F. )
     
  ACTIVATE MSDIALOG oDlg  CENTERED

Return  
      
/*
Funcao      : PorArmazem()  
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Rotina de transferência automatica de armazem baseado
Autor       : 
Data/Hora   : 
*/
*--------------------------*
Static Function PorArmazem()
*--------------------------*
Private cNota		:= space(TamSX3("D1_DOC")[1])
Private cSerie		:= space(TamSX3("D1_SERIE")[1])
Private cFornece	:= Space(TamSX3("D1_FORNECE")[1])

Private oDlg

Private lOk     :=.F.

Private aAuto   := {}

Private aCoBrw1 := {}
Private aHoBrw1 := {}
Private oBrw1

oDlg	:= MSDialog():New( 000,000,350,692,"Rotina de transferência automatica - Por Armazem",,,.F.,,,,,,.T.,,,.T. )

oSBox1	:= TScrollBox():New( oDlg,002,002,030,300,.F.,.F.,.T. )
oSBox2	:= TScrollBox():New( oDlg,002,303,030,043,.F.,.F.,.T. )
oSBox3	:= TScrollBox():New( oDlg,033,002,125,344,.F.,.F.,.T. )

oSay1	:= TSay():New( 010,010,{|| "Nota :"},oSBox1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,176,008)
oGet1	:= TGet():New( 009,025,{|u| IF(PCount()>0,cNota:=u,cNota)},oSBox1,030,008,"@!",,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
      
oSay2	:= TSay():New( 010,075,{|| "Serie :"},oSBox1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,176,008)
oGet2	:= TGet():New( 009,100,{|u| IF(PCount()>0,cSerie:=u,cSerie)},oSBox1,030,008,"@!",,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)

oSay3	:= TSay():New( 010,130,{|| "Fornec.:"},oSBox1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,176,008)
oGet3	:= TGet():New( 009,180,{|u| IF(PCount()>0,cFornece:=u,cFornece)},oSBox1,030,008,"@!",{|| FindSF1()},CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)

oFont := TFont():New('Courier new',,-14,.T.)
oTMsgBar := TMsgBar():New(oDlg, ' HLB BRASIL',.F.,.F.,.F.,.F., RGB(116,116,116),,oFont,.F.)   
oTMsgItem2 := TMsgItem():New( oTMsgBar,SM0->M0_NOME, 100,,,,.T., {||}) 
oTMsgItem3 := TMsgItem():New( oTMsgBar,CVERSAO, 100,,,,.T.,{||})

oTBtnBmp1  := TBtnBmp2():New( 16, 615, 26, 26, 'reload'   ,,,,{|| If(lRet:=Valida(),oDlg:End(),FindSF1())}	,oDlg,'Realiza a transferência'		,,.F.,.F. ) 
oTBtnBmp2  := TBtnBmp2():New( 16, 645, 26, 26, 'CANCEL'   ,,,,{|| oDlg:End()}			 					,oDlg,'Cancela operação'			,,.F.,.F. )

oDlg:Activate(,,,.T.)

Return .T.
  
/*
Funcao      : FindSF1()  
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Função para mostrar os dados na nota de entrada
Autor       : Tiago Luiz Mendonça
Data/Hora   : 31/10/2011
*/
*-----------------------*
Static Function FindSF1()
*-----------------------*
Local cLocal 	:= ""
Local lLocal :=.T.
Local lSD3   :=.F.
Local n      := 1   

If nTipo == 1//por Nota
	//Cria objeto para dados da nota 
	oBrowse := TSBrowse():New(35,04,340,120,oDlg,,16,,5)
	oBrowse:AddColumn( TCColumn():New('Nota'		,,,{|| },{|| }) )
	oBrowse:AddColumn( TCColumn():New('Serie'		,,,{|| },{|| }) ) 
	oBrowse:AddColumn( TCColumn():New('Tipo'		,,,{|| },{|| }) )  
	oBrowse:AddColumn( TCColumn():New('Local'		,,,{|| },{|| }) )
	oBrowse:AddColumn( TCColumn():New('Fornecedor'	,,,{|| },{|| }) )     
	oBrowse:AddColumn( TCColumn():New('Nome'		,,,{|| },{|| }) )
	oBrowse:AddColumn( TCColumn():New('Observação'	,,,{|| },{|| }) )

	//Valida a digitação da nota
	If !Empty(cNota)
		SF1->(DbSetOrder(1))    
		//Procura a nota de entrada
		If SF1->(DbSeek(xFilial("SF1")+cNota+cSerie))
			lSD3 := ChecSD3(cNota)
			If lSD3
				lOk:=.F.
				//RRP - 03/10/2013 - Ajuste para carregar o nome correto do fornecedor no aBrowse. 
				SA2->(DbSetOrder(1))
				If SA2->(DbSeek(xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA))
					aBrowse := {{SF1->F1_DOC  ,SF1->F1_SERIE,SF1->F1_TIPO,"",SF1->F1_FORNECE,SA2->A2_NOME,"Nota não pode ser transferida, já existe transferência: "+Alltrim(cNota) }}
	  				oBrowse:SetArray(aBrowse)
	  		 		oBrowse:Refresh()
	  		 	EndIf
	   		Else
				SD1->(DbSetorder(1))
				If SD1->(DbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))	
					//Apenas notas tipo N
					If SD1->D1_TIPO == "N"	
						cLocal := SD1->D1_LOCAL 
						aAuto := {}
		   				aadd(aAuto,{cNota,dDataBase})  //Cabecalho
						//Loop para validar o local e adicionar os itens da nota
						While SD1->(!EOF()) .And. SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA == SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
			    	   		If cLocal <> SD1->D1_LOCAL//Todos itens da nota devem estar no mesmo armazem.
			    		 		lLocal :=.F.
			        		EndIf   
							//JVR - 29/05/2012 - Aglutinação de produtos com o mesmo codigo.
				        	If Len(aAuto) > 1 .And.;
				        		(npos := aScan(aAuto,{ | X |   ALLTRIM(X[1]) ==  ALLTRIM(SD1->D1_COD) }) ) <> 0
								aAuto[nPos][16]+=SD1->D1_QUANT
				        	Else 
				           		SB1->(DbSetOrder(1))
				           		SB1->(DbSeek(xFilial("SB1")+SD1->D1_COD))    
				           		//Cabecalho a Incluir	
							 	aAux := {}
							 	aAdd(aAux, SD1->D1_COD)  		 	//D3_COD
						  		aAdd(aAux, LEFT(SB1->B1_DESC,30))	//D3_DESCRI		
								aAdd(aAux, SD1->D1_UM)  	   	    //D3_UM
								aAdd(aAux, SD1->D1_LOCAL)    		//D3_LOCAL
								aAdd(aAux, "")        				//D3_LOCALIZ
								aAdd(aAux, SD1->D1_COD)  	 		//D3_COD
								aAdd(aAux, LEFT(SB1->B1_DESC,30))	//D3_DESCRI		
								aAdd(aAux, SD1->D1_UM)  			//D3_UM
								aAdd(aAux, cLocDes)         	    //D3_LOCAL
								aAdd(aAux, "")        				//D3_LOCALIZ
								aAdd(aAux, "")        				//D3_NUMSERI
								aAdd(aAux, "")  					//D3_LOTECTL  
								aAdd(aAux, "")    	 				//D3_NUMLOTE
								aAdd(aAux, dDataBase)	 			//D3_DTVALID
								aAdd(aAux, 1)				 		//D3_POTENCI
								aAdd(aAux, SD1->D1_QUANT) 	 		//D3_QUANT
								aAdd(aAux, 0)				 		//D3_QTSEGUM
								aAdd(aAux, "N")         	   		//D3_ESTORNO
								aAdd(aAux, ProxNum())      			//D3_NUMSEQ 
								aAdd(aAux, "")	 					//D3_LOTECTL
								aAdd(aAux, dDataBase)		 		//D3_DTVALID
								aAdd(aAux, "")						//D3_ITEMGRD
								If lFci
									aAdd(aAux, 0)
								EndIf
							 	aadd(aAuto,aAux)
				            EndIf								
			    	   		SD1->(DbSkip())        
				   		EndDo   		
	
				    	//Valida o armazem    
				   		If lLocal
							SA2->(DbSetOrder(1))
							If SA2->(DbSeek(xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA))
				   				aBrowse := {{SF1->F1_DOC  ,SF1->F1_SERIE,SF1->F1_TIPO,cLocal,SF1->F1_FORNECE,SA2->A2_NOME,"Ok p/ transferencia automatica"      }}   
					   	   	Else
						  		aBrowse := {{SF1->F1_DOC  ,SF1->F1_SERIE,SF1->F1_TIPO,cLocal,SF1->F1_FORNECE,"","Ok p/ transferencia automatica"      }}  
	    			   		EndIf
	    					lOk:=.T.         
	    				Else  
	    					aBrowse := {{SF1->F1_DOC  ,SF1->F1_SERIE,SF1->F1_TIPO,"",SF1->F1_FORNECE,SA2->A2_NOME,"Nota não pode ser transferida, possui armazens diferentes"      }}
	    				EndIf
	    			
	    				oBrowse:SetArray(aBrowse)
	  					oBrowse:Refresh()
			   		Else
						lOk:=.F. 
						aBrowse := {{SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_TIPO,"",SF1->F1_FORNECE,"","Nota não pode ser transferida, tipo diferente de NORMAL"      }}   
	    				oBrowse:SetArray(aBrowse)
	  					oBrowse:Refresh()
	    			EndIf
	    		EndIf 
	    	EndIf
		Else
	       	lOk:=.F.   
			aBrowse := {{cNota,cSerie,"","","","","Nota + Serie não encontrada"     }}
			oBrowse:SetArray(aBrowse)
			oBrowse:Refresh()
		EndIf     		
	Else  
		lOk:=.F.
		aBrowse := {{"","","","","","","Informe o parâmetro de nota e serie"     }}
		oBrowse:SetArray(aBrowse)
		oBrowse:Refresh()
	EndIf
	
ElseIf nTipo == 2//por Armazem
	If LEN(aCoBrw1) <> 0
		aCoBrw1 := {}
	EndIf
	
	nOpc := GD_UPDATE//+GD_INSERT+GD_DELETE
	aHoBrw1 := {}
	//Aadd(aHoBrw1je,{Trim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"ALLWAYSTRUE()",SX3->X3_USADO, SX3->X3_TIPO,SX3->X3_F3, SX3->X3_CONTEXT,SX3->X3_CBOX } )
	Aadd(aHoBrw1,{'Nota'		,"NOTA"		,"@!"		,TamSx3("F1_DOC")[1]	,00,""	,"","C",""	,""})
	Aadd(aHoBrw1,{'Serie'  		,"SERIE" 	,"@!"		,TamSx3("F1_SERIE")[1]	,00,""	,"","C",""	,""})
	Aadd(aHoBrw1,{'Tipo'		,"TIPO"		,"@!"		,TamSx3("F1_TIPO")[1]	,00,""	,"","C",""	,""})
	Aadd(aHoBrw1,{'Local De'	,"LOCALDE"	,"@R 99"	,TamSx3("D1_LOCAL")[1]	,00,""	,"","C",""	,""})
	Aadd(aHoBrw1,{'Local Para'	,"LOCALPA"	,"@R 99"	,TamSx3("D1_LOCAL")[1]	,00,""	,"","C",""	,""})
	Aadd(aHoBrw1,{'Fornecedor'	,"FORNECE"	,"@!"		,TamSx3("F1_FORNECE")[1],00,""	,"","C",""	,""})
	Aadd(aHoBrw1,{'Nome'		,"NOME"		,"@!"  		,TamSx3("A2_NOME")[1]	,00,""	,"","C",""	,""})
	Aadd(aHoBrw1,{'Observação'	,"OBSERVA"	,"@!"		,200					,00,""	,"","C",""	,""})
	noBrw1:= Len(aHoBrw1)
	
	aAlter := {"LOCALPA"}
	If !Empty(cNota) .or. !Empty(cFornece)
		SA2->(DbSetOrder(1))
		
		SF1->(DbSetOrder(1))    
		If SF1->(DbSeek(xFilial("SF1")+cNota+cSerie+cFornece))//Procura a nota de entrada
			lSD3 := ChecSD3(cNota)
			
			lForn := SA2->(DbSeek(xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA))
			
			If lSD3
				aAdd(aCoBrw1,{	SF1->F1_DOC,;		//'Nota'
								SF1->F1_SERIE,;		//'Serie'
								SF1->F1_TIPO,;		//'Tipo'
								"",;				//'Local De'
								"",;				//'Local Para'
								SF1->F1_FORNECE,;	//'Fornecedor'."
								IIF(lForn,SA2->A2_NOME,""),;//'Nome'
								"Nota não pode ser transferida, já existe transferência: "+Alltrim(cNota),;//'Observação'
								.F.})				//DELET
				lOk:=.F.
	   		Else
				SD1->(DbSetorder(1))
				If SD1->(DbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))	
					If SD1->D1_TIPO == "N"	//Apenas notas tipo N
						aAuto	:= {}
		   				aadd(aAuto,{cNota,dDataBase})  //Cabecalho
						//Loop para validar o local e adicionar os itens da nota
						While SD1->(!EOF()) .And.;
								SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA == SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA

							//Aglutinação de produtos com o mesmo codigo e que estão no mesmo Armazem
				        	If Len(aAuto) > 0 .And.;
				        		(npos := aScan(aAuto,{ | X |   ALLTRIM(X[1])==ALLTRIM(SD1->D1_COD) .and. ALLTRIM(X[4])==ALLTRIM(SD1->D1_LOCAL) }) ) <> 0
								aAuto[nPos][16] += SD1->D1_QUANT
				        	Else 
				           		SB1->(DbSetOrder(1))
				           		SB1->(DbSeek(xFilial("SB1")+SD1->D1_COD))    
				           		//Cabecalho a Incluir	

							 	aAux := {}
							 	aAdd(aAux, SD1->D1_COD)  		 	//D3_COD
						  		aAdd(aAux, LEFT(SB1->B1_DESC,30))	//D3_DESCRI		
								aAdd(aAux, SD1->D1_UM)  	   	    //D3_UM
								aAdd(aAux, SD1->D1_LOCAL)    		//D3_LOCAL
								aAdd(aAux, "")        				//D3_LOCALIZ
								aAdd(aAux, SD1->D1_COD)  	 		//D3_COD
								aAdd(aAux, LEFT(SB1->B1_DESC,30))	//D3_DESCRI		
								aAdd(aAux, SD1->D1_UM)  			//D3_UM
								aAdd(aAux, "")		        	    //D3_LOCAL
								aAdd(aAux, "")        				//D3_LOCALIZ
								aAdd(aAux, "")        				//D3_NUMSERI
								aAdd(aAux, "")  					//D3_LOTECTL  
								aAdd(aAux, "")    	 				//D3_NUMLOTE
								aAdd(aAux, dDataBase)	 			//D3_DTVALID
								aAdd(aAux, 1)				 		//D3_POTENCI
								aAdd(aAux, SD1->D1_QUANT) 	 		//D3_QUANT
								aAdd(aAux, 0)				 		//D3_QTSEGUM
								aAdd(aAux, "N")         	   		//D3_ESTORNO
								aAdd(aAux, ProxNum())      			//D3_NUMSEQ 
								aAdd(aAux, "")	 					//D3_LOTECTL
								aAdd(aAux, dDataBase)		 		//D3_DTVALID
								aAdd(aAux, "")						//D3_ITEMGRD
								If lFci
									aAdd(aAux, 0)
								EndIf
							 	aadd(aAuto,aAux)

				            EndIf								
					    	//Valida o armazem    
							If (nPos := aScan(aCoBrw1, {|x| ALLTRIM(x[4])==ALLTRIM(SD1->D1_LOCAL) }) ) == 0
							   	aAdd(aCoBrw1,{	SF1->F1_DOC,;//'Nota'
												SF1->F1_SERIE,;//'Serie'
												SF1->F1_TIPO,;//'Tipo'
												SD1->D1_LOCAL,;//'Local De'
												"  ",;//'Local Para'
												SF1->F1_FORNECE,;//'Fornecedor'."
												IIF(lForn,SA2->A2_NOME,""),;//'Nome'
												"Ok p/ transferencia automatica",;//'Observação'
												.F.})//DELET
							EndIf
							
			    	   		SD1->(DbSkip())        
				   		EndDo   		
    					lOk:=.T.         
					Else
						lOk:=.F. 
						Add(aCoBrw1,{	SF1->F1_DOC,;//'Nota'
										SF1->F1_SERIE,;//'Serie'
										SF1->F1_TIPO,;//'Tipo'
										"",;//'Local De'
										"",;//'Local Para'
										SF1->F1_FORNECE,;//'Fornecedor'."
										IIF(lForn,SA2->A2_NOME,""),;//'Nome'
										"Nota não pode ser transferida, tipo diferente de NORMAL",;//'Observação'
										.F.})//DELET
	    			EndIf
	    		EndIf 
	    	EndIf
		Else
	       	lOk:=.F.   
			aAdd(aCoBrw1,{	cNota,;//'Nota'
							cSerie,;//'Serie'
							"",;//'Tipo'
							"",;//'Local De'
							"",;//'Local Para'
							"",;//'Fornecedor'."
							"",;//'Nome'
							"Nota + Serie não encontrada",;//'Observação'
				   			.F.})//DELET
		EndIf     		
	Else
		aAdd(aCoBrw1,{	"",;//'Nota'
						"",;//'Serie'
						"",;//'Tipo'
						"",;//'Local De'
						"",;//'Local Para'
						"",;//'Fornecedor'."
						"",;//'Nome'
						"Informe o parâmetro de nota, serie e Fornecedor",;//'Observação'
						.F.})//DELET
		lOk := .F.
	EndIf

	oBrw1 := MsNewGetDados():New(35,04,156,342,nOpc,'AllwaysTrue()','AllwaysTrue()','',aAlter,0,999,'AllwaysTrue()','','AllwaysTrue()',oDlg,aHoBrw1,aCoBrw1 )
	oBrw1:aHeader	:= aHoBrw1
	oBrw1:aCols		:= aCoBrw1
	oBrw1:Refresh()
EndIf
 
Return          
         
/*
Funcao      : ChecSD3()  
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Função que verifica se existi transferência
Autor       : Tiago Luiz Mendonça
Data/Hora   : 31/10/2011
*/
*----------------------------*
Static Function ChecSD3(cNota)   
*----------------------------*
Local lRet:=.F.

SD3->(DbSetOrder(2))
If SD3->(DbSeek(xFilial("SD3")+cNota))
	While SD3->(!EOF()) .And. cNota == Alltrim(SD3->D3_DOC)
		If Empty(SD3->D3_ESTORNO)
			lRet:=.T.
		EndIf
		       		                  
		SD3->(DbSkip())
	EndDo 
EndIf	
	
Return lRet		

/*
Funcao      : Valida()  
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Função que valida os dados para transferência
Autor       : Tiago Luiz Mendonça
Data/Hora   : 31/10/2011
*/
*------------------------------*
Static Function Valida(aMata240)   
*------------------------------*
Local lRet:=.F.
Local nOpcAuto:= 3 // Indica qual tipo de ação será tomada (Inclusão)   
Local cMsg := ""

Private lMsHelpAuto := .T.
Private lMsErroAuto := .F.

Do Case
	Case nTipo == 1
		If !(lOk)
			MsgAlert("Dados informado não podem ser processados!","Grant Thorton Brasil")
		
		ElseIf Empty(cLocDes) 
			MsgAlert("Armazem deve ser preenchido","Grant Thorton Brasil")
		
		ElseIf Len(Alltrim(cLocDes)) <> 2	
			MsgAlert("Armazem deve ter 2 caracteres","Grant Thorton Brasil")
		
		Else
			For i := 2 to len(aAuto)
				aAuto[i][9]:= cLocDes// Atualiza o local. 
			Next		

			MSExecAuto({|x,y| mata261(x,y)},aAuto,nOpcAuto)

			If lMsErroAuto
				cMsg += MostraErro("\SYSTEM\")+CHR(10)+CHR(13)
				cMsg += "---------------------------------------------"+CHR(10)+CHR(13)
			EndIf  

		EndIf

	Case nTipo == 2
		If !(lOk)
			MsgAlert("Dados informado não podem ser processados!","Grant Thorton Brasil")
		
		ElseIf nTipo == 2
			For i:=1 to Len(oBrw1:aCols)
				If EMPTY(oBrw1:aCols[i][5])
					MsgInfo("Existe Item sem a informação de Local de Destino!","Grant Thorton Brasil")
					Return lRet
				EndIf
			Next i

			//Retira do execauto linhas que não serão processadas.
			aAux	:= aAuto
			aAuto	:= {}
			aAdd(aAuto,aAux[1])
			For i:=2 to len(aAux)
				If (npos:=aScan(oBrw1:aCols,{|x| ALLTRIM(x[4])==ALLTRIM(aAux[i][4])}) ) <> 0 .And.;
						oBrw1:aCols[nPos][4] <> oBrw1:aCols[nPos][5]
					aAdd(aAuto,aAux[i])
				EndIf
			Next i
			If len(aAuto) <= 1
 				MsgInfo("Sem informações a serem processadas!","Grant Thorton Brasil")
				Return lRet
			EndIf

			For i := 2 to len(aAuto)  
				aAuto[i][9]:= oBrw1:aCols[aScan(oBrw1:aCols,{|x| ALLTRIM(x[4])==ALLTRIM(aAuto[i][4]) })][5]
				If EMPTY(aAuto[i][9])
					MsgInfo("Falha na atualização do Local de Destino!","Grant Thorton Brasil")
					Return lRet
				EndIf
			Next

			MSExecAuto({|x,y| mata261(x,y)},aAuto,nOpcAuto)

			If lMsErroAuto
				cMsg += MostraErro("\SYSTEM\")+CHR(10)+CHR(13)
				cMsg += "---------------------------------------------"+CHR(10)+CHR(13)
			EndIf  
		EndIf
		
EndCase

If !Empty(cMsg)
	cMsg := "Erro na transferencia :"+CHR(10)+CHR(13) + cMsg
	EECVIEW(cMsg)
	MsgStop("Erro na inclusao!")
Else
	MsgInfo("Tranferencia Finalizada com sucesso. " + cNota)	
	lRet:=.T.
EndIf  
    
Return  lRet