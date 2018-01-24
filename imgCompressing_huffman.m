% imgCompressing_huffman.m

function varargout = imgCompressing_huffman(varargin)
% IMGCOMPRESSING_HUFFMAN MATLAB code for imgCompressing_huffman.fig
%      IMGCOMPRESSING_HUFFMAN, by itself, creates a new IMGCOMPRESSING_HUFFMAN or raises the existing
%      singleton*.
%
%      H = IMGCOMPRESSING_HUFFMAN returns the handle to a new IMGCOMPRESSING_HUFFMAN or the handle to
%      the existing singleton*.
%
%      IMGCOMPRESSING_HUFFMAN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMGCOMPRESSING_HUFFMAN.M with the given input arguments.
%
%      IMGCOMPRESSING_HUFFMAN('Property','Value',...) creates a new IMGCOMPRESSING_HUFFMAN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before imgCompressing_huffman_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to imgCompressing_huffman_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help imgCompressing_huffman

% Last Modified by GUIDE v2.5 27-Mar-2017 16:56:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @imgCompressing_huffman_OpeningFcn, ...
                   'gui_OutputFcn',  @imgCompressing_huffman_OutputFcn, ...
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


% --- Executes just before imgCompressing_huffman is made visible.
function imgCompressing_huffman_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to imgCompressing_huffman (see VARARGIN)

% �ѽ����ƶ�����Ļ����
movegui(hObject, 'center');

% ȫ�����ʵı���
global SOURCE_PROBABILITY;         % ��Դ����
global SYMBOL;                     % ��Դ����
global SOURCE_COUNT;               % ��Դ���Ÿ���
global DICT;                       % �������롢�������е������ֵ�
global HUFFMANTREE;                % ����������
global NEXT_STEP_BUTTON_ENTRY_CNT; % ��¼show_next_step_button�����ô���
       NEXT_STEP_BUTTON_ENTRY_CNT = 0;
global ENCODING_MODE;              % ����ʱ�0����С���ʱ�0������
       ENCODING_MODE = 0;
% huffman������֮��ľ��룬��λ�����굥λ����ֵ��Ϊ��̫�����ڳ�����
% ��̬�仯������Ϊhandles��һ������level_space_interval
handles.level_space_interval = 2;

% ����������
set(handles.axes_demoArea,'Visible','off');

% ���������ж�
h_interruptible_list = findobj(hObject, '-property','Interruptible');
set(h_interruptible_list, 'Interruptible', 'off');
% ͳһ����String���ԵĿؼ���������ʽ��ע�⣡��������Ḳ��guide�н��е����ã�
% Ҳ����˵��������guide�и���ť����ʲô�������ƺʹ�С�����ᱻ���ӵ�
% ��Ӱ���GUI����text������axes�ϵ��Ǹ�text������edit��pushbutton��radiobutton
h_property_string_list = findobj(hObject, '-property','String');
set(h_property_string_list, 'FontSize',10.0);
set(h_property_string_list, 'FontName','΢���ź�');
% ͳһ���к���Title���ԵĿؼ���������ʽ
% ��Ӱ��GUI�Ķ���uipanel
h_property_title_list = findobj(hObject, '-property','Title');
set(h_property_title_list, 'FontSize',10.0);
set(h_property_title_list, 'FontName','΢���ź�');

% ���������ݵ���ʼ״̬��
guiResetAll(handles);

% Choose default command line output for imgCompressing_huffman
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes imgCompressing_huffman wait for user response (see UIRESUME)
% uiwait(handles.figure_imgCompressing_huffman);


% --- Outputs from this function are returned to the command line.
function varargout = imgCompressing_huffman_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%--------------------------------------------------------------------------
%                             �ǻص�����
%--------------------------------------------------------------------------
function guiShowEncodeResult(hObject, eventdata, handles)
% �ÿؼ�Ϊ����ʾ������̡�״̬
set(handles.button_next,'Enable','on');  %  ����һ������ťʹ��
set(handles.button_startDemo, 'Enable','off')  % �����ɹ�����������ť��ֹ
set(handles.button_decode,'Enable','off');             % �����롱��ť��ֹ
set(handles.edit_sourceProbability,'Enable','off');  % ��Դ������ֹ
set(handles.edit_sourceSymbol, 'Enable', 'off');   % ��Դ���ſ��ֹ
set(handles.radiobutton_encodingMode_0, 'Enable', 'off');  % ���õ�ѡ��ť
set(handles.radiobutton_encodingMode_1, 'Enable', 'off');

