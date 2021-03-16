#include 'totvs.ch'

/*
Funcao      : ANTCTBGRV
Objetivos   : P.E. para que sejam gerados pré-lançamentos contábeis em casos especificos. 
Autor     	: Eduardo C. Romanini
Data     	: 19/11/2013                       
*/
*-----------------------*
User Function ANTCTBGRV()
*-----------------------*
Local cLote    := ""
Local cSubLote := ""
Local cDoc     := ""

Local nOpcx := 0
Local dDataLanc
Local aParam := ParamIXB
                        
nOpcX     := ParamIXB[1]
dDataLanc := ParamIXB[2]
cLote     := ParamIXB[3]
cSubLote  := ParamIXB[4]
cDoc      := ParamIXB[5]

//Tratamento para todas as empresas
If CT5->CT5_LANPAD == "650" .or.;//Inclusão de documento de entrada
   CT5->CT5_LANPAD == "655"      //Exclusão de documento de entrada 

	//Equipe de Retenções
	If AllTrim(UsrRetName(__cUserID)) == "adenaide.sousa" .or.;
   	   AllTrim(UsrRetName(__cUserID)) == "andrea.ferreira" .or.;
   	   AllTrim(UsrRetName(__cUserID)) == "claudia.jesus" .or.;
   	   AllTrim(UsrRetName(__cUserID)) == "gilberto.almeida" .or.;
   	   AllTrim(UsrRetName(__cUserID)) == "paulo.abarco" .or.;
   	   AllTrim(UsrRetName(__cUserID)) == "wilson.pires" .or.;
  	   AllTrim(UsrRetName(__cUserID)) == "danilo.charlds" .or.;
   	   AllTrim(UsrRetName(__cUserID)) == "eliana.souza" .or.; 
   	   AllTrim(UsrRetName(__cUserID)) == "gabriela.villela" .or.;
   	   AllTrim(UsrRetName(__cUserID)) == "carla.faki" .or.;
	   AllTrim(UsrRetName(__cUserID)) == "samantha.santos" .or.;   	
	   AllTrim(UsrRetName(__cUserID)) == "jefferson.oliveira" .or.;
	   AllTrim(UsrRetName(__cUserID)) == "ana.carvalho" .or.;
	   AllTrim(UsrRetName(__cUserID)) == "simone.silva" .or.;//JSS - 22/04/2015 Add para solucionar o caso 025771.
	   AllTrim(UsrRetName(__cUserID)) == "rogerio.andrade" .or.;//JSS - 22/04/2015 Add para solucionar o caso 025771.
	   AllTrim(UsrRetName(__cUserID)) == "natalia.macedo" .or.;//JSS - 22/04/2015 Add para solucionar o caso 025771.
	   AllTrim(UsrRetName(__cUserID)) == "cristiane.monaco" .or.;//JSS - 22/04/2015 Add para solucionar o caso 025771.
	   AllTrim(UsrRetName(__cUserID)) == "leonardo.gomes".or.;
	   AllTrim(UsrRetName(__cUserID)) == "jessica.sanchez" .or.;//JSS - 22/05/2015 Add para solucionar o caso 026411.
	   AllTrim(UsrRetName(__cUserID)) == "glaice.machado"//JSS - 22/05/2015 Add para solucionar o caso 026411.
	    

		__PreLan:=.T.
	EndIf
EndIf

