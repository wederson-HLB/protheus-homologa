#Include "Protheus.ch"

/*
Funcao      : GTCORP14
Parametros  : 
Retorno     : Nil
Objetivos   : Função inicial(mBrowse) para apresentação dos dados da tabela Z89
Autor       : Matheus Massarotto
Data/Hora   : 14/05/2012    10:14
Revisão		:                    
Data/Hora   : 
Módulo      : Genérico
*/
*-----------------------*
User Function GTCORP14()
*-----------------------*
Local cString:="Z89"
Private aRotina:={}

if !TCCANOPEN("Z89"+cEmpAnt+"0")
	Alert("Rotina não disponível para esta empresa!")
	Return()
endif

AADD( aRotina, { "Pesquisar"	, "AxPesqui"  		, 0 , 1 } ) 
AADD( aRotina, { "Visualizar"	, 'U_GTCORP15("Z89",RECNO(),2)' 	, 0 , 2 } ) 
AADD( aRotina, { "Incluir"		, 'U_GTCORP15("Z89",RECNO(),3)' 	, 0 , 3 } ) 
AADD( aRotina, { "Alterar"		, 'U_GTCORP15("Z89",RECNO(),4)' 	, 0 , 4 } ) 
AADD( aRotina, { "Excluir"		, 'U_GTCORP15("Z89",RECNO(),5)' 	, 0 , 5 } ) 

DbSelectArea(cString) 
DbSetOrder(1)
MBrowse( 6,1,22,75,cString)
 
Return

/*
Funcao      : GTCORP15()  
Parametros  : xParam1,xParam2,xParam3
Retorno     : .T.
Objetivos   : Montagem da tela para manutenção das informações da Tabela Z89
Autor       : Matheus Massarotto
Data/Hora   : 14/05/2012
*/
*----------------------------------------------*
User Function GTCORP15(xParam1,xParam2,xParam3) 
*----------------------------------------------*
Local cAliasE := xParam1           // Tabela cadastrada no Dicionario de Tabelas (SX2) que sera editada
// Vetor com nome dos campos que serao exibidos. Os campos de usuario sempre serao              
// exibidos se nao existir no parametro um elemento com a expressao "NOUSER"                    
Local aCpoEnch  	:= iif(cEmpAnt=="ZF",{"Z89_ANO","Z89_GRUPO","NOUSER"},{"Z89_ANO","NOUSER"}) //ZF - Tratamento diferenciado para empresa 
Local aAlterEnch	:= iif(cEmpAnt=="ZF",{"Z89_ANO","Z89_GRUPO"},{"Z89_ANO"})		// Vetor com nome dos campos que poderao ser editados
Local nOpc    		:= xParam3 	// Numero da linha do aRotina que definira o tipo de edicao (Inclusao, Alteracao, Exclucao, Visualizacao)
Local nReg    		:= xParam2	// Numero do Registro a ser Editado/Visualizado (Em caso de Alteracao/Visualizacao)
// Vetor com coordenadas para criacao da enchoice no formato {<top>, <left>, <bottom>, <right>} 
Local aPos		  	:= {019,002,048,322}                      
Local nModelo		:= 3     	// Se for diferente de 1 desabilita execucao de gatilhos estrangeiros                           
Local lF3 		  	:= .F.		// Indica se a enchoice esta sendo criada em uma consulta F3 para utilizar variaveis de memoria 
Local lMemoria 		:= .T.		// Indica se a enchoice utilizara variaveis de memoria ou os campos da tabela na edicao         
Local lColumn		:= .F.		// Indica se a apresentacao dos campos sera em forma de coluna                                  
Local caTela 		:= "" 		// Nome da variavel tipo "private" que a enchoice utilizara no lugar da propriedade aTela       
Local lNoFolder		:= .F.		// Indica se a enchoice nao ira utilizar as Pastas de Cadastro (SXA)                            
Local lProperty		:= .F.		// Indica se a enchoice nao utilizara as variaveis aTela e aGets, somente suas propriedades com os mesmos nomes
                                                                                                                                             
Local nX			:= 0                                                                                                              
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis da MsNewGetDados()      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Vetor responsavel pela montagem da aHeader
Local aCpoGDa       := {"Z89_MES","Z89_VALOR"}
// Vetor com os campos que poderao ser alterados                                                                                
Local aAlter     	:= {""}
Local nSuperior    	:= 052           	// Distancia entre a MsNewGetDados e o extremidade superior do objeto que a contem
Local nEsquerda    	:= 002           	// Distancia entre a MsNewGetDados e o extremidade esquerda do objeto que a contem
Local nInferior    	:= 170          	// Distancia entre a MsNewGetDados e o extremidade inferior do objeto que a contem
Local nDireita     	:= 322           	// Distancia entre a MsNewGetDados e o extremidade direita  do objeto que a contem
// Posicao do elemento do vetor aRotina que a MsNewGetDados usara como referencia  
Local nOpc1        	:= GD_INSERT+GD_DELETE+GD_UPDATE                                                                            
Local cLinOk       	:= "AllwaysTrue"    // Funcao executada para validar o contexto da linha atual do aCols                  
Local cTudoOk      	:= "AllwaysTrue"    // Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)      
Local cIniCpos     	:= ""               // Nome dos campos do tipo caracter que utilizarao incremento automatico.            
                                        // Este parametro deve ser no formato "+<nome do primeiro campo>+<nome do            
                                        // segundo campo>+..."                                                               
