#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH" 
#INCLUDE "FILEIO.CH"    

#DEFINE ENTER CHR(13)+CHR(10)   
/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥ GTADP_09 ≥Autor  ≥ Francisco Neto        ≥ Data ≥13/10/2016≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ HLB BRASIL ADP - TransferÍncia Autom·tica Shuttle      ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Obs:      ≥ Transfere arquivo .Zip para o Shuttle                      ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ Especifico HLB BRASIL                                  ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
User Function GTADP_09(cPath,cPeriodo)

PRIVATE _oWindow

Processa( {|| GTADP09Go(cPath,cPeriodo) }, "Transferindo arquivos..." )


Return( .F. )

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥ FunáÖo    ≥ GTADP09Go≥ Autor ≥ Francisco Neto        ≥ Data ≥13/10/2016≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ DescriáÖo ≥ Processamento do Arquivo.                                  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function GTADP09Go(cPath,cPeriodo)

	LOCAL _cQry := ""
	LOCAL dDataInc, dDataAlt
	LOCAL _aDetails := {}
	LOCAL _cFolMes  := subs(GETMV("MV_FOLMES"),5,2)+"/"+subs(GETMV("MV_FOLMES"),1,4)
	LOCAL _cPer2ini := ""
	LOCAL _cPer2fin := ""
	LOCAL _cPer3ini := ""
	LOCAL nYear3 := VAL(subs(cPeriodo,4,4))
	LOCAL nYear := VAL(subs(cPeriodo,4,4))
	LOCAL aHeader := {}
	LOCAL cNomArq := ""
	Local aArquivos := {}
	
	PRIVATE _cTitulo  := " "
	PRIVATE _cPer1ini := subs(cPeriodo,4,4)+subs(cPeriodo,1,2)+"01"
	PRIVATE _cPer1fin := ""
	
	Private cNomeEmx := ""
	Private cNomeEmp := STRTRAN(ALLTRIM(SM0->M0_NOME),".","-")
	
	for x = 1 to len(cNomeEmp)
		if substr(cNomeEmp,x,1) <> " "
			cNomeEmx := cNomeEmx + substr(cNomeEmp,x,1)	
		endif
	next x
	
	cNomeEmp := alltrim(cNomeEmx)

	
	Private cUseradp := ''
	Private	cPswadp  := ''

	Private cCC := ' '
	Private	_lver := .t.
	Private _cSenhaRet   := .f.



	//// limpa pasta de relatorios
	//cComando := "C:\Windows\System32\"+"cmd.exe" 
	//cOption := '/c del '+cPath+'*.* /q '  
	//ShellExecute("Open",cComando, cOption, cPath, 0 )    

	//Sleep(1000)

    //// Move arquivos para a pasta temporaria
	cComando := "C:\Windows\System32\"+"cmd.exe" 
	cOption := '/c Move '+cPath+'*.* '+cPathT  
	ShellExecute("Open",cComando, cOption, cPath, 0 )   

	Sleep(1000)

	//// limpa pasta temporaria
	//cComando := "C:\Windows\System32\"+"cmd.exe" 
	//cOption := '/c del '+cPathT+'*.* /q '  
	//ShellExecute("Open",cComando, cOption, cPathT, 0 )    

	//Sleep(1000)

	//Armazena os dados da tabela X0 do SX5
	DbSelectArea("SX5")
	DbSetOrder(1)
	If DbSeek(xFilial("SX5")+"X0"+"CID")
		cCID := X5_DESCRI
	Else
		Aviso("ATEN«√O", "N„o encontrada tabela X0!. Verifique!", {"Ok"} ) 
		Return
	Endif
	If DbSeek(xFilial("SX5")+"X0"+"ENTITY")
		cENTITY := X5_DESCRI
	Else
		Aviso("ATEN«√O", "N„o encontrada tabela X0!. Verifique!", {"Ok"} )
		Return
	Endif
	If DbSeek(xFilial("SX5")+"X0"+"LID")
		cLID := X5_DESCRI
	Else
		Aviso("ATEN«√O", "N„o encontrada tabela X0!. Verifique!", {"Ok"} )
		Return
	Endif
	

	DbSelectArea("SX2") //verifica compartilhamento de centro de custos
	DbSetOrder(1)
	
	If DbSeek("CTT")
		cCC := X2_MODO
	Endif
	
