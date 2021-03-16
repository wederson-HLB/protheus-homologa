#include "PROTHEUS.CH"       

#define ENTER CHR(13)+CHR(10)

/*/{Protheus.doc} F430COMP - Execuções complementares
//TODO PE(Ponto de Entrada) utilizado para disparo de email de titulos rejeitados .
@author Leonardo (EZ4)
@since 02/01/2019
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
USER FUNCTION F430COMP()
    //ConOut("********************************** CUSTOMIZAÇÃO EZ4 (PE) F430COMP() "+Dtoc(Date())+" "+Time()+" LINHA: 15 **********************************")
    LOCAL aSE2REJ  := {}
    LOCAL aSE2REJ2 := {}
    LOCAL lAccesOK := SUPERGETMV("MV_P_00130",.F.,.F.) // SE A EMPRESA UTILIZA A ROTINA DA ACCESSTAGE DEVE VALIDAR OS CAMPOS DA TABELA SE2 (TITULOS A PAGAR)
    LOCAL cDirOrig := ""
	LOCAL cDirDest := ""
	LOCAL cArq     := ""
    IF lAccesOK // SE A EMPRESA UTILIZA A ROTINA DA ACCESSTAGE DEVE VALIDAR OS CAMPOS DA TABELA SE2 (TITULOS A PAGAR)

        dbSelectArea("Z0F")
        dbSetOrder(1)
        Z0F->(dbGoTop())

        WHILE !Z0F->(EOF())
            IF Z0F->Z0F_OCORRE == '03' .AND. Z0F->Z0F_DTPROC == DATE() .AND. EMPTY(Z0F->Z0F_DTENVI) 
                aSE2REJ := {Z0F->(Z0F_PREFIX),Z0F->(Z0F_NUM),Z0F->(Z0F_PARCEL),Z0F->(Z0F_TIPO),Z0F->(Z0F_FORCLI),;
                            Z0F->(Z0F_NOMFC),Z0F->(Z0F_DTEMIS),Z0F->(Z0F_DTVENC),Z0F->(Z0F_VALOR),Z0F->(Z0F_BANCO),;
                            Z0F->(Z0F_DESCOC),Z0F->(Z0F_NUMBOR),Z0F->(Z0F_IDCNAB),Z0F->(Z0F_REFBAN),Z0F->(RECNO())}
                AADD(aSE2REJ2,aSE2REJ)  
            ENDIF
            Z0F->( dbSkip() )
        ENDDO
        
        //SE POSSUIR TITULO REJEITADO REALIZA O ENVIO DE EMAIL
        IF LEN(aSE2REJ2) > 0
            // FUNÇÃO PARA ENVIO DE EMAIL DE TITULOS REJEITADOS, SE RETORNAR VERDADEIRO GRAVA DATA E HORA DE ENVIO NOS REGISTROS
            IF U_GTFIN039(4,aSE2REJ2)
                aAreaSE2 := GetArea("SE2")
                FOR i := 1 TO LEN(aSE2REJ2)     
                    dbSelectArea("Z0F")
                    //dbSetOrder(1)
                    dbGoTo(aSE2REJ2[i,15])
                    //IF DbSeek(xFilial('Z0F')+aSE2REJ2[i,13]+aSE2REJ2[i,14])
                    IF !EOF()
                        RecLock('Z0F',.F.)
                            Z0F->Z0F_DTENVI	:= DATE()
                            Z0F->Z0F_HRENVI	:= StrTran( TIME(),":","" )
                        MsUnlock()
                    ENDIF

                    DbSelectArea("SE2")
                    SE2->(DbSetOrder(13))
                    IF SE2->(dbSeek(aSE2REJ2[i,13]))				
                        RecLock( "SE2", .F.)
                        SE2->E2_IDCNAB := Space(10)
                        MsUnlock( )
                    ENDIF
                    SE2->(dbCloseArea()) 
                NEXT
                RestArea(aAreaSE2)   // Retorna o ambiente anterior
            ENDIF
        ENDIF
        ConOut("********* CUSTOMIZAÇÃO EZ4 (PE) F430COMP() "+Dtoc(Date())+" "+Time()+" LINHA: 55 *********") 
        
        
        //aPergF430 := {MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04,MV_PAR05,MV_PAR06,MV_PAR07,MV_PAR08,MV_PAR09,MV_PAR10,MV_PAR11,MV_PAR12}
        //POSICIONA NA TABELA SEE PARA PEGAR O CAMINHO DE DESTINO PARA MOVER O ARQUIVO
        DbSelectArea("SEE")
		SEE->(DbSetOrder(1))
		IF SEE->(dbSeek(xFilial("SEE")+MV_PAR05+MV_PAR06+MV_PAR07+MV_PAR08))				
			IF SEE->EE_RETAUT $ '2|3'
				cDirOrig := AllTrim(SEE->EE_DIRPAG) 
				cDirDest := AllTrim(SEE->EE_BKPPAG)
			ENDIF
		ENDIF
		SEE->(dbCloseArea())

            cArq 	:= AllTrim(SUBSTR(MV_PAR03,RAt("\", MV_PAR03 )+1))//
            if ! _CopyFile(cDirOrig+cArq, cDirDest+cArq)
                Conout("Não foi possivel copiar o arquivo "+cArq+" para o diretorio "+cDirDest) // "Não foi possivel copiar o arquivo " # " para o diretorio "
            Else
                FCLOSE(nHdlBco)
                IF Ferase(cDirOrig+cArq) == -1
                    MsgStop('Falha na deleção do Arquivo ( FError'+str(ferror(),4)+             ')')
                ENDIF
            Endif
    ENDIF
    

RETURN