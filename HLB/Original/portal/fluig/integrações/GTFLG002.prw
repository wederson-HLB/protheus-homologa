#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.CH"
#include "apwebex.ch"
#include "totvs.ch"
#include "tbiconn.ch"

/*
Funcao      : GTFLG002
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Processamentos de novas solicitações de faturamento do portal e integração com o Fluig  
Autor       : Jean Victor Rocha 
Revisão		:
Data/Hora   : 10/05/2016
Módulo      : 
*/
*----------------------*
User Function GTFLG002()
*----------------------*
ConOut("$GT --- GTFLG002 - ["+ALLTRIM(STR(ThreadID()))+"] - Executado em "+DTOS(date())+" - "+Time())
Private cEmpJOB := "02"//empresa teste 03 filial 01
Private cFilJOB := "01"

Private URLFLUIG := "http://187.94.57.99:8280/webdesk/"//"http://gt.fluig.com/webdesk/"//"http://gt.fluig.com:8280/webdesk/"//"http://10.11.210.3:8080/webdesk/"

Private cUserAdm := "esbUser"
Private cPassAdm := "Fluig@2014"
Private ncompanyId := 1

//Inicialização do ambiente
RpcSetType(3)
RpcSetEnv(cEmpJOB,cFilJOB)

//Busca os dados a serem processados.
BuscaDados()

//Integração dos dados para cada solicitação de faturamento
QRY->(DbGoTop())
If QRY->(!EOF())
	While QRY->(!EOF())
		//Validação para garantir que outra Thread não iniciou o processamento, ocorre duplicidades quando o processamento é demorado.
		If VldGrvInt(QRY->R_E_C_N_O_)
			cUpd := "Update "+RetSQLName("ZF0")+" set ZF0_NOTIF = 'INTEGRANDO' where R_E_C_N_O_ = "+ALLTRIM(STR(QRY->R_E_C_N_O_))
			TCSQLEXEC(cUpd)
			ConOut("$GT --- GTFLG002 - ["+ALLTRIM(STR(ThreadID()))+"] - "+DTOS(date())+" - "+Time()+" - Travado R_E_C_N_O_ ="+ALLTRIM(STR(QRY->R_E_C_N_O_)) )
			ProcInt(QRY->ZF0_CODEMP+QRY->ZF0_CODFIL+QRY->ZF0_CODIGO)
		Else
		    conout("$GT --- GTFLG002 - ["+ALLTRIM(STR(ThreadID()))+"] - "+DTOS(date())+" - "+Time()+" - R_E_C_N_O_ = " +;
		    															ALLTRIM(STR(QRY->R_E_C_N_O_)) + " - JA FOI INICIADO INTEGRACAO POR OUTRA THREAD!" )
		EndIf
		QRY->(DbSkip())
	EndDo
EndIf

//Encerra o ambiente JOB	
RpcClearEnv()

Return .T.   
                       
/*
Funcao      : BuscaDados
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Busca dos dados a serem processados
Autor       : Jean Victor Rocha 
Data/Hora   : 10/05/2016
*/
*--------------------------*
Static Function	BuscaDados()
*--------------------------*
If Select("QRY") <> 0
	QRY->(DbCloseArea())
EndIf

cQry := " Select *,ISNULL(CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), ZF0_INFADI)),'') AS ZF0_INFADI2 
cQry += " From "+RetSQLName("ZF0")+" ZF0
cQry += " Where ZF0.ZF0_STATUS = 'P' AND ZF0.ZF0_NOTIF = ''
cQry += " Order By ZF0.ZF0_FILIAL,ZF0.ZF0_CODEMP,ZF0.ZF0_CODFIL,ZF0.ZF0_CODIGO

dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQry), 'QRY', .T., .T.)

Return .T. 

/*
Funcao      : VldGrvInt
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Valida se a gravação sera realizada, para identificar se outra Thread não iniciou a gravação e/ou ja gravou.
Autor       : Jean Victor Rocha 
Data/Hora   : 07/11/2016
*/
*-------------------------------*
Static Function	VldGrvInt(nRecno)
*-------------------------------*
Local cQry := ""
If Select("QRY2") <> 0
	QRY2->(DbCloseArea())
EndIf

cQry := " Select *
cQry += " From "+RetSQLName("ZF0")+" ZF0
cQry += " Where ZF0.R_E_C_N_O_ = "+ALLTRIM(STR(nRecno))

dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQry), 'QRY2', .T., .T.)

Return (EMPTY(QRY2->ZF0_NOTIF) .and. QRY2->ZF0_STATUS == "P")//.T. para aguardando integração, pode integrar.

/*
Funcao      : ProcInt
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Processamento dos dados e integração com o Fluig
Autor       : Jean Victor Rocha 
Data/Hora   : 10/05/2016
*/
*--------------------------------*
Static Function ProcInt(cChaveRec)
*--------------------------------*
Local cQry := ""
Local cCodAmb := ""
Local nCount := 0
Local FlgWS  := WSECMWorkflowEngineServiceService():new()
Local aCardData   := {}
  
Private cCodAmb := ""
Private cCodEmp := ""

FlgWs:_URL             := URLFLUIG+"ECMWorkflowEngineService"
FlgWS:cusername        := cUserAdm
FlgWS:cpassword        := cPassAdm
FlgWS:ncompanyId       := ncompanyId
FlgWS:cprocessId       := "Solicitacao_faturamento"
FlgWS:ccomments        := "Processo iniciado via integração com Portal do Cliente"

