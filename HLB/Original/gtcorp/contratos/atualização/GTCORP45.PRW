#Include "Protheus.ch"
#Include "TopConn.ch"

/*
Funcao      : GTCORP45
Parametros  : Nil                      
Retorno     : Nil
Objetivos   : Função Mbrowse da tabela Z74, Cadastro de Draft
Autor       : Matheus Massarotto
Data/Hora   : 19/09/2012    10:14
Revisão		:                    
Data/Hora   : 
Módulo      : Gestão de Contratos
*/
*-----------------------*
User Function GTCORP45()
*-----------------------*
Local cString:="Z74"
Private aRotina:={}

if !TCCANOPEN("Z74"+cEmpAnt+"0")
	Alert("Rotina não disponível para esta empresa!")
	Return()
endif
  
AADD( aRotina, { "Pesquisar"	, "AxPesqui"  		, 0 , 1 } ) 
AADD( aRotina, { "Visualizar"	, 'U_GTCORP44("Z74",RECNO(),2)' 	, 0 , 2 } ) 
AADD( aRotina, { "Incluir"		, 'U_GTCORP44("Z74",RECNO(),3)' 	, 0 , 3 } ) 
AADD( aRotina, { "Alterar"		, 'U_GTCORP44("Z74",RECNO(),4)' 	, 0 , 4 } ) 
AADD( aRotina, { "Recusar"		, 'U_GTCORP44("Z74",RECNO(),5)' 	, 0 , 5 } )
AADD( aRotina, { "Legenda"		, 'U_LEGZ74'  						, 0 , 6 } )

Private aCores:={}

aCores := {{"Z74_STATUS == '1' .OR. Z74_STATUS == ' ' ", "BR_AMARELO" },; // Pendente
		   {"Z74_STATUS == '2'", "BR_VERDE" 	},; 	// Aprovado
           {"Z74_STATUS == '3'", "BR_CINZA"   	},; 	// Em proposta
			{"Z74_STATUS == '4'", "BR_VERMELHO" }} 		// Recusado

DbSelectArea(cString) 
DbSetOrder(1)
MBrowse( 6,1,22,75,cString,,,,,,aCores)
 
Return

/*
Funcao      : GTCORP44()  
Parametros  : xParam1,xParam2,xParam3
Retorno     : .T.
Objetivos   : Montagem da tela para manutenção das informações da Tabela Z74 e Z73 (Enchoice e Getdados)
Autor       : Matheus Massarotto
Data/Hora   : 20/08/2012
*/
*----------------------------------------------*
User Function GTCORP44(xParam1,xParam2,xParam3) 
*----------------------------------------------*
Local cAliasE := xParam1           // Tabela cadastrada no Dicionario de Tabelas (SX2) que sera editada
// Vetor com nome dos campos que serao exibidos. Os campos de usuario sempre serao              
// exibidos se nao existir no parametro um elemento com a expressao "NOUSER"                    
Local aCpoEnch  	:= {}
Local aAlterEnch	:= {}
Local nOpc    		:= nOpc2:= xParam3 	// Numero da linha do aRotina que definira o tipo de edicao (Inclusao, Alteracao, Exclucao, Visualizacao)
Local nReg    		:= xParam2	// Numero do Registro a ser Editado/Visualizado (Em caso de Alteracao/Visualizacao)
// Vetor com coordenadas para criacao da enchoice no formato {<top>, <left>, <bottom>, <right>} 
Local aPos		  	:= {012,002,161,422}//{019,002,118,322}
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
Local nSuperior    	:= 165 //122       	// Distancia entre a MsNewGetDados e o extremidade superior do objeto que a contem
Local nEsquerda    	:= 002 //002       	// Distancia entre a MsNewGetDados e o extremidade esquerda do objeto que a contem
Local nInferior    	:= 253 //210       	// Distancia entre a MsNewGetDados e o extremidade inferior do objeto que a contem
Local nDireita     	:= 422 //322       	// Distancia entre a MsNewGetDados e o extremidade direita  do objeto que a contem
// Posicao do elemento do vetor aRotina que a MsNewGetDados usara como referencia  
Local nOpc1        	:= GD_INSERT+GD_DELETE+GD_UPDATE                                                                            
Local cLinOk       	:= "AllwaysTrue"    // Funcao executada para validar o contexto da linha atual do aCols                  
Local cTudoOk      	:= "AllwaysTrue"    // Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)      
Local cIniCpos     	:= "+Z73_ITEM"       // Nome dos campos do tipo caracter que utilizarao incremento automatico.            
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

