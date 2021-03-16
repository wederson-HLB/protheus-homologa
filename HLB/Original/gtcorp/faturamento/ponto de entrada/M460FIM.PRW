#include "topconn.ch"
#include "rwmake.ch"  

/*
Funcao      : M460FIM 
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Ponto de entrada chamado após a gravação dos dados da NFS 
Autor       : José Augusto Pereira Alves
Data/Hora   : 14/03/2008     
Obs         : 
TDN         : Este P.E. é chamado apos a Gravacao da NF de Saida, e fora da transação.
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 31/05/2012
Obs         : Empresas foram tiradas do fonte, variavies ainda estão disponiveis.
Módulo      : Faturamento.
Cliente     : GTCoorp
*/
*---------------------*
USER FUNCTION M460FIM()
*---------------------*
// Variaveis criadas pela Microsiga para o fonte da DONALDSON 
Local _aArea     := GetArea()   // Inicializa array para capturar Area de Trabalho desconhecida
Local cAlias     := ALIAS()
Local _aAreaSB1  := SB1->(GetArea()) // Inicializa array para capturar Area de Trabalho SB1
Local _aAreaSF2  := SF2->(GetArea()) // Inicializa array para capturar Area de Trabalho SF2
Local _aAreaSD2  := SD2->(GetArea()) // Inicializa array para capturar Area de Trabalho SD2
Local _aAreaSA1  := SA1->(GetArea()) // Inicializa array para capturar Area de Trabalho SA1
Local _aAreaSA2  := SA2->(GetArea()) // Inicializa array para capturar Area de Trabalho SA2
Local _aAreaSC5  := SC5->(GetArea()) // Inicializa array para capturar Area de Trabalho SC5
Local _aAreaSF4  := SF4->(GetArea()) // Inicializa array para capturar Area de Trabalho SF4
Local _cDoc      := SF2->F2_DOC
Local _cSerie    := SF2->F2_SERIE
Local _nQtd      := SF2->F2_VOLUME1

Local _cNomeRed  := space(30)
Local _cPlaca    := space(08)
Local _cMarca    := space(20)
Local _cMens1    := space(03)
Local _cMens2    := space(03) 
Local _cConhec   := space(40)

Local _nRecD2    := 0
Local nItens     := 0 
Local nRecno     := 0 
Local _nPBruto   := 0
Local _nPLiqui   := 0
 
Local aAreaSC6  := SC6->(GetArea())
Local aAreaSC5  := SC5->(GetArea())
Local aAreaSD2  := SD2->(GetArea())

Local lSair     := .T.
Local lTotal    := .T.
Local lTemSerie := .T.  
Local lFirst    := .T. 

Local _cHrSaida := Time()  
Local aArea     := GetArea()   
Local _dDtSaida := dDataBase 

Local aPedido   := {}
Local aErros    := {}
Local aCond		:= {}
Local aItensD2  := {} 
Local aItens    := {"Sim","Nao"}
                                             
Local _cNome    := ""
Local _cTransp  := ""
Local _cCodRed  := ""
Local _cEspec   := "" 
Local _cEspec   := ""
Local cQry		:= ""    
Local cQryV		:= "" 
Local cQry2     := ""
Local cQry1     := "" 
Local cPara     := ""
Local cQrEma    := "" 
Local cNum      := ""   
Local cQuery    := ""  

Private aCod     [8]   // Inicializa array com 8 elementos para os codigos das mensagens.
Private aMsg     [8]   // Inicializa array com 8 elementos para os textos das mensagens.

Private lMsg     := .T.
Private nVar     := 0  
        
Private _cMens   := ""
Private cMsg     := ""   
Private cCod     := ""
Private cLin1    := ""
Private cLin2    := ""
Private _lFecha  := .F.
Private aEstNeg  := {}
Private lTemWFEst:= GetMV("MV_P_WFEST",.T.,.F.) // Se está habilitada para Workflow do Estoque Negativo

If !Empty(SA1->A1_CC_CUSTO)//JSS - Grava a informação do centro de custo do cliente na nota, para realizar filtro da KPMG/GT
	SE1->(Reclock("SE1",.F.))
	Replace SE1->E1_CCC WITH SA1->A1_CC_CUSTO
	SE1->(MsUnlock())
Endif

//Gravar Campo Invoce no financeiro
If SA1->A1_P_INVOI = '1'
	SE1->(Reclock("SE1",.F.))
	Replace SE1->E1_P_INVOC WITH '1'
	SE1->(MsUnlock())
Endif

