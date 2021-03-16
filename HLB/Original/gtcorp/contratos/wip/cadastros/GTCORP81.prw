#Include "Protheus.ch"

/*
Funcao      : GTCORP81
Parametros  : Nil
Retorno     : Nil
Objetivos   : Função que cria um grid para cadastro da unidade e km do clientes
Autor       : Matheus Massarotto
Data/Hora   : 27/08/2013    15:51
Revisão		:                    
Data/Hora   : 
Módulo      : Gestão de Contratos/Faturamento
*/

*--------------------------*
User function GTCORP81()
*--------------------------*

	CadKm("SA1",SA1->(RECNO()),4)

Return

/*
Funcao      : CadKm
Parametros  : nOpc,cNum
Retorno     : 
Objetivos   : Função principal para o preenchimento da unidade e km do clientes
Autor       : Matheus Massarotto
Data/Hora   : 27/08/2013
*/ 
*--------------------------------------------*
Static Function CadKm( cAlias, nReg, nOpc )
*--------------------------------------------*
Local aArea        := GetArea()
Local aPosObj      := {}
Local aObjects     := {}
Local aSize        := MsAdvSize( .F. )
Local aGet         := {}
Local aTravas      := {}
Local aEntidade    := {}
Local aRecZ38      := {}
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

Private aCpoZ38		:= {}
Private aColsZ38	:= {}
Private	aHeaZ38		:= {}
Private aAlterDesp	:= {}
		

		/*Preenche o array com os campos que serão utilizados na Enchoice*/
		DbSelectArea("SX3")
		DbSetOrder(1)
		DbSeek("Z38")
		While SX3->(!EOF()) .AND. SX3->X3_ARQUIVO=="Z38"
			
			if X3Uso(SX3->X3_USADO) .AND. !(SX3->X3_CAMPO $ "Z38_FILIAL")
				AADD(aCpoZ38,alltrim(SX3->X3_CAMPO))
				AADD(aAlterDesp,alltrim(SX3->X3_CAMPO))
			endif
				
			SX3->(DbSkip())
		Enddo
        
        if nOpc==2
        	aAlterDesp:={}
        endif

		cNomEnt		:= SA1->A1_COD
		cCodDesc	:= SA1->A1_NOME
		nUsadoZ38	:= 0
		
		DbSelectArea("SX3")                                                                                                             
		SX3->(DbSetOrder(2)) // Campo                                                                                                   
		For nX := 1 to Len(aCpoZ38)                                                                                                     
			If SX3->(DbSeek(aCpoZ38[nX]))                                                                                                 
				nUsadoZ38++
			AADD(aHeaZ38,{ 	ALLTRIM(X3TITULO()), ;
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

		@ 019,005 SAY "Cliente" SIZE 040,009 OF oDlg PIXEL // "Entidade"
		@ 018,050 GET oGet  VAR cNomEnt SIZE 120,009 OF oDlg PIXEL WHEN .F.

		@ 032,005 SAY "Nome" SIZE 040,009 OF oDlg PIXEL // "Identificacao"
		@ 031,050 GET oGet2 VAR cCodDesc SIZE 120,009 OF oDlg PIXEL WHEN .F.

		
		nOpc3        	:= GD_INSERT+GD_DELETE+GD_UPDATE
		cLinOkDesp      := "AllwaysTrue"    // Funcao executada para validar o contexto da linha atual do aCols                  
		cTudoOkDesp     := "AllwaysTrue"    // Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)      
		cICposDesp     	:= "+Z38_ITEM"       // Nome dos campos do tipo caracter que utilizarao incremento automatico.            
                                        // Este parametro deve ser no formato "+<nome do primeiro campo>+<nome do            
                                        // segundo campo>+..."                                                               
		nMaxZ38        	:= 99              // Numero maximo de linhas permitidas. Valor padrao 99    
		nFreeDesp      	:= 000              // Campos estaticos na GetDados.                                                               
		cFiOkDesp     	:= "U_VLD_GT38()"    // Funcao executada na validacao do campo                                           
		cSuDelDesp     	:= ""              	// Funcao executada quando pressionada as teclas <Ctrl>+<Delete>                    




		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Desabilita a delecao e adição de linha na visualizacao³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ        
		if nOpc==2
			cDelOkDesp      := "AllwaysFalse"   
		else
			cDelOkDesp      := "AllwaysTrue"
        endif

		aColsZ38	:= CarregaZ38(nOpc,aColsZ38,@nMaxZ38,nUsadoZ38,nReg,aHeaZ38)
        
		oGetDadEmp	:= MsNewGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc3,cLinOkDesp,cTudoOkDesp,cICposDesp,;                               
	                             aAlterDesp,nFreeDesp,nMaxZ38,cFiOkDesp,cSuDelDesp,cDelOkDesp,oDlg,aHeaZ38,aColsZ38)
	                             
		
		//oGetd:=MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4], nOpc,"FtContLOK","AlwaysTrue","+Z38_ITEM",.T.,NIL,NIL,NIL,500)			
		
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||GravaZ38(aHeaZ38,oGetDadEmp:aCols,oGetDadEmp),oDlg:End()},{||oDlg:End()})

RestArea( aArea )

