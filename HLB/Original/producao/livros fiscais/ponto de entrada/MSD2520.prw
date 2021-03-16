#include "rwmake.ch"

/*
Funcao      : MSD2520
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : P.E. para exclusão da NF de Saida (Item a Item), da tabela de Complementos de Serviços de Comunicação (SFX).
			  Comunicação (SFX)
Autor       : Ronaldo Bicudo
Data/Hora   : 07/03/2012
Obs         : 
TDN         : 
Revisão     : Renato Rezende
Data/Hora   : 22/01/2014
Obs         : 
Módulo      : Fiscal.
Cliente     : Todos
*/

*-------------------------*
 User Function MSD2520()
*-------------------------*
LOCAL _aAreaS := GetArea() 

If cEmpAnt $ "LW"
	DbSelectArea("SFX")
	DbSetOrder(1)
	If DbSeek(xFilial("SF2")+"S"+SF2->F2_SERIE+SF2->F2_DOC,.T.)
		RecLock("SFX",.F.) // Define que será realizada uma alteração no registro posicionado
			DbDelete() // Efetua a exclusão lógica do registro posicionado.
		MsUnLock()
	EndIf
EndIf

RestArea(_aAreaS)
	
Return()