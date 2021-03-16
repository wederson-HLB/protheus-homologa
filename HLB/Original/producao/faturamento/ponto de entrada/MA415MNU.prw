#include "protheus.ch"

/*
Funcao      : MA415MNU
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : P.E. Adiciona rotina customizada no or�amento. 
Autor       : Tiago Luiz Mendon�a
Data/Hora   : 16/09/2014     
Obs         : 
TDN         : Ponto de entrada disparado antes da abertura do Browse, caso Browse inicial da rotina esteja habilitado, ou antes da apresenta��o do
			  Menu de op��es, caso Browse inicial esteja desabilitado. 
			  Para habilitar ou desabilitar o Browse, entre na rotina, clique em Configura��es/Browse Inicial e selecione a op��o desejada:
			  Sim - Habilitar Browse Inicial
			  N�o - Desabilitar Browse Inicial
			  Este ponto de entrada pode ser utilizado para inserir novas op��es no array aRotina.
Revis�o     : 
Data/Hora   : 
M�dulo      : Faturamento.
Cliente     : Victaulic
*/

*---------------------------*
 User Function MA415MNU()
*---------------------------*   

  
If cEmpAnt $ ("TM") .And. Alltrim(substr(GetEnvServer(),1,6))=="P11_16" 
	aadd(aRotina,{'Revisao','U_TMFAT006' , 0 , 6,0,NIL})
EndIf

Return