Return(lGravou)


/*
Funcao      : CarregaZ38
Parametros  : nOpc,cNum
Retorno     : 
Objetivos   : Função para carregar os itens da tabela Z38
Autor       : Matheus Massarotto
Data/Hora   : 29/07/2013
*/                                                                 
*-----------------------------------------------------------------------*
Static Function CarregaZ38(nOpc,aColsZ38,nMaxZ38,nUsadoZ38,nReg,aHeaZ38)
*-----------------------------------------------------------------------*

	//Carrega as variáveis no aCols de acordo com a opção selecionada       
	If nOpc == 3
		AADD(aColsZ38,Array(nUsadoZ38+1))
		For nI := 1 To nUsadoZ38
			if Alltrim(aHeaZ38[nI,2]) == "Z38_ITEM"
				aColsZ38[len(aColsZ38)][nI] := "01"
			else
				aColsZ38[len(aColsZ38)][nI] := CriaVar(aHeaZ38[nI][2])
			endif
		Next
		aColsZ38[len(aColsZ38)][nUsadoZ38+1] := .F.
	Else

		cFilNum:= xFilial("Z38")+SA1->A1_COD+SA1->A1_LOJA
		
		aColsZ38:={}
		dbSelectArea("Z38")
		Z38->(dbSetOrder(1))
		Z38->(dbSeek(cFilNum))
		While Z38->(!EOF()) .AND. Z38->Z38_CLIENT==SA1->A1_COD .AND. Z38->Z38_CLOJA==SA1->A1_LOJA .AND. Z38->Z38_FILIAL==xFilial("Z38")
			AADD(aColsZ38,Array(nUsadoZ38+1))
				For nX:=1 to nUsadoZ38
					aColsZ38[Len(aColsZ38),nX]:=FieldGet(FieldPos(aHeaZ38[nX,2]))
				Next
			aColsZ38[Len(aColsZ38),nUsadoZ38+1]:=.F.
			Z38->(dbSkip())
		End
		
	EndIf                            
    
	if nOpc==2
	     nMaxZ38:=len(aColsZ38)
	endif

Return(aColsZ38)

/*
Funcao      : GravaZ38
Parametros  : 
Retorno     : 
Objetivos   : Função para gravar na tabela Z38
Autor       : Matheus Massarotto
Data/Hora   : 26/08/2013
*/ 
*----------------------------------------------------*
Static Function GravaZ38(aHeaZ38,aColsZ38,oGetDadEmp)
*----------------------------------------------------*
	nPosItem	:= Ascan(aHeaZ38,{|x| alltrim(x[2]) = "Z38_ITEM"})
	cCli		:= SA1->A1_COD
	cLoja		:= SA1->A1_LOJA
   	
   	Begin Transaction
    	
    	if !empty(oGetDadEmp:Acols)
		    for nW:=1 to len(oGetDadEmp:Acols)
		    	//se tiver vazio
		    	if empty(oGetDadEmp:Acols[nW][2])
		    	   loop
		    	//se tiver deletado
		    	elseif oGetDadEmp:aCols[nW][len(oGetDadEmp:aCols[nW])]
  					if Z38->(DbSeek(xFilial("Z38")+cCli+cLoja+oGetDadEmp:aCols[nW][nPosItem]))
			    		RecLock("Z38",.F.)
							Z38->(DbDelete())
						Z38->(MsUnlock())
					endif
		    	else
		    	    
  					if Z38->(DbSeek(xFilial("Z38")+cCli+cLoja+oGetDadEmp:aCols[nW][nPosItem]))
		    	    	lInc:=.F.
		    		else
		    			lInc:=.T.
		    		endif
		    		
		    		RecLock("Z38",lInc)
			    		Z38->Z38_FILIAL	:= xFilial("Z38")
			    		Z38->Z38_CLIENT	:= cCli
			    		Z38->Z38_CLOJA	:= cLoja
		    			for ny:=1 to len(aHeaZ38)
		    				Z38->&(aHeaZ38[ny][2]) := (aColsZ38[nW][nY])
		    			next
			    	Z38->(MsUnLock())

		    	endif
		    next
			
		endif
		
	End Transaction

Return

/*
Funcao      : VLD_GT38()  
Parametros  : 
Retorno     : .T. ou .F.
Objetivos   : Função para validação do aCols
Autor       : Matheus Massarotto
Data/Hora   : 27/08/2013
*/
*---------------------*
User Function VLD_GT38
*---------------------*
Local nPos	:= Ascan(aHeaZ38,{|x| alltrim(x[2]) = "Z38_UNIDAD"})
Local lRet	:= .T.

for i:=1 to len(oGetDadEmp:aCols)
	if oGetDadEmp:nAt==i
		Loop
	endif
    
	if nPos==oGetDadEmp:oBrowse:ColPos
		if !empty(oGetDadEmp:aCols[i][nPos]) .AND. UPPER(alltrim(oGetDadEmp:aCols[i][nPos]))==UPPER(alltrim(M->Z38_UNIDAD)) //oGetDados:aCols[oGetDados:nAt][nPos]
			alert("Unidade já está inserida!")
			lRet:=.F.
		endif
	endif	
next

Return(lRet)