Private aColsAux:={}  
Private nPosSta	:=0
Private aButtons:={}

AADD( aButtons, {"SDUIMPORT", {|| ServPAcol()}, "Servicos...","Servicos",{|| .T.}} )

	/*Preenche o array com os campos que serão utilizados na Enchoice*/
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("Z74")
	While SX3->(!EOF()) .AND. SX3->X3_ARQUIVO=="Z74"
		
		if X3Uso(SX3->X3_USADO) .AND. !(SX3->X3_CAMPO $ "Z74_FILIAL"+iif(nOpc<>5 .AND. nOpc<>2,"/Z74_MOTIVO","")+iif(nOpc<>4 .AND. nOpc<>2,"/Z74_MOTALT",""))
			AADD(aCpoEnch,alltrim(SX3->X3_CAMPO))
			AADD(aAlterEnch,alltrim(SX3->X3_CAMPO))
		endif
			
		SX3->(DbSkip())
	Enddo

	AADD(aCpoEnch,"NOUSER")

	/*Preenche o array com os campos que serão utilizados no aHeader*/
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("Z73")
	While SX3->(!EOF()) .AND. SX3->X3_ARQUIVO=="Z73"
		
		if X3Uso(SX3->X3_USADO) .AND. !(SX3->X3_CAMPO $ "Z73_FILIAL") 
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
		aAlterEnch	:= {"Z74_VALOR","Z74_DESCON","Z74_VLRTOT","Z74_DESPER","Z74_DESCON","Z74_TPVLR","Z74_VLRTOT","Z74_MOTALT"} 	   
	Case xParam3 == 5
		//DELETA := .T.
		ALTERA := .T.
		aAlter := {}
		aAlterEnch	:= {"Z74_MOTIVO"}
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
DEFINE MSDIALOG oDlg TITLE cCadastro From 0,0 To 530,850 of oMainWnd PIXEL
                                                 //430,650
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

//Tratamento para não deixar alterar drafts recusadas ou aprovadas
if nOpc==4 .OR. nOpc==5
	if Z74->Z74_STATUS $ '2'
		ACTIVATE MSDIALOG oDlg ON INIT oDlg:end()
		Alert("Opção não disponível para draft com status 'Aprovado'")
		Return()
	elseif Z74->Z74_STATUS $ '3'
		ACTIVATE MSDIALOG oDlg ON INIT oDlg:end()
		Alert("Opção não disponível para draft com status 'Em Proposta'")
		Return()
	elseif Z74->Z74_STATUS $ '4'
		ACTIVATE MSDIALOG oDlg ON INIT oDlg:end()
		Alert("Opção não disponível para draft com status 'Recusado'")
		Return()
	endif
endif

//Carrega as variáveis no aCols de acordo com a opção selecionada       
If nOpc == 3
	AADD(aCols,Array(nUsado+1))
	For nI := 1 To nUsado
		if Alltrim(aHeader[nI,2]) == "Z73_ITEM"
			aCols[len(aCols)][nI] := "01"
		else
			aCols[len(aCols)][nI] := CriaVar(aHeader[nI][2])
		endif
	Next
	aCols[len(aCols)][nUsado+1] := .F.
Else

	DbSelectArea("Z74")
	Z74->(DbGoTo(nReg))
	cFilNum:= Z74->Z74_FILIAL+Z74->Z74_NUM
	
	aCols:={}
	dbSelectArea("Z73")
	dbSetOrder(1)
	dbSeek(cFilNum)
	While !eof().and.Z73_NUM==M->Z74_NUM .AND. Z74_FILIAL==xFilial("Z74")
		AADD(aCols,Array(nUsado+1))
			For nX:=1 to nUsado
				aCols[Len(aCols),nX]:=FieldGet(FieldPos(aHeader[nX,2]))
			Next
		aCols[Len(aCols),nUsado+1]:=.F.
		Z73->(dbSkip())
	End
	
	nMax:=Len(aCols) //Tratamento para não permitir inserir mais linhas no alterar

