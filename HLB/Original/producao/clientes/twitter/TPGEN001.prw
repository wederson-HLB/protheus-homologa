#INCLUDE "SPEDNFE.ch"
#INCLUDE "FILEIO.CH"
#INCLUDE "RPTDEF.CH"  
#INCLUDE "FWPrintSetup.ch"
#Include "topconn.ch"
#Include "rwmake.ch"
#Include "protheus.ch"  
#Include "tbiconn.ch"

/*
Funcao      : TPGEN001
Parametros  : Nil
Retorno     : Nil
Objetivos   : Rotina de integração
Autor       : Jean Victor Rocha
Data/Hora   : 06/10/2014
*/
*----------------------*
User Function TPGEN001()
*----------------------*
//Variaveis locais.
Local i

//Controle Global no Fonte para saber qual a integração esta sendo gravada
Private nNATAtu := 0
Private cArqAtu := ""

//Verifica se a chamada foi de JOB ou não
Private lJob := (Select("SX3") <= 0)

//Parametros do FTP  //MSM - 07/04/2015 - Alterado para não trazer o ftp da produção quando não existir nos parâmetros

//Diretorio no Servido Protheus
Private cDirSrvIn := "\FTP\"+cEmpAnt+"\TPGEN001\IN"
Private cDirSrvOut := "\FTP\"+cEmpAnt+"\TPGEN001\OUT"

//Email de Notificação de interface
Private cEmailA1 	:= GETMV("MV_P_00026",,"jean.rocha@hlb.com.br")
Private cEmailA5 	:= GETMV("MV_P_00027",,"jean.rocha@hlb.com.br")
Private cEmailZX 	:= GETMV("MV_P_00028",,"jean.rocha@hlb.com.br")
Private cEmailF2 	:= GETMV("MV_P_00029",,"jean.rocha@hlb.com.br")
Private cEmailE1 	:= GETMV("MV_P_00030",,"jean.rocha@hlb.com.br")

//Parametros Iniciais dos Filtros de tela
Private cPar01 := ""
Private cPar02 := ""
Private cPar03 := ""
Private cPar04 := ""
Private cPar05 := ""
Private cPar06 := ""
Private cPar07 := ""
Private cPar08 := ""
Private nPar01 := 1

//Delimitador utilizado nos arquivos CSV.
Private cDelimitador := "|"

//Criação da referencia da integração com o Nome de Arquivo.
Private aRefArq:= {	{'01','BR_CUSTOMER_OB_'		,{|| GravaSA1() },"IN"},;
					{'02','BR_SALESORDER_OB_'	,{|| GravaSC5() },"IN"},;
					{'03','BR_CAMPAIGNS_OB_'	,{|| GravaZX1() },"IN"},;
					{'04','BR_INVOICE_IB_'		,{|| GravaSF2() },"OUT"},;
					{'05','BR_RECEIPTS_IB_'		,{|| GravaSE1() },"OUT"},;
					{'06','BR_INVOICE_IB_LOG_'	,{|| GrvLOGSF2()},"LOG"},;
					{'07','BR_INVOICE_IB_LOG_'	,{|| GrvLOGSE1()},"LOG"}}       

//Tipo de arquivo ZIP.
Private cExtZip := "ZIP"

//Controle de Alteração na Rotina.
Private lonlyView	:= .F.

//Controle de Status e Check de tela
Private oSelS	:= LoadBitmap( nil, "LBOK")
Private oSelN	:= LoadBitmap( nil, "LBNO") 
Private oStsok	:= LoadBitmap( nil, "BR_VERDE")
Private oStsAl	:= LoadBitmap( nil, "BR_LARANJA")
Private oStsEr	:= LoadBitmap( nil, "BR_VERMELHO")
Private oStsBr	:= LoadBitmap( nil, "BR_BRANCO")
Private oStsIn	:= LoadBitmap( nil, "BR_PRETO")

//Criação dos arrays dos dados das integrações e Dos logs de erros
For i:=1 to Len(aRefArq)
	&("a"+aRefArq[i][1]) := {}
	&("aLog"+aRefArq[i][1]) := {}
Next i

//Cabeçalho dos Array de Erro.
NewCabLog()

//Verifica se o ambiente esta atualizado, caso não, não permite manutenção na interface
For i:=1 to Len(aRefArq)
	If !AmbAtu(GetCodInt(aRefArq[i][1],.T.)) 
		If lJob
			Conout("TPGEN001 - Ambiente não esta atualizado!")
			Return .F.
		Else
			MsgAlert("Ambiente incompatível com a rotina, será permitido apenas a visualização da interface!","HLB BRASIL")
			lonlyView := .T.
			Exit
		EndIf		
	EndIf
Next i

//Verifica se o ambiente esta atualizado, para as tabelas de LOG.
If !lonlyView .and. !AmbAtu(GetCodInt("LOG",.T.)) 
	If lJob
		Conout("TPGEN001 - Ambiente não esta atualizado!")
		Return .F.
	Else
		MsgAlert("Ambiente incompatível com a rotina, será permitido apenas a visualização da interface!","HLB BRASIL")
		lonlyView := .T.
	EndIf		
EndIf

//Ajusta os diretorios no server protheus
If !lonlyView .and. !AtuDirServer()
	Return .F.
EndIf
                               
//Busca os arquivos no Servidor FTP e coloca na pasta
If !lonlyView
	If MsgYesNo("Rotina de integração automática, deseja continuar?","HLB BRASIL")
		Processa({|| ManuArqFTP("GET") },"Carregando arquivos aguarde...")
		Processa({|| ManuArqFTP("PUT") },"Enviando arquivos aguarde...")
	Else
		Return .T.
	EndIf
EndIf

//Verifica se possui Arquivos de Log a Serem Processados
SaveRetLog()

//Chamada da interface grafica, somente quando não for JOB.
If !lJob
	Processa({|| MainGT() },"Processando aguarde...")
Else
	loadArq()
	SaveArq()
EndIf

Return .T.

*----------------------*
Static Function MainGT()
*----------------------*
Local i
Private oDlg
Private oLayer	:= FWLayer():new()
Private aSize 	:= MsAdvSize()

Private aLegenda := {{"BR_BRANCO"	,"Integração Disponivel."},;
			   	  	{"BR_PRETO"		,"Integração Inativa."}}
			   	  	
Private aLegenda2 := {{"BR_VERDE"  		,"Integração Disponivel."},;
						{"BR_VERMELHO"	,"Integração Indisponivel."}}

Private aLegenda3 := {{"BR_VERDE"  		,"Recebido retorno."},;
						{"BR_VERMELHO"	,"Recebido Retorno com Erro."},;
						{"BR_BRANCO"	,"Aguardando Retorno."}}
						
//Criação da tela principal da integração
oDlg := MSDialog():New( aSize[7],0,aSize[6],aSize[5],"HLB BRASIL",,,.F.,,,,,,.T.,,,.T. )
oLayer:Init(oDlg,.F.)

oLayer:addLine( '1', 100 , .F. )

oLayer:addCollumn('1',25,.F.,'1')
oLayer:addCollumn('2',75,.F.,'1')

oLayer:addWindow('1','Win11','Menu'					,015,.F.,.T.,{|| },'1',{|| })
oLayer:addWindow('1','Win12','Tipos de Integrações'	,045,.F.,.T.,{|| },'1',{|| })
oLayer:addWindow('1','Win13','Log'		   			,040,.F.,.T.,{|| },'1',{|| })

oLayer:addWindow('2','Win21','Vizualização'			,100,.F.,.T.,{|| },'1',{|| })


oWin11 := oLayer:getWinPanel('1','Win11','1')
oWin12 := oLayer:getWinPanel('1','Win12','1')
oWin13 := oLayer:getWinPanel('1','Win13','1')

oWin21 := oLayer:getWinPanel('2','Win21','1')

//Menu -----------------------------------------------------------------------------
oBtn1 := TBtnBmp2():New(02,0010,26,26,'FINAL'   	   	,,,,{|| oDlg:end()}											, oWin11,"Sair"	   		,,.T.)
If !lonlyView
	oBtn2 := TBtnBmp2():New(02,180,26,26,'PMSSETABOT'  	,,,,{|| ManuArqFTP("GET")}									, oWin11,"Download"		,,.T.)
	oBtn3 := TBtnBmp2():New(02,210,26,26,'PMSSETATOP'	,,,,{|| ManuArqFTP("PUT")}									, oWin11,"Upload"		,,.T.)
	oBtn4 := TBtnBmp2():New(02,240,26,26,'TK_REFRESH'   ,,,,{|| loadInt()}											, oWin11,"Carregar Arq"	,,.T.)
	oBtn5 := TBtnBmp2():New(02,270,26,26,'RPMSAVE'  	,,,,{|| Processa({|| SaveInt() },"Processando aguarde...")}	, oWin11,"Salvar Arq"	,,.T.)

	oBtn6 := TBtnBmp2():New(02,150,26,26,'FILTRO'   	,,,,{|| loadInt()}											, oWin11,"Filtro"		,,.T.)
	oBtn7 := TBtnBmp2():New(02,120,26,26,'SELECTALL'  	,,,,{|| MarcaButton()}	 									, oWin11,"Marca Todos"	,,.T.)
EndIf

//Tipos de Integrações -------------------------------------------------------------
aHeader := {}
aCols	:= {}
AADD(aHeader,{ TRIM("Sts.")			,"STS","@BMP",02,0,"","","C","",""})
AADD(aHeader,{ TRIM("Integração")	,"DES","@!  ",20,0,"","","C","",""})

aAlter	:= {"STS"}
aAdd(aCols, {oStsBr,"01. Clientes" 			,.F.})
aAdd(aCols, {oStsBr,"02. Sales Order"		,.F.})
aAdd(aCols, {oStsBr,"03. Campanha" 			,.F.})
aAdd(aCols, {oStsBr,"04. Invoice"			,.F.})
aAdd(aCols, {oStsBr,"05. Pagamentos"		,.F.})
aAdd(aCols, {oStsIn,"06. Status Invoice"	,.F.})
aAdd(aCols, {oStsIn,"07. Status Pagamentos" ,.F.})

oGetDados := MsNewGetDados():New(01,01,(oWin12:NHEIGHT/2)-2,(oWin12:NRIGHT/2)-2,GD_UPDATE,"AllwaysTrue()","AllwaysTrue()",;
									"", aAlter,, 99, "AllwaysTrue()", "AllwaysTrue()","AllwaysTrue()", oWin12,aHeader, aCols, {|| MudaLinha()})

oGetDados:AddAction("STS", {|| BrwLegenda("Tipos de Integrações", "Legenda", aLegenda),;
							oGetDados:Obrowse:ColPos -= 1,;
							oGetDados:aCols[oGetDados:Obrowse:nAt][oGetDados:Obrowse:ColPos+1] })
oGetDados:LCANEDITLINE	:= .F.//não possibilita troca de tipo de edição.
oGetDados:LEDITLINE		:= .F.//Não abre linha de edição de linha quando clicar na linha.
oGetDados:ForceRefresh()

//Log ------------------------------------------------------------------
aHLog := GetCodInt("LOG")
aCLog	:= {}
aALog	:= {}

oGetLog := MsNewGetDados():New(01,01,(oWin13:NHEIGHT/2)-2,(oWin13:NRIGHT/2)-2,GD_UPDATE,"AllwaysTrue()","AllwaysTrue()",;
									"", aALog,,9999, "AllwaysTrue()", "AllwaysTrue()","AllwaysTrue()", oWin13,aHLog, aCLog, {|| })
oGetLog:LCANEDITLINE	:= .F.//não possibilita troca de tipo de edição.
oGetLog:LEDITLINE		:= .F.//Não abre linha de edição de linha quando clicar na linha.
oGetLog:ForceRefresh()


//Vizualização -------------------------------------------------------------
For i:=1 to Len(aRefArq)
	&("aHArq"+aRefArq[i][1]) := {}
	&("aCArq"+aRefArq[i][1]) := {}
	&("aAArq"+aRefArq[i][1]) := {}

	&("aHArq"+aRefArq[i][1]) := GetCodInt(aRefArq[i][1])

	//Inicia aCols com linha em branco
	aAdd(&("aCArq"+aRefArq[i][1]),Array(Len(&("aHArq"+aRefArq[i][1]))+1))
	&("aCArq"+aRefArq[i][1])[1][LEN(&("aCArq"+aRefArq[i][1])[1])] := .F.

	&("oArq"+aRefArq[i][1]):=MsNewGetDados():New(01,02,(oWin21:NHEIGHT/2)-2,(oWin21:NRIGHT/2)-2,GD_UPDATE,"AllwaysTrue()","AllwaysTrue()",;
										"", &("aAArq"+aRefArq[i][1]),,9999999, "AllwaysTrue()", "AllwaysTrue()","AllwaysTrue()",;
										oWin21,&("aHArq"+aRefArq[i][1]), &("aCArq"+aRefArq[i][1]) )
	
	&("oArq"+aRefArq[i][1]):LCANEDITLINE	:= .F.//não possibilita troca de tipo de edição.
	&("oArq"+aRefArq[i][1]):LEDITLINE		:= .F.//Não abre edição quando clicar na linha.

	&("oArq"+aRefArq[i][1]):OBROWSE:LVISIBLECONTROL := .F.
	&("oArq"+aRefArq[i][1]):ForceRefresh()

	cArqView := ""
	oArqView := tMultiget():New(01,(((oWin21:NRIGHT/2))/4)+2,{|u|if(Pcount()>0,cArqView:=u,cArqView)},;
				oWin21,(oWin21:NRIGHT/2)-2,(oWin21:NHEIGHT/2)-2,,.T.,,,,.T.,,,,,,.T.,,,,,.T.)
	oArqView:LVISIBLECONTROL := .F.

Next i

oDlg:Activate(,,,.T.)

Return .T.

/*
Funcao      : MudaStatus()
Parametros  : 
Retorno     : cArqConte
Objetivos   : Função para mudar a imagem do primeiro campo, para selecionado ou não selecionado
Autor       : Jean Victor Rocha 
Data/Hora   : 
*/
*------------------------------*
Static Function MudaStatus(nNAT)
*------------------------------*
Local cArqConte
Local cValida := ""

Default nNAT := &("oArq"+aRefArq[oGetDados:NAT][1]):Obrowse:nAt

cArqConte := &("oArq"+aRefArq[oGetDados:NAT][1]):aCols[nNAT][&("oArq"+aRefArq[oGetDados:NAT][1]):Obrowse:ColPos]

If aRefArq[oGetDados:NAT][1] == "04"
	cValida := &("oArq"+aRefArq[oGetDados:NAT][1]):aCols[nNAT][aScan(&("aHArq"+aRefArq[oGetDados:NAT][1]),{|x|ALLTRIM(x[2])=="WK"+"F2_P_ARQ"})]
ElseIf aRefArq[oGetDados:NAT][1] == "05"
	cValida := &("oArq"+aRefArq[oGetDados:NAT][1]):aCols[nNAT][aScan(&("aHArq"+aRefArq[oGetDados:NAT][1]),{|x|ALLTRIM(x[2])=="WK"+"E1_P_ARQ"})]
ElseIf aRefArq[oGetDados:NAT][1] == "06" .or. aRefArq[oGetDados:NAT][1] == "07"
	cValida := &("oArq"+aRefArq[oGetDados:NAT][1]):aCols[nNAT][aScan(&("aHArq"+aRefArq[oGetDados:NAT][1]),{|x|ALLTRIM(x[2])=="MSG_LOG"})]
	If EMPTY(cValida)//Inverte validação
		cValida := "*"
	Else
		cValida := ""
	EndIf
EndIf

If EMPTY(cValida)
	If oSelS == cArqConte
		cArqConte := oSelN
	Else 
		cArqConte := oSelS
	Endif
Else
	MsgInfo("Seleção não permitida para o registro!","HLB BRASIL")
EndIf

Return(cArqConte)

/*
Funcao      : GetCodInt()
Parametros  : 
Retorno     : 
Objetivos   : Função para retornar a configuração de cada Integração.
Autor       : Jean Victor Rocha
Data/Hora   : 06/10/2014
*/
*-------------------------------------------*
Static Function GetCodInt(cTipoInt,lGetaCpos)
*-------------------------------------------*
Local i
Local aCpos := {}
Local aRet := {}

Default lGetaCpos := .F.

Do Case
	Case cTipoInt == '01'
		aCpos := {'A1_P_ID','A1_LOJA','A1_NOME','A1_NREDUZ','A1_TIPO','A1_END','A1_EST','A1_MUN','A1_COD_MUN',;
					'A1_BAIRRO','A1_CEP','A1_DDD','A1_TEL','A1_CGC','A1_INSCR','A1_CODPAIS','A1_EMAIL'}
		For i:=1 to Len(aCpos)
			SX3->(DbSetOrder(2))
			If SX3->(DbSeek(aCpos[i]))
				AADD(aRet,{ TRIM(SX3->X3_TITULO),"WK"+SX3->X3_CAMPO,;
								/*SX3->X3_PICTURE*/"",SX3->X3_TAMANHO,SX3->X3_DECIMAL,"","",SX3->X3_TIPO,"",""})
			Else
				AADD(aRet,{ TRIM(aCpos[i]),"WK"+SUBSTR(aCpos[i],AT("_",aCpos[i]),50),"",20,0,"","","C","",""})			
			EndIf
		Next i
		AADD(aRet,{ "Arquivo","ARQ_ORI","",40,0,"","","C","",""})

	Case cTipoInt == '02'
		aCpos := {'C5_EMISSAO','C5_P_NUM','C5_P_REF','C5_P_MOED','C5_TIPO','C5_TIPOCLI','C5_CONDPAG','C5_MENNOTA',;
					'C6_ITEM','C6_PRODUTO','C6_DESCRI','C6_QTDVEN','C6_PRCVEN','C6_VALOR','C6_TES','A1_CGC','A1_P_ID',;
					'C6_P_NOME','C6_P_NREDUZ','C6_P_TIPO','C6_P_END','C6_P_EST','C6_P_MUN','C6_P_MUN','C6_P_BAIRRO',;
					'C6_P_CEP','C6_P_INSCR','C6_P_CODPAIS','C6_P_DDD','C6_P_TEL','C6_P_AGEN'}
		For i:=1 to Len(aCpos)
			SX3->(DbSetOrder(2))
			If SX3->(DbSeek(aCpos[i]))
				AADD(aRet,{ TRIM(SX3->X3_TITULO),"WK"+SX3->X3_CAMPO,;
								/*SX3->X3_PICTURE*/"",SX3->X3_TAMANHO,SX3->X3_DECIMAL,"","",SX3->X3_TIPO,"",""})
			Else
				AADD(aRet,{ TRIM(aCpos[i]),"WK"+SUBSTR(aCpos[i],AT("_",aCpos[i]),50),"",20,0,"","","C","",""})			
			EndIf
		Next i
		AADD(aRet,{ "Arquivo","ARQ_ORI","",40,0,"","","C","",""})
		
	Case cTipoInt == '03'
		aCpos := {'C5_EMISSAO','C5_P_NUM','C5_P_REF','C6_PRODUTO','C5_P_MOED','C6_VALOR','ZX1_ID','ZX1_NAME','ZX1_NAMEF','ZX1_MOED','ZX1_VALOR'}
		For i:=1 to Len(aCpos)
			SX3->(DbSetOrder(2))
			If SX3->(DbSeek(aCpos[i]))
				AADD(aRet,{ TRIM(SX3->X3_TITULO),"WK"+SX3->X3_CAMPO,;
								/*SX3->X3_PICTURE*/"",SX3->X3_TAMANHO,SX3->X3_DECIMAL,"","",SX3->X3_TIPO,"",""})
			Else
				AADD(aRet,{ TRIM(aCpos[i]),"WK"+SUBSTR(aCpos[i],AT("_",aCpos[i]),50),"",20,0,"","","C","",""})			
			EndIf
		Next i
		AADD(aRet,{ "Arquivo","ARQ_ORI","",40,0,"","","C","",""})

	Case cTipoInt == '04'
		AADD(aRet,{ TRIM("Sel."),"SEL","@BMP",02,0,"","","C","",""})
		AADD(aRet,{ TRIM("Sts."),"STS","@BMP",02,0,"","","C","",""})
		
		SX3->(DbSetOrder(2))
		If SX3->(DbSeek("F2_P_NUM"))
			AADD(aRet,{ TRIM(SX3->X3_TITULO),"WK"+SX3->X3_CAMPO,;
					SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"","",SX3->X3_TIPO,"",""})
			aAdd(aCpos,SX3->X3_CAMPO)
		EndIf

		SX3->(DbSetOrder(1))
		SX3->(DbSeek("SF2"))
		While SX3->(!EOF()) .and. SX3->X3_ARQUIVO == "SF2"
			If SX3->X3_BROWSE == "S" .AND. !(ALLTRIM(SX3->X3_CAMPO) $ "F2_USERLGI/F2_USERLGA/F2_P_NUM")
				AADD(aRet,{ TRIM(SX3->X3_TITULO),"WK"+SX3->X3_CAMPO,;
						SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"","",SX3->X3_TIPO,"",""})
				aAdd(aCpos,SX3->X3_CAMPO)
			EndIf
			SX3->(DbSkip())
		EndDo
		AADD(aRet,{ "Recno","R_E_C_N_O_","",10,0,"","","N","",""})

	Case cTipoInt == '06'
		AADD(aRet,{ TRIM("Sel."),"SEL","@BMP",02,0,"","","C","",""})
		AADD(aRet,{ TRIM("Sts."),"STS","@BMP",02,0,"","","C","",""})
		
		SX3->(DbSetOrder(2))
		If SX3->(DbSeek("D2_P_NUM"))
			AADD(aRet,{ TRIM(SX3->X3_TITULO),"WK"+SX3->X3_CAMPO,;
					SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"","",SX3->X3_TIPO,"",""})
			aAdd(aCpos,SX3->X3_CAMPO)
		EndIf

		SX3->(DbSetOrder(1))
		SX3->(DbSeek("SD2"))
		While SX3->(!EOF()) .and. SX3->X3_ARQUIVO == "SD2"
			If SX3->X3_BROWSE == "S" .AND. !(ALLTRIM(SX3->X3_CAMPO) $ "D2_USERLGI/D2_USERLGA/D2_P_NUM")
				AADD(aRet,{ TRIM(SX3->X3_TITULO),"WK"+SX3->X3_CAMPO,;
						SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"","",SX3->X3_TIPO,"",""})
				aAdd(aCpos,SX3->X3_CAMPO)
			EndIf
			SX3->(DbSkip())
		EndDo
		AADD(aRet,{ "Recno","R_E_C_N_O_","",10,0,"","","N","",""})
		AADD(aRet,{ "Arquivo","ARQ_ORI","",040,0,"","","C","",""})
		AADD(aRet,{ "Arq. Log","ARQ_LOG","",040,0,"","","C","",""})
		AADD(aRet,{ "Msg. Log","MSG_LOG","",240,0,"","","C","",""})

	Case cTipoInt == '05' .or. cTipoInt == '07'
		AADD(aRet,{ TRIM("Sel."),"SEL","@BMP",02,0,"","","C","",""})
		AADD(aRet,{ TRIM("Sts."),"STS","@BMP",02,0,"","","C","",""})
				
		SX3->(DbSetOrder(2))
		If SX3->(DbSeek("E1_P_NUM"))
			AADD(aRet,{ TRIM(SX3->X3_TITULO),"WK"+SX3->X3_CAMPO,;
					SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"","",SX3->X3_TIPO,"",""})
			aAdd(aCpos,SX3->X3_CAMPO)
		EndIf
		
		SX3->(DbSetOrder(1))
		SX3->(DbSeek("SE1"))
		While SX3->(!EOF()) .and. SX3->X3_ARQUIVO == "SE1"
			If SX3->X3_BROWSE == "S" .AND. !(SX3->X3_CAMPO $ "E1_USERLGI/E1_USERLGA/E1_P_NUM")
				AADD(aRet,{ TRIM(SX3->X3_TITULO),"WK"+SX3->X3_CAMPO,;
						SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"","",SX3->X3_TIPO,"",""})
				aAdd(aCpos,SX3->X3_CAMPO)
			EndIf
			SX3->(DbSkip())
		EndDo
		AADD(aRet,{ "Recno","R_E_C_N_O_","",10,0,"","","N","",""})
		If cTipoInt == '07'
			AADD(aRet,{ "Arquivo","ARQ_ORI","",040,0,"","","C","",""})
			AADD(aRet,{ "Arq. Log","ARQ_LOG","",040,0,"","","C","",""})
			AADD(aRet,{ "Msg. Log","MSG_LOG","",240,0,"","","C","",""})
		EndIf

	Case cTipoInt == 'LOG'
		aCpos := {"ZX2_COD","ZX2_DATA","ZX2_HORA","ZX2_ARQ","ZX2_USER"}
		For i:=1 to Len(aCpos)
			SX3->(DbSetOrder(2))
			If SX3->(DbSeek(aCpos[i]))
				AADD(aRet,{ TRIM(SX3->X3_TITULO),"WK"+SX3->X3_CAMPO,;
								SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"","",SX3->X3_TIPO,"",""})
			Else
				AADD(aRet,{ TRIM(aCpos[i]),"WK"+SUBSTR(aCpos[i],AT("_",aCpos[i]),50),"",20,0,"","","C","",""})			
			EndIf
		Next i	

EndCase

If lGetaCpos
	aRet := aCpos
EndIf

Return aRet

/*
Funcao	    : VisuDOC()
Parametros  : 
Retorno     : 
Objetivos   : Visualiza o Documento de Saida.
Autor       : Jean Victor Rocha 
Data/Hora   : 
*/
*-----------------------*
Static function VisuDOC()
*-----------------------*
Local nRec := 0
Local nNAT := &("oArq"+aRefArq[oGetDados:NAT][1]):NAT
Local nCol := &("oArq"+aRefArq[oGetDados:NAT][1]):Obrowse:ColPos
Local nPos := 0

