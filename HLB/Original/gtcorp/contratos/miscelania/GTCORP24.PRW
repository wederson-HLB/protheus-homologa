#Include "Protheus.ch"
#Include "TopConn.ch"

/*
Funcao      : GTCORP24
Parametros  : Nil
Retorno     : Nil
Objetivos   : Função Mbrowse da tabela Z86, Cadastro de Drafts
Autor       : Matheus Massarotto
Data/Hora   : 28/06/2012    17:30
Revisão		:                    
Data/Hora   : 
Módulo      : Gestão de Contratos
*/
*-----------------------*
User Function GTCORP24()
*-----------------------*
Local cString:="Z86"
Private aRotina:={}

if !TCCANOPEN("Z86"+cEmpAnt+"0")
	Alert("Rotina não disponível para esta empresa!")
	Return()
endif
  
AADD( aRotina, { "Pesquisar"	, "AxPesqui"  		, 0 , 1 } ) 
AADD( aRotina, { "Visualizar"	, 'U_GTCORP23("Z86",RECNO(),2)' 	, 0 , 2 } ) 
AADD( aRotina, { "Incluir"		, 'U_GTCORP23("Z86",RECNO(),3)' 	, 0 , 3 } ) 
AADD( aRotina, { "Alterar"		, 'U_GTCORP23("Z86",RECNO(),4)' 	, 0 , 4 } ) 
//AADD( aRotina, { "Aprovar"		, 'U_GTCORP23("Z86",RECNO(),5)' 	, 0 , 5 } )
AADD( aRotina, { "Legenda"		, 'U_LEGZ86'  						, 0 , 6 } )

Private aCores:={}

aCores := {{"Z86_STATUS == '1' .OR. Z86_STATUS == ' ' ", "BR_AMARELO" },; // Pendente
		   {"Z86_STATUS == '2'", "BR_VERDE" 	},; 	// Aprovado
           {"Z86_STATUS == '3'", "BR_CINZA"   	}} 		// Em proposta

DbSelectArea(cString) 
DbSetOrder(1)
MBrowse( 6,1,22,75,cString,,,,,,aCores)
 
Return

/*
Funcao      : GTCORP23()  
Parametros  : xParam1,xParam2,xParam3
Retorno     : .T.
Objetivos   : Montagem da tela para manutenção das informações da Tabela Z86 e Z85 (Enchoice e Getdados)
Autor       : Matheus Massarotto
Data/Hora   : 31/05/2012
*/
*----------------------------------------------*
User Function GTCORP23(xParam1,xParam2,xParam3) 
*----------------------------------------------*
Local cAliasE := xParam1           // Tabela cadastrada no Dicionario de Tabelas (SX2) que sera editada
// Vetor com nome dos campos que serao exibidos. Os campos de usuario sempre serao              
// exibidos se nao existir no parametro um elemento com a expressao "NOUSER"                    
Local aCpoEnch  	:= {}
Local aAlterEnch	:= {}
Local nOpc    		:= nOpc2:= xParam3 	// Numero da linha do aRotina que definira o tipo de edicao (Inclusao, Alteracao, Exclucao, Visualizacao)
Local nReg    		:= xParam2	// Numero do Registro a ser Editado/Visualizado (Em caso de Alteracao/Visualizacao)
// Vetor com coordenadas para criacao da enchoice no formato {<top>, <left>, <bottom>, <right>} 
Local aPos		  	:= {019,002,118,322}                      
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
Local aCpoGDa       := {}
// Vetor com os campos que poderao ser alterados                                                                                
Local aAlter     	:= {""}
Local nSuperior    	:= 122           	// Distancia entre a MsNewGetDados e o extremidade superior do objeto que a contem
Local nEsquerda    	:= 002           	// Distancia entre a MsNewGetDados e o extremidade esquerda do objeto que a contem
Local nInferior    	:= 210          	// Distancia entre a MsNewGetDados e o extremidade inferior do objeto que a contem
Local nDireita     	:= 322           	// Distancia entre a MsNewGetDados e o extremidade direita  do objeto que a contem
// Posicao do elemento do vetor aRotina que a MsNewGetDados usara como referencia  
Local nOpc1        	:= GD_INSERT+GD_DELETE+GD_UPDATE                                                                            
Local cLinOk       	:= "AllwaysTrue"    // Funcao executada para validar o contexto da linha atual do aCols                  
Local cTudoOk      	:= "AllwaysTrue"    // Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)      
Local cIniCpos     	:= "+Z85_ITEM"       // Nome dos campos do tipo caracter que utilizarao incremento automatico.            
                                        // Este parametro deve ser no formato "+<nome do primeiro campo>+<nome do            
                                        // segundo campo>+..."                                                               
