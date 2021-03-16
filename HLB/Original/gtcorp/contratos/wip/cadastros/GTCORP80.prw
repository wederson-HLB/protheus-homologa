#Include "Protheus.ch"

/*
Funcao      : GTCORP80
Parametros  : Nil
Retorno     : Nil
Objetivos   : Função que cria um grid para vinculo de empresas no prospect
Autor       : Matheus Massarotto
Data/Hora   : 27/08/2013    15:51
Revisão		:                    
Data/Hora   : 
Módulo      : Gestão de Contratos/Faturamento
*/

*--------------------*
User function GTCORP80
*--------------------*

if SUS->US_STATUS=="6"
	Empresas("SUS",SUS->(RECNO()),2)
else
	Empresas("SUS",SUS->(RECNO()),4)
endif

Return

/*
Funcao      : CarregaZ40
Parametros  : nOpc,cNum
Retorno     : 
Objetivos   : Função principal para o preenchimento das empresas vinculadas ao prospect
Autor       : Matheus Massarotto
Data/Hora   : 27/08/2013
*/ 
*--------------------------------------------*
Static Function Empresas( cAlias, nReg, nOpc )
*--------------------------------------------*
Local aArea        := GetArea()
Local aPosObj      := {}
Local aObjects     := {}
Local aSize        := MsAdvSize( .F. )
Local aGet         := {}
Local aTravas      := {}
Local aEntidade    := {}
Local aRecZ40      := {}
Local aChave       := {}

Local cCodEnt      := ""
Local cNomEnt      := ""
Local cUnico       := "" 

Local lGravou      := .F.
Local lTravas      := .T.
Local lAchou       := .F. 

Local nCntFor      := 0
Local nOpcA        := 0
Local nScan        := 0

Local oDlg
Local oGetD
Local oGet
Local oGet2

Private aCpoZ40		:= {}
Private aColsZ40	:= {}
Private	aHeaZ40		:= {}
Private aAlterDesp	:= {}
		

		/*Preenche o array com os campos que serão utilizados na Enchoice*/
		DbSelectArea("SX3")
		DbSetOrder(1)
		DbSeek("Z40")
		While SX3->(!EOF()) .AND. SX3->X3_ARQUIVO=="Z40"
			
			if X3Uso(SX3->X3_USADO) .AND. !(SX3->X3_CAMPO $ "Z40_FILIAL")
				AADD(aCpoZ40,alltrim(SX3->X3_CAMPO))
				AADD(aAlterDesp,alltrim(SX3->X3_CAMPO))
			endif
				
			SX3->(DbSkip())
		Enddo
        
        if nOpc==2
        	aAlterDesp:={}
        endif

		cNomEnt		:= SUS->US_COD
		cCodDesc	:= SUS->US_NOME
		nUsadoZ40	:= 0
		
		DbSelectArea("SX3")                                                                                                             
		SX3->(DbSetOrder(2)) // Campo                                                                                                   
		For nX := 1 to Len(aCpoZ40)                                                                                                     
			If SX3->(DbSeek(aCpoZ40[nX]))                                                                                                 
				nUsadoZ40++
			AADD(aHeaZ40,{ 	ALLTRIM(X3TITULO()), ;
							SX3->X3_CAMPO, ;
							SX3->X3_PICTURE, ;
							SX3->X3_TAMANHO, ;
							SX3->X3_DECIMAL, ;
							'ALLWAYSTRUE()', ;
							SX3->X3_USADO, ;
							SX3->X3_TIPO, ; 
							SX3->X3_F3, ;
							SX3->X3_CONTEXT, ;
							SX3->X3_CBOX, ;
							SX3->X3_RELACAO ;
							})
		
			Endif                                                                                                                         
		Next nX		
      

		INCLUI := .T.

		AAdd( aObjects, { 100,  44, .T., .F. } )
		AAdd( aObjects, { 100, 100, .T., .T. } )

		aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 2 }
		aPosObj := MsObjSize( aInfo, aObjects )

		DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] OF oMainWnd PIXEL

		@ 019,005 SAY "Prospect" SIZE 040,009 OF oDlg PIXEL // "Entidade"
		@ 018,050 GET oGet  VAR cNomEnt SIZE 120,009 OF oDlg PIXEL WHEN .F.

		@ 032,005 SAY "Nome" SIZE 040,009 OF oDlg PIXEL // "Identificacao"
		@ 031,050 GET oGet2 VAR cCodDesc SIZE 120,009 OF oDlg PIXEL WHEN .F.

		
		nOpc3        	:= GD_INSERT+GD_DELETE+GD_UPDATE
		cLinOkDesp      := "AllwaysTrue"    // Funcao executada para validar o contexto da linha atual do aCols                  
		cTudoOkDesp     := "AllwaysTrue"    // Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)      
		cICposDesp     	:= "+Z40_ITEM"       // Nome dos campos do tipo caracter que utilizarao incremento automatico.            
                                        // Este parametro deve ser no formato "+<nome do primeiro campo>+<nome do            
                                        // segundo campo>+..."                                                               
		nMaxZ40        	:= 99              // Numero maximo de linhas permitidas. Valor padrao 99    
		nFreeDesp      	:= 000              // Campos estaticos na GetDados.                                                               
		cFiOkDesp     	:= "U_VLD_GT40()"    // Funcao executada na validacao do campo                                           
		cSuDelDesp     	:= ""              	// Funcao executada quando pressionada as teclas <Ctrl>+<Delete>                    




		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Desabilita a delecao e adição de linha na visualizacao³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ        
		if nOpc==2
			cDelOkDesp      := "AllwaysFalse"   
		else
			cDelOkDesp      := "AllwaysTrue"
        endif

		aColsZ40	:= CarregaZ40(nOpc,aColsZ40,@nMaxZ40,nUsadoZ40,nReg,aHeaZ40)
        
		oGetDadEmp	:= MsNewGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc3,cLinOkDesp,cTudoOkDesp,cICposDesp,;                               
	                             aAlterDesp,nFreeDesp,nMaxZ40,cFiOkDesp,cSuDelDesp,cDelOkDesp,oDlg,aHeaZ40,aColsZ40)
	                             
		
		//oGetd:=MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4], nOpc,"FtContLOK","AlwaysTrue","+Z40_ITEM",.T.,NIL,NIL,NIL,500)			
		
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||GravaZ40(aHeaZ40,oGetDadEmp:aCols,oGetDadEmp),oDlg:End()},{||oDlg:End()})