%--------------------------------------------------------------------------
function guiResetAll(handles)
%guiResetAll ����һ��
guiResetWidget(handles);
guiResetEnable(handles);

%--------------------------------------------------------------------------
function guiResetWidget(handles)
%guiResetWidget ��������Ϊ��ʼ״̬
global NEXT_STEP_BUTTON_ENTRY_CNT;
global ENCODING_MODE;
ENCODING_MODE = 0;
set(gcf,'CurrentAxes',handles.axes_demoArea);  % axes(handles.axes_demoArea)
cla;
NEXT_STEP_BUTTON_ENTRY_CNT = 0;
set(handles.text_decodeResult,'String','');
set(handles.text_averageCodeLength,'string','');
set(handles.text_sourceEntropy,'string','');
set(handles.text_codingEfficiency,'string','');
set(handles.edit_sourceProbability,'string','0.25, 0.25, 0.2, 0.15, 0.10, 0.05');
set(handles.edit_sourceSymbol,'string','''i'',''r'',''a'',''k'',''u'',''Y''');
set(handles.edit_sequenceToDecode,'String','00010000001111001');  % �趨һ����ʼ���Ŀ������ֵ
set(handles.radiobutton_encodingMode_1,'Value',0);    % ȡ��ѡ��ģʽ1
set(handles.radiobutton_encodingMode_0,'Value',1);    % ѡ��ģʽ0

%--------------------------------------------------------------------------
function guiResetEnable(handles)
%guiResetEnable ����GUI�ؼ�ʹ��Ϊ��ʼ״̬
set(handles.button_startDemo,'Enable','on');  % ����ʹ�ܡ����ɹ�����������ť
set(handles.button_decode,'Enable','off');             % �����롱��ť��ֹ
set(handles.button_next, 'Enable', 'off');  % ������һ����ť
set(handles.radiobutton_encodingMode_0, 'Enable', 'on');  % ʹ�ܵ�ѡ��ť
set(handles.radiobutton_encodingMode_1, 'Enable', 'on');
set(handles.edit_sourceProbability,'Enable','on');  % ����ʹ����Դ�����
set(handles.edit_sourceSymbol, 'Enable', 'on');   % ʹ����Դ���ſ�

%--------------------------------------------------------------------------
function [status, probability, count, symbol] = evalUserInput(input_string_1, input_string_2)
%evalUserInput ����û�����
% input_string_1����ʾ��Դ���ʵ��ַ���
% input_string_2����ʾ��Դ���ŵ��ַ���
% �����ȷ��status = true��probability��count�ֱ�ֵ��Դ���ʾ������Դ���Ÿ���
% ������󣬵���error��ʾ��status = false, probability = count = NaN
status = true;
try
    mat = eval(strcat('[', input_string_1, ']'));
    symbol = eval(strcat('{', input_string_2, '}'));
catch exception
    errordlg('��������...��������','����','modal');
    error('��������...��������');
end
count = length(mat);
mat_sum = sum(mat);
if (any(mat <= 0))  % mat����<0��Ԫ��
    status = false;
    probability = NaN;
    count = NaN;
    symbol = NaN;
    errordlg('�㲻������һ������/����Ϊ���ʡ�������Ϣ����Command Window���ֵĴ�����Ϣ','����');
    error('ERROR: You cannot give a negative number or zero as probability');
end
if (any(mat >= 1))  % mat����>=1��Ԫ��
    status = false;
    probability = NaN;
    count = NaN;
    symbol = NaN;
    errordlg('�㲻��������ڵ���1������Ϊ���ʡ�������Ϣ����Command Window���ֵĴ�����Ϣ','����');
    error('ERROR: You cannot give a number greater equal than 1 as probability');
end

if (abs(mat_sum - 1) >= 1e-5)  % mat_sum ~= 1.0�����������õ�������ǳ���eps�����ƺ���������ʺܶ��ʱ�򲻺�ʹ
    status = false;
    probability = NaN;
    count = NaN;
    symbol = NaN;
    errordlg('�������֮�Ͳ�����1��������Ϣ����Command Window���ֵĴ�����Ϣ','����');
    error('ERROR: Probabilities do not add up to 1');