EndIf                            

if nOpc==5

/*	aColsAux:=aCols
	nPosSta:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z73_STATUS"})
	if nPosSta<>0
		for i:=1 to len(aColsAux)
			AADD(aColsAux[i],"")
			AINS(aColsAux[i], 1) 
			AFILL( aColsAux[i] , iif(aColsAux[i][nPosSta+1]=="2",.T.,.F.), 1, 1)
		next
	endif
		
	@ nSuperior,nEsquerda LISTBOX oQual VAR cVarQ Fields HEADER "","Item","Departamento","Descrição","Area","Descrição","Servico","Descrição","Volume" SIZE;
	420,90 ON DBLCLICK (aColsAux:=Troca(oQual:nAt,aColsAux),oQual:Refresh()) NoScroll OF oDlg PIXEL
	//320,90
	oQual:SetArray(aColsAux)
	
	oQual:bLine := { || {If(aColsAux[oQual:nAt,1],oOk,oNo),aColsAux[oQual:nAt,2],aColsAux[oQual:nAt,3],aColsAux[oQual:nAt,4],aColsAux[oQual:nAt,5],aColsAux[oQual:nAt,6],aColsAux[oQual:nAt,7],aColsAux[oQual:nAt,8],aColsAux[oQual:nAt,9]}}
*/
	oGetDados:= MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpc1,cLinOk,cTudoOk,cIniCpos,;
	                             aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oDlg,aHeader,aCols)
else

	oGetDados:= MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpc1,cLinOk,cTudoOk,cIniCpos,;
	                             aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oDlg,aHeader,aCols)
endif


//Tratamento diferenciado para a empresa ZF
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| ;
iif(Grava(aHeader,IIF(nOpc==5,aColsAux,oGetDados:aCols),aCpoEnch,nOpc,aAlterEnch),oDlg:End(),);
},{||oDlg:End()},,aButtons) CENTERED
         
Return(.T.)

/*
Funcao      : Grava()  
Parametros  : Header,aCols,cAno,nOpc,aAlterEnch
Retorno     : .T. ou .F.
Objetivos   : Função para gravação/alteração/Aprovação
Autor       : Matheus Massarotto
Data/Hora   : 20/08/2012
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

    /*Valida se o valor é diferente de 0(zero)*/
    if empty(M->Z74_VALOR) .OR. empty(M->Z74_VLRTOT)
		Alert("Campo valor deve ser preenchido!")
   		Return .F.
    endif
  
	/*Validação do preenchimento da GetDados*/
	nPosGetDep:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z73_DEPART"})
	nPosGetAre:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z73_AREA"})
	nPosGetSer:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z73_SERVIC"})
	nPosGetVol:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z73_VOLUME"})
		
 	for h:=1 to len(aCols)

    	if nPosGetDep>0
    		if empty(aCols[h][nPosGetDep])
	    		Alert("Existe linha com Departamento não preenchido!")
	    		Return .F.
				Exit
			endif
		endif
    	if nPosGetAre>0
    		if empty(aCols[h][nPosGetAre])
	    		Alert("Existe linha com Area não preenchida!")
	    		Return .F.
				Exit
			endif
		endif
    	if nPosGetSer>0
    		if empty(aCols[h][nPosGetSer])
	    		Alert("Existe linha com Serviço não preenchido!")
	    		Return .F.
				Exit
			endif
    	endif
    	if nPosGetVol>0
    		if empty(aCols[h][nPosGetVol])
	    		Alert("Existe linha com Volume não informado!")
	    		Return .F.
				Exit
			endif
    	endif

    next
	
	nPosNum		:= Ascan(aCpoEnch,{|x| alltrim(x) = "Z74_NUM"}) 
	nPosVlrIni	:= Ascan(aCpoEnch,{|x| alltrim(x) = "Z74_VLRINI"})
	nPosValor	:= Ascan(aCpoEnch,{|x| alltrim(x) = "Z74_VALOR"})
		
	cNum:=ProxNum(M->Z74_TPCTR)
	
	BEGIN TRANSACTION	
		//Gravando ENCHOICE
		RecLock("Z74",iif(nOpc==3,.T.,.F.)) 
			Z74->Z74_FILIAL	:=xFilial("Z74")
			for nx:=1 to len(aCpoEnch)-1
	    		if nx==nPosNum
					Z74->&(aCpoEnch[nx]) := cNum
	    		elseif nx==nPosVlrIni
	    			Z74->&(aCpoEnch[nx]) := M->&(aCpoEnch[nPosValor])
	    		else
	    			Z74->&(aCpoEnch[nx]) := M->&(aCpoEnch[nx])
	    		endif
			next 
			Z74->Z74_DTINC:=ddatabase
	    Z74->(MSUNLOCK())
	    
	    //GRAVANDO GETDADOS
			for i:=1 to len(aCols)
		    	RecLock("Z73",.T.)
		    		Z73->Z73_FILIAL:=xFilial("Z73")
		    		Z73->Z73_NUM:=cNum
		    		for j:=1 to len(aHeader)
		    			Z73->&(aHeader[j][2]):=aCols[i][j]
		    		next
		    	MsUnlock()
		    next
		//GRAVANDO TABELA DE SEQUENCIA DE NUMERACAO
			DbSelectArea("Z77")
			DbSetOrder(1)
			if !DbSeek(xFilial("Z77")+cNum)
				RecLock("Z77",.T.) 
					Z77->Z77_FILIAL	:=xFilial("Z77")
					Z77->Z77_NUM := cNum
			    Z77->(MSUNLOCK())
			endif

	END TRASACTION
	  
	MsgInfo("Foi gerado o draft: "+cNum)   