If lTemWFEst
   //ASK - 27/08/2010 - Trata Workflow de estoque negativo - TODAS AS EMPRESAS.
   SD2->(DbSetOrder(3))        
   SD2->(DbGoTop())
   If SD2->(DbSeek(xFilial("SD2")+SF2->F2_DOC + SF2->F2_SERIE)) 
      While !SD2->(EOF()) .AND. SD2->D2_DOC = SF2->F2_DOC .And. SD2->D2_SERIE = SF2->F2_SERIE 
         If SB2->(DbSeek(xFilial("SB2")+SD2->D2_COD+SD2->D2_LOCAL))
            If SB2->B2_QATU < 0  
               aadd(aEstNeg,{SD2->D2_PEDIDO,;
                             SD2->D2_DOC,;
                             SD2->D2_SERIE,;
                             SD2->D2_CLIENTE,;
                             SD2->D2_LOJA,;
                             SB2->B2_COD,;
                             SD2->D2_QUANT,;
                             SB2->B2_QATU,;
                             SD2->D2_ITEM,;
                             SD2->D2_LOCAL})   
            EndIf
         EndIf
         SD2->(DbSkip())
      End
   EndIf       

   If FindFunction ("U_WF_P_ESTNEG") .And. len(aEstNeg) > 0  
      U_WF_P_ESTNEG(aEstNeg)
   EndIf
EndIf 

