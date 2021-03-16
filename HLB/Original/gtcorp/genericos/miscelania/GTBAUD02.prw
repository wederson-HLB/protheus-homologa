#Include 'Protheus.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GTBAUD02  ºAutor  ³Rafael Rosa da Silvaº Data ³  17/07/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Relatório Empresas x Usuários								  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Grant Thornton Brasil									  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function GTBAUD02()

Local oReport				//Objeto do relatorio
Local cNomeprog	:= "GTBAUD02"
Local cPerg		:= "GTBAUD0201"
Local cTitulo	:= "Relatório Empresas x Usuários"

ValidPerg(cPerg)

If Pergunte(cPerg,.T.)
	oReport := RunReport(cPerg,cNomeprog,cTitulo)
	oReport:PrintDialog()
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RunReport ºAutor  ³Rafael Rosa da Silvaº Data ³  17/07/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta a estrutura do relatorio							  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Grant Thornton Brasil									  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function RunReport(cPerg,cNomeprog,cTitulo)

Local oReport													// Objeto do relatorio
Local oSection1													// Objeto da secao 1
Local oSection2													// Objeto da secao 1
Local aOrdem	:= {}											// Ordens disponiveis para escolha do usuario

//Tamanho dos campos do cabeçalho
Local _nTamEmp	:= Len(cEmpAnt)
Local _nTamFil	:= Len(cFilAnt)
Local _nTamRaz	:= 60
Local _nTamCnpj	:= 14
Local _nTamEnd	:= 60

oReport := TReport():New(cNomeprog,cTitulo,cPerg,{|oReport| GTBAUDRpt(@oReport,_nTamEmp,_nTamFil)},"Imprime o Relatório Empresas x Usuários" )
oReport:SetLandscape()			//Define orientecao do relatorio como Paisagem 
oReport:nFontBody 	:= 5		//Define o tamanho da fonte do relatorio
oReport:lParamPage	:= .F.		//Nao imprime pafina de paramentros

//Cabeçalho do Relatorio
oSection1 := TRSection():New(oReport,"")
TRCell():New(oSection1,"EMPRESA","","Empresa"		,"@!"					,_nTamEmp	)
TRCell():New(oSection1,"FILIAL"	,"","Filial"		,"@!"					,_nTamFil	)
TRCell():New(oSection1,"RAZAO"	,"","Razão Social"	,"@!"					,_nTamRaz	)
TRCell():New(oSection1,"CNPJ"	,"","CNPJ"			,"@R 99.999.999/9999-99",_nTamCnpj	)
TRCell():New(oSection1,"ENDENT"	,"","Endereço"		,"@!"					,_nTamEnd	)

//
oSection2 := TRSection():New(oSection1,"")
TRCell():New(oSection2,"CODIGO"	,"","Código"		,"@!",6	)
TRCell():New(oSection2,"USUARIO","","Usuário"		,"@!",25)
TRCell():New(oSection2,"NOME"	,"","Nome Completo"	,"@!",40)
TRCell():New(oSection2,"USRBLQ"	,"","Usr Bloq"		,"@!",3	)
TRCell():New(oSection2,"EMAIL"	,"","E-Mail"		,"@!",50)
TRCell():New(oSection2,"DEPART"	,"","Departamento"	,"@!",40)
TRCell():New(oSection2,"CARGO"	,"","Cargo"			,"@!",40)
TRCell():New(oSection2,"GRUPO"	,"","Grupo"			,"@!",6	)
TRCell():New(oSection2,"GRPBLQ"	,"","Grp Bloq"		,"@!",3	)

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GTBAUDRpt ºAutor  ³Rafael Rosa da Silvaº Data ³  17/07/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Filtra as informacoes e monta os detalhes do relatorio	  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Grant Thornton Brasil									  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function GTBAUDRpt(oReport,_nTamEmp,_nTamFil)

