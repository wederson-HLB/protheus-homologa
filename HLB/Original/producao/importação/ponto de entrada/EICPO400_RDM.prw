#Include 'Rwmake.ch'
#Include 'Protheus.ch'

/*
Funcao      : EICPO400 
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : P.E. para adicionar o botão marca todos na P.O. 
Autor       : Eduardo Romanini
Data/Hora   :      
Obs         : 
TDN         : Utilizado durante a rotina de manutenção do Purchase Order.
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 15/02/2012
Obs         : 
Módulo      : Importação.
Cliente     : Todos
*/

*----------------------*
User Function EICPO400()
*----------------------*

Local cParam := ""

If ValType(ParamIXB) == "C"
	cParam := ParamIXB
ElseIf ValType(ParamIXB) == "A"
	cParam := ParamIXB[1]
EndIf

Do Case 
	Case cParam == "ANTES_TELA_ITEM"
		
		//Adiciona o botão para marcar todos os itens.
		If aScan(aButtons,{|a| a[1] == "SELECTALL"}) == 0
			aAdd(aButtons,{"SELECTALL" ,{|| U_MarcaTPO()},"Marca Todos"})
		EndIf

	Case cParam == "GRAVA_SC7"

		cC1_CC:=""

End Case

Return Nil

*----------------------*
User Function MarcaTPO()
*----------------------*
Local lMTodos := .F.

Local cMsgVld := ""
Local cTexto  := ""

Local nPos := Work->(RecNo())
Local nI   := 0

Local oFont
Local oDlg
Local oMemo

Private aMsgVld := {}

//Verifica se existe algum item desmarcado
//para identificar se os itens serão marcados
//ou desmarcados.
Work->(DbGoTop())
While Work->(!EOF())
	
	//Verifica se está desmarcado.
	If !Work->WKFLAG
		lMTodos := .T.
		Exit
	EndIf

	Work->(DbSkip())
EndDo

//Marca Todos
If lMTodos
	Work->(DbGoTop())
	While Work->(!EOF())

		If !Work->WKFLAG
			If ValMarca()
		
				If lPOdaIntegracao .OR. cProg="PN"
					MTotal   -= VAL(STR(Work->WKPRECO * Work->WKQTDE,15,2))
					MFob_Abs -= VAL(STR(Work->WKPRECO * Work->WKQTDE,15,2))
					MForn    := IF(MTotal=0 .AND. !W_Flag_Seq,"",MForn)
				EndIf
			
				Work->WKFLAG    := .T.
				Work->WKFLAGWIN := cMarca		
				Work->WKSALDO_Q := PO400Saldo() 
				Work->WKPOSICAO := STRZERO(Val(Work->WKPOSICAO),LEN(SW3->W3_POSICAO),0)
				Work->WKSEM_PO  := (POSALDO_W1()-Work->WKQTDE)

				If Work->WKSALDO_Q < 0 .AND. !lLibQt
					Work->WKSALDO_Q := 0
				EndIf
	           
	            //RRP - 24/04/2013 - Passando parâmetros que está no PO ao marcar todos os itens
				E_ItFabFor("I",,"PO") // posiciona SB1, atualiza descricao do item em ingles,
								// nome reduzido do fabricante e do fornecedor
	
				If !EMPTY( Work->WKFABR )
					SYG->(DbSeek(xFilial()+M->W2_IMPORT+Work->WKFABR+Work->WKCOD_I))
					Work->WK_REG_MIN := SYG->YG_REG_MIN
				EndIf
	
				MTotal  := MTotal + Val(STR(WORK->WKPRECO * WORK->WKQTDE,15,2))
				MFob_Abs+= Val(STR(WORK->WKPRECO * WORK->WKQTDE,15,2))
	
				If lExiste_Midia .and. !Empty(M->W2_VLMIDIA) .and. SB1->B1_MIDIA $ cSim      
					Work->WK_VLTOTMI := SB1->B1_QTMIDIA * M->W2_VLMIDIA * Work->WKQTDE
				EndIf
	
				If Empty(MForn)
					MForn := M->W2_FORN
				EndIf
	             
				TEmb_Ant  := Work->WKDT_EMB
			    	
			EndIf 	
		EndIf
		
        Work->(DbSkip())
	EndDo	

//Desmarca Todos
Else

	Work->(DbGoTop())
	While Work->(!EOF())
		
		If Work->WKFLAG
		
			MTotal   -= VAL(STR(Work->WKPRECO * Work->WKQTDE,15,2))
			MFob_Abs -= VAL(STR(Work->WKPRECO * Work->WKQTDE,15,2))
			Work->WKSALDO_Q  := 0
   
			If !lCopiaPO
				If Work->WKFLUXO=="1"
					Work->WKQTDE := Work->WKQTDE_LI  
				EndIf
   
				Work->WKSEM_PO  := (POSALDO_W1()-Work->WKQTDE)
			Else
				Work->WKSEM_PO  += Work->WKQTDE
      			Work->WKQTDE    := 0
			EndIf

			Work->WKDT_ENTR   := Work->WKDTENTR_S
			Work->WKFABR      := Work->WKFABR_O
			Work->WKFORN      := Work->WKFORN_O
			Work->WKNOME_FAB  := SPACE(15)
			Work->WKNOME_FOR  := SPACE(15)
			Work->WKFLAG      := .F.
			Work->WKFLAGWIN   := SPACE(nLenOk)
            
			//RRP - 24/04/2013 - Passando parâmetros que está no PO ao marcar todos os itens
   			E_ItFabFor("I",,"PO") // posiciona SB1, atualiza descricao do item em ingles,
                   			// nome reduzido do fabricante e do fornecedor

			MForn := IF(MTotal == 0 .AND. ! W_Flag_Seq,"",MForn)
		
		EndIf

		Work->(DbSkip())
	EndDo

EndIf

//Mensagem de validação
If Len(aMsgVld) > 0
	
	For nI:=1 To Len(aMsgVld)
			
		If aMsgVld[nI][3] == "OBRIGAT"
			cMsgVld += "O item " + AllTrim(aMsgVld[nI][1]) + " está com o campo obrigatorio " +AllTrim(aMsgVld[nI][2])+ " em branco." + CRLF
		EndIf
					
	Next

	cTexto := "Alguns itens não foram selecionados porque apresentam divergencias:" + CRLF
	cTexto += cMsgVld	
	
	//Monta a tela da mensagem.
	DEFINE FONT oFont NAME "Mono AS" SIZE 5,12
	DEFINE MSDIALOG oDlg TITLE "Validação" From 3,0 to 340,417 PIXEL
	
		@ 5,5 GET oMemo  VAR cTexto MEMO SIZE 200,145 OF oDlg PIXEL READONLY
		oMemo:bRClicked := {||AllwaysTrue()}
		oMemo:oFont:=oFont
		
	ACTIVATE MSDIALOG oDlg CENTERED

EndIf

Work->(DbGoTo(nPos))

Return Nil

*------------------------*
Static Function ValMarca()
*------------------------*
Local lRet := .T.

Local nI := 0

Local aCpObrig := {{"WKFABR","Fabricante"},{"WKQTDE","Qtde"},{"WKPRECO","Preco Unit."},{"WKDT_EMB","Dt Embarque"},{"WKDT_ENTR","Dt Entrega"}}

For nI := 1 To Len(aCpObrig)

	If Empty(&("Work->"+aCpObrig[nI][1]))
    	lRet := .F.

		aAdd(aMsgVld,{Work->WKCOD_I,aCpObrig[nI][2],"OBRIGAT"})
	
	EndIf	
Next

Return lRet
