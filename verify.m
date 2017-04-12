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

% Last Modified by GUIDE v2.5 12-Apr-2017 14:58:42

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
char_index = handles.char_index;
file_index = handles.file_index;
file_index_max = handles.file_index_max;

if char_index >= 60
    charfname = handles.src_anchor_pos(file_index).name;
    filepath = fullfile(handles.output_folder_name, charfname);
    anchor = handles.anchors;
    pos = handles.char_pos;
    
    savePosition(filepath, anchor, pos);
    if file_index < file_index_max-1
        handles.file_index = file_index+1;
        setView(hObject, handles);
    else
        set(handles.savebtn, 'Enable', 'off');
    end
else
    handles.char_index = char_index + 1;
    setCharView(hObject, handles);
end
handles = guidata(hObject);

%save and update the index file
fileid = fopen(fullfile(handles.input_folder_name, 'config.txt'), 'w');
fprintf(fileid, '%d', file_index);
fclose(fileid);

guidata(hObject, handles);
    

% --- Executes on button press in output_folder_btn.
function output_folder_btn_Callback(hObject, eventdata, handles)
output_folder_name = uigetdir('C:\Users\kkmlover\Documents\DJIMY\WORK\temp');
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
input_folder_name = uigetdir('C:\Users\kkmlover\Documents\DJIMY\WORK\temp');
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
handles.file_index_max = length(src_im);
handles.file_index = index;
handles.current_section_index = 1;

setView(hObject, handles);
handles = guidata(hObject);
set(handles.savebtn, 'Enable', 'on');

guidata(hObject, handles);

%function to display the images on the differents views
function setView(hObject, handles)
%display the image at fileindex_current
index = handles.file_index;
handles.char_index = 1;
char_index = 1;

%anchor and char pos and image path
charfname = handles.src_anchor_pos(index).name;
posfname = fullfile(handles.input_folder_name, charfname);
imfname = fullfile(handles.input_folder_name, handles.src_im(index).name);

%center points of the anchors
[anchors, char_pos, main_rect_pos] = pointsFromFile(posfname);

%current image
im = imread(imfname);

%plot to main_axes
h = imshow(im, 'Parent', handles.main_axes);
axes(handles.main_axes);
handles.main_rect = rectangle('Position',main_rect_pos(1,:), 'EdgeColor','r');

%plot to section_axes
imagesc(im, 'Parent', handles.section_axes);
axes(handles.section_axes);
section_pos = main_rect_pos(1, :); %first rectangle on the main axes
xlim([section_pos(1) section_pos(3)+section_pos(1)-450]);
ylim([section_pos(2) section_pos(2)+section_pos(4)-100]);
sect_char_pos = [char_pos(1) char_pos(1) char_pos(3)-char_pos(1)  char_pos(4)-char_pos(2)];
handles.char_rect = rectangle('Position',sect_char_pos, 'EdgeColor','r');

%plot to char_axes
h_char = imshow(im, 'Parent', handles.char_axes);
axes(handles.char_axes);
posc = char_pos(1,:,char_index); % 1rst row, all col, 1rst layer
xlim([posc(1)-5 posc(3)+5]);
ylim([posc(2)-5 posc(4)+5]);

%update info displayed on the gui
set(handles.posfilename_label, 'String', charfname);
set(handles.imfilename_label, 'String', handles.src_im(index).name);
counter = strcat(num2str(index), '/', num2str(handles.file_index_max));
set(handles.counter_label, 'String', counter);

%display the draggable rectangles
setDraggables(hObject, handles, section_pos, posc);
handles = guidata(hObject);

%add page info to the guidata space
handles.anchors = anchors;
handles.char_pos = char_pos;
handles.single_char_pos = posc;
handles.main_rect_pos = main_rect_pos;
handles.current_im = im;
handles.char_index = char_index;

%set callbacks
set(h_char, 'ButtonDownFcn',@adjustBox);
% set(h, 'ButtonDownFcn', {@setFocus, handles, 0, 1});

guidata(hObject, handles);

function setDraggables(hObject, handles, section_pos, char_pos)

%set the position of the draggables on the main image
handles.main_rect.Position = section_pos;

%set the position of the draggables on the section_view
sect_char_pos = [char_pos(1) char_pos(2) char_pos(3)-char_pos(1)  char_pos(4)-char_pos(2)];
handles.char_rect.Position = sect_char_pos;

%set the position of the draggables on the char_view
[~, ~] = setBox(handles.char_axes, char_pos);

% Update handles structure
guidata(hObject, handles);

function [anchor, char_pos, main_rect_pos] = pointsFromFile(filepath)
char_pos = zeros(20, 4, 3); % 3 layers position file

%extract the positions
fileid = fopen(filepath, 'r');

%anchor position
file = textscan(fileid, '%d %f %f', 8, 'HeaderLines', 1, 'Whitespace',' \b\t:(,)');
anchor = [file{1, 2} file{1, 3}];

%char1 position
file = textscan(fileid, '%d %d %d %d %d', 20, 'HeaderLines', 4, 'Whitespace',' \b\t:(,)');
char_pos(:,:,1) = [file{1, 2} file{1, 3} file{1, 4} file{1, 5}];

%char2 position
file = textscan(fileid, '%d %d %d %d %d', 20, 'HeaderLines', 3, 'Whitespace',' \b\t:(,)');
char_pos(:,:,2) = [file{1, 2} file{1, 3} file{1, 4} file{1, 5}];

