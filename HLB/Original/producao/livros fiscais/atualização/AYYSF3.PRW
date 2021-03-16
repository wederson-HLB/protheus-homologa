#include "rwmake.ch"
#Include "colors.ch"

/*
Funcao      : AYYSF3 
Parametros  : .T.
Retorno     : Nil
Objetivos   : função Alterar | A função alterar altera apenas o campo de Observações (F3_OBSERV) quando a data de fechamento fiscal (MV_DATAFIS) estiver aberta.
			: A função excluir exclui apenas as notas fiscais existentes no livro fiscal e que esteja excluido da NF de entrada (SF1) ou da NF de Saida (SF2)	conforme o campo F3_DTCANC e quando a data de fechamento fiscal (MV_DATAFIS) estiver aberta.
Autor       : José Ferreira 
TDN         : 
Revisão     : Matheus Massarotto
Data/Hora   : 03/06/2006
Módulo      : Livros Fiscal.
*/

*--------------------*
User function AYYSF3()
*--------------------*
cExcL:= .F.
dEntSf3:= ""
cCampo:= SPACE(30)
cDtFis:= getMv("MV_DATAFIS")
cCadastro:= "Livro Fiscal"

_aCores  := {{"F3_ENTRADA >=cDtFis .AND. Alltrim(DTOS(F3_DTCANC)) = ''","ENABLE"    },; 
	          {"F3_ENTRADA >=cDtFis .AND. Alltrim(DTOS(F3_DTCANC)) <> ''" ,"BR_AMARELO"},;
	          {"F3_ENTRADA < cDtFis","DISABLE"   }}	


PRIVATE aRotina := { { "Pesquisar" , "AxPesqui"   , 0 , 1},; 
							{ "Visualizar", "AxVisual"   , 0 , 2},; 
							{ "Alterar"   , "U_MontTela" , 0 , 3},; 
							{ "Legenda"   , "U_fLegend1" , 0 , 4},;
							{ "Excluir"   , "U_ExcLixo" , 0 , 5}}


dbSelectArea("SF3")
dbSetOrder(1)
mBrowse( 6, 1,22,75,"SF3",,,,,,_aCores)


Return .T.   

*----------------------*
User function MontTela()
*----------------------*
	
if F3_ENTRADA >=cDtFis
	cCampo:= SPACE(30)  
	dEntSf3:= SF3->F3_ENTRADA
	@ 200,001 To 380,520 Dialog oLeT Title "Altera observação"
	@ 001,002 To 089,259 
	@ 007,005 Say "Nota/Serie:         "+SF3->F3_NFISCAL+"/"+SF3->F3_SERIE COLOR CLR_HRED, CLR_WHITE 
	@ 017,005 Say "Cliente/Fornecedor: "+SF3->F3_CLIEFOR COLOR CLR_HRED, CLR_WHITE 
	@ 027,005 Say "Data:               " COLOR CLR_HRED, CLR_WHITE 
	@ 027,026 Say dtoc(dEntSf3) COLOR CLR_HRED, CLR_WHITE 
	@ 037,005 Say "Observação Atual:   "+SF3->F3_OBSERV COLOR CLR_HRED, CLR_WHITE 
	@ 047,005 Say "Observação" COLOR CLR_HBLUE, CLR_WHITE 
	@ 057,005 Get cCampo Size 150,150    
	@ 070,190 BmpButton Type 01 Action AltCamp()
	@ 070,218 BmpButton Type 02 Action Close(oLeT)
	Activate Dialog oLeT Centered
else
	Alert("Esta nota não pode ser alterado pois a data fiscal está fechada!")
endif

Return .t. 

STATIC FUNCTION AltCamp()

	RecLock("SF3",.F.)
	Replace SF3->F3_OBSERV With cCampo
	MsUnlock()
	Close(oLeT)
	
return .t.

USER function ExcLixo()
cExcL:= .F.
if F3_ENTRADA >=cDtFis 
	if Alltrim(dtos(SF3->F3_DTCANC)) <> '' 
		IF MSGBOX("Esta acao ira excluir este o registro no Livro fiscal!"+CHR(13)+CHR(10)+"Confirma ?","Confirmação Exclui registro do livro fiscal","YESNO")
			RecLock("SF3",.F.)
			dbDelete()
			MsUnlock()
		endif	
	ELSE
		Alert("Essa nota não pode ser excluida pois não se trata de Lixo!")
	ENDIF
else
	Alert("Esta nota não pode ser excluida pois a data fiscal está fechada!")
endif

return (cExcL)


//----------------------------------------------------------Legenda

User Function fLegend1()
BrwLegenda(cCadastro,"Legenda",{{"ENABLE","Dt.Fiscal Aberta"},;
		                          {"BR_AMARELO","NF Entrada/Saida excluida"},;
		                          {"DISABLE","Dt.Fiscal Fechada"}})
Return(.T.)



