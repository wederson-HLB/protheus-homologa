#Include "Protheus.ch"
#Include "TopConn.ch"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "TBICONN.ch"

/*
Funcao      : GTCORP79
Parametros  : Nil
Retorno     : Nil
Objetivos   : Fun��o Mbrowse da tabela Z42, Cadastro de Al�ada do novo controle de proposta
Autor       : Matheus Massarotto
Data/Hora   : 04/02/2013    14:28
Revis�o		:                    
Data/Hora   : 
M�dulo      : Gest�o de Contratos
*/

*-----------------------*
User Function GTCORP79()
*-----------------------*
Local cString:="Z42"
Local lFilter:=.F.	//Define se deve ser filtrado a apresenta��o das propostas por usu�rio
Local cIdUser:=__cUserID // Id do usu�rio logado
Private aRotina:={}
/*
if !TCCANOPEN("Z42"+cEmpAnt+"0")
	Alert("Rotina n�o dispon�vel para esta empresa!"+CRLF+"N�o existe a tabela Z42")
	Return()
endif
if !TCCANOPEN("Z41"+cEmpAnt+"0")
	Alert("Rotina n�o dispon�vel para esta empresa!"+CRLF+"N�o existe a tabela Z41")
	Return()
endif
*/  
AADD( aRotina, { "Pesquisar"		, "AxPesqui"  		, 0 , 1 } ) 
AADD( aRotina, { "Visualizar"		, 'U_GTCORP78("Z42",RECNO(),2)' 	, 0 , 2 } ) 
AADD( aRotina, { "Incluir"			, 'U_GTCORP78("Z42",RECNO(),3)' 	, 0 , 3 } ) 
AADD( aRotina, { "Alterar"			, 'U_GTCORP78("Z42",RECNO(),4)' 	, 0 , 4 } ) 
AADD( aRotina, { "Excluir"			, 'U_GTCORP78("Z42",RECNO(),5)' 	, 0 , 5 } )


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
Funcao      : GTCORP78()
Parametros  : xParam1,xParam2,xParam3
Retorno     : .T.
Objetivos   : Montagem da tela para manuten��o das informa��es da Tabela Z42 e Z41 (Enchoice e Getdados)
Autor       : Matheus Massarotto
Data/Hora   : 20/08/2012
*/
*----------------------------------------------*
User Function GTCORP78(xParam1,xParam2,xParam3) 
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
//�����������������������������������Ŀ
//� Variaveis da MsNewGetDados()      �
//�������������������������������������
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
Local cIniCpos     	:= "+Z41_ITEM"       // Nome dos campos do tipo caracter que utilizarao incremento automatico.            
                                        // Este parametro deve ser no formato "+<nome do primeiro campo>+<nome do            
                                        // segundo campo>+..."                                                               
Local nFreeze      	:= 000              // Campos estaticos na GetDados.                                                               
Local nMax         	:= 99              // Numero maximo de linhas permitidas. Valor padrao 99                           
Local cFieldOk     	:= "U_VLD_GT79"    // Funcao executada na validacao do campo                                           
Local cSuperDel     := ""              	// Funcao executada quando pressionada as teclas <Ctrl>+<Delete>                    
Local cDelOk        := "AllwaysFalse"   	// Funcao executada para validar a exclusao de uma linha do aCols                   

Local aObjects      := {}
Local aPosObj       := {}
Local aSize         := {}        

Local nUsado:=0

Local cCadastro:="Cadastro de Alcada"

Local cAno:="" //Ano que se deseja alterar

// Vari�veis utilizadas na sele��o de categorias
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

Private aTELA[0][0] // Vari�veis que ser�o atualizadas pela Enchoice()
Private aGETS[0] // e utilizadas pela fun��o OBRIGATORIO()

Private cFilUser:=""

Private aButtons:={}

Private oGroup
Private cTexto:="0"
Private oTexto,oSlider,oMemo
Private cMemo := space(200)

SET DATE FORMAT "dd/mm/yyyy"


	/*Preenche o array com os campos que ser�o utilizados na Enchoice*/
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("Z42")
	While SX3->(!EOF()) .AND. SX3->X3_ARQUIVO=="Z42"
		
		if X3Uso(SX3->X3_USADO) .AND. !(SX3->X3_CAMPO $ "Z42_FILIAL")
			AADD(aCpoEnch,alltrim(SX3->X3_CAMPO))
			if nOpc==4
				if !(SX3->X3_CAMPO $ "Z42_IDUSER")
					AADD(aAlterEnch,alltrim(SX3->X3_CAMPO))
				endif
			else
				AADD(aAlterEnch,alltrim(SX3->X3_CAMPO))
			endif
		endif
			
		SX3->(DbSkip())
	Enddo

	AADD(aCpoEnch,"NOUSER")

	/*Preenche o array com os campos que ser�o utilizados no aHeader*/
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("Z41")
	While SX3->(!EOF()) .AND. SX3->X3_ARQUIVO=="Z41"
		
		if X3Uso(SX3->X3_USADO) .AND. !(SX3->X3_CAMPO $ "Z41_FILIAL/Z41_IDUSER/Z41_NOUSER") 
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


