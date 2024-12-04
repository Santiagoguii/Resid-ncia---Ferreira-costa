unit Home;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.Imaging.pngimage, VendaFc, Vcl.Imaging.jpeg, Consulta, Vcl.Buttons;

type
  TfrmHome = class(TForm)
    TelaFundo: TImage;
    Image1: TImage;
    BitBtnVenda: TBitBtn;
    BitBtnConsulta: TBitBtn;
    procedure BitBtnVendaClick(Sender: TObject);
    procedure BitBtnConsultaClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmHome: TfrmHome;

implementation

{$R *.dfm}

procedure TfrmHome.BitBtnConsultaClick(Sender: TObject);
begin
  FormConsultas := TFormConsultas.Create(Self);
   try
    FormConsultas.ShowModal;
   finally
    FormConsultas.Free;
    FormConsultas := nil;
   end;
end;

procedure TfrmHome.BitBtnVendaClick(Sender: TObject);
begin
  FormVenda := TFormVenda.Create(Self);
  try
    FormVenda.ShowModal;
  finally
    FormVenda.Free;
  end;
end;
end.
