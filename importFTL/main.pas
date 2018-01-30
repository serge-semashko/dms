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
 c1,c2,c3,str1       :string;
 WUName,wupref,wunum,Holder,startdate   :string;
 prevcolor,newcolor ,colindex:           int64;
 CostWU    :double;
 OutRow :integer;
 prj : integer;
 topic, project, fte,prstr, outstr,post, fio, tab_n : string;
 ff : tfilestream;
 ffsql : tfilestream;
 fte_perc : Integer;
begin
  DeleteFile(ExtractFilePath(Application.ExeName)+'out.txt');
  DeleteFile(ExtractFilePath(Application.ExeName)+'sql.txt');
  ff := TFileStream.Create(ExtractFilePath(Application.ExeName)+'out.txt',fmcreate);
  ffsql := TFileStream.Create(ExtractFilePath(Application.ExeName)+'sql.txt',fmcreate);
  if sheetlist.SelCount<1 then exit;
  for sel:=0 to sheetlist.Items.Count-1 do begin
    if not sheetlist.Selected[sel] then continue;
    sheetin:=XLAppIn.Workbooks[1].WorkSheets[sel+1];
    for xrow:=13 to 2000 do begin
       post := trim(sheetin.cells[xrow,6]);
       fio:=trim(sheetin.cells[xrow,7]);
       tab_n := trim(sheetin.cells[xrow,8].value);
       if Trim(tab_n)='' then Continue;
       outstr := tab_n+' '+fio+' ';
       for prj:= 48 to 71 do begin
         if trim(sheetin.cells[xrow,8]) = '' then Continue;
         topic := sheetin.cells[6,prj] ;
         if projects[prj] <>'' then
           project := projects[prj]
         else begin
           project := sheetin.cells[5,prj];
           projects[prj] := project;
         end;
         fte := sheetin.cells[xrow,prj];
         DecimalSeparator := '.';
         if Trim(fte) <> ''  then begin
           fte := StringReplace(fte,',','.',[rfReplaceAll]);

           fte_perc := Round(strtofloat(fte)*100);
           outstr := tab_n   +fio+' '+' '+topic+ ' '+project+' '+' '+IntToStr(fte_perc)+' '+#13;
           ff.Write(outstr[1],Length(outstr));
           outstr := 'insert FTE (tab_n,topic_id,project_id,percent, changed_by) values('+tab_n+', '+topic+', '+
           'ifnull((select id from projects where short_name like "'+project+'%"),'+IntToStr(-xrow+13)+'),'+IntToStr(fte_perc)+',-1);'+#13;
           ffsql.Write(outstr[1],Length(outstr));
         end;
       end;
    end;
  end;
   xlappIn.visible:=true;
   ff.free;
   ffsql.free;
end;

end.
