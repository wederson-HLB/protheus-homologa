#Include "Protheus.ch"
#INCLUDE "APWIZARD.CH"

STATIC __lBlind		:= IsBlind()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FINAJUTAM  �Autor  �TOTVS SA           � Data �  16/11/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao principal para altera��o de campos na base de dados ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User function FinAjuTam()
Private oWizard
Private aRet	:= { 0, 0, MsDate(),1}
Private lOk		:= .T.
Private lWizard:= .T. //Uso interno da fun��o parambox()

oWizard := APWizard():New( "Assistente para Ajuste de campos." ,"Aten��o!" ,;
"",;
"Este assistente tem como finalidade alterar os valores dos campos E2_TITPAI, E1_TITPAI e/ou E5_DOCUMEN ap�s altera��o do grupo de campos 'Parcela' no SIGACFG.";
+CHR(10)+CHR(13)+"- Somente rodar este ajuste em modo exclusivo!";
+CHR(10)+CHR(13)+"- Realizar backup do banco de dados antes da atualiza��o.";
+CHR(10)+CHR(13)+"- Rodar a atualiza��o primeiramente em base de homologa��o.";
+CHR(10)+CHR(13)+"- Esta rotina est� preparada para ser rodada apenas 1 vez, portanto, tenha certeza dos dados que ser�o informados na pr�xima tela!"/*<cText>*/,;
{||.T.}, {|| .T.},,,,) 
			
oWizard:NewPanel("Informe os dados abaixo.", "Informe o tamanho anterior e posterior do Grupo de Campos 'PARCELA' para que o ajuste possa corrigir o campo selecionado." ,{||.T.}/*<bBack>*/, ;
{||.T.} /*<bNext>*/ , ;
{||U_FinExecAj(@aRet)} ,;
.T.  ,;
{|| U_FinChoice(@oWizard,1)} )

ACTIVATE WIZARD oWizard CENTERED  WHEN {||.T.}

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FinChoice �Autor  �TOTVS SA            � Data �  16/11/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao que cria a parambox com os campos necessarios para a ���
���          � execu��o da rotina                                         ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User function FinChoice(oWizard,nPanel)
Local aOpcoes	:= {}
Local aParamFields := {}
Local lTitPai2 := !Empty( SE2->( FieldPos( "E2_TITPAI" ) ) )
Local lTitPai1 := !Empty( SE1->( FieldPos( "E1_TITPAI" ) ) )
Local lDocumen := !Empty( SE5->( FieldPos( "E5_DOCUMEN" ) ) )

If lTitPai2
	aadd(aOpcoes, "1=E2_TITPAI")
Endif

If lTitPai1
	aadd(aOpcoes, "2=E1_TITPAI")
Endif

If lDocumen
	aadd(aOpcoes, "3=E5_DOCUMEN")
Endif

MV_PAR01 := 0
MV_PAR02 := 0

aAdd(aParamFields, {1,"Tamanho Antigo: ",1,"@E 999","MV_PAR01<4 .AND. MV_PAR01>0","","",20,.T.})
aAdd(aParamFields, {1,"Novo Tamanho : ",1,"@E 999","MV_PAR02<4 .AND. MV_PAR02>0","","",20,.T.})
aAdd(aParamFields, {1,"At� Emiss�o : ",aRet[3],"","","","",45,.T.})

aAdd(aParamFields, {2,"Ajustar: ","1",aOpcoes,80,"",.T.})

ParamBox(aParamFields ,"Executar Ajuste" , @aRet,,,.F.,120,3,oWizard:oMPanel[oWizard:nPanel],,.F. )

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FinExecAj �Autor  �TOTVS SA            � Data �  16/11/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao que executa a query de acerto dos campos E2_TITPAI  ���
���          � e E5_DOCUMEN                                               ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function FinExecAj(aRet)
Local aLog2New	:= {}
Local aLog2Old	:= {}
Local nOldTam	:= 0
Local nNewTam	:= 0
Local nOpc		:= 0
Local nX			:= 0
Local nTamPre	:= 0
Local nTamNum	:= 0
Local nTamTotal:= 0
Local cSinal	:= ""
Local cQuery	:= ""
Local cAlias	:= ""
Local cRet		:= ""
Local cEmissao	:= ""
Local cFileLog	:= ""
Local cPath		:= ""
Local cTipoDB	:= Alltrim(Upper(TCGetDB()))

