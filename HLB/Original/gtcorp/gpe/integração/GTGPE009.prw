#INCLUDE "FIVEWIN.CH"
#include "rwmake.ch"
#include "protheus.ch"
#INCLUDE "TOPCONN.CH"  

/*
Funcao      : GTGPE009
Parametros  : 
Retorno     : 
Objetivos   : Integração de lançamentos mensais de Odonto. Sulamerica
Autor       : Renato Rezende
Data/Hora   : 23/10/2014
TDN         : 
*/
*-------------------------*
 User Function GTGPE009()
*-------------------------*
Local cPasta
Local nOpca := 0

Local aSays:={ }, aButtons:= { }

Private cPerg		:= "GTGPE009"

Private lAbortPrint := .F.

Private aExcel := {}

AjustaSX1()
cCadastro := "Importacao de Arquivo Odontologico."

AADD(aSays,"Esta rotina importa valores para os arquivos de Movimentacao Mensal," )
AADD(aSays,"Planos de Odonto.     " )

AADD(aButtons, { 5,.T.,{|| Pergunte("GTGPE009",.T. ) } } )
AADD(aButtons, { 1,.T.,{|o| nOpca := 1,IF(GTGPEOK(),FechaBatch(),nOpca:=0)  }} )
AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )

FormBatch( cCadastro, aSays, aButtons )

If nOpca == 1                      
	 Processa({|lEnd| GTGPE001MAIN(),"Importacao de Arquivo Plano Odonto."})
EndIf

Return( Nil )

*----------------------------*
Static Function GTGPE001MAIN()
*----------------------------*
Private cLog := ""

Pergunte(cPerg,.F.)
cPasta		:= AllTrim(mv_par01)//Nome da Pasta
dData		:= mv_par02			//Data

If !File(cPasta)
	Alert("Diretorio informado não encontrado!")
	Return .T.
EndIf

aArquivos := DIRECTORY(cPasta+"\*.CSV","D")
       
If Len(aArquivos) == 0
	cLog += "* Arquivos '.CSV' na pasta '"+cPasta+"' não encontrados, favor verificar!"+CHR(10)+CHR(13)
EndIf

PROCREGUA( len(aArquivos) )

