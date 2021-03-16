#include "PROTHEUS.CH"

#define ENTER CHR(13)+CHR(10)

USER FUNCTION FA050INC()
LOCAL lOk :=  .T.
LOCAL lCorpCli := SUPERGETMV("MV_P_00122",.F.,.F.)
LOCAL cMsgCpo := "Um ou mais campos obrigatórios não foram preenchidos." + ENTER + "Campo: "
LOCAL aAreaAnt 
LOCAL lAccesOK := SUPERGETMV("MV_P_00130",.F.,.F.)// SE A EMPRESA UTILIZA A ROTINA DA ACCESSTAGE DEVE VALIDAR OS CAMPOS DA TABELA SE2 (TITULOS A PAGAR)

ConOut("********* CUSTOMIZAÇÃO EZ4 (PE) FA050INC() "+Dtoc(Date())+" "+Time()+" LINHA: 12 *********")
IF lAccesOK // SE A EMPRESA UTILIZA A ROTINA DA ACCESSTAGE DEVE VALIDAR OS CAMPOS DA TABELA SE2 (TITULOS A PAGAR)

    IF !U_GTFIN039(3,'')
            RETURN .F.
        ENDIF
    //QUANDO A EMPRESA FOR CORPORATIVA TORNA O CAMPO "FORMA DE PAGAMENTO" DA PASTA BANCO  EM CAMPO OBRIGADÓRIO EXIBINDO UMA MENSAGEM.
    //E CASO ESTEJA SELECIONADO AS FORMAS 11/19/30/31 SOLICITA QUE PREENCHA O CÓDIGO DE BARRAS 
    aAreaAnt := GETAREA()
    DbSelectArea("SE2")
     
    IF EMPTY(M->E2_P_CGCBN)
        lOk :=  .F.
        SX3->(DbSetOrder(2))
        SX3->(DbSeek("E2_P_CGCBN"))
        SXA->(DbSetOrder(1))
        SXA->(DbSeek(SX3->X3_ARQUIVO + SX3->X3_FOLDER ))
        Help("",1,"CAMPO OBRIGATÓRIO",,cMsgCpo+" ("+SX3->X3_TITULO+")"+ENTER+"Pasta: ["+SXA->XA_DESCRIC+"] ",1)
    ELSEIF EMPTY(M->E2_P_TPMV)
        lOk :=  .F.
        SX3->(DbSetOrder(2))
        SX3->(DbSeek("E2_P_TPMV"))
        SXA->(DbSetOrder(1))
        SXA->(DbSeek(SX3->X3_ARQUIVO + SX3->X3_FOLDER ))
        Help("",1,"CAMPO OBRIGATÓRIO",,cMsgCpo+" ("+SX3->X3_TITULO+")"+ENTER+"Pasta: ["+SXA->XA_DESCRIC+"] ",1)
    ELSEIF EMPTY(M->E2_P_INSMV)
        lOk :=  .F.
        SX3->(DbSetOrder(2))
        SX3->(DbSeek("E2_P_INSMV"))
        SXA->(DbSetOrder(1))
        SXA->(DbSeek(SX3->X3_ARQUIVO + SX3->X3_FOLDER ))
        Help("",1,"CAMPO OBRIGATÓRIO",,cMsgCpo+" ("+SX3->X3_TITULO+")"+ENTER+"Pasta: ["+SXA->XA_DESCRIC+"] ",1)
    ENDIF

    cCampo := "E2_FORMPAG"
    IF FieldPos(cCampo) > 0 .AND. lCorpCli
        IF EMPTY(M->E2_FORMPAG)
            lOk :=  .F.
            SX3->(DbSetOrder(2))
            SX3->(DbSeek(cCampo))
            SXA->(DbSetOrder(1))
            SXA->(DbSeek(SX3->X3_ARQUIVO + SX3->X3_FOLDER ))
            Help("",1,"CAMPO OBRIGATÓRIO",,cMsgCpo+" ("+SX3->X3_TITULO+")"+ENTER+"Pasta: ["+SXA->XA_DESCRIC+"] ",1)

        ELSEIF (M->E2_FORMPAG$'11/19/30/31') .AND. (EMPTY(M->E2_LINDIG) .OR. EMPTY(M->E2_CODBAR))
            lOk :=  .F.
            SX3->(DbSetOrder(2))
            SX3->(DbSeek("E2_CODBAR"))
            SXA->(DbSetOrder(1))
            SXA->(DbSeek(SX3->X3_ARQUIVO + SX3->X3_FOLDER ))
            Help("",1,"CAMPO OBRIGATÓRIO",,cMsgCpo+" ("+SX3->X3_TITULO+")"+ENTER+"Pasta: ["+SXA->XA_DESCRIC+"] ",1)

        ENDIF
    ENDIF
    IF !EMPTY(M->E2_P_TRIB)

        IF EMPTY(M->E2_P_CODRE) .AND. !(M->E2_P_TRIB$'25/26/27')
            lOk :=  .F.
            SX3->(DbSetOrder(2))
            SX3->(DbSeek("E2_P_CODRE"))
            SXA->(DbSetOrder(1))
            SXA->(DbSeek(SX3->X3_ARQUIVO + SX3->X3_FOLDER ))
            Help("",1,"CAMPO OBRIGATÓRIO",,cMsgCpo+" ("+SX3->X3_TITULO+")"+ENTER+"Pasta: ["+SXA->XA_DESCRIC+"] ",1)
            
        ELSEIF EMPTY(M->E2_P_TPCON) 
            lOk :=  .F.
            SX3->(DbSetOrder(2))
            SX3->(DbSeek("E2_P_TPCON"))
            SXA->(DbSetOrder(1))
            SXA->(DbSeek(SX3->X3_ARQUIVO + SX3->X3_FOLDER ))
            Help("",1,"CAMPO OBRIGATÓRIO",,cMsgCpo+" ("+SX3->X3_TITULO+")"+ENTER+"Pasta: ["+SXA->XA_DESCRIC+"] ",1)
        ELSEIF EMPTY(M->E2_P_CGCON)
            lOk :=  .F.
            SX3->(DbSetOrder(2))
            SX3->(DbSeek("E2_P_CGCON"))
            SXA->(DbSetOrder(1))
            SXA->(DbSeek(SX3->X3_ARQUIVO + SX3->X3_FOLDER ))
            Help("",1,"CAMPO OBRIGATÓRIO",,cMsgCpo+" ("+SX3->X3_TITULO+")"+ENTER+"Pasta: ["+SXA->XA_DESCRIC+"] ",1)
        ELSEIF EMPTY(M->E2_P_NMCON)
            lOk :=  .F.
            SX3->(DbSetOrder(2))
            SX3->(DbSeek("E2_P_NMCON"))
            SXA->(DbSetOrder(1))
            SXA->(DbSeek(SX3->X3_ARQUIVO + SX3->X3_FOLDER ))
            Help("",1,"CAMPO OBRIGATÓRIO",,cMsgCpo+" ("+SX3->X3_TITULO+")"+ENTER+"Pasta: ["+SXA->XA_DESCRIC+"] ",1)
        ELSEIF EMPTY(M->E2_P_COMPE)
            lOk :=  .F.
            SX3->(DbSetOrder(2))
            SX3->(DbSeek("E2_P_COMPE"))
            SXA->(DbSetOrder(1))
            SXA->(DbSeek(SX3->X3_ARQUIVO + SX3->X3_FOLDER ))
            Help("",1,"CAMPO OBRIGATÓRIO",,cMsgCpo+" ("+SX3->X3_TITULO+")"+ENTER+"Pasta: ["+SXA->XA_DESCRIC+"] ",1)
        ENDIF

        //GPS-17
        IF M->E2_P_TRIB == '17'
            /* não é obrigatorio o lançamento do valor de outras entidades
            IF EMPTY(M->E2_P_VRENT) 
                lOk :=  .F.
                MsgAlert("Campo (Valor Out Entidade) não informado! Pasta [Pag. Tributo]")
            ENDIF
            */

        //DARF NORMAL-16
        ELSEIF M->E2_P_TRIB == '16'

            /* não é obrigatorio o lançamento numero de referencia
            IF EMPTY(M->E2_P_REFE) 
                lOk :=  .F.
                MsgAlert("Campo (Numero de Referencia) não informado! Pasta [Pag. Tributo]")
            ENDIF
            */

        //DARF SIMPLES-18
        ELSEIF M->E2_P_TRIB == '18'

            /*não é obrigatorio o lançamento da receita e nem do percentual
            IF EMPTY(M->E2_P_REBRU) 
                lOk :=  .F.
                MsgAlert("Campo (Receita Bruta) não informado! Pasta [Pag. Tributo]")
            ELSEIF EMPTY(M->E2_P_PERRB) 
                lOk :=  .F.
                MsgAlert("Campo (Percentual Receita Bruta) não informado! Pasta [Pag. Tributo]")
            ENDIF
            */
            
        //GARE-22
        ELSEIF M->E2_P_TRIB == '22'

            IF EMPTY(M->E2_P_INSCR) 
                lOk :=  .F.
                SX3->(DbSetOrder(2))
                SX3->(DbSeek("E2_P_INSCR"))
                SXA->(DbSetOrder(1))
                SXA->(DbSeek(SX3->X3_ARQUIVO + SX3->X3_FOLDER ))
                Help("",1,"CAMPO OBRIGATÓRIO",,cMsgCpo+" ("+SX3->X3_TITULO+")"+ENTER+"Pasta: ["+SXA->XA_DESCRIC+"] ",1)
        /*  não é obrigatorio o lançamento divita ativa e nem do numero da parcela
        ELSEIF EMPTY(M->E2_P_DIVAT) 
                lOk :=  .F.
                MsgAlert("Campo (Divida Ativa/ Numero Etiq) não informado! Pasta [Pag. Tributo]")
            ELSEIF EMPTY(M->E2_P_PARCE) 
                lOk :=  .F.
                MsgAlert("Campo (Num. Parcela da Notificação) não informado! Pasta [Pag. Tributo]")
            */
            ENDIF

        //IPVA/DPVAT/LICENCIAMENTO 25/26/27
        ELSEIF M->E2_P_TRIB$'25/26/27'

            IF EMPTY(M->E2_P_RENAV) 
                lOk :=  .F.
                SX3->(DbSetOrder(2))
                SX3->(DbSeek("E2_P_RENAV"))
                SXA->(DbSetOrder(1))
                SXA->(DbSeek(SX3->X3_ARQUIVO + SX3->X3_FOLDER ))
                Help("",1,"CAMPO OBRIGATÓRIO",,cMsgCpo+" ("+SX3->X3_TITULO+")"+ENTER+"Pasta: ["+SXA->XA_DESCRIC+"] ",1)
            ELSEIF EMPTY(M->E2_P_UFIPV) 
                lOk :=  .F.
                SX3->(DbSetOrder(2))
                SX3->(DbSeek("E2_P_UFIPV"))
                SXA->(DbSetOrder(1))
                SXA->(DbSeek(SX3->X3_ARQUIVO + SX3->X3_FOLDER ))
                Help("",1,"CAMPO OBRIGATÓRIO",,cMsgCpo+" ("+SX3->X3_TITULO+")"+ENTER+"Pasta: ["+SXA->XA_DESCRIC+"] ",1)
            ELSEIF EMPTY(M->E2_P_CDMUN) 
                lOk :=  .F.
                SX3->(DbSetOrder(2))
                SX3->(DbSeek("E2_P_CDMUN"))
                SXA->(DbSetOrder(1))
                SXA->(DbSeek(SX3->X3_ARQUIVO + SX3->X3_FOLDER ))
                Help("",1,"CAMPO OBRIGATÓRIO",,cMsgCpo+" ("+SX3->X3_TITULO+")"+ENTER+"Pasta: ["+SXA->XA_DESCRIC+"] ",1)
            ELSEIF EMPTY(M->E2_P_PLACA) 
                lOk :=  .F.
                SX3->(DbSetOrder(2))
                SX3->(DbSeek("E2_P_PLACA"))
                SXA->(DbSetOrder(1))
                SXA->(DbSeek(SX3->X3_ARQUIVO + SX3->X3_FOLDER ))
                Help("",1,"CAMPO OBRIGATÓRIO",,cMsgCpo+" ("+SX3->X3_TITULO+")"+ENTER+"Pasta: ["+SXA->XA_DESCRIC+"] ",1)
            ENDIF

            IF M->E2_P_TRIB == '25'
                IF EMPTY(M->E2_P_OPPAG) 
                    lOk :=  .F.
                    SX3->(DbSetOrder(2))
                    SX3->(DbSeek("E2_P_OPPAG"))
                    SXA->(DbSetOrder(1))
                    SXA->(DbSeek(SX3->X3_ARQUIVO + SX3->X3_FOLDER ))
                    Help("",1,"CAMPO OBRIGATÓRIO",,cMsgCpo+" ("+SX3->X3_TITULO+")"+ENTER+"Pasta: ["+SXA->XA_DESCRIC+"] ",1)
                ENDIF
            ELSEIF M->E2_P_TRIB == '26'
                IF EMPTY(M->E2_P_OPRET) 
                    lOk :=  .F.
                    SX3->(DbSetOrder(2))
                    SX3->(DbSeek("E2_P_OPRET"))
                    SXA->(DbSetOrder(1))
                    SXA->(DbSeek(SX3->X3_ARQUIVO + SX3->X3_FOLDER ))
                    Help("",1,"CAMPO OBRIGATÓRIO",,cMsgCpo+" ("+SX3->X3_TITULO+")"+ENTER+"Pasta: ["+SXA->XA_DESCRIC+"] ",1)
                ENDIF
            ENDIF
            
        //DARJ-21
        ELSEIF M->E2_P_TRIB == '18'

            IF EMPTY(M->E2_P_DCORI) 
                lOk :=  .F.
                SX3->(DbSetOrder(2))
                SX3->(DbSeek("E2_P_DCORI"))
                SXA->(DbSetOrder(1))
                SXA->(DbSeek(SX3->X3_ARQUIVO + SX3->X3_FOLDER ))
                Help("",1,"CAMPO OBRIGATÓRIO",,cMsgCpo+" ("+SX3->X3_TITULO+")"+ENTER+"Pasta: ["+SXA->XA_DESCRIC+"] ",1)
            ELSEIF EMPTY(M->E2_P_VLMON) 
                lOk :=  .F.
                SX3->(DbSetOrder(2))
                SX3->(DbSeek("E2_P_VLMON"))
                SXA->(DbSetOrder(1))
                SXA->(DbSeek(SX3->X3_ARQUIVO + SX3->X3_FOLDER ))
                Help("",1,"CAMPO OBRIGATÓRIO",,cMsgCpo+" ("+SX3->X3_TITULO+")"+ENTER+"Pasta: ["+SXA->XA_DESCRIC+"] ",1)
            ENDIF

        ENDIF



    ENDIF

    RESTAREA(aAreaAnt)   // Retorna o ambiente anterior
    ConOut("********* CUSTOMIZAÇÃO EZ4 (PE) FA050INC() "+Dtoc(Date())+" "+Time()+" LINHA: 237 *********")
ENDIF
RETURN lOk