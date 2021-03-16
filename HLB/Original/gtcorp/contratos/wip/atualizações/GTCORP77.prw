#Include "Protheus.ch"
#Include "TopConn.ch"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "TBICONN.ch"

/*
Funcao      : GTCORP77
Parametros  : Nil
Retorno     : Nil
Objetivos   : Função Mbrowse da tabela Z47, Cadastro de Alçada do controle de proposta
Autor       : Matheus Massarotto
Data/Hora   : 04/02/2013    14:28
Revisão		:                    
Data/Hora   : 
Módulo      : Gestão de Contratos
*/

*-----------------------*
User Function GTCORP77()
*-----------------------*
Local cString:="Z47"
Local lFilter:=.F.	//Define se deve ser filtrado a apresentação das propostas por usuário
Local cIdUser:=__cUserID // Id do usuário logado
Private aRotina:={}
/*
if !TCCANOPEN("Z47"+cEmpAnt+"0")
	Alert("Rotina não disponível para esta empresa!"+CRLF+"Não existe a tabela Z47")
	Return()
endif
if !TCCANOPEN("Z46"+cEmpAnt+"0")
	Alert("Rotina não disponível para esta empresa!"+CRLF+"Não existe a tabela Z46")
	Return()
endif
*/  
AADD( aRotina, { "Pesquisar"		, "AxPesqui"  						, 0 , 1 } ) 
AADD( aRotina, { "Visualizar"		, 'U_GTCORP76("Z47",RECNO(),2)' 	, 0 , 2 } ) 
AADD( aRotina, { "Incluir"			, 'U_GTCORP76("Z47",RECNO(),3)' 	, 0 , 3 } ) 
AADD( aRotina, { "Alterar"			, 'U_GTCORP76("Z47",RECNO(),4)' 	, 0 , 4 } ) 
AADD( aRotina, { "Excluir"			, 'U_GTCORP76("Z47",RECNO(),5)' 	, 0 , 5 } )
AADD( aRotina, { "Relacionar"		, 'U_GTCORP76("Z47",RECNO(),6)' 	, 0 , 4 } )

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
Funcao      : GTCORP76()
Parametros  : xParam1,xParam2,xParam3
Retorno     : .T.
Objetivos   : Montagem da tela para manutenção das informações da Tabela Z47 e Z46 (Enchoice e Getdados)
Autor       : Matheus Massarotto
Data/Hora   : 20/08/2012
*/
*----------------------------------------------*
User Function GTCORP76(xParam1,xParam2,xParam3) 
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
Local cIniCpos     	:= "+Z46_ITEM"       // Nome dos campos do tipo caracter que utilizarao incremento automatico.            
                                        // Este parametro deve ser no formato "+<nome do primeiro campo>+<nome do            
                                        // segundo campo>+..."                                                               
Local nFreeze      	:= 000              // Campos estaticos na GetDados.                                                               
Local nMax         	:= 99              // Numero maximo de linhas permitidas. Valor padrao 99                           
Local cFieldOk     	:= "U_VLD_GT47"    // Funcao executada na validacao do campo                                           
Local cSuperDel     := ""              	// Funcao executada quando pressionada as teclas <Ctrl>+<Delete>                    
Local cDelOk        := "AllwaysTrue"   	// Funcao executada para validar a exclusao de uma linha do aCols                   

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

Private cFilCod:=""

Private aButtons:={}

Private oGroup
Private cTexto:="0"
Private oTexto,oSlider,oMemo
Private cMemo := space(200)

SET DATE FORMAT "dd/mm/yyyy"


	/*Preenche o array com os campos que serão utilizados na Enchoice*/
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("Z47")
	While SX3->(!EOF()) .AND. SX3->X3_ARQUIVO=="Z47"
		
		if X3Uso(SX3->X3_USADO) .AND. !(SX3->X3_CAMPO $ "Z47_FILIAL")
			AADD(aCpoEnch,alltrim(SX3->X3_CAMPO))
			AADD(aAlterEnch,alltrim(SX3->X3_CAMPO))
		endif
			
		SX3->(DbSkip())
	Enddo

	AADD(aCpoEnch,"NOUSER")

	/*Preenche o array com os campos que serão utilizados no aHeader*/
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("Z46")
	While SX3->(!EOF()) .AND. SX3->X3_ARQUIVO=="Z46"
		
		if X3Uso(SX3->X3_USADO) .AND. !(SX3->X3_CAMPO $ "Z46_FILIAL") 
			AADD(aCpoGDa,alltrim(SX3->X3_CAMPO))
			AADD(aAlter,alltrim(SX3->X3_CAMPO))		
		endif
			
		SX3->(DbSkip())
	Enddo

