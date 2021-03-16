#Include "Protheus.ch"
#INCLUDE "rwmake.ch"
#include "topconn.ch" 
#include "average.ch" 

/*
Funcao      : N6FAT007
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Rotina de monitor de processamento doTerra
Autor       : Jean Victor Rocha
Data/Hora   : 13/08/2017
Módulo      : Faturamento
Cliente		: doTerra
*/ 
*----------------------*
User Function N6FAT007()
*----------------------*
Private oDlgLog
Private oLayer	:= FWLayer():new()
Private aSize 	:= MsAdvSize()

Private aCRes := {}
Private aHRes := {}
Private aARes := {}

Private aCDet := {}
Private aHDet := {}
Private aADet := {}

Private aHLog02 := {}
Private aALog02 := {}
Private aHLog03 := {}
Private aALog03 := {}
Private aHLog11 := {}
Private aALog11 := {}
Private aHLogEr := {}
Private aALogEr := {}

Private oVerde		:= LoadBitmap( GetResources(),"VERDE"	)
Private oAzul		:= LoadBitmap( GetResources(),"AZUL"	)
Private oVermelho	:= LoadBitmap( GetResources(),"VERMELHO")
Private oRosa  		:= LoadBitmap( GetResources(),"ROSA"	)
Private oAmarelo	:= LoadBitmap( GetResources(),"AMARELO"	)
Private olupa		:= LoadBitmap( GetResources(),"SDUSEEK")

Private oChart
oChart := FWChartFactory():New()

