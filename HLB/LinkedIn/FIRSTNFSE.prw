#Include 'Totvs.Ch'

/*
Funcao      : FIRSTNFSE
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Inclusão de rotina no menu de NFS-e FISA022. 
TDN			: Este ponto de entrada tem a finalidade de executar a manipulação do array aRotina utilizado pelo menu da Nota Fiscal de Serviço Eletrônica.
Autor       : Renato Rezende
Data/Hora   : 18/04/2018
*/
*---------------------------*
 User Function FIRSTNFSE()
*---------------------------*

If cEmpAnt $ "TP"
	If Type("aRotina") <> "U"
		aadd(aRotina,{'Env. NF/Bol','U_TPFIN008' , 0 , 4,0,NIL})
	EndIf
EndIf 

//AOA - 07/05/2018 - Prjeto NFS-e Linkedin
If cEmpAnt $ "ZJ"
	If Type("aRotina") <> "U"
		aadd(aRotina,{'Env. NF/Bol','U_ZJFIN003' , 0 , 4,0,NIL})
	EndIf
EndIf 

Return