Do Case
	Case xParam3 == 2
		VISUAL := .T.     
		aAlter := {}
		aAlterEnch	:= {}
		
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
	Case xParam3 == 6
		DELETA := .T.
		aAlterEnch	:= {}	
		nOpc2:=4
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
			if Alltrim(aHeader[nI,2]) == "Z46_ITEM"
				aCols[len(aCols)][nI] := "01"
			else
				aCols[len(aCols)][nI] := CriaVar(aHeader[nI][2])
			endif
		Next
		aCols[len(aCols)][nUsado+1] := .F.

	Elseif nOpc==6 .OR. nOpc==2 .OR. nOpc==5
	
		DbSelectArea("Z47")
		Z47->(DbGoTo(nReg))
		cFilCod:= Z47->Z47_FILIAL+Z47->Z47_CODIGO
		
		aCols:={}
		dbSelectArea("Z46")
		dbSetOrder(1)
		Z46->(dbSeek(cFilCod))
		While Z46->(!eof()) .AND. Z46->Z46_FILIAL+Z46->Z46_CODACA==cFilCod
			AADD(aCols,Array(nUsado+1))
				For nX:=1 to nUsado
					aCols[Len(aCols),nX]:=FieldGet(FieldPos(aHeader[nX,2]))
				Next
			aCols[Len(aCols),nUsado+1]:=.F.
			Z46->(dbSkip())
		End
		
		
	EndIf                            
	
		//oGetDados:= MsNewGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3]-10,aPosObj[2,4],nOpc1,cLinOk,cTudoOk,cIniCpos,;                               
		//                             aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oTFolder:aDialogs[1],aHeader,aCols)

    if nOpc==6 .OR. nOpc==2 .OR. nOpc==5
	
		oGetDados:= MsNewGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3]-10,aPosObj[2,4],nOpc1,cLinOk,cTudoOk,cIniCpos,;                               
		                             aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oTFolder:aDialogs[1],aHeader,aCols)

	    oGetDados :ForceRefresh()

    endif

	oTFolder:Align := CONTROL_ALIGN_ALLCLIENT
	// <-> FIM FOLDER 1

  
ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg,{||iif(Grava(aHeader,IIF(nOpc==6 .OR. nOpc==5,oGetDados:aCols,''),aCpoEnch,nOpc,aAlterEnch),oDlg:End(),)},{|| IIF(nOpc==3,RollBackSx8(),''),oDlg:End() },,aButtons))CENTERED

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
/*
	nPosGetDep:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z46_IDDEPE"})
	nPosGetNom:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z46_NODEPE"})

 	for h:=1 to len(oGetDados:aCols)

    	if nPosGetDep>0
			if M->Z47_LRESPO
	    		if empty(oGetDados:aCols[h][nPosGetDep])
		    		Alert("É necessário informar o(s) dependente(s), quando usuário está marcado como responsável!")
		    		Return .F.
					Exit
				endif
			endif
			if M->Z47_LAPROV
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
		RecLock("Z47",iif(nOpc==3,.T.,.F.)) 
			Z47->Z47_FILIAL	:= xFilial("Z47")

			for nx:=1 to len(aCpoEnch)-1
    			Z47->&(aCpoEnch[nx]) := M->&(aCpoEnch[nx])
			next 

	    Z47->(MSUNLOCK())
	    
	    //GRAVANDO GETDADOS
		/*	for i:=1 to len(oGetDados:aCols)
		    	if !empty(oGetDados:aCols[i][2]) //Grava somente se o dependente estiver preenchido
			    	RecLock("Z46",.T.)
			    		Z46->Z46_FILIAL	:= xFilial("Z46")
			    		for j:=1 to len(aHeader)
			    			Z46->&(aHeader[j][2]):=oGetDados:aCols[i][j]
			    		next
			    	MsUnlock()
		    	endif
		    next
        */
	
	Z47->(Confirmsx8())

	END TRANSACTION

elseif nOpc==4 //Alterar

	nPosGetDep:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z46_IDDEPE"})
	nPosGetIte:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z46_ITEM"})
	nPosGetNom:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z46_NODEPE"})


	/*Validação do preenchimento da GetDados*/