Local nFreeze      	:= 000              // Campos estaticos na GetDados.                                                               
Local nMax         	:= 12              // Numero maximo de linhas permitidas. Valor padrao 99                           
Local cFieldOk     	:= "AllwaysTrue"    // Funcao executada na validacao do campo                                           
Local cSuperDel     := ""              	// Funcao executada quando pressionada as teclas <Ctrl>+<Delete>                    
Local cDelOk        := "AllwaysFalse"   	// Funcao executada para validar a exclusao de uma linha do aCols                   
// Objeto no qual a MsNewGetDados sera criada                                      
Local aHeader       := {}               // Array a ser tratado internamente na MsNewGetDados como aHeader                    
Local aCols         := {}               // Array a ser tratado internamente na MsNewGetDados como aCols
Local aObjects      := {}
Local aPosObj       := {}
Local aSize         := {}        

Local nUsado:=0

Local cCadastro:="Cadastro de Faturamento Orcado"

Local cAno:="" //Ano que se deseja alterar

// Variaveis Private da Funcao
Private oDlg				// Dialog Principal
// Variaveis que definem a Acao do Formulario
Private VISUAL := .F.                        
Private INCLUI := .F.                        
Private ALTERA := .F.                        
Private DELETA := .F.                        
// Privates das NewGetDados
Private oGetDados


Do Case
	Case xParam3 == 2
		VISUAL := .T.     
	Case xParam3 == 3
		INCLUI := .T. 
		aAlter := {"Z89_VALOR"} 
		//Tratamento diferenciado para a empresa ZF
		aAlterEnch	:= iif(cEmpAnt=="ZF",{"Z89_ANO","Z89_GRUPO"},{"Z89_ANO"})
	Case xParam3 == 4
		ALTERA := .T.                                                
		aAlter := {"Z89_VALOR"}
		aAlterEnch	:= {} 	   
	Case xParam3 == 5
		DELETA := .T.
EndCase    


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz o calculo automatico de dimensoes de objetos     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize := MsAdvSize()
AAdd( aObjects, { 100, 100, .T., .T. } )
AAdd( aObjects, { 200, 200, .T., .T. } )
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj 	:= MsObjSize( aInfo, aObjects,.T.)
//DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 To aSize[6],aSize[5] of oMainWnd PIXEL
DEFINE MSDIALOG oDlg TITLE cCadastro From 0,0 To 350,650 of oMainWnd PIXEL

RegToMemory(cAliasE,If(nOpc == 3,.T.,.F.), .T.)
 
Enchoice(cAliasE,nReg,nOpc,/*aCRA*/,/*cLetra*/,/*cTexto*/,aCpoEnch,aPos,;
		aAlterEnch,nModelo,/*nColMens*/,/*cMensagem*/,/*cTudoOk*/,oDlg,lF3,;    
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
	For nJ:=1 to 12
		AADD(aCols,Array(nUsado+1))
		For nI := 1 To nUsado
			if nI==1
				aCols[len(aCols)][nI]:=STRZERO(nJ,2)
			else
				aCols[len(aCols)][nI] := CriaVar(aHeader[nI][2])
			endif
		Next
		aCols[len(aCols)][nUsado+1] := .F.
	Next
Else
	DbSelectArea("Z89")
	Z89->(DbGoTo(nReg))
	cAno:=Z89->Z89_ANO
	DbSetOrder(1)
	//Tratamento diferenciado para a empresa ZF
	if cEmpAnt=="ZF"
		cGrupo:=Z89->Z89_GRUPO
		
		Z89->(DbSeek(xFilial("Z89")+cAno+cGrupo))
		
		For nJ:=1 to 12
			AADD(aCols,Array(nUsado+1))
			For nI := 1 To nUsado
				if nI==1
					aCols[len(aCols)][nI]:=STRZERO(nJ,2)
				else
					if Z89->(DbSeek(xFilial("Z89")+cAno+cGrupo+STRZERO(nJ,2)))
						aCols[len(aCols)][nI] := Z89->Z89_VALOR
					else
						aCols[len(aCols)][nI] := CriaVar(aHeader[nI][2])
					endif	
				endif
			Next
			aCols[len(aCols)][nUsado+1] := .F.
		Next	
	else
		Z89->(DbSeek(xFilial("Z89")+cAno))
			
			For nJ:=1 to 12
				AADD(aCols,Array(nUsado+1))
				For nI := 1 To nUsado
					if nI==1
						aCols[len(aCols)][nI]:=STRZERO(nJ,2)
					else
						if Z89->(DbSeek(xFilial("Z89")+cAno+STRZERO(nJ,2)))
							aCols[len(aCols)][nI] := Z89->Z89_VALOR
						else
							aCols[len(aCols)][nI] := CriaVar(aHeader[nI][2])
						endif	
					endif
				Next
				aCols[len(aCols)][nUsado+1] := .F.
			Next	
	endif
EndIf                            

oGetDados:= MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpc1,cLinOk,cTudoOk,cIniCpos,;                               
                             aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oDlg,aHeader,aCols)              

