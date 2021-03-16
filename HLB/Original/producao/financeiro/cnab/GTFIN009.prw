#Include "rwmake.ch"    

/*
Funcao      : GTFIN009
Parametros  : nOpc
Retorno     : cRet
Objetivos   : Retorna Dados de Identificação do Tributo.
Autor       : Anderson Arrais
TDN         : 
OBS			: Layout 240 posições contas a pagar.
Revisão     : Anderson Arrais
Data/Hora   : 17/11/2015
Módulo      : Financeiro.
*/                      

*------------------------------*
 User Function GTFIN009(nOpc)   
*------------------------------*   

Local aArea:= GetArea()
Local cRet       := ""      
Local cModPag    := Posicione("SEA",1,xFilial("SEA")+SE2->E2_NUMBOR+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA,"EA_MODELO")
Local nOutEnt	 := 0
Local cCodre     := "" //CAMPO PARA RECEBER CODIGO DE RETENÇÃO/RECOLHIMENTO/RECEITA

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Dados de Identificação do Tributo  				   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If nOpc == 1 //Preenche a partir da posição 111 até a 230
    If cModPag $ "17"   //  GPS
    	DbSelectArea("SE2")
       	If FieldPos("E2_P_VRENT") > 0
       		nOutEnt := STRZERO(SE2->(E2_P_VRENT)*100,15)
       	Else
       		nOutEnt := REPL("0",15) 
       	EndIf
		IF ALLTRIM(SM0->M0_CODIGO) == "QU"
			/*IF !U_GTFIN039(3,'')
				Help("",1,"CAMPOS OBRIGATÓRIO",,"CAMPOS CUSTOMIZADOS NÃO EXISTEM NA TABELA SE2.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Entre em contato com o Suporte e informe a mensagem!"})
				cCodre := "0000"
			ELSE*/ 
				cRet:= PADR(ALLTRIM(SE2->E2_P_CODRE),6)                                         //01.N1 111 - 116 (6)    - Código da Receita do Tributo
				cRet+= PADL(ALLTRIM(SE2->E2_P_TPCON),2,'0')                                     //02.N1 117 - 118 (2)    - Tipo de Identificação do Contribuinte
				cRet+= PADL(ALLTRIM(SE2->E2_P_CGCON),14,'0')                                    //03.N1 119 - 132 (14)   - Identificação do Contribuinte - CNPJ/CGC/CPF
				cRet+= "17"                                                                     //04.N1 133 - 134 (2)    - Código de Identificação do Tributo
				cRet+= STRZERO(MONTH(SE2->E2_P_COMPE,2),2) + STRZERO(YEAR(SE2->E2_P_COMPE,4),4) //05.N1 135 - 140 (6)    - Mês e ano de competência
				cRet+= STRZERO(SE2->(E2_SALDO-E2_P_VRENT)*100,15)                                        //06.N1 141 - 155 (13,2) - Valor previsto do pagamento do INSS
				cRet+= nOutEnt                                                                  //07.N1 156 - 170 (13,2) - Valor de Outras Entidades
				cRet+= STRZERO(SE2->(E2_ACRESC)*100,15)                                         //08.N1 171 - 185 (13,2) - Atualização Monetária
				cRet+= SPACE(45)                                                                //09.N1 186 - 230 (45)   - Uso Exclusivo FEBRABAN/CNAB
			//ENDIF
		Else
			cCodre := SE2->E2_CODRET
			cRet := STRZERO(VAL(cCodre),6) + "01" + SUBSTR(SM0->M0_CGC,1,14) + "17" + STRZERO(MONTH(SE2->E2_EMISSAO,2),2)+ STRZERO(YEAR(SE2->E2_EMISSAO,4),4)
			cRet += STRZERO(SE2->(E2_SALDO)*100,15) + nOutEnt + STRZERO(SE2->(E2_ACRESC)*100,15) + SPACE (45)
		ENDIF  
        
    Endif 
    If cModPag $ "16"  // DARF
		IF ALLTRIM(SM0->M0_CODIGO) == "QU"
			/*IF !U_GTFIN039(3,'')
				Help("",1,"CAMPOS OBRIGATÓRIO",,"CAMPOS CUSTOMIZADOS NÃO EXISTEM NA TABELA SE2.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Entre em contato com o Suporte e informe a mensagem!"})
				cCodre := "0000"
			ELSE */
				cRet:= PADR(ALLTRIM(SE2->E2_P_CODRE),6)                                                   //01.N2 111 - 116 (6)    - Código da Receita do Tributo
				cRet+= PADL(ALLTRIM(SE2->E2_P_TPCON),2,'0')                                              //02.N2 117 - 118 (2)    - Tipo de Identificação do Contribuinte
				cRet+= PADL(ALLTRIM(SE2->E2_P_CGCON),14,'0')                                                 //03.N2 119 - 132 (14)   - Identificação do Contribuinte - CNPJ/CGC/CPF
				cRet+= "16"                                                                     //04.N2 133 - 134 (2)    - Código de Identificação do Tributo
				cRet+= GRAVADATA(SE2->E2_P_COMPE,.F.,5)	 									    //05.N2 135-142 (8)      - Período de Apuração
				cRet+= STRZERO(VAL(SE2->E2_P_REFE),17)                                          //06.N2 143-159 (17)     - Numero de referencia
				cRet+= STRZERO(SE2->(E2_SALDO+E2_ACRESC-E2_DECRESC)*100,15)				        //07.N2 160-174 (13,2)   - Valor Principal
				cRet+= STRZERO(0,15)											                //08.N2 175-189 (13,2)   - Valor da Multa
				cRet+= STRZERO(0,15)										                    //09.N2 190-204 (13,2)   - Valor dos Juros / Encargos
				cRet+= GRAVADATA(SE2->E2_VENCTO,.F.,5)			                                //10.N2 205-212 (8)      - Data de Vencimento
				cRet+= SPACE(18)    										                    //11.N2 213-230 (18)     - Uso Exclusivo FEBRABAN/CNAB
			//ENDIF
		Else
			cCodre := SE2->E2_CODRET
			cRet := STRZERO(VAL(cCodre),6) + "01" + SUBSTR(SM0->M0_CGC,1,14) + "16" + GRAVADATA(SE2->E2_EMISSAO,.F.,5)
			cRet += "00000000000000000" + STRZERO(SE2->(E2_SALDO+E2_ACRESC-E2_DECRESC)*100,15) + REPL("0",30) + GRAVADATA(SE2->E2_VENCREA,.F.,5) + SPACE(18)
		ENDIF  
    Endif
    If cModPag $ "22/23"  // GARE
			IF ALLTRIM(SM0->M0_CODIGO) == "QU"
				/*IF !U_GTFIN039(3,'')
					Help("",1,"CAMPOS OBRIGATÓRIO",,"CAMPOS CUSTOMIZADOS NÃO EXISTEM NA TABELA SE2.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Entre em contato com o Suporte e informe a mensagem!"})
					cCodre := "0000"
				ELSE */
					cRet:= PADR(ALLTRIM(SE2->E2_P_CODRE),6)                                         //01.N4 111 - 116 (6)    - Código da Receita do Tributo
					cRet+= PADL(ALLTRIM(SE2->E2_P_TPCON),2,'0')                                     //02.N4 117 - 118 (2)    - Tipo de Identificação do Contribuinte
					cRet+= PADL(ALLTRIM(SE2->E2_P_CGCON),14,'0')                                    //03.N4 119 - 132 (14)   - Identificação do Contribuinte - CNPJ/CGC/CPF
					cRet+= AllTrim(cModPag)                                                         //04.N4 133 - 134 (2)    - Código de Identificação do Tributo
					cRet+= GRAVADATA(SE2->E2_VENCTO,.F.,5)	 									    //05.N4 135 - 142 (8)    - Data de Vencimento
					cRet+= STRZERO(VAL(SUBSTR(SE2->E2_P_INSCR,1,12)),12)							//06.N4 143 - 154 (12)   - Inscrição Estadual / Código do Município / Número Declaração
					cRet+= STRZERO(Val(SE2->E2_P_DIVAT),13)										    //07.N4 155 - 167 (13)   - Dívida Ativa / N. Etiqueta
					cRet+= STRZERO(MONTH(SE2->E2_P_COMPE,2),2)+ STRZERO(YEAR(SE2->E2_P_COMPE,4),4)	//08.N4 168 - 173 (6)    - Período de Referência
					cRet+= STRZERO(Val(SE2->E2_P_PARCE),13)											//09.N4 174 - 186 (13)   - Número da Parcela / Notificação
					cRet+= STRZERO(SE2->(E2_SALDO+E2_ACRESC-E2_DECRESC)*100,15)					    //10.N4 187 - 201 (13,2) - Valor da Receita
					cRet+= STRZERO(0,14)											                //11.N4 202 - 215 (12,2) - Valor dos Juros / Encargos
					cRet+= STRZERO(0,14)			                                                //12.N4 216 - 229 (12,2) - Valor da Multa
					cRet+= SPACE(1) 										                        //13.N4 230 - 230 (1)    - Uso Exclusivo FEBRABAN/CNAB

				//ENDIF
			Else
				cCodre := SE2->E2_CODRET
				cRet := cCodre + SPACE(6-LEN(cCodre)) + "01" + SUBSTR(SM0->M0_CGC,1,14) + "22" + GRAVADATA(SE2->E2_VENCREA,.F.,5)
				cRet += STRZERO(VAL(SUBSTR(SM0->M0_INSC,1,12)),12) + REPL("0",13) + STRZERO(MONTH(SE2->E2_EMISSAO,2),2)+ STRZERO(YEAR(SE2->E2_EMISSAO,4),4)
				cRet += REPL("0",13) + STRZERO(SE2->(E2_SALDO+E2_ACRESC-E2_DECRESC)*100,15) + REPL("0",28) + SPACE(1)
			ENDIF  
        
    Endif
Endif    

//AOA - 25/05/2018 - Ajuste para tratamento de GPS com multa e valores de outras entidades.
If nOpc == 2 
	If cModPag $ "17"   //  GPS
		DbSelectArea("SE2")
		If FieldPos("E2_P_VRENT") > 0
	   	cRet := STRZERO(SE2->(E2_SALDO+E2_ACRESC+E2_P_VRENT-E2_DECRESC)*100,15)
	  Else
	  	cRet := STRZERO(SE2->(E2_SALDO+E2_ACRESC-E2_DECRESC)*100,15)
	  EndIf
  Else
   	cRet := STRZERO(SE2->(E2_SALDO+E2_ACRESC-E2_DECRESC)*100,15)
  EndIf   
EndIf

RestArea(aArea)
Return(cRet)