#include "topconn.ch"
#include "rwmake.ch"  
#iNCLUDE "AP5MAIL.CH" 
#Include "pryor.ch"     

/*
Funcao      : EXP5301
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Exporta o arquivo CT2 da folha de pagamento da empresa BOSTON 
Autor     	: Renato Mendonça 	
Data     	: 
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 15/03/2012
Módulo      : Financeiro.
*/

*------------------------*
 User Function EXP5301()      
*------------------------*

lFirst:=.T.

SetPrvt("cPerg,cNOVO,cEnvia,cNome,cNomEmp")

If Select("NOV")>0
   NOV->(DbCloseArea())
Endif   


cPerg 	:= "EX5301    "
cDestino := ""
cValid	:= ""
aSTRUCT := {}
PswOrder(1)
PswSeek(__cUserId,.T.)
aUsuario:= PswRet()
cEnvia   := Alltrim(aUsuario[1,14])
cNome		:=	Alltrim(aUsuario[1,4])


//CriaPerg()

If cEmpAnt $ "53"              
	If Pergunte(cPerg,.T.)
		Processa({|| CriaArqv() },"Aguarde...")
	ENDIF
else
    MsgInfo("Especifico Boston Scientif ","A T E N C A O")  
endif
Return

Static Function CriaArqv()

fGeraSql()
cContSql:= LASTREC()

fCriaTab()

DBSELECTAREA("SQL")
   dbgotop()
   y := fcount() 
   x := (y-2) // "R_E_C_N_O_" e "R_E_C_D_E_L_" 
   
   WHILE .NOT. EOF()

		IncProc("COPIANDO Arquivo...")
	   fCONTE := {}
	   FOR Z := 1 TO Y                           // LEITURA  
	      IF  !(FIELD(Z) == "R_E_C_N_O_" .OR. FIELD(Z) == "R_E_C_D_E_L_")
	         AADD(fCONTE ,FIELDGET(Z))
	      EndIf
	   NEXT Z


		DBSELECTAREA("NOV")                      // GRAVACAO
		reclock("NOV",.T.)
				
	   	for z := 1 to x
	      	
	      	fNAME := FIELD(Z)
	      	If fNAME <> 'CT2_KEY' .And. fNAME <> 'CT2_SEGOFI' .And. fNAME <> 'CT2_DTCV3' .And. fNAME <> 'CT2_SEQIDX' 
	           nov->&fNAME := fCONTE[Z]
	        EndIf
	         	            
	      next z    
	      
	    
      MSUNLOCK()

      DBSELECTAREA("SQL")
      DBSKIP()
	ENDDO


IF cContSql == 0 
   _aArquivo:={}
	AADD(_aArquivo,cNOVO)
	aFiles := _aArquivo[1]  
	dbCloseArea(cNOVO)
	dbCloseArea("NOV")	
	eEmail()
ELSE
	MSGINFO("Não existe registro no lançamento contabil no periodo informado!")
endif	

RETURN
//----------------------------------------//
//	Cria Tabela										//
//----------------------------------------//
Static Function fCriaTab()

	cAlias:= Alias()
	DbSelectArea("CT2")
	dbSetOrder(1)
	DbGotop()
	cNOVO:= '\UTIL\BOSTON.DBF'
   aSTRUCT := DBSTRUCT()
   dbcreate(cNOVO,ASTRUCT)  
	dbUseArea(.T.,,cNOVO,"NOV",.T.,.F.)
	DbGoTop()
	DbSelectArea(cAlias)


RETURN  .T.
//---------------------------------------------------------------//
// Seleciona o periodo informado no parametro						  //
//---------------------------------------------------------------//
Static Function fGeraSql()

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

aSTRUCT2 :={}
aSTRUCT2:= CT2->(dbStruct())


