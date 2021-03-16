#INCLUDE "PROTHEUS.CH"

/*
Funcao      : GTCORP46
Parametros  : nRec
Retorno     : Nil
Objetivos   : Fonte que imprimi o dot com a proposta selecionada 
Autor       : Matheus Massarotto
Data/Hora   : 08/10/2012    11:20
Revisão		:                    
Data/Hora   : 
Módulo      : Gestão de Contratos
*/

*--------------------------*
User Function GTCORP46(nRec)
*--------------------------*
// Variaveis Locais da Funcao
Local cPerg:=""

// Variaveis Private da Funcao
Private oDlgAu				// Dialog Principal

//Definindo perguntas
cPerg:=DefPerg()

Pergunte(cPerg,.F.)

DEFINE MSDIALOG oDlgAu TITLE "Impressão" FROM C(214),C(324) TO C(397),C(831) PIXEL

	// Cria as Groups do Sistema
	@ C(002),C(006) TO C(058),C(247) LABEL "Informativo" PIXEL OF oDlgAu

	// Cria Componentes Padroes do Sistema
	//@ C(011),C(012) MsGet oGet1 Var cGet1 Size C(230),C(041) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgAu
	@ C(012),C(012) Say "Esta rotina tem por objetivo imprimir a proposta/draft através de documento pré-configurado(modelo do word .dot) com auxílio das informações configuradas através dos parâmetros abaixo:" Size C(229),C(041) COLOR CLR_BLACK PIXEL OF oDlgAu
	
	@ C(068),C(024) Button "Parametros" Size C(037),C(012) action(ParamZ72()) PIXEL OF oDlgAu
	@ C(068),C(110) Button "Variaveis" Size C(037),C(012) action(Pergunte(cPerg,.T.)) PIXEL OF oDlgAu
	@ C(068),C(193) Button "Imprimir" Size C(037),C(012) action(Imprimir(nRec),oDlgAu:end()) PIXEL OF oDlgAu

	// Cria ExecBlocks dos Componentes Padroes do Sistema

ACTIVATE MSDIALOG oDlgAu CENTERED 

Return(.T.)

/*
Funcao      : Imprimir()  
Parametros  : nRec
Retorno     : .T.
Objetivos   : Função auxiliar para imprimir o dot
Autor       : Matheus Massarotto
Data/Hora   : 08/10/2012
*/
*----------------------------*
Static Function Imprimir(nRec)
*----------------------------*
Local lImpress      := .F.
Local cArqSaida     := MV_PAR02 //"C:\teste\testemodel.doc"
Local cArqWord		:= MV_PAR01 //"C:\teste\Modelo_TESTE.dot"
Local nCopias		:= 1


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa o Ole com o MS-Word 97 ( 8.0 )						      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oWord	:= OLE_CreateLink() ; OLE_NewFile( oWord , cArqWord )

//	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//  ³ Carrega Campos Disponiveis para Edicao                       ³
//	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aCampos := fCpos_Word()

DbSelectArea("Z79")
DbSetOrder(1)
Z79->(DbGoTo(nRec))

DbSelectArea("Z78")


//	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//  ³ Ajustando as Variaveis do Documento                          ³
//	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

for nK:=1 to len(aCampos)
	OLE_SetDocumentVar(oWord,&('"'+aCampos[nK][1]+'"'), iif( AT("->",aCampos[nK][2])>0,aCampos[nK][2],&(SUBSTRING(aCampos[nK][2],1,3)+"->"+aCampos[nK][2]) ) )
next

//	OLE_SetDocumentVar(oWord,"GPE", "Microsiga Software S/A")


//		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//      ³ Atualiza as Variaveis                                        ³
// 		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        OLE_UpDateFields( oWord )

//	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//	³Imprimindo o Documento                                                 ³
//	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF lImpress
			For nX := 1 To nCopias
				OLE_SetProperty( oWord, '208', .F. ) ; OLE_PrintFile( oWord )
			Next nX
		Else
			OLE_SaveAsFile( oWord, cArqSaida )
		EndIF


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Encerrando o Link com o Documento                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
OLE_CloseLink( oWord )
//If Len(cAux) > 0
//	fErase(carqword)
//Endif