//Dados do Solicitante                        
aAdd(aCardData ,{"cd_solic","esbUser"})  
aAdd(aCardData ,{"nm_solic","esbUser esbUser"})  
aAdd(aCardData ,{"cd_tp_doc","solicitacao_faturamento"})  
aAdd(aCardData ,{"nm_tp_doc","Solicitação de Faturamento"})
aAdd(aCardData ,{"dt_solic",Day2Str(date())+"/"+Month2Str(date())+"/"+Year2Str(date())+" - "+TIME()})  
aAdd(aCardData ,{"dt_solic_portal",Day2Str(StoD(QRY->ZF0_DATA))+"/"+Month2Str(StoD(QRY->ZF0_DATA))+"/"+Year2Str(StoD(QRY->ZF0_DATA))+" - "+AllTrim(QRY->ZF0_HORA)})

aAdd(aCardData ,{"id_solic"	,EncodeUTF8( _NoTags(AllTrim(QRY->ZF0_CODIGO)))})
ZW0->(DbSetOrder(1))
If ZW0->(DbSeek(xFilial("ZW0")+AllTrim(QRY->ZF0_LOGIN)))
	aAdd(aCardData ,{"nm_solic_portal",_NoTags(AllTrim(ZW0->ZW0_NOME))})
	aAdd(aCardData ,{"email_solic"	,_NoTags(AllTrim(ZW0->ZW0_EMAIL))})
EndIf

cCodEmp := AllTrim(QRY->ZF0_CODEMP)
aAdd(aCardData ,{"cd_emp"	, cCodEmp })
aAdd(aCardData ,{"cd_filial"	, AllTrim(QRY->ZF0_CODFIL) })
ZW1->(DbSetOrder(1))
If ZW1->(DbSeek(xFilial("ZW1")+AllTrim(QRY->ZF0_CODEMP)+AllTrim(QRY->ZF0_CODFIL)))	
	cCodAmb := AllTrim(ZW1->ZW1_AMB)
	aAdd(aCardData ,{"cd_ambemp", cCodAmb })
	aAdd(aCardData ,{"nm_emp"	, _NoTags(AllTrim(ZW1->ZW1_NFANT)) })
	aAdd(aCardData ,{"nm_razao"	, _NoTags(AllTrim(ZW1->ZW1_RAZAO)) })
	aAdd(aCardData ,{"cd_cnpj"	, _NoTags(AllTrim(ZW1->ZW1_CNPJ)) })
EndIf
If !Empty(QRY->ZF0_INFADI)//Dados Adicinais
	aAdd(aCardData ,{"desc_adic"	, _NoTags(AllTrim(QRY->ZF0_INFADI2)) })
EndIf
          
//Tratamento para busca da empresa "Matriz"
cCNPJChave := getCNPJAtivo(ZW1->ZW1_CNPJ)
If !EMPTY(cCNPJChave)
	oValueDS := getDataset("ds_empresa",cCNPJChave)//Busca os dados do cliente
	If LEN(oValueDS:OWSVALUES) <> 0
		nPos := aScan(oValueDS:CCOLUMNS, {|x| UPPER(x) == "CD_EMP"})
		aAdd(aCardData ,{"cd_cliente"	, _NoTags(AllTrim(oValueDS:OWSVALUES[1]:OWSVALUE[nPos]:TEXT)) })
		nPos := aScan(oValueDS:CCOLUMNS, {|x| UPPER(x) == "NM_RAZAO_EMP"})
		aAdd(aCardData ,{"nm_cliente"	, _NoTags(AllTrim(oValueDS:OWSVALUES[1]:OWSVALUE[nPos]:TEXT)) })
		nPos := aScan(oValueDS:CCOLUMNS, {|x| UPPER(x) == "NM_FORMULARIO"})
		aAdd(aCardData ,{"nm_cliente_form"	, _NoTags(AllTrim(oValueDS:OWSVALUES[1]:OWSVALUE[nPos]:TEXT)) })
	Else
		NotificaErro(QRY->ZF0_CODEMP+QRY->ZF0_CODFIL,"[Cod.Portal:"+ALLTRIM(QRY->ZF0_CODIGO)+"] = Não foi encontrado dados no fluig para o CNPJ '"+cCNPJChave+"'!")
		cUpd := " Update "+RetSQLName("ZF0")
		cUpd += " Set ZF0_NOTIF = 'ERRO_FLUIG'
		cUpd += " Where ZF0_CODEMP='"+QRY->ZF0_CODEMP+"' AND ZF0_CODFIL = '"+QRY->ZF0_CODFIL+"' AND ZF0_CODIGO = '"+QRY->ZF0_CODIGO+"'
		TcSQLExec(cUpd)
		Return .F.
	EndIf
Else
	NotificaErro(QRY->ZF0_CODEMP+QRY->ZF0_CODFIL,"[Cod.Portal:"+ALLTRIM(QRY->ZF0_CODIGO)+;
							"] = Não foi encontrado a empresa responsavel/grupo de empresas para o CNPJ no GTCORP'"+ZW1->ZW1_CNPJ+"'!")
	cUpd := " Update "+RetSQLName("ZF0")
	cUpd += " Set ZF0_NOTIF = 'ERRO_GTCORP'
	cUpd += " Where ZF0_CODEMP='"+QRY->ZF0_CODEMP+"' AND ZF0_CODFIL = '"+QRY->ZF0_CODFIL+"' AND ZF0_CODIGO = '"+QRY->ZF0_CODIGO+"'
	TcSQLExec(cUpd)
	Return .F.
EndIf

//Dados da solicitação
aAdd(aCardData ,{"tp_solic"	, IIF(QRY->ZF0_TIPO=="M","Mercantil","Servico") })
aAdd(aCardData ,{"tp_pedido_int", "N" })
aAdd(aCardData ,{"cb_tp_pedido", getComboSX3("C5_TIPO") })
aAdd(aCardData ,{"tp_cliente_int", "F" })
aAdd(aCardData ,{"cb_tp_cliente", getComboSX3("C5_TIPOCLI") })