//Tratamentos para GTCORP
If "GTCORP" $ ALLTRIM(UPPER(GetEnvServer()))
	Private lIntegra	:= .F.
	Private cQryInte	:= ""
	Private cCompName	:= ComputerName()

	AtuPortal()//Atualização do status do portal, caso seja PV pelo portal.

	//MSM - 25/04/2012 - Objetivo de gerar notas automáticas no cliente	
	cQryInte := " SELECT X5_DESCRI FROM SX5YY0"
	cQryInte += " WHERE X5_TABELA='ZO' AND X5_CHAVE='LIGADO'"
	If select("TRBX5")>0
		TRBX5->(DbCloseArea())
	EndIf
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryInte),"TRBX5",.T.,.T.)
	COUNT TO nRecCount
	If nRecCount>0
		TRBX5->(DbGotop())
		If alltrim(upper(TRBX5->X5_DESCRI)) == 'T' .OR. alltrim(upper(TRBX5->X5_DESCRI)) == '.T.'
			lIntegra:=.T.
			CONOUT("O X5 da empresa YY - X5_TABELA='ZO' AND X5_CHAVE='LIGADO' está como T, ou seja: ligado")
		EndIf
	EndIf
   
	If lIntegra .and. cEmpAnt == "8F"//Unica empresa que permanece com transmissão manual, demais empresas estão no retorno da prefeitura (F022ATUNF)
		CONOUT("ENTROU NO M460FIM - ROTINA DE INTEGRAÇÃO")
		DbSelectArea("SA1")
		SA1->(DbSetOrder(1))
		If SA1->(DbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA))
			If SA1->A1_P_GERA
				If !empty(SA1->A1_P_BANCO)
			    	If !empty(SA1->A1_P_CODIG)
			    		If !empty(SA1->A1_P_CODFI)
				    		If !empty(SA1->A1_P_SERVI)
					    		If !empty(SA1->A1_P_PORTA)
									If empty(SM0->M0_CGC)	//ambiente			,empresa		,filial
										AADD(aErros,{"ERRO",cmodulo,SF2->F2_FILIAL,SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_TIPO,SF2->(RECNO()),"cadastro do cnpj da empresa:"+alltrim(SM0->M0_NOME)+" em branco",date(), dDataBase ,time(), __cUserId ,cUserName,GetEnvServer(),cCompName,cEmpAnt, cFilAnt,SA1->A1_P_CODIG,SA1->A1_P_CODFI,"","","",""}) 
										//** "cadastro do cnpj da empresa:"+alltrim(SM0->M0_NOME)+" em branco"
									Else
										//** tratamento para a condição de pagamento
										cQry2 := " SELECT E4_CODIGO,E4_TIPO,E4_COND,E4_DESCRI FROM "+RETSQLNAME("SE4")
										cQry2 += " WHERE D_E_L_E_T_='' AND E4_CODIGO='"+SF2->F2_COND+"' AND E4_FILIAL='"+xFilial("SE4")+"'"
										If select("TRBSE4")>0
											TRBSE4->(DbCloseArea())
										EndIf
										dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry2),"TRBSE4",.T.,.T.)
										COUNT TO nRecCount
										If nRecCount>0
											TRBSE4->(DbGotop())
											AADD(aCond,TRBSE4->E4_CODIGO)
											AADD(aCond,TRBSE4->E4_TIPO)
											AADD(aCond,TRBSE4->E4_COND)
											AADD(aCond,TRBSE4->E4_DESCRI)									
										EndIf

										//** Tratamento para os itens									
										cQry1 := " SELECT D2_ITEM,D2_COD,D2_QUANT,D2_PRCVEN,D2_TOTAL FROM "+RETSQLNAME("SD2")
										cQry1 += " WHERE D_E_L_E_T_='' AND D2_FILIAL='"+xFilial("SD2")+"' AND D2_DOC='"+SF2->F2_DOC+"' AND D2_SERIE='"+SF2->F2_SERIE+"' AND D2_CLIENTE='"+SF2->F2_CLIENTE+"' AND D2_LOJA='"+SF2->F2_LOJA+"'"
										If select("TRBSD2")>0
											TRBSD2->(DbCloseArea())
										EndIf
										dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry1),"TRBSD2",.T.,.T.)
										COUNT TO nRecCount
										If nRecCount>0
											TRBSD2->(DbGotop())
											while TRBSD2->(!EOF())
												AADD(aItensD2,{TRBSD2->D2_COD,TRBSD2->D2_QUANT,TRBSD2->D2_PRCVEN,TRBSD2->D2_TOTAL})
											    TRBSD2->(DbSkip())
										    enddo
										EndIf

										//**Tratamento para quem enviar o e-mail
										If TCSQLExec("SELECT Z08_FUNC FROM [SQLTB717].GTHD.dbo.Z08010")<0
											cPara := "log.sistemas@br.gt.com"
											CONOUT("Tabela não encontrada para enviar o e-mail")									
										Else
											//**Query para tratar o e-mail do responsável através da tabela disponibilizada pelo Cristiano.
											cQrEma := " SELECT Z08_FUNC FROM [SQLTB717].GTHD.dbo.Z08010"
											cQrEma += " WHERE D_E_L_E_T_='' AND Z08_EMP+Z08_FIL=("
											cQrEma += " SELECT TOP 1 Z04_CODIGO+Z04_CODFIL FROM [SQLTB717].GTHD.dbo.Z04010"
											cQrEma += " WHERE D_E_L_E_T_='' AND Z04_CNPJ='"+SA1->A1_CGC+"' AND Z04_NOMFIL<>'TESTE') AND Z08_RECNF='T'"
	
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
										//** Rotina para conectar na empresa que se deseja gravar a nota
										U_GTCORP12(SA1->A1_P_BANCO,SA1->A1_P_CODIG,SA1->A1_P_CODFI,SM0->M0_CGC,SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_ESPECIE,cEmpAnt,cFilAnt,aCond,aItensD2,SF2->F2_CLIENTE,SF2->F2_LOJA,SM0->M0_NOME,dDataBase,aErros,3,cPara,SA1->A1_P_SERVI,SA1->A1_P_PORTA)
									EndIf
								Else
									AADD(aErros,{"ERRO",cmodulo,SF2->F2_FILIAL,SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_TIPO,SF2->(RECNO()),"cliente com porta não preenchida",date(), dDataBase ,time(), __cUserId ,cUserName,GetEnvServer(),cCompName,cEmpAnt, cFilAnt,SA1->A1_P_CODIG,SA1->A1_P_CODFI,"","","",""}) 
								EndIf
							Else
						   		AADD(aErros,{"ERRO",cmodulo,SF2->F2_FILIAL,SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_TIPO,SF2->(RECNO()),"cliente com servidor não preenchido",date(), dDataBase ,time(), __cUserId ,cUserName,GetEnvServer(),cCompName,cEmpAnt, cFilAnt,SA1->A1_P_CODIG,SA1->A1_P_CODFI,"","","",""}) 
							EndIf							
						Else
							AADD(aErros,{"ERRO",cmodulo,SF2->F2_FILIAL,SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_TIPO,SF2->(RECNO()),"cliente com codigo filial não preenchida",date(), dDataBase ,time(), __cUserId ,cUserName,GetEnvServer(),cCompName,cEmpAnt, cFilAnt,SA1->A1_P_CODIG,SA1->A1_P_CODFI,"","","",""}) 
						EndIf
					Else
						AADD(aErros,{"ERRO",cmodulo,SF2->F2_FILIAL,SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_TIPO,SF2->(RECNO()),"cliente com codigo empresa não preenchida",date(), dDataBase ,time(), __cUserId ,cUserName,GetEnvServer(),cCompName,cEmpAnt, cFilAnt,SA1->A1_P_CODIG,SA1->A1_P_CODFI,"","","",""}) 
					EndIf
				Else
			    	AADD(aErros,{"ERRO",cmodulo,SF2->F2_FILIAL,SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_TIPO,SF2->(RECNO()),"cliente com ambiente não preenchido",date(), dDataBase ,time(), __cUserId ,cUserName,GetEnvServer(),cCompName,cEmpAnt, cFilAnt,SA1->A1_P_CODIG,SA1->A1_P_CODFI,"","","",""}) 
				EndIf
			EndIf
		 Else
		   	AADD(aErros,{"ERRO",cmodulo,SF2->F2_FILIAL,SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_TIPO,SF2->(RECNO()),"cliente não encontrado",date(), dDataBase ,time(), __cUserId ,cUserName,GetEnvServer(),cCompName,cEmpAnt, cFilAnt,SA1->A1_P_CODIG,SA1->A1_P_CODFI,"","","",""}) 
		EndIf

		//GRAVA OS ERROS NA TABELA DE LOGS
		DbSelectArea("Z91")
		for nCont:=1 to len(aErros)
			Z91->(RecLock("Z91",.T.))
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
			Z91->(MsUnlock())
			CONFIRMSX8()
		next
		Z91->(DbCloseArea())
		RestArea(aArea)
	Else
		CONOUT("O X5 da empresa YY - X5_TABELA='ZO' AND X5_CHAVE='LIGADO' está diferente de T, ou seja: desligado")
	EndIf
