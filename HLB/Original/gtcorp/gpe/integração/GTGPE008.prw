#include "protheus.ch"
#INCLUDE "TOPCONN.CH" 

/*
Funcao      : GTGPE008
Parametros  : 
Retorno     : 
Objetivos   : Integração de lançamentos mensais de co participação plano de saude. Sulamerica
Autor       : Renato Rezende
Data/Hora   : 09/09/2014
TDN         : 
*/
*----------------------*
User Function GTGPE008()
*----------------------*
Local cPasta
Local nOpca := 0

Local aSays:={ }, aButtons:= { }	//<== arrays locais de preferencia

Private cPerg		:= "GTGPE008"
Private cProcesso	:= ""			// Variavel utilizada na funcao gpRCHFiltro() Consulta Padrao - 1 = Periodos Abertos
Private cCond		:= "1"			// Variavel utilizada na funcao gpRCHFiltro() Consulta Padrao - 1 = Periodos Abertos

Private lAbortPrint := .F.
Private cTabela		:= ""              
Private cPrefTab	:= ""

AjustaSX1()
cCadastro := "Importacao de Arquivo Plano Saude."

AADD(aSays,"Esta rotina importa valores para os arquivos de Movimentacao Mensal," )
AADD(aSays,"planos de saude CO participação.     " )

AADD(aButtons, { 5,.T.,{|| Pergunte("GTGPE008",.T. ) } } )
AADD(aButtons, { 1,.T.,{|o| nOpca := 1,IF(GTGPEOK(),FechaBatch(),nOpca:=0)  }} )
AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )

FormBatch( cCadastro, aSays, aButtons )

If nOpca == 1                      
	 Processa({|lEnd| GTGPE008MAIN(),"Importacao de Arquivo Plano Saude."})
EndIf

Return

*----------------------------*
Static Function GTGPE008MAIN()
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
Local nPos 		:= 0
Local nValor 	:= 0
Local nR		:= 0

Local cLinha 	:= ""
Local cVldCpf 	:= ""
Local cQuery	:= "" 
Local cIndex	:= ""
Local cSvFilAnt := cFilAnt //Salva a Filial Anterior 
Local cSvEmpAnt := cEmpAnt //Salva a Empresa Anterior 
Local cSvArqTab := cArqTab //Salva os arquivos de //trabalho 
Local cModo //Modo de acesso do arquivo aberto //"E" ou "C"

Local aLinha 	:= {}
Local aInfos 	:= {}
Local aLog 		:= {}
Local aArea 	:= GetArea() 
Local aAreaSRA 	:= SRA->(GetArea()) 
Local aAreaSRC 	:= SRC->(GetArea()) 

FT_FUse(cArquivo) // Abre o arquivo
FT_FGOTO(nPos)      // Posiciona no inicio do arquivo

While !FT_FEof()
	nValor := 0
   	cLinha := FT_FReadln()        // Le a linha
 	aLinha := separa(UPPER(cLinha),";")  // Sepera para vetor 
    If Len(aLinha) == 5 .and. !EMPTY(aLinha[5])//validação do tamanho da estrutura do arquivo.
	    If aLinha[1] <> "DEPENDENTE" .and. !EMPTY(ALLTRIM(aLinha[5])) .and. !EMPTY(ALLTRIM(aLinha[2]))
	    
            //Validando se é o mesmo titular
            If !(cVldCpf) == aLinha[2]

		   		nValor += VAL(Substr(aLinha[3],0,len(aLinha[3])-2)+"."+Right(aLinha[3],2))//VALOR
		   		aAdd(aInfos, {aLinha[2]/*CPF*/, nValor/*VALORES*/, aLinha[5]/*CNPJ*/ })             
				cVldCpf := aLinha[2]
			Else
				nValor += VAL(Substr(aLinha[3],0,len(aLinha[3])-2)+"."+Right(aLinha[3],2))//VALOR
				nPos:=Ascan(aInfos,{ |x| ALLTRIM(x[1]) == ALLTRIM(aLinha[2])})
				aInfos[nPos][2] += nValor
				cVldCpf := aLinha[2]
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
				aAdd(aLog, {1,aLinha[nTemInfo],"- CPF '"+aLinha[nTemInfo]+"'."+"Emp.:"+aInfos[i][5] })
			EndIf
		Else
			Exit
		EndIf		
	EndIf
	FT_FSkip() // Proxima linha
Enddo
FT_FUse() // Fecha o arquivo                     

