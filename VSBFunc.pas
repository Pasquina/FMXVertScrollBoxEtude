unit VSBFunc;

{
   Copyright © 2016 Milan Vydareny

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

	For more information contact:
	Milan Vydareny
	Milan@VyDevSoft.com

}

interface

uses
  FMX.Layouts, FMX.Types, FMX.Forms, FMX.Controls, System.Classes, System.Types, FMX.Dialogs, FMX.Memo,
  System.SysUtils, System.Math;

type

  TVyDVSBHelper = class(TComponent)
  private
    FVScrollBox: TVertScrollBox;
    FFocusedAbsY: Integer;
    FFormOwner: TForm;
    FShiftAmtRequired: Integer;
    FVKAbsY: Integer;
    FMemoBox: TMemo;
    procedure SetVScrollBox(const Value: TVertScrollBox);
    procedure VirtualKeyboardShown(
      Sender: TObject;
      KeyboardVisible: Boolean;
      const Bounds: TRect);
    procedure VirtualKeyboardHidden(
      Sender: TObject;
      KeyboardVisible: Boolean;
      const Bounds: TRect);
    procedure FormFocusChanged(Sender: TObject);
    procedure ResetViewport;
    procedure SetFocusedAbsY(const Value: Integer);
    procedure SetFormOwner(const Value: TForm);
    procedure SetShiftAmtRequired(const Value: Integer);
    procedure ShiftViewport;
    procedure CalcContentBounds(
      Sender: TObject;
      var ContentBounds: TRectF);
    procedure SetVKAbsY(const Value: Integer);
    procedure SetMemoBox(const Value: TMemo);
    property FocusedAbsY: Integer read FFocusedAbsY write SetFocusedAbsY;
    property FormOwner: TForm read FFormOwner write SetFormOwner;
    property ShiftAmtRequired: Integer read FShiftAmtRequired write SetShiftAmtRequired;
    property VKAbsY: Integer read FVKAbsY write SetVKAbsY;
    procedure SetupContentBounds;
    procedure LogFocused(Sender: TObject);
    procedure LogVK(Sender: TObject; KeyBoardVisible: Boolean; const Bounds: TRect; KBAction: String);

  protected
  public
    Constructor Create(AOwner: TComponent); override;
  published
    property VScrollBox: TVertScrollBox read FVScrollBox write SetVScrollBox;
    property MemoBox: TMemo read FMemoBox write SetMemoBox;
  end;

procedure Register;

implementation

{$M+}

procedure Register;
begin
  GroupDescendentsWith(TVyDVSBHelper,                // Allows IDE to distinguish between
    FMX.Types.TFMXObject);                           // Firemonkey and VCL only classes

  RegisterFmxClasses([TVyDVSBHelper]);

  RegisterComponents('VSB Helper', [TVyDVSBHelper]);
end;


{ TVyDVSBHelper }

{ This event is fired when the RealignContent method is invoked. It is the only way
  to change the ContentBounds. The new Bottom Bound is the client height plus the
  shift amount required. This will ensure sufficient size for the shift. }

procedure TVyDVSBHelper.CalcContentBounds(
  Sender: TObject;
  var ContentBounds: TRectF);
begin
  if ShiftAmtRequired > 0 then                                    // if no shift do not override Content Bounds
  begin
    ContentBounds.Bottom := VScrollBox.Height + ShiftAmtRequired; // make sure there's enough space
  end;
end;

{ The constructor saves a pointer to the form. Additionally, create sets event method
  pointers in the form that will be used during program execution. }

constructor TVyDVSBHelper.Create(AOwner: TComponent);
begin
  inherited;
  FFormOwner := TForm(AOwner);                                 // save the form owner object
  FFormOwner.OnVirtualKeyboardShown := VirtualKeyboardShown;   // set the VK Shown event
  FFormOwner.OnVirtualKeyboardHidden := VirtualKeyboardHidden; // set the VK Hidden event
  FFormOwner.OnFocusChanged := FormFocusChanged;               // set the focus change event