oDlgLog := MSDialog():New( aSize[7],0,aSize[6],aSize[5],"HLB BRASIL - doTerra - Monitor de integração de pedidos",,,.F.,,,,,,.T.,,,.T. )
	oLayer:Init(oDlgLog,.F.)
	oLayer:addLine( '1', 100 , .F. )
	
	oLayer:addCollumn('1',25,.F.,'1')
	oLayer:addCollumn('2',30,.F.,'1')
	oLayer:addCollumn('3',45,.F.,'1')
	
	oLayer:addWindow('1','Win11','Resumo'	,050,.F.,.T.,{|| }	,'1',{|| })
	oLayer:addWindow('1','Win12','Resumo Grafico (Exceto Status: 11)',050,.F.,.T.,{|| }	,'1',{|| })
	oLayer:addWindow('2','Win21','Detalhe'	,100,.F.,.T.,{|| }	,'1',{|| })
	oLayer:addWindow('3','Win31',''			,100,.F.,.T.,{|| }	,'1',{|| })
	
	//Definição das janelas para objeto.
	oWin11 := oLayer:getWinPanel('1','Win11','1')
	oWin12 := oLayer:getWinPanel('1','Win12','1')
	oWin21 := oLayer:getWinPanel('2','Win21','1')
	oWin31 := oLayer:getWinPanel('3','Win31','1')

	//Resumo ----------------------------------------------------------------------------------------------------------------------------------
	oSay1	:= TSay():New( 004,002,{||"Filtro: "},oWin11,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,176,008)
	aCombo1	:= {'Filial 01','Filial 02','Ambas'}
	cCombo1	:= aCombo1[2]
	oCombo1	:= TComboBox():New(002,020,{|u|if(PCount()>0,cCombo1:=u,cCombo1)},aCombo1,(oWin11:NWIDTH/2)-20,20,oWin11,,{|| Reload()},,,,.T.,,,,,,,,,'cCombo1')

	aAdd(aHRes,{"Item"		,'ITEM'		,"@!"			,04,0,"AllwaysTrue()" ,"€€€€€€€€€€€€€€ ","C","","R",,,,'A'})
	aAdd(aHRes,{"Qtde"		,'QTDE'		,"@R 99999999"	,08,0,"AllwaysTrue()" ,"€€€€€€€€€€€€€€ ","C","","R",,,,'A'})
	aAdd(aHRes,{"Descrição"	,'DESCR'	,"@!"			,20,0,"AllwaysTrue()" ,"€€€€€€€€€€€€€€ ","C","","R",,,,'A'})
	oGetRes	:= MsNewGetDados():New(020,002,(oWin11:NHEIGHT/2),(oWin11:NWIDTH/2),GD_UPDATE,'AllwaysTrue()','AllwaysTrue()','',aARes,0,9999,'AllwaysTrue()','','AllwaysTrue()',oWin11,aHRes,aCRes,{|| Processa({||MudaLinha("RESUMO")},"","Carregando, aguarde...") } )

	//Detalhe ----------------------------------------------------------------------------------------------------------------------------------
	cGet1 := space(200)	
	oGet1:= TGet():New(002,002,{|u| if(PCount()>0,cGet1:=u,cGet1)}, oWin21,(oWin21:NWIDTH/2)-2,05,'',{||},,,,,,.T.,,,,,,,,,,'cGet1')
	oGet1:CPLACEHOLD := "Digite seu filtro aqui"
	oGet1:BLOSTFOCUS := {|| MudaLinha("RESUMO")}

	aAdd(aHDet,{"Filial"		,'FILIAL'		,"@!"		,02,0,"AllwaysTrue()" ,"€€€€€€€€€€€€€€ ","C","","R",,,,'A'})
	aAdd(aHDet,{"DataTrax"		,'CODIGO'		,"@!"		,10,0,"AllwaysTrue()" ,"€€€€€€€€€€€€€€ ","C","","R",,,,'A'})
	aAdd(aHDet,{"Ped.Totvs"		,'PEDIDO'		,"@!"		,10,0,"AllwaysTrue()" ,"€€€€€€€€€€€€€€ ","C","","R",,,,'A'})
	aAdd(aHDet,{"Cod.Cli"		,'CLIENTE'		,"@!"		,10,0,"AllwaysTrue()" ,"€€€€€€€€€€€€€€ ","C","","R",,,,'A'})
	aAdd(aHDet,{"Nome"			,'NOME'			,"@!"		,40,0,"AllwaysTrue()" ,"€€€€€€€€€€€€€€ ","C","","R",,,,'A'})	
	oGetDet	:= MsNewGetDados():New(020,002,(oWin21:NHEIGHT/2),(oWin21:NWIDTH/2),GD_UPDATE,'AllwaysTrue()','AllwaysTrue()','',aADet,0,9999,'AllwaysTrue()','','AllwaysTrue()',oWin21,aHDet,aCDet,{|| MudaLinha("DETALHE")} )
	
	//Opções ----------------------------------------------------------------------------------------------------------------------------------
	oBtn1 := TBtnBmp2():New(002,oWin31:NWIDTH-40 ,30,30,'FINAL'		,,,,{|| oDlgLog:end()}		   	, oWin31,"Sair"				,,.T.)
	If FWCodFil() == "02"
		oBtn2 := TBtnBmp2():New(002,oWin31:NWIDTH-100,30,30,'PAPEL_ESCRITO'	,,,,{|| u_N6FAT003(),Reload()} 	, oWin31,"Gera Danfe (Filial 02)"	,,.T.)
	Else
		oBtn2 := TBtnBmp2():New(002,oWin31:NWIDTH-100,30,30,'PAPEL_ESCRITO'	,,,,{|| u_N6FAT004(),Reload()} 	, oWin31,"Gera Danfe (Filial 01)"	,,.T.)
	EndIf
	oBtn3 := TBtnBmp2():New(002,oWin31:NWIDTH-130,30,30,'GLOBO'		,,,,{|| u_N6FAT002(),Reload()} 	, oWin31,"Transmissao NF"	,,.T.)
	oBtn4 := TBtnBmp2():New(002,oWin31:NWIDTH-160,30,30,'SDUSETDEL'	,,,,{|| u_N6FAT001(),Reload()} 	, oWin31,"Faturamento DT"	,,.T.)
	If FWCodFil() == "02"
		oBtn5 := TBtnBmp2():New(002,oWin31:NWIDTH-190,30,30,'SDUIMPORT'		,,,,{|| u_N6WS005(),Reload()} 	, oWin31,"Retorno PickList"			,,.T.)
		oBtn6 := TBtnBmp2():New(002,oWin31:NWIDTH-220,30,30,'SDURECALL'		,,,,{|| u_N6FAT003(),Reload()} 	, oWin31,"Reenvia PickList(Ws Erro)",,.T.)
	EndIf
	oBtn7	:= TBtnBmp2():New(002,oWin31:NWIDTH-250	,30,30,'PEDIDO'		,,,,{|| u_N6FAT010(),Reload()} 	, oWin31,"Liberar Pedido"	,,.T.)
	oBtn8	:= TBtnBmp2():New(002,oWin31:NWIDTH-280	,30,30,'MENURUN'	,,,,{|| u_N6FAT007(),Reload()} 	, oWin31,"Importar Datatrax",,.T.)
	//oBtn9	:= TBtnBmp2():New(002,040				,30,30,'PMSPRINT'	,,,,{|| GeraRel(),Reload()} 	, oWin31,"Relatorios"		,,.T.)
	oBtn10	:= TBtnBmp2():New(002,010				,30,30,'REFRESH'	,,,,{|| Reload()}  				, oWin31,"Recarregar dados"	,,.T.)

	//Log
	aAdd(aALog02,'LOGVIEW')
	aAdd(aHLog02,{"Log.View" 		,'LOGVIEW'		,"@BMP"		,  1,0,"AllwaysTrue()" ,"€€€€€€€€€€€€€€ ","C","","R",,,,'A'})
	aAdd(aHLog02,{"descrição" 		,'DESCR'		,""			, 40,0,"AllwaysTrue()" ,"€€€€€€€€€€€€€€ ","C","","R",,,,'A'})
	aAdd(aHLog02,{"Data"			,'DATA'			,""	    	,  8,0,"AllwaysTrue()" ,"€€€€€€€€€€€€€€ ","D","","R",,,,'A'})
	aAdd(aHLog02,{"Hora"			,'HORA'			,"@!"		,  8,0,"AllwaysTrue()" ,"€€€€€€€€€€€€€€ ","C","","R",,,,'A'})
	aAdd(aHLog02,{"Recno"	 		,'RECNO'		,""			, 10,0,"AllwaysTrue()" ,"€€€€€€€€€€€€€€ ","N","","R",,,,'A'})
	oGetLog02:= MsNewGetDados():New(020,002,(oWin31:NHEIGHT/2),(oWin31:NWIDTH/2),GD_UPDATE,'AllwaysTrue()','AllwaysTrue()','',aALog02,0,9999,'AllwaysTrue()','','AllwaysTrue()',oWin31,aHLog02,{} )
	oGetLog02:AddAction('LOGVIEW', {|| ViewLog(oGetLog02:aCols[oGetLog02:Obrowse:nAt][5]), oGetLog02:aCols[oGetLog02:Obrowse:nAt][1] })

	aAdd(aHLog03,{"descrição" 		,'DESCR'		,""			, 40,0,"AllwaysTrue()" ,"€€€€€€€€€€€€€€ ","C","","R",,,,'A'})
	aAdd(aHLog03,{"Data"			,'DATA'			,""	    	,  8,0,"AllwaysTrue()" ,"€€€€€€€€€€€€€€ ","D","","R",,,,'A'})
	aAdd(aHLog03,{"Hora"			,'HORA'			,"@!"		,  8,0,"AllwaysTrue()" ,"€€€€€€€€€€€€€€ ","C","","R",,,,'A'})
	aAdd(aHLog03,{"Recno"	 		,'RECNO'		,""			, 10,0,"AllwaysTrue()" ,"€€€€€€€€€€€€€€ ","N","","R",,,,'A'})
	oGetLog03:= MsNewGetDados():New(020,002,(oWin31:NHEIGHT/2),(oWin31:NWIDTH/2),GD_UPDATE,'AllwaysTrue()','AllwaysTrue()','',aALog03,0,9999,'AllwaysTrue()','','AllwaysTrue()',oWin31,aHLog03,{} )

	aAdd(aHLog11,{"Filial" 		,'C5_FILIAL'		,""    	,  2,0,"AllwaysTrue()" ,"€€€€€€€€€€€€€€ ","C","","R",,,,'A'})
	aAdd(aHLog11,{"DataTrax"	,'C5_P_DTRAX'		,""    	, 10,0,"AllwaysTrue()" ,"€€€€€€€€€€€€€€ ","C","","R",,,,'A'})
	aAdd(aHLog11,{"Ped.Totvs"	,'C5_NUM'			,""		,  9,0,"AllwaysTrue()" ,"€€€€€€€€€€€€€€ ","C","","R",,,,'A'})
	aAdd(aHLog11,{"Tipo Ped." 	,'C5_TIPO'			,""    	,  1,0,"AllwaysTrue()" ,"€€€€€€€€€€€€€€ ","C","","R",,,,'A'})
	aAdd(aHLog11,{"NF"			,'C5_NOTA'			,""		,  9,0,"AllwaysTrue()" ,"€€€€€€€€€€€€€€ ","C","","R",,,,'A'})
	aAdd(aHLog11,{"Serie"		,'C5_SERIE'			,""		,  3,0,"AllwaysTrue()" ,"€€€€€€€€€€€€€€ ","C","","R",,,,'A'})
	oGetLog11:= MsNewGetDados():New(020,002,(oWin31:NHEIGHT/2),(oWin31:NWIDTH/2),GD_UPDATE,'AllwaysTrue()','AllwaysTrue()','',aALog11,0,9999,'AllwaysTrue()','','AllwaysTrue()',oWin31,aHLog11,{} )

	aAdd(aALogEr,'LOGVIEW')
	aAdd(aHLogEr,{"Log.View" 		,'LOGVIEW'		,"@BMP"		,  1,0,"AllwaysTrue()" ,"€€€€€€€€€€€€€€ ","C","","R",,,,'A'})
	aAdd(aHLogEr,{"Recno"	 		,'RECNO'		,""			, 10,0,"AllwaysTrue()" ,"€€€€€€€€€€€€€€ ","N","","R",,,,'A'})
	aAdd(aHLogEr,{"Data"			,'DATA'			,""	    	,  8,0,"AllwaysTrue()" ,"€€€€€€€€€€€€€€ ","D","","R",,,,'A'})
	aAdd(aHLogEr,{"Hora"			,'HORA'			,"@!"		,  8,0,"AllwaysTrue()" ,"€€€€€€€€€€€€€€ ","C","","R",,,,'A'})
	aAdd(aHLogEr,{"Log (Resumo)"	,'LOG'			,"@!"		,150,0,"AllwaysTrue()" ,"€€€€€€€€€€€€€€ ","C","","R",,,,'A'})
	oGetLogEr:= MsNewGetDados():New(020,002,(oWin31:NHEIGHT/2),(oWin31:NWIDTH/2),GD_UPDATE,'AllwaysTrue()','AllwaysTrue()','',aALogEr,0,9999,'AllwaysTrue()','','AllwaysTrue()',oWin31,aHLogEr,{} )
	oGetLogEr:AddAction('LOGVIEW', {|| ViewLog(oGetLogEr:aCols[oGetLogEr:Obrowse:nAt][2]), oGetLogEr:aCols[oGetLogEr:Obrowse:nAt][1] })

	Reload()

