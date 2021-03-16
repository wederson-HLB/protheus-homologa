#include "Protheus.ch"

/*
Funcao      : GTCORP61
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Mbrowse da tabela Z93(Empresas Indicadoras)
Autor       : Matheus Massarotto
Revisão		:
Data/Hora   : 15/03/2012    15:54
Módulo      : Gestão de Contratos
*/

User Function GTCORP61    
Local cString:="Z93"
Local cIdUser:=__cUserID // Id do usuário logado
Private aRotina:={}

if !cEmpAnt $ "Z4/ZF/ZB"
	Alert("Rotina não disponível para esta empresa!")
	Return()
endif

if !TCCANOPEN("Z93"+cEmpAnt+"0")
	Alert("Rotina não disponível para esta empresa!"+CRLF+"Não existe a tabela Z93")
	Return()
endif
if !TCCANOPEN("Z92"+cEmpAnt+"0")
	Alert("Rotina não disponível para esta empresa!"+CRLF+"Não existe a tabela Z92")
	Return()
endif
  
AADD( aRotina, { "Pesquisar"		, "AxPesqui"  		, 0 , 1 } ) 
AADD( aRotina, { "Visualizar"		, 'U_GTCORP60("Z93",RECNO(),2)' 	, 0 , 2 } ) 
AADD( aRotina, { "Incluir"			, 'U_GTCORP60("Z93",RECNO(),3)' 	, 0 , 3 } ) 
AADD( aRotina, { "Alterar"			, 'U_GTCORP60("Z93",RECNO(),4)' 	, 0 , 4 } ) 
AADD( aRotina, { "Excluir"			, 'U_GTCORP60("Z93",RECNO(),5)' 	, 0 , 5 } )

DbSetOrder(1)
MBrowse( 6,1,22,75,cString,,,,,,)


Return

/*
Funcao      : GTCORP60()
Parametros  : xParam1,xParam2,xParam3
Retorno     : .T.
Objetivos   : Montagem da tela para manutenção das informações da Tabela Z66 e Z92 (Enchoice e Getdados)
Autor       : Matheus Massarotto
Data/Hora   : 20/08/2012
*/
*----------------------------------------------*
User Function GTCORP60(xParam1,xParam2,xParam3) 
*----------------------------------------------*
Local cAliasE := xParam1           // Tabela cadastrada no Dicionario de Tabelas (SX2) que sera editada
// Vetor com nome dos campos que serao exibidos. Os campos de usuario sempre serao              
// exibidos se nao existir no parametro um elemento com a expressao "NOUSER"                    
Local aCpoEnch  	:= {}
Local aAlterEnch	:= {}
Local aCpoEnch2		:= {}
Local aAlterEn2		:= {}
Local nOpc    		:= nOpc2:= xParam3 	// Numero da linha do aRotina que definira o tipo de edicao (Inclusao, Alteracao, Exclucao, Visualizacao)
Local nReg    		:= xParam2	// Numero do Registro a ser Editado/Visualizado (Em caso de Alteracao/Visualizacao)
// Vetor com coordenadas para criacao da enchoice no formato {<top>, <left>, <bottom>, <right>} 
Local aPos		  	:= {012,002,161,620}//{012,002,161,422}
Local nModelo		:= 3     	// Se for diferente de 1 desabilita execucao de gatilhos estrangeiros                           
Local lF3 		  	:= .F.		// Indica se a enchoice esta sendo criada em uma consulta F3 para utilizar variaveis de memoria 
Local lMemoria 		:= .T.		// Indica se a enchoice utilizara variaveis de memoria ou os campos da tabela na edicao         
Local lColumn		:= .F.		// Indica se a apresentacao dos campos sera em forma de coluna                                  
Local caTela 		:= "" 		// Nome da variavel tipo "private" que a enchoice utilizara no lugar da propriedade aTela       
Local lNoFolder		:= .T.		// Indica se a enchoice nao ira utilizar as Pastas de Cadastro (SXA)                            
Local lProperty		:= .F.		// Indica se a enchoice nao utilizara as variaveis aTela e aGets, somente suas propriedades com os mesmos nomes
                                                                                                                                             
