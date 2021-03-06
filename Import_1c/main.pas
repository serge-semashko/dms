unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, Menus,comobj;

type
  Tmainform = class(TForm)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Open1: TMenuItem;
    SaveAs1: TMenuItem;
    Exit1: TMenuItem;
    Panel1: TPanel;
    StatusBar1: TStatusBar;
    SheetList: TListBox;
    od: TOpenDialog;
    procedure Open1Click(Sender: TObject);
    procedure SaveAs1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    XLAppIn,XLAppOut :variant;
  end;

var
  mainform: Tmainform;
  projects : array[0..200] of string;
implementation

{$R *.dfm}

procedure Tmainform.Open1Click(Sender: TObject);
var
 i:integer;
begin
  for i:=0 to 200 do projects[i] := '';
 od.FileName :=ExtractFilePath(application.ExeName)+'1.xls';
 if not od.Execute then exit;
  XLAppIn:= CreateOleObject('Excel.Application');
  xlappIn.visible:=true;
//  XLApp.Workbooks.Add;
  xlappIn.Workbooks.Open(od.FileName);
  sheetlist.Items.Clear;
  for i:=1 to XLAppIn.Workbooks[1].Sheets.count do begin;
    sheetlist.Items.add(XLAppIn.Workbooks[1].WorkSheets[i].Name);
  end;

end;

procedure Tmainform.SaveAs1Click(Sender: TObject);
var
 i:integer;
 sel :integer;
 sheet :variant;
 sheetin,ColumnRange :variant;
 xrow,xcol,wuPos :integer;
 i1,i2,i3 :integer;
 r1,r2,r3 :integer;
 c1,c2,c3,str1       :string;
 WUName,wupref,wunum,Holder,startdate   :string;
 prevcolor,newcolor ,colindex:           int64;
 CostWU    :double;
 OutRow :integer;
 prj : integer;
 prstr, outstr,post, fio, tab_n : string;
 ff : tfilestream;
 ffsql : tfilestream;
 fte_perc : double;
 oklad, itogo, stavka, rvu, fix, percent : string;


 var strn : string;
begin
  DeleteFile(ExtractFilePath(Application.ExeName)+'out.txt');
  DeleteFile(ExtractFilePath(Application.ExeName)+'import1c.sql');
  ff := TFileStream.Create(ExtractFilePath(Application.ExeName)+'out.txt',fmcreate);
  ffsql := TFileStream.Create(ExtractFilePath(Application.ExeName)+'import1c.sql',fmcreate);
  if sheetlist.SelCount<1 then exit;
  for sel:=0 to sheetlist.Items.Count-1 do begin
    if not sheetlist.Selected[sel] then continue;
    sheetin:=XLAppIn.Workbooks[1].WorkSheets[sel+1];
         DecimalSeparator := '.';
    for xrow:=1 to 2000 do begin
      strn := '#'+IntToStr(xrow)+' ';
       post := trim(sheetin.cells[xrow,3]);
        fio:=''''+trim(sheetin.cells[xrow,2])+'''';
        tab_n := trim(sheetin.cells[xrow,1].value);
        if Trim(tab_n)='' then Continue;
        val(tab_n,r1,r2);
        if (r2>0) then Continue;

        post:=trim(sheetin.cells[xrow,3]);

        oklad:=trim(sheetin.cells[xrow,5].value);
        if trim(oklad)='' then fix := '0';
        val(oklad,r1,r2);
        if (r2>0) then Continue;

        stavka:=trim(sheetin.cells[xrow,6].value);

        rvu:=trim(sheetin.cells[xrow,7].value);
        if trim(RVU)='' then RVU := '0';

        fix:=trim(sheetin.cells[xrow,8].value);
        if trim(fix)='' then fix := '0';
        val(fix,r1,r2);
        if (r2>0) then Continue;

        percent:=trim(sheetin.cells[xrow,9].value);
        if trim(percent)='' then percent := '0';

        itogo:=trim(sheetin.cells[xrow,11].value);
        if trim(itogo)='' then itogo := '0';

        outstr := 'insert oklad_agr (fio, tab_n,oklad_1c,doplati_abs_1c,doplati_percent_1c, rvu_1c, stavka_1c, itogo_1c ) values('
        +fio+', '
        +tab_n+', '
        +oklad+', '
        +fix+', '
        +percent+', '
        +rvu+', '
        +stavka+', '
        +itogo
        +') on duplicate key update '
        +'fio='+fio
        +', oklad_1c='+oklad
        +', doplati_abs_1c='+fix
        +', doplati_percent_1c='+percent
        +';'+#13;
        ffsql.Write(outstr[1],Length(outstr));
    end;
  end;
   xlappIn.visible:=true;
   ff.free;
   ffsql.free;
end;

end.
procedure Tmainform.SheetListDblClick(Sender: TObject);
begin

end;


