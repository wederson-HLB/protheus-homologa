#include "Protheus.ch"  

/*
Funcao      : P_GTISCC
Parametros  : 
Retorno     : cRet
Objetivos   : CNAB - Fonte para tratamento da agencia/conta, verificando banco ITAU ou não.
Autor       : Matheus Massarotto
Data/Hora   : 03/10/2011
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 06/02/2012
Módulo      : Financeiro.
*/

*------------------------*
  User function P_GTISCC    
*------------------------*

Local cRet:=""

if SA2->A2_BANCO=="341" .OR. SA2->A2_BANCO=="409"

	cRet+="0" //24 a 24
	cRet+=PADL(ALLTRIM(SUBSTR(SA2->A2_AGENCIA,1,4)),4,"0") // 25 a 28
	cRet+=" " //29 a 29
	cRet+=REPLICATE("0",6) //30 a 35
	cRet+=STRZERO(VAL(SUBSTR(ALLTRIM(SA2->A2_NUMCON),1,5)),6) //36 a 41
	cRet+=" " //42 a 42
	cRet+=IIF(AT("-",SA2->A2_NUMCON)>0,SUBSTR(SA2->A2_NUMCON,7,1),SUBSTR(SA2->A2_NUMCON,6,1)) //43 A 43

else

	cRet+=PADL(ALLTRIM(SUBSTR(SA2->A2_AGENCIA,1,4)),5,"0") // 24 a 28
	cRet+=" " //29 a 29

	if AT("-",SA2->A2_NUMCON)>0
		cRet+=STRZERO(VAL(SUBSTR(ALLTRIM(SA2->A2_NUMCON),1,AT("-",SA2->A2_NUMCON)-1)),12) //30 a 41
		if AT("-",SA2->A2_NUMCON)>0
			cRet+=PADL(ALLTRIM(SUBSTR(SA2->A2_NUMCON,AT("-",SA2->A2_NUMCON)+1,2)),2) //42 A 43
		else
			cRet+="  " //42 a 43 
		endif
	else
		cRet+=STRZERO(VAL(SUBSTR(ALLTRIM(SA2->A2_NUMCON),1,len(alltrim(SA2->A2_NUMCON)))),12) //30 a 41
		
		cRet+="  " //42 A 43
	endif
endif

Return(cRet)