RestArea( aArea )

Return(lGravou)


/*
Funcao      : CarregaZ40
Parametros  : nOpc,cNum
Retorno     : 
Objetivos   : Função para carregar os itens da tabela Z40
Autor       : Matheus Massarotto
Data/Hora   : 29/07/2013
*/                                                                 
*---------------------------------------------------------------*
Static Function CarregaZ40(nOpc,aColsZ40,nMaxZ40,nUsadoZ40,nReg,aHeaZ40)
*---------------------------------------------------------------*

	//Carrega as variáveis no aCols de acordo com a opção selecionada       
	If nOpc == 3
		AADD(aColsZ40,Array(nUsadoZ40+1))
		For nI := 1 To nUsadoZ40
			if Alltrim(aHeaZ40[nI,2]) == "Z40_ITEM"
				aColsZ40[len(aColsZ40)][nI] := "01"
			else
				aColsZ40[len(aColsZ40)][nI] := CriaVar(aHeaZ40[nI][2])
			endif
		Next
		aColsZ40[len(aColsZ40)][nUsadoZ40+1] := .F.
	Else

		cFilNum:= xFilial("Z40")+SUS->US_COD+SUS->US_LOJA
		
		aColsZ40:={}
		dbSelectArea("Z40")
		Z40->(dbSetOrder(1))
		Z40->(dbSeek(cFilNum))
		While Z40->(!EOF()) .AND. Z40->Z40_PROSPE==SUS->US_COD .AND. Z40->Z40_PLOJA==SUS->US_LOJA .AND. Z40->Z40_FILIAL==xFilial("Z40")
			AADD(aColsZ40,Array(nUsadoZ40+1))
				For nX:=1 to nUsadoZ40
					aColsZ40[Len(aColsZ40),nX]:=FieldGet(FieldPos(aHeaZ40[nX,2]))
				Next
			aColsZ40[Len(aColsZ40),nUsadoZ40+1]:=.F.
			Z40->(dbSkip())
		End
		
	EndIf                            
    
	if nOpc==2
	     nMaxZ40:=len(aColsZ40)
	endif

Return(aColsZ40)

