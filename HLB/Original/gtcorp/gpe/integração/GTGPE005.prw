#INCLUDE "FIVEWIN.CH"
#include "rwmake.ch"
#include "protheus.ch"
#INCLUDE "TOPCONN.CH"  

/*
Funcao      : GTGPE005
Parametros  : 
Retorno     : 
Objetivos   : Integração de lançamentos mensais de Odonto. Porto Seguro
Autor       : Jean Victor Rocha
Data/Hora   : 04/03/2013
TDN         : 
*/
*----------------------*
User Function GTGPE005()
*----------------------*
Local cPasta
Local nOpca := 0

Local aSays:={ }, aButtons:= { }

Private cPerg		:= "GTGPE001"

Private lAbortPrint := .F.

Private aExcel := {}

cCadastro := "Importacao de Arquivo Plano Saude."

AADD(aSays,"Esta rotina importa valores para os arquivos de Movimentacao Mensal," )
AADD(aSays,"Planos de Odonto.     " )

AADD(aButtons, { 5,.T.,{|| Pergunte("GTGPE001",.T. ) } } )
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


If MSGYESNO("Deseja gerar log em Excel?")
	GeraExcel()
Else
	EECVIEW(cLog)
EndIf

Return .t.

*-------------------------------*
Static Function ProcArq(cArquivo)
*-------------------------------*
Local cLinha := ""
Local aLinha := {}
Local aInfos := {}
Local nPos := 0
Local nValor := 0
Local aLog := {}

//	1           2             3            4                            5           6               7                         8            9       10           11          12            13              14               15             16            17                  18             19           20           21          22  23         24                25
//REGISTRO	|SEGURO		|CODIGO PLANO	|PLANO						|MATRICULA	|CENTRO CUSTO	|NOME SEGURADO			|NR DEPENDENTE	|IDADE	|PARENTESCO	|SITUACAO	|DATA ADESAO|DATA EXCLUSAO	|VALOR PREMIO	|VALOR PRORATA	|QT ORTODONTIA	|VALOR ORTODONTIA	|QT PROTESE	|VALOR PROTESE	|QT BASICA	|VALOR BASICA	|	|	|DESPESAS NAO COBERTAS	|CPF		|
//02		|22563477	|4197			|ODONTO BRONZE - EMPRESARIAL|			|				|ADAILTON PIRES SILVA	|1				|33		|Titular	|A			|30/08/2012	|				|955			|00				|0				|000				|0			|000			|0			|000			|0	|000|00						|27533649826|
//03		|22563477	|4197			|ODONTO BRONZE - EMPRESARIAL|			|				|						|				|		|			|			|			|				|955			|000			|0				|000				|0			|000			|0			|000			|0	|000|000					|27533649826|

FT_FUse(cArquivo) // Abre o arquivo
FT_FGOTO(nPos)    // Posiciona no inicio do arquivo

While !FT_FEof()
	nValor := 0
   	cLinha := FT_FReadln()        // Le a linha
 	aLinha := separa(UPPER(cLinha),";")  // Sepera para vetor 
    If Len(aLinha) == 25 .and. !EMPTY(aLinha[25])//validação do tamanho da estrutura do arquivo.
	    If aLinha[1] <> "REGISTRO" .and. !EMPTY(ALLTRIM(aLinha[25])) .and. VAL(aLinha[1]) == 3
			nValor += VAL(Substr(aLinha[14],0,len(aLinha[14])-2)+"."+Right(aLinha[14],2))//VALOR PREMIO
			//O funcionario não Paga os Itens Abaixo
			//nValor += VAL(Substr(aLinha[15],0,len(aLinha[15])-2)+"."+Right(aLinha[15],2))//VALOR PRORATA
			//nValor += VAL(Substr(aLinha[17],0,len(aLinha[17])-2)+"."+Right(aLinha[17],2))//VALOR ORTODONTIA
			//nValor += VAL(Substr(aLinha[19],0,len(aLinha[19])-2)+"."+Right(aLinha[19],2))//VALOR PROTESE
			//nValor += VAL(Substr(aLinha[21],0,len(aLinha[21])-2)+"."+Right(aLinha[21],2))//VALOR BASICA
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

*-------------------------*
Static Function GeraExcel()
*-------------------------*
Private cDest	:= GetTempPath()
Private cArq	:= "LOG_ODONTO.XLS"

Montaxls()

Return .T.                                                           

*----------------------------*
Static Function Montaxls()
*----------------------------*
Local cMsg := ""

IF FILE(cDest+cArq)
	FERASE(cDest+cArq)
ENDIF 

nHdl		:= FCREATE(cDest+cArq,0 )  //Criação do Arquivo HTML.
nBytesSalvo	:= FWRITE(nHdl, cMsg ) // Gravação do seu Conteudo.
fclose(nHdl) // Fecha o Arquivo que foi Gerado