Local nX			:= 0                                                                                                              
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis da MsNewGetDados()      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Vetor responsavel pela montagem da aHeader
Local aCpoGDa       := {}
// Vetor com os campos que poderao ser alterados                                                                                
Local aAlter     	:= {""}
Local nSuperior    	:= 165 //165       	// Distancia entre a MsNewGetDados e o extremidade superior do objeto que a contem
Local nEsquerda    	:= 002 //002       	// Distancia entre a MsNewGetDados e o extremidade esquerda do objeto que a contem
Local nInferior    	:= 253 //253       	// Distancia entre a MsNewGetDados e o extremidade inferior do objeto que a contem
Local nDireita     	:= 620 //422       	// Distancia entre a MsNewGetDados e o extremidade direita  do objeto que a contem
// Posicao do elemento do vetor aRotina que a MsNewGetDados usara como referencia  
Local nOpc1        	:= GD_INSERT+GD_DELETE+GD_UPDATE                                                                            
Local cLinOk       	:= "AllwaysTrue"    // Funcao executada para validar o contexto da linha atual do aCols                  
Local cTudoOk      	:= "AllwaysTrue"    // Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)      
Local cIniCpos     	:= "+Z92_ITEM"      // Nome dos campos do tipo caracter que utilizarao incremento automatico.            
                                        // Este parametro deve ser no formato "+<nome do primeiro campo>+<nome do            
                                        // segundo campo>+..."                                                               
Local nFreeze      	:= 000              // Campos estaticos na GetDados.                                                               
Local nMax         	:= 99               // Numero maximo de linhas permitidas. Valor padrao 99                           
Local cFieldOk     	:= "U_VLD_GT61"     // Funcao executada na validacao do campo                                           
Local cSuperDel     := ""              	// Funcao executada quando pressionada as teclas <Ctrl>+<Delete>                    
Local cDelOk        := "AllwaysTrue"   // Funcao executada para validar a exclusao de uma linha do aCols                   

Local aObjects      := {}
Local aPosObj       := {}
Local aSize         := {}        

Local nUsado:=0

Local cCadastro:="Cadastro de Indicadores"

Local cAno:="" //Ano que se deseja alterar

// Variáveis utilizadas na seleção de categorias
Local oChkQual,lQual,oQual,cVarQ
Local oQual1,cVarQ1
// Carrega bitmaps
Local oOk := LoadBitmap( GetResources(), "LBOK")
Local oNo := LoadBitmap( GetResources(), "LBNO")

// Objeto no qual a MsNewGetDados sera criada                                      
Private aHeader     := {}               // Array a ser tratado internamente na MsNewGetDados como aHeader                    
Private aCols       := {}               // Array a ser tratado internamente na MsNewGetDados como aCols

// Variaveis Private da Funcao
Private oDlg				// Dialog Principal
// Variaveis que definem a Acao do Formulario
Private VISUAL := .F.                        
Private INCLUI := .F.                        
Private ALTERA := .F.                        
Private DELETA := .F.                        
// Privates das NewGetDados
Private oGetDados

Private aTELA[0][0] // Variáveis que serão atualizadas pela Enchoice()
Private aGETS[0] // e utilizadas pela função OBRIGATORIO()

Private cFilUser:=""

Private aButtons:={}

Private oGroup
Private cTexto:="0"
Private oTexto,oSlider,oMemo
Private cMemo := space(200)

SET DATE FORMAT "dd/mm/yyyy"


	/*Preenche o array com os campos que serão utilizados na Enchoice*/
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("Z93")
	While SX3->(!EOF()) .AND. SX3->X3_ARQUIVO=="Z93"
		
		if X3Uso(SX3->X3_USADO) .AND. !(SX3->X3_CAMPO $ "Z93_FILIAL")
			AADD(aCpoEnch,alltrim(SX3->X3_CAMPO))
			if nOpc==4

				if !alltrim(SX3->X3_CAMPO) $ ("Z93_CODIGO/Z93_LOJA/Z93_CGC")
					AADD(aAlterEnch,alltrim(SX3->X3_CAMPO))
				endif
			else
				AADD(aAlterEnch,alltrim(SX3->X3_CAMPO))
			endif
		endif
			
		SX3->(DbSkip())
	Enddo

	AADD(aCpoEnch,"NOUSER")

	/*Preenche o array com os campos que serão utilizados no aHeader*/
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("Z92")
	While SX3->(!EOF()) .AND. SX3->X3_ARQUIVO=="Z92"
		
		if X3Uso(SX3->X3_USADO) .AND. !(SX3->X3_CAMPO $ "Z92_FILIAL/Z92_CODEMP/Z92_NOMEMP/Z92_CGCEMP")
			AADD(aCpoGDa,alltrim(SX3->X3_CAMPO))
			AADD(aAlter,alltrim(SX3->X3_CAMPO))		
		endif
			
		SX3->(DbSkip())
	Enddo

