#Include "Protheus.ch"

/*
Funcao      : GTP2C
Parametros  : cProsp,cLoja,lAuto
Retorno     : lRet
Objetivos   : Converte prospect em cliente, baseado no fonte padrão
Autor       : Matheus Massarotto
Data/Hora   : 02/07/2012
*/

User Function GTP2C(cProsp,cLoja,lAuto)

Local aArea			:= GetArea()					// Armazena o posicionamento atual
Local cCodSA1 		:= ""							// Novo codigo de cliente que sera informado para esse prospect
Local cCodAux 		:= ""							// Codigo auxiliar para evitar falhas no semaforo
Local lGrava  		:= .F.							// Flag para permitir ou nao a Gravacao 	
Local lRet	  		:= .F.							// Retorno da funcao	
//Local lTMK273PTC	:= FindFunction("U_TMK273PTC") 	// P.E. depois da gravacao do prospect no cliente - NAO DIVULGAR pois deve ser usado o P.E. TMKVFIM.
//Local lTK273PT2		:= FindFunction("U_TK273PT2") 	// P.E. depois da gravacao do SU5,AC8 e SA1 - NAO DIVULGAR pois deve ser usado o P.E. TMKVFIM.
Local lAtuADL		:= ChkFile("ADL")				// Indica se deve ser atualizada a tabela ADL

