#INCLUDE 'TOTVS.CH'

/*
Funcao      : USX3057
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Atualizar o tamanho do campo CVN_DSCCTA
Autor       : Eduardo C. Romanini
Data/Hora   : 08/06/2015 
*/               
*---------------------*
User Function USX3057()
*---------------------*

Local   aSay      := {}
Local   aButton   := {}
Local   aMarcadas := {}
Local   cTitulo   := "Atualização de Dicionários de Dados"
Local   cDesc1    := "Esta rotina tem como função fazer  a atualização  dos dicionários de Dados do Sistema     "
Local   cDesc2    := "Este processo deve ser executado em modo EXCLUSIVO, ou seja não podem haver outros        "
Local   cDesc3    := "  usuários  ou  jobs utilizando  o sistema.  É extremamente recomendavél  que  se  faça um"
Local   cDesc4    := "  BACKUP  dos DICIONÁRIOS  e da  BASE DE DADOS antes desta atualização.                   "
Local   cDesc5    := "Objetivo: Atualizar o tamanho dos campos do plano de contas referencial.                  "
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
			MsgStop( "Atualização não Realizada.", "USX3056" )

		EndIf

	Else
		MsgStop( "Atualização não Realizada.", "USX3056" )

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

			oProcess:SetRegua1( 2 )

			//Atualiza o dicionário
			oProcess:IncRegua1( "Dicionário de dados - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			AtuDic( @cTexto )

			oProcess:IncRegua1( "Base de dados - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			oProcess:IncRegua2( "Atualizando campos/índices" )
			// Alteracao fisica dos arquivos
			__SetX31Mode( .F. )

			For nX := 1 To Len( aArqUpd )

				If Select( aArqUpd[nX] ) > 0
					dbSelectArea( aArqUpd[nX] )
					dbCloseArea()
				EndIf

				X31UpdTable( aArqUpd[nX] )

				If __GetX31Error()
					Alert( __GetX31Trace() )
					MsgStop( "Ocorreu um erro desconhecido durante a atualização da tabela : " + aArqUpd[nX] + ". Verifique a integridade do dicionário e da tabela.", "ATENÇÃO" )
					cTexto += "Ocorreu um erro desconhecido durante a atualização da estrutura da tabela : " + aArqUpd[nX] + CRLF
				EndIf

			Next nX

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
Objetivos   : Realiza a atualização do dicionário SX3
Autor       : Eduardo C. Romanini
Data/Hora   : 03/06/2015 
*/ 
*----------------------------*
Static Function AtuDic(cTexto)
*----------------------------*
Local lAtuTam := .F.

Local nTamanho := 0
Local nI       := 0

Local aCampos := {}
 
//Indicação do início da operação
cTexto  += "Inicio da Atualizacao" + " SX3" + CRLF + CRLF

//Identificação dos campos que serão atualizados
aCampos:= {{"CVN","CVN_DSCCTA",250},;
           {"CVN","CVN_LINHA" ,4  }}

//Inicia a Atualização
For nI:=1 To Len(aCampos)
	
	//Reinicia as variáveis
	lAtuTam := .F.
	nTamanho := aCampos[nI][3]
	
	//Pesquisa o campo no dicionário	
	SX3->(DbSetOrder(2))
	If SX3->(DbSeek(aCampos[nI][2]))
        	
		//Verifica se o tamanho no dicionário é menor que o esperado
		If SX3->X3_TAMANHO < nTamanho
        	lAtuTam := .T.	
 		EndIf
 		
		//Verifica se a atualização é necessária
		If lAtuTam 
			
			//Trava o registro
			SX3->(RecLock("SX3",.F.))
			
			//Atualiza o tamanho
			If lAtuTam
				SX3->X3_TAMANHO := nTamanho
			EndIf
			
			//Destrava o registro
			SX3->(MSUnlock())		
            
            //Indica a tabela para atualização.
  			If aScan(aArqUpd, {|x| x == aCampos[nI][1] }) == 0
		  		aAdd(aArqUpd, aCampos[nI][1])
            EndIf
            
           	//Atualização do log da operação
			cTexto += "Atualizado o tamanho do campo " + aCampos[nI][2] + CRLF
            
		EndIf
	EndIf
	
	//Atualiza a regua de processamento.
	oProcess:IncRegua2( "Atualizando Campos de Tabelas (SX3)..." )

Next nI

//Indicação do término da operação
cTexto += CRLF + "Final da Atualizacao" + " SX3" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF

Return Nil