%char3 position
file = textscan(fileid, '%d %d %d %d %d', 20, 'HeaderLines', 3, 'Whitespace',' \b\t:(,)');
char_pos(:,:,3) = [file{1, 2} file{1, 3} file{1, 4} file{1, 5}];

%add shift
anchor = anchor + 1;
char_pos = char_pos + 1;

%main_rect_pos
main_rect_pos(1, :) = [anchor(1, 1) anchor(1, 2) anchor(5, 1)-anchor(1, 1) anchor(2, 2)-anchor(1, 2)];
main_rect_pos(2, :) = [anchor(2, 1) anchor(2, 2) anchor(6, 1)-anchor(2, 1) anchor(3, 2)-anchor(2, 2)];
main_rect_pos(3, :) = [anchor(3, 1) anchor(3, 2) anchor(7, 1)-anchor(3, 1) anchor(4, 2)-anchor(3, 2)];

fclose(fileid);

function [linev, lineh] = setBox(ax, pos)
%delete the current object
h = findobj(ax,'Type','Line');
delete(h);

x1 = pos(1); y1 = pos(2);
x2 = pos(3); y2 = pos(4);

x = x1-0.5:x2+0.5;
y = y1-0.5:y2+0.5;

%vertical
xv = zeros(1, 2*numel(x));
xv(1:2:end) = x;
xv(2:2:end) = x;

yv = repmat([y(1) ; y(end)], 1, numel(x));
yv(:,2:2:end) = flipud(yv(:,2:2:end));

xv = xv(:);
yv = yv(:);

%horizontal
yh = zeros(1, 2*numel(y));
yh(1:2:end) = y;
yh(2:2:end) = y;

xh = repmat([x(1) ; x(end)], 1, numel(y));
xh(:,2:2:end) = flipud(xh(:,2:2:end));

xh = xh(:);
yh = yh(:);

%plot lines
axes(ax)
linev = line(xv, yv, 'Color','red');
lineh = line(xh, yh,'Color','red');

function setCharView(hObject, handles)
char_index = handles.char_index;
idx = mod(char_index-1, 20) + 1;
layer = floor((char_index-1)/20) + 1;

char_pos = handles.char_pos(idx,:, layer);
main_rect_pos = handles.main_rect_pos(layer,:);

if char_index == 21 || char_index == 41
    axes(handles.section_axes);
    section_pos = main_rect_pos(1, :); %first rectangle on the main axes
    xlim([section_pos(1) section_pos(3)+section_pos(1)-450]);
    ylim([section_pos(2) section_pos(2)+section_pos(4)-100]);
end

%set limit on char view
axes(handles.char_axes);
posc = char_pos; % 1rst row, all col, 1rst layer
xlim([posc(1)-5 posc(3)+5]);
ylim([posc(2)-5 posc(4)+5]);

setDraggables(hObject, handles, main_rect_pos, char_pos);
handles = guidata(hObject);

guidata(hObject, handles);

%function to move the box
function adjustBox(hObject, eventdata)
handles = guidata(gcbo);
char_index = handles.char_index;
idx = mod(char_index-1, 20) + 1;
layer = floor((char_index-1)/20) + 1;

char_pos = handles.char_pos(idx,:,layer);
cp = get(handles.char_axes, 'CurrentPoint');
cp = [cp(1, 1) cp(1, 2)];
cp = round(cp);

temp1 = char_pos(1, [1 2]);
temp2 = char_pos(1, [3 4]);

d1 = sqrt(sum((temp1-cp).^2, 2));
d2 = sqrt(sum((temp2-cp).^2, 2));

if d1 <= d2
    char_pos = [cp temp2];
else
    char_pos = [temp1 cp];
end

handles.single_char_pos = char_pos;
handles.char_pos(idx,:,layer) = char_pos;
[~, ~] = setBox(handles.char_axes, char_pos);

guidata(hObject, handles);

%save the position of the character in a file
function savePosition(filepath, anchor, pos)
pos = pos-1;
%get char unicode
c = strsplit(filepath, {'_', '.'});
deg = c{end-2};
uni3 = c{end-3};
uni2 = c{end-4};
uni1 = c{end-5};

idx = 1:8;
anchor = [idx' anchor]';

idx = 1:20;
pos1 = [idx' pos(:,:,1)]';
pos2 = [idx' pos(:,:,2)]';
pos3 = [idx' pos(:,:,3)]';

%output the positions to a file in the output folder
fileid = fopen(filepath, 'w');
fprintf(fileid, '%s\r\n', '[ Anchor Points ]');
fprintf(fileid, ' %d : (  %6.1f , %6.1f )\r\n', anchor);

fprintf(fileid, '\r\n[ Word Contours ] \r\n unicode_brightness: %s_%s \r\n', uni1, deg);
fprintf(fileid, ' %2d : ( %4d , %4d ) , ( %4d , %4d )\r\n', pos1);

fprintf(fileid, '\r\nunicode_brightness: %s_%s \r\n', uni2, deg);
fprintf(fileid, ' %2d : ( %4d , %4d ) , ( %4d , %4d )\r\n', pos2);

fprintf(fileid, '\r\nunicode_brightness: %s_%s \r\n', uni3, deg);
fprintf(fileid, ' %2d : ( %4d , %4d ) , ( %4d , %4d )\r\n', pos3);

fclose(fileid);