Return(.T.)

/*
Funcao      : fCpos_Word()  
Parametros  : 
Retorno     : aExp
Objetivos   : Função para buscar as variáveis definidas na tabela Z72
Autor       : Matheus Massarotto
Data/Hora   : 08/10/2012
*/

*------------------------*
Static Function fCpos_Word
*------------------------*
Local aExp			:= {}

DbSelectArea("Z72")
DbSetOrder(1)
Z72->(DbGotop())

While Z72->(!EOF())

//aAdd( aExp, {'GPE'				,	SRA->RA_FILIAL 										  	, "SRA->RA_FILIAL"			,STR0013	} ) 
	aAdd( aExp, {alltrim(Z72->Z72_VARUSR),	alltrim(Z72->Z72_VARSIS)						  	, '"'+alltrim(Z72->Z72_VARSIS)+'"'			,Z72->Z72_DESCRI } ) 

	Z72->(DbSkip())
Enddo

Return(aExp)

/*
Funcao      : ParamZ72()  
Parametros  : 
Retorno     : aExp
Objetivos   : Função para carregar a tela com as variáveis buscadas na tabela Z72
Autor       : Matheus Massarotto
Data/Hora   : 08/10/2012
*/

*----------------------*
Static Function ParamZ72 
*----------------------*
Private oDlgZ72
Private oGetDdsZ72

DEFINE MSDIALOG oDlgZ72 TITLE "Variáveis do Arquivo" FROM C(188),C(285) TO C(675),C(748) PIXEL

	// Cria Componentes Padroes do Sistema
	@ C(224),C(028) Button "Ok" Size C(037),C(012) action( IIF(GravaZ72(),oDlgZ72:end(),) ) PIXEL OF oDlgZ72
	@ C(224),C(162) Button "Cancelar" Size C(037),C(012) action(oDlgZ72:end()) PIXEL OF oDlgZ72

	// Chamadas das GetDados do Sistema
	fGetDados1()

ACTIVATE MSDIALOG oDlgZ72 CENTERED 

Return

/*
Funcao      : fGetDados1()  
Parametros  : 
Retorno     : aExp
Objetivos   : Montagem da GetDados
Autor       : Matheus Massarotto
Data/Hora   : 08/10/2012
*/
*--------------------------*
Static Function fGetDados1()
*--------------------------*
// Variaveis deste Form                                                                                                         
Local nX			:= 0                                                                                                              
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis da MsNewGetDados()      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Vetor responsavel pela montagem da aHeader
Local aCpoGDa       	:= {}                                                                                                 
// Vetor com os campos que poderao ser alterados                                                                                
Local aAlter       	:= {""}
Local nSuperior    	:= C(006)           // Distancia entre a MsNewGetDados e o extremidade superior do objeto que a contem
Local nEsquerda    	:= C(009)           // Distancia entre a MsNewGetDados e o extremidade esquerda do objeto que a contem
Local nInferior    	:= C(216)           // Distancia entre a MsNewGetDados e o extremidade inferior do objeto que a contem
Local nDireita     	:= C(224)           // Distancia entre a MsNewGetDados e o extremidade direita  do objeto que a contem
// Posicao do elemento do vetor aRotina que a MsNewGetDados usara como referencia  
Local nOpc         	:= GD_INSERT+GD_DELETE+GD_UPDATE                                                                            
Local cLinOk       	:= "AllwaysTrue"    // Funcao executada para validar o contexto da linha atual do aCols                  
Local cTudoOk      	:= "AllwaysTrue"    // Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)      
Local cIniCpos     	:= "+Z72_ID"          // Nome dos campos do tipo caracter que utilizarao incremento automatico.            
                                         // Este parametro deve ser no formato "+<nome do primeiro campo>+<nome do            
                                         // segundo campo>+..."                                                               
