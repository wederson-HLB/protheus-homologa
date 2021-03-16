#include "rwmake.ch"

/*
Funcao      : CYYFAT03 
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Vinculo de TES x Empresas  
Autor       : 
Data/Hora   : 
Obs         : Vinculo da SZ2 com SF4
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 18/07/2012
Revisão     : Eduardo C. Romanini
Data/Hora   : 09/01/2013
Obs         :
Módulo      : Livros Fiscais.
Cliente     : Todas	
*/

*-----------------------*  
 USER FUNCTION CYYFAT03
*-----------------------* 
 
private aCampos  := {}
//hfpok
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria arquivo de trabalho para processar pela sequencia.      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aCampos,{ "TR_MARCA"	  ,"C",02,0 } )
AADD(aCampos,{ "TR_EMPRESA" ,"C",20,0 } )
AADD(aCampos,{ "TR_FILIA"  ,"C",20,0 } )
AADD(aCampos,{ "TR_TES"	  ,"C",03,0 } )
AADD(aCampos,{ "TR_CODEMP"  ,"C",04,0 } )

cNomTrb  := CriaTrab(aCampos)
cNomTrb1 := Subs(cNomTrb,1,7)+"A"

//dbSelectArea(0)
dbUseArea( .T.,,cNomTrb,"TRB",.F. )
IndRegua("TRB",cNomTrb1,"TRB->TR_CODEMP",,,"Criando Arquivo Trabalho...")
dbSelectArea("TRB")

cMarca := GetMark()

Processa({|| SZ22TRB() },"Processando SZ2 para TRB...")

//Private aRotina :={}
PRIVATE aRotina   := { { "Gravar",	"U_GRAVATE"  , 0 , 3} }
PRIVATE cCadastro := "Compartilhamento Empresas"
PRIVATE aCPO:={}

AADD(aCpo,{ "TR_MARCA"   ,,""        } )
AADD(aCpo,{ "TR_EMPRESA" ,,"Empresa" } )
AADD(aCpo,{ "TR_FILIA"   ,,"Filial"  } )
AADD(aCpo,{ "TR_TES"	 ,,"TES"     } )
AADD(aCpo,{ "TR_CODEMP"  ,,"CodEmp"  } )


DBSELECTAREA("TRB")
IndRegua("TRB",cNomTrb1,"TR_EMPRESA+TR_FILIA",,,"Criando Arquivo Trabalho...")
dbgotop()

MarkBrow("TRB","TR_MARCA",,aCpo,,cMarca)

DBSELECTAREA("TRB")
dbclosearea()
RETURN

*----------------------* 
 USER FUNCTION GRAVATE
*----------------------* 

Processa({|| SZ2_A() },"Gravando...")

RETURN

*-------------------------* 
 STATIC FUNCTION SZ22TRB()
*-------------------------* 
SM0->(DbGoTop())
While SM0->(!EOF())

	IncProc( "Carregando Empresa: " + AllTrim(SM0->M0_NOME))	

	TRB->(RecLock("TRB",.T.))

	TRB->TR_EMPRESA :=SM0->M0_NOME
	TRB->TR_FILIA	:=SM0->M0_FILIAL
	TRB->TR_CODEMP	:=SM0->M0_CODIGO+SM0->M0_CODFIL			
	TRB->TR_TES     :=_cTES
	
	SZ2->(DbSetOrder(3))
	If SZ2->(DbSeek(xFilial("SZ2")+AllTrim(SM0->M0_CODIGO)+Alltrim(SM0->M0_CODFIL)+Alltrim(_cTES)))
		If !Empty(SZ2->Z2_MARK)
			TRB->TR_MARCA := cMarca
		EndIf
	EndIf
	
	TRB->(MsUnlock())

	SM0->(DbSkip())
EndDo

*-------------------------* 
  Static function SZ2_A()
*-------------------------* 
TRB->(DbGoTop())
While TRB->(!EOF())

	IncProc("Gravando Empresa: " + AllTrim(TRB->TR_EMPRESA))

	//Verifica se foi marcado
	If !Empty(TRB->TR_MARCA)

		SZ2->(DbSetOrder(3))
		If SZ2->(DbSeek(xFilial("SZ2")+AllTrim(TRB->TR_CODEMP)+Alltrim(_cTES)))
			SZ2->(RecLock("SZ2",.F.))			
		Else
			SZ2->(RecLock("SZ2",.T.))							
		
			SZ2->Z2_FILIAL := xFilial("SZ2")
			SZ2->Z2_EMPRESA:= TRB->TR_CODEMP
		EndIf
	
		SZ2->Z2_MARK   := cMARCA
		SZ2->Z2_TES    := _cTES
        
		SF4->(DbSetOrder(1))
		If SF4->(DbSeek(xFilial("SF4")+_cTES))
			SZ2->Z2_DESCRI := SF4->F4_TEXTO
			SZ2->Z2_CFOP   := SF4->F4_CF
			SZ2->Z2_FINALID:= SF4->F4_FINALID
		EndIf
		SZ2->(MsUnlock())
	Else
		
		SZ2->(DbSetOrder(3))
		If SZ2->(DbSeek(xFilial("SZ2")+AllTrim(TRB->TR_CODEMP)+Alltrim(_cTES)))
			SZ2->(RecLock("SZ2",.F.))			
			
			SZ2->(DbDelete())
			
			SZ2->(MsUnlock())
	
		Endif
	
	EndIf

	TRB->(DbSkip())
EndDo	

Return