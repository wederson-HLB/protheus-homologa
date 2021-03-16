#Include "Protheus.ch"
#Include "TopConn.ch"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "TBICONN.ch"

/*
Funcao      : GTCORP57
Parametros  : Nil
Retorno     : Nil
Objetivos   : Função Mbrowse da tabela Z66, Cadastro de Alçada do controle de proposta
Autor       : Matheus Massarotto
Data/Hora   : 04/02/2013    14:28
Revisão		:                    
Data/Hora   : 
Módulo      : Gestão de Contratos
*/

*-----------------------*
User Function GTCORP57()
*-----------------------*
Local cString:="Z66"
Local lFilter:=.F.	//Define se deve ser filtrado a apresentação das propostas por usuário
Local cIdUser:=__cUserID // Id do usuário logado
Private aRotina:={}

if !TCCANOPEN("Z66"+cEmpAnt+"0")
	Alert("Rotina não disponível para esta empresa!"+CRLF+"Não existe a tabela Z66")
	Return()
endif
if !TCCANOPEN("Z65"+cEmpAnt+"0")
	Alert("Rotina não disponível para esta empresa!"+CRLF+"Não existe a tabela Z65")
	Return()
endif
  
AADD( aRotina, { "Pesquisar"		, "AxPesqui"  		, 0 , 1 } ) 
AADD( aRotina, { "Visualizar"		, 'U_GTCORP56("Z66",RECNO(),2)' 	, 0 , 2 } ) 
AADD( aRotina, { "Incluir"			, 'U_GTCORP56("Z66",RECNO(),3)' 	, 0 , 3 } ) 
AADD( aRotina, { "Alterar"			, 'U_GTCORP56("Z66",RECNO(),4)' 	, 0 , 4 } ) 
AADD( aRotina, { "Excluir"			, 'U_GTCORP56("Z66",RECNO(),5)' 	, 0 , 5 } )


If lFilter
	bCondicao := {|| Z79->Z79_USERRE = cIdUser }
	cCondicao := "Z79->Z79_USERRE = '"+cIdUser+"'"
	DbSelectArea(cString)

	DbSetFilter(bCondicao,cCondicao)
Else
	DbSelectArea(cString)
	
Endif


DbSetOrder(1)
MBrowse( 6,1,22,75,cString,,,,,,)
 
Return

/*
Funcao      : GTCORP56()
Parametros  : xParam1,xParam2,xParam3
Retorno     : .T.
Objetivos   : Montagem da tela para manutenção das informações da Tabela Z66 e Z65 (Enchoice e Getdados)
Autor       : Matheus Massarotto
Data/Hora   : 20/08/2012
*/
*----------------------------------------------*
User Function GTCORP56(xParam1,xParam2,xParam3) 
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
Local cIniCpos     	:= "+Z65_ITEM"       // Nome dos campos do tipo caracter que utilizarao incremento automatico.            
                                        // Este parametro deve ser no formato "+<nome do primeiro campo>+<nome do            
                                        // segundo campo>+..."                                                               
Local nFreeze      	:= 000              // Campos estaticos na GetDados.                                                               
Local nMax         	:= 99              // Numero maximo de linhas permitidas. Valor padrao 99                           
Local cFieldOk     	:= "U_VLD_GT57"    // Funcao executada na validacao do campo                                           
Local cSuperDel     := ""              	// Funcao executada quando pressionada as teclas <Ctrl>+<Delete>                    
Local cDelOk        := "AllwaysFalse"   	// Funcao executada para validar a exclusao de uma linha do aCols                   

Local aObjects      := {}
Local aPosObj       := {}
Local aSize         := {}        

Local nUsado:=0

Local cCadastro:="Cadastro de Alcada"

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
	DbSeek("Z66")
	While SX3->(!EOF()) .AND. SX3->X3_ARQUIVO=="Z66"
		
		if X3Uso(SX3->X3_USADO) .AND. !(SX3->X3_CAMPO $ "Z66_FILIAL")
			AADD(aCpoEnch,alltrim(SX3->X3_CAMPO))
			if nOpc==4
				if !(SX3->X3_CAMPO $ "Z66_IDUSER")
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
	DbSeek("Z65")
	While SX3->(!EOF()) .AND. SX3->X3_ARQUIVO=="Z65"
		
		if X3Uso(SX3->X3_USADO) .AND. !(SX3->X3_CAMPO $ "Z65_FILIAL/Z65_IDUSER/Z65_NOUSER") 
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