/*
Funcao      : GravaZ40
Parametros  : 
Retorno     : 
Objetivos   : Função para gravar na tabela Z40
Autor       : Matheus Massarotto
Data/Hora   : 26/08/2013
*/ 
*----------------------------------------------------*
Static Function GravaZ40(aHeaZ40,aColsZ40,oGetDadEmp)
*----------------------------------------------------*
	nPosItem	:= Ascan(aHeaZ40,{|x| alltrim(x[2]) = "Z40_ITEM"})
	cProsp		:= SUS->US_COD
	cLoja		:= SUS->US_LOJA
   	
   	Begin Transaction
    	
    	if !empty(oGetDadEmp:Acols)
		    for nW:=1 to len(oGetDadEmp:Acols)
		    	//se tiver vazio
		    	if empty(oGetDadEmp:Acols[nW][2])
		    	   loop
		    	//se tiver deletado
		    	elseif oGetDadEmp:aCols[nW][len(oGetDadEmp:aCols[nW])]
  					if Z40->(DbSeek(xFilial("Z40")+cProsp+cLoja+oGetDadEmp:aCols[nW][nPosItem]))
			    		RecLock("Z40",.F.)
							Z40->(DbDelete())
						Z40->(MsUnlock())
					endif
		    	else
		    	    
  					if Z40->(DbSeek(xFilial("Z40")+cProsp+cLoja+oGetDadEmp:aCols[nW][nPosItem]))
		    	    	lInc:=.F.
		    		else
		    			lInc:=.T.
		    		endif
		    		
		    		RecLock("Z40",lInc)
			    		Z40->Z40_FILIAL	:= xFilial("Z40")
			    		Z40->Z40_PROSPE	:= cProsp
			    		Z40->Z40_PLOJA	:= cLoja
		    			for ny:=1 to len(aHeaZ40)
		    				Z40->&(aHeaZ40[ny][2]) := (aColsZ40[nW][nY])
		    			next
			    	Z40->(MsUnLock())

		    	endif
		    next
			
		endif
		
	End Transaction

Return

/*
Funcao      : ValidZ40
Parametros  : cCgc
Retorno     : 
Objetivos   : Função para validar o cnpj
Autor       : Matheus Massarotto
Data/Hora   : 26/08/2013
*/ 

*---------------------------*
User Function ValidZ40(cCgc)
*---------------------------*
Local lRet 	:= .T.
Local cMsg	:= ""

	if !CGC(cCgc)
		lRet:= .F.
	else
		aTMKEnti:=TBuscaCNPJ(cCgc)
        
    	if !empty(aTMKEnti)
            for i:=1 to len(aTMKEnti)
               	DbSelectArea("SX2")
               	SX2->(DbSetOrder(1))
               	if DbSeek(aTMKEnti[i][1])
            		cMsg+="Cadastro: "+X2NOME()+CRLF
            		cMsg+="Codigo: "+aTMKEnti[i][2]+CRLF
            		cMSg+="Loja: "+aTMKEnti[i][3]+CRLF+CRLF

               	endif
            next
    	endif
    	
    endif
    
    if !empty(cMsg)
	   	Aviso("Registos encontrados!",cMsg,{"Ok"})
    	lRet:= .F.
    endif

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TBuscaCNPJºAutor  ³Vendas Clientes     º Data ³  07/02/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna array com Entidade, Codigo e Loja                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - CNPJ a ser pesquisado                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Call Center                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*---------------------------------*
Static Function TBuscaCNPJ(cCnpj)
*---------------------------------* 
Local aSavArea := GetArea()
Local aAreaSX5 := SX5->(GetArea())
Local aAreaACH := ACH->(GetArea())
Local aAreaSA1 := SA1->(GetArea())
Local aAreaSA2 := SA2->(GetArea())
Local aAreaSA4 := SA4->(GetArea())
Local aAreaSUS := SUS->(GetArea())
Local aRet     := {}
Local aAlias   := {}
Local i	       := 0
Local cTipoVld	:= GetMv("MV_TMKCGC",,"1") //1=Valida CNPJ,2=Apenas Raiz do CNPJ
Local nLenCnpj	:= 0 

// Retira caracteres de picture caso existam 
cCnpj := STRTRAN(cCnpj,'.','')
cCnpj := STRTRAN(cCnpj,'/','')
cCnpj := STRTRAN(cCnpj,'-','')
cCnpj := AllTrim(cCnpj)

//Se o Cnpj nao foi informado, aborta a busca
If Empty(cCnpj)
	RestArea(aSavArea)
	Return aRet
EndIf

DbSelectArea("SX5")      
DbSetOrder(1)
If DbSeek(xFilial("SX5")+"T5") 
   While SX5->(!eof()) .and. Alltrim(SX5->X5_TABELA) == "T5"
         aAdd(aAlias,{Alltrim(SX5->X5_CHAVE)})            
         SX5->(DbSkip()) 
   EndDo
EndIf