Local nFreeze      	:= 000              // Campos estaticos na GetDados.                                                               
Local nMax         	:= 999              // Numero maximo de linhas permitidas. Valor padrao 99                           
Local cFieldOk     	:= "U_VldZ72_VAR()"    // Funcao executada na validacao do campo                                           
Local cSuperDel     	:= ""              // Funcao executada quando pressionada as teclas <Ctrl>+<Delete>                    
Local cDelOk        	:= "AllwaysTrue"   // Funcao executada para validar a exclusao de uma linha do aCols                   
// Objeto no qual a MsNewGetDados sera criada                                      
Local oWnd          	:= oDlgZ72                                                                                                  
Local aHead        	:= {}               // Array a ser tratado internamente na MsNewGetDados como aHeader                    
Local aCol         	:= {}               // Array a ser tratado internamente na MsNewGetDados como aCols                      
Local nUsadoZ72		:= 0


	/*Preenche o array com os campos que serão utilizados no aHeader*/
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("Z72")
	While SX3->(!EOF()) .AND. SX3->X3_ARQUIVO=="Z72"
		
		if X3Uso(SX3->X3_USADO) .AND. !(SX3->X3_CAMPO $ "Z72_FILIAL") 
			AADD(aCpoGDa,alltrim(SX3->X3_CAMPO))
			AADD(aAlter,alltrim(SX3->X3_CAMPO))		
		endif
			
		SX3->(DbSkip())
	Enddo

                                                                                                                                
// Carrega aHead                                                                                                                
DbSelectArea("SX3")                                                                                                             
SX3->(DbSetOrder(2)) // Campo
For nX := 1 to Len(aCpoGDa)                                                                                                     
	If SX3->(DbSeek(aCpoGDa[nX]))                                                                                                 
		nUsadoZ72++
		Aadd(aHead,{ AllTrim(X3Titulo()),;                                                                                         
			SX3->X3_CAMPO	,;                                                                                                       
			SX3->X3_PICTURE,;                                                                                                       
			SX3->X3_TAMANHO,;                                                                                                       
			SX3->X3_DECIMAL,;                                                                                                       
			SX3->X3_VALID	,;                                                                                                       
			SX3->X3_USADO	,;                                                                                                       
			SX3->X3_TIPO	,;                                                                                                       
			SX3->X3_F3 		,;                                                                                                       
			SX3->X3_CONTEXT,;                                                                                                       
			SX3->X3_CBOX	,;                                                                                                       
			SX3->X3_RELACAO})                                                                                                       
	Endif                                                                                                                         
Next nX                                                                                                                         
// Carregue aqui a Montagem da sua aCol                                                                                         
/*aAux := {}                          
For nX := 1 to Len(aCpoGDa)         
	If DbSeek(aCpoGDa[nX])             
		Aadd(aAux,CriaVar(SX3->X3_CAMPO))
	Endif                              
Next nX                             
Aadd(aAux,.F.)                      
Aadd(aCol,aAux)                     
*/
	aCol:={}
	dbSelectArea("Z72")
	dbSetOrder(1)
	Z72->(DBGoTop())
	While !eof()
		AADD(aCol,Array(nUsadoZ72+1))
			For nX:=1 to nUsadoZ72
				aCol[Len(aCol),nX]:=FieldGet(FieldPos(aHead[nX,2]))
			Next
		aCol[Len(aCol),nUsadoZ72+1]:=.F.
		Z72->(dbSkip())
	End

