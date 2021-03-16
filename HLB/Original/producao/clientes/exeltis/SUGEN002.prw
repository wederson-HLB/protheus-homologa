
/*
Funcao      : SUGEN002
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Impressao de Etiqueta Fracionada
Autor       : Consultoria Totvs
Data/Hora   : 26/08/2014     
Obs         : 
Revisão     : Renato Rezende
Data/Hora   : 26/08/2014
Módulo      : Faturamento.
Cliente     : Exeltis
*/

*-------------------------------------------------------------------*
 User Function SUGEN002(cPorta, _nQtd,cDtVal,cLote,cDescr,_cCB)
*-------------------------------------------------------------------*
 	Local _I 
	
	MSCBPRINTER("S4M",cPorta,,,.f.,,,,) // Configura e define a porta na impressora Zebra S-600
	MSCBCHKStatus(.F.) // Não checa o "Status" da impressora - Sem esse comando nao imprime
	_nQtd := Int(_nQtd/2)+IIf(Int(_nQtd/2)<(_nQtd/2),1,0)
	For _I := 1 To _nQtd
		MSCBWrite("CT~~CD,~CC^~CT~")
		MSCBWrite("^XA~TA000~JSN^LT0^MNW^MTD^PON^PMN^LH0,0^JMA^PR4,4~SD15^JUS^LRN^CI0^XZ")
		MSCBWrite("^XA")
		MSCBWrite("^MMT")
		MSCBWrite("^PW607")
		MSCBWrite("^LL0160")
		MSCBWrite("^LS0")
		MSCBWrite("^BY2,3,64^FT46,130^B2N,,Y,N")
        MSCBWrite("^FD"+_cCB+"^FS")
		MSCBWrite("^FT26,30^A0N,17,16^FH\^FD"+SubStr(cDescr,1,30)+"^FS")
		MSCBWrite("^FT26,51^A0N,17,16^FH\^FD"+AllTrim(cLote)+"    "+cDtVal+"^FS")
		MSCBWrite("^BY2,3,64^FT366,130^B2N,,Y,N")
		MSCBWrite("^FD"+_cCB+"^FS")
		MSCBWrite("^FT346,30^A0N,17,16^FH\^FD"+SubStr(cDescr,1,30)+"^FS")
		MSCBWrite("^FT346,51^A0N,17,16^FH\^FD"+AllTrim(cLote)+"    "+cDtVal+"^FS")
		MSCBWrite("^PQ1,0,1,Y^XZ")
	Next _I
	MSCBEND()
	MSCBCLOSEPRINTER()
Return