aAdd(aCardData ,{"cd_pedido"	, _NoTags(AllTrim(QRY->ZF0_PEDIDO)) })
aAdd(aCardData ,{"cd_nosso_pedido"	, _NoTags(AllTrim(QRY->ZF0_NOSSOP)) })
aAdd(aCardData ,{"cd_natoper"	, _NoTags(AllTrim(QRY->ZF0_NATOPE)) })
aAdd(aCardData ,{"cd_condpag"	, _NoTags(AllTrim(QRY->ZF0_CONPGT)) })
If QRY->ZF0_TIPO == "M"
	aAdd(aCardData ,{"desc_destmerc"	, IIF(QRY->ZF0_DESTME=="R","Revenda",IIF(QRY->ZF0_DESTME=="C","Consumo Final","Industrialização"))  })
EndIf
If QRY->ZF0_TIPO == "S"
	aAdd(aCardData ,{"cd_pgtoext_int"	, IIF(QRY->ZF0_CLIEST == "B","B","E") }) //Brasil / Exterior
	If AllTrim(QRY->ZF0_CONTRA) == "S"
		aAdd(aCardData ,{"tp_contrato"	, "sim" })
		aAdd(aCardData ,{"cd_contrato"	, _NoTags(Alltrim(QRY->ZF0_NUMCON))})
		aAdd(aCardData ,{"cd_vigencia"	, _NoTags(Alltrim(QRY->ZF0_VIGCON))})
	Else
		aAdd(aCardData ,{"tp_contrato"	, "não" })
	EndIf
EndIf
//Destinatario
If QRY->ZF0_TIPO == "S"
	aAdd(aCardData ,{"tp_dest"	, "Não" })
Else
	If QRY->ZF0_NFFORN == "S"
   		aAdd(aCardData ,{"tp_dest"	, "Sim" })
	Else
		aAdd(aCardData ,{"tp_dest"	, "Não" })
	EndIf
EndIf
If !EMPTY(AllTrim(QRY->ZF0_CODDES))
	aCodDest := {Left(AllTrim(QRY->ZF0_CODDES),6),Right(AllTrim(QRY->ZF0_CODDES),2)}
Else
	aCodDest := getDest(cCodAmb,cCodEmp,AllTrim(QRY->ZF0_CNPJDE))
EndIf

aAdd(aCardData ,{"cd_dest_siga"		, _NoTags(aCodDest[1]) })
aAdd(aCardData ,{"cd_destlj_siga"	, _NoTags(aCodDest[2]) })

aAdd(aCardData ,{"nm_dest"			, _NoTags(AllTrim(QRY->ZF0_NOMDES)) })
aAdd(aCardData ,{"cd_cnpjdest"		, _NoTags(AllTrim(QRY->ZF0_CNPJDE)) })
aAdd(aCardData ,{"nm_enddest"		, _NoTags(AllTrim(QRY->ZF0_ENDDES)) })
aAdd(aCardData ,{"cd_cepdest"		, _NoTags(AllTrim(QRY->ZF0_CEPDES)) })
aAdd(aCardData ,{"nm_estadodest"	, _NoTags(AllTrim(QRY->ZF0_ESTDES)) })
aAdd(aCardData ,{"nm_cidadedest"	, _NoTags(AllTrim(QRY->ZF0_CIDDES)) })
aAdd(aCardData ,{"nm_bairrodest"	, _NoTags(AllTrim(QRY->ZF0_BAIDES)) })
aAdd(aCardData ,{"cd_inscestdest"	, _NoTags(AllTrim(QRY->ZF0_IEDEST)) })
aAdd(aCardData ,{"nm_maildest"		, _NoTags(AllTrim(QRY->ZF0_MAILDE)) })
If QRY->ZF0_TIPO == "S"
	aAdd(aCardData ,{"cd_nif"		, _NoTags(AllTrim(QRY->ZF0_NIF)) })
EndIf
//Local de Cobrança
If !Empty(QRY->ZF0_NOMCOB)
	aAdd(aCardData ,{"nm_cobr"			, _NoTags(AllTrim(QRY->ZF0_NOMCOB)) })
	aAdd(aCardData ,{"nm_endcobr"		, _NoTags(AllTrim(QRY->ZF0_ENDCOB)) })
	aAdd(aCardData ,{"cd_cepcobr"		, _NoTags(AllTrim(QRY->ZF0_CEPCOB)) })
	aAdd(aCardData ,{"nm_estadocobr"	, _NoTags(AllTrim(QRY->ZF0_ESTCOB)) })
	aAdd(aCardData ,{"nm_cidadecobr"	, _NoTags(AllTrim(QRY->ZF0_CIDCOB)) })
	aAdd(aCardData ,{"nm_bairrocobr"	, _NoTags(AllTrim(QRY->ZF0_BAICOB)) })
EndIf
//Local de Entrega
aAdd(aCardData ,{"nm_entrega"			, _NoTags(AllTrim(QRY->ZF0_NOMENT)) })
aAdd(aCardData ,{"cd_cnpjentrega"		, _NoTags(AllTrim(QRY->ZF0_CNPJEN)) })
aAdd(aCardData ,{"nm_endentrega"		, _NoTags(AllTrim(QRY->ZF0_ENDENT)) })
aAdd(aCardData ,{"cd_cepentrega"		, _NoTags(AllTrim(QRY->ZF0_CEPENT)) })
aAdd(aCardData ,{"nm_estadoentrega"		, _NoTags(AllTrim(QRY->ZF0_ESTENT)) })
aAdd(aCardData ,{"nm_cidadeentrega"		, _NoTags(AllTrim(QRY->ZF0_CIDENT)) })
aAdd(aCardData ,{"nm_bairroentrega"		, _NoTags(AllTrim(QRY->ZF0_BAIENT)) })
aAdd(aCardData ,{"cd_inscestentrega"	, _NoTags(AllTrim(QRY->ZF0_IEENTR)) })
//Local de Saída
If QRY->ZF0_TIPO == "M"
	aAdd(aCardData ,{"nm_saida"			, _NoTags(AllTrim(QRY->ZF0_NOMSAI)) })
	aAdd(aCardData ,{"cd_cnpjsaida"		, _NoTags(AllTrim(QRY->ZF0_CNPJSA)) })