For j:=1 to len(aArquivos)
	cLog += CHR(10)+CHR(13)+"== Arquivo : "+aArquivos[j][1]+" "+REPLICATE("=",27-LEN(aArquivos[j][1]))+CHR(10)+CHR(13)
	INCPROC(ALLTRIM(STR(j))+"\"+ALLTRIM(STR(len(aArquivos)))+" - Processando arquivo '"+aArquivos[j][1]+"'. Aguarde...")
	ProcArq(cPasta+"\"+aArquivos[j][1])
Next j

cLog := "Log de processamento da integração de Odonto:"+ CHR(10) + CHR(13) +;
		"==============================================================="+CHR(10)+CHR(13)+ cLog


EECVIEW(cLog)

Return .t.

*-------------------------------*
Static Function ProcArq(cArquivo)
*-------------------------------*
Local cLinha	:= ""
Local cCpf		:= ""
Local cValor	:= ""

Local aLinha	:= {}
Local aInfos	:= {}
Local aLog		:= {}

Local nPos		:= 0
Local nValor	:= 0

Local lAchou	:= .F. 

//	1           2             3            4                            5         
//			|VALOR		|CPF			|							|PARENTESCO	
//			|			|				|							|			
//			|			|				|							|			

FT_FUse(cArquivo) // Abre o arquivo
FT_FGOTO(nPos)    // Posiciona no inicio do arquivo

While !FT_FEof()
	nValor	:= 0
	cCpf	:= ""
	lAchou	:= .F.
   	cLinha	:= FT_FReadln()// Le a linha
 	aLinha	:= separa(UPPER(cLinha),";")  // Sepera para vetor 
    If Alltrim(aLinha[5]) == "TITULAR" .and. !EMPTY(ALLTRIM(aLinha[3]))

		cCpf:= Strtran(Alltrim(aLinha[3]),".")//Retira os pontos
		cCpf:= Strtran(Alltrim(cCpf),"-")//Retira os traços

		//Buscando Valor do Plano
		FT_FSkip() // Proxima linha
		//Busca a linha em branco que contem apenas o valor total do plano
		While !FT_FEof() .AND. !lAchou
			cLinha	:= FT_FReadln()
	 		aLinha	:= separa(UPPER(cLinha),";")
	 		If Empty(Alltrim(aLinha[5]))
	 			cValor	:= Strtran(Alltrim(aLinha[2]),"R$")//Retira o R$
	 			nValor	:= VAL(Substr(cValor,0,len(cValor)-3)+"."+Right(cValor,2))
	 			lAchou	:= .T.
	 		EndIf
	 		FT_FSkip()// Proxima linha
		EndDo                                             

		aAdd(aInfos, {cCpf, nValor})
	EndIf
	FT_FSkip() // Proxima linha
Enddo
FT_FUse() // Fecha o arquivo                     

SRA->(DbSetOrder(5))
For i:=1 to Len(aInfos)
	If aInfos[i][2] <> 0
		//If SRA->(DbSeek(xFilial("SRA")+aInfos[i][1] ))//RA_FILIAL+RA_CIC
		If SRA->(DbSeek(xFilial("SRA")+ PadL(aInfos[i][1],RETSX3("RA_CIC","TAM"), "0") ))//RA_FILIAL+RA_CIC
			While SRA->(!EOF()) .and. SRA->RA_CIC == PadL(aInfos[i][1],RETSX3("RA_CIC", "TAM"), "0")
				If EMPTY(SRA->RA_DEMISSA)
					lGrava := SRC->(DbSeek(xFilial("SRC")+SRA->RA_MAT+"670"))
					SRC->(RecLock("SRC",!lGrava))
					SRC->RC_FILIAL	:= xFilial("SRC")
					SRC->RC_MAT		:= SRA->RA_MAT
					SRC->RC_PD		:= "670"
					SRC->RC_TIPO1	:= "V"
					SRC->RC_VALOR	:= aInfos[i][2]
					SRC->RC_DATA	:= dData
					SRC->RC_CC		:= SRA->RA_CC
					SRC->RC_TIPO2	:= "I"
					SRC->(MsUnlock())
					If lGrava
						aAdd(aLog, {5,aLinha[Len(aLinha)],"- CPF '"+PadL(aInfos[i][1],RETSX3("RA_CIC", "TAM"), "0")+ "', MAT "+SRA->RA_MAT+", valor '"+ALLTRIM(STR(aInfos[i][2]))+"', CC '"+ALLTRIM(SRA->RA_CC)+"'."  })
					Else
						aAdd(aLog, {4,aLinha[Len(aLinha)],"- CPF '"+PadL(aInfos[i][1],RETSX3("RA_CIC", "TAM"), "0")+ "', MAT "+SRA->RA_MAT+", valor '"+ALLTRIM(STR(aInfos[i][2]))+"', CC '"+ALLTRIM(SRA->RA_CC)+"'." })
					EndIf
					aAdd(aExcel, {cEmpAnt,cFilAnt,SRA->RA_MAT,SRA->RA_NOME,PadL(aInfos[i][1],RETSX3("RA_CIC", "TAM"), "0"),ALLTRIM(STR(aInfos[i][2])) })
				EndIf
				SRA->(DbSkip())
			EndDo
		Else
			aAdd(aLog, {2,aLinha[Len(aLinha)],"- CPF '"+PadL(aInfos[i][1],RETSX3("RA_CIC", "TAM"), "0")+"'." })
		EndIf
	Else
		aAdd(aLog, {3,aLinha[Len(aLinha)],"- CPF '"+PadL(aInfos[i][1],RETSX3("RA_CIC", "TAM"), "0")+"'." })
	EndIf
Next i

aTit := {"-- Erro de estrutura -------------------",;
	     "-- Funcionario Sem Cadastro na empresa -",;
		 "-- Sem lançamentos ---------------------",;
		 "-- Inclusão ----------------------------",;
		 "-- Atualização -------------------------";
		}

nAux := 0
aSort(aLog,,, { |x, y| x[1] < y[1] })
For i:=1 to Len(aLog)
	If nAux <> aLog[i][1]
		cLog += CHR(10)+CHR(13)+aTit[aLog[i][1]]+CHR(10)+CHR(13)
		nAux := aLog[i][1]
    EndIf
    cLog += aLog[i][3]+CHR(10)+CHR(13)
Next i

Return .T.

*-------------------------*
STATIC Function AjustaSx1()
*-------------------------*
Local aRegs	   		:= {}

PUTSX1( cPerg, "01","Arquivo ?(.CSV)" ,"Arquivo ?(.CSV)","Arquivo ?(.CSV)"	,"mv_ch1","C"   , 30     ,0      ,0     ,"G", "NaoVazio()","","","", "mv_par01", " "  		 , "     " , "      " , "c:/" ,"    "		,"     ","      ","     "  ,"   ", "  " , "  " ,"     ","     ","   ", ""     ," ",   	{"Nome do Arquivo para importação!"}  ,     {},         {},        "")
PUTSX1( cPerg, "02","Data ? " ,"Data ?","Data ?"    	   					,"mv_ch2","D"   , 8      ,0      ,0     ,"G", "NaoVazio()","","","", "mv_par02", " "  	     , "     " , "      " , ""    ,"    "		,"     ","      ","     "  ,"   ", "  " , "  " ,"     ","     ","   ", ""     ," ",   	{"Data em que sera lançada."}  ,     {},         {},        ""      )

Return

*-----------------------*
Static Function GTGPEOK()
*-----------------------*
Local cMsg := "Confirma a configuração dos parametros?"
Return (MsgYesNo(cMsg,"Atenção!"))

*------------------------------------*
Static Function RETSX3(cCampo, cFuncao)
*------------------------------------*
Local aOrd := SaveOrd({"SX3"})
Local xRet

SX3->(DBSETORDER(2))
If SX3->(DBSEEK(cCampo))   
	Do Case
		Case cFuncao == "TAM"
			xRet := SX3->X3_TAMANHO
		Case cFuncao == "DEC"		
			xRet := SX3->X3_DECIMAL
		Case cFuncao == "TIP"      
			xRet := SX3->X3_TIPO
		Case cFuncao == "PIC" 
			xRet := SX3->X3_PICTURE
		Case cFuncao == "TIT"
			xRet := SX3->X3_TITULO
	EndCase
EndIf
RestOrd(aOrd)
Return xRet