EndIf

//Alteração no SE1 
If cEmpAnt $ "F2/Z4/RH/ZB/Z8/Z6/CH/ZF/ZG/ZP" //.OR. cEmpAnt $ "99"  
   If Select("TRBSF2")>0
      TRBSF2->(DbCloseArea())    
   EndIf

	If !Empty(SF2->F2_DUPL)
		cQuery+=" SELECT R_E_C_N_O_ AS REC FROM "+RETSQLNAME("SE1")
  		cQuery+=" WHERE E1_PREFIXO = '"+SF2->F2_PREFIXO+"' AND E1_NUM = '"+SF2->F2_DUPL+"' AND E1_PEDIDO = '"+SC5->C5_NUM+"' AND E1_CLIENTE = '"+SF2->F2_CLIENTE+"' AND E1_LOJA = '"+SF2->F2_LOJA+"' AND D_E_L_E_T_ = '' "
  
	 	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), "TRBSF2" ,.T.,.F.)

 		If Empty(SE1->E1_PARCELA) 
  			DBSELECTAREA("TRBSF2")
  	   		DBGOTOP()
  			nRecno:=TRBSF2->REC
  
   			DBSELECTAREA("SE1")
  			DBGOTO(nRecno)
        
        	If cEmpAnt $ "F2"
       	   		RECLOCK("SE1",.F.)
   				SE1->E1_P_PROJ:=SC5->C5_P_PROJ
   	   	   		SE1->E1_P_CC:=SC5->C5_P_CTT
    	   		MSUNLOCK()
       	 	EndIf
        
	        If cEmpAnt $ "Z4/RH/ZB/Z8/Z6/CH/ZF/ZG/ZP"
	        	If SE1->E1_NATUREZ <> '1001' .and. SE1->E1_TIPO = 'NF'
	           		RECLOCK("SE1",.F.)
	               	SE1->E1_NATUREZ = '1001' 
	              	MSUNLOCK()
	           	EndIf
	        EndIf
	        
	 	Else
	  		DBSELECTAREA("TRBSF2")
	  		DBGOTOP()
	  		While TRBSF2->(!eof())
	  			nRecno:=TRBSF2->REC

	  			DBSELECTAREA("SE1")
	  			DBGOTO(nRecno) 
	        
	        	If cEmpAnt $ "F2"  
	      			RECLOCK("SE1",.F.)
	   				SE1->E1_P_PROJ:=SC5->C5_P_PROJ
	    			SE1->E1_P_CC:=SC5->C5_P_CTT
	     			MSUNLOCK()
	  			EndIf
	  
	  			If cEmpAnt $ "Z4"
	           		If SE1->E1_NATUREZ <> '1001' .and. SE1->E1_TIPO = 'NF'
	           			RECLOCK("SE1",.F.)
	               		SE1->E1_NATUREZ = '1001' 
	             		 MSUNLOCK()
	           		EndIf
	           EndIf
  			   TRBSF2->(DbSkip())
	  		Enddo
	 	EndIf 
	 	TRBSF2->(DbCloseArea())   
	EndIf                     
 
	DBSELECTAREA("SF2")
	RECLOCK("SF2", .F. )
	REPLACE F2_VOLUME1 WITH SC5->C5_VOLUME1
	MSUNLOCK()
	DBSELECTAREA( cAlias )    

EndIf
  
//TLM 31/05/2012 - Tratamento para escolher o tipo da moeda do título gerado no módulo financeiro.
                                             	
//Caso a moeda seja diferente de reais.
If SC5->C5_MOEDA <> 1 
   MsgInfo("A moeda do pedido é "+alltrim(str(SC5->C5_MOEDA)+" ,verificar qual a moeda do título"),"Grant Thornton")
EndIF

Return

/*
Funcao      : AtuPortal 
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Atualização do Status no portal de faturamento CLiente.
Autor       : Jean Victor Rocha
Data/Hora   : 09/12/2013     
Obs         : 
*/
*-------------------------*
Static Function AtuPortal()
*-------------------------*
Local cOrc := ""
Local aOrd	:= SaveOrd({"SCK","SA1","SCJ"})
Local cAlias := "SCJ"
Local cStatus := ""
Local aBanco := {"PORTAL","MSSQL7/Portal_Cliente"   ,"10.0.30.5"} 
Local cTabela := "ZF2020"

If "GTCORPB" $ ALLTRIM(UPPER(GetEnvServer()))//Para ambiente de testes
	aBanco[2] := "MSSQL7/Portal_Cliente_Dev"
	cTabela := "ZF2030"
