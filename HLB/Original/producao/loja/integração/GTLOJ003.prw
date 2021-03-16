#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "TOTVS.CH"
#Include "rwmake.ch" 
#Include "colors.ch"   
/*
Funcao      : GTLOJ003
Parametros  : Nil
Retorno     : Nil
Objetivos   : Browse para a tabela de log da Z99
Autor       : Jean Victor Rocha
Data/Hora   : 07/09/2016
*/
*----------------------*
User Function GTLOJ003()
*----------------------* 
Private cCadastro := "Log de processamento"
Private aCores		:= {}
Private aRotina := {{"Visualizar", "AxVisual", 0, 2}}
					
MBrowse( 6,1,22,75,"Z99",,,,,,,,)

Return .T.