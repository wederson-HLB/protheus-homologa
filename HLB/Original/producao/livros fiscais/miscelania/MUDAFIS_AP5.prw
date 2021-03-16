#include "rwmake.ch"

/*/
________________________________________________________________________________
| Função     | MUDAFIS  | Autor | Pryor - Informática         | Data  03.02.93 |
________________________________________________________________________________
|Descrição   |Permitir que o usuário altere parametros específicos             |
________________________________________________________________________________
| Uso        |Módulo Fiscal													   |	
________________________________________________________________________________
/*/

User Function MudaFIS()

Local xNomeEmp:= AllTrim(SM0->M0_NOME)
                             
dDatade := GetMV("MV_DATADE")
dDataAte:= GetMV("MV_DATAATE")
dDataFin:= GetMV("MV_DATAFIN")
dULMes  := GetMV("MV_ULMES")
dDataFis:= GetMV("MV_DATAFIS")

@ 200,001 to 400,260 Dialog oDlg1 Title "Altera Parametros"
@ 010,010 Say "Parametros "+xNomeEmp
@ 030,020 Say "Data De: "
@ 040,020 Say "Data Ate: "
@ 050,020 Say "Data Fin: "
@ 060,020 Say "ULMES: "
@ 070,020 Say "Data Fis: "
@ 030,050 Say DTOC(dDatade)  Size 40,20   
@ 040,050 Say DTOC(dDataAte) Size 40,20
@ 050,050 Say DTOC(dDataFin) Size 40,20
@ 060,050 Say DTOC(dULMes)   Size 40,20
@ 070,050 Get dDataFis Picture "@D" Size 40,20
@ 080,020 Button "_Confirmar" Size 40,10 Action ConfParam(dDataFis)
@ 080,070 Button "_Sair" Size 30,10 Action Close(oDlg1)
Activate Dialog oDlg1 Centered

Return                                                 

Static Function ConfParam(dDataFis)

Local x
//DbSelectArea("SX6")
//x:=GetMV("MV_dDATADE")	//usado para posicionar o registro no sx6
//RecLock("SX6",.f.)
//Replace X6_CONTEUD With DtoC(dDataDe)
//MsUnlock()

//x:=GetMV("MV_dDATAATE")
//RecLock("SX6",.f.)
///Replace X6_CONTEUD With DToC(dDatAte)
//MsUnlock()

///x:=GetMV("MV_dDATAFIN")
///RecLock("SX6",.f.)
///Replace X6_CONTEUD With DToC(dDatFI)
///MsUnlock()

x:=GetMV("MV_DATAFIS")
RecLock("SX6",.f.)
Replace X6_CONTEUD With DToC(dDataFIS)
MsUnlock()

//x:=GetMV("MV_dULMES")
//RecLock("SX6",.f.)
///Replace X6_CONTEUD With DToC(dULMe)
//MsUnlock()

Alert("Alteracao Efetuada.")

Return