end;

{ Setting up the OnCalcContenBonds event is handled just before the RealignContent method
  is invoked. The VScrollBox parameter is not available at Create time to do this. (It's
  value is nil.) }

procedure TVyDVSBHelper.SetupContentBounds;
begin
  Assert(Assigned(VScrollBox), 'Vertical Scroll Box property must be assigned.');
  VScrollBox.OnCalcContentBounds := CalcContentBounds; // set the scroll box Calc Contents Bounds event
  VScrollBox.RealignContent;                           // Realign and set bounds
end;

{ Occurs whenever the focus changes. If a component has the focus the Y coordinate is
  determined and compared to the saved Y coordinate. If they are different, the new
  Y is saved and the adjust viewport routine is invoked by the setter. }

procedure TVyDVSBHelper.FormFocusChanged(Sender: TObject);
var
  LFocused: TControl;                                    // the focused object
begin
  if Assigned(FormOwner.Focused) then                    // test for focused object located
  begin
    LFocused := TControl(FormOwner.Focused.GetObject);   // get focused object
    FocusedAbsY := Trunc(LFocused.AbsoluteRect.Bottom +  // get Y coordinate
      VScrollBox.ViewportPosition.Y);
  end
  else
  begin
    FocusedAbsY := 0;                                    // no object focused
  end;
  LogFocused(Sender);
end;

{ This debugging routine exits immediately if a memo box is not assigned as a
  component property. If assigned, the newly focused object information is logged
  as the Sender class name, the focused class name, the focused object name and
  the absolute bottom of the focused object.  }

procedure TVyDVSBHelper.LogFocused(Sender: TObject);
var
  LSender: String;                                            // class name of sender
  LFocused: TFMXObject;                                       // the focused object
  LFocusedClass: String;                                      // the focused class
  LFocusedName: String;                                       // the focused component name
begin
  if not Assigned(FMemoBox) then
    Exit;
  if Assigned(Sender) then                                    // test for null sender
    LSender := Sender.ToString                                // if assigned get class name
  else
    LSender := '<Null>';                                      // unassigned are null

  if Assigned(FormOwner.Focused) then                         // test for FormOwner.Focused object located
  begin
    LFocused := FormOwner.Focused.GetObject;                  // get FormOwner.Focused object
    LFocusedClass := LFocused.ClassName;                      // get FormOwner.Focused object class name
    LFocusedName := LFocused.Name;                            // get focused object component name
  end
  else
  begin
    LFocusedClass := '<Unknown>';                             // unknown class name
    LFocusedName := '<Unknown>';                              // unknown component name
  end;

  MemoBox.Lines.Add(Format('Sender: %s; Focused: %s, %s, %u', // log the focus message
    [LSender, LFocusedClass, LFocusedName, FocusedAbsY]));
end;

{ Debugging log routine displays characteristics of the VK each time the KB is displayed
  or hidden. This common routine is used by both the display and hide events. }

procedure TVyDVSBHelper.LogVK(
  Sender: TObject;
  KeyboardVisible: Boolean;
  const Bounds: TRect;
  KBAction: String);                                            // string set by caller either "Display" or "Hide"
var
  LSender: String;
begin
  if not Assigned(FMemoBox) then                                // only log if MemoBox property is assigned
    Exit;
  if Assigned(Sender) then                                      // test for null sender
    LSender := Sender.ToString                                  // if assigned get class name
  else
    LSender := '<Null>';                                        // unassigned are null
  MemoBox.Lines.Add(Format(                                     // log the hidden event
    'Sender: %s; %s: V: %s; T: %d; W: %d; H: %d; X: %d; Y: %d', // parameter format string
    [Sender.ToString, KBAction, BoolToStr(KeyboardVisible, True), Bounds.Top,
    Bounds.Width, Bounds.Height, Bounds.Location.X, Bounds.Location.Y]))