/*
	DbSelectArea("SX6") //verifica se existem par‚metros
	DbSetOrder(1)
	
	If DbSeek(xFilial("SX6")+"MV_P_ADPUS")
		cUseradp := GETMV("MV_P_ADPUS")
	ELSE
		RecLock("SX6",.t.)
			SX6->X6_FIL := xFilial("SX6")
			SX6->X6_VAR  := "MV_P_ADPUS"
			SX6->X6_TIPO := "C"
			SX6->X6_DESCRIC := "Usu·rio para acesso ao Shuttle ADP"
			SX6->X6_CONTEUD := "FTP998055"
			SX6->X6_PROPRI := "U"
			SX6->X6_PYME := "S"
		MsUnlock()
		cUseradp := "FTP998055"	
	Endif

	If DbSeek(xFilial("SX6")+"MV_P_ADPPW")
		cPswadp := GETMV("MV_P_ADPPW")
	ELSE
		RecLock("SX6",.t.)
			SX6->X6_FIL := xFilial("SX6")
			SX6->X6_VAR  := "MV_P_ADPPW"
			SX6->X6_TIPO := "C"
			SX6->X6_DESCRIC := "Senha para acesso ao Shuttle ADP"
			SX6->X6_CONTEUD := "HrgT*2016"
			SX6->X6_PROPRI := "U"
			SX6->X6_PYME := "S"
		MsUnlock()
		cPswadp := "rHGt*2016"	
	Endif
*/

	DigSenha()

	If _cSenhaRet == .F.
		MsgInfo("Usu·rio e/ou Senha Inv·lidos","Shuttle n„o executado !!!!")
	    return
	EndIf

	// monta periodo 1 final 
	If subs(cPeriodo,1,2) $ "04/06/09/11"
		_cPer1fin := subs(cPeriodo,4,4)+subs(cPeriodo,1,2)+"30"
	Elseif subs(cPeriodo,1,2) $ "01/03/05/07/08/10/12"
		_cPer1fin := subs(cPeriodo,4,4)+subs(cPeriodo,1,2)+"31"
	Elseif subs(cPeriodo,1,2) $ "02"
		If (nYear % 4 = 0 .And. nYear % 100 <> 0) .Or. (nYear % 400 = 0) // ano bissexto
			_cPer1fin := subs(cPeriodo,4,4)+subs(cPeriodo,1,2)+"29"
		Else
			_cPer1fin := subs(cPeriodo,4,4)+subs(cPeriodo,1,2)+"28"
		Endif
	Endif
	
	// retrocede periodo inicial para montar periodo final
	If subs(cPeriodo,1,2) = "01"
		_cMesfin := "12"
		_cAnofin := strzero(val(subs(cPeriodo,4,4))-1,2)
	Else
		_cMesfin := strzero(val(subs(cPeriodo,1,2))-1,2)
		_cAnofin := subs(cPeriodo,4,4)
	Endif 
	
	//_cPer2ini := _cAnofin+_cMesfin+"01"
	_cPer2ini := _cAnofin+_cMesfin
	nYear := _cAnofin
	
	IF UPPER(ALLTRIM(_cRegime)) == "S"
	
		// adianta periodo inicial para regime de caixa
		If subs(cPeriodo,1,2) = "12"
			_cMesfin := "01"
			_cAnofin := strzero(val(subs(cPeriodo,4,4))+1,2)
		Else
			_cMesfin := strzero(val(subs(cPeriodo,1,2))+1,2)
			_cAnofin := subs(cPeriodo,4,4)
		Endif 
		
		_cPer3ini := _cAnofin+_cMesfin
		nYear3 := _cAnofin
		
	ENDIF

	/// arquivo que serÅEzipado e transferido
	cArqZipx := cPathO+cNomeEmp+"_"+subs(dtoc(ddatabase),7,4)+subs(dtoc(ddatabase),4,2)+subs(dtoc(ddatabase),1,2)+"_"+subs(time(),1,2) + subs(time(),4,2)+".ZIP"
    /// arquivo de destino
	cArqZipy :=  cNomeEmp+"_"+subs(dtoc(ddatabase),7,4)+subs(dtoc(ddatabase),4,2)+subs(dtoc(ddatabase),1,2)+"_"+subs(time(),1,2) + subs(time(),4,2)+".ZIP"