EndIf

SC6->(DbSetOrder(1))
If SC6->(DbSeek(xFilial("SC6")+SC5->C5_NUM))
	While SC6->(!EOF()) .and. SC6->C6_FILIAL == xFilial("SC6") .and. SC6->C6_NUM == SC5->C5_NUM .and. EMPTY(cOrc)
		If !EMPTY(SC6->C6_NUMORC)
			cOrc := LEFT(SC6->C6_NUMORC,6)
		EndIf
		SC6->(DbSkip())
	EndDo
EndIf

If EMPTY(cOrc)
	Return .T.
EndIf        

SCJ->(DbSetOrder(1))
SCJ->(DbSeek(xFilial("SCJ")+cOrc))
            
nCon := TCLink(aBanco[2],aBanco[3],7894)

cUpdate := " Update "+cTabela+" set ZF2_STATUS = 'S' 
cUpdate += " Where D_E_L_E_T_ <> '*' 
cUpdate += " AND ZF2_CODEMP = '"+cEmpAnt+"'
cUpdate += " AND ZF2_CODFIL = '"+cFilAnt+"' 
cUpdate += " AND ZF2_CODIGO = '"+cOrc+"'

If TcSQLExec(cUpdate) < 0
    Return MsgStop("Erro na alteração de Status do processo no Portal do Faturamento." + TCSQLError())
EndIf

TCunLink(nCon)

aHeader := {}
aDetail := {}
             
aAdd(aHeader,{"CJ_NUM"		,(cAlias)->CJ_NUM})
aAdd(aHeader,{"CJ_P_EMAIL"	,(cAlias)->CJ_P_EMAIL})
aAdd(aHeader,{"CJ_USERLGI"	,(cAlias)->CJ_USERLGI})
aAdd(aHeader,{"CJ_CLIENTE"	,(cAlias)->CJ_CLIENTE})
aAdd(aHeader,{"CJ_P_EMAIU"	,(cAlias)->CJ_P_EMAIU})

SCK->(DbSetorder(1))
If SCK->(DbSeek(xFilial("SCK")+(cAlias)->CJ_NUM))
	While SCK->(!Eof()) .And. SCK->CK_FILIAL==xFilial("SCK") .And.;
			SCK->CK_NUM == (cAlias)->CJ_NUM
	    aAux := {}
	    aAdd(aAux,{"CK_PRODUTO"	,SCK->CK_PRODUTO})
	    aAdd(aAux,{"CK_DESCRI"	,SCK->CK_DESCRI})
	    aAdd(aAux,{"CK_QTDVEN"	,SCK->CK_QTDVEN})
	    aAdd(aAux,{"CK_PRCVEN"	,SCK->CK_PRCVEN})
	    aAdd(aAux,{"CK_VALOR"	,SCK->CK_VALOR})
	    aAdd(aAux,{"CK_NUMPV"	,SCK->CK_NUMPV})
	    aAdd(aAux,{"CK_NOTA"	,SC5->C5_NOTA+"-"+SC5->C5_SERIE})
	    aAdd(aDetail,aAux)
	    
		SCK->(dbSkip())
	EndDo
EndIf

SendWorkFlow(aHeader,aDetail)

Restord(aOrd)

Return .T.      

/*
Função  : SendWorkFlow
Objetivo: Envia email de worflow
Autor   : Jean Victor Rocha
Data    : 09/12/2013
*/
*-------------------------------------------*
Static Function SendWorkFlow(aHeader,aDetail)
*-------------------------------------------*
Local nPosNum	:= aScan(aHeader, {|x| ALLTRIM(x[1]) == "CJ_NUM" })
Local nPosMail	:= aScan(aHeader, {|x| ALLTRIM(x[1]) == "CJ_P_EMAIL" })
Local nPosMailU	:= aScan(aHeader, {|x| ALLTRIM(x[1]) == "CJ_P_EMAIU" })
Local cEmail	:= Email(aHeader,aDetail)


oEmail          := DEmail():New()
oEmail:cFrom   	:= "totvs@br.gt.com"
oEmail:cTo		:= PADR(ALLTRIM(aHeader[nPosMail][2])+";"+ALLTRIM(aHeader[nPosMailU][2])+";"+ALLTRIM(GetMv("MV_P_00010",,"")),400)
oEmail:cSubject	:= padr("Solicitacao '"+ALLTRIM(aHeader[nPosNum][2])+"' Finalizada no Portal do Faturamento.",200)
oEmail:cBody   	:= cEmail
oEmail:Envia()

Return .T.  

/*
Função  : Email
Objetivo: Monta o email a ser enviado no workflow.
Autor   : Jean Victor Rocha
Data    : 09/12/2013
*/
*------------------------------------*
Static Function Email(aHeader,aDetail)
*------------------------------------*  
Local cAux := ""
Local cHtml := ""

