#include "protheus.ch"
#include "tbiconn.ch"

User Function USX3086

	AtuaDic()

Return 

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} AtuaDic
//Atualiza��o de dicion�rio
@author Marcio Martins Pereira
@since 18/08/2019
@version 1.00
@type function
/*/
//------------------------------------------------------------------------------------------
Static Function AtuaDic()  // Cria ou atualIza os objetos de dicionario

	Local i:=0
	Local aDados:={}
	Local nTamFil:=6
	Local cReservO := GetReserv( {.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.} ) // Campo obrigatorio
	Local cReserv  := GetReserv( {.T.,.T.,.T.,.T.,.T.,.T.,.F.,.T.} ) // Campo NAO obrigatorio
	Local cUsado   := GetUsado()                                    // Campo Usado
	Local cNaoUsado:= GetUsado(,.F.)                                // Campo N�o Usado
	
	Conout("ATUADIC " + Time())

//-------------------------------------------------------------------------------------------------------------
// Z0E INICIO
//-------------------------------------------------------------------------------------------------------------
	
	//
	// Tabela Z0E
	//
	aAdd( aDados, { ;
		'Z0E'																	, ; //INDICE
		'1'																		, ; //ORDEM			// RetNextIdx("DA1", 'DA1_FILIAL+DA1_XIDSKU')
		'Z0E_FILIAL+Z0E_ORDEM'													, ; //CHAVE
		'Ordem'																	, ; //DESCRICAO
		'Ordem'																	, ; //DESCSPA
		'Ordem'																	, ; //DESCENG
		'U'																		, ; //PROPRI
		''																		, ; //F3
		''																		, ; //NICKNAME
		'N'																		} ) //SHOWPESQ
	
	aAdd( aDados, { ;
		'Z0E'																	, ; //INDICE
		'2'																		, ; //ORDEM			// RetNextIdx("DA1", 'DA1_FILIAL+DA1_XIDSKU')
		'Z0E_FILIAL+Z0E_CPOPLA'													, ; //CHAVE
		'Cpo Planilha'															, ; //DESCRICAO
		'Cpo Planilha'															, ; //DESCSPA
		'Cpo Planilha'															, ; //DESCENG
		'U'																		, ; //PROPRI
		''																		, ; //F3
		''																		, ; //NICKNAME
		'N'																		} ) //SHOWPESQ
	
	aAdd( aDados, { ;
		'Z0E'																	, ; //INDICE
		'3'																		, ; //ORDEM			// RetNextIdx("DA1", 'DA1_FILIAL+DA1_XIDSKU')
		'Z0E_FILIAL+Z0E_CPOSX3'													, ; //CHAVE
		'Campo SX3'																, ; //DESCRICAO
		'Campo SX3'																, ; //DESCSPA
		'Campo SX3'																, ; //DESCENG
		'U'																		, ; //PROPRI
		''																		, ; //F3
		''																		, ; //NICKNAME
		'N'																		} ) //SHOWPESQ

	SIX->(dbSetOrder(1)) // INDICE+ORDEM
	For i:= 1 to Len(aDados)
	    SIX->( RecLock("SIX",!dbSeek(aDados[i,1]+aDados[i,2])) )
	    SIX->INDICE     := aDados[i,1]
	    SIX->ORDEM      := aDados[i,2]
	    SIX->CHAVE      := aDados[i,3]
	    SIX->DESCRICAO  := aDados[i,4]
	    SIX->DESCSPA	:= aDados[i,5]
	    SIX->DESCENG	:= aDados[i,6]
	    SIX->PROPRI		:= aDados[i,7]
	    SIX->F3			:= aDados[i,8]
	    SIX->NICKNAME	:= aDados[i,9]
	    SIX->SHOWPESQ   := aDados[i,10]
	    SIX->(dbUnlock())
	Next

	
	//
	// SX2 -> ZM0 Tabela 
	//
	aDados:={}
	aAdd( aDados, { ;
		'Z0E'																	, ; //X2_CHAVE
		'DE-PARA IMPORTA TABELAS'														, ; //X2_NOME
		''																		, ; //X2_UNICO
		'C'																		, ; //X2_MODO
		'C'																		, ; //X2_MODOUN
		'C'																		} ) //X2_MODOEMP
	
	SX2->(dbSetOrder(1)) // X2_CHAVE
	SX2->(dbGoTop())
	cAux := SubStr(SX2->X2_ARQUIVO,4)
	for i:= 1 to len(aDados)
	    SX2->( RecLock("SX2", !dbSeek(aDados[i,1])))
	    SX2->X2_CHAVE   := aDados[i,1]
	    SX2->X2_ARQUIVO := aDados[i,1]+cAux
	    SX2->X2_NOME    := aDados[i,2]
	    SX2->X2_UNICO   := aDados[i,3]
	    SX2->X2_MODO    := aDados[i,4]
	    SX2->X2_MODOUN  := aDados[i,5]
	    SX2->X2_MODOEMP := aDados[i,6]
	    SX2->(dbUnlock())
	next
	
	
	//
	// SX3 -> ZM0 Campos 
	//
	
	SX3->(dbSetOrder(2)) // X3_CAMPO
	SX3->( dbSeek("F1_FILIAL"))
	nTamFil:=SX3->X3_TAMANHO
	aDados:={}
	
	aAdd( aDados, { ;
		'Z0E'													, ; //X3_ARQUIVO
		'01'													, ; //X3_ORDEM
		'Z0E_FILIAL'											, ; //X3_CAMPO
		'C'														, ; //X3_TIPO
		nTamFil													, ; //X3_TAMANHO
		0														, ; //X3_DECIMAL
		'Filial'												, ; //X3_TITULO
		'Filial do Sistema'										, ; //X3_DESCRIC
		'@!'													, ; //X3_PICTURE
		cReserv													, ; //X3_RESERV
		cNaoUsado												, ; //X3_USADO	cUsado / cNaoUsado
		'U'														, ; //X3_PROPRI
		'N'														, ; //X3_BROWSE
		''														, ; //X3_VISUAL
		''														, ; //X3_CONTEXT
		''														, ; //X3_F3
		''														, ; //X3_VALID	
		''														, ; //X3_RELACAO
		''														, ; //X3_CBOX	
		1														, ; //X3_NIVEL
		''														, ; //X3_TRIGGER
		''														} ) //X3_OBRIGAT
	
	aAdd( aDados, { ;
		'Z0E'													, ; //X3_ARQUIVO
		'02'													, ; //X3_ORDEM
		'Z0E_ORDEM'												, ; //X3_CAMPO
		'C'														, ; //X3_TIPO
		3														, ; //X3_TAMANHO
		0														, ; //X3_DECIMAL
		'Ordem       '											, ; //X3_TITULO
		'Ordem       '											, ; //X3_DESCRIC
		'@!'														, ; //X3_PICTURE
		cReserv													, ; //X3_RESERV
		cUsado													, ; //X3_USADO	cUsado / cNaoUsado
		'U'														, ; //X3_PROPRI
		'S'														, ; //X3_BROWSE
		'A'														, ; //X3_VISUAL
		'R'														, ; //X3_CONTEXT
		''														, ; //X3_F3
		''														, ; //X3_VALID	
		''														, ; //X3_RELACAO
		''														, ; //X3_CBOX	
		1														, ; //X3_NIVEL
		''														, ; //X3_TRIGGER
		''														} ) //X3_OBRIGAT

	aAdd( aDados, { ;
		'Z0E'													, ; //X3_ARQUIVO
		'03'													, ; //X3_ORDEM
		'Z0E_CPOPLA'												, ; //X3_CAMPO
		'C'														, ; //X3_TIPO
		30														, ; //X3_TAMANHO
		0														, ; //X3_DECIMAL
		'Cpo Planilha'											, ; //X3_TITULO
		'Cpo Planilha'											, ; //X3_DESCRIC
		'@!'		 												, ; //X3_PICTURE
		cReserv													, ; //X3_RESERV
		cUsado													, ; //X3_USADO	cUsado / cNaoUsado
		'U'														, ; //X3_PROPRI
		'S'														, ; //X3_BROWSE
		'A'														, ; //X3_VISUAL
		'R'														, ; //X3_CONTEXT
		''														, ; //X3_F3
		''														, ; //X3_VALID	
		''														, ; //X3_RELACAO
		''														, ; //X3_CBOX	
		1														, ; //X3_NIVEL
		''														, ; //X3_TRIGGER
		''														} ) //X3_OBRIGAT

	aAdd( aDados, { ;
		'Z0E'													, ; //X3_ARQUIVO
		'04'													, ; //X3_ORDEM
		'Z0E_CPOSX3'											, ; //X3_CAMPO
		'C'														, ; //X3_TIPO
		10														, ; //X3_TAMANHO
		0														, ; //X3_DECIMAL
		'Campo SX3   '											, ; //X3_TITULO
		'Campo SX3   '											, ; //X3_DESCRIC
		'@!'														, ; //X3_PICTURE
		cReserv													, ; //X3_RESERV
		cUsado													, ; //X3_USADO	cUsado / cNaoUsado
		'U'														, ; //X3_PROPRI
		'S'														, ; //X3_BROWSE
		'A'														, ; //X3_VISUAL
		'R'														, ; //X3_CONTEXT
		''														, ; //X3_F3
		''														, ; //X3_VALID	
		''														, ; //X3_RELACAO
		''														, ; //X3_CBOX	
		1														, ; //X3_NIVEL
		''														, ; //X3_TRIGGER
		''														} ) //X3_OBRIGAT

	aAdd( aDados, { ;
		'Z0E'													, ; //X3_ARQUIVO
		'05'													, ; //X3_ORDEM
		'Z0E_EMUSO'												, ; //X3_CAMPO
		'C'														, ; //X3_TIPO
		1														, ; //X3_TAMANHO
		0														, ; //X3_DECIMAL
		'Em uso?     '											, ; //X3_TITULO
		'Em uso?     '											, ; //X3_DESCRIC
		'@!'												, ; //X3_PICTURE
		cReserv													, ; //X3_RESERV
		cUsado													, ; //X3_USADO	cUsado / cNaoUsado
		'U'														, ; //X3_PROPRI
		'S'														, ; //X3_BROWSE
		'A'														, ; //X3_VISUAL
		'R'														, ; //X3_CONTEXT
		''														, ; //X3_F3
		''														, ; //X3_VALID	
		''														, ; //X3_RELACAO
		'1=Sim;2=Nao'														, ; //X3_CBOX	
		1														, ; //X3_NIVEL
		''														, ; //X3_TRIGGER
		''														} ) //X3_OBRIGAT

	aAdd( aDados, { ;
		'Z0E'													, ; //X3_ARQUIVO
		'06'													, ; //X3_ORDEM
		'Z0E_ACAO'											, ; //X3_CAMPO
		'C'														, ; //X3_TIPO
		1														, ; //X3_TAMANHO
		0														, ; //X3_DECIMAL
		'Inclui/Alter'												, ; //X3_TITULO
		'Inclui/Alter'												, ; //X3_DESCRIC
		'@!'													, ; //X3_PICTURE
		cReserv													, ; //X3_RESERV
		cUsado													, ; //X3_USADO	cUsado / cNaoUsado
		'U'														, ; //X3_PROPRI
		'S'														, ; //X3_BROWSE
		'A'														, ; //X3_VISUAL
		'R'														, ; //X3_CONTEXT
		''														, ; //X3_F3
		''														, ; //X3_VALID	
		''														, ; //X3_RELACAO
		'1=Inclui/altera;2=Apenas altera'				, ; //X3_CBOX	
		1														, ; //X3_NIVEL
		''														, ; //X3_TRIGGER
		''														} ) //X3_OBRIGAT
		
	For i:= 1 to Len(aDados)
	    SX3->(RecLock("SX3", ! dbSeek(padr(aDados[i,3],10))))
	    SX3->X3_ARQUIVO := aDados[i,1]
	    SX3->X3_ORDEM   := aDados[i,2]
	    SX3->X3_CAMPO   := aDados[i,3]
	    SX3->X3_TIPO    := aDados[i,4]
	    SX3->X3_TAMANHO := aDados[i,5]
	    SX3->X3_DECIMAL := aDados[i,6]
	    SX3->X3_TITULO  := aDados[i,7]
	    SX3->X3_DESCRIC := aDados[i,8]
	    SX3->X3_PICTURE := aDados[i,9]
	    SX3->X3_RESERV  := aDados[i,10]
	    SX3->X3_USADO   := aDados[i,11]
	    SX3->X3_PROPRI  := aDados[i,12]
	    SX3->X3_BROWSE  := aDados[i,13]
	    SX3->X3_VISUAL  := aDados[i,14]
	    SX3->X3_CONTEXT := aDados[i,15]
	    SX3->X3_F3      := aDados[i,16]
	    SX3->X3_VALID   := aDados[i,17]
	    SX3->X3_RELACAO := aDados[i,18]
	    SX3->X3_CBOX    := aDados[i,19]
	    SX3->X3_NIVEL	:= aDados[i,20]
	    SX3->X3_TRIGGER	:= aDados[i,21]
	    SX3->X3_OBRIGAT	:= aDados[i,22]
	    SX3->(dbUnlock())
	Next
		
	// realizar a atualiza��o do banco
	aDados:={"Z0E"}
	for i:= 1 to len(aDados)
		(aDados[i])->(DBCLOSEAREA())
	    X31UpdTable( aDados[i] )
	next
	//Alert(__GetX31Trace())

	Conout("ATUADIC " + Time())
	
//-------------------------------------------------------------------------------------------------------------
// Z0E TERMINO
//-------------------------------------------------------------------------------------------------------------

Return .T.



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetUsado
//Utilizado na fun��o AtuaDic
@author Marcio Martins Pereira
@since 18/08/2019
@version 1.00
@type function
/*/
//------------------------------------------------------------------------------------------
Static Function GetUsado(aDados,lUsado)

