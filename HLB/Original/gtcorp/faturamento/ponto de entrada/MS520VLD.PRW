#include "Protheus.ch"

/*
Funcao      : MS520VLD
Parametros  : 
Retorno     : Nil
Objetivos   : Ponto de entrada, no MATA521, utilizado na rotina de integração automática de faturas e ND's da GT.
TDN			: Esse ponto de entrada é chamado para validar ou não a exclusão da nota na rotina MATA521
Autor       : Matheus Massarotto
Data/Hora   : 11/06/2012    09:34
Revisão		:                    
Data/Hora   : 
Módulo      : Faturamento
*/

*--------------------*
User function MS520VLD
*--------------------*
Local cUser := UsrRetName(__cUserId)
Local aUsers := {}
Private aArea:= GetArea()
Private lRet:=.T.

If "GTCORP" $ ALLTRIM(UPPER(GetEnvServer()))
	//Tratamento de Validação de cancelamento de NFs da GT consultores.
	aAdd(aUsers,"carine.garlipp")
	aAdd(aUsers,"elaine.fernandes")
	Begin Sequence
		If FwIsAdmin()
			Break
		EndIf
		If cEmpAnt == "Z8" .AND. aScan(aUsers,{|x| x == AllTrim(UsrRetName(__cUserId))}) == 0
			MsgAlert("Usuário sem permissão para executar esta ação.","Grant Thornton")
			Return .F.
		EndIf
	End Sequence

	Private aErros:={}
	Private cQry:=""
	Private cQry1:=""
	Private aCond:={}
	Private aItensD2:={}
	Private cCompName:=GetComputerName()
	Private cPara:=""
	Private cEmp := cEmpant   
	Private cFil := cFilant

	CONOUT("MS520VLD - INICIO")
	//if "GTCORP" $ ALLTRIM(UPPER(GetEnvServer())) 
		SA1->(DbSetOrder(1))
		if SA1->(DbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA))
			if SA1->A1_P_GERA                                                           
				if !empty(SA1->A1_P_BANCO)
			    	if !empty(SA1->A1_P_CODIG)
			    		if !empty(SA1->A1_P_CODFI)
				    		if !empty(SA1->A1_P_SERVI)
					    		if !empty(SA1->A1_P_PORTA)
									//ambiente			,empresa		,filial
									if empty(SM0->M0_CGC)
										AADD(aErros,{"ERRO",cmodulo,SF2->F2_FILIAL,SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_TIPO,SF2->(RECNO()),"cadastro do cnpj da empresa:"+alltrim(SM0->M0_NOME)+" em branco",date(), dDataBase ,time(), __cUserId ,cUserName,GetEnvServer(),cCompName,cEmpAnt, cFilAnt,cEmp,cFil,"","","",""}) 
										//** "cadastro do cnpj da empresa:"+alltrim(SM0->M0_NOME)+" em branco"
									else
										//** tratamento para a condição de pagamento
										cQry:=" SELECT E4_CODIGO,E4_TIPO,E4_COND,E4_DESCRI FROM "+RETSQLNAME("SE4")+Chr(13)+Chr(10)
										cQry+=" WHERE D_E_L_E_T_='' AND E4_CODIGO='"+SF2->F2_COND+"' AND E4_FILIAL='"+xFilial("SE4")+"'"
										if select("TRBSE4")>0
											TRBSE4->(DbCloseArea())
										endif
										
										dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TRBSE4",.T.,.T.)
				
										COUNT TO nRecCount
										if nRecCount>0
											TRBSE4->(DbGotop())
											AADD(aCond,TRBSE4->E4_CODIGO)
											AADD(aCond,TRBSE4->E4_TIPO)
											AADD(aCond,TRBSE4->E4_COND)
											AADD(aCond,TRBSE4->E4_DESCRI)									
										endif

										//** Tratamento para os itens									
										cQry1:=" SELECT D2_ITEM,D2_COD,D2_QUANT,D2_PRCVEN,D2_TOTAL FROM "+RETSQLNAME("SD2")+Chr(13)+Chr(10)
										cQry1+=" WHERE D_E_L_E_T_='' AND D2_FILIAL='"+xFilial("SD2")+"' AND D2_DOC='"+SF2->F2_DOC+"' AND D2_SERIE='"+SF2->F2_SERIE+"' AND D2_CLIENTE='"+SF2->F2_CLIENTE+"' AND D2_LOJA='"+SF2->F2_LOJA+"'"
										if select("TRBSD2")>0
											TRBSD2->(DbCloseArea())
										endif
										
										dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry1),"TRBSD2",.T.,.T.)
			
										COUNT TO nRecCount
										if nRecCount>0
											TRBSD2->(DbGotop())
											while TRBSD2->(!EOF())
												AADD(aItensD2,{TRBSD2->D2_COD,TRBSD2->D2_QUANT,TRBSD2->D2_PRCVEN,TRBSD2->D2_TOTAL})
											    TRBSD2->(DbSkip())
										    enddo
										endif
									
										//**Tratamento para quem enviar o e-mail									
										if TCSQLExec("SELECT Z08_FUNC FROM [SQLTB717].GTHD.dbo.Z08010")<0
											cPara:="protheus@br.gt.com"
											CONOUT("Tabela não encontrada para enviar o e-mail")									
										else
											//**Query para tratar o e-mail do responsável através da tabela disponibilizada pelo Cristiano.
											cQrEma:=" SELECT Z08_FUNC FROM [SQLTB717].GTHD.dbo.Z08010"
											cQrEma+=" WHERE D_E_L_E_T_='' AND Z08_EMP+Z08_FIL=("
											cQrEma+=" SELECT TOP 1 Z04_CODIGO+Z04_CODFIL FROM [SQLTB717].GTHD.dbo.Z04010"
											cQrEma+=" WHERE D_E_L_E_T_='' AND Z04_CNPJ='"+SA1->A1_CGC+"' AND Z04_NOMFIL<>'TESTE') AND Z08_RECNF='T'"
	                                    	if select("TRBPARA")>0
												TRBPARA->(DbCloseArea())
											endif
										
											dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrEma),"TRBPARA",.T.,.T.)
			
											COUNT TO nRecCount
                                    		if nRecCount>0
                                    			TRBPARA->(DbGoTop())
                                  				while TRBPARA->(!EOF())
                                   					cPara+=TRBPARA->Z08_FUNC+";"
                                   					TRBPARA->(DbSkip())
                                   				enddo
                                   				cPara:=SUBSTR(cPara,1,len(cPara)-1)
	                                    	else
	                                    		Conout("Não foi encontrado responsável pela empresa na tabela Z08010")
	                                    		cPara:="protheus@br.gt.com"
	                                    	endif
	                                    endif
										//** Rotina para conectar na empresa que se deseja gravar a nota
										//Tratamento para quando a NF for transmitida
										cDoc := SF2->F2_NFELETR
										cSerie := ""
										If EMPTY(cDoc)
											cDoc := SF2->F2_DOC
											cSerie := SF2->F2_SERIE
										EndIf
										U_GTCORP12(SA1->A1_P_BANCO,SA1->A1_P_CODIG,SA1->A1_P_CODFI,SM0->M0_CGC,cDoc,cSerie,SF2->F2_ESPECIE,cEmpAnt,cFilAnt,aCond,aItensD2,SF2->F2_CLIENTE,SF2->F2_LOJA,SM0->M0_NOME,dDataBase,aErros,5,cPara,SA1->A1_P_SERVI,SA1->A1_P_PORTA)
									endif
								else
									AADD(aErros,{"ERRO",cmodulo,SF2->F2_FILIAL,SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_TIPO,SF2->(RECNO()),"cliente com porta não preenchida",date(), dDataBase ,time(), __cUserId ,cUserName,GetEnvServer(),cCompName,cEmpAnt, cFilAnt,cEmp,cFil,"","","",""}) 
									//alert("cliente com codigo filial não preenchida")
									//**cliente com codigo filial não preenchida
								endif
							else
								AADD(aErros,{"ERRO",cmodulo,SF2->F2_FILIAL,SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_TIPO,SF2->(RECNO()),"cliente com servidor não preenchido",date(), dDataBase ,time(), __cUserId ,cUserName,GetEnvServer(),cCompName,cEmpAnt, cFilAnt,cEmp,cFil,"","","",""}) 
								//alert("cliente com codigo filial não preenchida")
								//**cliente com codigo filial não preenchida
							endif
						else
							AADD(aErros,{"ERRO",cmodulo,SF2->F2_FILIAL,SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_TIPO,SF2->(RECNO()),"cliente com codigo filial não preenchida",date(), dDataBase ,time(), __cUserId ,cUserName,GetEnvServer(),cCompName,cEmpAnt, cFilAnt,cEmp,cFil,"","","",""}) 
							//alert("cliente com codigo filial não preenchida")
							//**cliente com codigo filial não preenchida
						endif
			    	else
			    		AADD(aErros,{"ERRO",cmodulo,SF2->F2_FILIAL,SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_TIPO,SF2->(RECNO()),"cliente com codigo empresa não preenchida",date(), dDataBase ,time(), __cUserId ,cUserName,GetEnvServer(),cCompName,cEmpAnt, cFilAnt,cEmp,cFil,"","","",""}) 
			    		//alert("cliente com codigo empresa não preenchida")
			    		//**cliente com codigo empresa não preenchida
			    	endif
			    else
			    	AADD(aErros,{"ERRO",cmodulo,SF2->F2_FILIAL,SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_TIPO,SF2->(RECNO()),"cliente com ambiente não preenchido",date(), dDataBase ,time(), __cUserId ,cUserName,GetEnvServer(),cCompName,cEmpAnt, cFilAnt,cEmp,cFil,"","","",""}) 
			    	//alert("cliente com ambiente não preenchido")
			    	//**cliente com ambiente não preenchido
				endif
			endif
	    else
	    	AADD(aErros,{"ERRO",cmodulo,SF2->F2_FILIAL,SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_TIPO,SF2->(RECNO()),"cliente não encontrado",date(), dDataBase ,time(), __cUserId ,cUserName,GetEnvServer(),cCompName,cEmpAnt, cFilAnt,cEmp,cFil,"","","",""}) 
	    	//alert("cliente não encontrado")
	    	//**cliente não encontrado
	    endif

		//GRAVA OS ERROS NA TABELA DE LOGS
		DbSelectArea("Z91")
		for nCont:=1 to len(aErros)
			RecLock("Z91",.T.)
			Z91->Z91_CODIGO:=GETSXENUM("Z91","Z91_CODIGO")
			Z91->Z91_OCORRE:=aErros[nCont][1]
			Z91->Z91_MODULO:=aErros[nCont][2]
			Z91->Z91_X_FIL :=aErros[nCont][3]
			Z91->Z91_X_DOC :=aErros[nCont][4]
			Z91->Z91_X_SERI:=aErros[nCont][5]
			Z91->Z91_X_FORN:=aErros[nCont][6]
			Z91->Z91_X_LOJA:=aErros[nCont][7]
			Z91->Z91_X_TIPO:=aErros[nCont][8]
			Z91->Z91_X_RECN:=aErros[nCont][9]
			Z91->Z91_DESCRI:=aErros[nCont][10]
			Z91->Z91_DATA  :=aErros[nCont][11]
			Z91->Z91_DATASI:=aErros[nCont][12]
			Z91->Z91_HORA  :=aErros[nCont][13]
			Z91->Z91_CODUSE:=aErros[nCont][14]
			Z91->Z91_USER  :=aErros[nCont][15]
			Z91->Z91_AMBIEN:=aErros[nCont][16]
			Z91->Z91_COMPUT:=aErros[nCont][17]
			Z91->Z91_EMPORI:=aErros[nCont][18]
			Z91->Z91_FILORI:=aErros[nCont][19]
			Z91->Z91_EMPDES:=aErros[nCont][20]
			Z91->Z91_FILDES:=aErros[nCont][21]
			Z91->Z91_INCEXC:="exclusão"
			MsUnlock()
			CONFIRMSX8()		                    
		next
				
		Z91->(DbCloseArea())
	   	
	   	If len(aErros)>0
			CONOUT("Entrou para enviar e-mail")
			U_GTGEN002(cPara,aErros,5,2)//RRP - 28/11/2012 - Alterado o parâmetro do nOpc para 5 pois estava gerando error log.
	    EndIf
	//endif

	If!(lRet)
		Alert("Impossível exluir Doc.Saida, verifique vínculos gerados no cliente!")
	EndIf
EndIf

RestArea(aArea)
return(lRet)