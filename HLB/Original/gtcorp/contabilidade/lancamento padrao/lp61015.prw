#include "rwmake.ch"       

User Function lp61015()     // LP 610-015 

SetPrvt("_vRetorno")

IF  (SM0->M0_CODIGO $ 'CH/RH/Z8/Z4/ZF/4K/ZG/ZA/ZP') // HMO - 28/09/2018 - Inclusão da empresa ZP - Ticket 47057

	_vRetorno := SD2->D2_VALISS
    
EndIf    

IF  (SM0->M0_CODIGO == 'ZB' .AND. SM0->M0_FILIAL <> '05')//AOA -  06/05/2016 - incluido validação por filial, chamado 033567

	If !(SM0->M0_FILIAL = '06' .AND. SF2->F2_RECISS = '1')

		_vRetorno := SD2->D2_VALISS    

    EndIf
    
EndIf    

RETURN(_vRetorno)