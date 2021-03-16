//-----------------------------------------------------------------------------------------------------------//
// Wederson Santana 24/09/08 - Orbisat da Amazônia                                                           //
//-----------------------------------------------------------------------------------------------------------//
//Listagem de usuários                                                                                       //
//-----------------------------------------------------------------------------------------------------------//
# Include "Protheus.ch"

User Function xUsuarios()
Local nOpcoes   := GETF_RETDIRECTORY + GETF_LOCALHARD
Local lArvore   := .F. /*.T. = apresenta o árvore do servidor || .F. = não apresenta*/
Local cDirLoc   := ""
Local cDirSrv   := ""
Local cMascara  := "*.*|*.*"
Local cTitulo   := "Selecione o arquivo"
Local nMascpad  := 0
Local cDirini   := "c:\"
Local lSalvar   := .F. /*.T. = Salva || .F. = Abre*/
Private nHdlChk    
    
If MsgYesNo("(Sim) Arquivo XLS - (Nao) Arquivo TXT ")

   cDirLoc := cGetFile( cMascara, cTitulo, nMascpad, cDirIni, lSalvar, nOpcoes, lArvore)                                                            

   MsgRun(OemtoAnsi("Aguarde...Exportando Cadastro de Usuarios "),,{|| fOkExcel(cDirLoc) })
Else
   cDirLoc := cGetFile( cMascara, cTitulo, nMascpad, cDirIni, lSalvar, nOpcoes, lArvore)                                                            

   MsgRun(OemtoAnsi("Aguarde...Exportando Cadastro de Usuarios "),,{|| fOkTexto() })	
EndIf   
	
Return                                                                                                         

//-----------------------------------------------------------

Static Function fOkExcel(cDirLoc)
Local cDbAlias := GetSrvProfString('DBALIAS','')
_aUsers	:= {}
_aUsers := AllUsers()
_ni := 0

cMsg := '<html>'
cMsg += '<head>'
cMsg += '  <title>Relatorio de usuarios</title>'
cMsg += '</head>'
cMsg += '<body>'

cMsg += "<table cellspacing='1' cellpadding='1' width=700 bgcolor=#FFFFFF align='center' border='1'>
cMsg += "<td width='100%'>
cMsg += '    <tr>'
cMsg += "      <td rowspan='1' colspan='1' bgcolor='#99ccff' align='center'><font face='Arial' size='2'><B>Codigo</B></font></td> "
cMsg += "      <td rowspan='1' colspan='1' bgcolor='#99ccff' align='center'><font face='Arial' size='2'><B>Usuário</B></font></td> "
cMsg += "      <td rowspan='1' colspan='1' bgcolor='#99ccff' align='center'><font face='Arial' size='2'><B>Nome Completo</B></font></td> "
cMsg += "      <td rowspan='1' colspan='1' bgcolor='#99ccff' align='center'><font face='Arial' size='2'><B>Departamento</B></font></td> "
cMsg += "      <td rowspan='1' colspan='1' bgcolor='#99ccff' align='center'><font face='Arial' size='2'><B>E-mail</B></font></td> "
cMsg += "      <td rowspan='1' colspan='1' bgcolor='#99ccff' align='center'><font face='Arial' size='2'><B>Acessos</B></font></td> "
cMsg += "      <td rowspan='1' colspan='1' bgcolor='#99ccff' align='center'><font face='Arial' size='2'><B>Bloqueado</B></font></td> "
cMsg += "      <td rowspan='1' colspan='1' bgcolor='#99ccff' align='center'><font face='Arial' size='2'><B>Matricula</B></font></td> "
cMsg += "      <td rowspan='1' colspan='1' bgcolor='#99ccff' align='center'><font face='Arial' size='2'><B>Controle de Documentos</B></font></td> "
cMsg += "      <td rowspan='1' colspan='1' bgcolor='#99ccff' align='center'><font face='Arial' size='2'><B>Ativo Fixo</B></font></td> "
cMsg += "      <td rowspan='1' colspan='1' bgcolor='#99ccff' align='center'><font face='Arial' size='2'><B>Faturamento</B></font></td> "
cMsg += "      <td rowspan='1' colspan='1' bgcolor='#99ccff' align='center'><font face='Arial' size='2'><B>Compras</B></font></td> "
cMsg += "      <td rowspan='1' colspan='1' bgcolor='#99ccff' align='center'><font face='Arial' size='2'><B>Estoque</B></font></td> "
cMsg += "      <td rowspan='1' colspan='1' bgcolor='#99ccff' align='center'><font face='Arial' size='2'><B>Financeiro</B></font></td> "
cMsg += "      <td rowspan='1' colspan='1' bgcolor='#99ccff' align='center'><font face='Arial' size='2'><B>Gestão de Pessoal</B></font></td> "
cMsg += "      <td rowspan='1' colspan='1' bgcolor='#99ccff' align='center'><font face='Arial' size='2'><B>Ponto Eletrônico</B></font></td> "
cMsg += "      <td rowspan='1' colspan='1' bgcolor='#99ccff' align='center'><font face='Arial' size='2'><B>Fiscal</B></font></td> "
cMsg += "      <td rowspan='1' colspan='1' bgcolor='#99ccff' align='center'><font face='Arial' size='2'><B>Contabilidade</B></font></td> "
cMsg += "      <td rowspan='1' colspan='1' bgcolor='#99ccff' align='center'><font face='Arial' size='2'><B>Diretorio</B></font></td> "
cMsg += "      <td rowspan='1' colspan='1' bgcolor='#99ccff' align='center'><font face='Arial' size='2'><B>Emp/Fil</B></font></td> "
cMsg += '    </tr>'
cMsg += "</TD>