AAdd( aObjects, { 100, 60, .T., .T. } )
AAdd( aObjects, { 100, 40, .T., .T. } )

aInfo 	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T.)

aPosObjEnch		:= {aPosObj[1][1],aPosObj[1][2],aPosObj[1][3],aPosObj[1][4]-10}

			 					 
DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 To aSize[6],aSize[5] of oMainWnd PIXEL
//DEFINE MSDIALOG oDlg TITLE cCadastro From 0,0 To oMainWnd:nBottom-80,oMainWnd:nRight-70 of oMainWnd PIXEL
                                                 //530,850
                                                 //+100,+400

	//------>>>> Cria a Folder
	aTFolder := { 'Cadastro'}
	oTFolder := TFolder():New( 2,2,aTFolder,,oDlg,,,,.T.,,623,300 )
	//------>>>> Fim do criar folder

	// <-> FOLDER 1
	//Carrega as variáveris da tabela Z79
	RegToMemory(cAliasE,If(nOpc == 3,.T.,.F.), .T.)

	                                                                   //aPos
	Enchoice(cAliasE,nReg,nOpc2,/*aCRA*/,/*cLetra*/,/*cTexto*/,aCpoEnch,aPosObjEnch,;
			aAlterEnch,nModelo,/*nColMens*/,/*cMensagem*/,/*cTudoOk*/,oTFolder:aDialogs[1],lF3,;    
			lMemoria,lColumn,caTela,lNoFolder,lProperty)                    

	
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
			if Alltrim(aHeader[nI,2]) == "Z65_ITEM"
				aCols[len(aCols)][nI] := "01"
			else
				aCols[len(aCols)][nI] := CriaVar(aHeader[nI][2])
			endif
		Next
		aCols[len(aCols)][nUsado+1] := .F.
	Else
	
		DbSelectArea("Z66")
		Z66->(DbGoTo(nReg))
		cFilUser:= Z66->Z66_FILIAL+Z66->Z66_IDUSER
		
		aCols:={}
		dbSelectArea("Z65")
		dbSetOrder(1)
		dbSeek(cFilUser)
		While !eof() .AND. Z65->Z65_FILIAL+Z65->Z65_IDUSER==cFilUser
			AADD(aCols,Array(nUsado+1))
				For nX:=1 to nUsado
					aCols[Len(aCols),nX]:=FieldGet(FieldPos(aHeader[nX,2]))
				Next
			aCols[Len(aCols),nUsado+1]:=.F.
			Z65->(dbSkip())
		End
		
		
	EndIf                            
	
		//oGetDados:= MsNewGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3]-10,aPosObj[2,4],nOpc1,cLinOk,cTudoOk,cIniCpos,;                               
		//                             aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oTFolder:aDialogs[1],aHeader,aCols)

		oGetDados:= MsNewGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3]-10,aPosObj[2,4],nOpc1,cLinOk,cTudoOk,cIniCpos,;                               
		                             aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oTFolder:aDialogs[1],aHeader,aCols)

	    oGetDados :ForceRefresh()              
	    
	
	oTFolder:Align := CONTROL_ALIGN_ALLCLIENT
	// <-> FIM FOLDER 1

  
ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg,{||iif(Grava(aHeader,oGetDados:aCols,aCpoEnch,nOpc,aAlterEnch),oDlg:End(),)},{||oDlg:End()},,aButtons))CENTERED

Return(.T.)



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
	nPosGetDep:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z65_IDDEPE"})
	nPosGetNom:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z65_NODEPE"})

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

	
	BEGIN TRANSACTION	
		//Gravando ENCHOICE
		RecLock("Z66",iif(nOpc==3,.T.,.F.)) 
			Z66->Z66_FILIAL	:= xFilial("Z66")

			for nx:=1 to len(aCpoEnch)-1
    			Z66->&(aCpoEnch[nx]) := M->&(aCpoEnch[nx])
			next 

	    Z66->(MSUNLOCK())
	    
	    //GRAVANDO GETDADOS
			for i:=1 to len(oGetDados:aCols)
		    	if !empty(oGetDados:aCols[i][2]) //Grava somente se o dependente estiver preenchido
			    	RecLock("Z65",.T.)
			    		Z65->Z65_FILIAL	:= xFilial("Z78")
	   					Z65->Z65_IDUSER	:= M->Z66_IDUSER
			    		Z65->Z65_NOUSER	:= M->Z66_NOUSER
			    		for j:=1 to len(aHeader)
			    			Z65->&(aHeader[j][2]):=oGetDados:aCols[i][j]
			    		next
			    	MsUnlock()
		    	endif
		    next

	END TRANSACTION

