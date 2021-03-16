#include "PROTHEUS.CH"

#define ENTER CHR(13)+CHR(10)

USER FUNCTION FA050ALT()
LOCAL lOk :=  .T.
LOCAL lCorpCli := SUPERGETMV("MV_P_00122",.F.,.F.)
LOCAL cMsgCpo := "Um ou mais campos obrigatórios não foram preenchidos." + ENTER + "Campo: "
LOCAL cCpoPast := ""
LOCAL lAccesOK := SUPERGETMV("MV_P_00130",.F.,.F.)  // SE A EMPRESA UTILIZA A ROTINA DA ACCESSTAGE DEVE VALIDAR OS CAMPOS DA TABELA SE2 (TITULOS A PAGAR)

ConOut("********* CUSTOMIZAÇÃO EZ4 (PE) FA050ALT() "+Dtoc(Date())+" "+Time()+" LINHA: 11 *********")
IF lAccesOK // SE A EMPRESA UTILIZA A ROTINA DA ACCESSTAGE DEVE VALIDAR OS CAMPOS DA TABELA SE2 (TITULOS A PAGAR)
    IF !U_GTFIN039(3,'')
        RETURN .F.
    ENDIF 
     
    //QUANDO A EMPRESA FOR CORPORATIVA TORNA O CAMPO "FORMA DE PAGAMENTO" DA PASTA BANCO  EM CAMPO OBRIGADÓRIO EXIBINDO UMA MENSAGEM.
    //E CASO ESTEJA SELECIONADO AS FORMAS 11/19/30/31 SOLICITA QUE PREENCHA O CÓDIGO DE BARRAS 
    IF EMPTY(M->E2_P_CGCBN)
        DbSelectArea("SA2")
        SA2->(DbSetOrder(1))
        IF SA2->(dbSeek(xFilial("SA2")+M->E2_FORNECE+M->E2_LOJA))
            M->E2_P_NOMBN := IF(EMPTY(M->E2_P_CGCBN),SA2->A2_NOME,M->E2_P_CGCBN) 
            M->E2_P_CGCBN := SA2->A2_CGC
            M->E2_P_TIPO  := IF(EMPTY(M->E2_P_TIPO),SA2->A2_TIPO,M->E2_P_TIPO) 
        ENDIF

        IF EMPTY(M->E2_P_CGCBN)
            lOk :=  .F.
            SX3->(DbSetOrder(2))
            SX3->(DbSeek("E2_P_CGCBN"))
            SXA->(DbSetOrder(1))
            SXA->(DbSeek(SX3->X3_ARQUIVO + SX3->X3_FOLDER ))
            cCpoPast := cCpoPast+ENTER+SX3->X3_TITULO+" Pasta: ["+SXA->XA_DESCRIC+"]"
            //Help("",1,"CAMPO OBRIGATÓRIO",,cMsgCpo+" ("+SX3->X3_TITULO+")"+ENTER+"Pasta: ["+SXA->XA_DESCRIC+"] ",1)
        ENDIF
    ENDIF 
    
    
        IF EMPTY(M->E2_FORMPAG)
            lOk :=  .F.
            SX3->(DbSetOrder(2)) 
            SX3->(DbSeek("E2_FORMPAG"))
            SXA->(DbSetOrder(1))
            SXA->(DbSeek(SX3->X3_ARQUIVO + SX3->X3_FOLDER ))
            cCpoPast := cCpoPast+SX3->X3_TITULO+" Pasta: ["+SXA->XA_DESCRIC+"]"+ENTER
            //Help("",1,"CAMPO OBRIGATÓRIO",,cMsgCpo+" ("+SX3->X3_TITULO+")"+ENTER+"Pasta: ["+SXA->XA_DESCRIC+"] ",1) 
        ELSEIF (M->E2_FORMPAG$'11/19/30/31') .AND. (EMPTY(M->E2_LINDIG) .OR. EMPTY(M->E2_CODBAR))
            lOk :=  .F.
            SX3->(DbSetOrder(2)) 
            SX3->(DbSeek("E2_CODBAR"))
            SXA->(DbSetOrder(1))
            SXA->(DbSeek(SX3->X3_ARQUIVO + SX3->X3_FOLDER ))
            cCpoPast := cCpoPast+SX3->X3_TITULO+" Pasta: ["+SXA->XA_DESCRIC+"]"+ENTER
            //Help("",1,"CAMPO OBRIGATÓRIO",,cMsgCpo+" ("+SX3->X3_TITULO+")"+ENTER+"Pasta: ["+SXA->XA_DESCRIC+"] ",1)
        ENDIF 

        
    
    IF !EMPTY(M->E2_P_TRIB)
        IF EMPTY(M->E2_P_CODRE) .AND. !(M->E2_P_TRIB$'25/26/27')
            lOk :=  .F.
            SX3->(DbSetOrder(2)) 
            SX3->(DbSeek("E2_P_CODRE"))
            SXA->(DbSetOrder(1))
            SXA->(DbSeek(SX3->X3_ARQUIVO + SX3->X3_FOLDER ))
            cCpoPast := cCpoPast+SX3->X3_TITULO+" Pasta: ["+SXA->XA_DESCRIC+"]"+ENTER
            //Help("",1,"CAMPO OBRIGATÓRIO",,cMsgCpo+" ("+SX3->X3_TITULO+")"+ENTER+"Pasta: ["+SXA->XA_DESCRIC+"] ",1)    
        ENDIF

        IF EMPTY(M->E2_P_TPCON) 
            lOk :=  .F.
            SX3->(DbSetOrder(2)) 
            SX3->(DbSeek("E2_P_TPCON"))
            SXA->(DbSetOrder(1))
            SXA->(DbSeek(SX3->X3_ARQUIVO + SX3->X3_FOLDER ))
            cCpoPast := cCpoPast+SX3->X3_TITULO+" Pasta: ["+SXA->XA_DESCRIC+"]"+ENTER
            //Help("",1,"CAMPO OBRIGATÓRIO",,cMsgCpo+" ("+SX3->X3_TITULO+")"+ENTER+"Pasta: ["+SXA->XA_DESCRIC+"] ",1)
        ENDIF
        
        IF EMPTY(M->E2_P_CGCON)
            lOk :=  .F.
            SX3->(DbSetOrder(2)) 
            SX3->(DbSeek("E2_P_CGCON"))
            SXA->(DbSetOrder(1))
            SXA->(DbSeek(SX3->X3_ARQUIVO + SX3->X3_FOLDER ))
            cCpoPast := cCpoPast+SX3->X3_TITULO+" Pasta: ["+SXA->XA_DESCRIC+"]"+ENTER
            //Help("",1,"CAMPO OBRIGATÓRIO",,cMsgCpo+" ("+SX3->X3_TITULO+")"+ENTER+"Pasta: ["+SXA->XA_DESCRIC+"] ",1)
        ENDIF
        
        IF EMPTY(M->E2_P_NMCON)
            lOk :=  .F.
            SX3->(DbSetOrder(2)) 
            SX3->(DbSeek("E2_P_NMCON"))
            SXA->(DbSetOrder(1))
            SXA->(DbSeek(SX3->X3_ARQUIVO + SX3->X3_FOLDER ))
            cCpoPast := cCpoPast+SX3->X3_TITULO+" Pasta: ["+SXA->XA_DESCRIC+"]"+ENTER
            //Help("",1,"CAMPO OBRIGATÓRIO",,cMsgCpo+" ("+SX3->X3_TITULO+")"+ENTER+"Pasta: ["+SXA->XA_DESCRIC+"] ",1)
        ENDIF
        
        IF EMPTY(M->E2_P_COMPE)
            lOk :=  .F.
            SX3->(DbSetOrder(2)) 
            SX3->(DbSeek("E2_P_COMPE"))
            SXA->(DbSetOrder(1))
            SXA->(DbSeek(SX3->X3_ARQUIVO + SX3->X3_FOLDER ))
            cCpoPast := cCpoPast+SX3->X3_TITULO+" Pasta: ["+SXA->XA_DESCRIC+"]"+ENTER
            //Help("",1,"CAMPO OBRIGATÓRIO",,cMsgCpo+" ("+SX3->X3_TITULO+")"+ENTER+"Pasta: ["+SXA->XA_DESCRIC+"] ",1)
        ENDIF

        //GPS-17
        IF M->E2_P_TRIB == '17'
            /* não é obrigatorio o lançamento do valor de outras entidades
            IF EMPTY(M->E2_P_VRENT) 
                lOk :=  .F.
                MsgAlert("Campo (Valor Out Entidade) não informado! Pasta [Pag. Tributo]")
            ENDIF
            */
        ENDIF

        //DARF NORMAL-16
        IF M->E2_P_TRIB == '16'

            /* não é obrigatorio o lançamento numero de referencia
            IF EMPTY(M->E2_P_REFE) 
                lOk :=  .F.
                MsgAlert("Campo (Numero de Referencia) não informado! Pasta [Pag. Tributo]")
            ENDIF
            */
        ENDIF

        //DARF SIMPLES-18
        IF M->E2_P_TRIB == '18'

            /*não é obrigatorio o lançamento da receita e nem do percentual
            IF EMPTY(M->E2_P_REBRU) 
                lOk :=  .F.
                MsgAlert("Campo (Receita Bruta) não informado! Pasta [Pag. Tributo]")
            ELSEIF EMPTY(M->E2_P_PERRB) 
                lOk :=  .F.
                MsgAlert("Campo (Percentual Receita Bruta) não informado! Pasta [Pag. Tributo]")
            ENDIF
            */
        ENDIF    
        //GARE-22
        IF M->E2_P_TRIB == '22'

            IF EMPTY(M->E2_P_INSCR) 
                lOk :=  .F.
                SX3->(DbSetOrder(2))
                SX3->(DbSeek("E2_P_INSCR"))
                SXA->(DbSetOrder(1))
                SXA->(DbSeek(SX3->X3_ARQUIVO + SX3->X3_FOLDER ))
                cCpoPast := cCpoPast+SX3->X3_TITULO+" Pasta: ["+SXA->XA_DESCRIC+"]"+ENTER
                //Help("",1,"CAMPO OBRIGATÓRIO",,cMsgCpo+" ("+SX3->X3_TITULO+")"+ENTER+"Pasta: ["+SXA->XA_DESCRIC+"] ",1)
                /*  não é obrigatorio o lançamento divita ativa e nem do numero da parcela
                ELSEIF EMPTY(M->E2_P_DIVAT) 
                    lOk :=  .F.
                    MsgAlert("Campo (Divida Ativa/ Numero Etiq) não informado! Pasta [Pag. Tributo]")
                ELSEIF EMPTY(M->E2_P_PARCE) 
                    lOk :=  .F.
                    MsgAlert("Campo (Num. Parcela da Notificação) não informado! Pasta [Pag. Tributo]")
                    */
            ENDIF
        ENDIF

        //IPVA/DPVAT/LICENCIAMENTO 25/26/27
        IF M->E2_P_TRIB$'25/26/27'

            IF EMPTY(M->E2_P_RENAV) 
                lOk :=  .F.
                SX3->(DbSetOrder(2)) 
                SX3->(DbSeek("E2_P_RENAV"))
                SXA->(DbSetOrder(1))
                SXA->(DbSeek(SX3->X3_ARQUIVO + SX3->X3_FOLDER ))
                cCpoPast := cCpoPast+SX3->X3_TITULO+" Pasta: ["+SXA->XA_DESCRIC+"]"+ENTER
                //Help("",1,"CAMPO OBRIGATÓRIO",,cMsgCpo+" ("+SX3->X3_TITULO+")"+ENTER+"Pasta: ["+SXA->XA_DESCRIC+"] ",1)
            ENDIF
            IF EMPTY(M->E2_P_UFIPV) 
                lOk :=  .F.
                SX3->(DbSetOrder(2)) 
                SX3->(DbSeek("E2_P_UFIPV"))
                SXA->(DbSetOrder(1))
                SXA->(DbSeek(SX3->X3_ARQUIVO + SX3->X3_FOLDER ))
                cCpoPast := cCpoPast+SX3->X3_TITULO+" Pasta: ["+SXA->XA_DESCRIC+"]"+ENTER
                //Help("",1,"CAMPO OBRIGATÓRIO",,cMsgCpo+" ("+SX3->X3_TITULO+")"+ENTER+"Pasta: ["+SXA->XA_DESCRIC+"] ",1)
            ENDIF
            IF EMPTY(M->E2_P_CDMUN) 
                lOk :=  .F.
                SX3->(DbSetOrder(2)) 
                SX3->(DbSeek("E2_P_CDMUN"))
                SXA->(DbSetOrder(1))
                SXA->(DbSeek(SX3->X3_ARQUIVO + SX3->X3_FOLDER ))
                cCpoPast := cCpoPast+SX3->X3_TITULO+" Pasta: ["+SXA->XA_DESCRIC+"]"+ENTER
                //Help("",1,"CAMPO OBRIGATÓRIO",,cMsgCpo+" ("+SX3->X3_TITULO+")"+ENTER+"Pasta: ["+SXA->XA_DESCRIC+"] ",1)
            ENDIF
            IF EMPTY(M->E2_P_PLACA) 
                lOk :=  .F.
                SX3->(DbSetOrder(2)) 
                SX3->(DbSeek("E2_P_PLACA"))
                SXA->(DbSetOrder(1))
                SXA->(DbSeek(SX3->X3_ARQUIVO + SX3->X3_FOLDER ))
                cCpoPast := cCpoPast+SX3->X3_TITULO+" Pasta: ["+SXA->XA_DESCRIC+"]"+ENTER
                //Help("",1,"CAMPO OBRIGATÓRIO",,cMsgCpo+" ("+SX3->X3_TITULO+")"+ENTER+"Pasta: ["+SXA->XA_DESCRIC+"] ",1)
            ENDIF

            IF M->E2_P_TRIB == '25'
                IF EMPTY(M->E2_P_OPPAG) 
                    lOk :=  .F.
                    SX3->(DbSetOrder(2)) 
                    SX3->(DbSeek("E2_P_OPPAG"))
                    SXA->(DbSetOrder(1))
                    SXA->(DbSeek(SX3->X3_ARQUIVO + SX3->X3_FOLDER ))
                    cCpoPast := cCpoPast+SX3->X3_TITULO+" Pasta: ["+SXA->XA_DESCRIC+"]"+ENTER
                    //Help("",1,"CAMPO OBRIGATÓRIO",,cMsgCpo+" ("+SX3->X3_TITULO+")"+ENTER+"Pasta: ["+SXA->XA_DESCRIC+"] ",1)
                ENDIF
            ENDIF
            IF M->E2_P_TRIB == '26'
                IF EMPTY(M->E2_P_OPRET) 
                    lOk :=  .F.
                    SX3->(DbSetOrder(2)) 
                    SX3->(DbSeek("E2_P_OPRET"))
                    SXA->(DbSetOrder(1))
                    SXA->(DbSeek(SX3->X3_ARQUIVO + SX3->X3_FOLDER ))
                    cCpoPast := cCpoPast+SX3->X3_TITULO+" Pasta: ["+SXA->XA_DESCRIC+"]"+ENTER
                    //Help("",1,"CAMPO OBRIGATÓRIO",,cMsgCpo+" ("+SX3->X3_TITULO+")"+ENTER+"Pasta: ["+SXA->XA_DESCRIC+"] ",1)
                ENDIF
            ENDIF
            
        ENDIF
        //DARJ-21
        IF M->E2_P_TRIB == '18'

            IF EMPTY(M->E2_P_DCORI) 
                lOk :=  .F.
                SX3->(DbSetOrder(2)) 
                SX3->(DbSeek("E2_P_DCORI"))
                SXA->(DbSetOrder(1))
                SXA->(DbSeek(SX3->X3_ARQUIVO + SX3->X3_FOLDER ))
                cCpoPast := cCpoPast+SX3->X3_TITULO+" Pasta: ["+SXA->XA_DESCRIC+"]"+ENTER
                //Help("",1,"CAMPO OBRIGATÓRIO",,cMsgCpo+" ("+SX3->X3_TITULO+")"+ENTER+"Pasta: ["+SXA->XA_DESCRIC+"] ",1)
            ENDIF
            IF EMPTY(M->E2_P_VLMON) 
                lOk :=  .F.
                SX3->(DbSetOrder(2)) 
                SX3->(DbSeek("E2_P_VLMON"))
                SXA->(DbSetOrder(1))
                SXA->(DbSeek(SX3->X3_ARQUIVO + SX3->X3_FOLDER ))
                cCpoPast := cCpoPast+SX3->X3_TITULO+" Pasta: ["+SXA->XA_DESCRIC+"]"+ENTER
                //Help("",1,"CAMPO OBRIGATÓRIO",,cMsgCpo+" ("+SX3->X3_TITULO+")"+ENTER+"Pasta: ["+SXA->XA_DESCRIC+"] ",1)
            ENDIF
        ENDIF
    ENDIF

    //Código de Barras
    IF !EMPTY(M->E2_LINDIG) .AND. EMPTY(M->E2_CODBAR)
        M->E2_CODBAR := U_GTFIN038(10,'')
    ENDIF

    //Tipo de Movimento
    IF EMPTY(M->E2_P_TPMV)
            M->E2_P_TPMV := IF(EMPTY(M->E2_P_TPMV),"0",M->E2_P_TPMV) 
    ENDIF

    //Instraucao p/ Movimento
    IF EMPTY(M->E2_P_INSMV)
            M->E2_P_INSMV := IF(EMPTY(M->E2_P_INSMV),"00",M->E2_P_INSMV)
    ENDIF 

    //Tipo de Moeda
    IF EMPTY(M->E2_P_TPMOE)
            M->E2_P_TPMOE := IF(EMPTY(M->E2_P_TPMOE),"BRL",M->E2_P_TPMOE)
    ENDIF 

    IF !EMPTY(cCpoPast)
        Help("",1,"CAMPO OBRIGATÓRIO",,cMsgCpo+ENTER+cCpoPast,1)
    ENDIF 
    
    ConOut("********* CUSTOMIZAÇÃO EZ4 (PE) FA050ALT() "+Dtoc(Date())+" "+Time()+" LINHA: 229 *********")
ENDIF

RETURN lOk