/*
Funcao      : FA080PE 
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : P.E.  para deixar o campo E5_LA = 'N' quando a baixa for por da��o
Autor       : Jos� Ferreira
Data/Hora   : 11/05/06     
Obs         : 
TDN         : O ponto de entrada FA080PE sera executado na saida da funcao de baixa, apos gravar todos os dados e ap�s a contabiliza��o.
Revis�o     : Tiago Luiz Mendon�a 
Data/Hora   : 18/07/2012
Obs         :
M�dulo      : Financeiro.
Cliente     : WFI
*/
   
*------------------------*
 User Function FA080PE()
*------------------------*

	If cEmpAnt $ "DJ"
	   _cAlias := Alias()
	   DbSelectArea("SE5")
	   Reclock("SE5",.F.)
	   Replace E5_CCD With SE2->E2_P_CC
	   MsUnlock()
	   DbSelectArea(_cAlias)
	Endif
	IF cMotBx $ "DACAO"
		cAlias:=ALIAS()
      dbselectArea("SE5")          
      ReClock("SE5",.F.)
	   E5_LA := "N"                                                      	
		MsUnlock()
	   dbSelectArea(cAlias)
	ENDIF

Return(.T.)