Local nPosNum	:= aScan(aHeader, {|x| ALLTRIM(x[1]) == "CJ_NUM" })
Local nPosCol	:= aScan(aHeader, {|x| ALLTRIM(x[1]) == "CJ_USERLGI" })
Local nPosCli	:= aScan(aHeader, {|x| ALLTRIM(x[1]) == "CJ_CLIENTE" })
Local nPosGes	:= aScan(aHeader, {|x| ALLTRIM(x[1]) == "CJ_P_EMAIL" })

SA1->(DbSetorder(1))
SA1->(DbSeek(xFilial("SA1")+aHeader[nPosCli][2])) 

cHtml+='<html xmlns:v="urn:schemas-microsoft-com:vml"'
cHtml+='xmlns:o="urn:schemas-microsoft-com:office:office"'
cHtml+='xmlns:w="urn:schemas-microsoft-com:office:word" '
cHtml+='xmlns:m="http://schemas.microsoft.com/office/2004/12/omml"'
cHtml+='xmlns="http://www.w3.org/TR/REC-html40">'

cHtml+='<head>
cHtml+='	<meta http-equiv=Content-Type content="text/html; charset=windows-1252">'
cHtml+='	<meta name=ProgId content=Word.Document> '
cHtml+='	<meta name=Generator content="Microsoft Word 12"> '
cHtml+='	<meta name=Originator content="Microsoft Word 12">'
cHtml+='</head>
cHtml+='<body bgcolor="#FFFFFF" lang=PT-BR link=blue vlink=purple style="tab-interval:35.4pt">'
cHtml+='<div class=WordSection1>'
cHtml+="	<p class=MsoNormal  align=center style='text-align:center'> "
cHtml+='		<a href="http://www.grantthornton.com.br/">'
cHtml+="			<span style='text-decoration:none; text-underline:none'>"
cHtml+='				<center><img width=680 border=0 id="_x0000_i1025" src="http://assets.finda.co.nz/images/thumb/zc/9/x/5/4y39x5/790x97/grant-thornton.jpg" nosend=1>'
cHtml+="			</span>"
cHtml+="		</a>"  
cHtml+="    </p>"
cHtml+="</div>"
cHtml+="<h1>"
cHtml+="<div align=center>"
cHtml+="	<table class=MsoNormalTable border=0 cellpadding=0 width=800 style='width:525.0pt;mso-cellspacing:1.5pt;background:white;mso-yfti-tbllook:1184'>"
cHtml+="		<tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>"
cHtml+="			<td style='padding:.75pt .75pt .75pt .75pt'>"
cHtml+="				<div align=center>"
cHtml+="					<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=700 style='width:510.0pt;mso-cellspacing:0cm;mso-yfti-tbllook:1184;mso-padding-alt:0cm 0cm 0cm 0cm'>"
cHtml+="						<tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>"
cHtml+="							<td style='background:#4D1174;padding:0cm 0cm 0cm 0cm'>"
cHtml+="								<p class=MsoNormal align=center style='text-align:center'><b> "
cHtml+= TipoString(10.0,2)
cHtml+="										Solicitação "+ALLTRIM(aHeader[nPosNum][2])+" Finalizada"
cHtml+="									</span></b>"
cHtml+="								</p>"
cHtml+="							</td>"
cHtml+="						</tr>"
cHtml+="					</table>"
cHtml+="				</div>"
cHtml+="				<div align=center>"
cHtml+="					<Br>"
cHtml+="					<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=700 style='width:510.0pt;mso-cellspacing:0cm;mso-yfti-tbllook:1184;mso-padding-alt:0cm 0cm 0cm 0cm'>"
cHtml+='						<tr bgcolor="#FCFCFC">'
cHtml+="							<td>" 
cHtml+= TipoString(8.5,1)
cHtml+="									Numero:"
cHtml+="								</span>"
cHtml+="							</td>"
cHtml+="							<td>"
cHtml+= TipoString(8.5,1)
cHtml+="									"+ALLTRIM(aHeader[nPosNum][2])
cHtml+="								</span>"
cHtml+="							</td> " 
cHtml+="							<td>" 
cHtml+= TipoString(8.5,1)
cHtml+="									Colaborador:"
cHtml+="								</span>"
cHtml+="							</td>"
cHtml+="							<td>"
cHtml+= TipoString(8.5,1)
cHtml+="									"+ALLTRIM(aHeader[nPosCol][2])
cHtml+="								</span>"
cHtml+="							</td>"  
cHtml+="						</tr>"

