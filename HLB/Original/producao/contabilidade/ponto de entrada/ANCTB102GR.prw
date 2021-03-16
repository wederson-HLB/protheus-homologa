#include "rwmake.ch"
#include "protheus.ch"
#Include "TopConn.Ch"

/*
Funcao      : ANCTB102GR
Parametros  : ParamIXB - { nOpcx , dDataLanc , cLote , cSubLote , cDoc }
Retorno     : Nenhum
Objetivos   : P.E. para validar a gravação do Lançamento.
Autor     	: Jean Victor Rocha
TDN         : Ponto de entrada para tratativa do temporario antes da gravação do lançamento
Data     	: 14/09/2015                     
Módulo      : Contabil. 
*/
*------------------------*
User Function ANCTB102GR()
*------------------------*
Local aArea
Local aAreaCT2

Local nOpc			:= ParamIxb[ 1 ]
Local cChave    	:= xFilial( 'CT2' ) + DtoS( ParamIxb[ 2 ] ) + ParamIxb[ 3 ] + ParamIxb[ 4 ] + ParamIxb[ 5 ]

Local aCompara      := { 'CT2_CREDIT' , 'CT2_DEBITO' , 'CT2_DC' , 'CT2_VALOR' , 'CT2_HIST' , 'CT2_HP' , 'CT2_CCD' , 'CT2_CCC' , 'CT2_ITEMC' ,;
						'CT2_ITEMD' , 'CT2_TPSALD' , 'CT2_ORIGEM' }

//Executa caso for Copia de lançamento
If nOpc == 7
	TMP->(DbGoTop())
	While TMP->(!EOF())
		TMP->CT2_ORIGEM := "CPY-"+TMP->CT2_LP+"-"+SUBS(CUSUARIO,7,15)
		TMP->(DbSkip())
	EndDo
Else
	//LDB - 23/05/2016 - Leandro Diniz de Brito ( BRL Consulting ) - Especifico Paypal 
	Do Case
		Case ( cEmpAnt $ '7W' ) .And. GetNewPar( 'MV_P_00075' , .T. )	//** PayPal
			If ( nOpc == 4 )  		//** Alteração do lançamento
				
				TMP->( DbGoTop() )
				While TMP->( !Eof() )
					If TMP->CT2_RECNO > 0
						CT2->( DbGoTo( TMP->CT2_RECNO ) )
						
						If CT2->( !Eof() )
							For i := 1 To Len( aCompara )
								If TMP->&( aCompara[ i ] ) <> CT2->&( aCompara[ i ] )
									u_GravaZX2( 'CT2' , cChave + TMP->CT2_LINHA , aCompara[ i ] , CT2->&( aCompara[ i ] ) , TMP->&( aCompara[ i ] ) )
								EndIf
							Next
						EndIf
						
					Else
						u_GravaZX2( 'CT2' , cChave + TMP->CT2_LINHA , aCompara[ i ] , "" , TMP->&( aCompara[ i ] ) )
					EndIf
					
					TMP->( DbSkip() )
				EndDo  
				TMP->( DbGoTop() )
			EndIf
	EndCase
EndIf

Return

/*
Função.............: GravaZX2
Objetivo...........: Grava Log de uma Tabela do BD 
Autor..............: Leandro Diniz de Brito ( BRL Consulting )
Data...............: 23/05/2016
Observações........:
Parametros.........: ( cChave , cCampo , xAntigo , xNovo )
*/

*---------------------------------------------------------------------*
User Function GravaZX2( cAlias ,cChave , cCampo , xAntigo , xNovo )
*---------------------------------------------------------------------*

If AliasInDic( 'ZX2' )
	ZX2->( RecLock( 'ZX2' , .T. ) )
	ZX2->ZX2_FILIAL := xFilial( 'ZX2' )
	ZX2->ZX2_TAB	:= RetSqlName( cAlias ) 
	ZX2->ZX2_USER	:= cUserName 
	ZX2->ZX2_ID		:= __cUserID
	ZX2->ZX2_DATA	:= dDataBase
	ZX2->ZX2_HORA 	:= Left( Time() , 5 )
	ZX2->ZX2_CAMPO	:= cCampo
	ZX2->ZX2_ANTIGO := cValToChar( xAntigo )
	ZX2->ZX2_NOVO 	:= cValToChar( xNovo )
	ZX2->ZX2_ROTINA := FunName()
	ZX2->ZX2_CHAVE  := cChave 
	ZX2->( MSUnlock() )
EndIf

Return