/*                                                                                  
FUNCOES PARA AUXILIO NO USO DA NEWGETDADOS                                          
PARA MAIORES DETALHES ESTUDE AS FUNCOES AO FIM DESTE FONTE                          
==========================================================                          
                                                                                    
// Retorna numero da coluna onde se encontra o Campo na NewGetDados                 
Ex: NwFieldPos(oGet1,"A1_COD")                                                      
                                                                                    
// Retorna Valor da Celula da NewGetDados                                           
// OBS: Se nLinha estiver vazia ele acatara o oGet1:nAt(Linha Atual) da NewGetDados 
Ex: NwFieldGet(oGet1,"A1_COD",nLinha)                                               
                                                                                    
// Alimenta novo Valor na Celula da NewGetDados                                     
// OBS: Se nLinha estiver vazia ele acatara o oGet1:nAt(Linha Atual) da NewGetDados 
Ex: NwFieldPut(oGet1,"A1_COD",nLinha,"Novo Valor")                                  
                                                                                    
// Verifica se a linha da NewGetDados esta Deletada.                                
// OBS: Se nLinha estiver vazia ele acatara o oGet1:nAt(Linha Atual) da NewGetDados 
Ex: NwDeleted (oGet1,nLinha)                                                        
*/                                                                                  

oGetDdsZ72:= MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpc,cLinOk,cTudoOk,cIniCpos,;                               
                             aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oWnd,aHead,aCol)                                   

// Cria ExecBlocks da GetDados

Return Nil                                                                                                                      

/*
Funcao      : C() 
Parametros  : nTam
Retorno     : nTam
Objetivos   : Funcao responsavel por manter o Layout independente da resolucao horizontal do Monitor do Usuario. 
Autor       : Matheus Massarotto
Data/Hora   : 08/10/2012
*/

*---------------------*
Static Function C(nTam)                                                         
*---------------------*
Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor     
	If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)  
		nTam *= 0.8                                                                
	ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600                
		nTam *= 1                                                                  
	Else	// Resolucao 1024x768 e acima                                           
		nTam *= 1.28                                                               
	EndIf                                                                         
                                                                                
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                                               
	//³Tratamento para tema "Flat"³                                               
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                               
	If "MP8" $ oApp:cVersion                                                      
		If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()                      
			nTam *= 0.90                                                            
		EndIf                                                                      
	EndIf                                                                         
Return Int(nTam)                                                                

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ NwFieldPos ³ Autor ³ Ricardo Mansano       ³ Data ³06/09/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Retorna numero da coluna onde se encontra o Campo na         ³±±
±±³           ³ NewGetDados                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ oObjeto := Objeto da NewGetDados                             ³±±
±±³           ³ cCampo  := Nome do Campo a ser localizado                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³ Numero da coluna localizada pelo aScan                       ³±±
±±³           ³ OBS: Se retornar Zero significa que nao localizou o Registro ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
*----------------------------------------*
Static Function NwFieldPos(oObjeto,cCampo)                                      
*----------------------------------------*
Local nCol := aScan(oObjeto:aHeader,{|x| AllTrim(x[2]) == Upper(cCampo)})       
Return(nCol)                                                                    
                                                                                
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ NwFieldGet ³ Autor ³ Ricardo Mansano       ³ Data ³06/09/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Retorna Valor da Celula da NewGetDados                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ oObjeto := Objeto da NewGetDados                             ³±±
±±³           ³ cCampo  := Nome do Campo a ser localizado                    ³±±
±±³           ³ nLinha  := Linha da GetDados, caso o parametro nao seja      ³±±
±±³           ³            preenchido o Default sera o nAt da NewGetDados    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³ xRet := O Valor da Celula independente de seu TYPE           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
*-----------------------------------------------*
Static Function NwFieldGet(oObjeto,cCampo,nLinha)                               
*-----------------------------------------------*
Local nCol := aScan(oObjeto:aHeader,{|x| AllTrim(x[2]) == Upper(cCampo)})       
Local xRet                                                                      
// Se nLinha nao for preenchida Retorna a Posicao de nAt do Objeto              
Default nLinha := oObjeto:nAt                                                   
	xRet := oObjeto:aCols[nLinha,nCol]                                             