end

if (length(symbol) ~= length(mat))
    status = false;
    probability = NaN;
    count = NaN;
    symbol = NaN;
    errordlg('��Դ���ʺ���Դ���Ų��ȳ���������Ϣ����Command Window���ֵĴ�����Ϣ','����');
    error('ERROR: The length of probabilty matrix and symbol cell is not equal');
end
status = true;
probability = mat;

%--------------------------------------------------------------------------
function [ current_array ] = huffmantree_source_shrink( pre_array )
%huffmantree_source_shrink ��pre_array����һ����Դ������
% ���������Ľ��Ϊcurrent_array
%
[pre_len, ~] = size(pre_array);    % ��ȡǰһ����Դ�ĳ���
temp = makeDescend(pre_array);    % ��������
temp_1 = temp(:,1);                % �����1��
temp_2 = temp(:,2);                % �����2��

% �Ȱѳ������2����Դ����֮�����Դ�����������������
current_array = temp((1:(pre_len-1)), :);

% �������������һ��λ�ã�Ҳ���Ǽ�������ǰһ����Դ������������źϲ��Ľ����λ�ã�
% ��ʼ���洢�ռ�
current_array(pre_len-1, :) = [0 0];

% ǰһ����Դ����������ĸ������Ϊ�ϲ���Դ���ŵĸ���
new_node_val = temp_1(pre_len-1) + temp_1(pre_len);

% ȡǰһ����Դ�е����ڶ�����Ҳ���Ǳ��ϲ��������������С���Ǹ�����Ϊ����Դ����
% �ĵ�2����������ǰһ��������Դ�е���š�
new_node_index = temp_2(pre_len-1);

% �����µ���Դ���Žڵ㣬������������������
new_node = [new_node_val, new_node_index];
current_array = insertVar(current_array([1:pre_len-1],:), new_node);

%--------------------------------------------------------------------------
function temp = makeDescend(array)
% �ö�ά����array���ݵ�һ�н��������е�����Matlab���е�sortrows����
[len, ~] = size(array); 
temp = zeros(len,2);
[temp(:,1), temp(:,2)]= sort(array(:,1),'descend');

%--------------------------------------------------------------------------
% This function will insert a node in the sorted list such that the
% resulting list will be sorted (descending). If there exists node with the
% same probability as the new node, the new node  is placed BEFORE these
% same value nodes.
function new_tree = insertVar(huff_tree, newNode)
i = 1;
[len, ~] = size(huff_tree);
temp_1 = huff_tree(:,1);
temp_2 = huff_tree(:,2);
while (i <= len) && (newNode(1,1) < temp_1(i));
    i = i+1;
end
new_tree(:,1) = [temp_1(1:i-1)' newNode(1,1) temp_1(i:end-1)']';
new_tree(:,2) = [temp_2(1:i-1)' newNode(1,2) temp_2(i:end-1)']';


