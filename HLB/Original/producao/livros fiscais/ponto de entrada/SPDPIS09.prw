#include 'totvs.ch' 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SPDPIS09  ºAutor  ³Eduardo C. Romanini º Data ³  27/02/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de Entrada para gravação dos registros do Bloco F100  º±±
±±º          ³lançados manualmente atraves da rotina customizada - GTFIS001±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GT                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*----------------------*
User Function SPDPIS09()
*----------------------*
Local cDesFil  := ""
Local cFil     := ""
Local cDataDe  := ""
Local cDataAte := ""

Local aParam   := ParamIXB
Local aRetF100 := {}
Local aAuxF100 := {}

cFil := aParam[1]

cDataDe  := DtoS(aParam[2])
cDataAte := DtoS(aParam[3])

If !ChkFile("Z95")
	Return aRetF100
Endif

If Select("QRYZ95") > 0
	QRYZ95->(DbCloseArea())
EndIf

BeginSql Alias 'QRYZ95'
    SELECT * FROM %table:Z95%
    WHERE %notDel%
      AND Z95_FILIAL = %exp:cFil%
      AND Z95_DATA >= %exp:cDataDe%
      AND Z95_DATA <= %exp:cDataAte%
EndSql

QRYZ95->(DbGoTop())
While QRYZ95->(!EOF())
    
	aAuxF100 := {}	

	//Gravação registro F100.
	aAdd(aAuxF100,"F100") //[01] REG

	If AllTrim(QRYZ95->Z95_CSTPIS) >= "50" .and. AllTrim(QRYZ95->Z95_CSTPIS) <= "60"
		aAdd(aAuxF100,"0") //[02] IND_OPER

	ElseIf AllTrim(QRYZ95->Z95_CSTPIS) $ "01|02|03|05"
		aAdd(aAuxF100,"1") //[02] IND_OPER

	ElseIf AllTrim(QRYZ95->Z95_CSTPIS) $ "04|06|07|08|09|49|99"
		aAdd(aAuxF100,"2") //[02] IND_OPER
	EndIf

	aAdd(aAuxF100,"") //[03] COD_PART
	
	aAdd(aAuxF100,"") //[04] COD_ITEM
	
	aAdd(aAuxF100,StoD(QRYZ95->Z95_DATA)) //[05] DT_OPER

	aAdd(aAuxF100,QRYZ95->Z95_VALOR) //[06] VL_OPER
	
	aAdd(aAuxF100,QRYZ95->Z95_CSTPIS) //[07] CST_PIS

	aAdd(aAuxF100,QRYZ95->Z95_BASPIS) //[08] VL_BC_PIS

	aAdd(aAuxF100,QRYZ95->Z95_ALQPIS) //[09] ALIQ_PIS

	aAdd(aAuxF100,QRYZ95->Z95_VALPIS) //[10] VL_PIS

	aAdd(aAuxF100,QRYZ95->Z95_CSTCOF) //[11] CST_COFINS

	aAdd(aAuxF100,QRYZ95->Z95_BASCOF) //[12] VL_BC_COFINS

	aAdd(aAuxF100,QRYZ95->Z95_ALQCOF) //[13] ALIQ_COFINS

	aAdd(aAuxF100,QRYZ95->Z95_VALCOF) //[14] VL_COFINS

	aAdd(aAuxF100,QRYZ95->Z95_CODBCC) //[15] NAT_BC_CRED

	aAdd(aAuxF100,QRYZ95->Z95_ORICRE) //[16] IND_ORIG_CRED

	aAdd(aAuxF100,"") //[17] COD_CTA
	aAdd(aAuxF100,"") //[18] COD_CCUS
	
	aAdd(aAuxF100,QRYZ95->Z95_DESCOP) //[19] DESC_DOC_OPER   
	
	aAdd(aAuxF100,"") //[20] LOJA
	
	aAdd(aAuxF100,QRYZ95->Z95_INDCML) //[21] INDICE DE CUMULATIVIDADE

 	//Gravação registro 0150
	aAdd(aAuxF100,"") //[02] COD_PART

	aAdd(aAuxF100,"") //[03] NOME

	aAdd(aAuxF100,"") //[04] COD_PAIS

	aAdd(aAuxF100,"") //[05] CNPJ

	aAdd(aAuxF100,"") //[06] CPF

	aAdd(aAuxF100,"") //[07] IE

	aAdd(aAuxF100,"") //[08] COD_MUN

	aAdd(aAuxF100,"") //[09] SUFRAMA

	aAdd(aAuxF100,"") //[10] END

	aAdd(aAuxF100,"") //[11] NUM

	aAdd(aAuxF100,"") //[12] COMPL

	aAdd(aAuxF100,"") //[13] BAIRRO

	//Gravação registro 0500
	aAdd(aAuxF100,ctod("//")) //[02] DT_ALT - AOA - 06/06/2016 - Alteração para carregar como tipo data mesmo em branco

	aAdd(aAuxF100,"") //[03] COD_NAT_CC

	aAdd(aAuxF100,"") //[04] IND_CTA

	aAdd(aAuxF100,"") //[05] NIVEL

	aAdd(aAuxF100,"") //[06] COD_CTA

	aAdd(aAuxF100,"") //[07] NOME_CTA

	aAdd(aAuxF100,"") //[08] COD_CTA_REF

	aAdd(aAuxF100,"") //[09] CNPJ_EST
	
	//JSS - 10/03/2016
	aAdd(aAuxF100,"") //Codigo da tabela da Natureza da Receita. 
	aAdd(aAuxF100,"") //Codigo da Natureza da Receita 
	aAdd(aAuxF100,"") //Grupo da Natureza da Receita 
	aAdd(aAuxF100,ctod("//")) //Dt.Fim Natureza da Receita - AOA - 06/06/2016 - Alteração para carregar como tipo data mesmo em branco
	aAdd(aAuxF100,"") //0600 - 02 - DT_ALT 
	aAdd(aAuxF100,"") //0600 - 03 - COD_CCUS 
	aAdd(aAuxF100,"") //0600 - 04 - CCUS
	aAdd(aAuxF100,"") //SA1 para considerar cadastro de cliente, ou SA2 para considerar cadastro de Fornecedor	

	aAdd(aRetF100,aAuxF100)
	
	QRYZ95->(DbSkip())
EndDo

Return aRetF100                                 