elseif nOpc==4 //Alterar

	/*Verifica se nenhum está marcado, e o campo Z79_MOTIVO está preenchido*/
	if empty(M->Z74_MOTALT)
		Alert("Campo motivo deve ser preenchido!")
		Return(.F.)		
	endif

	//Gravando ENCHOICE
	RecLock("Z74",iif(nOpc==3,.T.,.F.)) 
		for nx:=1 to len(aAlterEnch)
    		Z74->&(aAlterEnch[nx]) := M->&(aAlterEnch[nx])
    	next
    Z74->(MSUNLOCK())

elseif nOpc==5 //Reprovar
    //Gravando a reprovação
	
	DbSelectArea("Z73")
	Z73->(DbSetOrder(1))
	
	for k:=1 to len(aCols)
		if DbSeek(M->Z74_FILIAL+M->Z74_NUM+aCols[k][2]+aCols[k][3])
			RecLock("Z73",.F.)
				Z73->Z73_STATUS:="3" //Recusado
			MsUnlock()
		endif
	next
	
	/*Verifica se o campo Z74_MOTIVO não está preenchido*/
	if empty(M->Z74_MOTIVO)
		Alert("Campo motivo deve ser preenchido!")
		Return(.F.)		
	endif
	//Grava o motivo na tabela
	if !empty(M->Z74_MOTIVO)
		RecLock("Z74",.F.)
			Z74->Z74_MOTIVO:=M->Z74_MOTIVO
		MsUnLock()
	endif

	/*Atualiza o status da capa das Propostas*/
		RecLock("Z74",.F.)
			Z74->Z74_STATUS:="4" //Recusado
			Z74->Z74_DTAPRO:=ddatabase
		MsUnLock()

	/*Fim do Atualiza o status da capa das Propostas*/
	
endif