%--------------------------------------------------------------------------
function [ tree ] = huffmantree_generate( source )
%huffmantree_generate ������Դ���ʾ�������haffman����������ʽ�ģ�
%   tree���������
%   ��iҳ��ʾ��i-1��������Դ�����Դ����
%   ����һ���ض��ĵ�iҳ��
%      ����ĵ�1�б�ʾ��ǰ��Դ�ĸ���
%      ��2�б�ʾ��ǰ��Դ������֮ǰ�ģ����ڵ�i-1���еģ��±�
[rows, ~] = size(source');
first_source = zeros(rows, 2);    % ��ʼ����1������ݽṹ�Ĵ洢�ռ�
first_source(:,1) = source;       % Ϊ��1��ĵ�1��������Դ����
first_source(:,2) = 1:1:rows;     % Ϊ��1��ĵ�2��������ţ��������±꣩
first_source = makeDescend(first_source);    % �Ե�1��Ϊ��׼��������
tree = cell(1,rows);              % ��ʼ�������������Ĵ洢�ռ�
tree{1} = first_source;           % �ѵ�1������ݽṹ����ŵ������������ĵ�1��Ԫ����

% ���������Դ���ʲ��������������Ӧ�Ĳ��С�
% huffmantree_source_shrink������������Դ�õ���������Դ
for k = 2:1:(rows)
    tree{k} = huffmantree_source_shrink(tree{k-1});    
end

%--------------------------------------------------------------------------
function [ code ] = huffmantree_encode_getcode( tree, symbol_index, mode)
%huffmantree_encode Ϊhuffmantree_generate���ɵ�huffman������
% ����symbol_index�ǳ�ʼ��Դ����ţ�1,2,3,4,5...��˳������֣�
% ����mode��������ʱ�0���Ǳ�1
% mode == 0 �� ����ʱ�0
% mode == ������ ����ʱ�1

[~, n] = size(tree);             % ��ȡ�����Ĳ���
[source_len,~] = size(tree{1});  % ��ȡ��Դ������
pre_index = symbol_index;        % ��ȡ��ʼ��Դ�������Ϊ��1��ѭ���ġ���ǰһ��������Դ�е���š�
code = char([]);                 % ��������洢�ռ�ı�����Ϊcode

for i=1:1:(n-1)
%     current_array_1 = tree{i}(:,1);
    current_array_2 = tree{i}(:,2);         % ��ȡ��ǰ��ĵ�2����������ǰһ��������Դ�е���š�
    local_sequence = 1:(source_len-i+1);    % ���ɵ�ǰ��ı�����ţ���˳���1,2,3...���֣�����
    
    % ���Ҵ��������Դ���ŵġ���ǰһ��������Դ�е���š���Ӧ�ı��������ʲô
    % ע�����������ž�����һ��ѭ���ġ���ǰһ��������Դ�е���š������Ա���
    % �����ж�������Ӧ�����pre_index = local_index;
    local_index = local_sequence(current_array_2 == pre_index);
    
    % �Ҳ���������ֻ��һ�ֿ��ܣ������Դ��������һ������һ�����ϲ��ķ��ţ�����
    % huffmantree_source_shrink�ƶ������ɹ��򣬱��ϲ�����Դ����ʹ�õġ���ǰһ
    % ��������Դ�е���š���ǰһ������Ž�С���Ǹ�������ֻҪ��pre_index��ȥ1��
    % �Ϳ����ҵ�������ϲ��ķ���
    if (isempty(local_index))
        local_index = local_sequence(current_array_2 == (pre_index - 1)); 
    end
    
    if (mode == 0)                            % ����ʱ�0
        if (local_index == (source_len-i))    % �ǵ�ǰ��ĵ�����1��Ԫ�أ���0
            code = strcat(code, '0');
        elseif (local_index == (source_len-i+1))  % �ǵ�ǰ��ĵ�����2��Ԫ�أ���1
            code = strcat(code,'1');
        end
    else                                      % ����ʱ�1
        if (local_index == (source_len-i))    % �ǵ�ǰ��ĵ�����1��Ԫ�أ���1
            code = strcat(code, '1');
        elseif (local_index == (source_len-i+1)) % �ǵ�ǰ��ĵ�����2��Ԫ�أ���0
            code = strcat(code,'0');
        end
    end
    pre_index = local_index;
end
code = fliplr(code);

%--------------------------------------------------------------------------
function avg_len = getAvgCodeLen(codes, source)
%getAvgCodeLen ��ƽ���볤
avg_len = 0;
source_count =length(source);
for i = 1:source_count
    avg_len = avg_len + source(i) * length(codes{i});
end

%--------------------------------------------------------------------------
function H = getSourceEntropy(source, source_count)
%getSourceEntropy ����Դ�� ��λbit/����
s = 0;
for i=1:1:source_count
    s = s + source(i)*log2(source(i));
end
s = -s;
H = s;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%��ͼ���%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function drawTreeLevel(tree_level_content, current_level,...
                         level_space_interval, top_level_nodes_count)
%drawTreeLevel ����ĳһ�����Դ����
% ����tree_level_content����ǰ��Դ���ʾ���
% ����current_level����Ҫ�������Դ���ʾ�������һ��
% ����level_space_interval������ˮƽ����������������������
% ����top_level_nodes_count���������ĵ�һ���ж��ٸ���Դ���š��༴��ʼ��Դ������
current_level_nodes_count = top_level_nodes_count - current_level + 1;
for i = 1:1:(current_level_nodes_count)
    % ��ʶ����
    text(1 + level_space_interval * (current_level-1) ,...
         i, num2str(tree_level_content(i)));
end

%--------------------------------------------------------------------------
function drawConnectionLines(tree_level_a_content, tree_level_b_content, ...
                               level_a, level_space_interval, ...
                               top_level_nodes_count, mode)
%drawConnectionLines ����������������֮���������
% ����tree_level_a_content��ǰһ�����Դ����
% ����tree_level_b_content����һ�����Դ����
% ����level_a��ǰһ����ǵڼ��㣿
% ����level_space_interval�����ƴ�ֱ���������������ź�Դ���ʻ��Ƶ���������
% ��������Ĵ���ֵ����ͺ���draw_tree_level��level_space_interval����ֵ��ͬ
% ����top_level_nodes_count���������ĵ�һ���ж��ٸ���Դ���š��༴��ʼ��Դ������
% ����mode ��������ʱ�0����С���ʱ�0
% mode == 0������ʱ�0���������С���ʱ�0

level_b = level_a + 1;       % ��һ���ǵڼ��㣿
% ǰ�������ĺ�����
level_a_x = 1 + level_space_interval * (level_a - 1);
level_b_x = 1 + level_space_interval * (level_b - 1);
% ��������delta��΢������
delta_1 = 0.5;
delta_2 = 0.2;
source_len = length(tree_level_b_content);
% �Ȼ��ƴ�tree_level_a_content��������ڵ�֮��Ľڵ��������߶Ρ�
% ��������ڵ���Ҫ��������
current_level_nodes_count = top_level_nodes_count - level_a + 1;
for i = 1:1:(current_level_nodes_count - 2)
    local_sequence = 1:source_len;
    j = local_sequence(tree_level_b_content == i);
    if (isempty(j))
        j = local_sequence(tree_level_b_content == (i - 1)); 
    end
    line([level_a_x + delta_1, level_b_x - delta_2], [i, j]);
% ����δ���Ļ��ƺ���ʲôҲ����������
%     if (i == j)  % ����ˮƽֱ��
%         line([level_a_x + delta_1, level_b_x - delta_2], [i, i]);
%     else    % ��������
%         line([level_a_x + delta_1, level_b_x - delta_2 * 2], [i, i]);
%         line([level_b_x - delta_2 * 2, level_b_x - delta_2 * 2], [i, j]);
%         line([level_b_x - delta_2 * 2, level_b_x - delta_2], [j, j]);
%     ends
end
i = (current_level_nodes_count - 1);
local_sequence = 1:source_len;
j = local_sequence(tree_level_b_content == i);
if (isempty(j))
    j = local_sequence(tree_level_b_content == (i - 1)); 
end
line([level_a_x + delta_1, level_a_x + delta_1 * 2], [i, i]);    % ���ϲ���Դ���ŵ�ˮƽ������
line([level_a_x + delta_1, level_a_x + delta_1 * 2], [i+1, i+1]); % ���ϲ���Դ���ŵ�ˮƽ������
line([level_a_x + delta_1 * 2, level_a_x + delta_1 * 2], [i, i+1]); % �������ϲ���Դ���ŵ�ˮƽ������ĩ���ô�ֱ������
line([level_a_x + delta_1 * 2, level_b_x - delta_2], [i+0.5, j]); % �������Ǹ���ֱ�߶ε��е�ָ����һ���кϲ��ĵ�����Դ����
if (mode == 0)   % ����ʱ�0����Ƿ���ı���
    text(level_a_x + delta_1 * 2, i, '0', 'Color',[0.42 0 0.82]);
    text(level_a_x + delta_1 * 2, i+1, '1', 'Color',[0.42 0 0.82]);
else    % С���ʱ�0
    text(level_a_x + delta_1 * 2, i, '1', 'Color','red');
    text(level_a_x + delta_1 * 2, i+1, '0', 'Color','red');
end

%--------------------------------------------------------------------------
function string = cellarr2string(cellarr)
% ��������{'a','b','cd'}������Ԫ��ת�����ַ���'abcd'
len = length(cellarr);
string = char([]);
string_cell = cell(1,len);
for k=1:len
    string_cell{k} = cellarr{k};
end

for k=1:len
%     string = strcat(string, string_cell{k});    %
%     ʹ��strcat��ɾ���ַ���ǰ��Ŀո񡢻��С�tab��
    string = horzcat(string, string_cell{k});
end
% string

%--------------------------------------------------------------------------
function num = code2num(string)
% ��stringת������һ����double������ɵľ���
len = length(string);
num = zeros(1,len);
for k=1:len
    num(k) = str2num(string(k));
end

%--------------------------------------------------------------------------
function [dict] = makeDict(sign, codes)
% makeDict ʹ��huffmantree_encode_getcode�õ�������Ԫ��������codes��Ϊ����
% ��������sign�����������ֵ䡣
len = length(codes);
dict = cell(len,2);
for i = 1:len
    dict(i,1) = {sign{i}};
    dict(i,2) = {code2num(codes{i})};
end
%----------------------------�ǻص����� end--------------------------------

%--------------------------------------------------------------------------
%                              �ص�����
%--------------------------------------------------------------------------

% --- Executes during object creation, after setting all properties.
function edit_sourceProbability_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sourceProbability (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in button_startDemo.
function button_startDemo_Callback(hObject, eventdata, handles)
% hObject    handle to button_startDemo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global HUFFMANTREE;
global SOURCE_PROBABILITY;
global SOURCE_COUNT;
global SYMBOL;
set(handles.text_averageCodeLength,'string','');
set(handles.text_sourceEntropy,'string','');
set(handles.text_codingEfficiency,'string','');
user_input_1 = get(handles.edit_sourceProbability,'string');  % ��ȡ�û��������Դ����
user_input_2 = get(handles.edit_sourceSymbol,'string'); % ��ȡ�û��������Դ����
[status,SOURCE_PROBABILITY,SOURCE_COUNT,SYMBOL] = evalUserInput(user_input_1,user_input_2);
top_level_nodes_count = SOURCE_COUNT;
level_space_interval = handles.level_space_interval;
% level_space_interval = 2;

set(gcf,'CurrentAxes',handles.axes_demoArea);  % axes(handles.axes_demoArea)
set(handles.axes_demoArea,'YDir','reverse');  % ��y����������
cla;  % ���֮ǰ��������
if status == false
    error('Exited due to a previous error');
end

HUFFMANTREE = huffmantree_generate(SOURCE_PROBABILITY);

% ����Դ���ź�һЩ����
source_symbols = HUFFMANTREE{1}(:,2);
text(-1,0, '����');
text(0 ,0, '��Դ����');
for i = 1:1:(top_level_nodes_count)
    
    text(0 ,i, SYMBOL{source_symbols(i)});
end
% ����Դ����
drawTreeLevel(HUFFMANTREE{1}(:,1),1 ,level_space_interval, top_level_nodes_count);
set(handles.axes_demoArea,'XLim',[-1.5, (level_space_interval * (top_level_nodes_count))], ...
                  'YLim',[0, (top_level_nodes_count + 0.5)]);
guiShowEncodeResult(hObject, eventdata, handles);

%--------------------------------------------------------------------------
function button_startDemo_ButtonDownFcn(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function text_averageCodeLength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_averageCodeLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function text_sourceEntropy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_sourceEntropy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function text_codingEfficiency_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_codingEfficiency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in button_reset.
function button_reset_Callback(hObject, eventdata, handles)
guiResetAll(handles);


% --- Executes during object creation, after setting all properties.
function result_area_huffman_tree_CreateFcn(hObject, eventdata, handles)
% hObject    handle to result_area_huffman_tree (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function button_startDemo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to button_startDemo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


%--------------------------------------------------------------------------
function menuitem_file_Callback(hObject, eventdata, handles)
% hObject    handle to menuitem_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%--------------------------------------------------------------------------
function menuitem_edit_Callback(hObject, eventdata, handles)
% hObject    handle to menuitem_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%--------------------------------------------------------------------------
function menuitem_view_Callback(hObject, eventdata, handles)
% hObject    handle to menuitem_view (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%--------------------------------------------------------------------------
function menuitem_help_Callback(hObject, eventdata, handles)
% hObject    handle to menuitem_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%--------------------------------------------------------------------------
function menuitem_showDoc_Callback(hObject, eventdata, handles)
% if exist('HELP/index.html','file') == 2
%     web('HELP/index.html','-browser');
% else
%     msgbox('û�ҵ������ĵ��������ĵ�ȷʵ�ŵ���ǰĿ¼��HELPĿ¼������','��ʾ');
% end
web 'https://zh.wikipedia.org/wiki/%E9%9C%8D%E5%A4%AB%E6%9B%BC%E7%BC%96%E7%A0%81' -browser

%--------------------------------------------------------------------------
function button_next_Callback(hObject, eventdata, handles)
global HUFFMANTREE;
global NEXT_STEP_BUTTON_ENTRY_CNT;
global ENCODING_MODE;
global SOURCE_PROBABILITY;
global SOURCE_COUNT;
% global SOURCE_PROBABILITYs;
global SYMBOL;
global DICT;
% disp('button_next');
NEXT_STEP_BUTTON_ENTRY_CNT = NEXT_STEP_BUTTON_ENTRY_CNT + 1;
set(gcf,'CurrentAxes',handles.axes_demoArea);  % axes(handles.axes_demoArea)
level_space_interval = handles.level_space_interval;
top_level_nodes_count = SOURCE_COUNT;

% �ӵ�2�㿪ʼ����������Դ���ʺ���������֮���������
if NEXT_STEP_BUTTON_ENTRY_CNT <= (top_level_nodes_count - 1)
    k = NEXT_STEP_BUTTON_ENTRY_CNT;
    drawTreeLevel(HUFFMANTREE{k+1}(:,1),k+1 ,level_space_interval, top_level_nodes_count);
    drawConnectionLines(HUFFMANTREE{k}(:,2), HUFFMANTREE{k+1}(:,2),...
                     k, level_space_interval, top_level_nodes_count, ENCODING_MODE);
end

if NEXT_STEP_BUTTON_ENTRY_CNT >= (top_level_nodes_count - 1)  % huffman��������
    % ��ȡ����
    for i = 1:1:top_level_nodes_count
        codes{i} = huffmantree_encode_getcode(HUFFMANTREE, i, ENCODING_MODE);
    end
    celldisp(codes);    % ������
    % �����ֻ���ͼ��
    for i = 1:1:(top_level_nodes_count)
        text(-1 ,i, codes{i});
    end
    
    % �����������롢�������е������ֵ�
    DICT = makeDict(SYMBOL, codes);
%     disp('�������ֵ�');
    
    % ��Դ��
    H = getSourceEntropy(HUFFMANTREE{1}(:,1), SOURCE_COUNT);
    
    % ƽ���볤
    N = getAvgCodeLen(codes, SOURCE_PROBABILITY);
    
    % ����Ч��
    P = H / N;
    % ����GUI�Ҳ����ʾ��
    set(handles.text_averageCodeLength,'string',num2str(N));
    set(handles.text_sourceEntropy,'string',num2str(H));
    set(handles.text_codingEfficiency,'string',num2str(P));
    NEXT_STEP_BUTTON_ENTRY_CNT = 0;  % ��������λ
    set(handles.edit_sourceProbability,'Enable','on');  % ����ʹ����Դ�����
    set(handles.edit_sourceSymbol, 'Enable', 'on');   % ʹ����Դ���ſ�
    set(handles.button_startDemo,'Enable','on');  % ����ʹ�ܡ����ɹ�����������ť
    set(handles.button_decode,'Enable','on');             % �����롱��ťʹ��
    set(handles.button_next, 'Enable', 'off');  % ���á���һ������ť
    set(handles.radiobutton_encodingMode_0, 'Enable', 'on');  % ʹ�ܵ�ѡ��ť
    set(handles.radiobutton_encodingMode_1, 'Enable', 'on');
end

%--------------------------------------------------------------------------
function encoding_mode_SelectionChangeFcn(hObject, eventdata, handles)
global ENCODING_MODE;
set(handles.button_decode, 'Enable', 'off');
chosen_val = get(hObject,'tag');
switch chosen_val
    case 'radiobutton_encodingMode_0'
        ENCODING_MODE = 0;
%         disp('0');
    case 'radiobutton_encodingMode_1'
        ENCODING_MODE = 1;
%         disp('1');
    otherwise
        disp('Something must be wrong!');
        error('����Ӧ�ý���˷�֧��һ����ʲô�ط������ˣ�');
end

%--------------------------------------------------------------------------
function edit_sourceSymbol_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function edit_sequenceToDecode_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_sequenceToDecode_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function button_decode_Callback(hObject, eventdata, handles)
global DICT;                       % �������롢�������е������ֵ�
% global SOURCE_COUNT;               % ��Դ���Ÿ���
% global ENCODING_MODE;

% ��ȡ����������
sequence = get(handles.edit_sequenceToDecode,'string');
try
    message_cell = huffmandeco(code2num(sequence), DICT);
    set(handles.text_decodeResult,'String',cellarr2string(message_cell));
catch exception
%     disp('something is wrong');
    set(handles.text_decodeResult,'String','�޷�����')
    switch(exception.identifier)
        case 'comm:huffmandeco:CodeNotFound'
            errordlg('��������������������в����ڵ�����','����', 'modal');
        case 'MATLAB:index_assign_element_count_mismatch'
            errordlg('��ʲô...���ǲ���������������������ʲô��ֵĶ�������',...
                     '��֮��������', 'modal');        
        otherwise
            errordlg('������������Command Window�����','����', 'modal');
            throw(exception);
    end
end

%--------------------------------------------------------------------------
function menuitem_aboutYukari_Callback(hObject, eventdata, handles)
% msgbox('�������������־���޸�','����');
h_fig = figure;
set(h_fig,'units','pixels','Windowstyle','normal','Menubar','none',...
            'Name', '����Yukari','NumberTitle','off','CloseRequestFcn','delete(gcf)');
h_axes = axes;
% axis off;

img = imread('Yukari Yakumo.jpg');
h_img = imshow(img, 'Parent', h_axes);

axes_position = get(h_axes, 'Position');

msg_str = horzcat('Զ�����������˰�����ʲô��������Խ������������', ... 
    char(10),'�������Ѿ����������ϣ�Yukari Yakumo���˰ɡ�');
% h_text = uicontrol(h_fig,'Style','text','Units','Normalized',...
%                    'FontSize',9.0,'Position',[0.05 0.01 0.90 0.075],...
%                    'String',msg_str);
h_text = uicontrol(h_fig,'Style','text','Units','Normalized',...
                   'FontSize',9.0,'Position',[0.05, axes_position(2)-0.077, 0.90, 0.075],...
                   'String',msg_str);

%--------------------------------------------------------------------------
function menuitem_aboutHuffman_Callback(hObject, eventdata, handles)
msg_str = ['ժ��ά���ٿ�',...
    char(10), ...
    char(10), '�������ǲ��ء���������Ӣ�David Albert Huffman��1925��8��9�գ�1999��10��7�գ���', ...
    char(10), '�������������ݣ��������ѧ�ң�Ϊ����������ķ����ߡ���Ҳ����ֽ��ѧ������������',...
    char(10), ...
    char(10), '1944�꣬�ڶ���������ѧȡ�õ������ѧʿ���ڵڶ��������ս�ڼ䣬������������������',...
    char(10), '���ꡣ��������ص�����������ѧ��ȡ�õ������˶ʿ����������ʡ��ѧԺ������ʿ��',...
    char(10), '���޵�����̡�', ...
    char(10), ...
    char(10), '1953�꣬ȡ����Ȼ��ѧ��ʿ���ڹ�����ʿ�ڼ䣬��1952�귢���˻��������롣��ȡ�ò�ʿѧλ��',...
    char(10), '����Ϊ��ʡ��ѧԺ��ʦ��1967�꣬ת��ʥ����³�ȼ��������Ǵ�ѧ�ν̣��ڴˣ���Э��������',...
    char(10), '�������ѧϵ��1970����1973��䣬������ϵ���Ρ�1994�꣬����ѧУ���ݡ�',...
    char(10), ...
    char(10), '1999�꣬����ϳ���֢����ͬ��10�²��š�����74�ꡣ'];
h1 = msgbox(msg_str,'����Huffman');
% get(h1);

%--------------------------------------------------------------------------
function figure_imgCompressing_huffman_CloseRequestFcn(hObject, eventdata, handles)
clear global -regexp SOURCE_PROBABILITY SYMBOL SOURCE_COUNT DICT HUFFMANTREE NEXT_STEP_BUTTON_ENTRY_CNT ENCODING_MODE
% Hint: delete(hObject) closes the figure
delete(hObject);

%------------------------------�ص����� end--------------------------------