Default lAuto		:= .F.							// Flag que indica se a rotina esta sendo executada sem interface

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciona o PROSPECT e GRAVA um novo CLIENTE                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SUS")
DbSetOrder(1)
If DbSeek(xFilial("SUS")+cProsp+cLoja)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³O PROSPECT nao pode ter nenhum cliente relacionado       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(SUS->US_CODCLI) .AND. Empty(SUS->US_LOJACLI)
	   lGrava := .T. 		
	Endif   

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida se existe o CGC desse prospect na base de clientes³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lGrava
	    If !Empty(SUS->US_CGC)
			DbSelectArea("SA1")
			DbSetOrder(3)
			If DbSeek(xFilial("SA1")+SUS->US_CGC)

				If !lAuto
					//"Atencao","O CNPJ desse Prospect ja está cadastrado na tabela de Clientes, o atendimento nao sera concluido"
					Aviso("Atencao","O CNPJ desse Prospect ja está cadastrado na tabela de Clientes, o atendimento nao sera concluido",{"OK"})
				Endif
				Return(lRet)
		
			Else   
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Valida se existe o mesmo NOME desse PROSPECT na base de clientes   ³
				//³Porem mantem a gravacao do registro porque os CNPJS sao diferentes ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SA1")
				DbSetOrder(2)
				If DbSeek(xFilial("SA1")+SUS->US_NOME)

					If (ALLTRIM(SA1->A1_NOME) == ALLTRIM(SUS->US_NOME)) .AND. !lAuto
			   		   // "Atencao","Ja existe um Cliente cadastrado com o mesmo nome desse Prospect"
					   Aviso("Atencao","Ja existe um Cliente cadastrado com o mesmo nome desse Prospect",{"OK"})
					Endif
					
				Endif
			Endif
			
		Endif	
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Pega um codigo valido para o novo  Cliente ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCodSA1 := CriaVar("A1_COD",.F.)
		cCodAux := TkNumero("SA1","A1_COD")

		cCodSA1 		:= cCodAux 
		If Type("M->UA_CLIENTE") == "C"
			M->UA_CLIENTE 	:= cCodAux
		EndIf		
		
		Reclock("SA1",.T.)
		SA1->A1_FILIAL 	:= SUS->US_FILIAL
		SA1->A1_COD 	:= cCodSA1
		SA1->A1_LOJA	:= SUS->US_LOJA
		SA1->A1_NOME	:= SUS->US_NOME
		SA1->A1_NREDUZ	:= SUS->US_NREDUZ
		SA1->A1_TIPO	:= SUS->US_TIPO		
		SA1->A1_END		:= SUS->US_END		
		SA1->A1_MUN		:= SUS->US_MUN
		SA1->A1_BAIRRO	:= SUS->US_BAIRRO
		SA1->A1_CEP		:= SUS->US_CEP
		SA1->A1_EST		:= SUS->US_EST
		SA1->A1_DDI		:= SUS->US_DDI
		SA1->A1_DDD		:= SUS->US_DDD
		SA1->A1_TEL		:= SUS->US_TEL
		SA1->A1_FAX		:= SUS->US_FAX
		SA1->A1_EMAIL	:= SUS->US_EMAIL
		SA1->A1_HPAGE	:= SUS->US_URL
		SA1->A1_ULTVIS	:= SUS->US_ULTVIS								
		SA1->A1_CODHIST	:= SUS->US_CODHIST
		SA1->A1_VEND	:= SUS->US_VEND
		SA1->A1_CGC		:= SUS->US_CGC				
		If cPaisloc == "BRA"
			SA1->A1_INSCR	:= SUS->US_INSCR
		EndIf
		SA1->A1_SATIV1	:= SUS->US_SATIV
		SA1->A1_SATIV2	:= SUS->US_SATIV2
		SA1->A1_SATIV3	:= SUS->US_SATIV3
		SA1->A1_SATIV4	:= SUS->US_SATIV4
		SA1->A1_SATIV5	:= SUS->US_SATIV5
		SA1->A1_SATIV6	:= SUS->US_SATIV6
		SA1->A1_SATIV7	:= SUS->US_SATIV7
		SA1->A1_SATIV8	:= SUS->US_SATIV8		
		SA1->A1_ALIQIR	:= SUS->US_ALIQIR		
		SA1->A1_GRPTRIB	:= SUS->US_GRPTRIB	
		SA1->A1_NATUREZ	:= SUS->US_NATUREZ		
		SA1->A1_RECCOFI	:= SUS->US_RECCOFI		
		SA1->A1_RECCSLL	:= SUS->US_RECCSLL		
		SA1->A1_RECISS	:= SUS->US_RECISS		
		SA1->A1_RECINSS	:= SUS->US_RECINSS		
		SA1->A1_RECPIS	:= SUS->US_RECPIS		
		SA1->A1_SUFRAMA	:= SUS->US_SUFRAMA			
		
		//MSM - 07/08/2013 - Atualizar os dados de cobrança de acordo com a proposta
		if SELECT("Z55")>0
            //endereço
			if SA1->(FieldPos("A1_ENDCOB"))>0 .AND. Z55->(FieldPos("Z55_COBEND"))>0
				SA1->A1_ENDCOB:=Z55->Z55_COBEND
			endif
			//e-mail
			if SA1->(FieldPos("A1_P_EMAIC"))>0 .AND. Z55->(FieldPos("Z55_COBEMA"))>0
				SA1->A1_P_EMAIC:=Z55->Z55_COBEMA
			endif
            //e-mail
			if SA1->(FieldPos("A1_P_EMACO"))>0 .AND. Z55->(FieldPos("Z55_COBEMA"))>0
				SA1->A1_P_EMACO:=Z55->Z55_COBEMA
			endif
			//e-mail
			if SA1->(FieldPos("A1_P_EMAIL"))>0 .AND. Z55->(FieldPos("Z55_COBEMA"))>0
				SA1->A1_P_EMAIL:=Z55->Z55_COBEMA
			endif
            //bairro
			if SA1->(FieldPos("A1_BAICOB"))>0 .AND. Z55->(FieldPos("Z55_COBBAI"))>0
				SA1->A1_BAICOB:=Z55->Z55_COBBAI
			endif			
            //bairro
			if SA1->(FieldPos("A1_BAIRROC"))>0 .AND. Z55->(FieldPos("Z55_COBBAI"))>0
				SA1->A1_BAIRROC:=Z55->Z55_COBBAI
			endif			
            //municipio
			if SA1->(FieldPos("A1_MUNCOB"))>0 .AND. Z55->(FieldPos("Z55_COBMUN"))>0
				SA1->A1_MUNCOB:=Z55->Z55_COBMUN
			endif
            //CEP
			if SA1->(FieldPos("A1_CEPCOB"))>0 .AND. Z55->(FieldPos("Z55_COBCEP"))>0
				SA1->A1_CEPCOB:=Z55->Z55_COBCEP
			endif
            //Código Ramo de atividade
			if SA1->(FieldPos("A1_P_RMATI"))>0 .AND. Z55->(FieldPos("Z55_RMATI"))>0
				SA1->A1_P_RMATI:=Z55->Z55_RMATI
			endif
			//Descrição Ramo de atividade
			if SA1->(FieldPos("A1_P_DRMAT"))>0 .AND. Z55->(FieldPos("Z55_DRMAT"))>0
				SA1->A1_P_DRMAT:=Z55->Z55_DRMAT
			endif
		endif
		//MSM - 07/08/2013 - Atualizar os dados de cobrança de acordo com a proposta
		if SELECT("Z79")>0
            //endereço
			if SA1->(FieldPos("A1_ENDCOB"))>0 .AND. Z79->(FieldPos("Z79_COBEND"))>0
				SA1->A1_ENDCOB:=Z79->Z79_COBEND
			endif
			//e-mail
			if SA1->(FieldPos("A1_P_EMAIC"))>0 .AND. Z79->(FieldPos("Z79_COBEMA"))>0
				SA1->A1_P_EMAIC:=Z79->Z79_COBEMA
			endif
            //e-mail
			if SA1->(FieldPos("A1_P_EMACO"))>0 .AND. Z79->(FieldPos("Z79_COBEMA"))>0
				SA1->A1_P_EMACO:=Z79->Z79_COBEMA
			endif
			//e-mail
			if SA1->(FieldPos("A1_P_EMAIL"))>0 .AND. Z79->(FieldPos("Z79_COBEMA"))>0
				SA1->A1_P_EMAIL:=Z79->Z79_COBEMA
			endif
            //bairro
			if SA1->(FieldPos("A1_BAICOB"))>0 .AND. Z79->(FieldPos("Z79_COBBAI"))>0
				SA1->A1_BAICOB:=Z79->Z79_COBBAI
			endif			
            //bairro
			if SA1->(FieldPos("A1_BAIRROC"))>0 .AND. Z79->(FieldPos("Z79_COBBAI"))>0
				SA1->A1_BAIRROC:=Z79->Z79_COBBAI
			endif			
            //municipio
			if SA1->(FieldPos("A1_MUNCOB"))>0 .AND. Z79->(FieldPos("Z79_COBMUN"))>0
				SA1->A1_MUNCOB:=Z79->Z79_COBMUN
			endif
            //CEP
			if SA1->(FieldPos("A1_CEPCOB"))>0 .AND. Z79->(FieldPos("Z79_COBCEP"))>0
				SA1->A1_CEPCOB:=Z79->Z79_COBCEP
			endif
			
		endif
		
		If (SA1->(FieldPos("A1_P_SOCIO")) > 0) .AND. (SUS->(FieldPos("US_P_SOCIO")) > 0) 
			SA1->A1_P_SOCIO := SUS->US_P_SOCIO
		EndIf		
		
		If (SA1->(FieldPos("A1_HRTRANS")) > 0) .AND. (SUS->(FieldPos("US_TRASLA")) > 0) 
			SA1->A1_HRTRANS	:= SUS->US_TRASLA
		EndIf
		
		FkCommit()
		MsUnlock()         

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de entrada para gravacao dos dados do cliente³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		/*
		If lTMK273PTC
			U_TMK273PTC()
		Endif
		*/	
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Pegou um codigo novo confirma a gravacao do SXE³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If __lSX8
			ConfirmSX8()
		Endif
		
		//RRP - 16/09/2013 - Gravar o Item contábil caso não exista um registro igual no CTD
		CTH->(DbSetOrder(1))
		If !(CTD->(DbSeek(xFilial("CTD")+cCodSA1)))
			CTD->(Reclock("CTD",.T.))
			CTD->CTD_ITEM	:= cCodSA1
			CTD->CTD_CLASSE	:= "2"
			CTD->CTD_DESC01	:= SUS->US_NOME
			CTD->CTD_BLOQ	:= "2"
			CTD->CTD_DTEXIS	:= StoD("19800101")
			CTD->CTD_ITLP	:= cCodSA1
			CTD->CTD_CLOBRG	:= "2"
			CTD->CTD_ACCLVL	:= "1"
			CTD->(MsUnlock())
		Else 
			MsgInfo("Não foi possível gerar o Item Contábil Automática. Com código "+cCodSA1)
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Altera os relacionamentos de contatos para a nova entidade - CLIENTES ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("AC8")
		dbSetOrder(2) 		//AC8_FILIAL+AC8_ENTIDA+AC8_FILENT+AC8_CODENT+AC8_CODCON

 		While dbSeek(xFilial("AC8")+"SUS"+xFilial("SUS")+(SUS->US_COD+SUS->US_LOJA))	
			Reclock("AC8",.F.)
				Replace AC8_FILIAL With xFilial("AC8")
				Replace AC8_ENTIDA With "SA1"
				Replace AC8_FILENT With xFilial("SA1")
				Replace AC8_CODENT With cCodSA1+SUS->US_LOJA
			MsUnlock()
			DbCommit()               
		EndDo

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Altera os relacionamentos de Banco de Conhecimento para³
		//³a nova entidade - CLIENTES                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("AC9")
		DbSetOrder(2) 		//AC9_FILIAL+AC9_ENTIDA+AC9_FILENT+AC9_CODENT+AC9_CODOBJ
		While dbSeek(xFilial("AC9")+"SUS"+xFilial("SUS")+(SUS->US_COD+SUS->US_LOJA))
			Reclock("AC9",.F.)
				Replace AC9_FILIAL With xFilial("AC9")
				Replace AC9_ENTIDA With "SA1"
				Replace AC9_FILENT With xFilial("SA1")
				Replace AC9_CODENT With cCodSA1+SUS->US_LOJA
			MsUnlock()
			DbCommit()               
		EndDo
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza o STATUS do prospect  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SUS")
		Reclock( "SUS" ,.F.)
		Replace US_STATUS  With "6" 			// 6 - Cliente     
		Replace US_CODCLI  With cCodSA1
		Replace US_LOJACLI With cLoja
		Replace US_DTCONV  With Date()    
		MsUnlock()
		
		If lAtuADL .AND. FindFunction("Ft520UpdEn")
			Ft520UpdEn("SUS"		, "SA1"			, SUS->US_COD	, SA1->A1_COD	,;
						SUS->US_LOJA, SA1->A1_LOJA	)
		EndIf
		
		If FindFunction("Ft300UpdEn")
			Ft300UpdEn(SUS->US_COD, SA1->A1_COD, SUS->US_LOJA, SA1->A1_LOJA)
		EndIf
		lRet := .T.
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de entrada para gravacao dos dados do cliente³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		/*
		If lTK273PT2
			U_TK273PT2()
		Endif			
		*/
		

	Endif