cMsg += "<html>"
cMsg += "	<body>"
cMsg += "	<table height='361' width='844' bgColor='#ffffff' border='0' bordercolor='#ffffff' style='border-collapse: collapse' cellpadding='0' cellspacing='0'>"
cMsg += "		<td colspan='2'>Data Integração</td><td>"+Dtoc(DATE())+" - "+TIME()+"</td>"
cMsg += "		<tr></tr><tr>"
cMsg += "			<td colspan='7' bgcolor='#ffffff' border='0' bordercolor='#ffffff' align = 'Left'><font face='times' color='black' size='4'><b> "+SM0->M0_NOME+" </b></font></td>"
cMsg += "		</tr>"
cMsg += "	<tr>"
cMsg += "	</table>"
cMsg += "	<table height='361' width='844' bgColor='#ffffff' border='2' bordercolor='#000000' style='border-collapse: collapse' cellpadding='0' cellspacing='0'>"
cMsg += "			 <td width='150' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
cMsg += "				 <font face='times' color='black' size='3'> <b> Cod.Emp. </b></font>"
cMsg += "			 </td>"
cMsg += "			 <td width='250' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
cMsg += "				 <font face='times' color='black' size='3'> <b> Cod.Fil. </b></font>"
cMsg += "			 </td>"
cMsg += "			 <td width='150' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
cMsg += "				 <font face='times' color='black' size='3'> <b> Matricula </b></font>"
cMsg += "			 </td>"
cMsg += "			 <td width='150' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
cMsg += "				 <font face='times' color='black' size='3'> <b> Nome </b></font>"
cMsg += "			 </td>"
cMsg += "			 <td width='350' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
cMsg += "				 <font face='times' color='black' size='3'> <b> CPF </b></font>"
cMsg += "			 </td>"
cMsg += "			 <td width='150' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
cMsg += "				 <font face='times' color='black' size='3'> <b> Valor </b></font>"
cMsg += "			 </td>"
cMsg += "		 </tr>"

cMsg := GrvXLS(cMsg) //Grava e limpa memoria da variavel.
            
nCont := 0
For i:=1 to Len(aExcel)     
	cMsg += "		 <tr>"
	cMsg += "			 <td width='150' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
	cMsg += "				 <font face='times' color='black' size='3'> " +aExcel[i][1]
	cMsg += "			 </td>"
	cMsg += "			 <td width='250' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
	cMsg += "				 <font face='times' color='black' size='3'> ="+'"'+aExcel[i][2]+'"'
	cMsg += "			 </td>"
	cMsg += "			 <td width='150' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
	cMsg += "				 <font face='times' color='black' size='3'> ="+'"'+aExcel[i][3]+'"'
	cMsg += "			 </td>"
	cMsg += "			 <td width='150' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
	cMsg += "				 <font face='times' color='black' size='3'> "+aExcel[i][4]
	cMsg += "			 </td>"
	cMsg += "			 <td width='350' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
	cMsg += "				 <font face='times' color='black' size='3'> ="+'"'+aExcel[i][5]+'"'
	cMsg += "			 </td>"
	cMsg += "			 <td width='150' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
	cMsg += "				 <font face='times' color='black' size='3'> "+aExcel[i][6]
	cMsg += "			 </td>"
	cMsg += "		 </tr>"
    
	If nCont == 40
		cMsg := GrvXLS(cMsg) //Grava e limpa memoria da variavel.
		nCont := 0
	EndIf         
	nCont ++
	IncProc("Gerando arquivo Excel...")	
Next i
 
cMsg += "	</table>"
cMsg += "	<BR?>"
cMsg += "</html> "

cMsg := GrvXLS(cMsg) //Grava e limpa memoria da variavel.

If nBytesSalvo <= 0   // Verificação do arquivo (GRAVADO OU NAO) e definição de valor de Bytes retornados.
	if ferror()	== 516
		MsgStop("Erro de gravação do Destino, o arquivo deve estar aberto. Error = "+ str(ferror(),4),'Erro')
	else
		MsgStop("Erro de gravação do Destino. Error = "+ str(ferror(),4),'Erro')
    endif
else
	fclose(nHdl) // Fecha o Arquivo que foi Gerado
	cExt := '.xls'
	SHELLEXECUTE("open",(cDest+cArq),"","",5)   // Gera o arquivo em Excel
endif

//FErase(cDest+cArq) //TLM 04/12/2012

Return cMsg

*------------------------------*
Static Function GrvXLS(cMsg)
*------------------------------*
Local nHdl		:= Fopen(cDest+cArq)

FSeek(nHdl,0,2)
nBytesSalvo += FWRITE(nHdl, cMsg )
fclose(nHdl)

Return ""