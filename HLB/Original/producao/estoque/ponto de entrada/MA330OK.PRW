#include "protheus.ch"
#include "topconn.ch"
/*
Funcao      : MA330OK
Parametros  : 
Retorno     : lRet
Objetivos   : PONTO DE ENTRADA -utilizado para alterar o campo CT2_ROTINA, para solucionar o problema abaixo:
			: 					A Harris possui 2 fechamentos (gerencial/societ�rio), no gerencial � gerado um lan�amento cont�bil, quando 
			: 					� feito o fechamento societ�rio ao inv�s de estornar o lan�amento do gerencial e criar um novo no societ�rio 
			: 					ele exclui o que foi feito no gerencial e assumi  o lan�amento societ�rio. (Harris - K2)
TDN			: MA330OK - Validar execu��o do rec�lculo do custo m�dio
Autor       : Matheus Massarotto
Data/Hora   : 19/04/2012    17:05
Revis�o		: 
Data/Hora   : 
M�dulo      : Estoque
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
		/*Verifica se j� foi processado a altera��o da rotina no periodo*/
			cQry+=" SELECT CT2_ROTINA FROM "+RETSQLNAME("CT2")
			cQry+=" WHERE SUBSTRING(CT2_DATA,1,6) ='"+cData+"' AND CT2_ROTINA='RCMHARRIS' AND D_E_L_E_T_='' AND CT2_FILIAL='"+xFilial("CT2")+"'"
		
			if select("QRYTEMP")>0
				QRYTEMP->(DbCloseArea())
			endif
			
			DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )
			
			Count to nRecCount
			/*Se n�o foi processada a atualiza��o do campo CT2_ROTINA ent�o faz a atualiza��o UPDATE*/
			if nRecCount<=0
				cQryUpd+=" UPDATE "+RETSQLNAME("CT2")+" SET CT2_ROTINA='RCMHARRIS'
				cQryUpd+=" WHERE SUBSTRING(CT2_DATA,1,6) ='"+cData+"' AND CT2_ROTINA='MATA330' AND D_E_L_E_T_='' AND CT2_FILIAL='"+xFilial("CT2")+"'"
				
				nErro:=TcSqlExec(cQryUpd)
				
				if nErro<0
					CONOUT("-->ERRO-->>ROTINA-->MA330OK - Problema na atualiza��o do recalculo do custo m�dio pela segunda vez no mesmo m�s.(Harris)")
				endif
			endif
    endif
endif

RestArea(aArea)
Return(lRet)