EndIf
//Transportadora
If QRY->ZF0_TIPO == "M" .and. QRY->ZF0_TRANSP == "S"
	If !EMPTY(QRY->ZF0_CODTRA)
		aAdd(aCardData ,{"cd_trans_siga"	, _NoTags(Left(AllTrim(QRY->ZF0_CODTRA),6)) })
	Else
		aAdd(aCardData ,{"cd_trans_siga"	, _NoTags(getTrans(cCodAmb,cCodEmp,AllTrim(QRY->ZF0_CNPJTA))) })	
	EndIf
	aAdd(aCardData ,{"nm_transp"			, _NoTags(AllTrim(QRY->ZF0_NOMTRA)) })
	aAdd(aCardData ,{"cd_cnpjtransp"		, _NoTags(AllTrim(QRY->ZF0_CNPJTA)) })
	aAdd(aCardData ,{"nm_endtransp"			, _NoTags(AllTrim(QRY->ZF0_ENDTRA)) })
	aAdd(aCardData ,{"cd_ceptransp"			, _NoTags(AllTrim(QRY->ZF0_CEPTRA)) })
	aAdd(aCardData ,{"nm_estadotransp"		, _NoTags(AllTrim(QRY->ZF0_ESTTRA)) })
	aAdd(aCardData ,{"nm_cidadetransp"		, _NoTags(AllTrim(QRY->ZF0_CIDTRA)) })
	aAdd(aCardData ,{"nm_bairrotransp"		, _NoTags(AllTrim(QRY->ZF0_BAITRA)) })
	aAdd(aCardData ,{"cd_inscesttransp"		, _NoTags(AllTrim(QRY->ZF0_IETRAN)) })
	aAdd(aCardData ,{"nm_coletatransp"		, _NoTags(AllTrim(QRY->ZF0_COLETA)) })
	aAdd(aCardData ,{"tp_fretetransp"		, IIF(QRY->ZF0_FRETE == "E","Emitente","Destinatario") })
	aAdd(aCardData ,{"nm_especietransp"		, _NoTags(AllTrim(QRY->ZF0_ESPECI)) })
	aAdd(aCardData ,{"val_qtdeespecietransp", _NoTags(ALLTRIM(Transform(  QRY->ZF0_QTDESP  ,"@E 999999999999999"))) })
	aAdd(aCardData ,{"val_pesoliqtransp"	, _NoTags(ALLTRIM(Transform(  QRY->ZF0_PESLIQ  ,"@E 999,999,999,999,999.9999"))) })
	aAdd(aCardData ,{"val_pesobrutotransp"	, _NoTags(ALLTRIM(Transform(  QRY->ZF0_PESBRU  ,"@E 999,999,999,999,999.9999"))) })
EndIf
//Valores Default
aAdd(aCardData ,{"cd_moeda"	, "1" })
aAdd(aCardData ,{"dt_emissao"	, STRZERO(day(date()),2)+"/"+STRZERO(month(date()),2)+"/"+STRZERO(year(date()),4) })

//Busca os itens da solicitação do portal
If Select("TEMP") <> 0
	TEMP->(DbCloseArea())
EndIf
cQry := " Select * 
cQry += " From "+RetSQLName("ZF1")
cQry += " Where D_E_L_E_T_ <> '*' 
cQry += " 	AND ZF1_FILIAL = '"+QRY->ZF0_FILIAL+"'
cQry += " 	AND ZF1_CODEMP = '"+QRY->ZF0_CODEMP+"'
cQry += " 	AND ZF1_CODFIL = '"+QRY->ZF0_CODFIL+"'
cQry += " 	AND ZF1_CODIGO = '"+QRY->ZF0_CODIGO+"'
dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQry), "TEMP", .F., .T.)

//Processamento dos itens da integração
TEMP->(DbGoTop())
If TEMP->(!EOF())
	nCount := 0
	While TEMP->(!EOF())
		nCount++
		aAdd(aCardData ,{"item_cod___"		+ALLTRIM(STR(nCount))+"" ,_NoTags(AllTrim(TEMP->ZF1_CODPRO))})
		aAdd(aCardData ,{"item_desc___"		+ALLTRIM(STR(nCount))+"" ,_NoTags(AllTrim(TEMP->ZF1_DESPRO))})
		aAdd(aCardData ,{"cod_serv___"		+ALLTRIM(STR(nCount))+"" ,_NoTags(getISS(cCodAmb,cCodEmp,TEMP->ZF1_CODPRO))})
		aAdd(aCardData ,{"item_unid___"		+ALLTRIM(STR(nCount))+"" ,_NoTags(AllTrim(TEMP->ZF1_UNID))})
		aAdd(aCardData ,{"item_qtde___"		+ALLTRIM(STR(nCount))+"" ,_NoTags(AllTrim(Str(TEMP->ZF1_QTDE)))})
		aAdd(aCardData ,{"item_qtde_lib___"	+ALLTRIM(STR(nCount))+"" ,"0"})
		aAdd(aCardData ,{"item_unit___"		+ALLTRIM(STR(nCount))+"" ,_NoTags(ALLTRIM(Transform(  TEMP->ZF1_PRECO  ,"@E 999,999,999,999,999.9999"))) })
		aAdd(aCardData ,{"item_armazem___"	+ALLTRIM(STR(nCount))+"" ,_NoTags(AllTrim(TEMP->ZF1_LOCAL))})
		TEMP->(DbSkip())
	EndDo
EndIf
aAdd(aCardData ,{"qtItens"	, ALLTRIM(STR(nCount)) })
aAdd(aCardData ,{"showCCusto"	, CheckCCusto(cCodAmb,cCodEmp) })

