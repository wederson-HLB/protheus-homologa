#INCLUDE 'TOTVS.CH'

/*
Funcao      : USX1006
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Atualizar os dicionários de perguntas da versão 11 R8 para que os itens
              customizados do grupo MTR943 não entrem em conflito com os criados pelo
              programa MTR942.
Autor       : Eduardo C. Romanini
Data/Hora   : 05/06/2015 
*/               
*---------------------*
User Function USX1006()
*---------------------*

Local   aSay      := {}
Local   aButton   := {}
Local   aMarcadas := {}
Local   cTitulo   := "Atualização de Dicionários de Dados"
Local   cDesc1    := "Esta rotina tem como função fazer  a atualização  dos dicionários de Dados do Sistema     "
Local   cDesc2    := "Este processo deve ser executado em modo EXCLUSIVO, ou seja não podem haver outros        "
Local   cDesc3    := "  usuários  ou  jobs utilizando  o sistema.  É extremamente recomendavél  que  se  faça um"
Local   cDesc4    := "  BACKUP  dos DICIONÁRIOS  e da  BASE DE DADOS antes desta atualização.                   "
Local   cDesc5    := "Objetivo: Atualiza o dicionário de perguntas(SX1) do grupo MTR943 e MTR930.               "
Local   lOk       := .F.

Private oMainWnd  := NIL
Private oProcess  := NIL

#IFDEF TOP
    TCInternal( 5, "*OFF" ) // Desliga Refresh no Lock do Top
#ENDIF

__cInterNet := NIL
__lPYME     := .F.

Set Dele On

// Mensagens de Tela Inicial
aAdd( aSay, cDesc1 )
aAdd( aSay, cDesc2 )
aAdd( aSay, cDesc3 )
aAdd( aSay, cDesc4 )
aAdd( aSay, "     ")
aAdd( aSay, cDesc5 )

// Botoes Tela Inicial
aAdd(  aButton, {  1, .T., { || lOk := .T., FechaBatch() } } )
aAdd(  aButton, {  2, .T., { || lOk := .F., FechaBatch() } } )

FormBatch(  cTitulo,  aSay,  aButton )

If lOk
	aMarcadas := EscEmpresa()

	If !Empty( aMarcadas )
		If  MsgYesNo( "Confirma a atualização dos dicionários ?", cTitulo )
			oProcess := MsNewProcess():New( { | lEnd | lOk := UpdProc( @lEnd, aMarcadas ) }, "Atualizando", "Aguarde, atualizando ...", .F. )
			oProcess:Activate()

			If lOk
				Final( "Atualização Concluída." )
			Else
				Final( "Atualização não Realizada." )
			EndIf

		Else
			MsgStop( "Atualização não Realizada.", "USX1006" )

		EndIf

	Else
		MsgStop( "Atualização não Realizada.", "USX1006" )

	EndIf

EndIf

Return Nil 

/*
Funcao      : EmpEmpresas
Parametros  : Nenhum
Retorno     : Empresas Selecionadas
Objetivos   : Exibir tela de seleção das empresas que serão atualizadas.
Autor       : Eduardo C. Romanini
Data/Hora   : 03/06/2015 
Obs.        : Baseada no fonte UPDFIN2.PRW
*/    
*--------------------------*
Static Function EscEmpresa()
*--------------------------*
Local   aSalvAmb := GetArea()
Local   aSalvSM0 := {}
Local   aRet     := {}
Local   aVetor   := {}
Local   oDlg     := NIL
Local   oChkMar  := NIL
Local   oLbx     := NIL
Local   oMascEmp := NIL
Local   oMascFil := NIL
Local   oButMarc := NIL
Local   oButDMar := NIL
Local   oButInv  := NIL
Local   oSay     := NIL
Local   oOk      := LoadBitmap( GetResources(), "LBOK" )
Local   oNo      := LoadBitmap( GetResources(), "LBNO" )
Local   lChk     := .F.
Local   lOk      := .F.
Local   lTeveMarc:= .F.
Local   cVar     := ""
Local   cNomEmp  := ""
Local   cMascEmp := "??"
Local   cMascFil := "??"

Local   aMarcadas  := {}

If !MyOpenSm0(.F.)
	Return aRet
EndIf

dbSelectArea( "SM0" )
aSalvSM0 := SM0->( GetArea() )
dbSetOrder( 1 )
dbGoTop()