// N�o � correto e aconselhado a diminui��o do tamanho do campo PARCELA por motivos inclusive se integridade dos dados na base.
IF (MV_PAR01 >= MV_PAR02)
	MSGALERT("Caso tenha alterado o grupo de campos 'Parcela' para um tamanho menor, esta fun��o n�o ser� v�lida da forma que se encontra."+CHR(10)+CHR(13);
		+ "Execu��o desta fun��o ser� abortada!")
	lOk := .F.
Else
	lOk := MsgYesNo("A base de dados ser� alterada ap�s esta confirma��o! Tem certeza que deseja atualiz�-la?")
Endif

If lOk

	// Verifico qual o sinal correto para concatenar dados na query
	Do Case
		Case "MSSQL" $ cTipoDB
			cSinal := "+"
		Case cTipoDB $ "AS/400|DB2"
			cSinal := "concat"
		Otherwise
			cSinal := "||"
	End Case

	/////////// Alimento as variaves principais para o UPDATE /////////////
	nOldTam	:= aRet[1]
	nNewTam	:= aRet[2]
	cEmissao	:= DtoS(aRet[3])
	nOpc		:= If(ValType(aRet[4])=="N", aRet[4], Val(aRet[4]))
	///////////////////////////////////////////////////////////////////////
	
	If nOpc == 1
		cAlias := "SE2"  // E2_TITPAI
	Elseif nOpc == 2
		cAlias := "SE1"  // E1_TITPAI
	Else
		cAlias := "SE5"  // E5_DOCUMEN
	Endif
	
	// Tamanhos de campos que fazem parte da chave do E2_TITPAI e E5_DOCUMEN
	nTamPre	:= TamSx3("E2_PREFIXO")[1]
	nTamNum	:= TamSx3("E2_NUM")[1]
	nTamTotal:= TamSx3("E2_TIPO")[1] + TamSx3("E2_FORNECE")[1] + TamSx3("E2_LOJA")[1]
	nDifTam	:= Iif(nNewTam-nOldTam < 0, 0, nNewTam-nOldTam)
	           
	// --> Gravo em um array os dados dos registros que ser�o alterados para gera��o de LOG
	aLog2Old := U_GetOldReg(cAlias,cEmissao)
	
	Begin Transaction
		cQuery := "UPDATE "+RetSqlName(cAlias)+" "
		If cAlias == "SE2"
			cQuery += " SET E2_TITPAI = SUBSTRING(E2_TITPAI,1,"+STR(nTamPre)+")"
			cQuery += cSinal+" SUBSTRING(E2_TITPAI,"+STR(nTamPre+1)+","+STR(nTamNum)+") "
			cQuery += cSinal+" SUBSTRING(E2_TITPAI,"+STR(nTamPre+nTamNum+1)+","+STR(nOldTam)+")"+cSinal+"'"+Space(nDifTam)+"' "
			cQuery += cSinal+" SUBSTRING(E2_TITPAI,"+STR(nTamPre+nTamNum+nOldTam+1)+","+STR(nTamTotal)+") "
			cQuery += "WHERE E2_TITPAI != ' ' AND E2_EMISSAO <= '"+cEmissao+"' AND D_E_L_E_T_ <> '*' "
		Elseif cAlias == "SE1"
			cQuery += " SET E1_TITPAI = SUBSTRING(E1_TITPAI,1,"+STR(nTamPre)+")"
			cQuery += cSinal+" SUBSTRING(E1_TITPAI,"+STR(nTamPre+1)+","+STR(nTamNum)+") "
			cQuery += cSinal+" SUBSTRING(E1_TITPAI,"+STR(nTamPre+nTamNum+1)+","+STR(nOldTam)+")"+cSinal+"'"+Space(nDifTam)+"' "
			cQuery += cSinal+" SUBSTRING(E1_TITPAI,"+STR(nTamPre+nTamNum+nOldTam+1)+","+STR(nTamTotal)+") "
			cQuery += "WHERE E1_TITPAI != ' ' AND E1_EMISSAO <= '"+cEmissao+"' AND D_E_L_E_T_ <> '*' "
		Else
			cQuery += " SET E5_DOCUMEN = SUBSTRING(E5_DOCUMEN,1,"+STR(nTamPre)+")"
			cQuery += cSinal+" SUBSTRING(E5_DOCUMEN,"+STR(nTamPre+1)+","+STR(nTamNum)+") "
			cQuery += cSinal+" SUBSTRING(E5_DOCUMEN,"+STR(nTamPre+nTamNum+1)+","+STR(nOldTam)+")"+cSinal+"'"+Space(nDifTam)+"' "
			cQuery += cSinal+" SUBSTRING(E5_DOCUMEN,"+STR(nTamPre+nTamNum+nOldTam+1)+","+STR(nTamTotal)+") "
			cQuery += "WHERE E5_DOCUMEN != ' ' AND E5_DATA <= '"+cEmissao+"' AND E5_MOTBX = 'CMP' AND D_E_L_E_T_ <> '*' "
		Endif

		// Prote��o de qual fun��o dever� ser chamada caso n�o seja SQL.
		If cTipoDB != "MSSQL"
			cQuery:=StrTran(cQuery,"SUBSTRING","SUBSTR")
		Endif

		// *** Execu��o e valida��o do retorno *** //
		cRet := TcSqlExec(cQuery)
		If cRet <> 0
			If !__lBlind
	 			MsgAlert("Erro ao executar UPDATE: "+TCSqlError())  //'Erro criando a Stored Procedure:'
				conout('SQL Error - '+DtoC(MsDate())+" - " + Substr(Time(),1,5))
				conout(MsParseError())
			Endif
			lRet := .F.
		Else
			MsgAlert("UPDATE executado com sucesso!")
		Endif
		// *** *** *** *** *** *** *** *** *** *** //
	End Transaction

   // --> Grava��o dos registros depois de alterados para gera��o do LOG final
	aLog2New := U_GetNewReg(cAlias,cEmissao)