//Se não for integraçaõ de Invoice não executa
If aRefArq[oGetDados:NAT][1] == "04" .or. aRefArq[oGetDados:NAT][1] == "06"
	//Tratamento para Chamar os Campos Editaveis.
	If &("oArq"+aRefArq[oGetDados:NAT][1]):oBrowse:ColPos == aScan(&("aHArq"+aRefArq[oGetDados:NAT][1]), {|x| ALLTRIM(x[2]) == "SEL" }) 
		&("oArq"+aRefArq[oGetDados:NAT][1]):aCols[nNAT][nCol] := MudaStatus(nNAT)
		Return .T.

	ElseIf &("oArq"+aRefArq[oGetDados:NAT][1]):oBrowse:ColPos == aScan(&("aHArq"+aRefArq[oGetDados:NAT][1]), {|x| ALLTRIM(x[2]) == "STS" })
		BrwLegenda("Tipos de Integrações", "Legenda", aLegenda3)
		Return .T.

	EndIf
	
	//Retorna o Recno do SF2 para visualização
	If (nPos := aScan(&("aHArq"+aRefArq[oGetDados:NAT][1]), {|x| ALLTRIM(x[2]) == "R_E_C_N_O_" })   ) <> 0
		nRec := &("oArq"+aRefArq[oGetDados:NAT][1]):ACOLS[nNAT][nPos]
	EndIf
	
	If nRec <> 0
		SF2->(DbSetOrder(1))
		SF2->(DbGoTo(nRec))
		Mc090Visual("SF2",nRec, 1 )
	Else
		MsgInfo("Não foi possivel visualizar o Documento de Saida!","HLB BRASIL")
	EndIf

ElseIf aRefArq[oGetDados:NAT][1] == "05" .or. aRefArq[oGetDados:NAT][1] == "07"
	//Tratamento para Chamar os Campos Editaveis.
	If &("oArq"+aRefArq[oGetDados:NAT][1]):oBrowse:ColPos == aScan(&("aHArq"+aRefArq[oGetDados:NAT][1]), {|x| ALLTRIM(x[2]) == "SEL" }) 
		&("oArq"+aRefArq[oGetDados:NAT][1]):aCols[nNAT][nCol] := MudaStatus(nNAT)
		Return .T.

	ElseIf &("oArq"+aRefArq[oGetDados:NAT][1]):oBrowse:ColPos == aScan(&("aHArq"+aRefArq[oGetDados:NAT][1]), {|x| ALLTRIM(x[2]) == "STS" })
		BrwLegenda("Tipos de Integrações", "Legenda", aLegenda3)
		Return .T.

	EndIf
	
EndIf

Return .T.

/*
Funcao	    : MudaLinha()
Parametros  : 
Retorno     : 
Objetivos   : Atualiza o Browse de acordo com o Layout posicionado
Autor       : Jean Victor Rocha 
Data/Hora   : 
*/
*-------------------------*
Static function MudaLinha()
*-------------------------*
Local aCposLog := GetCodInt("LOG",.T.)

//Atualiza o Tipo de edição para a integração de Invoice.
oArq04:OBROWSE:BLDBLCLICK := {|| VisuDOC()}
oArq05:OBROWSE:BLDBLCLICK := {|| VisuDOC()}
oArq06:OBROWSE:BLDBLCLICK := {|| VisuDOC()}
oArq07:OBROWSE:BLDBLCLICK := {|| VisuDOC()}

//Atualiza a Visualizações
oArqView:LVISIBLECONTROL := .F.
oBtn6:LVISIBLECONTROL := aRefArq[oGetDados:NAT][1]$"04/05/06/07"
oBtn7:LVISIBLECONTROL := aRefArq[oGetDados:NAT][1]$"04/05/06/07"

//Troca o Browse de arquivos ---------------------------------
For i:=1 to len(aRefArq)
	&("oArq"+aRefArq[i][1]):OBROWSE:LVISIBLECONTROL := .F.
Next i
&("oArq"+aRefArq[oGetDados:NAT][1]):OBROWSE:LVISIBLECONTROL := .T.

//Atualiza o Browse de Log de arquivos
oGetLog:ACOLS := {}

ZX2->(DbSetOrder(2))
If ZX2->(DbSeek(xFilial("ZX2")+aRefArq[oGetDados:NAT][2],.T.))
	While ZX2->(!EOF()) .and. AT(aRefArq[oGetDados:NAT][2],ZX2->ZX2_ARQ) <> 0
		aAux := {}
		For i:=1 to Len(aCposLog)
			If ZX2->(FieldPos(aCposLog[i])) <> 0
				aAdd(aAux, &("ZX2->"+aCposLog[i]) )
			EndIf
		Next i
		aAdd(aAux,.F.)
		aAdd(oGetLog:ACOLS,aAux)

		ZX2->(DbSkip())
	EndDo
EndIf
oGetLog:FORCEREFRESH()

Return .T.

/*
Funcao      : ManuArqFTP()  
Parametros  : cOpc *
Retorno     : Nil
Objetivos   : Função responsavel por manipular os arquivos no FTP.
Autor       : Jean Victor Rocha
Data/Hora   : 
* ATENÇÃO:
Get - Efetua o Download dos arquivos do FTP	; ou seja, Pegamos na Pasta de saida do Cliente e colocamos na Nossa pasta de entrada.
Put - Efetua o Upload dos arquivos no FTP	; ou seja, Pegamos na nossa Pasta de Saida e colocamos na pasta de entrada do cliente.
*/
*------------------------------*
Static Function ManuArqFTP(cOpc)
*------------------------------*
Local i
Local cDirFtp		:= ""
Local cDirServ		:= ""
Local cFtp			:= Alltrim(GetMV("MV_P_FTP" ,, ''))
Local cLogin		:= Alltrim(GetMV("MV_P_USR" ,, ''))
Local cPass			:= Alltrim(GetMV("MV_P_PSW" ,, ''))
Local aArqFTP		:= {}
Local aArqFTPDel	:= {}
Local aArqServer	:= {}

//Definição do Tipo de atualização que sera feita. (Upload ou Download)
Do Case
	Case cOpc == "GET"
		cDirServ	:= "\FTP\"+cEmpAnt+"\TPGEN001\IN"
		cDirFtp		:= "/outbound"	
	Case cOpc == "PUT"
		cDirServ	:= "\FTP\"+cEmpAnt+"\TPGEN001\OUT"
		cDirFtp		:= "/inbound"
EndCase          

//Carrega arquivos do Servidor Protheus
aArqServer	:= DIRECTORY(cDirServ+"\*.CSV",,,.F.)