Do Case
	Case xParam3 == 2
		VISUAL := .T.     
	Case xParam3 == 3
		INCLUI := .T. 
		//aAlter := {} 
		//aAlterEnch	:= {}
	Case xParam3 == 4 
		ALTERA := .T.

	Case xParam3 == 5
		DELETA := .T.
		aAlterEnch	:= {}
		nOpc2:=4
		nOpc1:=GD_DELETE
EndCase    


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz o calculo automatico de dimensoes de objetos     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize := MsAdvSize()
/*
AAdd( aObjects, { 100, 60, .T., .T. } )
AAdd( aObjects, { 100, 40, .T., .T. } )

aInfo 	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T.)
*/

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta a Tela Principal										 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aObjects := {}
		aAdd( aObjects, {   0, 119, .t., .t. } )
		aAdd( aObjects, { 120, 101, .t., .t. } )
		aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
		aPosObj := MsObjSize( aInfo, aObjects )
		
aPosObjEnch		:= {aPosObj[1][1],aPosObj[1][2],aPosObj[1][3],aPosObj[1][4]-10}


			 					 
DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 To aSize[6],aSize[5] of oMainWnd PIXEL
//DEFINE MSDIALOG oDlg TITLE cCadastro From 0,0 To oMainWnd:nBottom-80,oMainWnd:nRight-70 of oMainWnd PIXEL
                                                 //530,850
                                                 //+100,+400


	//Carrega as variáveris da tabela Z79
	RegToMemory(cAliasE,If(nOpc == 3,.T.,.F.), .T.)

	//------>>>> Cria a Folder

	//oTFolder := TFolder():New( 2,2,aTFolder,,oDlg,,,,.T.,,623,300 )
	oTFolder := TFolder():New(aPosObj[1,1],aPosObj[1,2],{"Empresa"},,oDlg,,,,.T.,.F.,aPosObj[1,4]-aPosObj[1,2],aPosObj[1,3]-aPosObj[1,1])
	//------>>>> Fim do criar folder

	                                                                   //aPos
	Enchoice(cAliasE,nReg,nOpc2,/*aCRA*/,/*cLetra*/,/*cTexto*/,aCpoEnch,aPosObj[1],;
			aAlterEnch,nModelo,/*nColMens*/,/*cMensagem*/,/*cTudoOk*/,oTFolder:aDialogs[1],lF3,;    
			lMemoria,lColumn,caTela,lNoFolder,lProperty)                    


	//------>>>> Cria a Folder

	oTFolder2 := TFolder():New(aPosObj[2,1]+15,aPosObj[2,2],{"Indicadores"},,oDlg,,,,.T.,.F.,aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1]-15)
	//------>>>> Fim do criar folder
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define as posicoes da Getdados a partir do folder    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nGd1 := 2
	nGd2 := 2
	nGd3 := aPosObj[2,3]-aPosObj[2,1]-15
	nGd4 := aPosObj[2,4]-aPosObj[2,2]-2

	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega o aHeader										 			³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SX3")                                                                                                             
	SX3->(DbSetOrder(2)) // Campo                                                                                                   
	For nX := 1 to Len(aCpoGDa)                                                                                                     
		If SX3->(DbSeek(aCpoGDa[nX]))                                                                                                 
			nUsado++
		AADD(aHeader,{ 	ALLTRIM(X3TITULO()), ;
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
	
	//Carrega as variáveis no aCols de acordo com a opção selecionada       
	If nOpc == 3
		AADD(aCols,Array(nUsado+1))
		For nI := 1 To nUsado
			if Alltrim(aHeader[nI,2]) == "Z92_ITEM"
				aCols[len(aCols)][nI] := "01"
			else
				aCols[len(aCols)][nI] := CriaVar(aHeader[nI][2])
			endif
		Next
		aCols[len(aCols)][nUsado+1] := .F.
	Else
	
		DbSelectArea("Z93")
		Z93->(DbGoTo(nReg))
		cFilUser:= Z93->Z93_FILIAL+Z93->Z93_CODIGO
		
		aCols:={}
		dbSelectArea("Z92")
		dbSetOrder(1)
		dbSeek(cFilUser)
		While !eof() .AND. Z92->Z92_FILIAL+Z92->Z92_CODEMP==cFilUser
			AADD(aCols,Array(nUsado+1))
				For nX:=1 to nUsado
					aCols[Len(aCols),nX]:=FieldGet(FieldPos(aHeader[nX,2]))
				Next
			aCols[Len(aCols),nUsado+1]:=.F.
			Z92->(dbSkip())
		End
		
		
	EndIf                            
	
		//oGetDados:= MsNewGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3]-10,aPosObj[2,4],nOpc1,cLinOk,cTudoOk,cIniCpos,;                               
		//                             aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oTFolder:aDialogs[1],aHeader,aCols)

		oGetDados:= MsNewGetDados():New(nGd1,nGd2,nGd3-13,nGd4,nOpc1,cLinOk,cTudoOk,cIniCpos,;                               
		                             aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oTFolder2:aDialogs[1],aHeader,aCols)

	    oGetDados :ForceRefresh()              
	    
	
	oTFolder:Align := CONTROL_ALIGN_ALLCLIENT

  
ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg,{||iif(Grava(aHeader,oGetDados:aCols,aCpoEnch,nOpc,aAlterEnch),oDlg:End(),)},{||ROLLBACKSX8(),oDlg:End()},,aButtons))//CENTERED

