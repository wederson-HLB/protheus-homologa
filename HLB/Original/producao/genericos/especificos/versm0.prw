/*
Funcao      : versm0
Parametros  : pemp
Retorno     : lflag
Objetivos   : 
Autor       : 
Data/Hora   : 
Revisão		: Matheus Massarotto                   
Data/Hora   : 
Módulo      : 
*/

*-------------------------*
User function versm0(pemp)
*-------------------------*
local lflag:=.t.
	IF !(SM0->M0_CODIGO $ pemp)
		_cALERT:=OEMTOANSI("  A T E N C A O  ")
		_cMENS:="Este programa foi desenvolvido especificamente  !!!!!!!!!!!!!!!!!!!!!!" + chr(13)
		_cMENS+="para atender um certo Cliente Pryor ..........  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" + chr(13)
		_cMENS+="CASO TENHA NECESSIDADE PARA A EMPRESA ( "+SM0->M0_CODIGO+" ) !!!!!!!!!"+ chr(13)
		_cMENS+="SOLICITE ORCAMENTO AO DEPTO TI PRYOR !!!!!!!!!!!!!!!!!!!!!!" + chr(13)
		MSGALERT(_CMENS,_CALERT)		
		lflag:=.f.
	endif             
return(lflag)