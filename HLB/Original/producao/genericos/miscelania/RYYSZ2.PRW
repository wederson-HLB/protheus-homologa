#INCLUDE "rwmake.ch"

/*
Funcao      : RYYSZ2
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Relacao Empresas X Tes.
Autor       : Carlinha / José Ferreira
Data/Hora   : 08/09/2005
Revisao     : Renato Rezende
Data	    : 29/04/2013
Obs.        :
*/  

*----------------------*
 User Function RYYSZ2
*----------------------*


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := "Relacao Empresas X Tes"
Local cPict          := ""
Local titulo       	:= "Relacao Empresas X Tes"
Local nLin         	:= 80
Local Cabec1       	:= "Codigo         Empresa            Filial"
Local Cabec2       	:= "               Tes   Cfop    Texto Padrao          Finalidade"
Local imprime      	:= .T.
Private aOrd         := {"Empresa"}
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite       := 80
Private tamanho      := "M" 
Private nomeprog     := "RYYSZ2"
Private nTipo        := 15
Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey     := 0
Private cPerg       := "SZ2REL    "
Private cbtxt      	:= Space(10)
Private cbcont     	:= 00
Private CONTFL     	:= 01
Private m_pag      	:= 01
Private wnrel      	:= "RYYSZ2" 
Private nItem		:= 1
Private cString 	:= "SZ2"

fCriaPerg()
fCriaSXB()

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,,Tamanho)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)


RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

Local nOrdem

dbSelectArea(cString)

nOrdem := aReturn[8]

dbSelectArea("SM0")
dbGoTop()
SetRegua(RecCount())
I:= 0
J:= 0
DO While !EOF()
	
	If SM0->M0_CODIGO <= SUBSTR(MV_PAR02,1,2).AND. SM0->M0_CODIGO >= SUBSTR(MV_PAR01,1,2) 

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif
		If nLin > 60 
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif
		SZ2->(dbSetOrder(3))
		IF SZ2->(dbSeek(xFilial("SZ2")+SM0->M0_CODIGO))
			@nLin, 02 PSAY SM0->M0_CODIGO
			@nLin, 05 PSAY SM0->M0_CODFIL
			@nLin, 15 PSAY SM0->M0_NOME
			@nLin, 35 PSAY SM0->M0_FILIAL
			nLin+=2
			I+=1
			While SUBSTR(SZ2->Z2_EMPRESA,1,2) == SM0->M0_CODIGO
				If nLin > 65 
				  Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,GETMV("MV_COMP"))
					nLin := 9
				Endif
				@nlin, 15 PSAY SZ2->Z2_TES
				@nLin, 20 PSAY SZ2->Z2_CFOP
				@nLin, 27 PSAY SZ2->Z2_DESCRI
				@nLin, 48 PSAY SZ2->Z2_FINALID
				SZ2->(DbSkip())
				nLin += 1
			END
		endif
		nLin += 3
	endif
	dbSkip()
	IncRegua()
EndDO
nLin++

Roda(0,Space(10),tamanho)

SET DEVICE TO SCREEN

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³criaperg º Autor ³ AP5 IDE            º Data ³  17/01/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Verifica a existencia das perguntas criando-as caso seja   º±±
±±º          ³ necessario (caso nao existam).                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

*----------------------------*
 Static Function fCriaPerg()
*----------------------------*

aSvAlias:={Alias(),IndexOrd(),Recno()}
i:=j:=0
aRegistros:={}
//               1      2    3                 4  5  6        7   8  9  1 0 11  12 13         14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38
AADD(aRegistros,{cPerg,"01","Empresa de:","","","mv_ch1","C",02,00,00,"G","","Mv_Par01","","","","","","","","","","","","","","","","","","","","","","","","","SZ2REL","","","","",""})
AADD(aRegistros,{cPerg,"02","Empresa ate:","","","mv_ch2","C",02,00,00,"G","","Mv_Par02","","","","","","","","","","","","","","","","","","","","","","","","","SZ2REL","","","","",""})

dbSelectArea("SX1")
For i := 1 to Len(aRegistros)
	If !dbSeek(aRegistros[i,1]+aRegistros[i,2])
		While !RecLock("SX1",.T.)
		End
		For j:=1 to FCount()
			FieldPut(j,aRegistros[i,j])
		Next
		MsUnlock()
	Endif
Next i

dbSelectArea(aSvAlias[1])
dbSetOrder(aSvAlias[2])
dbGoto(aSvAlias[3])

Return(Nil)       
                                                                       
*-----------------------------------*
 Static Function fCriaSXB()
*-----------------------------------*

