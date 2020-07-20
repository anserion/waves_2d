unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Grids, Buttons, ComCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Bevel1: TBevel;
    BTN_waves_N: TButton;
    Btn_redraw: TButton;
    BTN_gen_waves_rnd: TButton;
    BTN_gen_img_amp: TButton;
    CB_timer: TCheckBox;
    Edit_nx: TEdit;
    Edit_sx: TEdit;
    Edit_ny: TEdit;
    Edit_sy: TEdit;
    Edit_t: TEdit;
    Edit_dt: TEdit;
    Edit_Waves_N: TEdit;
    Edit_k_dist: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    PBox: TPaintBox;
    SG_waves: TStringGrid;
    Timer1: TTimer;
    UpDown_sy: TUpDown;
    UpDown_sx: TUpDown;
    procedure Btn_redrawClick(Sender: TObject);
    procedure BTN_gen_img_ampClick(Sender: TObject);
    procedure BTN_gen_waves_rndClick(Sender: TObject);
    procedure BTN_t_setClick(Sender: TObject);
    procedure BTN_waves_NClick(Sender: TObject);
    procedure CB_timerClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure UpDown_sxClick(Sender: TObject; Button: TUDBtnType);
    procedure UpDown_syClick(Sender: TObject; Button: TUDBtnType);
  private
    procedure Draw_img_amp;
    procedure Gen_waves_rnd;
    procedure Print_waves_to_grid;
    procedure get_params;
  public

  end;

type
  t_wave=record
    x,y:real;
    f,v:real;
    amp:real;
    phi:real;
  end;

var
  Form1: TForm1;
  SummaryBitmap:TBitmap;
  img_width,img_height:integer;
  dx,dy:integer;
  sx,sy:real;
  IMG_amp: array[0..512,0..512]of real;
  amp_width,amp_height:integer;
  N_waves: integer;
  waves: array[1..10000] of t_wave;
  t,dt:real;
  k_dist:real;

implementation

{$R *.lfm}

function wave_amp(f,A,phi,t:real):real;
begin
  wave_amp:=A*cos(f*t+phi);
end;

procedure gen_img_amp;
var i,x,y:integer; A_tmp,dist:real;
begin
  for y:=0 to amp_height-1 do
  for x:=0 to amp_width-1 do
    IMG_amp[x,y]:=128;

  for i:=1 to N_waves do
  begin
    for x:=0 to amp_width-1 do
    for y:=0 to amp_height-1 do
    begin
      dist:=sqrt(sqr(x-waves[i].x-sx)+sqr(y-waves[i].y-sy))*k_dist;
      A_tmp:=wave_amp(waves[i].f,waves[i].amp,waves[i].phi,dist+t*waves[i].v);
      IMG_amp[x,y]:=IMG_amp[x,y]+A_tmp;
    end;
  end;
end;

{ TForm1 }
procedure TForm1.get_params;
var i: integer;
begin
  sx:=StrToFloat(Edit_sx.text);
  sy:=StrToFloat(Edit_sy.text);

  amp_width:=StrToInt(Edit_nx.text);
  amp_height:=StrToInt(Edit_ny.text);
  dx:=img_width div amp_width;
  dy:=img_height div amp_height;

  t:=StrToFloat(Edit_t.text);
  dt:=StrToFloat(Edit_dt.text);

  k_dist:=StrToFloat(Edit_k_dist.text);

  for i:=1 to N_waves do
  begin
    waves[i].x:=StrToFloat(SG_waves.Cells[1,i]);
    waves[i].y:=StrToFloat(SG_waves.Cells[2,i]);
    waves[i].f:=StrToFloat(SG_waves.Cells[3,i]);
    waves[i].amp:=StrToFloat(SG_waves.Cells[4,i]);
    waves[i].phi:=StrToFloat(SG_waves.Cells[5,i]);
    waves[i].v:=StrToFloat(SG_waves.Cells[6,i]);
  end;
end;

procedure TForm1.Gen_waves_rnd;
var i:integer;
begin
  for i:=1 to N_waves do
  begin
    waves[i].x:=random(amp_width);
    waves[i].y:=random(amp_height);
    waves[i].f:=random(amp_width)*(2*pi)/amp_width;
    waves[i].amp:=random(50);
    waves[i].phi:=random(628)/100-pi/2;
    waves[i].v:=1;
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
    SG_waves.Cells[6,i]:=FloatToStr(waves[i].v);
  end;
end;