For _nI := 1 to len(_aUsers)
	If !_aUsers[_nI,1,1] $ '000000'.And.!_aUsers[_nI,1,17]
	      _aArray:={}
	      _aArray:=_aUsers[_nI,2,6]
		  cMsg += '    <tr>'
		  cMsg += "      <td rowspan='1' colspan='1' bgcolor='#FFFFFF' align='center'><font face='Arial' size='2'><B>" + _aUsers[_nI,1,01] + "</B></font></td>"
		  cMsg += "      <td rowspan='1' colspan='1' bgcolor='#FFFFFF' align='center'><font face='Arial' size='2'><B>" + _aUsers[_nI,1,02] + "</B></font></td>"
		  cMsg += "      <td rowspan='1' colspan='1' bgcolor='#FFFFFF' align='center'><font face='Arial' size='2'><B>" + _aUsers[_nI,1,04] + "</B></font></td>"
		  cMsg += "      <td rowspan='1' colspan='1' bgcolor='#FFFFFF' align='center'><font face='Arial' size='2'><B>" + _aUsers[_nI,1,12] + "</B></font></td>"
		  cMsg += "      <td rowspan='1' colspan='1' bgcolor='#FFFFFF' align='center'><font face='Arial' size='2'><B>" + _aUsers[_nI,1,14] + "</B></font></td>"
		  cMsg += "      <td rowspan='1' colspan='1' bgcolor='#FFFFFF' align='center'><font face='Arial' size='2'><B>" + StrZero(_aUsers[_nI,1,15],4) + "</B></font></td>"
		  cMsg += "      <td rowspan='1' colspan='1' bgcolor='#FFFFFF' align='center'><font face='Arial' size='2'><B>" + If(_aUsers[_nI,1,17],"S","N") + "</B></font></td>"
		  cMsg += "      <td rowspan='1' colspan='1' bgcolor='#FFFFFF' align='center'><font face='Arial' size='2'><B>" + _aUsers[_nI,1,22]  + "</B></font></td>"
    	  cMsg += "      <td rowspan='1' colspan='1' bgcolor='#FFFFFF' align='center'><font face='Arial' size='2'><B>" + If(Substr(_aUsers[_nI,3,24],3,1)$"X","",TiraXnu(Substr(_aUsers[_nI,3,24],12,30))) + "</B></font></td>"
		  cMsg += "      <td rowspan='1' colspan='1' bgcolor='#FFFFFF' align='center'><font face='Arial' size='2'><B>" + If(Substr(_aUsers[_nI,3,01],3,1)$"X","",TiraXnu(Substr(_aUsers[_nI,3,01],12,30))) + "</B></font></td>"
		  cMsg += "      <td rowspan='1' colspan='1' bgcolor='#FFFFFF' align='center'><font face='Arial' size='2'><B>" + If(Substr(_aUsers[_nI,3,05],3,1)$"X","",TiraXnu(Substr(_aUsers[_nI,3,05],12,30))) + "</B></font></td>"
		  cMsg += "      <td rowspan='1' colspan='1' bgcolor='#FFFFFF' align='center'><font face='Arial' size='2'><B>" + If(Substr(_aUsers[_nI,3,02],3,1)$"X","",TiraXnu(Substr(_aUsers[_nI,3,02],12,30))) + "</B></font></td>"
		  cMsg += "      <td rowspan='1' colspan='1' bgcolor='#FFFFFF' align='center'><font face='Arial' size='2'><B>" + If(Substr(_aUsers[_nI,3,04],3,1)$"X","",TiraXnu(Substr(_aUsers[_nI,3,04],12,30))) + "</B></font></td>"
		  cMsg += "      <td rowspan='1' colspan='1' bgcolor='#FFFFFF' align='center'><font face='Arial' size='2'><B>" + If(Substr(_aUsers[_nI,3,06],3,1)$"X","",TiraXnu(Substr(_aUsers[_nI,3,06],12,30))) + "</B></font></td>"
		  cMsg += "      <td rowspan='1' colspan='1' bgcolor='#FFFFFF' align='center'><font face='Arial' size='2'><B>" + If(Substr(_aUsers[_nI,3,07],3,1)$"X","",TiraXnu(Substr(_aUsers[_nI,3,07],12,30))) + "</B></font></td>"
		  cMsg += "      <td rowspan='1' colspan='1' bgcolor='#FFFFFF' align='center'><font face='Arial' size='2'><B>" + If(Substr(_aUsers[_nI,3,16],3,1)$"X","",TiraXnu(Substr(_aUsers[_nI,3,16],12,30))) + "</B></font></td>"
		  cMsg += "      <td rowspan='1' colspan='1' bgcolor='#FFFFFF' align='center'><font face='Arial' size='2'><B>" + If(Substr(_aUsers[_nI,3,09],3,1)$"X","",TiraXnu(Substr(_aUsers[_nI,3,09],12,30))) + "</B></font></td>"
		  cMsg += "      <td rowspan='1' colspan='1' bgcolor='#FFFFFF' align='center'><font face='Arial' size='2'><B>" + If(Substr(_aUsers[_nI,3,34],3,1)$"X","",TiraXnu(Substr(_aUsers[_nI,3,34],12,30))) + "</B></font></td>"
		  cMsg += "      <td rowspan='1' colspan='1' bgcolor='#FFFFFF' align='center'><font face='Arial' size='2'><B>" + _aUsers[_nI,2,3] + "</B></font></td>"
		  
		  j:=1
		  While j <= Len(_aArray)
 		        cMsg += "      <td rowspan='1' colspan='1' bgcolor='#FFFFFF' align='center'><font face='Arial' size='2'><B>" + _aArray[j] + "</B></font></td>"
 		        j++
 		        If j>Len(_aArray)
 		           Exit
 		        EndIf   
 		  End      
 		  
		  cMsg += '    </tr>'
	EndIf 