Return(.T.)
/*
Funcao      : ProxNum()  
Parametros  : cTipoCtr
Retorno     : cRet
Objetivos   : Função Retornar a sequencia disponível para a proposta
Autor       : Matheus Massarotto
Data/Hora   : 20/08/2012
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
	If SX3->(DbSeek("Z74_TPCTR"))
	
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
	//cQry:=" SELECT MAX(SUBSTRING(LTRIM(Z74_NUM),4,4)) AS SEQ FROM "+RETSQLNAME("Z74")+CRLF
	//cQry+=" WHERE D_E_L_E_T_='' AND RIGHT(RTRIM(Z74_NUM),2)='"+cAnoAtu+"' AND LEFT(LTRIM(Z74_NUM),3)='"+cDescOpc+"'"

	cQry:=" SELECT MAX(SUBSTRING(LTRIM(Z77_NUM),4,4)) AS SEQ FROM "+RETSQLNAME("Z77")+CRLF
	cQry+=" WHERE D_E_L_E_T_='' AND RIGHT(RTRIM(Z77_NUM),2)='"+cAnoAtu+"' AND LEFT(LTRIM(Z77_NUM),3)='"+cDescOpc+"' AND Z77_FILIAL='"+xFilial("Z77")+"'"
		
		if select("QRYTEMP")>0
			QRYTEMP->(DbCloseArea())
		endif
		
		DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )
		
		Count to nRecCount
        
		if nRecCount >0
        	QRYTEMP->(DbGotop())
        	cSeq:=SOMA1(QRYTEMP->SEQ)
        endif

cRet:=cDescOpc+cSeq+"/"+cAnoAtu

Return(cRet)

/*
Funcao      : LEGZ74()  
Parametros  : cTipoCtr
Retorno     : 
Objetivos   : Função para exibição da legenda
Autor       : Matheus Massarotto
Data/Hora   : 20/08/2012
*/
*--------------------*
User Function LEGZ74()
*--------------------*
Local aLegenda := {	{"BR_AMARELO"  ,"Pendente             	" },;
					{"BR_CINZA"    ,"Em proposta	   	  	" },;
					{"BR_VERDE"    ,"Aprovado	       	  	" },;
					{"BR_VERMELHO" ,"Recusado				" }}

BrwLegenda("Legenda","Status da Proposta",aLegenda)

Return   

/*
Funcao      : Troca  
Parametros  : nIt,aArray
Retorno     : aArray
Objetivos   : Função para trocar a Lógica do primeiro campo, (.T. / .F.), mudando assim a imagem do check
Autor       : Matheus Massarotto
Data/Hora   : 20/08/2012
*/
*-------------------------------*
Static Function Troca(nIt,aArray)
*-------------------------------*
aArray[nIt,1] := !aArray[nIt,1]
Return aArray

/*
Funcao      : Z74_PROS
Parametros  : 
Retorno     : lRet
Objetivos   : Função para validar se o prospect tem o conflito confirmado
Autor       : Matheus Massarotto
Data/Hora   : 03/07/2012
*/
*-------------------------------*
User Function Z74_PROS()
*-------------------------------*
Local lRet		:= .T.
Local cSta		:= POSICIONE("SUS",1,xFilial("SUS")+M->Z74_PROSPE+M->Z74_PLOJA,"US_STATUS")
Local cCodCli	:= SUS->US_CODCLI
Local cConfli	:= SUS->US_P_CONFL

if alltrim(cSta)=='6'
	Alert("Prospect já é cliente com código: "+cCodCli)
	lRet:=.F.
endif

Return lRet

/*
Funcao      : VALIDZ73
Parametros  : cAlias,cChave,nOrdem
Retorno     : lRet
Objetivos   : 
Autor       : Matheus Massarotto
Data/Hora   : 17/08/2012
*/

User function VALIDZ73(cAlias,cChave,nOrdem)
Local xAlias,nSalvReg,nOldOrder,lRet

If ValType(cChave) == "U"
	cChave := &(ReadVar())
EndIf

xAlias := Alias()

DbSelectArea(cAlias)
nOldOrder := IndexOrd()

If Eof() .Or. RecC() == 0
	nSalvReg := 0
Else
	nSalvReg := RecNo()
EndIf

nOrdem := If(nOrdem == NIL,1,nOrdem)
DbSetOrder(nOrdem)
lRet := DbSeek(xFilial(cAlias)+cChave)

If nSalvReg > 0
	DbGoTo(nSalvReg)
EndIf

DbSetOrder(nOldOrder)
DbSelectArea(xAlias)


Return lRet

/*
Funcao      : Z73PZ80
Parametros  : cVerif
Retorno     : lRet
Objetivos   : 
Autor       : Matheus Massarotto
Data/Hora   : 20/08/2012
*/
*-------------------------------*
User Function Z73PZ80(cVerif)
*-------------------------------*
Local lRet	:=.T.

DbSelectArea("Z80")
DbSetOrder(1)
if !DbSeek(xFilial("Z80")+cVerif)
	lRet:=.F.
	alert("Verifique as opções permitidas para esta operação"+CRLF+"Clicando na lupa, ou pressionando F3.","Atenção")
