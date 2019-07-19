unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Grids;

type

  { TForm1 }

  TForm1 = class(TForm)
    Bevel1: TBevel;
    BTN_waves_N: TButton;
    Btn_redraw: TButton;
    BTN_gen_waves_rnd: TButton;
    BTN_gen_waves_table: TButton;
    BTN_gen_img_amp: TButton;
    BTN_t_set: TButton;
    CB_timer: TCheckBox;
    Edit_t: TEdit;
    Edit_Waves_N: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    PBox: TPaintBox;
    SG_waves: TStringGrid;
    Timer1: TTimer;
    procedure Btn_redrawClick(Sender: TObject);
    procedure BTN_gen_img_ampClick(Sender: TObject);
    procedure BTN_gen_waves_rndClick(Sender: TObject);
    procedure BTN_gen_waves_tableClick(Sender: TObject);
    procedure BTN_t_setClick(Sender: TObject);
    procedure BTN_waves_NClick(Sender: TObject);
    procedure CB_timerClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    procedure Draw_img_amp;
    procedure Gen_waves_rnd;
    procedure Print_waves_to_grid;
  public

  end;

type
  t_wave=record
    x,y:real;
    f:real;
    amp:real;
    phi:real;
  end;

var
  Form1: TForm1;
  IMG_amp: array[0..512,0..512]of real;
  N_waves: integer;
  waves: array[1..10000] of t_wave;
  t:real;

implementation

{$R *.lfm}

function wave_amp(f,A,phi,t:real):real;
begin
  wave_amp:=A*cos(f*t+phi);
end;

procedure gen_img_amp;
var i,x,y:integer; A_tmp,dist:real;
begin
  for y:=0 to 511 do
  for x:=0 to 511 do
    IMG_amp[x,y]:=128;

  for i:=1 to N_waves do
  begin
    for x:=0 to 511 do
    for y:=0 to 511 do
    begin
      dist:=2*Pi*sqrt(sqr(x-waves[i].x)+sqr(y-waves[i].y))/512.0;
      A_tmp:=wave_amp(waves[i].f,waves[i].amp,waves[i].phi,dist+t);
      IMG_amp[x,y]:=IMG_amp[x,y]+A_tmp;
    end;
  end;
end;

{ TForm1 }
procedure TForm1.Gen_waves_rnd;
var i:integer;
begin
  for i:=1 to N_waves do
  begin
    waves[i].x:=random(512);
    waves[i].y:=random(512);
    waves[i].f:=random(512)*(2*pi)/512;
    waves[i].amp:=random(50);
    waves[i].phi:=random(628)/100-pi/2;
  end;
end;

procedure TForm1.Print_waves_to_grid;
var i:integer;
begin
  for i:=1 to N_waves do
  begin
    SG_waves.Cells[0,i]:=IntToStr(i);
    SG_waves.Cells[1,i]:=FloatToStr(waves[i].x);
    SG_waves.Cells[2,i]:=FloatToStr(waves[i].y);
    SG_waves.Cells[3,i]:=FloatToStr(waves[i].f);
    SG_waves.Cells[4,i]:=FloatToStr(waves[i].amp);
    SG_waves.Cells[5,i]:=FloatToStr(waves[i].phi);
  end;
end;

procedure TForm1.Draw_img_amp;
var i,x,y:integer; c:TColor; tmp:LongInt;
begin
  for y:=0 to 511 do
  for x:=0 to 511 do
  begin
    C:=0; tmp:=trunc(IMG_amp[x,y]);
    if (tmp>=0)and(tmp<=255) then C:=tmp;
    if tmp<0 then C:=0;
    if tmp>255 then C:=255;
    PBox.Canvas.Pixels[x,y]:=C+256*C+256*256*C;
  end;

  PBox.Canvas.Pen.Color:=clRed;
  PBox.Canvas.Brush.Style:=bsClear;
  PBox.Canvas.Font.Color:=clRed;
  for i:=1 to N_waves do
  begin
    PBox.Canvas.EllipseC(
                  trunc(waves[i].x),trunc(waves[i].y),
                  trunc(waves[i].amp),trunc(waves[i].amp)
                  );
    PBox.Canvas.TextOut(trunc(waves[i].x),trunc(waves[i].y),IntToStr(i));
  end;
end;

procedure TForm1.Btn_redrawClick(Sender: TObject);
begin
  t:=0; Edit_t.Text:=floatToStr(t);
  gen_img_amp;
  Draw_img_amp;
end;

procedure TForm1.BTN_gen_img_ampClick(Sender: TObject);
begin
  gen_img_amp;
  Draw_img_amp;
end;

procedure TForm1.BTN_gen_waves_rndClick(Sender: TObject);
begin
  Gen_waves_rnd;
  Print_waves_to_grid;
  gen_img_amp;
  Draw_img_amp;
end;

procedure TForm1.BTN_gen_waves_tableClick(Sender: TObject);
var i:integer;
begin
  for i:=1 to N_waves do
  begin
    waves[i].x:=StrToFloat(SG_waves.Cells[1,i]);
    waves[i].y:=StrToFloat(SG_waves.Cells[2,i]);
    waves[i].f:=StrToFloat(SG_waves.Cells[3,i]);
    waves[i].amp:=StrToFloat(SG_waves.Cells[4,i]);
    waves[i].phi:=StrToFloat(SG_waves.Cells[5,i]);
  end;
  gen_img_amp;
  Draw_img_amp;
end;

procedure TForm1.BTN_t_setClick(Sender: TObject);
begin
  t:=StrToFloat(Edit_t.text);
  gen_img_amp;
  Draw_img_amp;
end;

procedure TForm1.BTN_waves_NClick(Sender: TObject);
begin
  N_waves:=StrToInt(Edit_Waves_N.text);
  SG_waves.RowCount:=N_waves+1;
  Print_waves_to_grid;
  gen_img_amp;
  Draw_img_amp;
end;

procedure TForm1.CB_timerClick(Sender: TObject);
begin
  if CB_timer.Checked then Timer1.Enabled:=true else Timer1.Enabled:=false;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  timer1.Enabled:=false;
  N_waves:=8; Edit_Waves_N.text:=IntToStr(N_waves);

  SG_waves.RowCount:=N_waves+1;
  SG_waves.Cells[0,0]:='';
  SG_waves.Cells[1,0]:='X';
  SG_waves.Cells[2,0]:='Y';
  SG_waves.Cells[3,0]:='f';
  SG_waves.Cells[4,0]:='amp';
  SG_waves.Cells[5,0]:='phi';
  Gen_waves_rnd;
  Print_waves_to_grid;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  t:=t+0.1; //if t>2*pi then t:=0;
  gen_img_amp;
  Draw_img_amp;
  Edit_t.Text:=floatToStr(t);
end;

end.

