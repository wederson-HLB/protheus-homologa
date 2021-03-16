#include 'protheus.ch'
#include 'parmtype.ch'

User Function MA415COR()
//Local aCor:= aClone(PARAMIXB[1])
//Local aCor	:= {{'SCJ->CJ_STATUS=="A"', 'ENABLE'},;			 	//Orcamento em Aberto
//            	{'SCJ->CJ_STATUS=="B"', 'DISABLE'},;				//Orcamento Baixado
//            	{'SCJ->CJ_STATUS=="C"', 'BR_PRETO'},;				//Orcamento Cancelado
//            	{'SCJ->CJ_STATUS=="D"', 'BR_AMARELO'},;			//Orcamento nao Orcado
//                {'SCJ->CJ_STATUS=="F"', 'BR_MARROM'},;
//                {'SCJ->CJ_NUM=="000005"', 'BR_AZUL'}}				//Orcamento bloqueado
                Local aCor	:= {{'SCJ->CJ_STATUS=="B"', 'DISABLE'},;
                    {'SCJ->CJ_NUM=="000005"', 'BR_AZUL'}}				//Orcamento bloqueado

                    //If lRetorno .And. ExistBlock("A415TDOK")
                    //lRetorno := ExecBlock("A415TDOK",.F.,.F.)
                //EndIf
                Return(aCor)