Next

cMsg += '</body>'
cMsg += '</html>'

MemoWrite(cDirLoc+"\usuarios_ambiente_"+cDbAlias+".xls",cMsg)     
WinExec ("C:\WINDOWS\EXPLORER.EXE "+cDirLoc+"\usuarios_ambiente_"+cDbAlias+".xls")

Return    

//-----------------------------------------------------------

Static Function fOkTexto()

fGeraTxt("c:\usuarios")

_aUsers	:= {}
_aUsers := AllUsers()

For _nI := 1 to len(_aUsers)
	If !_aUsers[_nI,1,1] $ '000000'.And.!_aUsers[_nI,1,17]
	   cLinha:=_aUsers[_nI,1,01]+;
	           _aUsers[_nI,1,02]+;
	           _aUsers[_nI,1,04]+;
   	           Space(10)+Chr(13)+Chr(10)
	
	   FWrite(nHdlChk,cLinha,Len(cLinha))
	EndIf 
Next

Return

//--------------------------------------------------------------

Static Function fGeraTxt(_cLocalArq)
nHdlChk	:=	MsFCreate(AllTrim(_cLocalArq)+".txt")
If nHdlChk < 0
   MsgInfo("Arquivo nao pode ser criado em "+AllTrim(_cLocalArq),"A T E N C A O")
   Break
EndIf
Return

//--------------------------------------------------------------

Static Function TiraXnu(_xModulo)

Local _nX := 0
Local _cRet := ""

for _nX := 1 to len(_xmodulo)


	If Substr(_xmodulo,_nX,1) == "."
		_nX := len(_xmodulo)
    Else
		_cRet += Substr(_xmodulo,_nX,1)		
    EndIf

Next

Return(_cRet)
