#Include "Protheus.ch"

/*
Funcao      : LWEST001
Parametros  : Nil
Retorno     : Nil
Objetivos   : Fun��o para validar no documento de entrada a Qtd de d�gitos do n�mero, e se o N�mero+S�rie+Cnpj Fornecedor j� existem, em outras filiais
Autor       : Matheus Massarotto
Data/Hora   : 03/02/2015    17:45
Revis�o		:                    
Data/Hora   : 
M�dulo      : Estoque
*/

*---------------------*
User Function LWEST001
*---------------------*
Local lRet		:= .T.
Local nTamanho  := GetNewPar("MV_P_00044",0)
Local cCampo	:= READVAR()
Local aArea		:= GetArea()

if cCampo=="CNFISCAL" //N�mero

	if !empty(CNFISCAL)
		if len(alltrim(CNFISCAL))<nTamanho
			MsgStop("Por favor, infome o n�mero do documento com pelo menos "+cvaltochar(nTamanho)+" d�gitos.","HLB BRASIL")
			lRet:=.F.
		else
			BuscaNF()
		endif
	endif
elseif cCampo $ "CSERIE/CA100FOR/CLOJA" //S�rie
	BuscaNF()
endif


RestArea(aArea)	
Return(lRet)


/*
Funcao      : BuscaNF()
Parametros  : 
Retorno     : 
Objetivos   : Fun��o para buscar informa��es de notas em filiais
Autor       : Matheus Massarotto
Data/Hora   : 03/02/2015	17:10
*/

*----------------------------*
Static Function BuscaNF()
*----------------------------*
Local cQry	:= "" 

cQry:=" SELECT F1_FILIAL,A2_NOME FROM "+RETSQLNAME("SF1")+" SF1"
cQry+=" LEFT JOIN "+RETSQLNAME("SA2")+" SA2 ON SA2.A2_COD=SF1.F1_FORNECE AND SA2.A2_LOJA=SF1.F1_LOJA AND SA2.D_E_L_E_T_=''
cQry+=" WHERE SF1.F1_DOC = '"+CNFISCAL+"' AND SF1.F1_SERIE='"+CSERIE+"' AND SF1.D_E_L_E_T_=''
cQry+=" AND (A2_CGC IN (
cQry+=" SELECT A2_CGC FROM "+RETSQLNAME("SA2")
cQry+=" WHERE D_E_L_E_T_='' AND A2_COD='"+CA100FOR+"' AND A2_LOJA='"+CLOJA+"'
cQry+=" ) OR (A2_COD='"+CA100FOR+"' AND A2_LOJA='"+CLOJA+"') )

	if select("QRYTEMP")>0
		QRYTEMP->(DbCloseArea())
	endif

	DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )
	
	Count to nRecCount
        
	if nRecCount >0
		QRYTEMP->(DbGoTop())
   		MsgInfo("N�mero e s�rie encontrados na filial: "+alltrim(QRYTEMP->F1_FILIAL)+CRLF+"Fornecedor: "+alltrim(QRYTEMP->A2_NOME),"HLB BRASIL")
	endif

Return