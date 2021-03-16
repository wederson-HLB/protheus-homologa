#INCLUDE "PROTHEUS.CH" 
#INCLUDE "RWMAKE.CH" 
#INCLUDE "FONT.CH" 
#INCLUDE "COLORS.CH" 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³N6GEN004  º Autor ³ William Souza      º Data ³  05/03/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Monitor de transações                                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User function N6GEN004()

	Local oButton1,oComboBol,oRadio,oGetPesq
  //	Local oGet1,oGet,oGet,oGet4

	Local oGroup1,oGroup2,oGroup3,oGroup4,oGroup5,oGroup6,oGroup7,oGroup8
  //	Local oSay1,oSay2,oSay3,oSay4,oSay5,oSay6 
   Local cPesquisa := space(10)
   Local nRadio    := 1
	Local aSize     := MsAdvSize(.T.,.F.)
	Local aObjects  := {}
	Local aButtons  := {}   
	
	Local oBrowse   := nil
	Local oBrowse2  := nil  
	Local oBrowse3  := nil
	Local oBrowse4  := nil 
	
	Local aBrowse   := {}
	Local aBrowse2  := {} 
	Local aBrowse3  := {}
	Local aBrowse4  := {}
	Private aText   := {}
	Private aText2  := {}
	
	Private aSizeAut  := MsAdvSize(.T.,.F.) 
	Private oCinza    := LoadBitmap(GetResources(),'BR_CINZA')
	Private oLaranja  := LoadBitmap(GetResources(),'BR_LARANJA') 
	Private oVerdeE   := LoadBitmap(GetResources(),'BR_VERDE_ESCURO')
	Private oAmarelo  := LoadBitmap(GetResources(),'BR_AMARELO') 
	Private oPink     := LoadBitmap(GetResources(),'BR_PINK')
	Private oVermelho := LoadBitmap(GetResources(),'BR_VERMELHO')
	Private oVerde    := LoadBitmap(GetResources(),'BR_VERDE')
	Private oBranco   := LoadBitmap(GetResources(),'BR_BRANCO') 
	Private cErro     := ""
	Private cConteudo := "" 
	
	
	Static oDlg
	
	aObjects := {}
	AAdd( aObjects, { 100, 030, .T., .T.} )
	AAdd( aObjects, { 100, 070, .T., .T.} ) 
	Aadd( aButtons, {"Fluxograma", {|| alert('Em desenvolvimento')}, "Parametros", "Histórico" , {|| .T.}} )
	
	aInfo    := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj  := MsObjSize( aInfo, aObjects, .T., .F. )    	
	  	
	DEFINE MSDIALOG oDlg TITLE "Multas a serem pagas" FROM aSize[7],0 to aSize[6],aSize[5] COLORS 0, 16777215 PIXEL 
	          
	   @ 004, 004 FOLDER cFolder SIZE aPosObj[2,4]-2,aPosObj[2,3]+10 OF oDlg ITEMS "Saída","Entrada" COLORS 0, 16777215 PIXEL
	   
	   
	   /*---------------------------------------------------- ABA Saída ----------------------------------------------------*/
	                  
      //Grupos
    	@ 001             , 002              GROUP oGroup3 TO aPosObj[2,3]-110, aPosObj[2,4]-6   PROMPT "Pedido de Venda" OF cFolder:aDialogs[1] COLOR 0, 16777215 PIXEL  	 
    	@ aPosObj[2,3]-110, 002              GROUP oGroup1 TO aPosObj[2,3]-6  , aPosObj[2,4]-328 PROMPT "Logs"            OF cFolder:aDialogs[1] COLOR 0, 16777215 PIXEL	    
	   @ aPosObj[2,3]-110, aPosObj[2,4]-325 GROUP oGroup2 TO aPosObj[2,3]-6  , aPosObj[2,4]-6   PROMPT "Detalhes"        OF cFolder:aDialogs[1] COLOR 0, 16777215 PIXEL
	   
	   
	   //Grid Logs - Aba Saida 
	   oBrowse := TCBrowse():New( aPosObj[2,3] - 101, 5, aPosObj[2,4]-336,aPosObj[2,3] - 179,,{'TIPO','DATA','HORA','TRANSACAO','RECNO'},{10,100,100,100,100},cFolder:aDialogs[1],,,,,{||},,,,,,,.F.,,.T.,,.F.,,,)  
		aAdd(aBrowse,{oBranco,'','','','',''})
		oBrowse:SetArray(aBrowse)
		oBrowse:bLine  := {||{aBrowse[oBrowse:nAt,01],aBrowse[oBrowse:nAt,02],aBrowse[oBrowse:nAt,03],aBrowse[oBrowse:nAt,04] }}
	   
	   //Grid Pedidos - Aba Saida
	   oBrowse3 := TWBrowse():New( 22, 5, aPosObj[2,4]-14,aPosObj[2,3]-135,,{'','STATUS','PEDIDO DE VENDA','DATATRAX','COD.FEDEX','DATA FEDEX','RECNO'},{10,20,100,100,100,100,100},cFolder:aDialogs[1],,,,,{||},,,,,,,.F.,,.T.,,.F.,,,) 
  	   aAdd(aBrowse3,{oBranco,'','','','','',''})  
	
		oBrowse3:SetArray(aBrowse3)
	 	oBrowse3:bLine      := {||{aBrowse3[oBrowse3:nAt,01],aBrowse3[oBrowse3:nAt,02],aBrowse3[oBrowse3:nAt,03],aBrowse3[oBrowse3:nAt,04],aBrowse3[oBrowse3:nAt,05],aBrowse3[oBrowse3:nAt,06],aBrowse3[oBrowse3:nAt,07] }} 
	 	oBrowse3:bLDblClick := {||N6GEN02(aBrowse3[oBrowse3:nAt,02],oBrowse)}  
	 	
	 	//Campos detalhes 
	   @ aPosObj[2,3]-100, aPosObj[2,4]-322 SAY  "Tipo"    SIZE 025, 007 OF cFolder:aDialogs[1] COLORS 0, 16777215 PIXEL
    	@ aPosObj[2,3]-100, aPosObj[2,4]-280 SAY  "Data"    SIZE 025, 007 OF cFolder:aDialogs[1] COLORS 0, 16777215 PIXEL
    	@ aPosObj[2,3]-100, aPosObj[2,4]-236 SAY  "Hora"    SIZE 021, 007 OF cFolder:aDialogs[1] COLORS 0, 16777215 PIXEL
    	@ aPosObj[2,3]-100, aPosObj[2,4]-200 SAY  "Serviço" SIZE 025, 007 OF cFolder:aDialogs[1] COLORS 0, 16777215 PIXEL
		@ aPosObj[2,3]-53 , aPosObj[2,4]-322 SAY  "Conteúdo" SIZE 025, 007 OF cFolder:aDialogs[1] COLORS 0, 16777215 PIXEL 
		@ aPosObj[2,3]-78 , aPosObj[2,4]-322 SAY  "Mensagem Erro" SIZE 045, 007 OF cFolder:aDialogs[1] COLORS 0, 16777215 PIXEL 
    	 
    	aadd(aText,TSay():Create(cFolder:aDialogs[1],{||space(1)},aPosObj[2,3]-90 ,aPosObj[2,4]-322,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20)) 
    	aadd(aText,TSay():Create(cFolder:aDialogs[1],{||space(10)},aPosObj[2,3]-90,aPosObj[2,4]-280,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20))
    	aadd(aText,TSay():Create(cFolder:aDialogs[1],{||space(10)},aPosObj[2,3]-90,aPosObj[2,4]-236,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20))
     	aadd(aText,TSay():Create(cFolder:aDialogs[1],{||space(30)},aPosObj[2,3]-90,aPosObj[2,4]-200,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20))
     	aadd(aText,TGet():Create(cFolder:aDialogs[1],{|u|if(Pcount()>0,cErro:=u,cErro)    },aPosObj[2,3]-70 , aPosObj[2,4]-322,247, 010, "@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cErro,,,, ))
     	aadd(aText,tMultiget():create(cFolder:aDialogs[1], {|u|if(Pcount()>0,cConteudo,cConteudo)}, aPosObj[2,3]-45 , aPosObj[2,4]-322, 247, 035, , , , , , .T. ))
    	
    	//botoes
      
      //Pequisa de Pedido de venda
      
      oRadio := TRadMenu():Create(cFolder:aDialogs[1],{|u|Iif (PCount()==0,nRadio,nRadio:=u)},0010,010,{'Pedido de Venda','Datatrax'},,,,,,,,100,12,,,,.T.)
      oRadio:lHoriz := .T. 
      oRadio:SetOption(1)
      oGetPesq := TGet():Create(cFolder:aDialogs[1],{|u| If(PCount()>0,cPesquisa:=u,cPesquisa)},007 ,95 ,30, 010, "@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cPesquisa,,,, ) 
      @ 007, 128  BUTTON oButton1 PROMPT "Pesquisar" SIZE 037, 012 OF cFolder:aDialogs[1] action (N6GEN01(oBrowse3,oBrowse,cFolder:aDialogs[1],,cvaltochar(nRadio),oGetPesq:cText)) PIXEL 
     // @ 007, 168  BUTTON oButton1 PROMPT "Pedido de Venda" SIZE 043	, 012 OF cFolder:aDialogs[1] action (N6GEN04("SC5",aBrowse3[oBrowse3:nAt,07]))	 PIXEL  
      @ 007, 168  BUTTON oButton1 PROMPT "Pedido de Venda" SIZE 043	, 012 OF cFolder:aDialogs[1] action (N6GEN04(aBrowse3))	 PIXEL 
      @ 007, 214  BUTTON oButton1 PROMPT "Reprocessar" SIZE 037, 012 OF cFolder:aDialogs[1] action (N6GEN05(aBrowse3[oBrowse3:nAt,07],aBrowse3[oBrowse3:nAt,02])) PIXEL 
      
      //filtro de Status
    	oComboBol := TComboBox():New(008, aPosObj[2,4]-110,bSetGet(cvaltochar(randomize(1,34000))),{'Picking Transmitido','Picking Recebido','Picking Liberado','Picking Não Liberado','Erro de Webservice','Erro Transmissão SEFAZ','NFe Emitida','PV Novo','Todos'},060,010,cFolder:aDialogs[1],,,,,,.T.)
      oComboBol:nAt := 9
      @ 007, aPosObj[2,4]-47 BUTTON oButton1 PROMPT "Filtrar" SIZE 037, 012 OF cFolder:aDialogs[1] action (N6GEN01(oBrowse3,oBrowse,cFolder:aDialogs[1],oComboBol:nAt,,)) PIXEL  
	    	  
		
	   /*---------------------------------------------------- ABA Entrada ----------------------------------------------------*/ 
	   
 //	   @ 008, aPosObj[2,4]-150 MSCOMBOBOX oComboBo1 VAR nComboBo1 ITEMS {} SIZE 072, 010 OF cFolder:aDialogs[2] COLORS 0, 16777215 PIXEL
    	@ 007, aPosObj[2,4]-68 BUTTON oButton1 PROMPT "Filtrar" SIZE 037, 012 OF cFolder:aDialogs[2] action (fecha(oDlg)) PIXEL 
	   
	    //Grupos
    	@ 001             , 002              GROUP oGroup3 TO aPosObj[2,3]-110, aPosObj[2,4]-6   PROMPT "Pedido de Venda" OF cFolder:aDialogs[2] COLOR 0, 16777215 PIXEL  	 
    	@ aPosObj[2,3]-110, 002              GROUP oGroup1 TO aPosObj[2,3]-6  , aPosObj[2,4]-328 PROMPT "Logs"            OF cFolder:aDialogs[2] COLOR 0, 16777215 PIXEL	    
	   @ aPosObj[2,3]-110, aPosObj[2,4]-325 GROUP oGroup2 TO aPosObj[2,3]-6  , aPosObj[2,4]-6   PROMPT "Detalhes"        OF cFolder:aDialogs[2] COLOR 0, 16777215 PIXEL
	    
		//Grid Logs - Aba Entrada    
		oBrowse2 := TCBrowse():New( aPosObj[2,3] - 101, 5, aPosObj[2,4]-336,aPosObj[2,3] - 179,,{'TIPO','DATA','HORA','TRANSACAO'},{10,100,100,100},cFolder:aDialogs[2],,,,,{||},,,,,,,.F.,,.T.,,.F.,,,)  	
		aAdd(aBrowse2,{'1','le2c2cpeae','teteste','teste'})
		oBrowse2:SetArray(aBrowse2)
		oBrowse2:bLine  := {||{aBrowse2[oBrowse2:nAt,01],aBrowse2[oBrowse2:nAt,02],aBrowse2[oBrowse2:nAt,03],aBrowse2[oBrowse2:nAt,04] }}
	    	 

		//Grid Pedidos - Aba Entrada    	    
		oBrowse4 := TWBrowse():New( 22, 10, aPosObj[2,4]-14,aPosObj[2,3]-135,,{'','NOTA FISCAL','COD.FEDEX','DATA FEDEX','RECNO'},{10,100,100,100,100,100},cFolder:aDialogs[2],,,,,{||},,,,,,,.F.,,.T.,,.F.,,,) 
		aAdd(aBrowse4,{'1','le2c2cpeae','teteste','teste','teste'}) 
		aAdd(aBrowse4,{'1','ha00edha61','teteste','teste','teste'}) 
		aAdd(aBrowse4,{'1','xi5e81bi26','teteste','teste','teste'}) 
		   		                       
		oBrowse4:SetArray(aBrowse4)
		oBrowse4:bLine      := {||{aBrowse4[oBrowse4:nAt,01],aBrowse4[oBrowse4:nAt,02],aBrowse4[oBrowse4:nAt,03],aBrowse4[oBrowse4:nAt,04],aBrowse4[oBrowse4:nAt,05] }} 
	   oBrowse4:bLDblClick := {||N6GEN02(nLinha,nColuna,aBrowse[oBrowse:nAt,02],oBrowse2)}   
	   
	   //Campos detalhes 
	   @ aPosObj[2,3]-100, aPosObj[2,4]-322 SAY  "Tipo"    SIZE 025, 007 OF cFolder:aDialogs[2] COLORS 0, 16777215 PIXEL
    	@ aPosObj[2,3]-100, aPosObj[2,4]-280 SAY  "Data"    SIZE 025, 007 OF cFolder:aDialogs[2] COLORS 0, 16777215 PIXEL
    	@ aPosObj[2,3]-100, aPosObj[2,4]-236 SAY  "Hora"    SIZE 021, 007 OF cFolder:aDialogs[2] COLORS 0, 16777215 PIXEL
    	@ aPosObj[2,3]-100, aPosObj[2,4]-200 SAY  "Serviço" SIZE 025, 007 OF cFolder:aDialogs[2] COLORS 0, 16777215 PIXEL 
    	 
 /*   	@ aPosObj[2,3]-90 , aPosObj[2,4]-322 SAY cTipo      SIZE 025, 007 OF cFolder:aDialogs[2] COLORS 0, 16777215 PIXEL 
    	@ aPosObj[2,3]-90 , aPosObj[2,4]-280 SAY cData      SIZE 030, 007 OF cFolder:aDialogs[2] COLORS 0, 16777215 PIXEL 
    	@ aPosObj[2,3]-90 , aPosObj[2,4]-236 SAY cHora      SIZE 025, 007 OF cFolder:aDialogs[2] COLORS 0, 16777215 PIXEL 
    	@ aPosObj[2,3]-90 , aPosObj[2,4]-200 SAY cServico   SIZE 050, 007 OF cFolder:aDialogs[2] COLORS 0, 16777215 PIXEL */
    	
/*    	@ aPosObj[2,3]-53 , aPosObj[2,4]-322 SAY  "Conteúdo" SIZE 025, 007 OF cFolder:aDialogs[2] COLORS 0, 16777215 PIXEL
      @ aPosObj[2,3]-45 , aPosObj[2,4]-322 MSGET cConteudo SIZE 248, 032 OF cFolder:aDialogs[2] COLORS 0, 16777215 PIXEL    	 
    	
    	@ aPosObj[2,3]-78 , aPosObj[2,4]-322 SAY oSay5 PROMPT "Mensagem Erro" SIZE 045, 007 OF cFolder:aDialogs[2] COLORS 0, 16777215 PIXEL   	
    	@ aPosObj[2,3]-70 , aPosObj[2,4]-322 MSGET cMsg SIZE 247, 010 OF cFolder:aDialogs[2] COLORS 0, 16777215 PIXEL     */
	    	 
	   
	   ACTIVATE MSDIALOG oDlg ON INIT ()
	
	Return	 
	
/*
-------------------------------------------
Static function para de detalhes da tabela 
SC5
-------------------------------------------
*/ 
Static function N6GEN01(oBrowse,oBrowse2,nAba,nStatus,cTipoPedido,cPedido)  

Local aBrowse :={} 
Local AreaSC5 := GetNextAlias()
Local cSQL    := "SELECT C5_NUM, C5_P_CHAVE, C5_P_STFED, C5_P_DTFED, '123456' as C5_P_DTRAX, R_E_C_N_O_ as 'SC5_RECNO' FROM "+ RetSqlName("SC5") +" "
   
   IF empty(nStatus) .and. empty(cPedido)  
   	Alert("Favor informar o código do pedido de venda.")
   Else
   	If nStatus == 0 
			Alert("Favor Selecionar um status válido")
		Else	
				If !empty(cPedido)
						cSQL += "WHERE "
				ElseIF nStatus > 0 .and. nStatus < 9		
					   cSQL += "WHERE "
				EndIF 
				                                                          
				If !empty(cPedido)
				     If cTipoPedido == '1' 
				     		cSQL += "C5_NUM      = '"+cPedido+"' " 
				     Else
				     		cSQL += "C5_P_DTRAX  = '"+cPedido+"' " 
				     EndIf
				     
				    If !empty(nStatus) 
				     	cSQL += " AND  "
				    EndIf 	
				EndIf 
				
				If !Empty(nStatus)
					If nStatus > 0 .and. nStatus < 9 
						If nStatus == 8
							cSQL += " C5_P_STFED = '' "
						Else
							cSQL += " C5_P_STFED = '"+cValtochar(nStatus)+"' "
						EndIf
					EndIf	
				EndIf
				
				cSQL += "ORDER BY C5_P_DTFED DESC"
				
				//conecto no top e executo o SQL
				cSQL := ChangeQuery(cSQL)
				DbUseArea(.T., "TOPCONN", TcGenQry(,,cSQL), AreaSC5, .F., .T.)  
				
				//logs
				IF !(AreaSC5)->(EOF())
					While !(AreaSC5)->(EOF())
								Do Case 
									Case (AreaSC5)->C5_P_STFED == "01"   
										aAdd(aBrowse,{oCinza,'Picking Transmitido'      ,(AreaSC5)->C5_NUM,(AreaSC5)->C5_P_DTRAX,(AreaSC5)->C5_P_CHAVE,C5_P_DTFED,(AreaSC5)->SC5_RECNO}) 
									Case (AreaSC5)->C5_P_STFED == "02"
						        		aAdd(aBrowse,{oLaranja,'Picking Recebido'   ,(AreaSC5)->C5_NUM,(AreaSC5)->C5_P_DTRAX,(AreaSC5)->C5_P_CHAVE,C5_P_DTFED,(AreaSC5)->SC5_RECNO}) 
									Case (AreaSC5)->C5_P_STFED == "03"
										aAdd(aBrowse,{oVerdeE,'Picking Liberado'      ,(AreaSC5)->C5_NUM,(AreaSC5)->C5_P_DTRAX,(AreaSC5)->C5_P_CHAVE,C5_P_DTFED,(AreaSC5)->SC5_RECNO}) 
									Case (AreaSC5)->C5_P_STFED == "04"
										aAdd(aBrowse,{oAmarelo,'Picking Não Liberado'   ,(AreaSC5)->C5_NUM,(AreaSC5)->C5_P_DTRAX,(AreaSC5)->C5_P_CHAVE,C5_P_DTFED,(AreaSC5)->SC5_RECNO}) 
									Case (AreaSC5)->C5_P_STFED == "05"
										aAdd(aBrowse,{oPink,'Erro de Webservice'        ,(AreaSC5)->C5_NUM,(AreaSC5)->C5_P_DTRAX,(AreaSC5)->C5_P_CHAVE,C5_P_DTFED,(AreaSC5)->SC5_RECNO}) 
									Case (AreaSC5)->C5_P_STFED == "06"
										aAdd(aBrowse,{oPink,'Erro de Webservice Picking'    ,(AreaSC5)->C5_NUM,(AreaSC5)->C5_P_DTRAX,(AreaSC5)->C5_P_CHAVE,C5_P_DTFED,(AreaSC5)->SC5_RECNO}) 
									Case (AreaSC5)->C5_P_STFED == "07"
										aAdd(aBrowse,{oVerde,'Pedido Faturado'              ,(AreaSC5)->C5_NUM,(AreaSC5)->C5_P_DTRAX,(AreaSC5)->C5_P_CHAVE,C5_P_DTFED,(AreaSC5)->SC5_RECNO}) 
									Case (AreaSC5)->C5_P_STFED == "08"
										aAdd(aBrowse,{oVerde,'Pedido Faturado não faturado' ,(AreaSC5)->C5_NUM,(AreaSC5)->C5_P_DTRAX,(AreaSC5)->C5_P_CHAVE,C5_P_DTFED,(AreaSC5)->SC5_RECNO}) 
									Case (AreaSC5)->C5_P_STFED == "09"
									    aAdd(aBrowse,{oVerde,'NF-e Transmitida' ,(AreaSC5)->C5_NUM,(AreaSC5)->C5_P_DTRAX,(AreaSC5)->C5_P_CHAVE,C5_P_DTFED,(AreaSC5)->SC5_RECNO}) 
									Case (AreaSC5)->C5_P_STFED == "10" 
									    aAdd(aBrowse,{oVerde,'NF-e Erro' ,(AreaSC5)->C5_NUM,(AreaSC5)->C5_P_DTRAX,(AreaSC5)->C5_P_CHAVE,C5_P_DTFED,(AreaSC5)->SC5_RECNO}) 
									Case (AreaSC5)->C5_P_STFED == "11"
										aAdd(aBrowse,{oVermelho,'Danfe Ok',(AreaSC5)->C5_NUM,(AreaSC5)->C5_P_DTRAX,(AreaSC5)->C5_P_CHAVE,C5_P_DTFED,(AreaSC5)->SC5_RECNO})  
									Case (AreaSC5)->C5_P_STFED == "12"
									    aAdd(aBrowse,{oVermelho,'Erro Danfe',(AreaSC5)->C5_NUM,(AreaSC5)->C5_P_DTRAX,(AreaSC5)->C5_P_CHAVE,C5_P_DTFED,(AreaSC5)->SC5_RECNO})  
									Case empty((AreaSC5)->C5_P_STFED)
										aAdd(aBrowse,{oBranco,'PV Novo'                 ,(AreaSC5)->C5_NUM,(AreaSC5)->C5_P_DTRAX,(AreaSC5)->C5_P_CHAVE,C5_P_DTFED,(AreaSC5)->SC5_RECNO}) 
						       End Case
							(AreaSC5)->(DbSkip())  	 
					Enddo
				Else
					Alert(IIF(!empty(cPedido),"Não há pedido de venda com esse número informado","Não há pedidos de venda com o status selecionado"))
					aAdd(aBrowse,{'','','','','','',''})
				EndIf 
		
		    	oBrowse:SetArray(aBrowse)
				oBrowse:bLine      := {||{aBrowse[oBrowse:nAt,01],aBrowse[oBrowse:nAt,02],aBrowse[oBrowse:nAt,03],aBrowse[oBrowse:nAt,04],aBrowse[oBrowse:nAt,05],aBrowse[oBrowse:nAt,06],aBrowse[oBrowse:nAt,07] }} 
			 	oBrowse:bLDblClick := {||N6GEN02(aBrowse[oBrowse:nAt,03],oBrowse2)}      
		EndIF
   EndIF
Return  

/*
-------------------------------------------
Static function para preenchimento de 
twbrowser do log da tabela ZX2
-------------------------------------------
*/

Static Function N6GEN02(cValue,oBrowse,nAba)

Local aBrowse := {}
Local AreaZX2 := GetNextAlias()
Local cSQL    := "SELECT ZX2_TIPO,ZX2_DATA,ZX2_HORA,ZX2_SERWS,R_E_C_N_O_ as 'ZX2_RECNO' FROM "+ RetSqlName("ZX2") + " WHERE ZX2_CHAVE ='"+cValue+"' and RIGHT(RTRIM(ZX2_SERWS),4) <> '.XML' order by ZX2_DATA,ZX2_HORA DESC"

//conecto no top e executo o SQL
cSQL := ChangeQuery(cSQL)
DbUseArea(.T., "TOPCONN", TcGenQry(,,cSQL), AreaZX2, .F., .T.)  

//logs
IF !(AreaZX2)->(EOF())
	While !(AreaZX2)->(EOF())
		If (AreaZX2)->ZX2_TIPO == "E"
	       aAdd(aBrowse,{oAmarelo,'Enviado',substr((AreaZX2)->ZX2_DATA,7,2)+"/"+substr((AreaZX2)->ZX2_DATA,5,2)+"/"+substr((AreaZX2)->ZX2_DATA,1,4),(AreaZX2)->ZX2_HORA,(AreaZX2)->ZX2_SERWS,(AreaZX2)->ZX2_RECNO})
	   Else
	       aAdd(aBrowse,{oVerde ,'Recebido',substr((AreaZX2)->ZX2_DATA,7,2)+"/"+substr((AreaZX2)->ZX2_DATA,5,2)+"/"+substr((AreaZX2)->ZX2_DATA,1,4),(AreaZX2)->ZX2_HORA,(AreaZX2)->ZX2_SERWS,(AreaZX2)->ZX2_RECNO})
		EndIf
		(AreaZX2)->(DbSkip())  	
	Enddo
Else 
	aAdd(aBrowse,{'','','','','',''})
EndIf 

oBrowse:SetArray(aBrowse)
oBrowse:bLine  := {||{aBrowse[oBrowse:nAt,01],aBrowse[oBrowse:nAt,02],aBrowse[oBrowse:nAt,03],aBrowse[oBrowse:nAt,04],aBrowse[oBrowse:nAt,05],aBrowse[oBrowse:nAt,06]}}
oBrowse:bLDblClick := {||N6GEN03(aBrowse[oBrowse:nAt,06])}  
oBrowse:refresh()
 
Return 

/*
-------------------------------------------
Static function para de detalhes do log de
transações
-------------------------------------------
*/

Static Function N6GEN03(nRecno,nAba)

Local aBrowse := {}
Local AreaZX2 := GetNextAlias()
Local cSQL    := "" 
 

cSQL    := "SELECT CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),ZX2_ERRO)) as 'ZX2_ERRO',"
cSQL    += "CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),ZX2_CONTEU))as 'ZX2_CONTEU',ZX2_SERWS,ZX2_DATA, "
cSQL    += "ZX2_HORA, ZX2_TIPO FROM "+ RetSqlName("ZX2") + " WHERE R_E_C_N_O_ ='"+cvaltochar(nRecno)+"'"

//conecto no top e executo o SQL
cSQL := ChangeQuery(cSQL)
DbUseArea(.T., "TOPCONN", TcGenQry(,,cSQL), AreaZX2, .F., .T.)  

//logs
IF !(AreaZX2)->(EOF())
//	If nAba == 1
       cErro    := ""
       cConteudo := ""
		 aText[1]:SetText(IIF((AreaZX2)->ZX2_TIPO == "E","Enviado","Recebido"))
		 aText[2]:SetText(substr((AreaZX2)->ZX2_DATA,7,2)+"/"+substr((AreaZX2)->ZX2_DATA,5,2)+"/"+substr((AreaZX2)->ZX2_DATA,1,4))
	 	 aText[3]:SetText((AreaZX2)->ZX2_HORA)
	 	 aText[4]:SetText((AreaZX2)->ZX2_SERWS)  
	    aText[5]:varPut((AreaZX2)->ZX2_ERRO)  
	    aText[5]:CtrlRefresh()
	    aText[6]:cVariable := (AreaZX2)->ZX2_CONTEU
	    //cConteudo := (AreaZX2)->ZX2_CONTEU
 /*	Else
		 aText2[1]:SetText((AreaZX2)->ZX2_TIPO)
		 aText2[2]:SetText((AreaZX2)->ZX2_DATA)
	 	 aText2[3]:SetText((AreaZX2)->ZX2_HORA)
	 	 aText2[4]:SetText((AreaZX2)->ZX2_SERWS)  
	    aText2[5]:Varput((AreaZX2)->ZX2_CONTEU)
	    aText2[6]:AppendText((AreaZX2)->ZX2_ERRO)
	EndIF  */
EndIf 

Return

/*
-------------------------------------------
Static function para abrir pedido de venda
e Nfe de entrada
-------------------------------------------
*/
Static Function N6GEN04(aBrowse)//N6GEN04(cTable,nRecno)   

Local aArea     := GetArea()
	 
/*	 If !empty(nRecno)
	 		DbselectArea(cTable)
    		(cTable)->(DBGoTo(nRecno))
	 		AxVisual(cTable,,4)
	 		RestArea(aArea)
	 Else
	  		Alert(*/
Return 

/*
-------------------------------------------
Static function para reprocessar os pedidos
de venda com erro
-------------------------------------------
*/
Static Function N6GEN05(nRecno,cStatus)

Local AreaSC5 := GetNextAlias()

//conecto no top e executo o SQL
cSQL := ChangeQuery("SELECT C5_P_STFED FROM " + RetSqlName("SC5") + " WHERE R_E_C_N_O_ = '"+cvaltochar(nRecno)+"'")
DbUseArea(.T., "TOPCONN", TcGenQry(,,cSQL), AreaSC5, .F., .T.) 

IF !(AreaSC5)->(EOF())
	If (AreaSC5)->C5_P_STFED == "05"
		TCSqlExec("UPDATE  " + RetSqlName("SC5") + "  SET C5_P_STFED = '' WHERE R_E_C_N_O_ ='"+cvaltochar(nRecno)+"'") 
	ElseIF (AreaSC5)->C5_P_STFED == "06"
		TCSqlExec("UPDATE  " + RetSqlName("SC5") + "  SET C5_P_STFED = '03' WHERE R_E_C_N_O_ ='"+cvaltochar(nRecno)+"'") 
	Else 
		Alert("Ação não permitida.")
	EndIF	
Else
     Alert("Pedido de venda não existente.")
EndIF


Return 

	
static function fecha(oDlg)
     oDlg:end()
     u_TESTE()
return 