While !SM0->( EOF() )

	If aScan( aVetor, {|x| x[2] == SM0->M0_CODIGO} ) == 0
		aAdd(  aVetor, { aScan( aMarcadas, {|x| x[1] == SM0->M0_CODIGO .and. x[2] == SM0->M0_CODFIL} ) > 0, SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_NOME, SM0->M0_FILIAL } )
	EndIf

	dbSkip()
End

RestArea( aSalvSM0 )

Define MSDialog  oDlg Title "" From 0, 0 To 270, 396 Pixel

oDlg:cToolTip := "Tela para Múltiplas Seleções de Empresas/Filiais"

oDlg:cTitle   := "Selecione a(s) Empresa(s) para Atualização"

@ 10, 10 Listbox  oLbx Var  cVar Fields Header " ", " ", "Empresa" Size 178, 095 Of oDlg Pixel
oLbx:SetArray(  aVetor )
oLbx:bLine := {|| {IIf( aVetor[oLbx:nAt, 1], oOk, oNo ), ;
aVetor[oLbx:nAt, 2], ;
aVetor[oLbx:nAt, 4]}}
oLbx:BlDblClick := { || aVetor[oLbx:nAt, 1] := !aVetor[oLbx:nAt, 1], VerTodos( aVetor, @lChk, oChkMar ), oChkMar:Refresh(), oLbx:Refresh()}
oLbx:cToolTip   :=  oDlg:cTitle
oLbx:lHScroll   := .F. // NoScroll

@ 112, 10 CheckBox oChkMar Var  lChk Prompt "Todos"   Message  Size 40, 007 Pixel Of oDlg;
on Click MarcaTodos( lChk, @aVetor, oLbx )