Return(.T.)


/*
Funcao      : VLD_GT61()  
Parametros  : 
Retorno     : .T. ou .F.
Objetivos   : Função para validação do aCols
Autor       : Matheus Massarotto
Data/Hora   : 05/02/2012
*/
*---------------------*
User Function VLD_GT61
*---------------------*
Local nPos	:= Ascan(aHeader,{|x| alltrim(x[2]) = "Z92_NOME"})
Local lRet	:= .T.

if alltrim(aHeader[oGetDados:oBrowse:ColPos][2])=="Z92_NOME"

	for i:=1 to len(oGetDados:aCols)
		if oGetDados:nAt==i
			Loop
		endif
	
		if UPPER(alltrim(oGetDados:aCols[i][nPos]))==UPPER(alltrim(M->Z92_NOME)) //oGetDados:aCols[oGetDados:nAt][nPos]
			alert("Indicador já está inserido!")
			lRet:=.F.
		endif
		
	next

endif

Return(lRet)



/*
Funcao      : Grava()  
Parametros  : Header,aCols,cAno,nOpc,aAlterEnch
Retorno     : .T. ou .F.
Objetivos   : Função para gravação/alteração/deleção
Autor       : Matheus Massarotto
Data/Hora   : 04/02/2012
*/
*------------------------------------------------------------*
Static Function Grava(aHeader,aCols,aCpoEnch,nOpc,aAlterEnch)
*------------------------------------------------------------*
Local nPosGetIte:= ""
Local nPosGetDep:= ""
Local nPosGetNom:= ""

if nOpc==3 //Incluir

	/*Valida o cabecalho*/
	if !Obrigatorio(aGets,aTela) 
		Return .F.
	endif
    
	/*Validação do preenchimento da GetDados*/
/*	nPosGetDep:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z92_IDDEPE"})
	nPosGetNom:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z92_NODEPE"})

 	for h:=1 to len(oGetDados:aCols)

    	if nPosGetDep>0
			if M->Z66_LRESPO
	    		if empty(oGetDados:aCols[h][nPosGetDep])
		    		Alert("É necessário informar o(s) dependente(s), quando usuário está marcado como responsável!")
		    		Return .F.
					Exit
				endif
			endif
			if M->Z66_LAPROV
	    		if empty(oGetDados:aCols[h][nPosGetDep])
		    		Alert("É necessário informar o(s) dependente(s), quando usuário está marcado como aprovador!")
		    		Return .F.
					Exit
				endif
			endif
		endif

    next
*/
	
	BEGIN TRANSACTION	
		//Gravando ENCHOICE
		RecLock("Z93",iif(nOpc==3,.T.,.F.)) 
			Z93->Z93_FILIAL	:= xFilial("Z93")

			for nx:=1 to len(aCpoEnch)-1
    			Z93->&(aCpoEnch[nx]) := M->&(aCpoEnch[nx])
			next 

	    Z93->(MSUNLOCK())
	    
	    //GRAVANDO GETDADOS
			for i:=1 to len(oGetDados:aCols)
		    	if !empty(oGetDados:aCols[i][2]) //Grava somente se o dependente estiver preenchido
			    	RecLock("Z92",.T.)
			    		Z92->Z92_FILIAL	:= xFilial("Z78")
	   					Z92->Z92_CODEMP	:= M->Z93_CODIGO
	   					Z92->Z92_NOMEMP	:= M->Z93_RAZAO
	   					Z92->Z92_CGCEMP	:= M->Z93_CGC
			    		for j:=1 to len(aHeader)
			    			Z92->&(aHeader[j][2]):=oGetDados:aCols[i][j]
			    		next
			    	MsUnlock()
		    	endif
		    next

	END TRANSACTION
	
	Z93->(CONFIRMSX8())