Return(xRet)                                                                    
                                                                                
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ NwFieldPut ³ Autor ³ Ricardo Mansano       ³ Data ³06/09/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Alimenta novo Valor na Celula da NewGetDados                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ oObjeto := Objeto da NewGetDados                             ³±±
±±³           ³ cCampo  := Nome do Campo a ser localizado                    ³±±
±±³           ³ nLinha  := Linha da GetDados, caso o parametro nao seja      ³±±
±±³           ³            preenchido o Default sera o nAt da NewGetDados    ³±±
±±³           ³ xNewValue := Valor a ser inputado na Celula.                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
*---------------------------------------------------------*
Static Function NwFieldPut(oObjeto,cCampo,nLinha,xNewValue)                     
*---------------------------------------------------------*
Local nCol := aScan(oObjeto:aHeader,{|x| AllTrim(x[2]) == Upper(cCampo)})       
// Se nLinha nao for preenchida Retorna a Posicao de nAt do Objeto              
Default nLinha := oObjeto:nAt                                                   
	// Alimenta Celula com novo Valor se este foi preenchido                       
	If !Empty(xNewValue)                                                           
		oObjeto:aCols[nLinha,nCol] := xNewValue                                      
	Endif                                                                          
Return Nil                                                                      
                                                                                
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ NwDeleted  ³ Autor ³ Ricardo Mansano       ³ Data ³06/09/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Verifica se a linha da NewGetDados esta Deletada.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ oObjeto := Objeto da NewGetDados                             ³±±
±±³           ³ nLinha  := Linha da GetDados, caso o parametro nao seja      ³±±
±±³           ³            preenchido o Default sera o nAt da NewGetDados    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³ lRet := True = Linha Deletada / False = Nao Deletada         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
*---------------------------------------*
Static Function NwDeleted(oObjeto,nLinha)                                       
*---------------------------------------*
Local nCol := Len(oObjeto:aCols[1])                                             
Local lRet := .T.                                                               
// Se nLinha nao for preenchida Retorna a Posicao de nAt do Objeto              
Default nLinha := oObjeto:nAt                                                   
	// Alimenta Celula com novo Valor                                              
	lRet := oObjeto:aCols[nLinha,nCol]                                             
Return(lRet)                                                                    

/*
Funcao      : VldZ72_VAR 
Parametros  : 
Retorno     : lRet
Objetivos   : Funcao para validar a variável inserida
Autor       : Matheus Massarotto
Data/Hora   : 08/10/2012
*/
*----------------------*
User Function VldZ72_VAR
*----------------------*
Local nPos	:= NwFieldPos(oGetDdsZ72,"Z72_VARUSR")
Local lRet	:= .T.

//Verifico se o campo posicionado é o de variável do usuário
if !alltrim(oGetDdsZ72:aHeader[oGetDdsZ72:oBrowse:ColPos][2])=="Z72_VARUSR"
	return(.T.)
endif

for nI:=1 to len(oGetDdsZ72:aCols)
	if oGetDdsZ72:nAt<>nI
		if alltrim(oGetDdsZ72:aCols[nI][nPos])==alltrim(M->Z72_VARUSR)//alltrim(oGetDdsZ72:aCols[oGetDdsZ72:nAt][nPos])
			lRet:=.F.
			Alert("Variavel já utilizada!")
		endif
	endif
next

Return(lRet)

/*
Funcao      : GravaZ72
Parametros  : 
Retorno     : 
Objetivos   : Funcao para gravar na tabela Z72
Autor       : Matheus Massarotto
Data/Hora   : 08/10/2012
*/
*----------------------*
Static function GravaZ72
*----------------------*
Local lTemDel	:= .F.
Local nSeq		:= "000"
Local nPosUSR	:= Ascan(oGetDdsZ72:aHeader,{|x| alltrim(x[2]) = "Z72_VARUSR"})
Local nPosSIS	:= Ascan(oGetDdsZ72:aHeader,{|x| alltrim(x[2]) = "Z72_VARSIS"})
Local nPosDESC	:= Ascan(oGetDdsZ72:aHeader,{|x| alltrim(x[2]) = "Z72_DESCRI"})

