
#include "topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GTGPE024 ºAutor  ³Francisco Neto Data ³  08/02/17           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada no calculo de Folha de Pagamento para     º±±
±±º          ³ geracao do Premio Mensal de Permanencia TPB                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico Clientes GT (TRAVEL - FP - P11_14)              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
user function GTGPE024()

	private nmeses := 0
	datahum := SRA->RA_ADMISSA   
	datadois := DDATABASE     
	mes := val(right(cFolmes,2))
	cValor := 0

	Private cPeriodo    := subs(GETMV("MV_FOLMES"),5,2)+"/"+subs(GETMV("MV_FOLMES"),1,4)
	
	If subs(cPeriodo,1,2) $ "04/06/09/11"
		datadois := subs(cPeriodo,4,4)+subs(cPeriodo,1,2)+"30"
	Elseif subs(cPeriodo,1,2) $ "01/03/05/07/08/10/12"
		datadois := subs(cPeriodo,4,4)+subs(cPeriodo,1,2)+"31"
	Elseif subs(cPeriodo,1,2) $ "02"
		If (nYear % 4 = 0 .And. nYear % 100 <> 0) .Or. (nYear % 400 = 0) // ano bissexto
			datadois := subs(cPeriodo,4,4)+subs(cPeriodo,1,2)+"29"
		Else
			datadois := subs(cPeriodo,4,4)+subs(cPeriodo,1,2)+"28"
		Endif
	Endif

	datatres := subs(datadois,7,2)+"/"+subs(datadois,5,2)+"/"+subs(datadois,1,4)
	nmeses := DateDiffMonth( datahum , datatres ) 
	
	if nMeses >= 12
		nAnos :=  int(nMeses / 12)
	endif
	
	if nMeses <= 36
		return
	endif

	if M_ADPERM > 0
		fGeraVerba("100",((M_ADPERM*nAnos)/30*diastrab), , , , , , , , ,.T.) 
	endif	

return