cHtml+='						<tr bgcolor="#F3F3F3">'
cHtml+="							<td>" 
cHtml+= TipoString(8.5,1)
cHtml+="									Cliente:"
cHtml+="								</span>"
cHtml+="							</td>"
cHtml+="							<td>"
cHtml+= TipoString(8.5,1)
cHtml+="									"+ALLTRIM(aHeader[nPosCli][2])+" - "+ALLTRIM(SA1->A1_NOME)
cHtml+="								</span>"
cHtml+="							</td> " 
cHtml+="							<td>" 
cHtml+= TipoString(8.5,1)
cHtml+="									"
cHtml+="								</span>"
cHtml+="							</td>"
cHtml+="							<td>"
cHtml+= TipoString(8.5,1)
cHtml+="									"
cHtml+="								</span>"
cHtml+="							</td>"  
cHtml+="						</tr>"

cHtml+='						<tr bgcolor="#FCFCFC">'
cHtml+="							<td>" 
cHtml+= TipoString(8.5,1)
cHtml+="									Gestor:"
cHtml+="								</span>"
cHtml+="							</td>"
cHtml+="							<td>"
cHtml+= TipoString(8.5,1)
cHtml+="									"+ALLTRIM(aHeader[nPosGes][2])
cHtml+="								</span>"
cHtml+="							</td> " 
cHtml+="							<td>" 
cHtml+= TipoString(8.5,1)
cHtml+="									"
cHtml+="								</span>"
cHtml+="							</td>"
cHtml+="							<td>"
cHtml+= TipoString(8.5,1)
cHtml+="									"
cHtml+="								</span>"
cHtml+="							</td>"  
cHtml+="						</tr>"

cHtml+="					</table>" 
cHtml+="				</Div>"
cHtml+="			</td>"  
cHtml+="		</tr>"						
cHtml+="   	</table>"
cHtml+="</div>"	
cHtml+="<tr style='mso-yfti-irow:2;mso-yfti-lastrow:yes'>"
cHtml+="	<H1>"
cHtml+="	<td style='padding:0cm 0cm 0cm 0cm'>"
cHtml+="		<div align=center>"
cHtml+="			<table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width=679 style='width:509.25pt;mso-cellspacing:0cm;border:outset #CCCCCC 1.0pt;"
cHtml+="			mso-border-alt:outset #CCCCCC .75pt;mso-yfti-tbllook:1184;mso-padding-alt:2.25pt 2.25pt 2.25pt 2.25pt'>"
cHtml+="				<tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>"
cHtml+="					<td width='4%' style='width:4.0%;order:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;background:#4D1174;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
cHtml+="						<p class=MsoNormal>"
cHtml+="							<b>"
cHtml+= TipoString(7.5,2)
cHtml+="									Produto/Serviço<o:p></o:p>"
cHtml+="								</span>"
cHtml+="							</b>"
cHtml+="						</p>"
cHtml+="					</td>"
cHtml+="					<td width='9%' style='width:9.0%;border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;background:#4D1174;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
cHtml+="						<p class=MsoNormal>"
cHtml+="							<b>"
cHtml+= TipoString(7.5,2)
cHtml+="									Descrição<o:p></o:p>"
cHtml+="								</span>"
cHtml+="							</b>"
cHtml+="						</p>"
cHtml+="					</td>"
cHtml+="					<td width='7%' style='width:7.0%;border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;background:#4D1174;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
cHtml+="						<p class=MsoNormal>"
cHtml+="							<b>"
cHtml+= TipoString(7.5,2)
cHtml+="									Quantidade<o:p></o:p>"
cHtml+="								</span>"
cHtml+="							</b>"
cHtml+="						</p>"
cHtml+="					</td>"
cHtml+="					<td width='49%' style='width:49.0%;border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;background:#4D1174;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
cHtml+="						<p class=MsoNormal>"
cHtml+="							<b>"
cHtml+= TipoString(7.5,2)
cHtml+="									Vlr. Unitário<o:p></o:p>"
cHtml+="								</span>"
cHtml+="							</b>"
cHtml+="						</p>"
cHtml+="					</td>"
cHtml+="					<td width='11%' style='width:11.0%;border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;background:#4D1174;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
cHtml+="						<p class=MsoNormal>"
cHtml+="							<b>"
cHtml+= TipoString(7.5,2)
cHtml+="									Vlr. Total<o:p></o:p>"
cHtml+="								</span>"
cHtml+="							</b>"
cHtml+="						</p>"
cHtml+="					</td>"  
cHtml+="					<td width='11%' style='width:11.0%;border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;background:#4D1174;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
cHtml+="						<p class=MsoNormal>"
cHtml+="							<b>"
cHtml+= TipoString(7.5,2)
cHtml+="								Ped. Venda<o:p></o:p>"
cHtml+="								</span>"
cHtml+="							</b>"
cHtml+="						</p>"
cHtml+="					</td>"
cHtml+="					<td width='11%' style='width:11.0%;border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;background:#4D1174;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
cHtml+="						<p class=MsoNormal>"
cHtml+="							<b>"
cHtml+= TipoString(7.5,2)
cHtml+="								Fatura/Serie<o:p></o:p>"
cHtml+="								</span>"
cHtml+="							</b>"
cHtml+="						</p>"
cHtml+="					</td>"
cHtml+="				</tr>"