SXB->(DbSetOrder(1))
  
      IF !SXB->(DbSeek("SZ2REL"+"1"))
         RecLock("SXB", .T.)
         SXB->XB_ALIAS   := "SZ2REL"
         SXB->XB_TIPO    := "1" 
         SXB->XB_SEQ     := "01"
         SXB->XB_COLUNA  := "DB"
         SXB->XB_DESCRI  := "Empresa"
         SXB->XB_DESCSPA := "Empresa"
         SXB->XB_DESCENG := "Empresa"
         SXB->XB_CONTEM  := "SM0"
         SXB->(MsUnlock())
      EndIf
   
      IF !SXB->(DbSeek("SZ2REL"+"2"+"01"))
         RecLock("SXB", .T.)
         SXB->XB_ALIAS   := "SZ2REL"
         SXB->XB_TIPO    := "2" 
         SXB->XB_SEQ     := "01"
         SXB->XB_COLUNA  := "01"
         SXB->XB_DESCRI  := "Codigo"
         SXB->XB_DESCSPA := "Codigo"
         SXB->XB_DESCENG := "Code"
         SXB->(MsUnlock())
      EndIf
   
      IF !SXB->(DbSeek("SZ2REL"+"2"+"02"))
         RecLock("SXB", .T.)
         SXB->XB_ALIAS   := "SZ2REL"
         SXB->XB_TIPO    := "2" 
         SXB->XB_SEQ     := "02"
         SXB->XB_COLUNA  := "02"
         SXB->XB_DESCRI  := "Descricao"
         SXB->XB_DESCSPA := "Descripcion"
         SXB->XB_DESCENG := "Description" 
         SXB->(MsUnlock())
      EndIf   
   
      IF !SXB->(DbSeek("SZ2REL"+"4"+"01"+"01"))
         RecLock("SXB", .T.)
         SXB->XB_ALIAS   := "SZ2REL"
         SXB->XB_TIPO    := "4" 
         SXB->XB_SEQ     := "01"
         SXB->XB_COLUNA  := "01"
         SXB->XB_DESCRI  := "Codigo"
         SXB->XB_DESCSPA := "Codigo"
         SXB->XB_DESCENG := "Code" 
         SXB->XB_CONTEM  := "M0_CODIGO"
         SXB->(MsUnlock())
      EndIf   
      
      IF !SXB->(DbSeek("SZ2REL"+"4"+"01"+"02"))
         RecLock("SXB", .T.)
         SXB->XB_ALIAS   := "SZ2REL"
         SXB->XB_TIPO    := "4" 
         SXB->XB_SEQ     := "01"
         SXB->XB_COLUNA  := "02"
         SXB->XB_DESCRI  := "Descricao"
         SXB->XB_DESCSPA := "Descripcion"
         SXB->XB_DESCENG := "Description" 
         SXB->XB_CONTEM  := "M0_FILIAL"
         SXB->(MsUnlock())
      EndIf   
      
      IF !SXB->(DbSeek("SZ2REL"+"4"+"01"+"03"))
         RecLock("SXB", .T.)
         SXB->XB_ALIAS   := "SZ2REL"
         SXB->XB_TIPO    := "4" 
         SXB->XB_SEQ     := "01"
         SXB->XB_COLUNA  := "03"
         SXB->XB_DESCRI  := "Empresa"
         SXB->XB_DESCSPA := "Empresa"
         SXB->XB_DESCENG := "Empresa" 
         SXB->XB_CONTEM  := "M0_NOME"
         SXB->(MsUnlock())
      EndIf  
      
      IF !SXB->(DbSeek("SZ2REL"+"4"+"02"+"01"))
         RecLock("SXB", .T.)
         SXB->XB_ALIAS   := "SZ2REL"
         SXB->XB_TIPO    := "4" 
         SXB->XB_SEQ     := "02"
         SXB->XB_COLUNA  := "01"
         SXB->XB_DESCRI  := "Empresa"
         SXB->XB_DESCSPA := "Empresa"
         SXB->XB_DESCENG := "Empresa" 
         SXB->XB_CONTEM  := "M0_NOME"
         SXB->(MsUnlock())
      EndIf  
      
      IF !SXB->(DbSeek("SZ2REL"+"4"+"02"+"02"))
         RecLock("SXB", .T.)
         SXB->XB_ALIAS   := "SZ2REL"
         SXB->XB_TIPO    := "4" 
         SXB->XB_SEQ     := "02"
         SXB->XB_COLUNA  := "02"
         SXB->XB_DESCRI  := "Codigo"
         SXB->XB_DESCSPA := "Codigo"
         SXB->XB_DESCENG := "Code" 
         SXB->XB_CONTEM  := "M0_CODIGO"
         SXB->(MsUnlock())
      EndIf  
      
         IF !SXB->(DbSeek("SZ2REL"+"4"+"02"+"03"))
         RecLock("SXB", .T.)
         SXB->XB_ALIAS   := "SZ2REL"
         SXB->XB_TIPO    := "4" 
         SXB->XB_SEQ     := "02"
         SXB->XB_COLUNA  := "03"
         SXB->XB_DESCRI  := "Filial"
         SXB->XB_DESCSPA := "Filial"
         SXB->XB_DESCENG := "Filial" 
         SXB->XB_CONTEM  := "M0_FILIAL"
         SXB->(MsUnlock())
      EndIf  
      
      IF !SXB->(DbSeek("SZ2REL"+"5"+"01"))
         RecLock("SXB", .T.)
         SXB->XB_ALIAS   := "SZ2REL"
         SXB->XB_TIPO    := "5" 
         SXB->XB_SEQ     := "01"
         SXB->XB_CONTEM  := "SM0->M0_CODIGO"
         SXB->(MsUnlock())
      ENDIF

Return .T.
