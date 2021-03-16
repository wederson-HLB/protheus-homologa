#include "TOPCONN.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"  
#include "Protheus.ch"
#include "Rwmake.ch"       

/*
Funcao      : SPDFIS10
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Ponto de Entrada SPDFIS10 aplicado no SPEDFISCAL que grava as informações do 
			: Registro 1600: Total de operações com cartão de crédito e/ou débito.
Autor       : Jean Victor Rocha.
Data/Hora   : 02/07/2013
*/                        
*----------------------*
User Function SPDFIS10()
*----------------------*
Local aRet		:= {} 
Local aParam   := ParamIXB

Local cDataDe	:= DtoS(aParam[1])
Local cDataAte	:= DtoS(aParam[2])
Local nTotCC	:= 0
Local nTotCD	:= 0

If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf

BeginSql Alias 'QRY'
    SELECT * FROM %table:SE1%
    WHERE %notDel%
      AND E1_FILIAL 	= 	%exp:cFilAnt%
      AND E1_EMISSAO 	>= 	%exp:cDataDe%
      AND E1_EMISSAO 	<= 	%exp:cDataAte%
      AND E1_EMISSAO 	<= 	%exp:cDataAte% 
      AND E1_PREFIXO 	= 	'ECF'
      AND (E1_TIPO = 'CC' OR E1_TIPO = 'CD')
EndSql

QRY->(DbGoTop())
While QRY->(!EOF())             
    If ALLTRIM(QRY->E1_TIPO) == "CC"
    	nTotCC 		+= QRY->E1_VALOR
    	cClienteCC 	:= "   "+xFilial("SA1")+QRY->E1_CLIENTE+QRY->E1_LOJA
    	cClienteDC	:= QRY->E1_NOMCLI
    	
    ElseIf ALLTRIM(QRY->E1_TIPO) == "CD"
    	nTotCD 		+= QRY->E1_VALOR 
    	cClienteCD 	:= "   "+xFilial("SA1")+QRY->E1_CLIENTE+QRY->E1_LOJA
    	cClienteDD	:= QRY->E1_NOMCLI
    EndIf
	QRY->(DbSkip())
EndDo

If nTotCC <> 0
	aAdd (aRet, {cFilAnt,cClienteCC,cClienteDC,nTotCC,0})
EndIf
If nTotCD <> 0
	aAdd (aRet, {cFilAnt,cClienteCD,cClienteDD,0,nTotCD})
EndIf

If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf

Return aRet