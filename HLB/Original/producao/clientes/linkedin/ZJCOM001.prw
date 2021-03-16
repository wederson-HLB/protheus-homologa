#include "TOPCONN.CH"
#include "Protheus.ch"
#include "Rwmake.ch"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FWBROWSE.CH"
/*
Funcao      : ZJCOM001
Parametros  : 
Retorno     : 
Objetivos   : Integração de Pedido de Compras
Autor       : Jean Victor Rocha
Data/Hora   : 30/07/2015
*/
*----------------------*
User Function ZJCOM001()
*----------------------*
Private cDirArq := "c:\"+Replicate(" ",147)
Private cGt := "HLB BRASIL."
Private aLog := {}
Private aLogGrv := {}

IntWizard()

Return .T.

*----------------------*
User Function ZJCOMVLD()
*----------------------*
Return ValidArq()

/*
Funcao      : IntWizard()  
Parametros  : 
Retorno     : 
Objetivos   : Wizard da integração
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*-------------------------*
Static Function IntWizard()
*-------------------------*
Local aLegenda := {	{"BR_VERMELHO"	,"Não será integrado"},;
					{"BR_AMARELO"	,"Será integrado, caso seja tratado o alerta."},;
		   		  	{"BR_VERDE"		,"Pronto para integrar"},;
		   		  	{"BR_BRANCO"	,"Não processado, não será integrado."}} 
Local aLegendaL := {{"BR_VERDE"		,"Gravado com Sucesso"},;
		   		  	{"BR_VERMELHO"	,"Erro durante a gravação."},;
		   		  	{"BR_BRANCO"	,"Não enviado para gravação."}} 

Private oBR_VERMELHO	:= LoadBitmap( GetResources(), "BR_VERMELHO" )
Private oBR_VERDE 		:= LoadBitmap( GetResources(), "BR_VERDE" )
Private oBR_AMARELO		:= LoadBitmap( GetResources(), "BR_AMARELO" )
Private oBR_BRANCO		:= LoadBitmap( GetResources(), "BR_BRANCO" )

Private oWizard

Private aHeader := {}
Private aCols	:= {}
Private aColsLog := {}

Private oMeter
Private nMeter := 0
Private oMeter2
Private nMeter2:= 0
Private oSayTxt
Private oMeterL
Private nMeterL := 0
Private oMeterL2
Private nMeterL2:= 0
Private oSayTxtL
                      
oWizard := APWizard():New("Integração", ""/*<chMsg>*/, "Pedido de Compras",;
														"Na rotina de Integração de Pedido de Compras serão possivel o processamento de arquivos"+CRLF+;
														"enviados pelo cliente."+CRLF+;
														"A rotina efetua o processamento de Arquivos '.CSV(ms-dos) que estjam na pasta que sera"+CRLF+;
														"informada na tela de filtros.",;                                                                             
												 {||  .T.}/*<bNext>*/, {|| .T.}/*<bFinish>*/, /*<.lPanel.>*/,,,/*<.lNoFirst.>*/ )