oDlgLog:Activate(,,,.T.)

Return .T.

*-------------------------------*
STATIC FUNCTION LoadChart(aDados)
*-------------------------------*
Local i

oChart:DeActivate()
oChart:SetOwner(oWin12)
For i:=1 to Len(aDados)
	If ALLTRIM(aDados[i][1]) <> "11"
		oChart:addSerie( ALLTRIM(aDados[i][1]), aDados[i][2])
	EndIf
Next i
oChart:setLegend( CONTROL_ALIGN_LEFT ) 
oChart:SetChartDefault(NEWPIECHART)
oChart:Activate()

RETURN .T.

*------------------------------------------------------*
Static Function LoadCols(cOpc,aParam,cFiltroFil,cFiltro)
*------------------------------------------------------*
Local aRet := {}
Local cQry := ""
Local cFilQry := ""

DEFAULT aParam := {}
DEFAULT cFiltroFil := ""
DEFAULT cFiltro := ""

cFiltro := ALLTRIM(UPPER(cFiltro))

If !EMPTY(cFiltroFil)
	If cFiltroFil <> 'Ambas'
   		cFilQry := RIGHT(cFiltroFil,2)
	EndIf
EndIf

If Select("TMP") > 0
	TMP->(dbCloseArea())
EndIf

DO CASE
	Case cOpc == "RESUMO"
		cQry := "Select C5_P_STFED,
		cQry += "		CASE
		cQry += "		WHEN C5_P_STFED = '' THEN 'New orders' 
		cQry += "		WHEN C5_P_STFED = '01' THEN 'Picking Sent'
		cQry += "		WHEN C5_P_STFED = '02' THEN 'Picking Confirmation Received'
		cQry += "		WHEN C5_P_STFED = '03' THEN 'Picking Return Received'
		cQry += "		WHEN C5_P_STFED = '04' THEN 'Picking Unconfirmed'
		cQry += "		WHEN C5_P_STFED = '05' THEN 'Webservice Error'
		cQry += "		WHEN C5_P_STFED = '06' THEN 'Webservice Error'
		cQry += "		WHEN C5_P_STFED = '07' THEN 'Order invoiced and NF yet to be transmitted'
		cQry += "		WHEN C5_P_STFED = '08' THEN 'Order invoicing failed and NF yet to be created'
		cQry += "		WHEN C5_P_STFED = '09' THEN 'NF transmitted and yet to be approved'
		cQry += "		WHEN C5_P_STFED = '10' THEN 'NF transmission error'
		cQry += "		WHEN C5_P_STFED = '11' THEN 'NF Successfully issued'
		cQry += "		WHEN C5_P_STFED = '12' THEN 'NF DANFE creation error'
		cQry += "		ELSE 'N/A'
		cQry += "		END as STFED_DESCR,
		cQry += "		COUNT(C5_P_STFED) as QTDE
		cQry += "	From "+RetSQLName("SC5")
		cQry += "	Where D_E_L_E_T_ <> '*' AND C5_P_CHAVE <> ''
		If !EMPTY(cFilQry)
			cQry += "		AND C5_FILIAL = '"+cFilQry+"'
		EndIf
		cQry += "	Group BY C5_P_STFED
		cQry += "	Order BY C5_P_STFED
		TCQUERY cQry NEW ALIAS "TMP"
		While !TMP->(EOF())		
			aAdd(aRet,{TMP->C5_P_STFED,TMP->QTDE,TMP->STFED_DESCR,.F.})
			TMP->(dbSkip())
		EndDo
		TMP->(dbCloseArea())
		cQry := "Select COUNT(*) as QTDE From (Select ZX2_FILIAL,CASE WHEN LEFT(ZX2_CHAVE,2)='SO' THEN SUBSTRING(ZX2_CHAVE,3,8) ELSE ZX2_CHAVE END ZX2_CHAVE
		cQry += " From "+RetSQLName("ZX2")
		cQry += " Where D_E_L_E_T_ <> '*' 
		cQry += "	AND ZX2_FROM='DataTrax'
		cQry += "	AND ZX2_TO ='Totvs'
		cQry += "	AND ZX2_CHAVE not like 'CLIENTE%'
		cQry += "	AND CASE WHEN LEFT(ZX2_CHAVE,2)='SO' THEN SUBSTRING(ZX2_CHAVE,3,8) ELSE ZX2_CHAVE END 
		cQry += "		not in (Select C5_P_DTRAX From "+RetSQLName("SC5")+" Where D_E_L_E_T_ <> '*' AND C5_P_DTRAX <> '' GROUP BY C5_P_DTRAX)
		If !EMPTY(cFilQry)
			cQry += "	AND ZX2_FILIAL = '"+cFilQry+"'
		EndIf
		cQry += " Group by ZX2_FILIAL,CASE WHEN LEFT(ZX2_CHAVE,2)='SO' THEN SUBSTRING(ZX2_CHAVE,3,8) ELSE ZX2_CHAVE END       	) AS LOG
		TCQUERY cQry NEW ALIAS "TMP"
		While !TMP->(EOF())		
			aAdd(aRet,{'ERRO',TMP->QTDE,'Pedido não integrado',.F.})
			TMP->(dbSkip())
		EndDo
		
		LoadChart(aRet)

	Case cOpc == "DETALHE"
		If aParam[1]$"ERRO"
			cQry := "Select ZX2_FILIAL,CASE WHEN LEFT(ZX2_CHAVE,2)='SO' THEN SUBSTRING(ZX2_CHAVE,3,8) ELSE ZX2_CHAVE END ZX2_CHAVE
			cQry += " From "+RetSQLName("ZX2") 
			cQry += "	Where D_E_L_E_T_ <> '*' 
			cQry += "	AND ZX2_FROM='DataTrax'
			cQry += "	AND ZX2_TO ='Totvs'
			cQry += "	AND ZX2_CHAVE not like 'CLIENTE%'
			cQry += "	AND CASE WHEN LEFT(ZX2_CHAVE,2)='SO' THEN SUBSTRING(ZX2_CHAVE,3,8) ELSE ZX2_CHAVE END 
			cQry += "	not in (Select C5_P_DTRAX From "+RetSQLName("SC5")+" Where D_E_L_E_T_ <> '*' AND C5_P_DTRAX <> '' GROUP BY C5_P_DTRAX)
			If !EMPTY(cFilQry)
				cQry += "	AND ZX2_FILIAL = '"+cFilQry+"'
			EndIf
			If !EMPTY(cFiltro)
				cQry += "	AND (UPPER(ZX2_CHAVE) like '%"+cFiltro+"%')
			EndIf
			cQry += "	Group by ZX2_FILIAL,CASE WHEN LEFT(ZX2_CHAVE,2)='SO' THEN SUBSTRING(ZX2_CHAVE,3,8) ELSE ZX2_CHAVE END
			cQry += "	Order by ZX2_FILIAL,CASE WHEN LEFT(ZX2_CHAVE,2)='SO' THEN SUBSTRING(ZX2_CHAVE,3,8) ELSE ZX2_CHAVE END
			TCQUERY cQry NEW ALIAS "TMP"
			While !TMP->(EOF())		
				aAdd(aRet,{TMP->ZX2_FILIAL,TMP->ZX2_CHAVE,'','','',.F.})
				TMP->(dbSkip())
			EndDo
		Else	
			cQry := "Select SC5.C5_FILIAL,SC5.C5_P_DTRAX,SC5.C5_NUM,SC5.C5_CLIENTE,SA1.A1_NOME
			cQry += "	From "+RetSQLName("SC5")+" SC5
			cQry += "	Left outer join "+RetSQLName("SA1")+" SA1 on SA1.A1_COD = SC5.C5_CLIENTE
			cQry += "	Where SC5.D_E_L_E_T_ <> '*' 
			cQry += "		AND SC5.C5_P_CHAVE <> ''
			cQry += "		AND SC5.C5_P_STFED='"+aParam[1]+"'
			If !EMPTY(cFilQry)
				cQry += "	AND C5_FILIAL = '"+cFilQry+"'
			EndIf
			If !EMPTY(cFiltro)
				cQry += "	AND (UPPER(C5_P_DTRAX) like '%"+cFiltro+"%' OR UPPER(C5_CLIENTE) like '%"+cFiltro+"%' OR UPPER(A1_NOME) like '%"+cFiltro+"%')
			EndIf
			cQry += "	Order BY SC5.C5_P_DTRAX
			TCQUERY cQry NEW ALIAS "TMP"
			While !TMP->(EOF())		
				aAdd(aRet,{TMP->C5_FILIAL,TMP->C5_P_DTRAX,TMP->C5_NUM,TMP->C5_CLIENTE,TMP->A1_NOME,.F.})
				TMP->(dbSkip())
			EndDo
		EndIf
	
	Case cOpc == "LOG"
		If aParam[1] $ "02|05|06"
			cQry := " Select CASE 
			cQry += " 			WHEN ZX2_SERWS='GenSoWMS10In' AND ZX2_TIPO='E' THEN 'Enviado pedido do Totvs para a Fedex'
			cQry += " 			WHEN ZX2_SERWS='GenSoWMS10In' AND ZX2_TIPO='R' THEN 'Confirmação da Fedex de pedido recebido'
			cQry += " 			WHEN ZX2_SERWS='ConfirmCaixaSeparacaoWMS1' AND ZX2_TIPO='E' THEN 'Totvs consulta status do pedido na Fedex'
			cQry += " 			WHEN ZX2_SERWS='ConfirmCaixaSeparacaoWMS1' AND ZX2_TIPO='R' THEN 'Fedex retorna status do pedido'
			cQry += " 		END ZX2_DESCRI,ZX2_DATA,ZX2_HORA,R_E_C_N_O_
			cQry += " From "+RetSQLName("ZX2")  
			cQry += " Where D_E_L_E_T_ <> '*'
			cQry += " AND (UPPER(ZX2_TO)='FEDEX' or UPPER(ZX2_FROM)='FEDEX')
			cQry += " AND ISNULL(CONVERT(VARCHAR(max), CONVERT(VARBINARY(max), ZX2_ERRO)),'') not like 'SUCESSO%'
			cQry += " AND ZX2_CHAVE= '"+ALLTRIM(aParam[2])+"'
			If !EMPTY(cFilQry)
				cQry += "	AND ZX2_FILIAL = '"+cFilQry+"'
			EndIf
			cQry += " ORDER BY R_E_C_N_O_ DESC
			TCQUERY cQry NEW ALIAS "TMP"
			TCSetField("TMP" ,'ZX2_DATA','D',8)

			While !TMP->(EOF())		
				aAdd(aRet,{olupa,TMP->ZX2_DESCRI,TMP->ZX2_DATA,TMP->ZX2_HORA,TMP->R_E_C_N_O_,.F.})
				TMP->(dbSkip())
			EndDo

		ElseIf aParam[1] $ "03"
			cQry := " Select ZX2_DATA,ZX2_HORA,R_E_C_N_O_
			cQry += " From "+RetSQLName("ZX2")  
			cQry += " Where D_E_L_E_T_ <> '*'
			cQry += " AND ISNULL(CONVERT(VARCHAR(max), CONVERT(VARBINARY(max), ZX2_ERRO)),'') like 'SUCESSO%'
			cQry += " AND ZX2_CHAVE= '"+ALLTRIM(aParam[2])+"'
			If !EMPTY(cFilQry)
				cQry += "	AND ZX2_FILIAL = '"+cFilQry+"'
			EndIf
			cQry += " ORDER BY R_E_C_N_O_ DESC
			TCQUERY cQry NEW ALIAS "TMP"
			TCSetField("TMP" ,'ZX2_DATA','D',8)

			While !TMP->(EOF())		
				aAdd(aRet,{'Retorno Fedex, picking liberado',TMP->ZX2_DATA,TMP->ZX2_HORA,TMP->R_E_C_N_O_,.F.})
				TMP->(dbSkip())
			EndDo

		ElseIf aParam[1] $ "11|09|07|12"
			cQry := "Select C5_FILIAL,C5_TIPO,C5_P_DTRAX,C5_NUM,C5_NOTA,C5_SERIE
			cQry += " From "+RetSQLName("SC5")
			cQry += " Where D_E_L_E_T_ <> '*' 
			cQry += "	AND C5_P_DTRAX = '"+ALLTRIM(aParam[2])+"'
			If !EMPTY(cFilQry)
				cQry += "	AND C5_FILIAL = '"+cFilQry+"'
			EndIf
			TCQUERY cQry NEW ALIAS "TMP"

			While !TMP->(EOF())		
				aAdd(aRet,{TMP->C5_FILIAL,TMP->C5_P_DTRAX,TMP->C5_NUM,TMP->C5_TIPO,TMP->C5_NOTA,TMP->C5_SERIE,.F.})
				TMP->(dbSkip())
			EndDo

		ElseIf aParam[1] $ "ERRO"
			cQry := "Select R_E_C_N_O_,ZX2_DATA,ZX2_HORA,LEFT(ISNULL(CONVERT(VARCHAR(150), CONVERT(VARBINARY(150), ZX2_ERRO)),''),150) as ERRO
			cQry += " From "+RetSQLName("ZX2")
			cQry += " Where D_E_L_E_T_ <> '*' 
			cQry += "	AND (ZX2_CHAVE = '"+ALLTRIM(aParam[2])+"' OR ZX2_CHAVE like 'SO"+ALLTRIM(aParam[2])+"%')
			cQry += "	AND ZX2_SERWS='GTPREVALID'
			If !EMPTY(cFilQry)
				cQry += "	AND ZX2_FILIAL = '"+cFilQry+"'
			EndIf
			cQry += " Order BY R_E_C_N_O_ DESC
			TCQUERY cQry NEW ALIAS "TMP"
			
			TCSetField("TMP" ,'ZX2_DATA','D',8)
			
			While !TMP->(EOF())		
				aAdd(aRet,{olupa,TMP->R_E_C_N_O_,TMP->ZX2_DATA,TMP->ZX2_HORA,TMP->ERRO,.F.})
				TMP->(dbSkip())
			EndDo
		EndIf