Local nFreeze      	:= 000              // Campos estaticos na GetDados.                                                               
Local nMax         	:= 99              // Numero maximo de linhas permitidas. Valor padrao 99                           
Local cFieldOk     	:= "AllwaysTrue"    // Funcao executada na validacao do campo                                           
Local cSuperDel     := ""              	// Funcao executada quando pressionada as teclas <Ctrl>+<Delete>                    
Local cDelOk        := "AllwaysFalse"   	// Funcao executada para validar a exclusao de uma linha do aCols                   

Local aObjects      := {}
Local aPosObj       := {}
Local aSize         := {}        

Local nUsado:=0

Local cCadastro:="Cadastro de Draft"

Local cAno:="" //Ano que se deseja alterar

// Variáveis utilizadas na seleção de categorias
Local oChkQual,lQual,oQual,cVarQ
// Carrega bitmaps
Local oOk := LoadBitmap( GetResources(), "LBOK")
Local oNo := LoadBitmap( GetResources(), "LBNO")

// Objeto no qual a MsNewGetDados sera criada                                      
Local aHeader	:= {}               // Array a ser tratado internamente na MsNewGetDados como aHeader                    
Private aCols   := {}               // Array a ser tratado internamente na MsNewGetDados como aCols

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

Private aColsAux:={}  
Private nPosSta	:=0


	/*Preenche o array com os campos que serão utilizados na Enchoice*/
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("Z86")
	While SX3->(!EOF()) .AND. SX3->X3_ARQUIVO=="Z86"
		
		if X3Uso(SX3->X3_USADO) .AND. !(SX3->X3_CAMPO $ "Z86_FILIAL/Z86_FILORI"+iif(nOpc<>5,"/Z86_MOTIVO",""))
			AADD(aCpoEnch,alltrim(SX3->X3_CAMPO))
			AADD(aAlterEnch,alltrim(SX3->X3_CAMPO))
		endif
			
		SX3->(DbSkip())
	Enddo

	AADD(aCpoEnch,"NOUSER")

	/*Preenche o array com os campos que serão utilizados no aHeader*/
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("Z85")
	While SX3->(!EOF()) .AND. SX3->X3_ARQUIVO=="Z85"
		
		if X3Uso(SX3->X3_USADO) .AND. !(SX3->X3_CAMPO $ "Z85_FILIAL/Z85_FILORI") 
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
		aAlter := {}
		aAlterEnch	:= {"Z86_VALOR","Z86_DESCON","Z86_VLRTOT"} 	   
	Case xParam3 == 5
		//DELETA := .T.
		ALTERA := .T.
		aAlterEnch	:= {"Z86_MOTIVO"}
		nOpc2:=4
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
DEFINE MSDIALOG oDlg TITLE cCadastro From 0,0 To 430,650 of oMainWnd PIXEL

RegToMemory(cAliasE,If(nOpc == 3,.T.,.F.), .T.)

 
Enchoice(cAliasE,nReg,nOpc2,/*aCRA*/,/*cLetra*/,/*cTexto*/,aCpoEnch,aPos,;
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
	AADD(aCols,Array(nUsado+1))
	For nI := 1 To nUsado
		if Alltrim(aHeader[nI,2]) == "Z85_ITEM"
			aCols[len(aCols)][nI] := "01"
		else
			aCols[len(aCols)][nI] := CriaVar(aHeader[nI][2])
		endif
	Next
	aCols[len(aCols)][nUsado+1] := .F.
Else

	DbSelectArea("Z86")
	Z86->(DbGoTo(nReg))
	cFilNum:= Z86->Z86_FILIAL+Z86->Z86_NUM
	
	aCols:={}
	dbSelectArea("Z85")
	dbSetOrder(1)
	dbSeek(cFilNum)
	While !eof().and.Z85_NUM==M->Z86_NUM
		AADD(aCols,Array(nUsado+1))
			For nX:=1 to nUsado
				aCols[Len(aCols),nX]:=FieldGet(FieldPos(aHeader[nX,2]))
			Next
		aCols[Len(aCols),nUsado+1]:=.F.
		Z85->(dbSkip())
	End
	
	nMax:=Len(aCols) //Tratamento para não permitir inserir mais linhas no alterar

EndIf                            

if nOpc==5

	aColsAux:=aCols
	nPosSta:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z85_STATUS"})
	if nPosSta<>0
		for i:=1 to len(aColsAux)
			AADD(aColsAux[i],"")
			AINS(aColsAux[i], 1) 
			AFILL( aColsAux[i] , iif(aColsAux[i][nPosSta+1]=="2",.T.,.F.), 1, 1)
		next
	endif
		
	@ nSuperior,nEsquerda LISTBOX oQual VAR cVarQ Fields HEADER "","Item","Produto","Descrição" SIZE;
	320,90 ON DBLCLICK (aColsAux:=Troca(oQual:nAt,aColsAux),oQual:Refresh()) NoScroll OF oDlg PIXEL
	
	oQual:SetArray(aColsAux)
	
	oQual:bLine := { || {If(aColsAux[oQual:nAt,1],oOk,oNo),aColsAux[oQual:nAt,2],aColsAux[oQual:nAt,3],aColsAux[oQual:nAt,4]}}

else

	oGetDados:= MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpc1,cLinOk,cTudoOk,cIniCpos,;                               
	                             aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oDlg,aHeader,aCols)              
