#include "protheus.ch"
#include "fileio.ch"
#Include "rwmake.ch"
/*
Funcao      : GP410CRP
Parametros  : 
Retorno     : lRet
Objetivos   : Ponto de entrada utilizado para criptografia de arquivo de envio. Assim foi colocado o P.E. no final do processamento do arquivo
TDN			: http://tdn.totvs.com/pages/releaseview.action;jsessionid=ECC46BA2D21A5F6609A38CDF4B1E3864?pageId=6079127
Autor       : Jean Victor Rocha
Data/Hora   : 27/01/2014
Módulo      : Gestão de Pessoal
Cliente		: 
*/
*----------------------*
User Function GP410CRP()
*----------------------*
Local lRet		:= .T.
Local cLinha	:= ""
Local cArqRdm	:= ""

//Local cFileNew := FILE(LEFT(mv_par22,RAt( ".", mv_par22 )-1)+"_1024"+SubSTR(mv_par22,RAt( ".", mv_par22 ),Len(mv_par22)))
Local cNewDir	:= "c:\CNAB1024\"
Local cNewArq	:= DTOS(dDataBase)+".TXT"

Private nHdl	:=0

If cEmpAnt $ "DT/TP/49" .And. UPPER(ALLTRIM(mv_par21)) == "K"+AllTrim(cEmpAnt)+"745.CPE"
	FT_FUse(mv_par22)
	FT_FGOTOP()
	
	While !FT_FEof()
		cLinha := FT_FReadln() 
		If !EMPTY(cLinha)
			If  LEN(cLinha)>100
				cArqRdm += cLinha + SPACE(1024-LEN(cLinha)) + CHR(13)+CHR(10)
			Else
				cArqRdm += cLinha + CHR(13)+CHR(10)
			EndIf
		EndIf
		FT_FSkip()	
	EndDo

	If !ExistDir(cNewDir)
		MakeDir(cNewDir)
	EndIf 

	If File(cNewDir+cNewArq)
		FErase(cNewDir+cNewArq)	
	EndIf
	nHdl := FCREATE(cNewDir+cNewArq)
	If nHdl==-1
		ALERT("Erro no ajuste do arquivo","HLB BRASIL")
		Return
	Endif
	FSEEK(nHdl,0)//Posiciona no inicio do arquivo

	FWRITE(nHdl , cArqRdm)
	
	FCLOSE(nHdl)// Fecha o arquivo
	If File(cNewDir+cNewArq)
		Alert("Arquivo Gerado na pasta: '"+cNewDir+cNewArq+"'")	
	EndIf 

Endif

Return lRet