#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*
Funcao      : GTFAT021
Parametros  : Nil
Retorno     : Nil
Objetivos   : Atualizar o status da nota de serviço eletrônica
Autor     	: Weden Alves
Data     	: 08/09/2018
Módulo      : Faturamento
*/
*---------------------------------*
 User Function GTFAT021()
*---------------------------------*
Private nBytes 		:= 0                 
Private CENTSAI 	:= '1'
Private aLote 		:= {}  
Private aIdNotas	:= {}
Private cIdInicial 	:= '000001'  
Private cIdFinal 	:= '999999'  
Private cSerie 		:= 'A  '   
Private cIdNotas 	:= ''    

RpcClearEnv()
RpcSetType(3)
PREPARE ENVIRONMENT EMPRESA "S2" FILIAL "01"

Private cIdEnt	:= Alltrim(SM0->M0_CIDENT)
Private cURL 	:= Padr( GetNewPar("MV_SPEDURL","http://localhost:8080/nfse"),250 )         

StaticCall(fisa022, FisMonitorX,'000038', cSerie , cIdInicial , cIdFinal , SM0->M0_CGC, SM0->M0_CGC, 1, /* dDataDe */, /* dDataAte */, /* cHoraDe */, /* cHoraAte */, /* nTempo */, /* nDiasParaExclusao */,'', Fisa022Cod("004"))

Return Nil