aAdd(aAlias,{"Z40"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Controla quantos caracteres serao avaliados do CNPJ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTipoVld == "1"
	nLenCnpj := 14
Else
	nLenCnpj := 8
EndIf

cCnpj	:= SubStr(cCnpj,1,nLenCnpj)

For i := 1 to Len(aAlias) 

     Do Case

        /*
        Tabela AC4 Nao Possui CNPJ na Estrutura
        Tabela SU2 Nao Possui CNPJ na Estrutura
        */

        Case aAlias[i,1] == 'ACH'  // SUSPECTS 
             DbSelectArea('ACH') 
             DbSetOrder(2)
             If DbSeek(xFilial('ACH')+cCnpj)
                Do While ! Eof() .AND. ACH->ACH_FILIAL == xFilial('ACH') .AND. SubStr(ACH->ACH_CGC,1,nLenCNPJ) == ALLTRIM(cCnPj)
                   aAdd(aRet,{'ACH',ACH->ACH_CODIGO,ACH->ACH_LOJA})
                   ACH->(dbSkip())
                Enddo                                                     
             EndIf

        Case aAlias[i,1] == 'SA1'  // CLIENTES
             DbSelectArea('SA1') 
             DbSetOrder(3)
             If DbSeek(xFilial('SA1')+cCnpj) 
                Do While ! Eof() .and. SA1->A1_FILIAL == xFilial('SA1') .AND. SubStr(SA1->A1_CGC,1,nLenCNPJ) == ALLTRIM(cCnPj)
                   aAdd(aRet,{'SA1',SA1->A1_COD,SA1->A1_LOJA})
                   SA1->(dbSkip())
                Enddo   
             EndIf
        /*                                
        Case aAlias[i,1] == 'SA2'  // FORNECEDORES   
             DbSelectArea('SA2') 
             DbSetOrder(3)
             If DbSeek(xFilial('SA2')+cCnpj) 
                Do While ! Eof() .AND. SA2->A2_FILIAL == xFilial('SA2') .AND. SubStr(SA2->A2_CGC,1,nLenCNPJ) == ALLTRIM(cCnPj)
                   aAdd(aRet,{'SA2',SA2->A2_COD,SA2->A2_LOJA})
                   SA2->(dbSkip())
                Enddo   
             EndIf

        Case aAlias[i,1] == 'SA4'  // TRANSPORTADORA           
             DbSelectArea('SA4') 
             DbSetOrder(3)
             If DbSeek(xFilial('SA4')+cCnpj) 
                Do While ! Eof() .AND. SA4->A4_FILIAL == xFilial('SA4') .AND. SubStr(SA4->A4_CGC,1,nLenCNPJ) == ALLTRIM(cCnPj)
                   aAdd(aRet,{'SA4',SA4->A4_COD,''})
                   SA4->(dbSkip())
                Enddo   
             EndIf
        */
        Case aAlias[i,1] == 'SUS'  // PROSPECTS
             DbSelectArea('SUS') 
             DbSetOrder(4)
             If DbSeek(xFilial('SUS')+cCnpj) 
                Do While ! Eof() .AND. SUS->US_FILIAL == xFilial('SUS') .AND. SubStr(SUS->US_CGC,1,nLenCNPJ) == ALLTRIM(cCnPj)
                   aAdd(aRet,{'SUS',SUS->US_COD,SUS->US_LOJA})
                   SUS->(dbSkip())
                Enddo   
             EndIf
        Case aAlias[i,1] == 'Z40'  // Empresas
             DbSelectArea('Z40') 
             DbSetOrder(2)
             If DbSeek(xFilial('Z40')+cCnpj) 
                Do While ! Eof() .AND. Z40->Z40_FILIAL == xFilial('Z40') .AND. SubStr(Z40->Z40_CGC,1,nLenCNPJ) == ALLTRIM(cCnPj)
                   aAdd(aRet,{'Z40',Z40->Z40_PROSPE,Z40->Z40_PLOJA})
                   Z40->(dbSkip())
                Enddo   
             EndIf

        EndCase        

Next      

RestArea(aAreaSX5)
RestArea(aAreaACH)
RestArea(aAreaSA1)
RestArea(aAreaSA2)
RestArea(aAreaSA4)
RestArea(aAreaSUS)
RestArea(aSavArea)

Return(aRet)


/*
Funcao      : VLD_GT40()  
Parametros  : 
Retorno     : .T. ou .F.
Objetivos   : Função para validação do aCols
Autor       : Matheus Massarotto
Data/Hora   : 27/08/2013
*/
*---------------------*
User Function VLD_GT40
*---------------------*
Local nPos	:= Ascan(aHeaZ40,{|x| alltrim(x[2]) = "Z40_CGC"})
Local lRet	:= .T.

for i:=1 to len(oGetDadEmp:aCols)
	if oGetDadEmp:nAt==i
		Loop
	endif
    
	if nPos==oGetDadEmp:oBrowse:ColPos
		if !empty(oGetDadEmp:aCols[i][nPos]) .AND. alltrim(oGetDadEmp:aCols[i][nPos])==alltrim(M->Z40_CGC) //oGetDados:aCols[oGetDados:nAt][nPos]
			alert("CNPJ já está inserido!")
			lRet:=.F.
		endif
	endif	
next

Return(lRet)