//Atribui CardData
For nCount	:= 1 to Len(aCardData)
	Aadd(FlgWs:oWSsimpleStartProcesscardData:oWSitem, ECMWorkflowEngineServiceService_stringArray():New())
	For nY := 1 to Len(aCardData[nCount])
		xValor := aCardData[nCount][nY]
		If ValType(xValor) == "L"
			xValor := IIF(xValor,"true","false")
		ElseIf ValType(xValor) == "D"
			xValor := DtoC(xValor)
		ElseIf ValType(xValor) == "N"
			xValor := AllTrim(Str(xValor))
		EndIf
		Aadd(aTail(FlgWs:oWSsimpleStartProcesscardData:oWSitem):cItem, xValor)
	Next nY
Next nX

//Inicialização do processo no fluig.
If FlgWs:simpleStartProcess()
	If len(FlgWs:oWSsimpleStartProcessresult:CITEM) < 5
		Conout("$GT --- GTFLG002 - ["+ALLTRIM(STR(ThreadID()))+"] - "+DTOS(date())+" - "+Time()+;
													" - ZF0_CODEMP+ZF0_CODFIL+ZF0_CODIGO ["+QRY->ZF0_CODEMP+QRY->ZF0_CODFIL+QRY->ZF0_CODIGO+"] não pode ser aberto")
		NotificaErro(QRY->ZF0_CODEMP+QRY->ZF0_CODFIL,"[Cod.Portal:"+ALLTRIM(QRY->ZF0_CODIGO)+"] = Ocorreu um erro e o processo não pode ser iniciado no Fluig!")
		cUpd := " Update "+RetSQLName("ZF0")
		cUpd += " Set ZF0_NOTIF = 'ERRO_START_FLUIG'
		cUpd += " Where ZF0_CODEMP='"+QRY->ZF0_CODEMP+"' AND ZF0_CODFIL = '"+QRY->ZF0_CODFIL+"' AND ZF0_CODIGO = '"+QRY->ZF0_CODIGO+"'
		TcSQLExec(cUpd)
		Return .T.
	Else
		cProces := cValtoChar(FlgWs:oWSsimpleStartProcessresult:CITEM[5])
		Conout(cProces)
        cProces := STRTRAN(UPPER(cProces),"IPROCESS=","")
		cUpd := " Update "+RetSQLName("ZF0")
		cUpd += " Set ZF0_STATUS='A',ZF0_NUMPRO='"+cProces+"',ZF0_NOTIF = ''
		cUpd += " Where ZF0_CODEMP='"+QRY->ZF0_CODEMP+"' AND ZF0_CODFIL = '"+QRY->ZF0_CODFIL+"' AND ZF0_CODIGO = '"+QRY->ZF0_CODIGO+"'
		TcSQLExec(cUpd)
		ConOut("$GT --- GTFLG002 - ["+ALLTRIM(STR(ThreadID()))+"] - "+DTOS(date())+" - "+Time()+" - R_E_C_N_O_ ="+ALLTRIM(STR(QRY->R_E_C_N_O_))+" Update Fluig="+cProces)
	EndIf
Else
	Conout("GTFLG002 - ZF0_CODEMP+ZF0_CODFIL+ZF0_CODIGO ["+QRY->ZF0_CODEMP+QRY->ZF0_CODFIL+QRY->ZF0_CODIGO+"] Retornou um erro na integração Erro: "+chr(13)+GetWSCError())
	Conout("GTFLG002 - ZF0_CODEMP+ZF0_CODFIL+ZF0_CODIGO ["+QRY->ZF0_CODEMP+QRY->ZF0_CODFIL+QRY->ZF0_CODIGO+"] ElapseTime = "+ElapTime(QRY->ZF0_HORA,time()))
	If ElapTime(QRY->ZF0_HORA,time()) > "00:20:00"
		Conout("$GT --- GTFLG002 - ["+ALLTRIM(STR(ThreadID()))+"] - "+DTOS(date())+" - "+Time()+;
							" - ZF0_CODEMP+ZF0_CODFIL+ZF0_CODIGO ["+QRY->ZF0_CODEMP+QRY->ZF0_CODFIL+QRY->ZF0_CODIGO+"] Definido como erro, passado mais de 20 minutos.")
		cUpd := " Update "+RetSQLName("ZF0")
		cUpd += " Set ZF0_NOTIF = 'TIMEOUT'
		cUpd += " Where ZF0_CODEMP='"+QRY->ZF0_CODEMP+"' AND ZF0_CODFIL = '"+QRY->ZF0_CODFIL+"' AND ZF0_CODIGO = '"+QRY->ZF0_CODIGO+"'
		TcSQLExec(cUpd)	
		NotificaErro(QRY->ZF0_CODEMP+QRY->ZF0_CODFIL,"[Cod.Portal:"+ALLTRIM(QRY->ZF0_CODIGO)+"] = Ocorreu um erro e o processo não pode ser iniciado no Fluig."+;
					" Reprocessamento abortado devido ao tempo decorrido, favor avaliar.")
	Else
		cUpd := " Update "+RetSQLName("ZF0")
		cUpd += " Set ZF0_NOTIF = ''
		cUpd += " Where ZF0_CODEMP='"+QRY->ZF0_CODEMP+"' AND ZF0_CODFIL = '"+QRY->ZF0_CODFIL+"' AND ZF0_CODIGO = '"+QRY->ZF0_CODIGO+"'
		TcSQLExec(cUpd)	
	EndIf
EndIf

Return .T.

/*
Funcao      : getDataSet
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Consulta em DataSet do Fluig.
Autor       : Jean Victor Rocha 
Data/Hora   : 12/05/2016
*/
*-----------------------------------------*
Static Function getDataSet(cDataSet,cBusca)
*-----------------------------------------*
Local WS  := WSECMDatasetServiceService():new()
          
WS:_URL             := URLFLUIG+"ECMDatasetService"
WS:ncompanyId       := ncompanyId
WS:cusername        := cUserAdm
WS:cpassword        := cPassAdm
WS:cname       		:= cDataSet

