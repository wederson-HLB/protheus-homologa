#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"

/*
Funcao      : GTGEN009
Parametros  : aParam
Retorno     : 
Objetivos   : Fonte para ser utilizado via schedule, para executar a rotina de recalculo de custo médio(MATA330)
Autor       : Matheus Massarotto
Data/Hora   : 29/11/2012 14:00
Revisão     :
Data/Hora   :
Módulo      : Estoque Custos
Clientes    : Shiseido
TDN         :
*/

*----------------------------*
User Function GTGEN009(aParam)
*----------------------------*

Local lCPParte  := .F. // Define que não sera processado o custo em partes
Local lBat      := .T. // Define que a rotina sera executada em Batch
Local lRet		:= .F. // Retorna se conseguiu preparar o ambiente

Local cCodFil   := ''  // Codigo da Filial a ser processada
Local cNomFil   := ''  // Nome da Filial a ser processada
Local cCGC      := ''  // CGC da filial a ser processada

Local cUsua     := "custo" 	// Usuário
Local cSenh		:= "CustO1" // Senha

Local aTables	:= {"AF9","SB1","SB2","SB3","SB8","SB9","SBD","SBF","SBJ","SBK","SC2","SC5","SC6","SD1","SD2","SD3","SD4","SD5","SD8","SDB","SDC","SF1","SF2","SF4","SF5","SG1","SI1","SI2","SI3","SI5","SI6","SI7","SM2","ZAX","SAH","SM0","STL"} // Tabelas utilizadas
Local aListaFil := {}  // Carrega Lista com as Filiais a serem processadas

Private cEmp	:= ""
Private cFils	:= ""

if len(aParam)<=0
	conout("--> Fonte:GTGEN009, Não foi passado paramêtros para a função. Deve ser passado somente o código da empresa ou empresa + filiais")
	Return
elseif len(aParam)==1
	cEmp	:= aParam[1]
	conout("--> Fonte:GTGEN009, Definida a empresa: "+cEmp)
elseif len(aParam)>1
	
	cEmp	:= aParam[1]
	
	for i:=2 to len(aParam)
		cFils+=aParam[i]+","
	next
	
	conout("--> Fonte:GTGEN009, Definida a empresa: "+cEmp+", e Filiais:"+cFils)
endif

//**************************Prepara o ambiente**********************************//
lRet	:= RpcSetEnv( cEmp,"01", cUsua, cSenh, "EST", "MATA330", aTables, , , ,  )
//************************FIM Prepara o ambiente********************************//

if lRet
	conout("--> Fonte:GTGEN009, Ambiente preparado com sucesso")
else
	conout("--> Fonte:GTGEN009, Não foi possível preparar ambiente, Empresa: "+cEmp+", Filial: 01 , Usuário: "+cUsua+", Senha:"+cSenh)
	Return
endif

//Alterando o pergunte, parametro 01 - Data limite para processamento
DbSelectArea("SX1")
if DbSeek("MTA330    "+"01")
	RecLock("SX1",.F.)
		SX1->X1_CNT01:=DTOS(dDataBase)
	SX1->(MsUnlock())
	conout("--> Fonte:GTGEN009, Foi definido a data: "+DTOC(dDataBase))
else
	conout("--> Fonte:GTGEN009, SX1:'MTA330    01' não foi encontrado.")
endif

// Adiciona filial a ser processada
DbSelectArea("SM0")
if DbSeek(cEmpAnt)
	Do While SM0->(!Eof()) .And. SM0->M0_CODIGO == cEmpAnt
		cCodFil := SM0->M0_CODFIL
		cNomFil := SM0->M0_FILIAL
		cCGC    := SM0->M0_CGC
		
		// Verifica se deve executar somente as filiais indicadas, ou todas
		if empty(cFils)
			Aadd(aListaFil,{.T.,cCodFil,cNomFil,cCGC,.F.})
			conout("--> Fonte:GTGEN009, Todas as filiais ")
		else
			if SM0->M0_CODFIL $ cFils
				Aadd(aListaFil,{.T.,cCodFil,cNomFil,cCGC,.F.})
				conout("--> Fonte:GTGEN009, Somente a filial: "+SM0->M0_CODFIL)
			endif
		endif
		
		SM0->(dbSkip())
	EndDo
else
	conout("--> Fonte:GTGEN009, Não encontrado empresa: "+cEmpAnt)
endif

// Executa a rotina de recalculo do custo médio
MATA330(lBat,aListaFil,lCPParte)                 

//Finaliza o ambiente
RESET ENVIRONMENT

conout("--> Fonte:GTGEN009, Termino da execucao")

Return