procedure TForm1.Draw_img_amp;
var i,x,y:integer; c:byte; tmp:LongInt; dst_ptr:PByte; dst_bpp:integer;
begin
  SummaryBitmap.BeginUpdate(false);
  dst_bpp:=SummaryBitmap.RawImage.Description.BitsPerPixel div 8;
  dst_ptr:=SummaryBitmap.RawImage.Data;
  for y:=0 to img_height-1 do
  for x:=0 to img_width-1 do
  begin
    C:=0; tmp:=trunc(IMG_amp[x div dx,y div dy]);
    if (tmp>=0)and(tmp<=255) then C:=tmp;
    if tmp<0 then C:=0;
    if tmp>255 then C:=255;
    dst_ptr^:=C; (dst_ptr+1)^:=C; (dst_ptr+2)^:=C;
    inc(dst_ptr,dst_bpp);
  end;
  SummaryBitmap.EndUpdate(false);
  PBox.Canvas.Draw(0,0,SummaryBitmap);

  PBox.Canvas.Pen.Color:=clRed;
  PBox.Canvas.Brush.Style:=bsClear;
  PBox.Canvas.Font.Color:=clRed;
  for i:=1 to N_waves do
  begin
    PBox.Canvas.EllipseC(
                  trunc(dx*(waves[i].x+sx)),trunc(dy*(waves[i].y+sy)),
                  trunc(waves[i].amp),trunc(waves[i].amp)
                  );
    PBox.Canvas.TextOut(trunc(dx*(waves[i].x+sx)),trunc(dy*(waves[i].y+sy)),IntToStr(i));
  end;

end;

procedure TForm1.Btn_redrawClick(Sender: TObject);
begin
  t:=0; Edit_t.Text:=floatToStr(t);
  get_params;
  gen_img_amp;
  Draw_img_amp;
end;

procedure TForm1.BTN_gen_img_ampClick(Sender: TObject);
begin
  get_params;
  gen_img_amp;
  Draw_img_amp;
end;

procedure TForm1.BTN_gen_waves_rndClick(Sender: TObject);
begin
  Gen_waves_rnd;
  Print_waves_to_grid;
  get_params;
  gen_img_amp;
  Draw_img_amp;
end;

procedure TForm1.BTN_t_setClick(Sender: TObject);
begin
  get_params;
  gen_img_amp;
  Draw_img_amp;
end;

procedure TForm1.BTN_waves_NClick(Sender: TObject);
begin
  N_waves:=StrToInt(Edit_Waves_N.text);
  SG_waves.RowCount:=N_waves+1;
  Print_waves_to_grid;
  get_params;
  gen_img_amp;
  Draw_img_amp;
end;

procedure TForm1.CB_timerClick(Sender: TObject);
begin
  if CB_timer.Checked then Timer1.Enabled:=true else Timer1.Enabled:=false;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  img_width:=PBox.width;
  img_height:=PBox.height;
  SummaryBitmap:=TBitmap.Create;
  SummaryBitmap.SetSize(img_width,img_height);

  timer1.Enabled:=false;
  N_waves:=2; Edit_Waves_N.text:=IntToStr(N_waves);

  sx:=0; sy:=0;
  Edit_sx.text:=FloatToStr(sx);
  Edit_sy.text:=FloatToStr(sy);

  amp_width:=StrToInt(Edit_nx.text);
  amp_height:=StrToInt(Edit_ny.text);
  dx:=img_width div amp_width;
  dy:=img_height div amp_height;
  dt:=-0.1; Edit_dt.text:=FloatToStr(dt);

  k_dist:=0.1;
  Edit_k_dist.text:=FloatToStr(k_dist);

  SG_waves.RowCount:=N_waves+1;
  SG_waves.Cells[0,0]:='';
  SG_waves.Cells[1,0]:='X';
  SG_waves.Cells[2,0]:='Y';
  SG_waves.Cells[3,0]:='f';
  SG_waves.Cells[4,0]:='amp';
  SG_waves.Cells[5,0]:='phi';
  SG_waves.Cells[6,0]:='v';
  Gen_waves_rnd;
  Print_waves_to_grid;
  get_params;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  t:=t+dt; //if t>2*pi then t:=0;
  Edit_t.Text:=floatToStr(t);
  //get_params;
  gen_img_amp;
  Draw_img_amp;
end;

procedure TForm1.UpDown_sxClick(Sender: TObject; Button: TUDBtnType);
begin
  Edit_sx.Text:=IntToStr(UpDown_sx.Position);
  get_params;
  gen_img_amp;
  Draw_img_amp;
end;

procedure TForm1.UpDown_syClick(Sender: TObject; Button: TUDBtnType);
begin
  Edit_sy.Text:=IntToStr(UpDown_sy.Position);
  get_params;
  gen_img_amp;
  Draw_img_amp;
end;

end.