//Tratamento diferenciado para a empresa ZF
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| ;
iif(cEmpAnt=="ZF",iif(GravaZFZ89(aHeader,oGetDados:aCols,iif(nOpc==3,M->Z89_ANO,cAno),iif(nOpc==3,M->Z89_GRUPO,cGrupo),nOpc),oDlg:End(),),;
iif(GravaZ89(aHeader,oGetDados:aCols,iif(nOpc==3,M->Z89_ANO,cAno),nOpc),oDlg:End(),);
)},{||oDlg:End()}) CENTERED
         
Return(.T.)

/*
Funcao      : GravaZ89()  
Parametros  : Header,aCols,cAno,nOpc
Retorno     : .T. ou .F.
Objetivos   : Função para gravação/alteração/deleção
Autor       : Matheus Massarotto
Data/Hora   : 14/05/2012
*/
*-----------------------------------------------*
Static Function GravaZ89(aHeader,aCols,cAno,nOpc)
*-----------------------------------------------*
Local nPosVal:=0
    //Validação da obrigatoriedade do campo ano
	if empty(cAno)
		Alert("Campo Ano deve ser preenchido!")
		return(.F.)
	endif

	if nOpc==3 .OR. nOpc==4 //GRAVA ou ALTERA os ITENS
		DbSelectArea("Z89")
		DbSetOrder(1)
		Z89->(DbGoTop())
		if Z89->(DbSeek(xFilial("Z89")+cAno))
		    nPosVal:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z89_VALOR"}) 
		    for i:=1 to len(aCols)
		    	if Z89->(DbSeek(xFilial("Z89")+cAno+STRZERO(i,2)))
			    	RecLock("Z89",.F.)
		    			Z89->&(aHeader[nPosVal][2]):=aCols[i][nPosVal]
			    	MsUnlock()
		    	endif
		    next    
	    else
		    for i:=1 to len(aCols)
		    	RecLock("Z89",.T.)
		    		Z89->Z89_FILIAL:=xFilial("Z89")
		    		Z89->Z89_ANO:=cAno
		    		for j:=1 to len(aHeader)
		    			Z89->&(aHeader[j][2]):=aCols[i][j]
		    		next
		    	MsUnlock()
		    next
	    endif
	elseif nOpc==5 //DELETA OS ITENS
		
		if MSGYESNO("Confirma a exclusão do periodo?", "Atenção")
			DbSelectArea("Z89")
			DbSetOrder(1)
			Z89->(DbGoTop())
			if Z89->(DbSeek(xFilial("Z89")+cAno))
				for i:=1 to len(aCols)
			    	if Z89->(DbSeek(xFilial("Z89")+cAno+STRZERO(i,2)))
				    	RecLock("Z89",.F.)
			    			Z89->(DbDelete())
				    	MsUnlock()
			    	endif
			    next    
			endif
		else
			Return(.F.)
		endif
		
	endif    
Return(.T.)

