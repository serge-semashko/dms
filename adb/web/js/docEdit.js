// var frm=null;
var changed=false;
var aggr_to_cons="";

function setHist(txt)
{ frm.action.value = txt;
  docChanged();
}

function unlock()
{ setReadOnly(false);
  frm.cop.value="u";
  frm.submit();
//  save();
}

function docChanged(sum)
{ changed=true;
  document.getElementById("docStat").innerHTML="�������!";
//	if(sum) frm.SUM_CHANGED.value='Y';
  try
  { frm.cln.disabled=true; 
    frm.cld.disabled=true;
  } catch (e) {}

}

function send()
{ if (!checkFields()) return;
//  if (!confirm("�������� ����� ������ � �����������.\n\r ��������� ��������� ����� ����������")) return;
  frm.cop.value="s";
  frm.submit(); 
}

function respInfo()
{ var bc = frm.bc.value;
//  var pers = escape(frm.chief_sgn.value);
//  var tab_n = escape(frm.chief_code.value);
  var pers = frm.chief_sgn.value;
  var tab_n = frm.chief_code.value;
  if (pers.length > 1 || tab_n.length > 1) bc = "";
  if (bc.length > 3) bc = bc.substr(3); 
  openWindow("c=info/persons&back=y&f_search=" + pers
  + "&f_bc=" + bc + "&tab_n=" + tab_n, 'i_persons', 750, 550);
}

function setRespDate(dat)
{ if (frm.chief_sgn.value == "")
  { frm.chief_date.value="";
    frm.chief_code.value="";
  }
  else if (frm.chief_date.value=="")
    frm.chief_date.value=dat.substring(0,10);
  docChanged();
}

function finita()
{ if (changed)
  { if (!confirm("����������� �������� ���������\n\r\n\r�������� ��� �������!\n\r���� �� ������� ������ \"OK\", �� ��������� ����� ��������. \n\r\n\r����� ����� ����������� ��������� ���������, ������� \"������\". "))
    { //return save();
      return;
    }
  }
  if (frm.doc_changed.value == "y")
  	try {window.opener.refrSelf();} catch (e) {} 
  try {window.opener.focus();} catch (e) {}
  window.close();
}


function setApprovalDate(dat)
{ if (frm.approval.selectedIndex ==0)
    frm.approval_date.value="";
  else if (frm.approval_date.value=="")
    frm.approval_date.value=dat;
  docChanged();
}

function setReadOnly(ro)
{ for (i=0; i<frm.elements.length; i++)
  { try
    { frm.elements[i].readOnly=ro;
    }
    catch (e)
    {
      alert (frm.elements[i].name);
    }
    try
    { if (frm.elements[i].type.indexOf("select") >=0 )
      {  frm.elements[i].disabled=ro;
      }
    }
    catch (e)
    {
//      alert (i + ":" + frm.elements[i].type + ":" + frm.elements[i].name);
    }
  }
}

function checkFields()
{ // if (!checkFloat("summa_rub",null,null,"����� � ������")) return false;
// alert ("here-1");
  if (!checkFloat("summa_curr",null,null,"�����")) return false;
  if (!checkDate("doc_date", "���������", false)) return false;
  if (!checkDate("chief_date")) return false;

// alert ("here-2");
  try
  { if (getSelectedVal(frm.doc_type) == "0")
    { alert ("������� ��� ���������."); 
      return false;	
    } 
    if (!checkDate("approval_date")) return false;
    frm.approval.value=getSelectedText(frm.approval_c);
  }
  catch (e) {}
  return true;
}

function buhChanged()
{ if (frm.buh.checked)
    frm.action.value="� �����������";
  else if (frm.action.value=="� �����������")
    frm.action.value = "";
  frm.setChildren.value = "Y";
  docChanged();
}

function save_prix()
{ if (!checkFields()) return;
  if (!checkDate("PRIX_DAT", "�������", false)) return;
  frm.cop.value="uprix";
  frm.submit();
}


function getCode()
{ 
//  openWindow('c=info/bc/list&f_status=A&f_bc=' + frm.bc.value, 'bc_info', 700, 600);
  var lab= getSelectedVal(frm.lab_code);
  openWindow('c=info/bc/list&thisYearOnly=y&f_status=A&filtr=Y&is_prikaz=n&f_lab=' + lab, 'bc_info', 700, 600);
}

