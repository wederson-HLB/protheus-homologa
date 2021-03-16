/*
Funcao      : HoraPry
Parametros  : dHora, nFormato
			  ExpH1 := Hora a ser convertida	
			  ExpN1 := Formato (1,2,3)
			  Formato 1 := hhmmss 
Retorno     : xHora
Objetivos   : Determinado forma de grava‡„o para campo hora.
Autor       : Valter/Hamilton
Data/Hora   : 29/10/03
TDN         : 
Revisão     : Renato Rezende 
Data/Hora   : 14/11/2012
Módulo      : Financeiro.
*/

*----------------------------------------*
User Function HoraPry ( dHora, nFormato)
*----------------------------------------*
Local lSepar 	:= ""
Local xHora 	:= Time()

dHora   := Iif( dHora==Nil,Time(),dHora)
nFormato:= Iif( nFormato==Nil,1,nFormato )

Do Case
	Case nFormato == 1
		xHora := Substr(dHora,1,2)+lSepar+Substr(dHora,4,2)+lSepar+Substr(dHora,7,2)
Endcase
Return xHora
