#include "protheus.ch"
#include "topconn.ch"
/*
Funcao      : MA330OK
Parametros  : 
Retorno     : lRet
Objetivos   : PONTO DE ENTRADA -utilizado para alterar o campo CT2_ROTINA, para solucionar o problema abaixo:
			: 					A Harris possui 2 fechamentos (gerencial/societário), no gerencial é gerado um lançamento contábil, quando 
			: 					é feito o fechamento societário ao invés de estornar o lançamento do gerencial e criar um novo no societário 
			: 					ele exclui o que foi feito no gerencial e assumi  o lançamento societário. (Harris - K2)
TDN			: MA330OK - Validar execução do recálculo do custo médio
Autor       : Matheus Massarotto
Data/Hora   : 19/04/2012    17:05
Revisão		: 
Data/Hora   : 
Módulo      : Estoque
Cliente		: Harris(K2)
*/
*--------------------*
User Function MA330OK
*--------------------*
Local lRet:=.T.
Local aArea		:= GetArea()
Local cData:=""
Local cQry:=""
Local cQryUpd:=""
Local nErro:=0

//Funcionalidade exclusiva para Harris
if cEmpAnt $ "K2/IL"
	//tratamento para utilizar na data AAAAMM
	cData:=SUBSTR((DTOS(MV_PAR01)),1,6)
    
	if !empty(cData)
		/*Verifica se já foi processado a alteração da rotina no periodo*/
			cQry+=" SELECT CT2_ROTINA FROM "+RETSQLNAME("CT2")
			cQry+=" WHERE SUBSTRING(CT2_DATA,1,6) ='"+cData+"' AND CT2_ROTINA='RCMHARRIS' AND D_E_L_E_T_='' AND CT2_FILIAL='"+xFilial("CT2")+"'"
		
			if select("QRYTEMP")>0
				QRYTEMP->(DbCloseArea())
			endif
			
			DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )
			
			Count to nRecCount
			/*Se não foi processada a atualização do campo CT2_ROTINA então faz a atualização UPDATE*/
			if nRecCount<=0
				cQryUpd+=" UPDATE "+RETSQLNAME("CT2")+" SET CT2_ROTINA='RCMHARRIS'
				cQryUpd+=" WHERE SUBSTRING(CT2_DATA,1,6) ='"+cData+"' AND CT2_ROTINA='MATA330' AND D_E_L_E_T_='' AND CT2_FILIAL='"+xFilial("CT2")+"'"
				
				nErro:=TcSqlExec(cQryUpd)
				
				if nErro<0
					CONOUT("-->ERRO-->>ROTINA-->MA330OK - Problema na atualização do recalculo do custo médio pela segunda vez no mesmo mês.(Harris)")
				endif
			endif
    endif
endif

RestArea(aArea)
Return(lRet)