Local oSec1		:= oReport:Section(1)					//Associa o Section1 com um objeto local
Local oSec2		:= oReport:Section(1):Section(1)		//Associa o Section2 com um objeto local
Local aUsers	:= AllUsers(.F.,.T.)					//Busca todos os usuarios
Local aGroups	:= {}									//Busca os dados do grupo do usuario
Local nI		:= 0									//contador
Local nY		:= 0									//Contador
Local aUserSec2	:= {}									//Dados dos usuarios
Local cEmpUsr	:= ""									//Empresa do Usuario
Local cFilUsr	:= ""									//Filial do Usuario
Local aEmpVld	:= {}									//Array contendo as empresas validas
Local aArea		:= GetArea()							//Salva a Area Atual
Local aAreaSM0	:= SM0->( GetArea() )					//Salva a Area da tabela SM0
Local nPEmpFil	:= 0									//Variavel de posicionamento
Local nTEmpFil	:= Len(Alltrim(cEmpAnt + cFilAnt))		//Tamanho da empresa e filial
Local lImpCab	:= .F.									//Verifica se imprime o cabeçalho ou nao
Local nQtdUser	:= 0									//Contador de usuarios por empresa/filial
Local cGrupo	:= ""									//Grupo do Usuario
Local aEmpGrp	:= {}									//Busca as Empresas do Grupo se o mesmo estiver priorizado
Local cUsrBlq	:= ""									//Usuario Bloqueado
Local cGrpBlq	:= ""									//Grupo Bloqueado

//Busca os dados do cabeçalho
dbSelectArea("SM0")
SM0->( dbSetOrder(1) )
SM0->( dbGoTop() )
While !SM0->( Eof() )
	If  Alltrim(SM0->M0_CODIGO) >= Alltrim(MV_PAR01) .And. Alltrim(SM0->M0_CODIGO) <= Alltrim(MV_PAR02) .And.;
		Alltrim(SM0->M0_CODFIL) >= Alltrim(MV_PAR03) .And. Alltrim(SM0->M0_CODFIL) <= Alltrim(MV_PAR04)
		
		aAdd(aEmpVld,{	SM0->M0_CODIGO,;
						SM0->M0_CODFIL,;
						SM0->M0_NOMECOM,;
						SM0->M0_CGC,;
						SM0->M0_ENDENT})
	EndIf
	SM0->( dbSkip() )
End