cQuery := "SELECT * "+Chr(10)
cQuery += "FROM "+RetSqlName("CT2")+" AS CT2 "+Chr(10)
cQuery += "WHERE CT2.CT2_FILIAL = '"+xFilial("CT2")+"'"+Chr(10)
cQuery += "AND CT2.CT2_DATA BETWEEN '"+Dtos(MV_PAR01)      +"' AND '"+Dtos(MV_PAR02)      +"' "+Chr(10)
cQuery += "AND CT2.CT2_LOTE ='004400'"+Chr(10)
cQuery += "AND CT2.CT2_MOEDLC = '01'"+Chr(10)
cQuery += "AND CT2.D_E_L_E_T_ <> '*'"+Chr(10) 
cQuery += "ORDER BY CT2_DATA,CT2_SBLOTE,CT2_DOC,CT2_LINHA"  
TCQuery cQuery ALIAS "SQL" NEW

TCSetField("SQL","DTOS(CT2_DATA)"   ,"D",08,0)
TCSetField("SQL","DTOS(CT2_DTVENC)" ,"D",08,0)
	For nX := 1 To Len(aSTRUCT2)
	    If aSTRUCT2[nX,2]<>"C"
	 	    TcSetField("SQL",aSTRUCT2[nX,1],aSTRUCT2[nX,2],aSTRUCT2[nX,3],aSTRUCT2[nX,4])
	    EndIf
	Next nX



Return
//-------------------------------------------//
//   Cria Pergunta                           //
//-------------------------------------------//
Static Function CriaPerg()
aSvAlias:={Alias(),IndexOrd(),Recno()}
i:=j:=0

aRegs:={}
//            1    2       3                   4  5    6       7  8  9  10 11  12  13        14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41
AADD(aRegs,{cPerg,"01","Data de             ?","","","mv_ch1","D",08,00,00,"G","","Mv_Par01","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Data ate            ?","","","mv_ch2","D",08,00,00,"G","","Mv_Par02","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"03","Email               ?","","","mv_ch3","C",40,00,00,"G","","Mv_Par03","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})


DbSelectArea("SX1")
For i := 1 to Len(aRegs)
	dbSeek(aRegs[i,1]+aRegs[i,2])
	IF !Found()
		While !RecLock("SX1",.T.)
		End
		For j:=1 to FCount()
			FieldPut(j,aRegs[i,j])
		Next
		MsUnlock()
	Endif
Next i

Return  

Static Function eEmail()

Connect Smtp Server GetMv('MV_RELSERV')  Account GetMv('MV_RELACNT') PassWord GetMv('MV_RELPSW') Result lConectou

if lConectou 
	aTo	:=Alltrim(MV_PAR03)
	cFrom	:=cEnvia
	aCc	:=cEnvia
	CrLf		:= Chr(13)+Chr(10)
	cMsg		:= ""
	lOk      := .F.
	cMsg :=""
	cMsg += '<html>'+CrLf
	cMsg += '<font size="4" face="Arial">Arquivo CT2</font>'+CrLf+CrLf                  
	cMsg +=CrLf+CrLf
	cMsg += '<font size="2" face="Arial">Segue em anexo o Arquivo CT2</font>' +CrLf   
	cMsg +=CrLf+CrLf
	cMsg += '<font size="2" face="Arial">'+cNome+'</font>' +CrLf   
	cMsg += '<font size="2" face="Arial">'+cEnvia+'</font>' +CrLf   
	cMsg += '<font size="2" face="Arial">Fone: 5511- 38864800</font>' +CrLf  
	cMsg += '<font size="4" face="Arial"> Pryor Consulting </font>' +CrLf
	cMsg += '</body>'+CrLf
	cMsg += '</html>'+CrLf        

	cSubject:= 'Arquivo CT2'
	
	SEND MAIL ;
	FROM cFrom;
	TO aTo;
	CC aCc ;
	SUBJECT cSubject;
	BODY cMsg; 
	Attachment aFiles;	
	Result lEnviado   
	   
   If lEnviado
      MsgInfo("Email enviado Corretamente "," A T E N C A O ")
   Else 
      MsgInfo("Nao foi possivel enviar o email com detalhes do processo.E-mail "+aTo+" "+MailGetErr(),"A T E N C A O")
   EndIf

Else
	 MsgInfo("Nao foi possivel conexao com o servidor . "+GetMv('MV_RELSERV'),"A T E N C A O")
Endif  

Disconnect Smtp Server	

If Select("NOV")>0
   NOV->(DbCloseArea())
Endif   

fErase(cNOVO)   

return .t.