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

% Last Modified by GUIDE v2.5 05-Apr-2017 18:59:16

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
output_folder_name = uigetdir('C:\Users\kkmlover\Documents\DJIMY\WORK');
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
input_folder_name = uigetdir('C:\Users\kkmlover\Documents\DJIMY\WORK');
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

%initialize some gui objects
handles.src_im = src_im;
handles.src_anchor_pos = src_anchor_pos;
handles.fileindex_max = length(src_im);
handles.fileindex_current = index;

% setView(hObject, handles);
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
imshow(im, 'Parent', handles.fullimage_axes);

%plot to section_axes


%update info displayed on the gui
set(handles.imfile, 'String', handles.src_im(index).name);
counter = strcat(num2str(index), '/', num2str(handles.fileindex_max));
set(handles.filecounter, 'String', counter);

%display the draggable rectangles
setDraggables(hObject, handles);
handles = guidata(hObject);

%increment the current file position
guidata(hObject, handles);

function setDraggables(hObject, handles)
%read the file
filename = handles.src_anchor_pos(handles.fileindex_current).name;
filepath = fullfile(handles.input_folder_name, filename);
set(handles.posfile, 'String', filename);

%center points of the anchors
% refpoints = pointsFromFile(filepath);
% im1 = handles.current_im;
% im1 = getmorph(im1, refpoints);
% centerpoints = getcenterpoints(im1, refpoints);
centerpoints = pointsFromFile(filepath);

%set the position of the draggables on the main image
center_shift = 16.5; %distance of left corner from the center point
handles.center_shift = center_shift;
rect_width = 2*center_shift;
main_pos = centerpoints-center_shift;

%set the position of the draggables on the auxiliary views
axislimit = [centerpoints-50 centerpoints+50];
xlimit = axislimit(:, [1 3]);
ylimit = axislimit(:, [2 4]);

handles.main_pos = main_pos;
handles.centerpoints = centerpoints;
im = handles.current_im; %current image
h_axes = handles.anchor_axes; %anchor axes object array

%rectangle objects for the main gui and for the anchor_axes
main_anchors_rect = gobjects(1, 8);
single_anchor_rect = gobjects(1, 8);

%plot rectangle on main image
axes(handles.fullimage_axes);
for t=1:8
   %build the rectangle
   main_anchors_rect(t) = rectangle('Position', [main_pos(t, :) rect_width rect_width], 'FaceColor', 'r', 'Curvature', [1 1], 'EdgeColor', 'r');
    main_anchors_rect(t).HitTest = 'off';
end
% draggable(main_rect);
handles.main_anchors_rect = main_anchors_rect;

%plot on auxilliary axis
for t=1:8
   %build the rectangle
   axes(h_axes(t));
   cla
   imshow(im, 'Parent', h_axes(t)); %plot the image
   h_axes(t).XLim = xlimit(t, :);
   h_axes(t).YLim = ylimit(t, :);
   single_anchor_rect(t) = rectangle('Position', [main_pos(t, :) rect_width rect_width], 'FaceColor', 'r', 'EdgeColor', 'r', 'Curvature', [1 1]);
   set(ancestor(handles.anchor_axes(t), 'figure'),'KeyPressFcn', @move_rectangle);
end
handles.single_anchor_rect = single_anchor_rect;
draggable(single_anchor_rect);

% Update handles structure
guidata(hObject, handles);