Endif

// ********* GERA��O DO LOG ********* //
If !Empty(aLog2New)
	If nOpc == 1
		AutoGrLog("LOG do campo 'E2_TITPAI' - " +DtoC(MsDate())+ ' ' + Time() )
	Elseif nOpc == 2
		AutoGrLog("LOG do campo 'E1_TITPAI' - " +DtoC(MsDate())+ ' ' + Time() )
	Else
		AutoGrLog("LOG do campo 'E5_DOCUMEN' - " +DtoC(MsDate())+ ' ' + Time() )
	Endif
	
	For nX := 1 To Len(aLog2New)
		AutoGrLog("-----------------------------------------------------")
		AutoGrLog("Valor Antigo  : "		+ aLog2Old[nX][1])
		AutoGrLog("Valor Novo    : "		+ aLog2New[nX][1])
		AutoGrLog("Recno do Registro : "	+ STR(aLog2Old[nX][2]))
	Next

	cFileLog := NomeAutoLog()

	If cFileLog <> ""
		MostraErro(cPath,cFileLog)
	Endif
EndIf
 
EcdClrMsg() // limpo o controle de mensagens de erro

// ********* FINAL DA GERA��O DO LOG ********* //

Return lOk


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetOldReg �Autor  �Microsiga           � Data �  11/16/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
USER Function GetOldReg(cAlias,cEmissao)
Local aRetOld	:= {}
Local cSql		:= ""
Local cAliasTmp:= ""