DbSelectArea("SM0")
//Criando Index temporario
cIndex	:=CriaTrab(Nil,.F.)
IndRegua("SM0",cIndex,"M0_CGC")
SM0->(DbSetIndex(cIndex+OrdBagExt()))
SM0->(DbSetOrder(1))

For nR:=1 to Len(aInfos)
	
	If SM0->(DbSeek(aInfos[nR][3]))//CNPJ
		//Consulta no SIGAMAT para adicionar empresa+filial no array aInfos
		//Empresa Z5 possui o mesmo CNPJ da Z4.
		If SM0->M0_CODIGO == "Z5"
			aAdd(aInfos[nR],"01")//[4]
			aAdd(aInfos[nR],"Z4")//[5]
		Else
			aAdd(aInfos[nR],SM0->M0_CODFIL)//[4]
			aAdd(aInfos[nR],SM0->M0_CODIGO)//[5]
		EndIf
	EndIf                                   
Next nR

//Limpando index temporário
FErase(cIndex+OrdBagExt())

For i:=1 to Len(aInfos)
	If aInfos[i][2] <> 0
        //Abertura da SRA de outra empresa
		EmpOpenFile("SRA","SRA",5,.T.,aInfos[i][5],@cModo)
		
		//If SRA->(DbSeek(xFilial("SRA")+aInfos[i][1] ))//RA_FILIAL+RA_CIC
		If SRA->(DbSeek(aInfos[i][4]+ PadL(aInfos[i][1],RETSX3("RA_CIC","TAM"), "0") ))//RA_FILIAL+RA_CIC
			While SRA->(!EOF()) .and. SRA->RA_CIC == PadL(aInfos[i][1],RETSX3("RA_CIC", "TAM"), "0")
				If EMPTY(SRA->RA_DEMISSA)
					//Abertura da tabela SRC de outra empresa
					EmpOpenFile("SRC","SRC",1,.T.,aInfos[i][5],@cModo)
					lGrava := SRC->(DbSeek(aInfos[i][4]+SRA->RA_MAT+"681"))
					SRC->(RecLock("SRC",!lGrava))
					SRC->RC_FILIAL	:= aInfos[i][4]
					SRC->RC_MAT		:= SRA->RA_MAT
					SRC->RC_PD		:= "681"
					SRC->RC_TIPO1	:= "V"
					SRC->RC_VALOR	:= aInfos[i][2]
					SRC->RC_DATA	:= dData
					SRC->RC_CC		:= SRA->RA_CC
					SRC->RC_TIPO2	:= "I"
					SRC->(MsUnlock())
					If lGrava
						aAdd(aLog, {5,aLinha[Len(aLinha)],"- CPF '"+PadL(aInfos[i][1],RETSX3("RA_CIC", "TAM"), "0")+ "', MAT "+SRA->RA_MAT+", valor '"+ALLTRIM(STR(aInfos[i][2]))+"', CC '"+ALLTRIM(SRA->RA_CC)+"'."+"Emp.:"+aInfos[i][5]  })
					Else
						aAdd(aLog, {4,aLinha[Len(aLinha)],"- CPF '"+PadL(aInfos[i][1],RETSX3("RA_CIC", "TAM"), "0")+ "', MAT "+SRA->RA_MAT+", valor '"+ALLTRIM(STR(aInfos[i][2]))+"', CC '"+ALLTRIM(SRA->RA_CC)+"'."+"Emp.:"+aInfos[i][5] })
					EndIf
				EndIf
				SRA->(DbSkip())
			EndDo
		Else
			aAdd(aLog, {2,aLinha[Len(aLinha)],"- CPF '"+PadL(aInfos[i][1],RETSX3("RA_CIC", "TAM"), "0")+"'."+"Emp.:"+aInfos[i][5] })
		EndIf
		SRA->(dbCloseArea())
		SRC->(dbCloseArea())
		//Restaura os Dados de Entrada ( Ambiente ) 
		cFilAnt := cSvFilAnt 
		cEmpAnt := cSvEmpAnt 
		cArqTab := cSvArqTab 
		ChkFile("SRA") //Reabre o SRA da empresa atual
		ChkFile("SRC") //Reabre o SRC da empresa atual

		//Restaura os ponteiros das Tabelas 
		RestArea(aAreaSRC)
		RestArea(aAreaSRA) 
		RestArea(aArea)
	Else
		aAdd(aLog, {3,aLinha[Len(aLinha)],"- CPF '"+PadL(aInfos[i][1],RETSX3("RA_CIC", "TAM"), "0")+"'."+"Emp.:"+aInfos[i][5] })
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