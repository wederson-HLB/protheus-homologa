#INCLUDE "FIVEWIN.CH"
#include "rwmake.ch"
#include "protheus.ch"
#INCLUDE "TOPCONN.CH"  

/*
Funcao      : GTGPE001
Parametros  : 
Retorno     : 
Objetivos   : Integração de lançamentos mensais de co participação plano de saude. Porto Seguro
Autor       : Jean Victor Rocha
Data/Hora   : 08/06/2012
TDN         : 
*/
*----------------------*
User Function GTGPE001()
*----------------------*
Local cPasta
Local nOpca := 0

Local aSays:={ }, aButtons:= { }	//<== arrays locais de preferencia

Private cPerg		:= "GTGPE001"
Private cProcesso	:= ""			// Variavel utilizada na funcao gpRCHFiltro() Consulta Padrao - 1 = Periodos Abertos
Private cCond		:= "1"			// Variavel utilizada na funcao gpRCHFiltro() Consulta Padrao - 1 = Periodos Abertos

Private lAbortPrint := .F.
Private cTabela		:= ""              
Private cPrefTab	:= ""                                                                                              

AjustaSX1()
cCadastro := "Importacao de Arquivo Plano Saude."

AADD(aSays,"Esta rotina importa valores para os arquivos de Movimentacao Mensal," )
AADD(aSays,"planos de saude CO participação.     " )

AADD(aButtons, { 5,.T.,{|| Pergunte("GTGPE001",.T. ) } } )
AADD(aButtons, { 1,.T.,{|o| nOpca := 1,IF(GTGPEOK(),FechaBatch(),nOpca:=0)  }} )
AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )

FormBatch( cCadastro, aSays, aButtons )

If nOpca == 1                      
	 Processa({|lEnd| GTGPE001MAIN(),"Importacao de Arquivo Plano Saude."})
EndIf

Return( Nil )

*----------------------------*
Static Function GTGPE001MAIN()
*----------------------------*
Private cLog := ""

Pergunte(cPerg,.F.)
cPasta		:= AllTrim(mv_par01)	//Nome da Pasta
dData			:= mv_par02				//Data
cCodigo			:= "SRC"

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

cLog := "Log de processamento da integração:"+ CHR(10) + CHR(13) +;
		"==============================================================="+CHR(10)+CHR(13)+ cLog

EECVIEW(cLog)


Return .t.

*--------------------------------*
Static Function ProcArq(cArquivo)
*--------------------------------*
Local cLinha := ""
Local aLinha := {}
Local aInfos := {}
Local nPos := 0
Local nValor := 0
Local aLog := {}

FT_FUse(cArquivo) // Abre o arquivo
FT_FGOTO(nPos)      // Posiciona no inicio do arquivo

While !FT_FEof()
	nValor := 0
   	cLinha := FT_FReadln()        // Le a linha
 	aLinha := separa(UPPER(cLinha),";")  // Sepera para vetor 
    If Len(aLinha) == 25 .and. !EMPTY(aLinha[25])//validação do tamanho da estrutura do arquivo.
	    If aLinha[1] <> "REGISTRO" .and. !EMPTY(ALLTRIM(aLinha[25])) .and. VAL(aLinha[1]) == 3
			nValor += VAL(Substr(aLinha[17],0,len(aLinha[17])-2)+"."+Right(aLinha[17],2))//VALOR CONSULTA
			nValor += VAL(Substr(aLinha[19],0,len(aLinha[19])-2)+"."+Right(aLinha[19],2))//VALOR EXAME
			nValor += VAL(Substr(aLinha[21],0,len(aLinha[21])-2)+"."+Right(aLinha[21],2))//VALOR PSOCORRO
			//O funcionario não tem Coparticipação nos itens abaixo
			//nValor += VAL(Substr(aLinha[23],0,len(aLinha[23])-2)+"."+Right(aLinha[23],2))//VALOR INTERNACAO
			//nValor += VAL(Substr(aLinha[24],0,len(aLinha[24])-2)+"."+Right(aLinha[24],2))//DESPESAS NAO COBERTAS

			If (nPos:=Ascan(aInfos,{ |x| ALLTRIM(x[1]) == ALLTRIM(aLinha[25])}) ) == 0
				aAdd(aInfos, {aLinha[25]/*CPF*/, nValor/*VALORES*/  })	
			Else
				aInfos[nPos][2] += nValor
			EndIf                       
		EndIf
	Else
		nTemInfo := 0
		Begin Sequence
			For i:=Len(aLinha) to 1  Step -1
				If !EMPTY(aLinha[i])
					nTemInfo := i
					Break
				EndIf
			Next i
		End Sequence
		If nTemInfo <> 0 
			If aScan(aLog, {|x| x[2] == aLinha[nTemInfo]}) == 0
				aAdd(aLog, {1,aLinha[nTemInfo],"- CPF '"+aLinha[nTemInfo]+"'." })
			EndIf
		Else
			Exit
		EndIf		
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
					lGrava := SRC->(DbSeek(xFilial("SRC")+SRA->RA_MAT+"681"))
					SRC->(RecLock("SRC",!lGrava))
					SRC->RC_FILIAL	:= xFilial("SRC")
					SRC->RC_MAT		:= SRA->RA_MAT
					SRC->RC_PD		:= "681"
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