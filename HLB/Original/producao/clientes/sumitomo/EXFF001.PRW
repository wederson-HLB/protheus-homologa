/*
Funcao      : EXFF001
Parametros  : Nenhum
Retorno     : _ret   
Objetivos   : CNAB - Retornar código baseado na situação do título.
Autor     	: 
Data     	:  
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 15/03/2012
Módulo      : Financeiro
*/

*-----------------------*
 User Function EXFF001()             
*----------------------*

PRIVATE _ret:=" " 
//_aarea := getarea()

//DbSelectarea ("SE1")
//DbSetOrder (1)
//DbSeek (xFilial("SE1")+SEA->EA_PREFIXO+SEA->EA_NUM+SEA->EA_PARCELA)                                                                                                                          

IF(SE1->E1_SITUACA='4')
_ret :="000651015001411019"
ELSEIF(SE1->E1_SITUACA='1')
_ret :="000117059001417019"
ELSEIF(SE1->E1_SITUACA='3')
_ret :="000651015001431019"
ELSE                      
_ret :=" "
ENDIF

//Restarea(_aarea)         
Return(_ret)