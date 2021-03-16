#include "PROTHEUS.CH"

USER FUNCTION F430REJ()
    LOCAL cIdCnab
    LOCAL lAccesOK := SUPERGETMV("MV_P_00130",.F.,.F.)// SE A EMPRESA UTILIZA A ROTINA DA ACCESSTAGE DEVE VALIDAR OS CAMPOS DA TABELA SE2 (TITULOS A PAGAR)
    LOCAL aSE2REJ 

    IF lAccesOK // SE A EMPRESA UTILIZA A ROTINA DA ACCESSTAGE DEVE VALIDAR OS CAMPOS DA TABELA SE2 (TITULOS A PAGAR)
       // MSGINFO("F430REJ: LINHA 9")
        /*IF !U_GTFIN039(3,'')
            RETURN .F.
        ENDIF     
          */          
        cIdCnab := ALLTRIM(SE2->E2_IDCNAB) 

        IF ALLTRIM(SE2->E2_NUM) == ALLTRIM(SEA->EA_NUM) 
            //MSGINFO("TITULO: "+CVALTOCHAR(SE2->E2_NUM)+" REJEITADO DO ID: "+CVALTOCHAR(SE2->E2_IDCNAB))
            aSE2REJ := {SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_FORNECE,SE2->E2_LOJA,SE2->E2_NOMFOR,SE2->E2_EMISSAO,SE2->E2_VENCREA,SE2->E2_VALOR}
      
            IF EMPTY(SEA->EA_P_IDCNA)
                RecLock( "SEA", .F.)
                SEA->EA_P_IDCNA := cIdCnab
                MsUnlock( )
                // FUNÇÃO PARA ENVIO DE EMAIL DE TITULOS REJEITADOS
                //U_GTFIN039(4,aSE2REJ)
            ELSE
                //RecLock( "SE2", .F.)              //CAS - 24/06/2020 Comentado o bloco para não limpar o IDCNAB e não tirar do Borderô
                //SE2->E2_IDCNAB := Space(10)       //CAS - 24/06/2020 Comentado o bloco para não limpar o IDCNAB e não tirar do Borderô
                //MsUnlock( )                       //CAS - 24/06/2020 Comentado o bloco para não limpar o IDCNAB e não tirar do Borderô
            ENDIF

        ENDIF
    ENDIF

RETURN