If cDataSet == "ds_empresa"
	aAdd(Ws:OWSGETDATASETCONSTRAINTS:oWSitem,ECMDatasetServiceService_SEARCHCONSTRAINTDTO():New())
	aTail(Ws:OWSGETDATASETCONSTRAINTS:OWSITEM):CCONTRAINTTYPE := "MUST"
	aTail(Ws:OWSGETDATASETCONSTRAINTS:OWSITEM):CFIELDNAME := "nr_cnpj_emp"
	aTail(Ws:OWSGETDATASETCONSTRAINTS:OWSITEM):CFINALVALUE := SubStr(cBusca,1,2)+"%"
	aTail(Ws:OWSGETDATASETCONSTRAINTS:OWSITEM):CINITIALVALUE := SubStr(cBusca,1,2)+"%"
	aTail(Ws:OWSGETDATASETCONSTRAINTS:OWSITEM):LLIKESEARCH := .T.
	
	aAdd(Ws:OWSGETDATASETCONSTRAINTS:oWSitem,ECMDatasetServiceService_SEARCHCONSTRAINTDTO():New())
	aTail(Ws:OWSGETDATASETCONSTRAINTS:OWSITEM):CCONTRAINTTYPE := "MUST"
	aTail(Ws:OWSGETDATASETCONSTRAINTS:OWSITEM):CFIELDNAME := "nr_cnpj_emp"
	aTail(Ws:OWSGETDATASETCONSTRAINTS:OWSITEM):CFINALVALUE := "%"+SubStr(cBusca,3,3)+"%"
	aTail(Ws:OWSGETDATASETCONSTRAINTS:OWSITEM):CINITIALVALUE := "%"+SubStr(cBusca,3,3)+"%"
	aTail(Ws:OWSGETDATASETCONSTRAINTS:OWSITEM):LLIKESEARCH := .T.
	
	aAdd(Ws:OWSGETDATASETCONSTRAINTS:oWSitem,ECMDatasetServiceService_SEARCHCONSTRAINTDTO():New())
	aTail(Ws:OWSGETDATASETCONSTRAINTS:OWSITEM):CCONTRAINTTYPE := "MUST"
	aTail(Ws:OWSGETDATASETCONSTRAINTS:OWSITEM):CFIELDNAME := "nr_cnpj_emp"
	aTail(Ws:OWSGETDATASETCONSTRAINTS:OWSITEM):CFINALVALUE := "%"+SubStr(cBusca,6,3)+"%"
	aTail(Ws:OWSGETDATASETCONSTRAINTS:OWSITEM):CINITIALVALUE := "%"+SubStr(cBusca,6,3)+"%"
	aTail(Ws:OWSGETDATASETCONSTRAINTS:OWSITEM):LLIKESEARCH := .T.
	
	aAdd(Ws:OWSGETDATASETCONSTRAINTS:oWSitem,ECMDatasetServiceService_SEARCHCONSTRAINTDTO():New())
	aTail(Ws:OWSGETDATASETCONSTRAINTS:OWSITEM):CCONTRAINTTYPE := "MUST"
	aTail(Ws:OWSGETDATASETCONSTRAINTS:OWSITEM):CFIELDNAME := "nr_cnpj_emp"
	aTail(Ws:OWSGETDATASETCONSTRAINTS:OWSITEM):CFINALVALUE := "%"+SubStr(cBusca,9,4)+"%"
	aTail(Ws:OWSGETDATASETCONSTRAINTS:OWSITEM):CINITIALVALUE := "%"+SubStr(cBusca,9,4)+"%"
	aTail(Ws:OWSGETDATASETCONSTRAINTS:OWSITEM):LLIKESEARCH := .T.
	
	aAdd(Ws:OWSGETDATASETCONSTRAINTS:oWSitem,ECMDatasetServiceService_SEARCHCONSTRAINTDTO():New())
	aTail(Ws:OWSGETDATASETCONSTRAINTS:OWSITEM):CCONTRAINTTYPE := "MUST"
	aTail(Ws:OWSGETDATASETCONSTRAINTS:OWSITEM):CFIELDNAME := "nr_cnpj_emp"
	aTail(Ws:OWSGETDATASETCONSTRAINTS:OWSITEM):CFINALVALUE := "%"+SubStr(cBusca,13,2)
	aTail(Ws:OWSGETDATASETCONSTRAINTS:OWSITEM):CINITIALVALUE := "%"+SubStr(cBusca,13,2)
	aTail(Ws:OWSGETDATASETCONSTRAINTS:OWSITEM):LLIKESEARCH := .T.
	
	aAdd(Ws:OWSGETDATASETCONSTRAINTS:oWSitem,ECMDatasetServiceService_SEARCHCONSTRAINTDTO():New())
	aTail(Ws:OWSGETDATASETCONSTRAINTS:OWSITEM):CCONTRAINTTYPE := "MUST"
	aTail(Ws:OWSGETDATASETCONSTRAINTS:OWSITEM):CFIELDNAME := "metadata#active"
	aTail(Ws:OWSGETDATASETCONSTRAINTS:OWSITEM):CFINALVALUE := "true"
	aTail(Ws:OWSGETDATASETCONSTRAINTS:OWSITEM):CINITIALVALUE := "true"
	aTail(Ws:OWSGETDATASETCONSTRAINTS:OWSITEM):LLIKESEARCH := .T.
EndIf

Ws:getDataset()
oResult := Ws:OWSGETDATASETDATASET