Do Case
	Case cOpc == "GET"
		//Efetua o Download do Arquivo do SFTP para pasta INTSFTP.
		EnvFtps({},cOpc,cDirServ,cDirFtp,cFtp,cLogin,cPass)	
		
		//Carregar os arquivos que foram baixados do SFTP
		aArqFTP := DIRECTORY(cDirServ+"\intsftp\*.CSV",,,.F.)
		
		//Compata arquivos atuais na pasta IN somente se tiver um novo no SFTP.
		If Len(aArqFTP) <> 0
			For i:=1 to Len(aArqServer)
				//If aScan(aArqFTP, {|x| LEFT(x[1],LEN(SUBSTR(aArqServer[i][1],1,AT("OB_",aArqServer[i][1])+2))) == SUBSTR(aArqServer[i][1],1,AT("OB_",aArqServer[i][1])+2) }) <> 0
				//If aScan(aArqFTP, {|x| x[1] == aArqServer [i][1] })  <> 0
					compacta(cDirServ+"\"+aArqServer[i][1],cDirServ+"\BKP_"+STRZERO(Year(Date()),4)+STRZERO(Month(Date()),2)+"."+cExtZip)
				//EndIf
			Next i
		EndIf
        
		//Efetua a cópia do Arquivo da pasta INTSFTP para a pasta IN.
		For i:=1 to Len(aArqFTP)
			//Validação de arquivo não existente na pasta IN
			If File(cDirServ+"\"+aArqFTP[i][1])
				FErase(cDirServ+"\"+aArqFTP[i][1])
			EndIf
			 
			//Copia para a pasta IN
			If fRename(cDirServ + "\intsftp\" + aArqFTP[i][1], cDirServ + "\" + aArqFTP[i][1]) >= 0
				Aadd(aArqFTPDel,aArqFTP[i][1])
			EndIf
		Next i
		//Deletar arquivo do SFTP
		If Len(aArqFTPDel)>0
			EnvFtps(aArqFTPDel,"DEL",cDirServ,cDirFtp,cFtp,cLogin,cPass)
		EndIf

	Case cOpc == "PUT"
		//Efetua o Upload do Arquivo do Server para o FTP.
		EnvFtps(aArqServer,cOpc,cDirServ,cDirFtp,cFtp,cLogin,cPass)
		For i:=1 to Len(aArqServer)
			If RIGHT(aArqServer[i][1],3) <> cExtZip
				compacta(cDirServ+"\"+aArqServer[i][1],cDirServ+"\BKP_"+STRZERO(Year(Date()),4)+STRZERO(Month(Date()),2)+"."+cExtZip)
			EndIf
		Next i

EndCase

Return .T.

/*
Funcao      : AtuDirServer
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Funcão para Ajustar os diretorios no server protheus
Autor       : Jean Victor Rocha
Data/Hora   : 
Obs         :
*/          
*----------------------------*
Static Function AtuDirServer()
*----------------------------*
Local i
Local lRet		:= .T.
Local cAux		:= ""
Local cAux2		:= ""
Local cDirSrv	:= ""

//Ajusta o Diretorio de Entrada e Saida no Protheus
For i:=1 to 2
	If i == 1
		cDirSrv := cDirSrvIn
	Else 
		cDirSrv := cDirSrvOut
	EndIf

	If !ExistDir(cDirSrv)
		cAux := ALLTRIM(cDirSrv)
		cAux := Left(cDirSrv,AT("\",RIGHT(cDirSrv,LEN(cDirSrv)-1)))
		While cAux <>  cDirSrv
			If !ExistDir(cAux)
				MakeDir(cAux)
			EndIf
			cAux2:= SUBSTR(cDirSrv,LEN(cAux)+1,Len(cDirSrv))
			cAux += Left(cAux2,IF(AT("\",RIGHT(cAux2,LEN(cAux2)-1))==0,LEN(cAux2),AT("\",RIGHT(cAux2,LEN(cAux2)-1)))  )
		EndDo
		If !ExistDir(cAux)
			MakeDir(cAux)
		EndIf
	EndIf
Next i

If !ExistDir(cDirSrvIn) .and. !ExistDir(cDirSrvOut)
	If lJob
		Conout("TPGEN001 - Falha ao carregar diretórios FTP no Servidor!")
	Else
		MsgInfo("Falha ao carregar diretórios FTP no Servidor!","HLB BRASIL")
	EndIf
	lRet := .F.
EndIf

Return lRet

/*
Funcao      : compacta
Parametros  : cArquivo,cArqRar
Retorno     : lRet
Objetivos   : Função para compactar arquivo
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*--------------------------------------------------*
Static Function compacta(cArquivo,cArqRar,lApagaOri)
*--------------------------------------------------*
Local lRet		:=.F.
Local cRootPath	:=GetSrvProfString("RootPath", "\undefined")//retorna o caminho do rootpath
Local cCommand 	:= ""
Local lWait  	:= .T.
//Local cPath     := "C:\Program Files (x86)\WinRAR\"
Local cPath     := "C:\Program Files\WinRAR\"

Default lApagaOri := .T.

If lApagaOri
//	cCommand 	:= 'C:\Program Files (x86)\WinRAR\WinRAR.exe m -ep1 -o+ "'+cRootPath+cArqRar+'" "'+cRootPath+cArquivo+'"'
	cCommand 	:= 'C:\Program Files\WinRAR\WinRAR.exe m -ep1 -o+ "'+cRootPath+cArqRar+'" "'+cRootPath+cArquivo+'"'
Else
//	cCommand 	:= 'C:\Program Files (x86)\WinRAR\WinRAR.exe a -ep1 -o+ "'+cRootPath+cArqRar+'" "'+cRootPath+cArquivo+'"'
	cCommand 	:= 'C:\Program Files\WinRAR\WinRAR.exe a -ep1 -o+ "'+cRootPath+cArqRar+'" "'+cRootPath+cArquivo+'"'
EndIf
lRet := WaitRunSrv( cCommand , lWait , cPath )

Return(lRet)

/*
Funcao      : AmbAtu
Parametros  : 
Retorno     :
Objetivos   : Função para verificar se o ambiente esta atualizado como deveria, campos customizados.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*---------------------------*
Static Function AmbAtu(aCpos)
*---------------------------*
Local lRet := .T.
Local i

SX3->(DbSetOrder(2))//X3_CAMPO
For i:=1 to Len(aCpos)
	If !(lRet := SX3->(DbSeek(aCpos[i])))
		Exit
	EndIf
Next i

Return lRet

/*
Funcao      : LoadInt
Parametros  : 
Retorno     :
Objetivos   : Função para Carregar uma nova integração.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*-----------------------*
Static Function LoadInt()
*-----------------------*
Local i,j
Local nPos := 0
Local aArquivo := {}
Local cLinha := ""
Local cDirSrvAtu := cDirSrvIn
Local aArqServer := {}
Local cTipoInt := ""

Local oFT   := fT():New()//FUNCAO GENERICA

//Executa a limpeza da variavel com os dados e da tela, caso não for Job.
For i:=1 to Len(aRefArq)
	&("a"+aRefArq[i][1]) := {}
	&("oArq"+aRefArq[i][1]):ACOLS := {}
	aAdd(&("aCArq"+aRefArq[i][1]),Array(Len(&("aHArq"+aRefArq[i][1]))+1))
	&("aCArq"+aRefArq[i][1])[1][LEN(&("aCArq"+aRefArq[i][1])[1])] := .F.
	&("oArq"+aRefArq[i][1]):ForceRefresh()
Next i

//Carrega arquivos do Servidor Protheus
aArqServer	:= DIRECTORY(cDirSrvAtu+"\*.CSV",)

//Carrega as Infromações do Arquivo.
If lJob
	cTipoInt := "IN"
Else
	cTipoInt := aRefArq[oGetDados:NAT][4]
EndIf

If cTipoInt == "IN"
	For i:=1 to len(aArqServer)
		aArquivo := {}

		//Leitura do arquivo de tratamento.
		oFT:FT_FUse(cDirSrvAtu+"\"+aArqServer[i][1])
		While !oFT:FT_FEof()
			cLinha := oFT:FT_FReadln()
			If AT(cDelimitador,cLinha) <> 0
				aAdd(aArquivo, separa(UPPER(cLinha),cDelimitador))// Sepera para vetor e adiciona no array de arquivo.
			EndIf                          
			aAdd(aArquivo[Len(aArquivo)],aArqServer[i][1])
	        oFT:FT_FSkip() // Proxima linha
		Enddo
		oFT:FT_FUse() // Fecha o arquivo 

		//Carrega as Informações da Variavel de destino
		If (nPos := aScan(aRefArq, {|x| ALLTRIM(x[2]) == ALLTRIM(SUBSTR(aArqServer[i][1],1,AT("OB_",aArqServer[i][1])+2)) } )  ) <> 0
			If LEN(&("a"+aRefArq[nPos][1])) == 0
				&("a"+aRefArq[nPos][1]) := aArquivo
			Else
				If LEN(aArquivo) > 2
					For j:=3 to Len(aArquivo)
						aAdd(&("a"+aRefArq[nPos][1]),aArquivo[j])
					Next j
				EndIf
			EndIf
		EndIf
	Next i
	//Caso não for Job, carrega para a tela os dados.
	If !lJob
		//Executa para cada Integração
		For i:=1 to len(aRefArq)
			//Executa somente se tiver dados no array
			//If LEN(&("a"+aRefArq[i][1])) <> 0
				//Verifica se existe quantidade de linhas maior que somente os Titulos dos campos.
				If Len(&("a"+aRefArq[i][1])) >= 3
					//Reseta os dados da Tela, ACOLS.
					&("oArq"+aRefArq[i][1]):ACOLS := {}
	
					//Executa para cada linha do arquivo, iniciando o For nos dados
					For j:=3 to len(&("a"+aRefArq[i][1]))
						//Adiciona uma nova linha no Acols.
						aAdd(&("oArq"+aRefArq[i][1]):ACOLS,Array(Len(&("aHArq"+aRefArq[i][1]))+1))
	   					&("oArq"+aRefArq[i][1]):ACOLS[LEN(&("oArq"+aRefArq[i][1]):ACOLS)][LEN(&("oArq"+aRefArq[i][1]):ACOLS[1])] := .F.
						
						//Executa para cada campo enviado no arquivo.
						For h:=1 to len(&("a"+aRefArq[i][1])[2])
							//Caso o campo informado no arquivo exista na tela, preenche, caso contrario não.
							If (nPos := aScan(&("aHArq"+aRefArq[i][1]), {|x| ALLTRIM(x[2]) == ALLTRIM("WK"+&("a"+aRefArq[i][1])[2][h]) })   ) <> 0
								&("oArq"+aRefArq[i][1]):ACOLS[LEN(&("oArq"+aRefArq[i][1]):ACOLS)][nPos] := &("a"+aRefArq[i][1])[j][h]
							EndIf
						Next h
						If aScan(&("aHArq"+aRefArq[i][1]),{|x|x[2]=="ARQ_ORI" }) <> 0
							&("oArq"+aRefArq[i][1]):ACOLS[LEN(&("oArq"+aRefArq[i][1]):ACOLS)][aScan(&("aHArq"+aRefArq[i][1]),{|x|x[2]=="ARQ_ORI" })] := &("a"+aRefArq[i][1])[j][LEN(&("a"+aRefArq[i][1])[j])]
						EndIf
					Next j
				EndIf
			//EndIf
			&("oArq"+aRefArq[i][1]):ForceRefresh()
		Next i
	EndIf
		
Else
	//Carregar informações da Tela para exportação dos arquivos.
	If aRefArq[oGetDados:NAT][1] == "04"//Invoice
		If !FilInt()
			Return .F.
		EndIf
		&("oArq"+aRefArq[oGetDados:NAT][1]):ACOLS := GetInv()
		&("oArq"+aRefArq[oGetDados:NAT][1]):ForceRefresh()

	ElseIf aRefArq[oGetDados:NAT][1] == "05"//Pagamentos
		If !FilInt()
			Return .F.
		EndIf
		&("oArq"+aRefArq[oGetDados:NAT][1]):ACOLS := GetPag()
		&("oArq"+aRefArq[oGetDados:NAT][1]):ForceRefresh()

	ElseIf aRefArq[oGetDados:NAT][1] == "06"//Log Invoice
		If !FilInt()
			Return .F.
		EndIf
		&("oArq"+aRefArq[oGetDados:NAT][1]):ACOLS := GetLogInv()
		&("oArq"+aRefArq[oGetDados:NAT][1]):ForceRefresh()

	ElseIf aRefArq[oGetDados:NAT][1] == "07"//Log Pagamentos
		If !FilInt()
			Return .F.
		EndIf
		&("oArq"+aRefArq[oGetDados:NAT][1]):ACOLS := GetLogPag()
		&("oArq"+aRefArq[oGetDados:NAT][1]):ForceRefresh()

	EndIf
EndIf

Return .T.

/*
Funcao      : SaveInt
Parametros  : 
Retorno     :
Objetivos   : Função para Carregar uma nova integração.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*-----------------------*
Static Function SaveInt()
*-----------------------*
Local i,j
Local cTipoInt := "IN"
Local cMsgPerg := ""
Local aArquivos := {}

//Zera os arquivos de LOG.
NewCabLog()

//Controla o Tipo de Integração que sera realizada
If !lJob
	cTipoInt := aRefArq[oGetDados:NAT][4]
EndIf

//Verifica se o usuario tem certeza de gravar todos os arquivos.
If cTipoInt == "IN"  
	cMsgPerg := "Será importado os arquivos de Clientes, Pedidos de Vendas e Campanhas, Deseja Continuar?"
Else
	cMsgPerg := "Será processado o arquivo exibido em Tela apenas para os registros selecionados, Deseja Continuar?"
EndIf

If !lJob .And. !MsgYesNo(cMsgPerg,"HLB BRASIL")
	Return .F.
EndIf

//Zera controle Global da posição
nNATAtu := 0

//Define a Barra de Processamento
ProcRegua(LEN(aRefArq))

//Grava os Dados de Integração.
If lJob
	For i:=1 to len(aRefArq)
		If aRefArq[i][4] == "IN"
			//Executa somente se tiver dados no array
			If LEN(&("a"+aRefArq[i][1])) <> 0
				If Len(&("a"+aRefArq[i][1])[2]) >= 3
					If !ViewZX2(&("a"+aRefArq[i][1])[1])
						nNATAtu := i
						Eval(aRefArq[i][3])
					EndIf
				EndIf
			EndIf
		EndIf
		IncProc("Aguarde...")
	Next i
Else
	cMsgProc := ""
	If cTipoInt == "IN"
		For i:=1 to len(aRefArq)
			If aRefArq[i][4] == cTipoInt
				cArqAtu := ""
				If Len(&("a"+aRefArq[i][1])) >= 3
			   		cMsgProc += SUBSTR(aRefArq[i][2],4,AT("OB",aRefArq[i][2])-5)+CHR(10)+CHR(13)
					aArquivos := GetNameArq(&("a"+aRefArq[i][1]),.F.)
					For j:=1 to Len(aArquivos)
						If ViewZX2(aArquivos[j])
							cMsgProc += " - "+ALLTRIM(aArquivos[j])+" - Arquivo ja processado anteriormente!"+CHR(10)+CHR(13)
						Else
							nNATAtu := i
							cArqAtu := ALLTRIM(aArquivos[j])
							Eval(aRefArq[i][3])
							cMsgProc += " - "+ALLTRIM(aArquivos[j])+" - Arquivo processado com sucesso!"+CHR(10)+CHR(13)
						EndIf
					Next j
				Else
					cMsgProc += SUBSTR(aRefArq[i][2],4,AT("OB",aRefArq[i][2])-5)+CHR(10)+CHR(13)
					cMsgProc += " - Sem dados a serem salvos para esta integração!"+CHR(10)+CHR(13)
				EndIf
			EndIf
			IncProc("Aguarde...")
		Next i
		
		//Gera Arquivo LOG fisico.
		For i:=1 to len(aRefArq)
			//Executa somente se tiver dados no array
			If LEN(&("aLog"+aRefArq[i][1])) > 2
				GeraLog(&("aLog"+aRefArq[i][1]) )
			EndIf
		Next i

	Else
		If aRefArq[oGetDados:NAT][1] == "04"//Invoice
			lMarcado := .F.
			//Verifica se possui registros selecionados ainda não processados.
			For j:=1 to Len(&("oArq"+aRefArq[oGetDados:NAT][1]):aCols)
				If &("oArq"+aRefArq[oGetDados:NAT][1]):aCols[j][aScan(&("aHArq"+aRefArq[oGetDados:NAT][1]),{|x|ALLTRIM(x[2])=="SEL"})] == oSelS .and.;
					EMPTY(&("oArq"+aRefArq[oGetDados:NAT][1]):aCols[j][aScan(&("aHArq"+aRefArq[oGetDados:NAT][1]),{|x|ALLTRIM(x[2])=="WK"+"F2_P_ARQ"})])
					lMarcado := .T.
					j:=Len(&("oArq"+aRefArq[oGetDados:NAT][1]):aCols)
				EndIf
			Next j
			
			If lMarcado
				GravaSF2(&("oArq"+aRefArq[oGetDados:NAT][1]):AHeader,&("oArq"+aRefArq[oGetDados:NAT][1]):aCols)
				cMsgProc += SUBSTR(aRefArq[oGetDados:NAT][2],4,AT("IB",aRefArq[oGetDados:NAT][2])-5)+;
													" - Processado com Sucesso!"+CHR(10)+CHR(13)
				LoadInt()
			Else
				cMsgProc += SUBSTR(aRefArq[oGetDados:NAT][2],4,AT("IB",aRefArq[oGetDados:NAT][2])-5)+;
													" - Selecione ao Menos um registro para a gravação!"+CHR(10)+CHR(13)
			EndIf

		ElseIf aRefArq[oGetDados:NAT][1] == "05"//Pagamentos
			lMarcado := .F.
			//Verifica se possui registros selecionados ainda não processados.
			For j:=1 to Len(&("oArq"+aRefArq[oGetDados:NAT][1]):aCols)
				If &("oArq"+aRefArq[oGetDados:NAT][1]):aCols[j][aScan(&("aHArq"+aRefArq[oGetDados:NAT][1]),{|x|ALLTRIM(x[2])=="SEL"})] == oSelS .and.;
					EMPTY(&("oArq"+aRefArq[oGetDados:NAT][1]):aCols[j][aScan(&("aHArq"+aRefArq[oGetDados:NAT][1]),{|x|ALLTRIM(x[2])=="WK"+"E1_P_ARQ"})])
					lMarcado := .T.
					j:=Len(&("oArq"+aRefArq[oGetDados:NAT][1]):aCols)
				EndIf
			Next j

			If lMarcado
				GravaSE1(&("oArq"+aRefArq[oGetDados:NAT][1]):AHeader,&("oArq"+aRefArq[oGetDados:NAT][1]):aCols)
				cMsgProc += SUBSTR(aRefArq[oGetDados:NAT][2],4,AT("IB",aRefArq[oGetDados:NAT][2])-5)+;
													" - Processado com Sucesso!"+CHR(10)+CHR(13)
				LoadInt()
			Else
				cMsgProc += SUBSTR(aRefArq[oGetDados:NAT][2],4,AT("IB",aRefArq[oGetDados:NAT][2])-5)+;
													" - Selecione ao Menos um registro para a gravação!"+CHR(10)+CHR(13)
			EndIf

		ElseIf aRefArq[oGetDados:NAT][1] == "06"//Log Invoice
			lMarcado := .F.
			//Verifica se possui registros selecionados ainda não processados.
			For j:=1 to Len(&("oArq"+aRefArq[oGetDados:NAT][1]):aCols)
				If &("oArq"+aRefArq[oGetDados:NAT][1]):aCols[j][aScan(&("aHArq"+aRefArq[oGetDados:NAT][1]),{|x|ALLTRIM(x[2])=="SEL"})] == oSelS
					lMarcado := .T.
					j:=Len(&("oArq"+aRefArq[oGetDados:NAT][1]):aCols)
				EndIf
			Next j
			
			If lMarcado
				If MsgYesNo("Essa gravação ira estornar o envio para os registros selecionados, deseja continuar?","HLB BRASIL")
					EstEnvio("SD2",&("oArq"+aRefArq[oGetDados:NAT][1]):aCols[&("oArq"+aRefArq[oGetDados:NAT][1]):NAT];
																			[aScan(&("aHArq"+aRefArq[oGetDados:NAT][1]),{|x|ALLTRIM(x[2])=="R_E_C_N_O_"})])
					cMsgProc += SUBSTR(aRefArq[oGetDados:NAT][2],4,AT("IB",aRefArq[oGetDados:NAT][2])-5)+;
														" - Processado com Sucesso!"+CHR(10)+CHR(13)
				EndIf
				LoadInt()
			Else
				cMsgProc += SUBSTR(aRefArq[oGetDados:NAT][2],4,AT("IB",aRefArq[oGetDados:NAT][2])-5)+;
													" - Selecione ao Menos um registro para a gravação!"+CHR(10)+CHR(13)
			EndIf

		EndIf

		//Executa somente se tiver dados no array
		If LEN(&("aLog"+aRefArq[oGetDados:NAT][1])) <> 0
			
			MailLog(&("aLog"+aRefArq[oGetDados:NAT][1])[1],&("aLog"+aRefArq[oGetDados:NAT][1]))
		EndIf
	EndIf
    
	ManuArqFTP("GET") 
	ManuArqFTP("PUT") 
    
	EECVIEW("Processamento Finalizado"+CHR(10)+CHR(13)+cMsgProc)
	//MsgInfo(cMsgProc,"HLB BRASIL")
EndIf

Return .T. 

/*
Funcao      : GeraLog
Parametros  : 
Retorno     :
Objetivos   : Função para a geração do arquivo de LOG na pasta Out do FTP no SERVER.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*----------------------------*
Static Function GeraLog(aInfo)
*----------------------------*
Local i,j,k
Local nHdl	:= 0
Local cLinha := ""
Local cArqLog := ""

Local aArquivos := GetNameArq(aInfo)

For k:=1 to Len(aArquivos)
	//Criação do nome do arquivo de LOG referente ao Arquivo.
	cArqLog := ""
	cArqLog += SUBSTR(aArquivos[k],1,AT("OB_",aArquivos[k])+2)
	cArqLog += "LOG"
	cArqLog += SubStr(aArquivos[k],AT("OB_",aArquivos[k])+2,Len(aArquivos[k]))
	cArqLog := UPPER(cArqLog)
	
	//Validação de arquivo não existente
	If File(cDirSrvOut+"\"+cArqLog)
		FErase(cDirSrvOut+"\"+cArqLog)
	EndIf
	
	nHdl := FCreate(cDirSrvOut+"\"+cArqLog,0,,.F. )
	cLinha := ""
	For j:=1 to Len(aInfo[1])
		cLinha += ALLTRIM(aInfo[1][j])+cDelimitador
	Next j
	cLinha := LEFT(cLinha,Len(cLinha)-1)
	FWrite(nHdl, cLinha+CHR(10))
	cLinha := ""
	For j:=1 to Len(aInfo[2])
		cLinha += ALLTRIM(aInfo[2][j])+cDelimitador
	Next j
	cLinha := LEFT(cLinha,Len(cLinha)-1)
	FWrite(nHdl, cLinha+CHR(10))
	
	For i:=3 to Len(aInfo)
		If ALLTRIM(aInfo[i][aScan(aInfo[2],{|x| ALLTRIM(UPPER(x)) == "FILE"})]) == ALLTRIM(aArquivos[k])
			cLinha := ""
			For j:=1 to Len(aInfo[i])
				cLinha += ALLTRIM(aInfo[i][j])+cDelimitador
			Next j
			cLinha := LEFT(cLinha,Len(cLinha)-1)
		
			FWrite(nHdl, cLinha+CHR(10))
		EndIf
	Next i
	FClose(nHdl)
	
	GrvTabLog(aArquivos[k] )
	
	MailLog(aArquivos[k],aInfo)
	
	//RRP - 04/10/2018 - Compactar os arquivos processados
	compacta(cDirSrvIn+"\"+aArquivos[k],cDirSrvIn+"\BKP_"+STRZERO(Year(Date()),4)+STRZERO(Month(Date()),2)+"."+cExtZip)	
	
Next k
	
Return .T.

/*
Funcao      : GrvTabLog
Parametros  : 
Retorno     :
Objetivos   : Função para a gravação da tabela de LOG.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*---------------------------------*
Static Function GrvTabLog(cNomeArq)
*---------------------------------*
ZX2->(DbSetOrder(1))
ZX2->(RecLock("ZX2",.T.))
ZX2->ZX2_FILIAL := xFilial("ZX2")
ZX2->ZX2_COD := STRZERO(ZX2->(Recno()),9)
ZX2->ZX2_ARQ := UPPER(cNomeArq)
ZX2->ZX2_DATA := Date()
ZX2->ZX2_HORA := Time()
ZX2->ZX2_USER := cUserName
ZX2->(MsUnlock())

Return .T.

/*
Funcao      : ViewZX2
Parametros  : 
Retorno     :
Objetivos   : Verifica se o arquivo ja consta no Log de processados.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*---------------------------*
Static Function ViewZX2(cArq)
*---------------------------*
Local lRet := .F.

If Select("QRY") > 0
	QRY->(DbClosearea())
Endif  

cQuery := " Select COUNT(*) AS COUNT"
cQuery += " From "+RETSQLNAME("ZX2")
cQuery += " Where ZX2_ARQ = '"+ALLTRIM(UPPER(cArq))+"'
cQuery += " 	AND D_E_L_E_T_ <> '*'

dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)

lRet := QRY->COUNT <> 0

Return lRet

/*
Funcao      : GravaSA1
Parametros  : 
Retorno     :
Objetivos   : Gravação dos Arquivos.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*------------------------*
Static Function GravaSA1()
*------------------------*
Local i,j
Local nPos		:= 0
Local aDados	:= &("a"+aRefArq[nNATAtu][1])
Local lErro		:= .F.
Local lCritErro	:= .F.
Local aCposObrg	:= {"A1_P_ID","A1_NOME","A1_CGC","A1_EST","A1_MUN","A1_COD_MUN","A1_EMAIL"}
Local aNotEmpty	:= {"A1_P_ID","A1_NOME","A1_CGC","A1_EST","A1_MUN","A1_COD_MUN"}
Local aLog		:= &("aLog"+aRefArq[nNATAtu][1])
Local nNumSeq	:= 0
Local cId		:= ""
Local cQuery	:= ""

Local nPosA1_P_ID	:= aScan(aDados[2], {|x| ALLTRIM(x) == "A1_P_ID" })
Local nPosA1_CGC	:= aScan(aDados[2], {|x| ALLTRIM(x) == "A1_CGC" })

Local aVetor	:= {}

PRIVATE lMsErroAuto := .F.

SA1->(DbSetOrder(1))

//Executa a partir do primeiro registro com informação.
For i:=3 to len(aDados)
	If ALLTRIM(aDados[i][LEN(aDados[i])]) == cArqAtu
		//Reset de controle de erro.
		lCritErro	:= .F.
		lErro		:= .F.
		nNumSeq		:= 0    
	    
		//Reset a alteração do cliente
		lAltSA1		:= .F.
		
		//Validações De estrutura
		For j:=1 to Len(aCposObrg)
			If (nPos := aScan(aDados[2], {|x| ALLTRIM(x) == ALLTRIM(aCposObrg[j]) })   ) == 0
				lCritErro := .T.
				nNumSeq++
				If aCposObrg[j] == "A1_P_ID"
					cId := ""
				Else
					cId := aDados[i][nPosA1_P_ID]
				EndIf			
				aAdd(aLog,{ALLTRIM(STR(nNumSeq)),cId,"","E","",aCposObrg[j],"","Critical Error - Field not Exist",aDados[i][Len(aDados[i])]})
			EndIf
		Next j
		
		//Validações de Dados.
		If !lCritErro
			//Campos que não podem estar vazios
			For j:=1 to Len(aNotEmpty)
				If (nPos := aScan(aDados[2], {|x| ALLTRIM(x) == ALLTRIM(aNotEmpty[j]) }) ) <> 0
					If EMPTY(aDados[i][nPos])
						If aDados[2][nPos] == "A1_COD_MUN"
							If aScan(aDados[2],{|x| ALLTRIM(x) == "A1_EST"}) <> 0 .and. aScan(aDados[2],{|x| ALLTRIM(x) == "A1_MUN"}) <> 0
								aDados[i][nPos] := GetCodMun(aDados[i][aScan(aDados[2],{|x| ALLTRIM(x)=="A1_EST"})],aDados[i][aScan(aDados[2],{|x|ALLTRIM(x)=="A1_MUN"})])
							EndIf
							
							If EMPTY(aDados[i][nPos])
								nNumSeq++
								nPos1:= aScan(aDados[2],{|x| ALLTRIM(x)=="A1_EST"})
								nPos2:= aScan(aDados[2],{|x| ALLTRIM(x)=="A1_MUN"})
						   		aAdd(aLog,{ALLTRIM(STR(nNumSeq)),aDados[i][nPosA1_P_ID],"","E",;
						   														aDados[1][nPos1]+"+"+aDados[1][nPos2],;
						   														aDados[2][nPos1]+"+"+aDados[2][nPos2],;
						   														aDados[i][nPos1]+"+"+aDados[i][nPos2],"Invalid Code",aDados[i][Len(aDados[i])]})
							EndIf
						Else
							nNumSeq++ 
							aAdd(aLog,{ALLTRIM(STR(nNumSeq)),aDados[i][nPosA1_P_ID],"","E",aDados[1][nPos],aDados[2][nPos],aDados[i][nPos],"This field is required",aDados[i][Len(aDados[i])]})
						EndIf
					EndIf
				EndIf
			Next i
	
			//Validação de Conteudo 
			//CGC
			If (nPos := aScan(aDados[2], {|x| ALLTRIM(x) == "A1_CGC" }) ) <> 0
				If !EMPTY(ALLTRIM(aDados[i][nPos]))
					For j:=1 to Len(ALLTRIM(aDados[i][nPos]))
						If ASC(SubStr(ALLTRIM(aDados[i][nPos]),j,1)) < 48 .Or. ASC(SubStr(ALLTRIM(aDados[i][nPos]),j,1)) > 57
							nNumSeq++ 
							aAdd(aLog,{ALLTRIM(STR(nNumSeq)),aDados[i][nPosA1_P_ID],"","E",aDados[1][nPos],aDados[2][nPos],aDados[i][nPos],"This field has invalid content",aDados[i][Len(aDados[i])]})
							Exit
						ElseIf !VldCPFeCNPJ(aDados[i][nPos])
							nNumSeq++ 
							aAdd(aLog,{ALLTRIM(STR(nNumSeq)),aDados[i][nPosA1_P_ID],"","E",aDados[1][nPos],aDados[2][nPos],aDados[i][nPos],"Invalid Number",aDados[i][Len(aDados[i])]})
							Exit
						EndIf
					Next j
				EndIf
			EndIf
			
			//Validação de Unico para ID do Cliente
			/*If nPosA1_P_ID <> 0
				If Len(ClieTw(aDados[i][nPosA1_P_ID],aDados[i][nPosA1_CGC])) <> 0
					nNumSeq++ 
					aAdd(aLog,{ALLTRIM(STR(nNumSeq)),aDados[i][nPosA1_P_ID],"","E",;
															aDados[1][nPosA1_P_ID]+"+"+aDados[1][nPosA1_CGC],;
															aDados[2][nPosA1_P_ID]+"+"+aDados[2][nPosA1_CGC],;
															aDados[i][nPosA1_P_ID]+"+"+aDados[i][nPosA1_CGC],"Duplicate information",aDados[i][Len(aDados[i])]})
				EndIf
			EndIf*/
	
		EndIf
		
		//Verifica se possui erro.
		lErro := nNumSeq <> 0
		
		//Gravação quando não foi encontrado erro.
		If !lErro
			//Tratamento para update ou Insert
			aCli := ClieTw(aDados[i][nPosA1_P_ID],aDados[i][nPosA1_CGC])
			If Len(aCli) <> 0
				cNewCod := aCli[1]
			Else
				//define um novo codigo para o Cliente.
				If Select("QRY") > 0
					QRY->(DbClosearea())
				Endif  
				cQuery := " Select MAX(A1_COD) AS NEWCOD"
				cQuery += " From "+RETSQLNAME("SA1")
				dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)
				cNewCod := SOMA1(QRY->NEWCOD)
			EndIf
			lInclui := Len(aCli) == 0
					
			//Criação do Array do ExecAuto
			aVetor := {}
			aAdd(aVetor,{"A1_COD",cNewCod,Nil})
			For j:=1 to Len(aDados[2])//Executa para todos os campos do Sistema.
				If LEFT(aDados[2][j],2) == "A1" .and. SA1->(FieldPos(aDados[2][j])) <> 0
					aAdd(aVetor,{aDados[2][j],aDados[i][j],Nil})
				EndIf
			Next j
			
			//Verifica se existe campos obrigatorios, caso não adiciona o padrão.
			If (nPos:=aScan(aVetor,{|x| ALLTRIM(x[1]) == "A1_TIPO"})  ) == 0
				aAdd(aVetor,{"A1_TIPO","F",Nil})
			Else
				If EMPTY(aVetor[nPos][2])
					aVetor[nPos][2] := "F"
				EndIf
			EndIf		
			If (nPos:=aScan(aVetor,{|x| ALLTRIM(x[1]) == "A1_CONTA"})  ) == 0
				aAdd(aVetor,{"A1_CONTA","11211001",Nil})
			Else
				If EMPTY(aVetor[nPos][2])
					aVetor[nPos][2] := "11211001"
				EndIf
			EndIf
			If (nPos:=aScan(aVetor,{|x| ALLTRIM(x[1]) == "A1_NATUREZ"})  ) == 0
				aAdd(aVetor,{"A1_NATUREZ","1000",Nil})
			Else
				If EMPTY(aVetor[nPos][2])
					aVetor[nPos][2] := "1000"
				EndIf
			EndIf
			If (nPos:=aScan(aVetor,{|x| ALLTRIM(x[1]) == "A1_CODPAIS"})  ) == 0
				aAdd(aVetor,{"A1_CODPAIS","01058",Nil})
			Else
				If EMPTY(aVetor[nPos][2]) .or. aVetor[nPos][2] == "BR"
					aVetor[nPos][2] := "01058"
				EndIf
			EndIf

			//Ajuste de caracteres invalidos.
			cAux := ""
			If (nPos:=aScan(aVetor,{|x| ALLTRIM(x[1]) == "A1_NOME"})  ) <> 0
				cAux := ConvString(aVetor[nPos][2])
				aVetor[nPos][2] := cAux
			EndIf
			If (nPos:=aScan(aVetor,{|x| ALLTRIM(x[1]) == "A1_NREDUZ"})  ) == 0
				aAdd(aVetor,{"A1_NREDUZ",cAux,Nil})
			Else
				aVetor[nPos][2] := cAux
			EndIf
			If (nPos:=aScan(aVetor,{|x| ALLTRIM(x[1]) == "A1_END"})  ) <> 0
				aVetor[nPos][2] := ConvString(aVetor[nPos][2])
			EndIf

            
			//MSM - 0704/2015 - Tratamento para posicionar o cliente que se vai alterar, pois estava alterando sempre o primeiro da tabela
			if !lInclui
				
				if len(aCli)>1
					
					DbSelectArea("SA1")
					SA1->(DbSetOrder(1))
					if DbSeek(xFilial("SA1")+aCli[1]+aCli[2])
						lAltSA1 := .T.
					endif
					
				endif
			endif
			
			if lInclui .OR. lAltSA1

				//ExecAuto
				MSExecAuto({|x,y| Mata030(x,y)},aVetor,IIF(lInclui,3,4)  ) //3- Inclusão, 4- Alteração, 5- Exclusão
			
			else
				lMsErroAuto	:= .T.
			endif
			
			//Tratamento de Erro
			If lMsErroAuto
				nNumSeq++ 
				cMsg := "CNPJ "+aDados[i][nPosA1_CGC]+" error in recording"
		   		aAdd(aLog,{ALLTRIM(STR(nNumSeq)),aDados[i][nPosA1_P_ID],"","E","","","",cMsg,aDados[i][Len(aDados[i])]})
			Else
				nNumSeq++ 
				cMsg := "ID "+aDados[i][nPosA1_P_ID]+" - CNPJ "+aDados[i][nPosA1_CGC]+" - Inserted / Updated successfully"
		  		aAdd(aLog,{ALLTRIM(STR(nNumSeq)),aDados[i][nPosA1_P_ID],cNewCod,"S","","","",cMsg,aDados[i][Len(aDados[i])]})
			Endif
		EndIf
	EndIf
Next i

&("aLog"+aRefArq[nNATAtu][1]) := aLog

Return .T. 

/*
Funcao      : GravaSC5
Parametros  : 
Retorno     :
Objetivos   : Gravação dos Arquivos.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*------------------------*
Static Function GravaSC5()
*------------------------*
Local i
Local aDados	:= &("a"+aRefArq[nNATAtu][1])
Local lErro		:= .F.
Local lCritErro	:= .F.
Local nPos		:= 0
Local nPos2		:= 0
Local nSeq := 0
Local cChave := ""

Local aCposObrg	:= {'C5_EMISSAO','C5_P_NUM','C5_P_REF','C5_P_MOED','C5_TIPO','C5_TIPOCLI','C5_CONDPAG',;
					'C5_MENNOTA','C6_ITEM','C6_PRODUTO','C6_DESCRI','C6_QTDVEN','C6_PRCVEN','C6_VALOR',;
					'C6_TES','A1_CGC','A1_P_ID','C5_P_NOME','C5_P_PESSOA','C5_P_NREDUZ','C5_P_END','C5_P_EST',;
					'C5_P_COD_MUN','C5_P_MUN','C5_P_BAIRRO','C5_P_CEP','C5_P_INSCR','C5_P_CODPAIS','C5_P_DD',;
					'C5_P_TEL','C5_P_AGEN'}
Local aNotEmpty	:= {'C5_EMISSAO','C6_P_NUM','C6_P_REF','C5_TIPO','C5_TIPOCLI','C5_CONDPAG',;
					'C6_ITEM','C6_PRODUTO','C6_QTDVEN','C6_PRCVEN','C6_VALOR','A1_P_ID'}
Local aLog		:= &("aLog"+aRefArq[nNATAtu][1])

//Posição dos campos que compoem a chave do arquivo.
Local nPosC5_EMISSAO	:=  aScan(aDados[2], {|x| ALLTRIM(x) == "C5_EMISSAO" })
Local nPosC5_P_NUM		:=  aScan(aDados[2], {|x| ALLTRIM(x) == "C5_P_NUM" })
Local nPosC6_P_REF		:=  aScan(aDados[2], {|x| ALLTRIM(x) == "C5_P_REF" })
Local nPosC6_PRODUTO	:=  aScan(aDados[2], {|x| ALLTRIM(x) == "C6_PRODUTO" })

//Variavel que ira possuir os dados de Capa e Itens
Local aCxI := {}
Local aCab := {}
Local aIte := {}
Local aCab2Ite := {}

Local aCxIAtrib := {}
Local nPosCxTr1:= 0
Local nPosCxTr2:= 0

Local aAux3	:= {}

Private lMsErroAuto:= .F.
Private lMSHelpAuto := .F.
Private lAutoErrNoFile := .T.

//Campos que serão retirados da capa e colocados nos itens
aCab2Ite := {"C5_P_REF","C5_P_NOME","C5_P_NREDUZ","C5_P_TIPO","C5_P_END","C5_P_EST","C5_P_MUN","C5_P_COD_MUN",;
			"C5_P_BAIRRO","C5_P_CEP","C5_P_DD","C5_P_TEL","C5_P_CGC","C5_P_INSCR","C5_P_CODPAIS",;
			"C5_P_AGEN","C5_P_PESSOA"}

For i:=1 to len(aDados[2])
	If aScan(aCab2Ite, {|x| ALLTRIM(x) == ALLTRIM(aDados[2][i])}) <> 0
		aDados[2][i] := STRTRAN(aDados[2][i],"C5_P_","C6_P_")
	EndIf
Next i
//Ajuste Tambem nos Campos Obrigatorios 
For i:=1 to len(aCposObrg)
	If aScan(aCab2Ite, {|x| ALLTRIM(x) == ALLTRIM(aCposObrg[i])}) <> 0
		aCposObrg[i] := STRTRAN(aCposObrg[i],"C5_P_","C6_P_")
	EndIf
Next i

//Definição dos Campos aCab e aIte
For i:=1 to len(aDados[2])
	If Left(aDados[2][i],3) == "C5_"
		aAdd(aCab,aDados[2][i])	
	ElseIf Left(aDados[2][i],3) == "C6_"
		aAdd(aIte,aDados[2][i])	
	EndIf
Next i

//Executa a partir do primeiro registro com informação.
For i:=3 to len(aDados)
	//Reset de controles de erros
	lErro		:= .F.

	//Validações De estrutura
	For j:=1 to Len(aCposObrg)
		If (nPos := aScan(aDados[2], {|x| ALLTRIM(x) == ALLTRIM(aCposObrg[j]) })   ) == 0
			lCritErro := .T.
			aAdd(aLog,{"",IIF(nPosC5_EMISSAO<>0,aDados[i][nPosC5_EMISSAO],""),;
						IIF(nPosC5_P_NUM<>0,aDados[i][nPosC5_P_NUM],""),;
						IIF(nPosC6_P_REF<>0,aDados[i][nPosC6_P_REF],""),;
						IIF(nPosC6_PRODUTO<>0,aDados[i][nPosC6_PRODUTO],""),;
						"","",aCposObrg[j],"","E","Critical Error - Field not Exist",aDados[i][Len(aDados[i])]})
		EndIf
	Next j
		
	//Validações de Dados.
	If !lCritErro
		//Campos que não podem estar vazios
		For j:=1 to Len(aNotEmpty)
			If (nPos := aScan(aDados[2], {|x| ALLTRIM(x) == ALLTRIM(aNotEmpty[j]) }) ) <> 0
				If EMPTY(aDados[i][nPos])
					aAdd(aLog,{"",IIF(nPosC5_EMISSAO<>0,aDados[i][nPosC5_EMISSAO],""),;
							IIF(nPosC5_P_NUM<>0,aDados[i][nPosC5_P_NUM],""),;
							IIF(nPosC6_P_REF<>0,aDados[i][nPosC6_P_REF],""),;
							IIF(nPosC6_PRODUTO<>0,aDados[i][nPosC6_PRODUTO],""),;
							"",aDados[1][nPos],aDados[2][nPos],"","E","This field is required",aDados[i][Len(aDados[i])]})
				EndIf
			EndIf
		Next i

		//Validações especificas.
		//Se pedido ja existe no sistema
		If nPosC5_EMISSAO <> 0 .and. nPosC5_P_NUM <> 0
			If ViewPV(aDados[i][nPosC5_EMISSAO],aDados[i][nPosC5_P_NUM])
				aAdd(aLog,{"",IIF(nPosC5_EMISSAO<>0,aDados[i][nPosC5_EMISSAO],""),;
							IIF(nPosC5_P_NUM<>0,aDados[i][nPosC5_P_NUM],""),;
							IIF(nPosC6_P_REF<>0,aDados[i][nPosC6_P_REF],""),;
							IIF(nPosC6_PRODUTO<>0,aDados[i][nPosC6_PRODUTO],""),;
							"",;
							aDados[1][nPosC5_EMISSAO]+"+"+aDados[1][nPosC5_P_NUM],;
							aDados[2][nPosC5_EMISSAO]+"+"+aDados[2][nPosC5_P_NUM],;
							aDados[i][nPosC5_EMISSAO]+"+"+aDados[i][nPosC5_P_NUM],;
							"E","Duplicate Sales Order",aDados[i][Len(aDados[i])]})
			EndIf
		EndIf

		//Pais
		If (nPos := aScan(aDados[2], {|x| ALLTRIM(x) == 'C6_P_CODPAIS' }) ) <> 0
			If UPPER(aDados[i][nPos]) <> "BR"
				aAdd(aLog,{"",IIF(nPosC5_EMISSAO<>0,aDados[i][nPosC5_EMISSAO],""),;
							IIF(nPosC5_P_NUM<>0,aDados[i][nPosC5_P_NUM],""),;
							IIF(nPosC6_P_REF<>0,aDados[i][nPosC6_P_REF],""),;
							IIF(nPosC6_PRODUTO<>0,aDados[i][nPosC6_PRODUTO],""),;
							"",aDados[1][nPos],aDados[2][nPos],aDados[i][nPos],"E","Country not allowed, accept only 'BR'.",aDados[i][Len(aDados[i])]})
			EndIf
		EndIf
		//Cod.Municipio
		If (nPos := aScan(aDados[2], {|x| ALLTRIM(x) == 'C6_P_COD_MUN' }) ) <> 0
			If EMPTY(aDados[i][nPos])
				If aScan(aDados[2],{|x| ALLTRIM(x) == "C6_P_EST"}) <> 0 .and. aScan(aDados[2],{|x| ALLTRIM(x) == "C6_P_MUN"}) <> 0
					aDados[i][nPos] := GetCodMun(aDados[i][aScan(aDados[2],{|x| ALLTRIM(x)=="C6_P_EST"})],aDados[i][aScan(aDados[2],{|x|ALLTRIM(x)=="C6_P_MUN"})])
				EndIf
			EndIf
		EndIf
		//Cliente		
		nPos := aScan(aDados[2],{|x| ALLTRIM(x)=="A1_P_ID"})
		If !EMPTY(aDados[i][nPos])
			If Len(ClieTw(aDados[i][nPos])) == 0
				aAdd(aLog,{"",IIF(nPosC5_EMISSAO<>0,aDados[i][nPosC5_EMISSAO],""),;
							IIF(nPosC5_P_NUM<>0,aDados[i][nPosC5_P_NUM],""),;
							IIF(nPosC6_P_REF<>0,aDados[i][nPosC6_P_REF],""),;
							IIF(nPosC6_PRODUTO<>0,aDados[i][nPosC6_PRODUTO],""),;
							"",aDados[1][nPos],aDados[2][nPos],aDados[i][nPos],"E","Not found references to the ID",aDados[i][Len(aDados[i])]})
			
			EndIf
		Else
	   		aAdd(aLog,{"",IIF(nPosC5_EMISSAO<>0,aDados[i][nPosC5_EMISSAO],""),;
							IIF(nPosC5_P_NUM<>0,aDados[i][nPosC5_P_NUM],""),;
							IIF(nPosC6_P_REF<>0,aDados[i][nPosC6_P_REF],""),;
							IIF(nPosC6_PRODUTO<>0,aDados[i][nPosC6_PRODUTO],""),;
							"",aDados[1][nPos],aDados[2][nPos],"","E","This field is required",aDados[i][Len(aDados[i])]})
		EndIf
		//Condição de Pagamento.
		nPos := aScan(aDados[2],{|x| ALLTRIM(x)=="C5_CONDPAG"})
		If !EMPTY(aDados[i][nPos])
			If EMPTY(CondPag(aDados[i][nPos]))
				aAdd(aLog,{"",IIF(nPosC5_EMISSAO<>0,aDados[i][nPosC5_EMISSAO],""),;
							IIF(nPosC5_P_NUM<>0,aDados[i][nPosC5_P_NUM],""),;
							IIF(nPosC6_P_REF<>0,aDados[i][nPosC6_P_REF],""),;
							IIF(nPosC6_PRODUTO<>0,aDados[i][nPosC6_PRODUTO],""),;
							"",aDados[1][nPos],aDados[2][nPos],aDados[i][nPos],"E","Not found references to the ID",aDados[i][Len(aDados[i])]})
			
			EndIf
		Else
	   		aAdd(aLog,{"",IIF(nPosC5_EMISSAO<>0,aDados[i][nPosC5_EMISSAO],""),;
							IIF(nPosC5_P_NUM<>0,aDados[i][nPosC5_P_NUM],""),;
							IIF(nPosC6_P_REF<>0,aDados[i][nPosC6_P_REF],""),;
							IIF(nPosC6_PRODUTO<>0,aDados[i][nPosC6_PRODUTO],""),;
							"",aDados[1][nPos],aDados[2][nPos],"","E","This field is required",aDados[i][Len(aDados[i])]})
		EndIf

		//Produto
		nPos := aScan(aDados[2],{|x| ALLTRIM(x)=="C6_PRODUTO"})
		If !EMPTY(aDados[i][nPos])
			If !ValProd(aDados[i][nPos])
				aAdd(aLog,{"",IIF(nPosC5_EMISSAO<>0,aDados[i][nPosC5_EMISSAO],""),;
							IIF(nPosC5_P_NUM<>0,aDados[i][nPosC5_P_NUM],""),;
							IIF(nPosC6_P_REF<>0,aDados[i][nPosC6_P_REF],""),;
							IIF(nPosC6_PRODUTO<>0,aDados[i][nPosC6_PRODUTO],""),;
							"",aDados[1][nPos],aDados[2][nPos],aDados[i][nPos],"E","Not found references to the ID",aDados[i][Len(aDados[i])]})
			Else
				//Tratamento de TES de acordo com o Produto
				nPos2 := aScan(aDados[2],{|x| ALLTRIM(x)=="C6_TES"})
				cTes := ""
				If nPos2 <> 0 .and. (cTes := GetTES(aDados[i][nPos])) <> ""
					aDados[i][nPos2] := cTes
				EndIf
			EndIf
		Else
	   		aAdd(aLog,{"",IIF(nPosC5_EMISSAO<>0,aDados[i][nPosC5_EMISSAO],""),;
							IIF(nPosC5_P_NUM<>0,aDados[i][nPosC5_P_NUM],""),;
							IIF(nPosC6_P_REF<>0,aDados[i][nPosC6_P_REF],""),;
							IIF(nPosC6_PRODUTO<>0,aDados[i][nPosC6_PRODUTO],""),;
							"",aDados[1][nPos],aDados[2][nPos],"","E","This field is required",aDados[i][Len(aDados[i])]})
		EndIf

		//TES
		nPos := aScan(aDados[2],{|x| ALLTRIM(x)=="C6_TES"})
		If !EMPTY(aDados[i][nPos])
			If EMPTY(ValTES(aDados[i][nPos]))
				aAdd(aLog,{"",IIF(nPosC5_EMISSAO<>0,aDados[i][nPosC5_EMISSAO],""),;
							IIF(nPosC5_P_NUM<>0,aDados[i][nPosC5_P_NUM],""),;
							IIF(nPosC6_P_REF<>0,aDados[i][nPosC6_P_REF],""),;
							IIF(nPosC6_PRODUTO<>0,aDados[i][nPosC6_PRODUTO],""),;
							"",aDados[1][nPos],aDados[2][nPos],aDados[i][nPos],"E","Not found references to the ID",aDados[i][Len(aDados[i])]})
			
			EndIf
		Else
	   		aAdd(aLog,{"",IIF(nPosC5_EMISSAO<>0,aDados[i][nPosC5_EMISSAO],""),;
							IIF(nPosC5_P_NUM<>0,aDados[i][nPosC5_P_NUM],""),;
							IIF(nPosC6_P_REF<>0,aDados[i][nPosC6_P_REF],""),;
							IIF(nPosC6_PRODUTO<>0,aDados[i][nPosC6_PRODUTO],""),;
							"",aDados[1][nPos],aDados[2][nPos],"","E","This field is required",aDados[i][Len(aDados[i])]})
		EndIf
        
		//Tratamento para novo atributo
		nPosAtri1 := aScan(aDados[2],{|x| UPPER(ALLTRIM(x))=="ATTRIBUTE1"})
		nPosAtri2 := aScan(aDados[2],{|x| UPPER(ALLTRIM(x))=="ATTRIBUTE2"})
		
		//if Alltrim(aCxIAtrib[nPos][1][nPosAtri1]) <> "A" //Se não for Agency Credit Line
		
		if ALLTRIM(aDados[i][nPosAtri1]) <> "A" //Se não for Agency Credit Line, Attribute1 <> A
				
			//Adiciona ao Array para gravação.
			If (nPos := aScan(aCxI, {|x|	ALLTRIM(x[1][aScan(aCab,{|x| ALLTRIM(x)=="C5_EMISSAO" })][2]) == ALLTRIM(aDados[i][nPosC5_EMISSAO]) .and.;
											ALLTRIM(x[1][aScan(aCab,{|x| ALLTRIM(x)=="C5_P_NUM" })][2])   == ALLTRIM(aDados[i][nPosC5_P_NUM])  }) )    <> 0
	
				//Monta o Array de Itens
				aAux2 := {}
				For j:=1 to len(aIte)
					aAdd(aAux2, {aIte[j], aDados[i][aScan(aDados[2], {|x| ALLTRIM(x) == aIte[j] })], NIl  } )
				Next i
				
				aAdd(aCxI[nPos][2], aAux2 )
				
			Else
				//Monta o Array de Cabeçalho
				aAux1 := {}
				For j:=1 to len(aCab)
					aAdd(aAux1, {aCab[j], aDados[i][aScan(aDados[2], {|x| ALLTRIM(x) == aCab[j] })], NIl }  )
				Next i
				//Monta o Array de Itens
				aAux2 := {}
				For j:=1 to len(aIte)
					aAdd(aAux2, {aIte[j], aDados[i][aScan(aDados[2], {|x| ALLTRIM(x) == aIte[j] })], NIl  } )
				Next i
				//Busca o Cliente
				nPos2 := aScan(aDados[2],{|x| ALLTRIM(x)=="A1_P_ID"})
				aAdd(aAux1, {"C5_CLIENTE"	,IIF(LEN(ClieTw(aDados[i][nPos2]))==0,"",ClieTw(aDados[i][nPos2])[1]),Nil  } )
				aAdd(aAux1, {"C5_LOJACLI"	,IIF(LEN(ClieTw(aDados[i][nPos2]))==0,"",ClieTw(aDados[i][nPos2])[2]),Nil  } )
				aAdd(aAux1, {"C5_LOJAENT"	,IIF(LEN(ClieTw(aDados[i][nPos2]))==0,"",ClieTw(aDados[i][nPos2])[2]),Nil  } )
				
				//Adiciona no Array com os dados organizados.
				aAdd(aCxI,{aAux1,{}})
				aAdd(aCxI[Len(aCxI)][2], aAux2 )
				
				aAux3:=ACLONE(aAux1)
				
				//Adiciona no Array auxiliar para tratamento dos atributos adicionais
				aAdd(aCxIAtrib,{aAux3,{}})
				aAdd(aCxIAtrib[len(aCxIAtrib)][1],{"ATTRIBUTE1",aDados[i][nPosAtri1],Nil})
				nPosCxTr1:=len(aCxIAtrib[len(aCxIAtrib)][1])
				aAdd(aCxIAtrib[len(aCxIAtrib)][1],{"ATTRIBUTE2",aDados[i][nPosAtri2],Nil})            
				nPosCxTr2:=len(aCxIAtrib[len(aCxIAtrib)][1])
				
			EndIf
		
		//Se for Agency Credit Line, o pedido é agrupado de acordo com o attribute2
		else
				
			if (nPos := aScan(aCxIAtrib, {|x|	ALLTRIM(x[1][aScan(aCab,{|x| ALLTRIM(x)=="C5_EMISSAO" })][2]) == ALLTRIM(aDados[i][nPosC5_EMISSAO]) .and.;
												ALLTRIM(x[1][aScan(aCab,{|x| ALLTRIM(x)=="C5_P_NUM" })][2])   == ALLTRIM(aDados[i][nPosC5_P_NUM])   .and.;
												ALLTRIM(x[1][nPosCxTr2][2])   == ALLTRIM(aDados[i][nPosAtri2]) }) )    <> 0
                
            	nPosC6Ite:=aScan(aIte,{|x| ALLTRIM(x)=="C6_ITEM" })
				//Monta o Array de Itens
				aAux2 := {}
				For j:=1 to len(aIte)
					if aIte[j] == "C6_ITEM"
						cIte := SOMA1(aCxI[nPos][2][len(aCxI[nPos][2])][nPosC6Ite][2])
						
						aAdd(aAux2, {aIte[j], cIte, NIl  } )

					else
						aAdd(aAux2, {aIte[j], aDados[i][aScan(aDados[2], {|x| ALLTRIM(x) == aIte[j] })], NIl  } )
					endif
				Next i
				
				aAdd(aCxI[nPos][2], aAux2 )

            else

				//Monta o Array de Cabeçalho
				aAux1 := {}
				For j:=1 to len(aCab)
					aAdd(aAux1, {aCab[j], aDados[i][aScan(aDados[2], {|x| ALLTRIM(x) == aCab[j] })], NIl }  )
				Next i
				//Monta o Array de Itens
				aAux2 := {}
				For j:=1 to len(aIte)
					if aIte[j] == "C6_ITEM"
						aAdd(aAux2, {aIte[j], "1" , NIl  } )
					else
						aAdd(aAux2, {aIte[j], aDados[i][aScan(aDados[2], {|x| ALLTRIM(x) == aIte[j] })], NIl  } )
					endif
				Next i
				//Busca o Cliente
				nPos2 := aScan(aDados[2],{|x| ALLTRIM(x)=="A1_P_ID"})
				aAdd(aAux1, {"C5_CLIENTE"	,IIF(LEN(ClieTw(aDados[i][nPos2]))==0,"",ClieTw(aDados[i][nPos2])[1]),Nil  } )
				aAdd(aAux1, {"C5_LOJACLI"	,IIF(LEN(ClieTw(aDados[i][nPos2]))==0,"",ClieTw(aDados[i][nPos2])[2]),Nil  } )
				aAdd(aAux1, {"C5_LOJAENT"	,IIF(LEN(ClieTw(aDados[i][nPos2]))==0,"",ClieTw(aDados[i][nPos2])[2]),Nil  } )
				
				//Adiciona no Array com os dados organizados.
				aAdd(aCxI,{aAux1,{}})
				aAdd(aCxI[Len(aCxI)][2], aAux2 )
				
				aAux3:=ACLONE(aAux1)
				
				//Adiciona no Array auxiliar para tratamento dos atributos adicionais
				aAdd(aCxIAtrib,{aAux3,{}})
				aAdd(aCxIAtrib[len(aCxIAtrib)][1],{"ATTRIBUTE1",aDados[i][nPosAtri1],Nil})
				nPosCxTr1:=len(aCxIAtrib[len(aCxIAtrib)][1])
				aAdd(aCxIAtrib[len(aCxIAtrib)][1],{"ATTRIBUTE2",aDados[i][nPosAtri2],Nil})            
				nPosCxTr2:=len(aCxIAtrib[len(aCxIAtrib)][1])			
				
			endif

		endif
		
	EndIf
Next i

//Gravação do Pedido
If !lCritErro
	For i:=1 to Len(aCxI)
		lMsErroAuto:= .F.
		lMSHelpAuto := .F.
		lAutoErrNoFile := .T.

		If aScan(aLog,{|x| ALLTRIM(x[aScan(aLog[2],{|x|x==ALLTRIM("C5_EMISSAO")})]) == ALLTRIM(aCxI[i][1][aScan(aCab,{|x| ALLTRIM(x)=="C5_EMISSAO" })][2]) .and.;
						ALLTRIM(x[aScan(aLog[2],{|x|x==ALLTRIM("C5_P_NUM")})])      == ALLTRIM(aCxI[i][1][aScan(aCab,{|x| ALLTRIM(x)=="C5_P_NUM" })][2]) .and.;
						( aCxIAtrib[i][1][nPosCxTr1][2] <> "A" ) }) == 0
			//.and. ALLTRIM(x[aScan(aLog[2],{|x| alltrim(UPPER(x)) ==ALLTRIM("STATUS")})]) == "S"  )

			//Busca o Ultimo Numero dos PV.
			If Select("NUMPV") > 0
				NUMPV->(DbClosearea())
			Endif  
			cQuery := " Select MAX(C5_NUM)+1 AS PROXNUM"
			cQuery += " From "+RETSQLNAME("SC5")
			dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"NUMPV",.F.,.T.)
			cSeqNumC5 := STRZERO(NUMPV->PROXNUM,TAMSX3("C5_NUM")[1])
			NUMPV->(DbClosearea())
			
			//Valores deFault e Ajuste de Valores            
			aCabExec := {}
			aIteExec := {}
			aCabExec := aClone(aCxI[i][1])
			aIteExec := aClone(aCxI[i][2])
			
			aAdd(aCabExec,{"C5_NUM",cSeqNumC5,Nil})
			aAdd(aCabExec,{"C5_P_INT","S",Nil})
			if SC5->(FieldPos("C5_P_ATB01"))>0
				aAdd(aCabExec,{"C5_P_ATB01",alltrim(aCxIAtrib[i][1][nPosCxTr1][2]),Nil})
			endif
			
			aCabExec[aScan(aCabExec,{|x| ALLTRIM(x[1])=="C5_EMISSAO"  })][2] := AltData(aCabExec[aScan(aCabExec,{|x| ALLTRIM(x[1])=="C5_EMISSAO" })][2])
			aCabExec[aScan(aCabExec,{|x| ALLTRIM(x[1])=="C5_CONDPAG" })][2]  := CondPag(aCabExec[aScan(aCabExec,{|x| ALLTRIM(x[1])=="C5_CONDPAG" })][2])
			
			//Tratamento de Email
			If aScan(aCabExec,{|x| ALLTRIM(x[1])=="C5_P_EMAIL" }) <> 0
				aCabExec[aScan(aCabExec,{|x| ALLTRIM(x[1])=="C5_P_EMAIL" })][2]  := ALLTRIM(aCabExec[aScan(aCabExec,{|x| ALLTRIM(x[1])=="C5_P_EMAIL" })][2])
				//721-960
				If LEN(aCabExec[aScan(aCabExec,{|x| ALLTRIM(x[1])=="C5_P_EMAIL" })][2]) >= 721
					aAdd(aCabExec,{"C5_P_EMAI3", SUBSTR(aCabExec[aScan(aCabExec,{|x| ALLTRIM(x[1])=="C5_P_EMAIL" })][2],721,240) ,Nil})
				EndIf
				//481-720
				If LEN(aCabExec[aScan(aCabExec,{|x| ALLTRIM(x[1])=="C5_P_EMAIL" })][2]) >= 721
					aAdd(aCabExec,{"C5_P_EMAI2", SUBSTR(aCabExec[aScan(aCabExec,{|x| ALLTRIM(x[1])=="C5_P_EMAIL" })][2],481,240) ,Nil})
				EndIf
				//241-480
				If LEN(aCabExec[aScan(aCabExec,{|x| ALLTRIM(x[1])=="C5_P_EMAIL" })][2]) >= 721
					aAdd(aCabExec,{"C5_P_EMAI1", SUBSTR(aCabExec[aScan(aCabExec,{|x| ALLTRIM(x[1])=="C5_P_EMAIL" })][2],241,240) ,Nil})
				EndIf
	            //001-240
				aCabExec[aScan(aCabExec,{|x| ALLTRIM(x[1])=="C5_P_EMAIL" })][2]  := SUBSTR(aCabExec[aScan(aCabExec,{|x| ALLTRIM(x[1])=="C5_P_EMAIL" })][2],1,240)
			EndIf

			For j:=1 to len(aIteExec)
				aIteExec[j][aScan(aIteExec[j],{|x| ALLTRIM(x[1])=="C6_ITEM"		})][2] := StrZero(VAL(aIteExec[j][aScan(aIte,{|x| ALLTRIM(x)=="C6_ITEM" })][2]),TAMSX3("C6_ITEM")[1])
				aIteExec[j][aScan(aIteExec[j],{|x| ALLTRIM(x[1])=="C6_VALOR"	})][2] := VAL(aIteExec[j][aScan(aIte,{|x| ALLTRIM(x)=="C6_VALOR" })][2])
				aIteExec[j][aScan(aIteExec[j],{|x| ALLTRIM(x[1])=="C6_PRCVEN"	})][2] := VAL(aIteExec[j][aScan(aIte,{|x| ALLTRIM(x)=="C6_PRCVEN" })][2])
				aIteExec[j][aScan(aIteExec[j],{|x| ALLTRIM(x[1])=="C6_QTDVEN"	})][2] := VAL(aIteExec[j][aScan(aIte,{|x| ALLTRIM(x)=="C6_QTDVEN" })][2])
				aIteExec[j][aScan(aIteExec[j],{|x| ALLTRIM(x[1])=="C6_P_CODPAIS"})][1] := "C6_P_CODPA"
				aIteExec[j][aScan(aIteExec[j],{|x| ALLTRIM(x[1])=="C6_P_COD_MUN"})][1] := "C6_P_COD_M"
				aIteExec[j][aScan(aIteExec[j],{|x| ALLTRIM(x[1])=="C6_P_PESSOA"	})][1] := "C6_P_TIPO"

				If aScan(aIteExec[j],{|x| ALLTRIM(x[1])=="C6_PRUNIT" }) == 0
					nPrunit := aIteExec[j][aScan(aIteExec[j],{|x| ALLTRIM(x[1])=="C6_VALOR" })][2] /;
								aIteExec[j][aScan(aIteExec[j],{|x| ALLTRIM(x[1])=="C6_QTDVEN"})][2]
					aAdd(aIteExec[j],{"C6_PRUNIT",nPrunit,Nil})
				EndIf
				If aScan(aIteExec[j],{|x| ALLTRIM(x[1])=="C6_CF" }) == 0
					aAdd(aIteExec[j],{"C6_CF",ValTES(aIteExec[j][aScan(aIte,{|x| ALLTRIM(x)=="C6_TES" })][2]),Nil})
				EndIf
				If aScan(aIteExec[j],{|x| ALLTRIM(x[1])=="C6_P_NUM" }) == 0
					aAdd(aIteExec[j],{"C6_P_NUM",aCabExec[aScan(aCabExec,{|x| ALLTRIM(x[1])=="C5_P_NUM"  })][2],Nil})
				EndIf

				//Ajuste de caracteres invalidos.
				cAux := ""
				If (nPos:=aScan(aIteExec[j],{|x| ALLTRIM(x[1])=="C6_P_NOME"})  ) <> 0
					cAux := ConvString(aIteExec[j][nPos][2])
					aIteExec[j][nPos][2] := cAux
				EndIf
				If (nPos:=aScan(aIteExec[j],{|x| ALLTRIM(x[1])=="C6_P_NREDU"})  ) == 0
					aAdd(aIteExec[j],{"C6_P_NREDU",cAux,Nil})
				Else
					aIteExec[j][nPos][2] := cAux
				EndIf
				If (nPos:=aScan(aIteExec[j],{|x| ALLTRIM(x[1]) == "C6_P_END"})  ) <> 0
					aIteExec[j][nPos][2] := ConvString(aIteExec[j][nPos][2])
				EndIf
				If (nPos:=aScan(aIteExec[j],{|x| ALLTRIM(x[1]) == "C6_P_AGEN"})  ) <> 0
					aIteExec[j][nPos][2] := ConvString(aIteExec[j][nPos][2])
				EndIf
			Next i

			//Valida se o campo existe na Base
			SX3->(DbSetOrder(2))
			lErroInCpo := .F.
			For j:=1 to len(aCabExec)
				If !SX3->(DbSeek(aCabExec[j][1]))
			   		aAdd(aLog,{"",IIF(aScan(aCab,{|x| ALLTRIM(x)=="C5_EMISSAO"})<>0,aCxI[i][1][aScan(aCab,{|x| ALLTRIM(x)=="C5_EMISSAO"})][2],""),;
								  IIF(aScan(aCab,{|x| ALLTRIM(x)=="C5_P_NUM"  })<>0,aCxI[i][1][aScan(aCab,{|x| ALLTRIM(x)=="C5_P_NUM"  })][2],""),;
								  IIF(aScan(aIte,{|x| ALLTRIM(x)=="C6_P_REF"  })<>0,aCxI[i][2][1][aScan(aIte,{|x| ALLTRIM(x)=="C6_P_REF"  })][2],""),;
								  IIF(aScan(aIte,{|x| ALLTRIM(x)=="C6_PRODUTO"})<>0,aCxI[i][2][1][aScan(aIte,{|x| ALLTRIM(x)=="C6_PRODUTO" })][2],""),;
								  aCabExec[j][1],"","","","E","field is not valid",aDados[i][Len(aDados[i])]})
					lErroInCpo := .T.
				EndIf
			Next j
			For j:=1 to len(aIteExec)
				For k:=1 to len(aIteExec[j])
					If !SX3->(DbSeek(aIteExec[j][k][1]))
				   		aAdd(aLog,{"",IIF(aScan(aCab,{|x| ALLTRIM(x)=="C5_EMISSAO" })<>0,aCxI[i][1][aScan(aCab,{|x| ALLTRIM(x)=="C5_EMISSAO" })][2],""),;
									IIF(aScan(aCab,{|x| ALLTRIM(x)=="C5_P_NUM" })<>0	,aCxI[i][1][aScan(aCab,{|x| ALLTRIM(x)=="C5_P_NUM" })][2],""),;
									IIF(aScan(aIte,{|x| ALLTRIM(x)=="C6_P_REF" })<>0	,aCxI[i][2][1][aScan(aIte,{|x| ALLTRIM(x)=="C6_P_REF" })][2],""),;
									IIF(aScan(aIte,{|x| ALLTRIM(x)=="C6_PRODUTO" })<>0	,aCxI[i][2][1][aScan(aIte,{|x| ALLTRIM(x)=="C6_PRODUTO" })][2],""),;
									aIteExec[j][k][1],"","","","E","field is not valid",aDados[i][Len(aDados[i])]})
						lErroInCpo := .T.
					EndIf
				Next k
			Next j

            //Orderna Alguns campos.
			//Cabeçalho
			aAux := aCabExec
			aCabExec := {}
			aOrd := {"C5_NUM","C5_TIPO","C5_CLIENTE","C5_LOJACLI","C5_LOJAENT","C5_CONDPAG"}
			For j:=1 to Len(aOrd)
				aAdd(aCabExec,aAux[aScan(aAux,{|x| ALLTRIM(x[1]) == ALLTRIM(aOrd[j]) })] )
				aDel(aAux,aScan(aAux,{|x| ALLTRIM(x[1]) == ALLTRIM(aOrd[j]) }))
				aSize(aAux, Len(aAux)-1)
			Next j
			For j:=1 to Len(aAux)
				aAdd(aCabExec,aAux[j] )
			Next j
			//Itens
			aAux := aIteExec
			aIteExec := {}
			aOrd := {"C6_ITEM","C6_PRODUTO","C6_QTDVEN","C6_PRCVEN","C6_PRUNIT","C6_VALOR","C6_TES"}
			aIteExec := Array(Len(aAux))
			For j:=1 to Len(aAux)
				aIteExec[j] := {}
				For k:=1 to Len(aOrd) 
			  		aAdd(aIteExec[j],aAux[j][aScan(aAux[j],{|x| ALLTRIM(x[1]) == ALLTRIM(aOrd[K]) })] )
			   		aDel(aAux[j],aScan(aAux[j],{|x| ALLTRIM(x[1]) == ALLTRIM(aOrd[K]) }))
			   		aSize(aAux[j], Len(aAux[j])-1)
			   	Next k
				For k:=1 to Len(aAux[j])
					aAdd(aIteExec[j],aAux[j][k] )
				Next k
			Next j

    		//Efetua a gravação do Pedido
			If !lErroInCpo
				MSExecAuto( {|x,y,z| MATA410(x,y,z) }, aCabExec, aIteExec, 3)
				//Tratamento de Erro
				If lMsErroAuto
					cMsg := "Error in recording"
			   		aAdd(aLog,{"",IIF(aScan(aCab,{|x| ALLTRIM(x)=="C5_EMISSAO" })<>0,aCxI[i][1][aScan(aCab,{|x| ALLTRIM(x)=="C5_EMISSAO" })][2],""),;
									IIF(aScan(aCab,{|x| ALLTRIM(x)=="C5_P_NUM" })<>0,aCxI[i][1][aScan(aCab,{|x| ALLTRIM(x)=="C5_P_NUM" })][2],""),;
									IIF(aScan(aIte,{|x| ALLTRIM(x)=="C6_P_REF" })<>0,aCxI[i][2][1][aScan(aIte,{|x| ALLTRIM(x)=="C6_P_REF" })][2],""),;
									IIF(aScan(aIte,{|x| ALLTRIM(x)=="C6_PRODUTO" })<>0,aCxI[i][2][1][aScan(aIte,{|x| ALLTRIM(x)=="C6_PRODUTO" })][2],""),;
									"","","","","E",cMsg,aDados[i][Len(aDados[i])]})
				Else    
					cMsg := "Inserted successfully"
			   		aAdd(aLog,{"",IIF(aScan(aCab,{|x| ALLTRIM(x)=="C5_EMISSAO" })<>0,aCxI[i][1][aScan(aCab,{|x| ALLTRIM(x)=="C5_EMISSAO" })][2],""),;
									IIF(aScan(aCab,{|x| ALLTRIM(x)=="C5_P_NUM" })<>0,aCxI[i][1][aScan(aCab,{|x| ALLTRIM(x)=="C5_P_NUM" })][2],""),;
									IIF(aScan(aIte,{|x| ALLTRIM(x)=="C6_P_REF" })<>0,aCxI[i][2][1][aScan(aIte,{|x| ALLTRIM(x)=="C6_P_REF" })][2],""),;
									IIF(aScan(aIte,{|x| ALLTRIM(x)=="C6_PRODUTO" })<>0,aCxI[i][2][1][aScan(aIte,{|x| ALLTRIM(x)=="C6_PRODUTO" })][2],""),;
									aCabExec[aScan(aCabExec,{|x| ALLTRIM(x[1])=="C5_NUM" })][2],;
									"","","","S",cMsg,aDados[i][Len(aDados[i])]})
				EndIf
			EndIf

		EndIf
	Next i

EndIf

//Ajuste do Log de Processamento.
If Len(aLog) >= 3
	nPosLog1 := aScan(aLog[2],{|x|x==ALLTRIM("C5_EMISSAO")})
	nPosLog2 := aScan(aLog[2],{|x|x==ALLTRIM("C5_P_NUM")})
	nPosLog3 := aScan(aLog[2],{|x|x==ALLTRIM("C5_P_REF")})
	nPosLog4 := aScan(aLog[2],{|x|x==ALLTRIM("C6_PRODUTO")})

	//Tratamento para casos que possuem itens rejeitados na integração. para apresentar log para todos.
	For i:=3 to Len(aDados)
		If (nPos := aScan(aLog,{|x| ALLTRIM(x[nPosLog1]) == ALLTRIM(aDados[i][nPosC5_EMISSAO]) 	.and.;
									ALLTRIM(x[nPosLog2]) == ALLTRIM(aDados[i][nPosC5_P_NUM]) 	.and.;
									IIF( aDados[i][nPosAtri1]=="A", ALLTRIM(x[nPosLog3]) == ALLTRIM(aDados[i][nPosC6_P_REF]), .T. ) }) )	<> 0 //MSM - 28/04/2015 - tratamento para Agency credt line

			If aScan(aLog,{|x|	ALLTRIM(x[nPosLog1]) == ALLTRIM(aDados[i][nPosC5_EMISSAO]) .and.;
								ALLTRIM(x[nPosLog2]) == ALLTRIM(aDados[i][nPosC5_P_NUM]) .and.;
								ALLTRIM(x[nPosLog3]) == ALLTRIM(aDados[i][nPosC6_P_REF]) .and.;
								ALLTRIM(x[nPosLog4]) == ALLTRIM(aDados[i][nPosC6_PRODUTO]) }) == 0

				If alog[nPos][aScan(aLog[2],{|x| ALLTRIM(UPPER(x)) == ALLTRIM("STATUS")})] == "S"
					aAdd(aLog,{"",IIF(nPosC5_EMISSAO<>0,aDados[i][nPosC5_EMISSAO],""),;
								IIF(nPosC5_P_NUM<>0,aDados[i][nPosC5_P_NUM],""),;
								IIF(nPosC6_P_REF<>0,aDados[i][nPosC6_P_REF],""),;
								IIF(nPosC6_PRODUTO<>0,aDados[i][nPosC6_PRODUTO],""),;
								alog[nPos][aScan(aLog[2],{|x| ALLTRIM(UPPER(x)) == ALLTRIM("C5_NUM")})],;
								"","","","S","Inserted successfully",aDados[i][Len(aDados[i])]})
				Else
					aAdd(aLog,{"",IIF(nPosC5_EMISSAO<>0,aDados[i][nPosC5_EMISSAO],""),;
								IIF(nPosC5_P_NUM<>0,aDados[i][nPosC5_P_NUM],""),;
								IIF(nPosC6_P_REF<>0,aDados[i][nPosC6_P_REF],""),;
								IIF(nPosC6_PRODUTO<>0,aDados[i][nPosC6_PRODUTO],""),;
								"","","","","E","There is another item in the request rejected",aDados[i][Len(aDados[i])]})				
				EndIf
			EndIF
		EndIf
	Next i
    
	//Para manter as linhas de cabeçalho no local correto durante a ordenação
	aLog[1][nPosLog1] := "AAAAA"+aLog[1][nPosLog1]
	aLog[2][nPosLog1] := "AAAAB"+aLog[2][nPosLog1]
	
	aSort(aLog,,,{|x,y| x[nPosLog1]+x[nPosLog2]+x[nPosLog3]+x[nPosLog4] < y[nPosLog1]+y[nPosLog2]+y[nPosLog3]+y[nPosLog4] })

	//Restaura os dados alterados
	aLog[1][nPosLog1] := SubStr(aLog[1][nPosLog1],6,Len(aLog[1][nPosLog1]) )
	aLog[2][nPosLog1] := SubStr(aLog[2][nPosLog1],6,Len(aLog[2][nPosLog1]) )

	nSeq := 1
	cChave := aLog[3][nPosLog1]+aLog[3][nPosLog2]+aLog[3][nPosLog3]+aLog[3][nPosLog4]
	
	For i:=3 to Len(aLog)
		If cChave <> aLog[i][nPosLog1]+aLog[i][nPosLog2]+aLog[i][nPosLog3]+aLog[i][nPosLog4]
			nSeq := 1
			cChave := aLog[i][nPosLog1]+aLog[i][nPosLog2]+aLog[i][nPosLog3]+aLog[i][nPosLog4]
		EndIf
		alog[i][aScan(aLog[2],{|x|x==ALLTRIM("SEQ")})] := ALLTRIM(STR(nSeq))
		nSeq ++
	Next i
EndIf

Return .T.

/*
Funcao      : GravaZX1
Parametros  : 
Retorno     :
Objetivos   : Gravação dos Arquivos.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*------------------------*
Static Function GravaZX1()
*------------------------*
Local i
Local aDados	:= &("a"+aRefArq[nNATAtu][1])
Local lErro		:= .F.
Local lCritErro	:= .F.
Local nPos		:= 0
Local nPos2		:= 0

Local aCposObrg	:= {'C5_EMISSAO','C5_P_NUM','C5_P_REF','C6_PRODUTO','C5_P_MOED','C6_VALOR','ZX1_ID','ZX1_NAME','ZX1_NAMEF','ZX1_MOED','ZX1_VALOR'}
Local aNotEmpty	:= {'C5_EMISSAO','C5_P_NUM','C5_P_REF','C6_PRODUTO','ZX1_ID'}
Local aLog		:= &("aLog"+aRefArq[nNATAtu][1])

//Posição dos campos que compoem a chave do arquivo.
Local nPosC5_EMISSAO	:=  aScan(aDados[2], {|x| ALLTRIM(x) == "C5_EMISSAO" })
Local nPosC5_P_NUM		:=  aScan(aDados[2], {|x| ALLTRIM(x) == "C5_P_NUM" })
Local nPosC5_P_REF		:=  aScan(aDados[2], {|x| ALLTRIM(x) == "C5_P_REF" })
Local nPosC6_PRODUTO	:=  aScan(aDados[2], {|x| ALLTRIM(x) == "C6_PRODUTO" })
Local nPosZX1_ID		:=  aScan(aDados[2], {|x| ALLTRIM(x) == "ZX1_ID" })

//Executa a partir do primeiro registro com informação.
For i:=3 to len(aDados)
	//Validações De estrutura
	For j:=1 to Len(aCposObrg)
		If (nPos := aScan(aDados[2], {|x| ALLTRIM(x) == ALLTRIM(aCposObrg[j]) })   ) == 0
			lCritErro := .T.
			aAdd(aLog,{"",IIF(nPosC5_EMISSAO<>0,aDados[i][nPosC5_EMISSAO],""),;
						IIF(nPosC5_P_NUM<>0,aDados[i][nPosC5_P_NUM],""),;
						IIF(nPosC5_P_REF<>0,aDados[i][nPosC5_P_REF],""),;
						IIF(nPosC6_PRODUTO<>0,aDados[i][nPosC6_PRODUTO],""),;
						IIF(nPosZX1_ID<>0,aDados[i][nPosZX1_ID],""),;
						"",aCposObrg[j],"","E","Critical Error - Field not Exist",aDados[i][Len(aDados[i])]})
		EndIf
	Next j

	//Validações de Dados.
	If !lCritErro
		//Campos que não podem estar vazios
		For j:=1 to Len(aNotEmpty)
			If (nPos := aScan(aDados[2], {|x| ALLTRIM(x) == ALLTRIM(aNotEmpty[j]) }) ) <> 0
				If EMPTY(aDados[i][nPos])
					aAdd(aLog,{"",IIF(nPosC5_EMISSAO<>0,aDados[i][nPosC5_EMISSAO],""),;
						IIF(nPosC5_P_NUM<>0,aDados[i][nPosC5_P_NUM],""),;
						IIF(nPosC5_P_REF<>0,aDados[i][nPosC5_P_REF],""),;
						IIF(nPosC6_PRODUTO<>0,aDados[i][nPosC6_PRODUTO],""),;
						IIF(nPosZX1_ID<>0,aDados[i][nPosZX1_ID],""),;
						aDados[1][nPos],aDados[2][nPos],"","E","This field is required",aDados[i][Len(aDados[i])]})
				EndIf
			EndIf
		Next i
		
		//Validações especificas
		//Se pedido existe no sistema
		If nPosC5_EMISSAO <> 0 .and. nPosC5_P_NUM <> 0 .and. nPosC6_PRODUTO <> 0
			If !ViewPV(aDados[i][nPosC5_EMISSAO],aDados[i][nPosC5_P_NUM],aDados[i][nPosC6_PRODUTO])
				aAdd(aLog,{"",IIF(nPosC5_EMISSAO<>0,aDados[i][nPosC5_EMISSAO],""),;
							IIF(nPosC5_P_NUM<>0,aDados[i][nPosC5_P_NUM],""),;
							IIF(nPosC5_P_REF<>0,aDados[i][nPosC5_P_REF],""),;
							IIF(nPosC6_PRODUTO<>0,aDados[i][nPosC6_PRODUTO],""),;
							IIF(nPosZX1_ID<>0,aDados[i][nPosZX1_ID],""),;
							aDados[1][nPosC5_EMISSAO]+"+"+aDados[1][nPosC5_P_NUM]+"+"+aDados[1][nPosC5_P_REF]+"+"+aDados[1][nPosC6_PRODUTO],;
							aDados[2][nPosC5_EMISSAO]+"+"+aDados[2][nPosC5_P_NUM]+"+"+aDados[2][nPosC5_P_REF]+"+"+aDados[2][nPosC6_PRODUTO],;
							aDados[i][nPosC5_EMISSAO]+"+"+aDados[i][nPosC5_P_NUM]+"+"+aDados[i][nPosC5_P_REF]+"+"+aDados[i][nPosC6_PRODUTO],;
							"E","Not found references to Sales Order",aDados[i][Len(aDados[i])]})
			EndIf
		EndIf
		//Valida se campanha ja existe no sistema
		If nPosC5_EMISSAO <> 0 .and. nPosC5_P_NUM <> 0 .and. nPosC6_PRODUTO <> 0 .and. nPosZX1_ID <> 0
			If ViewCamp(aDados[i][nPosC5_EMISSAO],aDados[i][nPosC5_P_NUM],aDados[i][nPosC5_P_REF],aDados[i][nPosC6_PRODUTO],aDados[i][nPosZX1_ID])
				aAdd(aLog,{"",IIF(nPosC5_EMISSAO<>0,aDados[i][nPosC5_EMISSAO],""),;
							IIF(nPosC5_P_NUM<>0,aDados[i][nPosC5_P_NUM],""),;
							IIF(nPosC5_P_REF<>0,aDados[i][nPosC5_P_REF],""),;
							IIF(nPosC6_PRODUTO<>0,aDados[i][nPosC6_PRODUTO],""),;
							IIF(nPosZX1_ID<>0,aDados[i][nPosZX1_ID],""),;
							"","","","E","Duplicate Campaigns",aDados[i][Len(aDados[i])]})
			EndIf
		EndIf
	EndIf
Next i

//Gravação
If !lCritErro
	For i:=3 to Len(aDados)
		If aScan(aLog,{|x| ALLTRIM(x[aScan(aLog[2],{|x|x==ALLTRIM("C5_EMISSAO")})]) == ALLTRIM(aDados[i][nPosC5_EMISSAO]) .and.;
							ALLTRIM(x[aScan(aLog[2],{|x|x==ALLTRIM("C5_P_NUM")})]) == ALLTRIM(aDados[i][nPosC5_P_NUM]) .and.;
							ALLTRIM(x[aScan(aLog[2],{|x|x==ALLTRIM("C5_P_REF")})]) == ALLTRIM(aDados[i][nPosC5_P_REF]) .and.;
							ALLTRIM(x[aScan(aLog[2],{|x|ALLTRIM(UPPER(x))==ALLTRIM("STATUS") })]) == "E" }) == 0
			//Gravação do ZX1
			ZX1->(DbSetOrder(1))
			ZX1->(RecLock("ZX1",.T.))
			For j:=1 to Len(aDados[2])
				Do Case
					Case aDados[2][j] == "C5_EMISSAO"
						ZX1->ZX1_EMISSAO := AltData(aDados[i][j])
					Case aDados[2][j] == "C5_P_NUM"
						ZX1->ZX1_P_NUM := aDados[i][j]
					Case aDados[2][j] == "C5_P_REF"
						ZX1->ZX1_P_REF := aDados[i][j]
					Case aDados[2][j] == "C6_PRODUTO"
						ZX1->ZX1_PROD := aDados[i][j]
					Case aDados[2][j] == "ZX1_EMISSAO"
						ZX1->ZX1_EMISSA := aDados[i][j]
					Case aDados[2][j] == "ZX1_NAME"
				   		ZX1->ZX1_NAME := ConvString(aDados[i][j])
					Case aDados[2][j] == "ZX1_NAMEF"
				  		ZX1->ZX1_NAMEF := ConvString(aDados[i][j])
					Case aDados[2][j] == "ZX1_VALOR" .or. aDados[2][j] == "C6_VALOR"
						If aScan(aDados[2],{|x| ALLTRIM(x)=="ZX1_VALOR"}) <> 0 .and. VAL(aDados[i][aScan(aDados[2],{|x| ALLTRIM(x)=="ZX1_VALOR"})]) <> 0
							ZX1->ZX1_VALOR := VAL(aDados[i][aScan(aDados[2],{|x| ALLTRIM(x)=="ZX1_VALOR"})])
						ElseIf aScan(aDados[2],{|x| ALLTRIM(x)=="C6_VALOR"}) <> 0
							ZX1->ZX1_VALOR := VAL(aDados[i][aScan(aDados[2],{|x| ALLTRIM(x)=="C6_VALOR"})])
						EndIf
					OtherWise
						If ZX1->(FieldPos(aDados[2][j])) <> 0
							ZX1->(&(aDados[2][j])) := aDados[i][j]
						EndIf
				EndCase
			Next j
			ZX1->(MsUnlock())           

			aAdd(aLog,{"",IIF(nPosC5_EMISSAO<>0,aDados[i][nPosC5_EMISSAO],""),;
							IIF(nPosC5_P_NUM<>0,aDados[i][nPosC5_P_NUM],""),;
							IIF(nPosC5_P_REF<>0,aDados[i][nPosC5_P_REF],""),;
							IIF(nPosC6_PRODUTO<>0,aDados[i][nPosC6_PRODUTO],""),;
							IIF(nPosZX1_ID<>0,aDados[i][nPosZX1_ID],""),;
							"","","","S","Inserted successfully",aDados[i][Len(aDados[i])]})
		EndIf	
	Next i
EndIf

//Ajuste do Log de Processamento.
If Len(aLog) >= 3
	nPosLog1 := aScan(aLog[2],{|x|x==ALLTRIM("C5_EMISSAO")})
	nPosLog2 := aScan(aLog[2],{|x|x==ALLTRIM("C5_P_NUM")})
	nPosLog3 := aScan(aLog[2],{|x|x==ALLTRIM("C5_P_REF")})
	nPosLog4 := aScan(aLog[2],{|x|x==ALLTRIM("C6_PRODUTO")})
	nPosLog5 := aScan(aLog[2],{|x|x==ALLTRIM("ZX1_ID")})

	//Tratamento para casos que possuem itens rejeitados na integração. para apresentar log para todos.
	For i:=3 to Len(aDados)
		If aScan(aLog,{|x| ALLTRIM(x[nPosLog1]) == ALLTRIM(aDados[i][nPosC5_EMISSAO]) 	.and.;
							ALLTRIM(x[nPosLog2]) == ALLTRIM(aDados[i][nPosC5_P_NUM]) 	.and.;
							ALLTRIM(x[nPosLog3]) == ALLTRIM(aDados[i][nPosC5_P_REF])	.and.;
							ALLTRIM(x[nPosLog5]) <> ALLTRIM(aDados[i][nPosZX1_ID]) 		.and.;
							ALLTRIM(x[aScan(aLog[2],{|x|ALLTRIM(UPPER(x))==ALLTRIM("STATUS") })]) == "E" }) <> 0

			If aScan(aLog,{|x| ALLTRIM(x[nPosLog1]) == ALLTRIM(aDados[i][nPosC5_EMISSAO]) 	.and.;
							ALLTRIM(x[nPosLog2]) == ALLTRIM(aDados[i][nPosC5_P_NUM]) 	.and.;
							ALLTRIM(x[nPosLog3]) == ALLTRIM(aDados[i][nPosC5_P_REF])	.and.;
							ALLTRIM(x[nPosLog5]) == ALLTRIM(aDados[i][nPosZX1_ID]) 		.and.;
							ALLTRIM(x[aScan(aLog[2],{|x|ALLTRIM(UPPER(x))==ALLTRIM("STATUS") })]) == "E" }) == 0
							
				aAdd(aLog,{"",IIF(nPosC5_EMISSAO<>0,aDados[i][nPosC5_EMISSAO],""),;
							IIF(nPosC5_P_NUM<>0,aDados[i][nPosC5_P_NUM],""),;
							IIF(nPosC5_P_REF<>0,aDados[i][nPosC5_P_REF],""),;
							IIF(nPosC6_PRODUTO<>0,aDados[i][nPosC6_PRODUTO],""),;
							IIF(nPosZX1_ID<>0,aDados[i][nPosZX1_ID],""),;
							"","","","E","There is another item in the request rejected",aDados[i][Len(aDados[i])]})				
			EndIf
		EndIf
	Next i
    
	//Para manter as linhas de cabeçalho no local correto
	aLog[1][nPosLog1] := "AAAAA"+aLog[1][nPosLog1]
	aLog[2][nPosLog1] := "AAAAB"+aLog[2][nPosLog1]
	
	aSort(aLog,,,{|x,y| x[nPosLog1]+x[nPosLog2]+x[nPosLog3]+x[nPosLog4]+x[nPosLog5] < y[nPosLog1]+y[nPosLog2]+y[nPosLog3]+y[nPosLog4]+y[nPosLog5] })

	//Restaura os dados alterados
	aLog[1][nPosLog1] := SubStr(aLog[1][nPosLog1],6,Len(aLog[1][nPosLog1]) )
	aLog[2][nPosLog1] := SubStr(aLog[2][nPosLog1],6,Len(aLog[2][nPosLog1]) )

	nSeq := 1
	cChave := aLog[3][nPosLog1]+aLog[3][nPosLog2]+aLog[3][nPosLog3]+aLog[3][nPosLog4]+aLog[3][nPosLog5]
	
	For i:=3 to Len(aLog)
		If cChave <> aLog[i][nPosLog1]+aLog[i][nPosLog2]+aLog[i][nPosLog3]+aLog[i][nPosLog4]+aLog[i][nPosLog5]
			nSeq := 1
			cChave := aLog[i][nPosLog1]+aLog[i][nPosLog2]+aLog[i][nPosLog3]+aLog[i][nPosLog4]+aLog[i][nPosLog5]
		EndIf
		alog[i][aScan(aLog[2],{|x|x==ALLTRIM("SEQ")})] := ALLTRIM(STR(nSeq))
		nSeq ++
	Next i
EndIf


Return .T.

/*
Funcao      : NewCabLog
Parametros  : 
Retorno     :
Objetivos   : Gravação dos Log.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*-------------------------*
Static Function NewCabLog()
*-------------------------*
aLOG01 := {}
aLOG02 := {}
aLOG03 := {}

aAdd(aLOG01,{'SEQ','TWI_CUSTOMER_NUMBER','GT_COMPANY_ID','STATUS','Twitter_Reference','GT_Reference','VALUE','ERROR_MESSAGE','File'})
aAdd(aLOG01,{'SEQ','A1_P_ID','A1_COD','STATUS','Twitter Reference','GT Reference','VALUE','ERROR_MESSAGE','File'})
aAdd(aLOG02,{'SEQ','Billing_Period','IO_Number','IO_Line_Number','Item_Number','IO_number_GT','Twitter_Reference','GT_Reference','Value','Status','Error Message','File'})
aAdd(aLOG02,{'SEQ','C5_EMISSAO','C5_P_NUM','C5_P_REF','C6_PRODUTO','C5_NUM','Twitter_Reference','GT_Reference','Value','Status','Error_Message','File'})
aAdd(aLOG03,{'SEQ','Billing_Period','IO_Number','IO_Line_Number','Item_Number','Campaign_Id','Twitter_Reference','GT_Reference','VALUE','Status','Error_Message','File'})
aAdd(aLOG03,{'SEQ','C5_EMISSAO','C5_P_NUM','C5_P_REF','C6_PRODUTO','ZX1_ID','Twitter_Reference','GT_Reference','Value','Status','Error_Message','File'})

Return .T.

/*
Funcao      : VldCPFeCNPJ
Parametros  : 
Retorno     :
Objetivos   : Validação do Numero do CNPJ e do CPF.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*--------------------------------*
Static Function VldCPFeCNPJ(cInfo)
*--------------------------------*
Local lRet := .F.
Local i
Local nDig1 := 0
Local nDig2 := 0

Local cDigito := ""

Default cInfo := ""

//Retira espaços em branco
cInfo := ALLTRIM(cInfo)

//Retira pontuações
cInfo := STRTRAN(cInfo,".","")
cInfo := STRTRAN(cInfo,"-","")
cInfo := STRTRAN(cInfo,"/","")

//Grava o Digito Verificador
cDigito := RIGHT(cInfo,2)

If LEN(cInfo) == 11//CPF
	//Validação do 1º digito verificador
	nDig1 := 0
	For i:=1 To 9//Len(cInfo)
		nDig1 += VAL(SUBSTR(cInfo,i,1))*i
	Next i
    nDig1 := Mod(nDig1,11)
   	If nDig1 == 10
    	nDig1 := 0
	EndIf
   
	nDig2 := 0
	For i:=1 To 9//Len(cInfo)
		nDig2 += VAL(SUBSTR(cInfo,i,1))*(i-1)
	Next i
	nDig2 += nDig1 * 9
    nDig2 := Mod(nDig2,11)
   	If nDig2 == 10
    	nDig2 := 0
	EndIf 
	lRet := cDigito == ALLTRIM(STR(nDig1))+ALLTRIM(STR(nDig2))

	If lRet
		For i:=1 to 9
			If Replicate(ALLTRIM(STR(i)),09) == LEFT(cInfo,9)
				Return .F.//Retorna Erro, não pode numeros repetidos.
			EndIf
		Next i
	EndIf

ElseIf LEN(cInfo) == 14//CNPJ
	//Validação do 1º digito verificador
	nDig1 := 0
	nMult := 6
	For i:=1 To 12
		nDig1 += VAL(SUBSTR(cInfo,i,1))*nMult
		nMult ++
		If nMult == 10
			nMult := 2
		EndIf 
	Next i
    nDig1 := Mod(nDig1,11)
   	If nDig1 == 10
    	nDig1 := 0
	EndIf
   
	nDig2 := 0
	nMult := 5
	For i:=1 To 12
		nDig2 += VAL(SUBSTR(cInfo,i,1))*nMult
		nMult ++
		If nMult == 10
			nMult := 2
		EndIf 
	Next i
	nDig2 += nDig1 * 9
    nDig2 := Mod(nDig2,11)
   	If nDig2 == 10
    	nDig2 := 0
	EndIf 
	lRet := cDigito == ALLTRIM(STR(nDig1))+ALLTRIM(STR(nDig2))

	If lRet
		For i:=1 to 9
			If Replicate(ALLTRIM(STR(i)),12) == LEFT(cInfo,12)
				Return .F.//Retorna Erro, não pode numeros repetidos.
			EndIf
		Next i
	EndIf
EndIf

Return lRet

/*
Funcao      : GetCodMun
Parametros  : 
Retorno     :
Objetivos   : Retorna o Codigo do Municipio
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*-------------------------------------------*
Static Function GetCodMun(cEstado,cMunicipio)
*-------------------------------------------*
Local cRet := ""

//Valida se estão preenchidas
If EMPTY(cEstado) .or. EMPTY(cMunicipio)
	Return cRet
EndIf

//Busca o Codigo do Municipio
If Select("QRY") > 0
	QRY->(DbClosearea())
Endif  

cQuery := " Select CC2_CODMUN"
cQuery += " From "+RETSQLNAME("CC2")
cQuery += " Where D_E_L_E_T_ <> '*'
cQuery += "		AND CC2_EST = '"+ALLTRIM(cEstado)+"'
cQuery += "		AND UPPER(CC2_MUN) = '"+ALLTRIM(cMunicipio)+"'

dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)

QRY->(DbGoTop())
If QRY->(!EOF())
	If !EMPTY(QRY->CC2_CODMUN)
		cRet := QRY->CC2_CODMUN
	EndIf
EndIf

Return cRet

/*
Funcao      : AltData
Parametros  : 
Retorno     :
Objetivos   : Ajuste da Data
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*----------------------------------*
Static Function AltData(cInfo,cTipo)
*----------------------------------*
Local xRet
Local cMes := ""
Local cAno := ""

Default cTipo := "1"

If cTipo == "1"
	cMes := UPPER(LEFT(cInfo,3))
	cAno := RIGHT(cInfo,2)
	cNewDay := "01/"
	Do Case
		Case cMes == "JAN"
			cNewDay += "01/"
		Case cMes == "FEB"
			cNewDay += "02/"
		Case cMes == "MAR"
			cNewDay += "03/"
		Case cMes == "APR"
			cNewDay += "04/"
		Case cMes == "MAY"
			cNewDay += "05/"
		Case cMes == "JUN"
			cNewDay += "06/"
		Case cMes == "JUL"
			cNewDay += "07/"
		Case cMes == "AUG"
			cNewDay += "08/"
		Case cMes == "SEP"
			cNewDay += "09/"
		Case cMes == "OCT"
			cNewDay += "10/"
		Case cMes == "NOV"
			cNewDay += "11/"
		Case cMes == "DEC"
			cNewDay += "12/"
	EndCase
	cNewDay += cAno
	xRet := cTod(cNewDay)
Else
	cMes := ""
	cNewDay := SUBSTR(cInfo,5,2)
	cAno := SUBSTR(cInfo,3,2)
	Do Case
		Case cNewDay == "01"
			cMes += "JAN"
		Case cNewDay == "02"
			cMes += "FEB"
		Case cNewDay == "03
			cMes += "MAR"
		Case cNewDay == "04"
			cMes += "APR"
		Case cNewDay == "05"
			cMes += "MAY"
		Case cNewDay == "06"
			cMes += "JUN"
		Case cNewDay == "07"
			cMes += "JUL"
		Case cNewDay == "08"
			cMes += "AUG"
		Case cNewDay == "09"
			cMes += "SEP"
		Case cNewDay == "10"
			cMes += "OCT"
		Case cNewDay == "11"
			cMes += "NOV"
		Case cNewDay == "12"
			cMes += "DEC"
	EndCase
	xRet := cMes+"-"+cAno
EndIf

Return xRet

/*
Funcao      : ClieTw
Parametros  :
Retorno     :
Objetivos   : Buscar infromações do cliente pelo ID proprio
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*------------------------------*
Static Function ClieTw(cId,cCGC)
*------------------------------*
Local aRet := {}

Default lOnlyView := .F.
Default cId := ""
Default cCgc := ""

If Select("QRY") > 0
	QRY->(DbClosearea())
Endif  
cQuery := " Select Top 1 *"
cQuery += " From "+RETSQLNAME("SA1")
cQuery += " Where A1_P_ID = '"+ALLTRIM(cId)+"'
If !EMPTY(cCgc)
	cQuery += " 	AND A1_CGC = '"+ALLTRIM(cCGC)+"'
EndIf
cQuery += " 	AND D_E_L_E_T_ <> '*'

dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)

QRY->(DbGoTop())
If QRY->(!EOF())
	aRet := {QRY->A1_COD,QRY->A1_LOJA}
EndIf

Return aRet

/*
Funcao      : CondPag
Parametros  :
Retorno     :
Objetivos   : Validar a condição de pagamento
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*----------------------------*
Static Function CondPag(cCond)
*----------------------------*
Local cRet := ""

If Select("QRY") > 0
	QRY->(DbClosearea())
Endif  
cQuery := " Select *"
cQuery += " From "+RETSQLNAME("SE4")
cQuery += " Where E4_P_DESC = '"+ALLTRIM(cCond)+"'
cQuery += " 	AND D_E_L_E_T_ <> '*'

dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)

QRY->(DbGoTop())
If QRY->(!EOF())
	cRet := QRY->E4_CODIGO
EndIf

Return cRet

/*
Funcao      : GetTES
Parametros  :
Retorno     :
Objetivos   : Busca a tes de acordo com o produto
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*----------------------------*
Static Function GetTES(cProd)
*----------------------------*
Local cRet := ""

If Select("QRY") > 0
	QRY->(DbClosearea())
Endif  
cQuery := " Select *"
cQuery += " From "+RETSQLNAME("SB1")
cQuery += " Where B1_COD = '"+ALLTRIM(cProd)+"'
cQuery += " 	AND D_E_L_E_T_ <> '*'

dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)

QRY->(DbGoTop())
If QRY->(!EOF())
	cRet := QRY->B1_TS
EndIf

Return cRet

/*
Funcao      : ValTES
Parametros  :
Retorno     :
Objetivos   : Validar a TES utilizada.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*----------------------------*
Static Function ValTES(cTes)
*----------------------------*
Local cRet := ""

If Select("QRY") > 0
	QRY->(DbClosearea())
Endif  
cQuery := " Select Z2_CFOP"
cQuery += " From "+RETSQLNAME("SZ2")
cQuery += " Where Z2_TES = '"+ALLTRIM(cTes)+"'
cQuery += " 	AND D_E_L_E_T_ <> '*'
cQuery += " 	AND Z2_EMPRESA = '"+cEmpAnt+cFilAnt+"'

dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)

QRY->(DbGoTop())
If QRY->(!EOF())
	cRet := QRY->Z2_CFOP
EndIf

Return cRet

/*
Funcao      : ValProd
Parametros  :
Retorno     :
Objetivos   : Validar o Produto
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*----------------------------*
Static Function ValProd(cProd)
*----------------------------*
Local lRet := .F.

If Select("QRY") > 0
	QRY->(DbClosearea())
Endif  
cQuery := " Select COUNT(*) AS COUNT"
cQuery += " From "+RETSQLNAME("SB1")
cQuery += " Where B1_COD = '"+ALLTRIM(cProd)+"'
cQuery += " 	AND D_E_L_E_T_ <> '*'

dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)

lRet := QRY->COUNT <> 0

Return lRet

/*
Funcao      : ViewPV
Parametros  :
Retorno     :
Objetivos   : Validar se ja existe o pedido do cliente.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*-----------------------------------------------------------------*
Static Function ViewPV(cC5_EMISSAO,cC5_P_NUM,cC6_PRODUTO)
*-----------------------------------------------------------------*
Local lRet := .F.

Default cC6_PRODUTO := ""

cC5_EMISSAO := DtoS(AltData(cC5_EMISSAO))

If Select("QRY") > 0
	QRY->(DbClosearea())
Endif  
cQuery := " Select COUNT(*) AS COUNT"
cQuery += " From "+RETSQLNAME("SC5")+" SC5
//Quando informado o Produto, executa Join no SC6
If !EMPTY(cC6_PRODUTO)
	cQuery += "			Inner join (Select * From "+RETSQLNAME("SC6")+" Where C6_PRODUTO = '"+cC6_PRODUTO+"' ) AS SC6 on 
	cQuery += "																						SC5.C5_FILIAL 	= SC6.C6_FILIAL	AND 
	cQuery += "																						SC5.C5_NUM 		= SC6.C6_NUM 	AND
	cQuery += "																						SC5.C5_P_NUM 	= SC6.C6_P_NUM
EndIf
cQuery += " Where SC5.C5_EMISSAO = '"+ALLTRIM(cC5_EMISSAO)+"'
cQuery += " 	AND SC5.C5_P_NUM = '"+ALLTRIM(cC5_P_NUM)+"'
cQuery += " 	AND SC5.D_E_L_E_T_ <> '*'

dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)

lRet := QRY->COUNT <> 0

Return lRet

/*
Funcao      : ViewCamp
Parametros  :
Retorno     :
Objetivos   : Validar se ja existe o pedido do cliente.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*------------------------------------------------------------------------------*
Static Function ViewCamp(cC5_EMISSAO,cC5_P_NUM,cC5_P_REF,cC6_PRODUTO,cPosZX1_ID)
*------------------------------------------------------------------------------*
Local lRet := .F.

cC5_EMISSAO := DtoS(AltData(cC5_EMISSAO))

If Select("QRY") > 0
	QRY->(DbClosearea())
Endif  
cQuery := " Select COUNT(*) AS COUNT"
cQuery += " From "+RETSQLNAME("ZX1")
cQuery += " Where ZX1_EMISSA 	= '"+ALLTRIM(cC5_EMISSAO)+"'
cQuery += " 	AND ZX1_PROD	= '"+ALLTRIM(cC6_PRODUTO)+"'
cQuery += " 	AND ZX1_P_NUM 	= '"+ALLTRIM(cC5_P_NUM)+"'
cQuery += " 	AND ZX1_P_REF 	= '"+ALLTRIM(cC5_P_REF)+"'
cQuery += " 	AND ZX1_ID 		= '"+ALLTRIM(cPosZX1_ID)+"'
cQuery += " 	AND D_E_L_E_T_ <> '*'

dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)

lRet := QRY->COUNT <> 0

Return lRet                      

/*
Funcao      : MailLog
Parametros  :
Retorno     :
Objetivos   : envia email de processamento
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*----------------------------------------*
Static Function MailLog(cArqLog, aLogMail)
*----------------------------------------*
Local i
Local cQuery := ""

Local cArqMail := ""

Private nOk := 0
Private nErro := 0

Private cFrom		:= "totvs@hlb.com.br"
Private cTo			:= ""
Private cMsg		:= ""
Private cSubject	:= Capital(SUBSTR(cArqLog,4,AT("OB",cArqLog)-5)+" INTERFACE")

Private cArq  := UPPER(LEFT(cArqLog,LEN(cArqLog)-3))+LOWER(RIGHT(cArqLog,3))
Private cDate := ""
Private cTime := ""
Private cUser := ""

Do Case
	Case SUBSTR(cArqLog,4,AT("OB",cArqLog)-5) == "CUSTOMER"
		cTo := cEmailA1

	Case SUBSTR(cArqLog,4,AT("OB",cArqLog)-5) == "SALESORDER"
		cTo := cEmailA5

	Case SUBSTR(cArqLog,4,AT("OB",cArqLog)-5) == "CAMPAIGNS"
		cTo := cEmailZX

	Case SUBSTR(cArqLog,4,AT("IB",cArqLog)-5) == "INVOICE"
		cTo := cEmailZX

	Case SUBSTR(cArqLog,4,AT("IB",cArqLog)-5) == "RECEIPTS"
		cTo := cEmailZX

EndCase

//Realiza a contagem dos Logs para montagem do Email
If aRefArq[oGetDados:NAT][4] == "IN"
	If Len(aLogMail) > 2
		For i:=3 to Len(aLogMail)
			If ALLTRIM(aLogMail[i][aScan(aLogMail[2],{|x| ALLTRIM(UPPER(x)) == "FILE"})]) == ALLTRIM(cArqLog) 
				If aLogMail[i][aScan(aLogMail[2], {|x| ALLTRIM(UPPER(x)) == "SEQ"})] == "1"
					If aLogMail[i][aScan(aLogMail[2], {|x| ALLTRIM(UPPER(x)) == "STATUS"})] == "S"
			   			nOk	++
			  		Else
						nErro ++
					EndIf
				EndIf
			EndIf
		Next i
	EndIf
Else
	cSubject := Capital(SUBSTR(cArqLog,4,AT("IB",cArqLog)-5)+" INTERFACE")
	nOk	:= aLogMail[2]
EndIf

//Busca os dados do log gravado
If Select("QRY") > 0
	QRY->(DbClosearea())
Endif  
cQuery := " Select *"
cQuery += " From "+RETSQLNAME("ZX2")
cQuery += " Where ZX2_ARQ = '"+ALLTRIM(UPPER(cArqLog))+"'
cQuery += " 	AND D_E_L_E_T_ <> '*'

dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)

QRY->(DbGoTop())
If QRY->(!EOF())
	cDate := DTOCEUA(STOD(QRY->ZX2_DATA))
	cTime := QRY->ZX2_HORA
	cUser := QRY->ZX2_USER
EndIf
If Select("QRY") > 0
	QRY->(DbClosearea())
Endif 

//Tratamento para envio do Arquivo de log anexo ao Email. 
cArqMail := ""
cFile := ""
cArqZip := ""

cArqMail += SUBSTR(cArqLog,1,AT("OB_",cArqLog)+2)
cArqMail += "LOG"
cArqMail += SubStr(cArqLog,AT("OB_",cArqLog)+2,Len(cArqLog))
cArqMail := UPPER(cArqMail)

cFile	:= cDirSrvOut+"\"+cArqMail
If AT("_OB_",cFile) <> 0//compacta somente quando for processamento de entrada.
	cArqZip	:= cDirSrvOut+"\"+LEFT(cArqMail,LEN(cArqMail)-3)+"ZIP"
	lCompacta := compacta(cFile,cArqZip,.F.)
EndIf

cMsg := Email()

oEmail          := DEmail():New()
oEmail:cFrom   	:= cFrom
oEmail:cTo		:= PADR(cTo,200)
oEmail:cSubject	:= padr(cSubject,200)
If File(cArqZip)
	oEmail:cAnexos := cArqZip
EndIf
oEmail:cBody   	:= cMsg
oEmail:lExibMsg := .F.
oEmail:Envia()

If File(cArqZip)
	FERASE(cArqZip)
EndIf

Return .T.       

/*
Funcao      : Email
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Criar Email de Notificação
Autor       : Jean Victor Rocha
Data/Hora   : 
Autor       : Jean Victor Rocha	
Data/Hora   : 
*/
*---------------------*
Static Function Email()
*---------------------*
Local cHtml := ""

cHtml += '<html>
cHtml += '	<head>
cHtml += '	<title>Modelo-Email</title>
cHtml += '	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
cHtml += '	</head>
cHtml += '	<body bgcolor="#FFFFFF" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
cHtml += '		<table id="Tabela_01" width="631" height="342" border="0" cellpadding="0" cellspacing="0">
cHtml += '			<tr><td width="631" height="10"></td></tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="1" bgcolor="#8064A1"></td>
cHtml += '			</tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="25"> <font size="2" face="tahoma" color="#551A8B"><b>FILE PROCESSED '+cArq+'</b></font>   </td>
cHtml += '			</tr>
cHtml += '			<tr><td width="631" height="1" bgcolor="#8064A1"></td></tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="25" bgcolor="#E5DFEB"><font size="2" face="tahoma" color="#8064A1">DATE: '+ALLTRIM(cDate)+'</font></td>
cHtml += '			</tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="26"><font size="2" face="tahoma" color="#8064A1">TIME: '+ALLTRIM(cTime)+'</font></td>
cHtml += '			</tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="25" bgcolor="#E5DFEB"><font size="2" face="tahoma" color="#8064A1">USER: '+ALLTRIM(cUser)+'</font></td>
cHtml += '			</tr>
cHtml += '			<tr><td width="631" height="1" bgcolor="#8064A1"></td></tr>
cHtml += '			<tr><td width="631" height="20"></td></tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="25">
If aRefArq[oGetDados:NAT][4] == "IN"
	cHtml += '					<br><font size="2" face="tahoma">'+ALLTRIM(STR(nOk))	+' records processed successfully </font>
	cHtml += '					<br><font size="2" face="tahoma">'+ALLTRIM(STR(nErro))	+' records processed with errors</font>

Else
	cHtml += '					<br><font size="2" face="tahoma">'+ALLTRIM(STR(nOk))	+' records processed successfully </font>

EndIf
cHtml += '				</td>
cHtml += '			</tr>
cHtml += '			<tr><td width="631" height="20"></td></tr>
cHtml += '			<tr><td width="631" height="1" bgcolor="#8064A1"></td></tr>
cHtml += '			<tr><td width="631" height="20"></td></tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="20"><p align=center>Automatic message, no answer.</p></td>
cHtml += '			</tr>
cHtml += '		</table>
cHtml += '	</body>
cHtml += '</html>

Return cHtml

/*
Funcao      : GetInv
Parametros  :
Retorno     :
Objetivos   : Buscar os dados da Invoice e carregar em tela.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*----------------------*
Static Function GetInv()
*----------------------*
Local i := 0
Local aRet := {}
Local aStruQry := SF2->(dbStruct())
Local aAux := {}
Local aHeader := &("oArq"+aRefArq[oGetDados:NAT][1]):AHEADER

If Select("QRY") > 0
	QRY->(DbClosearea())
Endif  
cQuery := " Select *"
cQuery += " From "+RETSQLNAME("SF2")+" SF2
cQuery += "		Left OUter Join (Select * From "+RETSQLNAME("SE4")+" where D_E_L_E_T_ <> '*') as SE4 on SE4.E4_CODIGO = SF2.F2_COND 
cQuery += "		Left OUter Join (Select * From "+RETSQLNAME("SC5")+" where D_E_L_E_T_ <> '*') as SC5 on SC5.C5_P_NUM = SF2.F2_P_NUM AND SC5.C5_NOTA = SF2.F2_DOC AND SC5.C5_SERIE = SF2.F2_SERIE" // MSM - 07/04/2015 - Alterado para evitar duplicidade
cQuery += " Where SF2.D_E_L_E_T_ <> '*'
cQuery += "		AND SF2.F2_P_NUM <> ''
cQuery += "	AND (SE4.E4_P_DESC <> 'PREPAYMENT' OR 
cQuery += "				(SE4.E4_P_DESC = 'PREPAYMENT' AND SC5.C5_P_INT <> 'N')
cQuery += "		)
If !EMPTY(cPar01)
	cQuery += "		AND SF2.F2_EMISSAO >= '"+ALLTRIM(cPar01)+"'
EndIf
If !EMPTY(cPar02)
	cQuery += "		AND SF2.F2_EMISSAO <= '"+ALLTRIM(cPar02)+"'
EndIf
If !EMPTY(cPar03)
	cQuery += "		AND SF2.F2_DOC >= '"+ALLTRIM(cPar03)+"'
EndIf
If !EMPTY(cPar04)
	cQuery += "		AND SF2.F2_DOC <= '"+ALLTRIM(cPar04)+"'
EndIf
If !EMPTY(cPar05)
	cQuery += "		AND SF2.F2_SERIE >= '"+ALLTRIM(cPar05)+"'
EndIf
If !EMPTY(cPar06)
	cQuery += "		AND SF2.F2_SERIE <= '"+ALLTRIM(cPar06)+"'
EndIf
If nPar01 <> 1
	cQuery += "		AND SF2.F2_P_ARQ = ''
EndIf

dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)

For i := 1 To Len(aStruQry)
	If aStruQry[i][2] <> "C" .and. FieldPos(aStruQry[i][1]) > 0
		TcSetField("QRY",aStruQry[i][1],aStruQry[i][2],aStruQry[i][3],aStruQry[i][4])
	EndIf
Next i

QRY->(DbGoTop())
While QRY->(!EOF())
	aAux := {}
	For i:=1 to Len(aHeader)
		Do Case
			Case aHeader[i][2] == "SEL"
				aAdd(aAux,oSelN)

			Case aHeader[i][2] == "STS"
   				If !EMPTY(QRY->F2_P_ARQ)
	   				aAdd(aAux,oStsEr)
	   		   	Else
	   		   		aAdd(aAux,oStsOk)
	   			EndIf

			OtherWise
				aAdd(aAux,QRY->(&(STRTRAN(aHeader[i][2],"WK","")))  )

		EndCase
	Next i
	aAdd(aAux,.F.)

	aAdd(aRet,aAux)
	
	QRY->(DbSkip())
EndDo

Return aRet

/*
Funcao      : GetPag
Parametros  :
Retorno     :
Objetivos   : Buscar os dados do Pagamento e carregar em tela.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*----------------------*
Static Function GetPag()
*----------------------*
Local i := 0
Local aRet := {}
Local aStruQry := SE1->(dbStruct())
Local aAux := {}
Local aHeader := &("oArq"+aRefArq[oGetDados:NAT][1]):AHEADER

If Select("QRY") > 0
	QRY->(DbClosearea())
Endif  
cQuery := " Select *"
cQuery += " From "+RETSQLNAME("SE1")+" SE1
cQuery += " 	Left OUter Join (Select * From "+RETSQLNAME("SC5")+" where D_E_L_E_T_ <> '*') as SC5 on SC5.C5_NUM = SE1.E1_PEDIDO
cQuery += " 	Left OUter Join (Select * From "+RETSQLNAME("SE4")+" where D_E_L_E_T_ <> '*') as SE4 on SE4.E4_CODIGO = SC5.C5_CONDPAG 
cQuery += " Where SE1.D_E_L_E_T_ <> '*'
cQuery += "		AND SE1.E1_P_NUM <> ''
cQuery += "		AND SE1.E1_BAIXA <> ''
cQuery += "		AND (SE4.E4_P_DESC <> 'PREPAYMENT' OR 
cQuery += "				(SE4.E4_P_DESC = 'PREPAYMENT' AND SC5.C5_P_INT = 'N')
cQuery += "			)
If !EMPTY(cPar01)
	cQuery += "		AND SE1.E1_EMISSAO >= '"+ALLTRIM(cPar01)+"'
EndIf
If !EMPTY(cPar02)
	cQuery += "		AND SE1.E1_EMISSAO <= '"+ALLTRIM(cPar02)+"'
EndIf
If nPar01 <> 1
	cQuery += "		AND SE1.E1_P_ARQ = ''
EndIf

dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)

For i := 1 To Len(aStruQry)
	If aStruQry[i][2] <> "C" .and. FieldPos(aStruQry[i][1]) > 0
		TcSetField("QRY",aStruQry[i][1],aStruQry[i][2],aStruQry[i][3],aStruQry[i][4])
	EndIf
Next i

QRY->(DbGoTop())
While QRY->(!EOF())
	aAux := {}
	For i:=1 to Len(aHeader)
		Do Case
			Case aHeader[i][2] == "SEL"
				aAdd(aAux,oSelN)

			Case aHeader[i][2] == "STS"
   				If !EMPTY(QRY->E1_P_ARQ)
	   				aAdd(aAux,oStsEr)
	   		   	Else
	   		   		aAdd(aAux,oStsOk)
	   			EndIf
			
			OtherWise
				aAdd(aAux,QRY->(&(STRTRAN(aHeader[i][2],"WK","")))  )

		EndCase
	Next i
	aAdd(aAux,.F.)

	aAdd(aRet,aAux)
	
	QRY->(DbSkip())
EndDo

Return aRet

/*
Funcao      : GravaSF2
Parametros  : 
Retorno     :
Objetivos   : Geração dos Arquivos.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*-------------------------------------------*
Static Function GravaSF2(aHeaderSF2,aColsSF2)
*-------------------------------------------*
Local i,j
Local aLayout := {}
Local cArquivo := UPPER(aRefArq[oGetDados:NAT][2]+DTOS(Date())+LEFT(STRTRAN(TIME(),":",""),4))+".csv"
Local cLinha := ""
Local nCount := 0

Private nHandle := 0

//Grava Tabela de log
GrvTabLog(cArquivo)

//Carrega o Layout Fornecido pelo Cliente.
aAdd(aLayout,{"Billing_Period","IO_Number","IO_Line_Number","IO_number_GT","GT_Invoice_Num","GT_Invoice_serie","Customer_Number","Invoice_Date","Item_Number","Item_Description","Tax_ISS_Amount","Tax_IRRF_Amount","Tax_Cofins_Amount","Tax_Pis_Amount","Currency","Tax_Amount","Invoice_Amount","Attribute1","Attribute2","Attribute3","Attribute4","Attribute5","Attribute6","Attribute7","Attribute8","Attribute9","Attribute10"})
aAdd(aLayout,{"C5_EMISSAO","C5_P_NUM","C5_P_REF","C5_NUM","D2_DOC","D2_SERIE","A1_P_ID","D2_EMISSAO","C6_PRODUTO","C6_DESCRI","D2_VALISS","D2_VALIRRF","D2_VALIMP5","D2_VALIMP6","C5_P_MOED","TAXAMOUNT","D2_TOTAL","Attribute1","Attribute2","Attribute3","Attribute4","Attribute5","Attribute6","Attribute7","Attribute8","Attribute9","Attribute10"})

nHandle := FCREATE(cDirSrvOut+"\"+cArquivo,0,,.F.)

//Grava o Cabeçalho do arquivo
For i:=1 to Len(aLayout)
	cLinha := ""
	For j:=1 to Len(aLayout[i])
		cLinha += aLayout[i][j]+cDelimitador
	Next j
	cLinha := LEFT(cLinha,Len(cLinha)-1)
	FWrite(nHandle,cLinha+ CRLF)
Next i

//Grava os registros selecionados
nCount := 0
For i:=1 to len(aColsSF2)
	If aColsSF2[i][aScan(aHeaderSF2,{|x|ALLTRIM(x[2])=="SEL"})] == oSelS .and.;
		EMPTY(aColsSF2[i][aScan(aHeaderSF2,{|x|ALLTRIM(x[2])=="WK"+"F2_P_ARQ"})])
		cLinha := ""
		//Grava Linha do Arquivo
		cLinha := LinhaSF2(aColsSF2[i][aScan(aHeaderSF2,{|x|ALLTRIM(x[2])=="R_E_C_N_O_"})],aHeaderSF2)
   		FWrite(nHandle,cLinha+CRLF)
		nCount ++

		//Grava F2_P_ARQ
		SF2->(DbSetOrder(1))
		SF2->(DbGoTo(aColsSF2[i][aScan(aHeaderSF2,{|x|ALLTRIM(x[2])=="R_E_C_N_O_"})]))
		SF2->(RecLock("SF2",.F.))
		SF2->F2_P_ARQ := ALLTRIM(cArquivo)
		SF2->(MsUnlock())
		
		//Grava D2_P_ARQ
		SD2->(DbSetOrder(3))//D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
		SD2->(DbSeek(SF2->F2_FILIAL + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE ))
		While SD2->(!EOF()) .and.	SD2->D2_FILIAL	== SF2->F2_FILIAL .and.;
									SD2->D2_DOC		== SF2->F2_DOC    .and.;
									SD2->D2_SERIE	== SF2->F2_SERIE  .and.;
									SD2->D2_CLIENTE	== SF2->F2_CLIENTE

	 		SD2->(RecLock("SD2",.F.))
	   		SD2->D2_P_ARQ := ALLTRIM(cArquivo)
	  		SD2->(MsUnlock())

			SD2->(DbSkip())							
		EndDo

	EndIf	
Next i

&("aLog"+aRefArq[oGetDados:NAT][1]) := {cArquivo,nCount}

FClose(nHandle)

Return .T.

/*
Funcao      : LinhaSF2
Parametros  : 
Retorno     :
Objetivos   : Geração da linha de de informações para SF2.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*------------------------------------------*
Static Function LinhaSF2(nRecSF2,aHeaderSF2)
*------------------------------------------*
Local cRet := ""
Local cAux := ""

If Select("QRY") > 0
	QRY->(DbClosearea())
Endif  
cQuery := " Select SC5.C5_EMISSAO as C5_EMISSAO,
cQuery += " 		SF2.F2_P_NUM as C5_P_NUM,
cQuery += " 		SD2.D2_P_REF as C5_P_REF,
cQuery += " 		SD2.D2_PEDIDO as C5_NUM,
cQuery += " 		SF2.F2_DOC as D2_DOC,
cQuery += " 		SF2.F2_SERIE as D2_SERIE,
cQuery += " 		SA1.A1_P_ID as A1_P_ID,
cQuery += " 		SF2.F2_EMISSAO as D2_EMISSAO,
cQuery += " 		SD2.D2_COD as C6_PRODUTO,
cQuery += " 		SB1.B1_DESC as C6_DESCRI,
//cQuery += " 		SD2.D2_VALISS as D2_VALISS,
//cQuery += " 		SD2.D2_VALIRRF as D2_VALIRRF,
//cQuery += " 		SD2.D2_VALIMP5 as D2_VALIMP5,
//cQuery += " 		SD2.D2_VALIMP6 as D2_VALIMP6,
cQuery += " 		0 as D2_VALISS,
cQuery += " 		0 as D2_VALIRRF,
cQuery += " 		0 as D2_VALIMP5,
cQuery += " 		0 as D2_VALIMP6,
cQuery += " 		SF2.F2_MOEDA as C5_P_MOED,
//cQuery += " 		SD2.D2_VALISS+SD2.D2_VALIRRF+SD2.D2_VALIMP5+SD2.D2_VALIMP6 as TAXAMOUNT,
cQuery += " 		0 as TAXAMOUNT,
cQuery += " 		SD2.D2_TOTAL as D2_TOTAL
cQuery += " From "+RETSQLNAME("SF2")+" SF2
cQuery += " 	Left Outer Join (Select * From "+RETSQLNAME("SD2")+" Where D_E_L_E_T_ <> '*') AS SD2 On SD2.D2_FILIAL = SF2.F2_FILIAL
cQuery += " 																  					AND SD2.D2_DOC = SF2.F2_DOC
cQuery += " 																					AND SD2.D2_SERIE = SF2.F2_SERIE
cQuery += " 																					AND SD2.D2_CLIENTE = SF2.F2_CLIENTE
cQuery += " 	Left Outer Join (Select * From "+RETSQLNAME("SB1")+" Where D_E_L_E_T_ <> '*') AS SB1 On SD2.D2_COD = SB1.B1_COD
cQuery += " 	Left Outer Join (Select * From "+RETSQLNAME("SA1")+" Where D_E_L_E_T_ <> '*') AS SA1 On SF2.F2_CLIENTE = SA1.A1_COD
cQuery += " 	Left Outer Join (Select * From "+RETSQLNAME("SC5")+" Where D_E_L_E_T_ <> '*') AS SC5 On SC5.C5_NUM = SD2.D2_PEDIDO
cQuery += " 															   						AND SC5.C5_P_NUM = SD2.D2_P_NUM
cQuery += " Where SF2.D_E_L_E_T_ <> '*'
cQuery += " 	AND SF2.F2_P_NUM <> ''
cQuery += " 	AND SF2.R_E_C_N_O_ = "+ALLTRIM(STR(nRecSF2))

dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)

QRY->(DbGoTop())
While QRY->(!EOF())
	If !EMPTY(cRet)
		cRet += CRLF
	EndIf
	cAux := ""
	For i:=1 to QRY->(FCount())
		Do Case
			Case QRY->(Fieldname(i)) == "C5_EMISSAO"
				cAux += ALLTRIM(AltData(QRY->(&(QRY->(Fieldname(i)))),"2"))+cDelimitador
			Case QRY->(Fieldname(i)) == "D2_EMISSAO"
				cAux += ALLTRIM(DTOCEUA(STOD(QRY->(&(QRY->(Fieldname(i))))))  )+cDelimitador
			Case QRY->(Fieldname(i)) $ "D2_VALISS/D2_VALIRRF/D2_VALIMP5/D2_VALIMP6/TAXAMOUNT/D2_TOTAL"
				cAux += ALLTRIM(TRANSFORM(QRY->(&(QRY->(Fieldname(i)))),"@R 999999999999999.99"))+cDelimitador
			Case QRY->(Fieldname(i)) == "C5_P_MOED"
				//cAux += GetMV("MV_SIMB"+ALLTRIM(STR( QRY->(&(QRY->(Fieldname(i)))) )),,QRY->(&(QRY->(Fieldname(i)))))+cDelimitador
				cAux += "BRL"+cDelimitador
			OtherWise
				cAux += ALLTRIM(QRY->(&(QRY->(Fieldname(i)))))+cDelimitador
		EndCase
	Next i
	
	cAux += REPLICATE(cDelimitador,10)//Adiciona 10 campos vazios de "Attribute"
	
	cAux := LEFT(cAux,LEN(cAux)-1)
	
	cRet += cAux
	QRY->(DbSkip())
EndDo

Return cRet

/*
Funcao      : GravaSE1
Parametros  : 
Retorno     :
Objetivos   : Geração dos Arquivos.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*-------------------------------------------*
Static Function GravaSE1(aHeaderSE1,aColsSE1)
*-------------------------------------------*
Local i,j
Local aLayout := {}
Local cArquivo := UPPER(aRefArq[oGetDados:NAT][2]+DTOS(Date())+LEFT(STRTRAN(TIME(),":",""),4))+".csv"
Local cLinha := ""
Local nCount := 0

Private nHandle := 0

//Grava Tabela de log
GrvTabLog(cArquivo)

//Carrega o Layout Fornecido pelo Cliente.
aAdd(aLayout,{"GT_Receipt_Number","Customer_number","Receipt_Amount","Currency","Receipt_Date","Comments","GT_Invoice_Number","GT_Invoice_Serie","IO_Number","GT_IO_Number","Attribute1","Attribute2","Attribute3","Attribute4","Attribute5","Attribute6","Attribute7","Attribute8","Attribute9","Attribute10"})
aAdd(aLayout,{"E1_NUM","A1_P_ID","E1_VALOR","C5_CURRENCY","E1_BAIXA","E1_P_OBS","F2_DOC","F2_SERIE","C5_P_NUM","C5_NUM","Attribute1","Attribute2","Attribute3","Attribute4","Attribute5","Attribute6","Attribute7","Attribute8","Attribute9","Attribute10"})

nHandle := FCREATE(cDirSrvOut+"\"+cArquivo,0,,.F.)

//Grava o Cabeçalho do arquivo
For i:=1 to Len(aLayout)
	cLinha := ""
	For j:=1 to Len(aLayout[i])
		cLinha += aLayout[i][j]+cDelimitador
	Next j
	cLinha := LEFT(cLinha,Len(cLinha)-1)
	FWrite(nHandle,cLinha+ CRLF)
Next i

//Grava os registros selecionados
nCount := 0
For i:=1 to len(aColsSE1)
	If aColsSE1[i][aScan(aHeaderSE1,{|x|ALLTRIM(x[2])=="SEL"})] == oSelS .and.;
		EMPTY(aColsSE1[i][aScan(aHeaderSE1,{|x|ALLTRIM(x[2])=="WK"+"E1_P_ARQ"})])
		cLinha := ""
		//Grava Linha do Arquivo
		cLinha := LinhaSE1(aColsSE1[i][aScan(aHeaderSE1,{|x|ALLTRIM(x[2])=="R_E_C_N_O_"})],aHeaderSE1)
   		FWrite(nHandle,cLinha+CRLF)
		nCount ++
		   		
		//Grava E1_P_ARQ
		SE1->(DbSetOrder(1))
		SE1->(DbGoTo(aColsSE1[i][aScan(aHeaderSE1,{|x|ALLTRIM(x[2])=="R_E_C_N_O_"})]))
		SE1->(RecLock("SE1",.F.))
		SE1->E1_P_ARQ := ALLTRIM(cArquivo)
		SE1->(MsUnlock())

	EndIf	
Next i

&("aLog"+aRefArq[oGetDados:NAT][1]) := {cArquivo,nCount}

FClose(nHandle)

Return .T.

/*
Funcao      : LinhaSE1
Parametros  : 
Retorno     :
Objetivos   : Geração da linha de de informações para SE1.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*------------------------------------------*
Static Function LinhaSE1(nRecSE1,aHeaderSE1)
*------------------------------------------*
Local cRet := ""
Local cAux := ""

If Select("QRY") > 0
	QRY->(DbClosearea())
Endif  
cQuery := " Select SE1.E1_FILIAL+SE1.E1_CLIENTE+SE1.E1_LOJA+SE1.E1_PREFIXO+SE1.E1_NUM+SE1.E1_PARCELA+SE1.E1_TIPO As E1_NUM,
cQuery += "		SA1.A1_P_ID as A1_P_ID,
//cQuery += "		SE1.E1_VALOR As E1_VALOR,
cQuery += "		SE1.E1_VALLIQ As E1_VALOR,
cQuery += "		'BRL' as C5_CURRENCY,
cQuery += "		SE1.E1_BAIXA as E1_BAIXA,
cQuery += "		'' as E1_P_OBS,
cQuery += "		SE1.E1_NUM as F2_DOC,
cQuery += "		SE1.E1_PREFIXO as F2_SERIE,
cQuery += "		SE1.E1_P_NUM as C5_P_NUM,
cQuery += "		SE1.E1_PEDIDO as C5_NUM,
cQuery += "		SE4.E4_P_DESC,SC5.C5_P_INT
cQuery += "		,CASE E1_PORTADO WHEN '487' THEN 'Brazil HLB Receipt' ELSE CASE E1_PORTADO WHEN '745' THEN 'Brazil HLB Receipt Citi' ELSE '' END END as [Attribute1] 
cQuery += " From "+RETSQLNAME("SE1")+" SE1
cQuery += "		Left Outer Join (Select * From "+RETSQLNAME("SA1")+" Where D_E_L_E_T_ <> '*') AS SA1 On SE1.E1_CLIENTE = SA1.A1_COD
cQuery += " 	Left OUter Join (Select * From "+RETSQLNAME("SC5")+" where D_E_L_E_T_ <> '*') as SC5 on SC5.C5_NUM = SE1.E1_PEDIDO 	
cQuery += " 	Left OUter Join (Select * From "+RETSQLNAME("SE4")+" where D_E_L_E_T_ <> '*') as SE4 on SE4.E4_CODIGO = SC5.C5_CONDPAG 
cQuery += " Where SE1.D_E_L_E_T_ <> '*'
cQuery += "		AND SE1.R_E_C_N_O_ = "+ALLTRIM(STR(nRecSE1))

dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)

QRY->(DbGoTop())
While QRY->(!EOF())
	If !EMPTY(cRet)
		cRet += CRLF
	EndIf
	cAux := ""
	For i:=1 to QRY->(FCount())
		If !(QRY->(Fieldname(i)) $ "E4_P_DESC/C5_P_INT" )
			lVazio := .F.
	
			If QRY->(Fieldname(i)) $ "F2_DOC/F2_SERIE/C5_P_NUM/C5_NUM" .And.;
				QRY->E4_P_DESC = 'PREPAYMENT' .And. QRY->C5_P_INT = 'N'
				lVazio := .T.
			EndIf
	
			Do Case
				Case lVazio
					cAux += ""+cDelimitador
				Case QRY->(Fieldname(i)) == "E1_BAIXA"
					cAux += ALLTRIM(DTOCEUA(STOD(QRY->(&(QRY->(Fieldname(i))))))   )+cDelimitador
				Case QRY->(Fieldname(i)) $ "E1_VALOR"
					cAux += ALLTRIM(TRANSFORM(QRY->(&(QRY->(Fieldname(i)))),"@R 999999999999999.99"))+cDelimitador
				OtherWise
					cAux += ALLTRIM(QRY->(&(QRY->(Fieldname(i))))  )+cDelimitador
			EndCase
		EndIf
	Next i
	
	cAux += REPLICATE(cDelimitador,9)//Adiciona 9 campos vazios de "Attribute" // MSM - 26/10/2015 -  Utilizado o atributo1 para especificar o banco, solicitação: De: Otavio Rodrigues [mailto:otavio@twitter.com], Enviada em: sexta-feira, 23 de outubro de 2015 17:11
	
	cAux := LEFT(cAux,LEN(cAux)-1)
	
	cRet += cAux
	QRY->(DbSkip())
EndDo

Return cRet

/*
Funcao      : FilInt
Parametros  : 
Retorno     :
Objetivos   : Filtra os dados em tela.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*----------------------*
Static Function FilInt()
*----------------------*
Local cPergunte := "TPGEN001"
Local lContinua	:= .F.

cPergunte += aRefArq[oGetDados:NAT][1]

If aRefArq[oGetDados:NAT][1] == "04"
	U_PUTSX1(cPergunte , "01","Emissao de  ?" 	," "," ","mv_ch01","D",08					,0,0,"G","     ","   ","","" ,"MV_PAR01",""	,"",""," "	,"","","" ,"","","","","","","",""," ",{"Informe a Data de Emissao Inicial"})
	U_PUTSX1(cPergunte , "02","Emissao ate ?" 	," "," ","mv_ch02","D",08					,0,0,"G","     ","   ","","" ,"MV_PAR02",""	,"",""," "	,"","","" ,"","","","","","","",""," ",{"Informe a Data de Emissao Final"})
	U_PUTSX1(cPergunte , "03","Documento de ?" 	," "," ","mv_ch03","C",TamSX3("F2_DOC")[1]	,0,0,"G","     ","SF2","","" ,"MV_PAR03",""	,"",""," "	,"","","" ,"","","","","","","",""," ",{"Informe o número da nota inicial"})
	U_PUTSX1(cPergunte , "04","Documento ate ?"	," "," ","mv_ch04","C",TamSX3("F2_DOC")[1]	,0,0,"G","     ","SF2","","" ,"MV_PAR04",""	,"",""," "	,"","","" ,"","","","","","","",""," ",{"Informe o número da nota final"})
	U_PUTSX1(cPergunte , "05","Serie de ?"  		," "," ","mv_ch05","C",TamSX3("F2_SERIE")[1],0,0,"G","     ",""	  ,"","" ,"MV_PAR05",""	,"",""," "	,"","","" ,"","","","","","","",""," ",{"Informe a Serie da nota inicial"})
	U_PUTSX1(cPergunte , "06","Serie ate ?" 		," "," ","mv_ch06","C",TamSX3("F2_SERIE")[1],0,0,"G","     ",""	  ,"","" ,"MV_PAR06",""	,"",""," "	,"","","" ,"","","","","","","",""," ",{"Informe a Serie da nota final"})
	U_PUTSX1(cPergunte , "07","Exibe Enviados?"	," "," ","mv_ch07","N",01					,0,1,"C",""		,""   ,"","" ,"mv_par07","Sim","Sim","Sim","","Nao","Nao","Nao","","","","","","","","","",{"Selecione se Exibe ou Não","Registros ja processados."})
	
ElseIf aRefArq[oGetDados:NAT][1] == "05"
	U_PUTSX1(cPergunte , "01","Emissao de  ?" 	," "," ","mv_ch01","D",08					,0,0,"G","     ","   ","","" ,"MV_PAR01",""	,"",""," "	,"","","" ,"","","","","","","",""," ",{"Informe a Data de Emissao Inicial"})
	U_PUTSX1(cPergunte , "02","Emissao ate ?" 	," "," ","mv_ch02","D",08					,0,0,"G","     ","   ","","" ,"MV_PAR02",""	,"",""," "	,"","","" ,"","","","","","","",""," ",{"Informe a Data de Emissao Final"})
	U_PUTSX1(cPergunte , "03","Exibe Enviados?"	," "," ","mv_ch03","N",01					,0,1,"C",""		,""   ,"","S","mv_par03","Sim","Sim","Sim","","Nao","Nao","Nao","","","","","","","","","",{"Selecione se Exibe ou Não","Registros ja processados."})

ElseIf aRefArq[oGetDados:NAT][1] == "06"
	U_PUTSX1(cPergunte , "01","Emissao de  ?" 	," "," ","mv_ch01","D",08					,0,0,"G","     ","   ","","" ,"MV_PAR01",""	,"",""," "	,"","","" ,"","","","","","","",""," ",{"Informe a Data de Emissao Inicial"})
	U_PUTSX1(cPergunte , "02","Emissao ate ?" 	," "," ","mv_ch02","D",08					,0,0,"G","     ","   ","","" ,"MV_PAR02",""	,"",""," "	,"","","" ,"","","","","","","",""," ",{"Informe a Data de Emissao Final"})
	U_PUTSX1(cPergunte , "03","Documento de ?" 	," "," ","mv_ch03","C",TamSX3("F2_DOC")[1]	,0,0,"G","     ","SF2","","" ,"MV_PAR03",""	,"",""," "	,"","","" ,"","","","","","","",""," ",{"Informe o número da nota inicial"})
	U_PUTSX1(cPergunte , "04","Documento ate ?"	," "," ","mv_ch04","C",TamSX3("F2_DOC")[1]	,0,0,"G","     ","SF2","","" ,"MV_PAR04",""	,"",""," "	,"","","" ,"","","","","","","",""," ",{"Informe o número da nota final"})
	U_PUTSX1(cPergunte , "05","Serie de ?"  		," "," ","mv_ch05","C",TamSX3("F2_SERIE")[1],0,0,"G","     ",""	  ,"","" ,"MV_PAR05",""	,"",""," "	,"","","" ,"","","","","","","",""," ",{"Informe a Serie da nota inicial"})
	U_PUTSX1(cPergunte , "06","Serie ate ?" 		," "," ","mv_ch06","C",TamSX3("F2_SERIE")[1],0,0,"G","     ",""	  ,"","" ,"MV_PAR06",""	,"",""," "	,"","","" ,"","","","","","","",""," ",{"Informe a Serie da nota final"})
	U_PUTSX1(cPergunte , "07","Exibir ?" 			," "," ","mv_ch07","N",01					,0,1,"C",""		,""   ,"","" ,"mv_par07","Todos","Todos","Todos","","Retorno OK","Retorno OK","Retorno OK",;
																					"Aguardando Ret.","Aguardando Ret.","Aguardando Ret.","Erro no Ret.","Erro no Ret.","Erro no Ret.","","","",{"Selecione os tipos de","Registros para exibir."})
	U_PUTSX1(cPergunte , "08","Arq. Contem ?" 	," "," ","mv_ch08","C",40					,0,0,"G","     ",""	  ,"","" ,"MV_PAR08",""	,"",""," "	,"","","" ,"","","","","","","",""," ",{"Filtrar por nome de arquivo","que contem."})

ElseIf aRefArq[oGetDados:NAT][1] == "07"
	U_PUTSX1(cPergunte , "01","Emissao de  ?" 	," "," ","mv_ch01","D",08					,0,0,"G","     ","   ","","" ,"MV_PAR01",""	,"",""," "	,"","","" ,"","","","","","","",""," ",{"Informe a Data de Emissao Inicial"})
	U_PUTSX1(cPergunte , "02","Emissao ate ?" 	," "," ","mv_ch02","D",08					,0,0,"G","     ","   ","","" ,"MV_PAR02",""	,"",""," "	,"","","" ,"","","","","","","",""," ",{"Informe a Data de Emissao Final"})
	U_PUTSX1(cPergunte , "03","Exibir ?" 			," "," ","mv_ch03","N",01					,0,1,"C",""		,""   ,"","" ,"mv_par03","Todos","Todos","Todos","","Retorno OK","Retorno OK","Retorno OK",;
																					"Aguardando Ret.","Aguardando Ret.","Aguardando Ret.","Erro no Ret.","Erro no Ret.","Erro no Ret.","","","",{"Selecione os tipos de","Registros para exibir."})
	U_PUTSX1(cPergunte , "04","Arq. Contem ?" 	," "," ","mv_ch04","C",40					,0,0,"G","     ",""	  ,"","" ,"MV_PAR04",""	,"",""," "	,"","","" ,"","","","","","","",""," ",{"Filtrar por nome de arquivo","que contem."})

EndIf

//Inicializa as variaveis de pergunta.
lContinua:= Pergunte(cPergunte,!lJob,"Filtro da exibição")

If lContinua
	If aRefArq[oGetDados:NAT][1] == "04"
		cPar01 := DTOS(MV_PAR01)
		cPar02 := DTOS(MV_PAR02)
		cPar03 := ALLTRIM(MV_PAR03)
		cPar04 := ALLTRIM(MV_PAR04)
		cPar05 := ALLTRIM(MV_PAR05)
		cPar06 := ALLTRIM(MV_PAR06)
		nPar01 := MV_PAR07

	ElseIf aRefArq[oGetDados:NAT][1] == "05"
		cPar01 := DTOS(MV_PAR01)
		cPar02 := DTOS(MV_PAR02)
		nPar01 := MV_PAR03

	ElseIf aRefArq[oGetDados:NAT][1] == "06"
		cPar01 := DTOS(MV_PAR01)
		cPar02 := DTOS(MV_PAR02)
		cPar03 := ALLTRIM(MV_PAR03)
		cPar04 := ALLTRIM(MV_PAR04)
		cPar05 := ALLTRIM(MV_PAR05)
		cPar06 := ALLTRIM(MV_PAR06)
		nPar01 := MV_PAR07         
		cPar07 := ALLTRIM(MV_PAR08)

	ElseIf aRefArq[oGetDados:NAT][1] == "07"
		cPar01 := DTOS(MV_PAR01)
		cPar02 := DTOS(MV_PAR02)
		nPar01 := MV_PAR03
		cPar03 := ALLTRIM(MV_PAR04)

	EndIf
EndIf

Return lContinua

/*
Funcao      : DTOCEUA
Parametros  : 
Retorno     :
Objetivos   : Converte Data em Formato EUA MM/DD/AAAA
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*----------------------------*
Static Function DTOCEUA(dData)
*----------------------------*
Default dData := Date()
Return STRZERO(Day(dData),2)+"/"+STRZERO(MONTH(dData),2)+"/"+STRZERO(YEAR(dData),4)

/*
Funcao      : GetLogInv
Parametros  :
Retorno     :
Objetivos   : Buscar os dados do Log da Invoice e carregar em tela.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*-------------------------*
Static Function GetLogInv()
*-------------------------*
Local i := 0
Local aRet := {}
Local aStruQry := SD2->(dbStruct())
Local aAux := {}
Local aHeader := &("oArq"+aRefArq[oGetDados:NAT][1]):AHEADER

If Select("QRY") > 0
	QRY->(DbClosearea())
Endif  
cQuery := " Select *"
cQuery += " From "+RETSQLNAME("SD2")
cQuery += " Where D_E_L_E_T_ <> '*'
cQuery += "		AND D2_P_NUM <> ''
cQuery += "		AND D2_P_ARQ <> ''
If !EMPTY(cPar01)
	cQuery += "		AND D2_EMISSAO >= '"+ALLTRIM(cPar01)+"'
EndIf
If !EMPTY(cPar02)
	cQuery += "		AND D2_EMISSAO <= '"+ALLTRIM(cPar02)+"'
EndIf
If !EMPTY(cPar03)
	cQuery += "		AND D2_DOC >= '"+ALLTRIM(cPar03)+"'
EndIf
If !EMPTY(cPar04)
	cQuery += "		AND D2_DOC <= '"+ALLTRIM(cPar04)+"'
EndIf
If !EMPTY(cPar05)
	cQuery += "		AND D2_SERIE >= '"+ALLTRIM(cPar05)+"'
EndIf
If !EMPTY(cPar06)
	cQuery += "		AND D2_SERIE <= '"+ALLTRIM(cPar06)+"'
EndIf
If !EMPTY(cPar07)
	cQuery += "		AND D2_P_ARQ like '"+ALLTRIM(cPar07)+"'
EndIf
If nPar01 == 2
	cQuery += "		AND D2_P_LOG <> ''
	cQuery += "		AND D2_P_MSG = ''
ElseIf nPar01 == 3
	cQuery += "		AND D2_P_LOG = ''
ElseIf nPar01 == 4
	cQuery += "		AND D2_P_LOG <> ''
	cQuery += "		AND D2_P_MSG <> ''
EndIf

dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)

For i := 1 To Len(aStruQry)
	If aStruQry[i][2] <> "C" .and. FieldPos(aStruQry[i][1]) > 0
		TcSetField("QRY",aStruQry[i][1],aStruQry[i][2],aStruQry[i][3],aStruQry[i][4])
	EndIf
Next i

QRY->(DbGoTop())
While QRY->(!EOF())
	aAux := {}
	For i:=1 to Len(aHeader)
		Do Case
			Case aHeader[i][2] == "SEL"
				aAdd(aAux,oSelN)

			Case aHeader[i][2] == "STS"
   				If !EMPTY(QRY->D2_P_LOG)
	   				If !EMPTY(QRY->D2_P_MSG)
	   			   		aAdd(aAux,oStsEr)
	   				Else
	   					aAdd(aAux,oStsok)
	   				EndIf
	   		   	Else
	   		   		aAdd(aAux,oStsBr)
	   			EndIf
			
			Case aHeader[i][2] == "ARQ_ORI"
				aAdd(aAux,QRY->D2_P_ARQ)

			Case aHeader[i][2] == "ARQ_LOG"
				aAdd(aAux,QRY->D2_P_LOG)

			Case aHeader[i][2] == "MSG_LOG"
				aAdd(aAux,QRY->D2_P_MSG)

			OtherWise
				aAdd(aAux,QRY->(&(STRTRAN(aHeader[i][2],"WK","")))  )

		EndCase
	Next i
	aAdd(aAux,.F.)

	aAdd(aRet,aAux)
	
	QRY->(DbSkip())
EndDo

Return aRet

/*
Funcao      : GetLogPag
Parametros  :
Retorno     :
Objetivos   : Buscar os dados do Log de Pagamentos e carregar em tela.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*-------------------------*
Static Function GetLogPag()
*-------------------------*
Local i := 0
Local aRet := {}
Local aStruQry := SE1->(dbStruct())
Local aAux := {}
Local aHeader := &("oArq"+aRefArq[oGetDados:NAT][1]):AHEADER

If Select("QRY") > 0
	QRY->(DbClosearea())
Endif  
cQuery := " Select *"
cQuery += " From "+RETSQLNAME("SE1")
cQuery += " Where D_E_L_E_T_ <> '*'
cQuery += "		AND E1_P_NUM <> ''
cQuery += "		AND E1_P_ARQ <> ''

If !EMPTY(cPar01)
	cQuery += "		AND E1_EMISSAO >= '"+ALLTRIM(cPar01)+"'
EndIf
If !EMPTY(cPar02)
	cQuery += "		AND E1_EMISSAO <= '"+ALLTRIM(cPar02)+"'
EndIf
If nPar01 == 2
	cQuery += "		AND E1_P_LOG <> ''
	cQuery += "		AND E1_P_MSG = ''
ElseIf nPar01 == 3
	cQuery += "		AND E1_P_LOG = ''
ElseIf nPar01 == 4
	cQuery += "		AND E1_P_LOG <> ''
	cQuery += "		AND E1_P_MSG <> ''
EndIf

dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)

For i := 1 To Len(aStruQry)
	If aStruQry[i][2] <> "C" .and. FieldPos(aStruQry[i][1]) > 0
		TcSetField("QRY",aStruQry[i][1],aStruQry[i][2],aStruQry[i][3],aStruQry[i][4])
	EndIf
Next i

QRY->(DbGoTop())
While QRY->(!EOF())
	aAux := {}
	For i:=1 to Len(aHeader)
		Do Case
			Case aHeader[i][2] == "SEL"
				aAdd(aAux,oSelN)

			Case aHeader[i][2] == "STS"
   				If !EMPTY(QRY->E1_P_LOG)
	   				If !EMPTY(QRY->E1_P_MSG)
	   			   		aAdd(aAux,oStsEr)
	   				Else
	   					aAdd(aAux,oStsok)
	   				EndIf
	   		   	Else
	   		   		aAdd(aAux,oStsBr)
	   			EndIf
			
			Case aHeader[i][2] == "ARQ_ORI"
				aAdd(aAux,QRY->E1_P_ARQ)

			Case aHeader[i][2] == "ARQ_LOG"
				aAdd(aAux,QRY->E1_P_LOG)

			Case aHeader[i][2] == "MSG_LOG"
				aAdd(aAux,QRY->E1_P_MSG)

			OtherWise
				aAdd(aAux,QRY->(&(STRTRAN(aHeader[i][2],"WK","")))  )

		EndCase
	Next i
	aAdd(aAux,.F.)

	aAdd(aRet,aAux)

	QRY->(DbSkip())
EndDo

Return aRet

/*
Funcao      : GetNameArq
Parametros  : 
Retorno     :
Objetivos   : Retorna o Array somente com os nomes dos arquivos
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*--------------------------------------------*
Static Function GetNameArq(aDados,lGetPosFile)
*--------------------------------------------*
Local i
Local nPos := 0
Local aRet := {}

Default lGetPosFile := .T.

If lGetPosFile
	If Len(aDados) > 2 .and. (nPos := aScan(aDados[2],{|x| ALLTRIM(UPPER(x)) == "FILE"})    ) <> 0
		For i:=3 to Len(aDados)
			If aScan(aRet,{|x| ALLTRIM(UPPER(x)) == ALLTRIM(UPPER(aDados[i][nPos]))}) == 0
				aAdd(aRet,aDados[i][Len(aDados[i])])
			EndIf
		Next i
	EndIf
Else
	If Len(aDados) > 2
		For i:=3 to Len(aDados)
			If aScan(aRet,{|x| ALLTRIM(UPPER(x)) == ALLTRIM(UPPER(aDados[i][Len(aDados[i])]))}) == 0
				aAdd(aRet,aDados[i][Len(aDados[i])])
			EndIf
		Next i
	EndIf
EndIf

Return aRet

/*
Funcao      : SaveRetLog
Parametros  : 
Retorno     :
Objetivos   : Verifica se existe Log a Ser processado no Retorno e grava.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*--------------------------*
Static Function SaveRetLog()
*--------------------------*
Local i,j
Local nQtd  := 0
Local nPos  := 0
Local nPos1 := 0
Local nPos2 := 0
Local nPos3 := 0
Local cLinha	:= ""
Local oFT   := fT():New()//FUNCAO GENERICA
Local cDirSrvAtu := cDirSrvIn
Local aArqServer := DIRECTORY(cDirSrvAtu+"\*.CSV" , )
Local aArquivo := {}
Local cUpd := ""

For i:=1 to len(aArqServer)
	If AT("_IB_LOG_",aArqServer[i][1]) <> 0
		aArquivo := {}
		//Leitura do arquivo de tratamento.
		oFT:FT_FUse(cDirSrvAtu+"\"+aArqServer[i][1])
		While !oFT:FT_FEof()
			cLinha := oFT:FT_FReadln()
			If AT(cDelimitador,cLinha) <> 0
				aAdd(aArquivo, separa(UPPER(cLinha),cDelimitador))// Sepera para vetor e adiciona no array de arquivo.
			EndIf                          
			aAdd(aArquivo[Len(aArquivo)],aArqServer[i][1])
	        oFT:FT_FSkip() // Proxima linha
		Enddo
		oFT:FT_FUse() // Fecha o arquivo 

		//Processa arquivo que realmente possui dados e não somente cabeçalho.
		If Len(aArquivo) > 2
			Do Case
				Case UPPER(STRTRAN(LEFT(aArqServer[i][1],AT("_IB_LOG_",aArqServer[i][1])-1),"BR_","") ) == "INVOICE"
					For j:=3 to Len(aArquivo)
						If (nPos := aScan(aArquivo[2],{|x| UPPER(ALLTRIM(x)) == "C5_EMISSAO" }) ) <> 0 .and. ;
							(nPos1 := aScan(aArquivo[2],{|x| UPPER(ALLTRIM(x)) == "C5_P_NUM" }) ) <> 0 .and. ;
							(nPos2 := aScan(aArquivo[2],{|x| UPPER(ALLTRIM(x)) == "C5_P_REF" }) ) <> 0 .and. ;
							(nPos3 := aScan(aArquivo[2],{|x| UPPER(ALLTRIM(x)) == "C6_PRODUTO" }) ) <> 0

							If aScan(aArquivo[2],{|x| UPPER(ALLTRIM(x)) == "STATUS" }) <> 0
								cUpd := ""
								cUpd += " Update SD2"+CEmpAnt+"0 Set "
								cUpd += " D2_P_LOG = '"+Alltrim(aArqServer[i][1])+"'
								If ALLTRIM(aArquivo[j][aScan(aArquivo[2],{|x| UPPER(ALLTRIM(x)) == "STATUS" })]) <> "S"
									If aScan(aArquivo[2],{|x| UPPER(ALLTRIM(x)) == "ERROR_MESSAGE" }) <> 0
										cUpd += " ,D2_P_MSG = '"+SUBSTR(aArquivo[j][aScan(aArquivo[2],{|x|UPPER(ALLTRIM(x))=="ERROR_MESSAGE"})],1,240)+"'
									Else
								 		cUpd += " ,D2_P_MSG = 'unknown Error'
									EndIf
								EndIf
								If aScan(aArquivo[2],{|x| UPPER(ALLTRIM(x)) == "D2_P_ID" }) <> 0
							  		cUpd += " ,D2_P_ID = '"+Alltrim(aArquivo[j][aScan(aArquivo[2],{|x| UPPER(ALLTRIM(x)) == "D2_P_ID" })])+"'
								EndIf
								cUpd += " Where D_E_L_E_T_ <> '*'
								cUpd += " AND LEFT(D2_EMISSAO,6) = '"+LEFT(DTOS(AltData(aArquivo[j][nPos]) ) ,6)+"'
								cUpd += " AND D2_P_NUM = '"+ALLTRIM(aArquivo[j][nPos1])+"'
								cUpd += " AND D2_P_REF = '"+ALLTRIM(aArquivo[j][nPos2])+"'
								cUpd += " AND D2_COD   = '"+ALLTRIM(aArquivo[j][nPos3])+"'
								
								TCSQLExec(cUpd)
							EndIf

						EndIf
					Next j
				
				Case UPPER(STRTRAN(LEFT(aArqServer[i][1],AT("_IB_LOG_",aArqServer[i][1])-1),"BR_","") ) == "RECEIPTS"
					SE1->(DbSetOrder(2))//E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO

					For j:=3 to Len(aArquivo)
						If (nPos := aScan(aArquivo[2],{|x| UPPER(ALLTRIM(x)) == "E1_NUM" }) ) <> 0
							If SE1->(DbSeek(aArquivo[j][nPos]))
								SE1->(RecLock("SE1",.F.))
								SE1->E1_P_LOG := ALLTRIM(aArqServer[i][1])
								If aScan(aArquivo[2],{|x| UPPER(ALLTRIM(x)) == "STATUS" }) <> 0
									If ALLTRIM(aArquivo[j][aScan(aArquivo[2],{|x| UPPER(ALLTRIM(x)) == "STATUS" })]) <> "S"
										If aScan(aArquivo[2],{|x| UPPER(ALLTRIM(x)) == "ERROR MESSAGE" }) <> 0
											SE1->E1_P_MSG := SUBSTR(aArquivo[j][aScan(aArquivo[2],{|x| UPPER(ALLTRIM(x)) == "ERROR MESSAGE" })],1,240)
										Else
											SE1->E1_P_MSG := "unknown Error"
										EndIf
									EndIf
								EndIf
								SE1->(MsUnlock())
							EndIf
						EndIf
					Next j

			EndCase
			nQtd++
		EndIf
		oFT:FT_FUse() // Fecha o arquivo 
		Sleep(1000)
		//Apos o termino da utilização do arquivo coloca na pasta de BKP.
		compacta(cDirSrvAtu+"\"+aArqServer[i][1],cDirSrvAtu+"\BKP_"+STRZERO(Year(Date()),4)+STRZERO(Month(Date()),2)+"."+cExtZip)		
	EndIf
Next i

If nQtd <> 0
	MsgInfo("Foi identifica e processado automaticamente "+ALLTRIM(STR(nQtd))+" Log(s) de retorno!","HLB BRASIL")
EndIf

Return .T.


/*
Funcao      : EstEnvio
Parametros  : 
Retorno     :
Objetivos   : Estorna o Envio do Arquivo.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*-----------------------------------*
Static Function EstEnvio(cTab,nRecno)
*-----------------------------------* 
Local cUpd := ""

Do Case
	Case cTab == "SD2"
		SD2->(DbSetOrder(1))
		SD2->(DbGoTo(nRecno))
		cUpd := ""
		cUpd += " Update SD2"+cEmpAnt+"0 
		cUpd += " Set D2_P_ARQ = '',D2_P_LOG = '',D2_P_MSG = '',D2_P_ID = ''
		cUpd += " Where D2_FILIAL 	= '"+SD2->D2_FILIAL+"' "
		cUpd += " 	AND D2_DOC 		= '"+SD2->D2_DOC+"' "
		cUpd += " 	AND D2_SERIE 	= '"+SD2->D2_SERIE+"' "
		cUpd += " 	AND D2_CLIENTE	= '"+SD2->D2_CLIENTE+"' "
		cUpd += " 	AND D2_LOJA 	= '"+SD2->D2_LOJA+"' "
		TCSQLExec(cUpd)

		cUpd := ""
		cUpd += " Update SF2"+cEmpAnt+"0 
		cUpd += " Set F2_P_ARQ = ''
		cUpd += " Where F2_FILIAL 	= '"+SD2->D2_FILIAL+"' "
		cUpd += " 	AND F2_DOC 		= '"+SD2->D2_DOC+"' "
		cUpd += " 	AND F2_SERIE 	= '"+SD2->D2_SERIE+"' "
		cUpd += " 	AND F2_CLIENTE	= '"+SD2->D2_CLIENTE+"' "
		cUpd += " 	AND F2_LOJA 	= '"+SD2->D2_LOJA+"' "
		TCSQLExec(cUpd)

	Case cTab == "SE1"
		cUpd := ""
		cUpd += " Update SE1"+cEmpAnt+"0 
		cUpd += " Set E1_P_ARQ = '',E1_P_LOG = '',E1_P_MSG = ''
		cUpd += " Where R_E_C_N_O_ = "+ALLTRIM(STR(nRecno))
		TCSQLExec(cUpd)

EndCase

Return .T.

/*
Funcao      : ConvString
Parametros  : 
Retorno     :
Objetivos   : Retira caracteres invalidos da string
Autor       : Jean Victor Rocha
Data/Hora   : 11/12/2014
*/
*-------------------------------*
Static Function ConvString(cInfo)
*-------------------------------* 
Local i
Local cRet := ""
Local aTabConv := {	{"Ã¡","A"},{"°",""},{"Ã‡","C"},{"Ã•","O"},{"Ãƒ","A"},{"Ã‚","A"},{"Ã€","A"},{"Ã£","A"},{"Ã¢","A"},{"Ã ","A"},;
					{"Ã§","C"},{"Ã‡","C"},{"Ãº","U"},{"Ã­","I"},{"Â€“","-"},{"Ã³","o"},{"Ãª","e"},{"Âº","a"},{"Ãª","E"},{"Ã©","E"},;
					{"Âª","a"},{"Ãµ","O"},{"Ã‰","E"},{"ÃŠ","E"}}

cRet := ALLTRIM(cInfo)

For i:=1 to Len(aTabConv)
	cRet := StrTran(cRet,aTabConv[i][1],aTabConv[i][2])
Next i

Return UPPER(cRet)

/*
Funcao      : MarcaButton
Parametros  : 
Retorno     :
Objetivos   : Função de marca de desmarca todos.
Autor       : Jean Victor Rocha
Data/Hora   : 25/05/2015
*/
*---------------------------*
Static Function MarcaButton()
*---------------------------* 
Local i
Local oSelBtn
Local lAlterado := .F.

If UPPER(LEFT(oBtn7:CTOOLTIP,3)) == "MAR"
	oSelBtn := oSelS
Else
	oSelBtn := oSelN
EndIf

For i:=1 to len(&("oArq"+aRefArq[oGetDados:NAT][1]):aCols) 
	If &("oArq"+aRefArq[oGetDados:NAT][1]):aCols[i][2] == oStsok
		&("oArq"+aRefArq[oGetDados:NAT][1]):aCols[i][1] := oSelBtn
		lAlterado := .T.
	Else 
		&("oArq"+aRefArq[oGetDados:NAT][1]):aCols[i][1] := oSelN
	Endif
Next i

&("oArq"+aRefArq[oGetDados:NAT][1]):ForceRefresh()

If !lAlterado
	oBtn7:CTOOLTIP := "Desmarca Todos"
	oBtn7:LoadBitmaps("UNSELECTALL")
	MsgInfo("Não foi encontrado registros permitidos para seleção!","HLB BRASIL")
Else
	If UPPER(LEFT(oBtn7:CTOOLTIP,3)) == "MAR"
		oBtn7:CTOOLTIP := "Desmarca Todos"
		oBtn7:LoadBitmaps("UNSELECTALL")
	Else
		oBtn7:CTOOLTIP := "Marca Todos"
		oBtn7:LoadBitmaps("SELECTALL")
	EndIf
EndIf

Return .T.

/*
Funcao      : EnvFtps
Parametros  : aArqs,cOpc,cDirServ,cDirFtp,cFtp,cLogin,cPass
Retorno     : lRet
Objetivos   : Função para enviar o arquivo ao SFTP
Autor       : Renato Rezende
*/
*-------------------------------------------------------------------------*
 Static Function EnvFtps(aArqs,cOpc,cDirServ,cDirFtp,cFtp,cLogin,cPass)
*-------------------------------------------------------------------------*
Local lRet		:=.F.
Local cRootPath	:= GetSrvProfString("RootPath", "\undefined")//retorna o caminho do rootpath
Local cCommand 	:= ""
Local lWait  	:= .T.
Local cPath     := 'C:\Program Files (x86)\WinSCP\'
Local cBatWscp	:= ""
Local cArqLogEr := ""
Local cDataLog	:= ""

Private	cDate 		:= DtoC(Date())
Private	cTime 		:= SubStr(Time(),1,5)
Private	cUser 		:= UsrFullName(RetCodUsr())
Private	cSubject	:= "[TWITTER] ERRO WORKFLOW PROCESSAMENTO "+DtoC(Date())
Private	cTo			:= AllTrim(GetMv("MV_P_00029",," "))

If ExistDir(cDirServ)
	If !ExistDir(cDirServ+"\LOG")
		MakeDir(cDirServ+"\LOG")
		MakeDir(cDirServ+"\LOG\ERRO")
	EndIf
	If cOpc == "GET"
		If !ExistDir(cDirServ+"\intsftp")
			MakeDir(cDirServ+"\intsftp")
		EndIf
	EndIf
EndIf

cDataLog:= GravaData(Date(),.F.,8)+SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)+SUBSTR(TIME(),7,2)
cBatWscp := cDirServ+"\wiscpconnect2.bat"
cArqLogEr:= cDirServ+'\log\ERRO\WinSCPconnect_'+cDataLog+'.log

//Cria arquivo bat para subir arquivo no FTP.
nHdl := FCREATE(cBatWscp,0,,.F. )  //Criação do Arquivo txt.
If nHdl == -1 // Testa se o arquivo foi gerado 
	cMsg:="O bat "+cBatWscp+" nao pode ser executado." 
	conout(cMsg)
	Return lRet
EndIf

cCommand:= '@echo off' +CRLF
cCommand+= CRLF
cCommand+= 'set dateenv='+cDataLog+CRLF
cCommand+= CRLF
cCommand+= '"C:\Program Files (x86)\WinSCP\WinSCP.com" ^'+CRLF
cCommand+= '  /log="'+cRootPath+cDirServ+'\log\WinSCPconnect_%dateenv%.log" /ini=nul ^'+CRLF
cCommand+= '  /command ^'+CRLF
cCommand+= '    "open sftp://'+cLogin+':'+cPass+'@'+cFtp+'/ -certificate="*"" ^'+CRLF
If cOpc == "PUT"
	cCommand+= '    "cd '+cDirFtp+' " ^'+CRLF 	
	For nR:= 1 to Len(aArqs)
		If RIGHT(aArqs[nR][1],3) <> cExtZip
			cCommand+= '    "'+cOpc+' '+cRootPath+cDirServ+'\'+alltrim(aArqs[nR][1])+' " ^'+CRLF
		EndIf
	Next nR
ElseIf cOpc == "GET"
	cCommand+= '    "cd '+cDirFtp+' " ^'+CRLF 
	cCommand+= '    "'+cOpc+' *.csv  '+cRootPath+cDirServ+'\intsftp\ " ^'+CRLF
ElseIf cOpc == "DEL"
	cCommand+= '    "cd '+cDirFtp+' " ^'+CRLF
	For nR:= 1 to Len(aArqs)
		If RIGHT(aArqs[nR],3) <> cExtZip 
			cCommand+= '    "rm '+alltrim(aArqs[nR])+'" ^'+CRLF
		EndIf
	Next nR
EndIf 
cCommand+= '    "exit"' +CRLF
cCommand+= CRLF
cCommand+= 'set WINSCP_RESULT=%ERRORLEVEL%'+CRLF
cCommand+= 'if %WINSCP_RESULT% equ 0 ('+CRLF
cCommand+= '  echo Success'+CRLF
cCommand+= ') else ('+CRLF
cCommand+= '  echo Error'+CRLF
cCommand+= '  Move '+cRootPath+cDirServ+'\log\WinSCPconnect_%dateenv%.log '+cRootPath+cDirServ+'\log\ERRO\WinSCPconnect_%dateenv%.log'+CRLF
cCommand+= ')'+CRLF
cCommand+= CRLF
cCommand+= 'exit /b %WINSCP_RESULT%'+CRLF

fWrite(nHdl,cCommand)//Escreve no arquivo
fclose(nHdl)//Fecha o arquivo

lRet := WaitRunSrv( @cRootPath+cBatWscp , @lWait , @cPath )

fErase(cBatWscp)//Apaga o .Bat

cMsg	:= HtmlPrc(lRet)

If File(UPPER(cArqLogEr)) .AND. lRet
	u_GTGEN045(cMsg,cSubject,"",cTo,"",cArqLogEr)
	lRet:= .F.             
ElseIf !lRet
	u_GTGEN045(cMsg,cSubject,"",cTo,"",cArqLogEr)
EndIf

If !lRet
	MsgAlert("Problema ao conectar no FTP!","HLB BRASIL")
EndIf

Return(lRet)

/*
Funcao      : Email
Retorno     : cHtml
Objetivos   : Criar corpo do email de notificação
Autor       : Renato Rezende
*/
*---------------------------------------*
 Static Function HtmlPrc(lRetEnv)
*---------------------------------------*
Local cHtml := ""

cHtml += '<html>
cHtml += '	<head>
cHtml += '	<title>Modelo-Email</title>
cHtml += '	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
cHtml += '	</head>
cHtml += '	<body bgcolor="#FFFFFF" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
cHtml += '		<table id="Tabela_01" width="631" height="342" border="0" cellpadding="0" cellspacing="0">
cHtml += '			<tr><td width="631" height="10"></td></tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="1" bgcolor="#8064A1"></td>
cHtml += '			</tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="25"> <font size="2" face="tahoma" color="#551A8B"><b>PROCESSAMENTO</b></font>   </td>
cHtml += '			</tr>
cHtml += '			<tr><td width="631" height="1" bgcolor="#8064A1"></td></tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="25" bgcolor="#E5DFEB"><font size="2" face="tahoma" color="#8064A1">DATE: '+ALLTRIM(cDate)+'</font></td>
cHtml += '			</tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="26"><font size="2" face="tahoma" color="#8064A1">TIME: '+ALLTRIM(cTime)+'</font></td>
cHtml += '			</tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="25" bgcolor="#E5DFEB"><font size="2" face="tahoma" color="#8064A1">USER: '+IIF(Empty(ALLTRIM(cUser)),"JOB", Alltrim(cUser))+'</font></td>
cHtml += '			</tr>
cHtml += '			<tr><td width="631" height="1" bgcolor="#8064A1"></td></tr>
cHtml += '			<tr>
If lRetEnv
	cHtml += '				<td width="631" height="26"><font size="2" face="tahoma" color="#8064A1">ARQUIVO LOG ANEXO COM ERRO</font></td>
Else
	cHtml += '				<td width="631" height="26"><font size="2" face="tahoma" color="#8064A1">ERRO INTERNO - SERVIDOR</font></td>
EndIf
cHtml += '			</tr>
cHtml += '			<tr><td width="631" height="1" bgcolor="#8064A1"></td></tr>
cHtml += '			<tr><td width="631" height="20"></td></tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="20"><p align=center>Mensagem automatica, nao responder.</p></td>
cHtml += '			</tr>
cHtml += '		</table>
cHtml += '	</body>
cHtml += '</html>

Return cHtml