ENDCASE

If Select("TMP") > 0
	TMP->(dbCloseArea())
EndIf

Return aRet

*----------------------*
Static Function Reload()
*----------------------*
cGet1 := space(200)
oGetRes:aCols := LoadCols("RESUMO",,cCombo1,cGet1)
oGetRes:ForceRefresh()
MudaLinha("RESUMO")
Return .T.

/*
Funcao	    : MudaLinha()
Parametros  : 
Retorno     : 
Objetivos   : Atualiza o Browse de acordo com o Layout posicionado
Autor       : Jean Victor Rocha 
Data/Hora   : 
*/
*-----------------------------*
Static function MudaLinha(cOpc)
*-----------------------------*
If cOpc == "RESUMO"
	oGetDet:aCols := LoadCols("DETALHE"	,{oGetRes:aCols[oGetRes:NAT][1]},cCombo1,cGet1)
	oGetDet:ForceRefresh()
EndIf

If LEN(oGetDet:aCols) <> 0
	Do CASE
		CASE oGetRes:aCols[oGetRes:NAT][1] $ "02|05|06"
			oGetLog02:aCols	:= LoadCols("LOG"	,{oGetRes:aCols[oGetRes:NAT][1],oGetDet:aCols[oGetDet:NAT][2]},cCombo1,cGet1)
		CASE oGetRes:aCols[oGetRes:NAT][1] $ "03"
			oGetLog03:aCols	:= LoadCols("LOG"	,{oGetRes:aCols[oGetRes:NAT][1],oGetDet:aCols[oGetDet:NAT][2]},cCombo1,cGet1)
		CASE oGetRes:aCols[oGetRes:NAT][1] $ "11|09|07|12"
			oGetLog11:aCols	:= LoadCols("LOG"	,{oGetRes:aCols[oGetRes:NAT][1],oGetDet:aCols[oGetDet:NAT][2]},cCombo1,cGet1)
		CASE oGetRes:aCols[oGetRes:NAT][1] $ "ERRO"
			oGetLogEr:aCols := LoadCols("LOG"	,{oGetRes:aCols[oGetRes:NAT][1],oGetDet:aCols[oGetDet:NAT][2]},cCombo1,cGet1)
			oGetLogEr:ForceRefresh()    
	ENDCASE

	oGetLog02:OBROWSE:LVISIBLECONTROL := oGetRes:aCols[oGetRes:NAT][1] $ "02|05|06"
	oGetLog03:OBROWSE:LVISIBLECONTROL := oGetRes:aCols[oGetRes:NAT][1] $ "03"
	oGetLog11:OBROWSE:LVISIBLECONTROL := oGetRes:aCols[oGetRes:NAT][1] $ "11|09|07|12"
	oGetLogEr:OBROWSE:LVISIBLECONTROL := oGetRes:aCols[oGetRes:NAT][1] $ "ERRO"