Local nCnt
Local cUsado 	:= Space(103)
Local aModulos  := RetModName()

Default lUsado  := .T.
Default aDados  := {{}, .F.}

If !lUsado
   cUsado := Str2Bin(FirstBitOn(cUsado))
   Return cUsado
EndIf

For nCnt := 1 To Len(aDados[1])
    If ValType(aDados[1][nCnt]) == "N"
       cUsado := Stuff(cUsado, aDados[1][nCnt] ,1,"x")
    Else
       cUsado := Stuff(cUsado, aScan(aModulos,{|x| x[2] == aDados[1][nCnt]}) ,1,"x")
    EndIf
Next

If Len(aDados[1]) == 0 //Se for zero sera utilizado para todos os modulos
   cUsado := Stuff(cUsado,100,1,"x")
EndIf

If aDados[2] //aDados[2] == .T. eh chave e .F. nao eh chave
   cUsado := Stuff(cUsado,101,1,"x")
EndIf

Return Str2Bin(FirstBitOn(cUsado))



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetReserv
//Utilizado na fun��o AtuaDic
@author Marcio Martins Pereira
@since 18/08/2019
@version 1.00
@type function
/*/
//------------------------------------------------------------------------------------------
Static Function GetReserv(aReserv)

Local nCnt, cReserv := Space(9)

For nCnt := 1 To Len(aReserv)
    If aReserv[nCnt]
       cReserv := Stuff(cReserv,nCnt,1,"x")
    EndIf
Next

Return X3Reserv(cReserv)