Endif

RestArea(aArea)

Return(lRet)

/*
Função  : GeraEmpGrp
Objetivo: Transformar prospects que fazem parte de um grupo em clientes. 
Autor   : Eduardo C. Romanini
Data    : 11/09/13
*/
*-----------------------------------------*
User Function GeraEmpGrp(cTpCtr,cProp,cRev)
*-----------------------------------------*
Local lGrava := .F.

Local cCodPros  := ""
Local cLojaPros := ""
Local cCodSA1   := ""
Local cCodAux   := ""
Local cCodACY   := ""

Local aAreaZ55 := Z55->(GetArea())

//Verifica se existem empresas de grupo
Z35->(DbSetOrder(1))
If Z35->(DbSeek(xFilial("Z35")+cProp+cRev))
	While Z35->(!EOF()) .and. Z35->(Z35_FILIAL+Z35_PROPOS+Z35_REVISA) == xFilial("Z35")+cProp+cRev

		If Z35->Z35_ITEM <> "00" .and. Z35->Z35_PERCEN > 0
			lGrava := .T.
			Exit
		EndIf

		Z35->(DbSkip())
	EndDo
EndIf

//Se não existir empresa de grupo, não realiza a gravação.
If !lGrava
	Return
EndIf

Z55->(DbSetOrder(1))
If Z55->(DbSeek(xFilial("Z55")+cTpCtr+cProp+cRev))
	cCodPros  := Z55->Z55_PROSPE
	cLojaPros := Z55->Z55_PLOJA