For i:=1 to Len(aDetail)
	cHtml+="				<tr style='mso-yfti-irow:1'>"
	cHtml+="					<td style='border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
	cHtml+="						<p class=MsoNormal>"
	cHtml+= TipoString(8.5,1)                                             
	cHtml+="					"+ALLTRIM(aDetail[i][aScan(aDetail[i], {|x| ALLTRIM(x[1]) == "CK_PRODUTO" })][2])+"<o:p></o:p>"	
	cHtml+="							</span>"
	cHtml+="						</p>"
	cHtml+="					</td>"
	cHtml+="					<td style='border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
	cHtml+="						<p class=MsoNormal>"
	cHtml+= TipoString(8.5,1)
 		cHtml+="				"+ALLTRIM(aDetail[i][aScan(aDetail[i], {|x| ALLTRIM(x[1]) == "CK_DESCRI" })][2])+"<o:p></o:p>"
 	cHtml+="							</span>"
	cHtml+="						</p>"
	cHtml+="					</td>"
	cHtml+="					<td style='border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
	cHtml+="						<p class=MsoNormal>"
	cHtml+= TipoString(8.5,1)
	cHtml+="					"+ALLTRIM(STR(aDetail[i][aScan(aDetail[i], {|x| ALLTRIM(x[1]) == "CK_QTDVEN" })][2]))+"<o:p></o:p>"
	cHtml+="							</span>"
	cHtml+="						</p>"
	cHtml+="					</td>"
	cHtml+="					<td style='border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
	cHtml+="						<p class=MsoNormal>"
	cHtml+= TipoString(8.5,1)
	cHtml+="					"+ALLTRIM(Transform(aDetail[i][aScan(aDetail[i], {|x| ALLTRIM(x[1]) == "CK_PRCVEN" })][2],"@E 99,999,999.9999"))+"<o:p></o:p>"
	cHtml+="							</span>"
	cHtml+="						</p>"
	cHtml+="					</td>"
	cHtml+="					<td style='border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
	cHtml+="						<p class=MsoNormal>"
	cHtml+= TipoString(8.5,1)
	cHtml+="					"+ALLTRIM(Transform(aDetail[i][aScan(aDetail[i], {|x| ALLTRIM(x[1]) == "CK_VALOR" })][2],"@E 99,999,999.9999"))+"<o:p></o:p>"
	cHtml+="							</span>"
	cHtml+="						</p>"
	cHtml+="					</td>"
	cHtml+="					<td style='border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
	cHtml+="						<p class=MsoNormal>"
	cHtml+= TipoString(8.5,1)
	cHtml+="					"+ALLTRIM(aDetail[i][aScan(aDetail[i], {|x| ALLTRIM(x[1]) == "CK_NUMPV" })][2])+"<o:p></o:p>"
	cHtml+="							</span>"
	cHtml+="						</p>"
	cHtml+="					</td>"
	cHtml+="					<td style='border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
	cHtml+="						<p class=MsoNormal>"
	cHtml+= TipoString(8.5,1)
	cHtml+="					"+ALLTRIM(aDetail[i][aScan(aDetail[i], {|x| ALLTRIM(x[1]) == "CK_NOTA" })][2])+"<o:p></o:p>"
	cHtml+="							</span>"
	cHtml+="						</p>"
	cHtml+="					</td>"
	cHtml+="				</tr>"
Next i

cHtml+="			</table>"
cHtml+="		</div>"
cHtml+="		<p class=MsoNormal>&nbsp;</p>"
cHtml+="    </td>" 
cHtml+="</tr>"	
cHtml+="<tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>"
cHtml+="	<td style='padding:.75pt .75pt .75pt .75pt'>"
cHtml+="		<p class=MsoNormal align=center style='text-align:center'>"
cHtml+="			<span class=tituloatencao1>"
cHtml+="				<span style='font-size:9.5pt;mso-fareast-font-family:"
cHtml+='				"Times New Roman"'
cHtml+="				;color:red'>"
cHtml+="						GRANT THORNTON BRASIL - Mensagem automática, favor não responder este e-mail."
cHtml+="				</span>"
cHtml+="			</span>"
cHtml+="		</p>"
cHtml+="    </td>"
cHtml+="</tr>"
cHtml+="</body>"
cHtml+="</html>"                       

Return cHtml

/*
Funcao      : TipoString
Objetivos   : 
Autor       : 
Data/Hora   : 
*/            
*----------------------------------------*
 Static Function TipoString(nTam,nColor)
*-----------------------------------------*
                               
Local cAux:=""
      			     			
cAux:="<span style='font-size:"+Alltrim(Str(nTam))+"pt;font-family:"
cAux+='"Verdana","sans-serif"'
cAux+=";mso-fareast-font-family:"
cAux+='"Times New Roman"'
cAux+=";color:"+IIf(nColor==1,"Black","white")+"'>"
               
Return cAux