for g:=1 to len(oGetDdsZ72:aCols)
	if nPosUSR>0
		if empty(oGetDdsZ72:aCols[g][nPosUSR])
	 		Alert("Existe linha com variavel de usuário não preenchido!")
	    	Return .F.
			Exit
		endif
	endif
	if nPosSIS>0
		if empty(oGetDdsZ72:aCols[g][nPosSIS])
	 		Alert("Existe linha com variavel de sistema não preenchido!")
	    	Return .F.
			Exit
		endif	
	endif
	if nPosDESC>0
		if empty(oGetDdsZ72:aCols[g][nPosDESC])
	 		Alert("Existe linha com descrição não preenchido!")
	    	Return .F.
			Exit
		endif	
	endif
next

	BEGIN TRANSACTION	
	    //GRAVANDO GETDADOS
			for i:=1 to len(oGetDdsZ72:aCols)
		    	
		 		if empty(oGetDdsZ72:aCols[i][1])
		 			loop
		 		endif
		 		Z72->(DBSetOrder(1)) 

		 		//verifica se o registro já existe para fazer alteração
		 		if Z72->(DbSeek(xFilial("Z72")+oGetDdsZ72:aCols[i][1] ))
			    	//se for deletado
			    	if oGetDdsZ72:aCols[i][len(oGetDdsZ72:aCols[i])]
						RecLock("Z72",.F.)
							Z72->(DbDelete())
						MsUnlock()
			    		lTemDel:=.T.
			    	else
				    	RecLock("Z72",.F.)
				    		Z72->Z72_FILIAL:=xFilial("Z72")
				    		for j:=1 to len(oGetDdsZ72:aHeader)
				    			Z72->&(oGetDdsZ72:aHeader[j][2]):=oGetDdsZ72:aCols[i][j]
				    		next
				    	MsUnlock()
			    	endif
		    	else
		    		//se não estiver deletado
		    		if !oGetDdsZ72:aCols[i][len(oGetDdsZ72:aCols[i])]
				    	RecLock("Z72",.T.)
				    		Z72->Z72_FILIAL:=xFilial("Z72")
				    		for j:=1 to len(oGetDdsZ72:aHeader)
				    			Z72->&(oGetDdsZ72:aHeader[j][2]):=oGetDdsZ72:aCols[i][j]
				    		next
				    	MsUnlock()
			    	else
			    		lTemDel:=.T.
			    	endif
		    	endif
		    next
	END TRASACTION
/*
if lTemDel
	nSeq:="000"
	
	DbSelectArea("Z72")
	DbSetOrder(1)
	Z72->(DbGoTop())
	
	while !eof()
		
	endif
	
endif
	*/
Return(.T.)

/*
Funcao      : VldZ72Digi
Parametros  : cConteudo
Retorno     : lRet
Objetivos   : Funcao validar se a variável inserida começa com número
Autor       : Matheus Massarotto
Data/Hora   : 08/10/2012
*/

*---------------------------------*
User Function VldZ72Digi(cConteudo)
*---------------------------------*
Local lRet:= .T.

if ISDIGIT(cConteudo)
	Alert("Número não é permitido como inicio de variavel!")
	lRet:=.F.
endif

Return(lRet)

/*
Funcao      : DefPerg
Parametros  : 
Retorno     : cPergunte
Objetivos   : Funcao que define a pergunta
Autor       : Matheus Massarotto
Data/Hora   : 08/10/2012
*/
*----------------------*
Static Function DefPerg
*----------------------*
cPergunte:="GTCORP46_P"

	//Definição das perguntas.
	PutSx1( cPergunte, "01", "Arquivo Word?"	, "Arquivo Word?"	, "Arquivo Word?"   , "", "C",50,00,00,"G","" , "","","","MV_PAR01")
	PutSx1( cPergunte, "02", "Local Saida?"		, "Local Saida?"	, "Local Saida?"	, "", "C",50,00,00,"G","" , "","","","MV_PAR02")


Return(cPergunte)