If VldAmb()
	//Painel 2
	oWizard:NewPanel( "Filtros", "Informe os Filtros da integração.",{ ||.T.}/*<bBack>*/,;
														{ || ValidNext()}/*<bNext>*/, {|| .T.}/*<bFinish>*/, /*<.lPanel.>*/, {|| .T.}/*<bExecute>*/ )
	
	@ 010, 010 TO 125,280 OF oWizard:oMPanel[2] PIXEL
	oSBox1 := TScrollBox():New( oWizard:oMPanel[2],009,009,124,279,.T.,.T.,.T. )
	
	@ 21,20 SAY oSay1 VAR "Diretorio? " SIZE 100,10 OF oSBox1 PIXEL
	ocDirArq := TGet():New(20,85,{|u| If(PCount()>0,cDirArq:=u,cDirArq)},oSBox1,43,05,'',{|o|},,,,,,.T.,,,,,,,,,"",'cDirArq')
	@ 20,127.5 Button "..."	Size 7,10 Pixel of oSBox1 action (GetDir())
	
	//Painel 3                                	
	oWizard:NewPanel( "Manutenção", "Ajustar as linhas da integração, quando necessario.",;
															{ || MsgYesNo("Os dados serão perdidos, deseja continuar?",cGt)}/*<bBack>*/,;
														 	{ || MsgYesNo("Confirma a execução da Integração?",cGt)}/*<bNext>*/,;
														 	{ || .T.}/*<bFinish>*/, /*<.lPanel.>*/, { || ReadArq()}/*<bExecute>*/ )
	
	@ 01,010 Button oBtnLeg PROMPT "Legenda" Size 28,08 Pixel of oWizard:oMPanel[3] action BrwLegenda("Status do Registro", "Legenda", aLegenda)
	@ 01,264 Button oBtnInc PROMPT "Incluir" Size 28,08 Pixel of oWizard:oMPanel[3] action NewCad()
	
	AADD(aHeader,{ TRIM("Status")		,"STS" 		,"@BMP"						,02,0,"","","C","",""})
	AADD(aHeader,{ TRIM("File")	   		,"FILE"		,"@!  "						,40,0,"","","C","",""})
	AADD(aHeader,{ TRIM("Line")			,"LINE"		,"@!  "						,06,0,"","","C","",""})
	AADD(aHeader,{ TRIM("Requisition")	,"REQUI"	,"@!  "						,20,0,"","","C","",""})
	AADD(aHeader,{ TRIM("P.O.")			,"PO"		,"@!  "						,20,0,"","","C","",""})
	AADD(aHeader,{ TRIM("Vendor Name")	,"VNAME"	,"@!  "						,30,0,"","","C","",""})
	AADD(aHeader,{ TRIM("Vendor Number"),"VNUMBER"	,"@!  "						,06,0,"","","C","",""})
	AADD(aHeader,{ TRIM("Vendor Site")	,"VSITE"	,"@!  "						,40,0,"","","C","",""})
	AADD(aHeader,{ TRIM("Buyer")		,"BUYER"	,"@!  "						,40,0,"","","C","",""})
	AADD(aHeader,{ TRIM("Requisitioner"),"REQ"		,"@!  "						,40,0,"","","C","",""})
	AADD(aHeader,{ TRIM("Category")		,"CAT"		,"@!  "						,30,0,"","","C","",""})
	AADD(aHeader,{ TRIM("Currency Code"),"CURR"		,"@!  "	   					,03,0,"","","C","",""})
	AADD(aHeader,{ TRIM("Quantity")		,"QTD"		,"@E     99,999,999,999.99"	,14,2,"","","N","",""})
	AADD(aHeader,{ TRIM("Unit Price")	,"UNIT"		,"@E 99,999,999,999,999.99"	,17,2,"","","N","",""})
	AADD(aHeader,{ TRIM("Amount")		,"AMOUNT"	,"@E  9,999,999,999,999.99"	,16,2,"","","N","",""})
	AADD(aHeader,{ TRIM("Amount USD")	,"AMOUNTUSD","@E  9,999,999,999,999.99"	,16,2,"","","N","",""})
	AADD(aHeader,{ TRIM("Requestor")	,"REQUESTOR","@!  "						,40,0,"","","C","",""})
	AADD(aHeader,{ TRIM("Line Num SUM")	,"ITEM"		,"@!  "						,04,0,"","","C","",""})
	AADD(aHeader,{ TRIM("Item Desc.")	,"DESC"		,"@!  "						,40,0,"","","C","",""})
	AADD(aHeader,{ TRIM("Deliver Loc.")	,"DELIVER"	,"@!  "						,40,0,"","","C","",""})
	AADD(aHeader,{ TRIM("Payment terms"),"PAY"		,"@!  "						,10,0,"","","C","",""})
	AADD(aHeader,{ TRIM("Approval Sts."),"APPSTS"	,"@!  "						,08,0,"","","C","",""})
	AADD(aHeader,{ TRIM("Item Type")	,"TYPE"		,"@!  "						,40,0,"","","C","",""})
	AADD(aHeader,{ TRIM("Cost Center")	,"COST"		,"@!  "						,9,0,"","","C","",""})
	AADD(aHeader,{ TRIM("HLB Vendor Number")	,"FORNECE"	,"@!  "					,TAMSX3("A2_COD")[1]	,0,"","","C","SA2A",""})
	AADD(aHeader,{ TRIM("HLB Loja Vendor")	,"LOJA"		,"@!  "					,TAMSX3("A2_LOJA")[1]	,0,"","","C","",""})
	AADD(aHeader,{ TRIM("HLB Category")		,"PRODUTO"	,"@!  "					,TAMSX3("B1_COD")[1]	,0,"","","C","SB1",""})
	AADD(aHeader,{ TRIM("HLB TES")	   		,"TES" 		,"@!  "					,TAMSX3("F4_CODIGO")[1]	,0,"","","C","SF4",""})
	AADD(aHeader,{ TRIM("HLB Payment terms")	,"CONDICAO"	,"@!  "					,TAMSX3("E4_CODIGO")[1]	,0,"","","C","SE4",""})
	
	aAlter	:= {"STS","FORNECE","LOJA","PRODUTO","CONDICAO","TES"}
	
	oGetDados := MsNewGetDados():New(010,010,135,292,GD_UPDATE,"U_ZJCOMVLD()","AllwaysTrue()",;
										"", aAlter,,999999, "U_ZJCOMVLD()", "AllwaysTrue()","AllwaysTrue()", oWizard:oMPanel[3],aHeader, aCols, {|| })
	
	oGetDados:AddAction("STS", {|| EECVIEW(aLog[oGetDados:Obrowse:NAT]),;
								oGetDados:Obrowse:ColPos -= 1,;
								oGetDados:aCols[oGetDados:Obrowse:nAt][oGetDados:Obrowse:ColPos+1] })
	oGetDados:LCANEDITLINE	:= .F.//não possibilita troca de tipo de edição.
	oGetDados:LEDITLINE		:= .F.//Não abre linha de edição de linha quando clicar na linha.
	oGetDados:ForceRefresh()
	
	
	@ 21,20 SAY oSayTxt VAR "Carregando..."  SIZE 280,10 OF oWizard:oMPanel[3] PIXEL
	nMeter := 0
	oMeter := TMeter():New(31,20,{|u|if(Pcount()>0,nMeter:=u,nMeter)},0,oWizard:oMPanel[3],250,34,,.T.,,,,,,,,,)
	oMeter:Set(0) 
	nMeter2 := 0
	oMeter2 := TMeter():New(41,20,{|u|if(Pcount()>0,nMeter2:=u,nMeter2)},0,oWizard:oMPanel[3],250,34,,.T.,,,,,,,,,)
	oMeter2:Set(0) 

 	//Painel 4
	oWizard:NewPanel( "Manutenção", "Ajustar as linhas da integração, quando necessario.",;
															{ || .T.}/*<bBack>*/,{ || .T.}/*<bNext>*/,;
														 	{ || .T.}/*<bFinish>*/, /*<.lPanel.>*/, { || SaveArq()}/*<bExecute>*/ )
	
	@ 01,264 Button oBtnLegL PROMPT "Legenda" Size 28,08 Pixel of oWizard:oMPanel[4] action BrwLegenda("Status do Registro", "Legenda", aLegendaL)
	
	aHeaderL := {}                                                                                                   
	AADD(aHeaderL,{ TRIM("Status")	   		,"STS" 		,"@BMP"						,02,0,"","","C","",""})
	AADD(aHeaderL,{ TRIM("File")	   		,"FILE"		,"@!  "						,40,0,"","","C","",""})
	AADD(aHeaderL,{ TRIM("Line")	   		,"LINE"		,"@!  "						,06,0,"","","C","",""})
	AADD(aHeaderL,{ TRIM("HLB Pedido")		,"PEDIDO"	,"@!  "				  		,TAMSX3("C7_NUM")[1]	,0,"","","C","",""})
	AADD(aHeaderL,{ TRIM("Requisition")		,"REQUI"	,"@!  "						,20,0,"","","C","",""})
	AADD(aHeaderL,{ TRIM("P.O.")	   		,"PO"		,"@!  "						,20,0,"","","C","",""})
	AADD(aHeaderL,{ TRIM("Vendor Name")		,"VNAME"	,"@!  "						,30,0,"","","C","",""})
	AADD(aHeaderL,{ TRIM("Vendor Number")	,"VNUMBER"	,"@!  "						,06,0,"","","C","",""})
	AADD(aHeaderL,{ TRIM("Vendor Site")		,"VSITE"	,"@!  "						,40,0,"","","C","",""})
	AADD(aHeaderL,{ TRIM("Buyer")	   		,"BUYER"	,"@!  "						,40,0,"","","C","",""})
	AADD(aHeaderL,{ TRIM("Requisitioner")	,"REQ"		,"@!  "						,40,0,"","","C","",""})
	AADD(aHeaderL,{ TRIM("Category")   		,"CAT"		,"@!  "						,30,0,"","","C","",""})
	AADD(aHeaderL,{ TRIM("Currency Code")	,"CURR"		,"@!  "	   					,03,0,"","","C","",""})
	AADD(aHeaderL,{ TRIM("Quantity")   		,"QTD"		,"@E     99,999,999,999.99"	,14,2,"","","N","",""})
	AADD(aHeaderL,{ TRIM("Unit Price") 		,"UNIT"		,"@E 99,999,999,999,999.99"	,17,2,"","","N","",""})
	AADD(aHeaderL,{ TRIM("Amount")	   		,"AMOUNT"	,"@E  9,999,999,999,999.99"	,16,2,"","","N","",""})
	AADD(aHeaderL,{ TRIM("Amount USD") 		,"AMOUNTUSD","@E  9,999,999,999,999.99"	,16,2,"","","N","",""})
	AADD(aHeaderL,{ TRIM("Requestor")  		,"REQUESTOR","@!  "						,40,0,"","","C","",""})
	AADD(aHeaderL,{ TRIM("Line Num SUM")	,"ITEM"		,"@!  "						,04,0,"","","C","",""})
	AADD(aHeaderL,{ TRIM("Item Desc.") 		,"DESC"		,"@!  "						,40,0,"","","C","",""})
	AADD(aHeaderL,{ TRIM("Deliver Loc.")	,"DELIVER"	,"@!  "						,40,0,"","","C","",""})
	AADD(aHeaderL,{ TRIM("Payment terms")	,"PAY"		,"@!  "						,10,0,"","","C","",""})
	AADD(aHeaderL,{ TRIM("Approval Sts.")	,"APPSTS"	,"@!  "						,08,0,"","","C","",""})
	AADD(aHeaderL,{ TRIM("Item Type") 		,"TYPE"		,"@!  "						,40,0,"","","C","",""})
	AADD(aHeaderL,{ TRIM("Cost Center")		,"COST"		,"@!  "						,9,0,"","","C","",""})
	AADD(aHeaderL,{ TRIM("HLB Vendor Number"),"FORNECE"	,"@!  "				  		,TAMSX3("A2_COD")[1]	,0,"","","C","SA2A",""})
	AADD(aHeaderL,{ TRIM("HLB Loja Vendor")	,"LOJA"		,"@!  "				 		,TAMSX3("A2_LOJA")[1]	,0,"","","C","",""})
	AADD(aHeaderL,{ TRIM("HLB Category")	,"PRODUTO"	,"@!  "				 		,TAMSX3("B1_COD")[1]	,0,"","","C","SB1",""})
	AADD(aHeaderL,{ TRIM("HLB TES")	   		,"TES" 		,"@!  "				 		,TAMSX3("F4_CODIGO")[1]	,0,"","","C","SF4",""})
	AADD(aHeaderL,{ TRIM("HLB Payment terms"),"CONDICAO"	,"@!  "					,TAMSX3("E4_CODIGO")[1]	,0,"","","C","SE4",""})
	
	
	aAlter	:= {"STS"}                                                                                 
	
	oGetLog := MsNewGetDados():New(010,010,135,292,GD_UPDATE,"AllwaysTrue()","AllwaysTrue()",;
										"", aAlter,,999999, "AllwaysTrue()", "AllwaysTrue()","AllwaysTrue()", oWizard:oMPanel[4],aHeaderL, aColsLog, {|| })
	
	oGetLog:AddAction("STS", {|| EECVIEW(aLogGrv[oGetLog:Obrowse:NAT]),;
								oGetLog:Obrowse:ColPos -= 1,;
								oGetLog:aCols[oGetLog:Obrowse:nAt][oGetLog:Obrowse:ColPos+1] })
	oGetLog:LCANEDITLINE	:= .F.//não possibilita troca de tipo de edição.
	oGetLog:LEDITLINE		:= .F.//Não abre linha de edição de linha quando clicar na linha.
	oGetLog:ForceRefresh()
	
	
	@ 21,20 SAY oSayTxtL VAR "Carregando..."  SIZE 280,10 OF oWizard:oMPanel[4] PIXEL
	nMeterL := 0
	oMeterL := TMeter():New(31,20,{|u|if(Pcount()>0,nMeter:=u,nMeter)},0,oWizard:oMPanel[4],250,34,,.T.,,,,,,,,,)
	oMeterL:Set(0) 
	nMeterL2 := 0
	oMeterL2 := TMeter():New(41,20,{|u|if(Pcount()>0,nMeter2:=u,nMeter2)},0,oWizard:oMPanel[4],250,34,,.T.,,,,,,,,,)
	oMeterL2:Set(0) 
    oMeter:LVISIBLE := .F.
    oMeter2:LVISIBLE := .F.
     
