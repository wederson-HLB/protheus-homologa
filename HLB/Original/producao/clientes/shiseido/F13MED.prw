
/*
Funcao      : F13Med
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Quebra galho para calculo do 13 variavel  
Autor     	: Wederson Lourenco Santana                               
Data     	: 16/12/2005                     
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça	
Data/Hora   : 17/07/12
Módulo      : Gestão Pessoal. 
Cliente     : Shiseido
*/

*----------------------*
 User Function F13Med()
*----------------------* 
 
_nValor := 0
SRD->(DbSetOrder(1))
If SRD->(DbSeek(xFilial("SRD")+SRA->RA_MAT+"200511"+"180"))
   _nValor += SRD->RD_VALOR
Endif
If SRD->(DbSeek(xFilial("SRD")+SRA->RA_MAT+"200511"+"191"))
   _nValor += SRD->RD_VALOR
Endif
If SRD->(DbSeek(xFilial("SRD")+SRA->RA_MAT+"200510"+"180"))
   _nValor += SRD->RD_VALOR
Endif
If SRD->(DbSeek(xFilial("SRD")+SRA->RA_MAT+"200510"+"191"))
   _nValor += SRD->RD_VALOR
Endif

If Year(SRA->RA_ADMISSA) == Year(dDataBase)
   _nAvos := (Month(dDataBase)-Month(SRA->RA_ADMISSA))+1
Else
   _nAvos := 12
Endif

_nValExtra :=0
SRD->(DbSetOrder(1))
SRD->(DbSeek(xFilial("SRD")+SRA->RA_MAT))
While SRA->RA_MAT == SRD->RD_MAT
     SRV->(DbSetOrder(1))
     If SRD->RD_DATARQ >= "200501".AND.SRD->RD_DATARQ <= "200512"
     If SRD->RD_PD =="160"           
        SRV->(DbSeek(xFilial("SRV")+"160"))
        _nValExtra += (SRD->RD_HORAS*@SalHora)*(SRV->RV_PERC/100)
     Endif
     If SRD->RD_PD == "161"
        SRV->(DbSeek(xFilial("SRV")+"161"))
        _nValExtra += (SRD->RD_HORAS*@SalHora)*(SRV->RV_PERC/100)
     Endif
     If SRD->RD_PD == "162"
        SRV->(DbSeek(xFilial("SRV")+"162"))
        _nValExtra += (SRD->RD_HORAS*@SalHora)*(SRV->RV_PERC/100)
     Endif
     If SRD->RD_PD == "163"
        SRV->(DbSeek(xFilial("SRV")+"163"))
        _nValExtra += (SRD->RD_HORAS*@SalHora)*(SRV->RV_PERC/100)
     Endif

     If SRD->RD_PD == "190"
        _nValExtra += (SRD->RD_HORAS*@SalHora)
     Endif
     Endif
     SRD->(DbSkip())
End     

_nValor := ((((_nValor/3)/12)*_nAvos)+(_nValExtra/12))

If _nValor > 0
   fGeraVerba("015",_nValor)
Endif   

SRD->(DbSetOrder(1))
If SRD->(DbSeek(xFilial("SRD")+SRA->RA_MAT+"200511"+"011"))  
   fGeraVerba("659",SRD->RD_VALOR)
Endif   

Return