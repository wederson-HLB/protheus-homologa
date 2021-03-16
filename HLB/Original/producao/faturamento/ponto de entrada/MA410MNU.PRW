#include "protheus.ch"

/*
Funcao      : MA410MNU
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : P.E. Adiciona rotina customizada no pedido de vendas. 
Autor       : Innovare Soluções
Data/Hora   : 29/10/2013     
Obs         : 
TDN         : Ponto de entrada disparado antes da abertura do Browse, caso Browse inicial da rotina esteja habilitado, ou antes da apresentação do
			  Menu de opções, caso Browse inicial esteja desabilitado. 
			  Para habilitar ou desabilitar o Browse, entre na rotina, clique em Configurações/Browse Inicial e selecione a opção desejada:
			  Sim - Habilitar Browse Inicial
			  Não - Desabilitar Browse Inicial
			  Este ponto de entrada pode ser utilizado para inserir novas opções no array aRotina.
Revisão     : Renato Rezende
Data/Hora   : 11/03/2014
Módulo      : Faturamento.
Cliente     : Mabra / Victaulic
*/

*---------------------------*
 User Function MA410MNU()
*---------------------------*   
Local nPosAlt

//RRP - 23/07/2014 - Inclusão empresa Exeltis. Chamado 020283 
If cEmpAnt $ ("JK/SU")  //Mabra/Exeltis 
	aadd(aRotina,{'Impr. Etiqueta','U_JKFAT010()' , 0 , 6,0,NIL})
	aAdd(aRotina,{"Impr. Laser", "U_SUFAT002()", 0 , 6, 0, nil})
EndIf

//RSB - 03/08/2017 - Inclusão empresa Exeltis. Projeto Reinplantação 
If cEmpAnt $ ("LG")  //Exeltis 
	aadd(aRotina,{'Impr. Etiqueta','U_LGFAT003()' , 0 , 6,0,NIL})  
	aAdd(aRotina,{"Impr. Laser", "U_LGFAT002()", 0 , 6, 0, nil})
EndIf         

//TLM - 25/07/2014 - Tratamento de informações adicionais após geração do picking list
If cEmpAnt $ ("TM") .And. Alltrim(substr(GetEnvServer(),1,6))=="P11_16" 
	aadd(aRotina,{'Inf. Adicional','U_TMFAT005' , 0 , 6,0,NIL})
EndIf 

//JSS - 09/04/2015 - Tratamento para ajuste do numero de P.O. 
If cEmpAnt $ ("TP")  //Twitter
	aadd(aRotina,{'Altera P.O.','U_TPFAT003' , 0 , 6,0,NIL})
EndIf

//AOA - 08/02/2018 - Projeto doTerra (customizado por William Souza)
If cEmpAnt $ "N6"
	//aAdd(aRotina,{"Envio PickList FedEx","u_N6WS004(SC5->C5_P_CHAVE)"     ,0,3,0,NIL})
    //aAdd(aRotina,{"Importar Datatrax","u_N6WS007()"     ,0,3,0,NIL}) 
	aAdd(aRotina,{"Faturamento DT","u_N6FAT001()"     ,0,3,0,NIL})
	aAdd(aRotina,{"Transmissao Nf","u_N6FAT002()"     ,0,3,0,NIL}) 
	/*if FWCodFil() == "02"
		aAdd(aRotina,{"Gera Danfe"    ,"u_N6FAT003()"     ,0,3,0,NIL})
		aAdd(aRotina,{"Retorno PickList FedEx","u_N6WS005()"     ,0,3,0,NIL})
		aAdd(aRotina,{"Reenvia Ws Erro","u_N6WS009()"     ,0,3,0,NIL})
		aAdd(aRotina,{"Envio PickList FedEx","u_N6WS004(SC5->C5_P_CHAVE)"     ,0,3,0,NIL}) 				
	Else
		aAdd(aRotina,{"Gera Danfe"    ,"u_N6FAT004()"     ,0,3,0,NIL}) 
	EndIf*/
	aAdd(aRotina,{"Libera Pedido" ,"u_N6FAT010()"     ,0,3,0,NIL}) 	
EndIF

If cEmpAnt == "R7"
   // Envio de documentos para o operador logístico - SFTP e WS.  
   aadd(aRotina,{"Arquivos Operador Logístico - IDL","U_R7WSFATB()",0,7,0, nil} )
EndIf

If cEmpAnt == "X2"
   nPosAlt:=Ascan(aRotina, {|x| Upper(AllTrim(x[1])) == "ALTERAR"})
   If nPosAlt > 0
      //aRotina[nPosAlt][2] := "u_X2FAT003()"
   EndIf 
EndIf 

Return 