//Tratamento por Clientes.
Do Case
	Case cEmpAnt == "L2" //SilverSpring
		If	CT5->CT5_LANPAD == "510" .or. CT5->CT5_LANPAD == "515" .or.;//Inclusão/Exclusão Contas a Pagar.
			CT5->CT5_LANPAD == "530" .or. CT5->CT5_LANPAD == "531"//Baixas/Estorno Contas a Pagar
			If AllTrim(UsrRetName(__cUserID)) == "adilson.ferreira"	.or.;
		   	   AllTrim(UsrRetName(__cUserID)) == "edimeia.almeida"	.or.;
		   	   AllTrim(UsrRetName(__cUserID)) == "mauricio.requena"

		   	   __PreLan:=.T.
			EndIf
		EndIf
	Case cEmpAnt == "N7" //Global English

		If	CT5->CT5_LANPAD == "510" .or. CT5->CT5_LANPAD == "515" .or.;//Inclusão/Exclusão Contas a Pagar.
			CT5->CT5_LANPAD == "530" .or. CT5->CT5_LANPAD == "531" .or.;//Baixas/Estorno Contas a Pagar
			CT5->CT5_LANPAD == "500" .or. CT5->CT5_LANPAD == "505" .or.;//Inclusão/Exclusão Contas a Receber.
			CT5->CT5_LANPAD $ "520|521|522|523|524|525|526" .or.;		//Baixas Contas a Receber 
			CT5->CT5_LANPAD == "527"									//Estorno Contas a Receber
			
			If AllTrim(UsrRetName(__cUserID)) == "adilson.ferreira"	.or.;
		   	   AllTrim(UsrRetName(__cUserID)) == "edimeia.almeida"	.or.;
		   	   AllTrim(UsrRetName(__cUserID)) == "angela.pessoa"	.or.;
		   	   AllTrim(UsrRetName(__cUserID)) == "mauricio.requena"

		   	   __PreLan:=.T.
			EndIf
		EndIf

	Case cEmpAnt == "XR" //Texas

		If	CT5->CT5_LANPAD == "510" .or. CT5->CT5_LANPAD == "515" .or.;//Inclusão/Exclusão Contas a Pagar.
			CT5->CT5_LANPAD == "530" .or. CT5->CT5_LANPAD == "531" .or.;//Baixas/Estorno Contas a Pagar
			CT5->CT5_LANPAD == "500" .or. CT5->CT5_LANPAD == "505" .or.;//Inclusão/Exclusão Contas a Receber.
			CT5->CT5_LANPAD $ "520|521|522|523|524|525|526" .or.;		//Baixas Contas a Receber 
			CT5->CT5_LANPAD == "527"									//Estorno Contas a Receber
			
			If AllTrim(UsrRetName(__cUserID)) == "adilson.ferreira"	.or.;
		   	   AllTrim(UsrRetName(__cUserID)) == "edimeia.almeida"	.or.;
		   	   AllTrim(UsrRetName(__cUserID)) == "angela.pessoa"	.or.;
		   	   AllTrim(UsrRetName(__cUserID)) == "mauricio.requena"

		   	   __PreLan:=.T.
			EndIf
		EndIf
	
	Case cEmpAnt == "H9" //Affinion

		If	CT5->CT5_LANPAD == "510" .or. CT5->CT5_LANPAD == "515" .or.;//Inclusão/Exclusão Contas a Pagar.
			CT5->CT5_LANPAD == "530" .or. CT5->CT5_LANPAD == "531" .or.;//Baixas/Estorno Contas a Pagar
			CT5->CT5_LANPAD == "500" .or. CT5->CT5_LANPAD == "505" .or.;//Inclusão/Exclusão Contas a Receber.
			CT5->CT5_LANPAD $ "520|521|522|523|524|525|526" .or.;		//Baixas Contas a Receber 
			CT5->CT5_LANPAD == "527"									//Estorno Contas a Receber
			
			If AllTrim(UsrRetName(__cUserID)) == "adilson.ferreira"	.or.;
		   	   AllTrim(UsrRetName(__cUserID)) == "edimeia.almeida"	.or.;
		   	   AllTrim(UsrRetName(__cUserID)) == "angela.pessoa"	.or.;
		   	   AllTrim(UsrRetName(__cUserID)) == "mauricio.requena"

		   	   __PreLan:=.T.
			EndIf
		EndIf
	
	Case cEmpAnt == "5F" //Alliance

		If	CT5->CT5_LANPAD == "510" .or. CT5->CT5_LANPAD == "515" .or.;//Inclusão/Exclusão Contas a Pagar.
			CT5->CT5_LANPAD == "530" .or. CT5->CT5_LANPAD == "531" .or.;//Baixas/Estorno Contas a Pagar
			CT5->CT5_LANPAD == "500" .or. CT5->CT5_LANPAD == "505" .or.;//Inclusão/Exclusão Contas a Receber.
			CT5->CT5_LANPAD $ "520|521|522|523|524|525|526" .or.;		//Baixas Contas a Receber 
			CT5->CT5_LANPAD == "527"									//Estorno Contas a Receber
			
			If AllTrim(UsrRetName(__cUserID)) == "adilson.ferreira"	.or.;
		   	   AllTrim(UsrRetName(__cUserID)) == "edimeia.almeida"	.or.;
		   	   AllTrim(UsrRetName(__cUserID)) == "angela.pessoa"	.or.;
		   	   AllTrim(UsrRetName(__cUserID)) == "mauricio.requena"

		   	   __PreLan:=.T.
			EndIf
		EndIf
	
	Case cEmpAnt == "DP" //Turn Latam

		If	CT5->CT5_LANPAD == "510" .or. CT5->CT5_LANPAD == "515" .or.;//Inclusão/Exclusão Contas a Pagar.
			CT5->CT5_LANPAD == "530" .or. CT5->CT5_LANPAD == "531" .or.;//Baixas/Estorno Contas a Pagar
			CT5->CT5_LANPAD == "500" .or. CT5->CT5_LANPAD == "505" .or.;//Inclusão/Exclusão Contas a Receber.
			CT5->CT5_LANPAD $ "520|521|522|523|524|525|526" .or.;		//Baixas Contas a Receber 
			CT5->CT5_LANPAD == "527"									//Estorno Contas a Receber
			
			If AllTrim(UsrRetName(__cUserID)) == "adilson.ferreira"	.or.;
		   	   AllTrim(UsrRetName(__cUserID)) == "edimeia.almeida"	.or.;
		   	   AllTrim(UsrRetName(__cUserID)) == "angela.pessoa"	.or.;
		   	   AllTrim(UsrRetName(__cUserID)) == "mauricio.requena"

		   	   __PreLan:=.T.
			EndIf
		EndIf
	
EndCase

Return .F. 