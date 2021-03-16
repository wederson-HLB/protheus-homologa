#include 'protheus.ch'
#include 'parmtype.ch'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂ¿±±
±±?Programa  * F022ATUNF.PRW *                            ³±?
±±?Autor     * Guilherme Fernandes Pilan - GFP *          ³±?
±±?Data      * 06/02/2017 - 11:05 *                       ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁ´±±
±±?Descricao * Ponto de Entrada do fonte MATA460 *        ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±?PE        * F022ATUNF * Ponto de Entrada executado ao  ³±?
±±?          *             final da geração da NFS-e *    ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±?Uso       * FATURAMENTO                                ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
*-----------------------*
User Function F022ATUNF()
*-----------------------*
Local aOrd
Local i
Private cSerie		:= ParamIxb[1]
Private cNumero		:= ParamIxb[2]
Private cProtocolo	:= ParamIxb[3]
Private cNumNFS		:= ""//If(!Empty(cProtocolo),ParamIxb[5],"") 

If !Empty(cProtocolo) //.AND. MsgYesNo("Enviar e-mail ao cliente com NFS-e e Boleto?","Grant Thornton")
	aOrd := SaveOrd({"SE1","SF2","SA1","Z91"})
	
	SF2->(DbSetOrder(1))
	If SF2->(DbSeek(xFilial("SF2")+AvKey(cNumero,"F2_DOC")+AvKey(cSerie,"F2_SERIE")))
		If !Empty(SF2->F2_NFELETR)
			cNumNFS	:= SF2->F2_NFELETR
		EndIf
		SA1->(DbSetOrder(1))
		If SA1->(DbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA)) .AND. SA1->A1_EST <> "EX"  // Somente envia email quando Cliente for nacional.
			U_GTFAT016()  // Tratamento de transmissão de NFS-e, geração de boleto Contas a Receber e envio de e-mail.
		EndIf
	EndIf            

	//Integração com ambiente do cliente para geração de NF de entrada
	If !Empty(cNumNFS)
		Processa({|| IntegraNF() } , "Notas Fiscais de Entrada de clientes...")
	EndIf

	RestOrd(aOrd,.T.)
EndIf
Return Nil
          
/*
Funcao      : IntegraNF 
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Integração com ambiente do cliente para geração de NF de entrada
Autor       : Jean Victor Rocha
Data/Hora   : 12/04/2017
*/
*-------------------------*
Static Function IntegraNF()
*-------------------------*
//Integração com ambiente de cliente, gera a NF de entrada.
Local lIntegra	:= .F.
Local cQryInte	:= ""  
Local cPara		:= ""
Local cCompName	:= ComputerName()
Local aErros := {}
Local aCond := {}
Local aItensD2 := {}

//Verifica se esta habilitada a rotina de integração
If select("TRBX5")>0
	TRBX5->(DbCloseArea())
EndIf
cQryInte := " SELECT X5_DESCRI FROM SX5YY0 WHERE X5_TABELA='ZO' AND X5_CHAVE='LIGADO'"
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryInte),"TRBX5",.T.,.T.)
COUNT TO nRecCount
If nRecCount > 0
	TRBX5->(DbGotop())
	If (lIntegra := (alltrim(upper(TRBX5->X5_DESCRI)) == 'T' .OR. alltrim(upper(TRBX5->X5_DESCRI)) == '.T.'))
		CONOUT("O X5 da empresa YY - X5_TABELA='ZO' AND X5_CHAVE='LIGADO' está como T, ou seja: ligado")
	EndIf
EndIf