endif
//Tratamento diferenciado para a empresa ZF
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| ;
iif(Grava(aHeader,IIF(nOpc==5,aColsAux,oGetDados:aCols),aCpoEnch,nOpc,aAlterEnch),oDlg:End(),);
},{||oDlg:End()}) CENTERED
         
Return(.T.)

/*
Funcao      : Grava()  
Parametros  : Header,aCols,cAno,nOpc,aAlterEnch
Retorno     : .T. ou .F.
Objetivos   : Função para gravação/alteração/Aprovação
Autor       : Matheus Massarotto
Data/Hora   : 28/06/2012
*/
*-----------------------------------------------*
Static Function Grava(aHeader,aCols,aCpoEnch,nOpc,aAlterEnch)
*-----------------------------------------------*
Local nPosVal	:=0
Local cNum		:=""
Local nPosGetDad:=0

if nOpc==3 //Incluir

	/*Valida o cabecalho*/
	if !Obrigatorio(aGets,aTela) 
		Return .F.
	endif
    
	/*Validação do preenchimento da GetDados*/
	nPosGetDad:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z85_PRODUT"}) 
 	for h:=1 to len(aCols)
    	if empty(aCols[h][nPosGetDad])
    		Alert("Existe linha com produto não preenchido!")
    		Return .F.
			Exit
    	endif
    next
	
	nPosNum:=Ascan(aCpoEnch,{|x| alltrim(x) = "Z86_NUM"}) 
	
	cNum:=ProxNum(M->Z86_TPCTR)
	
	//Gravando ENCHOICE
	RecLock("Z86",iif(nOpc==3,.T.,.F.)) 
		Z86->Z86_FILIAL	:=xFilial("Z86")
		
		if nOpc==3
			Z86->Z86_FILORI	:=cFilAnt
		endif
		
		for nx:=1 to len(aCpoEnch)-1
    		if nx==nPosNum
				Z86->&(aCpoEnch[nx]) := cNum
    		else
    			Z86->&(aCpoEnch[nx]) := M->&(aCpoEnch[nx])
    		endif
		next 
		Z86->Z86_DTINC:=ddatabase
    Z86->(MSUNLOCK())
    
    //GRAVANDO GETDADOS
		for i:=1 to len(aCols)
	    	RecLock("Z85",.T.)
	    		Z85->Z85_FILIAL:=xFilial("Z85")
	    		
	    		if nOpc==3
					Z85->Z85_FILORI	:=cFilAnt
				endif
	    		
	    		Z85->Z85_NUM:=cNum
	    		for j:=1 to len(aHeader)
	    			Z85->&(aHeader[j][2]):=aCols[i][j]
	    		next
	    	MsUnlock()
	    next
	MsgInfo("Foi gerado o draft: "+cNum)   

elseif nOpc==4 //Alterar

	//Gravando ENCHOICE
	RecLock("Z86",iif(nOpc==3,.T.,.F.)) 
		for nx:=1 to len(aAlterEnch)
    		Z86->&(aAlterEnch[nx]) := M->&(aAlterEnch[nx])
    	next
    Z86->(MSUNLOCK())

elseif nOpc==5 //Aprovar
    //Gravando a aprovação
	Private lApro:=.F.
	Private lRecu:=.F.
	
	DbSelectArea("Z85")
	Z85->(DbSetOrder(1))
	
	for k:=1 to len(aCols)
		if DbSeek(M->Z86_FILIAL+M->Z86_NUM+aCols[k][2]+aCols[k][3])
			RecLock("Z85",.F.)
				if aCols[k][1]
					Z85->Z85_STATUS:="2" 
					lApro:=.T.
				else
					Z85->Z85_STATUS:="3"
					lRecu:=.T.
				endif
			MsUnlock()
		endif
	next
	
	/*Verifica se nenhum está marcado, e o campo Z86_MOTIVO está preenchido*/
	if !lApro .AND. lRecu .AND. empty(M->Z86_MOTIVO)
		Alert("Campo motivo deve ser preenchido!")
		Return(.F.)		
	endif
	//Grava o motivo na tabela
	if !empty(M->Z86_MOTIVO)
		RecLock("Z86",.F.)
			Z86->Z86_MOTIVO:=M->Z86_MOTIVO
		MsUnLock()
	endif
	
		/*Atualiza o status da capa das Propostas*/
		if lApro .AND. !lRecu
			RecLock("Z86",.F.)
				Z86->Z86_STATUS:="2"
				Z86->Z86_DTAPRO:=ddatabase
			MsUnLock()
		endif
		/*Fim do Atualiza o status da capa das Propostas*/
