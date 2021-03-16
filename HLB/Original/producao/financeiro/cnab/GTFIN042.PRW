#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#include "TBICONN.CH"

#define ENTER CHR(13)+CHR(10)

*=====================================================================================================================================*
/*/{Protheus.doc} GTFIN042
//TODO Fonte para tratamento de funções com retorno logico no processo de CNAB via ACCESSTAEG:

nOPCAO := 1 "U_ALTEMP()- VERIFICA SE O NOME DA EMPRESA JÁ TEVE ALTERAÇÃO NA TELA DE PARAMETROS. (CHAMADO NO CAMPO)" 
nOPCAO := 2 "U_VlCodBar(cCodBar) - FUNÇÃO QUE VALIDA SE O CÓDIGO DE BARRAS OU A LINHA DIGITAVEL SE ESTÃO SENDO DIGITADOS CORRETAMENTE (CAMPOS E2_LINDIG E E2_CODBAR)" 
nOPCAO := 3 "U_CPFILPOS() - FUNÇÃO PARA VERIFICAR SE OS CAMPOS CUSTOMIZADOS EXISTEM, UTILIZADO NAS FUNÇÕES QUE UTILIZAM ESSES CAMPOS"
nOPCAO := 4 "U_EMAILREJ() - função para receber os dados do título que foi rejeitado e enviar por email para o responsável da empresa/cliente.
nOPCAO := 5 "U_ARQCNAB() - função para exibir uma lista de arquivos CNAB que se encontram na pasta de retorno 
    - nOPCAO := 6 "U_SELECARQ() - função para validar se arquivo foi selecionado para processar retorno.
    - nOPCAO := 7 "U_DETALARQ() - função para abrir o relatório retorno CNAB e exibir os detalhes dos titulos se foram rejeitados ou incluidos  
@author Leosanlim
@since 02/01/2019
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
USER FUNCTION GTFIN042(nOPCAO,cDados)
LOCAL lRet
//INICIO VARIAVEIS DA FUNÇÃO U_CPFILPOS()
Local cMsgCpos := ""//"Um ou mais campos obrigatórios não foram preenchidos:" + ENTER
Local aCpos_Z0F
Local aCpos_Z0D
Local aCpos_SEE
Local aCpos_SA1
Local aCpos_SA2 
Local aCpos_SE1
Local aCpos_SE2
Local aCpos_SEA
Local aAreaSEE , aAreaSA1,aAreaSA2
Local aAreaSE1, aAreaSE2, aAreaSEA
//FIM VARIAVEIS DA FUNÇÃO U_CPFILPOS()

/*************************
INICIO DAS OPÇÕES 
*************************/
DO CASE
    
    CASE nOPCAO == 3 //U_CPFILPOS()
        lRet := .T.
       /* 
        aCpos_Z0F := {{"Z0F_FILIAL"},{"Z0F_IDCNAB"},{"Z0F_BANCO"},{"Z0F_AGE"},{"Z0F_CTA"},{"Z0F_PREFIX"},{"Z0F_NUM"},{"Z0F_PARCEL"};
            ,{"Z0F_TIPO"},{"Z0F_FORCLI"},{"Z0F_NOMFC"},{"Z0F_CGCCPF"},{"Z0F_DTVENC"},{"Z0F_DTBAIX"},{"Z0F_DTPROC"},{"Z0F_HRPROC"};
            ,{"Z0F_VALOR"},{"Z0F_OCORRE"},{"Z0F_DESCOC"}}
            
        aCpos_Z0D := {{"Z0D_FILIAL"},{"Z0D_BANCO"},{"Z0D_AGE"},{"Z0D_CTA"},{"Z0D_SUBCTA"};
            ,{"Z0D_DIR"},{"Z0D_OPERA"},{"Z0D_STATUS"},{"Z0D_M_MSG"},{"Z0D_DTCRI"},{"Z0D_HRCRI"},{"Z0D_USCRI"},{"Z0D_ALTERA"}}
            
        aCpos_SEE := {{"EE_P_ACCES"},{"EE_P_NOEMP"},{"EE_P_ACEIT"},{"EE_P_TPIMP"},{"EE_P_PROTE"},{"EE_P_PERMT"},{"EE_P_TIPO"},{"EE_P_PERJR"},{"EE_P_EMAIL"}}
        aCpos_SA1 := {{"A1_P_PROTE"},{"A1_P_DIASP"},{"A1_P_PERMT"},{"A1_P_TIPO"},{"A1_P_PERJR"},{"A1_P_CL_PA"},{"A1_P_AGECL"},{"A1_P_CTACL"}}
        aCpos_SA2 := {{"A2_DVAGE"},{"A2_DVCTA"}}
        aCpos_SE1 := {{"E1_P_TPMUL"},{"E1_P_MULTA"},{"E1_P_JUROS"}}
        */
        aCpos_SE2 := {{"E2_P_MULTA"},{"E2_P_JUROS"},{"E2_P_TRIB"},{"E2_P_CODRE"},{"E2_P_TPCON"},{"E2_P_CGCON"},{"E2_P_NMCON"},{"E2_P_COMPE"};
            ,{"E2_P_VRENT"},{"E2_P_VLINS"},{"E2_P_REFE"},{"E2_P_REBRU"},{"E2_P_PERRB"},{"E2_P_INSCR"},{"E2_P_DIVAT"},{"E2_P_PARCE"};
            ,{"E2_P_RENAV"},{"E2_P_UFIPV"},{"E2_P_CDMUN"},{"E2_P_PLACA"},{"E2_P_OPPAG"},{"E2_P_OPRET"},{"E2_P_DCORI"},{"E2_P_VLMON"};
            ,{"E2_P_IDFGT"},{"E2_P_LCSOC"},{"E2_P_DGSOC"},{"E2_LINDIG"},{"E2_FORBCO"},{"E2_FORAGE"},{"E2_FORCTA"},{"E2_FAGEDV"};
            ,{"E2_FCTADV"}}
        
        //aCpos_SEA := {{"EA_P_IDCNA"}}
        //aAreaSEE := GetArea("SEE")
        //aAreaSA1 := GetArea("SA1")
        //aAreaSA2 := GetArea("SA2")
        //aAreaSE1 := GetArea("SE1")
        aAreaSE2 := GetArea("SE2")
        //aAreaSEA := GetArea("SEA")
        /*
        DbSelectArea("SEE") 
        FOR x:=1 TO LEN(aCpos_SEE)
            IF FieldPos(aCpos_SEE[x,1]) == 0
                lRet := .F.
                cMsgCpos += aCpos_SEE[x,1] + ENTER
            ENDIF
        NEXT

        DbSelectArea("SA1") 
        FOR x:=1 TO LEN(aCpos_SA1)
            IF FieldPos(aCpos_SA1[x,1]) == 0
                lRet := .F.
                cMsgCpos += aCpos_SA1[x,1] + ENTER
            ENDIF
        NEXT

        DbSelectArea("SA2") 
        FOR x:=1 TO LEN(aCpos_SA2)
            IF FieldPos(aCpos_SA2[x,1]) == 0
                lRet := .F.
                cMsgCpos += aCpos_SA2[x,1] + ENTER
            ENDIF
        NEXT

        DbSelectArea("SE1") 
        FOR x:=1 TO LEN(aCpos_SE1)
            IF FieldPos(aCpos_SE1[x,1]) == 0
                lRet := .F.
                cMsgCpos += aCpos_SE1[x,1] + ENTER
            ENDIF
        NEXT
        */
        DbSelectArea("SE2") 
        FOR x:=1 TO LEN(aCpos_SE2)
            IF FieldPos(aCpos_SE2[x,1]) == 0
                lRet := .F.
                cMsgCpos += aCpos_SE2[x,1] + ENTER
            ENDIF
        NEXT

        /*
        DbSelectArea("SEA") 
        FOR x:=1 TO LEN(aCpos_SEA)
            IF FieldPos(aCpos_SEA[x,1]) == 0
                lRet := .F.
                cMsgCpos += aCpos_SEA[x,1] + ENTER
            ENDIF
        NEXT
        */

        IF !lRet
        cMsgCpos := "Um ou mais campos obrigatórios não foram preenchidos:" + ENTER + cMsgCpos
            Help("",1,"CAMPOS OBRIGATÓRIOS",,cMsgCpos, 1, 0, NIL, NIL, NIL, NIL, NIL, {"Entre em contato com o Suporte e informe a mensagem!"})
        ENDIF

        //RestArea(aAreaSEE)   // Retorna o ambiente anterior
        //RestArea(aAreaSA1)   // Retorna o ambiente anterior
        //RestArea(aAreaSA2)   // Retorna o ambiente anterior
        //RestArea(aAreaSE1)   // Retorna o ambiente anterior
        RestArea(aAreaSE2)   // Retorna o ambiente anterior
        //RestArea(aAreaSEA)   // Retorna o ambiente anterior

ENDCASE
RETURN lRet
*=====================================================================================================================================*