endif

Return lRet

/*
Funcao      : Z73VOLUME
Parametros  : 
Retorno     : lRet
Objetivos   : 
Autor       : Matheus Massarotto
Data/Hora   : 20/08/2012
*/
User function Z73VOLUME
Local cRet		:=""
Local nHora		:=0
Local nTotal	:=0
Local nPosVol	:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z73_VOLUME"})
Local nPosSer	:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z73_SERVIC"})

DbSelectArea("Z81")
DbSetOrder(1)

For i:=1 to len(aCols)
	if DbSeek(xFilial("Z81")+aCols[i][nPosSer])
		nHora	:=HTON(Z81->Z81_TEMPO)
		nTotal	+=(nHora*aCols[i][nPosVol])
	endif
Next

cRet	:=NTOH(nTotal)
M->Z74_TIME:=cRet

//para atualizar a tela com os dados novos
GetDRefresh()	

return(cRet)


/*
Funcao      : ServPAcol
Parametros  : 
Retorno     : lRet
Objetivos   : Função para preencher o aCols da rotina principal com auxilio da rotina U_GTF3Z80
Autor       : Matheus Massarotto
Data/Hora   : 08/10/2012
*/
*------------------------*
Static function ServPAcol
*------------------------*
Local aArray	:={}
Local nII		:="00"
Local nUsado	:=len(oGetDados:aHeader)

aArray	:= U_GTF3Z80()  //chama rotina com os serviços para escolha.
aCols	:= oGetDados:aCols

	if len(aCols)>0
	    for u:=len(aCols) to 1 Step -1
		    
		    for v:=1 to len(aCols[u])-1
				if Alltrim(aHeader[v,2])=="Z73_SERVIC"
					if empty(aCols[u][v])
						aSize(aCols,len(aCols)-1)
					endif
				endif
			next
			
		next
	endif


if !empty(aCols)
	nII:=aCols[Len(aCols)][1]
else
	nII:="00"
	aCols:={}
endif

	for nSeqI:=1 to len(aArray)
		if !empty(aArray[nSeqI][1]) .AND. !aArray[nSeqI][len(aArray[nSeqI])]
   	
		   	AADD(aCols,Array(nUsado+1))
			nII:=SOMA1(nII)
			for nSeqJ:=1 to len(aCols[Len(aCols)])-1
				if nSeqJ==1
					aCols[Len(aCols)][nSeqJ]:=nII
				elseif Alltrim(aHeader[nSeqJ,2])=="Z73_DEPART" //nSeqJ==2 // Código do Departamento
					aCols[Len(aCols)][nSeqJ]:=aArray[nSeqI][5]
				elseif Alltrim(aHeader[nSeqJ,2])=="Z73_DESCDE" //nSeqJ==3 // Descrição do Departamento
					aCols[Len(aCols)][nSeqJ]:=aArray[nSeqI][6]
				elseif Alltrim(aHeader[nSeqJ,2])=="Z73_AREA" //nSeqJ==4 // Código da Área
					aCols[Len(aCols)][nSeqJ]:=aArray[nSeqI][3]
				elseif Alltrim(aHeader[nSeqJ,2])=="Z73_DESCAR" //nSeqJ==5 // Descrição da Área
					aCols[Len(aCols)][nSeqJ]:=aArray[nSeqI][4]
				elseif Alltrim(aHeader[nSeqJ,2])=="Z73_SERVIC" //nSeqJ==6 // Código do Serviço
					aCols[Len(aCols)][nSeqJ]:=aArray[nSeqI][1]
				elseif Alltrim(aHeader[nSeqJ,2])=="Z73_DESCSE" //nSeqJ==7 // Descrição do Serviço
					aCols[Len(aCols)][nSeqJ]:=aArray[nSeqI][2]
				elseif Alltrim(aHeader[nSeqJ,2])=="Z73_VOLUME" //nSeqJ==8 // Volume
					aCols[Len(aCols)][nSeqJ]:=0
				else
					aCols[Len(aCols)][nSeqJ]:=""
				endif
			next
			aCols[Len(aCols)][nUsado+1] := .F.
		endif

	next

oGetDados:aCols:=aCols

Return