If Len(aEmpVld) > 0
	//Busca os dados dos usuarios
	For nI := 1 to Len(aUsers)		
		If Len(aUsers[nI][2][6]) > 0
			For nY := 1 to Len(aUsers[nI][2][6])
				cEmpUsr	:= SubStr(aUsers[nI][2][6][nY],1,_nTamEmp)
				cFilUsr	:= SubStr(aUsers[nI][2][6][nY],_nTamEmp +1,_nTamFil)
				cUsrBlq	:= IIF(aUsers[nI][1][17],"Sim","Não")
				
				//Verifica se o usuario possui um grupo
				If Len(aUsers[nI][1][10]) > 0
					//Busca os dados do Grupo
					aGroups := FWGrpParam(aUsers[nI][1][10][1])
					
					//Traz o nome do grupo para facilitar o entendimento
					cGrupo	:= Alltrim(aGroups[1][1])
					cGrpBlq	:= IIF(aGroups[1][3] == "1","Sim","Não")
				Else
					cGrupo	:= ""
					cGrpBlq	:= ""
				EndIf			
				
				aAdd(aUserSec2,{cEmpUsr,;				//Empresa
								cFilUsr,;				//Filial
								aUsers[nI][1][1],;		//Codigo do Usuario
								aUsers[nI][1][2],;		//Usuario
								aUsers[nI][1][4],;		//Nome completo do Usuario
								aUsers[nI][1][14],;		//e-mail
								aUsers[nI][1][12],;		//Departamento
								aUsers[nI][1][13],;		//Cargo
								cGrupo,;				//Grupo
								cUsrBlq,;				//Usuario Bloqueado
								cGrpBlq})				//Grupo Bloqueado
								
			Next nY
		EndIf
		
		//Verifica se ele Prioriza Grupo
		If aUsers[nI][2][11]
			If Len(aUsers[nI][1][10]) > 0
				For nY := 1 to Len(aUsers[nI][1][10])
					aEmpGrp := FwGrpEmp(aUsers[nI][1][10][nY])
					For nZ := 1 to Len(aEmpGrp)
						If aScan(aUserSec2,{|x| Alltrim(x[1]) + Alltrim(x[2]) + Alltrim(x[3]) == Alltrim(aEmpGrp[nZ]) + Alltrim(aUsers[nI][1][1]) }) == 0
							//Busco a Empresa e a Filial
							cEmpUsr	:= SubStr(aEmpGrp[nZ],1,_nTamEmp)
							cFilUsr	:= SubStr(aEmpGrp[nZ],_nTamEmp +1,_nTamFil)
							cUsrBlq	:= IIF(aUsers[nI][1][17],"Sim","Não")
							
							//Busca os dados do Grupo
							aGroups := FWGrpParam(aUsers[nI][1][10][1])
							
							//Traz o nome do grupo para facilitar o entendimento
							cGrupo	:= Alltrim(aGroups[1][1])							
							
							cGrpBlq	:= IIF(aGroups[1][3] == "1","Sim","Não")

							aAdd(aUserSec2,{cEmpUsr,;				//Empresa
											cFilUsr,;				//Filial
											aUsers[nI][1][1],;		//Codigo do Usuario
											aUsers[nI][1][2],;		//Usuario
											aUsers[nI][1][4],;		//Nome completo do Usuario
											aUsers[nI][1][14],;		//e-mail
											aUsers[nI][1][12],;		//Departamento
											aUsers[nI][1][13],;		//Cargo
											cGrupo,;				//Grupo
											cUsrBlq,;				//Usuario Bloqueado
											cGrpBlq})				//Grupo Bloqueado
						EndIf
					Next nZ
				Next nY
			EndIf
		EndIf
	Next nI
	
	//Ajusta a Ordem das Empresas
	aUserSec2 := aSort(aUserSec2,,,{|x,y| x[1] + x[2] < y[1] + y[2] })
	
	oReport:SetMeter(Len(aEmpVld))
	
	For nI := 1 to Len(aEmpVld)
		If oReport:Cancel()
			Exit
		Endif
	
		oSec1:Init()
		
		//Verifico se existe algum usuario com a empresa/Filial vinculada
		nPEmpFil := aScan(aUserSec2,{|x| Alltrim(x[1]) + Alltrim(x[2]) == Alltrim(aEmpVld[nI][1]) + Alltrim(aEmpVld[nI][2])})
		lImpCab	 := .T.
		nQtdUser := 0

		If nPEmpFil > 0
			lImpCab	 := .F.
			oSec1:Cell("EMPRESA"):SetBlock( { || Alltrim(aEmpVld[nI][1])} )
			oSec1:Cell("FILIAL"	):SetBlock( { || Alltrim(aEmpVld[nI][2])} )
			oSec1:Cell("RAZAO"	):SetBlock( { || Alltrim(aEmpVld[nI][3])} )
			oSec1:Cell("CNPJ"	):SetBlock( { || Alltrim(aEmpVld[nI][4])} )
			oSec1:Cell("ENDENT"	):SetBlock( { || Alltrim(aEmpVld[nI][5])} )
			oSec1:PrintLine()
			
			oSec2:Init()
			
			oReport:SkipLine(2)

		    For nY := nPEmpFil to Len(aUserSec2)
		    	//Verifico se ainda esta na mesma Empresa/Filial
		    	If Alltrim(aUserSec2[nY][1]) + Alltrim(aUserSec2[nY][2]) <> Alltrim(aEmpVld[nI][1]) + Alltrim(aEmpVld[nI][2])
		    		Exit
		    	EndIf
				
				oSec2:Cell("CODIGO"	):SetBlock( { || Alltrim(aUserSec2[nY][03])} )
				oSec2:Cell("USUARIO"):SetBlock( { || Alltrim(aUserSec2[nY][04])} )
				oSec2:Cell("NOME"	):SetBlock( { || Alltrim(aUserSec2[nY][05])} )
				oSec2:Cell("USRBLQ"	):SetBlock( { || Alltrim(aUserSec2[nY][10])} )
				oSec2:Cell("EMAIL"	):SetBlock( { || Alltrim(aUserSec2[nY][06])} )
				oSec2:Cell("DEPART"	):SetBlock( { || Alltrim(aUserSec2[nY][07])} )
				oSec2:Cell("CARGO"	):SetBlock( { || Alltrim(aUserSec2[nY][08])} )
				oSec2:Cell("GRUPO"	):SetBlock( { || Alltrim(aUserSec2[nY][09])} )
				oSec2:Cell("GRPBLQ"	):SetBlock( { || Alltrim(aUserSec2[nY][11])} )
		  		oSec2:PrintLine()
		  		
		  		nQtdUser++
		    Next nY
		EndIf

		//Verifico se existe algum usuario com acesso a todas as empresas
		nPEmpFil := aScan(aUserSec2,{|x| Alltrim(x[1]) + Alltrim(x[2]) == Replicate("@",nTEmpFil) })
		If nPEmpFil > 0
			If lImpCab
				oSec1:Cell("EMPRESA"):SetBlock( { || Alltrim(aEmpVld[nI][1])} )
				oSec1:Cell("FILIAL"	):SetBlock( { || Alltrim(aEmpVld[nI][2])} )
				oSec1:Cell("RAZAO"	):SetBlock( { || Alltrim(aEmpVld[nI][3])} )
				oSec1:Cell("CNPJ"	):SetBlock( { || Alltrim(aEmpVld[nI][4])} )
				oSec1:Cell("ENDENT"	):SetBlock( { || Alltrim(aEmpVld[nI][5])} )
				oSec1:PrintLine()
				
				oSec2:Init()
				
				oReport:SkipLine(2)
			EndIf
			
		    For nY := nPEmpFil to Len(aUserSec2)
		    	//Verifico se ainda esta na mesma Empresa/Filial
		    	If Alltrim(aUserSec2[nY][1]) + Alltrim(aUserSec2[nY][2]) <> Replicate("@",nTEmpFil)
		    		Exit
		    	EndIf
				
				oSec2:Cell("CODIGO"	):SetBlock( { || Alltrim(aUserSec2[nY][03])} )
				oSec2:Cell("USUARIO"):SetBlock( { || Alltrim(aUserSec2[nY][04])} )
				oSec2:Cell("NOME"	):SetBlock( { || Alltrim(aUserSec2[nY][05])} )
				oSec2:Cell("USRBLQ"	):SetBlock( { || Alltrim(aUserSec2[nY][10])} )
				oSec2:Cell("EMAIL"	):SetBlock( { || Alltrim(aUserSec2[nY][06])} )
				oSec2:Cell("DEPART"	):SetBlock( { || Alltrim(aUserSec2[nY][07])} )
				oSec2:Cell("CARGO"	):SetBlock( { || Alltrim(aUserSec2[nY][08])} )
				oSec2:Cell("GRUPO"	):SetBlock( { || Alltrim(aUserSec2[nY][09])} )
				oSec2:Cell("GRPBLQ"	):SetBlock( { || Alltrim(aUserSec2[nY][11])} )
		  		oSec2:PrintLine()
		  		
		  		nQtdUser++
		    Next nY
		EndIf
		
		If nPEmpFil > 0
			oSec2:Finish()
			
			//Imprime o Totalizador da quantidade de registros
			If nQtdUser > 0
			   	oReport:SkipLine(1)
				oReport:PrintText("Total de Usuários:   " + Alltrim( Str(nQtdUser) ) )
				oReport:SkipLine(1)
				oReport:ThinLine()
			EndIf
		EndIf

		oSec1:Finish()		
		oReport:IncMeter()
	Next nI