If (nPos := aScan(oResult:CCOLUMNS, {|x| UPPER(x) == "NR_CNPJ_EMP"})) <> 0
	cCnpj := ""
	For i:=1 to len(oResult:OWSVALUES)
		cCnpj := oResult:OWSVALUES[i]:OWSVALUE[nPos]:TEXT
		cCnpj := STRTRAN(cCnpj,".","")
		cCnpj := STRTRAN(cCnpj,"/","")
		cCnpj := STRTRAN(cCnpj,"-","")
		If Val(cCnpj) <> val(cBusca)
			aDel(oResult:OWSVALUES,i)
			aSize(oResult:OWSVALUES,Len(oResult:OWSVALUES)-1)
			If len(oResult:OWSVALUES) == 0
				Exit
			Else
				i:=0
			EndIf
		EndIf
	Next i
Else
	oResult:OWSVALUES := {}
EndIf

Return oResult

/*
Funcao      : getISS
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Retorna o Codigo ISS cadastrado no produto.
Autor       : Jean Victor Rocha 
Data/Hora   : 17/05/2016
*/
*----------------------------------------------*
Static Function getISS(cCodAmb,cCodEmp,cCodProd)
*----------------------------------------------*
Local cQry := ""
Local cRet := ""

If Select("TMP") <> 0
	TMP->(DbCloseArea())
EndIf

cQry := " Select B1_CODISS
cQry += " From SQL717TB_P1108."+ALLTRIM(cCodAmb)+".dbo.SB1"+ALLTRIM(cCodEmp)+"0
cQry += " Where D_E_L_E_T_ <> '*'

dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQry), 'TMP', .F., .T.)
  
TMP->(DbGoTop())
If TMP->(!EOF())
	cRet := TMP->B1_CODISS
EndIf

Return cRet

/*
Funcao      : getComboSX3
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Retorna o combobox do SX3
Autor       : Jean Victor Rocha 
Data/Hora   : 23/05/2016
*/
*---------------------------------*
Static Function getComboSX3(cCampo)
*---------------------------------*
Local cRet := ""

//Pega as informações do combo do proprio ambiente logado.
SX3->(DbSelectArea("SX3"))
SX3->(DbSetOrder(2))

Do Case
	Case cCampo == "C5_TIPOCLI"
		If SX3->(DbSeek(cCampo))
			cRet := X3CBox()		
		EndIf
	Case cCampo == "C5_TIPO"
		If SX3->(DbSeek(cCampo))
			cRet := X3CBox()		
		EndIf
EndCase

Return cRet

/*
Funcao      : getDest
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Retorna o codigo e loja do destinatario, caso encontre
Autor       : Jean Victor Rocha 
Data/Hora   : 02/06/2016
*/
*--------------------------------------------*
Static Function getDest(cCodAmb,cCodEmp,cCNPJ)
*--------------------------------------------*
Local cQry := ""
Local aret := {"",""}

If EMPTY(ALLTRIM(cCodAmb)) .or. EMPTY(ALLTRIM(cCodEmp)) .or. EMPTY(ALLTRIM(cCNPJ))
	return aRet
EndIf

If Select("TMP") <> 0
	TMP->(DbCloseArea())
EndIf
                                    
cCNPJ := STRTRAN(cCNPJ,"/","")
cCNPJ := STRTRAN(cCNPJ,".","")
cCNPJ := STRTRAN(cCNPJ,"-","")

cQry := " Select TOP 1 A1_COD,A1_LOJA
cQry += " From SQL717TB_P1108."+ALLTRIM(cCodAmb)+".dbo.SA1"+ALLTRIM(cCodEmp)+"0
cQry += " Where D_E_L_E_T_ <> '*'
cQry += " 		AND A1_CGC like '%"+cCNPJ+"%'

dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQry), 'TMP', .F., .T.)
  
TMP->(DbGoTop())
If TMP->(!EOF())
	aRet[1] := TMP->A1_COD
	aRet[2] := TMP->A1_LOJA
EndIf

Return aRet

/*
Funcao      : getTrans
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Retorna o codigo da transportadora, caso encontre
Autor       : Jean Victor Rocha 
Data/Hora   : 02/06/2016
*/
*---------------------------------------------*
Static Function getTrans(cCodAmb,cCodEmp,cCNPJ)
*---------------------------------------------*
Local cQry := ""
Local cRet := ""
    
If EMPTY(ALLTRIM(cCodAmb)) .or. EMPTY(ALLTRIM(cCodEmp)) .or. EMPTY(ALLTRIM(cCNPJ))
	return cRet
EndIf

If Select("TMP") <> 0
	TMP->(DbCloseArea())
EndIf
                                    
cCNPJ := STRTRAN(cCNPJ,"/","")
cCNPJ := STRTRAN(cCNPJ,".","")
cCNPJ := STRTRAN(cCNPJ,"-","")

cQry := " Select TOP 1 A4_COD
cQry += " From SQL717TB_P1108."+ALLTRIM(cCodAmb)+".dbo.SA4"+ALLTRIM(cCodEmp)+"0
cQry += " Where D_E_L_E_T_ <> '*'
cQry += " 		AND A4_CGC like '%"+cCNPJ+"%'

dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQry), 'TMP', .F., .T.)
  
TMP->(DbGoTop())
If TMP->(!EOF())
	cRet := TMP->A4_COD
EndIf

Return cRet

/*
Funcao      : getCNPJAtivo
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Retorna o CNPJ da empresa utilizada como principal
Autor       : Jean Victor Rocha 
Data/Hora   : 23/06/2016
*/
*---------------------------------*
Static Function getCNPJAtivo(cCNPJ)
*---------------------------------*
Local cRet := ""   
Local cQry := ""

cCNPJ := STRTRAN(cCNPJ,"/","")
cCNPJ := STRTRAN(cCNPJ,".","")
cCNPJ := STRTRAN(cCNPJ,"-","")
             
If Select("TMP") <> 0
	TMP->(DbCloseArea())
EndIf

