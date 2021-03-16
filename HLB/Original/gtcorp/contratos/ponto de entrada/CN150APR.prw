#include "rwmake.ch" 

/*
Funcao      : CN150APR 
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : EXECUTADO APOS A APROVACAO DA REVISAO - possibilita atualizar data de revisao do contrato com base em tipo de revisao contida no parametro MV_XTIPREV
Autor       : 
TDN         : Function CN150Aprov - Função responsável pela aprovação da revisão do contrato/ Executado apos a aprovação da revisão. 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 06/02/2012
Módulo      : Contratos.
*/

*-------------------------*                       
 User Function CN150APR()  
*-------------------------*

Local  cNumCtr     := '"
Local  dDtRevOld   := ctod("  /  /  ")
//Comentado pois o repositório da 11 é separado MSM - 21/08/2012
/*Local  cAmbiente   := "GTCORP/GTCORPTESTE/ENVGTCORP01/ENVGTCORP02"

If !Upper(GetEnvServer()) $ Upper(cAmbiente)
    Return
Endif     
*/

cNumCtr   := CN9->CN9_NUMERO
dDtRevOld := CN9->CN9_DTREV

If !Empty(dDtRevOld)
    If CN9->CN9_TIPREV $ ALLTRIM(GetMv("MV_XTIPREV"))
        MsgAlert("Data de Revisão do Contrato = "+dtoc(dDtRevOld)+" ")
        IF MSGYESNO("Deseja Atualizar Data de Revisao do Contrato ?","Atualiza Data Revisao Contrato")
            dbSelectArea("CN9")
            RecLock("CN9",.F.)
            CN9->CN9_DTREV := dDtRevOld + 364 
            MsUnlock()
        Endif      
    Endif
Endif

Return