Else
	oGetLog02:OBROWSE:LVISIBLECONTROL := .F.
	oGetLog03:OBROWSE:LVISIBLECONTROL := .F.
	oGetLog11:OBROWSE:LVISIBLECONTROL := .F.
	oGetLogEr:OBROWSE:LVISIBLECONTROL := .F.
EndIf

oGetLog02:ForceRefresh()
oGetLog03:ForceRefresh()
oGetLog11:ForceRefresh()
oGetLogEr:ForceRefresh()
Return .T.

*-----------------------------*
Static Function ViewLog(nRecno)
*-----------------------------*
If Select("TMP") > 0
	TMP->(dbCloseArea())
EndIf
cQry := "Select ISNULL(CONVERT(VARCHAR(8000), CONVERT(VARBINARY(8000), ZX2_ERRO)),'') as ERRO
cQry += " From "+RetSQLName("ZX2")
cQry += " Where D_E_L_E_T_ <> '*' 
cQry += "	AND R_E_C_N_O_ = "+ALLTRIM(STR(nRecno))
TCQUERY cQry NEW ALIAS "TMP"

EECVIEW(TMP->ERRO)

Return .T.
          
*-----------------------*
Static Function GeraRel()
*-----------------------*
Local nOpc := 0
Private nRadio	:= 1
Private oDlgRel
Private oSay1
Private oRMenu1
Private oSBtn1
Private oSBtn2
Private aOpcoes	:= getQry(,"OPCOES")

