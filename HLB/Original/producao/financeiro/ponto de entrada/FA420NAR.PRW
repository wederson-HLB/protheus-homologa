#include "PROTHEUS.CH"

#define ENTER CHR(13)+CHR(10)
/*/{Protheus.doc} FA420NAR
//TODO (PE) PONTO DE ENTRADA PARA VALIDAÇÃO DO ARQUIVO DE SAIDA E O DIRETÓRIO NA ROTINA DE CNAB DE PAGAMENTO
CASO O BANCO UTILIZE O LAYOUT PARA ACEESSTAGE
@author Leosanlim
@since 15/08/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

USER FUNCTION FA420NAR()
	*=====================================================================================================================================*
	LOCAL cDirArq := PARAMIXB // parametro 1 - diretorio e nome do arquivo
	LOCAL cArqSaida := ""
	LOCAL cSeekZ0D := ""
	LOCAL cMSG := ""
	LOCAL lAccesOK := SUPERGETMV("MV_P_00130",.F.,.F.)// SE A EMPRESA UTILIZA A ROTINA DA ACCESSTAGE DEVE VALIDAR OS CAMPOS DA TABELA SE2 (TITULOS A PAGAR)
    Public  cDirCnab := ""
	
	ConOut("********* CUSTOMIZAÇÃO EZ4 (PE) FA420NAR() "+Dtoc(Date())+" "+Time()+" LINHA: 24 *********")
	IF lAccesOK // SE A EMPRESA UTILIZA A ROTINA DA ACCESSTAGE DEVE VALIDAR OS CAMPOS DA TABELA SE2 (TITULOS A PAGAR)
		cSeekZ0D :=SEE->EE_CODIGO+SEE->EE_AGENCIA+SEE->EE_CONTA+SEE->EE_SUBCTA+"01"
		IF !U_GTFIN039(3,'')
			RETURN .F.
		ENDIF

		cMSG +="Arquivo criado para o banco: "+SEE->EE_CODIGO+" Conta: "+SEE->EE_CONTA+" no diretório: "	
		
		//MSGINFO("Criar arquivo","Cria Arquivo")
		
		IF SEE->EE_P_ACCES == "1"
			//CAS - 04/11/2019 Adicionado no nome do arquivo de saida os conteudos dos campos SEE->EE_CODIGO+SEE->EE_CONTA
			cArqSaida := cValToChar(SM0->M0_CODIGO)+"_PE_"+ALLTRIM(SEE->EE_CODIGO)+"_"+ALLTRIM(SEE->EE_CONTA)+AllTrim(SEE->EE_DVCTA)+"_"+DTOS(date()) + "_" + STRTRAN(TIME(), ":","") +"."+SEE->EE_EXTEN // novo nome do arquivo de saída.

			DbSelectArea("Z0D")
			Z0D->(DbSetOrder(2))
			IF Z0D->(dbSeek(xFilial("Z0D")+cSeekZ0D))
				cDirCnab := cDirArq := AllTrim(Z0D->Z0D_DIR)+AllTrim(cArqSaida)
				AVISO("<center><h3><font color='#7db9e8'>ARQUIVO CNAB A PAGAR CRIADO COM SUCESSO!!</font></h2></center>",cMSG+ENTER+ENTER+"( "+cDirArq+" )",{"OK"}, 3)
			ENDIF
			Z0D->(dbCloseArea())
		ENDIF
		ConOut("********* CUSTOMIZAÇÃO EZ4 (PE) FA420NAR() "+Dtoc(Date())+" "+Time()+" LINHA: 46 *********")
	ENDIF
RETURN cDirArq