function varargout = verify(varargin)
% VERIFY MATLAB code for verify.fig
%      VERIFY, by itself, creates a new VERIFY or raises the existing
%      singleton*.
%
%      H = VERIFY returns the handle to a new VERIFY or the handle to
%      the existing singleton*.
%
%      VERIFY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VERIFY.M with the given input arguments.
%
%      VERIFY('Property','Value',...) creates a new VERIFY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before verify_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to verify_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help verify

% Last Modified by GUIDE v2.5 09-Apr-2017 22:40:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @verify_OpeningFcn, ...
                   'gui_OutputFcn',  @verify_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before verify is made visible.
function verify_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to verify (see VARARGIN)

% Choose default command line output for verify
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes verify wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = verify_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in savebtn.
function savebtn_Callback(hObject, eventdata, handles)

% --- Executes on button press in output_folder_btn.
function output_folder_btn_Callback(hObject, eventdata, handles)
output_folder_name = uigetdir('D:\DJIMY\test');
%stop if the user press cancel or close the dialog box
if output_folder_name == 0
    return;
end

handles.output_folder_name = output_folder_name;
set(handles.output_folder_btn, 'Enable', 'off');

initView(hObject, handles);
handles = guidata(hObject);

guidata(hObject, handles);

% --- Executes on button press in input_folder_btn.
function input_folder_btn_Callback(hObject, eventdata, handles)
input_folder_name = uigetdir('D:\DJIMY\test');
%stop if the user press cancel or close the dialog box
if input_folder_name == 0
    return;
end

handles.input_folder_name = input_folder_name;

set(handles.input_folder_btn, 'Enable', 'off');
set(handles.output_folder_btn, 'Enable', 'on');
guidata(hObject, handles);

%function to initialize the parameters
function initView(hObject, handles)
%retrieve the files
src_im = dir(strcat(handles.input_folder_name, '\*_bw.bmp'));
src_anchor_pos = dir(strcat(handles.input_folder_name, '\*_info.txt'));

%check whether the folders are valid
imcounter = length(src_im);
poscounter = length(src_anchor_pos);
if imcounter == 0 || poscounter == 0 || imcounter - poscounter ~= 0
    errordlg('Invalid folder or number of files', 'error', 'modal');
    set(handles.input_folder_btn, 'Enable', 'on');
    return;
end

%get initial fileindex
fileid = fopen(fullfile(handles.input_folder_name, 'config.txt'), 'r');
if fileid == -1
   index = 1; 
else
   index = fscanf(fileid, '%d');
   fclose(fileid);
end

%==================================================
%anchor pos
filename = src_anchor_pos(index).name;
filepath = fullfile(handles.input_folder_name, filename);
set(handles.posfilename_label, 'String', filename);

%center points of the anchors
pos = pointsFromFile(filepath);

%compute coordinates
main_rect_pos(1, :) = [pos(1, 1) pos(1, 2) pos(5, 1)-pos(1, 1) pos(2, 2)-pos(1, 2)];
main_rect_pos(2, :) = [pos(2, 1) pos(2, 2) pos(6, 1)-pos(2, 1) pos(3, 2)-pos(2, 2)];
main_rect_pos(3, :) = [pos(3, 1) pos(3, 2) pos(7, 1)-pos(3, 1) pos(4, 2)-pos(3, 2)];
handles.main_rect_pos = main_rect_pos;
%====================================================


%initialize some gui objects
handles.src_im = src_im;
handles.src_anchor_pos = src_anchor_pos;
handles.fileindex_max = length(src_im);
handles.fileindex_current = index;
handles.current_section_index = 1;

setView(hObject, handles);
set(handles.savebtn, 'Enable', 'on');
handles = guidata(hObject);

guidata(hObject, handles);

%function to display the images on the differents views
function setView(hObject, handles)
%display the image at fileindex_current
index = handles.fileindex_current;
fname = fullfile(handles.input_folder_name, handles.src_im(index).name);

%current image
im = imread(fname);
handles.current_im = im;

%plot to main_axes
h = imshow(im, 'Parent', handles.main_axes);

%plot to section_axes
imagesc(im, 'Parent', handles.section_axes);

%update info displayed on the gui
set(handles.imfilename_label, 'String', handles.src_im(index).name);
counter = strcat(num2str(index), '/', num2str(handles.fileindex_max));
set(handles.counter_label, 'String', counter);

%display the draggable rectangles
setDraggables(hObject, handles);
handles = guidata(hObject);

%set callbacks
set(h, 'ButtonDownFcn', {@setFocus, handles, 0, 1});

%increment the current file position
guidata(hObject, handles);

function setDraggables(hObject, handles)
%center points of the anchors
pos = handles.main_rect_pos(1, :);

%set the position of the draggables on the main image
axes(handles.main_axes);
handles.main_rect = rectangle('Position',pos, 'EdgeColor','r');

%set the position of the draggables on the section_view
axes(handles.section_axes);
xlim([pos(1) pos(3)+pos(1)-450]);
ylim([pos(2) pos(2)+pos(4)-100]);

% Update handles structure
guidata(hObject, handles);

function pos = pointsFromFile(filepath)
%extract the positions
fileid = fopen(filepath, 'r');
file = textscan(fileid, '%d %f %f','HeaderLines', 1, 'Whitespace',' \b\t:(,)');
pos = [file{1, 2} file{1, 3}];
fclose(fileid);

function setFocus(hObject, eventdata, handles, index, position)
found = 0;

if index
   idx = handles.current_section_index;
   pos = handles.main_rect_pos(idx, :);
   found = 1;
elseif position
    %get the current position
    points = get(gca, 'CurrentPoint');
    
    %get it's index
    x = points(1, 1);
    y = points(1, 2);
    for t=1:3
       pos = handles.main_rect_pos(t, :);
       %if points is in main_rect_pos
       if x >= pos(1) && x <= pos(1)+pos(3) && y >= pos(2) && y <= pos(2)+pos(4)
           found = 1;
           break;
       end
    end
end

if ~found
    return;
end

%update gui
handles.main_rect.Position = pos;
axes(handles.section_axes);
xlim([pos(1) pos(3)+pos(1)-450]);
ylim([pos(2) pos(2)+pos(4)]-100);

% Update handles structure
guidata(hObject, handles);
