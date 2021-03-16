#include "protheus.ch"

/*
Funcao      : MA415MNU
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : P.E. Adiciona rotina customizada no orçamento. 
Autor       : Tiago Luiz Mendonça
Data/Hora   : 16/09/2014     
Obs         : 
TDN         : Ponto de entrada disparado antes da abertura do Browse, caso Browse inicial da rotina esteja habilitado, ou antes da apresentação do
			  Menu de opções, caso Browse inicial esteja desabilitado. 
			  Para habilitar ou desabilitar o Browse, entre na rotina, clique em Configurações/Browse Inicial e selecione a opção desejada:
			  Sim - Habilitar Browse Inicial
			  Não - Desabilitar Browse Inicial
			  Este ponto de entrada pode ser utilizado para inserir novas opções no array aRotina.
Revisão     : 
Data/Hora   : 
Módulo      : Faturamento.
Cliente     : Victaulic
*/

*---------------------------*
 User Function MA415MNU()
*---------------------------*   

  
If cEmpAnt $ ("TM") .And. Alltrim(substr(GetEnvServer(),1,6))=="P11_16" 
	aadd(aRotina,{'Revisao','U_TMFAT006' , 0 , 6,0,NIL})
EndIf

Return