Else
	//Painel 2                                	
	oWizard:NewPanel( "Integração Pedido de Compras", "Operação Abortada.",;
						{ || .F.}/*<bBack>*/,{ || .T.}/*<bNext>*/,{ || .T.}/*<bFinish>*/, /*<.lPanel.>*/, { || .T.}/*<bExecute>*/ )
	@ 21,20 SAY oSayTxt VAR "A integração de Pedido de Compras foi abortada devido ao ambiente não estar preparado."  SIZE 280,10 OF oWizard:oMPanel[2] PIXEL
	@ 41,20 SAY oSayTxt VAR "Entre em contato com a equipe de Sistemas de HLB BRASIL."  SIZE 280,10 OF oWizard:oMPanel[2] PIXEL
EndIf	

oWizard:Activate( .T./*<.lCenter.>*/,/*<bValid>*/, /*<bInit>*/, /*<bWhen>*/ )

Return	                 

/*
Funcao      : GetDir
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Busca de diretorio.
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*----------------------*
Static Function GetDir()
*----------------------*
Local cTitle:= "Salvar arquivo"
Local cFile := ""
Local nDefaultMask := 0
Local cDefaultDir  := ALLTRIM(cDirArq)
Local nOptions:= GETF_NETWORKDRIVE+GETF_RETDIRECTORY+GETF_LOCALHARD

cDirArq := ALLTRIM(cGetFile(cFile,cTitle,nDefaultMask,cDefaultDir,.T.,nOptions,.F.))

Return

/*
Funcao      : ValidNext
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : validação do avançar da tela de diretorio.
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*-----------------------*
Static Function ValidNext()
*-----------------------*
Local lRet := .F.

//Validação do Diretorio.
If EMPTY(cDirArq)
	MsgInfo("O Diretorio deve ser informado!",cGt)
	Return lRet
ElseIf !ExistDir(cDirArq)
	MsgInfo("Diretorio informado não encontrado!",cGt)
	Return lRet
EndIf

//Verifica se possir arquivos no diretorio.
If Len(Directory ( cDirArq+"*.CSV")) == 0
	MsgInfo("Não foi encontrado nenhum arquivo no firetorio informado!",cGt)
	Return lRet
EndIf 
   
lRet := .T.

Return lRet

/*
Funcao      : ReadArq
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Efetua a leitura do arquivo e insere no array de tela.
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*-----------------------*
Static Function ReadArq()
*-----------------------*
Local lRet := .T.
Local i
Local nLinha := 0
Local aArquivos := {}
Local cArqAtu	:= ""

Private oFT   := fT():New()//FUNCAO GENERICA

cDirArq := ALLTRIM(cDirArq)

//Validação de no minimo um arquivo na pasta
aArquivos := Directory ( cDirArq+"*.CSV")

//Tratamentos de Tela       
oMeter:LVISIBLE 					:= .T.
oMeter:NTOTAL := Len(aArquivos)  
oMeter:Set(0)
oMeter2:LVISIBLE 					:= .T.
oMeter2:NTOTAL := 0  
oMeter:Set(0)
oGetDados:OBROWSE:LVISIBLECONTROL	:= .F.
oBtnLeg:OWND:LACTIVE 		 		:= .F.
oBtnInc:OWND:LACTIVE 		   		:= .F.  
oWizard:OBACK:LVISIBLECONTROL  		:= .F.
oWizard:OCANCEL:LVISIBLECONTROL		:= .F.
oWizard:ONEXT:LVISIBLECONTROL  		:= .F.
//oWizard:OFINISH:LVISIBLECONTROL	:= .F.
aCols := {}

For i:=1 to Len(aArquivos)
	oSayTxt:CCAPTION := "Carregando arquivo "+ALLTRIM(STR(i))+"/"+ALLTRIM(STR(Len(aArquivos)))+"..."
	oMeter:Set(i)
	cArqAtu := cDirArq+aArquivos[i][1]
	oFT:FT_FUse(cArqAtu) // Abre o arquivo
	oMeter2:NTOTAL := oFT:FT_FLastRec()
	oMeter2:Set(0) 
	oFT:FT_FGOTOP()      // Posiciona no inicio do arquivo
	nLinha := 0
	While !oFT:FT_FEof()
		cLinha := oFT:FT_FReadln()        // Le a linha
		aLinha := separa(UPPER(cLinha),";")  // Sepera para vetor
		nLinha++
		oMeter2:Set(nLinha) 
		If Len(aLinha) <> 0 .and. UPPER(ALLTRIM(aLinha[1])) == UPPER("LinkedIn BR OU")
			aAdd(aCols, {	oBR_BRANCO,;//STS
							Alltrim(aArquivos[i][1]),;//File
							Alltrim(STR(nLinha)),;//Line
							ALLTRIM(aLinha[2] ),;//"REQUI"
							ALLTRIM(aLinha[3] ),;//"PO"
							ALLTRIM(aLinha[4] ),;//"VNAME"
							ALLTRIM(aLinha[5] ),;//"VNUMBER"
							ALLTRIM(aLinha[6] ),;//"VSITE"
							ALLTRIM(aLinha[7] ),;//"BUYER"
							ALLTRIM(aLinha[8] ),;//"REQ"
							ALLTRIM(aLinha[9] ),;//"CAT"
							ALLTRIM(aLinha[10]),;//"CURR"
							VAL(STRTRAN(STRTRAN(aLinha[11],".",""),",",".")),;//"QTD"
							VAL(STRTRAN(STRTRAN(aLinha[12],".",""),",",".")),;//"UNIT"
							VAL(STRTRAN(STRTRAN(aLinha[13],".",""),",",".")),;//"AMOUNT"
							VAL(STRTRAN(STRTRAN(aLinha[14],".",""),",",".")),;//"AMOUNTUSD"
							ALLTRIM(aLinha[15]),;//"REQUESTOR"
							STRZERO(VAL(aLinha[16]),TAMSX3("C7_ITEM")[1]),;//"ITEM"
							ALLTRIM(aLinha[17]),;//"DESC"
							ALLTRIM(aLinha[18]),;//"DELIVER"
							ALLTRIM(aLinha[19]),;//"PAY"
							ALLTRIM(aLinha[20]),;//"APPSTS"
							ALLTRIM(aLinha[21]),;//"TYPE"
							ALLTRIM(aLinha[22]),;//"COST"
							GetCadGT("SA2",ALLTRIM(aLinha[5] )),;//"FORNECE"
							GetCadGT("SA2L",ALLTRIM(aLinha[5] )),;//"LOJA"
							GetCadGT("SB1",ALLTRIM(aLinha[9]) ),;//"PRODUTO"
							GetCadGT("SF4",GetCadGT("SB1",ALLTRIM(aLinha[9]) )),;//"TES"
							GetCadGT("SE4",ALLTRIM(aLinha[19])),;//"CONDICAO"
							.F.})    //Tratamento deletado MsNewGetDados
		EndIf
		oFT:FT_FSkip() // Proxima linha
	Enddo
	oFT:FT_FUse()
Next i
                       
oGetDados:aCols := aCols

oMeter:LVISIBLE := .F.
oMeter2:LVISIBLE := .F.

If LEN(oGetDados:aCols) <> 0
   	//reset do Log.   
	oMeter:LVISIBLE := .T.
	oMeter:NTOTAL := Len(aLog)
	oMeter:Set(0)
	aLog := Array(Len(oGetDados:aCols))
	aLogGrv := Array(Len(oGetDados:aCols))
	For i:=1 to Len(aLog)
		oSayTxt:CCAPTION := "Limpeza do Log "+ALLTRIM(STR(i))+"/"+ALLTRIM(STR(Len(aLog)))+"..."
		oMeter:Set(i)
		aLog[i] := ""
		aLogGrv[i] := ""
	Next i
	oMeter:LVISIBLE := .F.        

	ValidArq(.T.)

	oGetDados:OBROWSE:LVISIBLECONTROL 	:= .T.
	oBtnLeg:OWND:LACTIVE := .T.
	oBtnInc:OWND:LACTIVE := .T.
Else
	oSayTxt:CCAPTION := "Não foi possivel carregar as informações do(s) arquivo(s)!"
EndIf                                       
                   
oWizard:OBACK:LVISIBLECONTROL		:= .T.
oWizard:OCANCEL:LVISIBLECONTROL		:= .T.
oWizard:ONEXT:LVISIBLECONTROL		:= .T.
//oWizard:OFINISH:LVISIBLECONTROL		:= .T.

oGetDados:ForceRefresh()
           
Return lRet

/*
Funcao      : ValidArq
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Efetua a validação da Tela/Linha.
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*------------------------------*
Static Function ValidArq(ltudo)
*------------------------------*
Local i
Local nPos := 0            
Local nLinha := 0
Default ltudo := .F.
           
If ltudo
	oMeter:LVISIBLE := .T.
	oMeter:NTOTAL := Len(oGetDados:aCols)  
	oMeter:Set(0)
	For i:=1 to Len(oGetDados:aCols)
		oSayTxt:CCAPTION := "Validando registro "+ALLTRIM(STR(i))+"/"+ALLTRIM(STR(Len(oGetDados:aCols)))+"..."
		oMeter:Set(i)
		oGetDados:OBROWSE:LVISIBLECONTROL := .F.
		ValidLinArq(i)               
	Next i      
	oMeter:NTOTAL := Len(oGetDados:aCols)
	oMeter:Set(0)
	For i:=1 to Len(oGetDados:aCols)
		oSayTxt:CCAPTION := "Validando pares "+ALLTRIM(STR(i))+"/"+ALLTRIM(STR(Len(oGetDados:aCols)))+"..."
		oMeter:Set(i)
		oGetDados:OBROWSE:LVISIBLECONTROL := .F.
		ValidPares(i)
	Next i
	
	oMeter:LVISIBLE := .F.
Else     
	For i:=1 to Len(oGetDados:aCols)
		ValidLinArq(i)               
	Next i
	For i:=1 to Len(oGetDados:aCols)
		ValidPares(i)               
	Next i
	//ValidLinArq(oGetDados:Obrowse:NAT)
	//ValidPares(oGetDados:Obrowse:NAT)
EndIf

oGetDados:OBROWSE:Refresh()
oGetDados:Refresh()

Return .T.

/*
Funcao      : ValidPares
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Efetua a Validação de Pares na integração, valida se tem outros itens rejeitados da mesma PO.
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*---------------------------------*
Static Function ValidPares(nPosVld)
*---------------------------------*
Local nPosErro := 0
Local nPosSErro := 0

nPosErro := aScan(oGetDados:aCols,;
		{|x| x[aScan(aHeader,{|x| x[2] == "STS"})] <> oBR_VERDE .and. x[aScan(aHeader,{|x| x[2] == "STS"})] <> oBR_BRANCO .and.;
			x[aScan(aHeader,{|x| x[2] == "REQUI"})] == oGetDados:aCols[nPosVld][ aScan(aHeader,{|x| x[2] == "REQUI"}) ]	.and.;
			x[aScan(aHeader,{|x| x[2] == "PO"})] 	== oGetDados:aCols[nPosVld][ aScan(aHeader,{|x| x[2] == "PO"}) ]	})

If nPosErro <> 0
	nPosSErro := aScan(oGetDados:aCols,;
			{|x| (x[aScan(aHeader,{|x| x[2] == "STS"})]	== oBR_VERDE .or. x[aScan(aHeader,{|x| x[2] == "STS"})] == oBR_BRANCO) .and.;
				x[aScan(aHeader,{|x| x[2] == "REQUI"})] == oGetDados:aCols[nPosVld][ aScan(aHeader,{|x| x[2] == "REQUI"}) ]	.and.;
				x[aScan(aHeader,{|x| x[2] == "PO"})] 	== oGetDados:aCols[nPosVld][ aScan(aHeader,{|x| x[2] == "PO"}) ]	})

	If nPosSErro <> 0
		While nPosSErro <> 0
   			oGetDados:aCols[nPosSErro][ aScan(aHeader,{|x| x[2] == "STS"}) ] := oGetDados:aCols[nPosErro][ aScan(aHeader,{|x| x[2] == "STS"}) ]
	   		aLog[nPosSErro] += "[Error Line:"+oGetDados:aCols[nPosSErro][aScan(aHeader,{|x| x[2] == "LINE"}) ]+;
   																		"] Existe outro item desta PO com erro."+CHR(13)+CHR(10)
			nPosSErro := aScan(oGetDados:aCols,;
					{|x| (x[aScan(aHeader,{|x| x[2] == "STS"})]	== oBR_VERDE .or. x[aScan(aHeader,{|x| x[2] == "STS"})] == oBR_BRANCO) .and.;
						x[aScan(aHeader,{|x| x[2] == "REQUI"})] == oGetDados:aCols[nPosVld][ aScan(aHeader,{|x| x[2] == "REQUI"}) ]	.and.;
						x[aScan(aHeader,{|x| x[2] == "PO"})] 	== oGetDados:aCols[nPosVld][ aScan(aHeader,{|x| x[2] == "PO"}) ]	})
		EndDo
	EndIf
EndIf

Return .T.

/*
Funcao      : ValidLinArq
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Efetua a validação da Linha passada como parametro.
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*-------------------------------*
Static Function ValidLinArq(nPos)
*-------------------------------*
Local i
Local cRet := ""
         
oGetDados:aCols[nPos][1] := oBR_VERDE
aLog[nPos] := ""
//Alertas
If !ValCadGT("SA2",oGetDados:aCols[nPos][ aScan(aHeader,{|x| x[2] == "FORNECE"}) ])
   	oGetDados:aCols[nPos][1] := oBR_AMARELO
   	aLog[nPos] += "[ALERT Line:"+oGetDados:aCols[nPos][ aScan(aHeader,{|x| x[2] == "LINE"}) ]+"] Fornecedor não encontrado."+CHR(13)+CHR(10)
EndIf
If !ValCadGT("SB1",oGetDados:aCols[nPos][ aScan(aHeader,{|x| x[2] == "PRODUTO"}) ])
   	oGetDados:aCols[nPos][1] := oBR_AMARELO
   	aLog[nPos] += "[ALERT Line:"+oGetDados:aCols[nPos][ aScan(aHeader,{|x| x[2] == "LINE"}) ]+"] Produto não encontrado."+CHR(13)+CHR(10)
EndIf
If !ValCadGT("SE4",oGetDados:aCols[nPos][ aScan(aHeader,{|x| x[2] == "CONDICAO"}) ])
   	oGetDados:aCols[nPos][1] := oBR_AMARELO
   	aLog[nPos] += "[ALERT Line:"+oGetDados:aCols[nPos][ aScan(aHeader,{|x| x[2] == "LINE"}) ]+"] Condição de pagamento não encontrado."+CHR(13)+CHR(10)
EndIf 
If readvar() == "M->PRODUTO" .and. !EMPTY(M->PRODUTO) .and. EMPTY(oGetDados:aCols[nPos][ aScan(aHeader,{|x| x[2] == "TES"}) ])
   	oGetDados:aCols[nPos][ aScan(aHeader,{|x| x[2] == "TES"}) ] := GetCadGT("SF4",M->PRODUTO)
EndIf 
If EMPTY(oGetDados:aCols[nPos][ aScan(aHeader,{|x| x[2] == "TES"}) ])
   	oGetDados:aCols[nPos][1] := oBR_AMARELO
   	aLog[nPos] += "[ALERT Line:"+oGetDados:aCols[nPos][ aScan(aHeader,{|x| x[2] == "LINE"}) ]+"] TES não informada."+CHR(13)+CHR(10)
EndIf 


//Erros
If EMPTY(oGetDados:aCols[nPos][ aScan(aHeader,{|x| x[2] == "REQUI"}) ])
	oGetDados:aCols[nPos][1] := oBR_VERMELHO
   	aLog[nPos] += "[ERROR Line:"+oGetDados:aCols[nPos][ aScan(aHeader,{|x| x[2] == "LINE"}) ]+"] 'Requisition' em branco."+CHR(13)+CHR(10)
EndIf
If EMPTY(oGetDados:aCols[nPos][ aScan(aHeader,{|x| x[2] == "PO"}) ])
	oGetDados:aCols[nPos][1] := oBR_VERMELHO
   	aLog[nPos] += "[ERROR Line:"+oGetDados:aCols[nPos][ aScan(aHeader,{|x| x[2] == "LINE"}) ]+"] 'PO number' em branco."+CHR(13)+CHR(10)
EndIf             
If !EMPTY(oGetDados:aCols[nPos][ aScan(aHeader,{|x| x[2] == "PO"}) ])
	If Select("QRY") > 0
   		QRY->(DbClosearea())
	Endif 
	cQry := ""
	cQry += " SELECT TOP 1 *
	cQry += " FROM "+RETSQLNAME("SC7")
	cQry += " Where D_E_L_E_T_ <> '*' AND UPPER(C7_P_PO) = '"+ALLTRIM(UPPER(oGetDados:aCols[nPos][ aScan(aHeader,{|x| x[2] == "PO"}) ]))+"'"

	dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQry),"QRY",.F.,.T.)

	QRY->(DbGoTop())
	If QRY->(!EOF())
		oGetDados:aCols[nPos][1] := oBR_VERMELHO
   		aLog[nPos] += "[ERROR Line:"+oGetDados:aCols[nPos][ aScan(aHeader,{|x| x[2] == "LINE"}) ]+;
   													"] 'PO number' já existe no sistema, pedido HLB = '"+ALLTRIM(QRY->C7_NUM)+"'."+CHR(13)+CHR(10)
  	EndIf
EndIf
If UPPER(ALLTRIM(oGetDados:aCols[nPos][ aScan(aHeader,{|x| x[2] == "APPSTS"}) ]) ) <> "APPROVED"
	oGetDados:aCols[nPos][1] := oBR_VERMELHO
   	aLog[nPos] += "[ERROR Line:"+oGetDados:aCols[nPos][ aScan(aHeader,{|x| x[2] == "LINE"}) ]+"] Status diferente de 'APPROVED'."+CHR(13)+CHR(10)
EndIf
If oGetDados:aCols[nPos][ aScan(aHeader,{|x| x[2] == "QTD"}) ] == 0
	oGetDados:aCols[nPos][1] := oBR_VERMELHO
   	aLog[nPos] += "[ERROR Line:"+oGetDados:aCols[nPos][ aScan(aHeader,{|x| x[2] == "LINE"}) ]+"] Quantidade invalida.'"+CHR(13)+CHR(10)
EndIf
If oGetDados:aCols[nPos][ aScan(aHeader,{|x| x[2] == "UNIT"}) ] == 0
	oGetDados:aCols[nPos][1] := oBR_VERMELHO
   	aLog[nPos] += "[ERROR Line:"+oGetDados:aCols[nPos][ aScan(aHeader,{|x| x[2] == "LINE"}) ]+"] Preço unitario invalido.'"+CHR(13)+CHR(10)
EndIf
If oGetDados:aCols[nPos][ aScan(aHeader,{|x| x[2] == "AMOUNT"}) ] == 0
	oGetDados:aCols[nPos][1] := oBR_VERMELHO
   	aLog[nPos] += "[ERROR Line:"+oGetDados:aCols[nPos][ aScan(aHeader,{|x| x[2] == "LINE"}) ]+"] Valor total invalido.'"+CHR(13)+CHR(10)
EndIf
If oGetDados:aCols[nPos][ aScan(aHeader,{|x| x[2] == "QTD"})]*;
	oGetDados:aCols[nPos][ aScan(aHeader,{|x| x[2] == "UNIT"})] <> oGetDados:aCols[nPos][ aScan(aHeader,{|x| x[2] == "AMOUNT"})]
	oGetDados:aCols[nPos][1] := oBR_VERMELHO
   	aLog[nPos] += "[ERROR Line:"+oGetDados:aCols[nPos][ aScan(aHeader,{|x| x[2] == "LINE"}) ]+"] 'Quantidade X Preço' não é igual ao Total.'"+CHR(13)+CHR(10)
EndIf                                                                         
If aScan(oGetDados:aCols,;
		{|x| x[aScan(aHeader,{|x| x[2] == "REQUI"})] == oGetDados:aCols[nPos][ aScan(aHeader,{|x| x[2] == "REQUI"}) ]	.and.;
			x[aScan(aHeader,{|x| x[2] == "PO"})] 	== oGetDados:aCols[nPos][ aScan(aHeader,{|x| x[2] == "PO"}) ]	.and.;
			x[aScan(aHeader,{|x| x[2] == "ITEM"})] 	== oGetDados:aCols[nPos][ aScan(aHeader,{|x| x[2] == "ITEM"}) ]	.and.;
			x[aScan(aHeader,{|x| x[2] == "LINE"})] 	<> oGetDados:aCols[nPos][ aScan(aHeader,{|x| x[2] == "LINE"}) ]	}) <> 0

	oGetDados:aCols[nPos][1] := oBR_VERMELHO
   	aLog[nPos] += "[ERROR Line:"+oGetDados:aCols[nPos][ aScan(aHeader,{|x| x[2] == "LINE"}) ]+;
   												"] Existe mais de um registro no mesmo Pedido com Linha igual de item do Pedido.'"+CHR(13)+CHR(10)
EndIf                                        

Return cRet

/*
Funcao      : ValCadGT
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Validação do cadastro da HLB
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*----------------------------------*
Static Function ValCadGT(cCad,cInfo)
*----------------------------------*
Local lRet := .F.
Local cQry := ""

Do Case
	Case cCad == "SA2"
		cQry += "SELECT COUNT(*) as COUNT FROM "+RETSQLNAME("SA2")+" Where D_E_L_E_T_ <> '*' AND UPPER(A2_COD) = '"+ALLTRIM(UPPER(cInfo))+"'"
	Case cCad == "SB1"
		cQry += "SELECT COUNT(*) as COUNT FROM "+RETSQLNAME("SB1")+" Where D_E_L_E_T_ <> '*' AND UPPER(B1_COD) = '"+ALLTRIM(UPPER(cInfo))+"'"
	Case cCad == "SE4"
		cQry += "SELECT COUNT(*) as COUNT FROM "+RETSQLNAME("SE4")+" Where D_E_L_E_T_ <> '*' AND UPPER(E4_CODIGO) = '"+ALLTRIM(UPPER(cInfo))+"'"
End Case   

If Select("QRY") > 0
	QRY->(DbClosearea())
Endif     

dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQry),"QRY",.F.,.T.)

lRet := QRY->COUNT <> 0

Return lRet

/*
Funcao      : GetCadGT
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Retorna o cadastro da HLB
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*----------------------------------*
Static Function GetCadGT(cCad,cInfo)
*----------------------------------*
Local cRet := ""
Local cQry := ""

Do Case
	Case cCad == "SA2"
		cRet := Replicate(" ",aHeader[aScan(aHeader,{|x| x[2] == "FORNECE"})][4])
		cQry += "SELECT A2_COD as RETORNO FROM "+RETSQLNAME("SA2")+" Where D_E_L_E_T_ <> '*' AND UPPER(A2_P_REF) = '"+ALLTRIM(UPPER(cInfo))+"'"

	Case cCad == "SA2L"
		cRet := Replicate(" ",aHeader[aScan(aHeader,{|x| x[2] == "FORNECE"})][4])
		cQry += "SELECT A2_LOJA as RETORNO FROM "+RETSQLNAME("SA2")+" Where D_E_L_E_T_ <> '*' AND UPPER(A2_P_REF) = '"+ALLTRIM(UPPER(cInfo))+"'"

	Case cCad == "SB1"
		cRet := Replicate(" ",aHeader[aScan(aHeader,{|x| x[2] == "PRODUTO"})][4])
		cQry += "SELECT B1_COD as RETORNO FROM "+RETSQLNAME("SB1")
		cQry += " Where D_E_L_E_T_ <> '*' AND UPPER(B1_P_REF) = '"+LEFT(ALLTRIM(UPPER(cInfo)),AT(".",ALLTRIM(cInfo))-1)+"'"

	Case cCad == "SF4"
		cRet := Replicate(" ",aHeader[aScan(aHeader,{|x| x[2] == "PRODUTO"})][4])
		cQry += "SELECT B1_TE as RETORNO FROM "+RETSQLNAME("SB1")+" Where D_E_L_E_T_ <> '*' AND B1_COD = '"+ALLTRIM(UPPER(cInfo))+"'"

	Case cCad == "SE4"                                                           
		cRet := Replicate(" ",aHeader[aScan(aHeader,{|x| x[2] == "CONDICAO"})][4])
		cQry += "SELECT E4_CODIGO as RETORNO FROM "+RETSQLNAME("SE4")+" Where D_E_L_E_T_ <> '*' AND UPPER(E4_P_REF) = '"+ALLTRIM(UPPER(cInfo))+"'"

End Case   

If Select("QRY") > 0
	QRY->(DbClosearea())
Endif     

dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQry),"QRY",.F.,.T.)
   
QRY->(DbGoTop())
If QRY->(!EOF())
	cRet := QRY->RETORNO
EndIf

Return cRet

/*
Funcao      : VldAmb
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Valida se tem todos os campos customizados.
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*----------------------*
Static Function VldAmb()
*----------------------*    
Local lRet := .F.
                 
lRet := SC7->(FieldPos("C7_P_NREQ")) <> 0 .and.;
		SC7->(FieldPos("C7_P_PO")) <> 0 .and.;
		SC7->(FieldPos("C7_P_LOCAL")) <> 0 .and.;
		SC7->(FieldPos("C7_P_COMP")) <> 0 .and.;
		SC7->(FieldPos("C7_P_REQ")) <> 0 .and.;
		SC7->(FieldPos("C7_P_SOL")) <> 0 .and.;
		SC7->(FieldPos("C7_P_DESC")) <> 0 .and.;
		SC7->(FieldPos("C7_P_END")) <> 0 .and.;
		SC7->(FieldPos("C7_P_ST")) <> 0 .and.;
		SC7->(FieldPos("C7_P_TIPO")) <> 0 .and.;
		SA2->(FieldPos("A2_P_REF")) <> 0 .and.;
		SB1->(FieldPos("B1_P_REF")) <> 0 .and.;
		SE4->(FieldPos("E4_P_REF")) <> 0

Return lRet


/*
Funcao      : SaveArq
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Gravação dos registros em tela
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*-----------------------*
Static Function SaveArq()
*-----------------------*
Local i        
Local aInfo := {}
Local aCabec := {}
Local aLinha := {}
Local aErroExec := {}
Local nPosLog := 0

oMeterL:NTOTAL := 3//Quantidades de etapas
oMeterL2:NTOTAL := 0
oMeterL:Set(0)
oMeterL2:Set(0)

oGetLog:OBROWSE:LVISIBLECONTROL := .F.
oMeterL:LVISIBLE := .T.
oMeterL2:LVISIBLE := .T.
oWizard:OBACK:LVISIBLECONTROL		:= .F.
oWizard:OCANCEL:LVISIBLECONTROL		:= .F.
oWizard:ONEXT:LVISIBLECONTROL		:= .F.
oWizard:OFINISH:LVISIBLECONTROL		:= .F.
oBtnLegL:OWND:LACTIVE := .F.

oGetLog:aCols := {}
      
//Organização dos Dados
oMeterL:Set(1)
oMeterL2:NTOTAL := Len(oGetDados:aCols)
For i:=1 to len(oGetDados:aCols)
	oMeterL2:Set(i)
	oSayTxtL:CCAPTION := "Organização de Dados do registro "+ALLTRIM(STR(i))+"/"+ALLTRIM(STR(len(oGetDados:aCols)))+"..."
	          
	//Copia para Log.
	aAdd(oGetLog:aCols, oGetDados:aCols[i])
	
	//Gravação
    If oGetDados:aCols[i][aScan(aHeader,{|x| x[2] == "STS"}) ] == oBR_VERDE
		aCabec	:= {}
			aadd(aCabec,{"C7_NUM"		, "AUTO"})
			aadd(aCabec,{"C7_EMISSAO"	, dDataBase})
			aadd(aCabec,{"C7_FORNECE"	, oGetDados:aCols[i][aScan(aHeader,{|x| x[2] == "FORNECE"})]	})
			aadd(aCabec,{"C7_LOJA"		, oGetDados:aCols[i][aScan(aHeader,{|x| x[2] == "LOJA"})]		})
			aadd(aCabec,{"C7_COND"		, oGetDados:aCols[i][aScan(aHeader,{|x| x[2] == "CONDICAO"})]	})
			aadd(aCabec,{"C7_CONTATO"	, "INTEGRACAO"})
			aadd(aCabec,{"C7_FILENT"	, cFilAnt})
			aadd(aCabec,{"C7_P_NREQ"	, oGetDados:aCols[i][aScan(aHeader,{|x| x[2] == "REQUI"})] 		})    
			aadd(aCabec,{"C7_P_PO"		, oGetDados:aCols[i][aScan(aHeader,{|x| x[2] == "PO"})]	   		})
		aLinha	:={}                                                                                          
			aadd(aLinha,{"C7_PRODUTO"	, oGetDados:aCols[i][aScan(aHeader,{|x| x[2] == "PRODUTO"})]  	,Nil})
			aadd(aLinha,{"C7_QUANT"		, oGetDados:aCols[i][aScan(aHeader,{|x| x[2] == "QTD"})]		,Nil})
			aadd(aLinha,{"C7_PRECO"		, oGetDados:aCols[i][aScan(aHeader,{|x| x[2] == "UNIT"})]		,Nil})
			aadd(aLinha,{"C7_TOTAL"		, oGetDados:aCols[i][aScan(aHeader,{|x| x[2] == "AMOUNT"})]		,Nil})
			aadd(aLinha,{"C7_TES"		, oGetDados:aCols[i][aScan(aHeader,{|x| x[2] == "TES"})]		,Nil})
			aadd(aLinha,{"C7_P_NREQ"	, oGetDados:aCols[i][aScan(aHeader,{|x| x[2] == "REQUI"})] 		,Nil})    
			aadd(aLinha,{"C7_P_PO"		, oGetDados:aCols[i][aScan(aHeader,{|x| x[2] == "PO"})]	   		,Nil})
			aadd(aLinha,{"C7_P_LOCAL"	, oGetDados:aCols[i][aScan(aHeader,{|x| x[2] == "VSITE"})]		,Nil})
			aadd(aLinha,{"C7_P_COMP"	, oGetDados:aCols[i][aScan(aHeader,{|x| x[2] == "BUYER"})]		,Nil})
			aadd(aLinha,{"C7_P_REQ"		, oGetDados:aCols[i][aScan(aHeader,{|x| x[2] == "REQ"})]		,Nil})
			aadd(aLinha,{"C7_P_SOL"		, oGetDados:aCols[i][aScan(aHeader,{|x| x[2] == "REQUESTOR"})]	,Nil})
			aadd(aLinha,{"C7_P_DESC"	, oGetDados:aCols[i][aScan(aHeader,{|x| x[2] == "DESC"})]		,Nil})
			aadd(aLinha,{"C7_P_END"		, oGetDados:aCols[i][aScan(aHeader,{|x| x[2] == "DELIVER"})]	,Nil})
			aadd(aLinha,{"C7_P_ST"		, oGetDados:aCols[i][aScan(aHeader,{|x| x[2] == "APPSTS"})]		,Nil})
			aadd(aLinha,{"C7_P_TIPO"	, oGetDados:aCols[i][aScan(aHeader,{|x| x[2] == "TYPE"})]		,Nil})
			aadd(aLinha,{"C7_CC"		, oGetDados:aCols[i][aScan(aHeader,{|x| x[2] == "COST"})]		,Nil})
			
		If (nPos:= aScan(aInfo,{|x| x[1][aScan(aCabec,{|X|X[1]=="C7_P_PO"})][2] == oGetDados:aCols[i][aScan(aHeader,{|x| x[2] == "PO"})] 			.and.;
									x[1][aScan(aCabec,{|X|X[1]=="C7_FORNECE"})][2] == oGetDados:aCols[i][aScan(aHeader,{|x| x[2] == "FORNECE"})]	.and.;
							   		x[1][aScan(aCabec,{|X|X[1]=="C7_LOJA"})][2] == oGetDados:aCols[i][aScan(aHeader,{|x| x[2] == "LOJA"})]})        ) == 0
			aAdd(aInfo,{aCabec,{aLinha}})
		Else
			aAdd(aInfo[nPos][2], aLinha)
		EndIf
    Else
    	oGetLog:aCols[i][aScan(aHeaderL,{|x| x[2] == "STS"})] := oBR_BRANCO
    	aLogGrv[i] += "[ERROR Line:"+oGetLog:aCols[i][ aScan(aHeaderL,{|x| x[2] == "LINE"}) ]+"] Registro não habilitado para integração."+CHR(13)+CHR(10)
    EndIf	                           
Next i

//Gravação dos Dados.
oMeterL:Set(2)
oMeterL2:NTOTAL := Len(aInfo)
For i:=1 to Len(aInfo)
	oMeterL2:Set(i)
	oSayTxtL:CCAPTION := "Gravação do Pedido "+ALLTRIM(STR(i))+"/"+ALLTRIM(STR(len(aInfo)))+"..."

	//Ajuste do numero do PC.
	aInfo[i][1][aScan(aInfo[i][1],{|x| x[1] == "C7_NUM"  })][2] := GetNextNum()
		
	lMsErroAuto := .F.		
	MATA120(1,aInfo[i][1],aInfo[i][2],3)
	
	If lMsErroAuto
		aAdd(aErroExec,{aInfo[i][1][aScan(aInfo[i][1],{|x| x[1] == "C7_P_PO"  })][2], Mostraerro(GetTempPath(),"TEMP.log")  })
	EndIf
Next i

//Geração de Log
oMeterL:Set(3)
oMeterL2:NTOTAL := Len(oGetDados:aCols)
For i:=1 to Len(oGetDados:aCols)
	oMeterL2:Set(i)
	oSayTxtL:CCAPTION := "Geração de Log do Registro "+ALLTRIM(STR(i))+"/"+ALLTRIM(STR(len(oGetDados:aCols)))+"..."

	If !EMPTY(oGetDados:aCols[i][ aScan(aHeader,{|x| x[2] == "PO"}) ])
		If Select("QRY") > 0
	   		QRY->(DbClosearea())
		Endif 
		cQry := ""
		cQry += " SELECT TOP 1 *
		cQry += " FROM "+RETSQLNAME("SC7")
		cQry += " Where D_E_L_E_T_ <> '*' AND UPPER(C7_P_PO) = '"+ALLTRIM(UPPER(oGetDados:aCols[i][ aScan(aHeader,{|x| x[2] == "PO"}) ]))+"'"

		dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQry),"QRY",.F.,.T.)
		QRY->(DbGoTop())
		If QRY->(!EOF())
	    	oGetLog:aCols[i][aScan(aHeaderL,{|x| x[2] == "STS"})] := oBR_VERDE
	    	aLogGrv[i] += "[ERROR Line:"+oGetLog:aCols[i][ aScan(aHeaderL,{|x| x[2] == "LINE"}) ]+;
	    											"] Pedido gravado com Sucesso - Pedido HLB '"+QRY->C7_NUM+"'."+CHR(13)+CHR(10)
	    	oGetLog:aCols[i][aScan(aHeaderL,{|x| x[2] == "PEDIDO"})] := QRY->C7_NUM

		ElseIf oGetLog:aCols[i][aScan(aHeaderL,{|x| x[2] == "STS"})] == oBR_VERDE
			oGetLog:aCols[i][aScan(aHeaderL,{|x| x[2] == "STS"})] := oBR_VERMELHO
	    	aLogGrv[i] += "[ERROR Line:"+oGetLog:aCols[i][ aScan(aHeaderL,{|x| x[2] == "LINE"}) ]+"] Erro na gravação do Pedido:"+CHR(13)+CHR(10)
	    	nPosLog := aScan(aErroExec,{|X| X[1] == oGetLog:aCols[i][aScan(aHeaderL,{|x| x[2] == "PO"})]})
	    	If LEN(aErroExec) >= nPosLog .and.	nPosLog <> 0
	       		aLogGrv[i] += aErroExec[nPosLog][2]
	     	Else
	     		aLogGrv[i] += ">>>Não foi possivel recuperar mensagem de processamento<<<"+CHR(13)+CHR(10)
	     	EndIf
	  	EndIf
	EndIf	

Next i

oMeterL:LVISIBLE := .F.
oMeterL2:LVISIBLE := .F.                                      
oBtnLegL:OWND:LACTIVE := .T.
oGetLog:OBROWSE:LVISIBLECONTROL := .T.
oWizard:OFINISH:LVISIBLECONTROL	:= .T.

Return .T.  

/*
Funcao      : GetNextNum
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Busca o Proximo Numero de Pedido de Compas
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*--------------------------*
Static Function GetNextNum()
*--------------------------*
Local cRet := ""
Local cQry := ""
           
cQry := "Select ISNULL(MAX(C7_NUM)+1,1) AS RETORNO From "+RETSQLNAME("SC7")

If Select("QRY") > 0
	QRY->(DbClosearea())
Endif     

dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQry),"QRY",.F.,.T.)
   
QRY->(DbGoTop())
If QRY->(!EOF())
	cRet := STRZERO(QRY->RETORNO,TAMSX3("C7_NUM")[1])
EndIf

Return cRet

/*
Funcao      : NewCad
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Tela de inclusão de novo cadastro.
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*----------------------*
Static Function NewCad()    
*----------------------*
Local nOpc := 0
Local nRadMenu := 1

SetPrvt("oDlg1","oRMenu1","oSBtn1","oSBtn2")

oDlg1      := MSDialog():New( 275,557,410,829,"Incluir",,,.F.,,,,,,.T.,,,.T. )
GoRMenu1   := TGroup():New( 004,004,054,092,"",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
oRMenu1    := TRadMenu():New( 008,010,{"Fornecedor","Produto","Condicao de pagamento"},,oDlg1,,,CLR_BLACK,CLR_WHITE,"",,,072,17,,.F.,.F.,.T. )
oRMenu1:SetOption(nRadMenu)
oRMenu1:bSetGet := {|u| If(PCount()==0,nRadMenu,nRadMenu:=u)}

oSBtn1     := SButton():New( 008,100,1,{|| nOpc := 1,oDlg1:end()},oDlg1,,"", )
oSBtn2     := SButton():New( 025,100,2,{|| nOpc := 0,oDlg1:end()},oDlg1,,"", )

oDlg1:Activate(,,,.T.)

If nOpc == 1
	Do Case
		Case nRadMenu == 1
	   		cCadastro:= "Incluir - Cadastro de Fornecedores"
	   		AxInclui("SA2")
		Case nRadMenu == 2
			cCadastro:= "Incluir - Cadastro de Produtos"
	   		AxInclui("SB1")
		Case nRadMenu == 3                    
	   		cCadastro:= "Incluir - Condição de Pagamentos"
	   		AxInclui("SE4")
	EndCase
EndIf

Return .T.