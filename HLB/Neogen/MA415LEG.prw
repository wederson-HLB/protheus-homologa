#include 'protheus.ch'
#include 'parmtype.ch'

User Function MA415LEG()
//Local aCor:= aClone(PARAMIXB[1])
Local aCor := {	{ 'ENABLE'    , 'Orcamento em Aberto' },; //'Orcamento em Aberto'
				{ 'DISABLE'   , 'Orcamento Baixado' },; //'Orcamento Baixado'
				{ 'BR_PRETO'  , 'Orcamento Cancelado' },; //'Orcamento Cancelado'
				{ 'BR_AMARELO', 'Orcamento nao Orcado' },; //'Orcamento nao Orcado'
                { 'BR_MARROM' , 'Orcamento bloqueado' },;  //'Orcamento bloqueado'
                { 'BR_AZUL' , 'Orcamento Parcial' }}				
Return(aCor)