/*
    //// Move arquivos para a pasta temporaria
	cComando := "C:\Windows\System32\"+"cmd.exe" 
	cOption := '/c Move '+cPath+'*.* '+cPathT  
	ShellExecute("Open",cComando, cOption, cPath, 0 )   

	Sleep(1000)
*/
    //// zipa arquivos
  	cComando := "C:\streamline\"+"7z.exe" 
    cOption := 'a -y "'+cArqZipx+'" '+cPathT+'*.*'
	ShellExecute("Open",cComando,cOption,CPathO,0)    /// zipa arquivos 

	Sleep(1000)


	//// Transfere para o Shuttle   --ProduÁ„o

	cComando := "C:\streamline\"+"curl.exe"
	cOption :='-Fupload=@'+cArqZipx+' -b "STRSMCHALLENGE=YES"'+' -u '+cUseradp+':'+cPswadp+' '+;   
	'"https://login.streamline.adp.com/ifx/Servlet?Action=Upload&Option=replace&Filename='+cArqZipx+'&Path=998055/OUTPUT&Mode=auto"'+;
	' --trace-ascii '+CPathL+'log'+cNomeEmp+"_"+subs(dtoc(ddatabase),7,4)+subs(dtoc(ddatabase),4,2)+subs(dtoc(ddatabase),1,2)+"_"+;
	subs(time(),1,2) + subs(time(),4,2)+'.txt'
	ShellExecute("Open",cComando,cOption,CPathO,0)      


/*

	//// Transfere para o Shuttle   ////---periodo de teste
	cComando := "C:\streamline\"+"curl.exe"
	cOption :='-Fupload=@'+cArqZipx+' -b "STRSMCHALLENGE=YES"'+' -u '+cUseradp+':'+cPswadp+' '+;   
	'"https://login.streamline.adp.com/ifx/Servlet?Action=Upload&Option=replace&Filename='+cArqZipx+'&Path=998055/SANDBOX&Mode=auto"'+;
	' --trace-ascii '+CPathL+'log'+cNomeEmp+"_"+subs(dtoc(ddatabase),7,4)+subs(dtoc(ddatabase),4,2)+subs(dtoc(ddatabase),1,2)+"_"+;
	subs(time(),1,2) + subs(time(),4,2)+'.txt'
	ShellExecute("Open",cComando,cOption,CPathO,1)
*/

    //// Move arquivo para a pasta Historico
	//cComando := "C:\Windows\System32\"+"cmd.exe" 
	//cOption := '/c Copy '+cPathO+'*.* '+cPathH  
	//ShellExecute("Open",cComando, cOption, cPath, 0 ) 


	//// limpa pasta temporaria
	cComando := "C:\Windows\System32\"+"cmd.exe" 
	cOption := '/c del '+cPathT+'*.* /q '  
	ShellExecute("Open",cComando, cOption, cPathT, 0 )    

	Sleep(1000)

	//// limpa pasta Output
	cComando := "C:\Windows\System32\"+"cmd.exe" 
	cOption := '/c del '+cPathO+'*.* /q '  
	ShellExecute("Open",cComando, cOption, cPathO, 0 )    

	Sleep(1000)


Return( Nil )




Static Function DigSenha()
	cUseradp := Space(9)
	cPswadp := SPACE(10)
	_cSenhaRet := .F.
	@ 100,55 To 290,350 Dialog oDlg4 Title OemToAnsi("Usu·rio e Senha Shuttle")
	@ 10,20 Say OemToAnsi(" Informe Usu·rio e Senha.")      Size 230,8
	@ 30,20 Say "Usu·rio: " Size 35,10
	@ 30,55 Get cUseradp Size 50,10
	@ 50,20 Say OemToAnsi("Senha :") Size 25,8
	@ 50,45 Get cPswadp PASSWORD Size 30,10
	@ 75,30 Button OemToAnsi("_OK") Size 32,12 Action VerSenha()
	@ 75,80 Button OemToAnsi("_Sair")    Size 32,12 Action Close(oDlg4)
	Activate Dialog oDlg4 Centered
Return


Static Function VerSenha()

	If len(alltrim(cUseradp)) # 9 .or. len(alltrim(cPswadp)) # 10
		MsgInfo("necess·rio informar Usu·rio e Senha v·lidos","Informe !!!!")
	     _cSenhaRet := .F.
	Else
	     _cSenhaRet := .T.
	     Close(oDlg4)
	EndIf
	
Return