//������������������������������������������������������Ŀ
//� Faz o calculo automatico de dimensoes de objetos     �
//��������������������������������������������������������
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
	//Carrega as vari�veris da tabela Z79
	RegToMemory(cAliasE,If(nOpc == 3,.T.,.F.), .T.)

	                                                                   //aPos
	Enchoice(cAliasE,nReg,nOpc2,/*aCRA*/,/*cLetra*/,/*cTexto*/,aCpoEnch,aPosObjEnch,;
			aAlterEnch,nModelo,/*nColMens*/,/*cMensagem*/,/*cTudoOk*/,oTFolder:aDialogs[1],lF3,;    
			lMemoria,lColumn,caTela,lNoFolder,lProperty)                    

	
	//���������������������������������������������������������������������Ŀ
	//� Carrega o aHeader										 			�
	//�����������������������������������������������������������������������
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
	
	//Carrega as vari�veis no aCols de acordo com a op��o selecionada       
	If nOpc == 3
		AADD(aCols,Array(nUsado+1))
		For nI := 1 To nUsado
			if Alltrim(aHeader[nI,2]) == "Z41_ITEM"
				aCols[len(aCols)][nI] := "01"
			else
				aCols[len(aCols)][nI] := CriaVar(aHeader[nI][2])
			endif
		Next
		aCols[len(aCols)][nUsado+1] := .F.
	Else
	
		DbSelectArea("Z42")
		Z42->(DbGoTo(nReg))
		cFilUser:= Z42->Z42_FILIAL+Z42->Z42_IDUSER
		
		aCols:={}
		dbSelectArea("Z41")
		dbSetOrder(1)
		dbSeek(cFilUser)
		While !eof() .AND. Z41->Z41_FILIAL+Z41->Z41_IDUSER==cFilUser
			AADD(aCols,Array(nUsado+1))
				For nX:=1 to nUsado
					aCols[Len(aCols),nX]:=FieldGet(FieldPos(aHeader[nX,2]))
				Next
			aCols[Len(aCols),nUsado+1]:=.F.
			Z41->(dbSkip())
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
Objetivos   : Fun��o para grava��o/altera��o/dele��o
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
    
	/*Valida��o do preenchimento da GetDados*/
	nPosGetDep:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z41_IDDEPE"})
	nPosGetNom:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z41_NODEPE"})

 	for h:=1 to len(oGetDados:aCols)

    	if nPosGetDep>0
			
			/*if M->Z42_LRESPO
	    		if empty(oGetDados:aCols[h][nPosGetDep])
		    		Alert("� necess�rio informar o(s) dependente(s), quando usu�rio est� marcado como respons�vel!")
		    		Return .F.
					Exit
				endif
			endif
			*/
			if M->Z42_LAPROV
	    		if empty(oGetDados:aCols[h][nPosGetDep])
		    		Alert("� necess�rio informar o(s) dependente(s), quando usu�rio est� marcado como aprovador!")
		    		Return .F.
					Exit
				endif
			endif
		endif

    next

	
	BEGIN TRANSACTION	
		//Gravando ENCHOICE
		RecLock("Z42",iif(nOpc==3,.T.,.F.)) 
			Z42->Z42_FILIAL	:= xFilial("Z42")

			for nx:=1 to len(aCpoEnch)-1
    			Z42->&(aCpoEnch[nx]) := M->&(aCpoEnch[nx])
			next 

	    Z42->(MSUNLOCK())
	    
	    //GRAVANDO GETDADOS
			for i:=1 to len(oGetDados:aCols)
		    	if !empty(oGetDados:aCols[i][2]) //Grava somente se o dependente estiver preenchido
			    	RecLock("Z41",.T.)
			    		Z41->Z41_FILIAL	:= xFilial("Z78")
	   					Z41->Z41_IDUSER	:= M->Z42_IDUSER
			    		Z41->Z41_NOUSER	:= M->Z42_NOUSER
			    		for j:=1 to len(aHeader)
			    			Z41->&(aHeader[j][2]):=oGetDados:aCols[i][j]
			    		next
			    	MsUnlock()
		    	endif
		    next

	END TRANSACTION

