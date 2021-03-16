#include "rwmake.ch"

/*
Funcao      : MSD2460
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : P.E. na gravacao da NF de Saida (Item a Item),efetuando a gravacao dos Complementos de Serviços de
			  Comunicação (SFX)
Autor       : Ronaldo Bicudo
Data/Hora   : 08/03/2012
Obs         : 
TDN         : 
Revisão     : Renato Rezende
Data/Hora   : 21/01/2014
Obs         : 
Módulo      : Fiscal.
Cliente     : Todos
*/

*-----------------------*
 User Function MSD2460()
*-----------------------*

Local _aAreaSD2 := GetArea()

If cEmpAnt $ "LW"
    //RRP - 28/05/2015 - Inclusão de novas séries. Chamado 026301.
	If EMPTY(SD2->D2_CODISS) .AND. Len(ALLTRIM(SD2->D2_SERIE)) == 3 
		If ALLTRIM(SD2->D2_SERIE) == 'NFC' .OR. Substr(ALLTRIM(SD2->D2_SERIE),1,1) $ 'B/C/D/E/G/H/I/J/K/L/M/O/P' 
	
			// Posicionando SFX
			DbSelectArea("SFX")
			// Efetuamos a gravacao do SFX (Complemento das Notas de Serviço de Comunicação),
			// Apenas para espcie NFSC e que não contenha Codigo de ISS.
			RecLock("SFX",.T.)
			
			REPLACE SFX->FX_FILIAL  with SD2->D2_FILIAL
			REPLACE SFX->FX_TIPOMOV with 'S'
			REPLACE SFX->FX_DOC     with SD2->D2_DOC
			REPLACE SFX->FX_SERIE   with SD2->D2_SERIE
			REPLACE SFX->FX_CLIFOR  with SD2->D2_CLIENTE
			REPLACE SFX->FX_LOJA    with SD2->D2_LOJA
			REPLACE SFX->FX_CLASCON with '99'
			REPLACE SFX->FX_TIPSERV with '1'//0
			REPLACE SFX->FX_ITEM    with SD2->D2_ITEM
			REPLACE SFX->FX_COD     with SD2->D2_COD
			REPLACE SFX->FX_GRPCLAS with '02'
			REPLACE SFX->FX_CLASSIF with '02'
			REPLACE SFX->FX_TIPOREC with '4'
			//RRP - 21/01/2014 - Inclusão do preenchimento dos campos abaixo conforme chamado 016579.
			REPLACE SFX->FX_TPASSIN with '1'
			REPLACE SFX->FX_RECEP	with SD2->D2_CLIENTE
			REPLACE SFX->FX_LOJAREC	with SD2->D2_LOJA
			If !Empty(SD2->D2_EMISSAO)
				REPLACE SFX->FX_PERFIS	with SubStr((DTOS(SD2->D2_EMISSAO)),5,2)+SubStr((DTOS(SD2->D2_EMISSAO)),1,4)
				REPLACE SFX->FX_DTINI	with STOD((SubStr(DTOS(SD2->D2_EMISSAO),1,6) + "01"))
				REPLACE SFX->FX_DTFIM	with LastDay(SD2->D2_EMISSAO)
			EndIf
			                 
			MSUNLOCK()
		
		EndIf
	EndIf
EndIf

//WFA - Customização para empresa Cascade
//LOS - 31/08/2017 - Inclusão para Renesola
If cEmpAnt $ "K1/JG"
	RecLock("SD2",.F.)
		SD2->D2_CCUSTO := SC6->C6_P_CCUST
	SD2->(MSUNLOCK())
EndIf
RestArea(_aAreaSD2)

Return()