/*
Funcao      : GravaZ89()  
Parametros  : Header,aCols,cAno,nOpc
Retorno     : .T. ou .F.
Objetivos   : Função para gravação/alteração/deleção Especifico ZF
Autor       : Matheus Massarotto
Data/Hora   : 14/05/2012
*/
*-----------------------------------------------*
Static Function GravaZFZ89(aHeader,aCols,cAno,cGrupo,nOpc)
*-----------------------------------------------*
Local nPosVal:=0
    //Validação da obrigatoriedade do campo ano
	if empty(cAno)
		Alert("Campo Ano deve ser preenchido!")
		return(.F.)
	elseif empty(cGrupo)
		Alert("Campo Grupo deve ser preenchido!")
		return(.F.)	
	endif

	if nOpc==3 .OR. nOpc==4 //GRAVA ou ALTERA os ITENS
		DbSelectArea("Z89")
		DbSetOrder(1)
		Z89->(DbGoTop())
		if Z89->(DbSeek(xFilial("Z89")+cAno+cGrupo))
		    nPosVal:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z89_VALOR"}) 
		    for i:=1 to len(aCols)
		    	if Z89->(DbSeek(xFilial("Z89")+cAno+cGrupo+STRZERO(i,2)))
			    	RecLock("Z89",.F.)
		    			Z89->&(aHeader[nPosVal][2]):=aCols[i][nPosVal]
			    	MsUnlock()
		    	endif
		    next    
	    else
		    for i:=1 to len(aCols)
		    	RecLock("Z89",.T.)
		    		Z89->Z89_FILIAL:=xFilial("Z89")
		    		Z89->Z89_ANO:=cAno
		    		Z89->Z89_GRUPO:=cGrupo
		    		for j:=1 to len(aHeader)
		    			Z89->&(aHeader[j][2]):=aCols[i][j]
		    		next
		    	MsUnlock()
		    next
	    endif
	elseif nOpc==5 //DELETA OS ITENS
		
		if MSGYESNO("Confirma a exclusão do periodo?", "Atenção")
			DbSelectArea("Z89")
			DbSetOrder(1)
			Z89->(DbGoTop())
			if Z89->(DbSeek(xFilial("Z89")+cAno+cGrupo))
				for i:=1 to len(aCols)
			    	if Z89->(DbSeek(xFilial("Z89")+cAno+cGrupo+STRZERO(i,2)))
				    	RecLock("Z89",.F.)
			    			Z89->(DbDelete())
				    	MsUnlock()
			    	endif
			    next    
			endif
		else
			Return(.F.)
		endif
		
	endif    
Return(.T.)

/*
Funcao      : VLANOZ89()  
Parametros  : 
Retorno     : .T. ou .F.
Objetivos   : Função para validar o campo do ano no cadastro.
Autor       : Matheus Massarotto
Data/Hora   : 14/05/2012
*/
*---------------------*
User Function VLANOZ89
*---------------------*
Local lRet:=.T.

if len(alltrim(M->Z89_ANO))<4
	Alert("Ano deve ter 4 dígitos. Ex: AAAA.")
	lRet:=.F.
else
	DbSelectArea("Z89")
	DbSetOrder(1)
	if DbSeek(xFilial("Z89")+M->Z89_ANO)
		Alert("Já existe cadastro deste ano!")
		lRet:=.F.
	endif
	
	for nU:=1 to len(alltrim(M->Z89_ANO))
    	if !ISDIGIT(SUBSTR(alltrim(M->Z89_ANO),nU,1))
    		Alert("O campo só permite digitação de números!")
			lRet:=.F.
			exit
    	endif
	next
endif

Return(lRet)

/*
Funcao      : VLAZFZ89()  
Parametros  : 
Retorno     : .T. ou .F.
Objetivos   : Função para validar o campo do ano no cadastro Especifico ZF.
Autor       : Matheus Massarotto
Data/Hora   : 14/05/2012
*/
*---------------------*
User Function VLAZFZ89
*---------------------*
Local lRet:=.T.

if len(alltrim(M->Z89_ANO))<4
	Alert("Ano deve ter 4 dígitos. Ex: AAAA.")
	lRet:=.F.
else
	DbSelectArea("Z89")
	DbSetOrder(1)
	if DbSeek(xFilial("Z89")+M->Z89_ANO+M->Z89_GRUPO)
		Alert("Já existe cadastro deste ano e grupo!")
		lRet:=.F.
	endif
	
	for nU:=1 to len(alltrim(M->Z89_ANO))
    	if !ISDIGIT(SUBSTR(alltrim(M->Z89_ANO),nU,1))
    		Alert("O campo só permite digitação de números!")
			lRet:=.F.
			exit
    	endif
	next


endif

Return(lRet)
/*
Funcao      : VLGZFZ89()  
Parametros  : 
Retorno     : .T. ou .F.
Objetivos   : Função para validar o campo do Grupo no cadastro Especifico ZF.
Autor       : Matheus Massarotto
Data/Hora   : 14/05/2012
*/
*---------------------*
User Function VLGZFZ89
*---------------------*
Local lRet:=.T.

if empty(alltrim(M->Z89_GRUPO))
	Alert("Preencha o grupo!")
	lRet:=.F.
else
	DbSelectArea("Z89")
	DbSetOrder(1)
	if DbSeek(xFilial("Z89")+M->Z89_ANO+M->Z89_GRUPO)
		Alert("Já existe cadastro deste ano e grupo!")
		lRet:=.F.
	endif
	
	DbSelectArea("SX5")
	DbSetOrder(1)
	if !DbSeek(xFilial("SX5")+"V0"+M->Z89_GRUPO)
 			Alert("Grupo não cadastrado!")
			lRet:=.F.
	endif
endif

Return(lRet)