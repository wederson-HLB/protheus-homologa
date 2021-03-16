//|=====================================================================|
//|Programa: SUFIN001		   |Autor: Jo�o Vitor   | Data: 13/05/2016		|
//|=====================================================================|
//|Descricao:PROGRAMA PARA TRATAMENTO DO CAMPO E2_CODBAR PARA UTILIZACAO|
//|     	DO PAGFOR.                                                  |
//|=====================================================================|
//|Sintaxe:                                                             |
//|=====================================================================|
//|Uso: 									                            |
//|=====================================================================|
//|       ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.             |
//|---------------------------------------------------------------------|
//|Programador |Data:      |BOPS  |Motivo da Alteracao                  |
//|---------------------------------------------------------------------|
//|=====================================================================|
///--------------------------------------------------------------------------\
//| Fun��o: SUFIN001				Autor:Jo�o Vitor			Data: 13/05/2016 |
//|--------------------------------------------------------------------------|
//| Essa Fun��o foi desenvolvida com base no Manual do Bco. Santander.	   |
//|--------------------------------------------------------------------------|
//| Descri��o: Fun��o para Valida��o de C�digo de Barras (CB) e Representa��o|
//|            Num�rica do C�digo de Barras - Linha Digit�vel (LD).	         |
//|                                                                          |
//|            A LD de Bloquetos possui tr�s Digitos Verificadores (DV) que  |
//|				s�o consistidos pelo M�dulo 10, al�m do D�gito Verificador   |
//|				Geral (DVG) que � consistido pelo M�dulo 11. Essa LD t�m 47  |
//|            D�gitos.                                                      |
//|                                                                          |
//|            A LD de T�tulos de Concessin�rias do Servi�o P�blico e IPTU   |
//|				possui quatro Digitos Verificadores (DV) que s�o consistidos |
//|            pelo M�dulo 10, al�m do Digito Verificador Geral (DVG) que    |
//|            tamb�m � consistido pelo M�dulo 10. Essa LD t�m 48 D�gitos.   |
//|                                                                          |
//|            O CB de Bloquetos e de T�tulos de Concession�rias do Servi�o  |
//|            P�blico e IPTU possui apenas o D�gito Verificador Geral (DVG) |
//|            sendo que a �nica diferen�a � que o CB de Bloquetos �         |
//|            consistido pelo M�dulo 11 enquanto que o CB de T�tulos de     |
//|            Concession�rias � consistido pelo M�dulo 10. Todos os CB�s    |
//|            t�m 44 D�gitos.                                               |
//|                                                                          |
//|            Utilize tamb�m o gatilho com a Fun��o SUFIN002()para converter |
//|            a LD em CB.													 |
//\--------------------------------------------------------------------------/
#include "rwmake.ch"

USER FUNCTION SUFIN001()       

local lret := SUFIN002(M->E2_CODBAR)
            
RETURN(lRet)