//Inicia a integração da NF
If lIntegra
	CONOUT("F022ATUNF - ROTINA DE INTEGRAÇÃO DE NF COM BASE DO CLIENTE")
	aNotEmpty := {"A1_P_GERA","A1_P_BANCO","A1_P_CODIG","A1_P_CODFI","A1_P_SERVI","A1_P_PORTA"}

	SF2->(DbSetOrder(1))
	If SF2->(DbSeek(xFilial("SF2")+AvKey(cNumero,"F2_DOC")+AvKey(cSerie,"F2_SERIE")))
		SA1->(DbSetOrder(1))
		//Validações para geração da NF
		If SA1->(DbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA))
			If SA1->(FieldPos("A1_P_GERA")) <> 0 .and. SA1->(FieldPos("A1_P_CODFI")) <> 0 .and. SA1->(FieldPos("A1_P_CODIG")) <> 0
				If SA1->A1_P_GERA//Verifica se o cliente esta habilitado para integração
					For i:=1 to Len(aNotEmpty)
						If SA1->(FieldPos(aNotEmpty[i])) <> 0
							If EMPTY(SA1->(&(aNotEmpty[i])))
								AADD(aErros,{"ERRO",cmodulo,SF2->F2_FILIAL,SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_TIPO,SF2->(RECNO()),;
										  		"cliente com o campo '"+aNotEmpty[i]+"' não preenchido",date(),;
										   		dDataBase ,time(), __cUserId ,cUserName,GetEnvServer(),cCompName,cEmpAnt, cFilAnt,SA1->A1_P_CODIG,SA1->A1_P_CODFI,"","","",""}) 
							EndIf
						Else  
							AADD(aErros,{"ERRO",cmodulo,SF2->F2_FILIAL,SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_TIPO,SF2->(RECNO()),;
										"Campo '"+aNotEmpty[i]+"' não existe no ambiente",;
										date(), dDataBase ,time(), __cUserId ,cUserName,GetEnvServer(),cCompName,cEmpAnt,cFilAnt,SA1->A1_P_CODIG,SA1->A1_P_CODFI,"","","",""}) 
					    EndIf
					next i
				Else
			   		AADD(aErros,{"ERRO",cmodulo,SF2->F2_FILIAL,SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_TIPO,SF2->(RECNO()),;
									"Empresa não possui integração habilitado no cadastro do cliente.",;
									date(), dDataBase ,time(), __cUserId ,cUserName,GetEnvServer(),cCompName,cEmpAnt,cFilAnt,"","","","","",""}) 
				EndIf
			Else
				AADD(aErros,{"ERRO",cmodulo,SF2->F2_FILIAL,SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_TIPO,SF2->(RECNO()),;
									"Campo 'A1_P_GERA','A1_P_CODIG' e 'A1_P_CODFI' não existe no ambiente",;
									date(), dDataBase ,time(), __cUserId ,cUserName,GetEnvServer(),cCompName,cEmpAnt,cFilAnt,"","","","","",""}) 				
			EndIf
		Else
			AADD(aErros,{"ERRO",cmodulo,SF2->F2_FILIAL,SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_TIPO,SF2->(RECNO()),;
									"Cliente não encontrado",;
									date(), dDataBase ,time(), __cUserId ,cUserName,GetEnvServer(),cCompName,cEmpAnt, cFilAnt,SA1->A1_P_CODIG,SA1->A1_P_CODFI,"","","",""}) 
		EndIf
		If EMPTY(SM0->M0_CGC)	//ambiente			,empresa		,filial
			AADD(aErros,{"ERRO",cmodulo,SF2->F2_FILIAL,SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_TIPO,SF2->(RECNO()),;
						"cadastro do cnpj da empresa:"+alltrim(SM0->M0_NOME)+" em branco",;
						date(), dDataBase ,time(), __cUserId ,cUserName,GetEnvServer(),cCompName,cEmpAnt, cFilAnt,SA1->A1_P_CODIG,SA1->A1_P_CODFI,"","","",""}) 
		Else
			//Inicia a gravação da NF.
			If len(aErros) == 0
				//Condição de pagamento
				If SELECT("TRBSE4")>0
					TRBSE4->(DbCloseArea())
				EndIf
				cQry2 := " SELECT E4_CODIGO,E4_TIPO,E4_COND,E4_DESCRI FROM "+RETSQLNAME("SE4")
				cQry2 += " WHERE D_E_L_E_T_='' AND E4_CODIGO='"+SF2->F2_COND+"' AND E4_FILIAL='"+xFilial("SE4")+"'"
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry2),"TRBSE4",.T.,.T.)
				COUNT TO nRecCount
				If nRecCount>0
					TRBSE4->(DbGotop())
					AADD(aCond,TRBSE4->E4_CODIGO)
					AADD(aCond,TRBSE4->E4_TIPO)
					AADD(aCond,TRBSE4->E4_COND)
					AADD(aCond,TRBSE4->E4_DESCRI)									
				EndIf
			
				//Itens da NF
				If select("TRBSD2")>0
					TRBSD2->(DbCloseArea())
				EndIf									
				cQry1 := " SELECT D2_ITEM,D2_COD,D2_QUANT,D2_PRCVEN,D2_TOTAL FROM "+RETSQLNAME("SD2")
				cQry1 += " WHERE D_E_L_E_T_='' AND D2_FILIAL='"+xFilial("SD2")+"' AND D2_DOC='"+SF2->F2_DOC+"' AND D2_SERIE='"+SF2->F2_SERIE+"'"
				cQry1 += " 	 AND D2_CLIENTE='"+SF2->F2_CLIENTE+"' AND D2_LOJA='"+SF2->F2_LOJA+"'"
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry1),"TRBSD2",.T.,.T.)
				COUNT TO nRecCount
				If nRecCount>0
					TRBSD2->(DbGotop())
					While TRBSD2->(!EOF())
						AADD(aItensD2,{TRBSD2->D2_COD,TRBSD2->D2_QUANT,TRBSD2->D2_PRCVEN,TRBSD2->D2_TOTAL})
						TRBSD2->(DbSkip())
					EndDo
				EndIf
			
				//Envio de e-mail de notificação
				If TCSQLExec("SELECT Z08_FUNC FROM [SQLTB717].GTHD.dbo.Z08010")<0
					cPara := "log.sistemas@br.gt.com"
					CONOUT("Tabela não encontrada para enviar o e-mail")									
				Else
					//Query para tratar o e-mail do responsável através da tabela no GTHD
					cQrEma := " SELECT Z08_FUNC FROM [SQLTB717].GTHD.dbo.Z08010"
					cQrEma += " WHERE D_E_L_E_T_='' AND Z08_EMP+Z08_FIL=("
					cQrEma += " 			SELECT TOP 1 Z04_CODIGO+Z04_CODFIL FROM [SQLTB717].GTHD.dbo.Z04010"
					cQrEma += " 			WHERE D_E_L_E_T_='' AND Z04_CNPJ='"+SA1->A1_CGC+"' AND Z04_NOMFIL<>'TESTE') AND Z08_RECNF='T'"

					If Select("TRBPARA")>0
						TRBPARA->(DbCloseArea())
					EndIf
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrEma),"TRBPARA",.T.,.T.)
					COUNT TO nRecCount
					If nRecCount>0
						TRBPARA->(DbGoTop())
						while TRBPARA->(!EOF())
							cPara+=TRBPARA->Z08_FUNC+";"
							TRBPARA->(DbSkip())
						enddo
						cPara:=SUBSTR(cPara,1,len(cPara)-1)
					Else
						Conout("Não foi encontrado responsável pela empresa na tabela Z08010")
						cPara:="log.sistemas@br.gt.com"
					EndIf
				EndIf
			
				cNumDoc := cNumNFS
				cSerie	:= ""
				If EMPTY(cNumDoc)
					cNumDoc := SF2->F2_DOC
					cSerie	:= SF2->F2_SERIE
				EndIf
				//Conecta na empresa que se deseja gravar a nota
				U_GTCORP12(SA1->A1_P_BANCO,SA1->A1_P_CODIG,SA1->A1_P_CODFI,SM0->M0_CGC,cNumDoc,cSerie,SF2->F2_ESPECIE,;
							cEmpAnt,cFilAnt,aCond,aItensD2,SF2->F2_CLIENTE,SF2->F2_LOJA,SM0->M0_NOME,dDataBase,aErros,3,cPara,SA1->A1_P_SERVI,SA1->A1_P_PORTA)
			Else
				//GRAVA OS ERROS NA TABELA DE LOGS
				DbSelectArea("Z91")
				for nCont:=1 to len(aErros)
					Z91->(RecLock("Z91",.T.))
					Z91->Z91_CODIGO := GETSXENUM("Z91","Z91_CODIGO")
					Z91->Z91_OCORRE := aErros[nCont][1]
					Z91->Z91_MODULO := aErros[nCont][2]
					Z91->Z91_X_FIL  := aErros[nCont][3]
					Z91->Z91_X_DOC  := aErros[nCont][4]
					Z91->Z91_X_SERI := aErros[nCont][5]
					Z91->Z91_X_FORN := aErros[nCont][6]
					Z91->Z91_X_LOJA := aErros[nCont][7]
					Z91->Z91_X_TIPO := aErros[nCont][8]
					Z91->Z91_X_RECN := aErros[nCont][9]
					Z91->Z91_DESCRI := aErros[nCont][10]
					Z91->Z91_DATA   := aErros[nCont][11]
					Z91->Z91_DATASI := aErros[nCont][12]
					Z91->Z91_HORA   := aErros[nCont][13]
					Z91->Z91_CODUSE := aErros[nCont][14]
					Z91->Z91_USER   := aErros[nCont][15]
					Z91->Z91_AMBIEN := aErros[nCont][16]
					Z91->Z91_COMPUT := aErros[nCont][17]
					Z91->Z91_EMPORI := aErros[nCont][18]
					Z91->Z91_FILORI := aErros[nCont][19]
					Z91->Z91_EMPDES := aErros[nCont][20]
					Z91->Z91_FILDES := aErros[nCont][21]
					Z91->(MsUnlock())
					CONFIRMSX8()
				next
				Z91->(DbCloseArea())
			EndIf
		EndIf
	Else
   		CONOUT("F022ATUNF - Não encontrada a NF no GTCORP para integração. (chave: )"+xFilial("SF2")+AvKey(cNumero,"F2_DOC")+AvKey(cSerie,"F2_SERIE"))
	EndIf	
Else
	CONOUT("F022ATUNF - O X5 da empresa YY - X5_TABELA='ZO' AND X5_CHAVE='LIGADO' está diferente de T, ou seja: desligado")
EndIf

Return .T.