elseif nOpc==4 //Alterar

	/*Valida o cabecalho*/
	if !Obrigatorio(aGets,aTela) 
		Return .F.
	endif

	nPosGetDep:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z41_IDDEPE"})
	nPosGetIte:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z41_ITEM"})
	nPosGetNom:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z41_NODEPE"})


	/*Valida��o do preenchimento da GetDados*/

 	for h:=1 to len(oGetDados:aCols)

    	if nPosGetDep>0
			/*if M->Z42_LRESPO
	    		if empty(oGetDados:aCols[h][nPosGetDep])
		    		Alert("� necess�rio informar o(s) dependente(s), quando usu�rio est� marcado como respons�vel!")
		    		Return .F.
					Exit
				endif
			endif
			*/
			if M->Z42_LAPROV
	    		if empty(oGetDados:aCols[h][nPosGetDep])
		    		Alert("� necess�rio informar o(s) dependente(s), quando usu�rio est� marcado como aprovador!")
		    		Return .F.
					Exit
				endif
			endif
		endif

    next
	
	//Gravando ENCHOICE
	RecLock("Z42",iif(nOpc==3,.T.,.F.)) 
		for nx:=1 to len(aAlterEnch)
    		Z42->&(aAlterEnch[nx]) := M->&(aAlterEnch[nx])
    	next
    Z42->(MSUNLOCK())
    
	//Gravando getdados
	DbSelectArea("Z41")
	Z41->(DbSetOrder(2))
	for i:=1 to len(oGetDados:aCols)
		Z41->(DbGotop())
		
		//Se tiver deletado
		if oGetDados:aCols[i][len(oGetDados:aCols[i])]
			if Z41->(DbSeek(xFilial("Z41")+oGetDados:aCols[i][nPosGetIte]+M->Z42_IDUSER))
				Z41->(DbDelete())
			endif
		else
			
			if Z41->(DbSeek(xFilial("Z41")+oGetDados:aCols[i][nPosGetIte]+M->Z42_IDUSER)) //Se ja existe o item inserido
				RecLock("Z41",.F.)
		    		for j:=1 to len(aHeader)
		    			Z41->&(aHeader[j][2]):=oGetDados:aCols[i][j]
		    		next
				Z41->(MsUnlock())
			else
			   	if !empty(oGetDados:aCols[i][2]) //Somente se dependente estiver preenchido
				   	RecLock("Z41",.T.)
			    		Z41->Z41_FILIAL	:= xFilial("Z78")
			   			Z41->Z41_IDUSER	:= M->Z42_IDUSER
			    		Z41->Z41_NOUSER	:= M->Z42_NOUSER
			    		for j:=1 to len(aHeader)
			    			Z41->&(aHeader[j][2]):=oGetDados:aCols[i][j]
			    		next
			    	MsUnlock()
				endif		    	
			endif
			
		endif		
		
	next
	
elseif nOpc==5 //Excluir	
	
	if !MsgYesNo("Deseja realmente exlcuir usu�rio e seu(s) dependente(s)?")
		Return .F.	
	endif

	nPosGetIte:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z41_ITEM"})
	
	//Deletando Enchoice
	RecLock("Z42",.F.)
		Z42->(DbDelete())
	Z42->(MsUnlock())
	
	//Deletando getdados
	DbSelectArea("Z41")
	Z41->(DbSetOrder(2))
	for i:=1 to len(oGetDados:aCols)
		if Z41->(DbSeek(xFilial("Z41")+oGetDados:aCols[i][nPosGetIte]+M->Z42_IDUSER)) //Posiciona no item da tabela Z41
			Reclock("Z41",.F.)
				Z41->(DbDelete())
			Z41->(MsUnlock())		 	
		endif
	next	

endif

Return(.T.)

/*
Funcao      : VLD_GT79()  
Parametros  : 
Retorno     : .T. ou .F.
Objetivos   : Fun��o para valida��o do aCols
Autor       : Matheus Massarotto
Data/Hora   : 05/02/2012
*/
*---------------------*
User Function VLD_GT79
*---------------------*
Local nPos	:= Ascan(aHeader,{|x| alltrim(x[2]) = "Z41_IDDEP"})
Local lRet	:= .T.

for i:=1 to len(oGetDados:aCols)
	if oGetDados:nAt==i
		Loop
	endif

	if alltrim(oGetDados:aCols[i][nPos])==alltrim(M->Z41_IDDEPE) //oGetDados:aCols[oGetDados:nAt][nPos]
		alert("Dependente j� est� inserido!")
		lRet:=.F.
	endif
	
next

Return(lRet)

/*
Funcao      : VLD_Z42()
Parametros  : 
Retorno     : .T.
Objetivos   : Fun��o para n�o deixar preencher aprovador e respons�vel ao mesmo tempo.
Autor       : Matheus Massarotto
Data/Hora   : 05/02/2012
*/

*---------------------*
User Function VLD_Z42(cCampo)
*---------------------*
Local lRet	:= .T.


if cCampo == "Z42_LAPROV"

	if M->Z42_LRESPO
		M->Z42_LRESPO:=.F.
	endif
elseif cCampo == "Z42_LRESPO"

	if M->Z42_LAPROV
		M->Z42_LAPROV:=.F.
	endif
endif

Return(lRet)