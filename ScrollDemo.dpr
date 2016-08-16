program ScrollDemo;

uses
  System.StartUpCopy,
  FMX.Forms,
  pScrollDemo in 'pScrollDemo.pas' {fScrollDemo};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfScrollDemo, fScrollDemo);
  Application.Run;
end.