endif

Return(.T.)
/*
Funcao      : ProxNum()  
Parametros  : cTipoCtr
Retorno     : cRet
Objetivos   : Função Retornar a sequencia disponível para a Draft
Autor       : Matheus Massarotto
Data/Hora   : 28/06/2012
*/
*-------------------------------*
Static Function ProxNum(cTipoCtr)
*-------------------------------*
Local cRet		:=""
Local cAnoAtu	:= Right(Str(Year(Date())),2) //Retora o ano atual (2 digitos)
Local cQry		:=""
Local aCbox		:={}
Local nAt		:=""
Local nPos		:=0
Local cDescOpc	:=""
Local cSeq		:="0001"

DEFAULT cTipoCtr:=""

	SX3->(DbSetOrder(2))
	If SX3->(DbSeek("Z86_TPCTR"))
	
		cCbox := AllTrim(SX3->X3_CBOX)
		nAt := At(";",cCbox)
		While nAt > 0
			cAux  := Left(cCbox,nAt-1)
											
			aAdd(aCbox,{Left(cAux,1),Substr(cAux,3)}) 
											
			cCbox := Substr(cCbox,nAt+1)
			nAt := At(";",cCbox)
		EndDo
		cAux  := cCbox
		aAdd(aCbox,{Left(cAux,1),Substr(cAux,3)}) 			
	EndIf

	nPos := aScan(aCbox,{|a| Alltrim(a[1])== AllTrim(cTipoCtr)})
	if nPos > 0
		cDescOpc := SUBSTR(aCbox[nPos][2],1,3)
	endif
	
	/*MONTAGEM DA QUERY*/
	cQry:=" SELECT MAX(SUBSTRING(LTRIM(Z86_NUM),4,4)) AS SEQ FROM "+RETSQLNAME("Z86")+CRLF
	cQry+=" WHERE D_E_L_E_T_='' AND LEFT(RIGHT(RTRIM(Z86_NUM),4),2)='"+cAnoAtu+"' AND LEFT(LTRIM(Z86_NUM),3)='"+cDescOpc+"'"
		
		if select("QRYTEMP")>0
			QRYTEMP->(DbCloseArea())
		endif
		
		DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )
		
		Count to nRecCount
        
		if nRecCount >0
        	QRYTEMP->(DbGotop())
        	cSeq:=SOMA1(QRYTEMP->SEQ)
        endif

cRet:=cDescOpc+cSeq+"/"+alltrim(cAnoAtu)+" D"

Return(cRet)

/*
Funcao      : LEGZ86()  
Parametros  : cTipoCtr
Retorno     : 
Objetivos   : Função para exibição da legenda
Autor       : Matheus Massarotto
Data/Hora   : 28/06/2012
*/
*--------------------*
User Function LEGZ86()
*--------------------*
Local aLegenda := {	{"BR_AMARELO"  ,"Pendente             	" },;
					{"BR_CINZA"    ,"Em proposta	   	  	" },;
					{"BR_VERDE"    ,"Aprovado	       	  	" }}

BrwLegenda("Legenda","Status do Draft",aLegenda)

Return   

/*
Funcao      : Troca  
Parametros  : nIt,aArray
Retorno     : aArray
Objetivos   : Função para trocar a Lógica do primeiro campo, (.T. / .F.), mudando assim a imagem do check
Autor       : Matheus Massarotto
Data/Hora   : 28/06/2012
*/
*-------------------------------*
Static Function Troca(nIt,aArray)
*-------------------------------*
aArray[nIt,1] := !aArray[nIt,1]
Return aArray 

/*
Funcao      : Z86_PROS
Parametros  : 
Retorno     : lRet
Objetivos   : Função para validar se o prospect já é cliente
Autor       : Matheus Massarotto
Data/Hora   : 02/07/2012
*/
*-------------------------------*
User Function Z86_PROS()
*-------------------------------*
Local lRet		:= .T.
Local cSta		:= POSICIONE("SUS",1,xFilial("SUS")+M->Z86_PROSPE+M->Z86_PLOJA,"US_STATUS")
Local cCodCli	:= SUS->US_CODCLI
Local cConfli	:= SUS->US_P_CONFL

if alltrim(cSta)=='6'
	Alert("Prospect já é cliente com código: "+cCodCli)
	lRet:=.F.
elseif cConfli=='1'
	Alert("Prospect já está com conflito confirmado!"+CRLF+"Por favor inclua uma Proposta!")
	lRet:=.F.	
endif

Return lRet 