oDlgRel	:= MSDialog():New(140,435,550,875,"HLB BRASIL - doTerra - Geração de Relatorios",,,.F.,,,,,,.T.,,,.T. )
	oSay1	:= TSay():New(004,004,{|| "Selecione o relatorio a ser gerado:"},oDlgRel,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,212,008)
	GoRMenu1:= TGroup():New(016,004,184,216,"Relatorios",oDlgRel,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oRMenu1	:= TRadMenu():New(030,015,aOpcoes,,GoRMenu1,,,CLR_BLACK,CLR_WHITE,"",,,192,168,,.F.,.F.,.T. )
	oRMenu1:bSetGet := {|u|Iif (PCount()==0,nRadio,nRadio:=u)}

	oSBtn1	:= SButton():New(188,160,2,{|| oDlgRel:End()},oDlgRel,,"", )
	oSBtn2	:= SButton():New(188,189,1,{|| nOpc:=1,oDlgRel:End()},oDlgRel,,"", )
oDlgRel:Activate(,,,.T.)

If nOpc == 1
	Processa({|| PrintRel(nRadio) } ,"Geração de Relatório","Processando registros...")
EndIf

Return .T.

*------------------------------*
Static Function PrintRel(nRadio)
*------------------------------*
Local cQry := ""
Local nTotRegs := 0

Private cArq := "RELATORIO_MONITOR_"+ALLTRIM(STR(nRadio))+DTOS(Date())+"_"+StrTran(Time(),":","") + ".xls"

cQry := getQry(nRadio,"QUERY")

If EMPTY(cQry)
	MsgInfo("Não foi possivel carregar a consulta","HLB BRASIL")
	Return .F.
EndIf

If TCSQLEXEC(cQry) # 0
	Alert("Erro na geração do relatório." + CHR(13)+CHR(10) + "Erro SQL: " + TCSQLError())
	Return .F.
EndIf

If Select("REL_MNT") > 0
	REL_MNT->(DbClosearea())
Endif	

TCQuery cQry ALIAS "REL_MNT" NEW

If REL_MNT->(Bof()) .AND. REL_MNT->(Eof())
	Alert("Nenhum registro localizado.")
	Return .F.
EndIf

REL_MNT->(DbGoTop())
nTotRegs := Contar("REL_MNT","!Eof()")
REL_MNT->(DbGoTop())

ProcRegua(nTotRegs)
GeraExcel()

If CpyS2T("\SYSTEM\"+cArq, GetTempPath())
	FErase("\SYSTEM\"+cArq)
EndIf

If !File(GetTempPath()+cArq)
	Alert("Erro ao localizar arquivo gerado para este relatório.")
	Return .F.
EndIf

If !ApOleClient('MsExcel')
	Alert('MsExcel não instalado.')
	Return .F.
EndIf

SHELLEXECUTE("open",(GetTempPath()+cArq),"","",5)   // Gera o arquivo em Excel

If Select("REL_MNT") > 0
	REL_MNT->(DbClosearea())
Endif

Return .T.

*-------------------------*
Static Function GeraExcel()
*-------------------------*
Local oExcel := FWMSEXCEL():New()
Local nCols := REL_MNT->(FCount()), i

oExcel:AddWorkSheet(AllTrim(aOpcoes[nRadio]))
oExcel:AddTable(AllTrim(aOpcoes[nRadio]),AllTrim(aOpcoes[nRadio]))

For i := 1 To nCols
	oExcel:AddColumn(AllTrim(aOpcoes[nRadio]),AllTrim(aOpcoes[nRadio]),REL_MNT->(Field(i)),1,1,.F.)
Next i

REL_MNT->(DbGoTop())
Do While REL_MNT->(!Eof())
	IncProc()
	aRow := {}
	For i := 1 To nCols
		aAdd(aRow,REL_MNT->(FieldGet(i)))
	Next i
	oExcel:AddRow(AllTrim(aOpcoes[nRadio]),AllTrim(aOpcoes[nRadio]),aRow)
	REL_MNT->(DbSkip())
EndDo

oExcel:Activate()
oExcel:GetXMLFile(cArq)

Return

*---------------------------------*
Static Function getQry(nRadio,cOpc)
*---------------------------------*
Local xRet := ""
Local aOpcMenu := {"Cadastro de clientes",;
			   		"Cadastro de Produtos (Tipo = ME)",;
			   		"Cadastro de Fornecedores",;
			   		"Cadastro de Transportadoras",;
			   		"Quantidade de P.V. por Status",;
			   		"Quantidade de P.V. sem estoque (Produtos = ME)",;
			   		"Log de envio de DANFE ao FEDEX",;
			   		"Log de P.V. Represados (ERRO = Pedido não integrado)"}

Default nRadio := 0
Default cOpc := "QUERY"

DO CASE
	CASE cOpc =="QUERY"
		DO CASE
			CASE nRadio == 1
				xRet := "SELECT * FROM "+RetSQLName("SA1")+" WHERE D_E_L_E_T_<>'*'"
			CASE nRadio == 2
				xRet := "SELECT * FROM "+RetSQLName("SB1")+" WHERE D_E_L_E_T_<>'*' AND B1_TIPO='ME'"
			CASE nRadio == 3
				xRet := "SELECT * FROM "+RetSQLName("SA2")+" WHERE D_E_L_E_T_<>'*' "
			CASE nRadio == 4
				xRet := "SELECT * FROM "+RetSQLName("SA4")+" WHERE D_E_L_E_T_<>'*' "
			CASE nRadio == 5
				xRet := "SELECT C5_FILIAL,LEFT(C5_EMISSAO,4) as PERIODO_ANO,SUBSTRING(C5_EMISSAO,5,2) as PERIODO_MES,
				xRet += " C5_P_STFED,
				xRet += " CASE WHEN C5_P_STFED = '' THEN 'New orders' 
				xRet += "		WHEN C5_P_STFED = '01' THEN 'Picking Sent'
				xRet += "		WHEN C5_P_STFED = '02' THEN 'Picking Confirmation Received'
				xRet += "		WHEN C5_P_STFED = '03' THEN 'Picking Return Received'
				xRet += "		WHEN C5_P_STFED = '04' THEN 'Picking Unconfirmed'
				xRet += "		WHEN C5_P_STFED = '05' THEN 'Webservice Error'
				xRet += "		WHEN C5_P_STFED = '06' THEN 'Webservice Error'
				xRet += "		WHEN C5_P_STFED = '07' THEN 'Order invoiced and NF yet to be transmitted'
				xRet += "		WHEN C5_P_STFED = '08' THEN 'Order invoicing failed and NF yet to be created'
				xRet += "		WHEN C5_P_STFED = '09' THEN 'NF transmitted and yet to be approved'
				xRet += "		WHEN C5_P_STFED = '10' THEN 'NF transmission error'
				xRet += "		WHEN C5_P_STFED = '11' THEN 'NF Successfully issued'
				xRet += "		WHEN C5_P_STFED = '12' THEN 'NF DANFE creation error'
				xRet += "		ELSE 'N/A'
				xRet += "		END as STFED_DESCR,
				xRet += " COUNT(C5_P_STFED) as QTDE
				xRet += " FROM "+RetSQLName("SC5")
				xRet += " WHERE D_E_L_E_T_ <> '*' AND C5_P_CHAVE <> ''
				xRet += " Group BY C5_FILIAL,LEFT(C5_EMISSAO,4),SUBSTRING(C5_EMISSAO,5,2),C5_P_STFED
				xRet += " Order BY C5_FILIAL,LEFT(C5_EMISSAO,4),SUBSTRING(C5_EMISSAO,5,2),C5_P_STFED
			CASE nRadio == 6
				xRet := "SELECT SB2.B2_FILIAL,SB2.B2_COD,SB2.B2_QATU,COUNT(C6_QTDVEN) QTDE_SO,SUM(C6_QTDVEN) C6_QTDVEN
				xRet += " FROM "+RetSQLName("SC6")+" SC6
				xRet += " LEFT OUTER JOIN "+RetSQLName("SB1")+" SB1		on SC6.C6_PRODUTO = SB1.B1_COD
				xRet += " LEFT OUTER JOIN "+RetSQLName("SB2")+" SB2		on SB2.B2_FILIAL = SC6.C6_FILIAL		AND SB2.B2_COD = SC6.C6_PRODUTO
				xRet += " WHERE SC6.D_E_L_E_T_ <> '*' AND SC6.C6_NOTA = '' AND SB2.B2_QATU = 0 AND SB1.B1_TIPO IN ('ME')
				xRet += " GROUP BY SB2.B2_FILIAL,SB2.B2_COD,SB2.B2_QATU
				xRet += " Order by SB2.B2_COD,SB2.B2_FILIAL
			CASE nRadio == 7
				xRet := "SELECT ZX2_CHAVE NF,ZX2_DATA DATA,ZX2_HORA HORA,R_E_C_N_O_ 
				xRet += " From "+RetSQLName("ZX2")+" Where ZX2_SERWS='N6FAT003'
				xRet += " AND ISNULL(CONVERT(VARCHAR(max), CONVERT(VARBINARY(max), ZX2_CONTEU)),'''') <> ''''
				xRet += " Union ALL
				xRet += " Select ZX2_CHAVE,ZX2_DATA,ZX2_HORA,R_E_C_N_O_ 
				xRet += " From "+RetSQLName("ZX2")+" Where ZX2_SERWS='N6FAT004' AND ISNULL(CONVERT(VARCHAR(max), CONVERT(VARBINARY(max), ZX2_CONTEU)),'''') <> ''''
				xRet += " Order By R_E_C_N_O_ DESC
			CASE nRadio == 8
				xRet := "Select ZX2_FILIAL,ZX2_CHAVE,ZX2_DATA,ZX2_HORA,
				xRet += " REPLACE(REPLACE(ISNULL(CONVERT(VARCHAR(4096), CONVERT(VARBINARY(4096),ZX2_ERRO)),''),'<','|/|'),'>','|\|') LOG 
				xRet += " From "+RetSQLName("ZX2") 
				xRet += " Where D_E_L_E_T_ <> '*' 
				xRet += " AND ZX2_FROM='DataTrax'
				xRet += " AND ZX2_TO ='Totvs'
				xRet += " AND ZX2_CHAVE not like 'CLIENTE%'
				xRet += " AND CASE WHEN LEFT(ZX2_CHAVE,2)='SO' THEN SUBSTRING(ZX2_CHAVE,3,8) ELSE ZX2_CHAVE END 
				xRet += " not in (Select C5_P_DTRAX From "+RetSQLName("SC5")+" Where D_E_L_E_T_ <> '*' AND C5_P_DTRAX <> '' GROUP BY C5_P_DTRAX)
				xRet += " ORDER BY R_E_C_N_O_ DESC 

		ENDCASE
	CASE cOpc == "OPCOES"
		xRet := aOpcMenu

ENDCASE

Return xRet