cQry += " Select ZW1A.ZW1_CNPJ
cQry += " From "+RetSQLName("ZW1")+" ZW1
cQry += " 	Left Outer join(Select *
cQry += " 					From "+RetSQLName("ZW1")
cQry += " 					where D_E_L_E_T_ <> '*') AS ZW1A on ZW1.ZW1_CODIGO = ZW1A.ZW1_CODIGO
cQry += " 	inner join (Select *
cQry += " 						From SQLTB717_P11.GTCORP_P11.dbo.SA1Z40
cQry += " 						Where D_E_L_E_T_ <> '*') AS SA1 on SA1.A1_CGC = ZW1A.ZW1_CNPJ
cQry += " where ZW1.D_E_L_E_T_ <> '*' 
cQry += " 	AND ZW1.ZW1_CNPJ = '"+cCNPJ+"'

dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQry), 'TMP', .F., .T.)
  
TMP->(DbGoTop())
If TMP->(!EOF())
	cRet := TMP->ZW1_CNPJ
EndIf

Return cRet
          
/*
Funcao      : CheckCCusto
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Retorna Se o campo CCusto vai ser habilitado ou não.
Autor       : Jean Victor Rocha 
Data/Hora   : 22/07/2016
*/
*------------------------------------------*
Static Function CheckCCusto(cCodAmb,cCodEmp)
*------------------------------------------*
Local cRet := ""   
Local cQry := ""

If Select("TMP") <> 0
	TMP->(DbCloseArea())
EndIf
         
cQry += " SELECT t.name as TableName, c.name as ColumnName
cQry += " FROM SQL717TB_P1108."+ALLTRIM(cCodAmb)+".sys.columns c 
cQry += " INNER JOIN SQL717TB_P1108."+ALLTRIM(cCodAmb)+".sys.tables t ON c.object_id = t.object_id
cQry += " WHERE c.name like 'C6_P_CC' AND t.name like 'SC6"+ALLTRIM(cCodEmp)+"0'

dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQry), 'TMP', .F., .T.)
  
TMP->(DbGoTop())
If TMP->(!EOF())
	cRet := "sim"
Else
	cRet := "nao"
EndIf

Return cRet

/*
Funcao      : NotificaErro
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Envia email de notificação de erro no processamento
Autor       : Jean Victor Rocha 
Data/Hora   : 23/06/2016
*/
*----------------------------------------*
Static Function NotificaErro(cChave,cErro)
*----------------------------------------*
Local cNomeEmp := ""

cMailConta	:= GETMV("MV_EMCONTA",,"totvs@br.gt.com")
cMailServer	:= GETMV("MV_RELSERV",,"mail.br.gt.com")
cMailSenha	:= GETMV("MV_EMSENHA",,"Email@14")


ZW1->(DbSetOrder(1))
If ZW1->(DbSeek(xFilial("ZW1")+AllTrim(cChave)))
	cNomeEmp := ALLTRIM(ZW1->ZW1_RAZAO)
EndIf

cSubject := "[GT] - Erro no processamento Solicitação de faturamento"
cTexto := "<p>Olá,</p><br>"
cTexto += "<p>Identificado um erro no processamento da integração da Solicitação de faturamento</p>"
cTexto += "<br>"
cTexto += "<p>Empresa: "+cNomeEmp
cTexto += "<p>Cod./Filial: "+cChave
cTexto += "<br>Erro: "+cErro
cTexto += "<br>* Este erro pode ter sido causado por falta de cadastro da empresa no Fluig e/ou o cadastro da equipe. Verifique junto a equipe de implantação.
cTexto += "</p>"
cTexto += "<br>"
cTexto += "<p>Este e-mail foi enviado automaticamente, não responder!"
cTexto += "<br><b>Grant Thornton Brasil.</b></p>"
cTexto += "<img src='http://www.grantthornton.com.br/globalassets/1.-member-firms/global/logos/logo.png'>"

oMessage			:= TMailMessage():New()
oMessage:Clear()
oMessage:cDate		:= cValToChar(Date())
oMessage:cFrom		:= cMailConta
oMessage:cTo		:= "elias.vitorino@br.gt.com;luana.alves@br.gt.com; suporte.fluig@br.gt.com"
oMessage:cCC 		:= "fernanda.bernardes@br.gt.com;jefferson.bernardino@br.gt.com;priscila.santos@br.gt.com;vilma.oliveira@br.gt.com;juliane.balbo@br.gt.com;willian.galindo@br.gt.com;tatiane.miranda@br.gt.com"
oMessage:cBCC 		:= "jean.rocha@br.gt.com"//copia oculta
oMessage:cSubject	:= cSubject
oMessage:cBody		:= cTexto

oServer				:= tMailManager():New()
cUser				:= cMailConta
cPass				:= cMailSenha
xRet := oServer:Init( "", cMailServer, cUser, cPass, 0, 0 )
If xRet != 0
	conout( "Could not initialize SMTP server: " + oServer:GetErrorString( xRet ) )
	lEnvioOK := .F.
EndIf
xRet := oServer:SetSMTPTimeout( 60 )
If xRet != 0
    conout( "Could not set timeout to " + cValToChar( 60 ) ) 
	lEnvioOK := .F.
EndIf
xRet := oServer:SMTPConnect()
If xRet <> 0
	conout( "Could not connect on SMTP server: " + oServer:GetErrorString( xRet ) )
	lEnvioOK := .F.
EndIf
xRet := oServer:SmtpAuth( cUser, cPass )
If xRet <> 0
    conout( "Could not authenticate on SMTP server: " + oServer:GetErrorString( xRet ) )
    lEnvioOK := .F.
    oServer:SMTPDisconnect()
EndIf      
//Envio
xRet := oMessage:Send( oServer )
If xRet <> 0
    conout( "Could not send message: " + oServer:GetErrorString( xRet ))
    lEnvioOK := .F.
EndIf
//Encerra
xRet := oServer:SMTPDisconnect()
If xRet <> 0
    conout("Could not disconnect from SMTP server: " + oServer:GetErrorString(xRet))
    lEnvioOK := .F.
EndIf

Return .T.