If cAlias == "SE2"
	cSql := "SELECT SE2.E2_TITPAI TITPAI, SE2.R_E_C_N_O_ REC FROM "+RetSqlName(cAlias)+" SE2 "
	cSql += "WHERE E2_TITPAI != '' AND E2_EMISSAO <= '"+cEmissao+"' AND D_E_L_E_T_ != '*' "
ElseIf cAlias == "SE1"
	cSql := "SELECT SE1.E1_TITPAI TITPAI, SE1.R_E_C_N_O_ REC FROM "+RetSqlName(cAlias)+" SE1 "
	cSql += "WHERE E1_TITPAI != '' AND E1_EMISSAO <= '"+cEmissao+"' AND D_E_L_E_T_ != '*' "
Else
	cSql := "SELECT SE5.E5_DOCUMEN DOCUMENTO, SE5.R_E_C_N_O_ REC FROM "+RetSqlName(cAlias)+" SE5 "
	cSql += "WHERE E5_DOCUMEN != '' AND E5_MOTBX = 'CMP' AND D_E_L_E_T_ != '*' "
Endif

cSql := ChangeQuery(cSql)

cAliasTmp := GetNextAlias()

dbUseArea(.T., "TOPCONN", TcGenQry(,,cSql), cAliasTmp, .T., .T.)

If cAlias $ "SE2|SE1"

	While (cAliasTmp)->(!EOF())
		aAdd(aRetOld, { (cAliasTmp)->(TITPAI) , (cAliasTmp)->(REC) } )
		(cAliasTmp)->(dbSkip())
	EndDo

Else
	While (cAliasTmp)->(!EOF())
		aAdd(aRetOld, { (cAliasTmp)->(DOCUMENTO) , (cAliasTmp)->(REC) } )
		(cAliasTmp)->(dbSkip())
	EndDo
	
EndIf

If Select(cAliasTmp)>0
	(cAliasTmp)->(dbCloseArea())
Endif

Return aRetOld


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetNewReg �Autor  �Microsiga           � Data �  11/16/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

USER Function GetNewReg(cAlias,cEmissao)
Local aRetNew	:= {}
Local cSql		:= ""
Local cAliasTmp:= ""

If cAlias == "SE2"
	cSql := "SELECT SE2.E2_TITPAI TITPAI, SE2.R_E_C_N_O_ REC FROM "+RetSqlName(cAlias)+" SE2 "
	cSql += "WHERE E2_TITPAI != '' AND E2_EMISSAO <= '"+cEmissao+"' AND D_E_L_E_T_ != '*' "

ElseIf cAlias == "SE1"
	cSql := "SELECT SE1.E1_TITPAI TITPAI, SE1.R_E_C_N_O_ REC FROM "+RetSqlName(cAlias)+" SE1 "
	cSql += "WHERE E1_TITPAI != '' AND E1_EMISSAO <= '"+cEmissao+"' AND D_E_L_E_T_ != '*' "

Else
	cSql := "SELECT SE5.E5_DOCUMEN DOCUMENTO, SE5.R_E_C_N_O_ REC FROM "+RetSqlName(cAlias)+" SE5 "
	cSql += "WHERE E5_DOCUMEN != '' AND E5_MOTBX = 'CMP' AND D_E_L_E_T_ != '*' "
Endif

cSql := ChangeQuery(cSql)

cAliasTmp := GetNextAlias()

dbUseArea(.T., "TOPCONN", TcGenQry(,,cSql), cAliasTmp, .T., .T.)

If cAlias $ "SE2|SE1"

	While (cAliasTmp)->(!EOF())
		aAdd(aRetNew, { (cAliasTmp)->(TITPAI) , (cAliasTmp)->(REC) } )
		(cAliasTmp)->(dbSkip())
	EndDo
   
Else
	While (cAliasTmp)->(!EOF())
		aAdd(aRetNew, { (cAliasTmp)->(DOCUMENTO) , (cAliasTmp)->(REC) } )
		(cAliasTmp)->(dbSkip())
	EndDo
EndIf   

If Select(cAliasTmp)>0
	(cAliasTmp)->(dbCloseArea())
Endif

Return aRetNew