elseif nOpc==4 //Alterar

	nPosGetDep:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z65_IDDEPE"})
	nPosGetIte:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z65_ITEM"})
	nPosGetNom:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z65_NODEPE"})


	/*Validação do preenchimento da GetDados*/

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
	
	//Gravando ENCHOICE
	RecLock("Z66",iif(nOpc==3,.T.,.F.)) 
		for nx:=1 to len(aAlterEnch)
    		Z66->&(aAlterEnch[nx]) := M->&(aAlterEnch[nx])
    	next
    Z66->(MSUNLOCK())
    
	//Gravando getdados
	DbSelectArea("Z65")
	Z65->(DbSetOrder(2))
	for i:=1 to len(oGetDados:aCols)
		Z65->(DbGotop())
		
		//Se tiver deletado
		if oGetDados:aCols[i][len(oGetDados:aCols[i])]
			if Z65->(DbSeek(xFilial("Z65")+oGetDados:aCols[i][nPosGetIte]+M->Z66_IDUSER))
				Z65->(DbDelete())
			endif
		else
			
			if Z65->(DbSeek(xFilial("Z65")+oGetDados:aCols[i][nPosGetIte]+M->Z66_IDUSER)) //Se ja existe o item inserido
				RecLock("Z65",.F.)
		    		for j:=1 to len(aHeader)
		    			Z65->&(aHeader[j][2]):=oGetDados:aCols[i][j]
		    		next
				Z65->(MsUnlock())
			else
			   	if !empty(oGetDados:aCols[i][2]) //Somente se dependente estiver preenchido
				   	RecLock("Z65",.T.)
			    		Z65->Z65_FILIAL	:= xFilial("Z78")
			   			Z65->Z65_IDUSER	:= M->Z66_IDUSER
			    		Z65->Z65_NOUSER	:= M->Z66_NOUSER
			    		for j:=1 to len(aHeader)
			    			Z65->&(aHeader[j][2]):=oGetDados:aCols[i][j]
			    		next
			    	MsUnlock()
				endif		    	
			endif
			
		endif		
		
	next
	
elseif nOpc==5 //Excluir	
	
	if !MsgYesNo("Deseja realmente exlcuir usuário e seu(s) dependente(s)?")
		Return .F.	
	endif

	nPosGetIte:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z65_ITEM"})
	
	//Deletando Enchoice
	RecLock("Z66",.F.)
		Z66->(DbDelete())
	Z66->(MsUnlock())
	
	//Deletando getdados
	DbSelectArea("Z65")
	Z65->(DbSetOrder(2))
	for i:=1 to len(oGetDados:aCols)
		if Z65->(DbSeek(xFilial("Z65")+oGetDados:aCols[i][nPosGetIte]+M->Z66_IDUSER)) //Posiciona no item da tabela Z65
			Reclock("Z65",.F.)
				Z65->(DbDelete())
			Z65->(MsUnlock())		 	
		endif
	next	

endif

Return(.T.)

/*
Funcao      : VLD_GT57()  
Parametros  : 
Retorno     : .T. ou .F.
Objetivos   : Função para validação do aCols
Autor       : Matheus Massarotto
Data/Hora   : 05/02/2012
*/
*---------------------*
User Function VLD_GT57
*---------------------*
Local nPos	:= Ascan(aHeader,{|x| alltrim(x[2]) = "Z65_IDDEP"})
Local lRet	:= .T.

for i:=1 to len(oGetDados:aCols)
	if oGetDados:nAt==i
		Loop
	endif

	if alltrim(oGetDados:aCols[i][nPos])==alltrim(M->Z65_IDDEPE) //oGetDados:aCols[oGetDados:nAt][nPos]
		alert("Dependente já está inserido!")
		lRet:=.F.
	endif
	
next

Return(lRet)

/*
Funcao      : VLD_Z66()
Parametros  : 
Retorno     : .T.
Objetivos   : Função para não deixar preencher aprovador e responsável ao mesmo tempo.
Autor       : Matheus Massarotto
Data/Hora   : 05/02/2012
*/

*---------------------*
User Function VLD_Z66(cCampo)
*---------------------*
Local lRet	:= .T.


if cCampo == "Z66_LAPROV"

	if M->Z66_LRESPO
		M->Z66_LRESPO:=.F.
	endif
elseif cCampo == "Z66_LRESPO"

	if M->Z66_LAPROV
		M->Z66_LAPROV:=.F.
	endif
endif

Return(lRet)