EndIf


Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValidPerg ºAutor  ³Rafael Rosa da Silvaº Data ³  06/19/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina que cria o grupo de perguntas na tabela SX1		  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Eletrozema												  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ValidPerg(_cPerg)

Local aArea    := GetArea()
Local aAreaDic := SX1->( GetArea() )
Local aEstrut  := {}
Local aStruDic := SX1->( dbStruct() )
Local aDados   := {}
Local nI       := 0
Local nJ       := 0
Local nTam1    := Len( SX1->X1_GRUPO )
Local nTam2    := Len( SX1->X1_ORDEM )

aEstrut := { "X1_GRUPO"  , "X1_ORDEM"  , "X1_PERGUNT", "X1_PERSPA" , "X1_PERENG" , "X1_VARIAVL", "X1_TIPO"   , ;
             "X1_TAMANHO", "X1_DECIMAL", "X1_PRESEL" , "X1_GSC"    , "X1_VALID"  , "X1_VAR01"  , "X1_DEF01"  , ;
             "X1_DEFSPA1", "X1_DEFENG1", "X1_CNT01"  , "X1_VAR02"  , "X1_DEF02"  , "X1_DEFSPA2", "X1_DEFENG2", ;
             "X1_CNT02"  , "X1_VAR03"  , "X1_DEF03"  , "X1_DEFSPA3", "X1_DEFENG3", "X1_CNT03"  , "X1_VAR04"  , ;
             "X1_DEF04"  , "X1_DEFSPA4", "X1_DEFENG4", "X1_CNT04"  , "X1_VAR05"  , "X1_DEF05"  , "X1_DEFSPA5", ;
             "X1_DEFENG5", "X1_CNT05"  , "X1_F3"     , "X1_PYME"   , "X1_GRPSXG" , "X1_HELP"   , "X1_PICTURE", ;
             "X1_IDFIL"   }

