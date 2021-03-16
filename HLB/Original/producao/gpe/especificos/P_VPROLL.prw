#include "protheus.ch" 
#include "topconn.ch"

/*
Funcao      : P_VPROLL 
Parametros  : Nenhum
Retorno     : lRet
Objetivos   : Função para validar o nome inserido no campo RV_DPAYROL
Autor     	: Matheus Massarotto 	 	
Data     	: 25/07/2011
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 15/03/2012
Módulo      : Gestão Pessoal.
Cliente     : Todos.
*/

*-----------------------*
 User Function P_VPROLL
*-----------------------*

Local lRet:=.T.
Local lCtl1:=.F.
Local cVar:=M->RV_DPAYROL
Local cQry:=""

if substr(cVar,1,1) $ "1234567890"
	alert("Campo não aceita conteúdo iniciado por número!")
	lRet:=.T.
	lCtl1:=.T.
endif

if !lCtl1
	for i:=1 to len(cVar)
		if substr(cVar,i,1) $ "!@#$%¨&*()-+=?|{}^ªº§¢¬',.;<>:/°\[]²³¹´`~£çÇäáàâãÄÁÀÂÃëéèêËÉÈÊïíìîÏÍÌÎöóòôõÖÓÒÔÕüúùûÜÚÙÛ"
			alert("Caracter especial não aceito: "+substr(cVar,i,1))
			lRet:=.F.
			lCtl1:=.T.
			exit  
		endif
	next
endif

if !lCtl1
	cQry:=" SELECT RV_DPAYROL FROM "+RETSQLNAME("SRV")+CRLF
	cQry+=" WHERE UPPER(SUBSTRING(RV_DPAYROL,1,10))='"+UPPER(SUBSTR(cVar,1,10))+"' AND D_E_L_E_T_='' AND RV_COD<>'"+M->RV_COD+"'"

	if select("TRBPROLL_")>0
		TRBPROLL_->(DbCloseArea())
	endif

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry), "TRBPROLL_" ,.T.,.F.)
			
	COUNT to nRecCount                                           
	
	if nRecCount>0
    	alert("Já existem os 10 primeiros caracteres em outra verba!")
    	lRet:=.F.
    endif        
    
    TRBPROLL_->(DbCloseArea())
endif

return(lRet)