Else
	Return .F.
EndIf

//Posiciona o cadastro de prospect da proposta
SUS->(DbSetOrder(1))
SUS->(DbSeek(xFilial("SUS")+cCodPros+cLojaPros))     

//Grava o grupo de empresas
cCodACY := CriaVar("ACY_GRPVEN",.F.)
cCodAux := TkNumero("ACY","ACY_GRPVEN")
cCodACY := cCodAux

ACY->(RecLock("ACY",.T.))

ACY->ACY_FILIAL := xFilial("ACY")
ACY->ACY_GRPVEN := cCodACY
ACY->ACY_DESCRI := SUS->US_NOME

ACY->(MsUnlock())


//Grava o grupo do prospect principal
SA1->(DbSetOrder(1))
If SA1->(DbSeek(xFilial("SA1")+SUS->US_CODCLI+SUS->US_LOJACLI))
	SA1->(RecLock("SA1",.F.))
	SA1->A1_GRPVEN := cCodACY	
	SA1->(MsUnlock())
EndIf

Z35->(DbSetOrder(1))
If Z35->(DbSeek(xFilial("Z35")+cProp+cRev))
	While Z35->(!EOF()) .and. Z35->(Z35_FILIAL+Z35_PROPOS+Z35_REVISA) == xFilial("Z35")+cProp+cRev
        
        lGrava := .F.
        
		//Desconsidera o primeiro item que é o prospect da proposta.
		If Z35->Z35_ITEM == "00"
			Z35->(DbSkip())
			Loop
		EndIf
		
		//Se não foi informado percentual, é porque o prospect não irá virar cliente.
		If Z35->Z35_PERCEN == 0
			Z35->(DbSkip())
			Loop
		EndIf
   
        Z40->(DbSetOrder(1))
        If Z40->(DbSeek(xFilial("Z40")+SUS->US_COD+SUS->US_LOJA+Z35->Z35_ITEM))
	 			
 			If Empty(Z40->Z40_CODCLI) .and. Empty(Z40->Z40_LOJCLI)
 				lGrava := .T.
 			EndIf
	 			           	
			If lGrava            
                 
				If !Empty(Z35->Z35_CGC)
					SA1->(DbSetOrder(3))
					If SA1->(DbSeek(xFilial("SA1")+Z35->Z35_CGC))
						Z35->(DbSkip())
						Loop
					Endif

	            ElseIf !Empty(Z40->Z40_CGC)
	   			
					SA1->(DbSetOrder(3))
					If SA1->(DbSeek(xFilial("SA1")+Z40->Z40_CGC))
						Z40->(DbSkip())
						Loop
					Endif

	   			Else   
					SA1->(DbSetOrder(2))
					If SA1->(DbSeek(xFilial("SA1")+Z40->Z40_NOME))
						If (AllTrim(SA1->A1_NOME) == ALLTRIM(Z40->Z40_NOME))
                        	Z35->(DbSkip())
							Loop
						EndIf
					EndIf
				EndIf
               	 
				//Inicio da gravação do cliente              		
					
				DbSelectArea("SA1")
				cCodSA1 := CriaVar("A1_COD",.F.)
				cCodAux := TkNumero("SA1","A1_COD")

				cCodSA1 		:= cCodAux 
			
				If Type("M->UA_CLIENTE") == "C"
					M->UA_CLIENTE 	:= cCodAux
				EndIf		
		
				Reclock("SA1",.T.)
				SA1->A1_FILIAL 	:= SUS->US_FILIAL
				SA1->A1_COD 	:= cCodSA1
				SA1->A1_LOJA	:= "01"
				SA1->A1_NOME	:= Z40->Z40_NOME
				SA1->A1_NREDUZ	:= Z40->Z40_NOME
				SA1->A1_TIPO	:= SUS->US_TIPO		
				SA1->A1_END		:= SUS->US_END		
				SA1->A1_MUN		:= SUS->US_MUN
				SA1->A1_BAIRRO	:= SUS->US_BAIRRO
				SA1->A1_CEP		:= SUS->US_CEP
				SA1->A1_EST		:= SUS->US_EST
				SA1->A1_DDI		:= SUS->US_DDI
				SA1->A1_DDD		:= SUS->US_DDD
				SA1->A1_TEL		:= SUS->US_TEL
				SA1->A1_FAX		:= SUS->US_FAX
				SA1->A1_EMAIL	:= SUS->US_EMAIL
				SA1->A1_HPAGE	:= SUS->US_URL
				SA1->A1_ULTVIS	:= SUS->US_ULTVIS								
				SA1->A1_CODHIST	:= SUS->US_CODHIST
				SA1->A1_VEND	:= SUS->US_VEND
				SA1->A1_CGC		:= Z35->Z35_CGC			
				If cPaisloc == "BRA"
					SA1->A1_INSCR	:= SUS->US_INSCR
				EndIf
				SA1->A1_SATIV1	:= SUS->US_SATIV
				SA1->A1_SATIV2	:= SUS->US_SATIV2
				SA1->A1_SATIV3	:= SUS->US_SATIV3
				SA1->A1_SATIV4	:= SUS->US_SATIV4
				SA1->A1_SATIV5	:= SUS->US_SATIV5
				SA1->A1_SATIV6	:= SUS->US_SATIV6
				SA1->A1_SATIV7	:= SUS->US_SATIV7
				SA1->A1_SATIV8	:= SUS->US_SATIV8		
				SA1->A1_ALIQIR	:= SUS->US_ALIQIR		
				SA1->A1_GRPTRIB	:= SUS->US_GRPTRIB	
				SA1->A1_NATUREZ	:= SUS->US_NATUREZ		
				SA1->A1_RECCOFI	:= SUS->US_RECCOFI		
				SA1->A1_RECCSLL	:= SUS->US_RECCSLL		
				SA1->A1_RECISS	:= SUS->US_RECISS		
				SA1->A1_RECINSS	:= SUS->US_RECINSS		
				SA1->A1_RECPIS	:= SUS->US_RECPIS		
				SA1->A1_SUFRAMA	:= SUS->US_SUFRAMA			
				SA1->A1_GRPVEN  := cCodACY
				//MSM - 07/08/2013 - Atualizar os dados de cobrança de acordo com a proposta
	            //endereço
				if SA1->(FieldPos("A1_ENDCOB"))>0 .AND. Z55->(FieldPos("Z55_COBEND"))>0
					SA1->A1_ENDCOB:=Z55->Z55_COBEND
				endif
				//e-mail
				if SA1->(FieldPos("A1_P_EMAIC"))>0 .AND. Z55->(FieldPos("Z55_COBEMA"))>0
					SA1->A1_P_EMAIC:=Z55->Z55_COBEMA
				endif
		        //e-mail
				if SA1->(FieldPos("A1_P_EMACO"))>0 .AND. Z55->(FieldPos("Z55_COBEMA"))>0
					SA1->A1_P_EMACO:=Z55->Z55_COBEMA
				endif
				//e-mail
				if SA1->(FieldPos("A1_P_EMAIL"))>0 .AND. Z55->(FieldPos("Z55_COBEMA"))>0
					SA1->A1_P_EMAIL:=Z55->Z55_COBEMA
				endif
		        //bairro
				if SA1->(FieldPos("A1_BAICOB"))>0 .AND. Z55->(FieldPos("Z55_COBBAI"))>0
					SA1->A1_BAICOB:=Z55->Z55_COBBAI
				endif			
		        //bairro
				if SA1->(FieldPos("A1_BAIRROC"))>0 .AND. Z55->(FieldPos("Z55_COBBAI"))>0
					SA1->A1_BAIRROC:=Z55->Z55_COBBAI
				endif			
		        //municipio
				if SA1->(FieldPos("A1_MUNCOB"))>0 .AND. Z55->(FieldPos("Z55_COBMUN"))>0
					SA1->A1_MUNCOB:=Z55->Z55_COBMUN
				endif
		        //CEP
				if SA1->(FieldPos("A1_CEPCOB"))>0 .AND. Z55->(FieldPos("Z55_COBCEP"))>0
					SA1->A1_CEPCOB:=Z55->Z55_COBCEP
				endif
				If (SA1->(FieldPos("A1_HRTRANS")) > 0) .AND. (SUS->(FieldPos("US_TRASLA")) > 0) 
					SA1->A1_HRTRANS	:= SUS->US_TRASLA
				EndIf
				//Código Ramo de atividade
				if SA1->(FieldPos("A1_P_RMATI"))>0 .AND. Z55->(FieldPos("Z55_RMATI"))>0
					SA1->A1_P_RMATI:=Z55->Z55_RMATI
				endif
				//Descrição Ramo de atividade
				if SA1->(FieldPos("A1_P_DRMAT"))>0 .AND. Z55->(FieldPos("Z55_DRMAT"))>0
					SA1->A1_P_DRMAT:=Z55->Z55_DRMAT
				endif
			    
				SA1->A1_P_SOCIO := SUS->US_P_SOCIO
			
				FkCommit()
				MsUnlock()         

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Pegou um codigo novo confirma a gravacao do SXE³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If __lSX8
					ConfirmSX8()
				Endif
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualiza o STATUS do prospect  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Z40->(Reclock("Z40",.F.))
				Z40->Z40_CODCLI  := cCodSA1
				Z40->Z40_LOJCLI  := "01"
				Z40->Z40_DTCONV  := dDataBase
				Z40->Z40_ECLI    := "1"    
				Z40->(MsUnlock())
				
				//RRP - 16/09/2013 - Gravar o Item contábil caso não exista um registro igual no CTD
				CTH->(DbSetOrder(1))
				If !(CTD->(DbSeek(xFilial("CTD")+cCodSA1)))
					CTD->(Reclock("CTD",.T.))
					CTD->CTD_ITEM	:= cCodSA1
					CTD->CTD_CLASSE	:= "2"
					CTD->CTD_DESC01	:= Z40->Z40_NOME
					CTD->CTD_BLOQ	:= "2"
					CTD->CTD_DTEXIS	:= StoD("19800101")
					CTD->CTD_ITLP	:= cCodSA1
					CTD->CTD_CLOBRG	:= "2"
					CTD->CTD_ACCLVL	:= "1"
					CTD->(MsUnlock())
				Else 
					MsgInfo("Não foi possível gerar o Item Contábil Automática. Com código "+cCodSA1)
				EndIf				  
			
	        EndIf
                
		EndIf

		Z35->(DbSkip())
    EndDo
EndIf

RestArea(aAreaZ55)

Return