@ 123, 10 Button oButInv Prompt "&Inverter"  Size 32, 12 Pixel Action ( InvSelecao( @aVetor, oLbx, @lChk, oChkMar ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Inverter Seleção" Of oDlg

// Marca/Desmarca por mascara
@ 113, 51 Say  oSay Prompt "Empresa" Size  40, 08 Of oDlg Pixel
@ 112, 80 MSGet  oMascEmp Var  cMascEmp Size  05, 05 Pixel Picture "@!"  Valid (  cMascEmp := StrTran( cMascEmp, " ", "?" ), cMascFil := StrTran( cMascFil, " ", "?" ), oMascEmp:Refresh(), .T. ) ;
Message "Máscara Empresa ( ?? )"  Of oDlg
@ 123, 50 Button oButMarc Prompt "&Marcar"    Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .T. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Marcar usando máscara ( ?? )"    Of oDlg
@ 123, 80 Button oButDMar Prompt "&Desmarcar" Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .F. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Desmarcar usando máscara ( ?? )" Of oDlg

Define SButton From 111, 125 Type 1 Action ( RetSelecao( @aRet, aVetor ), oDlg:End() ) OnStop "Confirma a Seleção"  Enable Of oDlg
Define SButton From 111, 158 Type 2 Action ( IIf( lTeveMarc, aRet :=  aMarcadas, .T. ), oDlg:End() ) OnStop "Abandona a Seleção" Enable Of oDlg
Activate MSDialog  oDlg Center

RestArea( aSalvAmb )
dbSelectArea( "SM0" )
dbCloseArea()

Return  aRet    

/*
Funcao      : MarcaTodos   
Retorno     : Nil
Objetivos   : Seleciona todas as empresas
Autor       : Eduardo C. Romanini
Data/Hora   : 03/06/2015 
Obs.        : Auxiliar da função EmpEmpresas().
*/   
*------------------------------------------------*
Static Function MarcaTodos( lMarca, aVetor, oLbx )
*------------------------------------------------*
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := lMarca
Next nI

oLbx:Refresh()

Return NIL

/*
Funcao      : InvSelecao   
Retorno     : Nil
Objetivos   : Inverte a selecão das empresas
Autor       : Eduardo C. Romanini
Data/Hora   : 03/06/2015 
Obs.        : Auxiliar da função EmpEmpresas().
*/  
*----------------------------------------*
Static Function InvSelecao( aVetor, oLbx )
*----------------------------------------*
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := !aVetor[nI][1]
Next nI

oLbx:Refresh()

Return NIL

/*
Funcao      : RetSelecao   
Retorno     : Nil
Objetivos   : Montar o retorno com as empresas selecioandas.
Autor       : Eduardo C. Romanini
Data/Hora   : 03/06/2015 
Obs.        : Auxiliar da função EmpEmpresas().
*/ 
*----------------------------------------*
Static Function RetSelecao( aRet, aVetor )
*----------------------------------------*
Local  nI    := 0

aRet := {}
For nI := 1 To Len( aVetor )
	If aVetor[nI][1]
		aAdd( aRet, { aVetor[nI][2] , aVetor[nI][3], aVetor[nI][2] +  aVetor[nI][3] } )
	EndIf
Next nI

Return NIL

/*
Funcao      : MarcaMas   
Retorno     : Nil
Objetivos   : Selecionar empresas com base na máscara informada.
Autor       : Eduardo C. Romanini
Data/Hora   : 03/06/2015 
Obs.        : Auxiliar da função EmpEmpresas().
*/ 
*---------------------------------------------------------*
Static Function MarcaMas( oLbx, aVetor, cMascEmp, lMarDes )
*---------------------------------------------------------*
Local cPos1 := SubStr( cMascEmp, 1, 1 )
Local cPos2 := SubStr( cMascEmp, 2, 1 )
Local nPos  := oLbx:nAt
Local nZ    := 0

For nZ := 1 To Len( aVetor )
	If cPos1 == "?" .or. SubStr( aVetor[nZ][2], 1, 1 ) == cPos1
		If cPos2 == "?" .or. SubStr( aVetor[nZ][2], 2, 1 ) == cPos2
			aVetor[nZ][1] :=  lMarDes
		EndIf
	EndIf
Next

oLbx:nAt := nPos
oLbx:Refresh()

Return NIL

/*
Funcao      : VerTodos   
Retorno     : Nil
Objetivos   : Verificar se a empresa está marcada
Autor       : Eduardo C. Romanini
Data/Hora   : 03/06/2015 
Obs.        : Auxiliar da função EmpEmpresas().
*/ 
*-----------------------------------------------*
Static Function VerTodos( aVetor, lChk, oChkMar )
*-----------------------------------------------*
Local lTTrue := .T.
Local nI     := 0

For nI := 1 To Len( aVetor )
	lTTrue := IIf( !aVetor[nI][1], .F., lTTrue )
Next nI

lChk := IIf( lTTrue, .T., .F. )
oChkMar:Refresh()

Return NIL

/*
Funcao      : MyOpenSM0   
Retorno     : lOpen: Indica se a tabela foi aberta.
Objetivos   : Realiza a abertura exclusiva da tabela SM0.
Autor       : Eduardo C. Romanini
Data/Hora   : 03/06/2015 
Obs.        : Auxiliar da função EmpEmpresas().
*/ 
*--------------------------------*
Static Function MyOpenSM0(lShared)
*--------------------------------*
Local lOpen := .F.
Local nLoop := 0

For nLoop := 1 To 20
	dbUseArea( .T., , "SIGAMAT.EMP", "SM0", lShared, .F. )

	If !Empty( Select( "SM0" ) )
		lOpen := .T.
		dbSetIndex( "SIGAMAT.IND" )
		Exit
	EndIf

	Sleep( 500 )

Next nLoop

If !lOpen
	MsgStop( "Não foi possível a abertura da tabela " + ;
	IIf( lShared, "de empresas (SM0).", "de empresas (SM0) de forma exclusiva." ), "ATENÇÃO" )
EndIf

Return lOpen


/*
Funcao      : UpdProc   
Parâmetros  : lEnd     : Indicação de cancelamento do processamento
              aMarcadas: Empresas selecionadas
Objetivos   : Realiza a atualização do dicionário
Autor       : Eduardo C. Romanini
Data/Hora   : 03/06/2015 
*/ 
*----------------------------------------*
Static Function UpdProc( lEnd, aMarcadas )
*----------------------------------------*      
Local   lRet      := .T.
Local   lOpen     := .F.

Local   cAux      := ""
Local   cFile     := ""
Local   cFileLog  := ""
Local   cMask     := "Arquivos Texto" + "(*.TXT)|*.txt|"
Local   cTexto    := ""

Local   nI        := 0
Local   nPos      := 0
Local   nRecno    := 0
Local   nX        := 0

Local   aInfo     := {}
Local   aRecnoSM0 := {}

Local   oDlg      := NIL
Local   oFont     := NIL
Local   oMemo     := NIL

Private aArqUpd   := {}

If ( lOpen := MyOpenSm0(.T.) )

	dbSelectArea( "SM0" )
	dbGoTop()

	While !SM0->( EOF() )
		// So adiciona no aRecnoSM0 se a empresa for diferente
		If aScan( aRecnoSM0, { |x| x[2] == SM0->M0_CODIGO } ) == 0 ;
		   .AND. aScan( aMarcadas, { |x| x[1] == SM0->M0_CODIGO } ) > 0
			aAdd( aRecnoSM0, { Recno(), SM0->M0_CODIGO } )
		EndIf
		SM0->( dbSkip() )
	End

	SM0->( dbCloseArea() )

	If lOpen

		For nI := 1 To Len( aRecnoSM0 )

			If !( lOpen := MyOpenSm0(.F.) )
				MsgStop( "Atualização da empresa " + aRecnoSM0[nI][2] + " não efetuada." )
				Exit
			EndIf

			SM0->( dbGoTo( aRecnoSM0[nI][1] ) )

			RpcSetType( 3 )
			RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL )

			lMsFinalAuto := .F.
			lMsHelpAuto  := .F.

			cTexto += Replicate( "-", 128 ) + CRLF
			cTexto += "Empresa : " + SM0->M0_CODIGO + "/" + SM0->M0_NOME + CRLF + CRLF

			oProcess:SetRegua1( 1 )

			//Atualiza o dicionário
			oProcess:IncRegua1( "Dicionário de perguntas - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			AtuDic( @cTexto )

			RpcClearEnv()

		Next nI

		If MyOpenSm0(.T.)
		
			cAux += Replicate( "-", 128 ) + CRLF
			cAux += CRLF
			
			cTexto := cAux + cTexto + CRLF
			cTexto += Replicate( "-", 128 ) + CRLF
			cTexto += " Data / Hora Final.: " + DtoC( Date() ) + " / " + Time()  + CRLF
			cTexto += Replicate( "-", 128 ) + CRLF
			
			cFileLog := MemoWrite( CriaTrab( , .F. ) + ".log", cTexto )

			Define Font oFont Name "Mono AS" Size 5, 12

			Define MsDialog oDlg Title "Atualizacao concluida." From 3, 0 to 340, 417 Pixel

			@ 5, 5 Get oMemo Var cTexto Memo Size 200, 145 Of oDlg Pixel
			oMemo:bRClicked := { || AllwaysTrue() }
			oMemo:oFont     := oFont

			Define SButton From 153, 175 Type  1 Action oDlg:End() Enable Of oDlg Pixel // Apaga
			Define SButton From 153, 145 Type 13 Action ( cFile := cGetFile( cMask, "" ), If( cFile == "", .T., ;
			MemoWrite( cFile, cTexto ) ) ) Enable Of oDlg Pixel

			Activate MsDialog oDlg Center

		EndIf

	EndIf

Else

	lRet := .F.

EndIf

Return lRet

/*
Funcao      : AtuDic  
Retorno     : lEnd     : Indicação de cancelamento do processamento
Objetivos   : Realiza a atualização do dicionário SX1
Autor       : Eduardo C. Romanini
Data/Hora   : 03/06/2015 
*/ 
*----------------------------*
Static Function AtuDic(cTexto)
*----------------------------*
Local aPergs := {"Admin 1 ?"  ,;
                 "Admin 2 ?"  ,;
                 "Contador 1?",;
                 "Contador 2?",;
                 "Contador 3?"}

//Indicação do início da operação
cTexto  += "Inicio da Atualizacao" + " SX1" + CRLF + CRLF

////////////////////////////////////////
//Inicia a atualização no grupo MTR943//
////////////////////////////////////////

//Pesquisa o item com problema 
SX1->(DbSetOrder(1))
If SX1->(DbSeek(PadR("MTR943",10)+"18"))

	If AllTrim(SX1->X1_PERGUNT) <> "Aglutina por CNPJ+IE"
    
   		While SX1->(!EOF()) .and. AllTrim(SX1->X1_GRUPO) == "MTR943"

          	If aScan(aPergs,AllTrim(SX1->X1_PERGUNT)) > 0
				//Grava o dicionário
        		SX1->(RecLock("SX1",.F.))
        	    SX1->(DbDelete())
    	    	SX1->(MSUnlock())   
    	    	
    	    	//Atualização do log da operação
				cTexto += "MTR943: Removida a pergunta " + AllTrim(SX1->X1_PERGUNT) + CRLF

			EndIf

	   		//Atualiza a regua de processamento.
   			oProcess:IncRegua2( "Atualizando itens das perguntas (SX1)..." )
        
        	SX1->(DbSkip())    
		EndDo
	EndIf
EndIf

//Atualiza o pergunte, conforme fonte MTR942
U_PUTSX1("MTR943", ;  	                	            //-- 01 - X1_GRUPO
	'18' , ;                  		                //-- 02 - X1_ORDEM
	'Aglutina por CNPJ+IE', ;          				//-- 03 - X1_PERGUNT
	'aglutinados  CNPJ+IE', ;	       				//-- 04 - X1_PERSPA
	'agglutinated CNPJ+IE', ;        				//-- 05 - X1_PERENG
	'mv_cho', ;                                     //-- 06 - X1_VARIAVL
	'N', ;                                          //-- 07 - X1_TIPO
	1, ;                                            //-- 08 - X1_TAMANHO
	0, ;                                            //-- 09 - X1_DECIMAL
	2, ;                                            //-- 10 - X1_PRESEL
	'C', ;                                          //-- 11 - X1_GSC
	'', ;                                           //-- 12 - X1_VALID
	'', ;                                           //-- 13 - X1_F3
	'', ;                                           //-- 14 - X1_GRPSXG
	'', ;                                           //-- 15 - X1_PYME
	'mv_par18', ;                                   //-- 16 - X1_VAR01
	'Sim' , ;                           			//-- 17 - X1_DEF01
	'Si', ;	                            			//-- 18 - X1_DEFSPA1
	'Yes', ;                            			//-- 19 - X1_DEFENG1
	'', ;                                           //-- 20 - X1_CNT01
	'Nao', ;                            			//-- 21 - X1_DEF02
	'No', ;	                            			//-- 22 - X1_DEFSPA2
	'No', ; 	                           			//-- 23 - X1_DEFENG2
	'', ;                             				//-- 24 - X1_DEF03
	'', ;                             				//-- 25 - X1_DEFSPA3
	'', ;                             				//-- 26 - X1_DEFENG3
	'', ;                                           //-- 27 - X1_DEF04
	'', ;                                           //-- 28 - X1_DEFSPA4
	'', ;                                           //-- 29 - X1_DEFENG4
	'', ;                                           //-- 30 - X1_DEF05
	'', ;                                           //-- 31 - X1_DEFSPA5
	'', ;                                           //-- 32 - X1_DEFENG5
     {'Aglutina a impressão do relatorio por '	,;  //-- 33 - HelpPor1#3
      'CNPJ+IE respeitando a seleção de filiais ',;
      'realizada pelo usuario. Este tratamento'	,;
      'somente sera realizado quando utilizada'	,;
      'a pergunta de seleção de filiais.'		,;
      'Tratamento disponivel somente para '		,;
      'ambientes DBAccess.'				   		},;   
     {'Fusiona la impresión del informe de '	,;  //-- 34 - HelpPor1#3
      'CNPJ+IE sobre la selección de las '	,;
      'sucursales que tiene el usuario. Se'	    ,;
      'llevará a cabo este tratamiento sólo se'	,;
      'utiliza cuando la cuestión de la'		,;
      'selección de ramas.'						,;
      'El tratamiento disponible sólo para'     ,;
      'entornos DBAccess.'                      },;
     {'Coalesces printing of the report by '	,;  //-- 35 - HelpPor1#3
      'CNPJ+IE respecting the selection of '	,;
      'branches held by the User. This treatment',;
      'will be performed only used when the'	,;
      'question of selecting branches.'			,;
      'Treatment available only for DBAccess'   ,;
      'environments.'                           },;
	 '')                                            //-- 36 - X1_HELP


////////////////////////////////////////
//Inicia a atualização no grupo MTR930//
////////////////////////////////////////

//Pesquisa o item com problema 
SX1->(DbSetOrder(1))
If SX1->(DbSeek(PadR("MTR930",10)))

	While SX1->(!EOF()) .and. AllTrim(SX1->X1_GRUPO) == "MTR930"
	    
    	If aScan(aPergs,AllTrim(SX1->X1_PERGUNT)) > 0
			//Grava o dicionário
        	SX1->(RecLock("SX1",.F.))
            SX1->(DbDelete())
    	   	SX1->(MSUnlock())


			//Atualização do log da operação
			cTexto += "MTR930: Removida a pergunta " + AllTrim(SX1->X1_PERGUNT) + CRLF
		EndIf

		oProcess:IncRegua2( "Atualizando itens das perguntas (SX1)..." )
	
		SX1->(DbSkip())
	EndDo

EndIf

//Indicação do término da operação
cTexto += CRLF + "Final da Atualizacao" + " SX1" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF

Return Nil