//			  {X1_GRUPO	,X1_ORDEM,X1_PERGUNT	 ,X1_PERSPA		 ,X1_PERENG		 ,X1_VARIAVL,X1_TIPO,X1_TAMANHO	,X1_DECIMAL	,X1_PRESEL	,X1_GSC	,X1_VALID,X1_VAR01  ,X1_DEF01,X1_DEFSPA1,X1_DEFENG1	,X1_CNT01,X1_VAR02	,X1_DEF02,X1_DEFSPA2,X1_DEFENG2	,X1_CNT02,X1_VAR03	,X1_DEF03,X1_DEFSPA3,X1_DEFENG3	,X1_CNT03,X1_VAR04,X1_DEF04	,X1_DEFSPA4	,X1_DEFENG4	,X1_CNT04,X1_VAR05,X1_DEF05	,X1_DEFSPA5	,X1_DEFENG5	,X1_CNT05,X1_F3	,X1_PYME,X1_GRPSXG	,X1_HELP,X1_PICTURE	,X1_IDFIL}
aAdd( aDados, {_cPerg	,'01'	 ,'Empresa De: ?','Empresa De: ?','Empresa De: ?','MV_CH1'	,'C'	,6			,0			,2			,'G'	,''		 ,'MV_PAR01',''		 ,''		,''			,''		 ,''		,''		 ,''		,''			,''		 ,''		,''		 ,''		,''			,''		 ,''	  ,''		,''			,''			,''		 ,''	  ,''		,''			,''			,''		 ,'GTBEMP'	,''		,''			,''		,''			,''		 } )
aAdd( aDados, {_cPerg	,'02'	 ,'Empresa Ate:?','Empresa Ate:?','Empresa Ate:?','MV_CH2'	,'C'	,6			,0			,2			,'G'	,''		 ,'MV_PAR02',''		 ,''		,''			,''		 ,''		,''		 ,''		,''			,''		 ,''		,''		 ,''		,''			,''		 ,''	  ,''		,''			,''			,''		 ,''	  ,''		,''			,''			,''		 ,'GTBEMP'	,''		,''			,''		,''			,''		 } )
aAdd( aDados, {_cPerg	,'03'	 ,'Filial De: ?' ,'Filial De: ?' ,'Filial De: ?' ,'MV_CH3'	,'C'	,6			,0			,2			,'G'	,''		 ,'MV_PAR03',''		 ,''		,''			,''		 ,''		,''		 ,''		,''			,''		 ,''		,''		 ,''		,''			,''		 ,''	  ,''		,''			,''			,''		 ,''	  ,''		,''			,''			,''		 ,'GTBFIL'	,''		,''			,''		,''			,''		 } )
aAdd( aDados, {_cPerg	,'04'	 ,'Filial Ate:?' ,'Filial Ate:?' ,'Filial Ate:?' ,'MV_CH4'	,'C'	,6			,0			,2			,'G'	,''		 ,'MV_PAR04',''		 ,''		,''			,''		 ,''		,''		 ,''		,''			,''		 ,''		,''		 ,''		,''			,''		 ,''	  ,''		,''			,''			,''		 ,''	  ,''		,''			,''			,''		 ,'GTBFIL'	,''		,''			,''		,''			,''		 } )

//
// Atualizando dicionário
//
dbSelectArea( "SX1" )
SX1->( dbSetOrder( 1 ) )

For nI := 1 To Len( aDados )
	If !SX1->( dbSeek( PadR( aDados[nI][1], nTam1 ) + PadR( aDados[nI][2], nTam2 ) ) )
		RecLock( "SX1", .T. )
		For nJ := 1 To Len( aDados[nI] )
			If aScan( aStruDic, { |aX| PadR( aX[1], 10 ) == PadR( aEstrut[nJ], 10 ) } ) > 0
				SX1->( FieldPut( FieldPos( aEstrut[nJ] ), aDados[nI][nJ] ) )
			EndIf
		Next nJ
		MsUnLock()
	EndIf
Next nI

RestArea( aAreaDic )
RestArea( aArea )

Return