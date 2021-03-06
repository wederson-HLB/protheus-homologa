#Include 'Protheus.ch'

/*
Funcao      : MA103OPC
Parametros  : Nil
Retorno     : Nil
Objetivos   : Ponto de entrada para adi??o de itens ao aRotina
TDN			: 	LOCALIZA??O : MATA103(Notas Fiscais de Entrada 
				EM QUE PONTO : Ponto de Entrada utilizado para adicionar itens no menu
Autor       : Matheus Massarotto
Data/Hora   : 15/01/2014    10:14
Revis?o		:                    
Data/Hora   : 
M?dulo      : Estoque
*/

*-----------------------*
User Function MA103OPC()
*-----------------------*
Local aRet := {}
Local lFluig := SuperGetMv("MV_P_00109",.T.,.F.) 

If cEmpAnt $ "LX/LW"
	aAdd(aRet,{'Imp Capinha', 'U_GTEST002()', 0, 5})
ElseIf cEmpAnt $ "6W/73"
	aAdd(aRet,{'Imp Capinha', 'U_6WEST001()', 0, 5})
//RRP - 03/03/2017 - Altera??o N?mero Protocolo para o grupo Solaris
ElseIf cEmpAnt $ "HH/HJ/IK/"
	aAdd(aRet,{'Num Protocolo', 'U_HHEST003(1)', 0, 5})
EndIf
//RSB - 23/10/2017 - Exibe a tela do numero do Fluig no menu de a??es relacionadas.
If lFluig
	aAdd(aRet,{'Num.ID', 'U_GTGEN042()', 0, 4})
Endif

Return aRet