elseif nOpc==4 //Alterar


	nPosGetIte:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z92_ITEM"})

	/*Validação do preenchimento da GetDados*/
/*
 	for h:=1 to len(oGetDados:aCols)

    	if nPosGetDep>0
			if M->Z93_LRESPO
	    		if empty(oGetDados:aCols[h][nPosGetDep])
		    		Alert("É necessário informar o(s) dependente(s), quando usuário está marcado como responsável!")
		    		Return .F.
					Exit
				endif
			endif
			if M->Z93_LAPROV
	    		if empty(oGetDados:aCols[h][nPosGetDep])
		    		Alert("É necessário informar o(s) dependente(s), quando usuário está marcado como aprovador!")
		    		Return .F.
					Exit
				endif
			endif
		endif

    next
*/	
	//Gravando ENCHOICE
	RecLock("Z93",iif(nOpc==3,.T.,.F.)) 
		for nx:=1 to len(aAlterEnch)
    		Z93->&(aAlterEnch[nx]) := M->&(aAlterEnch[nx])
    	next
    Z93->(MSUNLOCK())
    
	//Gravando getdados
	DbSelectArea("Z92")
	Z92->(DbSetOrder(2))
	for i:=1 to len(oGetDados:aCols)
		Z92->(DbGotop())
		
		//Se tiver deletado
		if oGetDados:aCols[i][len(oGetDados:aCols[i])]
			if Z92->(DbSeek(xFilial("Z92")+oGetDados:aCols[i][nPosGetIte]+M->Z93_CODIGO))
				RecLock("Z92",.F.)
					Z92->(DbDelete())
				Z92->(MsUnlock())
			endif
		else
			
			if Z92->(DbSeek(xFilial("Z92")+oGetDados:aCols[i][nPosGetIte]+M->Z93_CODIGO)) //Se ja existe o item inserido
				RecLock("Z92",.F.)
		    		for j:=1 to len(aHeader)
		    			Z92->&(aHeader[j][2]):=oGetDados:aCols[i][j]
		    		next
				Z92->(MsUnlock())
			else
			   	if !empty(oGetDados:aCols[i][2]) //Somente se nome estiver preenchido
				   	RecLock("Z92",.T.)
			    		Z92->Z92_FILIAL	:= xFilial("Z78")
			   			Z92->Z92_CODEMP	:= M->Z93_CODIGO
	   					Z92->Z92_NOMEMP	:= M->Z93_RAZAO
	   					Z92->Z92_CGCEMP	:= M->Z93_CGC
			    		for j:=1 to len(aHeader)
			    			Z92->&(aHeader[j][2]):=oGetDados:aCols[i][j]
			    		next
			    	MsUnlock()
				endif		    	
			endif
			
		endif		
		
	next
	
elseif nOpc==5 //Excluir	
	
	if !MsgYesNo("Deseja realmente exlcuir a empresa e seu(s) indicadores(s)?")
		Return .F.	
	endif

	nPosGetIte:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z92_ITEM"})
	
	//Deletando Enchoice
	RecLock("Z93",.F.)
		Z93->(DbDelete())
	Z93->(MsUnlock())
	
	//Deletando getdados
	DbSelectArea("Z92")
	Z92->(DbSetOrder(2))
	for i:=1 to len(oGetDados:aCols)
		if Z92->(DbSeek(xFilial("Z92")+oGetDados:aCols[i][nPosGetIte]+M->Z93_CODIGO)) //Posiciona no item da tabela Z92
			Reclock("Z92",.F.)
				Z92->(DbDelete())
			Z92->(MsUnlock())		 	
		endif
	next	

endif

Return(.T.)