#include "PROTHEUS.CH"

#define ENTER CHR(13)+CHR(10)

/*/{Protheus.doc} F150ARQ
//TODO (PE) PONTO DE ENTRADA PARA VALIDAÇÃO DO ARQUIVO DE SAIDA E O DIRETÓRIO NA ROTINA DE CNAB DE COBRANÇA
CASO O BANCO UTILIZE O LAYOUT PARA ACEESSTAGE
@author Leosanlim
@since 15/08/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

User Function F150ARQ()
	*=====================================================================================================================================*
	LOCAL cDirArq  := PARAMIXB // parametro 1 - diretorio e nome do arquivo
	LOCAL cArqSaida := ""
	LOCAL cSeekZ0D  := ""
	LOCAL lAccesOK  := SUPERGETMV("MV_P_00130",.F.,.F.)// SE A EMPRESA UTILIZA A ROTINA DA ACCESSTAGE DEVE VALIDAR OS CAMPOS DA TABELA SE2 (TITULOS A PAGAR)
	
	ConOut("********* CUSTOMIZAÇÃO EZ4 (PE) F150ARQ() "+Dtoc(Date())+" "+Time()+" LINHA: 23 *********")
    IF lAccesOK // SE A EMPRESA UTILIZA A ROTINA DA ACCESSTAGE DEVE VALIDAR OS CAMPOS DA TABELA SE2 (TITULOS A PAGAR)	
		cSeekZ0D :=SEE->EE_CODIGO+SEE->EE_AGENCIA+SEE->EE_CONTA+SEE->EE_SUBCTA+"04"

		IF SEE->EE_P_ACCES == "1"
			//CAS - 04/11/2019 Adicionado no nome do arquivo de saida os conteudos dos campos SEE->EE_CODIGO+SEE->EE_CONTA
			cArqSaida := cValToChar(SM0->M0_CODIGO)+"_RE_"+ALLTRIM(SEE->EE_CODIGO)+"_"+ALLTRIM(SEE->EE_CONTA)+AllTrim(SEE->EE_DVCTA)+"_"+DTOS(date()) + "_" + STRTRAN(TIME(), ":","") +"."+SEE->EE_EXTEN // novo nome do arquivo de saída - //CAS - 24/06/2020 Cpmplementado com o +AllTrim(SEE->EE_DVCTA)

			DbSelectArea("Z0D")
			Z0D->(DbSetOrder(2))
			IF Z0D->(dbSeek(xFilial("Z0D")+cSeekZ0D))
				cDirArq := AllTrim(Z0D->Z0D_DIR)+AllTrim(cArqSaida)
				AVISO("ARQUIVO CNAB A RECEBER CRIADO COM SUCESSO","Arquivo criado para o banco: "+SEE->EE_CODIGO;
				+" Conta: "+SEE->EE_CONTA+" no diretório: "+ENTER+ENTER+"( "+cDirArq+" )",{"OK"}, 3)
			ENDIF
			Z0D->(dbCloseArea())
		ENDIF
		ConOut("********* CUSTOMIZAÇÃO EZ4 (PE) F150ARQ() "+Dtoc(Date())+" "+Time()+" LINHA: 41 *********")
	ENDIF

	Return cDirArq
	*=====================================================================================================================================*