end;

{ Restores the scroll box viewport to its default position at the upper left corner of the scroll box. }

procedure TVyDVSBHelper.ResetViewport;
begin
  VScrollBox.ViewportPosition := PointF(0, 0); // set viewport to upper left corner of scroll box
  ShiftAmtRequired := 0;                       // no shift required when reset
  SetupContentBounds;                          // this causes the OnCalcContentsBottom event to fire
end;

{ Besides being a setter, this invokes the ShiftViewPort routine if the Y value of the
  Control has changed.  }

procedure TVyDVSBHelper.SetFocusedAbsY(const Value: Integer);
begin
  if Value <> FFocusedAbsY then
  begin
    FFocusedAbsY := Value;
    ShiftViewPort;
  end;
end;

procedure TVyDVSBHelper.SetFormOwner(const Value: TForm);
begin
  FFormOwner := Value;
end;

procedure TVyDVSBHelper.SetMemoBox(const Value: TMemo);
begin
  FMemoBox := Value;
end;

procedure TVyDVSBHelper.SetShiftAmtRequired(const Value: integer);
begin
  FShiftAmtRequired := Value;
end;

{ Besides being a setter, this invokes the ShiftViewPort routine if the Y value of the
  Virtual Keyboard has changed.  }

procedure TVyDVSBHelper.SetVKAbsY(const Value: integer);
begin
  if Value <> FVKAbsY then
  begin
    FVKAbsY := Value;
    ShiftViewPort;
  end;
end;

procedure TVyDVSBHelper.SetVScrollBox(const Value: TVertScrollBox);
begin
  FVScrollBox := Value;
end;

{ The Viewport is shifted by calculating the offset required based on the current
  position of the control with focus and the height of the Virtual Keyboard. After
  the offset is determined, RealignContent is used to adjust the Content Bottom.
  Then follows the Viewport positioning. }

procedure TVyDVSBHelper.ShiftViewport;
begin
  if VKAbsY = 0 then                                   // VK Absolute Y of zero indicates no KB visible
  begin
    ResetViewport;                                     // reset viewport to no shift
    Exit;                                              // quit right away
  end;
  ShiftAmtRequired := FocusedAbsY - VKAbsY;
  if ShiftAmtRequired < 0 then                         // no shift required
  begin
    ResetViewport;                                     // reset viewport to no shift
    Exit;                                              // quit right away
  end;
  SetupContentBounds;                                  // this causes the OnCalcContentsBottom event to fire
  VScrollBox.ViewportPosition :=                       // set viewport to upper left corner of scroll box
    PointF(0, ShiftAmtRequired);
end;

{ When the Virtual Keyboard is shown, this routine obtains the Absolute Y coordinate
  of the VK top. A little hacking is required because the Bounds of the Keyboard
  are not reliably returned. The new VK Y coordinate is saved. The setter shifts
  the viewport if needed. }

procedure TVyDVSBHelper.VirtualKeyboardShown(
  Sender: TObject;
  KeyboardVisible: Boolean;
  const Bounds: TRect);
begin
  LogVK(Sender, KeyboardVisible, Bounds, 'Shown');
  if Bounds.Height = 25 then // bogus height reported
    if VKAbsY <> 0 then      // if there is a prior value
      Exit                   // just reuse it
    else                     // otherwise
      VKAbsY := 381          // take a guess
  else
    VKAbsY := Bounds.Top;    // reported value returned
end;

{ When the virtual keyboard is hidden, this routine resets the VK Y coordinate
  to zero. The Viewport Reset routine is invoked if needed by the setter. }

procedure TVyDVSBHelper.VirtualKeyboardHidden(
  Sender: TObject;
  KeyboardVisible: Boolean;
  const Bounds: TRect);
begin
  VKAbsY := 0;
  LogVK(Sender, KeyboardVisible, Bounds, 'Hidden');
end;

end.
