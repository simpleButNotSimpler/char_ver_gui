function test()
% test gui function

% create figure
handles.im = imshow('temp.bmp');

handles.rect = rectangle('Position', [1000 1000 500 500]);

% set the figure's WindowButtonDownFcn
set(gcf,'WindowButtonDownFcn',{@wbd});
setappdata(gcf, 'handles', handles);

% ---------------------------
function wbd(h,evd)
handles = getappdata(h,'handles');

points = get(gca, 'CurrentPoint');
points = [points(1, 1), points(1, 2)];

rect_pos = handles.rect.Position;
x1 = rect_pos(1);
y1 = rect_pos(2);
x2 = rect_pos(3)+x1;
y2 = rect_pos(4)+y1;

[x, y] = closestPoint(points, [x1 y1; x2 y2]);

set(h,'WindowButtonMotionFcn',{@wbm, x, y, handles.rect})
set(h,'WindowButtonUpFcn',{@wbu})

% ---------------------------
function wbm(h,evd, x, y, rect)
% executes while the mouse moves
points = get(gca, 'CurrentPoint');
points = [points(1, 1), points(1, 2)];
points = floor(points) + 0.5;

if points(1) > x && points(2) > y
    [points(1), x] = swap(points(1), x);
    [points(2), y] = swap(points(2), y);
elseif points(2) > y
    [points(2), y] = swap(points(2), y);
elseif points(1) > x
    [points(1), x] = swap(points(1), x);
end

rect.Position = [points abs(x-points(1)) abs(y-points(2))];

% ---------------------------
function wbu(h,evd)
% executes when the mouse button is released

disp('up')
set(h,'WindowButtonMotionFcn','')
set(h,'WindowButtonUpFcn','')

function [x y]  = swap(x1, y1)
x = y1;
y = x1;

function [x, y] = closestPoint(point, point_set)
point = repmat(point, 2, 1);
point = point_set - point;
point = sqrt(sum(point.^2, 2));

[~, idx] = max(point);
val = point_set(idx, :);
x = val(1);
y = val(2);
