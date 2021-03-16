#include "PROTHEUS.CH"       

#define ENTER CHR(13)+CHR(10)
//aValores := ( { cNumTit, dBaixa, cTipo, cNsNum, nDespes, nDescont, nAbatim, nValPgto, nJuros, nMulta, cForne, cOcorr, cCGC, nCM, cRejeicao, xBuffer })

/*/{Protheus.doc} FA430OCO
//TODO PE(Ponto de Entrada) utilizado para salvar os registros das ocorrências retornadas no arquivo CNAB 
para Pagamento na tabela Z0F (Log de retorno), possibilitando a emissão de um relatório do retorno.
@author Leonardo (EZ4)
@since 02/01/2019
@version 1.0
@return ${return}, ${return_description}
@type function
/*/

USER FUNCTION FA430OCO()
    //ConOut("********************************** CUSTOMIZAÇÃO EZ4 (PE) FA430OCO() "+Dtoc(Date())+" "+Time()+" LINHA: 17 **********************************")
    
    Local cZ0F_Table, cZ0F_Idcnab 
    Local cZ0F_BANCO, cZ0F_AGE, cZ0F_CTA 
    Local cZ0F_PREFIX, cZ0F_NUM, cZ0F_PARCEL, cZ0F_TIPO
    Local cZ0F_FORCLI, cZ0F_NOMFC, cZ0F_CGCCPF
    Local dZ0F_DTVENC, dZ0F_DTBAIX, dZ0F_DTPROC, cZ0F_HRPROC
    Local nZ0F_VALOR
    Local cZ0F_OCORRE, cZ0F_DESCOC
    LOCAL lAccesOK := SUPERGETMV("MV_P_00130",.F.,.F.) // SE A EMPRESA UTILIZA A ROTINA DA ACCESSTAGE DEVE VALIDAR OS CAMPOS DA TABELA SE2 (TITULOS A PAGAR)
	LOCAL cIdCnab 

    ConOut("********* CUSTOMIZAÇÃO EZ4 (PE) FA430OCO() "+Dtoc(Date())+" "+Time()+" LINHA: 27 *********")
    
    IF lAccesOK // SE A EMPRESA UTILIZA A ROTINA DA ACCESSTAGE DEVE VALIDAR OS CAMPOS DA TABELA SE2 (TITULOS A PAGAR)
        cZ0F_Table := "Z0F" 
        cZ0F_Idcnab := PARAMIXB[1,1]
        cZ0F_BANCO  := mv_par05
        cZ0F_AGE    := mv_par06
        cZ0F_CTA    := mv_par07
        cZ0F_PREFIX := SE2->E2_PREFIXO
        cZ0F_NUM    := SE2->E2_NUM
        cZ0F_PARCEL := SE2->E2_PARCELA
        cZ0F_TIPO   := SE2->E2_TIPO
        cZ0F_FORCLI := SE2->E2_FORNECE 
        cZ0F_NOMFC  := SE2->E2_P_NOMBN
        cZ0F_CGCCPF := SE2->E2_P_CGCBN
        dZ0F_DTVENC := PARAMIXB[1,2]
        dZ0F_DTBAIX := DATE()
        dZ0F_DTPROC := DATE()
        cZ0F_HRPROC := StrTran( TIME(),":","" )
        nZ0F_VALOR  := PARAMIXB[1,8]
        cZ0F_OCORRE := AllTrim(SUBSTR(PARAMIXB[1,16],231,10))
        
        IF !MsFile(RetSqlName(cZ0F_Table),,"TOPCONN")
            MSGALERT("NESSARIO APLICAR UPDATE PARA CRIAÇÃO DO ALIAS:"+cZ0F_Table+ENTER+" POR FAVOR INFORMAR O ADMINISTRADOR","NÃO EXISTE ALIAS: "+cZ0F_Table)
            RETURN .F.
        ENDIF 
        
        cZ0F_DESCOC := AllTrim(SEB->EB_DESCRI)
        
        IF LEN(AllTrim(SUBSTR(PARAMIXB[1,16],231,10)))>2
            cZ0F_DESCOC += " - ( " 
            FOR nI:= 1 TO (LEN(AllTrim(SUBSTR(PARAMIXB[1,16],231,10)))/2)
                nI:= nI+1  
                //MSGINFO(SUBSTR(PARAMIXB[1,16],231+nI,2))
                cOcorrencia := PADR(SUBSTR(PARAMIXB[1,16],231+nI,2),3) 
                If !(dbSeek(xFilial("SEB")+mv_par05+cOcorrencia+"P"))
                    if ! lExecJob
                        Help(" ",1,"FA430OCORR")
                    Endif
                    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                    //³ Atualiza o log de processamento com o erro  ³
                    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                    ProcLogAtu("ERRO","FA430OCORR",Ap5GetHelp("FA430OCORR"))
                else
                    cZ0F_DESCOC += AllTrim(SEB->EB_DESCRI) + ", "
                Endif 			                                  
                            
            NEXT   
            cZ0F_DESCOC += " ) "     
            dbSeek(xFilial("SEB")+mv_par05+cOcorr+"P")
        ENDIF 
        
        ConOut("## EZ4 - (PE) FA430OCO LINHA 70")//MSGINFO(SE2->E2_IDCNAB,"FA430OCO: IDCNAB TITULO")
        DbSelectArea(cZ0F_Table)
        (cZ0F_Table)->(DbSetOrder(1))
        IF !(cZ0F_Table)->(dbSeek(xFilial(cZ0F_Table) + SE2->E2_IDCNAB + SEB->EB_OCORR + cZ0F_OCORRE + cZ0F_HRPROC + cZ0F_HRPROC)) 
        //(cZ0F_Table)->(dbAppend( .F. )) // COMENTADO POIS ESTAVA DANDO ERRO DE dbUnlock e a RDD da tabela em questão está com uma transação ativa 
        RecLock(cZ0F_Table, .T.)
        //(cZ0F_Table)->(RecLock(.T.))
            (cZ0F_Table)->Z0F_FILIAL := xFilial("SEB")
            (cZ0F_Table)->Z0F_IDCNAB := cZ0F_Idcnab
            (cZ0F_Table)->Z0F_BANCO  := cZ0F_BANCO
            (cZ0F_Table)->Z0F_AGE    := cZ0F_AGE
            (cZ0F_Table)->Z0F_CTA    := cZ0F_CTA
            (cZ0F_Table)->Z0F_PREFIX := cZ0F_PREFIX
            (cZ0F_Table)->Z0F_NUM    := cZ0F_NUM
            (cZ0F_Table)->Z0F_PARCEL := cZ0F_PARCEL
            (cZ0F_Table)->Z0F_TIPO   := cZ0F_TIPO
            (cZ0F_Table)->Z0F_FORCLI := cZ0F_FORCLI
            (cZ0F_Table)->Z0F_NOMFC  := cZ0F_NOMFC
            (cZ0F_Table)->Z0F_CGCCPF := cZ0F_CGCCPF
            (cZ0F_Table)->Z0F_DTEMIS := SE2->E2_EMISSAO
            (cZ0F_Table)->Z0F_DTVENC := dZ0F_DTVENC
            IF cOcorr == '00 '
                (cZ0F_Table)->Z0F_DTBAIX := dZ0F_DTBAIX
            ENDIF
            (cZ0F_Table)->Z0F_DTPROC := dZ0F_DTPROC
            (cZ0F_Table)->Z0F_HRPROC := cZ0F_HRPROC
            (cZ0F_Table)->Z0F_VALOR  := nZ0F_VALOR
            (cZ0F_Table)->Z0F_REFBAN := cZ0F_OCORRE
            (cZ0F_Table)->Z0F_OCORRE := SEB->EB_OCORR
            (cZ0F_Table)->Z0F_DESCOC := cZ0F_DESCOC
            (cZ0F_Table)->Z0F_NUMBOR := SE2->E2_NUMBOR
        //(cZ0F_Table)->(dbUnlock()) // COMENTADO POIS ESTAVA DANDO ERRO DE dbUnlock e a RDD da tabela em questão está com uma transação ativa 
        MsUnLock()  
        ENDIF
        (cZ0F_Table)->(dbCloseArea()) 
        
        If ( SEB->EB_OCORR $ "03" )
        	cIdCnab := ALLTRIM(SE2->E2_IDCNAB)                                
        	dbSelectArea("SEA")
			dbSetOrder(1)
        	IF dbSeek(xFilial()+SE2->E2_NUMBOR+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA) 
                RecLock( "SEA", .F.)
                SEA->EA_P_IDCNA := cIdCnab
                MsUnlock( )
            ENDIF
        ENDIF
     ConOut("********* CUSTOMIZAÇÃO EZ4 (PE) FA430OCO() "+Dtoc(Date())+" "+Time()+" LINHA: 128 *********")   
    ENDIF  
     
RETURN