#Include "Protheus.ch"
#Include "TBICONN.ch"

/*
Funcao      : GTCORP55
Parametros  : 
Retorno     : 
Objetivos   : Fonte utilizado por schedules, Atualiza a tabela do SA1 de todas as empresas do GTCORP com base no GTHD.
Autor       : Matheus Massarotto
Data/Hora   : 29/01/2013    20:42
Revisão		:                    
Data/Hora   : 
Módulo      : Genérico
*/

*--------------------*
User function GTCORP55
*--------------------*
Local cQry		:=""
Local cEmpContro:=""

RpcClearEnv()
RpcSetType(3)
Prepare Environment Empresa "YY" Filial "01"

DbSelectArea("SM0")
DbSetOrder(1)
SM0->(DbGoTop())

While SM0->(!EOF())

	if cEmpContro==SM0->M0_CODIGO
		SM0->(DbSkip())
		Loop
	endif

	cQry:=" UPDATE SA1"+ALLTRIM(SM0->M0_CODIGO)+"0 SET A1_P_CODFI=Z04_CODFIL,A1_P_CODIG=Z04_CODIGO,A1_P_BANCO=Z04_AMB,A1_P_SERVI=Z04_SERVID,A1_P_PORTA=Z04_PORTA
	cQry+=" FROM SA1"+ALLTRIM(SM0->M0_CODIGO)+"0 SA1
	cQry+=" JOIN SQLTB717.GTHD.dbo.Z04010 HD ON A1_CGC=Z04_CNPJ
	cQry+=" WHERE SA1.D_E_L_E_T_='' AND HD.D_E_L_E_T_=''
	cQry+=" AND A1_CGC<>'' AND HD.Z04_AMB NOT IN ('PAGUS','PORTAL')
	cQry+=" AND HD.Z04_NOME<>'TESTE'     
	cQry+=" AND HD.Z04_SIGMAT = 'S'"
	
	if TcSqlExec(cQry)<0
		conout("GTCORP55 -----> Erro ao atualizar a tabela SA1"+ALLTRIM(SM0->M0_CODIGO)+"0")
	else
		conout("GTCORP55 -----> Atualizou a tabela SA1"+ALLTRIM(SM0->M0_CODIGO)+"0")
	endif
	
	cEmpContro:=SM0->M0_CODIGO
	
SM0->(DbSkip())
Enddo

Return