
/*
Funcao      : TRAILLER
Parametros  : _nOpc
Retorno     : _cRet
Objetivos   : Retorna o valor total ou o valor da multa
Autor       : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 06/02/2012
Módulo      : Financeiro.
*/    

*------------------------------*
  USER FUNCTION TRAILLER(_nOpc)
*------------------------------*   

Local _nVlrTotal	:= 0   
Local _nMulta		:= 0
Local aArea			:= GetArea()

     
DBSELECTAREA("SE2")
SE2->(DBGOTOP())
cInd	:= Criatrab(Nil,.F.)
cKey	:= "E2_FILIAL + E2_NUMBOR"
cFil 	:= ""	
IndRegua("SE2",cInd,cKey,,cFil,"Selecionando Registros ...")

SE2->(DBSEEK(xFilial("SE2")+ MV_PAR01))
WHILE SE2->(!EOF()) .AND. SE2->E2_NUMBOR == MV_PAR01
	_nVlrTotal += SE2->E2_SALDO
	_nMulta    += SE2->E2_ACRESC
	SE2->(DBSKIP())
ENDDO  

_nVlrTotal 	:= STRZERO((_nVlrTotal * 100),14)
_nMulta		:= STRZERO((_nMulta * 100),14)   

IF _nOpc == 'V'
	_cRet	:= _nVlrTotal
ELSEIF _nOpc == 'M' 
	_cRet	:= _nMulta
ENDIF

RestArea(aArea)

RETURN _cRet