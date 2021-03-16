#Include "Protheus.Ch"
#Include "Topconn.Ch"
#Include "TbiConn.Ch"

/*
Funcao      : HHFAT004 
Parametros  : aEmp,aItens
Retorno     : aRet
Objetivos   : Processar Consulta de produto  - Web Service
Autor       : Anderson Arrais 
Data/Hora   : 10/09/2018
*/
*----------------------------------------------------* 
 User Function HHFAT004( aEmp,cCodProd,cArmaz )
*----------------------------------------------------*
Local lErro 	:= .F.

Local cResultInt:= ""
Local cCodProd	:= Alltrim(cCodProd)
Local cChave	:= cCodProd
Local cArmaz	:= Alltrim(cArmaz)
Local cQr		:= ""
Local cCodProd4 := ""
Local cArmaz4	:= ""

Local aRet		:= {}

Local nR		:= 0 
Local nSaldo	:= 0

//Private lMsHelpAuto		:= .T.
//Private lMsErroAuto		:= .F.
//Private lAutoErrNoFile	:= .T. //Caso queira utilizar a função MostraErro() deverá deixar esse parâmetro como .F.

Private cArqLog			:= ""

conout("Entrou HHFAT004")
conout(aEmp[1]+" "+aEmp[2])

RpcClearEnv()
RpcSetType( 3 )
PREPARE ENVIRONMENT EMPRESA aEmp[1] FILIAL aEmp[2] TABLES "SB1" , "SB2"  MODULO "FAT"
conout("Preparou HHFAT004")

//1- Verificar se o produto existe no sistema

//Procurando produto no sistema
DbSelectArea("SB1")
SB1->(DbGoTop())
SB1->(DbSetOrder(1))
If SB1->(DbSeek(xFilial("SB1") + cCodProd ))
	//Produto encontrado
	cCodProd4 := cCodProd
	cQr:=" SELECT B1_COD,B1_LOCPAD FROM "+RetSqlName("SB1") +CRLF
	cQr+=" WHERE D_E_L_E_T_='' AND B1_FILIAL='"+xFilial("SB1")+"' AND B1_COD='"+cCodProd+"' AND B1_LOCPAD='"+cArmaz+"'"
	
	If Select("QRYTEMP")>0
		QRYTEMP->(DbCloseArea())
	EndIf
	
	DbUseArea( .T., "TOPCONN", TcGenqry( , , cQr), "QRYTEMP", .F., .F. )
	
	Count to nRecCount
	       
	If nRecCount >0
		cArmaz4 := cArmaz
		DbSelectArea("SB2")
		SB2->(DbSetOrder(1))
		If SB2->(DbSeek(xFilial("SB2")+(cCodProd+space(TamSx3("B2_COD")[1]-len(cCodProd)))+(Alltrim(cArmaz)+space(TamSx3("B2_LOCAL")[1]-len(Alltrim(cArmaz))))))
			//Estoque fisico encontrado
			nSaldo := SaldoSb2()//SB2->B2_QATU
		Else
			//Produto+armazem não encontrado
			nSaldo := 0
		EndIf
	Else
		//Armazem não encontrado
		cCodProd4	:= cCodProd
		cArmaz4 	:= "Armazem nao encontrado"
	EndIf
Else
	//Produto não cadastrado
	cCodProd4	:= "Produto nao encontrado"
	cArmaz4		:= " " 
EndIf

SB1->(DbClosearea())
SB2->(DbClosearea())

cArqLog := cCodProd4+" - "+cArmaz4
//Grava na Tabela de Log	
u_HHGEN001("SB2",cChave,.T.,"Consulta Produto/Saldo",cArqLog)

AADD(aRet,lErro)
AADD(aRet,cCodProd4)
AADD(aRet,cArmaz4)
AADD(aRet,cValToChar(nSaldo))

Return aRet