/*
 	for h:=1 to len(oGetDados:aCols)

    	if nPosGetDep>0
			if M->Z47_LRESPO
	    		if empty(oGetDados:aCols[h][nPosGetDep])
		    		Alert("É necessário informar o(s) dependente(s), quando usuário está marcado como responsável!")
		    		Return .F.
					Exit
				endif
			endif
			if M->Z47_LAPROV
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
	RecLock("Z47",iif(nOpc==3,.T.,.F.)) 
		for nx:=1 to len(aAlterEnch)
    		Z47->&(aAlterEnch[nx]) := M->&(aAlterEnch[nx])
    	next
    Z47->(MSUNLOCK())
/*    
	//Gravando getdados
	DbSelectArea("Z46")
	Z46->(DbSetOrder(2))
	for i:=1 to len(oGetDados:aCols)
		Z46->(DbGotop())
		
		//Se tiver deletado
		if oGetDados:aCols[i][len(oGetDados:aCols[i])]
			if Z46->(DbSeek(xFilial("Z46")+oGetDados:aCols[i][nPosGetIte]))
				Z46->(DbDelete())
			endif
		else
			
			if Z46->(DbSeek(xFilial("Z46")+oGetDados:aCols[i][nPosGetIte]+M->Z47_IDUSER)) //Se ja existe o item inserido
				RecLock("Z46",.F.)
		    		for j:=1 to len(aHeader)
		    			Z46->&(aHeader[j][2]):=oGetDados:aCols[i][j]
		    		next
				Z46->(MsUnlock())
			else
			   	if !empty(oGetDados:aCols[i][2]) //Somente se dependente estiver preenchido
				   	RecLock("Z46",.T.)
			    		Z46->Z46_FILIAL	:= xFilial("Z78")
			    		for j:=1 to len(aHeader)
			    			Z46->&(aHeader[j][2]):=oGetDados:aCols[i][j]
			    		next
			    	MsUnlock()               
				endif		    	
			endif
			
		endif		
		
	next
*/
elseif nOpc==5 //Excluir	
	
	if !MsgYesNo("Deseja realmente exlcuir a ação e seu(s) relacionamento(s)?")
		Return .F.	
	endif

	nPosGetIte:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z46_ITEM"})
	
	//Deletando Enchoice
	RecLock("Z47",.F.)
		Z47->(DbDelete())
	Z47->(MsUnlock())
	
	//Deletando getdados
	DbSelectArea("Z46")
	Z46->(DbSetOrder(1))
	for i:=1 to len(oGetDados:aCols)
		if Z46->(DbSeek(xFilial("Z46")+M->Z47_CODIGO+oGetDados:aCols[i][nPosGetIte])) //Posiciona no item da tabela Z46
			Reclock("Z46",.F.)
				Z46->(DbDelete())
			Z46->(MsUnlock())		 	
		endif
	next	

elseif nOpc==6

	nPosGetIte:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z46_ITEM"})
	nPosGetCod:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z46_CODIGO"})
	
	//Gravando getdados
	DbSelectArea("Z46")
	Z46->(DbSetOrder(1))
	for i:=1 to len(oGetDados:aCols)
		Z46->(DbGotop())
		
		//Se tiver deletado
		if oGetDados:aCols[i][len(oGetDados:aCols[i])]
			if Z46->(DbSeek(xFilial("Z46")+M->Z47_CODIGO+oGetDados:aCols[i][nPosGetIte]))
				RecLock("Z46",.F.)
					Z46->(DbDelete())
				Z46->(MsUnlock())
			endif
		else
			
			if Z46->(DbSeek(xFilial("Z46")+M->Z47_CODIGO+oGetDados:aCols[i][nPosGetIte])) //Se ja existe o item inserido
				RecLock("Z46",.F.)
		    		for j:=1 to len(aHeader)
		    			Z46->&(aHeader[j][2]):=oGetDados:aCols[i][j]
		    		next
				Z46->(MsUnlock())
			else
			   	if !empty(oGetDados:aCols[i][2]) //Somente se codigo estiver preenchido
				   	RecLock("Z46",.T.)
			    		Z46->Z46_FILIAL	:= xFilial("Z46")
			    		Z46->Z46_CODACA	:= M->Z47_CODIGO
			    		for j:=1 to len(aHeader)
			    			Z46->&(aHeader[j][2]):=oGetDados:aCols[i][j]
			    		next
			    	MsUnlock()
				endif		    	
			endif
			
		endif		
		
	next



endif

Return(.T.)

/*
Funcao      : VLD_GT47()  
Parametros  : 
Retorno     : .T. ou .F.
Objetivos   : Função para validação do aCols
Autor       : Matheus Massarotto
Data/Hora   : 05/02/2012
*/
*---------------------*
User Function VLD_GT47
*---------------------*
Local nPos	:= Ascan(aHeader,{|x| alltrim(x[2]) = "Z46_CODIGO"})
Local lRet	:= .T.

for i:=1 to len(oGetDados:aCols)
	if oGetDados:nAt==i
		Loop
	endif

	if alltrim(oGetDados:aCols[i][nPos])==alltrim(M->Z46_CODIGO) //oGetDados:aCols[oGetDados:nAt][nPos]
		alert("Codigo já está inserido!")
		lRet:=.F.
	endif
	
next

Return(lRet)


//Função para validar se ja existe um incluir
User Function VLD_NO47
Local lRet	:= .T.
Local cQry	:= ""

	if M->Z47_NOPC=='3' 
		cQry:=" SELECT * FROM "+RETSQLNAME("Z47")+" Z47"
		cQry+=" WHERE Z47.D_E_L_E_T_='' AND Z47_NOPC='3'
	    
		if select("QRYTEMP")>0
			QRYTEMP->(DbCloseArea())
		endif
		
		DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )
		
		Count to nRecCount
	        
		if nRecCount >0
	    	lRet:=.F.
	    	Alert("Já existe uma opção de incluir inserida!")
	    endif
    endif
    
Return(lRet)