//|=====================================================================|
//|Programa: SUFIN001		   |Autor: João Vitor   | Data: 13/05/2016		|
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
//| Função: SUFIN001				Autor:João Vitor			Data: 13/05/2016 |
//|--------------------------------------------------------------------------|
//| Essa Função foi desenvolvida com base no Manual do Bco. Santander.	   |
//|--------------------------------------------------------------------------|
//| Descrição: Função para Validação de Código de Barras (CB) e Representação|
//|            Numérica do Código de Barras - Linha Digitável (LD).	         |
//|                                                                          |
//|            A LD de Bloquetos possui três Digitos Verificadores (DV) que  |
//|				são consistidos pelo Módulo 10, além do Dígito Verificador   |
//|				Geral (DVG) que é consistido pelo Módulo 11. Essa LD têm 47  |
//|            Dígitos.                                                      |
//|                                                                          |
//|            A LD de Títulos de Concessinárias do Serviço Público e IPTU   |
//|				possui quatro Digitos Verificadores (DV) que são consistidos |
//|            pelo Módulo 10, além do Digito Verificador Geral (DVG) que    |
//|            também é consistido pelo Módulo 10. Essa LD têm 48 Dígitos.   |
//|                                                                          |
//|            O CB de Bloquetos e de Títulos de Concessionárias do Serviço  |
//|            Público e IPTU possui apenas o Dígito Verificador Geral (DVG) |
//|            sendo que a única diferença é que o CB de Bloquetos é         |
//|            consistido pelo Módulo 11 enquanto que o CB de Títulos de     |
//|            Concessionárias é consistido pelo Módulo 10. Todos os CB´s    |
//|            têm 44 Dígitos.                                               |
//|                                                                          |
//|            Utilize também o gatilho com a Função SUFIN002()para converter |
//|            a LD em CB.													 |
//\--------------------------------------------------------------------------/
#include "rwmake.ch"

USER FUNCTION SUFIN001()       

local lret := SUFIN002(M->E2_CODBAR)
            
RETURN(lRet)