function pasteBcInfo(txt, labcode)
{ document.getElementById("bcodeDescr").innerHTML = txt; 
  selectOptionByVal(frm.lab_code, labcode);
}


function kontrInfo()
{ 
// var v =  encodeURIComponent(frm.receiver.value);
// var v =  escape(frm.receiver.value);
// v =  encodeURIComponent(v);
 // alert(v);
	openWindow("c=info/kontragent&inn=" + frm.inn_receiver.value
//  + "&name=" + v
//	+ "&name=" + encodeURIComponent(frm.receiver.value)
//	+ "&name=" + escape(frm.receiver.value)
	, 'i_kontragent', 600, 550);
}

function pasteKontragent(inn, code, name)
{ if (inn.length > 0)
    frm.inn_receiver.value = inn;
  if (name.length > 0)
    frm.receiver.value = name.replace(/~/g,'"');
  frm.receiver_c.value = code;
  docChanged();    
}

function currConvert()
{ var val = 0;
//  if (frm.summa_curr.value != "")
  	val = frm.summa_curr.value;
//  else
//  	val = frm.summa_rub.value;
  openWindow("c=info/currConvert&val=" + val
	+ "&curr_code=" + getSelectedVal(frm.curr_code)
	, 'currConvert', 600, 400);
}

function pasteCurrency(val, code)
{ // if (code==810)
 //    frm.summa_rub.value = val;
 //  else
  { frm.summa_curr.value = val;
  	selectOptionByVal(frm.curr_code, code);
    document.getElementById("sum_curr").innerHTML="";
  }
  docChanged();
}


function disableButtons()
{ frm.cls.disabled=true; 
  try
  { frm.cln.disabled=true; 
    frm.cld.disabled=true;  
  } catch (e) {}
}

function setCons()
{ var aggr = getSelectedVal(frm.aggr);
  var cons = getCons(aggr);
  if (cons.length > 0) 
    selectOptionByVal(frm.cons,cons);
  docChanged();
}

function getCons(aggr)
{ var i = aggr_to_cons.indexOf(aggr + ":");
  if (i >= 0) 
   return aggr_to_cons.substring(i+3, i+4);
  else
   return "";
}

function checkAggr()
{ var aggr = getSelectedVal(frm.aggr);
  var cons = getCons(aggr);
  if (cons != getSelectedVal(frm.cons))  
    frm.aggr.options[0].selected=true;
  docChanged();    
}

function setInput(inp, className, readOnly, value)
{ inp.className=className;
  inp.readOnly=readOnly;
  if (typeof value != "undefined") inp.value = value;
}


function undelete()
{ frm.cop.value="ud";
  frm.submit();
}

function createNew()
{ frm.cop.value="c";
  frm.submit();
}

function clone()
{ frm.cop.value="clone";
  setReadOnly(false);
  frm.submit();
}

function makeChild(docID)
{ // alert ("makeChild-1");
  frm.cop.value="child";
  frm.PID.value=docID;
//  alert ("makeChild-2");
  setReadOnly(false);
//  alert ("makeChild-3");
  frm.submit();
}

function save_p()
{ if (!checkFields()) return;
  if (!checkDate("DAT_PLAT_1", "���������� ���������", false)) return;
  if (!checkDate("DAT_PLAT_2", "2-�� ���������� ���������", false)) return;
  frm.cop.value="up";
  frm.submit();
}

function save()
{ 
// alert ("save-1");
  if (!checkFields()) return;
// alert ("save-2");
  if (!checkDate("DAT_PLAT_1", "���������� ���������", false)) return;
  frm.cop.value="u";
// alert ("3");
 frm.submit();
}

function setInfo() {document.theForm.info.value='�� ���.��������';}

function showPlat()
{ var d = document.getElementById("setPlat");
  if (d.style.display == "none")
    d.style.display = "block";
  else
    d.style.display = "none";
}  

function showPrixod()
{ try
  { var d = document.getElementById("setPrix");
    if (d.style.display == "none")
      d.style.display = "block";
    else
      d.style.display = "none";
  }
  catch (e) {}
}

function showActions()
{ d = document.getElementById("actions");
  if (d.style.display == "none")
  { d.style.display = "block";
  }
  else
  { d.style.display = "none";
  }
}
