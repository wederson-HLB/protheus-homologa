#include "protheus.ch"   

/*
Funcao      : F200IMP
Parametros  : 
Retorno     : 
Objetivos   : Permite a gravação dos dados adicionais no momento do recebimento do arquivo em comunicação bancária/retorno cobrança.
Autor       : 
TDN         : 
Revisão     : César Alves dos Santos
Data/Hora   : 17/12/2020
Módulo      : Financeiro.
*/                      

*--------------------------*
 User Function F200IMP()   
*--------------------------*   
	Local lAccesOK := SUPERGETMV("MV_P_00130",.F.,.F.) // SE A EMPRESA UTILIZA A ROTINA DA ACCESSTAGE DEVE VALIDAR OS CAMPOS DA TABELA SE2 (TITULOS A PAGAR)


	IF lAccesOK // SE A EMPRESA UTILIZA A ROTINA DA ACCESSTAGE DEVE VALIDAR OS CAMPOS DA TABELA SE2 (TITULOS A PAGAR)

		//aPergF200 := {MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04,MV_PAR05,MV_PAR06,MV_PAR07,MV_PAR08,MV_PAR09,MV_PAR10,MV_PAR11,MV_PAR12}
		//POSICIONA NA TABELA SEE PARA PEGAR O CAMINHO DE DESTINO PARA MOVER O ARQUIVO
		DbSelectArea("SEE")
		SEE->(DbSetOrder(1))
		IF SEE->(dbSeek(xFilial("SEE")+MV_PAR06+MV_PAR07+MV_PAR08+MV_PAR09))				
			IF SEE->EE_RETAUT $ '2|3'
				cDirOrig := AllTrim(SEE->EE_DIRPAG) 
				cDirDest := AllTrim(SEE->EE_BKPPAG)
			ENDIF
		ENDIF
		SEE->(dbCloseArea())

        cArq 	:= AllTrim(SUBSTR(MV_PAR04,RAt("\", MV_PAR04 )+1))//
        If ! _CopyFile(cDirOrig+cArq, cDirDest+cArq)
            Conout("Não foi possivel copiar o arquivo "+cArq+" para o diretorio "+cDirDest) // "Não foi possivel copiar o arquivo " # " para o diretorio "
        Else
            FCLOSE(nHdlBco)
            IF Ferase(cDirOrig+cArq) == -1
                MsgStop('Falha na deleção do Arquivo ( FError'+str(ferror(),4)+             ')')
            ENDIF
        Endif

	EndIF

Return